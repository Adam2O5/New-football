@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/game_factory.dart';
import '../helpers/fixtures/game_fixtures.dart';
import '../helpers/widgets/widget_harness.dart';

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

  Widget app(LeagueStateFixture fixture) => task41App(
    const Scaffold(body: InboxScreen()),
    saveForLeague(fixture.league),
  );

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
