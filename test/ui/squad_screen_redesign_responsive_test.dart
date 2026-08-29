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
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/app/widgets/tactics/substitute_sheet.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widget_harness.dart';

const _responsiveViewports = <Size>[
  Size(320, 568),
  Size(360, 800),
  Size(390, 844),
  Size(844, 390),
];

const _responsiveTextScales = <double>[1.0, 1.3, 2.0];
const _geometryTolerance = 1.0;
const _responsiveLongName =
    'Responsive Player With An Exceptionally Long Name For Layout';
const _responsiveLongNameFirstLine = 'Responsive';
const _responsiveLongNameSecondLine =
    'Player With An Exceptionally Long Name For Layout';

void main() {
  // Feature: squad-row-polish, Property 6: Responsive row invariants hold across the supported matrix
  testWidgets(
    'Feature: squad-row-polish, Property 6: Responsive row invariants hold across the supported matrix',
    (tester) async {
      final frameworkErrors = <FlutterErrorDetails>[];
      final previousErrorHandler = FlutterError.onError;
      FlutterError.onError = (details) => frameworkErrors.add(details);
      var completedScenarios = 0;
      expect(
        _responsiveViewports.length * _responsiveTextScales.length,
        12,
        reason:
            'Property 6 must cover all 4×3 viewport/text-scale combinations',
      );

      try {
        for (final viewport in _responsiveViewports) {
          for (final textScale in _responsiveTextScales) {
            final scenario = _scenarioName(viewport, textScale);
            final harness = _ResponsiveSquadHarness(
              game: _responsiveFixtureGame(),
              viewport: viewport,
              textScale: textScale,
            );

            try {
              await harness.pump(tester);
              _expectNoFlutterErrors(tester, frameworkErrors, scenario);

              _expectSquadSurfaceGeometry(tester, scenario: scenario);
              _expectRowGeometry(tester, scenario: scenario);
              _expectResponsiveStressRow(tester, scenario: scenario);

              final selectedId = _selectFirstRenderedPlayer(tester);
              await tester.pump();
              _expectNoFlutterErrors(tester, frameworkErrors, scenario);

              _changeMetricMode(tester, SquadTileMetricMode.potential);
              await tester.pump();
              _expectNoFlutterErrors(tester, frameworkErrors, scenario);
              expect(
                _currentMetricMode(tester),
                SquadTileMetricMode.potential,
                reason: '$scenario: metric control did not activate',
              );
              _changeMetricMode(tester, SquadTileMetricMode.staminaForm);
              await tester.pump();
              expect(
                _selectedPlayerIds(tester),
                [selectedId],
                reason: '$scenario: selected player changed while sorting',
              );

              await _activatePitchMarker(tester, scenario);
              _expectNoFlutterErrors(tester, frameworkErrors, scenario);

              await _scrollToFinalRow(tester, scenario);
              _expectNoFlutterErrors(tester, frameworkErrors, scenario);
              _expectSquadSurfaceGeometry(
                tester,
                scenario: '$scenario after final-row scroll',
                allowScrolledContent: true,
                requireRosterContent: false,
              );
              _expectRowGeometry(
                tester,
                scenario: '$scenario after final-row scroll',
                requireFinalRowInViewport: true,
              );
              _expectResponsiveStressRow(
                tester,
                scenario: '$scenario after final-row scroll',
              );

              final finalRow = _finalRenderedRowFinder(tester);
              await _activateProfileAction(tester, harness, finalRow, scenario);
              _expectNoFlutterErrors(tester, frameworkErrors, scenario);

              final beforeRelayout = _teamSnapshot(harness.controller.save!);
              final selectedBeforeRelayout = _selectedPlayerIds(tester);
              final metricBeforeRelayout = _currentMetricMode(tester);
              final oppositeOrientation = viewport.width < viewport.height
                  ? const Size(844, 390)
                  : const Size(390, 844);
              harness.configureViewport(tester, oppositeOrientation);
              await tester.pumpAndSettle();
              _expectNoFlutterErrors(tester, frameworkErrors, scenario);

              await _scrollToFinalRow(
                tester,
                '$scenario after orientation relayout',
              );
              _expectNoFlutterErrors(tester, frameworkErrors, scenario);
              _expectSquadSurfaceGeometry(
                tester,
                scenario: '$scenario after orientation relayout',
                allowScrolledContent: true,
                requireRosterContent: false,
              );
              _expectRowGeometry(
                tester,
                scenario: '$scenario after orientation relayout',
                requireFinalRowInViewport: true,
              );
              _expectResponsiveStressRow(
                tester,
                scenario: '$scenario after orientation relayout',
              );
              expect(
                _currentMetricMode(tester),
                metricBeforeRelayout,
                reason: '$scenario: sort mode was not retained after relayout',
              );
              expect(
                _selectedPlayerIds(tester),
                selectedBeforeRelayout,
                reason: '$scenario: selectedId was not retained after relayout',
              );
              final afterRelayout = _teamSnapshot(harness.controller.save!);
              expect(
                afterRelayout.roster,
                beforeRelayout.roster,
                reason:
                    '$scenario: roster membership changed during orientation relayout',
              );
              expect(
                afterRelayout.lineup,
                beforeRelayout.lineup,
                reason:
                    '$scenario: lineup assignments changed during orientation relayout',
              );
              expect(
                afterRelayout.bench,
                beforeRelayout.bench,
                reason:
                    '$scenario: bench assignments changed during orientation relayout',
              );
              completedScenarios++;
            } finally {
              await harness.dispose(tester);
              frameworkErrors.clear();
            }
          }
        }
        expect(
          completedScenarios,
          12,
          reason: 'Property 6 did not execute the complete responsive matrix',
        );
      } finally {
        FlutterError.onError = previousErrorHandler;
      }
    },
  );
}

