import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/engine/match_engine.dart' as legacy;
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/services/cohesion_service.dart';
import 'package:new_football/core/simulation/duel_resolver.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/matchday_runtime.dart';
import 'package:new_football/core/simulation/sequence_chain_resolver.dart';
import 'package:new_football/core/simulation/sequence_resolver.dart';
import 'package:new_football/core/simulation/set_piece_resolver.dart';
import 'package:new_football/core/simulation/shot_models.dart';
import 'package:new_football/core/simulation/shot_resolver.dart';
import 'package:new_football/core/simulation/team_shape.dart';
import 'package:new_football/core/simulation/unit_ratings.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

class SimulationSequenceTrace {
  const SimulationSequenceTrace({
    required this.type,
    required this.attackingHome,
    required this.attackerId,
    required this.defenderId,
    required this.duel,
    this.duels = const [],
    this.chain,
    this.shot,
    this.setPiece,
  });

  final SequenceType type;
  final bool attackingHome;
  final String attackerId;
  final String defenderId;

  /// Backwards-compatible first duel from Task 17. It is null for a pure
  /// set-piece sequence that has no outfield chain.
  final DuelResult? duel;
  final List<SequenceDuelTrace> duels;
  final SequenceResolution? chain;
  final ShotResolution? shot;
  final SetPieceResolution? setPiece;

