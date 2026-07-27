import 'dart:math';

import 'package:new_football/core/models/match_models.dart';

/// Generates a double round-robin schedule for [teamIds].
///
/// For 30 teams: 58 rounds × 15 matches = 870 fixtures (each team plays 58).
/// Rounds are paired into weeks (2 rounds/week) by the calendar service.
class ScheduleGenerator {
  const ScheduleGenerator();

  List<ScheduledMatch> generateDoubleRoundRobin(List<String> teamIds) {
    if (teamIds.length < 2 || teamIds.length.isOdd) {
      throw ArgumentError(
        'Need an even number of teams (>=2), got ${teamIds.length}',
      );
    }

    final n = teamIds.length;
    final roundsPerHalf = n - 1;
    final firstHalf = _circleMethod(teamIds);

    final secondHalf = <ScheduledMatch>[];
    for (final match in firstHalf) {
      secondHalf.add(
        ScheduledMatch(
          id: 'match_${match.round + roundsPerHalf}_${match.awayTeamId}_${match.homeTeamId}',
          homeTeamId: match.awayTeamId,
          awayTeamId: match.homeTeamId,
          round: match.round + roundsPerHalf,
        ),
      );
    }

    return [...firstHalf, ...secondHalf];
  }

  /// Circle method: fix first team, rotate the rest.
  List<ScheduledMatch> _circleMethod(List<String> teamIds) {
    final n = teamIds.length;
    final rounds = n - 1;
    final half = n ~/ 2;
    final rotation = List<String>.from(teamIds);
    final matches = <ScheduledMatch>[];

    for (var round = 1; round <= rounds; round++) {
      for (var i = 0; i < half; i++) {
        final home = rotation[i];
        final away = rotation[n - 1 - i];
        // Alternate home/away for fairness across rounds.
        final swap = round.isEven;
        final homeId = swap ? away : home;
        final awayId = swap ? home : away;
        matches.add(
          ScheduledMatch(
            id: 'match_${round}_${homeId}_$awayId',
            homeTeamId: homeId,
            awayTeamId: awayId,
            round: round,
          ),
        );
      }
      // Rotate all except index 0.
      final last = rotation.removeLast();
      rotation.insert(1, last);
    }
    return matches;
  }
}

/// Maps calendar week (1–29) + slot (0=midweek, 1=weekend) → schedule round (1–58).
int scheduleRoundForWeekSlot(int week, int slot) {
  if (week < 1 || week > 29 || slot < 0 || slot > 1) {
    throw ArgumentError('Invalid week=$week slot=$slot');
  }
  return (week - 1) * 2 + slot + 1;
}

(int week, int slot) weekSlotForRound(int round) {
  if (round < 1 || round > 58) {
    throw ArgumentError('Invalid round=$round');
  }
  final zeroBased = round - 1;
  return ((zeroBased ~/ 2) + 1, zeroBased % 2);
}

/// Midweek matches: Wednesday (3) or Thursday (4). Weekend: Saturday (6) or Sunday (7).
int matchDayForSlot(int slot, {Random? random}) {
  final rng = random ?? Random();
  if (slot == 0) return rng.nextBool() ? 3 : 4;
  return rng.nextBool() ? 6 : 7;
}
