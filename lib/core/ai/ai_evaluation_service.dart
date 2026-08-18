import 'dart:math';

import 'package:new_football/core/ai/ai_evaluation_context.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_value.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/league_strength_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/trade_service.dart';

/// Pure, explainable implementation of `AI_behaviour.md` §2.
///
/// This service evaluates preferences only. Trade legality remains owned by
/// [TradeService] and salary-cap validation; no method here mutates a save.
class AiEvaluationService {
  const AiEvaluationService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  /// Builds a context from the canonical league strength table. If a fixture
  /// has no table yet, the shared [LeagueStrengthService] calculates a
  /// read-only snapshot instead of introducing an AI-specific ranking.
  AiEvaluationContext contextForTeam({
    required Team team,
    LeagueState? league,
    int saveSeed = 0,
    int? seasonYear,
    int? week,
    DecisionType decisionType = DecisionType.tradeEval,
  }) {
    var table = league?.strengthTable;
    if (league != null && table == null) {
      table = LeagueStrengthService(balance: balance).calculate(
        league,
        week: league.currentWeek,
        day: league.currentDay,
        seasonYear: league.currentSeason.year,
      );
    }
    final entry = table?.entryFor(team.id);
    final fallbackPower = LeagueStrengthService(
      balance: balance,
    ).computeTeamPower(team);
    return AiEvaluationContext(
      team: team,
      teamStatus: entry?.teamStatus ?? TeamStatus.pretender,
      expectedRank: entry?.expectedRank ?? 15,
      teamPower: entry?.teamPower ?? fallbackPower,
      leagueTeams: league?.teams ?? [team],
      strengthTable: table,
      saveSeed: saveSeed,
      seasonYear: seasonYear ?? league?.currentSeason.year ?? 0,
      week: week ?? league?.currentWeek ?? 1,
      decisionType: decisionType,
    );
  }

  /// Calculates all seven roster needs, including the public league median
  /// used by the quality-gap term.
  List<AiPositionNeed> rosterNeeds(AiEvaluationContext context) {
    final teams = context.leagueTeams.isEmpty
        ? [context.team]
        : context.leagueTeams;
    return [
      for (final definition in balance.ai.rosterGroups)
        _needForDefinition(context.team, definition, teams),
    ];
  }

  AiPositionNeed? needForPosition(
    AiEvaluationContext context,
    Position position,
  ) {
    for (final need in rosterNeeds(context)) {
      if (need.definition.contains(position)) return need;
    }
    return null;
  }

  /// Values a player from the [recipient]'s perspective. [sourceTeam] is
  /// optional because the player may be a free agent; when present it exposes
  /// only public event/contract state and never [Player.hidden].
  AiAssetValuation evaluatePlayer(
    Player player,
    AiEvaluationContext recipient, {
    Team? sourceTeam,
  }) {
    final need = needForPosition(recipient, player.position);
    final pointValue = player.computePointValue(balance).toDouble();
    final statusAgeMult = balance.ai.statusAgeMultiplier(
      recipient.teamStatus,
      player.age,
    );
    final needMult = need == null ? 1.0 : balance.ai.needMultiplier(need);
    final contextFactors = <String>[];
    var contextMult = 1.0;

    void apply(String name, double multiplier) {
      contextFactors.add(name);
      contextMult *= multiplier;
    }

    final transferRequested =
        sourceTeam?.eventState.transferSituations.any(
          (s) => s.playerId == player.id && s.weeksRemaining > 0,
        ) ??
        false;
    if (transferRequested) {
      apply('transferRequest', balance.ai.transferRequestMult);
    }
    if (player.state.injury?.isActive == true &&
        player.state.injury?.type == InjuryType.major) {
      apply('majorInjury', balance.ai.majorInjuryMult);
    }
    if (player.contract.yearsRemaining == 1 &&
        !player.contract.noTradeClause &&
        !player.contract.blockedTeamIds.contains(recipient.team.id)) {
      apply('expiringContract', balance.ai.expiringContractMult);
    }
    if (player.contract.isRookieScale && player.contract.yearsRemaining >= 4) {
      apply('rookieScaleYearOne', balance.ai.rookieYearOneMult);
    }
    if (player.contract.noTradeClause) {
      apply('ntc', balance.ai.ntcMult);
    }

    final estimatedSalary = estimatedSalaryForOverall(player.overall(balance));
    if (player.contract.salary > estimatedSalary * 1.5 &&
        player.contract.yearsRemaining >= 3) {
      apply('overpaidContract', balance.ai.overpaidContractMult);
    }

    final contractDrag =
        (player.contract.salary - estimatedSalary) /
        1000000.0 *
        player.contract.yearsRemaining;
    return AiAssetValuation(
      kind: AiAssetKind.player,
      assetId: player.id,
      value: pointValue * statusAgeMult * needMult * contextMult,
      pointValue: pointValue,
      statusAgeMult: statusAgeMult,
      needMult: needMult,
      contextMult: contextMult,
      contractDrag: contractDrag,
      contractDragClass: _contractDragClass(contractDrag),
      contextFactors: List.unmodifiable(contextFactors),
    );
  }

