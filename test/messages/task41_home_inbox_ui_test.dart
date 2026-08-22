@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/message.dart';

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

  testWidgets('Inbox rozstrzyga decyzję przez UI i zwalnia urgent pause', (
    tester,
  ) async {
    late GameController controller;
    final game = _gameWithInbox(
      task41Game(seed: 4105),
      Inbox(messages: [_urgentMessage(decision: true)]),
    );

    await tester.pumpWidget(
      task41App(
        const Scaffold(body: InboxScreen()),
        game,
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pilna decyzja'), findsOneWidget);
    await tester.tap(find.text('Pilna decyzja'));
    await tester.pumpAndSettle();

    expect(find.text('Wybierz opcję'), findsOneWidget);
    expect(find.text('Akceptuj'), findsOneWidget);
    await tester.tap(find.text('Akceptuj'));
    await tester.pumpAndSettle();

    expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
    expect(
      controller.save!.leagueState.inbox.messages.single.acknowledged,
      isTrue,
    );
  });
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
