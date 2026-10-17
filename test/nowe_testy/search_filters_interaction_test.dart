import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/search_filters_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

void main() {
  for (final language in ['pl', 'en']) {
    testWidgets('filter edits, sheet cancellation and reset in $language', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = MemorySaveRepository(controllerSave());
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          saveRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await container
          .read(gameControllerProvider.notifier)
          .loadGame(repository.game.meta.id);
      final key = container.read(activeSearchFiltersKeyProvider);
      SearchFiltersState filters() =>
          container.read(searchFiltersProvider(key));
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => context.push('/filters'),
                child: const Text('Open filters'),
              ),
            ),
          ),
          GoRoute(
            path: '/filters',
            builder: (_, _) => const SearchFiltersScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.binding.setSurfaceSize(const Size(1400, 1500));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open filters'));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SearchFiltersScreen)),
      )!;
      final screenElement = tester.element(find.byType(SearchFiltersScreen));

      // A dismissed sheet must not publish its temporary selection.
      await tester.tap(find.text(l10n.searchFilters_club));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pump();
      router.pop();
      await tester.pumpAndSettle();
      expect(filters().players.clubIds, isEmpty);
      await tester.tap(find.text(l10n.searchFilters_club));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CheckboxListTile>(find.byType(CheckboxListTile).first)
            .value,
        isFalse,
      );
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.tap(find.text(l10n.common_save));
      await tester.pumpAndSettle();
      expect(filters().players.clubIds, {PlayersFilterState.noClubSentinel});

      tester
          .widget<DropdownButton<Position?>>(
            find.byType(DropdownButton<Position?>),
          )
          .onChanged!(Position.gk);
      await tester.pumpAndSettle();
      expect(filters().players.position, Position.gk);
      tester.widget<RangeSlider>(find.byType(RangeSlider).first).onChanged!(
        const RangeValues(1, 4),
      );
      await tester.pump();
      expect(filters().players.potential, const RangeFilter(min: 1, max: 4));

      await tester.tap(find.widgetWithText(Tab, l10n.search_picks));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, '2'));
      await tester.pump();
      expect(filters().picks.rounds, {2});
      await tester.tap(find.byTooltip(l10n.searchFilters_reset));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      expect(filters().players.position, Position.gk);
      expect(filters().picks.rounds, {2});

      await tester.tap(find.byTooltip(l10n.searchFilters_reset));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, l10n.searchFilters_reset),
      );
      await tester.pumpAndSettle();
      expect(filters(), const SearchFiltersState());
      expect(
        tester.element(find.byType(SearchFiltersScreen)),
        same(screenElement),
      );
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller!.index, 2);
      await tester.tap(find.text(l10n.searchFilters_searchButton));
      await tester.pumpAndSettle();
      expect(find.text('Open filters'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
