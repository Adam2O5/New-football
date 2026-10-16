import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/widgets/calendar_day_tile.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/controlled_simulation_runner.dart';
import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

void main() {
  const calendar = CalendarService();
  late ProviderContainer container;
  late GameController controller;
  late ControlledSimulationRunner runner;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    runner = ControlledSimulationRunner();
    final league = controllerSave().leagueState.copyWith(currentWeek: 48);
    final repository = MemorySaveRepository(saveForLeague(league));
    container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
        simulationRunnerProvider.overrideWithValue(runner),
      ],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(repository.game.meta.id);
  });
  tearDown(() => container.dispose());

  Future<void> showCalendar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CalendarScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder action(WidgetTester tester) {
    final l10n = AppLocalizations.of(
      tester.element(find.byType(CalendarScreen)),
    )!;
    return find.ancestor(
      of: find.text(l10n.calendar_simulateUntilDate),
      matching: find.byType(FilledButton),
    );
  }

  test(
    'date mapping covers weeks 47–52 and rejects dates outside the cycle',
    () {
      for (final year in [2026, 2027, 2031]) {
        for (var week = 47; week <= 52; week++) {
          for (final day in [1, 7]) {
            expect(
              calendar.weekDayForDate(
                calendar.dateForWeekDay(year, week, day),
                year,
              ),
              (week: week, day: day),
            );
          }
        }
        expect(
          calendar.weekDayForDate(
            calendar
                .dateForWeekDay(year, 1, 1)
                .subtract(const Duration(days: 1)),
            year,
          ),
          isNull,
        );
        expect(
          calendar.weekDayForDate(
            calendar.dateForWeekDay(year, 52, 7).add(const Duration(days: 1)),
            year,
          ),
          isNull,
        );
        expect(calendar.advanceDay(52, 7), (1, 1));
        expect(
          calendar.weekDayForDate(
            calendar.dateForWeekDay(year + 1, 1, 1),
            year + 1,
          ),
          (week: 1, day: 1),
        );
      }
    },
  );
  for (var week = 47; week <= 52; week++) {
    testWidgets('week $week can be selected and enables simulation', (
      tester,
    ) async {
      final date = calendar.dateForWeekDay(2026, week, 3);
      await tester.runAsync(
        () => controller.updateLeague(
          (league) => league.copyWith(currentWeek: week),
        ),
      );
      container.read(calendarCursorMonthProvider.notifier).state = DateTime(
        date.year,
        date.month,
      );
      await showCalendar(tester);
      final tile = find.byWidgetPredicate(
        (w) => w is CalendarDayTile && w.date == date,
      );
      expect(tile, findsOneWidget);
      await tester.tap(tile);
      await tester.pump();
      expect(container.read(calendarSelectedDayProvider), date);
      expect(tester.widget<FilledButton>(action(tester)).onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('past and unsupported dates disable simulation', (tester) async {
    await showCalendar(tester);
    for (final date in [
      calendar.dateForWeekDay(2026, 47, 7),
      calendar.dateForWeekDay(2026, 53, 1),
    ]) {
      container.read(calendarSelectedDayProvider.notifier).state = date;
      await tester.pump();
      expect(tester.widget<FilledButton>(action(tester)).onPressed, isNull);
    }
    expect(runner.daysCalled, 0);
  });
  testWidgets('week 48 action advances to the selected future day', (
    tester,
  ) async {
    container.read(calendarSelectedDayProvider.notifier).state = calendar
        .dateForWeekDay(2026, 48, 3);
    await showCalendar(tester);
    await tester.tap(action(tester));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(runner.daysCalled, 2);
    expect(controller.save!.leagueState.currentDay, 3);
    expect(tester.takeException(), isNull);
  });
}
