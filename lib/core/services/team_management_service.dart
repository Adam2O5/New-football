import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';

/// Result of applying one match to the persistent team-management indicators.
class TeamMatchUpdate {
  const TeamMatchUpdate({
    required this.team,
    required this.chemistryDelta,
    required this.result,
  });

  final Team team;
  final double chemistryDelta;
  final int result;
}

/// Result of the Sunday → Monday team-management rollover.
class TeamWeeklyUpdate {
  const TeamWeeklyUpdate({
    required this.team,
    required this.atmosphereDelta,
    required this.chemistryDelta,
  });

  final Team team;
  final int atmosphereDelta;
  final double chemistryDelta;
}

/// Implements the persistent chemistry/atmosphere rules from
/// `docs/team_management.md`.
///
/// Match cohesion remains in [CohesionService]. This service owns the slower,
/// saved team-level chemistry and the weekly atmosphere lifecycle.
class TeamManagementService {
  const TeamManagementService();

  /// Discrete chemistry multiplier used by the match engine.
  static double chemistryMultiplier(num chemistry) {
    final value = chemistry.toDouble().clamp(0.0, 100.0);
    if (value < 30) return 0.95;
    if (value < 50) return 0.98;
    if (value < 70) return 1.00;
    if (value < 85) return 1.02;
    return 1.05;
  }

  /// Discrete atmosphere multiplier used by the match engine.
  static double atmosphereMultiplier(int atmosphere) {
    final value = atmosphere.clamp(0, 100);
    if (value < 30) return 0.95;
    if (value < 45) return 0.97;
    if (value < 70) return 1.00;
    if (value < 85) return 1.02;
    return 1.04;
  }

  /// Event chance multiplier for the two atmosphere-driven event families.
  static double eventProbabilityMultiplier(
    int atmosphere, {
    required bool positive,
  }) {
    final value = atmosphere.clamp(0, 100);
    if (positive) {
      if (value >= 85) return 1.20;
      if (value >= 70) return 1.10;
      return 1.00;
    }
    if (value < 30) return 1.25;
    if (value < 45) return 1.10;
    return 1.00;
  }

  static double negativeEventMultiplier(int atmosphere) =>
      eventProbabilityMultiplier(atmosphere, positive: false);

  static double positiveEventMultiplier(int atmosphere) =>
      eventProbabilityMultiplier(atmosphere, positive: true);

  /// Expected wins for a team-power rank in the 58-game regular season.
  static int expectedWins(int expectedRank) {
    final rank = expectedRank.clamp(1, 30);
    return (58 * (1 - (rank - 1) / 29 * 0.45) * 0.5).round();
  }

  /// Form of the last eight results as a points ratio in [0, 1].
  static double teamForm(Iterable<int> results) {
    final allValues = results.toList();
    final values = allValues.length <= 8
        ? allValues
        : allValues.sublist(allValues.length - 8);
    if (values.isEmpty) return 0.5;
    final points = values.fold<int>(
      0,
      (sum, result) =>
          sum +
          (result > 0
              ? 3
              : result == 0
              ? 1
              : 0),
    );
    return points / (values.length * 3);
  }

  /// Returns true for roster/no-goalkeeper administrative results.
  static bool isWalkoverResult(MatchResult result) {
    if (result.isWalkover) return true;
    return result.events.any(
      (event) => _isAdministrativeDescription(event.description ?? ''),
    );
  }

  /// Teams responsible for an administrative result and therefore receiving
  /// the one-off atmosphere penalty.
  static Set<String> walkoverTeamIds(MatchResult result) {
    if (!isWalkoverResult(result)) return const {};
    final descriptions = result.events
        .map((event) => event.description ?? '')
        .where(_isAdministrativeDescription)
        .toList();
    if (descriptions.any(
      (description) => description.toLowerCase().contains('obie drużyny'),
    )) {
      return {result.homeTeamId, result.awayTeamId};
    }
    return {
      for (final event in result.events)
        if (_isAdministrativeDescription(event.description ?? '') &&
            !(event.description ?? '').toLowerCase().contains('obie drużyny'))
          event.teamId,
    };
  }