  /// Values a pick using either its materialized slot or the original team's
  /// expected rank from the shared strength table.
  AiAssetValuation evaluatePick(
    DraftPick pick,
    AiEvaluationContext recipient, {
    int? currentYear,
  }) {
    final year = currentYear ?? recipient.seasonYear;
    final ownerRank = recipient
        .expectedRankFor(pick.originalTeamId)
        .clamp(1, 30);
    final materialized = pick.pickNumber != null;
    final projectedSlot = materialized
        ? pick.pickNumber!.toDouble()
        : _projectedSlot(pick.round, ownerRank);
    final pointValue = balance.ai.pickValueForSlot(projectedSlot);
    final yearsAhead = materialized ? 1 : max(1, pick.year - year);
    final futureDiscount = materialized
        ? 1.0
        : pow(balance.ai.pickFutureDiscount, yearsAhead - 1).toDouble();
    final uncertaintyMult = materialized
        ? 1.0
        : balance.ai.uncertaintyFor(yearsAhead);
    final statusPickMult = pick.round == 1
        ? switch (recipient.teamStatus) {
            TeamStatus.rebuild || TeamStatus.retool => 1.15,
            TeamStatus.contender || TeamStatus.elite => 0.88,
            TeamStatus.pretender => 1.00,
          }
        : 1.0;
    return AiAssetValuation(
      kind: AiAssetKind.pick,
      assetId: pick.id,
      value: pointValue * futureDiscount * uncertaintyMult * statusPickMult,
      pointValue: pointValue,
      futureDiscount: futureDiscount,
      uncertaintyMult: uncertaintyMult,
      statusPickMult: statusPickMult,
      projectedSlot: projectedSlot,
    );
  }

  /// Values unsigned drafted-player rights as the associated pick × 0.85.
  AiAssetValuation evaluateRights(
    DraftedPlayerRights rights,
    AiEvaluationContext recipient, {
    int? currentYear,
  }) {
    final pickNumber = rights.pickNumber;
    if (pickNumber < 1 || pickNumber > 90) {
      return _zeroValuation(AiAssetKind.rights, rights.id);
    }
    final round = pickNumber <= 30
        ? 1
        : pickNumber <= 60
        ? 2
        : 3;
    final pick = DraftPick(
      id: 'rights-pick:${rights.id}',
      year: rights.draftYear,
      round: round,
      pickNumber: pickNumber,
      teamId: rights.ownerTeamId,
      originalTeamId: rights.ownerTeamId,
    );
    final evaluated = evaluatePick(pick, recipient, currentYear: currentYear);
    return AiAssetValuation(
      kind: AiAssetKind.rights,
      assetId: rights.id,
      value: evaluated.value * balance.ai.rightsValueMult,
      pointValue: evaluated.pointValue,
      futureDiscount: evaluated.futureDiscount,
      uncertaintyMult: evaluated.uncertaintyMult,
      statusPickMult: evaluated.statusPickMult,
      rightsMult: balance.ai.rightsValueMult,
      projectedSlot: evaluated.projectedSlot,
    );
  }

