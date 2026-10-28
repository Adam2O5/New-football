@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';

import '../helpers/widgets/widget_harness.dart';

void main() {
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
