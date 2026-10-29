@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/league_state.dart';

import '../helpers/widgets/squad_screen_harness.dart';
import '../helpers/widgets/widget_harness.dart';

void main() {
  testWidgets(
    'Feature: squad-row-polish, Property 5: TapSwap is a deterministic selection state machine',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final game = task41Game(seed: 9425);
      final harness = SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      try {
        await harness.pump(tester);
        final l10n = screenLocalizations(tester);
        final initialTeam = harness.controller.save!.leagueState.playerTeam!;
        final firstStarter = initialTeam.lineupPlayerIds.first;
        final firstBench = initialTeam.benchPlayerIds.first;
        final initialRosterIds = initialTeam.roster
            .map((player) => player.id)
            .toList();
        final initialLineupIds = [...initialTeam.lineupPlayerIds];
        final initialBenchIds = [...initialTeam.benchPlayerIds];
        final initialZones = assignmentZones(initialTeam);

        PlayerListTile tileFor(String id) =>
            tester.widget<PlayerListTile>(tileFinder(id));

        expectRosterRowSelectionSemantics(
          tester,
          l10n,
          tileFor(firstStarter),
          selected: false,
        );

        tileFor(firstStarter).onTap();
        await tester.pump();
        var currentTeam = harness.controller.save!.leagueState.playerTeam!;
        expect(currentTeam.lineupPlayerIds, initialLineupIds);
        expect(currentTeam.benchPlayerIds, initialBenchIds);
        expect(currentTeam.roster.map((player) => player.id), initialRosterIds);
        expectRosterRowSelectionSemantics(
          tester,
          l10n,
          tileFor(firstStarter),
          selected: true,
        );
        expect(tileFor(firstStarter).selected, isTrue);

        tileFor(firstStarter).onTap();
        await tester.pump();
        currentTeam = harness.controller.save!.leagueState.playerTeam!;
        expect(currentTeam.lineupPlayerIds, initialLineupIds);
        expect(currentTeam.benchPlayerIds, initialBenchIds);
        expect(currentTeam.roster.map((player) => player.id), initialRosterIds);
        expectRosterRowSelectionSemantics(
          tester,
          l10n,
          tileFor(firstStarter),
          selected: false,
        );
        expect(tileFor(firstStarter).selected, isFalse);

        tileFor(firstStarter).onTap();
        await tester.pump();
        tileFor(firstBench).onTap();
        await tester.pumpAndSettle();

        final afterSwap = harness.controller.save!.leagueState.playerTeam!;
        final afterZones = assignmentZones(afterSwap);
        final changedAssignmentIds = initialZones.keys
            .where((id) => initialZones[id] != afterZones[id])
            .toSet();
        final expectedLineupIds = [
          for (final id in initialLineupIds)
            id == firstStarter ? firstBench : id,
        ];
        final expectedBenchIds = [
          for (final id in initialBenchIds)
            id == firstBench ? firstStarter : id,
        ];

        expect(changedAssignmentIds, {firstStarter, firstBench});
        expect(afterSwap.roster.map((player) => player.id), initialRosterIds);
        expect(afterSwap.lineupPlayerIds, expectedLineupIds);
        expect(afterSwap.benchPlayerIds, expectedBenchIds);
        expect(tileFor(firstStarter).selected, isFalse);
        expect(tileFor(firstBench).selected, isFalse);
        expectRosterRowSelectionSemantics(
          tester,
          l10n,
          tileFor(firstStarter),
          selected: false,
        );
        expectRosterRowSelectionSemantics(
          tester,
          l10n,
          tileFor(firstBench),
          selected: false,
        );
        expect(find.text(l10n.squad_swappedPlaces), findsOneWidget);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'keeps tap swap, same-row deselection, drag/drop and rejected lists intact',
    (tester) async {
      final game = task41Game(seed: 9404);
      final harness = SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final initialTeam = harness.controller.save!.leagueState.playerTeam!;
      final firstStarter = initialTeam.lineupPlayerIds[0];
      final firstBench = initialTeam.benchPlayerIds[0];
      final secondStarter = initialTeam.lineupPlayerIds[1];
      final secondBench = initialTeam.benchPlayerIds[1];

      final initialLineup = [...initialTeam.lineupPlayerIds];
      final initialBench = [...initialTeam.benchPlayerIds];
      tester.widget<PlayerListTile>(tileFinder(firstStarter)).onTap();
      await tester.pump();
      expect(
        tester.widget<PlayerListTile>(tileFinder(firstStarter)).selected,
        isTrue,
      );
      tester.widget<PlayerListTile>(tileFinder(firstStarter)).onTap();
      await tester.pump();
      expect(
        tester.widget<PlayerListTile>(tileFinder(firstStarter)).selected,
        isFalse,
      );
      expect(
        harness.controller.save!.leagueState.playerTeam!.lineupPlayerIds,
        initialLineup,
      );
      expect(
        harness.controller.save!.leagueState.playerTeam!.benchPlayerIds,
        initialBench,
      );

      tester.widget<PlayerListTile>(tileFinder(firstStarter)).onTap();
      tester.widget<PlayerListTile>(tileFinder(firstBench)).onTap();
      await tester.pumpAndSettle();
      var updatedTeam = harness.controller.save!.leagueState.playerTeam!;
      expect(updatedTeam.lineupPlayerIds, contains(firstBench));
      expect(updatedTeam.lineupPlayerIds, isNot(contains(firstStarter)));
      expect(updatedTeam.benchPlayerIds, contains(firstStarter));
      expect(
        find.text(screenLocalizations(tester).squad_swappedPlaces),
        findsOneWidget,
      );

      final dragTargetFinder = find.descendant(
        of: tileFinder(secondBench),
        matching: find.byType(DragTarget<String>),
      );
      expect(dragTargetFinder, findsOneWidget);
      final dragTarget = tester.widget<DragTarget<String>>(dragTargetFinder);
      final details = DragTargetDetails<String>(
        data: secondStarter,
        offset: Offset.zero,
      );
      expect(dragTarget.onWillAcceptWithDetails!(details), isTrue);
      dragTarget.onAcceptWithDetails!(details);
      await tester.pumpAndSettle();
      updatedTeam = harness.controller.save!.leagueState.playerTeam!;
      expect(updatedTeam.lineupPlayerIds, contains(secondBench));
      expect(updatedTeam.lineupPlayerIds, isNot(contains(secondStarter)));
      expect(updatedTeam.benchPlayerIds, contains(secondStarter));
    },
  );
}