  static bool _isAdministrativeDescription(String description) {
    final normalized = description.toLowerCase();
    return normalized.startsWith('walkower') ||
        normalized.startsWith('brak bramkarza') ||
        normalized.startsWith('obie drużyny bez br');
  }

  /// Applies a result to the persistent team history and chemistry.
  ///
  /// [assignedPositions] is optional because the current engine stores the
  /// player's natural position as the assignment. Tests and future formation
  /// code can provide the actual position at each XI slot to model an
  /// out-of-position appearance precisely.
  TeamMatchUpdate applyMatchResult({
    required Team team,
    required MatchResult result,
    required List<Player> startingEleven,
    List<Position>? assignedPositions,
  }) {
    final isHome = team.id == result.homeTeamId;
    final isAway = team.id == result.awayTeamId;
    if (!isHome && !isAway) {
      return TeamMatchUpdate(team: team, chemistryDelta: 0.0, result: 0);
    }

    final scored = isHome ? result.homeGoals : result.awayGoals;
    final conceded = isHome ? result.awayGoals : result.homeGoals;
    final outcome = scored > conceded
        ? 1
        : scored < conceded
        ? -1
        : 0;
    final recent = [...team.recentMatchResults, outcome];
    final recentResults = recent.length <= 8
        ? recent
        : recent.sublist(recent.length - 8);

    // Walkovers and no-GK results are recorded as results, but do not count
    // as a normal XI chemistry appearance.
    if (isWalkoverResult(result) || startingEleven.isEmpty) {
      return TeamMatchUpdate(
        team: team.copyWith(recentMatchResults: recentResults),
        chemistryDelta: 0.0,
        result: outcome,
      );
    }

    final lineup = startingEleven.take(11).toList();
    final positions =
        assignedPositions != null && assignedPositions.length >= lineup.length
        ? assignedPositions
        : null;
    var optimalPlayers = 0;
    var outOfPosition = 0;
    for (var i = 0; i < lineup.length; i++) {
      final player = lineup[i];
      final optimal = positions == null
          ? _positionFitsRole(player.position, player.state.role)
          : player.position == positions[i];
      if (optimal) {
        optimalPlayers++;
      } else {
        outOfPosition++;
      }
    }

    var delta = 0.0;
    if (lineup.length == 11 && optimalPlayers == 11) {
      delta += 0.3;
    }
    delta -= outOfPosition * 0.4;

    final experienced = team.roster
        .where((player) => player.state.seasonsWithTeam >= 3)
        .length;
    if (experienced >= 10) delta += 0.3;

    final nationalityCounts = <Nationality, int>{};
    for (final player in lineup) {
      nationalityCounts[player.nationality] =
          (nationalityCounts[player.nationality] ?? 0) + 1;
    }
    final clusters = nationalityCounts.values.fold<int>(
      0,
      (sum, count) => sum + count ~/ 4,
    );
    delta += (clusters * 0.2).clamp(0.0, 1.0);

    final appearances = Map<String, int>.from(team.chemistryAppearances);
    for (final player in lineup) {
      final previousAppearances = appearances[player.id] ?? 0;
      if (previousAppearances < 5) {
        // -1.0, -0.8, -0.6, -0.4, -0.2 before appearances 1–5;
        // the penalty is zero from the sixth appearance onward.
        delta -= (5 - previousAppearances) / 5;
      }
      appearances[player.id] = previousAppearances + 1;
    }

    final rosterIds = team.roster.map((player) => player.id).toSet();
    appearances.removeWhere((id, _) => !rosterIds.contains(id));
    final nextChemistry = (team.chemistry + delta).clamp(0.0, 100.0).toDouble();
    return TeamMatchUpdate(
      team: team.copyWith(
        chemistry: nextChemistry,
        recentMatchResults: recentResults,
        chemistryAppearances: appearances,
      ),
      chemistryDelta: nextChemistry - team.chemistry,
      result: outcome,
    );
  }

