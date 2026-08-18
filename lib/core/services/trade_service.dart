import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';

class TradeAsset {
  const TradeAsset.player(this.playerId)
    : draftedRightsId = null,
      pickYear = null,
      pickRound = null,
      originalTeamId = null;

  const TradeAsset.draftedRights(this.draftedRightsId)
    : playerId = null,
      pickYear = null,
      pickRound = null,
      originalTeamId = null;

  const TradeAsset.pick({
    required this.pickYear,
    required this.pickRound,
    required this.originalTeamId,
  }) : playerId = null,
       draftedRightsId = null;

  final String? playerId;
  final String? draftedRightsId;
  final int? pickYear;
  final int? pickRound;
  final String? originalTeamId;

  bool get isPlayer => playerId != null;
  bool get isDraftedRights => draftedRightsId != null;
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

  int assetValue(Team team, TradeAsset asset, {required int currentYear}) {
    if (asset.isPlayer) {
      final matches = team.roster.where((p) => p.id == asset.playerId);
      if (matches.isEmpty) return 0;
      final player = matches.first;
      final baseValue = player.computePointValue(balance);
      return (baseValue * team.eventState.pointValueMultiplierFor(player.id))
          .round();
    }
    if (asset.isDraftedRights) return 0;
    final owned = _findOwnedPick(team, asset);
    if (owned != null) {
      return owned.computeTradeValue(
        currentYear: currentYear,
        balance: balance,
      );
    }
    return DraftPick(
      id: 'preview_${asset.originalTeamId}_${asset.pickYear}_r${asset.pickRound}',
      year: asset.pickYear!,
      round: asset.pickRound!,
      teamId: team.id,
      originalTeamId: asset.originalTeamId!,
    ).computeTradeValue(currentYear: currentYear, balance: balance);
  }

  int rightsAssetValue(
    DraftedPlayerRights rights, {
    required int currentYear,
  }) => rights.player.computePointValue(balance);

  /// Validates and executes a proposal containing drafted rights. Rights are
  /// not roster players, so they do not affect salary matching or the 20–30
  /// roster check; ownership is transferred in the persistent league state.
  TradeValidation validateLeague(
    LeagueState league,
    TradeProposal proposal, {
    int? currentWeek,
  }) {
    final a = league.teamById(proposal.teamAId);
    final b = league.teamById(proposal.teamBId);
    if (a == null || b == null) {
      return const TradeValidation(ok: false, reason: 'Nieznana drużyna');
    }
    final rightsValidation = _validateRights(league, proposal, a.id, b.id);
    if (!rightsValidation.ok) return rightsValidation;
    return validate(a, b, proposal, currentWeek: currentWeek);
  }

  LeagueState? executeLeague(LeagueState league, TradeProposal proposal) {
    final validation = validateLeague(league, proposal);
    if (!validation.ok) return null;
    final a = league.teamById(proposal.teamAId);
    final b = league.teamById(proposal.teamBId);
    if (a == null || b == null) return null;
    final result = execute(a, b, proposal);
    if (result == null) return null;
    final rights = league.draftedRights.map((right) {
      if (proposal.assetsFromA.any(
            (asset) =>
                asset.isDraftedRights && asset.draftedRightsId == right.id,
          ) &&
          right.ownerTeamId == a.id) {
        return right.copyWith(ownerTeamId: b.id);
      }
      if (proposal.assetsFromB.any(
            (asset) =>
                asset.isDraftedRights && asset.draftedRightsId == right.id,
          ) &&
          right.ownerTeamId == b.id) {
        return right.copyWith(ownerTeamId: a.id);
      }
      return right;
    }).toList();
    return league.copyWith(
      teams: league.teams.map((team) {
        if (team.id == result.$1.id) return result.$1;
        if (team.id == result.$2.id) return result.$2;
        return team;
      }).toList(),
      draftedRights: rights,
    );
  }

  TradeValidation _validateRights(
    LeagueState league,
    TradeProposal proposal,
    String teamAId,
    String teamBId,
  ) {
    for (final entry in [
      (assets: proposal.assetsFromA, owner: teamAId, recipient: teamBId),
      (assets: proposal.assetsFromB, owner: teamBId, recipient: teamAId),
    ]) {
      for (final asset in entry.assets.where((item) => item.isDraftedRights)) {
        final right = league.draftedRights.cast<DraftedPlayerRights?>().firstWhere(
          (item) => item?.id == asset.draftedRightsId,
          orElse: () => null,
        );
        if (right == null || right.ownerTeamId != entry.owner) {
          return const TradeValidation(
            ok: false,
            reason: 'Prawa draftowe nie należą do drużyny sprzedającej',
          );
        }
        if (entry.owner == entry.recipient) {
          return const TradeValidation(
            ok: false,
            reason: 'Nie można wymienić praw z samym sobą',
          );
        }
      }
    }
    return const TradeValidation(ok: true);
  }

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
    final matchA = capService.tradeMatching(
      team: a,
      outgoingSalary: salaryOutA,
      outgoingSalaries: _playerSalaries(a, proposal.assetsFromA),
      incomingSalary: salaryOutB,
      incomingFirstRoundPicks: _firstRoundPicks(proposal.assetsFromB),
    );
    if (!matchA.allowed) {
      return TradeValidation(
        ok: false,
        reason: 'Drużyna A: ${matchA.reason ?? 'salary matching'}',
      );
    }

    final matchB = capService.tradeMatching(
      team: b,
      outgoingSalary: salaryOutB,
      outgoingSalaries: _playerSalaries(b, proposal.assetsFromB),
      incomingSalary: salaryOutA,
      incomingFirstRoundPicks: _firstRoundPicks(proposal.assetsFromA),
    );
    if (!matchB.allowed) {
      return TradeValidation(
        ok: false,
        reason: 'Drużyna B: ${matchB.reason ?? 'salary matching'}',
      );
    }

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

    final remainingA = List<DraftPick>.from(a.ownedPicks);
    final movingPicksToB = <DraftPick>[];
    for (final asset in proposal.assetsFromA.where((x) => x.isPick)) {
      final idx = remainingA.indexWhere(
        (p) =>
            p.year == asset.pickYear &&
            p.round == asset.pickRound &&
            p.originalTeamId == asset.originalTeamId,
      );
      if (idx == -1) return null;
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

  int _salaryOf(Team team, List<TradeAsset> assets) =>
      _playerSalaries(team, assets).fold(0, (sum, salary) => sum + salary);

  List<int> _playerSalaries(Team team, List<TradeAsset> assets) {
    final salaries = <int>[];
    for (final asset in assets) {
      if (!asset.isPlayer) continue;
      final player = team.roster.where((p) => p.id == asset.playerId);
      if (player.isNotEmpty) salaries.add(player.first.contract.salary);
    }
    return salaries;
  }

  int _firstRoundPicks(List<TradeAsset> assets) =>
      assets.where((asset) => asset.isPick && asset.pickRound == 1).length;

  bool _legalRoster(Team team) {
    final n = team.roster.length;
    return n >= balance.roster.minSize && n <= balance.roster.maxSize;
  }
}
