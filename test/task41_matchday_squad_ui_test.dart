import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/matchday_screen.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';

import 'helpers/widget_harness.dart';

void main() {
  testWidgets('Matchday wykonuje zmianę przez arkusz zmian', (tester) async {
    final game = task41Game(seed: 4106);
    final match = game.leagueState.currentSeason.schedule.firstWhere(
      (item) =>
          item.homeTeamId == game.leagueState.playerTeamId ||
          item.awayTeamId == game.leagueState.playerTeamId,
    );

    await tester.pumpWidget(task41App(MatchdayScreen(match: match), game));
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zmiany'));
    await tester.pumpAndSettle();

    final dropdowns = find.byType(DropdownButtonFormField<String>);
    expect(dropdowns, findsNWidgets(2));
    final dropdownButtons = find.byType(DropdownButton<String>);
    expect(dropdownButtons, findsNWidgets(2));
    final outgoing = tester.widget<DropdownButton<String>>(
      dropdownButtons.at(0),
    );
    final incoming = tester.widget<DropdownButton<String>>(
      dropdownButtons.at(1),
    );
    final outgoingId = outgoing.items!.first.value!;
    final incomingId = incoming.items!.first.value!;
    outgoing.onChanged!(outgoingId);
    incoming.onChanged!(incomingId);
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Wykonaj zmianę'));
    await tester.pumpAndSettle();

    expect(find.text('Zmiany: 1'), findsOneWidget);
  });

  testWidgets('Matchday symuluje do końca i pokazuje podsumowanie', (
    tester,
  ) async {
    final game = task41Game(seed: 4107);
    final match = game.leagueState.currentSeason.schedule.firstWhere(
      (item) =>
          item.homeTeamId == game.leagueState.playerTeamId ||
          item.awayTeamId == game.leagueState.playerTeamId,
    );

    await tester.pumpWidget(task41App(MatchdayScreen(match: match), game));
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Do końca'));
    await tester.pumpAndSettle();

    expect(find.text('Podsumowanie meczu'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Squad blokuje wejście kontuzjowanego i zawieszonego gracza', (
    tester,
  ) async {
    late GameController controller;
    final base = task41Game(seed: 4108);
    final baseTeam = base.leagueState.playerTeam!;
    final starterId = baseTeam.lineupPlayerIds.first;
    final injuredId = baseTeam.benchPlayerIds.first;
    final suspendedId = baseTeam.benchPlayerIds[1];
    final injured = baseTeam.roster
        .firstWhere((player) => player.id == injuredId)
        .copyWith(
          state: baseTeam.roster
              .firstWhere((player) => player.id == injuredId)
              .state
              .copyWith(
                injury: const Injury(
                  id: 'task41-injury',
                  group: InjuryGroup.legMuscles,
                  type: InjuryType.minor,
                  daysTotal: 5,
                  daysRemaining: 3,
                ),
              ),
        );
    final suspended = baseTeam.roster
        .firstWhere((player) => player.id == suspendedId)
        .copyWith(
          state: baseTeam.roster
              .firstWhere((player) => player.id == suspendedId)
              .state
              .copyWith(suspensionGamesRemaining: 2),
        );
    final updatedTeam = baseTeam.copyWith(
      roster: [
        for (final player in baseTeam.roster)
          if (player.id == injuredId)
            injured
          else if (player.id == suspendedId)
            suspended
          else
            player,
      ],
    );
    final game = base.copyWith(
      leagueState: base.leagueState.updateTeam(updatedTeam),
    );

    await tester.pumpWidget(
      task41App(
        const Scaffold(body: SquadScreen()),
        game,
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    final rosterScroll = find.byKey(const ValueKey('squad-roster-scroll'));
    for (var i = 0; i < 8; i++) {
      await tester.drag(rosterScroll, const Offset(0, -500));
      await tester.pump();
    }

    Finder tile(String id) => find.byWidgetPredicate(
      (widget) => widget is PlayerListTile && widget.player.id == id,
    );

    final starterTile = tester.widget<PlayerListTile>(tile(starterId));
    starterTile.onTap();
    await tester.pump();
    final injuredTile = tester.widget<PlayerListTile>(tile(injuredId));
    injuredTile.onTap();
    await tester.pump();
    expect(
      controller.save!.leagueState.playerTeam!.lineupPlayerIds,
      contains(starterId),
    );
    expect(
      controller.save!.leagueState.playerTeam!.benchPlayerIds,
      contains(injuredId),
    );

    final starterForSuspension = tester.widget<PlayerListTile>(tile(starterId));
    starterForSuspension.onTap();
    await tester.pump();
    final suspendedTile = tester.widget<PlayerListTile>(tile(suspendedId));
    suspendedTile.onTap();
    await tester.pump();
    expect(
      controller.save!.leagueState.playerTeam!.lineupPlayerIds,
      contains(starterId),
    );
    expect(
      controller.save!.leagueState.playerTeam!.benchPlayerIds,
      contains(suspendedId),
    );
  });
}
