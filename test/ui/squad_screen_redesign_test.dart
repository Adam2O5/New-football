@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/player_detail_screen.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/app/widgets/tactics/substitute_sheet.dart';
import 'package:new_football/app/widgets/squad/roster_size_indicator.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
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

      final dragTargetFinder = find.ancestor(
        of: _rowFinder(secondBench),
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
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final beforeLineup = [...team.lineupPlayerIds];
    final beforeBench = [...team.benchPlayerIds];
    tester.widget<PlayerListTile>(_tileFinder(starterId)).onTap();
    tester.widget<PlayerListTile>(_tileFinder(injuredId)).onTap();
    await tester.pumpAndSettle();

    final after = harness.controller.save!.leagueState.playerTeam!;
    expect(after.lineupPlayerIds, beforeLineup);
    expect(after.benchPlayerIds, beforeBench);
    expect(
      find.text(_screenLocalizations(tester).squad_cannotFieldInjured),
      findsOneWidget,
    );
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

AppLocalizations _screenLocalizations(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(SquadScreen)))!;
