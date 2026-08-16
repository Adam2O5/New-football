import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/engine/match_engine.dart' as legacy;
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/simulation/duel_resolver.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/sequence_resolver.dart';
import 'package:new_football/core/simulation/team_shape.dart';
import 'package:new_football/core/simulation/unit_ratings.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

class SimulationSequenceTrace {
  const SimulationSequenceTrace({
    required this.type,
    required this.attackingHome,
    required this.attackerId,
    required this.defenderId,
    required this.duel,
  });

  final SequenceType type;
  final bool attackingHome;
  final String attackerId;
  final String defenderId;
  final DuelResult duel;
}

class SimulationMinuteTrace {
  const SimulationMinuteTrace({
    required this.minute,
    required this.homePossessionProbability,
    required this.homePossession,
    required this.sequenceCount,
    required this.homeSequenceCount,
    required this.awaySequenceCount,
    required this.sequences,
    required this.randomCursorStart,
    required this.randomCursorEnd,
  });

  factory SimulationMinuteTrace.empty({
    required int minute,
    required int randomCursor,
  }) => SimulationMinuteTrace(
    minute: minute,
    homePossessionProbability: 0.5,
    homePossession: true,
    sequenceCount: 0,
    homeSequenceCount: 0,
    awaySequenceCount: 0,
    sequences: const [],
    randomCursorStart: randomCursor,
    randomCursorEnd: randomCursor,
  );

  final int minute;
  final double homePossessionProbability;
  final bool homePossession;
  final int sequenceCount;
  final int homeSequenceCount;
  final int awaySequenceCount;
  final List<SimulationSequenceTrace> sequences;
  final int randomCursorStart;
  final int randomCursorEnd;
}

/// Runtime-only result for Task 17. It intentionally does not replace
/// [MatchResult] until Tasks 18–22 complete the shot, event and UI pipeline.
class SimulationResult {
  SimulationResult({
    required this.seed,
    required this.context,
    required this.finalState,
    required List<SimulationMinuteTrace> minuteTraces,
    required this.homeSequences,
    required this.awaySequences,
    required this.totalSequences,
    required this.homePossessionPercent,
  }) : minuteTraces = List.unmodifiable(minuteTraces);

  final int seed;
  final MatchContext context;
  final MatchState finalState;
  final List<SimulationMinuteTrace> minuteTraces;
  final int homeSequences;
  final int awaySequences;
  final int totalSequences;
  final double homePossessionPercent;

  double get awayPossessionPercent => 100.0 - homePossessionPercent;
  int get minutesSimulated => minuteTraces.length;

  /// Stable, human-readable digest of the complete Task 17 roll trace.
  String get traceSignature => minuteTraces
      .map(
        (minute) => [
          minute.minute,
          minute.homePossessionProbability.toStringAsFixed(8),
          minute.homePossession ? 'H' : 'A',
          minute.sequenceCount,
          for (final sequence in minute.sequences)
            [
              sequence.type.name,
              sequence.attackingHome ? 'H' : 'A',
              sequence.attackerId,
              sequence.defenderId,
              sequence.duel.attackerProbability.toStringAsFixed(8),
              sequence.duel.attackerWon == true ? 'W' : 'L',
            ].join(','),
        ].join(':'),
      )
      .join('|');
}

/// A Task 17 runtime around the existing pre-match [legacy.LiveMatch].
///
/// Reusing [legacy.LiveMatch] keeps Task 15 validation, snapshots, stamina
/// storage and Task 16 diagnostic fields consistent. The legacy minute solver
/// is never called; this class owns the new one-stream simulation loop.
class SimulationLiveMatch {
  SimulationLiveMatch({
    required this.legacyMatch,
    required this.random,
    required this.seed,
  });

  final legacy.LiveMatch legacyMatch;
  final MatchRandom random;
  final int seed;
  final List<SimulationMinuteTrace> minuteTraces = [];

  double _homePossessionSum = 0;
  int _homeSequences = 0;
  int _awaySequences = 0;

  MatchState get state => legacyMatch.state;
  bool get isFinished => legacyMatch.isFinished;
  String get homeTeamId => legacyMatch.homeTeamId;
  String get awayTeamId => legacyMatch.awayTeamId;
  TeamShape? get homeTeamShape => legacyMatch.homeTeamShape;
  TeamShape? get awayTeamShape => legacyMatch.awayTeamShape;
  UnitRatings? get homeUnitRatings => legacyMatch.homeUnitRatings;
  UnitRatings? get awayUnitRatings => legacyMatch.awayUnitRatings;
  Map<String, EffectivePlayerAttributes> get homeEffectiveAttributes =>
      legacyMatch.homeEffectiveAttributes;
  Map<String, EffectivePlayerAttributes> get awayEffectiveAttributes =>
      legacyMatch.awayEffectiveAttributes;

