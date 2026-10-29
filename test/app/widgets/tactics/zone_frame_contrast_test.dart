@Tags(['ui'])
library;

import 'package:new_football/core/tactics/player_sort.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final language in ['pl', 'en']) {
      testWidgets('zone contrast: $brightness, $language', (tester) async {
        for (final zone in RosterZone.values) {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              locale: Locale(language),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) => ZoneFrame(
                    l10n: AppLocalizations.of(context)!,
                    zone: zone,
                    child: const SizedBox(height: 40, width: 200),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final frame = tester.widget<Container>(
            find
                .descendant(
                  of: find.byType(ZoneFrame),
                  matching: find.byType(Container),
                )
                .first,
          );
          final decoration = frame.decoration! as BoxDecoration;
          final background = decoration.color!;
          final border = (decoration.border! as Border).top.color;
          final text = tester.widget<Text>(
            find.descendant(
              of: find.byType(ZoneFrame),
              matching: find.byType(Text),
            ),
          );
          final reason = '$brightness/$language/$zone';
          expect(
            contrastRatio(text.style!.color!, background),
            greaterThanOrEqualTo(4.5),
            reason: reason,
          );
          expect(
            contrastRatio(border, background),
            greaterThanOrEqualTo(3),
            reason: reason,
          );
          switch (zone) {
            case RosterZone.xi:
              expect(
                border.g > border.r && border.g > border.b,
                isTrue,
                reason: reason,
              );
            case RosterZone.bench:
              expect(
                border.b > border.r && border.b > border.g,
                isTrue,
                reason: reason,
              );
            case RosterZone.reserve:
              expect(
                border.r > border.b && border.g > border.b,
                isTrue,
                reason: reason,
              );
          }
        }
      });
    }
  }
}
