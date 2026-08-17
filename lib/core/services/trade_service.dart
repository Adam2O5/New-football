import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';

class TradeAsset {
  const TradeAsset.player(this.playerId)
    : pickYear = null,
      pickRound = null,
      originalTeamId = null;

  const TradeAsset.pick({
    required this.pickYear,
    required this.pickRound,
    required this.originalTeamId,
  }) : playerId = null;

  final String? playerId;
  final int? pickYear;
  final int? pickRound;

  /// Drużyna, do której pierwotnie należał ten pick (`DraftPick.originalTeamId`)
  /// — wraz z `pickYear`/`pickRound` jednoznacznie identyfikuje konkretny
  /// `DraftPick` w `Team.ownedPicks`.
  final String? originalTeamId;

  bool get isPlayer => playerId != null;
  bool get isPick => pickYear != null;
}

class TradeProposal {
  const TradeProposal({
    required this.teamAId,
    required this.teamBId,
    required this.assetsFromA,
    required this.assetsFromB,
  });

  final String teamAId;
  final String teamBId;
  final List<TradeAsset> assetsFromA;
  final List<TradeAsset> assetsFromB;
}

class TradeValidation {
  const TradeValidation({required this.ok, this.reason});

  final bool ok;
  final String? reason;
}

class TradeService {
  TradeService({
    this.balance = BalanceConfig.defaults,
    SalaryCapService? capService,
    CalendarService? calendarService,
  }) : capService = capService ?? SalaryCapService(balance: balance),
       calendarService = calendarService ?? CalendarService(balance: balance);

  final BalanceConfig balance;
  final SalaryCapService capService;
  final CalendarService calendarService;

  /// Znajduje konkretny `DraftPick` w `team.ownedPicks` odpowiadający
  /// [asset] (dopasowanie po `pickYear`/`pickRound`/`originalTeamId`).
  DraftPick? _findOwnedPick(Team team, TradeAsset asset) {
    for (final p in team.ownedPicks) {
      if (p.year == asset.pickYear &&
          p.round == asset.pickRound &&
          p.originalTeamId == asset.originalTeamId) {
        return p;
      }
    }
    return null;
  }

  /// Wycena handlowa aktywa. [currentYear] jest wymagany dla picków —
  /// wpływa na dyskonto czasowe (`DraftPick.computeTradeValue`).
  int assetValue(Team team, TradeAsset asset, {required int currentYear}) {
    if (asset.isPlayer) {
      final matches = team.roster.where((p) => p.id == asset.playerId);
      if (matches.isEmpty) return 0;
      final player = matches.first;
      final baseValue = player.computePointValue(balance);
      return (baseValue * team.eventState.pointValueMultiplierFor(player.id))
          .round();
    }
    final owned = _findOwnedPick(team, asset);
    if (owned != null) {
      return owned.computeTradeValue(
        currentYear: currentYear,
        balance: balance,
      );
    }
    // Pick nie znaleziony w ownedPicks (np. rozbieżność stanu UI/silnika) —
    // policz wartość "z powietrza" dla podanych parametrów zamiast zwracać 0,
    // żeby okno wymian nie pokazywało fałszywie zerowej wyceny.
    return DraftPick(
      id: 'preview_${asset.originalTeamId}_${asset.pickYear}_r${asset.pickRound}',
      year: asset.pickYear!,
      round: asset.pickRound!,
      teamId: team.id,
      originalTeamId: asset.originalTeamId!,
    ).computeTradeValue(currentYear: currentYear, balance: balance);
  }

