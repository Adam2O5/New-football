@Tags(['integration'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';

import '../helpers/calendar/real_calendar_harness.dart';

void main() {
  test(
    'real controller no-save and incomplete player operations publish no calendar popup day',
    () async {
      final noSaveFixture = await newFixture(fixtureGame(seed: 7));
      try {
        noSaveFixture.controller.state = const AsyncValue.data(null);
        final noSaveFeedback = <CalendarDaySimulationFeedback>[];
        final noSaveResult = await noSaveFixture.controller.simulateToDate(
          1,
          2,
          observer: noSaveFeedback.add,
          pacer: fakePacer(),
        );
        expect(noSaveResult.stopReason, SimulationStopReason.noSave);
        expect(noSaveResult.daysSimulated, 0);
        expect(noSaveFeedback, isEmpty);
      } finally {
        await noSaveFixture.dispose();
      }

      final matchDays = matchDaysForWeek(1);
      final target = const CalendarService().advanceDay(
        1,
        matchDays.midweekDay,
      );
      final brokenBase = gameAtDate(
        fixtureGame(seed: 7),
        week: 1,
        day: matchDays.midweekDay,
        playerTeamId: 'team_europe_0',
      );
      final round = scheduleRoundForWeekSlot(1, 0);
      final playerMatch = brokenBase.leagueState.currentSeason.schedule
          .firstWhere(
            (match) =>
                match.round == round &&
                (match.homeTeamId == 'team_europe_0' ||
                    match.awayTeamId == 'team_europe_0'),
          );
      final broken = playerMatch.homeTeamId == 'team_europe_0'
          ? playerMatch.copyWith(awayTeamId: 'missing-auto-team')
          : playerMatch.copyWith(homeTeamId: 'missing-auto-team');
      final incompleteGame = brokenBase.copyWith(
        leagueState: brokenBase.leagueState.copyWith(
          currentSeason: brokenBase.leagueState.currentSeason.copyWith(
            schedule: [
              for (final match in brokenBase.leagueState.currentSeason.schedule)
                if (match.id == broken.id) broken else match,
            ],
          ),
        ),
      );
      final incompleteFixture = await newFixture(incompleteGame);
      try {
        final feedback = <CalendarDaySimulationFeedback>[];
        final result = await incompleteFixture.controller.simulateToDate(
          target.$1,
          target.$2,
          observer: feedback.add,
          pacer: fakePacer(),
        );
        expect(result.stopReason, SimulationStopReason.playerMatch);
        expect(result.daysSimulated, 0);
        expect(feedback, isEmpty);
        expect(
          (
            incompleteFixture.controller.save!.leagueState.currentWeek,
            incompleteFixture.controller.save!.leagueState.currentDay,
          ),
          (1, matchDays.midweekDay),
        );
      } finally {
        await incompleteFixture.dispose();
      }
    },
  );

  test(
    'real non-calendar day advance retains its one-step no-result behavior',
    () async {
      final game = gameAtDate(
        fixtureGame(seed: 17),
        week: 1,
        day: 1,
        playerTeamId: null,
      );
      final fixture = await newFixture(game);
      try {
        final result = await fixture.controller.advanceOneDay();
        expect(result, isNotNull);
        expect(result!.simulatedResults, isEmpty);
        expect(result.playerMatch, isNull);
        expect(
          (
            fixture.controller.save!.leagueState.currentWeek,
            fixture.controller.save!.leagueState.currentDay,
          ),
          (1, 2),
        );
        expect(
          fixture.controller.save!.leagueState.currentSeason.schedule.where(
            (match) => match.result != null,
          ),
          isEmpty,
        );
      } finally {
        await fixture.dispose();
      }
    },
  );
}
