import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import 'helpers/widget_harness.dart';

void main() {
  testWidgets(
    'baseline: ordinary messages are read without acknowledgement and close normally',
    (tester) async {
      late GameController controller;
      final repository = _RecordingSaveRepository();
      final ordinary = _message(
        id: 'ordinary-baseline',
        title: 'Zwykła wiadomość',
        domain: MessageDomain.health,
      );

      await tester.pumpWidget(
        task41App(
          const Scaffold(body: InboxScreen()),
          _withInbox(task41Game(seed: 4103), Inbox(messages: [ordinary])),
          onController: (value) => controller = value,
          saveRepository: repository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nieprzeczytane'), findsOneWidget);
      expect(find.text('Zwykła wiadomość'), findsOneWidget);
      await tester.tap(find.text('Zwykła wiadomość'));
      await tester.pumpAndSettle();

      expect(find.text('Zwykła wiadomość'), findsNWidgets(2));
      expect(find.text('Potwierdź'), findsNothing);
      expect(find.text('Zamknij'), findsOneWidget);
      await tester.tap(find.text('Zamknij'));
      await tester.pumpAndSettle();

      final after = controller.save!.leagueState.inbox.messages.single;
      expect(after.read, isTrue);
      expect(after.acknowledged, isFalse);
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(
        repository.lastPersisted?.leagueState.inbox.messages.single,
        after,
      );
      expect(find.byType(BottomSheet), findsNothing);
    },
  );

  testWidgets(
    'baseline: already-read and already-acknowledged messages stay unchanged',
    (tester) async {
      late GameController controller;
      final repository = _RecordingSaveRepository();
      final readMessage = _message(
        id: 'already-read-baseline',
        title: 'Już przeczytana',
        domain: MessageDomain.system,
        read: true,
      );
      final acknowledgedUrgent = _message(
        id: 'already-acknowledged-baseline',
        title: 'Już potwierdzona pilna',
        domain: MessageDomain.playerEvent,
        priority: MessagePriority.urgent,
        read: true,
        acknowledged: true,
      );
      final game = _withInbox(
        task41Game(seed: 4104),
        Inbox(messages: [readMessage, acknowledgedUrgent]),
      );

      await tester.pumpWidget(
        task41App(
          const Scaffold(body: InboxScreen()),
          game,
          onController: (value) => controller = value,
          saveRepository: repository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Już przeczytana'));
      await tester.pumpAndSettle();
      expect(find.text('Zamknij'), findsOneWidget);
      await tester.tap(find.text('Zamknij'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Już potwierdzona pilna'));
      await tester.pumpAndSettle();
      expect(find.text('Potwierdź'), findsOneWidget);
      Navigator.of(tester.element(find.byType(InboxScreen))).pop();
      await tester.pumpAndSettle();

      final messages = controller.save!.leagueState.inbox.messages;
      expect(
        messages.firstWhere((message) => message.id == readMessage.id),
        readMessage,
      );
      expect(
        messages.firstWhere((message) => message.id == acknowledgedUrgent.id),
        acknowledgedUrgent,
      );
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(repository.saveCount, 0);
    },
  );

  test(
    'baseline: every existing decision option preserves effect ordering and meaning',
    () {
      final base = task41Game(seed: 4105).leagueState;
      final options = <String, int>{'accept': 2, 'decline': 3};

      for (final entry in options.entries) {
        final message = _decisionMessage(
          id: 'decision-${entry.key}',
          title: 'Decyzja ${entry.key}',
        );
        final league = base.copyWith(inbox: Inbox(messages: [message]));
        final effectTrace = <String>[];

        final resolved = MessageService().resolveDecision(
          league,
          message.id,
          entry.key,
          onDecision: (state, selected, optionId) {
            effectTrace.add(
              '${state.inbox.messages.single.acknowledged}:$optionId:${selected.id}',
            );
            return state.copyWith(currentDay: entry.value);
          },
        );

        expect(effectTrace, ['false:${entry.key}:${message.id}']);
        expect(resolved.currentDay, entry.value);
        expect(resolved.inbox.messages.single.read, isTrue);
        expect(resolved.inbox.messages.single.acknowledged, isTrue);
        expect(resolved.inbox.pendingUrgent, isEmpty);
      }
    },
  );

  test(
    'baseline: seeded inbox ordering keeps urgent first and unread before read',
    () {
      for (final seed in [4103, 4104, 4105]) {
        final random = Random(seed);
        final messages = <GameMessage>[
          _message(
            id: 'seed-$seed-urgent',
            title: 'Seed urgent $seed',
            domain: MessageDomain.playerEvent,
            priority: MessagePriority.urgent,
            read: random.nextBool(),
          ),
          for (var index = 0; index < 6; index++)
            _message(
              id: 'seed-$seed-$index',
              title: 'Seed $seed $index',
              domain: MessageDomain.values[index % MessageDomain.values.length],
              read: index.isEven ? false : random.nextBool(),
            ),
        ];

        final sorted = sortInboxMessages(messages);
        final firstNormal = sorted.indexWhere(
          (message) => message.priority != MessagePriority.urgent,
        );
        expect(firstNormal, greaterThanOrEqualTo(1));
        expect(
          sorted
              .take(firstNormal)
              .every((message) => message.priority == MessagePriority.urgent),
          isTrue,
        );
        final normalMessages = sorted.skip(firstNormal).toList();
        final firstReadNormal = normalMessages.indexWhere(
          (message) => message.read,
        );
        if (firstReadNormal >= 0) {
          expect(
            normalMessages
                .skip(firstReadNormal)
                .every((message) => message.read),
            isTrue,
          );
        }
      }
    },
  );

  testWidgets('baseline: empty inbox and archive retain their empty states', (
    tester,
  ) async {
    await tester.pumpWidget(
      task41App(
        const Scaffold(body: InboxScreen()),
        _withInbox(task41Game(seed: 4106), const Inbox()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Skrzynka pusta'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    await tester.tap(find.text('Archiwum'));
    await tester.pumpAndSettle();
    expect(find.text('Archiwum jest puste'), findsOneWidget);
  });

  test(
    'baseline: pending urgent blocks day advancement until its acknowledgement is persisted',
    () async {
      final repository = _RecordingSaveRepository();
      final message = _message(
        id: 'pending-baseline',
        title: 'Pilna blokada',
        domain: MessageDomain.playerEvent,
        priority: MessagePriority.urgent,
      );
      final game = _withInbox(
        task41Game(seed: 4103),
        Inbox(messages: [message]),
      );
      final container = ProviderContainer(
        overrides: [
          saveRepositoryProvider.overrideWithValue(repository),
          gameControllerProvider.overrideWith((ref) {
            final controller = GameController(ref);
            controller.state = AsyncValue.data(game);
            return controller;
          }),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);
      final before = controller.save!.leagueState;

      final blockedResult = await controller.advanceOneDay();
      expect(blockedResult, isNull);
      expect(controller.save!.leagueState.currentWeek, before.currentWeek);
      expect(controller.save!.leagueState.currentDay, before.currentDay);
      expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));
      expect(
        repository.lastPersisted?.leagueState.inbox.pendingUrgent,
        hasLength(1),
      );

      await controller.acknowledgeMessage(message.id);
      expect(repository.lastPersisted, isNotNull);
      expect(
        repository.lastPersisted!.leagueState.inbox.pendingUrgent,
        isEmpty,
      );
      expect(
        repository
            .lastPersisted!
            .leagueState
            .inbox
            .messages
            .single
            .acknowledged,
        isTrue,
      );

      await controller.advanceOneDay();
      final after = controller.save!.leagueState;
      expect(
        after.currentWeek != before.currentWeek ||
            after.currentDay != before.currentDay,
        isTrue,
      );
    },
  );

  testWidgets(
    'baseline: all shell tabs and local inbox controls remain available with pending urgent',
    (tester) async {
      final urgent = _message(
        id: 'shell-pending-baseline',
        title: 'Pilna shell',
        domain: MessageDomain.playerEvent,
        priority: MessagePriority.urgent,
      );
      final ordinaryHealth = _message(
        id: 'shell-health-baseline',
        title: 'Raport zdrowia shell',
        domain: MessageDomain.health,
      );
      final game = _withInbox(
        task41Game(seed: 4107),
        Inbox(messages: [urgent, ordinaryHealth]),
      );

      await tester.pumpWidget(task41App(const ShellScreen(), game));
      await tester.pumpAndSettle();

      final navigation = find.byType(NavigationBar);
      expect(navigation, findsOneWidget);
      expect(
        tester.widget<NavigationBar>(navigation).destinations,
        hasLength(6),
      );
      for (var index = 0; index < 6; index++) {
        await tester.tap(find.byType(NavigationDestination).at(index));
        await tester.pumpAndSettle();
        expect(tester.widget<NavigationBar>(navigation).selectedIndex, index);
        expect(tester.takeException(), isNull);
      }

      await tester.tap(find.byType(NavigationDestination).last);
      await tester.pumpAndSettle();
      final filter = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Zdrowie'),
      );
      expect(filter.onSelected, isNotNull);
      await tester.tap(find.widgetWithText(FilterChip, 'Zdrowie'));
      await tester.pumpAndSettle();
      expect(find.text('Raport zdrowia shell'), findsOneWidget);

      await tester.tap(find.byTooltip('Powiadomienia'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Poziomy powiadomień'), findsOneWidget);
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'baseline: message actions preserve player, transfer, contract, staff, finance, and prospect routes',
    (tester) async {
      final game = task41Game(seed: 4108);
      final playerId = game.leagueState.playerTeam!.roster.first.id;
      final cases = [
        _RouteCase(
          type: MessageType.system,
          title: 'Akcja gracz',
          payload: {'playerId': playerId},
          path: '/game/player/$playerId',
        ),
        _RouteCase(
          type: MessageType.tradeOffer,
          title: 'Akcja transfer',
          path: '/game/trade',
        ),
        _RouteCase(
          type: MessageType.contractOffer,
          title: 'Akcja kontrakt',
          path: '/game/contracts',
        ),
        _RouteCase(
          type: MessageType.staffHired,
          title: 'Akcja sztab',
          path: '/game/staff',
        ),
        _RouteCase(
          type: MessageType.apronWarning,
          title: 'Akcja finanse',
          path: '/game/finance',
        ),
        _RouteCase(
          type: MessageType.scoutReport,
          title: 'Akcja prospekty',
          path: '/game/prospects',
          query: {'watchlist': 'true', 'combine': 'true'},
        ),
      ];

      for (final testCase in cases) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        late GameController controller;
        final message = _message(
          id: 'route-${testCase.type.name}',
          title: testCase.title,
          domain: _domainFor(testCase.type),
          type: testCase.type,
          payload: testCase.payload,
          actions: const [MessageAction(id: 'open', labelKey: 'open')],
        );
        final harness = _routeApp(
          _withInbox(game, Inbox(messages: [message])),
          onController: (value) => controller = value,
        );
        await tester.pumpWidget(harness.app);
        await tester.pumpAndSettle();

        await tester.tap(find.text(testCase.title));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Otwórz'));
        await tester.pumpAndSettle();

        final uri = harness.destinationUris.last;
        final routeException = tester.takeException();
        expect(
          routeException,
          isNull,
          reason: 'Action route exception; uri=${uri.toString()}',
        );
        expect(
          find.text('Otwórz'),
          findsNothing,
          reason:
              'Action sheet stayed open; uri=${uri.toString()} pushes=${harness.observer.pushes}',
        );
        expect(
          uri.path,
          testCase.path,
          reason: 'Router pushes=${harness.observer.pushes}',
        );
        expect(uri.queryParameters, testCase.query);
        expect(controller.save!.leagueState.inbox.messages.single.read, isTrue);
        expect(tester.takeException(), isNull);
      }
    },
  );
}

GameSave _withInbox(GameSave game, Inbox inbox) =>
    game.copyWith(leagueState: game.leagueState.copyWith(inbox: inbox));

GameMessage _message({
  required String id,
  required String title,
  required MessageDomain domain,
  MessageType type = MessageType.system,
  MessagePriority priority = MessagePriority.normal,
  bool read = false,
  bool acknowledged = false,
  Map<String, dynamic> payload = const {},
  List<MessageAction> actions = const [],
}) => GameMessage(
  id: id,
  type: type,
  domain: domain,
  priority: priority,
  seasonYear: 2026,
  week: 1,
  day: 1,
  titleKey: 'msg_system_title',
  bodyKey: 'msg_system_body',
  args: {'_legacyTitle': title, '_legacyBody': 'Treść $title'},
  payload: payload,
  actions: actions,
  read: read,
  acknowledged: acknowledged,
);

GameMessage _decisionMessage({required String id, required String title}) =>
    _message(
      id: id,
      title: title,
      type: MessageType.playerEvent,
      domain: MessageDomain.playerEvent,
      priority: MessagePriority.urgent,
    ).copyWith(
      decision: const DecisionSpec(
        options: [
          MessageAction(id: 'accept', labelKey: 'accept'),
          MessageAction(id: 'decline', labelKey: 'decline'),
        ],
        defaultOnExpiry: 'decline',
      ),
    );

MessageDomain _domainFor(MessageType type) => switch (type) {
  MessageType.tradeOffer => MessageDomain.trades,
  MessageType.contractOffer => MessageDomain.contracts,
  MessageType.staffHired => MessageDomain.staff,
  MessageType.apronWarning => MessageDomain.finance,
  MessageType.scoutReport => MessageDomain.draft,
  _ => MessageDomain.system,
};

class _RecordingSaveRepository extends SaveRepository {
  int saveCount = 0;
  GameSave? lastPersisted;

  @override
  Future<void> save(GameSave gameSave) async {
    saveCount++;
    lastPersisted = gameSave;
  }
}

class _RouteObserver extends NavigatorObserver {
  final pushes = <String>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes.add(route.settings.name ?? route.runtimeType.toString());
    super.didPush(route, previousRoute);
  }
}

class _RouteCase {
  const _RouteCase({
    required this.type,
    required this.title,
    required this.path,
    this.payload = const {},
    this.query = const {},
  });

  final MessageType type;
  final String title;
  final String path;
  final Map<String, dynamic> payload;
  final Map<String, String> query;
}

({
  Widget app,
  GoRouter router,
  _RouteObserver observer,
  List<Uri> destinationUris,
})
_routeApp(
  GameSave game, {
  required void Function(GameController controller) onController,
}) {
  final observer = _RouteObserver();
  final destinationUris = <Uri>[];
  final router = GoRouter(
    observers: [observer],
    initialLocation: '/game',
    routes: [
      GoRoute(
        path: '/game',
        builder: (context, state) => const Scaffold(body: InboxScreen()),
      ),
      GoRoute(
        path: '/game/player/:id',
        builder: (context, state) {
          destinationUris.add(state.uri);
          return Text('player-route:${state.pathParameters['id']}');
        },
      ),
      GoRoute(
        path: '/game/trade',
        builder: (context, state) {
          destinationUris.add(state.uri);
          return const Text('trade-route');
        },
      ),
      GoRoute(
        path: '/game/contracts',
        builder: (context, state) {
          destinationUris.add(state.uri);
          return const Text('contracts-route');
        },
      ),
      GoRoute(
        path: '/game/staff',
        builder: (context, state) {
          destinationUris.add(state.uri);
          return const Text('staff-route');
        },
      ),
      GoRoute(
        path: '/game/finance',
        builder: (context, state) {
          destinationUris.add(state.uri);
          return const Text('finance-route');
        },
      ),
      GoRoute(
        path: '/game/prospects',
        builder: (context, state) {
          destinationUris.add(state.uri);
          return const Text('prospects-route');
        },
      ),
    ],
  );

  final localizedApp = MaterialApp.router(
    locale: const Locale('pl'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );

  return (
    observer: observer,
    destinationUris: destinationUris,
    router: router,
    app: ProviderScope(
      overrides: [
        saveRepositoryProvider.overrideWithValue(_RecordingSaveRepository()),
        gameControllerProvider.overrideWith((ref) {
          final controller = GameController(ref);
          controller.state = AsyncValue.data(game);
          onController(controller);
          return controller;
        }),
      ],
      child: localizedApp,
    ),
  );
}
