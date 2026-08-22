@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  // **Validates: Requirements 1.6, 1.7**
  testWidgets(
    'pre-fix exploration: selected match-and-event tile stays bounded across the device matrix',
    (tester) async {
      addTearDown(tester.view.reset);

      final game = _fixtureGame(seed: 7);
      // The override below deliberately forces the same concrete date so the
      // selected tile always has both the round-1 match and the event.
      const matchDay = 3;
      final selectedDate = _dateForInGameWeekDay(
        game.leagueState.currentSeason.year,
        (1, matchDay),
      );
      final playerMatch = game.leagueState.currentSeason.schedule.firstWhere(
        (match) =>
            match.round == 1 &&
            (match.homeTeamId == game.leagueState.playerTeamId ||
                match.awayTeamId == game.leagueState.playerTeamId),
      );
      final homeName = game.leagueState.teamById(playerMatch.homeTeamId)!.name;
      final awayName = game.leagueState.teamById(playerMatch.awayTeamId)!.name;
      final matchTooltip = '$homeName – $awayName';

      final cases =
          <
            ({
              double width,
              double pixelRatio,
              double textScale,
              bool landscape,
            })
          >[
            for (final width in [320.0, 360.0, 393.0, 414.0, 600.0])
              for (final pixelRatio in [1.0, 2.0, 2.75, 3.0])
                for (final textScale in [1.0, 1.3, 1.5, 2.0])
                  for (final landscape in [false, true])
                    (
                      width: width,
                      pixelRatio: pixelRatio,
                      textScale: textScale,
                      landscape: landscape,
                    ),
          ];

      for (final configuration in cases) {
        final logicalHeight = configuration.landscape ? 320.0 : 600.0;
        tester.view.physicalSize = Size(
          configuration.width * configuration.pixelRatio,
          logicalHeight * configuration.pixelRatio,
        );
        tester.view.devicePixelRatio = configuration.pixelRatio;

        await tester.pumpWidget(
          _calendarTileApp(game, textScale: configuration.textScale),
        );
        await tester.pump();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(CalendarScreen)),
        );
        container.read(calendarSelectedDayProvider.notifier).state =
            selectedDate;
        await tester.pump();

        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason:
              'Pre-fix tile counterexample: selected tile with match+event '
              'failed at width=${configuration.width}dp, '
              'pixelRatio=${configuration.pixelRatio}, '
              'textScale=${configuration.textScale}, '
              'orientation=${configuration.landscape ? 'landscape' : 'portrait'}; '
              'exception=$exception',
        );

        final eventTooltip = find.byTooltip('Nagrody');
        final matchTooltipFinder = find.byTooltip(matchTooltip);
        expect(
          eventTooltip,
          findsOneWidget,
          reason:
              'Event indicator disappeared at '
              'width=${configuration.width}dp/textScale=${configuration.textScale}.',
        );
        expect(
          matchTooltipFinder,
          findsOneWidget,
          reason:
              'Match indicator disappeared at '
              'width=${configuration.width}dp/textScale=${configuration.textScale}.',
        );

        final eventIcon = find.descendant(
          of: eventTooltip,
          matching: find.byIcon(Icons.event_available_outlined),
        );
        final matchIcon = find.descendant(
          of: matchTooltipFinder,
          matching: find.byIcon(Icons.sports_soccer),
        );
        final tile = find
            .ancestor(of: eventTooltip, matching: find.byType(InkWell))
            .first;
        final tileRect = tester.getRect(tile);
        final eventRect = tester.getRect(eventIcon);
        final matchRect = tester.getRect(matchIcon);

        expect(
          tileRect.inflate(0.1).contains(eventRect.topLeft) &&
              tileRect.inflate(0.1).contains(eventRect.bottomRight),
          isTrue,
          reason:
              'Event indicator was clipped/outside tile bounds at '
              'width=${configuration.width}dp, textScale=${configuration.textScale}; '
              'tile=$tileRect, event=$eventRect',
        );
        expect(
          tileRect.inflate(0.1).contains(matchRect.topLeft) &&
              tileRect.inflate(0.1).contains(matchRect.bottomRight),
          isTrue,
          reason:
              'Match indicator was clipped/outside tile bounds at '
              'width=${configuration.width}dp, textScale=${configuration.textScale}; '
              'tile=$tileRect, match=$matchRect',
        );
        expect(
          eventRect.overlaps(matchRect),
          isFalse,
          reason:
              'Match and event indicators overlap at width=${configuration.width}dp, '
              'textScale=${configuration.textScale}; match=$matchRect, event=$eventRect',
        );
      }
    },
  );
}

Widget _calendarTileApp(GameSave game, {required double textScale}) {
  return ProviderScope(
    overrides: [
      saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
      calendarServiceProvider.overrideWithValue(
        const _BothIndicatorCalendarService(),
      ),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
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
      home: Builder(
        builder: (context) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
            child: const CalendarScreen(),
          );
        },
      ),
    ),
  );
}

class _BothIndicatorCalendarService extends CalendarService {
  const _BothIndicatorCalendarService();

  @override
  bool isActualMatchDay(int week, int day, {int seed = 0}) {
    return week == 1 && day == 3;
  }

  @override
  List<CalendarEventSlot> eventsOn(int week, int day) {
    if (week == 1 && day == 3) {
      return const [
        CalendarEventSlot(
          id: CalendarEventId.awards,
          week: 1,
          day: 3,
          order: 0,
          kind: CalendarEventKind.informational,
        ),
      ];
    }
    return super.eventsOn(week, day);
  }
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

GameSave _fixtureGame({required int seed}) {
  return GameFactory().create(
    NewGameRequest(
      saveName: 'Calendar tile exploration',
      playerTeamId: 'team_europe_0',
      seed: seed,
    ),
  );
}

class _NoopSaveRepository extends SaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}
