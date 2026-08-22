@Tags(['ui', 'integration', 'slow'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/screens/matchday_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/app/widgets/calendar_day_result_popup.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

const _progressKey = ValueKey<String>('calendar-batch-progress-overlay');
const _cancelKey = ValueKey<String>('calendar-batch-cancel');

void main() {
  testWidgets(
    'real calendar flow shows complete ordered popups and preserves the baseline',
    (tester) async {
      final target = _targetAfterWeekOneWeekend();
      final base = _gameAtDate(
        _fixtureGame(seed: 7),
        week: 1,
        day: 1,
        playerTeamId: null,
      );
      final baseline = (await tester.runAsync(
        () => _runBaseline(base, target),
      ))!;
      final selectedDay = _calendarDate(
        base.leagueState.currentSeason.year,
        target.$1,
        target.$2,
      );
      final fixture = (await tester.runAsync(
        () => _newFixture(base, selectedDay: selectedDay),
      ))!;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await fixture.dispose();
      });

      await tester.pumpWidget(_app(fixture.container, const CalendarScreen()));
      await tester.pumpAndSettle();

      final integrationController =
          fixture.controller as _IntegrationGameController;
      final trace = (await tester.runAsync(() async {
        await _tapCalendarSimulation(tester);
        return _pumpCalendarUntilSimulationCompletes(
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
      expect(_scheduleSnapshot(persisted), baseline.scheduleSnapshot);
      expect(_standingsSnapshot(persisted), baseline.standingsSnapshot);
      expect(find.textContaining('Cel osiągnięty'), findsOneWidget);
      expect(find.byType(CalendarDayResultPopup), findsNothing);
      expect(find.byKey(_progressKey), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'real calendar cancellation closes the completed popup and resumes without replay',
    (tester) async {
      final matchDays = matchDaysForWeek(1);
      final target = _targetAfterWeekOneWeekend();
      final base = _gameAtDate(
        _fixtureGame(seed: 7),
        week: 1,
        day: matchDays.midweekDay,
        playerTeamId: null,
      );
      final selectedDay = _calendarDate(
        base.leagueState.currentSeason.year,
        target.$1,
        target.$2,
      );
      final fixture = await _newWidgetFixture(
        tester,
        base,
        selectedDay: selectedDay,
        pauseAfterFirstCalendarDay: true,
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await fixture.dispose();
      });

      await tester.pumpWidget(_app(fixture.container, const CalendarScreen()));
      await tester.pumpAndSettle();

      final firstFeedback = await _startCalendarBatchUntilPopup(tester);
      expect(firstFeedback.completedDateKey, '1:${matchDays.midweekDay}');
      final firstMatchIds = firstFeedback.results
          .map((row) => row.matchId)
          .toSet();
      expect(firstMatchIds, isNotEmpty);

      await tester.tap(find.byKey(_cancelKey));
      await tester.pump();
      final cancelledTrace = (await tester.runAsync(
        () => _pumpCalendarUntil(
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
        await _tapCalendarSimulation(tester);
        return _pumpCalendarUntil(
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
      var game = _gameAtDate(
        _fixtureGame(seed: 7),
        week: 1,
        day: matchDays.midweekDay,
        playerTeamId: 'team_europe_0',
      );
      game = _withScheduledUrgent(game, week: target.$1, day: target.$2);
      final selectedDay = _calendarDate(
        game.leagueState.currentSeason.year,
        target.$1,
        target.$2,
      );
      final fixture = await _newWidgetFixture(
        tester,
        game,
        selectedDay: selectedDay,
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await fixture.dispose();
      });

      await tester.pumpWidget(
        _app(fixture.container, const ShellScreen(initialTab: 1)),
      );
      await tester.pumpAndSettle();

      final feedback = await _startCalendarBatchUntilPopup(tester);
      expect(feedback.results, isNotEmpty);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      expect(find.byType(CalendarDayResultPopup), findsOneWidget);

      final trace = (await tester.runAsync(
        () => _pumpCalendarUntil(
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

  testWidgets(
    'real draft and scout stops navigate after the calendar host is cleaned up',
    (tester) async {
      final draftGame = _draftEventGame();
      final draftSelectedDay = _calendarDate(
        draftGame.leagueState.currentSeason.year,
        46,
        2,
      );
      final draftFixture = await _newWidgetFixture(
        tester,
        draftGame,
        selectedDay: draftSelectedDay,
      );
      final draftHarness = _calendarRouterApp(draftFixture.container);
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
      await _startCalendarBatchAndWait(tester, draftFixture);
      await tester.pumpAndSettle();

      expect(
        draftHarness.destinations.map((uri) => uri.path),
        contains('/game/draft'),
      );
      expect(find.byType(CalendarDayResultPopup), findsNothing);
      expect(find.byKey(_progressKey), findsNothing);
      expect(tester.takeException(), isNull);

      // Reuse the same widget tester with a fresh real container for scout
      // report, whose real completion hook runs before navigation.
      await tester.pumpWidget(const SizedBox.shrink());
      await disposeDraftFixture();

      final scoutGame = _scoutEventGame();
      final scoutSelectedDay = _calendarDate(
        scoutGame.leagueState.currentSeason.year,
        45,
        2,
      );
      final scoutFixture = await _newWidgetFixture(
        tester,
        scoutGame,
        selectedDay: scoutSelectedDay,
      );
      final scoutHarness = _calendarRouterApp(scoutFixture.container);
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
      await _startCalendarBatchAndWait(tester, scoutFixture);
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
      expect(find.byKey(_progressKey), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await disposeScoutFixture();
    },
  );

  test(
    'real controller no-save and incomplete player operations publish no calendar popup day',
    () async {
      final noSaveFixture = await _newFixture(_fixtureGame(seed: 7));
      try {
        noSaveFixture.controller.state = const AsyncValue.data(null);
        final noSaveFeedback = <CalendarDaySimulationFeedback>[];
        final noSaveResult = await noSaveFixture.controller.simulateToDate(
          1,
          2,
          observer: noSaveFeedback.add,
          pacer: _fakePacer(),
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
      final brokenBase = _gameAtDate(
        _fixtureGame(seed: 7),
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
      final incompleteFixture = await _newFixture(incompleteGame);
      try {
        final feedback = <CalendarDaySimulationFeedback>[];
        final result = await incompleteFixture.controller.simulateToDate(
          target.$1,
          target.$2,
          observer: feedback.add,
          pacer: _fakePacer(),
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

  testWidgets(
    'real HomeScreen simulate-to-event stays non-calendar and opens MatchdayScreen',
    (tester) async {
      final matchDays = matchDaysForWeek(1);
      final game = _gameAtDate(
        _fixtureGame(seed: 7),
        week: 1,
        day: matchDays.midweekDay,
        playerTeamId: 'team_europe_0',
      );
      final fixture = await _newWidgetFixture(tester, game);
      final routerHarness = _homeRouterApp(fixture.container);
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
          fixture.controller as _IntegrationGameController;
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

  test(
    'real non-calendar day advance retains its one-step no-result behavior',
    () async {
      final game = _gameAtDate(
        _fixtureGame(seed: 17),
        week: 1,
        day: 1,
        playerTeamId: null,
      );
      final fixture = await _newFixture(game);
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

Future<_RealFixture> _newWidgetFixture(
  WidgetTester tester,
  GameSave game, {
  DateTime? selectedDay,
  bool pauseAfterFirstCalendarDay = false,
}) async {
  return (await tester.runAsync(
    () => _newFixture(
      game,
      selectedDay: selectedDay,
      pauseAfterFirstCalendarDay: pauseAfterFirstCalendarDay,
    ),
  ))!;
}

Future<void> _startCalendarBatchAndWait(
  WidgetTester tester,
  _RealFixture fixture,
) async {
  final controller = fixture.controller as _IntegrationGameController;
  await tester.runAsync(() async {
    await _tapCalendarSimulation(tester);
    await controller.lastSimulation!;
    for (
      var tick = 0;
      tick < 100 && controller.lastCalendarEvent == null;
      tick++
    ) {
      await Future<void>.delayed(Duration.zero);
    }
    final event = controller.lastCalendarEvent;
    if (event != null) await event;
  });
  await tester.pump();
}

Future<CalendarDaySimulationFeedback> _startCalendarBatchUntilPopup(
  WidgetTester tester,
) async {
  return (await tester.runAsync(() async {
    await _tapCalendarSimulation(tester);
    return _pumpUntilPopup(tester);
  }))!;
}

Future<void> _tapCalendarSimulation(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Do wybranej daty');
  await tester.scrollUntilVisible(
    button,
    400,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pump();
}

Future<CalendarDaySimulationFeedback> _pumpUntilPopup(
  WidgetTester tester, {
  int maxTicks = 400,
}) async {
  for (var tick = 0; tick < maxTicks; tick++) {
    await tester.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(Duration.zero);
    final finder = find.byType(CalendarDayResultPopup);
    if (finder.evaluate().isNotEmpty) {
      return tester.widget<CalendarDayResultPopup>(finder.first).feedback;
    }
  }
  throw TestFailure('A real calendar result popup did not appear in time.');
}

Future<_CalendarTrace> _pumpCalendarUntilSimulationCompletes(
  WidgetTester tester,
  Future<BatchSimulationResult> simulation,
) async {
  final feedbackByIdentity = <String, CalendarDaySimulationFeedback>{};
  var snackbarOverlappedPopup = false;
  var completed = false;
  simulation.then((_) => completed = true);

  for (var tick = 0; tick < 3000 && !completed; tick++) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(Duration.zero);
    final popupFinder = find.byType(CalendarDayResultPopup);
    final popupVisible = popupFinder.evaluate().isNotEmpty;
    if (popupVisible) {
      final popup = tester.widget<CalendarDayResultPopup>(popupFinder.first);
      feedbackByIdentity.putIfAbsent(
        popup.feedback.identityKey,
        () => popup.feedback,
      );
    }
    final snackbarVisible = find.byType(SnackBar).evaluate().isNotEmpty;
    if (popupVisible && snackbarVisible) snackbarOverlappedPopup = true;
  }

  if (!completed) {
    throw TestFailure(
      'The real calendar simulation did not complete. '
      'progress=${find.byKey(_progressKey).evaluate().isNotEmpty}, '
      'popup=${find.byType(CalendarDayResultPopup).evaluate().isNotEmpty}, '
      'snackbar=${find.byType(SnackBar).evaluate().isNotEmpty}',
    );
  }

  return _CalendarTrace(
    feedback: feedbackByIdentity.values.toList(),
    snackbarOverlappedPopup: snackbarOverlappedPopup,
  );
}

Future<_CalendarTrace> _pumpCalendarUntil(
  WidgetTester tester, {
  required bool Function(
    bool progressVisible,
    bool popupVisible,
    bool snackbarVisible,
  )
  terminal,
  int maxTicks = 240,
}) async {
  final feedbackByIdentity = <String, CalendarDaySimulationFeedback>{};
  var snackbarOverlappedPopup = false;

  for (var tick = 0; tick < maxTicks; tick++) {
    await tester.pump(const Duration(milliseconds: 100));
    // Let real repository IO and controller futures progress while the
    // widget tree is pumped.
    await Future<void>.delayed(Duration.zero);
    final popupFinder = find.byType(CalendarDayResultPopup);
    final popupVisible = popupFinder.evaluate().isNotEmpty;
    if (popupVisible) {
      final popup = tester.widget<CalendarDayResultPopup>(popupFinder.first);
      feedbackByIdentity.putIfAbsent(
        popup.feedback.identityKey,
        () => popup.feedback,
      );
    }
    final progressVisible = find.byKey(_progressKey).evaluate().isNotEmpty;
    final snackbarVisible = find.byType(SnackBar).evaluate().isNotEmpty;
    if (popupVisible && snackbarVisible) snackbarOverlappedPopup = true;
    if (terminal(progressVisible, popupVisible, snackbarVisible)) {
      return _CalendarTrace(
        feedback: feedbackByIdentity.values.toList(),
        snackbarOverlappedPopup: snackbarOverlappedPopup,
      );
    }
  }
  throw TestFailure(
    'The real calendar batch did not reach its terminal UI state. '
    'progress=${find.byKey(_progressKey).evaluate().isNotEmpty}, '
    'popup=${find.byType(CalendarDayResultPopup).evaluate().isNotEmpty}, '
    'snackbar=${find.byType(SnackBar).evaluate().isNotEmpty}',
  );
}

final class _CalendarTrace {
  const _CalendarTrace({
    required this.feedback,
    required this.snackbarOverlappedPopup,
  });

  final List<CalendarDaySimulationFeedback> feedback;
  final bool snackbarOverlappedPopup;
}

final class _RealFixture {
  _RealFixture({
    required this.directory,
    required this.repository,
    required this.container,
    required this.controller,
    required this.game,
  });

  final Directory directory;
  final SaveRepository repository;
  final ProviderContainer container;
  final GameController controller;
  final GameSave game;
  var _disposed = false;

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    container.dispose();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

final class _IntegrationGameController extends GameController {
  _IntegrationGameController(
    super.ref,
    GameSave game, {
    bool pauseAfterFirstCalendarDay = false,
  }) : _pauseAfterFirstCalendarDay = pauseAfterFirstCalendarDay {
    state = AsyncValue.data(game);
  }

  Future<BatchSimulationResult>? lastSimulation;
  Future<BatchSimulationResult>? lastEventSimulation;
  Future<void>? lastCalendarEvent;
  final publishedFeedback = <CalendarDaySimulationFeedback>[];
  final bool _pauseAfterFirstCalendarDay;
  final Completer<void> _releaseFirstCalendarDay = Completer<void>();
  var _firstCalendarDayPauseConsumed = false;

  @override
  Future<void> runEventAtCurrentDay(CalendarEventId eventId) {
    final future = super.runEventAtCurrentDay(eventId);
    lastCalendarEvent = future;
    return future;
  }

  @override
  Future<BatchSimulationResult> simulateToEvent() {
    final future = super.simulateToEvent();
    lastEventSimulation = future;
    return future;
  }

  @override
  void cancelSimulation() {
    super.cancelSimulation();
    if (!_releaseFirstCalendarDay.isCompleted) {
      _releaseFirstCalendarDay.complete();
    }
  }

  @override
  Future<BatchSimulationResult> simulateToDate(
    int targetWeek,
    int targetDay, {
    CalendarDaySimulationObserver? observer,
    CalendarSimulationPacer? pacer,
  }) {
    // Keep the real controller/domain path while making the presentation
    // cadence deterministic for a testWidgets fake-async environment.
    final wrappedObserver = observer == null
        ? null
        : (CalendarDaySimulationFeedback feedback) {
            publishedFeedback.add(feedback);
            observer(feedback);
          };
    final future = super.simulateToDate(
      targetWeek,
      targetDay,
      observer: wrappedObserver,
      pacer: _testCalendarPacer(),
    );
    lastSimulation = future;
    return future;
  }

  CalendarSimulationPacer _testCalendarPacer() {
    var elapsed = Duration.zero;
    return CalendarSimulationPacer(
      elapsedSource: () => elapsed,
      delay: (duration) async {
        elapsed += duration;
        if (_pauseAfterFirstCalendarDay && !_firstCalendarDayPauseConsumed) {
          _firstCalendarDayPauseConsumed = true;
          await _releaseFirstCalendarDay.future;
        }
        await Future<void>.delayed(const Duration(milliseconds: 1));
      },
    );
  }
}

Future<_RealFixture> _newFixture(
  GameSave game, {
  DateTime? selectedDay,
  bool pauseAfterFirstCalendarDay = false,
}) async {
  final directory = await Directory.systemTemp.createTemp('nf_it_');
  final repository = SaveRepository(overrideDirectory: directory);
  await repository.save(game);
  final overrides = [
    saveRepositoryProvider.overrideWithValue(repository),
    gameControllerProvider.overrideWith(
      (ref) => _IntegrationGameController(
        ref,
        game,
        pauseAfterFirstCalendarDay: pauseAfterFirstCalendarDay,
      ),
    ),
  ];
  if (selectedDay != null) {
    overrides.add(
      calendarSelectedDayProvider.overrideWith((ref) => selectedDay),
    );
  }
  final container = ProviderContainer(overrides: overrides);
  final controller = container.read(gameControllerProvider.notifier);
  return _RealFixture(
    directory: directory,
    repository: repository,
    container: container,
    controller: controller,
    game: game,
  );
}

final class _BaselineOutcome {
  const _BaselineOutcome({required this.save, required this.result});

  final GameSave save;
  final BatchSimulationResult result;

  String get scheduleSnapshot => _scheduleSnapshot(save);
  String get standingsSnapshot => _standingsSnapshot(save);
}

Future<_BaselineOutcome> _runBaseline(GameSave game, (int, int) target) async {
  final fixture = await _newFixture(game);
  try {
    final result = await fixture.controller.simulateToDate(
      target.$1,
      target.$2,
    );
    final persisted = await fixture.repository.load(game.meta.id);
    return _BaselineOutcome(save: persisted, result: result);
  } finally {
    await fixture.dispose();
  }
}

CalendarSimulationPacer _fakePacer({bool yieldToEventLoop = false}) {
  var elapsed = Duration.zero;
  return CalendarSimulationPacer(
    elapsedSource: () => elapsed,
    delay: (duration) async {
      elapsed += duration;
      if (yieldToEventLoop) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    },
  );
}

GameSave _fixtureGame({required int seed}) {
  return GameFactory().create(
    NewGameRequest(
      saveName: 'Calendar integration $seed',
      playerTeamId: 'team_europe_0',
      seed: seed,
    ),
  );
}

GameSave _gameAtDate(
  GameSave game, {
  required int week,
  required int day,
  required String? playerTeamId,
}) {
  return game.copyWith(
    leagueState: game.leagueState.copyWith(
      currentWeek: week,
      currentDay: day,
      currentHour: null,
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
      playerTeamId: playerTeamId,
    ),
  );
}

GameSave _withScheduledUrgent(
  GameSave game, {
  required int week,
  required int day,
}) {
  final message = GameMessage(
    id: 'calendar-integration-urgent-$week-$day',
    type: MessageType.tradeWindowEvent,
    priority: MessagePriority.urgent,
    seasonYear: game.leagueState.currentSeason.year,
    week: week,
    day: day,
    titleKey: 'calendar.integration.urgent.title',
    bodyKey: 'calendar.integration.urgent.body',
  );
  return game.copyWith(
    leagueState: game.leagueState.copyWith(
      inbox: game.leagueState.inbox.scheduleMessage(message),
    ),
  );
}

GameSave _draftEventGame() {
  final game = _fixtureGame(seed: 7);
  final league = game.leagueState;
  return game.copyWith(
    leagueState: league.copyWith(
      currentWeek: 46,
      currentDay: 1,
      currentHour: null,
      currentSeason: league.currentSeason.copyWith(
        draftState: DraftState(
          year: league.currentSeason.year,
          order: [
            DraftPick(
              id: 'calendar-integration-draft-pick',
              year: league.currentSeason.year,
              round: 1,
              pickNumber: 1,
              teamId: 'team_europe_0',
              originalTeamId: 'team_europe_0',
            ),
          ],
          draftClass: DraftClass(year: league.currentSeason.year),
        ),
      ),
    ),
  );
}

GameSave _scoutEventGame() {
  final game = _fixtureGame(seed: 7);
  final league = game.leagueState;
  return game.copyWith(
    leagueState: league.copyWith(
      currentWeek: 45,
      currentDay: 1,
      currentHour: null,
      currentSeason: league.currentSeason.copyWith(
        draftState: DraftState(
          year: league.currentSeason.year + 1,
          draftClass: DraftClass(year: league.currentSeason.year + 1),
        ),
        scoutReportDone: false,
        combineDone: false,
      ),
    ),
  );
}

(int, int) _targetAfterWeekOneWeekend() {
  final matchDays = matchDaysForWeek(1);
  return const CalendarService().advanceDay(1, matchDays.weekendDay);
}

DateTime _calendarDate(int seasonYear, int week, int day) {
  var start = DateTime(seasonYear, 8, 1);
  while (start.weekday != DateTime.monday) {
    start = start.add(const Duration(days: 1));
  }
  while (start.month != 8 || start.add(const Duration(days: 6)).month != 8) {
    start = start.add(const Duration(days: 7));
  }
  return start.add(Duration(days: (week - 1) * 7 + day - 1));
}

String _scheduleSnapshot(GameSave save) => save
    .leagueState
    .currentSeason
    .schedule
    .map((match) {
      final result = match.result;
      return [
        match.id,
        match.homeTeamId,
        match.awayTeamId,
        match.round,
        result == null ? 'unplayed' : '${result.homeGoals}:${result.awayGoals}',
        result?.status.name ?? '',
        result?.reasonCode ?? '',
      ].join('|');
    })
    .join('\n');

String _standingsSnapshot(GameSave save) => save
    .leagueState
    .currentSeason
    .standings
    .expand(
      (conference) => conference.standings.map(
        (standing) => [
          conference.conference.name,
          standing.teamId,
          standing.wins,
          standing.losses,
          standing.draws,
          standing.goalsFor,
          standing.goalsAgainst,
          standing.conferenceRank,
        ].join('|'),
      ),
    )
    .join('\n');

Widget _app(ProviderContainer container, Widget home) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: const Locale('pl'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

({Widget app, GoRouter router, List<Uri> destinations}) _calendarRouterApp(
  ProviderContainer container,
) {
  final destinations = <Uri>[];
  final router = GoRouter(
    initialLocation: '/calendar',
    routes: [
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/game/draft',
        builder: (context, state) {
          destinations.add(state.uri);
          return const Scaffold(body: Text('draft destination'));
        },
      ),
      GoRoute(
        path: '/game/prospects',
        builder: (context, state) {
          destinations.add(state.uri);
          return const Scaffold(body: Text('prospects destination'));
        },
      ),
    ],
  );
  return (
    app: _routerMaterialApp(container, router),
    router: router,
    destinations: destinations,
  );
}

({Widget app, GoRouter router}) _homeRouterApp(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/game/match',
        builder: (context, state) {
          final match = state.extra;
          if (match is ScheduledMatch) {
            return MatchdayScreen(match: match);
          }
          return const Scaffold(body: Text('missing match'));
        },
      ),
    ],
  );
  return (app: _routerMaterialApp(container, router), router: router);
}

Widget _routerMaterialApp(ProviderContainer container, GoRouter router) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      locale: const Locale('pl'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}
