@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/screens/player_detail_screen.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/tactics/player_sort.dart';

import '../helpers/widgets/squad_screen_harness.dart';
import '../helpers/widgets/widget_harness.dart';

void main() {
  testWidgets(
    'preserves roster membership, zone presentation, drag/drop and profile callbacks',
    (tester) async {
      final game = task41Game(seed: 9445);
      final harness = SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final l10n = screenLocalizations(tester);
      final initialTeam = harness.controller.save!.leagueState.playerTeam!;
      final initialRosterIds = initialTeam.roster
          .map((player) => player.id)
          .toList();
      final initialLineupIds = [...initialTeam.lineupPlayerIds];
      final initialBenchIds = [...initialTeam.benchPlayerIds];
      final initialRoster = [...initialTeam.roster];
      final initialTactics = initialTeam.tactics;
      final zones = assignmentZones(initialTeam);

      expect(zones.values, contains(RosterZone.xi));
      expect(zones.values, contains(RosterZone.bench));
      expect(zones.values, contains(RosterZone.reserve));
      expect(rosterRows(tester), hasLength(initialRosterIds.length));
      expect(
        rosterRows(tester).map((row) => row.player.id).toSet(),
        initialRosterIds.toSet(),
      );
      for (final player in initialTeam.roster) {
        final row = rowFinder(player.id);
        expect(row, findsOneWidget);
        expect(
          tester.widget<PlayerListTile>(tileFinder(player.id)).zone,
          zones[player.id],
        );
        expect(
          find.descendant(
            of: row,
            matching: find.text(
              localizedRosterZoneLabel(l10n, zones[player.id]!),
            ),
          ),
          findsOneWidget,
        );
      }

      final metricButtonFinder = find.byType(
        DropdownButton<SquadTileMetricMode>,
      );
      for (final mode in SquadTileMetricMode.values) {
        tester
            .widget<DropdownButton<SquadTileMetricMode>>(metricButtonFinder)
            .onChanged!(mode);
        await tester.pump();
        expect(
          rosterRows(tester).map((row) => row.player.id).toList(),
          sortRoster(
            initialTeam,
            initialTeam.roster,
            PlayerSortMode.assignedZone,
          ).map((player) => player.id).toList(),
        );
        expect(
          tester
              .widget<DropdownButton<SquadTileMetricMode>>(metricButtonFinder)
              .value,
          mode,
        );
      }

      final selfId = initialTeam.benchPlayerIds.first;
      final selfTarget = tester.widget<DragTarget<String>>(
        find.descendant(
          of: tileFinder(selfId),
          matching: find.byType(DragTarget<String>),
        ),
      );
      final selfDetails = DragTargetDetails<String>(
        data: selfId,
        offset: Offset.zero,
      );
      expect(selfTarget.onWillAcceptWithDetails!(selfDetails), isFalse);
      expect(
        harness.controller.save!.leagueState.playerTeam!.lineupPlayerIds,
        initialLineupIds,
      );
      expect(
        harness.controller.save!.leagueState.playerTeam!.benchPlayerIds,
        initialBenchIds,
      );

      final draggedId = initialTeam.lineupPlayerIds.first;
      final targetId = initialTeam.benchPlayerIds.first;
      final target = tester.widget<DragTarget<String>>(
        find.descendant(
          of: tileFinder(targetId),
          matching: find.byType(DragTarget<String>),
        ),
      );
      final otherDetails = DragTargetDetails<String>(
        data: draggedId,
        offset: Offset.zero,
      );
      expect(target.onWillAcceptWithDetails!(otherDetails), isTrue);
      target.onAcceptWithDetails!(otherDetails);
      await tester.pumpAndSettle();

      final afterDrop = harness.controller.save!.leagueState.playerTeam!;
      final expectedLineupIds = [
        for (final id in initialLineupIds) id == draggedId ? targetId : id,
      ];
      final expectedBenchIds = [
        for (final id in initialBenchIds) id == targetId ? draggedId : id,
      ];
      expect(afterDrop.roster, initialRoster);
      expect(afterDrop.lineupPlayerIds, expectedLineupIds);
      expect(afterDrop.benchPlayerIds, expectedBenchIds);
      expect(afterDrop.tactics, initialTactics);
      expect(afterDrop.roster.map((player) => player.id), initialRosterIds);
      expect(find.text(l10n.squad_swappedPlaces), findsOneWidget);

      final infoAction = find.descendant(
        of: rowFinder(targetId),
        matching: find.byType(IconButton),
      );
      expect(infoAction, findsOneWidget);
      tester.widget<IconButton>(infoAction).onPressed!();
      await tester.pumpAndSettle();
      expect(harness.router.state.uri.path, '/game/player/$targetId');
      expect(find.byType(PlayerDetailScreen), findsOneWidget);
      harness.router.pop();
      await tester.pumpAndSettle();
    },
  );
}
