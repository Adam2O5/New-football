import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';

/// Calculates and updates the league strength table (`team_management.md`).
///
/// Key rules:
/// - `teamPower` = avg overall of top 15 signed roster players (missing → 50).
/// - Tie-break: full-precision teamPower → previous regular-season points →
///   lower totalPayroll → teamId.
/// - Hysteresis: max 1 tier shift per recalculation.
/// - Fixed tier distribution: elite(3), contender(6), pretender(9),
///   retool(7), rebuild(5).
class LeagueStrengthService {
  const LeagueStrengthService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  static const _topN = 15;
  static const _missingOvr = 50.0;
  static const _tierCounts = <int>[5, 7, 9, 6, 3];

  /// Computes teamPower rounded to the two decimal places shown in the UI.
  double computeTeamPower(Team team) => _round(computeTeamPowerPrecise(team));

  /// Computes the unrounded value used by the deterministic tie-break.
  double computeTeamPowerPrecise(Team team) {
    final overalls =
        team.roster.where(_isSigned).map((p) => p.overall(balance)).toList()
          ..sort((a, b) => b.compareTo(a));

    var sum = 0.0;
    for (var i = 0; i < _topN; i++) {
      sum += i < overalls.length ? overalls[i] : _missingOvr;
    }
    return sum / _topN;
  }

  /// Tier for a given rank position (1-indexed).
  /// Distribution: 1–3=elite, 4–9=contender, 10–18=pretender,
  /// 19–25=retool, 26–30=rebuild.
  static TeamStatus tierForRank(int rank) {
    if (rank <= 3) return TeamStatus.elite;
    if (rank <= 9) return TeamStatus.contender;
    if (rank <= 18) return TeamStatus.pretender;
    if (rank <= 25) return TeamStatus.retool;
    return TeamStatus.rebuild;
  }

  /// Applies hysteresis: clamps tier change to ±1 from previous.
  static TeamStatus applyHysteresis(TeamStatus target, TeamStatus? previous) {
    if (previous == null) return target;
    final tiers = TeamStatus.values;
    final targetIdx = tiers.indexOf(target);
    final prevIdx = tiers.indexOf(previous);
    final clamped = targetIdx.clamp(prevIdx - 1, prevIdx + 1);
    return tiers[clamped];
  }

  /// Full recalculation of the strength table.
  ///
  /// [previousTable] is used for hysteresis. Pass `null` on first calculation
  /// (new career start) — hysteresis is skipped.
  LeagueStrengthTable calculate(
    LeagueState league, {
    LeagueStrengthTable? previousTable,
    required int week,
    int day = 1,
    int? seasonYear,
  }) {
    final powers = <String, double>{};
    for (final team in league.teams) {
      powers[team.id] = computeTeamPowerPrecise(team);
    }

    final previousPoints = _previousSeasonPoints(league);
    final sorted = List<Team>.from(league.teams)
      ..sort((a, b) {
        final pa = powers[a.id] ?? 0.0;
        final pb = powers[b.id] ?? 0.0;
        final byPower = pb.compareTo(pa);
        if (byPower != 0) return byPower;

        final pointsA = previousPoints[a.id] ?? 0;
        final pointsB = previousPoints[b.id] ?? 0;
        final byPreviousPoints = pointsB.compareTo(pointsA);
        if (byPreviousPoints != 0) return byPreviousPoints;

        final payA = a.finance.totalPayroll;
        final payB = b.finance.totalPayroll;
        if (payA != payB) return payA.compareTo(payB);
        return a.id.compareTo(b.id);
      });

    final statuses = _assignStatuses(sorted, previousTable);
    final entries = <TeamStrengthEntry>[];
    for (var i = 0; i < sorted.length; i++) {
      final team = sorted[i];
      entries.add(
        TeamStrengthEntry(
          teamId: team.id,
          teamPower: _round(powers[team.id] ?? 0.0),
          expectedRank: i + 1,
          teamStatus: statuses[i],
        ),
      );
    }

    return LeagueStrengthTable(
      entries: entries,
      lastCalculatedWeek: week,
      lastCalculatedDay: day,
      seasonYear: seasonYear ?? league.currentSeason.year,
    );
  }