  /// Performs the weekly atmosphere update and the slower chemistry drift.
  TeamWeeklyUpdate updateWeekly({
    required Team team,
    required int seasonYear,
    required int week,
    required int expectedRank,
    required int currentRank,
  }) {
    var atmosphereDelta = 0;
    final streak = _streak(team.recentMatchResults);
    if (streak >= 3) atmosphereDelta += 3;
    if (streak <= -3) atmosphereDelta -= 3;

    final rankDifference = expectedRank - currentRank;
    if (rankDifference >= 6) atmosphereDelta += 2;
    if (rankDifference >= 2 && rankDifference <= 5) atmosphereDelta += 1;
    if (rankDifference <= -6) atmosphereDelta -= 2;
    if (rankDifference <= -2 && rankDifference >= -5) atmosphereDelta -= 1;

    final nextAtmosphere = (team.atmosphere + atmosphereDelta).clamp(0, 100);
    final chemistryDelta = chemistryDriftForAtmosphere(team.atmosphere);
    final nextChemistry = (team.chemistry + chemistryDelta)
        .clamp(0.0, 100.0)
        .toDouble();

    final wins = team.recentMatchResults.where((result) => result > 0).length;
    final draws = team.recentMatchResults.where((result) => result == 0).length;
    final losses = team.recentMatchResults.where((result) => result < 0).length;
    final history = [
      ...team.weeklyHistory,
      TeamWeeklyHistory(
        seasonYear: seasonYear,
        week: week,
        atmosphereDelta: nextAtmosphere - team.atmosphere,
        chemistryDelta: nextChemistry - team.chemistry,
        atmosphere: nextAtmosphere,
        chemistry: nextChemistry,
        wins: wins,
        draws: draws,
        losses: losses,
      ),
    ];
    final retainedHistory = history.length <= 52
        ? history
        : history.sublist(history.length - 52);

    return TeamWeeklyUpdate(
      team: team.copyWith(
        atmosphere: nextAtmosphere,
        chemistry: nextChemistry,
        weeklyHistory: retainedHistory,
      ),
      atmosphereDelta: nextAtmosphere - team.atmosphere,
      chemistryDelta: nextChemistry - team.chemistry,
    );
  }

  /// Applies an immediate event/season atmosphere delta.
  Team applyAtmosphereDelta(Team team, num delta) => team.copyWith(
    atmosphere: (team.atmosphere + delta).round().clamp(0, 100),
  );

  /// Applies an immediate chemistry delta while preserving fractional points.
  Team applyChemistryDelta(Team team, num delta) => team.copyWith(
    chemistry: (team.chemistry + delta).clamp(0.0, 100.0).toDouble(),
  );

  /// Overall regular-season rank (1-based), using points then point
  /// differential, matching the UI's existing rank calculation.
  static int actualRankOf(LeagueState league, String teamId) {
    final standings =
        [
          for (final conference in league.currentSeason.standings)
            ...conference.standings,
        ]..sort((a, b) {
          final byPoints = b.points.compareTo(a.points);
          if (byPoints != 0) return byPoints;
          final byDifference = b.goalDifference.compareTo(a.goalDifference);
          if (byDifference != 0) return byDifference;
          return a.teamId.compareTo(b.teamId);
        });
    final index = standings.indexWhere((standing) => standing.teamId == teamId);
    return index < 0 ? 15 : index + 1;
  }

  /// Weekly chemistry drift induced by the current atmosphere.
  static double chemistryDriftForAtmosphere(int atmosphere) {
    if (atmosphere < 30) return -2.0;
    if (atmosphere < 45) return -1.0;
    if (atmosphere < 70) return 0.0;
    if (atmosphere < 85) return 1.0;
    return 2.0;
  }

  static int _streak(List<int> results) {
    if (results.isEmpty) return 0;
    final last = results.last;
    if (last == 0) return 0;
    var count = 0;
    for (var i = results.length - 1; i >= 0; i--) {
      if (results[i] != last) break;
      count++;
    }
    return last * count;
  }

  static bool _positionFitsRole(Position position, AssignedRole role) {
    return role.map(
      gk: (_) => position == Position.gk,
      cb: (_) => position == Position.cb,
      fullBack: (_) => position == Position.lb || position == Position.rb,
      wingBack: (_) => position == Position.lwb || position == Position.rwb,
      cdm: (_) => position == Position.cdm,
      cm: (_) => position == Position.cm,
      cam: (_) => position == Position.cam,
      winger: (_) => position == Position.lw || position == Position.rw,
      striker: (_) => position == Position.st,
    );
  }
}
