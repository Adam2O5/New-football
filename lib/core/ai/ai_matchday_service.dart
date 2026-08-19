import 'dart:math';

import 'package:new_football/core/ai/ai_matchday_models.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/position_group.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

/// Canonical AI matchday policy (`docs/AI_behaviour.md` §4).
///
/// This class only makes fixture decisions and orchestrates the already
/// validated live-engine actions. It never mutates a persisted [Team].
class AiMatchdayService {
  AiMatchdayService({
    this.balance = BalanceConfig.defaults,
    SimulationMatchEngine? matchEngine,
  }) : matchEngine = matchEngine ?? SimulationMatchEngine(balance: balance);

  final BalanceConfig balance;
  final SimulationMatchEngine matchEngine;

  factory AiMatchdayService.fromBalance({
    BalanceConfig balance = BalanceConfig.defaults,
    SimulationMatchEngine? matchEngine,
  }) => AiMatchdayService(balance: balance, matchEngine: matchEngine);

  /// Builds the explicit, fixture-scoped input used by [planForTeam].
  AiMatchdayContext contextForTeam({
    required Team team,
    required Team opponent,
    required String matchId,
    required MatchContext matchContext,
    required int saveSeed,
    required int seasonYear,
    required int week,
    SeasonPhase phase = SeasonPhase.regular,
    Formation? opponentFormation,
    List<Formation> opponentFormationHistory = const [],
    Set<String> returningAfterMajorInjury = const {},
    bool? nextMatchWithinThreeDays,
    bool? mathematicallyMeaningless,
  }) => AiMatchdayContext(
    team: team,
    opponent: opponent,
    matchId: matchId,
    matchContext: matchContext,
    saveSeed: saveSeed,
    seasonYear: seasonYear,
    week: week,
    phase: phase,
    opponentFormation: opponentFormation ?? opponent.tactics.formation,
    opponentFormationHistory: opponentFormationHistory,
    returningAfterMajorInjury: returningAfterMajorInjury,
    nextMatchWithinThreeDays:
        nextMatchWithinThreeDays ??
        (team.id == matchContext.homeTeamId
            ? matchContext.homeMatchInWeek >= 2
            : matchContext.awayMatchInWeek >= 2),
    mathematicallyMeaningless:
        mathematicallyMeaningless ?? (week >= 27 && week <= 29),
  );

  /// Selects one AI side's complete pre-match plan.
  AiMatchdayPlan planForTeam(AiMatchdayContext context) {
    final team = context.team;
    final opponent = context.opponent;
    final lineupRandom = Random(
      matchAiSeed(
        context.saveSeed,
        context.seasonYear,
        context.week,
        team.id,
        DecisionType.lineup,
        context.matchId,
        opponentId: opponent.id,
      ),
    );
    final formationRandom = Random(
      matchAiSeed(
        context.saveSeed,
        context.seasonYear,
        context.week,
        team.id,
        DecisionType.formation,
        context.matchId,
        opponentId: opponent.id,
      ),
    );
    final tacticsRandom = Random(
      matchAiSeed(
        context.saveSeed,
        context.seasonYear,
        context.week,
        team.id,
        DecisionType.tactics,
        context.matchId,
        opponentId: opponent.id,
      ),
    );

    final available = team.roster
        .where((player) => player.isEligibleForStartingEleven)
        .toList(growable: false);
    final selectionPool = _selectionPool(
      team: team,
      available: available,
      context: context,
      random: lineupRandom,
    );
    final formationChoice = _selectFormation(
      candidates: selectionPool,
      opponentFormation:
          context.opponentFormation ?? opponent.tactics.formation,
      history: context.opponentFormationHistory,
      random: formationRandom,
    );
    final formation = formationChoice.formation;
    final selection = _selectLineup(
      candidates: selectionPool,
      formation: formation,
    );
    final lineup = selection.lineup;
    final averageOvr = _averageOverall(lineup);
    final opponentAverageOvr = _averageOverall(opponent.startingEleven);
    final tactics = _tacticsFor(
      formation: formation,
      teamAverageOvr: averageOvr,
      opponentAverageOvr: opponentAverageOvr,
      opponentTactics: opponent.tactics,
      lineup: lineup,
      random: tacticsRandom,
    );
    final roles = _rolesFor(
      lineup: lineup,
      strengthDifference: averageOvr - opponentAverageOvr,
      random: tacticsRandom,
    );
    final bench = _selectBench(
      team: team,
      lineupIds: lineup.map((player) => player.id).toSet(),
      selection: selection,
    );

    return AiMatchdayPlan(
      teamId: team.id,
      matchId: context.matchId,
      lineupPlayerIds: lineup
          .map((player) => player.id)
          .toList(growable: false),
      benchPlayerIds: bench.map((player) => player.id).toList(growable: false),
      formation: formation,
      tactics: tactics,
      assignedPositions: selection.assignedPositions,
      assignedRoles: roles,
      playerScores: selection.playerScores,
      rotationReasons: selection.rotationReasons,
      counterFormationApplied: formationChoice.counterApplied,
      substitutionSeed: matchAiSeed(
        context.saveSeed,
        context.seasonYear,
        context.week,
        team.id,
        DecisionType.subs,
        context.matchId,
        opponentId: opponent.id,
      ),
    );
  }