  /// Whether the table should be recalculated on the given (week, day).
  ///
  /// Rules (`team_management.md`): start of a career, every four weeks at
  /// weeks 1/5/9/13/17/21, Monday of week 23, and Tuesday of week 44. The
  /// week-44 calculation is deliberately additional: it refreshes AI values
  /// before the lottery without replacing the trade-deadline calculation.
  bool shouldRecalculate(
    int week,
    int day,
    LeagueStrengthTable? current, {
    int? seasonYear,
  }) {
    if (current == null) return true;
    if (seasonYear != null &&
        current.seasonYear != 0 &&
        current.seasonYear != seasonYear) {
      return true;
    }
    if (week == current.lastCalculatedWeek &&
        day == current.lastCalculatedDay) {
      return false;
    }
    // A rollover starts a new season at week 1/day 1. The old table may also
    // have been calculated on week 1 in the previous season, so the date
    // guard above is intentionally not sufficient on its own.
    if (week == 1 && day == 1 && current.lastCalculatedWeek != 1) {
      return true;
    }

    if (week == balance.calendar.tradeDeadlineWeek && day == 1) return true;
    if (day == 1 && week >= 5 && week < balance.calendar.tradeDeadlineWeek) {
      if ((week - 1) % 4 == 0) return true;
    }
    return week == balance.calendar.awardsWeek && day == 2;
  }

  static bool _isSigned(Player player) =>
      player.contract.salary > 0 && player.contract.yearsRemaining > 0;

  static double _round(double value) => double.parse(value.toStringAsFixed(2));

  Map<String, int> _previousSeasonPoints(LeagueState league) {
    if (league.history.isEmpty) return const {};
    final last = league.history.last;
    final points = <String, int>{};
    for (final conference in last.finalStandings) {
      for (final standing in conference.standings) {
        points[standing.teamId] = standing.points;
      }
    }
    return points;
  }

  List<TeamStatus> _assignStatuses(
    List<Team> sorted,
    LeagueStrengthTable? previousTable,
  ) {
    if (sorted.length != 30) {
      return [
        for (var i = 0; i < sorted.length; i++)
          applyHysteresis(
            tierForRank(i + 1),
            previousTable?.entryFor(sorted[i].id)?.teamStatus,
          ),
      ];
    }

    // A constrained assignment keeps the mandated 3/6/9/7/5 distribution
    // while limiting every returning team's movement to one tier. This is a
    // small dynamic program (30 rows and at most 5 tier counts), so it is
    // deterministic and cheap enough for the periodic recalculation.
    final previous = [
      for (final team in sorted) previousTable?.entryFor(team.id)?.teamStatus,
    ];
    if (previousTable == null) {
      return [for (var rank = 1; rank <= 30; rank++) tierForRank(rank)];
    }

    final memo = <String, List<int>?>{};
    List<int>? solve(int index, List<int> remaining) {
      final key = '$index:${remaining.join(',')}';
      if (memo.containsKey(key)) return memo[key];
      if (index == sorted.length) {
        final complete = remaining.every((count) => count == 0);
        return memo[key] = complete ? <int>[] : null;
      }

      final target = TeamStatus.values.indexOf(tierForRank(index + 1));
      final previousStatus = previous[index];
      final previousIndex = previousStatus == null
          ? null
          : TeamStatus.values.indexOf(previousStatus);
      List<int>? best;
      var bestCost = 1 << 30;
      for (
        var candidate = 0;
        candidate < TeamStatus.values.length;
        candidate++
      ) {
        if (remaining[candidate] == 0) continue;
        if (previousIndex != null && (candidate - previousIndex).abs() > 1) {
          continue;
        }
        final nextRemaining = [...remaining];
        nextRemaining[candidate]--;
        final tail = solve(index + 1, nextRemaining);
        if (tail == null) continue;
        final cost = (candidate - target).abs();
        if (best == null || cost < bestCost) {
          bestCost = cost;
          best = [candidate, ...tail];
        }
      }
      return memo[key] = best;
    }

    final indexes = solve(0, [..._tierCounts]);
    if (indexes == null) {
      return [
        for (var i = 0; i < sorted.length; i++)
          applyHysteresis(
            tierForRank(i + 1),
            previousTable.entryFor(sorted[i].id)?.teamStatus,
          ),
      ];
    }
    return [for (final index in indexes) TeamStatus.values[index]];
  }
}
