@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/widgets/calendar_day_tile.dart';
import 'package:new_football/core/balance/balance_config.dart';

import 'package:new_football/core/models/league_state.dart';

import '../helpers/widgets/career_dashboard_harness.dart';

void main() {
  testWidgets('home preview skips the civil gap at a 52-week rollover', (
    tester,
  ) async {
    final source = dashboardGame(seed: 4003);
    final game = source.copyWith(
      leagueState: source.leagueState.copyWith(
        currentWeek: 52,
        currentDay: 7,
        currentSeason: source.leagueState.currentSeason.copyWith(year: 2027),
      ),
    );
    await tester.pumpWidget(dashboardApp(const HomeScreen(), game));
    await tester.pumpAndSettle();
    final preview = find.byKey(const ValueKey('home-next-seven-days'));
    expect(
      find.descendant(of: preview, matching: find.text('30.07')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: preview, matching: find.text('7.08')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: preview, matching: find.text('31.07')),
      findsNothing,
    );
  });

  testWidgets(
    'calendar reads its date projection from the configured provider',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1500));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final source = dashboardGame(seed: 4003);
      final game = source.copyWith(
        leagueState: source.leagueState.copyWith(currentWeek: 1, currentDay: 1),
      );
      await tester.pumpWidget(
        dashboardApp(
          const CalendarScreen(),
          game,
          balance: const BalanceConfig(
            calendar: CalendarBalance(seasonStartMonth: 9),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final scope = ProviderScope.containerOf(
        tester.element(find.byType(CalendarScreen)),
      );
      expect(
        scope.read(calendarServiceProvider).balance.calendar.seasonStartMonth,
        9,
      );
      expect(scope.read(activeLeagueProvider)!.currentWeek, 1);
      final tiles = tester
          .widgetList<CalendarDayTile>(find.byType(CalendarDayTile))
          .toList();
      expect(tiles.map((tile) => tile.date), contains(DateTime(2026, 9, 7)));
      final today = tiles.singleWhere((tile) => tile.isToday);
      expect(today.date, DateTime(2026, 9, 7));
    },
  );

  testWidgets('HomeScreen pokazuje nagłówek, kalendarz i kontekstową akcję', (
    tester,
  ) async {
    final game = dashboardGame(seed: 4003);
    await tester.pumpWidget(dashboardApp(const HomeScreen(), game));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-dashboard-header')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-next-seven-days')), findsOneWidget);
    expect(find.text(game.leagueState.playerTeam!.name), findsOneWidget);
    expect(find.text('Najbliższe 7 dni'), findsOneWidget);
    expect(find.text('Bilans drużyny'), findsOneWidget);
    expect(find.text('Najbliższa akcja'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
