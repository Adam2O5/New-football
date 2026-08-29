@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  GameMessage message({
    required String id,
    required String title,
    required MessageDomain domain,
    MessagePriority priority = MessagePriority.normal,
    bool read = false,
  }) {
    return GameMessage(
      id: id,
      type: MessageType.system,
      domain: domain,
      priority: priority,
      seasonYear: 2026,
      week: 4,
      day: 2,
      titleKey: 'msg_system_title',
      bodyKey: 'msg_system_body',
      args: {'_legacyTitle': title, '_legacyBody': 'Treść $title'},
      read: read,
    );
  }

  LeagueStateFixture fixture() {
    final league = GameFactory()
        .create(
          const NewGameRequest(
            saveName: 'Task 9 UI',
            playerTeamId: 'team_europe_0',
            seed: 9,
          ),
        )
        .leagueState;
    return LeagueStateFixture(
      league: league.copyWith(
        inbox: Inbox(
          messages: [
            message(
              id: 'urgent',
              title: 'Pilna wiadomość',
              domain: MessageDomain.health,
              priority: MessagePriority.urgent,
            ),
            message(
              id: 'unread',
              title: 'Nieprzeczytany raport',
              domain: MessageDomain.trades,
            ),
            message(
              id: 'read',
              title: 'Przeczytany raport',
              domain: MessageDomain.health,
              read: true,
            ),
            message(
              id: 'digest',
              title: 'Digest wiadomości',
              domain: MessageDomain.roster,
            ).copyWith(
              payload: {
                'messageIds': ['archived'],
              },
            ),
          ],
          archive: [
            message(
              id: 'archived',
              title: 'Wiadomość archiwalna',
              domain: MessageDomain.roster,
              read: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget app(LeagueStateFixture fixture) {
    return ProviderScope(
      overrides: [activeLeagueProvider.overrideWithValue(fixture.league)],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: InboxScreen()),
      ),
    );
  }

  test('sortInboxMessages pins urgent and keeps unread before read', () {
    final messages = [
      message(
        id: 'read',
        title: 'Read',
        domain: MessageDomain.system,
        read: true,
      ),
      message(id: 'unread', title: 'Unread', domain: MessageDomain.system),
      message(
        id: 'urgent',
        title: 'Urgent',
        domain: MessageDomain.system,
        priority: MessagePriority.urgent,
      ),
    ];

    expect(sortInboxMessages(messages).map((item) => item.id), [
      'urgent',
      'unread',
      'read',
    ]);
  });

  test(
    'decision choice dispatches an effect and acknowledges urgent message',
    () {
      final base = GameFactory()
          .create(
            const NewGameRequest(
              saveName: 'Task 9 decision',
              playerTeamId: 'team_europe_0',
              seed: 10,
            ),
          )
          .leagueState;
      final decision = DecisionSpec(
        options: [
          const MessageAction(id: 'accept', labelKey: 'accept'),
          const MessageAction(id: 'decline', labelKey: 'decline'),
        ],
        defaultOnExpiry: 'decline',
      );
      final league = base.copyWith(
        inbox: Inbox().addMessage(
          GameMessage(
            id: 'decision',
            type: MessageType.playerEvent,
            domain: MessageDomain.playerEvent,
            priority: MessagePriority.urgent,
            seasonYear: 2026,
            week: 1,
            titleKey: 'msg_playerEvent_title',
            bodyKey: 'msg_playerEvent_body',
            decision: decision,
          ),
        ),
      );
      var effectApplied = false;
      var dispatchCount = 0;
      bool? acknowledgedDuringEffect;

      final resolved = MessageService().resolveDecision(
        league,
        'decision',
        'accept',
        onDecision: (state, _, optionId) {
          dispatchCount++;
          effectApplied = optionId == 'accept';
          acknowledgedDuringEffect = state.inbox.messages.single.acknowledged;
          return state.copyWith(currentDay: 2);
        },
      );

      expect(effectApplied, isTrue);
      expect(dispatchCount, 1);
      expect(acknowledgedDuringEffect, isFalse);
      expect(resolved.currentDay, 2);
      expect(resolved.inbox.pendingUrgent, isEmpty);
    },
  );

  test('muted non-decision type is routed to archive, not active inbox', () {
    final league = GameFactory()
        .create(
          const NewGameRequest(
            saveName: 'Task 9 muted',
            playerTeamId: 'team_europe_0',
            seed: 11,
          ),
        )
        .leagueState
        .copyWith(
          messageSettings: MessageSettings().withTypeLevel(
            MessageType.walkover,
            NotificationLevel.muted,
          ),
        );

    final result = MessageService().send(
      league,
      type: MessageType.walkover,
      titleKey: 'msg_walkover_title',
      bodyKey: 'msg_walkover_body',
    );

    expect(result.inbox.messages, isEmpty);
    expect(result.inbox.archive, hasLength(1));
  });

  testWidgets(
    'inbox renders pinned urgent, unread/read sections and domain filter',
    (tester) async {
      final state = fixture();
      await tester.pumpWidget(app(state));

      expect(find.text('Pilne'), findsOneWidget);
      expect(find.text('Nieprzeczytane'), findsOneWidget);
      expect(find.text('Przeczytane'), findsOneWidget);
      expect(find.text('Pilna wiadomość'), findsOneWidget);
      expect(find.text('Nieprzeczytany raport'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'Zdrowie'));
      await tester.pumpAndSettle();

      expect(find.text('Pilna wiadomość'), findsOneWidget);
      expect(find.text('Nieprzeczytany raport'), findsNothing);
      expect(find.text('Przeczytany raport'), findsOneWidget);
    },
  );

  testWidgets('digest details expand to archived component messages', (
    tester,
  ) async {
    final state = fixture();
    await tester.pumpWidget(app(state));

    await tester.tap(find.text('Digest wiadomości'));
    await tester.pumpAndSettle();
    expect(find.text('Wiadomości składowe (1)'), findsOneWidget);

    await tester.tap(find.text('Wiadomości składowe (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Wiadomość archiwalna'), findsOneWidget);
  });

  testWidgets('archive tab displays archived messages separately', (
    tester,
  ) async {
    final state = fixture();
    await tester.pumpWidget(app(state));

    await tester.tap(find.text('Archiwum'));
    await tester.pumpAndSettle();

    expect(find.text('Wiadomość archiwalna'), findsOneWidget);
    expect(find.text('Pilna wiadomość'), findsNothing);
  });
}

class LeagueStateFixture {
  const LeagueStateFixture({required this.league});

  final LeagueState league;
}
