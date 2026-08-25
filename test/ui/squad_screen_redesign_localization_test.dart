@Tags(['ui'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widget_harness.dart';

const _newLocalizationKeys = <String>[
  'squad_rosterCount',
  'squad_rosterMinimum',
  'squad_rosterMaximum',
  'squad_rosterStateInRange',
  'squad_rosterStateOutOfRange',
  'squad_rosterSizeSemantics',
  'squad_emptyRoster',
  'squad_statusInjury',
  'squad_statusSuspension',
  'squad_statusSlotEmpty',
  'squad_playerSelected',
  'squad_playerNotSelected',
  'squad_positionMismatch',
  'squad_playerRowSemantics',
  'squad_playerMarkerSemantics',
  'squad_zoneFrameSemantics',
  'squad_positionBadgeSemantics',
  'squad_ovrBadgeSemantics',
  'squad_formIndicatorSemantics',
  'squad_profileAction',
];

void main() {
  testWidgets(
    'resolves Polish and English squad labels and accessibility meanings',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        for (final locale in const [Locale('pl'), Locale('en')]) {
          final fixture = _accessibilityFixture();
          await tester.pumpWidget(_localizedApp(locale, fixture.game));
          await tester.pumpAndSettle();

          final l10n = await AppLocalizations.delegate.load(locale);
          _expectLocalizedSquadSurface(tester, l10n, fixture);
          _expectNoRawLocalizationKeys(tester);

          final emptyGame = _emptyRosterGame(fixture.game);
          await tester.pumpWidget(_localizedApp(locale, emptyGame));
          await tester.pumpAndSettle();

          expect(l10n.squad_emptyRoster.trim(), isNotEmpty);
          expect(find.text(l10n.squad_emptyRoster), findsOneWidget);
          _expectRangeState(tester, expected: l10n.squad_rosterStateOutOfRange);
          _expectNoRawLocalizationKeys(tester);
        }
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  // Feature: squad-row-polish, Property 7: Localization and accessibility expose the same state as the visuals
  testWidgets(
    'Feature: squad-row-polish, Property 7: Localization and accessibility expose the same state as the visuals',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        final baseFixture = _accessibilityFixture();
        const scenarios = <_Property7Scenario>[
          _Property7Scenario(
            name: 'empty-status',
            injury: false,
            suspension: false,
            form: -2.5,
          ),
          _Property7Scenario(
            name: 'injury-only',
            injury: true,
            suspension: false,
            form: 4.25,
          ),
          _Property7Scenario(
            name: 'suspension-only',
            injury: false,
            suspension: true,
            form: 12.5,
          ),
          _Property7Scenario(
            name: 'both-statuses',
            injury: true,
            suspension: true,
            form: 7.5,
          ),
        ];

        for (final locale in const [Locale('pl'), Locale('en')]) {
          final l10n = await AppLocalizations.delegate.load(locale);
          _expectProperty7LocalizationValues(l10n);

          for (final textScale in const <double>[1.0, 1.3, 2.0]) {
            for (final scenario in scenarios) {
              final game = _property7Game(baseFixture, scenario);
              await tester.pumpWidget(
                _localizedApp(
                  locale,
                  game,
                  textScale: textScale,
                  testKey: '${scenario.name}-$textScale',
                ),
              );
              await tester.pumpAndSettle();

              final team = game.leagueState.playerTeam!;
              final player = team.roster.firstWhere(
                (item) => item.id == baseFixture.player.id,
              );
              final zone = rosterZoneOf(team, player.id);
              final status = statusFor(player, baseFixture.assignment);
              final rowFinder = find.byKey(
                ValueKey<String>('squad-player-row-${player.id}'),
              );
              final rowLabel = _property7RowSemanticsLabel(
                l10n,
                player,
                status,
                zone,
              );

              _expectProperty7Surface(
                tester,
                l10n: l10n,
                player: player,
                zone: zone,
                rowFinder: rowFinder,
                rowLabel: rowLabel,
                scenario: scenario,
                textScale: textScale,
              );
              _expectNoRawLocalizationKeys(tester);

              if (scenario.injury && scenario.suspension) {
                await tester.ensureVisible(rowFinder);
                await tester.pumpAndSettle();
                await tester.tap(rowFinder);
                await tester.pump();
                _expectProperty7SelectedRow(
                  tester,
                  l10n: l10n,
                  player: player,
                  rowFinder: rowFinder,
                  rowLabel: rowLabel,
                  zone: zone,
                  scenario: scenario,
                );
              }
            }
          }
        }
      } finally {
        semanticsHandle.dispose();
      }
    },
  );
}

void _expectProperty7LocalizationValues(AppLocalizations l10n) {
  final polish = l10n.localeName.startsWith('pl');
  final expectedZoneLabels = polish
      ? const ['XI', 'Ławka', 'Rezerwy']
      : const ['XI', 'Bench', 'Reserves'];
  expect([
    l10n.squad_zoneXi,
    l10n.squad_zoneBench,
    l10n.squad_zoneReserves,
  ], expectedZoneLabels);
  expect(
    l10n.squad_statusSlotEmpty,
    polish ? 'Brak aktywnego statusu' : 'No active status',
  );
  expect(l10n.squad_playerSelected, polish ? 'Zaznaczony' : 'Selected');
  expect(
    l10n.squad_playerNotSelected,
    polish ? 'Niezaznaczony' : 'Not selected',
  );

  final values = <String>[
    l10n.squad_statusInjury,
    l10n.squad_statusSuspension,
    l10n.squad_statusSlotEmpty,
    l10n.squad_playerSelected,
    l10n.squad_playerNotSelected,
    l10n.squad_formIndicatorSemantics('10'),
    l10n.squad_zoneFrameSemantics(l10n.squad_zoneXi),
    l10n.squad_profileAction('Property Seven Player'),
  ];
  for (final value in values) {
    expect(value.trim(), isNotEmpty);
  }
}

void _expectProperty7Surface(
  WidgetTester tester, {
  required AppLocalizations l10n,
  required Player player,
  required RosterZone zone,
  required Finder rowFinder,
  required String rowLabel,
  required _Property7Scenario scenario,
  required double textScale,
}) {
  expect(rowFinder, findsOneWidget);

  final rowSemanticsFinder = find.bySemanticsLabel(rowLabel);
  expect(
    rowSemanticsFinder,
    findsOneWidget,
    reason: '${scenario.name} at text scale $textScale: missing row semantics',
  );
  final rowSemantics = tester.getSemantics(rowSemanticsFinder);
  expect(rowSemantics.flagsCollection.isSelected, ui.Tristate.isFalse);
  expect(rowSemantics.value, l10n.squad_playerNotSelected);

  final zoneLabel = _localizedZoneLabel(l10n, zone);
  expect(zoneLabel.trim(), isNotEmpty);
  expect(
    find.descendant(
      of: rowFinder,
      matching: find.bySemanticsLabel(l10n.squad_zoneFrameSemantics(zoneLabel)),
    ),
    findsOneWidget,
  );

  final formValue = clampedFormValue(player.state.form);
  expect(formValue, inInclusiveRange(0.0, 10.0));
  final formLabel = l10n.squad_formIndicatorSemantics(_formatForm(formValue));
  expect(
    find.descendant(of: rowFinder, matching: find.bySemanticsLabel(formLabel)),
    findsOneWidget,
    reason: 'form semantics lost its clamped numeric value',
  );

  final profileLabel = l10n.squad_profileAction(player.name);
  final profileFinder = find.descendant(
    of: rowFinder,
    matching: find.bySemanticsLabel(profileLabel),
  );
  expect(profileFinder, findsOneWidget);
  final profileSemantics = tester.getSemantics(profileFinder);
  expect(profileSemantics.flagsCollection.isButton, isTrue);
  final profileButtonFinder = find.descendant(
    of: rowFinder,
    matching: find.byType(IconButton),
  );
  expect(profileButtonFinder, findsOneWidget);
  final profileButtonSemantics = tester.getSemantics(profileButtonFinder);
  expect(profileButtonSemantics.flagsCollection.isButton, isTrue);
  final profileButton = tester.widget<IconButton>(profileButtonFinder);
  expect(
    profileButton.onPressed,
    isNotNull,
    reason: 'InfoAction must remain independently activatable on the row',
  );

  _expectProperty7StatusSlot(
    tester,
    l10n: l10n,
    rowFinder: rowFinder,
    scenario: scenario,
  );
  _expectProperty7Contrast(
    tester,
    l10n: l10n,
    rowFinder: rowFinder,
    zone: zone,
    scenario: scenario,
  );
}

void _expectProperty7StatusSlot(
  WidgetTester tester, {
  required AppLocalizations l10n,
  required Finder rowFinder,
  required _Property7Scenario scenario,
}) {
  final statusFinder = find.descendant(
    of: rowFinder,
    matching: find.byType(StatusIcons),
  );
  expect(statusFinder, findsOneWidget);

  final expectedLabels = <String>[
    if (scenario.injury) l10n.squad_statusInjury,
    if (scenario.suspension) l10n.squad_statusSuspension,
  ];
  final tooltipMessage = expectedLabels.isEmpty
      ? l10n.squad_statusSlotEmpty
      : expectedLabels.join('. ');
  expect(
    find.descendant(of: rowFinder, matching: find.byTooltip(tooltipMessage)),
    findsOneWidget,
    reason: 'localized status tooltip does not match the visual state',
  );

  final visualSymbols = find.descendant(
    of: statusFinder,
    matching: find.byType(Icon),
  );
  expect(
    visualSymbols,
    expectedLabels.isEmpty ? findsNothing : findsOneWidget,
    reason: 'status slot must paint at most one visual symbol',
  );
  expect(
    find.descendant(
      of: statusFinder,
      matching: find.byIcon(Icons.healing_outlined),
    ),
    scenario.injury ? findsOneWidget : findsNothing,
  );
  expect(
    find.descendant(
      of: statusFinder,
      matching: find.byIcon(Icons.gavel_outlined),
    ),
    !scenario.injury && scenario.suspension ? findsOneWidget : findsNothing,
  );

  for (final label in [l10n.squad_statusInjury, l10n.squad_statusSuspension]) {
    final labelFinder = find.descendant(
      of: statusFinder,
      matching: find.bySemanticsLabel(label),
    );
    expect(
      labelFinder,
      expectedLabels.contains(label) ? findsOneWidget : findsNothing,
      reason: 'inactive status must not be announced by the status slot',
    );
  }
  if (expectedLabels.isEmpty) {
    expect(
      find.descendant(
        of: statusFinder,
        matching: find.bySemanticsLabel(l10n.squad_statusSlotEmpty),
      ),
      findsOneWidget,
    );
  }
}

void _expectProperty7Contrast(
  WidgetTester tester, {
  required AppLocalizations l10n,
  required Finder rowFinder,
  required RosterZone zone,
  required _Property7Scenario scenario,
}) {
  final frameContainers = tester
      .widgetList<Container>(
        find.descendant(of: rowFinder, matching: find.byType(Container)),
      )
      .where((container) {
        final decoration = container.decoration;
        return container.margin != null &&
            decoration is BoxDecoration &&
            decoration.border != null;
      })
      .toList();
  expect(frameContainers, hasLength(1));
  final frameDecoration = frameContainers.single.decoration! as BoxDecoration;
  final rowBackground = frameDecoration.color!;
  final frameBorder = frameDecoration.border! as Border;
  expect(
    contrastRatio(frameBorder.top.color, rowBackground),
    greaterThanOrEqualTo(3),
    reason: '${scenario.name}: zone border contrast is too low',
  );

  final zoneLabel = _localizedZoneLabel(l10n, zone);
  final zoneTextFinder = find.descendant(
    of: rowFinder,
    matching: find.text(zoneLabel),
  );
  expect(zoneTextFinder, findsOneWidget);
  final zoneText = tester.widget<Text>(zoneTextFinder);
  expect(
    contrastRatio(zoneText.style!.color!, rowBackground),
    greaterThanOrEqualTo(4.5),
    reason: '${scenario.name}: zone label contrast is too low',
  );

  final statusIcons = tester.widgetList<Icon>(
    find.descendant(
      of: find.descendant(of: rowFinder, matching: find.byType(StatusIcons)),
      matching: find.byType(Icon),
    ),
  );
  for (final icon in statusIcons) {
    expect(icon.color, isNotNull);
    expect(
      contrastRatio(icon.color!, rowBackground),
      greaterThanOrEqualTo(3),
      reason: '${scenario.name}: active status contrast is too low',
    );
  }

  final zoneColor = frameBorder.top.color;
  expect(_property7HasZoneColorFamily(zoneColor, zone), isTrue);
}

void _expectProperty7SelectedRow(
  WidgetTester tester, {
  required AppLocalizations l10n,
  required Player player,
  required Finder rowFinder,
  required String rowLabel,
  required RosterZone zone,
  required _Property7Scenario scenario,
}) {
  final rowSemantics = tester.getSemantics(find.bySemanticsLabel(rowLabel));
  expect(rowSemantics.flagsCollection.isSelected, ui.Tristate.isTrue);
  expect(rowSemantics.value, l10n.squad_playerSelected);

  final profileFinder = find.descendant(
    of: rowFinder,
    matching: find.bySemanticsLabel(l10n.squad_profileAction(player.name)),
  );
  expect(profileFinder, findsOneWidget);
  final profileSemantics = tester.getSemantics(profileFinder);
  expect(profileSemantics.flagsCollection.isButton, isTrue);
  final profileButtonFinder = find.descendant(
    of: rowFinder,
    matching: find.byType(IconButton),
  );
  expect(profileButtonFinder, findsOneWidget);
  final profileButtonSemantics = tester.getSemantics(profileButtonFinder);
  expect(profileButtonSemantics.flagsCollection.isButton, isTrue);
  expect(tester.widget<IconButton>(profileButtonFinder).onPressed, isNotNull);
  expect(
    find.descendant(
      of: rowFinder,
      matching: find.bySemanticsLabel(
        l10n.squad_zoneFrameSemantics(_localizedZoneLabel(l10n, zone)),
      ),
    ),
    findsOneWidget,
  );

  final selectedDecorations = tester
      .widgetList<DecoratedBox>(
        find.descendant(of: rowFinder, matching: find.byType(DecoratedBox)),
      )
      .where((decoratedBox) {
        final decoration = decoratedBox.decoration;
        return decoration is BoxDecoration &&
            decoration.color != null &&
            decoration.border != null &&
            (decoration.color!.a - 0.12).abs() < 0.0001;
      })
      .toList();
  expect(selectedDecorations, hasLength(1));
  final selectedDecoration =
      selectedDecorations.single.decoration as BoxDecoration;
  final theme = Theme.of(tester.element(rowFinder));
  final primary = theme.colorScheme.primary;
  expect(selectedDecoration.color!.a, inInclusiveRange(0.08, 0.16));
  expect(
    selectedDecoration.color!.toARGB32(),
    primary.withValues(alpha: 0.12).toARGB32(),
  );
  final selectedBorder = selectedDecoration.border! as Border;
  for (final side in [
    selectedBorder.top,
    selectedBorder.right,
    selectedBorder.bottom,
    selectedBorder.left,
  ]) {
    expect(side.width, inInclusiveRange(1.0, 2.0));
    expect(side.color.toARGB32(), primary.toARGB32());
  }

  final frameContainers = tester
      .widgetList<Container>(
        find.descendant(of: rowFinder, matching: find.byType(Container)),
      )
      .where((container) {
        final decoration = container.decoration;
        return container.margin != null &&
            decoration is BoxDecoration &&
            decoration.border != null;
      })
      .toList();
  expect(frameContainers, hasLength(1));
  final frameDecoration = frameContainers.single.decoration! as BoxDecoration;
  expect(
    contrastRatio(primary, frameDecoration.color!),
    greaterThanOrEqualTo(3),
    reason: '${scenario.name}: selection outline contrast is too low',
  );

  _expectProperty7Contrast(
    tester,
    l10n: l10n,
    rowFinder: rowFinder,
    zone: zone,
    scenario: scenario,
  );
}

bool _property7HasZoneColorFamily(Color color, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return color.g > color.r && color.g > color.b;
    case RosterZone.bench:
      return color.b > color.r && color.b > color.g;
    case RosterZone.reserve:
      return color.r > color.b && color.g > color.b;
  }
}

