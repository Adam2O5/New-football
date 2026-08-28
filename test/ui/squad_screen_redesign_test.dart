@Tags(['ui'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/player_detail_screen.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/app/widgets/tactics/substitute_sheet.dart';
import 'package:new_football/app/widgets/squad/squad_indicators.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widget_harness.dart';

void main() {
  testWidgets(
    'renders the full redesign surface and keeps all four sort modes',
    (tester) async {
      final game = task41Game(seed: 9401);
      final harness = _SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final team = game.leagueState.playerTeam!;
      final l10n = _screenLocalizations(tester);
      final originalRosterIds = team.roster.map((player) => player.id).toList();
      final originalLineupIds = [...team.lineupPlayerIds];
      final originalBenchIds = [...team.benchPlayerIds];

      expect(find.text(l10n.squad_matchday), findsNothing);
      expect(find.text(l10n.squad_filters), findsNothing);
      expect(find.text(l10n.squad_search), findsNothing);
      expect(find.text(l10n.squad_selectHint), findsNothing);
      expect(find.text(l10n.squad_clearFilters), findsNothing);

      expect(
        find.byKey(const ValueKey('squad-size-indicator')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('squad-size-indicator-count')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('squad-size-indicator-minimum')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('squad-size-indicator-maximum')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('squad-size-indicator-range-track')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('squad-pitch-field')), findsOneWidget);
      expect(find.byKey(const ValueKey('squad-roster-list')), findsOneWidget);

      final rows = _rosterRows(tester);
      expect(rows, hasLength(team.roster.length));
      expect(
        rows.map((row) => row.player.id).toSet(),
        originalRosterIds.toSet(),
      );
      for (final player in team.roster) {
        expect(_rowFinder(player.id), findsOneWidget);
      }

      final sortButtonFinder = find.byType(DropdownButton<PlayerSortMode>);
      expect(sortButtonFinder, findsOneWidget);
      final sortButton = tester.widget<DropdownButton<PlayerSortMode>>(
        sortButtonFinder,
      );
      expect(sortButton.items, hasLength(4));
      expect(sortButton.items!.map((item) => item.value), <PlayerSortMode>[
        PlayerSortMode.overall,
        PlayerSortMode.assignedZone,
        PlayerSortMode.form,
        PlayerSortMode.position,
      ]);
      expect(
        sortButton.items!.map((item) => (item.child as Text).data),
        <String>[
          l10n.squad_sortOverall,
          l10n.squad_sortAssignedZone,
          l10n.squad_sortForm,
          l10n.squad_sortPosition,
        ],
      );

      for (final mode in PlayerSortMode.values) {
        final currentButton = tester.widget<DropdownButton<PlayerSortMode>>(
          sortButtonFinder,
        );
        currentButton.onChanged!(mode);
        await tester.pump();

        final currentTeam = harness.controller.save!.leagueState.playerTeam!;
        expect(
          _rosterRows(tester).map((row) => row.player.id).toList(),
          sortRoster(
            currentTeam,
            currentTeam.roster,
            mode,
          ).map((player) => player.id).toList(),
        );
        expect(
          tester.widget<DropdownButton<PlayerSortMode>>(sortButtonFinder).value,
          mode,
        );
      }

      expect(
        harness.controller.save!.leagueState.playerTeam!.roster.map(
          (player) => player.id,
        ),
        originalRosterIds,
      );
      expect(
        harness.controller.save!.leagueState.playerTeam!.lineupPlayerIds,
        originalLineupIds,
      );
      expect(
        harness.controller.save!.leagueState.playerTeam!.benchPlayerIds,
        originalBenchIds,
      );

      final tabs = find.byType(Tab);
      expect(tabs, findsNWidgets(2));
      await tester.tap(tabs.at(1));
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<Formation>), findsOneWidget);
      await tester.tap(tabs.at(0));
      await tester.pumpAndSettle();
      expect(
        tester.widget<DropdownButton<PlayerSortMode>>(sortButtonFinder).value,
        PlayerSortMode.position,
      );
    },
  );

  testWidgets(
    'updates count, progress, row zone and pitch marker from provider state',
    (tester) async {
      final game = task41Game(seed: 9402);
      final harness = _SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final initialTeam = harness.controller.save!.leagueState.playerTeam!;
      final addedPlayer = initialTeam.roster.last.copyWith(
        id: 'provider-added-player',
        name: 'Provider Added',
      );
      final sortButtonFinder = find.byType(DropdownButton<PlayerSortMode>);
      final sortButton = tester.widget<DropdownButton<PlayerSortMode>>(
        sortButtonFinder,
      );
      sortButton.onChanged!(PlayerSortMode.position);
      await tester.pump();

      final initialCount = tester.widget<RosterSizeIndicator>(
        find.byType(RosterSizeIndicator),
      );
      final initialFill = tester.widget<FractionallySizedBox>(
        find.byKey(const ValueKey('squad-size-indicator-track-fill')),
      );
      expect(_rowFinder(addedPlayer.id), findsNothing);

      await harness.controller.updateLeague((league) {
        final team = league.playerTeam!;
        return league.updateTeam(
          team.copyWith(roster: [...team.roster, addedPlayer]),
        );
      }, autosave: false);
      await tester.pumpAndSettle();

      final updatedCount = tester.widget<RosterSizeIndicator>(
        find.byType(RosterSizeIndicator),
      );
      final updatedFill = tester.widget<FractionallySizedBox>(
        find.byKey(const ValueKey('squad-size-indicator-track-fill')),
      );
      expect(updatedCount.count, initialCount.count + 1);
      expect(updatedFill.widthFactor, greaterThan(initialFill.widthFactor!));
      expect(find.byKey(_rowKey(addedPlayer.id)), findsOneWidget);
      expect(
        tester.widget<DropdownButton<PlayerSortMode>>(sortButtonFinder).value,
        PlayerSortMode.position,
      );
      expect(
        tester.widget<PlayerListTile>(_tileFinder(addedPlayer.id)).zone,
        RosterZone.reserve,
      );
      expect(
        find.descendant(
          of: _rowFinder(addedPlayer.id),
          matching: find.text(_screenLocalizations(tester).squad_zoneReserves),
        ),
        findsOneWidget,
      );

      final beforeAssignment = harness.controller.save!.leagueState.playerTeam!;
      final replacedStarter = beforeAssignment.lineupPlayerIds.first;
      final nextLineup = [
        addedPlayer.id,
        ...beforeAssignment.lineupPlayerIds.skip(1),
      ];
      await harness.controller.updateLeague(
        (league) => league.updateTeam(
          beforeAssignment.copyWith(lineupPlayerIds: nextLineup),
        ),
        autosave: false,
      );
      await tester.pumpAndSettle();

      final finalTeam = harness.controller.save!.leagueState.playerTeam!;
      expect(
        tester.widget<DropdownButton<PlayerSortMode>>(sortButtonFinder).value,
        PlayerSortMode.position,
      );
      expect(
        tester.widget<PlayerListTile>(_tileFinder(addedPlayer.id)).zone,
        RosterZone.xi,
      );
      expect(
        find.descendant(
          of: _rowFinder(addedPlayer.id),
          matching: find.text(_screenLocalizations(tester).squad_zoneXi),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<PlayerListTile>(_tileFinder(replacedStarter)).zone,
        RosterZone.reserve,
      );

      final pitch = tester.widget<PitchField>(
        find.byKey(const ValueKey('squad-pitch-field')),
      );
      final placement = pitch.precomputedPlacements!.firstWhere(
        (item) => item.player?.id == addedPlayer.id,
      );
      final l10n = _screenLocalizations(tester);
      final status = statusFor(addedPlayer, placement.slot);
      final markerStatus = <String>[
        if (status.hasActiveInjury) l10n.squad_statusInjury,
        if (status.hasActiveSuspension) l10n.squad_statusSuspension,
        if (status.hasPositionMismatch) l10n.squad_positionMismatch,
      ].join(', ');
      expect(
        find.bySemanticsLabel(
          l10n.squad_playerMarkerSemantics(
            addedPlayer.name,
            addedPlayer.position.code,
            markerStatus,
          ),
        ),
        findsOneWidget,
      );
      expect(finalTeam.lineupPlayerIds, contains(addedPlayer.id));
      expect(finalTeam.lineupPlayerIds, isNot(contains(replacedStarter)));
    },
  );

  testWidgets('shows status colors, zone labels and stable presentation keys', (
    tester,
  ) async {
    final base = task41Game(seed: 9403);
    final baseTeam = base.leagueState.playerTeam!;
    final statusId = baseTeam.lineupPlayerIds.first;
    final source = baseTeam.roster.firstWhere(
      (player) => player.id == statusId,
    );
    final statusPlayer = source.copyWith(
      state: source.state.copyWith(
        injury: const Injury(
          id: 'red-status-injury',
          group: InjuryGroup.legMuscles,
          type: InjuryType.minor,
          daysTotal: 5,
          daysRemaining: 3,
        ),
        suspensionGamesRemaining: 2,
      ),
    );
    final statusTeam = baseTeam.copyWith(
      roster: [
        for (final player in baseTeam.roster)
          player.id == statusId ? statusPlayer : player,
      ],
    );
    final game = base.copyWith(
      leagueState: base.leagueState.updateTeam(statusTeam),
    );
    final harness = _SquadHarness(game);
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final l10n = _screenLocalizations(tester);
    final statusRow = _rowFinder(statusId);
    expect(find.byKey(_rowKey(statusId)), findsOneWidget);
    expect(
      find.descendant(of: statusRow, matching: find.byType(PositionBadge)),
      findsOneWidget,
    );
    expect(
      tester
          .widget<PositionBadge>(
            find.descendant(
              of: statusRow,
              matching: find.byType(PositionBadge),
            ),
          )
          .backgroundColor,
      Colors.red,
    );
    expect(
      find.descendant(of: statusRow, matching: find.byType(StatusIcons)),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(l10n.squad_statusInjury), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.squad_statusSuspension), findsOneWidget);
    expect(
      find.descendant(of: statusRow, matching: find.text(l10n.squad_zoneXi)),
      findsOneWidget,
    );
    final pitch = tester.widget<PitchField>(
      find.byKey(const ValueKey('squad-pitch-field')),
    );
    final placement = pitch.precomputedPlacements!.firstWhere(
      (item) => item.player?.id == statusId,
    );
    final markerStatus = [
      l10n.squad_statusInjury,
      l10n.squad_statusSuspension,
    ].join(', ');
    expect(
      find.bySemanticsLabel(
        l10n.squad_playerMarkerSemantics(
          statusPlayer.name,
          statusPlayer.position.code,
          markerStatus,
        ),
      ),
      findsOneWidget,
    );
    expect(statusFor(statusPlayer, placement.slot).color, Colors.red);
    expect(find.byKey(const ValueKey('squad-size-indicator')), findsOneWidget);
    expect(find.byKey(const ValueKey('squad-pitch-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('squad-roster-list')), findsOneWidget);
  });

  // Feature: squad-row-polish, Property 5: TapSwap is a deterministic selection state machine
  testWidgets(
    'Feature: squad-row-polish, Property 5: TapSwap is a deterministic selection state machine',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final game = task41Game(seed: 9425);
      final harness = _SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      try {
        await harness.pump(tester);
        final l10n = _screenLocalizations(tester);
        final initialTeam = harness.controller.save!.leagueState.playerTeam!;
        final firstStarter = initialTeam.lineupPlayerIds.first;
        final firstBench = initialTeam.benchPlayerIds.first;
        final initialRosterIds = initialTeam.roster
            .map((player) => player.id)
            .toList();
        final initialLineupIds = [...initialTeam.lineupPlayerIds];
        final initialBenchIds = [...initialTeam.benchPlayerIds];
        final initialZones = _assignmentZones(initialTeam);

        PlayerListTile tileFor(String id) =>
            tester.widget<PlayerListTile>(_tileFinder(id));

        _expectRosterRowSelectionSemantics(
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
        _expectRosterRowSelectionSemantics(
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
        _expectRosterRowSelectionSemantics(
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
        final afterZones = _assignmentZones(afterSwap);
        final changedAssignmentIds = initialZones.keys
            .where((id) => initialZones[id] != afterZones[id])
            .toSet();
        final expectedLineupIds = [...initialLineupIds]
          ..remove(firstStarter)
          ..add(firstBench);
        final expectedBenchIds = [...initialBenchIds]
          ..remove(firstBench)
          ..add(firstStarter);

        expect(changedAssignmentIds, {firstStarter, firstBench});
        expect(afterSwap.roster.map((player) => player.id), initialRosterIds);
        expect(afterSwap.lineupPlayerIds, expectedLineupIds);
        expect(afterSwap.benchPlayerIds, expectedBenchIds);
        expect(tileFor(firstStarter).selected, isFalse);
        expect(tileFor(firstBench).selected, isFalse);
        _expectRosterRowSelectionSemantics(
          tester,
          l10n,
          tileFor(firstStarter),
          selected: false,
        );
        _expectRosterRowSelectionSemantics(
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
      final harness = _SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final initialTeam = harness.controller.save!.leagueState.playerTeam!;
      final firstStarter = initialTeam.lineupPlayerIds[0];
      final firstBench = initialTeam.benchPlayerIds[0];
      final secondStarter = initialTeam.lineupPlayerIds[1];
      final secondBench = initialTeam.benchPlayerIds[1];

      final initialLineup = [...initialTeam.lineupPlayerIds];
      final initialBench = [...initialTeam.benchPlayerIds];
      tester.widget<PlayerListTile>(_tileFinder(firstStarter)).onTap();
      await tester.pump();
      expect(
        tester.widget<PlayerListTile>(_tileFinder(firstStarter)).selected,
        isTrue,
      );
      tester.widget<PlayerListTile>(_tileFinder(firstStarter)).onTap();
      await tester.pump();
      expect(
        tester.widget<PlayerListTile>(_tileFinder(firstStarter)).selected,
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

      tester.widget<PlayerListTile>(_tileFinder(firstStarter)).onTap();
      tester.widget<PlayerListTile>(_tileFinder(firstBench)).onTap();
      await tester.pumpAndSettle();
      var updatedTeam = harness.controller.save!.leagueState.playerTeam!;
      expect(updatedTeam.lineupPlayerIds, contains(firstBench));
      expect(updatedTeam.lineupPlayerIds, isNot(contains(firstStarter)));
      expect(updatedTeam.benchPlayerIds, contains(firstStarter));
      expect(
        find.text(_screenLocalizations(tester).squad_swappedPlaces),
        findsOneWidget,
      );

      final dragTargetFinder = find.descendant(
        of: _tileFinder(secondBench),
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

  testWidgets('rejects unavailable assignments without changing domain lists', (
    tester,
  ) async {
    final base = task41Game(seed: 9405);
    final baseTeam = base.leagueState.playerTeam!;
    final starterId = baseTeam.lineupPlayerIds.first;
    final injuredId = baseTeam.benchPlayerIds.first;
    final injuredSource = baseTeam.roster.firstWhere(
      (player) => player.id == injuredId,
    );
    final injured = injuredSource.copyWith(
      state: injuredSource.state.copyWith(
        injury: const Injury(
          id: 'swap-rejection-injury',
          group: InjuryGroup.legMuscles,
          type: InjuryType.minor,
          daysTotal: 5,
          daysRemaining: 3,
        ),
      ),
    );
    final team = baseTeam.copyWith(
      roster: [
        for (final player in baseTeam.roster)
          player.id == injuredId ? injured : player,
      ],
    );
    final game = base.copyWith(leagueState: base.leagueState.updateTeam(team));
    final harness = _SquadHarness(game);
    final semanticsHandle = tester.ensureSemantics();
    addTearDown(() => harness.dispose(tester));

    try {
      await harness.pump(tester);
      final l10n = _screenLocalizations(tester);
      final beforeLineup = [...team.lineupPlayerIds];
      final beforeBench = [...team.benchPlayerIds];
      final starterTile = tester.widget<PlayerListTile>(_tileFinder(starterId));
      _expectRosterRowSelectionSemantics(
        tester,
        l10n,
        starterTile,
        selected: false,
      );
      starterTile.onTap();
      await tester.pump();
      _expectRosterRowSelectionSemantics(
        tester,
        l10n,
        tester.widget<PlayerListTile>(_tileFinder(starterId)),
        selected: true,
      );
      tester.widget<PlayerListTile>(_tileFinder(injuredId)).onTap();
      await tester.pumpAndSettle();

      final after = harness.controller.save!.leagueState.playerTeam!;
      expect(after.lineupPlayerIds, beforeLineup);
      expect(after.benchPlayerIds, beforeBench);
      _expectRosterRowSelectionSemantics(
        tester,
        l10n,
        tester.widget<PlayerListTile>(_tileFinder(starterId)),
        selected: false,
      );
      _expectRosterRowSelectionSemantics(
        tester,
        l10n,
        tester.widget<PlayerListTile>(_tileFinder(injuredId)),
        selected: false,
      );
      expect(find.text(l10n.squad_cannotFieldInjured), findsOneWidget);
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets(
    'opens substitute sheet, applies accepted swap and navigates profile',
    (tester) async {
      final game = task41Game(seed: 9406);
      final harness = _SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final team = harness.controller.save!.leagueState.playerTeam!;
      final l10n = _screenLocalizations(tester);
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
      final expectedCandidateIds = team.roster
          .where((player) => !team.lineupPlayerIds.contains(player.id))
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
        matching: find.text(candidatePlayer.name),
      );
      expect(candidateFinder, findsOneWidget);
      await tester.tap(candidateFinder);
      await tester.pumpAndSettle();

      final afterSheet = harness.controller.save!.leagueState.playerTeam!;
      expect(afterSheet.lineupPlayerIds, contains(candidate));
      expect(afterSheet.lineupPlayerIds, isNot(contains(outgoing)));
      expect(afterSheet.benchPlayerIds, contains(outgoing));
      expect(find.byType(SubstituteSheet), findsNothing);
      expect(find.text(l10n.squad_swappedPlaces), findsOneWidget);

      final profileRow = _rowFinder(candidate);
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
    'preserves roster membership, zone presentation, drag/drop and profile callbacks',
    (tester) async {
      final game = task41Game(seed: 9445);
      final harness = _SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final l10n = _screenLocalizations(tester);
      final initialTeam = harness.controller.save!.leagueState.playerTeam!;
      final initialRosterIds = initialTeam.roster
          .map((player) => player.id)
          .toList();
      final initialLineupIds = [...initialTeam.lineupPlayerIds];
      final initialBenchIds = [...initialTeam.benchPlayerIds];
      final initialRoster = [...initialTeam.roster];
      final initialTactics = initialTeam.tactics;
      final zones = _assignmentZones(initialTeam);

      expect(zones.values, contains(RosterZone.xi));
      expect(zones.values, contains(RosterZone.bench));
      expect(zones.values, contains(RosterZone.reserve));
      expect(_rosterRows(tester), hasLength(initialRosterIds.length));
      expect(
        _rosterRows(tester).map((row) => row.player.id).toSet(),
        initialRosterIds.toSet(),
      );
      for (final player in initialTeam.roster) {
        final row = _rowFinder(player.id);
        expect(row, findsOneWidget);
        expect(
          tester.widget<PlayerListTile>(_tileFinder(player.id)).zone,
          zones[player.id],
        );
        expect(
          find.descendant(
            of: row,
            matching: find.text(_rosterZoneLabel(l10n, zones[player.id]!)),
          ),
          findsOneWidget,
        );
      }

      final sortButtonFinder = find.byType(DropdownButton<PlayerSortMode>);
      for (final mode in PlayerSortMode.values) {
        tester
            .widget<DropdownButton<PlayerSortMode>>(sortButtonFinder)
            .onChanged!(mode);
        await tester.pump();
        expect(
          _rosterRows(tester).map((row) => row.player.id).toList(),
          sortRoster(
            initialTeam,
            initialTeam.roster,
            mode,
          ).map((player) => player.id).toList(),
        );
        expect(
          tester.widget<DropdownButton<PlayerSortMode>>(sortButtonFinder).value,
          mode,
        );
      }

      final selfId = initialTeam.benchPlayerIds.first;
      final selfTarget = tester.widget<DragTarget<String>>(
        find.descendant(
          of: _tileFinder(selfId),
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
          of: _tileFinder(targetId),
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
      final expectedLineupIds = [...initialLineupIds]
        ..remove(draggedId)
        ..add(targetId);
      final expectedBenchIds = [...initialBenchIds]
        ..remove(targetId)
        ..add(draggedId);
      expect(afterDrop.roster, initialRoster);
      expect(afterDrop.lineupPlayerIds, expectedLineupIds);
      expect(afterDrop.benchPlayerIds, expectedBenchIds);
      expect(afterDrop.tactics, initialTactics);
      expect(afterDrop.roster.map((player) => player.id), initialRosterIds);
      expect(find.text(l10n.squad_swappedPlaces), findsOneWidget);

      final infoAction = find.descendant(
        of: _rowFinder(targetId),
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

  testWidgets(
    'keeps Tactics_Tab isolated and preserves state across tab switches',
    (tester) async {
      final game = task41Game(seed: 9446);
      final harness = _SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final l10n = _screenLocalizations(tester);
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

      final sortButtonFinder = find.byType(DropdownButton<PlayerSortMode>);
      tester
          .widget<DropdownButton<PlayerSortMode>>(sortButtonFinder)
          .onChanged!(PlayerSortMode.form);
      await tester.pump();
      tester.widget<PlayerListTile>(_tileFinder(selectedId)).onTap();
      await tester.pump();
      expect(
        tester.widget<PlayerListTile>(_tileFinder(selectedId)).selected,
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
        tester.widget<DropdownButton<PlayerSortMode>>(sortButtonFinder).value,
        PlayerSortMode.form,
      );
      expect(
        tester.widget<PlayerListTile>(_tileFinder(selectedId)).selected,
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

  testWidgets('shows a localized empty roster without player rows or filters', (
    tester,
  ) async {
    final base = task41Game(seed: 9407);
    final emptyTeam = base.leagueState.playerTeam!.copyWith(
      roster: const [],
      lineupPlayerIds: const [],
      benchPlayerIds: const [],
    );
    final game = base.copyWith(
      leagueState: base.leagueState.updateTeam(emptyTeam),
    );
    final harness = _SquadHarness(game);
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final l10n = _screenLocalizations(tester);
    expect(find.text(l10n.squad_emptyRoster), findsOneWidget);
    expect(find.byType(PlayerListTile), findsNothing);
    expect(find.byKey(const ValueKey('squad-roster-list')), findsNothing);
    expect(find.text(l10n.squad_filters), findsNothing);
    expect(find.text(l10n.squad_search), findsNothing);
    expect(find.text(l10n.squad_position), findsNothing);
    expect(find.text(l10n.squad_zone), findsNothing);
    expect(find.text(l10n.squad_availability), findsNothing);
    expect(find.text(l10n.squad_minOvr), findsNothing);
    expect(find.text(l10n.squad_minForm), findsNothing);

    final indicator = tester.widget<RosterSizeIndicator>(
      find.byType(RosterSizeIndicator),
    );
    expect(indicator.count, 0);
    expect(
      tester
          .widget<Icon>(
            find.byKey(const ValueKey('squad-size-indicator-state-icon')),
          )
          .icon,
      Icons.close,
    );
    expect(
      tester
          .widget<FractionallySizedBox>(
            find.byKey(const ValueKey('squad-size-indicator-track-fill')),
          )
          .widthFactor,
      0,
    );
  });
}

class _SquadHarness {
  _SquadHarness(this.game);

  final GameSave game;
  late GameController controller;

  late final GoRouter router = GoRouter(
    initialLocation: '/squad',
    routes: [
      GoRoute(
        path: '/squad',
        builder: (context, state) => const Scaffold(body: SquadScreen()),
      ),
      GoRoute(
        path: '/game/player/:id',
        builder: (context, state) =>
            PlayerDetailScreen(playerId: state.pathParameters['id']!),
      ),
    ],
  );

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
          gameControllerProvider.overrideWith((ref) {
            final value = GameController(ref);
            value.state = AsyncValue.data(game);
            controller = value;
            return value;
          }),
        ],
        child: MaterialApp.router(
          locale: const Locale('pl'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    router.dispose();
  }
}

Finder _rowFinder(String id) => find.byKey(_rowKey(id));

Finder _tileFinder(String id) => find.byWidgetPredicate(
  (widget) => widget is PlayerListTile && widget.player.id == id,
);

ValueKey<String> _rowKey(String id) => ValueKey<String>('squad-player-row-$id');

List<PlayerListTile> _rosterRows(WidgetTester tester) =>
    tester.widgetList<PlayerListTile>(find.byType(PlayerListTile)).toList();

Map<String, RosterZone> _assignmentZones(Team team) => {
  for (final player in team.roster) player.id: rosterZoneOf(team, player.id),
};

void _expectRosterRowSelectionSemantics(
  WidgetTester tester,
  AppLocalizations l10n,
  PlayerListTile tile, {
  required bool selected,
}) {
  final rowLabel = _rosterRowSemanticsLabel(l10n, tile);
  final semanticsFinder = find.bySemanticsLabel(rowLabel);
  expect(
    semanticsFinder,
    findsOneWidget,
    reason: 'row semantics for ${tile.player.id}',
  );
  final node = tester.getSemantics(semanticsFinder);
  expect(
    node.flagsCollection.isSelected,
    selected ? ui.Tristate.isTrue : ui.Tristate.isFalse,
  );
  expect(
    node.value,
    selected ? l10n.squad_playerSelected : l10n.squad_playerNotSelected,
  );
  expect(node.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);
}

String _rosterRowSemanticsLabel(AppLocalizations l10n, PlayerListTile tile) {
  final status = statusFor(
    tile.player,
    tile.positionAssignment ?? tile.assignment,
  );
  final form = clampedFormValue(tile.player.state.form);
  final formattedForm = form == form.roundToDouble()
      ? form.toInt().toString()
      : form.toString();
  final base = l10n.squad_playerRowSemantics(
    tile.player.name,
    tile.player.position.code,
    roundedOvrForDisplay(tile.player.overall()),
    formattedForm,
    _rosterZoneLabel(l10n, tile.zone),
  );
  final statuses = <String>[
    if (status.hasActiveInjury) l10n.squad_statusInjury,
    if (status.hasActiveSuspension) l10n.squad_statusSuspension,
    if (status.hasPositionMismatch) l10n.squad_positionMismatch,
  ];
  return statuses.isEmpty ? base : '$base. ${statuses.join('. ')}.';
}

String _rosterZoneLabel(AppLocalizations l10n, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return l10n.squad_zoneXi;
    case RosterZone.bench:
      return l10n.squad_zoneBench;
    case RosterZone.reserve:
      return l10n.squad_zoneReserves;
  }
}

AppLocalizations _screenLocalizations(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(SquadScreen)))!;
