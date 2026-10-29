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
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import 'widget_harness.dart';

class SquadHarness {
  SquadHarness(this.game);

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

Finder rowFinder(String id) => find.byKey(rowKey(id));

Finder tileFinder(String id) => find.byWidgetPredicate(
  (widget) => widget is PlayerListTile && widget.player.id == id,
);

ValueKey<String> rowKey(String id) => ValueKey<String>('squad-player-row-$id');

List<PlayerListTile> rosterRows(WidgetTester tester) =>
    tester.widgetList<PlayerListTile>(find.byType(PlayerListTile)).toList();

Map<String, RosterZone> assignmentZones(Team team) => {
  for (final player in team.roster) player.id: rosterZoneOf(team, player.id),
};

void expectRosterRowSelectionSemantics(
  WidgetTester tester,
  AppLocalizations l10n,
  PlayerListTile tile, {
  required bool selected,
}) {
  final rowLabel = rosterRowSemanticsLabel(l10n, tile);
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

String rosterRowSemanticsLabel(AppLocalizations l10n, PlayerListTile tile) {
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
    localizedRosterZoneLabel(l10n, tile.zone),
  );
  final statuses = <String>[
    if (status.hasActiveInjury) l10n.squad_statusInjury,
    if (status.hasActiveSuspension) l10n.squad_statusSuspension,
    if (status.hasPositionMismatch) l10n.squad_positionMismatch,
  ];
  return statuses.isEmpty ? base : '$base. ${statuses.join('. ')}.';
}

String localizedRosterZoneLabel(AppLocalizations l10n, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return l10n.squad_zoneXi;
    case RosterZone.bench:
      return l10n.squad_zoneBench;
    case RosterZone.reserve:
      return l10n.squad_zoneReserves;
  }
}

AppLocalizations screenLocalizations(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(SquadScreen)))!;