  /// Simulates a fixture with AI decisions on both non-player-controlled
  /// sides. Player-controlled teams retain their saved lineup/tactics.
  MatchResult simulateFullMatch({
    required Team home,
    required Team away,
    required MatchContext context,
    required int saveSeed,
    required int seasonYear,
    required int week,
    required String matchId,
    SeasonPhase phase = SeasonPhase.regular,
    List<Formation> homeOpponentFormationHistory = const [],
    List<Formation> awayOpponentFormationHistory = const [],
    Set<String> homeReturningAfterMajorInjury = const {},
    Set<String> awayReturningAfterMajorInjury = const {},
    bool? homeNextMatchWithinThreeDays,
    bool? awayNextMatchWithinThreeDays,
    bool? mathematicallyMeaningless,
    bool includeStoppageTime = false,
  }) {
    final homePlan = home.ai == null
        ? null
        : planForTeam(
            contextForTeam(
              team: home,
              opponent: away,
              matchId: matchId,
              matchContext: context,
              saveSeed: saveSeed,
              seasonYear: seasonYear,
              week: week,
              phase: phase,
              opponentFormation: away.tactics.formation,
              opponentFormationHistory: homeOpponentFormationHistory,
              returningAfterMajorInjury: homeReturningAfterMajorInjury,
              nextMatchWithinThreeDays: homeNextMatchWithinThreeDays,
              mathematicallyMeaningless: mathematicallyMeaningless,
            ),
          );
    final awayPlan = away.ai == null
        ? null
        : planForTeam(
            contextForTeam(
              team: away,
              opponent: home,
              matchId: matchId,
              matchContext: context,
              saveSeed: saveSeed,
              seasonYear: seasonYear,
              week: week,
              phase: phase,
              opponentFormation: homePlan?.formation ?? home.tactics.formation,
              opponentFormationHistory: awayOpponentFormationHistory,
              returningAfterMajorInjury: awayReturningAfterMajorInjury,
              nextMatchWithinThreeDays: awayNextMatchWithinThreeDays,
              mathematicallyMeaningless: mathematicallyMeaningless,
            ),
          );

    final plannedHome = homePlan?.applyTo(home) ?? home;
    final plannedAway = awayPlan?.applyTo(away) ?? away;
    final fixtureSeed = matchSeed(saveSeed, seasonYear, matchId);
    final live = matchEngine.start(
      home: plannedHome,
      away: plannedAway,
      context: context.copyWith(seed: fixtureSeed),
      rngSeed: fixtureSeed,
      homeAssignedPositions: homePlan?.assignedPositions ?? const {},
      awayAssignedPositions: awayPlan?.assignedPositions ?? const {},
    );
    final homeRuntime = homePlan == null
        ? null
        : AiMatchdayRuntime(plan: homePlan);
    final awayRuntime = awayPlan == null
        ? null
        : AiMatchdayRuntime(plan: awayPlan);

    _simulateWithAi(
      live: live,
      homeRuntime: homeRuntime,
      awayRuntime: awayRuntime,
      includeStoppageTime: includeStoppageTime,
    );
    return matchEngine.toMatchResult(
      live: live,
      home: plannedHome,
      away: plannedAway,
    );
  }

