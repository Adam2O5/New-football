import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/data/save_repository.dart';

import 'support/game_fixtures.dart';

void main() {
  test(
    'save the day before a fixture: load reaches the same pending match without skipping it',
    () async {
      const calendar = CalendarService();
      final matchDay = matchDaysForWeek(1).midweekDay;
      final initial = seededLeague();
      final fixture = ScheduledMatch(
        id: 'replay-fixture',
        homeTeamId: initial.playerTeamId!,
        awayTeamId: initial.teams[1].id,
        round: 1,
      );
      final league = initial.copyWith(
        currentDay: matchDay - 1,
        teams: initial.teams.map((t) => t.copyWith(ai: null)).toList(),
        currentSeason: initial.currentSeason.copyWith(schedule: [fixture]),
      );
      final directory = await Directory.systemTemp.createTemp(
        'football-before-match-',
      );
      try {
        final repository = SaveRepository(overrideDirectory: directory);
        await repository.save(saveForLeague(league));
        final loaded = (await repository.load('stage-zero')).leagueState;
        for (final input in [league, loaded]) {
          final days = DaySimulator();
          final before = days.simulateDay(
            input,
            saveSeed: fixtureSeed,
            resolveContractMarket: false,
          );
          expect(before.league.currentDay, matchDay);
          expect(before.league.currentSeason.schedule.single.result, isNull);
          expect(
            calendar.isActualMatchDay(1, before.league.currentDay),
            isTrue,
          );
          final paused = days.simulateDay(
            before.league,
            saveSeed: fixtureSeed,
            resolveContractMarket: false,
          );
          expect(paused.playerMatch?.id, fixture.id);
          expect(paused.league.currentDay, matchDay);
          expect(paused.league.currentSeason.schedule.single.result, isNull);
        }
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
}