  /// Adds one deterministic Gaussian noise roll to a package and evaluates
  /// payroll/apron movement. The package itself remains immutable.
  AiPackageEvaluation evaluatePackage({
    required AiEvaluationContext recipient,
    Iterable<AiAssetValuation> incoming = const [],
    Iterable<AiAssetValuation> outgoing = const [],
    int? currentPayroll,
    int? resultingPayroll,
    int packageSalt = 0,
  }) {
    final incomingList = List<AiAssetValuation>.unmodifiable(incoming);
    final outgoingList = List<AiAssetValuation>.unmodifiable(outgoing);
    final inValue = incomingList.fold<double>(
      0.0,
      (sum, value) => sum + value.value,
    );
    final outValue = outgoingList.fold<double>(
      0.0,
      (sum, value) => sum + value.value,
    );
    final netBeforeApron = inValue - outValue;
    final salaryService = SalaryCapService(balance: balance);
    final snapshot = salaryService.snapshot(recipient.team);
    final current = currentPayroll ?? snapshot.payroll;
    final resulting = resultingPayroll ?? current;
    final currentStatus = _capStatusForPayroll(current, snapshot);
    final resultingStatus = _capStatusForPayroll(resulting, snapshot);
    final statusMovedUp =
        _capStatusRank(resultingStatus) > _capStatusRank(currentStatus);
    final apronPenalty = statusMovedUp
        ? balance.ai.apronPenaltyFor(recipient.teamStatus)
        : 0;

    final random = Random(
      aiSeed(
            recipient.saveSeed,
            recipient.seasonYear,
            recipient.week,
            recipient.team.id,
            recipient.decisionType,
          ) ^
          packageSalt,
    );
    final evaluationNoisePp = _gaussian(random) * balance.ai.evaluationNoiseSd;
    final entersSecondApron =
        resultingStatus == CapStatus.secondApron &&
        currentStatus != CapStatus.secondApron;
    final secondApronRoll = entersSecondApron ? random.nextDouble() : null;
    final titleChance = recipient.expectedRank <= 3;
    final secondApronBlocked =
        entersSecondApron &&
        !(recipient.teamStatus == TeamStatus.elite &&
            titleChance &&
            (secondApronRoll ?? 1.0) < balance.ai.pSecondApronEntry);
    final netValue = netBeforeApron - apronPenalty;
    final rawSurplusPct = netValue / max(100.0, outValue) * 100.0;
    return AiPackageEvaluation(
      incoming: incomingList,
      outgoing: outgoingList,
      inValue: inValue,
      outValue: outValue,
      netValue: netValue,
      rawSurplusPct: rawSurplusPct,
      surplusPct: rawSurplusPct + evaluationNoisePp,
      evaluationNoisePp: evaluationNoisePp,
      apronPenalty: apronPenalty,
      resultingPayroll: resulting,
      secondApronBlocked: secondApronBlocked,
      secondApronRoll: secondApronRoll,
    );
  }

  /// Resolves trade assets and evaluates them without performing any trade
  /// validation. Callers must still pass the proposal through TradeService.
  AiPackageEvaluation evaluateTradeAssets({
    required Team recipient,
    required Team partner,
    required Iterable<TradeAsset> incomingAssets,
    required Iterable<TradeAsset> outgoingAssets,
    LeagueState? league,
    required int currentYear,
    int saveSeed = 0,
    int? week,
    int packageSalt = 0,
  }) {
    final context = contextForTeam(
      team: recipient,
      league: league,
      saveSeed: saveSeed,
      seasonYear: league?.currentSeason.year ?? currentYear,
      week: week ?? league?.currentWeek ?? 1,
    );
    final incoming = [
      for (final asset in incomingAssets)
        _evaluateTradeAsset(
          asset,
          sourceTeam: partner,
          recipient: context,
          league: league,
          currentYear: currentYear,
        ),
    ];
    final outgoing = [
      for (final asset in outgoingAssets)
        _evaluateTradeAsset(
          asset,
          sourceTeam: recipient,
          recipient: context,
          league: league,
          currentYear: currentYear,
        ),
    ];
    final currentPayroll = _payroll(recipient);
    final incomingSalary = _playerSalaryTotal(incomingAssets, partner);
    final outgoingSalary = _playerSalaryTotal(outgoingAssets, recipient);
    return evaluatePackage(
      recipient: context,
      incoming: incoming,
      outgoing: outgoing,
      currentPayroll: currentPayroll,
      resultingPayroll: currentPayroll + incomingSalary - outgoingSalary,
      packageSalt: packageSalt,
    );
  }

  /// Public helper used by tests, tuning screens and future trade policy.
  double contractDrag(Player player) {
    final estimated = estimatedSalaryForOverall(player.overall(balance));
    return (player.contract.salary - estimated) /
        1000000.0 *
        player.contract.yearsRemaining;
  }

  AiContractDragClass contractDragClass(Player player) =>
      _contractDragClass(contractDrag(player));

  AiPositionNeed _needForDefinition(
    Team team,
    AiRosterGroupDefinition definition,
    List<Team> leagueTeams,
  ) {
    final players = team.roster.where(
      (player) => _isSigned(player) && definition.contains(player.position),
    );
    final count = players.length;
    final bestOvr = players.isEmpty
        ? 0.0
        : players.map((player) => player.overall(balance)).reduce(max);
    final medianValues = [
      for (final other in leagueTeams) _bestOvrForDefinition(other, definition),
    ]..sort();
    final leagueMedianOvr = _median(medianValues, fallback: bestOvr);
    final gapPenalty = count >= definition.max
        ? -12.0
        : count < definition.min
        ? 40.0 + (definition.min - count) * 15.0
        : count < definition.target
        ? (definition.target - count) * 8.0
        : 0.0;
    final qualityGap = max(0.0, leagueMedianOvr - bestOvr) * 1.5;
    final needScore = gapPenalty + qualityGap;
    final band = needScore >= balance.ai.minGapThreshold
        ? AiNeedBand.critical
        : count < definition.target
        ? AiNeedBand.belowTarget
        : count >= definition.max
        ? AiNeedBand.surplus
        : AiNeedBand.target;
    return AiPositionNeed(
      definition: definition,
      count: count,
      bestOvr: bestOvr,
      leagueMedianOvr: leagueMedianOvr,
      gapPenalty: gapPenalty,
      qualityGap: qualityGap,
      needScore: needScore,
      band: band,
    );
  }