String _property7RowSemanticsLabel(
  AppLocalizations l10n,
  Player player,
  SquadStatus status,
  RosterZone zone,
) {
  final form = clampedFormValue(player.state.form);
  final base = l10n.squad_playerRowSemantics(
    player.name,
    player.position.code,
    roundedOvrForDisplay(player.overall()),
    _formatForm(form),
    _localizedZoneLabel(l10n, zone),
  );
  final statuses = <String>[
    if (status.hasActiveInjury) l10n.squad_statusInjury,
    if (status.hasActiveSuspension) l10n.squad_statusSuspension,
    if (status.hasPositionMismatch) l10n.squad_positionMismatch,
  ];
  return statuses.isEmpty ? base : '$base. ${statuses.join('. ')}.';
}

GameSave _property7Game(
  _AccessibilityFixture fixture,
  _Property7Scenario scenario,
) {
  final team = fixture.game.leagueState.playerTeam!;
  final updatedPlayer = fixture.player.copyWith(
    state: fixture.player.state.copyWith(
      injury: scenario.injury ? fixture.player.state.injury : null,
      suspensionGamesRemaining: scenario.suspension ? 2 : 0,
      form: scenario.form,
    ),
  );
  final roster = [
    for (final player in team.roster)
      player.id == updatedPlayer.id ? updatedPlayer : player,
  ];
  return fixture.game.copyWith(
    leagueState: fixture.game.leagueState.updateTeam(
      team.copyWith(roster: roster),
    ),
  );
}