String _scenarioName(Size viewport, double textScale) =>
    '${viewport.width.toInt()}x${viewport.height.toInt()} at text scale $textScale';

void _expectNoFlutterErrors(
  WidgetTester tester,
  List<FlutterErrorDetails> frameworkErrors,
  String scenario,
) {
  expect(
    tester.takeException(),
    isNull,
    reason: '$scenario: Flutter surfaced an exception',
  );
  expect(
    frameworkErrors,
    isEmpty,
    reason: '$scenario: Flutter reported a layout or rendering error',
  );
}

void _expectSquadSurfaceGeometry(
  WidgetTester tester, {
  required String scenario,
  bool allowScrolledContent = false,
  bool requireRosterContent = true,
}) {
  final viewportRect = _testViewportRect(tester);
  final tabBar = find.byType(TabBar);
  final tabFinder = find.descendant(of: tabBar, matching: find.byType(Tab));
  final rosterScroll = find.byKey(
    const ValueKey<String>('squad-roster-scroll'),
  );
  final rosterList = find.byKey(const ValueKey<String>('squad-roster-list'));
  final pitch = find.byKey(const ValueKey<String>('squad-pitch-field'));
  final indicator = find.byKey(const ValueKey<String>('squad-size-indicator'));

  expect(tabBar, findsOneWidget, reason: '$scenario: missing tab bar');
  expect(tabFinder, findsNWidgets(2), reason: '$scenario: missing tab');
  expect(
    rosterScroll,
    findsOneWidget,
    reason: '$scenario: missing roster scroll',
  );

  final tabBarRect = tester.getRect(tabBar);
  final rosterScrollRect = tester.getRect(rosterScroll);

  _expectRectInside(viewportRect, tabBarRect, reason: '$scenario: tab bar');
  _expectRectInside(
    viewportRect,
    rosterScrollRect,
    reason: '$scenario: roster scroll viewport',
  );
  for (final tab in tester.widgetList<Tab>(tabFinder)) {
    final tabRect = tester.getRect(find.byWidget(tab));
    _expectRectInside(
      tabBarRect,
      tabRect,
      reason: '$scenario: tab exceeds tab bar bounds',
    );
  }

  if (!requireRosterContent) return;

  expect(pitch, findsOneWidget, reason: '$scenario: missing squad pitch');
  expect(rosterList, findsOneWidget, reason: '$scenario: missing roster list');
  expect(
    indicator,
    findsOneWidget,
    reason: '$scenario: missing size indicator',
  );

  final pitchRect = tester.getRect(pitch);
  final rosterListRect = tester.getRect(rosterList);
  final indicatorRect = tester.getRect(indicator);

  _expectHorizontalBounds(
    viewportRect,
    indicatorRect,
    reason: '$scenario: size indicator',
  );
  _expectHorizontalBounds(viewportRect, pitchRect, reason: '$scenario: pitch');
  _expectHorizontalBounds(
    viewportRect,
    rosterListRect,
    reason: '$scenario: roster list',
  );
  expect(
    pitchRect.width,
    greaterThan(0),
    reason: '$scenario: pitch has no width',
  );
  expect(
    pitchRect.height,
    greaterThan(0),
    reason: '$scenario: pitch has no height',
  );
  expect(
    rosterListRect.width,
    greaterThan(0),
    reason: '$scenario: roster list has no width',
  );
  expect(
    rosterListRect.top,
    greaterThanOrEqualTo(pitchRect.bottom - _geometryTolerance),
    reason: '$scenario: pitch overlaps the roster list',
  );

  if (!allowScrolledContent) {
    expect(
      rosterScrollRect.top,
      greaterThanOrEqualTo(tabBarRect.bottom - _geometryTolerance),
      reason: '$scenario: roster scroll overlaps tab controls',
    );
    expect(
      indicatorRect.top,
      greaterThanOrEqualTo(rosterScrollRect.top - _geometryTolerance),
      reason: '$scenario: size indicator is above the roster scroll region',
    );
    expect(
      pitchRect.top,
      greaterThanOrEqualTo(rosterScrollRect.top - _geometryTolerance),
      reason: '$scenario: pitch starts above the roster scroll region',
    );
  }
}

