import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';

/// Calculates and updates the league strength table (`team_management.md`).
///
/// Key rules:
/// - `teamPower` = avg overall of top 15 roster players (missing → 50).
/// - Tie-break: higher precision teamPower → lower totalPayroll → teamId.
/// - Hysteresis: max 1 tier shift per recalculation.
/// - Fixed tier distribution: elite(3), contender(6), pretender(9), retool(7), rebuild(5).
class LeagueStrengthService {
  const LeagueStrengthService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  static const _topN = 15;
  static const _missingOvr = 50.0;

  /// Computes teamPower for a single team.
  double computeTeamPower(Team team) {
    final overalls = team.roster
        .map((p) => p.overall(balance))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    var sum = 0.0;
    for (var i = 0; i < _topN; i++) {
      sum += i < overalls.length ? overalls[i] : _missingOvr;
    }
    return double.parse((sum / _topN).toStringAsFixed(2));
  }

  /// Tier for a given rank position (1-indexed).
  /// Distribution: 1–3=elite, 4–9=contender, 10–18=pretender, 19–25=retool, 26–30=rebuild.
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
    final tiers = TeamStatus.values; // rebuild=0, retool=1, pretender=2, contender=3, elite=4
    final targetIdx = tiers.indexOf(target);
    final prevIdx = tiers.indexOf(previous);
    final clamped = targetIdx.clamp(prevIdx - 1, prevIdx + 1);
    return tiers[clamped];
  }

  /// Full recalculation of the strength table.
  ///
  /// [previousTable] is used for hysteresis. Pass `null` on first calculation
  /// (new career start) — hysteresis is skipped.
  ///
  /// [week] and [day] record when the calculation was performed.
  LeagueStrengthTable calculate(
    LeagueState league, {
    LeagueStrengthTable? previousTable,
    required int week,
    int day = 1,
  }) {
    // 1. Compute power for each team.
    final powers = <String, double>{};
    for (final team in league.teams) {
      powers[team.id] = computeTeamPower(team);
    }

    // 2. Sort by tie-break rules: teamPower desc → totalPayroll asc → teamId asc.
    final sorted = List<Team>.from(league.teams)
      ..sort((a, b) {
        final pa = powers[a.id] ?? 0.0;
        final pb = powers[b.id] ?? 0.0;
        if (pa != pb) return pb.compareTo(pa); // desc
        final payA = a.finance.totalPayroll;
        final payB = b.finance.totalPayroll;
        if (payA != payB) return payA.compareTo(payB); // asc (lower = better)
        return a.id.compareTo(b.id); // deterministic
      });

    // 3. Assign ranks and tiers with hysteresis.
    final entries = <TeamStrengthEntry>[];
    for (var i = 0; i < sorted.length; i++) {
      final team = sorted[i];
      final rank = i + 1;
      final rawTier = tierForRank(rank);
      final prevStatus = previousTable?.entryFor(team.id)?.teamStatus;
      final tier = applyHysteresis(rawTier, prevStatus);

      entries.add(TeamStrengthEntry(
        teamId: team.id,
        teamPower: powers[team.id] ?? 0.0,
        expectedRank: rank,
        teamStatus: tier,
      ));
    }

    return LeagueStrengthTable(
      entries: entries,
      lastCalculatedWeek: week,
      lastCalculatedDay: day,
    );
  }

  /// Whether the table should be recalculated on the given (week, day).
  ///
  /// Rules (`team_management.md`):
  /// - Game start (week=1, day=1 with no previous table)
  /// - 1st day of each "month" (every 4 weeks: week 5, 9, 13, 17, 21)
  ///   until trade deadline week (23)
  /// - Monday of trade deadline week (23, day 1)
  bool shouldRecalculate(int week, int day, LeagueStrengthTable? current) {
    if (current == null) return true; // first time
    if (week == current.lastCalculatedWeek &&
        day == current.lastCalculatedDay) {
      return false; // already done today
    }
    // Trade deadline Monday
    if (week == balance.calendar.tradeDeadlineWeek && day == 1) return true;
    // Monthly (every 4 weeks starting at week 5, only during regular season before deadline)
    if (day == 1 && week >= 5 && week < balance.calendar.tradeDeadlineWeek) {
      if ((week - 1) % 4 == 0) return true;
    }
    return false;
  }
}
