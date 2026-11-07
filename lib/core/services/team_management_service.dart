import 'package:new_football/core/tactics/position_role_fit.dart';
import 'package:new_football/core/balance/balance_config.dart';
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
  const TeamManagementService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  /// Discrete chemistry multiplier used by the match engine.
  static double chemistryMultiplier(
    num chemistry, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    final b = balance.chemistry;
    final value = chemistry.toDouble().clamp(b.scoreMin, b.scoreMax);
    for (final (upperBound, multiplier) in b.chemistryBands) {
      if (value < upperBound) return multiplier;
    }
    return b.chemistryBands.last.$2;
  }

  /// Discrete atmosphere multiplier used by the match engine.
  static double atmosphereMultiplier(
    int atmosphere, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    final b = balance.chemistry;
    final value = atmosphere.clamp(b.scoreMin, b.scoreMax);
    for (final (upperBound, multiplier) in b.atmosphereBands) {
      if (value < upperBound) return multiplier;
    }
    return b.atmosphereBands.last.$2;
  }

  /// Event chance multiplier for the two atmosphere-driven event families.
  static double eventProbabilityMultiplier(
    int atmosphere, {
    required bool positive,
    BalanceConfig balance = BalanceConfig.defaults,
  }) {
    final b = balance.chemistry;
    final value = atmosphere.clamp(b.scoreMin, b.scoreMax);
    final bands = positive ? b.positiveEventBands : b.negativeEventBands;
    for (final (upperBound, multiplier) in bands) {
      if (value < upperBound) return multiplier;
    }
    return bands.last.$2;
  }

  static double negativeEventMultiplier(
    int atmosphere, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) =>
      eventProbabilityMultiplier(atmosphere, positive: false, balance: balance);

  static double positiveEventMultiplier(
    int atmosphere, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) =>
      eventProbabilityMultiplier(atmosphere, positive: true, balance: balance);

  /// Expected wins for a team-power rank in the 58-game regular season.
  static int expectedWins(
    int expectedRank, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    final rank = expectedRank.clamp(1, 30);
    return (58 *
            (1 - (rank - 1) / 29 * balance.chemistry.expectedWinsRankPenalty) *
            balance.chemistry.expectedWinsBaseShare)
        .round();
  }

  /// Form of the last eight results as a points ratio in [0, 1].
  static double teamForm(
    Iterable<int> results, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    final allValues = results.toList();
    final values = allValues.length <= ChemistryBalance.recentResultsWindow
        ? allValues
        : allValues.sublist(
            allValues.length - ChemistryBalance.recentResultsWindow,
          );
    if (values.isEmpty) return balance.chemistry.emptyTeamForm;
    final points = values.fold<int>(
      0,
      (sum, result) =>
          sum +
          (result > 0
              ? CalendarBalance.winPoints
              : result == 0
              ? CalendarBalance.drawPoints
              : 0),
    );
    return points / (values.length * CalendarBalance.winPoints);
  }

  /// Returns true for structural administrative results. The description
  /// fallback keeps old saved/test results compatible; real Task 15 no-GK
  /// matches remain `played` and are therefore not classified as walkovers.
  static bool isWalkoverResult(MatchResult result) {
    if (result.status != MatchStatus.played || result.isWalkover) return true;
    return result.events.any(
      (event) => _isAdministrativeDescription(event.description ?? ''),
    );
  }

  /// Teams responsible for an administrative result and therefore receiving
  /// the one-off atmosphere penalty.
  static Set<String> walkoverTeamIds(MatchResult result) {
    if (!isWalkoverResult(result)) return const {};
    if (result.violatingTeamIds.isNotEmpty) {
      return result.violatingTeamIds.toSet();
    }
    if (result.status != MatchStatus.played || result.isWalkover) {
      final descriptions = result.events
          .map((event) => event.description ?? '')
          .where(_isAdministrativeDescription)
          .toList();
      if (descriptions.isEmpty) {
        return {result.homeTeamId, result.awayTeamId};
      }
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

    // Legacy results were sometimes marked only by a Polish event
    // description while retaining the default `played` status.
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
    required int seasonYear,
    List<Position>? assignedPositions,
  }) {
    final isHome = team.id == result.homeTeamId;
    final isAway = team.id == result.awayTeamId;
    if (!isHome && !isAway) {
      return TeamMatchUpdate(team: team, chemistryDelta: 0.0, result: 0);
    }

    final withStats = _recordSeasonStats(
      team,
      stats: isHome ? result.homeStats : result.awayStats,
      seasonYear: seasonYear,
    );

    final scored = isHome ? result.homeGoals : result.awayGoals;
    final conceded = isHome ? result.awayGoals : result.homeGoals;
    final outcome = scored > conceded
        ? 1
        : scored < conceded
        ? -1
        : 0;
    final recent = [...team.recentMatchResults, outcome];
    final recentResults = recent.length <= ChemistryBalance.recentResultsWindow
        ? recent
        : recent.sublist(recent.length - ChemistryBalance.recentResultsWindow);

    // Walkovers and no-GK results are recorded as results, but do not count
    // as a normal XI chemistry appearance.
    if (isWalkoverResult(result) || startingEleven.isEmpty) {
      return TeamMatchUpdate(
        team: withStats.copyWith(recentMatchResults: recentResults),
        chemistryDelta: 0.0,
        result: outcome,
      );
    }

    final b = balance.chemistry;
    final lineup = startingEleven.take(balance.roster.startingXi).toList();
    final positions =
        assignedPositions != null && assignedPositions.length >= lineup.length
        ? assignedPositions
        : null;
    var optimalPlayers = 0;
    var outOfPosition = 0;
    for (var i = 0; i < lineup.length; i++) {
      final player = lineup[i];
      final optimal = positions == null
          ? positionFitsRole(player.position, player.state.role)
          : player.position == positions[i];
      if (optimal) {
        optimalPlayers++;
      } else {
        outOfPosition++;
      }
    }

    var delta = 0.0;
    if (lineup.length == balance.roster.startingXi &&
        optimalPlayers == balance.roster.startingXi) {
      delta += b.fullLineupChemistryBonus;
    }
    delta -= outOfPosition * b.foreignPositionChemistryPenalty;

    final experienced = team.roster
        .where(
          (player) => player.state.seasonsWithTeam >= b.experiencedSeasonsMin,
        )
        .length;
    if (experienced >= b.experiencedPlayersMin) {
      delta += b.experiencedChemistryBonus;
    }

    final nationalityCounts = <Nationality, int>{};
    for (final player in lineup) {
      nationalityCounts[player.nationality] =
          (nationalityCounts[player.nationality] ?? 0) + 1;
    }
    final clusters = nationalityCounts.values.fold<int>(
      0,
      (sum, count) => sum + count ~/ b.nationalityClusterSize,
    );
    delta += (clusters * b.nationalityClusterBonus).clamp(
      0.0,
      b.nationalityBonusMax,
    );

    final appearances = Map<String, int>.from(team.chemistryAppearances);
    for (final player in lineup) {
      final previousAppearances = appearances[player.id] ?? 0;
      if (previousAppearances < balance.matchday.adaptationAppearances) {
        // -1.0, -0.8, -0.6, -0.4, -0.2 before appearances 1–5;
        // the penalty is zero from the sixth appearance onward.
        delta -= balance.matchday.adaptationPenaltyForAppearances(
          previousAppearances,
        );
      }
      appearances[player.id] = previousAppearances + 1;
    }

    final rosterIds = team.roster.map((player) => player.id).toSet();
    appearances.removeWhere((id, _) => !rosterIds.contains(id));
    final nextChemistry = (team.chemistry + delta)
        .clamp(balance.chemistry.scoreMin, balance.chemistry.scoreMax)
        .toDouble();
    return TeamMatchUpdate(
      team: withStats.copyWith(
        chemistry: nextChemistry,
        recentMatchResults: recentResults,
        chemistryAppearances: appearances,
      ),
      chemistryDelta: nextChemistry - team.chemistry,
      result: outcome,
    );
  }

  Team _recordSeasonStats(
    Team team, {
    required TeamMatchStats stats,
    required int seasonYear,
  }) {
    final seasons = [...team.seasonStats];
    final index = seasons.indexWhere((season) => season.year == seasonYear);
    final previous = index < 0
        ? TeamSeasonStats(year: seasonYear)
        : seasons[index];
    final next = previous.addMatch(stats);
    if (index < 0) {
      seasons.add(next);
    } else {
      seasons[index] = next;
    }
    return team.copyWith(seasonStats: seasons);
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
    final b = balance.chemistry;
    if (streak >= b.atmosphereStreakLength) {
      atmosphereDelta += b.atmosphereStreakDelta;
    }
    if (streak <= -b.atmosphereStreakLength) {
      atmosphereDelta -= b.atmosphereStreakDelta;
    }

    final rankDifference = expectedRank - currentRank;
    for (final (minDifference, delta) in b.rankAtmosphereBands) {
      if (rankDifference.abs() >= minDifference) {
        atmosphereDelta += rankDifference.sign * delta;
        break;
      }
    }

    final nextAtmosphere = (team.atmosphere + atmosphereDelta).clamp(
      balance.chemistry.scoreMin,
      balance.chemistry.scoreMax,
    );
    final chemistryDelta = chemistryDriftForAtmosphere(
      team.atmosphere,
      balance,
    );
    final nextChemistry = (team.chemistry + chemistryDelta)
        .clamp(balance.chemistry.scoreMin, balance.chemistry.scoreMax)
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
    final retainedHistory = history.length <= balance.calendar.seasonCycleWeeks
        ? history
        : history.sublist(history.length - balance.calendar.seasonCycleWeeks);

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
    atmosphere: (team.atmosphere + delta).round().clamp(
      balance.chemistry.scoreMin,
      balance.chemistry.scoreMax,
    ),
  );

  /// Applies an immediate chemistry delta while preserving fractional points.
  Team applyChemistryDelta(Team team, num delta) => team.copyWith(
    chemistry: (team.chemistry + delta)
        .clamp(balance.chemistry.scoreMin, balance.chemistry.scoreMax)
        .toDouble(),
  );

  /// Overall regular-season rank (1-based), using points then point
  /// differential, matching the UI's existing rank calculation.
  static int actualRankOf(
    LeagueState league,
    String teamId, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
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
    return index < 0 ? balance.ai.expectedRankFallback : index + 1;
  }

  /// Weekly chemistry drift induced by the current atmosphere.
  static double chemistryDriftForAtmosphere(
    int atmosphere, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    for (final (upperBound, delta)
        in balance.chemistry.atmosphereChemistryDrift) {
      if (atmosphere < upperBound) return delta;
    }
    return balance.chemistry.atmosphereChemistryDrift.last.$2;
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
}