void _expectRowGeometry(
  WidgetTester tester, {
  required String scenario,
  bool requireFinalRowInViewport = false,
}) {
  final rosterList = find.byKey(const ValueKey<String>('squad-roster-list'));
  final rosterListRect = tester.getRect(rosterList);
  final rows = tester.widgetList<PlayerListTile>(find.byType(PlayerListTile));
  expect(rows, isNotEmpty, reason: '$scenario: no player rows rendered');
  final statusWidths = <double>[];

  for (final tile in rows) {
    final playerId = tile.player.id;
    final row = find.byKey(ValueKey<String>('squad-player-row-$playerId'));
    final frame = find.byKey(ValueKey<String>('squad-zone-frame-$playerId'));
    final positionBadge = find.descendant(
      of: row,
      matching: find.byType(PositionBadge),
    );
    final ovrBadge = find.descendant(of: row, matching: find.byType(OvrBadge));
    final form = find.descendant(
      of: row,
      matching: find.byKey(const ValueKey<String>('squad-form-indicator')),
    );
    final status = find.descendant(of: row, matching: find.byType(StatusIcons));
    final profile = find.descendant(of: row, matching: find.byType(IconButton));

    expect(row, findsOneWidget, reason: '$scenario: missing row $playerId');
    expect(frame, findsOneWidget, reason: '$scenario: missing frame $playerId');
    expect(
      positionBadge,
      findsOneWidget,
      reason: '$scenario: missing position badge $playerId',
    );
    expect(
      ovrBadge,
      findsOneWidget,
      reason: '$scenario: missing OVR badge $playerId',
    );
    expect(
      form,
      findsOneWidget,
      reason: '$scenario: missing form indicator $playerId',
    );
    expect(
      status,
      findsOneWidget,
      reason: '$scenario: missing status area $playerId',
    );
    expect(
      profile,
      findsOneWidget,
      reason: '$scenario: missing profile action $playerId',
    );

    final rowRect = tester.getRect(row);
    final frameRect = tester.getRect(frame);
    final positionRect = tester.getRect(positionBadge);
    final ovrRect = tester.getRect(ovrBadge);
    final formRect = tester.getRect(form);
    final statusRect = tester.getRect(status);
    final profileRect = tester.getRect(profile);
    statusWidths.add(statusRect.width);

    expect(rowRect.width, greaterThan(0), reason: '$scenario: zero-width row');
    expect(
      rowRect.height,
      greaterThan(0),
      reason: '$scenario: zero-height row',
    );
    _expectRectInside(
      rosterListRect,
      rowRect,
      reason: '$scenario: row $playerId exceeds roster list bounds',
    );
    _expectRectInside(
      rowRect,
      frameRect,
      reason: '$scenario: frame $playerId exceeds row bounds',
    );
    _expectRectInside(
      frameRect,
      positionRect,
      reason: '$scenario: position badge $playerId exceeds frame bounds',
    );
    _expectRectInside(
      frameRect,
      ovrRect,
      reason: '$scenario: OVR badge $playerId exceeds frame bounds',
    );
    _expectRectInside(
      frameRect,
      formRect,
      reason: '$scenario: form indicator $playerId exceeds frame bounds',
    );
    _expectRectInside(
      frameRect,
      statusRect,
      reason: '$scenario: status area $playerId exceeds frame bounds',
    );
    _expectRectInside(
      frameRect,
      profileRect,
      reason: '$scenario: profile action $playerId exceeds frame bounds',
    );
    _expectRectInside(
      rowRect,
      positionRect,
      reason: '$scenario: position badge $playerId exceeds row bounds',
    );
    _expectRectInside(
      rowRect,
      ovrRect,
      reason: '$scenario: OVR badge $playerId exceeds row bounds',
    );
    _expectRectInside(
      rowRect,
      formRect,
      reason: '$scenario: form indicator $playerId exceeds row bounds',
    );
    _expectRectInside(
      rowRect,
      statusRect,
      reason: '$scenario: status area $playerId exceeds row bounds',
    );
    _expectRectInside(
      rowRect,
      profileRect,
      reason: '$scenario: profile action $playerId exceeds row bounds',
    );

    expect(
      formRect.width,
      allOf(greaterThanOrEqualTo(32.0), lessThanOrEqualTo(36.0)),
      reason: '$scenario: form indicator $playerId is outside 32..36 pixels',
    );
    expect(
      formRect.width,
      closeTo(positionRect.width, _geometryTolerance),
      reason:
          '$scenario: form indicator width differs from position badge for $playerId',
    );

    final positionBadgeWidget = tester.widget<PositionBadge>(positionBadge);
    final ovrBadgeWidget = tester.widget<OvrBadge>(ovrBadge);
    expect(
      positionBadgeWidget.size,
      closeTo(ovrBadgeWidget.size, _geometryTolerance),
      reason: '$scenario: badge diameters differ for $playerId',
    );
    expect(
      positionRect.right,
      lessThanOrEqualTo(ovrRect.left + _geometryTolerance),
      reason:
          '$scenario: OVR badge is not immediately after position badge for $playerId',
    );
  }

  final reservedStatusWidth = statusWidths.first;
  expect(
    reservedStatusWidth,
    closeTo(25.0, _geometryTolerance),
    reason: '$scenario: status slot did not reserve one fixed symbol cell',
  );
  for (final statusWidth in statusWidths) {
    expect(
      statusWidth,
      closeTo(reservedStatusWidth, _geometryTolerance),
      reason: '$scenario: status slot width changed between row states',
    );
  }

  if (requireFinalRowInViewport) {
    final finalRow = _finalRenderedRowFinder(tester);
    final finalFrame = find.descendant(
      of: finalRow,
      matching: find.byType(ZoneFrame),
    );
    final finalProfile = find.descendant(
      of: finalRow,
      matching: find.byType(IconButton),
    );
    final outerViewport = tester.getRect(
      find.byKey(const ValueKey<String>('squad-roster-scroll')),
    );
    expect(
      finalFrame,
      findsOneWidget,
      reason: '$scenario: missing final frame',
    );
    expect(
      finalProfile,
      findsOneWidget,
      reason: '$scenario: missing final profile action',
    );
    _expectRectInside(
      outerViewport,
      tester.getRect(finalRow),
      reason:
          '$scenario: final row is not fully reachable in the scroll viewport',
    );
    _expectRectInside(
      outerViewport,
      tester.getRect(finalFrame),
      reason:
          '$scenario: final row frame is not fully reachable in the scroll viewport',
    );
    _expectRectInside(
      outerViewport,
      tester.getRect(finalProfile),
      reason:
          '$scenario: final profile action is not fully reachable in the scroll viewport',
    );
  }
}

