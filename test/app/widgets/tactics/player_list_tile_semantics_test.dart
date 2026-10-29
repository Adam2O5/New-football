@Tags(['ui'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/tactics/player_sort.dart';

import '../../../helpers/widgets/player_list_tile_harness.dart';

void main() {
  testWidgets(
    'renders the selected surface around the full zone frame with selected semantics',
    (tester) async {
      final game = fixtureGame(seed: 4222);
      final player = copyPlayer(
        game,
        id: 'selected-surface-player',
        name: 'Selected Surface Player',
        position: Position.cm,
        form: 8.5,
        activeInjury: true,
        activeSuspension: true,
      );
      final assignment = slot('selected-surface-slot', Position.cm);
      final semanticsHandle = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          tileApp(
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
          find.text(zoneLabel(tileLocalizations(tester), RosterZone.bench)),
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

        final frameContainer = zoneBorderContainer(tester);
        final frameDecoration = frameContainer.decoration! as BoxDecoration;
        final frameBorder = frameDecoration.border! as Border;
        expect(
          hasZoneColorFamily(frameBorder.top.color, RosterZone.bench),
          isTrue,
        );
        for (final finder in <Finder>[
          find.byType(PositionBadge),
          find.byType(OvrBadge),
          find.byType(FormIndicator),
          find.byType(StatusIcons),
          find.byType(IconButton),
        ]) {
          expectInside(tester.getRect(finder), frameRect);
        }

        final l10n = tileLocalizations(tester);
        final status = statusFor(player, assignment);
        final rowLabel = rowSemanticsLabel(
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
    'uses red, orange and white status colors with independent status semantics',
    (tester) async {
      final game = fixtureGame(seed: 4212);
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
        final player = copyPlayer(
          game,
          id: 'status-${scenario.injury}-${scenario.suspension}-${scenario.mismatch}',
          name: 'Status Player',
          position: Position.cm,
          activeInjury: scenario.injury,
          activeSuspension: scenario.suspension,
        );
        final assignment = slot(
          'status-slot',
          scenario.mismatch ? Position.cdm : Position.cm,
        );

        await tester.pumpWidget(
          tileApp(
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

        final l10n = tileLocalizations(tester);
        expect(
          find.bySemanticsLabel(l10n.squad_statusInjury),
          scenario.injury ? findsOneWidget : findsNothing,
        );
        expect(
          find.bySemanticsLabel(l10n.squad_statusSuspension),
          scenario.suspension ? findsOneWidget : findsNothing,
        );

        final status = statusFor(player, assignment);
        final rowLabel = rowSemanticsLabel(
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
    final game = fixtureGame(seed: 4213);
    final player = copyPlayer(
      game,
      id: 'selected-injured-player',
      name: 'Selected Injured',
      position: Position.cm,
      activeInjury: true,
    );

    await tester.pumpWidget(
      tileApp(
        game,
        player: player,
        selected: true,
        positionAssignment: slot('selected-slot', Position.cm),
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
      final game = fixtureGame(seed: 4214);
      final player = copyPlayer(
        game,
        id: 'zone-frame-player',
        name: 'Zone Frame Player',
        position: Position.cm,
        activeInjury: true,
      );
      final semanticsHandle = tester.ensureSemantics();

      for (final zone in RosterZone.values) {
        await tester.pumpWidget(
          tileApp(
            game,
            player: player,
            zone: zone,
            positionAssignment: slot('zone-slot', Position.cm),
            onTap: () {},
          ),
        );
        await tester.pumpAndSettle();

        final l10n = tileLocalizations(tester);
        final label = zoneLabel(l10n, zone);
        expect(find.text(label), findsOneWidget);
        expect(
          find.bySemanticsLabel(l10n.squad_zoneFrameSemantics(label)),
          findsOneWidget,
        );

        final frameContainer = zoneBorderContainer(tester);
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
        expect(hasZoneColorFamily(borderColor, zone), isTrue);
        expect(
          tester
              .widget<PositionBadge>(find.byType(PositionBadge))
              .backgroundColor,
          Colors.red,
        );

        final frameRect = tester.getRect(find.byType(ZoneFrame));
        expectInside(tester.getRect(find.byType(PositionBadge)), frameRect);
        expectInside(tester.getRect(find.byType(OvrBadge)), frameRect);
        expectInside(tester.getRect(find.byType(FormIndicator)), frameRect);
        expectInside(tester.getRect(find.byType(StatusIcons)), frameRect);
        expectInside(tester.getRect(find.byType(IconButton)), frameRect);
      }
      semanticsHandle.dispose();
    },
  );
}
