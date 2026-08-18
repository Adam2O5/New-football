import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/cohesion_service.dart';
import 'package:new_football/core/services/discipline_service.dart';
import 'package:new_football/core/services/injury_service.dart';
import 'package:new_football/core/services/team_management_service.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/pre_match_validator.dart';
import 'package:new_football/core/simulation/team_shape.dart';
import 'package:new_football/core/simulation/unit_ratings.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

class LiveMatch {
  LiveMatch({
    required this.state,
    required this.homeTeamId,
    required this.awayTeamId,
    List<Player>? startingHomeLineup,
    List<Player>? startingAwayLineup,
    this.balance = BalanceConfig.defaults,
    List<MatchEvent>? events,
    List<MatchInjury>? injuries,
    List<MatchDiscipline>? disciplines,
    this.homeSubsUsed = 0,
    this.awaySubsUsed = 0,
    this.homeSubWindows = 0,
    this.awaySubWindows = 0,
    this.homeCohesionMult = 1.03,
    this.awayCohesionMult = 1.03,
    this.homeChemistry = 50.0,
    this.awayChemistry = 50.0,
    this.homeAtmosphere = 50,
    this.awayAtmosphere = 50,
    this.homeDoctorCareMult = 1.0,
    this.awayDoctorCareMult = 1.0,
    this.homeDoctorPreventionMult = 1.0,
    this.awayDoctorPreventionMult = 1.0,
    this.administrativeResult,
    this.homeSnapshot,
    this.awaySnapshot,
    this.homeNoGkPenalty = false,
    this.awayNoGkPenalty = false,
    this.homeHeadCoach,
    this.awayHeadCoach,
    this.homeTeamShape,
    this.awayTeamShape,
    this.homeUnitRatings,
    this.awayUnitRatings,
    Map<String, EffectivePlayerAttributes>? homeEffectiveAttributes,
    Map<String, EffectivePlayerAttributes>? awayEffectiveAttributes,
  }) : homeEffectiveAttributes = homeEffectiveAttributes ?? const {},
       awayEffectiveAttributes = awayEffectiveAttributes ?? const {},
       homeStartingLineup = List.unmodifiable(
         startingHomeLineup ?? state.homeLineup,
       ),
       awayStartingLineup = List.unmodifiable(
         startingAwayLineup ?? state.awayLineup,
       ),
       events = events ?? [],
       injuries = injuries ?? [],
       disciplines = disciplines ?? [],
       playersById = _playersFromState(state),
       teamByPlayerId = _teamsFromState(state, homeTeamId, awayTeamId),
       minutesPlayed = {
         for (final player in _playersFromState(state).values) player.id: 0,
       },
       staminaRemaining = {
         for (final player in _playersFromState(state).values)
           player.id: player.state.stamina.toDouble(),
       };

  MatchState state;
  final String homeTeamId;
  final String awayTeamId;
  final List<Player> homeStartingLineup;
  final List<Player> awayStartingLineup;
  final BalanceConfig balance;
  final List<MatchEvent> events;
  final List<MatchInjury> injuries;
  final List<MatchDiscipline> disciplines;
  final Map<String, Player> playersById;
  final Map<String, String> teamByPlayerId;
  final Map<String, int> minutesPlayed;
  final Map<String, double> staminaRemaining;
  int homeSubsUsed;
  int awaySubsUsed;
  int homeSubWindows;
  int awaySubWindows;

  /// Lineup cohesion multiplier (1.01–1.05 × HC Motivation), frozen at start.
  final double homeCohesionMult;
  final double awayCohesionMult;

  /// Team zgranie (0–100) from Team.chemistry, frozen at start.
  final double homeChemistry;
  final double awayChemistry;
  final int homeAtmosphere;
  final int awayAtmosphere;
  final double homeDoctorCareMult;
  final double awayDoctorCareMult;
  final double homeDoctorPreventionMult;
  final double awayDoctorPreventionMult;
  final MatchResult? administrativeResult;
  final MatchTeamSnapshot? homeSnapshot;
  final MatchTeamSnapshot? awaySnapshot;
  bool homeNoGkPenalty;
  bool awayNoGkPenalty;
  final StaffMember? homeHeadCoach;
  final StaffMember? awayHeadCoach;

  /// Latest runtime Task 16 diagnostics. These values are derived and are not
  /// serialized into MatchState or MatchResult.
  TeamShape? homeTeamShape;
  TeamShape? awayTeamShape;
  UnitRatings? homeUnitRatings;
  UnitRatings? awayUnitRatings;
  Map<String, EffectivePlayerAttributes> homeEffectiveAttributes;
  Map<String, EffectivePlayerAttributes> awayEffectiveAttributes;

  /// Runtime guards for the one-off leader momentum intervention.
  bool homeLeaderDriftApplied = false;
  bool awayLeaderDriftApplied = false;

  bool get isFinished => state.minute >= 90;

  /// Keeps the goalkeeper penalty aligned with the current live XI. The
  /// legacy engine calls this only when its runtime changes the lineup; the
  /// simulation runtime invokes it after every dismissal/injury substitution.
  void syncNoGkPenalty() {
    homeNoGkPenalty = !state.homeLineup.any(
      (player) => player.position == Position.gk,
    );
    awayNoGkPenalty = !state.awayLineup.any(
      (player) => player.position == Position.gk,
    );
  }

