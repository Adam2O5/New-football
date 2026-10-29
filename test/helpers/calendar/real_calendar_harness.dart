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

const progressKey = ValueKey<String>('calendar-batch-progress-overlay');
const cancelKey = ValueKey<String>('calendar-batch-cancel');

Future<RealFixture> newWidgetFixture(
  WidgetTester tester,
  GameSave game, {
  DateTime? selectedDay,
  bool pauseAfterFirstCalendarDay = false,
}) async {
  return (await tester.runAsync(
    () => newFixture(
      game,
      selectedDay: selectedDay,
      pauseAfterFirstCalendarDay: pauseAfterFirstCalendarDay,
    ),
  ))!;
}

Future<void> startCalendarBatchAndWait(
  WidgetTester tester,
  RealFixture fixture,
) async {
  final controller = fixture.controller as IntegrationGameController;
  await tester.runAsync(() async {
    await tapCalendarSimulation(tester);
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

Future<CalendarDaySimulationFeedback> startCalendarBatchUntilPopup(
  WidgetTester tester,
) async {
  return (await tester.runAsync(() async {
    await tapCalendarSimulation(tester);
    return pumpUntilPopup(tester);
  }))!;
}

Future<void> tapCalendarSimulation(WidgetTester tester) async {
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

Future<CalendarDaySimulationFeedback> pumpUntilPopup(
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

Future<CalendarTrace> pumpCalendarUntilSimulationCompletes(
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
      'progress=${find.byKey(progressKey).evaluate().isNotEmpty}, '
      'popup=${find.byType(CalendarDayResultPopup).evaluate().isNotEmpty}, '
      'snackbar=${find.byType(SnackBar).evaluate().isNotEmpty}',
    );
  }

  return CalendarTrace(
    feedback: feedbackByIdentity.values.toList(),
    snackbarOverlappedPopup: snackbarOverlappedPopup,
  );
}

Future<CalendarTrace> pumpCalendarUntil(
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
    final progressVisible = find.byKey(progressKey).evaluate().isNotEmpty;
    final snackbarVisible = find.byType(SnackBar).evaluate().isNotEmpty;
    if (popupVisible && snackbarVisible) snackbarOverlappedPopup = true;
    if (terminal(progressVisible, popupVisible, snackbarVisible)) {
      return CalendarTrace(
        feedback: feedbackByIdentity.values.toList(),
        snackbarOverlappedPopup: snackbarOverlappedPopup,
      );
    }
  }
  throw TestFailure(
    'The real calendar batch did not reach its terminal UI state. '
    'progress=${find.byKey(progressKey).evaluate().isNotEmpty}, '
    'popup=${find.byType(CalendarDayResultPopup).evaluate().isNotEmpty}, '
    'snackbar=${find.byType(SnackBar).evaluate().isNotEmpty}',
  );
}

final class CalendarTrace {
  const CalendarTrace({
    required this.feedback,
    required this.snackbarOverlappedPopup,
  });

  final List<CalendarDaySimulationFeedback> feedback;
  final bool snackbarOverlappedPopup;
}

final class RealFixture {
  RealFixture({
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
  var disposed = false;

  Future<void> dispose() async {
    if (disposed) return;
    disposed = true;
    controller.cancelSimulation();
    try {
      final integration = controller as IntegrationGameController;
      await integration.lastSimulation;
      await integration.lastEventSimulation;
      await integration.lastCalendarEvent;
      await controller.enqueueSaveManagement(() async {});
    } finally {
      container.dispose();
    }
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

final class IntegrationGameController extends GameController {
  IntegrationGameController(
    super.ref,
    GameSave game, {
    this.pauseAfterFirstCalendarDay = false,
  }) {
    state = AsyncValue.data(game);
  }

  Future<BatchSimulationResult>? lastSimulation;
  Future<BatchSimulationResult>? lastEventSimulation;
  Future<void>? lastCalendarEvent;
  final publishedFeedback = <CalendarDaySimulationFeedback>[];
  final bool pauseAfterFirstCalendarDay;
  final Completer<void> releaseFirstCalendarDay = Completer<void>();
  var firstCalendarDayPauseConsumed = false;

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
    if (!releaseFirstCalendarDay.isCompleted) {
      releaseFirstCalendarDay.complete();
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
        : (CalendarDaySimulationFeedback feedback) async {
            debugPrint('calendar day published: ${feedback.identityKey}');
            publishedFeedback.add(feedback);
            await observer(feedback);
          };
    final future = super.simulateToDate(
      targetWeek,
      targetDay,
      observer: wrappedObserver,
      pacer: testCalendarPacer(),
    );
    lastSimulation = future;
    return future;
  }

  CalendarSimulationPacer testCalendarPacer() {
    var elapsed = Duration.zero;
    return CalendarSimulationPacer(
      elapsedSource: () => elapsed,
      delay: (duration) async {
        elapsed += duration;
        if (pauseAfterFirstCalendarDay && !firstCalendarDayPauseConsumed) {
          firstCalendarDayPauseConsumed = true;
          await releaseFirstCalendarDay.future;
        }
        await Future<void>.delayed(const Duration(milliseconds: 1));
      },
    );
  }
}

Future<RealFixture> newFixture(
  GameSave game, {
  DateTime? selectedDay,
  bool pauseAfterFirstCalendarDay = false,
}) async {
  final directory = await Directory.systemTemp.createTemp('nf_it_');
  final repository = SaveRepository(overrideDirectory: directory);
  await repository.save(game);
  debugPrint(
    'calendar fixture ready: seed=${game.saveSeed} W${game.leagueState.currentWeek}D${game.leagueState.currentDay}',
  );
  final overrides = [
    saveRepositoryProvider.overrideWithValue(repository),
    gameControllerProvider.overrideWith(
      (ref) => IntegrationGameController(
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
  return RealFixture(
    directory: directory,
    repository: repository,
    container: container,
    controller: controller,
    game: game,
  );
}

final class BaselineOutcome {
  const BaselineOutcome({required this.save, required this.result});

  final GameSave save;
  final BatchSimulationResult result;

  String get scheduleSnapshot => snapshotSchedule(save);
  String get standingsSnapshot => snapshotStandings(save);
}

Future<BaselineOutcome> runBaseline(GameSave game, (int, int) target) async {
  final fixture = await newFixture(game);
  try {
    final result = await fixture.controller.simulateToDate(
      target.$1,
      target.$2,
    );
    final persisted = await fixture.repository.load(game.meta.id);
    return BaselineOutcome(save: persisted, result: result);
  } finally {
    await fixture.dispose();
  }
}

CalendarSimulationPacer fakePacer({bool yieldToEventLoop = false}) {
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

GameSave fixtureGame({required int seed}) {
  return GameFactory().create(
    NewGameRequest(
      saveName: 'Calendar integration $seed',
      playerTeamId: 'team_europe_0',
      seed: seed,
    ),
  );
}

GameSave gameAtDate(
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

GameSave withScheduledUrgent(
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

GameSave draftEventGame() {
  final game = fixtureGame(seed: 7);
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

GameSave scoutEventGame() {
  final game = fixtureGame(seed: 7);
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

(int, int) targetAfterWeekOneWeekend() {
  final matchDays = matchDaysForWeek(1);
  return const CalendarService().advanceDay(1, matchDays.weekendDay);
}

DateTime calendarDate(int seasonYear, int week, int day) {
  var start = DateTime(seasonYear, 8, 1);
  while (start.weekday != DateTime.monday) {
    start = start.add(const Duration(days: 1));
  }
  while (start.month != 8 || start.add(const Duration(days: 6)).month != 8) {
    start = start.add(const Duration(days: 7));
  }
  return start.add(Duration(days: (week - 1) * 7 + day - 1));
}

String snapshotSchedule(GameSave save) => save
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

String snapshotStandings(GameSave save) => save
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

Widget app(ProviderContainer container, Widget home) {
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

({Widget app, GoRouter router, List<Uri> destinations}) calendarRouterApp(
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
    app: routerMaterialApp(container, router),
    router: router,
    destinations: destinations,
  );
}

({Widget app, GoRouter router}) homeRouterApp(ProviderContainer container) {
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
  return (app: routerMaterialApp(container, router), router: router);
}

Widget routerMaterialApp(ProviderContainer container, GoRouter router) {
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