void _expectResponsiveStressRow(
  WidgetTester tester, {
  required String scenario,
}) {
  final tile = tester
      .widgetList<PlayerListTile>(find.byType(PlayerListTile))
      .firstWhere((candidate) => candidate.player.name == _responsiveLongName);
  final row = find.byKey(
    ValueKey<String>('squad-player-row-${tile.player.id}'),
  );
  final ovrBadge = find.descendant(of: row, matching: find.byType(OvrBadge));
  final form = find.descendant(
    of: row,
    matching: find.byKey(const ValueKey<String>('squad-form-indicator')),
  );
  final status = find.descendant(of: row, matching: find.byType(StatusIcons));

  expect(tile.player.state.injury?.isActive, isTrue);
  expect(tile.player.state.suspensionGamesRemaining, greaterThan(0));
  expect(status, findsOneWidget, reason: '$scenario: missing dual-status slot');
  final statusWidget = tester.widget<StatusIcons>(status);
  expect(statusWidget.hasActiveInjury, isTrue);
  expect(statusWidget.hasActiveSuspension, isTrue);
  final visualSymbols = find.descendant(
    of: status,
    matching: find.byType(Icon),
  );
  expect(
    visualSymbols,
    findsOneWidget,
    reason: '$scenario: both statuses rendered more than one visual symbol',
  );
  expect(
    tester.widget<Icon>(visualSymbols).icon,
    Icons.healing_outlined,
    reason:
        '$scenario: dual-status slot did not use the injury priority symbol',
  );

  final rowRect = tester.getRect(row);
  final ovrRect = tester.getRect(ovrBadge);
  final formRect = tester.getRect(form);
  final nameArea = Rect.fromLTRB(
    ovrRect.right,
    rowRect.top,
    formRect.left,
    rowRect.bottom,
  );
  expect(
    nameArea.width,
    greaterThan(0),
    reason: '$scenario: long-name area has no available width',
  );

  for (final line in const [
    _responsiveLongNameFirstLine,
    _responsiveLongNameSecondLine,
  ]) {
    final textFinder = find.descendant(
      of: row,
      matching: find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == line,
      ),
    );
    expect(
      textFinder,
      findsOneWidget,
      reason: '$scenario: missing long-name line "$line"',
    );
    final text = tester.widget<Text>(textFinder);
    expect(
      text.maxLines,
      1,
      reason: '$scenario: long-name line "$line" is not bounded to one line',
    );
    expect(
      text.overflow,
      TextOverflow.ellipsis,
      reason: '$scenario: long-name line "$line" has no ellipsis policy',
    );
    _expectRectInside(
      nameArea,
      tester.getRect(textFinder),
      reason: '$scenario: long-name line "$line" escaped the name area',
    );
  }
}

