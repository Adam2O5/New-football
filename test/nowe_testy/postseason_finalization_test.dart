import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/season_service.dart';

import 'support/game_fixtures.dart';

class _SundayCalendar extends CalendarService {
  @override
  bool isActualMatchDay(int week, int day, {int seed = 0}) => day == 7;
}

void main() {
  test(
    'last player result decides qualification before postseason is created',
    () {
      final league = finalRegularSeasonDay();
      final simulator = DaySimulator(calendar: _SundayCalendar());
      final paused = simulator.simulateDay(
        league,
        saveSeed: fixtureSeed,
        resolveContractMarket: false,
      );
      expect(paused.playerMatch, isNotNull);
      expect(paused.league.currentSeason.postseasonFixtures, isEmpty);
      final resumed = simulator.applyPlayerMatchResult(
        paused.league,
        paused.playerMatch!,
        finalRegularSeasonResult(league),
        saveSeed: fixtureSeed,
        resolveContractMarket: false,
      );
      expect(resumed.currentWeek, 30);
      expect(resumed.currentSeason.postseasonFixtures, hasLength(46));
      final bracket = resumed.currentSeason.playoffBrackets.firstWhere(
        (b) => b.conference == Conference.europe,
      );
      expect(
        bracket.quarterFinals.any(
          (s) => s.lowerSeedTeamId == league.playerTeamId,
        ),
        isTrue,
      );
      expect(
        resumed.currentSeason.playInProgress.first.seed7TeamId,
        isNot(league.playerTeamId),
      );
    },
  );

  test('incomplete regular season cannot seed postseason', () {
    final league = finalRegularSeasonDay();
    expect(
      identical(SeasonService().generatePostseasonFixtures(league), league),
      isTrue,
    );
  });

  test(
    'complete postseason initialization is idempotent; partial state is rejected',
    () {
      final league = finalRegularSeasonDay();
      final completed = league.copyWith(
        currentSeason: league.currentSeason.copyWith(
          schedule: [
            league.currentSeason.schedule.single.copyWith(
              result: finalRegularSeasonResult(league),
            ),
          ],
        ),
      );
      final service = SeasonService();
      final seeded = service.generatePostseasonFixtures(completed);
      expect(seeded.currentSeason.postseasonFixtures, hasLength(46));
      expect(
        identical(service.generatePostseasonFixtures(seeded), seeded),
        isTrue,
      );
      final partial = seeded.copyWith(
        currentSeason: seeded.currentSeason.copyWith(
          postseasonFixtures: seeded.currentSeason.postseasonFixtures
              .skip(1)
              .toList(),
        ),
      );
      expect(
        () => service.generatePostseasonFixtures(partial),
        throwsStateError,
      );
    },
  );
}
