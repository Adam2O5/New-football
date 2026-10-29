@Tags(['ui'])
library;

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

import '../helpers/fixtures/game_fixtures.dart';
import '../helpers/persistence/memory_save_repository.dart';
import '../helpers/widgets/widget_harness.dart';

void main() {
  final base = controllerSave();
  for (final decision in [false, true]) {
    for (var taps = 2; taps <= 10; taps++) {
      testWidgets(
        '${decision ? 'decision' : 'acknowledgement'}: $taps taps share one save and one sheet close',
        (tester) async {
          final fixture = await _mount(tester, base, decision: decision);
          final gate = Completer<void>();
          fixture.repository.writeGate = gate;
          await _open(tester);
          final primary = find.widgetWithText(
            FilledButton,
            decision ? 'Akceptuj' : 'Potwierdź',
          );
          final submit = tester.widget<FilledButton>(primary).onPressed!;
          final other = decision
              ? tester
                    .widget<FilledButton>(
                      find.widgetWithText(FilledButton, 'Odrzuć'),
                    )
                    .onPressed!
              : tester
                    .widget<OutlinedButton>(
                      find.widgetWithText(OutlinedButton, 'Otwórz'),
                    )
                    .onPressed!;
          for (var tap = 0; tap < taps; tap++) {
            submit();
            other();
          }
          await tester.pump();
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(tester.widget<FilledButton>(primary).onPressed, isNull);
          expect(
            tester
                .widget<OutlinedButton>(
                  find.widgetWithText(OutlinedButton, 'Otwórz'),
                )
                .onPressed,
            isNull,
          );
          if (decision) {
            expect(
              tester
                  .widget<TextButton>(
                    find.widgetWithText(TextButton, 'Zamknij'),
                  )
                  .onPressed,
              isNull,
            );
          }
          if (decision) {
            expect(
              tester
                  .widget<FilledButton>(
                    find.widgetWithText(FilledButton, 'Odrzuć'),
                  )
                  .onPressed,
              isNull,
            );
            expect(fixture.decisions.options, ['accept']);
            expect(fixture.decisions.acknowledgedDuringEffect, [false]);
          }
          // Publication and durability are deliberately separate assertions.
          expect(
            fixture.controller.save!.leagueState.inbox.pendingUrgent,
            isEmpty,
          );
          expect(
            fixture.repository.game.leagueState.inbox.pendingUrgent,
            hasLength(1),
          );
          expect(fixture.repository.writes, isEmpty);
          expect(fixture.observer.pops, 0);
          gate.complete();
          await tester.pumpAndSettle();
          expect(fixture.repository.writes, hasLength(1));
          expect(
            fixture.repository.game.leagueState.inbox.pendingUrgent,
            isEmpty,
          );
          expect(find.byType(BottomSheet), findsNothing);
          expect(fixture.observer.pushes, 1);
          expect(fixture.observer.pops, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'domain error stays in the sheet; retry applies the effect once',
    (tester) async {
      final fixture = await _mount(tester, base, decision: true);
      fixture.decisions.error = StateError('controlled decision failure');
      await _open(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Akceptuj'));
      await tester.pumpAndSettle();
      expect(
        find.text('Nie udało się potwierdzić wiadomości. Spróbuj ponownie.'),
        findsOneWidget,
      );
      expect(find.text('Spróbuj ponownie'), findsOneWidget);
      expect(
        fixture.controller.save!.leagueState.inbox.pendingUrgent,
        hasLength(1),
      );
      expect(fixture.repository.writes, isEmpty);
      fixture.decisions.error = null;
      await tester.tap(find.text('Spróbuj ponownie'));
      await tester.pumpAndSettle();
      expect(fixture.decisions.options, ['accept', 'accept']);
      expect(fixture.decisions.successfulEffects, 1);
      expect(
        fixture.repository.game.leagueState.currentDay,
        base.leagueState.currentDay + 1,
      );
      expect(fixture.observer.pops, 1);
    },
  );

  testWidgets(
    'card bursts reserve the first message until queued mark-read completes',
    (tester) async {
      final fixture = await _mount(
        tester,
        base,
        unread: true,
        secondMessage: true,
      );
      final gate = Completer<void>();
      addTearDown(() {
        if (!gate.isCompleted) gate.complete();
      });
      final blocked = fixture.controller.enqueueSaveManagement(
        () => gate.future,
      );
      final first = tester
          .widget<ListTile>(
            find
                .ancestor(
                  of: find.text('Confirmation'),
                  matching: find.byType(ListTile),
                )
                .first,
          )
          .onTap!;
      final second = tester
          .widget<ListTile>(
            find
                .ancestor(
                  of: find.text('Second message'),
                  matching: find.byType(ListTile),
                )
                .first,
          )
          .onTap!;
      for (var tap = 0; tap < 10; tap++) {
        first();
        second();
      }
      await tester.pump();
      expect(find.byType(BottomSheet), findsNothing);
      gate.complete();
      await blocked;
      await tester.pumpAndSettle();
      expect(fixture.observer.pushes, 1);
      expect(find.text('Confirmation'), findsNWidgets(2));
      final messages = fixture.controller.save!.leagueState.inbox.messages;
      expect(messages.first.read, isTrue);
      expect(messages.last.read, isFalse);
      expect(messages.every((message) => !message.acknowledged), isTrue);
      expect(fixture.repository.writes, hasLength(1));
    },
  );

  testWidgets(
    'failed mark-read autosave does not prevent opening or acknowledge the message',
    (tester) async {
      final fixture = await _mount(tester, base, unread: true);
      final failure = StateError('controlled read autosave failure');
      fixture.repository.writeError = failure;
      await _open(tester);
      await expectLater(
        fixture.controller.flushPendingSave(),
        throwsA(same(failure)),
      );
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Spróbuj ponownie'), findsNothing);
      expect(
        fixture.controller.save!.leagueState.inbox.messages.single.read,
        isTrue,
      );
      expect(
        fixture.controller.save!.leagueState.inbox.pendingUrgent,
        hasLength(1),
      );
      expect(
        fixture.repository.game.leagueState.inbox.messages.single.read,
        isFalse,
      );
      fixture.repository.writeError = null;
      await tester.tap(find.widgetWithText(FilledButton, 'Potwierdź'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(fixture.repository.writes, hasLength(1));
      expect(
        fixture.repository.game.leagueState.inbox.messages.single.read,
        isTrue,
      );
      expect(fixture.repository.game.leagueState.inbox.pendingUrgent, isEmpty);
    },
  );

  testWidgets(
    'external sheet removal while saving never pops the underlying page',
    (tester) async {
      final fixture = await _mount(tester, base);
      final gate = Completer<void>();
      fixture.repository.writeGate = gate;
      await _open(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Potwierdź'));
      await tester.pump();
      Navigator.of(tester.element(find.byType(InboxScreen))).pop();
      await tester.pump();
      gate.complete();
      await tester.pumpAndSettle();
      expect(fixture.observer.pops, 1);
      expect(find.byType(InboxScreen), findsOneWidget);
      expect(fixture.repository.game.leagueState.inbox.pendingUrgent, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Home and Calendar stay interactive after a durable confirmation',
    (tester) async {
      final fixture = await _mount(tester, task41Game(seed: 4103), shell: true);
      await _open(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Potwierdź'));
      await tester.pumpAndSettle();
      expect(fixture.repository.game.leagueState.inbox.pendingUrgent, isEmpty);
      for (final index in [0, 1]) {
        await tester.tap(find.byType(NavigationDestination).at(index));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          index,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Confirmation').first);
  await tester.pumpAndSettle();
  expect(find.byType(BottomSheet), findsOneWidget);
}

Future<_Fixture> _mount(
  WidgetTester tester,
  GameSave base, {
  bool decision = false,
  bool unread = false,
  bool secondMessage = false,
  bool shell = false,
}) async {
  final message = GameMessage(
    id: 'confirmation',
    type: decision ? MessageType.teamEvent : MessageType.system,
    priority: MessagePriority.urgent,
    seasonYear: 2026,
    week: 1,
    titleKey: 'test_confirmation_title',
    bodyKey: 'test_confirmation_body',
    args: const {
      '_legacyTitle': 'Confirmation',
      '_legacyBody': 'Choose a response.',
    },
    read: !unread,
    actions: const [MessageAction(id: 'open', labelKey: 'open')],
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
  final game = base.copyWith(
    leagueState: base.leagueState.copyWith(
      inbox: Inbox(
        messages: [
          message,
          if (secondMessage)
            message.copyWith(
              id: 'second',
              args: const {
                '_legacyTitle': 'Second message',
                '_legacyBody': 'Another response.',
              },
            ),
        ],
      ),
    ),
  );
  final repository = MemorySaveRepository(game);
  final observer = _PopupObserver();
  final decisions = _Decisions();
  late GameController controller;
  await tester.pumpWidget(
    task41App(
      shell
          ? const ShellScreen(initialTab: 5)
          : const Scaffold(body: InboxScreen()),
      game,
      saveRepository: repository,
      navigatorObservers: [observer],
      onController: (value) => controller = value,
      extraOverrides: [teamEventServiceProvider.overrideWithValue(decisions)],
    ),
  );
  addTearDown(() async {
    repository.releasePendingWrites();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  await tester.pumpAndSettle();
  return _Fixture(controller, repository, observer, decisions);
}

class _Fixture {
  const _Fixture(
    this.controller,
    this.repository,
    this.observer,
    this.decisions,
  );
  final GameController controller;
  final MemorySaveRepository repository;
  final _PopupObserver observer;
  final _Decisions decisions;
}

class _PopupObserver extends NavigatorObserver {
  int pushes = 0;
  int pops = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute) pushes++;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute) pops++;
  }
}

class _Decisions extends TeamEventService {
  Object? error;
  final options = <String>[];
  final acknowledgedDuringEffect = <bool>[];
  int successfulEffects = 0;
  @override
  LeagueState resolveDecision(
    LeagueState league,
    GameMessage message,
    String optionId, {
    int saveSeed = 0,
  }) {
    options.add(optionId);
    acknowledgedDuringEffect.add(message.acknowledged);
    if (error != null) throw error!;
    successfulEffects++;
    return league.copyWith(currentDay: league.currentDay + 1);
  }
}