String _selectFirstRenderedPlayer(WidgetTester tester) {
  final first = tester.widget<PlayerListTile>(
    find.byType(PlayerListTile).first,
  );
  first.onTap();
  return first.player.id;
}

void _changeMetricMode(WidgetTester tester, SquadTileMetricMode mode) {
  final metricControl = tester.widget<DropdownButton<SquadTileMetricMode>>(
    find.byType(DropdownButton<SquadTileMetricMode>),
  );
  metricControl.onChanged!(mode);
}

SquadTileMetricMode _currentMetricMode(WidgetTester tester) => tester
    .widget<DropdownButton<SquadTileMetricMode>>(
      find.byType(DropdownButton<SquadTileMetricMode>),
    )
    .value!;

List<String> _selectedPlayerIds(WidgetTester tester) => tester
    .widgetList<PlayerListTile>(find.byType(PlayerListTile))
    .where((tile) => tile.selected)
    .map((tile) => tile.player.id)
    .toList(growable: false);

Future<void> _activatePitchMarker(WidgetTester tester, String scenario) async {
  final pitchFinder = find.byKey(const ValueKey<String>('squad-pitch-field'));
  final pitch = tester.widget<PitchField>(pitchFinder);
  final placements = pitch.precomputedPlacements!;
  PlacedPlayer? chosen;
  for (final placement in placements) {
    if (placement.player == null) continue;
    if (placement.slot.x > 0.15 &&
        placement.slot.x < 0.85 &&
        placement.slot.y > 0.15 &&
        placement.slot.y < 0.85) {
      chosen = placement;
      break;
    }
  }
  chosen ??= placements.firstWhere((placement) => placement.player != null);
  final player = chosen.player!;
  final markerText = find.descendant(
    of: pitchFinder,
    matching: find.text(player.name),
  );
  expect(markerText, findsOneWidget, reason: '$scenario: missing pitch marker');
  final marker = find.ancestor(
    of: markerText,
    matching: find.byType(GestureDetector),
  );
  expect(
    marker,
    findsOneWidget,
    reason: '$scenario: pitch marker has no gesture target',
  );
  await tester.ensureVisible(marker);
  await tester.pumpAndSettle();
  await tester.tap(marker);
  await tester.pumpAndSettle();
  expect(
    find.byType(SubstituteSheet),
    findsOneWidget,
    reason: '$scenario: pitch marker did not activate SubstituteSheet',
  );
  Navigator.of(tester.element(find.byType(SubstituteSheet))).pop();
  await tester.pumpAndSettle();
}