  /// Advances the currently selected player by one real match minute.
  /// Fractional consumption is kept in [staminaRemaining]. Match calculations
  /// read that map directly, avoiding a full immutable-player copy every tick.
  List<Player> recordMinute({
    required List<Player> lineup,
    required bool homeSide,
    bool applyShortHanded = false,
    double additionalStaminaMultiplier = 1.0,
  }) {
    final tactics = homeSide ? state.homeTactics : state.awayTactics;
    for (final player in lineup) {
      minutesPlayed[player.id] = (minutesPlayed[player.id] ?? 0) + 1;
      final current = staminaRemaining[player.id] ?? player.state.stamina;
      final loss = balance.player.staminaLossForMinutes(
        player.position,
        1,
        tempo: tactics.tempo,
        pressing: tactics.pressing,
        weather: state.context.weather,
        isDerby: state.context.isDerby,
        additionalMultiplier: additionalStaminaMultiplier,
      );
      final shortHandedMultiplier = applyShortHanded
          ? balance.matchday.shortHandedStaminaMultiplier(lineup.length)
          : 1.0;
      staminaRemaining[player.id] = (current - loss * shortHandedMultiplier)
          .clamp(
            balance.player.staminaMin.toDouble(),
            balance.player.staminaMax.toDouble(),
          );
    }
    return lineup;
  }

  int visibleStamina(Player player) => balance.player.clampStamina(
    (staminaRemaining[player.id] ?? player.state.stamina.toDouble()).round(),
  );

  MatchResult toResult() {
    final administrative = administrativeResult;
    if (administrative != null) return administrative;

    final homeShots = events
        .where(
          (e) =>
              e.teamId == homeTeamId &&
              (e.type == MatchEventType.goal ||
                  e.type == MatchEventType.scoredPenalty),
        )
        .length;
    final awayShots = events
        .where(
          (e) =>
              e.teamId == awayTeamId &&
              (e.type == MatchEventType.goal ||
                  e.type == MatchEventType.scoredPenalty),
        )
        .length;
    final homeSnapshotValue =
        homeSnapshot ??
        _fallbackSnapshot(
          teamId: homeTeamId,
          startingXi: homeStartingLineup,
          bench: state.homeBench,
          tactics: state.homeTactics,
          chemistry: homeChemistry,
          atmosphere: homeAtmosphere,
          cohesionMultiplier: homeCohesionMult,
        );
    final awaySnapshotValue =
        awaySnapshot ??
        _fallbackSnapshot(
          teamId: awayTeamId,
          startingXi: awayStartingLineup,
          bench: state.awayBench,
          tactics: state.awayTactics,
          chemistry: awayChemistry,
          atmosphere: awayAtmosphere,
          cohesionMultiplier: awayCohesionMult,
        );
    final noGkTeams = [
      if (homeNoGkPenalty) homeTeamId,
      if (awayNoGkPenalty) awayTeamId,
    ];
    return MatchResult(
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homeGoals: state.homeGoals,
      awayGoals: state.awayGoals,
      homeStats: TeamMatchStats(
        teamId: homeTeamId,
        goals: state.homeGoals,
        shots: homeShots + state.homeGoals + 4,
        shotsOnTarget: state.homeGoals + 2,
        possession: 50,
        xg: state.homeGoals * 0.9 + 0.4,
        fouls: _foulCount(homeTeamId),
        yellowCards: _cardCount(homeTeamId, yellow: true),
        redCards: _cardCount(homeTeamId, yellow: false),
      ),
      awayStats: TeamMatchStats(
        teamId: awayTeamId,
        goals: state.awayGoals,
        shots: awayShots + state.awayGoals + 4,
        shotsOnTarget: state.awayGoals + 2,
        possession: 50,
        xg: state.awayGoals * 0.9 + 0.4,
        fouls: _foulCount(awayTeamId),
        yellowCards: _cardCount(awayTeamId, yellow: true),
        redCards: _cardCount(awayTeamId, yellow: false),
      ),
      status: MatchStatus.played,
      noGkPenalty: noGkTeams.isNotEmpty,
      noGkPenaltyTeamIds: noGkTeams,
      context: state.context,
      homeTactics: state.homeTactics,
      awayTactics: state.awayTactics,
      homeLineup: homeStartingLineup,
      awayLineup: awayStartingLineup,
      homeLineupPositions: homeSnapshotValue.assignedPositions,
      awayLineupPositions: awaySnapshotValue.assignedPositions,
      homeSnapshot: homeSnapshotValue,
      awaySnapshot: awaySnapshotValue,
      playerStats: _playerStats(),
      events: List.unmodifiable(events),
      injuries: List.unmodifiable(injuries),
      disciplines: List.unmodifiable(disciplines),
    );
  }

  MatchTeamSnapshot _fallbackSnapshot({
    required String teamId,
    required List<Player> startingXi,
    required List<Player> bench,
    required TacticsSetup tactics,
    required double chemistry,
    required int atmosphere,
    required double cohesionMultiplier,
  }) => MatchTeamSnapshot(
    teamId: teamId,
    startingXi: startingXi,
    bench: bench,
    assignedPositions: [for (final player in startingXi) player.position],
    assignedRoles: [for (final player in startingXi) player.state.role],
    tactics: tactics,
    chemistry: chemistry,
    atmosphere: atmosphere,
    cohesionMultiplier: cohesionMultiplier,
  );

