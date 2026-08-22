@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  // **Validates: Requirements 1.2, 1.3, 1.4, 1.5**
  testWidgets(
    'pre-fix exploration: CalendarScreen shows one complete result cycle before final action',
    (tester) async {
      final baseGame = _fixtureGame(seed: 7);
      final matchDay = matchDaysForWeek(1).midweekDay;
      final target = matchDay < 7 ? (1, matchDay + 1) : (2, 1);
      final game = baseGame.copyWith(
        leagueState: baseGame.leagueState.copyWith(
          currentWeek: 1,
          currentDay: matchDay,
        ),
      );
      late GameController controller;

      await tester.pumpWidget(
        _calendarApp(
          const CalendarScreen(),
          game,
          onController: (value) => controller = value,
        ),
      );
      await tester.pump();

      final calendarElement = tester.element(find.byType(CalendarScreen));
      final container = ProviderScope.containerOf(calendarElement);
      container.read(calendarSelectedDayProvider.notifier).state =
          _dateForInGameWeekDay(game.leagueState.currentSeason.year, target);
      await tester.pump();

      final simulateButton = find.widgetWithText(
        FilledButton,
        'Do wybranej daty',
      );
      expect(simulateButton, findsOneWidget);
      await tester.ensureVisible(simulateButton);
      await tester.pump();
      await tester.tap(simulateButton);
      await tester.pump();

      // The production path has no observer, so this pump lets the unchanged
      // batch finish while keeping the assertion at the point where a fixed
      // implementation must keep its per-day feedback visible.
      for (var i = 0; i < 10; i++) {
        if (_roundResults(controller).isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 1));
      }

      final persisted = _roundResults(controller);
      final schedulePairs = persisted
          .map((match) => '${match.homeTeamId}->${match.awayTeamId}')
          .toList();
      expect(
        persisted.length,
        greaterThanOrEqualTo(3),
        reason:
            'Fixture must contain several results on W1 match day. '
            'target=W${target.$1}D${target.$2}, schedule=$schedulePairs',
      );

      final teamNames = <String>{};
      for (final match in persisted) {
        teamNames.add(
          controller.save!.leagueState.teamById(match.homeTeamId)!.name,
        );
        teamNames.add(
          controller.save!.leagueState.teamById(match.awayTeamId)!.name,
        );
      }
      final missingNames = [
        for (final name in teamNames)
          if (find.textContaining(name).evaluate().isEmpty) name,
      ];
      final duplicateNames = [
        for (final name in teamNames)
          if (find.textContaining(name).evaluate().length > 1) name,
      ];

      expect(
        missingNames,
        isEmpty,
        reason:
            'Pre-fix feedback counterexample: CalendarScreen emitted no '
            'complete per-day popup after committed W1D$matchDay. '
            'target=W${target.$1}D${target.$2}, persistedCount=${persisted.length}, '
            'missingNames=$missingNames, schedule=$schedulePairs',
      );
      expect(
        duplicateNames,
        isEmpty,
        reason:
            'Pre-fix feedback counterexample: a result row was rendered more '
            'than once. target=W${target.$1}D${target.$2}, '
            'duplicateNames=$duplicateNames, schedule=$schedulePairs',
      );

      // A fixed implementation must dismiss transient feedback before its
      // final snackbar/navigation action and must not replay it after stop.
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Zasymulowano dni:'),
        findsOneWidget,
        reason:
            'Final calendar stop action was not observable after the batch '
            'completed for target=W${target.$1}D${target.$2}.',
      );
      final staleNames = [
        for (final name in teamNames)
          if (find.textContaining(name).evaluate().isNotEmpty) name,
      ];
      expect(
        staleNames,
        isEmpty,
        reason:
            'Pre-fix lifecycle counterexample: result feedback remained visible '
            'after final action. staleNames=$staleNames',
      );
    },
  );
}

List<ScheduledMatch> _roundResults(GameController controller) {
  const round = 1;
  return controller.save!.leagueState.currentSeason.schedule
      .where((match) => match.round == round && match.result != null)
      .toList();
}

Widget _calendarApp(
  Widget screen,
  GameSave game, {
  required void Function(GameController controller) onController,
}) {
  return ProviderScope(
    overrides: [
      saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        onController(controller);
        return controller;
      }),
    ],
    child: MaterialApp(
      locale: const Locale('pl'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  );
}

GameSave _fixtureGame({required int seed}) {
  return GameFactory().create(
    NewGameRequest(
      saveName: 'Calendar exploration',
      playerTeamId: 'team_europe_0',
      seed: seed,
    ),
  );
}

class _NoopSaveRepository extends SaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}

DateTime _dateForInGameWeekDay(int seasonYear, (int, int) date) {
  var start = DateTime(seasonYear, 8, 1);
  while (start.weekday != DateTime.monday) {
    start = start.add(const Duration(days: 1));
  }
  while (start.month != 8 || start.add(const Duration(days: 6)).month != 8) {
    start = start.add(const Duration(days: 7));
  }
  return DateTime(
    start.year,
    start.month,
    start.day,
  ).add(Duration(days: (date.$1 - 1) * 7 + date.$2 - 1));
}