  double _bestOvrForDefinition(Team team, AiRosterGroupDefinition definition) {
    final values = team.roster
        .where(
          (player) => _isSigned(player) && definition.contains(player.position),
        )
        .map((player) => player.overall(balance));
    return values.isEmpty ? 0.0 : values.reduce(max);
  }

  AiAssetValuation _evaluateTradeAsset(
    TradeAsset asset, {
    required Team sourceTeam,
    required AiEvaluationContext recipient,
    required LeagueState? league,
    required int currentYear,
  }) {
    if (asset.isPlayer) {
      final player = sourceTeam.roster.cast<Player?>().firstWhere(
        (candidate) => candidate?.id == asset.playerId,
        orElse: () => null,
      );
      return player == null
          ? _zeroValuation(AiAssetKind.unknown, asset.identity)
          : evaluatePlayer(player, recipient, sourceTeam: sourceTeam);
    }
    if (asset.isDraftedRights) {
      final rights = league?.draftedRights
          .cast<DraftedPlayerRights?>()
          .firstWhere(
            (candidate) => candidate?.id == asset.draftedRightsId,
            orElse: () => null,
          );
      return rights == null
          ? _zeroValuation(AiAssetKind.unknown, asset.identity)
          : evaluateRights(rights, recipient, currentYear: currentYear);
    }
    if (!asset.isPick) {
      return _zeroValuation(AiAssetKind.unknown, asset.identity);
    }
    final owned = sourceTeam.ownedPicks.cast<DraftPick?>().firstWhere(
      (pick) =>
          (asset.pickId != null && pick?.id == asset.pickId) ||
          (asset.pickId == null &&
              pick?.year == asset.pickYear &&
              pick?.round == asset.pickRound &&
              pick?.originalTeamId == asset.originalTeamId),
      orElse: () => null,
    );
    final pick =
        owned ??
        DraftPick(
          id: asset.pickId ?? asset.identity,
          year: asset.pickYear!,
          round: asset.pickRound!,
          teamId: sourceTeam.id,
          originalTeamId: asset.originalTeamId!,
        );
    return evaluatePick(pick, recipient, currentYear: currentYear);
  }

  int _playerSalaryTotal(Iterable<TradeAsset> assets, Team source) => assets
      .where((asset) => asset.isPlayer)
      .map(
        (asset) => source.roster
            .where((player) => player.id == asset.playerId)
            .fold<int>(0, (sum, player) => sum + player.contract.salary),
      )
      .fold<int>(0, (sum, salary) => sum + salary);

  int _payroll(Team team) =>
      team.roster.fold<int>(0, (sum, player) => sum + player.contract.salary);

  static bool _isSigned(Player player) =>
      player.contract.salary > 0 && player.contract.yearsRemaining > 0;

  static AiContractDragClass _contractDragClass(double drag) {
    if (drag >= 60) return AiContractDragClass.toxic;
    if (drag >= 30) return AiContractDragClass.anchor;
    if (drag >= 10) return AiContractDragClass.burden;
    return AiContractDragClass.acceptable;
  }

  static AiAssetValuation _zeroValuation(AiAssetKind kind, String id) =>
      AiAssetValuation(kind: kind, assetId: id, value: 0, pointValue: 0);

  static double _median(List<double> values, {required double fallback}) {
    if (values.isEmpty) return fallback;
    final middle = values.length ~/ 2;
    if (values.length.isOdd) return values[middle];
    return (values[middle - 1] + values[middle]) / 2.0;
  }

  double _projectedSlot(int round, int ownerRank) {
    if (round == 1 && ownerRank >= 21) {
      return balance.ai.lotteryExpectedSlots[ownerRank] ?? 9.4;
    }
    return (31 - ownerRank) + (round - 1) * 30.0;
  }

  static CapStatus _capStatusForPayroll(int payroll, CapSnapshot thresholds) {
    if (payroll >= thresholds.secondApron) return CapStatus.secondApron;
    if (payroll >= thresholds.firstApron) return CapStatus.firstApron;
    if (payroll > thresholds.cap) return CapStatus.overCap;
    return CapStatus.underCap;
  }

  static int _capStatusRank(CapStatus status) => switch (status) {
    CapStatus.underCap => 0,
    CapStatus.overCap => 1,
    CapStatus.firstApron => 2,
    CapStatus.secondApron => 3,
  };

  static double _gaussian(Random random) {
    final u1 = max(random.nextDouble(), 1e-12);
    final u2 = random.nextDouble();
    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }
}
