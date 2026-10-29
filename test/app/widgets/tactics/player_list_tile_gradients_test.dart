@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../../../helpers/widgets/player_list_tile_harness.dart';

void main() {
  testWidgets(
    'renders representative OVR colors, clamped edges and readable numeric text',
    (tester) async {
      final values = <int>[49, 70, 85, 99, 100];
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
          localizedApp(
            (context) => OvrBadge(
              ovr: value,
              size: 36,
              l10n: AppLocalizations.of(context)!,
            ),
          ),
        );
        await tester.pump();

        final badgeFinder = find.byType(OvrBadge);
        final container = circleContainer(tester, badgeFinder);
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
    'renders representative form colors and clamped edges without numeric text',
    (tester) async {
      final values = <double>[-1, 1, 5, 6, 10, 11];
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
          localizedApp(
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
}