  int get totalSequences => _homeSequences + _awaySequences;
  int get homeSequences => _homeSequences;
  int get awaySequences => _awaySequences;

  SimulationResult toResult() => SimulationResult(
    seed: seed,
    context: state.context,
    finalState: state,
    minuteTraces: minuteTraces,
    homeSequences: _homeSequences,
    awaySequences: _awaySequences,
    totalSequences: totalSequences,
    homePossessionPercent: minuteTraces.isEmpty
        ? 50.0
        : _homePossessionSum / minuteTraces.length * 100.0,
  );
}

/// Task 17 engine. It is deliberately not wired to the production provider;
/// Task 22 will perform the cutover after Tasks 18–21 complete.
class SimulationMatchEngine {
  const SimulationMatchEngine({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  SimulationLiveMatch start({
    required Team home,
    required Team away,
    MatchContext context = const MatchContext(),
    int rngSeed = 0,
  }) {
    final seed = context.seed == 0 ? rngSeed : context.seed;
    final seededContext = context.copyWith(seed: seed);
    final live = legacy.MatchEngine(
      balance: balance,
    ).start(home: home, away: away, context: seededContext, rngSeed: seed);
    final simulation = SimulationLiveMatch(
      legacyMatch: live,
      random: MatchRandom(seed),
      seed: seed,
    );
    _refreshRuntimeRatings(simulation);
    return simulation;
  }

  SimulationMinuteTrace simulateMinute(SimulationLiveMatch live) {
    if (live.isFinished) {
      return SimulationMinuteTrace.empty(
        minute: live.state.minute,
        randomCursor: live.random.cursor,
      );
    }

    final nextMinute = live.state.minute + 1;
    final cursorStart = live.random.cursor;
    final previousHomeLineup = live.state.homeLineup;
    final previousAwayLineup = live.state.awayLineup;
    var state = live.state.copyWith(minute: nextMinute);

    // Task 17 order 1: stamina tick for the players on the pitch at minute
    // start. Task 16 is refreshed only after both sides have been ticked.
    state = state.copyWith(
      homeLineup: live.legacyMatch.recordMinute(
        lineup: previousHomeLineup,
        homeSide: true,
      ),
      awayLineup: live.legacyMatch.recordMinute(
        lineup: previousAwayLineup,
        homeSide: false,
      ),
    );
    live.legacyMatch.state = state;

    // Task 17 order 2: derive effAttr and D/M/A ratings from fresh stamina.
    _refreshRuntimeRatings(live);
    final homeRatings = live.homeUnitRatings ?? _emptyRatings;
    final awayRatings = live.awayUnitRatings ?? _emptyRatings;

    // Task 17 order 3: one noisy contest produces the possession probability;
    // the adjusted probability receives one Bernoulli roll for the minute.
    final possessionDuel = DuelResolver(balance: balance).contest(
      attackerRating: homeRatings.midRating,
      defenderRating: awayRatings.midRating,
      random: live.random,
      resolveWinner: false,
    );
    final possessionProbability = _possessionProbability(
      baseProbability: possessionDuel.attackerProbability,
      homeTactics: state.homeTactics,
      awayTactics: state.awayTactics,
    );
    final homePossession = live.random.nextDouble() < possessionProbability;
    live._homePossessionSum += possessionProbability;

    // Task 17 order 4: Poisson sequence count, bounded to 0–3.
    final sequenceCount = live.random
        .nextPoisson(_sequenceLambda(state))
        .clamp(0, balance.matchday.sequenceMaxPerMinute)
        .toInt();
    final sequenceTraces = <SimulationSequenceTrace>[];
    var homeSequenceCount = 0;
    var awaySequenceCount = 0;

    // Task 17 order 5: each sequence consumes side, type, player selection,
    // then one noisy core duel. Task 18 will expand this into multi-duel shot
    // chains without changing the RNG ownership contract.
    for (var index = 0; index < sequenceCount; index++) {
      final attackingHome = live.random.nextDouble() < possessionProbability;
      final context = _sequenceContext(live, attackingHome: attackingHome);
      final selection = SequenceSelector(
        balance: balance,
      ).select(context: context, random: live.random);
      final attackerAttributes =
          context.attackingEffectiveAttributes[selection.attacker.id];
      final defenderAttributes =
          context.defendingEffectiveAttributes[selection.defender.id];
      final attackerRating = attackerAttributes == null
          ? context.attackingRatings.atkRating
          : const DuelResolver().weightedRating(
              attackerAttributes,
              selection.attackerAttributeWeights,
            );
      final defenderRating = defenderAttributes == null
          ? context.defendingRatings.defRating
          : const DuelResolver().weightedRating(
              defenderAttributes,
              selection.defenderAttributeWeights,
            );
      final duel = DuelResolver(balance: balance).contest(
        attackerRating: attackerRating,
        defenderRating: defenderRating,
        random: live.random,
      );
      sequenceTraces.add(
        SimulationSequenceTrace(
          type: selection.type,
          attackingHome: attackingHome,
          attackerId: selection.attacker.id,
          defenderId: selection.defender.id,
          duel: duel,
        ),
      );
      if (attackingHome) {
        homeSequenceCount++;
      } else {
        awaySequenceCount++;
      }
    }

    live._homeSequences += homeSequenceCount;
    live._awaySequences += awaySequenceCount;
    final trace = SimulationMinuteTrace(
      minute: nextMinute,
      homePossessionProbability: possessionProbability,
      homePossession: homePossession,
      sequenceCount: sequenceCount,
      homeSequenceCount: homeSequenceCount,
      awaySequenceCount: awaySequenceCount,
      sequences: List.unmodifiable(sequenceTraces),
      randomCursorStart: cursorStart,
      randomCursorEnd: live.random.cursor,
    );
    live.minuteTraces.add(trace);
    return trace;
  }

  List<SimulationMinuteTrace> runUntil(
    SimulationLiveMatch live,
    int untilMinute,
  ) {
    final traces = <SimulationMinuteTrace>[];
    while (!live.isFinished && live.state.minute < untilMinute) {
      traces.add(simulateMinute(live));
    }
    return traces;
  }

  SimulationResult simulateFull({
    required Team home,
    required Team away,
    MatchContext context = const MatchContext(),
    int rngSeed = 0,
  }) {
    final live = start(
      home: home,
      away: away,
      context: context,
      rngSeed: rngSeed,
    );
    runUntil(live, 90);
    return live.toResult();
  }

  void _refreshRuntimeRatings(SimulationLiveMatch live) {
    final state = live.state;
    final homeLineup = state.homeLineup;
    final awayLineup = state.awayLineup;
    final shapeCalculator = TeamShapeCalculator(balance: balance);
    final effectiveCalculator = EffectiveAttributeCalculator(balance: balance);
    final unitCalculator = UnitRatingCalculator(balance: balance);
    final homeShape = shapeCalculator.calculate(
      tactics: state.homeTactics,
      opponentTactics: state.awayTactics,
      lineup: homeLineup,
      opponentLineup: awayLineup,
      headCoach: live.legacyMatch.homeHeadCoach,
    );
    final awayShape = shapeCalculator.calculate(
      tactics: state.awayTactics,
      opponentTactics: state.homeTactics,
      lineup: awayLineup,
      opponentLineup: homeLineup,
      headCoach: live.legacyMatch.awayHeadCoach,
    );
    final homeEffective = effectiveCalculator.calculateLineup(
      lineup: homeLineup,
      context: state.context,
      chemistry: live.legacyMatch.homeChemistry,
      atmosphere: live.legacyMatch.homeAtmosphere,
      cohesionMultiplier: live.legacyMatch.homeCohesionMult,
      isHome: true,
      headCoach: live.legacyMatch.homeHeadCoach,
      staminaRemaining: live.legacyMatch.staminaRemaining,
      assignedPositions: _assignedPositions(live.legacyMatch.homeSnapshot),
    );
    final awayEffective = effectiveCalculator.calculateLineup(
      lineup: awayLineup,
      context: state.context,
      chemistry: live.legacyMatch.awayChemistry,
      atmosphere: live.legacyMatch.awayAtmosphere,
      cohesionMultiplier: live.legacyMatch.awayCohesionMult,
      isHome: false,
      headCoach: live.legacyMatch.awayHeadCoach,
      staminaRemaining: live.legacyMatch.staminaRemaining,
      assignedPositions: _assignedPositions(live.legacyMatch.awaySnapshot),
    );

    live.legacyMatch.homeTeamShape = homeShape;
    live.legacyMatch.awayTeamShape = awayShape;
    live.legacyMatch.homeEffectiveAttributes = Map.unmodifiable(homeEffective);
    live.legacyMatch.awayEffectiveAttributes = Map.unmodifiable(awayEffective);
    live.legacyMatch.homeUnitRatings = unitCalculator.calculate(
      lineup: homeLineup,
      effectiveAttributes: homeEffective,
      shape: homeShape,
    );
    live.legacyMatch.awayUnitRatings = unitCalculator.calculate(
      lineup: awayLineup,
      effectiveAttributes: awayEffective,
      shape: awayShape,
    );
  }

  SequenceContext _sequenceContext(
    SimulationLiveMatch live, {
    required bool attackingHome,
  }) {
    final state = live.state;
    final attackingLineup = attackingHome ? state.homeLineup : state.awayLineup;
    final defendingLineup = attackingHome ? state.awayLineup : state.homeLineup;
    final attackingTactics = attackingHome
        ? state.homeTactics
        : state.awayTactics;
    final defendingTactics = attackingHome
        ? state.awayTactics
        : state.homeTactics;
    final attackingEffective = attackingHome
        ? live.homeEffectiveAttributes
        : live.awayEffectiveAttributes;
    final defendingEffective = attackingHome
        ? live.awayEffectiveAttributes
        : live.homeEffectiveAttributes;
    final attackingRatings = attackingHome
        ? live.homeUnitRatings ?? _emptyRatings
        : live.awayUnitRatings ?? _emptyRatings;
    final defendingRatings = attackingHome
        ? live.awayUnitRatings ?? _emptyRatings
        : live.homeUnitRatings ?? _emptyRatings;
    final attackingSnapshot = attackingHome
        ? live.legacyMatch.homeSnapshot
        : live.legacyMatch.awaySnapshot;
    final defendingSnapshot = attackingHome
        ? live.legacyMatch.awaySnapshot
        : live.legacyMatch.homeSnapshot;

    return SequenceContext(
      attackingTactics: attackingTactics,
      defendingTactics: defendingTactics,
      attackingLineup: attackingLineup,
      defendingLineup: defendingLineup,
      attackingEffectiveAttributes: attackingEffective,
      defendingEffectiveAttributes: defendingEffective,
      attackingRatings: attackingRatings,
      defendingRatings: defendingRatings,
      weather: state.context.weather,
      attackingAssignedPositions: _assignedPositions(attackingSnapshot),
      defendingAssignedPositions: _assignedPositions(defendingSnapshot),
    );
  }

  double _possessionProbability({
    required double baseProbability,
    required TacticsSetup homeTactics,
    required TacticsSetup awayTactics,
  }) {
    double settingDelta(TacticsSetup tactics) {
      var delta = 0.0;
      if (tactics.tempo == Tempo.slow) {
        delta += balance.matchday.possessionSlowBonus;
      } else if (tactics.tempo == Tempo.fast) {
        delta -= balance.matchday.possessionFastPenalty;
      }
      if (tactics.pressing == PressingIntensity.gegenpressing) {
        delta += balance.matchday.possessionGegenpressingBonus;
      }
      return delta;
    }

    return (baseProbability +
            settingDelta(homeTactics) -
            settingDelta(awayTactics))
        .clamp(0.02, 0.98)
        .toDouble();
  }

  double _sequenceLambda(MatchState state) {
    final homeTempo = balance.matchday.tempoMultiplier(state.homeTactics.tempo);
    final awayTempo = balance.matchday.tempoMultiplier(state.awayTactics.tempo);
    final homePress = balance.matchday.pressingMultiplier(
      state.homeTactics.pressing,
    );
    final awayPress = balance.matchday.pressingMultiplier(
      state.awayTactics.pressing,
    );
    final tempoMultiplier = (homeTempo + awayTempo) / 2.0;
    final pressingMultiplier = (homePress + awayPress) / 2.0;
    final documentedMomentum = _documentedMomentum(state.momentum);
    final momentumMultiplier =
        1.0 + documentedMomentum / balance.matchday.momentumSequenceDivisor;
    return balance.matchday.sequenceBase *
        tempoMultiplier *
        pressingMultiplier *
        momentumMultiplier *
        balance.matchday.stakeMultiplier(state.context.stake);
  }

  double _documentedMomentum(double runtimeMomentum) {
    // Task 16 uses a small [-1, 1] drift, while matchday_model.md documents
    // [-100, 100]. Values outside [-1, 1] are already in the documented scale
    // (the legacy kickoff crowd value is one such value).
    final documented = runtimeMomentum.abs() <= 1
        ? runtimeMomentum * 100
        : runtimeMomentum;
    return documented.clamp(-100.0, 100.0).toDouble();
  }

  Map<String, Position> _assignedPositions(MatchTeamSnapshot? snapshot) {
    if (snapshot == null || snapshot.startingXi.isEmpty) return const {};
    return {
      for (
        var index = 0;
        index < snapshot.startingXi.length &&
            index < snapshot.assignedPositions.length;
        index++
      )
        snapshot.startingXi[index].id: snapshot.assignedPositions[index],
    };
  }

  static const _emptyRatings = UnitRatings(
    defRating: 0,
    midRating: 0,
    atkRating: 0,
  );
}