  /// Applies the same forced-injury and probabilistic trigger policy used by
  /// headless fixtures to an interactive [SimulationLiveMatch].
  void applyInMatchDecisions({
    required SimulationLiveMatch live,
    required AiMatchdayRuntime runtime,
    required bool homeSide,
  }) {
    _applyForcedInjurySubstitutions(
      live: live,
      runtime: runtime,
      homeSide: homeSide,
    );
    if (live.isFinished) return;

    final minute = live.state.minute;
    final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
    final bench = homeSide ? live.state.homeBench : live.state.awayBench;
    if (lineup.isEmpty || bench.isEmpty) return;

    if (_applyRedCardReconfiguration(
      live: live,
      runtime: runtime,
      homeSide: homeSide,
    )) {
      return;
    }

    if (minute >= 60 &&
        _applyStaminaTrigger(
          live: live,
          runtime: runtime,
          homeSide: homeSide,
          threshold: 35,
          probability: balance.ai.pSubstitutionStaminaCritical,
          triggerKey: 'stamina-critical',
          allowAnyReplacement: true,
        )) {
      return;
    }
    if (minute >= 45 &&
        _applyStaminaTrigger(
          live: live,
          runtime: runtime,
          homeSide: homeSide,
          threshold: 45,
          probability: balance.ai.pSubstitutionStaminaLow,
          triggerKey: 'stamina-low',
          allowAnyReplacement: false,
        )) {
      return;
    }
    if (minute >= 60 &&
        _applyRatingTrigger(live: live, runtime: runtime, homeSide: homeSide)) {
      return;
    }
    if (minute >= 70 &&
        _applyYellowCardTrigger(
          live: live,
          runtime: runtime,
          homeSide: homeSide,
        )) {
      return;
    }

    final scoreDelta = homeSide
        ? live.state.homeGoals - live.state.awayGoals
        : live.state.awayGoals - live.state.homeGoals;
    if (scoreDelta <= -2 && minute >= 60) {
      if (_applyScoreTrigger(
        live: live,
        runtime: runtime,
        homeSide: homeSide,
        triggerKey: 'trailing-two',
        probability: balance.ai.pSubstitutionTrailingTwo,
        count: 2,
        offensive: true,
      )) {
        return;
      }
    } else if (scoreDelta == -1 && minute >= 65) {
      if (_applyScoreTrigger(
        live: live,
        runtime: runtime,
        homeSide: homeSide,
        triggerKey: 'trailing-one',
        probability: balance.ai.pSubstitutionTrailingOne,
        count: 1,
        offensive: true,
      )) {
        return;
      }
    } else if (scoreDelta >= 2 && minute >= 70) {
      if (_applyScoreTrigger(
        live: live,
        runtime: runtime,
        homeSide: homeSide,
        triggerKey: 'leading-two',
        probability: balance.ai.pSubstitutionLeadingTwo,
        count: 1,
        offensive: false,
      )) {
        return;
      }
    } else if (scoreDelta == 1 && minute >= 78) {
      if (_applyScoreTrigger(
        live: live,
        runtime: runtime,
        homeSide: homeSide,
        triggerKey: 'leading-one',
        probability: balance.ai.pSubstitutionLeadingOne,
        count: 1,
        offensive: false,
      )) {
        return;
      }
    }

    if (scoreDelta <= -2 &&
        minute > 70 &&
        !runtime.hasHandled('tactical-correction') &&
        runtime.random.nextDouble() < balance.ai.pTacticalLateCorrection) {
      final current = homeSide
          ? live.state.homeTactics
          : live.state.awayTactics;
      final accepted = live.updateTactics(
        homeSide: homeSide,
        tactics: current.copyWith(
          tempo: Tempo.slow,
          attackWidth: AttackWidth.narrow,
          defensiveLine: DefensiveLine.deep,
          pressing: PressingIntensity.low,
        ),
      );
      runtime.markHandled('tactical-correction');
      if (accepted) return;
    }
  }

  /// Converts public scheduled results into opponent formation memory.
  static List<Formation> formationHistoryFromSchedule(
    Iterable<ScheduledMatch> schedule,
    String teamId,
    String opponentId,
  ) {
    final history = <Formation>[];
    for (final match in schedule) {
      final result = match.result;
      if (result == null) continue;
      final samePair =
          (result.homeTeamId == teamId && result.awayTeamId == opponentId) ||
          (result.homeTeamId == opponentId && result.awayTeamId == teamId);
      if (!samePair) continue;
      history.add(
        result.homeTeamId == opponentId
            ? result.homeTactics.formation
            : result.awayTactics.formation,
      );
    }
    return List.unmodifiable(history);
  }

  /// Public for deterministic balance/property tests.
  double playerMatchScore(
    Player player,
    Position assignedPosition, {
    bool availabilityGate = true,
  }) {
    final effectiveOvr =
        player.overall(balance) *
        EffectiveAttributeCalculator.positionMultiplier(
          player,
          assignedPosition: assignedPosition,
        );
    final roleFit = player.state.role == player.optimalRole
        ? balance.matchday.roleFitBonus
        : 1.0;
    final gate = availabilityGate && !player.isAvailable ? 0.0 : 1.0;
    final promiseBonus =
        1.0 + player.state.eventState.modifierValue('promiseMatchScoreBonus');
    return effectiveOvr *
        balance.player.formMult(player.state.form) *
        staminaReadiness(player.state.stamina) *
        roleFit *
        promiseBonus *
        gate;
  }

  /// The four documented readiness bands: 1.00 / 0.94 / 0.82 / 0.60.
  double staminaReadiness(int stamina) {
    if (stamina >= 80) return balance.ai.staminaReadinessFull;
    if (stamina >= 60) return balance.ai.staminaReadinessGood;
    if (stamina >= 40) return balance.ai.staminaReadinessMid;
    return balance.ai.staminaReadinessLow;
  }

  /// Public formation-fit helper used by tests and diagnostics.
  double formationFitScore({required Team team, required Formation formation}) {
    final candidates = team.roster.where((p) => p.isEligibleForStartingEleven);
    return _formationFitScore(candidates, formation);
  }

