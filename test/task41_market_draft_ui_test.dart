import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/contract_screen.dart';
import 'package:new_football/app/screens/draft_screen.dart';
import 'package:new_football/app/screens/trade_screen.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/trade_models.dart';
import 'package:new_football/core/models/seed_data_generator.dart';

import 'helpers/widget_harness.dart';

void main() {
  testWidgets('TradeScreen pokazuje konkretny powód odrzucenia oferty', (
    tester,
  ) async {
    final base = task41Game(seed: 4109);
    final league = base.leagueState;
    final own = league.playerTeam!;
    final target = league.teams.firstWhere((team) => team.id != own.id);
    const reason = 'Rozmowy z tym klubem są czasowo zablokowane';
    final blocked = league.copyWith(
      tradeHistory: [
        TradeHistoryEntry(
          id: 'task41-trade-block',
          teamAId: own.id,
          teamBId: target.id,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          day: league.currentDay,
          outcome: 'hardRejected',
        ),
      ],
    );
    final game = base.copyWith(leagueState: blocked);

    await tester.pumpWidget(
      task41App(
        TradeScreen(
          initialOwnPlayerId: own.roster.first.id,
          initialTargetTeamId: target.id,
          initialTheirPlayerId: target.roster.first.id,
        ),
        game,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(reason), findsOneWidget);
    final submitButton = find.widgetWithText(FilledButton, 'Zatwierdź wymianę');
    await tester.scrollUntilVisible(
      submitButton,
      400,
      scrollable: _verticalScrollable(),
    );
    final submitWidget = tester.widget<FilledButton>(submitButton);
    expect(submitWidget.onPressed, isNotNull);
    submitWidget.onPressed!();
    await tester.pumpAndSettle();
    expect(find.text(reason), findsWidgets);
  });

  testWidgets('ContractScreen przesuwa zegar trybu godzinowego', (
    tester,
  ) async {
    late GameController controller;
    final base = task41Game(seed: 4110);
    final source = base.leagueState.playerTeam!.roster.first;
    final freeAgent = source.copyWith(
      id: 'task41-free-agent',
      name: 'Task 41 Free Agent',
      contract: source.contract.copyWith(yearsRemaining: 0),
    );
    final league = base.leagueState.copyWith(
      currentWeek: 47,
      currentDay: 1,
      currentHour: 1,
      freeAgents: [freeAgent],
    );
    final game = base.copyWith(leagueState: league);

    await tester.pumpWidget(
      task41App(
        const ContractScreen(),
        game,
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wolna agentura — faza I'), findsOneWidget);
    expect(find.textContaining('Godzina ofert: 1/10'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Task 41 Free Agent'),
      400,
      scrollable: _verticalScrollable(),
    );
    await tester.tap(find.text('Task 41 Free Agent'));
    await tester.pump();
    expect(find.text('Podgląd oferty: Task 41 Free Agent'), findsOneWidget);

    final vertical = _verticalScrollable();
    for (var i = 0; i < 8; i++) {
      await tester.drag(vertical, const Offset(0, 500));
      await tester.pump();
    }
    await tester.tap(find.text('Przejdź o godzinę'));
    await tester.pumpAndSettle();

    expect(controller.save!.leagueState.currentHour, 2);
    expect(find.textContaining('Godzina ofert: 2/10'), findsOneWidget);
  });

  testWidgets('Draft pozwala dojść do tury gracza i wybrać prospekta', (
    tester,
  ) async {
    late GameController controller;
    final base = task41Game(seed: 4111);
    final league = base.leagueState;
    final playerTeamId = league.playerTeamId!;
    final prospect = GameFactoryDraftFixture.prospect();
    final draft = DraftState(
      year: league.currentSeason.year + 1,
      order: [
        DraftPick(
          id: 'task41-pick-1',
          year: league.currentSeason.year + 1,
          round: 1,
          pickNumber: 1,
          teamId: playerTeamId,
          originalTeamId: playerTeamId,
        ),
      ],
      draftClass: DraftClass(
        year: league.currentSeason.year + 1,
        prospects: [prospect],
      ),
    );
    final game = base.copyWith(
      leagueState: league.copyWith(
        currentSeason: league.currentSeason.copyWith(draftState: draft),
      ),
    );

    await tester.pumpWidget(
      task41App(
        const DraftScreen(),
        game,
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rozpocznij draft'));
    await tester.pump();
    await tester.tap(find.text('Symuluj do mojego wyboru'));
    await tester.pumpAndSettle();

    expect(
      find.text('Twoja kolej! Wybierz prospekta z zakładki Prospekty.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Prospekty'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(prospect.name));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Wybierz gracza'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draft Order'));
    await tester.pumpAndSettle();

    expect(find.text('Draft zakończony!'), findsOneWidget);
    expect(
      controller.save!.leagueState.currentSeason.draftState!.currentPickIndex,
      1,
    );
  });
}

class GameFactoryDraftFixture {
  static Prospect prospect() => SeedDataGenerator()
      .generateDraftClass(year: 2027, prospectCount: 1)
      .prospects
      .single;
}

Finder _verticalScrollable() => find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable && widget.axisDirection == AxisDirection.down,
);
