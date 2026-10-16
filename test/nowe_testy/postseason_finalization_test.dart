import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/season_service.dart';

import 'support/game_fixtures.dart';

class _SundayCalendar extends CalendarService {
  @override
  bool isActualMatchDay(int week, int day, {int seed = 0}) => day == 7;
}

/// Supplies a finished fixture at the integration boundary; no engine runs.
class _FixedMatchday extends AiMatchdayService {
  _FixedMatchday(this.result);
  final MatchResult result;
  @override
  MatchResult simulateFullMatch({
    dynamic home,
    dynamic away,
    dynamic context,
    dynamic saveSeed,
    dynamic seasonYear,
    dynamic week,
    dynamic matchId,
    dynamic phase,
    dynamic homeOpponentFormationHistory,
    dynamic awayOpponentFormationHistory,
    dynamic homeNextMatchWithinThreeDays,
    dynamic awayNextMatchWithinThreeDays,
    dynamic homeReturningAfterMajorInjury,
    dynamic awayReturningAfterMajorInjury,
    dynamic includeStoppageTime,
    dynamic mathematicallyMeaningless,
  }) => result;
}

class _RecordingMarket extends ContractMarketService {
  final dates = <(int, int)>[];
  @override
  LeagueState resolveDay(LeagueState league, {int saveSeed = 0}) {
    dates.add((league.currentWeek, league.currentDay));
    return league;
  }

  @override
  LeagueState weeklyTick(LeagueState league, {int saveSeed = 0}) => league;
}

Object _seeding(LeagueState league) => [
  league.currentSeason.playInProgress,
  [
    for (final bracket in league.currentSeason.playoffBrackets)
      [
        for (final series in bracket.quarterFinals)
          (series.higherSeedTeamId, series.lowerSeedTeamId),
      ],
  ],
];

void main() {
  for (final finishedConferences in [1, 2]) {
    test(
      'finalization remains idempotent after $finishedConferences completed play-ins',
      () {
        final initial = finalRegularSeasonDay();
        final service = SeasonService();
        var state = service.generatePostseasonFixtures(
          initial.copyWith(
            currentSeason: initial.currentSeason.copyWith(
              schedule: [
                initial.currentSeason.schedule.single.copyWith(
                  result: finalRegularSeasonResult(initial),
                ),
              ],
            ),
          ),
        );
        for (final conference in Conference.values.take(finishedConferences)) {
          for (final slot in ['7v8', '9v10', 'final']) {
            final fixture = state.currentSeason.postseasonFixtures.firstWhere(
              (m) => m.id == 'playIn:${conference.name}:$slot',
            );
            final result = MatchResult(
              homeTeamId: fixture.homeTeamId,
              awayTeamId: fixture.awayTeamId,
              homeGoals: 1,
              awayGoals: 0,
              homeStats: TeamMatchStats(teamId: fixture.homeTeamId, goals: 1),
              awayStats: TeamMatchStats(teamId: fixture.awayTeamId),
            );
            state = service.applyPlayInPlayerResult(
              state,
              matchId: fixture.id,
              rawResult: result,
              saveSeed: fixtureSeed,
            );
          }
        }
        expect(
          state.currentSeason.playInResults,
          hasLength(finishedConferences),
        );
        expect(
          state.currentSeason.playInProgress,
          hasLength(2 - finishedConferences),
        );
        expect(
          identical(service.generatePostseasonFixtures(state), state),
          isTrue,
        );
      },
    );
  }
  test(
    'resumed match resolves the market on the match date before advancing',
    () {
      final league = finalRegularSeasonDay();
      final market = _RecordingMarket();
      DaySimulator(contractMarket: market).applyPlayerMatchResult(
        league,
        league.currentSeason.schedule.single,
        finalRegularSeasonResult(league),
        saveSeed: fixtureSeed,
      );
      expect(market.dates, [(29, 7)]);
    },
  );
  for (final cutoff in [6, 10]) {
    test(
      'last result crosses $cutoff/${cutoff + 1}; pause/resume matches headless seeding',
      () {
        final original = finalRegularSeasonDay();
        final league = original.copyWith(
          currentSeason: original.currentSeason.copyWith(
            standings: [
              for (final conference in original.currentSeason.standings)
                conference.copyWith(
                  standings: [
                    for (var i = 0; i < conference.standings.length; i++)
                      conference.standings[i].copyWith(
                        wins: i == 0
                            ? 1
                            : i < cutoff
                            ? cutoff + 2 - i
                            : i == cutoff
                            ? 1
                            : 0,
                        goalsFor: i == cutoff ? 1 : 0,
                      ),
                  ],
                ),
            ],
          ),
        );
        final result = finalRegularSeasonResult(league);
        final days = DaySimulator(
          calendar: _SundayCalendar(),
          aiMatchdayService: _FixedMatchday(result),
        );
        final paused = days.simulateDay(
          league,
          saveSeed: fixtureSeed,
          resolveContractMarket: false,
        );
        expect(paused.league.currentSeason.postseasonFixtures, isEmpty);
        final resumed = days.applyPlayerMatchResult(
          paused.league,
          paused.playerMatch!,
          result,
          saveSeed: fixtureSeed,
          resolveContractMarket: false,
        );
        final automatic = days
            .simulateDay(
              league,
              saveSeed: fixtureSeed,
              simulatePlayerMatch: true,
              resolveContractMarket: false,
            )
            .league;
        expect(_seeding(resumed), _seeding(automatic));
        final sorted = resumed.currentSeason.standings.first.sorted;
        expect(
          sorted.indexWhere((s) => s.teamId == league.playerTeamId),
          cutoff - 1,
        );
        final qualifiers = resumed.currentSeason.playInProgress.first;
        if (cutoff == 10) {
          expect(qualifiers.seed10TeamId, league.playerTeamId);
        } else {
          expect(
            resumed.currentSeason.playoffBrackets.first.quarterFinals.any(
              (s) => s.lowerSeedTeamId == league.playerTeamId,
            ),
            isTrue,
          );
        }
      },
    );
  }
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