  void _simulateWithAi({
    required SimulationLiveMatch live,
    required AiMatchdayRuntime? homeRuntime,
    required AiMatchdayRuntime? awayRuntime,
    required bool includeStoppageTime,
  }) {
    if (includeStoppageTime && live.state.minute < 45) {
      matchEngine.runUntil(live, 45, includeStoppageTime: true);
      if (homeRuntime != null) {
        applyInMatchDecisions(live: live, runtime: homeRuntime, homeSide: true);
      }
      if (awayRuntime != null) {
        applyInMatchDecisions(
          live: live,
          runtime: awayRuntime,
          homeSide: false,
        );
      }
    }
    while (!live.isFinished && live.state.minute < 90) {
      matchEngine.simulateMinute(live);
      if (homeRuntime != null) {
        applyInMatchDecisions(live: live, runtime: homeRuntime, homeSide: true);
      }
      if (awayRuntime != null) {
        applyInMatchDecisions(
          live: live,
          runtime: awayRuntime,
          homeSide: false,
        );
      }
    }
    if (includeStoppageTime && !live.isFinished) {
      matchEngine.runUntil(live, 90, includeStoppageTime: true);
    }
  }

  List<Player> _selectionPool({
    required Team team,
    required List<Player> available,
    required AiMatchdayContext context,
    required Random random,
  }) {
    final rested = <Player>[];
    for (final player in available) {
      if (_shouldRotate(player, context, random)) rested.add(player);
    }
    final selected = available
        .where((player) => !rested.any((item) => item.id == player.id))
        .toList();
    if (selected.length >= balance.roster.startingXi) return selected;

    // Rotation is never allowed to make an otherwise legal roster forfeit.
    final byId = selected.map((player) => player.id).toSet();
    for (final player in available) {
      if (byId.add(player.id)) selected.add(player);
      if (selected.length >= balance.roster.startingXi) break;
    }
    return selected;
  }

  bool _shouldRotate(Player player, AiMatchdayContext context, Random random) {
    final lowStamina = player.state.stamina < 45;
    if (context.isPlayoff && player.state.stamina >= 55) {
      if (random.nextDouble() < balance.ai.pPlayoffBestXi) return false;
    }
    if (lowStamina &&
        random.nextDouble() < balance.ai.pRotationCriticalStamina) {
      return true;
    }
    if (context.nextMatchWithinThreeDays &&
        player.state.stamina < 65 &&
        random.nextDouble() < balance.ai.pRotationShortRest) {
      return true;
    }
    if (context.mathematicallyMeaningless &&
        player.hidden.injuryProne >= balance.ai.rotationInjuryProneThreshold &&
        random.nextDouble() < balance.ai.pRotationMeaningless) {
      return true;
    }
    if (context.returningAfterMajorInjury.contains(player.id) &&
        random.nextDouble() < balance.ai.pRotationMajorReturn) {
      return true;
    }
    return false;
  }

  ({Formation formation, bool counterApplied}) _selectFormation({
    required List<Player> candidates,
    required Formation? opponentFormation,
    required List<Formation> history,
    required Random random,
  }) {
    final ranked =
        Formation.values
            .map(
              (formation) => (
                formation: formation,
                fit: _formationFitScore(candidates, formation),
              ),
            )
            .toList()
          ..sort((a, b) {
            final byFit = b.fit.compareTo(a.fit);
            return byFit != 0
                ? byFit
                : a.formation.index.compareTo(b.formation.index);
          });
    final top = ranked.take(3).toList(growable: false);
    if (top.isEmpty) return (formation: Formation.f433, counterApplied: false);

    final observed = _mostFrequent(history) ?? opponentFormation;
    final weighted = top.toList()
      ..sort((a, b) {
        final byScore = _formationChoiceScore(
          b.fit,
          b.formation,
          observed,
        ).compareTo(_formationChoiceScore(a.fit, a.formation, observed));
        return byScore != 0
            ? byScore
            : a.formation.index.compareTo(b.formation.index);
      });
    if (history.length >= balance.ai.counterFormationMinMatches &&
        observed != null &&
        random.nextDouble() < balance.ai.pCounterFormation) {
      final topCounters = top
          .where(
            (candidate) =>
                balance.tactics.formationMatchupBonus(
                  candidate.formation,
                  observed,
                ) >
                0,
          )
          .toList(growable: false);
      // Counter memory is a deliberate exception to the ordinary top-three
      // fit pool: if none of the best-fit shapes can counter the remembered
      // family, use the best positive counter from the full ranked set.
      final counters =
          (topCounters.isNotEmpty
                  ? topCounters
                  : ranked
                        .where(
                          (candidate) =>
                              balance.tactics.formationMatchupBonus(
                                candidate.formation,
                                observed,
                              ) >
                              0,
                        )
                        .toList(growable: false))
              .toList()
            ..sort((a, b) {
              final byBonus = balance.tactics
                  .formationMatchupBonus(b.formation, observed)
                  .compareTo(
                    balance.tactics.formationMatchupBonus(
                      a.formation,
                      observed,
                    ),
                  );
              return byBonus != 0 ? byBonus : b.fit.compareTo(a.fit);
            });
      if (counters.isNotEmpty) {
        return (formation: counters.first.formation, counterApplied: true);
      }
    }
    return (formation: weighted.first.formation, counterApplied: false);
  }

  double _formationChoiceScore(
    double fit,
    Formation formation,
    Formation? opponent,
  ) {
    final matchup = opponent == null
        ? 50.0
        : (50.0 +
                  balance.tactics.formationMatchupBonus(formation, opponent) *
                      1000.0)
              .clamp(0.0, 100.0)
              .toDouble();
    return fit * balance.ai.formationFitWeight +
        matchup * balance.ai.formationMatchupWeight;
  }