  bool get isGoal => shot?.isGoal ?? false;
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

/// Runtime-only result for Task 18. It intentionally does not replace
/// [MatchResult] until the later event, UI and persistence cutover tasks.
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
    required this.homeShots,
    required this.awayShots,
    required this.homeShotsOnTarget,
    required this.awayShotsOnTarget,
    required this.homeXg,
    required this.awayXg,
    required this.homeCorners,
    required this.awayCorners,
  }) : minuteTraces = List.unmodifiable(minuteTraces);

  final int seed;
  final MatchContext context;
  final MatchState finalState;
  final List<SimulationMinuteTrace> minuteTraces;
  final int homeSequences;
  final int awaySequences;
  final int totalSequences;
  final double homePossessionPercent;
  final int homeShots;
  final int awayShots;
  final int homeShotsOnTarget;
  final int awayShotsOnTarget;
  final double homeXg;
  final double awayXg;
  final int homeCorners;
  final int awayCorners;

  double get awayPossessionPercent => 100.0 - homePossessionPercent;
  int get minutesSimulated => minuteTraces.length;
  int get homeGoals => finalState.homeGoals;
  int get awayGoals => finalState.awayGoals;
  int get totalGoals => homeGoals + awayGoals;

  /// Stable digest including Task 17 duels and Task 18 shot outcomes.
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
              sequence.duel?.attackerProbability.toStringAsFixed(8) ?? 'none',
              sequence.duel?.attackerWon == true ? 'W' : 'L',
              sequence.chain?.wonDuels ?? 0,
              sequence.shot?.outcome?.name ?? 'no-shot',
              sequence.shot?.xg.toStringAsFixed(8) ?? '0.00000000',
              sequence.shot?.reboundGoal == true ? 'R' : '-',
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
    required this.balance,
    Map<String, int>? homeChemistryAppearances,
    Map<String, int>? awayChemistryAppearances,
  }) : homeChemistryAppearances = Map.unmodifiable(
         homeChemistryAppearances ?? const {},
       ),
       awayChemistryAppearances = Map.unmodifiable(
         awayChemistryAppearances ?? const {},
       ),
       _homeAssignedPositions = _initialAssignedPositions(
         legacyMatch.homeSnapshot,
         legacyMatch.state.homeLineup,
       ),
       _awayAssignedPositions = _initialAssignedPositions(
         legacyMatch.awaySnapshot,
         legacyMatch.state.awayLineup,
       );

  final legacy.LiveMatch legacyMatch;
  final MatchRandom random;
  final int seed;
  final BalanceConfig balance;
  final Map<String, int> homeChemistryAppearances;
  final Map<String, int> awayChemistryAppearances;
  final Map<String, Position> _homeAssignedPositions;
  final Map<String, Position> _awayAssignedPositions;
  final Set<String> _homeSubstitutionWindowKeys = <String>{};
  final Set<String> _awaySubstitutionWindowKeys = <String>{};
  final Set<String> _homeSubstitutedOutIds = <String>{};
  final Set<String> _awaySubstitutedOutIds = <String>{};
  final Set<String> _homeUnreplacedMajorInjuryIds = <String>{};
  final Set<String> _awayUnreplacedMajorInjuryIds = <String>{};
  int? _homeTacticalPenaltyExpiresAtMinute;
  int? _awayTacticalPenaltyExpiresAtMinute;
  SimulationActionResult? lastAction;
  final List<SimulationMinuteTrace> minuteTraces = [];

  double _homePossessionSum = 0;
  int _homeSequences = 0;
  int _awaySequences = 0;
  int _homeShots = 0;
  int _awayShots = 0;
  int _homeShotsOnTarget = 0;
  int _awayShotsOnTarget = 0;
  double _homeXg = 0;
  double _awayXg = 0;
  int _homeCorners = 0;
  int _awayCorners = 0;
  bool _homeCounterAttackEligible = false;
  bool _awayCounterAttackEligible = false;

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

  Map<String, Position> get homeAssignedPositions =>
      Map.unmodifiable(_homeAssignedPositions);
  Map<String, Position> get awayAssignedPositions =>
      Map.unmodifiable(_awayAssignedPositions);

  bool get isHalfTime => state.minute == 45;
  int get homeSubsUsed => legacyMatch.homeSubsUsed;
  int get awaySubsUsed => legacyMatch.awaySubsUsed;
  int get homeSubWindows => legacyMatch.homeSubWindows;
  int get awaySubWindows => legacyMatch.awaySubWindows;
  double get homeCohesionMultiplier => _runtimeCohesionMultiplier(true);
  double get awayCohesionMultiplier => _runtimeCohesionMultiplier(false);
  double get homeCohesionMult => homeCohesionMultiplier;
  double get awayCohesionMult => awayCohesionMultiplier;
  double get homeCohesionScore => _runtimeCohesionScore(true);
  double get awayCohesionScore => _runtimeCohesionScore(false);
  double get homeAdaptationPenalty => _adaptationPenalty(true);
  double get awayAdaptationPenalty => _adaptationPenalty(false);
  int get homeTacticalPenaltyRemaining =>
      _remainingPenaltyMinutes(_homeTacticalPenaltyExpiresAtMinute);
  int get awayTacticalPenaltyRemaining =>
      _remainingPenaltyMinutes(_awayTacticalPenaltyExpiresAtMinute);
  bool get homeTacticalPenaltyActive => homeTacticalPenaltyRemaining > 0;
  bool get awayTacticalPenaltyActive => awayTacticalPenaltyRemaining > 0;
  Set<String> get homeUnreplacedMajorInjuryIds =>
      Set.unmodifiable(_homeUnreplacedMajorInjuryIds);
  Set<String> get awayUnreplacedMajorInjuryIds =>
      Set.unmodifiable(_awayUnreplacedMajorInjuryIds);

  bool applySubstitution({
    required bool homeSide,
    required String playerOutId,
    required String playerInId,
    bool? atHalfTime,
    bool forced = false,
    String? windowId,
  }) => SimulationMatchEngine(balance: balance).applySubstitution(
    live: this,
    homeSide: homeSide,
    playerOutId: playerOutId,
    playerInId: playerInId,
    atHalfTime: atHalfTime,
    forced: forced,
    windowId: windowId,
  );

  bool applyMajorInjurySubstitution({
    required bool homeSide,
    required String playerOutId,
    String? playerInId,
    bool? atHalfTime,
  }) => SimulationMatchEngine(balance: balance).applyMajorInjurySubstitution(
    live: this,
    homeSide: homeSide,
    playerOutId: playerOutId,
    playerInId: playerInId,
    atHalfTime: atHalfTime,
  );

  bool updateTactics({
    required bool homeSide,
    required TacticsSetup tactics,
    bool? atHalfTime,
  }) => SimulationMatchEngine(balance: balance).updateTactics(
    live: this,
    homeSide: homeSide,
    tactics: tactics,
    atHalfTime: atHalfTime,
  );

  double _runtimeCohesionMultiplier(bool homeSide) {
    final score = _runtimeCohesionScore(homeSide);
    var multiplier = const CohesionService().cohesionMult(
      score.clamp(0.0, 100.0),
      headCoach: homeSide
          ? legacyMatch.homeHeadCoach
          : legacyMatch.awayHeadCoach,
    );
    if (_remainingPenaltyMinutes(
          homeSide
              ? _homeTacticalPenaltyExpiresAtMinute
              : _awayTacticalPenaltyExpiresAtMinute,
        ) >
        0) {
      multiplier -= balance.matchday.cohesionTacticsPenalty / 100.0;
    }
    return multiplier.clamp(0.0, 2.0).toDouble();
  }

  double _runtimeCohesionScore(bool homeSide) {
    final lineup = homeSide ? state.homeLineup : state.awayLineup;
    final assignments = homeSide
        ? _homeAssignedPositions
        : _awayAssignedPositions;
    var score = 50.0;
    for (final player in lineup) {
      final assigned = assignments[player.id] ?? player.position;
      score += player.position == assigned ? 2.0 : -5.0;
      if (player.state.role == player.optimalRole) score += 2.0;
    }
    score -= _adaptationPenalty(homeSide);
    return score.clamp(0.0, 100.0).toDouble();
  }

  double _adaptationPenalty(bool homeSide) {
    final lineup = homeSide ? state.homeLineup : state.awayLineup;
    final appearances = homeSide
        ? homeChemistryAppearances
        : awayChemistryAppearances;
    return lineup.fold<double>(
      0.0,
      (sum, player) =>
          sum +
          balance.matchday.adaptationPenaltyForAppearances(
            appearances[player.id] ?? 0,
          ),
    );
  }

  int _remainingPenaltyMinutes(int? expiresAtMinute) {
    if (expiresAtMinute == null) return 0;
    final remaining = expiresAtMinute - state.minute;
    return remaining > 0 ? remaining : 0;
  }

  int get totalSequences => _homeSequences + _awaySequences;
  int get homeSequences => _homeSequences;
  int get awaySequences => _awaySequences;
  int get homeShots => _homeShots;
  int get awayShots => _awayShots;
  int get homeShotsOnTarget => _homeShotsOnTarget;
  int get awayShotsOnTarget => _awayShotsOnTarget;
  double get homeXg => _homeXg;
  double get awayXg => _awayXg;
  int get homeCorners => _homeCorners;
  int get awayCorners => _awayCorners;

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
    homeShots: _homeShots,
    awayShots: _awayShots,
    homeShotsOnTarget: _homeShotsOnTarget,
    awayShotsOnTarget: _awayShotsOnTarget,
    homeXg: _homeXg,
    awayXg: _awayXg,
    homeCorners: _homeCorners,
    awayCorners: _awayCorners,
  );

  static Map<String, Position> _initialAssignedPositions(
    MatchTeamSnapshot? snapshot,
    List<Player> lineup,
  ) {
    final assignments = <String, Position>{};
    if (snapshot != null) {
      for (
        var index = 0;
        index < snapshot.startingXi.length &&
            index < snapshot.assignedPositions.length;
        index++
      ) {
        assignments[snapshot.startingXi[index].id] =
            snapshot.assignedPositions[index];
      }
    }
    for (final player in lineup) {
      assignments.putIfAbsent(player.id, () => player.position);
    }
    return assignments;
  }
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
      balance: balance,
      homeChemistryAppearances: home.chemistryAppearances,
      awayChemistryAppearances: away.chemistryAppearances,
    );
    _refreshRuntimeRatings(simulation);
    return simulation;
  }

  bool applySubstitution({
    required SimulationLiveMatch live,
    required bool homeSide,
    required String playerOutId,
    required String playerInId,
    bool? atHalfTime,
    bool forced = false,
    String? windowId,
  }) => applySubstitutionResult(
    live: live,
    homeSide: homeSide,
    playerOutId: playerOutId,
    playerInId: playerInId,
    atHalfTime: atHalfTime,
    forced: forced,
    windowId: windowId,
  ).accepted;

  SimulationActionResult applySubstitutionResult({
    required SimulationLiveMatch live,
    required bool homeSide,
    required String playerOutId,
    required String playerInId,
    bool? atHalfTime,
    bool forced = false,
    String? windowId,
  }) {
    if (live.isFinished) {
      return _reject(live, SimulationActionFailure.matchFinished);
    }

    final halftime = atHalfTime ?? live.isHalfTime;
    final state = live.state;
    final lineup = List<Player>.from(
      homeSide ? state.homeLineup : state.awayLineup,
    );
    final bench = List<Player>.from(
      homeSide ? state.homeBench : state.awayBench,
    );
    final outIndex = lineup.indexWhere((player) => player.id == playerOutId);
    if (outIndex < 0) {
      return _reject(live, SimulationActionFailure.playerNotOnPitch);
    }
    final inIndex = bench.indexWhere((player) => player.id == playerInId);
    if (inIndex < 0) {
      return _reject(live, SimulationActionFailure.playerNotOnBench);
    }

    final substitutedOutIds = homeSide
        ? live._homeSubstitutedOutIds
        : live._awaySubstitutedOutIds;
    if (substitutedOutIds.contains(playerInId)) {
      return _reject(live, SimulationActionFailure.playerCannotReenter);
    }

    final outgoing = lineup[outIndex];
    final incoming = bench[inIndex];
    if (!forced && !outgoing.isAvailable) {
      return _reject(live, SimulationActionFailure.playerUnavailable);
    }
    if (!incoming.isAvailable) {
      return _reject(live, SimulationActionFailure.playerUnavailable);
    }

    final windowKeys = homeSide
        ? live._homeSubstitutionWindowKeys
        : live._awaySubstitutionWindowKeys;
    final currentWindows = homeSide ? live.homeSubWindows : live.awaySubWindows;
    final key = windowId ?? 'minute:${state.minute}';
    final isNewOrdinaryWindow = !halftime && !windowKeys.contains(key);
    if (!halftime && !forced && isNewOrdinaryWindow) {
      if (currentWindows >= balance.matchday.maxSubstitutionWindows) {
        return _reject(live, SimulationActionFailure.substitutionWindowsLimit);
      }
    }
    final used = homeSide ? live.homeSubsUsed : live.awaySubsUsed;
    if (used >= balance.matchday.maxSubstitutions) {
      return _reject(live, SimulationActionFailure.substitutionsLimit);
    }

    final assignments = homeSide
        ? live._homeAssignedPositions
        : live._awayAssignedPositions;
    final assignedPosition = assignments[outgoing.id] ?? outgoing.position;
    lineup[outIndex] = incoming;
    bench.removeAt(inIndex);
    bench.add(outgoing);
    assignments.remove(outgoing.id);
    assignments[incoming.id] = assignedPosition;
    live.legacyMatch.staminaRemaining.putIfAbsent(
      incoming.id,
      () => incoming.state.stamina.toDouble(),
    );

    live.legacyMatch.state = homeSide
        ? state.copyWith(homeLineup: lineup, homeBench: bench)
        : state.copyWith(awayLineup: lineup, awayBench: bench);
    substitutedOutIds.add(outgoing.id);
    if (homeSide) {
      live.legacyMatch.homeSubsUsed++;
    } else {
      live.legacyMatch.awaySubsUsed++;
    }
    if (isNewOrdinaryWindow && !forced) {
      windowKeys.add(key);
      if (homeSide) {
        live.legacyMatch.homeSubWindows++;
      } else {
        live.legacyMatch.awaySubWindows++;
      }
    }

    live.legacyMatch.events.add(
      MatchEvent(
        type: MatchEventType.substitution,
        minute: state.minute,
        teamId: homeSide ? live.homeTeamId : live.awayTeamId,
        playerId: incoming.id,
        description: 'Zmiana: ${outgoing.name} → ${incoming.name}',
      ),
    );
    _refreshRuntimeRatings(live);
    return _accept(live);
  }

  bool applyMajorInjurySubstitution({
    required SimulationLiveMatch live,
    required bool homeSide,
    required String playerOutId,
    String? playerInId,
    bool? atHalfTime,
  }) => applyMajorInjurySubstitutionResult(
    live: live,
    homeSide: homeSide,
    playerOutId: playerOutId,
    playerInId: playerInId,
    atHalfTime: atHalfTime,
  ).accepted;

  SimulationActionResult applyMajorInjurySubstitutionResult({
    required SimulationLiveMatch live,
    required bool homeSide,
    required String playerOutId,
    String? playerInId,
    bool? atHalfTime,
  }) {
    final bench = homeSide ? live.state.homeBench : live.state.awayBench;
    final substitutedOutIds = homeSide
        ? live._homeSubstitutedOutIds
        : live._awaySubstitutedOutIds;
    final eligible = bench.where(
      (player) => player.isAvailable && !substitutedOutIds.contains(player.id),
    );
    Player? selected;
    if (playerInId == null) {
      if (eligible.isNotEmpty) selected = eligible.first;
    } else {
      for (final player in bench) {
        if (player.id == playerInId) {
          selected = player;
          break;
        }
      }
    }
    if (selected == null || !selected.isAvailable) {
      final unreplaced = homeSide
          ? live._homeUnreplacedMajorInjuryIds
          : live._awayUnreplacedMajorInjuryIds;
      unreplaced.add(playerOutId);
      return _reject(live, SimulationActionFailure.noAvailableSubstitute);
    }
    final result = applySubstitutionResult(
      live: live,
      homeSide: homeSide,
      playerOutId: playerOutId,
      playerInId: selected.id,
      atHalfTime: atHalfTime,
      forced: true,
    );
    if (result.accepted) {
      (homeSide
              ? live._homeUnreplacedMajorInjuryIds
              : live._awayUnreplacedMajorInjuryIds)
          .remove(playerOutId);
    }
    return result;
  }

  bool updateTactics({
    required SimulationLiveMatch live,
    required bool homeSide,
    required TacticsSetup tactics,
    bool? atHalfTime,
  }) => updateTacticsResult(
    live: live,
    homeSide: homeSide,
    tactics: tactics,
    atHalfTime: atHalfTime,
  ).accepted;

  SimulationActionResult updateTacticsResult({
    required SimulationLiveMatch live,
    required bool homeSide,
    required TacticsSetup tactics,
    bool? atHalfTime,
  }) {
    if (live.isFinished) {
      return _reject(live, SimulationActionFailure.matchFinished);
    }
    final halftime = atHalfTime ?? live.isHalfTime;
    final current = homeSide ? live.state.homeTactics : live.state.awayTactics;
    final formationChanged = current.formation != tactics.formation;
    if (!halftime && formationChanged) {
      return _reject(
        live,
        SimulationActionFailure.formationChangeOutsideHalfTime,
      );
    }

    final changed = current != tactics;
    if (homeSide) {
      live.legacyMatch.state = live.state.copyWith(homeTactics: tactics);
      if (halftime && formationChanged) {
        _remapFormation(live, homeSide: true, formation: tactics.formation);
      }
      live._homeTacticalPenaltyExpiresAtMinute = halftime || !changed
          ? null
          : live.state.minute + balance.matchday.cohesionPenaltyDurationMinutes;
    } else {
      live.legacyMatch.state = live.state.copyWith(awayTactics: tactics);
      if (halftime && formationChanged) {
        _remapFormation(live, homeSide: false, formation: tactics.formation);
      }
      live._awayTacticalPenaltyExpiresAtMinute = halftime || !changed
          ? null
          : live.state.minute + balance.matchday.cohesionPenaltyDurationMinutes;
    }
    _refreshRuntimeRatings(live);
    return _accept(live);
  }

  SimulationActionResult _accept(SimulationLiveMatch live) {
    const result = SimulationActionResult.accepted();
    live.lastAction = result;
    return result;
  }

  SimulationActionResult _reject(
    SimulationLiveMatch live,
    SimulationActionFailure failure,
  ) {
    final result = SimulationActionResult.rejected(failure);
    live.lastAction = result;
    return result;
  }

  void _remapFormation(
    SimulationLiveMatch live, {
    required bool homeSide,
    required Formation formation,
  }) {
    final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
    final assignments = homeSide
        ? live._homeAssignedPositions
        : live._awayAssignedPositions;
    final slots = FormationLayout.of(formation).slots;
    assignments.clear();
    for (
      var index = 0;
      index < lineup.length && index < slots.length;
      index++
    ) {
      assignments[lineup[index].id] = slots[index].position;
    }
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

    // Task 18 order 5: resolve each selected sequence as a multi-duel chain,
    // then pass successful sequences through the shot/GK funnel. The same
    // MatchRandom remains the owner of every additional draw.
    final chainResolver = SequenceChainResolver(balance: balance);
    final shotResolver = ShotResolver(balance: balance);
    final setPieceResolver = SetPieceResolver(balance: balance);
    for (var index = 0; index < sequenceCount; index++) {
      final attackingHome = live.random.nextDouble() < possessionProbability;
      final sequenceContext = _sequenceContext(
        live,
        attackingHome: attackingHome,
        counterAttackEligible: attackingHome
            ? live._homeCounterAttackEligible
            : live._awayCounterAttackEligible,
      );
      final selection = SequenceSelector(
        balance: balance,
      ).select(context: sequenceContext, random: live.random);
      final chain = chainResolver.resolve(
        selection: selection,
        context: sequenceContext,
        random: live.random,
      );
      if (attackingHome) {
        live._awayCounterAttackEligible = chain.wonDuels > 0;
        live._homeCounterAttackEligible = false;
      } else {
        live._homeCounterAttackEligible = chain.wonDuels > 0;
        live._awayCounterAttackEligible = false;
      }

      ShotResolution? shot;
      SetPieceResolution? setPiece;
      if (selection.type == SequenceType.setPiece) {
        final attackingLineup = attackingHome
            ? state.homeLineup
            : state.awayLineup;
        final defendingLineup = attackingHome
            ? state.awayLineup
            : state.homeLineup;
        final attackingAttributes = attackingHome
            ? live.homeEffectiveAttributes
            : live.awayEffectiveAttributes;
        final defendingAttributes = attackingHome
            ? live.awayEffectiveAttributes
            : live.homeEffectiveAttributes;
        final attackingTactics = attackingHome
            ? state.homeTactics
            : state.awayTactics;
        // Task 20 will replace this explicit bridge with foul/corner events.
        setPiece = setPieceResolver.resolve(
          type: SetPieceType.corner,
          attackingLineup: attackingLineup,
          defendingLineup: defendingLineup,
          attackingAttributes: attackingAttributes,
          defendingAttributes: defendingAttributes,
          attackingTactics: attackingTactics,
          context: state.context,
          random: live.random,
        );
        shot = setPiece.shot;
      } else if (chain.canShoot && chain.shooter != null) {
        final defendingLineup = attackingHome
            ? state.awayLineup
            : state.homeLineup;
        final defendingAttributes = attackingHome
            ? live.awayEffectiveAttributes
            : live.homeEffectiveAttributes;
        shot = shotResolver.resolve(
          sequenceType: selection.type,
          shotKind: chain.shotKind,
          shooter: chain.shooter!,
          defendingLineup: defendingLineup,
          context: state.context,
          random: live.random,
          shooterAttributes: sequenceContext.attackingEffectiveAttributes,
          defendingAttributes: defendingAttributes,
          wonDuels: chain.wonDuels,
          chanceQualityMultiplier: chain.chanceQualityMultiplier,
          minute: nextMinute,
        );
      }

      if (shot != null && shot.isShot) {
        final xg = shot.xg + shot.reboundXg;
        if (attackingHome) {
          live._homeShots++;
          live._homeXg += xg;
          if (shot.isOnTarget) live._homeShotsOnTarget++;
          if (shot.reboundAttempted) live._homeShots++;
          if (shot.reboundGoal) live._homeShotsOnTarget++;
          if (shot.isGoal) {
            state = state.copyWith(homeGoals: state.homeGoals + 1);
          }
          if (shot.cornerAwarded || setPiece?.type == SetPieceType.corner) {
            live._homeCorners++;
          }
        } else {
          live._awayShots++;
          live._awayXg += xg;
          if (shot.isOnTarget) live._awayShotsOnTarget++;
          if (shot.reboundAttempted) live._awayShots++;
          if (shot.reboundGoal) live._awayShotsOnTarget++;
          if (shot.isGoal) {
            state = state.copyWith(awayGoals: state.awayGoals + 1);
          }
          if (shot.cornerAwarded || setPiece?.type == SetPieceType.corner) {
            live._awayCorners++;
          }
        }
      }

      final primaryDuel = chain.primaryDuel ?? setPiece?.penaltyDuel;
      sequenceTraces.add(
        SimulationSequenceTrace(
          type: selection.type,
          attackingHome: attackingHome,
          attackerId: chain.duels.isNotEmpty
              ? chain.duels.first.attackerId
              : selection.attacker.id,
          defenderId: chain.duels.isNotEmpty
              ? chain.duels.first.defenderId
              : selection.defender.id,
          duel: primaryDuel,
          duels: chain.duels,
          chain: chain,
          shot: shot,
          setPiece: setPiece,
        ),
      );
      if (attackingHome) {
        homeSequenceCount++;
      } else {
        awaySequenceCount++;
      }
    }

    live.legacyMatch.state = state;

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
      cohesionMultiplier: live.homeCohesionMultiplier,
      isHome: true,
      headCoach: live.legacyMatch.homeHeadCoach,
      staminaRemaining: live.legacyMatch.staminaRemaining,
      assignedPositions: live.homeAssignedPositions,
    );
    final awayEffective = effectiveCalculator.calculateLineup(
      lineup: awayLineup,
      context: state.context,
      chemistry: live.legacyMatch.awayChemistry,
      atmosphere: live.legacyMatch.awayAtmosphere,
      cohesionMultiplier: live.awayCohesionMultiplier,
      isHome: false,
      headCoach: live.legacyMatch.awayHeadCoach,
      staminaRemaining: live.legacyMatch.staminaRemaining,
      assignedPositions: live.awayAssignedPositions,
    );

    live.legacyMatch.homeTeamShape = homeShape;
    live.legacyMatch.awayTeamShape = awayShape;
    live.legacyMatch.homeEffectiveAttributes = Map.unmodifiable(homeEffective);
    live.legacyMatch.awayEffectiveAttributes = Map.unmodifiable(awayEffective);
    live.legacyMatch.homeUnitRatings = unitCalculator.calculate(
      lineup: homeLineup,
      effectiveAttributes: homeEffective,
      shape: homeShape,
      assignedPositions: live.homeAssignedPositions,
    );
    live.legacyMatch.awayUnitRatings = unitCalculator.calculate(
      lineup: awayLineup,
      effectiveAttributes: awayEffective,
      shape: awayShape,
      assignedPositions: live.awayAssignedPositions,
    );
  }

  SequenceContext _sequenceContext(
    SimulationLiveMatch live, {
    required bool attackingHome,
    required bool counterAttackEligible,
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
      counterAttackEligible: counterAttackEligible,
      attackingAssignedPositions: attackingHome
          ? live.homeAssignedPositions
          : live.awayAssignedPositions,
      defendingAssignedPositions: attackingHome
          ? live.awayAssignedPositions
          : live.homeAssignedPositions,
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

  static const _emptyRatings = UnitRatings(
    defRating: 0,
    midRating: 0,
    atkRating: 0,
  );
}
