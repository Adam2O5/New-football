import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/engine/match_engine.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/schedule_generator.dart';

void main() {
  late final teams = SeedDataGenerator(
    random: null,
  ).generateLeague(year: 2026, seed: 42).teams;

  group('MatchEngine', () {
    test('is deterministic for the same seed', () {
      const engine = MatchEngine();
      final home = teams[0];
      final away = teams[1];
      final a = engine.simulateFull(home: home, away: away, rngSeed: 123);
      final b = engine.simulateFull(home: home, away: away, rngSeed: 123);
      expect(a.homeGoals, b.homeGoals);
      expect(a.awayGoals, b.awayGoals);
      expect(a.events.length, b.events.length);
    });

    test('simulateMinute advances to full time', () {
      const engine = MatchEngine();
      final live = engine.start(home: teams[2], away: teams[3], rngSeed: 7);
      if (!live.isFinished) {
        engine.runUntil(live, 90);
      }
      expect(live.state.minute, 90);
      expect(live.isFinished, isTrue);
      final result = live.toResult();
      expect(result.homeGoals, greaterThanOrEqualTo(0));
      expect(result.awayGoals, greaterThanOrEqualTo(0));
    });

    test('illegal roster yields walkover', () {
      const engine = MatchEngine();
      final tinyRoster = teams[0].roster.take(5).toList();
      final tiny = teams[0].copyWith(
        roster: tinyRoster,
        lineupPlayerIds: tinyRoster.map((p) => p.id).toList(),
        benchPlayerIds: const [],
      );
      final result = engine.simulateFull(home: tiny, away: teams[1], rngSeed: 1);
      expect(result.homeGoals, 0);
      expect(result.awayGoals, 3);
      expect(result.events.first.description, contains('Walkower'));
    });

    test('scoreline stays in sensible bounds over many sims', () {
      const engine = MatchEngine();
      var maxGoals = 0;
      for (var i = 0; i < 40; i++) {
        final r = engine.simulateFull(
          home: teams[i % 10],
          away: teams[(i + 11) % 20],
          rngSeed: i * 17,
        );
        maxGoals = [
          maxGoals,
          r.homeGoals,
          r.awayGoals,
        ].reduce((a, b) => a > b ? a : b);
      }
      expect(maxGoals, lessThanOrEqualTo(12));
    });
  });

  group('ScheduleGenerator', () {
    test('generates 58 rounds for 30 teams', () {
      final ids = teams.map((t) => t.id).toList();
      final schedule = const ScheduleGenerator().generateDoubleRoundRobin(ids);
      expect(schedule.length, 870); // 58 * 15
      final rounds = schedule.map((m) => m.round).toSet();
      expect(rounds.length, 58);
      for (final id in ids) {
        final played = schedule
            .where((m) => m.homeTeamId == id || m.awayTeamId == id)
            .length;
        expect(played, 58);
      }
    });
  });
}
