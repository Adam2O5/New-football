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
}