  Formation? _mostFrequent(List<Formation> history) {
    if (history.isEmpty) return null;
    final counts = <Formation, int>{};
    for (final formation in history) {
      counts[formation] = (counts[formation] ?? 0) + 1;
    }
    Formation? best;
    var bestCount = -1;
    for (final formation in history) {
      final count = counts[formation]!;
      if (count > bestCount ||
          (count == bestCount && formation.index < (best?.index ?? 999))) {
        best = formation;
        bestCount = count;
      }
    }
    return best;
  }

  double _formationFitScore(Iterable<Player> candidates, Formation formation) {
    final list = candidates.toList(growable: false);
    if (list.isEmpty) return 0;
    final slots = FormationLayout.of(formation).slots;
    var total = 0.0;
    for (final slot in slots) {
      var best = 0.0;
      for (final player in list) {
        best = max(best, playerMatchScore(player, slot.position));
      }
      total += best;
    }
    return total / slots.length;
  }

  _LineupSelection _selectLineup({
    required List<Player> candidates,
    required Formation formation,
  }) {
    final slots = FormationLayout.of(formation).slots;
    final assigned = <Player?>[];
    final remaining = candidates.toList();
    final gkAvailable = remaining.any(
      (player) => player.position == Position.gk,
    );
    for (var index = 0; index < slots.length; index++) {
      final slot = slots[index];
      final pool = index == 0 && gkAvailable
          ? remaining.where((player) => player.position == Position.gk).toList()
          : remaining;
      if (pool.isEmpty) {
        assigned.add(null);
        continue;
      }
      pool.sort((a, b) => _comparePlayersForSlot(b, a, slot.position));
      final selected = pool.first;
      assigned.add(selected);
      remaining.removeWhere((player) => player.id == selected.id);
    }

    // Two complete pair-swap passes improve the greedy assignment while the
    // hard GK rule remains invariant.
    for (var pass = 0; pass < balance.ai.lineupSwapPasses; pass++) {
      for (var left = 0; left < assigned.length; left++) {
        if (assigned[left] == null) continue;
        for (var right = left + 1; right < assigned.length; right++) {
          if (assigned[right] == null) continue;
          if (left == 0 || right == 0) continue;
          final current =
              playerMatchScore(assigned[left]!, slots[left].position) +
              playerMatchScore(assigned[right]!, slots[right].position);
          final swapped =
              playerMatchScore(assigned[right]!, slots[left].position) +
              playerMatchScore(assigned[left]!, slots[right].position);
          if (swapped > current + 0.000001) {
            final temp = assigned[left];
            assigned[left] = assigned[right];
            assigned[right] = temp;
          }
        }
      }
    }

    final lineup = <Player>[];
    final positions = <String, Position>{};
    final scores = <String, double>{};
    for (var index = 0; index < assigned.length; index++) {
      final player = assigned[index];
      if (player == null) continue;
      lineup.add(player);
      positions[player.id] = slots[index].position;
      scores[player.id] = playerMatchScore(player, slots[index].position);
    }
    return _LineupSelection(
      lineup: lineup,
      assignedPositions: Map.unmodifiable(positions),
      playerScores: Map.unmodifiable(scores),
      rotationReasons: const {},
    );
  }

  int _comparePlayersForSlot(Player first, Player second, Position slot) {
    final byScore = playerMatchScore(
      first,
      slot,
    ).compareTo(playerMatchScore(second, slot));
    return byScore != 0 ? byScore : first.id.compareTo(second.id);
  }

  List<Player> _selectBench({
    required Team team,
    required Set<String> lineupIds,
    required _LineupSelection selection,
  }) {
    final available = team.availablePlayers
        .where((player) => !lineupIds.contains(player.id))
        .toList();
    double score(Player player) {
      var best = 0.0;
      for (final position in Position.values) {
        best = max(best, playerMatchScore(player, position));
      }
      return best;
    }

    available.sort((a, b) {
      final byScore = score(b).compareTo(score(a));
      return byScore != 0 ? byScore : a.id.compareTo(b.id);
    });
    final bench = <Player>[];
    void addGroup(bool Function(Player) predicate, int count) {
      for (final player in available) {
        if (bench.length >= balance.roster.benchSize || count <= 0) break;
        if (bench.contains(player) || !predicate(player)) continue;
        bench.add(player);
        count--;
      }
    }

    addGroup((p) => p.position == Position.gk, 1);
    addGroup(_isDefender, 2);
    addGroup(_isMidfielder, 2);
    addGroup(_isAttacker, 2);
    for (final player in available) {
      if (bench.length >= balance.roster.benchSize) break;
      if (!bench.contains(player)) bench.add(player);
    }
    return bench;
  }

