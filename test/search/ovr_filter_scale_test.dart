import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/search_filters_screen.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  for (final bounds in [(50, 99), (70, 80), (75, 75)]) {
    for (final tab in [0, 1]) {
      testWidgets('OVR filter tab $tab uses configured bounds $bounds', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(1400, 1800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              balanceProvider.overrideWithValue(
                BalanceConfig(
                  ui: UiBalance(
                    filterOvrMin: bounds.$1,
                    filterOvrMax: bounds.$2,
                  ),
                ),
              ),
            ],
            child: const MaterialApp(
              locale: Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: SearchFiltersScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        tester.widget<TabBar>(find.byType(TabBar)).controller!.index = tab;
        await tester.pumpAndSettle();
        final sliders = tester.widgetList<RangeSlider>(
          find.byType(RangeSlider).hitTestable(),
        );
        expect(
          sliders.where(
            (slider) => slider.min == bounds.$1 && slider.max == bounds.$2,
          ),
          isNotEmpty,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
