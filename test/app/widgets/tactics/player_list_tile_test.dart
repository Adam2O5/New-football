@Tags(['ui'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/position_group.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'renders badges in order with equal dimensions and normalized name lines',
    (tester) async {
      final game = _fixtureGame(seed: 4210);
      final player = _copyPlayer(
        game,
        id: 'badge-order-player',
        name: '  Ada   Lovelace   Hamilton  ',
        form: 7.25,
        position: Position.cm,
      );

      await tester.pumpWidget(
        _tileApp(
          game,
          player: player,
          onTap: () {},
          positionAssignment: _slot('cm-slot', Position.cm),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Lovelace Hamilton'), findsOneWidget);
      expect(find.byType(FormIndicator), findsOneWidget);
      expect(find.text('7.25'), findsNothing);

      final positionFinder = find.byType(PositionBadge);
      final ovrFinder = find.byType(OvrBadge);
      expect(positionFinder, findsOneWidget);
      expect(ovrFinder, findsOneWidget);

      final positionRect = tester.getRect(positionFinder);
      final ovrRect = tester.getRect(ovrFinder);
      expect(positionRect.right, lessThanOrEqualTo(ovrRect.left));
      expect(tester.getSize(positionFinder), tester.getSize(ovrFinder));
      expect(
        tester.widget<PositionBadge>(positionFinder).size,
        tester.widget<OvrBadge>(ovrFinder).size,
      );
    },
  );

  testWidgets(
    'renders one bordered form indicator at badge width and orders the right status area',
    (tester) async {
      final game = _fixtureGame(seed: 4220);
      final player = _copyPlayer(
        game,
        id: 'form-layout-player',
        name: 'Form Layout Player',
        form: 6.5,
        position: Position.cm,
      );

      for (final scenario in const <({double width, double badgeSize})>[
        (width: 360, badgeSize: 32),
        (width: 400, badgeSize: 36),
      ]) {
        await tester.pumpWidget(
          _tileApp(game, player: player, width: scenario.width, onTap: () {}),
        );
        await tester.pumpAndSettle();

        final positionFinder = find.byType(PositionBadge);
        final formFinder = find.byType(FormIndicator);
        final statusFinder = find.byType(StatusIcons);
        final profileFinder = find.byType(IconButton);
        expect(positionFinder, findsOneWidget);
        expect(formFinder, findsOneWidget);
        expect(statusFinder, findsOneWidget);
        expect(profileFinder, findsOneWidget);

        final positionBadge = tester.widget<PositionBadge>(positionFinder);
        final formIndicator = tester.widget<FormIndicator>(formFinder);
        expect(positionBadge.size, scenario.badgeSize);
        expect(formIndicator.width, scenario.badgeSize);

        final positionRect = tester.getRect(positionFinder);
        final formRect = tester.getRect(formFinder);
        final statusRect = tester.getRect(statusFinder);
        final profileRect = tester.getRect(profileFinder);
        expect(formRect.width, closeTo(positionRect.width, 0.001));
        expect(formRect.width, inInclusiveRange(32.0, 36.0));
        expect(formRect.right, lessThanOrEqualTo(statusRect.left));
        expect(statusRect.right, lessThanOrEqualTo(profileRect.left));

        final trackFinder = find.descendant(
          of: formFinder,
          matching: find.byType(Container),
        );
        expect(trackFinder, findsOneWidget);
        final track = tester.widget<Container>(trackFinder);
        final decoration = track.decoration! as BoxDecoration;
        final border = decoration.border! as Border;
        for (final side in [
          border.top,
          border.right,
          border.bottom,
          border.left,
        ]) {
          expect(side.style, BorderStyle.solid);
          expect(side.width, closeTo(1, 0.001));
        }
      }
    },
  );

  testWidgets(
    'keeps one fixed status slot, one visual symbol, and stable right-side bounds',
    (tester) async {
      final game = _fixtureGame(seed: 4221);
      const scenarios = <({bool injury, bool suspension, double form})>[
        (injury: false, suspension: false, form: 2),
        (injury: true, suspension: false, form: 4),
        (injury: false, suspension: true, form: 7),
        (injury: true, suspension: true, form: 9.5),
      ];
      Rect? previousFormRect;
      Rect? previousStatusRect;
      Rect? previousProfileRect;

      for (final scenario in scenarios) {
        final player = _copyPlayer(
          game,
          id: 'status-slot-player',
          name: 'Status Slot Player',
          position: Position.cm,
          form: scenario.form,
          activeInjury: scenario.injury,
          activeSuspension: scenario.suspension,
        );
        await tester.pumpWidget(
          _tileApp(game, player: player, width: 400, onTap: () {}),
        );
        await tester.pumpAndSettle();

        final l10n = _tileLocalizations(tester);
        final statusFinder = find.byType(StatusIcons);
        final formFinder = find.byType(FormIndicator);
        final profileFinder = find.byType(IconButton);
        expect(statusFinder, findsOneWidget);
        expect(formFinder, findsOneWidget);
        expect(profileFinder, findsOneWidget);

        final formRect = tester.getRect(formFinder);
        final statusRect = tester.getRect(statusFinder);
        final profileRect = tester.getRect(profileFinder);
        expect(statusRect.width, closeTo(25, 0.001));
        expect(statusRect.height, closeTo(32, 0.001));
        expect(formRect.right, lessThanOrEqualTo(statusRect.left));
        expect(statusRect.right, lessThanOrEqualTo(profileRect.left));
        if (previousFormRect != null) {
          _expectSameRect(formRect, previousFormRect);
          _expectSameRect(statusRect, previousStatusRect!);
          _expectSameRect(profileRect, previousProfileRect!);
        }
        previousFormRect = formRect;
        previousStatusRect = statusRect;
        previousProfileRect = profileRect;

        final expectedStatusLabels = <String>[
          if (scenario.injury) l10n.squad_statusInjury,
          if (scenario.suspension) l10n.squad_statusSuspension,
        ];
        final tooltipMessage = expectedStatusLabels.isEmpty
            ? l10n.squad_statusSlotEmpty
            : expectedStatusLabels.join('. ');
        expect(find.byTooltip(tooltipMessage), findsOneWidget);

        final visualIcons = tester.widgetList<Icon>(
          find.descendant(of: statusFinder, matching: find.byType(Icon)),
        );
        expect(
          visualIcons,
          scenario.injury || scenario.suspension ? hasLength(1) : isEmpty,
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
          !scenario.injury && scenario.suspension
              ? findsOneWidget
              : findsNothing,
        );

        final statusLabels = [
          l10n.squad_statusInjury,
          l10n.squad_statusSuspension,
        ];
        final expectedSemanticsLabels = expectedStatusLabels.isEmpty
            ? [l10n.squad_statusSlotEmpty]
            : expectedStatusLabels;
        for (final label in expectedSemanticsLabels) {
          expect(
            find.descendant(
              of: statusFinder,
              matching: find.bySemanticsLabel(label),
            ),
            findsOneWidget,
          );
        }
        for (final label in statusLabels) {
          if (!expectedStatusLabels.contains(label)) {
            expect(
              find.descendant(
                of: statusFinder,
                matching: find.bySemanticsLabel(label),
              ),
              findsNothing,
            );
          }
        }
      }
    },
  );

  testWidgets(
    'renders the selected surface around the full zone frame with selected semantics',
    (tester) async {
      final game = _fixtureGame(seed: 4222);
      final player = _copyPlayer(
        game,
        id: 'selected-surface-player',
        name: 'Selected Surface Player',
        position: Position.cm,
        form: 8.5,
        activeInjury: true,
        activeSuspension: true,
      );
      final assignment = _slot('selected-surface-slot', Position.cm);
      final semanticsHandle = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          _tileApp(
            game,
            player: player,
            zone: RosterZone.bench,
            selected: true,
            positionAssignment: assignment,
            width: 400,
            onTap: () {},
          ),
        );
        await tester.pumpAndSettle();

        final rowFinder = find.byKey(ValueKey('squad-player-row-${player.id}'));
        final frameFinder = find.descendant(
          of: rowFinder,
          matching: find.byType(ZoneFrame),
        );
        expect(rowFinder, findsOneWidget);
        expect(frameFinder, findsOneWidget);
        expect(
          find.text(_zoneLabel(_tileLocalizations(tester), RosterZone.bench)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: rowFinder, matching: find.byType(FormIndicator)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: rowFinder,
            matching: find.byIcon(Icons.healing_outlined),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: rowFinder,
            matching: find.byIcon(Icons.gavel_outlined),
          ),
          findsNothing,
        );
        expect(
          find.descendant(of: rowFinder, matching: find.byType(IconButton)),
          findsOneWidget,
        );

        final selectedDecorations = tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: rowFinder,
                matching: find.byType(DecoratedBox),
              ),
            )
            .where((decoratedBox) {
              final decoration = decoratedBox.decoration;
              if (decoration is! BoxDecoration ||
                  decoration.border == null ||
                  decoration.color == null) {
                return false;
              }
              return (decoration.color!.a - 0.12).abs() < 0.0001;
            })
            .toList();
        expect(selectedDecorations, hasLength(1));
        final selectedDecoration =
            selectedDecorations.single.decoration as BoxDecoration;
        final selectedBorder = selectedDecoration.border! as Border;
        final primary = Theme.of(
          tester.element(find.byType(PlayerListTile)),
        ).colorScheme.primary;
        expect(selectedDecoration.color!.a, closeTo(0.12, 0.0001));
        expect(
          selectedDecoration.color!.toARGB32(),
          primary.withValues(alpha: 0.12).toARGB32(),
        );
        for (final side in [
          selectedBorder.top,
          selectedBorder.right,
          selectedBorder.bottom,
          selectedBorder.left,
        ]) {
          expect(side.width, inInclusiveRange(1.0, 2.0));
          expect(side.color.toARGB32(), primary.toARGB32());
        }

        final selectedFinder = find.byWidget(selectedDecorations.single);
        final selectedRect = tester.getRect(selectedFinder);
        final frameRect = tester.getRect(frameFinder);
        expect(selectedRect.left, closeTo(frameRect.left, 0.001));
        expect(selectedRect.top, closeTo(frameRect.top, 0.001));
        expect(selectedRect.right, closeTo(frameRect.right, 0.001));
        expect(selectedRect.bottom, closeTo(frameRect.bottom, 0.001));

        final frameContainer = _zoneBorderContainer(tester);
        final frameDecoration = frameContainer.decoration! as BoxDecoration;
        final frameBorder = frameDecoration.border! as Border;
        expect(
          _hasZoneColorFamily(frameBorder.top.color, RosterZone.bench),
          isTrue,
        );
        for (final finder in <Finder>[
          find.byType(PositionBadge),
          find.byType(OvrBadge),
          find.byType(FormIndicator),
          find.byType(StatusIcons),
          find.byType(IconButton),
        ]) {
          _expectInside(tester.getRect(finder), frameRect);
        }

        final l10n = _tileLocalizations(tester);
        final status = statusFor(player, assignment);
        final rowLabel = _rowSemanticsLabel(
          l10n,
          player,
          status,
          RosterZone.bench,
        );
        final selectedSemantics = tester.getSemantics(
          find.bySemanticsLabel(rowLabel),
        );
        expect(
          selectedSemantics.flagsCollection.isSelected,
          ui.Tristate.isTrue,
        );
        expect(selectedSemantics.value, l10n.squad_playerSelected);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'keeps a one-part name on the upper line without a second name line',
    (tester) async {
      final game = _fixtureGame(seed: 42101);
      final player = _copyPlayer(
        game,
        id: 'single-name-player',
        name: 'Pelé',
        position: Position.st,
      );

      await tester.pumpWidget(_tileApp(game, player: player, onTap: () {}));
      await tester.pumpAndSettle();

      expect(find.text('Pelé'), findsOneWidget);
      final nameTexts = tester
          .widgetList<Text>(find.byType(Text))
          .where((text) => text.data == 'Pelé' || text.data == '')
          .toList();
      expect(nameTexts, hasLength(1));
      expect(find.byType(FormIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'opens the represented profile independently from row selection',
    (tester) async {
      final game = _fixtureGame(seed: 4211);
      final player = _copyPlayer(
        game,
        id: 'profile-action-player',
        name: 'Profile Target',
      );
      var tapCount = 0;
      final profileIds = <String>[];

      await tester.pumpWidget(
        _tileApp(
          game,
          player: player,
          onTap: () => tapCount++,
          onInfo: () => profileIds.add(player.id),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = _tileLocalizations(tester);
      expect(
        find.bySemanticsLabel(l10n.squad_profileAction(player.name)),
        findsOneWidget,
      );

      await tester.tap(find.byKey(ValueKey('squad-player-row-${player.id}')));
      await tester.pump();
      expect(tapCount, 1);
      expect(profileIds, isEmpty);

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();
      expect(tapCount, 1);
      expect(profileIds, [player.id]);
    },
  );

  testWidgets(
    'renders every OVR gradient endpoint and clamped edge with contrast-safe text',
    (tester) async {
      final values = <int>[
        49,
        50,
        51,
        59,
        60,
        61,
        69,
        70,
        71,
        79,
        80,
        81,
        89,
        90,
        91,
        98,
        99,
        100,
      ];
      final exactStops = <int, Color>{
        50: Colors.red,
        60: Colors.orange,
        70: Colors.yellow,
        80: Colors.lightGreen,
        90: const Color(0xFF2E7D32),
        99: Colors.blue,
      };

      for (final value in values) {
        await tester.pumpWidget(
          _localizedApp(
            (context) => OvrBadge(
              ovr: value,
              size: 36,
              l10n: AppLocalizations.of(context)!,
            ),
          ),
        );
        await tester.pump();

        final badgeFinder = find.byType(OvrBadge);
        final container = _circleContainer(tester, badgeFinder);
        final decoration = container.decoration! as BoxDecoration;
        final background = decoration.color!;
        expect(
          background.toARGB32(),
          ovrColorForRoundedValue(value).toARGB32(),
        );
        if (exactStops.containsKey(value)) {
          expect(background.toARGB32(), exactStops[value]!.toARGB32());
        }

        final text = tester.widget<Text>(
          find.descendant(of: badgeFinder, matching: find.byType(Text)),
        );
        expect(text.data, '$value');
        expect(
          contrastRatio(text.style!.color!, background),
          greaterThanOrEqualTo(4.5),
        );
      }
    },
  );

  testWidgets(
    'renders every form gradient endpoint and clamped edge without numeric form text',
    (tester) async {
      final values = <double>[-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
      final exactStops = <double, Color>{
        1: Colors.red,
        3: Colors.orange,
        5: Colors.yellow,
        7: Colors.lightGreen,
        9: const Color(0xFF2E7D32),
        10: Colors.blue,
      };

      for (final value in values) {
        await tester.pumpWidget(
          _localizedApp(
            (context) =>
                FormIndicator(form: value, l10n: AppLocalizations.of(context)!),
          ),
        );
        await tester.pump();

        final indicatorFinder = find.byType(FormIndicator);
        final fill = tester.widget<FractionallySizedBox>(
          find.descendant(
            of: indicatorFinder,
            matching: find.byType(FractionallySizedBox),
          ),
        );
        final fillColor = tester
            .widgetList<ColoredBox>(
              find.descendant(
                of: indicatorFinder,
                matching: find.byType(ColoredBox),
              ),
            )
            .last
            .color;
        final clamped = clampedFormValue(value);

        expect(fill.widthFactor, closeTo(clamped / 10, 0.000001));
        expect(
          fillColor.toARGB32(),
          formColorForClampedValue(value).toARGB32(),
        );
        if (exactStops.containsKey(value)) {
          expect(fillColor.toARGB32(), exactStops[value]!.toARGB32());
        }
        expect(find.byType(Text), findsNothing);
      }
    },
  );

  testWidgets(
    'uses red, orange and white status colors with independent status semantics',
    (tester) async {
      final game = _fixtureGame(seed: 4212);
      final semanticsHandle = tester.ensureSemantics();
      final scenarios =
          <({bool injury, bool suspension, bool mismatch, Color color})>[
            (
              injury: false,
              suspension: false,
              mismatch: false,
              color: Colors.white,
            ),
            (
              injury: false,
              suspension: false,
              mismatch: true,
              color: Colors.orange,
            ),
            (
              injury: true,
              suspension: false,
              mismatch: false,
              color: Colors.red,
            ),
            (
              injury: false,
              suspension: true,
              mismatch: false,
              color: Colors.red,
            ),
            (injury: true, suspension: true, mismatch: true, color: Colors.red),
          ];

      for (final scenario in scenarios) {
        final player = _copyPlayer(
          game,
          id: 'status-${scenario.injury}-${scenario.suspension}-${scenario.mismatch}',
          name: 'Status Player',
          position: Position.cm,
          activeInjury: scenario.injury,
          activeSuspension: scenario.suspension,
        );
        final assignment = _slot(
          'status-slot',
          scenario.mismatch ? Position.cdm : Position.cm,
        );

        await tester.pumpWidget(
          _tileApp(
            game,
            player: player,
            zone: RosterZone.bench,
            positionAssignment: assignment,
            onTap: () {},
          ),
        );
        await tester.pumpAndSettle();

        final badge = tester.widget<PositionBadge>(find.byType(PositionBadge));
        expect(badge.backgroundColor, scenario.color);

        final l10n = _tileLocalizations(tester);
        expect(
          find.bySemanticsLabel(l10n.squad_statusInjury),
          scenario.injury ? findsOneWidget : findsNothing,
        );
        expect(
          find.bySemanticsLabel(l10n.squad_statusSuspension),
          scenario.suspension ? findsOneWidget : findsNothing,
        );

        final status = statusFor(player, assignment);
        final rowLabel = _rowSemanticsLabel(
          l10n,
          player,
          status,
          RosterZone.bench,
        );
        expect(find.bySemanticsLabel(rowLabel), findsOneWidget);
        expect(status.hasPositionMismatch, scenario.mismatch);
      }
      semanticsHandle.dispose();
    },
  );

  testWidgets('keeps the selected ring separate from an active status color', (
    tester,
  ) async {
    final game = _fixtureGame(seed: 4213);
    final player = _copyPlayer(
      game,
      id: 'selected-injured-player',
      name: 'Selected Injured',
      position: Position.cm,
      activeInjury: true,
    );

    await tester.pumpWidget(
      _tileApp(
        game,
        player: player,
        selected: true,
        positionAssignment: _slot('selected-slot', Position.cm),
        onTap: () {},
      ),
    );
    await tester.pumpAndSettle();

    final badge = tester.widget<PositionBadge>(find.byType(PositionBadge));
    final decoration =
        tester
                .widget<Container>(
                  find.descendant(
                    of: find.byType(PositionBadge),
                    matching: find.byType(Container),
                  ),
                )
                .decoration!
            as BoxDecoration;
    final border = decoration.border! as Border;

    expect(badge.backgroundColor, Colors.red);
    expect(badge.selected, isTrue);
    expect(border.top.width, 2);
    expect(border.top.color, isNot(Colors.red));
  });

  testWidgets(
    'renders each zone frame label and color with required contrast',
    (tester) async {
      final game = _fixtureGame(seed: 4214);
      final player = _copyPlayer(
        game,
        id: 'zone-frame-player',
        name: 'Zone Frame Player',
        position: Position.cm,
        activeInjury: true,
      );
      final semanticsHandle = tester.ensureSemantics();

      for (final zone in RosterZone.values) {
        await tester.pumpWidget(
          _tileApp(
            game,
            player: player,
            zone: zone,
            positionAssignment: _slot('zone-slot', Position.cm),
            onTap: () {},
          ),
        );
        await tester.pumpAndSettle();

        final l10n = _tileLocalizations(tester);
        final label = _zoneLabel(l10n, zone);
        expect(find.text(label), findsOneWidget);
        expect(
          find.bySemanticsLabel(l10n.squad_zoneFrameSemantics(label)),
          findsOneWidget,
        );

        final frameContainer = _zoneBorderContainer(tester);
        final frameDecoration = frameContainer.decoration! as BoxDecoration;
        final borderColor = (frameDecoration.border! as Border).top.color;
        final rowBackground = frameDecoration.color!;
        final labelWidget = tester.widget<Text>(find.text(label));
        final labelColor = labelWidget.style!.color!;

        expect(
          contrastRatio(labelColor, rowBackground),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(borderColor, rowBackground),
          greaterThanOrEqualTo(3),
        );
        expect(_hasZoneColorFamily(borderColor, zone), isTrue);
        expect(
          tester
              .widget<PositionBadge>(find.byType(PositionBadge))
              .backgroundColor,
          Colors.red,
        );

        final frameRect = tester.getRect(find.byType(ZoneFrame));
        _expectInside(tester.getRect(find.byType(PositionBadge)), frameRect);
        _expectInside(tester.getRect(find.byType(OvrBadge)), frameRect);
        _expectInside(tester.getRect(find.byType(FormIndicator)), frameRect);
        _expectInside(tester.getRect(find.byType(StatusIcons)), frameRect);
        _expectInside(tester.getRect(find.byType(IconButton)), frameRect);
      }
      semanticsHandle.dispose();
    },
  );

  testWidgets(
    'constrains long names at text scales 1.0, 1.3 and 2.0 without moving row actions',
    (tester) async {
      final game = _fixtureGame(seed: 4215);
      const longName =
          'Alexanderthegreat International Footballer Van Der Berg';
      final player = _copyPlayer(
        game,
        id: 'long-name-player',
        name: longName,
        position: Position.cm,
        form: 8.5,
        activeInjury: true,
        activeSuspension: true,
      );
      const width = 320.0;

      for (final textScale in <double>[1.0, 1.3, 2.0]) {
        await tester.pumpWidget(
          _tileApp(
            game,
            player: player,
            width: width,
            textScale: textScale,
            zone: RosterZone.xi,
            positionAssignment: _slot('long-name-slot', Position.cdm),
            onTap: () {},
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final rowRect = tester.getRect(
          find.byKey(ValueKey('squad-player-row-${player.id}')),
        );
        expect(rowRect.left, greaterThanOrEqualTo(0));
        expect(rowRect.right, lessThanOrEqualTo(width));

        final firstName = tester
            .widgetList<Text>(find.byType(Text))
            .where((text) => text.data == 'Alexanderthegreat')
            .toList();
        final remainingName = tester
            .widgetList<Text>(find.byType(Text))
            .where(
              (text) => text.data == 'International Footballer Van Der Berg',
            )
            .toList();
        expect(firstName, hasLength(1));
        expect(remainingName, hasLength(1));
        expect(firstName.single.maxLines, 1);
        expect(remainingName.single.maxLines, 1);
        expect(firstName.single.overflow, TextOverflow.ellipsis);
        expect(remainingName.single.overflow, TextOverflow.ellipsis);

        for (final finder in <Finder>[
          find.byType(PositionBadge),
          find.byType(OvrBadge),
          find.byType(FormIndicator),
          find.byType(StatusIcons),
          find.byType(IconButton),
        ]) {
          expect(finder, findsOneWidget);
          _expectInside(tester.getRect(finder), rowRect);
        }
        expect(
          find.byKey(const ValueKey('squad-form-indicator')),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      }
    },
  );

  testWidgets('drag target rejects itself and forwards an accepted player id', (
    tester,
  ) async {
    final game = _fixtureGame(seed: 4216);
    final player = _copyPlayer(
      game,
      id: 'drag-target-player',
      name: 'Drag Target',
    );
    const otherPlayerId = 'other-player';
    final acceptedIds = <String>[];

    await tester.pumpWidget(
      _tileApp(
        game,
        player: player,
        enableDragDrop: true,
        onTap: () {},
        onAcceptDrop: acceptedIds.add,
      ),
    );
    await tester.pumpAndSettle();

    final dragTarget = tester.widget<DragTarget<String>>(
      find.byType(DragTarget<String>),
    );
    final selfDetails = DragTargetDetails<String>(
      data: player.id,
      offset: Offset.zero,
    );
    final otherDetails = DragTargetDetails<String>(
      data: otherPlayerId,
      offset: Offset.zero,
    );

    expect(dragTarget.onWillAcceptWithDetails!(selfDetails), isFalse);
    expect(dragTarget.onWillAcceptWithDetails!(otherDetails), isTrue);
    dragTarget.onAcceptWithDetails!(otherDetails);
    expect(acceptedIds, [otherPlayerId]);

    final draggable = tester.widget<LongPressDraggable<String>>(
      find.byType(LongPressDraggable<String>),
    );
    expect(draggable.data, player.id);
  });

  testWidgets(
    'shows stamina bars, gold or faded potential stars, and the optimal role',
    (tester) async {
      final game = _fixtureGame(seed: 4290);
      final young = _copyPlayer(
        game,
        id: 'metric-young',
        name: 'Young Star',
        form: 6,
        position: Position.cm,
      ).copyWith(age: 22, potentialStars: 3.5);
      final veteran = young.copyWith(
        id: 'metric-veteran',
        name: 'Veteran Star',
        age: 30,
      );

      await tester.pumpWidget(
        _tileApp(
          game,
          player: young,
          onTap: () {},
          positionAssignment: _slot('cm-slot', Position.cm),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FormIndicator), findsOneWidget);
      expect(find.byType(StaminaIndicator), findsOneWidget);

      await tester.pumpWidget(
        _tileApp(
          game,
          player: young,
          onTap: () {},
          positionAssignment: _slot('cm-slot', Position.cm),
          metricMode: SquadTileMetricMode.potential,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FormIndicator), findsNothing);
      final youngStars = tester.widget<PotentialStars>(
        find.byType(PotentialStars),
      );
      expect(youngStars.stars, 3.5);
      expect(youngStars.color, const Color(0xFFFFC107));

      await tester.pumpWidget(
        _tileApp(
          game,
          player: veteran,
          onTap: () {},
          positionAssignment: _slot('cm-slot', Position.cm),
          metricMode: SquadTileMetricMode.potential,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<PotentialStars>(find.byType(PotentialStars)).color,
        const Color(0xFFB8A98A),
      );

      await tester.pumpWidget(
        _tileApp(
          game,
          player: young,
          onTap: () {},
          positionAssignment: _slot('cm-slot', Position.cm),
          metricMode: SquadTileMetricMode.optimalRole,
        ),
      );
      await tester.pumpAndSettle();
      final expected = compactRoleLabel(
        roleDisplayInfo(young.optimalRole).label,
      );
      expect(find.text(expected), findsOneWidget);
    },
  );
}

Widget _tileApp(
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
  return _localizedApp((context) {
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

Widget _localizedApp(
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

GameSave _fixtureGame({required int seed}) {
  return GameFactory().create(
    NewGameRequest(
      saveName: 'PlayerListTile widget test',
      playerTeamId: 'team_europe_0',
      seed: seed,
    ),
  );
}

Player _copyPlayer(
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

AssignedSlot _slot(String key, Position position) {
  return AssignedSlot(
    key: key,
    position: position,
    group: positionGroupOf(position),
    x: 0.5,
    y: 0.5,
  );
}

AppLocalizations _tileLocalizations(WidgetTester tester) {
  return AppLocalizations.of(tester.element(find.byType(PlayerListTile)))!;
}

Container _circleContainer(WidgetTester tester, Finder owner) {
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

Container _zoneBorderContainer(WidgetTester tester) {
  final containers = tester.widgetList<Container>(find.byType(Container)).where(
    (container) {
      final decoration = container.decoration;
      return decoration is BoxDecoration && decoration.border != null;
    },
  ).toList();
  expect(containers, isNotEmpty);
  return containers.first;
}

String _zoneLabel(AppLocalizations l10n, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return l10n.squad_zoneXi;
    case RosterZone.bench:
      return l10n.squad_zoneBench;
    case RosterZone.reserve:
      return l10n.squad_zoneReserves;
  }
}

String _rowSemanticsLabel(
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
    _zoneLabel(l10n, zone),
  );
  final statuses = <String>[
    if (status.hasActiveInjury) l10n.squad_statusInjury,
    if (status.hasActiveSuspension) l10n.squad_statusSuspension,
    if (status.hasPositionMismatch) l10n.squad_positionMismatch,
  ];
  return statuses.isEmpty ? base : '$base. ${statuses.join('. ')}.';
}

bool _hasZoneColorFamily(Color color, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return color.g > color.r && color.g > color.b;
    case RosterZone.bench:
      return color.b > color.r && color.b > color.g;
    case RosterZone.reserve:
      return color.r > color.b && color.g > color.b;
  }
}

void _expectInside(Rect inner, Rect outer) {
  const tolerance = 0.5;
  expect(inner.left, greaterThanOrEqualTo(outer.left - tolerance));
  expect(inner.top, greaterThanOrEqualTo(outer.top - tolerance));
  expect(inner.right, lessThanOrEqualTo(outer.right + tolerance));
  expect(inner.bottom, lessThanOrEqualTo(outer.bottom + tolerance));
}

void _expectSameRect(Rect actual, Rect expected) {
  const tolerance = 0.001;
  expect(actual.left, closeTo(expected.left, tolerance));
  expect(actual.top, closeTo(expected.top, tolerance));
  expect(actual.right, closeTo(expected.right, tolerance));
  expect(actual.bottom, closeTo(expected.bottom, tolerance));
}