  List<PlayerMatchStats> _playerStats() {
    return playersById.values.map((player) {
      final minutes = minutesPlayed[player.id] ?? 0;
      final goals = events
          .where(
            (event) =>
                event.playerId == player.id &&
                (event.type == MatchEventType.goal ||
                    event.type == MatchEventType.scoredPenalty),
          )
          .length;
      final teamId = _teamForPlayer(player.id);
      final outcome = teamId == homeTeamId
          ? state.homeGoals.compareTo(state.awayGoals)
          : state.awayGoals.compareTo(state.homeGoals);
      final visibleStamina = balance.player.clampStamina(
        (staminaRemaining[player.id] ?? player.state.stamina.toDouble())
            .round(),
      );
      final current = player.copyWith(
        state: player.state.copyWith(stamina: visibleStamina),
      );
      var rating = 6.0;
      if (minutes > 0) {
        rating += (current.overall(balance) - 75) * 0.04;
        rating += (current.formMult(balance) - 1.0) * 4;
        rating += (balance.player.performanceMult(visibleStamina) - 1.0) * 2;
        rating += outcome * 0.35;
        rating += goals * 0.75;
      }
      return PlayerMatchStats(
        playerId: player.id,
        minutes: minutes,
        goals: goals,
        yellowCards: _playerCardCount(player.id, MatchEventType.yellowCard),
        redCards: _playerCardCount(player.id, MatchEventType.redCard),
        rating: rating.clamp(0.0, 10.0).toDouble(),
      );
    }).toList();
  }

  String _teamForPlayer(String playerId) =>
      teamByPlayerId[playerId] ?? awayTeamId;

  int _playerCardCount(String playerId, MatchEventType type) => events
      .where((event) => event.playerId == playerId && event.type == type)
      .length;

  int _foulCount(String teamId) => events
      .where(
        (event) => event.teamId == teamId && event.type == MatchEventType.foul,
      )
      .length;

  int _cardCount(String teamId, {required bool yellow}) {
    return events
        .where(
          (e) =>
              e.teamId == teamId &&
              e.type ==
                  (yellow ? MatchEventType.yellowCard : MatchEventType.redCard),
        )
        .length;
  }

  static Map<String, String> _teamsFromState(
    MatchState state,
    String homeTeamId,
    String awayTeamId,
  ) {
    final teams = <String, String>{};
    for (final player in [...state.homeLineup, ...state.homeBench]) {
      teams[player.id] = homeTeamId;
    }
    for (final player in [...state.awayLineup, ...state.awayBench]) {
      teams[player.id] = awayTeamId;
    }
    return teams;
  }

  static Map<String, Player> _playersFromState(MatchState state) {
    final players = <String, Player>{};
    for (final player in [
      ...state.homeLineup,
      ...state.awayLineup,
      ...state.homeBench,
      ...state.awayBench,
    ]) {
      players[player.id] = player;
    }
    return players;
  }
}

