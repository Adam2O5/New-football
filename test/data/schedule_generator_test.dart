import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/services/schedule_generator.dart';

void main() {
  test('generates 58 rounds for 30 teams', () {
    final ids = List.generate(30, (index) => 'team-$index');
    final schedule = const ScheduleGenerator().generateDoubleRoundRobin(ids);
    expect(schedule.length, 870);
    expect(schedule.map((match) => match.round).toSet(), hasLength(58));
    for (final id in ids) {
      expect(
        schedule.where(
          (match) => match.homeTeamId == id || match.awayTeamId == id,
        ),
        hasLength(58),
      );
    }
  });
  test('reference match days and legal spacing for several seeds', () {
    const weeks = [1, 2, 15, 29, 32, 43];
    const reference = {
      0: [(3, 6), (3, 7), (3, 6), (4, 7), (4, 7), (3, 7)],
      1: [(3, 6), (3, 6), (4, 7), (4, 7), (4, 7), (4, 7)],
      123: [(3, 7), (4, 7), (4, 7), (3, 6), (3, 7), (4, 7)],
      987654: [(3, 6), (4, 7), (3, 7), (3, 6), (3, 6), (4, 7)],
    };
    for (final entry in reference.entries) {
      expect([
        for (final week in weeks)
          (
            matchDaysForWeek(week, seed: entry.key).midweekDay,
            matchDaysForWeek(week, seed: entry.key).weekendDay,
          ),
      ], entry.value);
    }
    for (final seed in [0, 1, 123, 987654]) {
      for (var week = 1; week <= 52; week++) {
        final days = matchDaysForWeek(week, seed: seed);
        expect([3, 4], contains(days.midweekDay));
        expect([6, 7], contains(days.weekendDay));
        expect(days.weekendDay - days.midweekDay, greaterThanOrEqualTo(3));
      }
    }
  });
}