  TacticsSetup _tacticsFor({
    required Formation formation,
    required double teamAverageOvr,
    required double opponentAverageOvr,
    required TacticsSetup opponentTactics,
    required List<Player> lineup,
    required Random random,
  }) {
    final difference = teamAverageOvr - opponentAverageOvr;
    var tempo = Tempo.balanced;
    var width = AttackWidth.balanced;
    var line = DefensiveLine.normal;
    var pressing = PressingIntensity.medium;
    if (difference >= 12) {
      width = AttackWidth.wide;
      line = DefensiveLine.high;
      pressing = PressingIntensity.high;
    } else if (difference >= 5) {
      width = AttackWidth.wide;
      pressing = PressingIntensity.high;
    } else if (difference <= -12) {
      tempo = Tempo.slow;
      width = AttackWidth.narrow;
      line = DefensiveLine.deep;
      pressing = PressingIntensity.low;
    } else if (difference <= -5) {
      tempo = Tempo.fast;
      line = DefensiveLine.deep;
      pressing = PressingIntensity.low;
    }

    final matchup = balance.tactics.formationMatchupBonus(
      formation,
      opponentTactics.formation,
    );
    if (random.nextDouble() < balance.ai.pTacticalMatchupAdjust) {
      if (matchup > 0) {
        width = AttackWidth.wide;
        pressing = PressingIntensity.high;
      } else if (matchup < 0) {
        line = DefensiveLine.deep;
        pressing = PressingIntensity.low;
      }
    }

    final outfield = lineup.where((p) => p.position != Position.gk).toList();
    final aerialAttack = _average(outfield.map(_aerialRating), fallback: 0);
    final shooting = _average(outfield.map(_shootingRating), fallback: 0);
    final defenders = lineup.where(_isDefender).toList();
    final aerialDefense = _average(
      defenders.map(_aerialRating),
      fallback: aerialAttack,
    );
    final setPieceAttack =
        aerialAttack >= balance.ai.sfgAerialAttackThreshold ||
            shooting >= balance.ai.sfgShootingThreshold
        ? balance.ai.sfgStrongValue
        : balance.ai.sfgDefaultValue;
    final setPieceDefense =
        aerialDefense >= balance.ai.sfgAerialDefenseThreshold
        ? balance.ai.sfgDefenseStrongValue
        : balance.ai.sfgDefaultValue;
    return TacticsSetup(
      formation: formation,
      tempo: tempo,
      attackWidth: width,
      defensiveLine: line,
      pressing: pressing,
      cornersAttack: setPieceAttack,
      freeKicks: setPieceAttack,
      penalties: setPieceAttack,
      cornersDefense: setPieceDefense,
    );
  }

  Map<String, AssignedRole> _rolesFor({
    required List<Player> lineup,
    required double strengthDifference,
    required Random random,
  }) {
    final result = <String, AssignedRole>{};
    final offensive = strengthDifference >= 5;
    final defensive = strengthDifference <= -5;
    for (final player in lineup) {
      var role = player.optimalRole;
      if ((offensive || defensive) &&
          random.nextDouble() < balance.ai.pRoleOverride) {
        final candidates = rolesForPosition(player.position)
            .where(
              (candidate) => offensive
                  ? _isOffensiveRole(candidate)
                  : _isDefensiveRole(candidate),
            )
            .toList();
        if (candidates.isNotEmpty) role = candidates.first;
      }
      result[player.id] = role;
    }
    return Map.unmodifiable(result);
  }

  void _applyForcedInjurySubstitutions({
    required SimulationLiveMatch live,
    required AiMatchdayRuntime runtime,
    required bool homeSide,
  }) {
    final teamId = homeSide ? live.homeTeamId : live.awayTeamId;
    for (final injury in live.injuries.where((item) => item.teamId == teamId)) {
      final key = '${injury.teamId}:${injury.playerId}:${injury.injury.type}';
      if (!runtime.handledInjuryKeys.add(key)) continue;
      final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
      if (!lineup.any((player) => player.id == injury.playerId)) continue;
      live.applyInjurySubstitution(
        homeSide: homeSide,
        playerOutId: injury.playerId,
        atHalfTime: live.isHalfTime,
        injuryType: injury.injury.type,
      );
    }
  }

  bool _applyRedCardReconfiguration({
    required SimulationLiveMatch live,
    required AiMatchdayRuntime runtime,
    required bool homeSide,
  }) {
    final teamId = homeSide ? live.homeTeamId : live.awayTeamId;
    final sentOff = live.state.sentOffPlayerIds.any(
      (playerId) => live.events.any(
        (event) =>
            event.teamId == teamId &&
            event.playerId == playerId &&
            event.type == MatchEventType.redCard,
      ),
    );
    if (!sentOff || runtime.hasHandled('red-card')) return false;
    final current = homeSide ? live.state.homeTactics : live.state.awayTactics;
    final accepted = live.updateTactics(
      homeSide: homeSide,
      tactics: current.copyWith(
        defensiveLine: DefensiveLine.deep,
        pressing: PressingIntensity.low,
      ),
    );
    runtime.markHandled('red-card');
    return accepted;
  }

