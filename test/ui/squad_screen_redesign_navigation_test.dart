@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/screens/player_detail_screen.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/app/widgets/tactics/substitute_sheet.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';

import '../helpers/widgets/squad_screen_harness.dart';
import '../helpers/widgets/widget_harness.dart';

void main() {
  testWidgets(
    'opens substitute sheet, applies accepted swap and navigates profile',
    (tester) async {
      final game = task41Game(seed: 9406);
      final harness = SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final team = harness.controller.save!.leagueState.playerTeam!;
      final l10n = screenLocalizations(tester);
      final outgoing = team.lineupPlayerIds.first;
      final candidate = team.benchPlayerIds.first;
      final outgoingPlayer = team.roster.firstWhere(
        (player) => player.id == outgoing,
      );
      final candidatePlayer = team.roster.firstWhere(
        (player) => player.id == candidate,
      );

      final pitchBeforeSheet = tester.widget<PitchField>(
        find.byKey(const ValueKey('squad-pitch-field')),
      );
      final outgoingPlacement = pitchBeforeSheet.precomputedPlacements!
          .firstWhere((item) => item.player?.id == outgoing);
      final outgoingStatus = statusFor(outgoingPlayer, outgoingPlacement.slot);
      final outgoingMarkerStatus = <String>[
        if (outgoingStatus.hasActiveInjury) l10n.squad_statusInjury,
        if (outgoingStatus.hasActiveSuspension) l10n.squad_statusSuspension,
        if (outgoingStatus.hasPositionMismatch) l10n.squad_positionMismatch,
      ].join(', ');
      final markerFinder = find.bySemanticsLabel(
        l10n.squad_playerMarkerSemantics(
          outgoingPlayer.name,
          outgoingPlayer.position.code,
          outgoingMarkerStatus,
        ),
      );
      expect(markerFinder, findsOneWidget);
      await tester.tap(markerFinder);
      await tester.pumpAndSettle();

      final sheet = find.byType(SubstituteSheet);
      expect(sheet, findsOneWidget);
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(l10n.substitute_sheetTitle(outgoingPlayer.name)),
        ),
        findsOneWidget,
      );
      expect(outgoingPlayer.position, Position.gk);
      final expectedCandidateIds = team.roster
          .where(
            (player) =>
                !team.lineupPlayerIds.contains(player.id) &&
                player.position == Position.gk,
          )
          .map((player) => player.id)
          .toSet();
      expect(
        tester
            .widget<SubstituteSheet>(sheet)
            .candidates
            .map((player) => player.id)
            .toSet(),
        expectedCandidateIds,
      );
      final candidateFinder = find.descendant(
        of: sheet,
        matching: find.byWidgetPredicate(
          (widget) => widget is PlayerListTile && widget.player.id == candidate,
        ),
      );
      await tester.ensureVisible(candidateFinder);
      expect(candidateFinder, findsOneWidget);
      await tester.tap(candidateFinder);
      await tester.pumpAndSettle();

      final afterSheet = harness.controller.save!.leagueState.playerTeam!;
      expect(afterSheet.lineupPlayerIds, contains(candidate));
      expect(afterSheet.lineupPlayerIds, isNot(contains(outgoing)));
      expect(afterSheet.benchPlayerIds, contains(outgoing));
      expect(find.byType(SubstituteSheet), findsNothing);
      expect(find.text(l10n.squad_swappedPlaces), findsOneWidget);

      final profileRow = rowFinder(candidate);
      final profileAction = find.descendant(
        of: profileRow,
        matching: find.byType(IconButton),
      );
      expect(profileAction, findsOneWidget);
      tester.widget<IconButton>(profileAction).onPressed!();
      await tester.pumpAndSettle();
      expect(harness.router.state.uri.path, '/game/player/$candidate');
      expect(find.byType(PlayerDetailScreen), findsOneWidget);
      expect(find.text(candidatePlayer.name), findsOneWidget);
    },
  );

  testWidgets(
    'keeps Tactics_Tab isolated and preserves state across tab switches',
    (tester) async {
      final game = task41Game(seed: 9446);
      final harness = SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final l10n = screenLocalizations(tester);
      final initialTeam = harness.controller.save!.leagueState.playerTeam!;
      final initialRoster = [...initialTeam.roster];
      final initialLineupIds = [...initialTeam.lineupPlayerIds];
      final initialBenchIds = [...initialTeam.benchPlayerIds];
      final tacticsPlayer = initialTeam.roster.firstWhere(
        (player) =>
            initialTeam.lineupPlayerIds.contains(player.id) &&
            player.isAvailable,
      );
      final selectedId = initialTeam.roster.last.id;

      final metricButtonFinder = find.byType(
        DropdownButton<SquadTileMetricMode>,
      );
      tester
          .widget<DropdownButton<SquadTileMetricMode>>(metricButtonFinder)
          .onChanged!(SquadTileMetricMode.potential);
      await tester.pump();
      tester.widget<PlayerListTile>(tileFinder(selectedId)).onTap();
      await tester.pump();
      expect(
        tester.widget<PlayerListTile>(tileFinder(selectedId)).selected,
        isTrue,
      );

      final tabs = find.byType(Tab);
      expect(tabs, findsNWidgets(2));
      await tester.tap(tabs.at(1));
      await tester.pumpAndSettle();

      final tacticsPitchFinder = find.descendant(
        of: find.byKey(const ValueKey('squad-tactics-scroll')),
        matching: find.byType(PitchField),
      );
      expect(tacticsPitchFinder, findsOneWidget);
      final tacticsPitch = tester.widget<PitchField>(tacticsPitchFinder);
      expect(tacticsPitch.markerStyleBuilder, isNull);
      expect(tacticsPitch.enableDragDrop, isFalse);
      expect(tacticsPitch.onAcceptDrop, isNull);
      expect(tacticsPitch.selectedId, isNull);

      final tacticsMarker = find.descendant(
        of: tacticsPitchFinder,
        matching: find.text(tacticsPlayer.name),
      );
      expect(tacticsMarker, findsOneWidget);
      final tacticsAvatar = tester.widget<CircleAvatar>(
        find
            .descendant(
              of: tacticsPitchFinder,
              matching: find.byType(CircleAvatar),
            )
            .first,
      );
      expect(tacticsAvatar.backgroundColor, Colors.white);

      await tester.tap(tacticsMarker);
      await tester.pumpAndSettle();
      final roleSheet = find.byType(BottomSheet);
      expect(roleSheet, findsOneWidget);
      expect(
        find.descendant(of: roleSheet, matching: find.text(tacticsPlayer.name)),
        findsOneWidget,
      );
      Navigator.of(tester.element(roleSheet)).pop();
      await tester.pumpAndSettle();

      await tester.longPress(tacticsMarker);
      await tester.pumpAndSettle();
      expect(harness.router.state.uri.path, '/game/player/${tacticsPlayer.id}');
      expect(find.byType(PlayerDetailScreen), findsOneWidget);
      harness.router.pop();
      await tester.pumpAndSettle();

      final formationFinder = find.byType(DropdownButtonFormField<Formation>);
      final tempoFinder = find.byType(DropdownButtonFormField<Tempo>);
      final pressingFinder = find.byType(
        DropdownButtonFormField<PressingIntensity>,
      );
      final lineFinder = find.byType(DropdownButtonFormField<DefensiveLine>);
      final widthFinder = find.byType(DropdownButtonFormField<AttackWidth>);
      expect(formationFinder, findsOneWidget);
      expect(tempoFinder, findsOneWidget);
      expect(pressingFinder, findsOneWidget);
      expect(lineFinder, findsOneWidget);
      expect(widthFinder, findsOneWidget);

      final formation = tester.widget<DropdownButtonFormField<Formation>>(
        formationFinder,
      );
      final tempo = tester.widget<DropdownButtonFormField<Tempo>>(tempoFinder);
      final pressing = tester
          .widget<DropdownButtonFormField<PressingIntensity>>(pressingFinder);
      final line = tester.widget<DropdownButtonFormField<DefensiveLine>>(
        lineFinder,
      );
      final width = tester.widget<DropdownButtonFormField<AttackWidth>>(
        widthFinder,
      );
      final changedFormation = Formation.values.firstWhere(
        (value) => value != formation.initialValue,
      );
      final changedTempo = Tempo.values.firstWhere(
        (value) => value != tempo.initialValue,
      );
      final changedPressing = PressingIntensity.values.firstWhere(
        (value) => value != pressing.initialValue,
      );
      final changedLine = DefensiveLine.values.firstWhere(
        (value) => value != line.initialValue,
      );
      final changedWidth = AttackWidth.values.firstWhere(
        (value) => value != width.initialValue,
      );
      formation.onChanged!(changedFormation);
      tempo.onChanged!(changedTempo);
      pressing.onChanged!(changedPressing);
      line.onChanged!(changedLine);
      width.onChanged!(changedWidth);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      final afterAutosave = harness.controller.save!.leagueState.playerTeam!;
      expect(afterAutosave.roster, initialRoster);
      expect(afterAutosave.lineupPlayerIds, initialLineupIds);
      expect(afterAutosave.benchPlayerIds, initialBenchIds);
      expect(afterAutosave.tactics.formation, changedFormation);
      expect(afterAutosave.tactics.tempo, changedTempo);
      expect(afterAutosave.tactics.pressing, changedPressing);
      expect(afterAutosave.tactics.defensiveLine, changedLine);
      expect(afterAutosave.tactics.attackWidth, changedWidth);
      expect(find.text(l10n.tactics_autosaved), findsOneWidget);

      await tester.tap(tabs.at(0));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButton<SquadTileMetricMode>>(metricButtonFinder)
            .value,
        SquadTileMetricMode.potential,
      );
      expect(
        tester.widget<PlayerListTile>(tileFinder(selectedId)).selected,
        isTrue,
      );
      final afterReturn = harness.controller.save!.leagueState.playerTeam!;
      expect(afterReturn.roster, initialRoster);
      expect(afterReturn.lineupPlayerIds, initialLineupIds);
      expect(afterReturn.benchPlayerIds, initialBenchIds);
      expect(afterReturn.tactics.formation, changedFormation);
      expect(afterReturn.tactics.tempo, changedTempo);
      expect(afterReturn.tactics.pressing, changedPressing);
      expect(afterReturn.tactics.defensiveLine, changedLine);
      expect(afterReturn.tactics.attackWidth, changedWidth);

      await tester.tap(tabs.at(1));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButtonFormField<Formation>>(formationFinder)
            .initialValue,
        changedFormation,
      );
      expect(
        tester.widget<DropdownButtonFormField<Tempo>>(tempoFinder).initialValue,
        changedTempo,
      );
      expect(
        tester
            .widget<DropdownButtonFormField<PressingIntensity>>(pressingFinder)
            .initialValue,
        changedPressing,
      );
      expect(
        tester
            .widget<DropdownButtonFormField<DefensiveLine>>(lineFinder)
            .initialValue,
        changedLine,
      );
      expect(
        tester
            .widget<DropdownButtonFormField<AttackWidth>>(widthFinder)
            .initialValue,
        changedWidth,
      );
      expect(find.text(l10n.tactics_autosaved), findsOneWidget);
    },
  );
}