Future<void> _scrollToFinalRow(WidgetTester tester, String scenario) async {
  final finalRow = _finalRenderedRowFinder(tester);
  final rosterScroll = find.byKey(
    const ValueKey<String>('squad-roster-scroll'),
  );
  final scrollable = find
      .descendant(of: rosterScroll, matching: find.byType(Scrollable))
      .first;

  await tester.scrollUntilVisible(finalRow, 400, scrollable: scrollable);
  await Scrollable.ensureVisible(tester.element(finalRow), alignment: 0.5);
  await tester.pumpAndSettle();
  expect(
    finalRow,
    findsOneWidget,
    reason: '$scenario: final row was not built after scrolling',
  );
}

Finder _finalRenderedRowFinder(WidgetTester tester) {
  final rows = tester.widgetList<PlayerListTile>(find.byType(PlayerListTile));
  expect(rows, isNotEmpty);
  final playerId = rows.last.player.id;
  return find.byKey(ValueKey<String>('squad-player-row-$playerId'));
}

Future<void> _activateProfileAction(
  WidgetTester tester,
  _ResponsiveSquadHarness harness,
  Finder row,
  String scenario,
) async {
  final playerId = tester
      .widgetList<PlayerListTile>(find.byType(PlayerListTile))
      .last
      .player
      .id;
  final profile = find.descendant(of: row, matching: find.byType(IconButton));
  expect(
    profile,
    findsOneWidget,
    reason: '$scenario: missing final profile action',
  );
  await tester.ensureVisible(profile);
  await tester.pumpAndSettle();
  await tester.tap(profile);
  await tester.pumpAndSettle();
  expect(
    harness.router.state.uri.path,
    '/game/player/$playerId',
    reason: '$scenario: profile action navigated to the wrong player',
  );
  expect(find.byType(PlayerDetailScreen), findsOneWidget);
  harness.router.pop();
  await tester.pumpAndSettle();
}

