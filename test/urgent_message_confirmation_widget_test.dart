import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/team_event_service.dart';
import 'package:new_football/data/save_repository.dart';

import 'helpers/widget_harness.dart';

void main() {
  testWidgets(
    'acknowledgement bursts of 2, 5, and 10 taps commit once for 0 and 300 ms',
    (tester) async {
      for (final delay in const [Duration.zero, Duration(milliseconds: 300)]) {
        for (final taps in [2, 5, 10]) {
          await _resetWidget(tester);
          late GameController controller;
          final repository = _WidgetSaveRepository(
            delay: delay,
            waitForRelease: true,
          );
          final observer = _PopupObserver();
          final game = _withInbox(
            task41Game(seed: 4103),
            Inbox(messages: [_urgentMessage(read: true)]),
          );

          await tester.pumpWidget(
            task41App(
              const Scaffold(body: InboxScreen()),
              game,
              saveRepository: repository,
              navigatorObservers: [observer],
              onController: (value) => controller = value,
            ),
          );
          await tester.pumpAndSettle();
          await _openDetails(tester);

          final acknowledge = find.widgetWithText(FilledButton, 'Potwierdź');
          final callback = tester.widget<FilledButton>(acknowledge).onPressed;
          expect(callback, isNotNull);
          for (var index = 0; index < taps; index++) {
            callback!();
          }
          await tester.pump();

          expect(find.text('Zapisywanie potwierdzenia…'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(tester.widget<FilledButton>(acknowledge).onPressed, isNull);
          expect(repository.saveCount, 1);
          expect(repository.completedSaves, isEmpty);
          expect(
            controller.save!.leagueState.inbox.pendingUrgent,
            hasLength(1),
          );
          expect(observer.popupPushCount, 1);
          expect(observer.popupPopCount, 0);

          repository.release();
          await _pumpAsync(tester);

          expect(repository.saveCount, 1);
          expect(repository.completedSaves, hasLength(1));
          expect(controller.save, same(repository.completedSaves.single));
          expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
          expect(
            controller.save!.leagueState.inbox.messages.single.acknowledged,
            isTrue,
          );
          expect(observer.popupPushCount, 1);
          expect(observer.popupPopCount, 1);
          expect(find.byType(BottomSheet), findsNothing);
          expect(find.byType(InboxScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'decision bursts disable both options and commit one domain effect',
    (tester) async {
      late GameController controller;
      final repository = _WidgetSaveRepository(waitForRelease: true);
      final observer = _PopupObserver();
      final service = _CountingTeamEventService();
      final base = task41Game(seed: 4103);
      final team = base.leagueState.playerTeam!;
      final message = _decisionMessage(
        id: 'widget-team-decision',
        teamId: team.id,
        playerId: team.roster.first.id,
      );
      final game = _withInbox(base, Inbox(messages: [message]));

      await tester.pumpWidget(
        task41App(
          const Scaffold(body: InboxScreen()),
          game,
          saveRepository: repository,
          navigatorObservers: [observer],
          onController: (value) => controller = value,
          extraOverrides: [teamEventServiceProvider.overrideWithValue(service)],
        ),
      );
      await tester.pumpAndSettle();
      await _openDetails(tester, title: 'Pilna decyzja widget');

      final accept = find.widgetWithText(FilledButton, 'Akceptuj');
      final decline = find.widgetWithText(FilledButton, 'Odrzuć');
      final acceptCallback = tester.widget<FilledButton>(accept).onPressed;
      final declineCallback = tester.widget<FilledButton>(decline).onPressed;
      expect(acceptCallback, isNotNull);
      expect(declineCallback, isNotNull);

      // Deliver the first option and rapid taps on both options before the
      // first repository release. Only the first callback may own the sheet.
      acceptCallback!();
      declineCallback!();
      acceptCallback();
      declineCallback();
      await tester.pump();

      expect(find.text('Zapisywanie potwierdzenia…'), findsOneWidget);
      expect(tester.widget<FilledButton>(accept).onPressed, isNull);
      expect(tester.widget<FilledButton>(decline).onPressed, isNull);
      expect(service.decisionCalls, 1);
      expect(service.successfulEffects, 1);
      expect(repository.saveCount, 1);
      expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));
      expect(observer.popupPopCount, 0);

      repository.release();
      await _pumpAsync(tester);

      expect(service.decisionCalls, 1);
      expect(service.successfulEffects, 1);
      expect(repository.saveCount, 1);
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(
        controller.save!.leagueState.inbox.messages
            .firstWhere((candidate) => candidate.id == message.id)
            .acknowledged,
        isTrue,
      );
      expect(observer.popupPushCount, 1);
      expect(observer.popupPopCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'domain-effect failure stays local and retry commits once after recovery',
    (tester) async {
      late GameController controller;
      final repository = _WidgetSaveRepository(waitForRelease: true);
      final observer = _PopupObserver();
      final service = _CountingTeamEventService(failure: true);
      final base = task41Game(seed: 4103);
      final team = base.leagueState.playerTeam!;
      final message = _decisionMessage(
        id: 'widget-effect-failure',
        teamId: team.id,
        playerId: team.roster.first.id,
      );

      await tester.pumpWidget(
        task41App(
          const Scaffold(body: InboxScreen()),
          _withInbox(base, Inbox(messages: [message])),
          saveRepository: repository,
          navigatorObservers: [observer],
          onController: (value) => controller = value,
          extraOverrides: [teamEventServiceProvider.overrideWithValue(service)],
        ),
      );
      await tester.pumpAndSettle();
      await _openDetails(tester, title: 'Pilna decyzja widget');

      await tester.tap(find.widgetWithText(FilledButton, 'Akceptuj'));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Nie udało się potwierdzić wiadomości. Spróbuj ponownie.'),
        findsOneWidget,
      );
      expect(find.text('Spróbuj ponownie'), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(repository.saveCount, 0);
      expect(repository.completedSaves, isEmpty);
      expect(service.decisionCalls, 1);
      expect(service.successfulEffects, 0);
      expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));
      expect(observer.popupPopCount, 0);

      service.failure = false;
      await tester.tap(find.text('Spróbuj ponownie'));
      await tester.pump();
      expect(find.text('Zapisywanie potwierdzenia…'), findsOneWidget);
      expect(repository.saveCount, 1);
      expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));

      repository.release();
      await _pumpAsync(tester);

      expect(service.decisionCalls, 2);
      expect(service.successfulEffects, 1);
      expect(repository.saveCount, 1);
      expect(repository.completedSaves, hasLength(1));
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(observer.popupPopCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('multiple unread cards share one mark-read gate and one sheet', (
    tester,
  ) async {
    late GameController controller;
    final repository = _WidgetSaveRepository(waitForRelease: true);
    final observer = _PopupObserver();
    final first = _urgentMessage(
      id: 'widget-first-card',
      title: 'Pilna pierwsza',
      read: false,
    );
    final second = _urgentMessage(
      id: 'widget-second-card',
      title: 'Pilna druga',
      read: false,
    );
    final game = _withInbox(
      task41Game(seed: 4103),
      Inbox(messages: [first, second]),
    );

    await tester.pumpWidget(
      task41App(
        const Scaffold(body: InboxScreen()),
        game,
        saveRepository: repository,
        navigatorObservers: [observer],
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    final firstCard = find
        .ancestor(
          of: find.text('Pilna pierwsza'),
          matching: find.byType(ListTile),
        )
        .first;
    final secondCard = find
        .ancestor(of: find.text('Pilna druga'), matching: find.byType(ListTile))
        .first;
    await tester.tap(firstCard);
    await tester.pump();
    expect(repository.saveCount, 1);
    expect(find.byType(BottomSheet), findsNothing);

    for (var index = 0; index < 5; index++) {
      await tester.tap(firstCard);
      await tester.tap(secondCard);
    }
    await tester.pump();
    expect(repository.saveCount, 1);
    expect(observer.popupPushCount, 0);

    repository.release();
    await _pumpAsync(tester);

    expect(repository.saveCount, 1);
    expect(observer.popupPushCount, 1);
    expect(find.text('Pilna pierwsza'), findsNWidgets(2));
    expect(find.text('Pilna druga'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final secondAfter = controller.save!.leagueState.inbox.messages.firstWhere(
      (message) => message.id == second.id,
    );
    expect(secondAfter.read, isFalse);
    Navigator.of(tester.element(find.byType(InboxScreen))).pop();
    await tester.pump();
    expect(observer.popupPopCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'successful confirmation leaves Home and Calendar navigation interactive',
    (tester) async {
      late GameController controller;
      final repository = _WidgetSaveRepository(waitForRelease: true);
      final observer = _PopupObserver();
      final game = _withInbox(
        task41Game(seed: 4103),
        Inbox(messages: [_urgentMessage(read: true)]),
      );

      await tester.pumpWidget(
        task41App(
          const ShellScreen(initialTab: 5),
          game,
          saveRepository: repository,
          navigatorObservers: [observer],
          onController: (value) => controller = value,
        ),
      );
      await tester.pumpAndSettle();
      await _openDetails(tester);
      await _tapAcknowledge(tester);
      await tester.pump();
      expect(find.text('Zapisywanie potwierdzenia…'), findsOneWidget);
      expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));

      repository.release();
      await _pumpAsync(tester);

      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(observer.popupPushCount, 1);
      expect(observer.popupPopCount, 1);
      final navigation = find.byType(NavigationBar);
      expect(tester.widget<NavigationBar>(navigation).selectedIndex, 5);
      await tester.tap(find.byType(NavigationDestination).at(0));
      await tester.pump();
      expect(tester.widget<NavigationBar>(navigation).selectedIndex, 0);
      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pump();
      expect(tester.widget<NavigationBar>(navigation).selectedIndex, 1);
      expect(find.byType(ShellScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'confirmation reserves the sheet and disables every local control while saving',
    (tester) async {
      late GameController controller;
      final repository = _WidgetSaveRepository(waitForRelease: true);
      final observer = _PopupObserver();
      final game = _withInbox(
        task41Game(seed: 4103),
        Inbox(messages: [_urgentMessage(read: true, withAction: true)]),
      );

      await tester.pumpWidget(
        task41App(
          const Scaffold(body: InboxScreen()),
          game,
          saveRepository: repository,
          navigatorObservers: [observer],
          onController: (value) => controller = value,
        ),
      );
      await tester.pumpAndSettle();
      await _openDetails(tester);

      final acknowledge = find.widgetWithText(FilledButton, 'Potwierdź');
      _invokeAcknowledge(tester, acknowledge);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Zapisywanie potwierdzenia…'), findsOneWidget);
      expect(tester.widget<FilledButton>(acknowledge).onPressed, isNull);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Otwórz'),
            )
            .onPressed,
        isNull,
      );
      expect(repository.saveCount, 1);
      expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));

      // Further taps are ignored while the first acknowledgement owns the
      // operation and the sheet remains mounted.
      await tester.tap(acknowledge, warnIfMissed: false);
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Otwórz'),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(repository.saveCount, 1);
      expect(observer.popupPopCount, 0);

      repository.release();
      await _pumpAsync(tester);

      expect(repository.saveCount, 1);
      expect(observer.popupPushCount, 1);
      expect(observer.popupPopCount, 1);
      expect(find.byType(InboxScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget.runtimeType.toString().startsWith('SegmentedButton'),
        ),
        findsOneWidget,
      );
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'persistence failure keeps the sheet open and retry commits once after recovery',
    (tester) async {
      late GameController controller;
      final repository = _WidgetSaveRepository(
        waitForRelease: true,
        failure: true,
      );
      final observer = _PopupObserver();
      final game = _withInbox(
        task41Game(seed: 4103),
        Inbox(messages: [_urgentMessage(read: true)]),
      );

      await tester.pumpWidget(
        task41App(
          const Scaffold(body: InboxScreen()),
          game,
          saveRepository: repository,
          navigatorObservers: [observer],
          onController: (value) => controller = value,
        ),
      );
      await tester.pumpAndSettle();
      await _openDetails(tester);

      await _tapAcknowledge(tester);
      await tester.pump();
      repository.release();
      await _pumpAsync(tester);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(
        find.text('Nie udało się potwierdzić wiadomości. Spróbuj ponownie.'),
        findsOneWidget,
      );
      expect(find.text('Spróbuj ponownie'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(observer.popupPopCount, 0);
      expect(repository.completedSaves, isEmpty);
      expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));

      repository.failure = false;
      final retry = find.byIcon(Icons.refresh);
      final retryButton = tester.widget<TextButton>(
        find.ancestor(of: retry, matching: find.byType(TextButton)),
      );
      retryButton.onPressed!();
      await tester.pump();
      await _pumpAsync(tester);

      expect(repository.saveCount, 2);
      expect(observer.popupPopCount, 1);
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'mark-read failure uses a localized message without opening a sheet',
    (tester) async {
      final repository = _WidgetSaveRepository(failure: true);
      final observer = _PopupObserver();
      final game = _withInbox(
        task41Game(seed: 4103),
        Inbox(messages: [_urgentMessage(read: false)]),
      );

      await tester.pumpWidget(
        task41App(
          const Scaffold(body: InboxScreen()),
          game,
          saveRepository: repository,
          navigatorObservers: [observer],
        ),
      );
      await tester.pumpAndSettle();

      final card = find
          .ancestor(
            of: find.text('Pilna wiadomość').first,
            matching: find.byType(ListTile),
          )
          .first;
      await tester.tap(card);
      await tester.pump();
      await tester.pump();

      expect(repository.saveCount, 1);
      expect(find.byType(BottomSheet), findsNothing);
      expect(
        find.text('Nie udało się otworzyć wiadomości. Spróbuj ponownie.'),
        findsOneWidget,
      );
      expect(observer.popupPushCount, 0);
      expect(tester.takeException(), isNull);

      // The failed opening releases its gate; a second attempt may mark the
      // same card read and open exactly one details sheet.
      repository.failure = false;
      await tester.tap(card);
      await tester.pump();
      await _pumpAsync(tester);
      expect(repository.saveCount, 2);
      expect(observer.popupPushCount, 1);
      expect(find.byType(BottomSheet), findsOneWidget);
      Navigator.of(tester.element(find.byType(InboxScreen))).pop();
      await tester.pump();
      expect(observer.popupPopCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'repeated card taps share one mark-read opening and create one sheet',
    (tester) async {
      final repository = _WidgetSaveRepository(waitForRelease: true);
      final observer = _PopupObserver();
      final game = _withInbox(
        task41Game(seed: 4103),
        Inbox(messages: [_urgentMessage(read: false)]),
      );

      await tester.pumpWidget(
        task41App(
          const Scaffold(body: InboxScreen()),
          game,
          saveRepository: repository,
          navigatorObservers: [observer],
        ),
      );
      await tester.pumpAndSettle();

      final card = find
          .ancestor(
            of: find.text('Pilna wiadomość').first,
            matching: find.byType(ListTile),
          )
          .first;
      await tester.tap(card);
      await tester.pump();
      expect(repository.saveCount, 1);
      expect(find.byType(BottomSheet), findsNothing);

      for (var index = 0; index < 5; index++) {
        await tester.tap(card);
        await tester.pump();
      }
      expect(repository.saveCount, 1);
      expect(observer.popupPushCount, 0);

      repository.release();
      await _pumpAsync(tester);
      expect(observer.popupPushCount, 1);
      expect(find.text('Potwierdź'), findsOneWidget);

      Navigator.of(tester.element(find.byType(InboxScreen))).pop();
      await tester.pumpAndSettle();
      expect(observer.popupPopCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'closing the sheet during an acknowledgement does not cause a late pop or lifecycle error',
    (tester) async {
      late GameController controller;
      final repository = _WidgetSaveRepository(waitForRelease: true);
      final observer = _PopupObserver();
      final game = _withInbox(
        task41Game(seed: 4103),
        Inbox(messages: [_urgentMessage(read: true)]),
      );

      await tester.pumpWidget(
        task41App(
          const Scaffold(body: InboxScreen()),
          game,
          saveRepository: repository,
          navigatorObservers: [observer],
          onController: (value) => controller = value,
        ),
      );
      await tester.pumpAndSettle();
      await _openDetails(tester);

      await _tapAcknowledge(tester);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      Navigator.of(tester.element(find.byType(InboxScreen))).pop();
      await tester.pump();
      repository.release();
      await _pumpAsync(tester);

      expect(observer.popupPopCount, 1);
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _openDetails(
  WidgetTester tester, {
  String title = 'Pilna wiadomość',
}) async {
  await tester.tap(find.text(title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  expect(find.byType(BottomSheet), findsOneWidget);
  if (title == 'Pilna decyzja widget') {
    expect(find.text('Akceptuj'), findsOneWidget);
  } else {
    expect(find.text('Potwierdź'), findsOneWidget);
  }
}

Future<void> _tapAcknowledge(WidgetTester tester) async {
  final acknowledge = find.widgetWithText(FilledButton, 'Potwierdź');
  _invokeAcknowledge(tester, acknowledge);
}

void _invokeAcknowledge(WidgetTester tester, Finder acknowledge) {
  final button = tester.widget<FilledButton>(acknowledge);
  expect(button.onPressed, isNotNull);
  button.onPressed!();
}

Future<void> _resetWidget(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _pumpAsync(WidgetTester tester) async {
  for (var index = 0; index < 20; index++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

GameSave _withInbox(GameSave game, Inbox inbox) =>
    game.copyWith(leagueState: game.leagueState.copyWith(inbox: inbox));

GameMessage _urgentMessage({
  required bool read,
  bool withAction = false,
  String id = 'task34-urgent',
  String title = 'Pilna wiadomość',
}) => GameMessage(
  id: id,
  type: MessageType.playerEvent,
  domain: MessageDomain.playerEvent,
  priority: MessagePriority.urgent,
  seasonYear: 2026,
  week: 1,
  day: 1,
  titleKey: 'msg_playerEvent_title',
  bodyKey: 'msg_playerEvent_body',
  args: {'_legacyTitle': title, '_legacyBody': 'Treść pilnej wiadomości.'},
  actions: withAction
      ? const [MessageAction(id: 'open', labelKey: 'open')]
      : const [],
  read: read,
);

GameMessage _decisionMessage({
  required String id,
  required String teamId,
  required String playerId,
}) => GameMessage(
  id: id,
  type: MessageType.teamEvent,
  kind: 'moreMinutesRequest',
  domain: MessageDomain.teamEvent,
  priority: MessagePriority.urgent,
  seasonYear: 2026,
  week: 1,
  day: 1,
  titleKey: 'msg_teamEvent_moreMinutesRequest_title',
  bodyKey: 'msg_teamEvent_moreMinutesRequest_body',
  args: const {
    '_legacyTitle': 'Pilna decyzja widget',
    '_legacyBody': 'Wybierz jedną z opcji.',
  },
  payload: {'teamId': teamId, 'playerId': playerId},
  decision: const DecisionSpec(
    options: [
      MessageAction(id: 'accept', labelKey: 'accept'),
      MessageAction(id: 'decline', labelKey: 'decline'),
    ],
    defaultOnExpiry: 'decline',
  ),
  read: true,
);

class _PopupObserver extends NavigatorObserver {
  int popupPushCount = 0;
  int popupPopCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute<dynamic>) popupPushCount++;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute<dynamic>) popupPopCount++;
    super.didPop(route, previousRoute);
  }
}

class _CountingTeamEventService extends TeamEventService {
  _CountingTeamEventService({this.failure = false});

  bool failure;
  int decisionCalls = 0;
  int successfulEffects = 0;

  @override
  LeagueState resolveDecision(
    LeagueState league,
    GameMessage message,
    String optionId, {
    int saveSeed = 0,
  }) {
    decisionCalls++;
    if (failure) {
      throw StateError('Widget-controlled domain effect failure');
    }
    successfulEffects++;
    return super.resolveDecision(league, message, optionId, saveSeed: saveSeed);
  }
}

class _WidgetSaveRepository extends SaveRepository {
  _WidgetSaveRepository({
    this.delay = Duration.zero,
    this.waitForRelease = false,
    this.failure = false,
  });

  final Duration delay;
  final bool waitForRelease;
  bool failure;
  final Completer<void> _releaseCompleter = Completer<void>();

  int saveCount = 0;
  final attemptedSaves = <GameSave>[];
  final completedSaves = <GameSave>[];

  @override
  Future<void> save(GameSave gameSave) async {
    saveCount++;
    attemptedSaves.add(gameSave);
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (waitForRelease) await _releaseCompleter.future;
    if (failure) {
      throw SaveRepositoryException('Widget-controlled save failure');
    }
    completedSaves.add(gameSave);
  }

  void release() {
    if (!_releaseCompleter.isCompleted) _releaseCompleter.complete();
  }
}
