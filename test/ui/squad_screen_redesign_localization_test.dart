@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
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

Widget _localizedApp(Locale locale, GameSave game) {
  return ProviderScope(
    key: ValueKey<String>(
      'squad-localization-${locale.languageCode}-${game.leagueState.playerTeam?.roster.length}',
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
      home: const Scaffold(body: SquadScreen()),
    ),
  );
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