_TeamSnapshot _teamSnapshot(GameSave game) {
  final team = game.leagueState.playerTeam!;
  return (
    roster: team.roster.map((player) => player.id).toList(growable: false),
    lineup: List<String>.unmodifiable(team.lineupPlayerIds),
    bench: List<String>.unmodifiable(team.benchPlayerIds),
  );
}

GameSave _responsiveFixtureGame() {
  final base = task41Game(seed: 9707);
  final team = base.leagueState.playerTeam!;
  final assignedIds = <String>{...team.lineupPlayerIds, ...team.benchPlayerIds};
  final source = team.roster.firstWhere(
    (player) => !assignedIds.contains(player.id),
  );
  final responsivePlayer = source.copyWith(
    name: _responsiveLongName,
    state: source.state.copyWith(
      injury: const Injury(
        id: 'responsive-both-status-injury',
        group: InjuryGroup.legMuscles,
        type: InjuryType.minor,
        daysTotal: 5,
        daysRemaining: 3,
      ),
      suspensionGamesRemaining: 2,
    ),
  );
  final responsiveTeam = team.copyWith(
    roster: [
      for (final player in team.roster)
        player.id == source.id ? responsivePlayer : player,
    ],
  );
  return base.copyWith(
    leagueState: base.leagueState.updateTeam(responsiveTeam),
  );
}

Rect _testViewportRect(WidgetTester tester) {
  final physicalSize = tester.view.physicalSize;
  final devicePixelRatio = tester.view.devicePixelRatio;
  return Offset.zero &
      Size(
        physicalSize.width / devicePixelRatio,
        physicalSize.height / devicePixelRatio,
      );
}

void _expectHorizontalBounds(Rect outer, Rect inner, {required String reason}) {
  expect(
    inner.left,
    greaterThanOrEqualTo(outer.left - _geometryTolerance),
    reason: '$reason: left edge overflows',
  );
  expect(
    inner.right,
    lessThanOrEqualTo(outer.right + _geometryTolerance),
    reason: '$reason: right edge overflows',
  );
}

void _expectRectInside(Rect outer, Rect inner, {required String reason}) {
  expect(
    inner.left,
    greaterThanOrEqualTo(outer.left - _geometryTolerance),
    reason: '$reason: left edge overflows',
  );
  expect(
    inner.top,
    greaterThanOrEqualTo(outer.top - _geometryTolerance),
    reason: '$reason: top edge overflows',
  );
  expect(
    inner.right,
    lessThanOrEqualTo(outer.right + _geometryTolerance),
    reason: '$reason: right edge overflows',
  );
  expect(
    inner.bottom,
    lessThanOrEqualTo(outer.bottom + _geometryTolerance),
    reason: '$reason: bottom edge overflows',
  );
}

class _ResponsiveSquadHarness {
  _ResponsiveSquadHarness({
    required this.game,
    required this.viewport,
    required this.textScale,
  });

  final GameSave game;
  final Size viewport;
  final double textScale;
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

  void configureViewport(WidgetTester tester, Size nextViewport) {
    _configureTestView(tester, nextViewport);
  }

  Future<void> pump(WidgetTester tester) async {
    _configureTestView(tester, viewport);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
  }

  Widget _app() {
    return ProviderScope(
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
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    router.dispose();
    tester.view.reset();
  }
}

void _configureTestView(WidgetTester tester, Size viewport) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = viewport;
}

typedef _TeamSnapshot = ({
  List<String> roster,
  List<String> lineup,
  List<String> bench,
});
