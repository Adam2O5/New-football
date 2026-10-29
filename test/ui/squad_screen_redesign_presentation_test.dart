@Tags(['ui'])
library;

import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import '../helpers/widgets/career_dashboard_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/squad/squad_indicators.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/tactics/player_sort.dart';

import '../helpers/widgets/squad_screen_harness.dart';
import '../helpers/widgets/widget_harness.dart';

void main() {
  testWidgets(
    'renders the full redesign surface and keeps all three tile metric modes',
    (tester) async {
      final game = task41Game(seed: 9401);
      final harness = SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final team = game.leagueState.playerTeam!;
      final l10n = screenLocalizations(tester);
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
        find.byKey(const ValueKey('squad-size-indicator-range-track')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('squad-size-indicator-track-fill')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('squad-pitch-field')), findsOneWidget);
      expect(find.byKey(const ValueKey('squad-roster-list')), findsOneWidget);

      final rows = rosterRows(tester);
      expect(rows, hasLength(team.roster.length));
      expect(
        rows.map((row) => row.player.id).toSet(),
        originalRosterIds.toSet(),
      );
      for (final player in team.roster) {
        expect(rowFinder(player.id), findsOneWidget);
      }

      final metricButtonFinder = find.byType(
        DropdownButton<SquadTileMetricMode>,
      );
      expect(metricButtonFinder, findsOneWidget);
      final metricButton = tester.widget<DropdownButton<SquadTileMetricMode>>(
        metricButtonFinder,
      );
      expect(metricButton.items, hasLength(3));
      expect(
        metricButton.items!.map((item) => item.value),
        <SquadTileMetricMode>[
          SquadTileMetricMode.staminaForm,
          SquadTileMetricMode.potential,
          SquadTileMetricMode.optimalRole,
        ],
      );
      expect(
        metricButton.items!.map((item) => (item.child as Text).data),
        <String>[
          l10n.squad_metricStaminaForm,
          l10n.squad_metricPotential,
          l10n.squad_metricOptimalRole,
        ],
      );

      final assignedZoneOrder = sortRoster(
        team,
        team.roster,
        PlayerSortMode.assignedZone,
      ).map((player) => player.id).toList();
      for (final mode in SquadTileMetricMode.values) {
        final currentButton = tester
            .widget<DropdownButton<SquadTileMetricMode>>(metricButtonFinder);
        currentButton.onChanged!(mode);
        await tester.pump();

        expect(
          rosterRows(tester).map((row) => row.player.id).toList(),
          assignedZoneOrder,
        );
        expect(
          tester
              .widget<DropdownButton<SquadTileMetricMode>>(metricButtonFinder)
              .value,
          mode,
        );
        switch (mode) {
          case SquadTileMetricMode.staminaForm:
            expect(
              find.byType(FormIndicator),
              findsNWidgets(team.roster.length),
            );
            expect(
              find.byType(StaminaIndicator),
              findsNWidgets(team.roster.length),
            );
            expect(find.byType(PotentialStars), findsNothing);
            expect(find.byType(OptimalRoleLabel), findsNothing);
          case SquadTileMetricMode.potential:
            expect(find.byType(FormIndicator), findsNothing);
            expect(find.byType(StaminaIndicator), findsNothing);
            expect(
              find.byType(PotentialStars),
              findsNWidgets(team.roster.length),
            );
            expect(find.byType(OptimalRoleLabel), findsNothing);
          case SquadTileMetricMode.optimalRole:
            expect(find.byType(FormIndicator), findsNothing);
            expect(find.byType(StaminaIndicator), findsNothing);
            expect(find.byType(PotentialStars), findsNothing);
            expect(
              find.byType(OptimalRoleLabel),
              findsNWidgets(team.roster.length),
            );
        }
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
        tester
            .widget<DropdownButton<SquadTileMetricMode>>(metricButtonFinder)
            .value,
        SquadTileMetricMode.optimalRole,
      );
    },
  );

  testWidgets(
    'updates count, progress, row zone and pitch marker from provider state',
    (tester) async {
      final game = task41Game(seed: 9402);
      final harness = SquadHarness(game);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final initialTeam = harness.controller.save!.leagueState.playerTeam!;
      final addedPlayer = initialTeam.roster.last.copyWith(
        id: 'provider-added-player',
        name: 'Provider Added',
      );
      final metricButtonFinder = find.byType(
        DropdownButton<SquadTileMetricMode>,
      );
      final metricButton = tester.widget<DropdownButton<SquadTileMetricMode>>(
        metricButtonFinder,
      );
      metricButton.onChanged!(SquadTileMetricMode.potential);
      await tester.pump();

      final initialCount = tester.widget<RosterSizeIndicator>(
        find.byType(RosterSizeIndicator),
      );
      final initialFillWidth = tester
          .getSize(
            find.byKey(const ValueKey('squad-size-indicator-track-fill')),
          )
          .width;
      expect(rowFinder(addedPlayer.id), findsNothing);

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
      final updatedFillWidth = tester
          .getSize(
            find.byKey(const ValueKey('squad-size-indicator-track-fill')),
          )
          .width;
      expect(updatedCount.count, initialCount.count + 1);
      expect(updatedFillWidth, greaterThan(initialFillWidth));
      expect(find.byKey(rowKey(addedPlayer.id)), findsOneWidget);
      expect(
        tester
            .widget<DropdownButton<SquadTileMetricMode>>(metricButtonFinder)
            .value,
        SquadTileMetricMode.potential,
      );
      expect(
        tester.widget<PlayerListTile>(tileFinder(addedPlayer.id)).zone,
        RosterZone.reserve,
      );
      expect(
        find.descendant(
          of: rowFinder(addedPlayer.id),
          matching: find.text(screenLocalizations(tester).squad_zoneReserves),
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
        tester
            .widget<DropdownButton<SquadTileMetricMode>>(metricButtonFinder)
            .value,
        SquadTileMetricMode.potential,
      );
      expect(
        tester.widget<PlayerListTile>(tileFinder(addedPlayer.id)).zone,
        RosterZone.xi,
      );
      expect(
        find.descendant(
          of: rowFinder(addedPlayer.id),
          matching: find.text(screenLocalizations(tester).squad_zoneXi),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<PlayerListTile>(tileFinder(replacedStarter)).zone,
        RosterZone.reserve,
      );

      final pitch = tester.widget<PitchField>(
        find.byKey(const ValueKey('squad-pitch-field')),
      );
      final placement = pitch.precomputedPlacements!.firstWhere(
        (item) => item.player?.id == addedPlayer.id,
      );
      final l10n = screenLocalizations(tester);
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
    final harness = SquadHarness(game);
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final l10n = screenLocalizations(tester);
    final statusRow = rowFinder(statusId);
    expect(find.byKey(rowKey(statusId)), findsOneWidget);
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
    final harness = SquadHarness(game);
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final l10n = screenLocalizations(tester);
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
          .getSize(
            find.byKey(const ValueKey('squad-size-indicator-track-fill')),
          )
          .width,
      0,
    );
  });
  testWidgets(
    'SquadScreen pokazuje pełny roster bez filtrów i zakładkę taktyki',
    (tester) async {
      final game = dashboardGame(seed: 4004);
      final team = game.leagueState.playerTeam!;
      await tester.pumpWidget(dashboardApp(const SquadScreen(), game));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(SquadScreen)),
      )!;
      expect(find.text(l10n.squad_filters), findsNothing);
      expect(find.text(l10n.squad_clearFilters), findsNothing);
      expect(find.text(l10n.squad_search), findsNothing);
      expect(find.byType(TextField), findsNothing);

      expect(
        find.byKey(const ValueKey('squad-size-indicator')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('squad-pitch-field')), findsOneWidget);
      expect(find.byKey(const ValueKey('squad-roster-list')), findsOneWidget);
      expect(find.byType(PlayerListTile), findsNWidgets(team.roster.length));
      for (final player in team.roster) {
        expect(
          find.byKey(ValueKey('squad-player-row-${player.id}')),
          findsOneWidget,
        );
      }

      await tester.tap(find.text(l10n.squad_tacticsTitle).first);
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<Formation>), findsOneWidget);
      expect(find.text(l10n.tactics_autosaveHint), findsOneWidget);
    },
  );
}
