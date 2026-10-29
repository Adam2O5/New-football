import 'package:new_football/core/models/draft_models.dart';
import '../fixtures/presentation_fixtures.dart';
import '../fixtures/game_fixtures.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/position_group.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

Widget tileApp(
  GameSave game, {
  required Player player,
  required VoidCallback onTap,
  RosterZone zone = RosterZone.xi,
  bool selected = false,
  AssignedSlot? positionAssignment,
  AssignedSlot? assignment,
  VoidCallback? onInfo,
  VoidCallback? onProfile,
  bool enableDragDrop = false,
  void Function(String draggedPlayerId)? onAcceptDrop,
  double width = 360,
  double textScale = 1.0,
  SquadTileMetricMode metricMode = SquadTileMetricMode.staminaForm,
}) {
  return localizedApp((context) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
      child: SizedBox(
        width: width,
        child: PlayerListTile(
          l10n: AppLocalizations.of(context)!,
          player: player,
          zone: zone,
          selected: selected,
          onTap: onTap,
          positionAssignment: positionAssignment,
          assignment: assignment,
          onInfo: onInfo,
          onProfile: onProfile,
          enableDragDrop: enableDragDrop,
          onAcceptDrop: onAcceptDrop,
          metricMode: metricMode,
        ),
      ),
    );
  });
}

Widget localizedApp(
  WidgetBuilder builder, {
  Locale locale = const Locale('pl'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Builder(builder: builder)),
  );
}

GameSave fixtureGame({required int seed}) => saveForLeague(
  LeagueState(
    teams: [presentationTeam()],
    playerTeamId: 'presentation-team',
    currentSeason: const Season(year: 2026),
  ),
).copyWith(saveSeed: seed);

Player copyPlayer(
  GameSave game, {
  required String id,
  required String name,
  Position? position,
  double form = 5,
  bool activeInjury = false,
  bool activeSuspension = false,
}) {
  final roster = game.leagueState.playerTeam!.roster;
  final source = position == null
      ? roster.first
      : roster.firstWhere(
          (candidate) => candidate.position == position,
          orElse: () => roster.first,
        );
  return source.copyWith(
    id: id,
    name: name,
    position: position ?? source.position,
    state: source.state.copyWith(
      form: form,
      injury: activeInjury
          ? Injury(
              id: '$id-injury',
              group: InjuryGroup.legMuscles,
              type: InjuryType.minor,
              daysTotal: 5,
              daysRemaining: 3,
            )
          : null,
      suspensionGamesRemaining: activeSuspension ? 2 : 0,
    ),
  );
}

AssignedSlot slot(String key, Position position) {
  return AssignedSlot(
    key: key,
    position: position,
    group: positionGroupOf(position),
    x: 0.5,
    y: 0.5,
  );
}

AppLocalizations tileLocalizations(WidgetTester tester) {
  return AppLocalizations.of(tester.element(find.byType(PlayerListTile)))!;
}

Container circleContainer(WidgetTester tester, Finder owner) {
  final containers = tester
      .widgetList<Container>(
        find.descendant(of: owner, matching: find.byType(Container)),
      )
      .where((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration &&
            decoration.shape == BoxShape.circle;
      })
      .toList();
  expect(containers, hasLength(1));
  return containers.single;
}

Container zoneBorderContainer(WidgetTester tester) {
  final containers = tester.widgetList<Container>(find.byType(Container)).where(
    (container) {
      final decoration = container.decoration;
      return decoration is BoxDecoration && decoration.border != null;
    },
  ).toList();
  expect(containers, isNotEmpty);
  return containers.first;
}

String zoneLabel(AppLocalizations l10n, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return l10n.squad_zoneXi;
    case RosterZone.bench:
      return l10n.squad_zoneBench;
    case RosterZone.reserve:
      return l10n.squad_zoneReserves;
  }
}

String rowSemanticsLabel(
  AppLocalizations l10n,
  Player player,
  SquadStatus status,
  RosterZone zone,
) {
  final form = clampedFormValue(player.state.form);
  final formattedForm = form == form.roundToDouble()
      ? form.toInt().toString()
      : form.toString();
  final base = l10n.squad_playerRowSemantics(
    player.name,
    player.position.code,
    roundedOvrForDisplay(player.overall()),
    formattedForm,
    zoneLabel(l10n, zone),
  );
  final statuses = <String>[
    if (status.hasActiveInjury) l10n.squad_statusInjury,
    if (status.hasActiveSuspension) l10n.squad_statusSuspension,
    if (status.hasPositionMismatch) l10n.squad_positionMismatch,
  ];
  return statuses.isEmpty ? base : '$base. ${statuses.join('. ')}.';
}

bool hasZoneColorFamily(Color color, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return color.g > color.r && color.g > color.b;
    case RosterZone.bench:
      return color.b > color.r && color.b > color.g;
    case RosterZone.reserve:
      return color.r > color.b && color.g > color.b;
  }
}

void expectInside(Rect inner, Rect outer) {
  const tolerance = 0.5;
  expect(inner.left, greaterThanOrEqualTo(outer.left - tolerance));
  expect(inner.top, greaterThanOrEqualTo(outer.top - tolerance));
  expect(inner.right, lessThanOrEqualTo(outer.right + tolerance));
  expect(inner.bottom, lessThanOrEqualTo(outer.bottom + tolerance));
}

void expectSameRect(Rect actual, Rect expected) {
  const tolerance = 0.001;
  expect(actual.left, closeTo(expected.left, tolerance));
  expect(actual.top, closeTo(expected.top, tolerance));
  expect(actual.right, closeTo(expected.right, tolerance));
  expect(actual.bottom, closeTo(expected.bottom, tolerance));
}
