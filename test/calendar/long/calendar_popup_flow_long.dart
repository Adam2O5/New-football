@Tags(['long', 'slow', 'ui', 'integration'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/widgets/calendar_day_result_popup.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';

import '../../helpers/calendar/real_calendar_harness.dart';

void main() {
  testWidgets(
    'real calendar preserves full ordered feedback and the player-result presentation',
    (tester) async {
      final target = targetAfterWeekOneWeekend();
      final base = gameAtDate(
        fixtureGame(seed: 7),
        week: 1,
        day: 1,
        playerTeamId: 'team_europe_0',
      );
      final baseline = (await tester.runAsync(
        () => runBaseline(base, target),
      ))!;
      final selectedDay = calendarDate(
        base.leagueState.currentSeason.year,
        target.$1,
        target.$2,
      );
      final fixture = (await tester.runAsync(
        () => newFixture(base, selectedDay: selectedDay),
      ))!;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await fixture.dispose();
      });

      await tester.pumpWidget(app(fixture.container, const CalendarScreen()));
      await tester.pumpAndSettle();

      final integrationController =
          fixture.controller as IntegrationGameController;
      final trace = (await tester.runAsync(() async {
        await tapCalendarSimulation(tester);
        return pumpCalendarUntilSimulationCompletes(
          tester,
          integrationController.lastSimulation!,
        );
      }))!;
      // The controller future completes in real async time; this pump lets
      // CalendarScreen process its final clear-progress/snackbar continuation.
      await tester.pump();
      await tester.pumpAndSettle();

      expect(trace.snackbarOverlappedPopup, isFalse);
      expect(trace.feedback.map((item) => item.completedDateKey), [
        '1:${matchDaysForWeek(1).midweekDay}',
        '1:${matchDaysForWeek(1).weekendDay}',
      ]);
      expect(
        integrationController.publishedFeedback
            .where((item) => item.results.isNotEmpty)
            .map((item) => item.completedDateKey),
        orderedEquals([
          '1:${matchDaysForWeek(1).midweekDay}',
          '1:${matchDaysForWeek(1).weekendDay}',
        ]),
      );
      expect(
        trace.feedback.map((item) => item.identityKey).toSet(),
        hasLength(trace.feedback.length),
      );

      final persisted = (await tester.runAsync(
        () => fixture.repository.load(fixture.game.meta.id),
      ))!;
      final popupRows = trace.feedback
          .expand((item) => item.results)
          .map((row) => row.matchId)
          .toList();
      final persistedRows = persisted.leagueState.currentSeason.schedule
          .where((match) => match.result != null)
          .map((match) => match.id)
          .toList();
      expect(popupRows, orderedEquals(persistedRows));
      expect(popupRows.toSet(), hasLength(popupRows.length));
      expect(
        trace.feedback,
        everyElement(isA<CalendarDaySimulationFeedback>()),
      );

      // The target is the first date after the second matchday. Reaching it
      // exactly proves that the controller did not simulate an extra day.
      expect((
        persisted.leagueState.currentWeek,
        persisted.leagueState.currentDay,
      ), target);
      expect(snapshotSchedule(persisted), baseline.scheduleSnapshot);
      expect(snapshotStandings(persisted), baseline.standingsSnapshot);
      expect(find.textContaining('Cel osiągnięty'), findsOneWidget);
      expect(find.byType(CalendarDayResultPopup), findsNothing);
      expect(find.byKey(progressKey), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'real calendar cancellation closes the completed popup and resumes without replay',
    (tester) async {
      final matchDays = matchDaysForWeek(1);
      final target = targetAfterWeekOneWeekend();
      final base = gameAtDate(
        fixtureGame(seed: 7),
        week: 1,
        day: matchDays.midweekDay,
        playerTeamId: 'team_europe_0',
      );
      final selectedDay = calendarDate(
        base.leagueState.currentSeason.year,
        target.$1,
        target.$2,
      );
      final fixture = await newWidgetFixture(
        tester,
        base,
        selectedDay: selectedDay,
        pauseAfterFirstCalendarDay: true,
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await fixture.dispose();
      });

      await tester.pumpWidget(app(fixture.container, const CalendarScreen()));
      await tester.pumpAndSettle();

      final firstFeedback = await startCalendarBatchUntilPopup(tester);
      expect(firstFeedback.completedDateKey, '1:${matchDays.midweekDay}');
      final firstMatchIds = firstFeedback.results
          .map((row) => row.matchId)
          .toSet();
      expect(firstMatchIds, isNotEmpty);

      await tester.tap(find.byKey(cancelKey));
      await tester.pump();
      final cancelledTrace = (await tester.runAsync(
        () => pumpCalendarUntil(
          tester,
          terminal: (progressVisible, popupVisible, snackbarVisible) =>
              !progressVisible && !popupVisible && snackbarVisible,
        ),
      ))!;
      await tester.pumpAndSettle();
      expect(cancelledTrace.snackbarOverlappedPopup, isFalse);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Symulacja przerwana'), findsOneWidget);
      expect(find.byType(CalendarDayResultPopup), findsNothing);

      // The cancelled run's final action was already asserted above. Dismiss
      // that completed action before starting a new run so the resumed popup
      // is measured against a clean route-owned presentation state.
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .hideCurrentSnackBar();
      await tester.pump();

      final afterCancel = (await tester.runAsync(
        () => fixture.repository.load(fixture.game.meta.id),
      ))!;
      final persistedAfterCancel = afterCancel.leagueState;
      expect((
        persistedAfterCancel.currentWeek,
        persistedAfterCancel.currentDay,
      ), const CalendarService().advanceDay(1, matchDays.midweekDay));
      expect(
        persistedAfterCancel.currentSeason.schedule.where(
          (match) => match.result != null,
        ),
        hasLength(firstMatchIds.length),
      );

      // The same screen is reusable after the cancelled run. Its selected
      // target stays in place, while the controller reads the persisted date
      // and starts at the first unfinished day.
      final resumedTrace = (await tester.runAsync(() async {
        await tapCalendarSimulation(tester);
        return pumpCalendarUntil(
          tester,
          terminal: (progressVisible, popupVisible, snackbarVisible) =>
              !progressVisible && !popupVisible && snackbarVisible,
        );
      }))!;
      await tester.pumpAndSettle();
      final resumedRows = resumedTrace.feedback
          .expand((item) => item.results)
          .map((row) => row.matchId)
          .toSet();
      expect(resumedTrace.snackbarOverlappedPopup, isFalse);
      expect(resumedRows.intersection(firstMatchIds), isEmpty);
      expect(
        resumedTrace.feedback.every(
          (feedback) =>
              feedback.week > 1 || feedback.day > matchDays.midweekDay,
        ),
        isTrue,
      );

      final finalSave = (await tester.runAsync(
        () => fixture.repository.load(fixture.game.meta.id),
      ))!;
      expect((
        finalSave.leagueState.currentWeek,
        finalSave.leagueState.currentDay,
      ), target);
      final allResultIds = finalSave.leagueState.currentSeason.schedule
          .where((match) => match.result != null)
          .map((match) => match.id)
          .toSet();
      expect(allResultIds.length, firstMatchIds.length + resumedRows.length);
      expect(find.byType(CalendarDayResultPopup), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'urgent calendar stop switches to Inbox only after the real popup closes',
    (tester) async {
      final matchDays = matchDaysForWeek(1);
      final target = const CalendarService().advanceDay(
        1,
        matchDays.midweekDay,
      );
      var game = gameAtDate(
        fixtureGame(seed: 7),
        week: 1,
        day: matchDays.midweekDay,
        playerTeamId: 'team_europe_0',
      );
      game = withScheduledUrgent(game, week: target.$1, day: target.$2);
      final selectedDay = calendarDate(
        game.leagueState.currentSeason.year,
        target.$1,
        target.$2,
      );
      final fixture = await newWidgetFixture(
        tester,
        game,
        selectedDay: selectedDay,
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await fixture.dispose();
      });

      await tester.pumpWidget(
        app(fixture.container, const ShellScreen(initialTab: 1)),
      );
      await tester.pumpAndSettle();

      final feedback = await startCalendarBatchUntilPopup(tester);
      expect(feedback.results, isNotEmpty);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      expect(find.byType(CalendarDayResultPopup), findsOneWidget);

      final trace = (await tester.runAsync(
        () => pumpCalendarUntil(
          tester,
          terminal: (progressVisible, popupVisible, snackbarVisible) =>
              !progressVisible && !popupVisible && snackbarVisible,
        ),
      ))!;
      expect(trace.snackbarOverlappedPopup, isFalse);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(CalendarDayResultPopup), findsNothing);
      expect(fixture.container.read(shellTabIndexProvider), 5);
      await tester.pumpAndSettle();
      expect((
        fixture.controller.save!.leagueState.currentWeek,
        fixture.controller.save!.leagueState.currentDay,
      ), target);
      expect(tester.takeException(), isNull);
    },
  );
}
