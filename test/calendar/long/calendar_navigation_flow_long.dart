@Tags(['long', 'slow', 'ui', 'integration'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/screens/matchday_screen.dart';
import 'package:new_football/app/widgets/calendar_day_result_popup.dart';
import 'package:new_football/core/services/schedule_generator.dart';

import '../../helpers/calendar/real_calendar_harness.dart';

void main() {
  testWidgets(
    'real draft and scout stops navigate after the calendar host is cleaned up',
    (tester) async {
      final draftGame = draftEventGame();
      final draftSelectedDay = calendarDate(
        draftGame.leagueState.currentSeason.year,
        46,
        2,
      );
      final draftFixture = await newWidgetFixture(
        tester,
        draftGame,
        selectedDay: draftSelectedDay,
      );
      final draftHarness = calendarRouterApp(draftFixture.container);
      var draftRouterDisposed = false;
      var draftFixtureDisposed = false;

      Future<void> disposeDraftFixture() async {
        if (!draftRouterDisposed) {
          draftRouterDisposed = true;
          draftHarness.router.dispose();
        }
        if (!draftFixtureDisposed) {
          draftFixtureDisposed = true;
          await tester.runAsync(() => draftFixture.dispose());
        }
      }

      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await disposeDraftFixture();
      });

      await tester.pumpWidget(draftHarness.app);
      await tester.pumpAndSettle();
      await startCalendarBatchAndWait(tester, draftFixture);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      final dialogContext = tester.element(find.byType(AlertDialog));
      await tester.tap(
        find.widgetWithText(
          TextButton,
          MaterialLocalizations.of(dialogContext).okButtonLabel,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        draftHarness.destinations.map((uri) => uri.path),
        contains('/game/draft'),
      );
      expect(find.byType(CalendarDayResultPopup), findsNothing);
      expect(find.byKey(progressKey), findsNothing);
      expect(tester.takeException(), isNull);

      // Reuse the same widget tester with a fresh real container for scout
      // report, whose real completion hook runs before navigation.
      await tester.pumpWidget(const SizedBox.shrink());
      await disposeDraftFixture();

      final scoutGame = scoutEventGame();
      final scoutSelectedDay = calendarDate(
        scoutGame.leagueState.currentSeason.year,
        45,
        2,
      );
      final scoutFixture = await newWidgetFixture(
        tester,
        scoutGame,
        selectedDay: scoutSelectedDay,
      );
      final scoutHarness = calendarRouterApp(scoutFixture.container);
      var scoutRouterDisposed = false;
      var scoutFixtureDisposed = false;

      Future<void> disposeScoutFixture() async {
        if (!scoutRouterDisposed) {
          scoutRouterDisposed = true;
          scoutHarness.router.dispose();
        }
        if (!scoutFixtureDisposed) {
          scoutFixtureDisposed = true;
          await tester.runAsync(() => scoutFixture.dispose());
        }
      }

      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await disposeScoutFixture();
      });

      await tester.pumpWidget(scoutHarness.app);
      await tester.pumpAndSettle();
      await startCalendarBatchAndWait(tester, scoutFixture);
      await tester.pumpAndSettle();

      expect(
        scoutHarness.destinations.map((uri) => uri.path),
        contains('/game/prospects'),
      );
      expect(scoutHarness.destinations.single.queryParameters, {
        'watchlist': 'true',
        'combine': 'true',
      });
      expect(find.byType(CalendarDayResultPopup), findsNothing);
      expect(find.byKey(progressKey), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await disposeScoutFixture();
    },
  );

  testWidgets(
    'real HomeScreen simulate-to-event stays non-calendar and opens MatchdayScreen',
    (tester) async {
      final matchDays = matchDaysForWeek(1);
      final game = gameAtDate(
        fixtureGame(seed: 7),
        week: 1,
        day: matchDays.midweekDay,
        playerTeamId: 'team_europe_0',
      );
      final fixture = await newWidgetFixture(tester, game);
      final routerHarness = homeRouterApp(fixture.container);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        routerHarness.router.dispose();
        await fixture.dispose();
      });

      await tester.pumpWidget(routerHarness.app);
      await tester.pumpAndSettle();
      final simulateMatch = find.widgetWithIcon(
        FilledButton,
        Icons.sports_soccer,
      );
      expect(simulateMatch, findsOneWidget);

      final integrationController =
          fixture.controller as IntegrationGameController;
      await tester.runAsync(() async {
        await tester.tap(simulateMatch);
        await tester.pump();
        await integrationController.lastEventSimulation!;
      });
      await tester.pumpAndSettle();

      expect(find.byType(MatchdayScreen), findsOneWidget);
      expect(find.byType(CalendarDayResultPopup), findsNothing);
      expect(
        (
          fixture.controller.save!.leagueState.currentWeek,
          fixture.controller.save!.leagueState.currentDay,
        ),
        (1, matchDays.midweekDay),
      );
      final persistedPlayerMatch = fixture
          .controller
          .save!
          .leagueState
          .currentSeason
          .schedule
          .firstWhere(
            (match) =>
                match.homeTeamId == 'team_europe_0' ||
                match.awayTeamId == 'team_europe_0',
          );
      expect(persistedPlayerMatch.result, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