  /// Validates a proposed trade. Pass [currentWeek] to also enforce the
  /// trade window (`docs/trade_rules.md`); omit it (e.g. in tests) to skip
  /// that check.
  TradeValidation validate(
    Team a,
    Team b,
    TradeProposal proposal, {
    int? currentWeek,
  }) {
    if (proposal.teamAId != a.id || proposal.teamBId != b.id) {
      return const TradeValidation(ok: false, reason: 'Niezgodne ID drużyn');
    }

    if (currentWeek != null &&
        !calendarService.isTradeWindowOpen(currentWeek)) {
      return const TradeValidation(
        ok: false,
        reason: 'Okno wymian jest zamknięte',
      );
    }

    final picksA = proposal.assetsFromA.where((x) => x.isPick).length;
    final picksB = proposal.assetsFromB.where((x) => x.isPick).length;
    if (picksA > balance.salaryCap.maxPicksPerTrade ||
        picksB > balance.salaryCap.maxPicksPerTrade) {
      return TradeValidation(
        ok: false,
        reason: 'Max ${balance.salaryCap.maxPicksPerTrade} picki na trade',
      );
    }

    final salaryOutA = _salaryOf(a, proposal.assetsFromA);
    final salaryOutB = _salaryOf(b, proposal.assetsFromB);
    final match = balance.salaryCap.salaryMatchPct;

    // Matching: incoming <= outgoing * 125% + buffer (when over cap).
    final snapA = capService.snapshot(a);
    final snapB = capService.snapshot(b);
    if (snapA.payroll > snapA.cap) {
      final maxIn = (salaryOutA * match + balance.salaryCap.salaryMatchBuffer)
          .round();
      if (salaryOutB > maxIn) {
        return const TradeValidation(
          ok: false,
          reason: 'Drużyna A: matching pensji (125%)',
        );
      }
    }
    if (snapB.payroll > snapB.cap) {
      final maxIn = (salaryOutB * match + balance.salaryCap.salaryMatchBuffer)
          .round();
      if (salaryOutA > maxIn) {
        return const TradeValidation(
          ok: false,
          reason: 'Drużyna B: matching pensji (125%)',
        );
      }
    }

    // NTC check
    for (final asset in proposal.assetsFromA) {
      if (!asset.isPlayer) continue;
      final p = a.roster.firstWhere((p) => p.id == asset.playerId);
      if (p.contract.noTradeClause) {
        return TradeValidation(ok: false, reason: 'NTC: ${p.name}');
      }
      if (p.contract.blockedTeamIds.contains(b.id)) {
        return TradeValidation(ok: false, reason: 'Blocked team: ${p.name}');
      }
    }
    for (final asset in proposal.assetsFromB) {
      if (!asset.isPlayer) continue;
      final p = b.roster.firstWhere((p) => p.id == asset.playerId);
      if (p.contract.noTradeClause) {
        return TradeValidation(ok: false, reason: 'NTC: ${p.name}');
      }
      if (p.contract.blockedTeamIds.contains(a.id)) {
        return TradeValidation(ok: false, reason: 'Blocked team: ${p.name}');
      }
    }

    final after = execute(a, b, proposal);
    if (after == null) {
      return const TradeValidation(ok: false, reason: 'Nie udało się wykonać');
    }
    final (newA, newB) = after;
    if (!_legalRoster(newA) || !_legalRoster(newB)) {
      return const TradeValidation(
        ok: false,
        reason: 'Roster poza limitem 20–30 po trade',
      );
    }
    return const TradeValidation(ok: true);
  }

  (Team, Team)? execute(Team a, Team b, TradeProposal proposal) {
    final leaveA = proposal.assetsFromA
        .where((x) => x.isPlayer)
        .map((x) => x.playerId!)
        .toSet();
    final leaveB = proposal.assetsFromB
        .where((x) => x.isPlayer)
        .map((x) => x.playerId!)
        .toSet();

    final movingToB = a.roster.where((p) => leaveA.contains(p.id)).map((p) {
      // Bird rights do not travel.
      return p.copyWith(
        contract: p.contract.copyWith(hasBirdRights: false),
        state: p.state.copyWith(seasonsWithTeam: 0),
      );
    }).toList();
    final movingToA = b.roster.where((p) => leaveB.contains(p.id)).map((p) {
      return p.copyWith(
        contract: p.contract.copyWith(hasBirdRights: false),
        state: p.state.copyWith(seasonsWithTeam: 0),
      );
    }).toList();

    // Picki: przenosimy konkretny DraftPick z ownedPicks nadawcy do
    // odbiorcy (zmiana teamId, originalTeamId bez zmian — `trade_rules.md`).
    final remainingA = List<DraftPick>.from(a.ownedPicks);
    final movingPicksToB = <DraftPick>[];
    for (final asset in proposal.assetsFromA.where((x) => x.isPick)) {
      final idx = remainingA.indexWhere(
        (p) =>
            p.year == asset.pickYear &&
            p.round == asset.pickRound &&
            p.originalTeamId == asset.originalTeamId,
      );
      if (idx == -1)
        return null; // asset niedostępny — walidacja powinna to wyłapać wcześniej
      movingPicksToB.add(remainingA.removeAt(idx).copyWith(teamId: b.id));
    }

    final remainingB = List<DraftPick>.from(b.ownedPicks);
    final movingPicksToA = <DraftPick>[];
    for (final asset in proposal.assetsFromB.where((x) => x.isPick)) {
      final idx = remainingB.indexWhere(
        (p) =>
            p.year == asset.pickYear &&
            p.round == asset.pickRound &&
            p.originalTeamId == asset.originalTeamId,
      );
      if (idx == -1) return null;
      movingPicksToA.add(remainingB.removeAt(idx).copyWith(teamId: a.id));
    }

    var newA = a.copyWith(
      roster: [...a.roster.where((p) => !leaveA.contains(p.id)), ...movingToA],
      ownedPicks: [...remainingA, ...movingPicksToA],
      eventState: a.eventState.clearPlayers(leaveA),
    );
    var newB = b.copyWith(
      roster: [...b.roster.where((p) => !leaveB.contains(p.id)), ...movingToB],
      ownedPicks: [...remainingB, ...movingPicksToB],
      eventState: b.eventState.clearPlayers(leaveB),
    );
    newA = capService.applyPayroll(newA);
    newB = capService.applyPayroll(newB);
    return (newA, newB);
  }

  int _salaryOf(Team team, List<TradeAsset> assets) {
    var sum = 0;
    for (final a in assets) {
      if (!a.isPlayer) continue;
      final p = team.roster.where((p) => p.id == a.playerId);
      if (p.isNotEmpty) sum += p.first.contract.salary;
    }
    return sum;
  }

  bool _legalRoster(Team team) {
    final n = team.roster.length;
    return n >= balance.roster.minSize && n <= balance.roster.maxSize;
  }
}
