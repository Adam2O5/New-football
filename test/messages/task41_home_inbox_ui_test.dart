@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/preferences_test_double.dart';
import '../helpers/widget_harness.dart';

void main() {
  testWidgets('Home blokuje akcję symulacji, gdy czeka pilna wiadomość', (
    tester,
  ) async {
    final game = _gameWithInbox(
      task41Game(seed: 4103),
      Inbox(messages: [_urgentMessage(decision: false)]),
    );

    await tester.pumpWidget(task41App(const HomeScreen(), game));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Odczytaj pilną wiadomość'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Home pokazuje aktywną akcję kontekstową bez urgent pause', (
    tester,
  ) async {
    final game = task41Game(seed: 4104);

    await tester.pumpWidget(task41App(const HomeScreen(), game));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-next-seven-days')), findsOneWidget);
    final buttons = tester.widgetList<FilledButton>(find.byType(FilledButton));
    expect(buttons.any((button) => button.onPressed != null), isTrue);
  });

  testWidgets(
    'Home go-to event preserves event navigation and exposes one Inbox CTA',
    (tester) async {
      late _FakeHomeController controller;
      final game = _gameWithInbox(
        task41Game(seed: 4110),
        Inbox(messages: [_urgentMessage(decision: false)]),
      );
      final action = _actionFor(
        game,
        kind: CalendarEventKind.playerAction,
        id: 'draft',
        calendarEventId: CalendarEventId.draft,
      );

      await tester.pumpWidget(
        _homeResultApp(
          game: game,
          action: action,
          result: const BatchSimulationResult(
            stopReason: SimulationStopReason.event,
            eventId: CalendarEventId.draft,
            daysSimulated: 1,
          ),
          onController: (value) => controller = value,
        ),
      );
      await tester.pumpAndSettle();

      final goToButton = find.widgetWithText(FilledButton, 'Przejdź do: Draft');
      await tester.scrollUntilVisible(
        goToButton,
        500,
        scrollable: find.byType(Scrollable).at(0),
      );
      await tester.tap(goToButton.at(0));
      await tester.pumpAndSettle();

      expect(controller.simulateToEventCalls, 1);
      expect(find.text('home draft destination'), findsOneWidget);
      expect(
        find.text('Pilna wiadomość czeka w skrzynce odbiorczej.'),
        findsOneWidget,
      );
      expect(
        find.text('Otwórz skrzynkę odbiorczą'),
        findsOneWidget,
        reason: 'The result must expose exactly one Inbox CTA.',
      );
      _expectPendingUrgent(controller.save!);

      await tester.tap(find.text('Otwórz skrzynkę odbiorczą'));
      await tester.pumpAndSettle();
      expect(find.byType(InboxScreen), findsOneWidget);
      _expectPendingUrgent(controller.save!);
    },
  );

  testWidgets(
    'Home simulate-event keeps ordinary result behavior and localizes Inbox CTA',
    (tester) async {
      late _FakeHomeController controller;
      final game = _gameWithInbox(
        task41Game(seed: 4111),
        Inbox(messages: [_urgentMessage(decision: false)]),
      );
      final action = _actionFor(
        game,
        kind: CalendarEventKind.automatic,
        id: 'combine',
        calendarEventId: CalendarEventId.combine,
      );

      await tester.pumpWidget(
        _homeResultApp(
          game: game,
          action: action,
          locale: const Locale('en'),
          result: const BatchSimulationResult(
            stopReason: SimulationStopReason.event,
            eventId: CalendarEventId.combine,
            daysSimulated: 1,
          ),
          advanceResult: DaySimulationResult(
            league: game.leagueState,
            pauseForUrgent: false,
          ),
          onController: (value) => controller = value,
        ),
      );
      await tester.pumpAndSettle();

      final simulateButton = find.widgetWithText(
        FilledButton,
        'Simulate: Draft Combine',
      );
      await tester.scrollUntilVisible(
        simulateButton,
        500,
        scrollable: find.byType(Scrollable).at(0),
      );
      await tester.tap(simulateButton.at(0));
      await tester.pumpAndSettle();

      expect(controller.simulateToEventCalls, 1);
      expect(controller.runEventCalls, 1);
      expect(controller.advanceOneDayCalls, 1);
      expect(
        find.text('An urgent message is waiting in your inbox.'),
        findsOneWidget,
      );
      expect(find.text('Open Inbox'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      _expectPendingUrgent(controller.save!);

      await tester.tap(find.text('Open Inbox'));
      await tester.pumpAndSettle();
      expect(find.byType(InboxScreen), findsOneWidget);
      _expectPendingUrgent(controller.save!);
    },
  );

  testWidgets(
    'Home simulate-match preserves match navigation and pending Inbox action',
    (tester) async {
      late _FakeHomeController controller;
      final game = _gameWithInbox(
        task41Game(seed: 4112),
        Inbox(messages: [_urgentMessage(decision: false)]),
      );
      final action = _actionFor(
        game,
        kind: CalendarEventKind.match,
        id: 'match',
      );
      final playerMatch = game.leagueState.currentSeason.schedule.firstWhere(
        (match) =>
            match.homeTeamId == game.leagueState.playerTeamId ||
            match.awayTeamId == game.leagueState.playerTeamId,
      );

      await tester.pumpWidget(
        _homeResultApp(
          game: game,
          action: action,
          result: BatchSimulationResult(
            stopReason: SimulationStopReason.playerMatch,
            daysSimulated: 1,
            lastResult: DaySimulationResult(
              league: game.leagueState,
              pauseForUrgent: true,
              playerMatch: playerMatch,
            ),
          ),
          onController: (value) => controller = value,
        ),
      );
      await tester.pumpAndSettle();

      final matchButton = find.widgetWithText(FilledButton, 'Symuluj mecz');
      await tester.scrollUntilVisible(
        matchButton,
        500,
        scrollable: find.byType(Scrollable).at(0),
      );
      await tester.tap(matchButton.at(0));
      await tester.pumpAndSettle();

      expect(controller.simulateToEventCalls, 1);
      expect(find.text('home match destination'), findsOneWidget);
      expect(
        find.text('Pilna wiadomość czeka w skrzynce odbiorczej.'),
        findsOneWidget,
      );
      expect(find.text('Otwórz skrzynkę odbiorczą'), findsOneWidget);
      _expectPendingUrgent(controller.save!);

      await tester.tap(find.text('Otwórz skrzynkę odbiorczą'));
      await tester.pumpAndSettle();
      expect(find.byType(InboxScreen), findsOneWidget);
      _expectPendingUrgent(controller.save!);
    },
  );

  testWidgets(
    'Home urgent go-to result selects Inbox without acknowledging the message',
    (tester) async {
      late _FakeHomeController controller;
      final game = _gameWithInbox(
        task41Game(seed: 4113),
        Inbox(messages: [_urgentMessage(decision: false)]),
      );
      final action = _actionFor(
        game,
        kind: CalendarEventKind.playerAction,
        id: 'draft',
        calendarEventId: CalendarEventId.draft,
      );

      await tester.pumpWidget(
        _homeResultApp(
          game: game,
          action: action,
          result: const BatchSimulationResult(
            stopReason: SimulationStopReason.urgent,
            daysSimulated: 1,
          ),
          onController: (value) => controller = value,
        ),
      );
      await tester.pumpAndSettle();

      final goToButton = find.widgetWithText(FilledButton, 'Przejdź do: Draft');
      await tester.scrollUntilVisible(
        goToButton,
        500,
        scrollable: find.byType(Scrollable).at(0),
      );
      await tester.tap(goToButton.at(0));
      await tester.pumpAndSettle();

      expect(controller.simulateToEventCalls, 1);
      expect(find.byType(InboxScreen), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      _expectPendingUrgent(controller.save!);
    },
  );
}

GameSave _gameWithInbox(GameSave game, Inbox inbox) =>
    game.copyWith(leagueState: game.leagueState.copyWith(inbox: inbox));

GameMessage _urgentMessage({required bool decision}) => GameMessage(
  id: decision ? 'task41-decision' : 'task41-urgent',
  type: MessageType.playerEvent,
  domain: MessageDomain.playerEvent,
  priority: MessagePriority.urgent,
  seasonYear: 2026,
  week: 1,
  day: 1,
  titleKey: 'msg_playerEvent_title',
  bodyKey: 'msg_playerEvent_body',
  args: const {
    '_legacyTitle': 'Pilna decyzja',
    '_legacyBody': 'Wybierz jedną z opcji.',
  },
  decision: decision
      ? const DecisionSpec(
          options: [
            MessageAction(id: 'accept', labelKey: 'accept'),
            MessageAction(id: 'decline', labelKey: 'decline'),
          ],
          defaultOnExpiry: 'decline',
        )
      : null,
);

UpcomingAction _actionFor(
  GameSave game, {
  required CalendarEventKind kind,
  required String id,
  CalendarEventId? calendarEventId,
}) {
  return UpcomingAction(
    kind: kind,
    id: id,
    calendarEventId: calendarEventId,
    week: game.leagueState.currentWeek,
    day: game.leagueState.currentDay,
  );
}

void _expectPendingUrgent(GameSave game) {
  expect(game.leagueState.inbox.pendingUrgent, hasLength(1));
  final message = game.leagueState.inbox.messages.single;
  expect(message.read, isFalse);
  expect(message.acknowledged, isFalse);
}

Widget _homeResultApp({
  required GameSave game,
  required UpcomingAction action,
  required BatchSimulationResult result,
  required void Function(_FakeHomeController controller) onController,
  Locale locale = const Locale('pl'),
  DaySimulationResult? advanceResult,
}) {
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
            const Scaffold(body: Text('home draft destination')),
      ),
      GoRoute(
        path: '/game/match',
        builder: (context, state) =>
            const Scaffold(body: Text('home match destination')),
      ),
    ],
  );
  final preferences = PreferencesTestDouble(
    initialValues: <String, Object?>{urgentInterruptionSettingKey: false},
  );

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
      nextGameEventProvider.overrideWithValue(action),
      gameControllerProvider.overrideWith((ref) {
        final controller = _FakeHomeController(
          ref,
          game,
          result: result,
          advanceResult: advanceResult,
        );
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

final class _FakeHomeController extends GameController {
  _FakeHomeController(
    super.ref,
    GameSave game, {
    required this.result,
    this.advanceResult,
  }) : _resultGame = game {
    final initialLeague = game.leagueState.copyWith(
      inbox: game.leagueState.inbox.copyWith(messages: const []),
    );
    state = AsyncValue.data(game.copyWith(leagueState: initialLeague));
  }

  final GameSave _resultGame;
  final BatchSimulationResult result;
  final DaySimulationResult? advanceResult;
  var simulateToEventCalls = 0;
  var runEventCalls = 0;
  var advanceOneDayCalls = 0;

  @override
  Future<BatchSimulationResult> simulateToEvent() async {
    simulateToEventCalls++;
    state = AsyncValue.data(_resultGame);
    return result;
  }

  @override
  Future<void> runEventAtCurrentDay(CalendarEventId eventId) async {
    runEventCalls++;
  }

  @override
  Future<DaySimulationResult?> advanceOneDay({
    bool resolveContractMarket = true,
  }) async {
    advanceOneDayCalls++;
    return advanceResult;
  }
}
