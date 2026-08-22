@Tags(['ui'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/app/widgets/calendar_day_result_popup.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('owns progress and cancellation in the route state', (
    tester,
  ) async {
    late _FakeCalendarController controller;
    await tester.pumpWidget(
      _calendarApp(
        selectedDay: _futureCalendarDay,
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    await _tapSimulate(tester);
    await tester.pump();

    expect(find.byKey(_progressKey), findsOneWidget);
    expect(find.byKey(_cancelKey), findsOneWidget);
    expect(controller.runs, hasLength(1));
    expect(controller.runs.single.observer, isNotNull);
    expect(controller.runs.single.pacer, isNotNull);

    await tester.tap(find.byKey(_cancelKey));
    expect(controller.runs.single.cancelled, isTrue);
    controller.runs.single.complete(
      const BatchSimulationResult(
        stopReason: SimulationStopReason.cancelled,
        daysSimulated: 0,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(_progressKey), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('Symulacja przerwana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'clears result feedback before the final reached-target snackbar',
    (tester) async {
      late _FakeCalendarController controller;
      await tester.pumpWidget(
        _calendarApp(
          selectedDay: _futureCalendarDay,
          onController: (value) => controller = value,
        ),
      );
      await tester.pumpAndSettle();

      await _tapSimulate(tester);
      await tester.pump();
      final run = controller.runs.single;
      run.emit(_feedback(runId: 0, sequence: 0));
      await tester.pump();

      expect(find.byType(CalendarDayResultPopup), findsOneWidget);
      expect(find.byKey(_feedbackHostKey), findsOneWidget);

      run.emit(
        CalendarDaySimulationFeedback(
          runId: 0,
          sequence: 1,
          week: 1,
          day: 3,
          results: const [],
        ),
      );
      await tester.pump();
      expect(find.byType(CalendarDayResultPopup), findsNothing);

      run.complete(
        const BatchSimulationResult(
          stopReason: SimulationStopReason.reachedTarget,
          daysSimulated: 1,
        ),
      );
      await tester.pump();

      expect(find.byType(CalendarDayResultPopup), findsNothing);
      expect(find.byKey(_feedbackHostKey), findsNothing);
      expect(find.byKey(_progressKey), findsNothing);
      expect(find.textContaining('Cel osiągnięty'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'keeps popup through 449 and 450 ms and dismisses at the 500 ms cycle',
    (tester) async {
      late _FakeCalendarController controller;
      await tester.pumpWidget(
        _calendarApp(
          selectedDay: _futureCalendarDay,
          onController: (value) => controller = value,
        ),
      );
      await tester.pumpAndSettle();

      await _tapSimulate(tester);
      final run = controller.runs.single;
      var sequence = 0;

      Future<void> publishForNewDay() async {
        final currentSequence = sequence++;
        run.emit(
          _feedback(
            runId: 0,
            sequence: currentSequence,
            day: currentSequence + 2,
          ),
        );
        await tester.pump();
      }

      await publishForNewDay();
      await tester.pump(const Duration(milliseconds: 449));
      expect(find.byType(CalendarDayResultPopup), findsOneWidget);

      await publishForNewDay();
      await tester.pump(const Duration(milliseconds: 450));
      expect(
        find.byType(CalendarDayResultPopup),
        findsOneWidget,
        reason: 'The host timer must not dismiss feedback at 450 ms.',
      );

      await publishForNewDay();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.byType(CalendarDayResultPopup),
        findsNothing,
        reason: 'The host timer should dismiss feedback at the target cycle.',
      );

      // Fresh completed days make the 600 ms and 601 ms checks exercise a
      // newly scheduled timer rather than the screen's same-date dedup guard.
      await publishForNewDay();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(CalendarDayResultPopup), findsNothing);
      await publishForNewDay();
      await tester.pump(const Duration(milliseconds: 601));
      expect(find.byType(CalendarDayResultPopup), findsNothing);

      run.complete(
        const BatchSimulationResult(
          stopReason: SimulationStopReason.cancelled,
          daysSimulated: 1,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('restart clears the old run and dispose requests cancellation', (
    tester,
  ) async {
    late _FakeCalendarController controller;
    await tester.pumpWidget(
      _calendarApp(
        selectedDay: _futureCalendarDay,
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    await _tapSimulate(tester);
    await tester.pump();
    final firstRun = controller.runs.single;
    firstRun.emit(_feedback(runId: 0, sequence: 0));
    await tester.pump();
    expect(find.byType(CalendarDayResultPopup), findsOneWidget);

    firstRun.complete(
      const BatchSimulationResult(
        stopReason: SimulationStopReason.cancelled,
        daysSimulated: 1,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDayResultPopup), findsNothing);

    await _tapSimulate(tester);
    await tester.pump();
    expect(controller.runs, hasLength(2));
    expect(find.byType(CalendarDayResultPopup), findsNothing);

    final secondRun = controller.runs[1];
    secondRun.emit(_feedback(runId: 1, sequence: 0));
    await tester.pump();
    expect(find.byType(CalendarDayResultPopup), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('calendar-day-result-popup-1-0')),
      findsOneWidget,
    );

    // The old observer may still be called by an in-flight controller future,
    // but it must not replace the newer run's popup.
    firstRun.emit(_feedback(runId: 0, sequence: 99));
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('calendar-day-result-popup-1-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('calendar-day-result-popup-0-99')),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    expect(secondRun.cancelled, isTrue);
    secondRun.complete(
      const BatchSimulationResult(
        stopReason: SimulationStopReason.cancelled,
        daysSimulated: 0,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('clears popup before an urgent-stop snackbar', (tester) async {
    late _FakeCalendarController controller;
    await tester.pumpWidget(
      _calendarApp(
        selectedDay: _futureCalendarDay,
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    await _tapSimulate(tester);
    final run = controller.runs.single;
    run.emit(_feedback(runId: 0, sequence: 0));
    await tester.pump();
    expect(find.byType(CalendarDayResultPopup), findsOneWidget);

    run.complete(
      const BatchSimulationResult(
        stopReason: SimulationStopReason.urgent,
        daysSimulated: 1,
      ),
    );
    await tester.pump();

    expect(find.byType(CalendarDayResultPopup), findsNothing);
    expect(find.byKey(_feedbackHostKey), findsNothing);
    expect(find.byKey(_progressKey), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clears popup before a no-save stop snackbar', (tester) async {
    late _FakeCalendarController controller;
    await tester.pumpWidget(
      _calendarApp(
        selectedDay: _futureCalendarDay,
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    await _tapSimulate(tester);
    final run = controller.runs.single;
    run.emit(_feedback(runId: 0, sequence: 0));
    await tester.pump();
    expect(find.byType(CalendarDayResultPopup), findsOneWidget);

    run.complete(
      const BatchSimulationResult(
        stopReason: SimulationStopReason.noSave,
        daysSimulated: 0,
      ),
    );
    await tester.pump();

    expect(find.byType(CalendarDayResultPopup), findsNothing);
    expect(find.byKey(_feedbackHostKey), findsNothing);
    expect(find.byKey(_progressKey), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clears popup before draft-event navigation', (tester) async {
    late _FakeCalendarController controller;
    final harness = _calendarRouterApp(
      selectedDay: _futureCalendarDay,
      onController: (value) => controller = value,
    );
    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    await _tapSimulate(tester);
    final run = controller.runs.single;
    run.emit(_feedback(runId: 0, sequence: 0));
    await tester.pump();
    expect(find.byType(CalendarDayResultPopup), findsOneWidget);

    run.complete(
      const BatchSimulationResult(
        stopReason: SimulationStopReason.event,
        eventId: CalendarEventId.draft,
        daysSimulated: 1,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDayResultPopup), findsNothing);
    expect(find.byKey(_feedbackHostKey), findsNothing);
    expect(find.byKey(_progressKey), findsNothing);
    expect(
      harness.destinationUris.map((uri) => uri.path),
      contains('/game/draft'),
    );
    expect(find.text('draft destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending event without a completed day shows no result popup', (
    tester,
  ) async {
    late _FakeCalendarController controller;
    final harness = _calendarRouterApp(
      selectedDay: _futureCalendarDay,
      onController: (value) => controller = value,
    );
    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    await _tapSimulate(tester);
    final run = controller.runs.single;
    run.complete(
      const BatchSimulationResult(
        stopReason: SimulationStopReason.event,
        eventId: CalendarEventId.draft,
        daysSimulated: 0,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDayResultPopup), findsNothing);
    expect(find.byKey(_feedbackHostKey), findsNothing);
    expect(
      harness.destinationUris.map((uri) => uri.path),
      contains('/game/draft'),
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _tapSimulate(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Do wybranej daty');
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

const _progressKey = ValueKey<String>('calendar-batch-progress-overlay');
const _cancelKey = ValueKey<String>('calendar-batch-cancel');
const _feedbackHostKey = ValueKey<String>('calendar-day-result-feedback-host');
final _futureCalendarDay = DateTime(2026, 8, 4);

CalendarDaySimulationFeedback _feedback({
  required int runId,
  required int sequence,
  int day = 2,
}) {
  return CalendarDaySimulationFeedback(
    runId: runId,
    sequence: sequence,
    week: 1,
    day: day,
    results: [
      const CalendarMatchFeedback(
        matchId: 'calendar-test-match',
        homeTeamId: 'team-europe-0',
        homeTeamName: 'North London United',
        awayTeamId: 'team-america-0',
        awayTeamName: 'South Coast City',
        homeGoals: 2,
        awayGoals: 1,
        schedulePosition: 0,
      ),
    ],
  );
}

Widget _calendarApp({
  required DateTime selectedDay,
  required void Function(_FakeCalendarController controller) onController,
}) {
  return ProviderScope(
    overrides: [
      saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
      gameControllerProvider.overrideWith((ref) {
        final controller = _FakeCalendarController(ref, _fixtureGame());
        onController(controller);
        return controller;
      }),
      calendarSelectedDayProvider.overrideWith((ref) => selectedDay),
    ],
    child: const MaterialApp(
      locale: Locale('pl'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: CalendarScreen(),
    ),
  );
}

({Widget app, List<Uri> destinationUris}) _calendarRouterApp({
  required DateTime selectedDay,
  required void Function(_FakeCalendarController controller) onController,
}) {
  final destinationUris = <Uri>[];
  final router = GoRouter(
    initialLocation: '/game',
    routes: [
      GoRoute(
        path: '/game',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/game/draft',
        builder: (context, state) {
          destinationUris.add(state.uri);
          return const Scaffold(body: Text('draft destination'));
        },
      ),
    ],
  );

  return (
    destinationUris: destinationUris,
    app: ProviderScope(
      overrides: [
        saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
        gameControllerProvider.overrideWith((ref) {
          final controller = _FakeCalendarController(ref, _fixtureGame());
          onController(controller);
          return controller;
        }),
        calendarSelectedDayProvider.overrideWith((ref) => selectedDay),
      ],
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
    ),
  );
}

GameSave _fixtureGame() {
  return GameFactory().create(
    const NewGameRequest(
      saveName: 'Calendar screen test',
      playerTeamId: 'team_europe_0',
      seed: 7,
    ),
  );
}

class _FakeCalendarController extends GameController {
  _FakeCalendarController(super.ref, GameSave game) {
    state = AsyncValue.data(game);
  }

  final runs = <_FakeCalendarRun>[];

  @override
  Future<BatchSimulationResult> simulateToDate(
    int targetWeek,
    int targetDay, {
    CalendarDaySimulationObserver? observer,
    CalendarSimulationPacer? pacer,
  }) {
    final run = _FakeCalendarRun(observer, pacer);
    runs.add(run);
    return run.future;
  }

  @override
  void cancelSimulation() {
    if (runs.isNotEmpty) runs.last.cancelled = true;
  }

  @override
  Future<void> runEventAtCurrentDay(CalendarEventId eventId) async {}
}

class _FakeCalendarRun {
  _FakeCalendarRun(this.observer, this.pacer);

  final CalendarDaySimulationObserver? observer;
  final CalendarSimulationPacer? pacer;
  final _completer = Completer<BatchSimulationResult>();
  bool cancelled = false;

  Future<BatchSimulationResult> get future => _completer.future;

  void emit(CalendarDaySimulationFeedback feedback) => observer?.call(feedback);

  void complete(BatchSimulationResult result) {
    if (!_completer.isCompleted) _completer.complete(result);
  }
}

class _NoopSaveRepository extends SaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}