  bool _applyStaminaTrigger({
    required SimulationLiveMatch live,
    required AiMatchdayRuntime runtime,
    required bool homeSide,
    required int threshold,
    required double probability,
    required String triggerKey,
    required bool allowAnyReplacement,
  }) {
    if (runtime.hasHandled(triggerKey) ||
        runtime.random.nextDouble() >= probability) {
      return false;
    }
    final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
    final outgoing = lineup
        .where((player) => player.position != Position.gk)
        .where((player) => live.currentStamina(player.id) < threshold)
        .fold<Player?>(null, (best, player) {
          if (best == null ||
              live.currentStamina(player.id) < live.currentStamina(best.id)) {
            return player;
          }
          return best;
        });
    if (outgoing == null) return false;
    final incoming = _bestSubstitute(
      live: live,
      homeSide: homeSide,
      outgoing: outgoing,
      allowAnyReplacement: allowAnyReplacement,
    );
    if (incoming == null) return false;
    final accepted = live.applySubstitution(
      homeSide: homeSide,
      playerOutId: outgoing.id,
      playerInId: incoming.id,
      atHalfTime: live.isHalfTime,
      windowId: 'ai:$triggerKey:${live.state.minute}',
    );
    runtime.markHandled(triggerKey);
    return accepted;
  }

  bool _applyRatingTrigger({
    required SimulationLiveMatch live,
    required AiMatchdayRuntime runtime,
    required bool homeSide,
  }) {
    const key = 'rating-low';
    if (runtime.hasHandled(key) ||
        runtime.random.nextDouble() >= balance.ai.pSubstitutionLowRating) {
      return false;
    }
    final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
    final attributes = homeSide
        ? live.homeEffectiveAttributes
        : live.awayEffectiveAttributes;
    final outgoing = lineup
        .where((player) => player.position != Position.gk)
        .where((player) {
          final effective = attributes[player.id];
          if (effective == null) return false;
          final average =
              effective.values.values.fold<double>(0, (a, b) => a + b) /
              effective.values.length;
          return average / 10.0 < 5.0;
        })
        .firstOrNull;
    if (outgoing == null) return false;
    final incoming = _bestSubstitute(
      live: live,
      homeSide: homeSide,
      outgoing: outgoing,
      allowAnyReplacement: true,
    );
    if (incoming == null) return false;
    final accepted = live.applySubstitution(
      homeSide: homeSide,
      playerOutId: outgoing.id,
      playerInId: incoming.id,
      atHalfTime: live.isHalfTime,
      windowId: 'ai:$key:${live.state.minute}',
    );
    runtime.markHandled(key);
    return accepted;
  }

  bool _applyYellowCardTrigger({
    required SimulationLiveMatch live,
    required AiMatchdayRuntime runtime,
    required bool homeSide,
  }) {
    const key = 'yellow-high-press';
    if (runtime.hasHandled(key) ||
        runtime.random.nextDouble() >= balance.ai.pSubstitutionYellowCard) {
      return false;
    }
    final current = homeSide ? live.state.homeTactics : live.state.awayTactics;
    if (current.pressing != PressingIntensity.high &&
        current.pressing != PressingIntensity.gegenpressing) {
      return false;
    }
    final teamId = homeSide ? live.homeTeamId : live.awayTeamId;
    final cardedIds = live.disciplines
        .where((item) => item.teamId == teamId && item.yellowCardsInMatch > 0)
        .map((item) => item.playerId)
        .toSet();
    final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
    final outgoing = lineup.firstWhereOrNull(
      (player) => cardedIds.contains(player.id),
    );
    if (outgoing == null) return false;
    final incoming = _bestSubstitute(
      live: live,
      homeSide: homeSide,
      outgoing: outgoing,
      allowAnyReplacement: true,
    );
    if (incoming == null) return false;
    final accepted = live.applySubstitution(
      homeSide: homeSide,
      playerOutId: outgoing.id,
      playerInId: incoming.id,
      atHalfTime: live.isHalfTime,
      windowId: 'ai:$key:${live.state.minute}',
    );
    runtime.markHandled(key);
    return accepted;
  }

  bool _applyScoreTrigger({
    required SimulationLiveMatch live,
    required AiMatchdayRuntime runtime,
    required bool homeSide,
    required String triggerKey,
    required double probability,
    required int count,
    required bool offensive,
  }) {
    if (runtime.hasHandled(triggerKey) ||
        runtime.random.nextDouble() >= probability) {
      return false;
    }
    var changed = false;
    for (var index = 0; index < count; index++) {
      final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
      final outgoing = _outgoingForDirection(lineup, offensive: offensive);
      if (outgoing == null) break;
      final incoming = _bestSubstitute(
        live: live,
        homeSide: homeSide,
        outgoing: outgoing,
        allowAnyReplacement: true,
        offensive: offensive,
      );
      if (incoming == null) break;
      final accepted = live.applySubstitution(
        homeSide: homeSide,
        playerOutId: outgoing.id,
        playerInId: incoming.id,
        atHalfTime: live.isHalfTime,
        windowId: 'ai:$triggerKey:${live.state.minute}',
      );
      if (!accepted) break;
      changed = true;
    }
    runtime.markHandled(triggerKey);
    return changed;
  }

