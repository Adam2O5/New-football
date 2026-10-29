@Tags(['ui', 'property'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/preferences_test_double.dart';
import '../helpers/widgets/widget_harness.dart';
import '../helpers/fixtures/calendar_fixtures.dart';

const _scenarioLabel = 'urgent message lifecycle and Inbox';

DateTime _calendarSelectedDayFor(GameSave game) {
  final seasonYear = game.leagueState.currentSeason.year;
  var week1Start = DateTime(seasonYear, 8, 1);
  while (week1Start.weekday != DateTime.monday) {
    week1Start = week1Start.add(const Duration(days: 1));
  }
  while (week1Start.month != 8 ||
      week1Start.add(const Duration(days: 6)).month != 8) {
    week1Start = week1Start.add(const Duration(days: 7));
  }

  final league = game.leagueState;
  return week1Start.add(
    Duration(days: (league.currentWeek - 1) * 7 + league.currentDay - 1),
  );
}

void main() {
  for (final scenario in _lifecycleCases()) {
    test('message lifecycle: ${scenario.label}', () async {
      final game = _gameFor(scenario);
      final originalMessages = <String, GameMessage>{
        for (final message in [
          ...game.leagueState.inbox.messages,
          ...game.leagueState.inbox.scheduled,
        ])
          message.id: message,
      };
      final fixture = _controllerFixture(game, scenario.enabled);
      final label = scenario.label;

      try {
        expect(
          fixture.container.read(urgentInterruptionSettingProvider),
          scenario.enabled,
          reason: '$label must use its explicit preference override',
        );

        final result = await _runBatch(fixture.controller, scenario);
        final after = fixture.controller.save!;
        final inbox = after.leagueState.inbox;

        if (scenario.enabled) {
          expect(
            result.stopReason,
            SimulationStopReason.urgent,
            reason: '$label must hand the batch to Inbox at the urgent stop',
          );
        } else {
          expect(
            result.stopReason,
            _ordinaryStopFor(scenario.outcome),
            reason:
                '$label must use the ordinary outcome after skipping urgent',
          );
          expect(
            result.stopReason,
            isNot(SimulationStopReason.urgent),
            reason:
                '$label must not report a pending message as the final stop',
          );
        }

        expect(
          inbox.pendingUrgent.map((message) => message.id),
          orderedEquals(originalMessages.keys),
          reason: '$label must retain every urgent in pendingUrgent',
        );
        expect(
          inbox.pendingUrgent,
          hasLength(scenario.messageCount),
          reason: '$label must not drop or duplicate a pending urgent',
        );
        expect(
          inbox.scheduled,
          isEmpty,
          reason:
              '$label must deliver scheduled messages before the ordinary '
              'batch result is returned',
        );

        for (final original in originalMessages.values) {
          final current = inbox.messages.firstWhere(
            (message) => message.id == original.id,
          );
          expect(
            current,
            original,
            reason: '$label changed data for ${original.id}',
          );
          expect(
            current.read,
            original.read,
            reason: '$label changed read for ${original.id}',
          );
          expect(
            current.acknowledged,
            isFalse,
            reason: '$label auto-acknowledged ${original.id}',
          );
          expect(
            current.priority,
            MessagePriority.urgent,
            reason: '$label changed priority for ${original.id}',
          );
        }

        final lastLeague = result.lastResult?.league;
        if (lastLeague != null) {
          for (final original in originalMessages.values) {
            final lastMessage = lastLeague.inbox.messages.where(
              (message) => message.id == original.id,
            );
            if (lastMessage.isNotEmpty) {
              expect(
                lastMessage.single,
                original,
                reason:
                    '$label changed lifecycle in lastResult for '
                    '${original.id}',
              );
            }
          }
        }
      } finally {
        fixture.dispose();
      }
    });
  }

  for (final scenario in _handoffCases()) {
    testWidgets('Inbox handoff: ${scenario.label}', (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      final game = _uiGameFor(scenario);
      final result = _uiResultFor(game, scenario);
      final l10n = await AppLocalizations.delegate.load(scenario.locale);
      late GameController controller;

      final app = scenario.surface == _UiSurface.calendar
          ? _calendarUiApp(
              game: game,
              result: result,
              enabled: scenario.enabled,
              locale: scenario.locale,
              onController: (value) => controller = value,
            )
          : _homeUiApp(
              game: game,
              result: result,
              enabled: scenario.enabled,
              locale: scenario.locale,
              outcome: scenario.outcome,
              onController: (value) => controller = value,
            );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      final label = scenario.label;

      if (scenario.surface == _UiSurface.calendar) {
        final simulate = find.widgetWithText(
          FilledButton,
          l10n.calendar_simulateUntilDate,
        );
        expect(simulate, findsOneWidget, reason: label);
        await Scrollable.ensureVisible(
          tester.element(simulate),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(simulate);
      } else {
        await _tapHomeAction(tester, scenario);
      }
      await tester.pumpAndSettle();

      if (!scenario.enabled &&
          scenario.surface == _UiSurface.calendar &&
          scenario.outcome == _OrdinaryOutcome.event) {
        expect(find.byType(AlertDialog), findsOneWidget);
        final dialog = tester.element(find.byType(AlertDialog));
        await tester.tap(
          find.widgetWithText(
            TextButton,
            MaterialLocalizations.of(dialog).okButtonLabel,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('property 5 draft destination'), findsOneWidget);
      }

      final openInbox = l10n.simulation_openInbox;
      final actionCount = find.text(openInbox).evaluate().length;
      expect(
        actionCount,
        lessThanOrEqualTo(1),
        reason: '$label must not duplicate the localized Inbox action',
      );
      expect(
        controller.save!.leagueState.inbox.pendingUrgent,
        hasLength(scenario.messageCount),
        reason: '$label must leave pending messages available to Inbox',
      );
      expect(
        controller.save!.leagueState.inbox.messages.every(
          (message) => !message.acknowledged,
        ),
        isTrue,
        reason:
            '$label must not auto-acknowledge a message while presenting '
            'the result',
      );

      if (scenario.enabled) {
        expect(
          find.byType(InboxScreen),
          findsOneWidget,
          reason: '$label must hand an enabled urgent stop to Inbox',
        );
        if (scenario.surface == _UiSurface.calendar) {
          expect(
            actionCount,
            1,
            reason:
                '$label may expose the direct Inbox '
                'handoff as a localized action too',
          );
        }
      } else {
        expect(
          actionCount,
          1,
          reason: '$label must expose exactly one localized Inbox action',
        );
        expect(
          find.text(l10n.simulation_pendingUrgentNotice),
          findsOneWidget,
          reason: '$label must explain why Inbox is available',
        );
        await tester.tap(find.text(openInbox));
        await tester.pumpAndSettle();
        expect(
          find.byType(InboxScreen),
          findsOneWidget,
          reason: '$label Inbox action must open the existing Inbox UI',
        );
      }
    });
  }

  // The batch/UI assertions above deliberately never acknowledge a message.
  // This final example proves the existing manual Inbox lifecycle still owns
  // the only read/acknowledge transition.
  testWidgets('$_scenarioLabel retains the existing manual Inbox '
      'acknowledgement lifecycle', (tester) async {
    final preferences = PreferencesTestDouble(
      initialValues: <String, Object?>{urgentInterruptionSettingKey: false},
    );
    late GameController controller;
    final message = _urgentMessage(
      id: 'property-5-manual-ack',
      seasonYear: 2026,
      week: 1,
      day: 1,
      read: false,
    );
    final game = _withInbox(
      _baseGame(seed: 5205, outcome: _OrdinaryOutcome.target),
      Inbox(messages: [message]),
    );

    await tester.pumpWidget(
      task41App(
        const Scaffold(body: InboxScreen()),
        game,
        onController: (value) => controller = value,
        extraOverrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          urgentInterruptionSettingProvider.overrideWith(
            (_) => UrgentInterruptionSettingController(preferences),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));
    expect(
      controller.save!.leagueState.inbox.messages.single,
      message,
      reason:
          'the result lifecycle must reach Inbox unchanged before manual '
          'acknowledgement',
    );

    await tester.tap(find.text('Property 5 urgent'));
    await tester.pumpAndSettle();
    expect(find.text('Potwierdź'), findsOneWidget);
    expect(
      controller.save!.leagueState.inbox.pendingUrgent,
      hasLength(1),
      reason: 'opening Inbox details must not acknowledge the urgent',
    );

    await tester.tap(find.text('Potwierdź'));
    await tester.pumpAndSettle();

    final acknowledged = controller.save!.leagueState.inbox.messages.single;
    expect(acknowledged.read, isTrue);
    expect(acknowledged.acknowledged, isTrue);
    expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

enum _LifecyclePlacement { scheduled, delivered, pending }

enum _OrdinaryOutcome { target, event, match }

enum _UiSurface { calendar, home }

class _InboxScenario {
  const _InboxScenario({
    required this.index,
    required this.enabled,
    required this.locale,
    required this.surface,
    required this.outcome,
    required this.placement,
    required this.messageCount,
    required this.seed,
  });

  final int index;
  final bool enabled;
  final Locale locale;
  final _UiSurface surface;
  final _OrdinaryOutcome outcome;
  final _LifecyclePlacement placement;
  final int messageCount;
  final int seed;

  String get label =>
      '$_scenarioLabel case=$index '
      'policy=${enabled ? 'enabled' : 'disabled'} '
      'locale=${locale.languageCode} surface=${surface.name} '
      'outcome=${outcome.name} placement=${placement.name} '
      'messages=$messageCount seed=$seed';
}

List<_InboxScenario> _lifecycleCases() => [
  for (final enabled in [false, true])
    for (final outcome in _OrdinaryOutcome.values)
      for (final placement in _LifecyclePlacement.values)
        for (final count in [1, 2])
          _InboxScenario(
            index:
                (enabled ? 18 : 0) +
                outcome.index * 6 +
                placement.index * 2 +
                count -
                1,
            enabled: enabled,
            locale: const Locale('pl'),
            surface: _UiSurface.calendar,
            outcome: outcome,
            placement: placement,
            messageCount: count,
            seed: 5200,
          ),
];

List<_InboxScenario> _handoffCases() => [
  for (final enabled in [false, true])
    for (final locale in ['pl', 'en'])
      for (final surface in _UiSurface.values)
        for (final outcome in _OrdinaryOutcome.values)
          _InboxScenario(
            index: outcome.index,
            enabled: enabled,
            locale: Locale(locale),
            surface: surface,
            outcome: outcome,
            placement: locale == 'pl'
                ? _LifecyclePlacement.pending
                : _LifecyclePlacement.delivered,
            messageCount: outcome.index.isEven ? 1 : 2,
            seed: 5200,
          ),
];

Future<BatchSimulationResult> _runBatch(
  GameController controller,
  _InboxScenario scenario,
) {
  return switch (scenario.outcome) {
    _OrdinaryOutcome.target => controller.simulateToDate(
      1,
      3,
      pacer: CalendarSimulationPacer(
        target: Duration.zero,
        delay: (_) async {},
      ),
    ),
    _OrdinaryOutcome.event ||
    _OrdinaryOutcome.match => controller.simulateToEvent(),
  };
}

SimulationStopReason _ordinaryStopFor(_OrdinaryOutcome outcome) {
  return switch (outcome) {
    _OrdinaryOutcome.target => SimulationStopReason.reachedTarget,
    _OrdinaryOutcome.event => SimulationStopReason.event,
    _OrdinaryOutcome.match => SimulationStopReason.playerMatch,
  };
}

_ControllerFixture _controllerFixture(GameSave game, bool enabled) {
  final preferences = PreferencesTestDouble(
    initialValues: <String, Object?>{urgentInterruptionSettingKey: enabled},
  );
  final container = ProviderContainer(
    overrides: [
      // The setting is intentionally injected independently of GameSave.
      sharedPreferencesProvider.overrideWithValue(preferences),
      urgentInterruptionSettingProvider.overrideWith(
        (_) => UrgentInterruptionSettingController(preferences),
      ),
      saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
    ],
  );
  final controller = container.read(gameControllerProvider.notifier);
  controller.state = AsyncValue.data(game);
  return _ControllerFixture(container, controller);
}

GameSave _gameFor(_InboxScenario scenario) {
  final base = _baseGame(seed: scenario.seed, outcome: scenario.outcome);
  final league = base.leagueState;
  var inbox = const Inbox();
  final deliveryDay = scenario.outcome == _OrdinaryOutcome.target ? 2 : 1;

  for (var index = 0; index < scenario.messageCount; index++) {
    final message = _urgentMessage(
      id: 'property-5-${scenario.index}-$index',
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: scenario.placement == _LifecyclePlacement.scheduled
          ? deliveryDay
          : league.currentDay,
      read: scenario.placement == _LifecyclePlacement.pending,
    );
    inbox = scenario.placement == _LifecyclePlacement.scheduled
        ? inbox.scheduleMessage(message)
        : inbox.addMessage(message);
  }

  return base.copyWith(leagueState: league.copyWith(inbox: inbox));
}

GameSave _baseGame({required int seed, required _OrdinaryOutcome outcome}) {
  final base = calendarFixture(
    seed: seed,
    withPlayerMatch: outcome == _OrdinaryOutcome.match,
  );
  final league = base.leagueState;
  switch (outcome) {
    case _OrdinaryOutcome.target:
      return base.copyWith(
        leagueState: league.copyWith(
          playerTeamId: null,
          currentWeek: 1,
          currentDay: 1,
          currentHour: null,
        ),
      );
    case _OrdinaryOutcome.event:
      return base.copyWith(
        leagueState: league.copyWith(
          playerTeamId: null,
          currentWeek: 45,
          currentDay: 2,
          currentHour: null,
          currentSeason: league.currentSeason.copyWith(
            scoutReportDone: true,
            combineDone: false,
          ),
        ),
      );
    case _OrdinaryOutcome.match:
      return base.copyWith(
        leagueState: league.copyWith(
          playerTeamId: 'team_europe_0',
          currentWeek: 1,
          currentDay: 1,
          currentHour: null,
        ),
      );
  }
}

GameMessage _urgentMessage({
  required String id,
  required int seasonYear,
  required int week,
  required int day,
  required bool read,
}) {
  return GameMessage(
    id: id,
    type: MessageType.tradeWindowEvent,
    domain: MessageDomain.trades,
    priority: MessagePriority.urgent,
    seasonYear: seasonYear,
    week: week,
    day: day,
    titleKey: 'property_5_urgent_title',
    bodyKey: 'property_5_urgent_body',
    args: const {
      '_legacyTitle': 'Property 5 urgent',
      '_legacyBody': 'A pending urgent message from the lifecycle property.',
    },
    read: read,
  );
}

GameSave _withInbox(GameSave game, Inbox inbox) =>
    game.copyWith(leagueState: game.leagueState.copyWith(inbox: inbox));

class _ControllerFixture {
  const _ControllerFixture(this.container, this.controller);

  final ProviderContainer container;
  final GameController controller;

  void dispose() => container.dispose();
}

GameSave _uiGameFor(_InboxScenario scenario) {
  final base = _baseGame(seed: scenario.seed, outcome: scenario.outcome);
  final messages = [
    for (var index = 0; index < scenario.messageCount; index++)
      _urgentMessage(
        id: 'property-5-${scenario.index}-$index',
        seasonYear: base.leagueState.currentSeason.year,
        week: base.leagueState.currentWeek,
        day: base.leagueState.currentDay,
        read: scenario.placement == _LifecyclePlacement.pending,
      ),
  ];
  return _withInbox(base, Inbox(messages: messages));
}

BatchSimulationResult _uiResultFor(GameSave game, _InboxScenario scenario) {
  if (scenario.enabled) {
    return const BatchSimulationResult(
      stopReason: SimulationStopReason.urgent,
      daysSimulated: 0,
    );
  }

  switch (scenario.outcome) {
    case _OrdinaryOutcome.target:
      return const BatchSimulationResult(
        stopReason: SimulationStopReason.reachedTarget,
        daysSimulated: 2,
      );
    case _OrdinaryOutcome.event:
      return const BatchSimulationResult(
        stopReason: SimulationStopReason.event,
        eventId: CalendarEventId.draft,
        daysSimulated: 1,
      );
    case _OrdinaryOutcome.match:
      final match = game.leagueState.currentSeason.schedule.firstWhere(
        (candidate) =>
            candidate.homeTeamId == game.leagueState.playerTeamId ||
            candidate.awayTeamId == game.leagueState.playerTeamId,
      );
      return BatchSimulationResult(
        stopReason: SimulationStopReason.playerMatch,
        daysSimulated: 1,
        lastResult: DaySimulationResult(
          league: game.leagueState,
          pauseForUrgent: false,
          playerMatch: match,
        ),
      );
  }
}

Widget _calendarUiApp({
  required GameSave game,
  required BatchSimulationResult result,
  required bool enabled,
  required Locale locale,
  required void Function(GameController controller) onController,
}) {
  final preferences = PreferencesTestDouble(
    initialValues: <String, Object?>{urgentInterruptionSettingKey: enabled},
  );
  final router = GoRouter(
    initialLocation: '/game',
    routes: [
      GoRoute(
        path: '/game',
        builder: (context, state) => ShellScreen(
          initialTab: state.extra is int ? state.extra as int : 1,
        ),
      ),
      GoRoute(
        path: '/game/draft',
        builder: (context, state) =>
            const Scaffold(body: Text('property 5 draft destination')),
      ),
      GoRoute(
        path: '/game/match',
        builder: (context, state) =>
            const Scaffold(body: Text('property 5 match destination')),
      ),
    ],
  );

  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      urgentInterruptionSettingProvider.overrideWith(
        (_) => UrgentInterruptionSettingController(preferences),
      ),
      saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
      calendarSelectedDayProvider.overrideWith(
        (_) => _calendarSelectedDayFor(game),
      ),
      gameControllerProvider.overrideWith((ref) {
        final controller = _UiCalendarController(ref, game, result);
        onController(controller);
        return controller;
      }),
    ],
    child: MaterialApp.router(
      locale: locale,
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

Widget _homeUiApp({
  required GameSave game,
  required BatchSimulationResult result,
  required bool enabled,
  required Locale locale,
  required _OrdinaryOutcome outcome,
  required void Function(GameController controller) onController,
}) {
  final preferences = PreferencesTestDouble(
    initialValues: <String, Object?>{urgentInterruptionSettingKey: enabled},
  );
  final action = _homeActionFor(game, outcome);
  final router = GoRouter(
    initialLocation: '/game',
    routes: [
      GoRoute(
        path: '/game',
        builder: (context, state) => ShellScreen(
          initialTab: state.extra is int ? state.extra as int : 0,
        ),
      ),
      GoRoute(
        path: '/game/draft',
        builder: (context, state) =>
            const Scaffold(body: Text('property 5 draft destination')),
      ),
      GoRoute(
        path: '/game/match',
        builder: (context, state) =>
            const Scaffold(body: Text('property 5 match destination')),
      ),
    ],
  );

  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      urgentInterruptionSettingProvider.overrideWith(
        (_) => UrgentInterruptionSettingController(preferences),
      ),
      saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
      nextGameEventProvider.overrideWithValue(action),
      gameControllerProvider.overrideWith((ref) {
        final controller = _UiHomeController(ref, game, result);
        onController(controller);
        return controller;
      }),
    ],
    child: MaterialApp.router(
      locale: locale,
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

UpcomingAction _homeActionFor(GameSave game, _OrdinaryOutcome outcome) {
  final league = game.leagueState;
  switch (outcome) {
    case _OrdinaryOutcome.target:
      return UpcomingAction(
        kind: CalendarEventKind.automatic,
        id: 'combine',
        calendarEventId: CalendarEventId.combine,
        week: league.currentWeek,
        day: league.currentDay + 2,
      );
    case _OrdinaryOutcome.event:
      return UpcomingAction(
        kind: CalendarEventKind.playerAction,
        id: 'draft',
        calendarEventId: CalendarEventId.draft,
        week: league.currentWeek,
        day: league.currentDay,
      );
    case _OrdinaryOutcome.match:
      return UpcomingAction(
        kind: CalendarEventKind.match,
        id: 'match',
        week: league.currentWeek,
        day: league.currentDay,
      );
  }
}

Future<void> _tapHomeAction(
  WidgetTester tester,
  _InboxScenario scenario,
) async {
  final l10n = await AppLocalizations.delegate.load(scenario.locale);
  final finder = switch (scenario.outcome) {
    _OrdinaryOutcome.target => find.text(
      l10n.home_simulateToEvent(l10n.calendar_event_combine),
    ),
    _OrdinaryOutcome.event => find.text(
      l10n.home_goToEvent(l10n.calendar_event_draft),
    ),
    _OrdinaryOutcome.match => find.widgetWithIcon(
      FilledButton,
      Icons.sports_soccer,
    ),
  };
  await tester.scrollUntilVisible(
    finder,
    500,
    scrollable: find.byType(Scrollable).at(0),
  );
  expect(finder, findsOneWidget, reason: scenario.label);
  await tester.tap(finder);
}

final class _UiCalendarController extends GameController {
  _UiCalendarController(super.ref, GameSave game, this.result) {
    state = AsyncValue.data(game);
  }

  final BatchSimulationResult result;

  @override
  Future<BatchSimulationResult> simulateToDate(
    int targetWeek,
    int targetDay, {
    CalendarDaySimulationObserver? observer,
    CalendarSimulationPacer? pacer,
  }) async => result;

  @override
  void cancelSimulation() {}

  @override
  Future<void> runEventAtCurrentDay(CalendarEventId eventId) async {}
}

final class _UiHomeController extends GameController {
  _UiHomeController(super.ref, GameSave game, this.result)
    : _resultGame = game {
    state = AsyncValue.data(
      game.copyWith(
        leagueState: game.leagueState.copyWith(inbox: const Inbox()),
      ),
    );
  }

  final GameSave _resultGame;
  final BatchSimulationResult result;

  @override
  Future<BatchSimulationResult> simulateToEvent() async {
    state = AsyncValue.data(_resultGame);
    return result;
  }

  @override
  Future<void> runEventAtCurrentDay(CalendarEventId eventId) async {}

  @override
  Future<DaySimulationResult?> advanceOneDay({
    bool resolveContractMarket = true,
  }) async => null;
}
