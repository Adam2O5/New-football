import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/engine/match_engine.dart' as legacy;
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/services/cohesion_service.dart';
import 'package:new_football/core/simulation/duel_resolver.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/matchday_runtime.dart';
import 'package:new_football/core/simulation/match_incident_resolver.dart';
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
    this.homeFouls = 0,
    this.awayFouls = 0,
    this.homeNoGkPenalty = false,
    this.awayNoGkPenalty = false,
    List<MatchEvent> events = const [],
    List<MatchInjury> injuries = const [],
    List<MatchDiscipline> disciplines = const [],
    List<String> unreplacedInjuryIds = const [],
  }) : minuteTraces = List.unmodifiable(minuteTraces),
       events = List.unmodifiable(events),
       injuries = List.unmodifiable(injuries),
       disciplines = List.unmodifiable(disciplines),
       unreplacedInjuryIds = List.unmodifiable(unreplacedInjuryIds);

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
  final int homeFouls;
  final int awayFouls;
  final bool homeNoGkPenalty;
  final bool awayNoGkPenalty;
  final List<MatchEvent> events;
  final List<MatchInjury> injuries;
  final List<MatchDiscipline> disciplines;
  final List<String> unreplacedInjuryIds;

  double get awayPossessionPercent => 100.0 - homePossessionPercent;
  int get minutesSimulated => minuteTraces.length;
  int get homeGoals => finalState.homeGoals;
  int get awayGoals => finalState.awayGoals;
  int get totalGoals => homeGoals + awayGoals;

  TeamMatchStats get homeStats => _teamStats(
    teamId: context.homeTeamId,
    goals: homeGoals,
    shots: homeShots,
    shotsOnTarget: homeShotsOnTarget,
    xg: homeXg,
    corners: homeCorners,
    fouls: homeFouls,
  );

  TeamMatchStats get awayStats => _teamStats(
    teamId: context.awayTeamId,
    goals: awayGoals,
    shots: awayShots,
    shotsOnTarget: awayShotsOnTarget,
    xg: awayXg,
    corners: awayCorners,
    fouls: awayFouls,
  );

  TeamMatchStats _teamStats({
    required String teamId,
    required int goals,
    required int shots,
    required int shotsOnTarget,
    required double xg,
    required int corners,
    required int fouls,
  }) {
    final yellowCards = disciplines
        .where((item) => item.teamId == teamId)
        .fold<int>(0, (sum, item) => sum + item.yellowCardsInMatch);
    final redCards = disciplines
        .where(
          (item) =>
              item.teamId == teamId && item.redCardKind != RedCardKind.none,
        )
        .length;
    return TeamMatchStats(
      teamId: teamId,
      goals: goals,
      shots: shots,
      shotsOnTarget: shotsOnTarget,
      possession: teamId == context.homeTeamId
          ? homePossessionPercent.round()
          : awayPossessionPercent.round(),
      xg: xg,
      corners: corners,
      fouls: fouls,
      yellowCards: yellowCards,
      redCards: redCards,
    );
  }

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
  final Set<String> _homeUnreplacedInjuryIds = <String>{};
  final Set<String> _awayUnreplacedInjuryIds = <String>{};
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
  int _homeFouls = 0;
  int _awayFouls = 0;
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

  List<MatchEvent> get events => List.unmodifiable(legacyMatch.events);
  List<MatchInjury> get injuries => List.unmodifiable(legacyMatch.injuries);
  List<MatchDiscipline> get disciplines =>
      List.unmodifiable(legacyMatch.disciplines);
  int get homeFouls => _homeFouls;
  int get awayFouls => _awayFouls;
  bool get homeNoGkPenalty =>
      !state.homeLineup.any((player) => player.position == Position.gk);
  bool get awayNoGkPenalty =>
      !state.awayLineup.any((player) => player.position == Position.gk);

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
  Set<String> get homeUnreplacedInjuryIds =>
      Set.unmodifiable(_homeUnreplacedInjuryIds);
  Set<String> get awayUnreplacedInjuryIds =>
      Set.unmodifiable(_awayUnreplacedInjuryIds);
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

  bool applyInjurySubstitution({
    required bool homeSide,
    required String playerOutId,
    String? playerInId,
    bool? atHalfTime,
    InjuryType? injuryType,
  }) => SimulationMatchEngine(balance: balance).applyInjurySubstitution(
    live: this,
    homeSide: homeSide,
    playerOutId: playerOutId,
    playerInId: playerInId,
    atHalfTime: atHalfTime,
    injuryType: injuryType,
  );

  bool applyMajorInjurySubstitution({
    required bool homeSide,
    required String playerOutId,
    String? playerInId,
    bool? atHalfTime,
  }) => SimulationMatchEngine(balance: balance).applyInjurySubstitution(
    live: this,
    homeSide: homeSide,
    playerOutId: playerOutId,
    playerInId: playerInId,
    atHalfTime: atHalfTime,
    injuryType: InjuryType.major,
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
    homeFouls: _homeFouls,
    awayFouls: _awayFouls,
    homeNoGkPenalty: homeNoGkPenalty,
    awayNoGkPenalty: awayNoGkPenalty,
    events: legacyMatch.events,
    injuries: legacyMatch.injuries,
    disciplines: legacyMatch.disciplines,
    unreplacedInjuryIds: [
      ..._homeUnreplacedInjuryIds,
      ..._awayUnreplacedInjuryIds,
    ],
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
    live.legacyMatch.syncNoGkPenalty();
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

  bool applyInjurySubstitution({
    required SimulationLiveMatch live,
    required bool homeSide,
    required String playerOutId,
    String? playerInId,
    bool? atHalfTime,
    InjuryType? injuryType,
  }) => applyInjurySubstitutionResult(
    live: live,
    homeSide: homeSide,
    playerOutId: playerOutId,
    playerInId: playerInId,
    atHalfTime: atHalfTime,
    injuryType: injuryType,
  ).accepted;

  bool applyMajorInjurySubstitution({
    required SimulationLiveMatch live,
    required bool homeSide,
    required String playerOutId,
    String? playerInId,
    bool? atHalfTime,
  }) => applyInjurySubstitution(
    live: live,
    homeSide: homeSide,
    playerOutId: playerOutId,
    playerInId: playerInId,
    atHalfTime: atHalfTime,
    injuryType: InjuryType.major,
  );

  SimulationActionResult applyMajorInjurySubstitutionResult({
    required SimulationLiveMatch live,
    required bool homeSide,
    required String playerOutId,
    String? playerInId,
    bool? atHalfTime,
  }) => applyInjurySubstitutionResult(
    live: live,
    homeSide: homeSide,
    playerOutId: playerOutId,
    playerInId: playerInId,
    atHalfTime: atHalfTime,
    injuryType: InjuryType.major,
  );

  SimulationActionResult applyInjurySubstitutionResult({
    required SimulationLiveMatch live,
    required bool homeSide,
    required String playerOutId,
    String? playerInId,
    bool? atHalfTime,
    InjuryType? injuryType,
  }) {
    final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
    if (!lineup.any((player) => player.id == playerOutId)) {
      return _reject(live, SimulationActionFailure.playerNotOnPitch);
    }
    final outgoing = lineup.firstWhere((player) => player.id == playerOutId);
    final resolvedType = injuryType ?? outgoing.state.injury?.type;
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
        if (player.id == playerInId &&
            player.isAvailable &&
            !substitutedOutIds.contains(player.id)) {
          selected = player;
          break;
        }
      }
    }

    if (selected != null) {
      final result = applySubstitutionResult(
        live: live,
        homeSide: homeSide,
        playerOutId: playerOutId,
        playerInId: selected.id,
        atHalfTime: atHalfTime,
        forced: true,
      );
      if (result.accepted) {
        _clearUnreplacedInjury(live, homeSide: homeSide, playerId: playerOutId);
        return result;
      }
    }

    _removeUnreplacedInjury(live, homeSide: homeSide, playerId: playerOutId);
    _markUnreplacedInjury(
      live,
      homeSide: homeSide,
      playerId: playerOutId,
      injuryType: resolvedType,
    );
    return _reject(live, SimulationActionFailure.noAvailableSubstitute);
  }

  void _markUnreplacedInjury(
    SimulationLiveMatch live, {
    required bool homeSide,
    required String playerId,
    InjuryType? injuryType,
  }) {
    (homeSide ? live._homeUnreplacedInjuryIds : live._awayUnreplacedInjuryIds)
        .add(playerId);
    if (injuryType == InjuryType.major) {
      (homeSide
              ? live._homeUnreplacedMajorInjuryIds
              : live._awayUnreplacedMajorInjuryIds)
          .add(playerId);
    }
  }

  void _clearUnreplacedInjury(
    SimulationLiveMatch live, {
    required bool homeSide,
    required String playerId,
  }) {
    (homeSide ? live._homeUnreplacedInjuryIds : live._awayUnreplacedInjuryIds)
        .remove(playerId);
    (homeSide
            ? live._homeUnreplacedMajorInjuryIds
            : live._awayUnreplacedMajorInjuryIds)
        .remove(playerId);
  }

  void _removeUnreplacedInjury(
    SimulationLiveMatch live, {
    required bool homeSide,
    required String playerId,
  }) {
    final lineup = List<Player>.from(
      homeSide ? live.state.homeLineup : live.state.awayLineup,
    )..removeWhere((player) => player.id == playerId);
    final assignments = homeSide
        ? live._homeAssignedPositions
        : live._awayAssignedPositions;
    assignments.remove(playerId);
    live.legacyMatch.state = homeSide
        ? live.state.copyWith(homeLineup: lineup)
        : live.state.copyWith(awayLineup: lineup);
    live.legacyMatch.syncNoGkPenalty();
    _reconfigureAfterLineupChange(live, homeSide: homeSide);
    _refreshRuntimeRatings(live);
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

  void _reconfigureAfterLineupChange(
    SimulationLiveMatch live, {
    required bool homeSide,
  }) {
    final formation = homeSide
        ? live.state.homeTactics.formation
        : live.state.awayTactics.formation;
    _remapFormation(live, homeSide: homeSide, formation: formation);
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
        applyShortHanded: true,
      ),
      awayLineup: live.legacyMatch.recordMinute(
        lineup: previousAwayLineup,
        homeSide: false,
        applyShortHanded: true,
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
    final homeDuelParticipants = <String>{};
    final awayDuelParticipants = <String>{};
    var homeSequenceCount = 0;
    var awaySequenceCount = 0;

    // Task 20 keeps the same MatchRandom stream and resolves secondary
    // incidents directly from the duels produced by this minute.
    final incidentResolver = MatchIncidentResolver(balance: balance);
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

      state = _resolveSequenceIncidents(
        live: live,
        state: state,
        attackingHome: attackingHome,
        sequenceContext: sequenceContext,
        chain: chain,
        resolver: incidentResolver,
        minute: nextMinute,
        homeDuelParticipants: homeDuelParticipants,
        awayDuelParticipants: awayDuelParticipants,
      );
      live.legacyMatch.state = state;

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

    state = _resolveMinuteInjuries(
      live: live,
      state: state,
      resolver: incidentResolver,
      minute: nextMinute,
      homeDuelParticipants: homeDuelParticipants,
      awayDuelParticipants: awayDuelParticipants,
    );
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

  MatchState _resolveSequenceIncidents({
    required SimulationLiveMatch live,
    required MatchState state,
    required bool attackingHome,
    required SequenceContext sequenceContext,
    required SequenceResolution chain,
    required MatchIncidentResolver resolver,
    required int minute,
    required Set<String> homeDuelParticipants,
    required Set<String> awayDuelParticipants,
  }) {
    var next = state;
    for (final duel in chain.duels) {
      final attacker = sequenceContext.attackingLineup.firstWhere(
        (player) => player.id == duel.attackerId,
      );
      final defender = sequenceContext.defendingLineup.firstWhere(
        (player) => player.id == duel.defenderId,
      );
      if (attackingHome) {
        homeDuelParticipants.add(attacker.id);
        awayDuelParticipants.add(defender.id);
      } else {
        awayDuelParticipants.add(attacker.id);
        homeDuelParticipants.add(defender.id);
      }
      if (duel.attackerWon) continue;

      final foul = resolver.rollFoul(
        attackerPace: _pace(
          attacker,
          sequenceContext.attackingEffectiveAttributes[attacker.id],
        ),
        defenderPhysicality: _physicality(
          defender,
          sequenceContext.defendingEffectiveAttributes[defender.id],
        ),
        defender: defender,
        defendingTactics: sequenceContext.defendingTactics,
        context: next.context,
        nextDouble: live.random.nextDouble,
      );
      if (!foul.occurred) continue;

      final defendingHome = !attackingHome;
      if (defendingHome) {
        live._homeFouls++;
      } else {
        live._awayFouls++;
      }
      final defendingTeamId = defendingHome ? live.homeTeamId : live.awayTeamId;
      live.legacyMatch.events.add(
        MatchEvent(
          type: MatchEventType.foul,
          minute: minute,
          teamId: defendingTeamId,
          playerId: defender.id,
          description: 'Faul ${defender.name} na ${attacker.name}',
        ),
      );

      final existingYellow = next.yellowCardCounts[defender.id] ?? 0;
      final card = resolver.rollCard(
        defender: defender,
        context: next.context,
        oneOnOne: chain.shotKind == SequenceShotKind.oneOnOne,
        existingYellowCards: existingYellow,
        nextDouble: live.random.nextDouble,
      );
      final playerInStartingXi =
          (defendingHome
                  ? live.legacyMatch.homeStartingLineup
                  : live.legacyMatch.awayStartingLineup)
              .any((player) => player.id == defender.id);

      if (card.yellow) {
        final yellowCards = Map<String, int>.from(next.yellowCardCounts)
          ..[defender.id] = existingYellow + 1;
        next = next.copyWith(yellowCardCounts: yellowCards);
        _recordDiscipline(
          live,
          teamId: defendingTeamId,
          playerId: defender.id,
          playerInStartingXi: playerInStartingXi,
          yellowCardsInMatch: 1,
          redCardKind: card.secondYellow
              ? RedCardKind.secondYellow
              : RedCardKind.none,
        );
        live.legacyMatch.events.add(
          MatchEvent(
            type: MatchEventType.yellowCard,
            minute: minute,
            teamId: defendingTeamId,
            playerId: defender.id,
            description: 'Żółta kartka — ${defender.name}',
          ),
        );
        if (card.secondYellow) {
          live.legacyMatch.events.add(
            MatchEvent(
              type: MatchEventType.redCard,
              minute: minute,
              teamId: defendingTeamId,
              playerId: defender.id,
              description: 'Czerwona kartka — ${defender.name} (2× żółta)',
            ),
          );
          next = _sendOffRuntime(
            live,
            next,
            defender.id,
            defendingHome,
            secondYellow: true,
          );
        }
      } else if (card.directRed) {
        _recordDiscipline(
          live,
          teamId: defendingTeamId,
          playerId: defender.id,
          playerInStartingXi: playerInStartingXi,
          redCardKind: RedCardKind.direct,
          directRedSeverity: card.directRedSeverity,
        );
        live.legacyMatch.events.add(
          MatchEvent(
            type: MatchEventType.redCard,
            minute: minute,
            teamId: defendingTeamId,
            playerId: defender.id,
            description:
                'Czerwona kartka — ${defender.name} (bezpośrednia, poziom ${card.directRedSeverity})',
          ),
        );
        next = _sendOffRuntime(live, next, defender.id, defendingHome);
      }
    }
    return next;
  }

  MatchState _sendOffRuntime(
    SimulationLiveMatch live,
    MatchState state,
    String playerId,
    bool homeSide, {
    bool secondYellow = false,
  }) {
    final lineup = List<Player>.from(
      homeSide ? state.homeLineup : state.awayLineup,
    )..removeWhere((player) => player.id == playerId);
    final sentOff = [...state.sentOffPlayerIds];
    if (!sentOff.contains(playerId)) sentOff.add(playerId);
    final next = homeSide
        ? state.copyWith(
            homeLineup: lineup,
            sentOffPlayerIds: sentOff,
            yellowCardCounts: secondYellow
                ? {...state.yellowCardCounts, playerId: 2}
                : state.yellowCardCounts,
            momentum: (state.momentum - 0.2).clamp(-1.0, 1.0),
          )
        : state.copyWith(
            awayLineup: lineup,
            sentOffPlayerIds: sentOff,
            yellowCardCounts: secondYellow
                ? {...state.yellowCardCounts, playerId: 2}
                : state.yellowCardCounts,
            momentum: (state.momentum + 0.2).clamp(-1.0, 1.0),
          );
    live.legacyMatch.state = next;
    live.legacyMatch.syncNoGkPenalty();
    _reconfigureAfterLineupChange(live, homeSide: homeSide);
    _refreshRuntimeRatings(live);
    return next;
  }

  MatchState _resolveMinuteInjuries({
    required SimulationLiveMatch live,
    required MatchState state,
    required MatchIncidentResolver resolver,
    required int minute,
    required Set<String> homeDuelParticipants,
    required Set<String> awayDuelParticipants,
  }) {
    var next = _rollInjuriesForSide(
      live: live,
      state: state,
      homeSide: true,
      resolver: resolver,
      minute: minute,
      duelParticipants: homeDuelParticipants,
    );
    next = _rollInjuriesForSide(
      live: live,
      state: next,
      homeSide: false,
      resolver: resolver,
      minute: minute,
      duelParticipants: awayDuelParticipants,
    );
    return next;
  }

  MatchState _rollInjuriesForSide({
    required SimulationLiveMatch live,
    required MatchState state,
    required bool homeSide,
    required MatchIncidentResolver resolver,
    required int minute,
    required Set<String> duelParticipants,
  }) {
    var next = state;
    final lineupAtMinuteEnd = List<Player>.from(
      homeSide ? next.homeLineup : next.awayLineup,
    );
    final staff = homeSide
        ? live.legacyMatch.homeSnapshot?.staff
        : live.legacyMatch.awaySnapshot?.staff;
    for (final player in lineupAtMinuteEnd) {
      final currentLineup = homeSide ? next.homeLineup : next.awayLineup;
      if (!currentLineup.any((candidate) => candidate.id == player.id)) {
        continue;
      }
      final decision = resolver.rollInjury(
        player: player,
        stamina:
            live.legacyMatch.staminaRemaining[player.id] ??
            player.state.stamina.toDouble(),
        tactics: homeSide ? next.homeTactics : next.awayTactics,
        context: next.context,
        duelInvolved: duelParticipants.contains(player.id),
        physio: staff?.physio,
        doctor: staff?.doctor,
        doctorCareMultiplier: homeSide
            ? live.legacyMatch.homeDoctorCareMult
            : live.legacyMatch.awayDoctorCareMult,
        nextDouble: live.random.nextDouble,
        nextInt: live.random.nextInt,
      );
      if (!decision.occurred || decision.diagnosis == null) continue;

      final diagnosis = decision.diagnosis!;
      final injured = player.copyWith(
        state: player.state.copyWith(injury: diagnosis.injury),
      );
      final updatedLineup = [
        for (final candidate in currentLineup)
          candidate.id == player.id ? injured : candidate,
      ];
      next = homeSide
          ? next.copyWith(homeLineup: updatedLineup)
          : next.copyWith(awayLineup: updatedLineup);
      live.legacyMatch.state = next;

      final teamId = homeSide ? live.homeTeamId : live.awayTeamId;
      final startingXi = homeSide
          ? live.legacyMatch.homeStartingLineup
          : live.legacyMatch.awayStartingLineup;
      live.legacyMatch.injuries.add(
        MatchInjury(
          teamId: teamId,
          playerId: player.id,
          injury: diagnosis.injury,
          playerInStartingXi: startingXi.any(
            (candidate) => candidate.id == player.id,
          ),
          potentialLoss: diagnosis.potentialLoss,
        ),
      );
      final injuries = [...next.injuriesThisMatch];
      if (!injuries.contains(player.id)) injuries.add(player.id);
      next = next.copyWith(injuriesThisMatch: injuries);
      live.legacyMatch.events.add(
        MatchEvent(
          type: diagnosis.injury.type == InjuryType.major
              ? MatchEventType.majorInjury
              : MatchEventType.minorInjury,
          minute: minute,
          teamId: teamId,
          playerId: player.id,
          description: '${diagnosis.definition.name} — ${player.name}',
        ),
      );

      live.legacyMatch.state = next;
      final substitution = applyInjurySubstitutionResult(
        live: live,
        homeSide: homeSide,
        playerOutId: player.id,
        atHalfTime: false,
        injuryType: diagnosis.injury.type,
      );
      next = live.state;
      if (substitution.rejected &&
          substitution.failure !=
              SimulationActionFailure.noAvailableSubstitute) {
        // Any rejected forced path still leaves the diagnosed player out; the
        // guard is defensive for manually assembled runtime states.
        _removeUnreplacedInjury(live, homeSide: homeSide, playerId: player.id);
        next = live.state;
      }
    }
    return next;
  }

  double _pace(Player player, EffectivePlayerAttributes? effective) =>
      effective?.pace ??
      player.attributes.map(
        outfield: (attributes) => attributes.stats.pace.toDouble(),
        goalkeeper: (attributes) => attributes.stats.overall.toDouble(),
      );

  double _physicality(Player player, EffectivePlayerAttributes? effective) =>
      effective?.physicality ??
      player.attributes.map(
        outfield: (attributes) => attributes.stats.physicality.toDouble(),
        goalkeeper: (attributes) => attributes.stats.overall.toDouble(),
      );

  void _recordDiscipline(
    SimulationLiveMatch live, {
    required String teamId,
    required String playerId,
    required bool playerInStartingXi,
    int yellowCardsInMatch = 0,
    RedCardKind redCardKind = RedCardKind.none,
    int directRedSeverity = 0,
  }) {
    final item = MatchDiscipline(
      teamId: teamId,
      playerId: playerId,
      yellowCardsInMatch: yellowCardsInMatch,
      redCardKind: redCardKind,
      directRedSeverity: directRedSeverity,
      playerInStartingXi: playerInStartingXi,
    );
    final index = live.legacyMatch.disciplines.indexWhere(
      (discipline) =>
          discipline.teamId == teamId && discipline.playerId == playerId,
    );
    if (index < 0) {
      live.legacyMatch.disciplines.add(item);
      return;
    }
    final previous = live.legacyMatch.disciplines[index];
    final redKind =
        item.redCardKind == RedCardKind.direct ||
            previous.redCardKind == RedCardKind.direct
        ? RedCardKind.direct
        : item.redCardKind == RedCardKind.secondYellow ||
              previous.redCardKind == RedCardKind.secondYellow
        ? RedCardKind.secondYellow
        : RedCardKind.none;
    live.legacyMatch.disciplines[index] = previous.copyWith(
      yellowCardsInMatch: previous.yellowCardsInMatch + item.yellowCardsInMatch,
      redCardKind: redKind,
      directRedSeverity: item.directRedSeverity > 0
          ? item.directRedSeverity
          : previous.directRedSeverity,
      playerInStartingXi:
          previous.playerInStartingXi || item.playerInStartingXi,
    );
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
      applyShortHanded: true,
    );
    live.legacyMatch.awayUnitRatings = unitCalculator.calculate(
      lineup: awayLineup,
      effectiveAttributes: awayEffective,
      shape: awayShape,
      assignedPositions: live.awayAssignedPositions,
      applyShortHanded: true,
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