  Player? _outgoingForDirection(
    List<Player> lineup, {
    required bool offensive,
  }) {
    final candidates = lineup
        .where((player) => player.position != Position.gk)
        .where(
          (player) => offensive
              ? _isDefender(player) || player.position == Position.cdm
              : _isAttacker(player) || player.position == Position.cam,
        )
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => a.overall(balance).compareTo(b.overall(balance)));
    return candidates.first;
  }

  Player? _bestSubstitute({
    required SimulationLiveMatch live,
    required bool homeSide,
    required Player outgoing,
    required bool allowAnyReplacement,
    bool? offensive,
  }) {
    final bench = homeSide ? live.state.homeBench : live.state.awayBench;
    final assigned = homeSide
        ? live.homeAssignedPositions[outgoing.id] ?? outgoing.position
        : live.awayAssignedPositions[outgoing.id] ?? outgoing.position;
    final candidates = bench.where((player) => player.isAvailable).where((
      player,
    ) {
      if (offensive == null) return true;
      return offensive
          ? _isAttacker(player) || player.position == Position.cam
          : _isDefender(player) || player.position == Position.cdm;
    }).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final aScore = playerMatchScore(a, assigned);
      final bScore = playerMatchScore(b, assigned);
      return bScore.compareTo(aScore);
    });
    if (!allowAnyReplacement &&
        candidates.first.overall(balance) < outgoing.overall(balance) - 4) {
      return null;
    }
    return candidates.first;
  }

  double _averageOverall(Iterable<Player> players) {
    final list = players.toList(growable: false);
    if (list.isEmpty) return 0;
    return list.fold<double>(
          0,
          (sum, player) => sum + player.overall(balance),
        ) /
        list.length;
  }

  double _aerialRating(Player player) =>
      player.heightCm * 0.20 +
      player.attributes.map(
        outfield: (attributes) => attributes.stats.physicality * 0.60,
        goalkeeper: (attributes) => attributes.stats.overall * 0.60,
      );

  double _shootingRating(Player player) => player.attributes.map(
    outfield: (attributes) => attributes.stats.shooting.toDouble(),
    goalkeeper: (attributes) => attributes.stats.overall,
  );

  double _average(Iterable<double> values, {required double fallback}) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return fallback;
    return list.fold<double>(0, (sum, value) => sum + value) / list.length;
  }

  bool _isDefender(Player player) =>
      positionGroupOf(player.position) == PositionGroup.centreBack ||
      positionGroupOf(player.position) == PositionGroup.fullBack ||
      positionGroupOf(player.position) == PositionGroup.wingBack;

  bool _isMidfielder(Player player) =>
      positionGroupOf(player.position) == PositionGroup.midfield;

  bool _isAttacker(Player player) =>
      positionGroupOf(player.position) == PositionGroup.winger ||
      positionGroupOf(player.position) == PositionGroup.striker;

  bool _isOffensiveRole(AssignedRole role) => role.map(
    gk: (_) => false,
    cb: (value) => value.role == CbRole.ballPlayingDefender,
    fullBack: (value) => value.role == FullBackRole.attackingFullBack,
    wingBack: (value) => value.role == WingBackRole.wingBack,
    cdm: (value) =>
        value.role == CdmRole.regista ||
        value.role == CdmRole.deepLyingPlaymaker,
    cm: (value) =>
        value.role == CmRole.playmaker ||
        value.role == CmRole.boxToBox ||
        value.role == CmRole.mezzala,
    cam: (value) =>
        value.role == CamRole.playmaker || value.role == CamRole.shadowStriker,
    winger: (value) =>
        value.role == WingerRole.winger ||
        value.role == WingerRole.invertedWinger,
    striker: (value) => value.role != StrikerRole.standard,
  );

  bool _isDefensiveRole(AssignedRole role) => role.map(
    gk: (_) => false,
    cb: (value) => value.role == CbRole.noNonsenseCentreBack,
    fullBack: (value) => value.role == FullBackRole.defensiveFullBack,
    wingBack: (value) =>
        value.role == WingBackRole.standard ||
        value.role == WingBackRole.invertedWingBack,
    cdm: (value) => value.role == CdmRole.anchorMan,
    cm: (value) => value.role == CmRole.ballWinning,
    cam: (value) => value.role == CamRole.standard,
    winger: (value) => value.role == WingerRole.standard,
    striker: (value) => value.role == StrikerRole.deepLyingForward,
  );
}

class _LineupSelection {
  const _LineupSelection({
    required this.lineup,
    required this.assignedPositions,
    required this.playerScores,
    required this.rotationReasons,
  });

  final List<Player> lineup;
  final Map<String, Position> assignedPositions;
  final Map<String, double> playerScores;
  final Map<String, String> rotationReasons;
}

extension _FirstOrNullIterable<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;

  T? firstWhereOrNull(bool Function(T value) test) {
    for (final value in this) {
      if (test(value)) return value;
    }
    return null;
  }
}
