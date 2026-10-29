@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/tactics/player_sort.dart';

import '../../../helpers/widgets/player_list_tile_harness.dart';

void main() {
  testWidgets(
    'renders one bordered form indicator at badge width and orders the right status area',
    (tester) async {
      final game = fixtureGame(seed: 4220);
      final player = copyPlayer(
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
          tileApp(game, player: player, width: scenario.width, onTap: () {}),
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
      final game = fixtureGame(seed: 4221);
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
        final player = copyPlayer(
          game,
          id: 'status-slot-player',
          name: 'Status Slot Player',
          position: Position.cm,
          form: scenario.form,
          activeInjury: scenario.injury,
          activeSuspension: scenario.suspension,
        );
        await tester.pumpWidget(
          tileApp(game, player: player, width: 400, onTap: () {}),
        );
        await tester.pumpAndSettle();

        final l10n = tileLocalizations(tester);
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
          expectSameRect(formRect, previousFormRect);
          expectSameRect(statusRect, previousStatusRect!);
          expectSameRect(profileRect, previousProfileRect!);
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
    'constrains long names at text scales 1.0, 1.3 and 2.0 without moving row actions',
    (tester) async {
      final game = fixtureGame(seed: 4215);
      const longName =
          'Alexanderthegreat International Footballer Van Der Berg';
      final player = copyPlayer(
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
          tileApp(
            game,
            player: player,
            width: width,
            textScale: textScale,
            zone: RosterZone.xi,
            positionAssignment: slot('long-name-slot', Position.cdm),
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
          expectInside(tester.getRect(finder), rowRect);
        }
        expect(
          find.byKey(const ValueKey('squad-form-indicator')),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      }
    },
  );
}