/// Minute-by-minute match engine (`docs/matchday_model.md`).
class MatchEngine {
  const MatchEngine({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  LiveMatch start({
    required Team home,
    required Team away,
    MatchContext context = const MatchContext(),
    required int rngSeed,
    bool refreshDerivedRatings = true,
    Map<String, Position> homeAssignedPositions = const {},
    Map<String, Position> awayAssignedPositions = const {},
  }) {
    final report = PreMatchValidator(
      balance: balance,
    ).validate(home: home, away: away);
    final matchContext = context.copyWith(
      homeTeamId: context.homeTeamId.isEmpty ? home.id : context.homeTeamId,
      awayTeamId: context.awayTeamId.isEmpty ? away.id : context.awayTeamId,
      seed: context.seed == 0 ? rngSeed : context.seed,
    );

    final cohesionService = const CohesionService();
    final homeCohesionMult = cohesionService.cohesionMult(
      cohesionService.computeCohesion(report.home.startingXi),
      headCoach: home.staff.headCoach,
    );
    final awayCohesionMult = cohesionService.cohesionMult(
      cohesionService.computeCohesion(report.away.startingXi),
      headCoach: away.staff.headCoach,
    );
    final homeSnapshot = _snapshotFor(
      home,
      report.home,
      cohesionMultiplier: homeCohesionMult,
      assignedPositions: homeAssignedPositions,
    );
    final awaySnapshot = _snapshotFor(
      away,
      report.away,
      cohesionMultiplier: awayCohesionMult,
      assignedPositions: awayAssignedPositions,
    );

    if (report.status != MatchStatus.played) {
      final homeGoals = report.status == MatchStatus.dsq
          ? 0
          : report.violatingTeamIds.contains(home.id)
          ? balance.matchday.walkoverGoalsFor
          : balance.matchday.walkoverGoalsAgainst;
      final awayGoals = report.status == MatchStatus.dsq
          ? 0
          : report.violatingTeamIds.contains(away.id)
          ? balance.matchday.walkoverGoalsFor
          : balance.matchday.walkoverGoalsAgainst;
      final administrativeResult = MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        homeStats: TeamMatchStats(teamId: home.id, goals: homeGoals),
        awayStats: TeamMatchStats(teamId: away.id, goals: awayGoals),
        status: report.status,
        reasonCode: report.reasonCode,
        violatingTeamIds: report.violatingTeamIds,
        isWalkover: true,
        context: matchContext,
        homeTactics: home.tactics,
        awayTactics: away.tactics,
        homeLineup: report.home.startingXi,
        awayLineup: report.away.startingXi,
        homeLineupPositions: homeSnapshot.assignedPositions,
        awayLineupPositions: awaySnapshot.assignedPositions,
        homeSnapshot: homeSnapshot,
        awaySnapshot: awaySnapshot,
      );
      return LiveMatch(
        state: MatchState(
          minute: 90,
          homeGoals: homeGoals,
          awayGoals: awayGoals,
          homeLineup: report.home.startingXi,
          awayLineup: report.away.startingXi,
          homeBench: report.home.bench,
          awayBench: report.away.bench,
          homeTactics: home.tactics,
          awayTactics: away.tactics,
          context: matchContext,
          rngSeed: rngSeed,
        ),
        homeTeamId: home.id,
        awayTeamId: away.id,
        startingHomeLineup: report.home.startingXi,
        startingAwayLineup: report.away.startingXi,
        balance: balance,
        events: const [],
        administrativeResult: administrativeResult,
        homeSnapshot: homeSnapshot,
        awaySnapshot: awaySnapshot,
      );
    }

    final homeNoGk = report.noGkPenaltyTeamIds.contains(home.id);
    final awayNoGk = report.noGkPenaltyTeamIds.contains(away.id);
    final live = LiveMatch(
      state: MatchState(
        minute: 0,
        homeLineup: List.of(report.home.startingXi),
        awayLineup: List.of(report.away.startingXi),
        homeBench: report.home.bench,
        awayBench: report.away.bench,
        homeTactics: home.tactics,
        awayTactics: away.tactics,
        context: matchContext,
        momentum: matchContext.crowdIntensity / 8,
        rngSeed: rngSeed,
      ),
      homeTeamId: home.id,
      awayTeamId: away.id,
      startingHomeLineup: report.home.startingXi,
      startingAwayLineup: report.away.startingXi,
      balance: balance,
      homeSnapshot: homeSnapshot,
      awaySnapshot: awaySnapshot,
      homeNoGkPenalty: homeNoGk,
      awayNoGkPenalty: awayNoGk,
      homeHeadCoach: home.staff.headCoach,
      awayHeadCoach: away.staff.headCoach,
      homeCohesionMult: homeCohesionMult,
      awayCohesionMult: awayCohesionMult,
      homeChemistry: home.chemistry,
      awayChemistry: away.chemistry,
      homeAtmosphere: home.atmosphere,
      awayAtmosphere: away.atmosphere,
      homeDoctorCareMult: const InjuryService().doctorCareMult(
        home.staff.doctor,
      ),
      awayDoctorCareMult: const InjuryService().doctorCareMult(
        away.staff.doctor,
      ),
      homeDoctorPreventionMult: const InjuryService().doctorPreventionMult(
        home.staff.doctor,
      ),
      awayDoctorPreventionMult: const InjuryService().doctorPreventionMult(
        away.staff.doctor,
      ),
    );
    if (refreshDerivedRatings) {
      _refreshRuntimeRatings(live);
    }
    return live;
  }

  /// Rebuilds the derived Task 16 diagnostics from the current on-pitch state.
  ///
  /// The maps are intentionally kept on [LiveMatch] only. They are not part of
  /// MatchState/MatchResult and therefore do not change save compatibility.
  void _refreshRuntimeRatings(LiveMatch live) {
    final homeLineup = live.state.homeLineup;
    final awayLineup = live.state.awayLineup;
    final shapeCalculator = TeamShapeCalculator(balance: balance);
    final effectiveCalculator = EffectiveAttributeCalculator(balance: balance);
    final unitCalculator = UnitRatingCalculator(balance: balance);

    final homeShape = shapeCalculator.calculate(
      tactics: live.state.homeTactics,
      opponentTactics: live.state.awayTactics,
      lineup: homeLineup,
      opponentLineup: awayLineup,
      headCoach: live.homeHeadCoach,
    );
    final awayShape = shapeCalculator.calculate(
      tactics: live.state.awayTactics,
      opponentTactics: live.state.homeTactics,
      lineup: awayLineup,
      opponentLineup: homeLineup,
      headCoach: live.awayHeadCoach,
    );
    final homeEffective = effectiveCalculator.calculateLineup(
      lineup: homeLineup,
      context: live.state.context,
      chemistry: live.homeChemistry,
      atmosphere: live.homeAtmosphere,
      cohesionMultiplier: live.homeCohesionMult,
      isHome: true,
      headCoach: live.homeHeadCoach,
      staminaRemaining: live.staminaRemaining,
      assignedPositions: _assignedPositionsFor(live.homeSnapshot),
    );
    final awayEffective = effectiveCalculator.calculateLineup(
      lineup: awayLineup,
      context: live.state.context,
      chemistry: live.awayChemistry,
      atmosphere: live.awayAtmosphere,
      cohesionMultiplier: live.awayCohesionMult,
      isHome: false,
      headCoach: live.awayHeadCoach,
      staminaRemaining: live.staminaRemaining,
      assignedPositions: _assignedPositionsFor(live.awaySnapshot),
    );

    live.homeTeamShape = homeShape;
    live.awayTeamShape = awayShape;
    live.homeEffectiveAttributes = Map.unmodifiable(homeEffective);
    live.awayEffectiveAttributes = Map.unmodifiable(awayEffective);
    live.homeUnitRatings = unitCalculator.calculate(
      lineup: homeLineup,
      effectiveAttributes: homeEffective,
      shape: homeShape,
    );
    live.awayUnitRatings = unitCalculator.calculate(
      lineup: awayLineup,
      effectiveAttributes: awayEffective,
      shape: awayShape,
    );
  }

  Map<String, Position> _assignedPositionsFor(MatchTeamSnapshot? snapshot) {
    if (snapshot == null || snapshot.startingXi.isEmpty) return const {};
    final positions = snapshot.assignedPositions;
    return {
      for (
        var index = 0;
        index < snapshot.startingXi.length && index < positions.length;
        index++
      )
        snapshot.startingXi[index].id: positions[index],
    };
  }

  MatchState _applyLeaderMomentumDrift(LiveMatch live, MatchState state) {
    if (state.minute < 60) return state;

    var next = state;
    if (!live.homeLeaderDriftApplied &&
        state.homeGoals < state.awayGoals &&
        _hasLeader(state.homeLineup)) {
      live.homeLeaderDriftApplied = true;
      next = next.copyWith(
        momentum: (next.momentum + 0.08).clamp(-1.0, 1.0).toDouble(),
      );
    }
    if (!live.awayLeaderDriftApplied &&
        state.awayGoals < state.homeGoals &&
        _hasLeader(state.awayLineup)) {
      live.awayLeaderDriftApplied = true;
      next = next.copyWith(
        momentum: (next.momentum - 0.08).clamp(-1.0, 1.0).toDouble(),
      );
    }
    return next;
  }

  bool _hasLeader(List<Player> lineup) =>
      lineup.any((player) => player.personality == PlayerPersonality.leader);

  MatchTeamSnapshot _snapshotFor(
    Team team,
    PreMatchTeamReport report, {
    required double cohesionMultiplier,
    Map<String, Position> assignedPositions = const {},
  }) => MatchTeamSnapshot(
    teamId: team.id,
    startingXi: report.startingXi,
    bench: report.bench,
    assignedPositions: [
      for (final player in report.startingXi)
        assignedPositions[player.id] ?? player.position,
    ],
    assignedRoles: [for (final player in report.startingXi) player.state.role],
    tactics: team.tactics,
    chemistry: team.chemistry,
    atmosphere: team.atmosphere,
    cohesionMultiplier: cohesionMultiplier,
    staff: team.staff,
  );

  /// Simulate one minute. Returns new events produced this minute.
  List<MatchEvent> simulateMinute(LiveMatch live) {
    if (live.isFinished) return const [];
    final nextMinute = live.state.minute + 1;
    final rng = Random(
      Object.hash(live.state.rngSeed, nextMinute, live.state.homeGoals),
    );

    var state = live.state.copyWith(minute: nextMinute);
    final newEvents = <MatchEvent>[];

    // Count the minute with the lineup that was on the pitch at its start.
    state = state.copyWith(
      homeLineup: live.recordMinute(
        lineup: live.state.homeLineup,
        homeSide: true,
      ),
      awayLineup: live.recordMinute(
        lineup: live.state.awayLineup,
        homeSide: false,
      ),
    );
    // The stamina tick belongs to the current minute. Make it visible before
    // calculating team power so effAttr and UnitRatings use the fresh values.
    live.state = state;
    _refreshRuntimeRatings(live);
    state = _applyLeaderMomentumDrift(live, state);
    live.state = state;

    if (nextMinute == 45) {
      final ht = MatchEvent(
        type: MatchEventType.halfTime,
        minute: 45,
        teamId: live.homeTeamId,
        description: 'Przerwa',
      );
      newEvents.add(ht);
    }

    final homePower = _teamPower(
      state.homeLineup,
      state.homeTactics,
      chemistry: live.homeChemistry,
      atmosphere: live.homeAtmosphere,
      cohesionMult: live.homeCohesionMult,
      isHome: true,
      momentum: state.momentum,
      morale: state.moraleModHome,
      context: state.context,
      opponentTactics: state.awayTactics,
      staminaRemaining: live.staminaRemaining,
      noGkPenalty: live.homeNoGkPenalty,
      unitRatings: live.homeUnitRatings,
    );
    final awayPower = _teamPower(
      state.awayLineup,
      state.awayTactics,
      chemistry: live.awayChemistry,
      atmosphere: live.awayAtmosphere,
      cohesionMult: live.awayCohesionMult,
      isHome: false,
      momentum: -state.momentum,
      morale: state.moraleModAway,
      context: state.context,
      opponentTactics: state.homeTactics,
      staminaRemaining: live.staminaRemaining,
      noGkPenalty: live.awayNoGkPenalty,
      unitRatings: live.awayUnitRatings,
    );

    final total = homePower + awayPower;
    final homeChance = (homePower / total) * 0.085;
    final awayChance = (awayPower / total) * 0.085;

    if (rng.nextDouble() < homeChance) {
      final (ev, updated) = _resolveChance(
        live: live,
        state: state,
        attackingHome: true,
        rng: rng,
      );
      state = updated;
      newEvents.addAll(ev);
    } else if (rng.nextDouble() < awayChance) {
      final (ev, updated) = _resolveChance(
        live: live,
        state: state,
        attackingHome: false,
        rng: rng,
      );
      state = updated;
      newEvents.addAll(ev);
    } else if (rng.nextDouble() < 0.012 * _cardChanceMultiplier(live)) {
      final homeAttack = rng.nextBool();
      final teamId = homeAttack ? live.homeTeamId : live.awayTeamId;
      final lineup = homeAttack ? state.homeLineup : state.awayLineup;
      if (lineup.isNotEmpty) {
        final player = lineup[rng.nextInt(lineup.length)];
        final playerInStartingXi =
            (homeAttack ? live.state.homeLineup : live.state.awayLineup).any(
              (candidate) => candidate.id == player.id,
            );
        if (rng.nextDouble() < balance.matchday.redDirect) {
          final severity = DisciplineService.rollDirectRedSeverity(rng);
          newEvents.add(
            MatchEvent(
              type: MatchEventType.redCard,
              minute: nextMinute,
              teamId: teamId,
              playerId: player.id,
              description:
                  'Czerwona kartka — ${player.name} (bezpośrednia, poziom $severity)',
            ),
          );
          _recordDiscipline(
            live,
            teamId: teamId,
            playerId: player.id,
            playerInStartingXi: playerInStartingXi,
            redCardKind: RedCardKind.direct,
            directRedSeverity: severity,
          );
          state = _sendOff(state, player.id, homeAttack);
        } else {
          final yellows = Map<String, int>.from(state.yellowCardCounts);
          final count = (yellows[player.id] ?? 0) + 1;
          yellows[player.id] = count;
          if (count >= 2) {
            newEvents.add(
              MatchEvent(
                type: MatchEventType.redCard,
                minute: nextMinute,
                teamId: teamId,
                playerId: player.id,
                description: 'Czerwona kartka — ${player.name} (2× żółta)',
              ),
            );
            _recordDiscipline(
              live,
              teamId: teamId,
              playerId: player.id,
              playerInStartingXi: playerInStartingXi,
              yellowCardsInMatch: 1,
              redCardKind: RedCardKind.secondYellow,
            );
            state = _sendOff(state, player.id, homeAttack, secondYellow: true);
          } else {
            newEvents.add(
              MatchEvent(
                type: MatchEventType.yellowCard,
                minute: nextMinute,
                teamId: teamId,
                playerId: player.id,
                description: 'Żółta kartka — ${player.name}',
              ),
            );
            _recordDiscipline(
              live,
              teamId: teamId,
              playerId: player.id,
              playerInStartingXi: playerInStartingXi,
              yellowCardsInMatch: 1,
            );
            state = state.copyWith(yellowCardCounts: yellows);
          }
        }
      }
    } else {
      final homeSide = rng.nextBool();
      final lineup = homeSide ? state.homeLineup : state.awayLineup;
      if (lineup.length > 1) {
        final player = lineup[rng.nextInt(lineup.length)];
        final injuryChance =
            0.004 *
            (homeSide
                ? live.homeDoctorPreventionMult
                : live.awayDoctorPreventionMult) *
            balance.player.injuryRiskMult(live.visibleStamina(player)) *
            EffectiveAttributeCalculator(
              balance: balance,
            ).injuryMultiplier(player);
        if (rng.nextDouble() < injuryChance) {
          final diagnosis = const InjuryService().diagnose(
            random: rng,
            doctorCareMultiplier: homeSide
                ? live.homeDoctorCareMult
                : live.awayDoctorCareMult,
          );
          final playerInStartingXi =
              (homeSide ? live.state.homeLineup : live.state.awayLineup).any(
                (candidate) => candidate.id == player.id,
              );
          newEvents.add(
            MatchEvent(
              type: diagnosis.injury.type == InjuryType.major
                  ? MatchEventType.majorInjury
                  : MatchEventType.minorInjury,
              minute: nextMinute,
              teamId: homeSide ? live.homeTeamId : live.awayTeamId,
              playerId: player.id,
              description: '${diagnosis.definition.name} — ${player.name}',
            ),
          );
          live.injuries.add(
            MatchInjury(
              teamId: homeSide ? live.homeTeamId : live.awayTeamId,
              playerId: player.id,
              injury: diagnosis.injury,
              playerInStartingXi: playerInStartingXi,
              potentialLoss: diagnosis.potentialLoss,
            ),
          );
          state = state.copyWith(
            injuriesThisMatch: [...state.injuriesThisMatch, player.id],
          );
          if (diagnosis.injury.type == InjuryType.major) {
            state = _forceInjurySub(
              live,
              state,
              player.id,
              homeSide,
              newEvents,
            );
          }
        }
      }
    }

    if (nextMinute == 90) {
      newEvents.add(
        MatchEvent(
          type: MatchEventType.fullTime,
          minute: 90,
          teamId: live.homeTeamId,
          description: 'Koniec meczu ${state.homeGoals}:${state.awayGoals}',
        ),
      );
    }

    live.state = state;
    _refreshRuntimeRatings(live);
    live.events.addAll(newEvents);
    return newEvents;
  }

  /// Run until [untilMinute] (inclusive) or full time.
  List<MatchEvent> runUntil(LiveMatch live, int untilMinute) {
    final all = <MatchEvent>[];
    while (!live.isFinished && live.state.minute < untilMinute) {
      all.addAll(simulateMinute(live));
    }
    return all;
  }

  MatchResult simulateFull({
    required Team home,
    required Team away,
    MatchContext context = const MatchContext(),
    required int rngSeed,
  }) {
    final live = start(
      home: home,
      away: away,
      context: context,
      rngSeed: rngSeed,
    );
    if (!live.isFinished) {
      runUntil(live, 90);
    }
    return live.toResult();
  }

  bool applySubstitution({
    required LiveMatch live,
    required bool homeSide,
    required String playerOutId,
    required String playerInId,
  }) {
    final maxSubs = balance.matchday.maxSubstitutions;
    final maxWindows = balance.matchday.maxSubstitutionWindows;
    final used = homeSide ? live.homeSubsUsed : live.awaySubsUsed;
    final windows = homeSide ? live.homeSubWindows : live.awaySubWindows;
    if (used >= maxSubs || windows >= maxWindows) return false;

    var lineup = List<Player>.from(
      homeSide ? live.state.homeLineup : live.state.awayLineup,
    );
    var bench = List<Player>.from(
      homeSide ? live.state.homeBench : live.state.awayBench,
    );
    final outIdx = lineup.indexWhere((p) => p.id == playerOutId);
    final inIdx = bench.indexWhere((p) => p.id == playerInId);
    if (outIdx < 0 || inIdx < 0) return false;

    final out = lineup[outIdx];
    final incoming = bench[inIdx];
    lineup[outIdx] = incoming;
    bench.removeAt(inIdx);
    bench.add(out);

    live.state = homeSide
        ? live.state.copyWith(homeLineup: lineup, homeBench: bench)
        : live.state.copyWith(awayLineup: lineup, awayBench: bench);

    if (homeSide) {
      live.homeSubsUsed++;
      live.homeSubWindows++;
    } else {
      live.awaySubsUsed++;
      live.awaySubWindows++;
    }

    live.events.add(
      MatchEvent(
        type: MatchEventType.substitution,
        minute: live.state.minute,
        teamId: homeSide ? live.homeTeamId : live.awayTeamId,
        playerId: playerInId,
        description: 'Zmiana: ${out.name} → ${incoming.name}',
      ),
    );
    _refreshRuntimeRatings(live);
    return true;
  }

  void updateTactics({
    required LiveMatch live,
    required bool homeSide,
    required TacticsSetup tactics,
  }) {
    live.state = homeSide
        ? live.state.copyWith(homeTactics: tactics)
        : live.state.copyWith(awayTactics: tactics);
    _refreshRuntimeRatings(live);
  }

  double _teamPower(
    List<Player> lineup,
    TacticsSetup tactics, {
    required double chemistry,
    required int atmosphere,
    required double cohesionMult,
    required bool isHome,
    required double momentum,
    required double morale,
    required MatchContext context,
    required TacticsSetup opponentTactics,
    required Map<String, double> staminaRemaining,
    required bool noGkPenalty,
    required UnitRatings? unitRatings,
  }) {
    if (lineup.isEmpty) return 1;

    final unitBase = _unitPower(unitRatings);
    final homeAdv = isHome ? (1.0 + context.homeAdvantage) : 1.0;
    final noGkMult = noGkPenalty ? 0.72 : 1.0;
    if (unitBase != null) {
      // UnitRatings already contain effAttr and TeamShape.tacticalMult. Do
      // not multiply chemistry, form, stamina or the old formation scalar a
      // second time here.
      final effectiveMomentum = _averageMomentum(lineup, momentum);
      return unitBase *
          homeAdv *
          noGkMult *
          (1.0 + effectiveMomentum * 0.08 + morale * 0.05);
    }

    // Compatibility fallback for manually assembled LiveMatch instances that
    // predate the runtime diagnostics. Normal MatchEngine.start always takes
    // the UnitRatings branch above.
    final chemMult = TeamManagementService.chemistryMultiplier(chemistry);
    final atmosphereMult = TeamManagementService.atmosphereMultiplier(
      atmosphere,
    );
    var sum = 0.0;
    for (final p in lineup) {
      final roleMult = _roleFitMult(p);
      final contrib =
          p.overall(balance) *
          balance.player.performanceMult(
            balance.player.clampStamina(
              (staminaRemaining[p.id] ?? p.state.stamina.toDouble()).round(),
            ),
          ) *
          p.formMult(balance) *
          roleMult *
          chemMult *
          atmosphereMult *
          cohesionMult;
      sum += contrib;
    }
    sum /= lineup.length;

    final tacticsMult = _tacticsMultiplier(tactics, opponentTactics);
    final effectiveMomentum = _averageMomentum(lineup, momentum);
    return sum *
        tacticsMult *
        homeAdv *
        noGkMult *
        (1.0 + effectiveMomentum * 0.08 + morale * 0.05);
  }

  double? _unitPower(UnitRatings? ratings) {
    if (ratings == null) return null;
    final values = [
      ratings.defRating,
      ratings.midRating,
      ratings.atkRating,
    ].where((rating) => rating > 0).toList(growable: false);
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _averageMomentum(List<Player> lineup, double teamMomentum) {
    if (lineup.isEmpty) return teamMomentum;
    final calculator = EffectiveAttributeCalculator(balance: balance);
    final sum = lineup.fold<double>(
      0,
      (total, player) =>
          total + calculator.momentumForPlayer(player, teamMomentum),
    );
    return sum / lineup.length;
  }

  double _cardChanceMultiplier(LiveMatch live) {
    final players = [...live.state.homeLineup, ...live.state.awayLineup];
    if (players.isEmpty) return 1.0;
    final calculator = EffectiveAttributeCalculator(balance: balance);
    final sum = players.fold<double>(
      0,
      (total, player) => total + calculator.cardProneMultiplier(player),
    );
    // The side and carded player are selected after the existing card roll.
    // Averaging preserves that distribution while applying temperamental's
    // documented expected ×1.35 chance without adding an RNG draw.
    return sum / players.length;
  }

  double _roleFitMult(Player p) {
    final chem = balance.chemistry;
    final role = p.state.role;
    final fits = role.map(
      gk: (_) => p.position == Position.gk,
      cb: (_) => p.position == Position.cb,
      fullBack: (_) => p.position == Position.lb || p.position == Position.rb,
      wingBack: (_) => p.position == Position.lwb || p.position == Position.rwb,
      cdm: (_) => p.position == Position.cdm,
      cm: (_) => p.position == Position.cm,
      cam: (_) => p.position == Position.cam,
      winger: (_) => p.position == Position.lw || p.position == Position.rw,
      striker: (_) => p.position == Position.st,
    );
    if (fits) {
      return (chem.roleMultOkMin + chem.roleMultOkMax) / 2;
    }
    return (chem.roleMultFailMin + chem.roleMultFailMax) / 2;
  }

  double _tacticsMultiplier(TacticsSetup ours, TacticsSetup theirs) {
    final tb = balance.tactics;
    var bonus = 0.0;
    for (final m in tb.formationMatchups) {
      if (m.formationA == ours.formation && m.formationB == theirs.formation) {
        bonus += m.bonusForA;
      }
      if (m.formationA == theirs.formation && m.formationB == ours.formation) {
        bonus -= m.bonusForA;
      }
    }
    final clamp = tb.matchupClamp;
    return 1.0 + bonus.clamp(-clamp, clamp);
  }

  (List<MatchEvent>, MatchState) _resolveChance({
    required LiveMatch live,
    required MatchState state,
    required bool attackingHome,
    required Random rng,
  }) {
    final lineup = attackingHome ? state.homeLineup : state.awayLineup;
    final defense = attackingHome ? state.awayLineup : state.homeLineup;
    if (lineup.isEmpty) return ([], state);

    final attacker = _pickAttacker(lineup, rng);
    final teamId = attackingHome ? live.homeTeamId : live.awayTeamId;
    final defendingNoGk = attackingHome
        ? live.awayNoGkPenalty
        : live.homeNoGkPenalty;
    final atk = attacker.overall(balance);
    final baseDefense = defense.isEmpty
        ? 50.0
        : defense.map((p) => p.overall(balance)).reduce((a, b) => a + b) /
              defense.length;
    // A makeshift goalkeeper is deliberately much less effective than the
    // rest of the defensive block. This keeps a no-GK match playable while
    // reproducing the documented ~0-5 penalty through normal chance rolls.
    final def = defendingNoGk ? baseDefense * 0.55 : baseDefense;
    final finishProb = (0.35 + (atk - def) / 200).clamp(0.15, 0.65);

    if (rng.nextDouble() < 0.08) {
      // Penalty
      final scored = rng.nextDouble() < (defendingNoGk ? 0.95 : 0.75);
      final events = <MatchEvent>[
        MatchEvent(
          type: scored
              ? MatchEventType.scoredPenalty
              : MatchEventType.missedPenalty,
          minute: state.minute,
          teamId: teamId,
          playerId: attacker.id,
          description: scored
              ? 'Gol z karnego — ${attacker.name}'
              : 'Niewykorzystany karny — ${attacker.name}',
        ),
      ];
      if (scored) {
        state = attackingHome
            ? state.copyWith(
                homeGoals: state.homeGoals + 1,
                momentum: (state.momentum + 0.3).clamp(-1.0, 1.0),
              )
            : state.copyWith(
                awayGoals: state.awayGoals + 1,
                momentum: (state.momentum - 0.3).clamp(-1.0, 1.0),
              );
      }
      return (events, state);
    }

    if (rng.nextDouble() < finishProb) {
      final events = [
        MatchEvent(
          type: MatchEventType.goal,
          minute: state.minute,
          teamId: teamId,
          playerId: attacker.id,
          description: 'GOL — ${attacker.name}',
        ),
      ];
      state = attackingHome
          ? state.copyWith(
              homeGoals: state.homeGoals + 1,
              momentum: (state.momentum + 0.25).clamp(-1.0, 1.0),
            )
          : state.copyWith(
              awayGoals: state.awayGoals + 1,
              momentum: (state.momentum - 0.25).clamp(-1.0, 1.0),
            );
      return (events, state);
    }

    return ([], state);
  }

  Player _pickAttacker(List<Player> lineup, Random rng) {
    final attackers = lineup
        .where(
          (p) =>
              p.position == Position.st ||
              p.position == Position.lw ||
              p.position == Position.rw ||
              p.position == Position.cam,
        )
        .toList();
    final pool = attackers.isNotEmpty ? attackers : lineup;
    return pool[rng.nextInt(pool.length)];
  }

  void _recordDiscipline(
    LiveMatch live, {
    required String teamId,
    required String playerId,
    required bool playerInStartingXi,
    int yellowCardsInMatch = 0,
    RedCardKind redCardKind = RedCardKind.none,
    int directRedSeverity = 0,
  }) {
    final index = live.disciplines.indexWhere(
      (discipline) =>
          discipline.teamId == teamId && discipline.playerId == playerId,
    );
    final item = MatchDiscipline(
      teamId: teamId,
      playerId: playerId,
      yellowCardsInMatch: yellowCardsInMatch,
      redCardKind: redCardKind,
      directRedSeverity: directRedSeverity,
      playerInStartingXi: playerInStartingXi,
    );
    if (index < 0) {
      live.disciplines.add(item);
      return;
    }
    final previous = live.disciplines[index];
    live.disciplines[index] = previous.copyWith(
      yellowCardsInMatch: previous.yellowCardsInMatch + item.yellowCardsInMatch,
      redCardKind:
          item.redCardKind == RedCardKind.direct ||
              previous.redCardKind == RedCardKind.direct
          ? RedCardKind.direct
          : item.redCardKind == RedCardKind.secondYellow ||
                previous.redCardKind == RedCardKind.secondYellow
          ? RedCardKind.secondYellow
          : RedCardKind.none,
      directRedSeverity: item.directRedSeverity > 0
          ? item.directRedSeverity
          : previous.directRedSeverity,
      playerInStartingXi:
          previous.playerInStartingXi || item.playerInStartingXi,
    );
  }

  MatchState _sendOff(
    MatchState state,
    String playerId,
    bool homeSide, {
    bool secondYellow = false,
  }) {
    final lineup = List<Player>.from(
      homeSide ? state.homeLineup : state.awayLineup,
    );
    lineup.removeWhere((p) => p.id == playerId);
    return homeSide
        ? state.copyWith(
            homeLineup: lineup,
            sentOffPlayerIds: [...state.sentOffPlayerIds, playerId],
            yellowCardCounts: secondYellow
                ? {...state.yellowCardCounts, playerId: 2}
                : state.yellowCardCounts,
            momentum: (state.momentum - 0.2).clamp(-1.0, 1.0),
          )
        : state.copyWith(
            awayLineup: lineup,
            sentOffPlayerIds: [...state.sentOffPlayerIds, playerId],
            yellowCardCounts: secondYellow
                ? {...state.yellowCardCounts, playerId: 2}
                : state.yellowCardCounts,
            momentum: (state.momentum + 0.2).clamp(-1.0, 1.0),
          );
  }

  MatchState _forceInjurySub(
    LiveMatch live,
    MatchState state,
    String playerId,
    bool homeSide,
    List<MatchEvent> events,
  ) {
    final bench = homeSide ? state.homeBench : state.awayBench;
    if (bench.isEmpty) {
      return _sendOff(state, playerId, homeSide);
    }
    final incoming = bench.first;
    applySubstitution(
      live: live..state = state,
      homeSide: homeSide,
      playerOutId: playerId,
      playerInId: incoming.id,
    );
    return live.state;
  }
}