void _expectLocalizedSquadSurface(
  WidgetTester tester,
  AppLocalizations l10n,
  _AccessibilityFixture fixture,
) {
  final team = fixture.game.leagueState.playerTeam!;
  final count = team.roster.length;
  final min = BalanceConfig.defaults.roster.minSize;
  final max = BalanceConfig.defaults.roster.maxSize;
  final presentation = rosterSizePresentation(count: count, min: min, max: max);
  final stateLabel = presentation.isInRange
      ? l10n.squad_rosterStateInRange
      : l10n.squad_rosterStateOutOfRange;
  final otherStateLabel = presentation.isInRange
      ? l10n.squad_rosterStateOutOfRange
      : l10n.squad_rosterStateInRange;
  final zoneLabel = _localizedZoneLabel(
    l10n,
    rosterZoneOf(team, fixture.player.id),
  );
  final roundedOvr = roundedOvrForDisplay(fixture.player.overall());
  final clampedForm = clampedFormValue(fixture.player.state.form);
  final formText = _formatForm(clampedForm);
  final status = statusFor(fixture.player, fixture.assignment);
  final statusLabels = <String>[
    if (status.hasActiveInjury) l10n.squad_statusInjury,
    if (status.hasActiveSuspension) l10n.squad_statusSuspension,
    if (status.hasPositionMismatch) l10n.squad_positionMismatch,
  ];
  final markerStatus = statusLabels.join(', ');
  final rowLabel =
      '${l10n.squad_playerRowSemantics(fixture.player.name, fixture.player.position.code, roundedOvr, formText, zoneLabel)}. '
      '${statusLabels.join('. ')}.';
  final markerLabel = l10n.squad_playerMarkerSemantics(
    fixture.player.name,
    fixture.player.position.code,
    markerStatus,
  );

  final labels = <String>[
    l10n.squad_rosterCount(count),
    l10n.squad_rosterMinimum(min),
    l10n.squad_rosterMaximum(max),
    l10n.squad_rosterStateInRange,
    l10n.squad_rosterStateOutOfRange,
    l10n.squad_rosterSizeSemantics(count, min, max, stateLabel),
    l10n.squad_emptyRoster,
    l10n.squad_statusInjury,
    l10n.squad_statusSuspension,
    l10n.squad_positionMismatch,
    rowLabel,
    markerLabel,
    l10n.squad_zoneFrameSemantics(zoneLabel),
    l10n.squad_positionBadgeSemantics(fixture.player.position.code),
    l10n.squad_ovrBadgeSemantics(roundedOvr),
    l10n.squad_formIndicatorSemantics(formText),
    l10n.squad_profileAction(fixture.player.name),
    l10n.squad_rosterTitle,
    l10n.squad_sortOverall,
    l10n.squad_sortAssignedZone,
    l10n.squad_sortForm,
    l10n.squad_sortPosition,
    l10n.squad_zoneXi,
    l10n.squad_zoneBench,
    l10n.squad_zoneReserves,
  ];
  for (final label in labels) {
    expect(label.trim(), isNotEmpty);
  }

  expect(find.text(l10n.squad_rosterTitle), findsWidgets);
  expect(find.byTooltip(l10n.squad_rosterCount(count)), findsOneWidget);
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

  final indicatorFinder = find.byKey(
    const ValueKey<String>('squad-size-indicator'),
  );
  expect(indicatorFinder, findsOneWidget);
  final indicatorSemantics = tester.getSemantics(indicatorFinder);
  expect(
    indicatorSemantics.label,
    l10n.squad_rosterSizeSemantics(count, min, max, stateLabel),
  );
  _expectRangeState(tester, expected: stateLabel);
  expect(indicatorSemantics.label, isNot(contains(otherStateLabel)));

  final rowKeyFinder = find.byKey(
    ValueKey<String>('squad-player-row-${fixture.player.id}'),
  );
  expect(rowKeyFinder, findsOneWidget);
  final rowSemanticsFinder = find.bySemanticsLabel(rowLabel);
  expect(rowSemanticsFinder, findsOneWidget);
  expect(tester.getSemantics(rowSemanticsFinder).label, rowLabel);

  final profileLabel = l10n.squad_profileAction(fixture.player.name);
  final profileFinder = find.descendant(
    of: rowKeyFinder,
    matching: find.bySemanticsLabel(profileLabel),
  );
  expect(profileFinder, findsOneWidget);
  final profileSemantics = tester.getSemantics(profileFinder);
  expect(profileSemantics.label, profileLabel);
  expect(profileSemantics.flagsCollection.isButton, isTrue);

  for (final statusLabel in [
    l10n.squad_statusInjury,
    l10n.squad_statusSuspension,
  ]) {
    final statusFinder = find.descendant(
      of: rowKeyFinder,
      matching: find.bySemanticsLabel(statusLabel),
    );
    expect(statusFinder, findsOneWidget);
    expect(tester.getSemantics(statusFinder).label, statusLabel);
  }

  expect(
    find.descendant(
      of: rowKeyFinder,
      matching: find.bySemanticsLabel(l10n.squad_zoneFrameSemantics(zoneLabel)),
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(
      of: rowKeyFinder,
      matching: find.bySemanticsLabel(
        l10n.squad_positionBadgeSemantics(fixture.player.position.code),
      ),
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(
      of: rowKeyFinder,
      matching: find.bySemanticsLabel(l10n.squad_ovrBadgeSemantics(roundedOvr)),
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(
      of: rowKeyFinder,
      matching: find.bySemanticsLabel(
        l10n.squad_formIndicatorSemantics(formText),
      ),
    ),
    findsOneWidget,
  );
  expect(find.bySemanticsLabel(markerLabel), findsOneWidget);
  expect(markerLabel, contains(l10n.squad_positionMismatch));
  expect(rowLabel, contains(l10n.squad_positionMismatch));
}

void _expectRangeState(WidgetTester tester, {required String expected}) {
  final indicator = tester.getSemantics(
    find.byKey(const ValueKey<String>('squad-size-indicator')),
  );
  final l10n = AppLocalizations.of(tester.element(find.byType(SquadScreen)))!;
  final states = [
    l10n.squad_rosterStateInRange,
    l10n.squad_rosterStateOutOfRange,
  ];
  final presentStates = states
      .where((state) => indicator.label.contains(state))
      .toList(growable: false);
  expect(presentStates, hasLength(1));
  expect(presentStates.single, expected);
}

void _expectNoRawLocalizationKeys(WidgetTester tester) {
  for (final key in _newLocalizationKeys) {
    expect(
      find.textContaining(key),
      findsNothing,
      reason: 'raw localization key is visible: $key',
    );
    expect(
      find.bySemanticsLabel(RegExp(RegExp.escape(key))),
      findsNothing,
      reason: 'raw localization key is exposed to semantics: $key',
    );
    expect(
      find.byTooltip(key),
      findsNothing,
      reason: 'raw localization key is exposed as a tooltip: $key',
    );
  }
}

String _localizedZoneLabel(AppLocalizations l10n, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return l10n.squad_zoneXi;
    case RosterZone.bench:
      return l10n.squad_zoneBench;
    case RosterZone.reserve:
      return l10n.squad_zoneReserves;
  }
}

String _formatForm(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

_AccessibilityFixture _accessibilityFixture() {
  final base = task41Game(seed: 9505);
  final baseTeam = base.leagueState.playerTeam!;
  final injury = const Injury(
    id: 'localization-smoke-injury',
    group: InjuryGroup.legMuscles,
    type: InjuryType.minor,
    daysTotal: 5,
    daysRemaining: 3,
  );

  for (final playerId in baseTeam.lineupPlayerIds) {
    final source = baseTeam.roster.firstWhere(
      (player) => player.id == playerId,
    );
    for (final position in Position.values) {
      final player = source.copyWith(
        position: position,
        state: source.state.copyWith(
          injury: injury,
          suspensionGamesRemaining: 2,
        ),
      );
      try {
        player.overall();
      } on ArgumentError {
        continue;
      }
      final roster = [
        for (final rosterPlayer in baseTeam.roster)
          rosterPlayer.id == playerId ? player : rosterPlayer,
      ];
      final team = baseTeam.copyWith(roster: roster);
      final playersById = <String, Player>{
        for (final rosterPlayer in team.roster) rosterPlayer.id: rosterPlayer,
      };
      final placements = placePlayersOnSlots(
        slots: FormationLayout.of(team.tactics.formation).slots,
        lineupPlayerIds: team.lineupPlayerIds,
        playersById: playersById,
      );
      PlacedPlayer? assignment;
      for (final placement in placements) {
        if (placement.player?.id == playerId) {
          assignment = placement;
          break;
        }
      }
      if (assignment == null || assignment.slot.position == player.position) {
        continue;
      }

      return _AccessibilityFixture(
        game: base.copyWith(leagueState: base.leagueState.updateTeam(team)),
        player: player,
        assignment: assignment.slot,
      );
    }
  }

  throw StateError('Unable to construct a deterministic mismatch fixture');
}

GameSave _emptyRosterGame(GameSave game) {
  final team = game.leagueState.playerTeam!;
  return game.copyWith(
    leagueState: game.leagueState.updateTeam(
      team.copyWith(
        roster: const [],
        lineupPlayerIds: const [],
        benchPlayerIds: const [],
      ),
    ),
  );
}

Widget _localizedApp(
  Locale locale,
  GameSave game, {
  double textScale = 1.0,
  String testKey = 'default',
}) {
  return ProviderScope(
    key: ValueKey<String>(
      'squad-localization-${locale.languageCode}-${game.leagueState.playerTeam?.roster.length}-$textScale-$testKey',
    ),
    overrides: [
      saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        return controller;
      }),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: const Scaffold(body: SquadScreen()),
    ),
  );
}

class _Property7Scenario {
  const _Property7Scenario({
    required this.name,
    required this.injury,
    required this.suspension,
    required this.form,
  });

  final String name;
  final bool injury;
  final bool suspension;
  final double form;
}

class _AccessibilityFixture {
  const _AccessibilityFixture({
    required this.game,
    required this.player,
    required this.assignment,
  });

  final GameSave game;
  final Player player;
  final AssignedSlot assignment;
}
