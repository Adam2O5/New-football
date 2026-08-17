// import 'dart:math';

// import 'package:flutter_test/flutter_test.dart';
// import 'package:new_football/core/balance/balance_config.dart';
// import 'package:new_football/core/models/league_state.dart';
// import 'package:new_football/core/models/match_models.dart';
// import 'package:new_football/core/models/player.dart';
// import 'package:new_football/core/models/seed_data_generator.dart';
// import 'package:new_football/core/models/standing.dart';
// import 'package:new_football/core/models/team.dart';
// import 'package:new_football/core/services/schedule_generator.dart';
// import 'package:new_football/core/simulation/match_context_factory.dart';
// import 'package:new_football/core/simulation/match_engine.dart';

// void main() {
//   test(
//     'Task 24 — raport kalibracyjny modelu meczowego',
//     () {
//       final report = const _CalibrationHarness().run();
//       print(report.format());

//       expect(report.matches, _CalibrationHarness.matchCount);
//       expect(report.goalsPerMatch, inInclusiveRange(2.4, 2.9));
//       expect(report.homeWinRate, inInclusiveRange(0.48, 0.55));
//       expect(report.drawRate, inInclusiveRange(0.21, 0.27));
//       expect(report.shotsPerTeam, inInclusiveRange(9.0, 13.0));
//       expect(report.foulsPerTeam, inInclusiveRange(9.0, 13.0));
//       expect(report.yellowCardsPerTeam, inInclusiveRange(1.5, 2.3));
//       expect(report.redCardsPerMatch, inInclusiveRange(0.08, 0.16));
//       expect(report.injuriesPerMatch, inInclusiveRange(0.25, 0.45));
//       expect(report.extremePossessionRate, lessThan(0.08));
//       expect(report.ovrPointsCorrelation, inInclusiveRange(0.65, 0.9));
//       expect(report.favoriteOvrGap, inInclusiveRange(8.0, 12.0));
//       expect(report.favoriteWinRate, inInclusiveRange(0.60, 0.76));
//       expect(report.favoriteSamples, greaterThanOrEqualTo(500));
//       expect(report.roundMilliseconds, lessThan(150.0));
//     },
//     timeout: const Timeout(Duration(minutes: 3)),
//   );
// }

// class _CalibrationHarness {
//   const _CalibrationHarness();

//   static const matchCount = int.fromEnvironment(
//     'TASK24_MATCH_COUNT',
//     defaultValue: 10000,
//   );
//   static const favoriteMatchCount = int.fromEnvironment(
//     'TASK24_FAVORITE_MATCH_COUNT',
//     defaultValue: 2000,
//   );
//   static const seasonCount = int.fromEnvironment(
//     'TASK24_SEASON_COUNT',
//     defaultValue: 3,
//   );
//   static const year = 2026;
//   static const saveSeed = 24024;

//   final BalanceConfig balance = BalanceConfig.defaults;

//   _CalibrationReport run() {
//     final randomMatches = _runRandomMatches();
//     final favorite = _runFavoriteCohort();
//     final correlation = _runSeasonCorrelation();
//     final roundMilliseconds = _measureRound();

//     return _CalibrationReport(
//       matches: randomMatches.matches,
//       goalsPerMatch: randomMatches.totalGoals / randomMatches.matches,
//       homeWinRate: randomMatches.homeWins / randomMatches.matches,
//       drawRate: randomMatches.draws / randomMatches.matches,
//       shotsPerTeam: randomMatches.totalShots / (randomMatches.matches * 2),
//       foulsPerTeam: randomMatches.totalFouls / (randomMatches.matches * 2),
//       yellowCardsPerTeam:
//           randomMatches.totalYellowCards / (randomMatches.matches * 2),
//       redCardsPerMatch: randomMatches.totalRedCards / randomMatches.matches,
//       injuriesPerMatch: randomMatches.totalInjuries / randomMatches.matches,
//       extremePossessionRate:
//           randomMatches.extremePossessionMatches / randomMatches.matches,
//       ovrPointsCorrelation: correlation,
//       favoriteOvrGap: favorite.gap,
//       favoriteWinRate: favorite.wins / favorite.matches,
//       favoriteSamples: favorite.matches,
//       roundMilliseconds: roundMilliseconds,
//     );
//   }

//   _MatchAggregate _runRandomMatches() {
//     final teams = _league(seed: saveSeed).teams;
//     final random = Random(saveSeed + 1);
//     final aggregate = _MatchAggregate();
//     final engine = SimulationMatchEngine(
//       balance: balance,
//       recordRandomRolls: false,
//     );
//     const contextFactory = MatchContextFactory();

//     for (var i = 0; i < matchCount; i++) {
//       final homeIndex = random.nextInt(teams.length);
//       var awayIndex = random.nextInt(teams.length - 1);
//       if (awayIndex >= homeIndex) awayIndex++;
//       final home = teams[homeIndex];
//       final away = teams[awayIndex];
//       final context = contextFactory.createForTeams(
//         home: home,
//         away: away,
//         seasonYear: year,
//         matchId: 'task24-random-$i',
//         saveSeed: saveSeed,
//         week: i % 29 + 1,
//         homeMatchInWeek: i % 2 + 1,
//         awayMatchInWeek: i % 2 + 1,
//       );
//       final result = engine.simulateFull(
//         home: home,
//         away: away,
//         context: context,
//         rngSeed: context.seed,
//       );
//       aggregate.add(result);
//     }

//     return aggregate;
//   }

//   _FavoriteAggregate _runFavoriteCohort() {
//     final teams = _league(seed: saveSeed + 2).teams;
//     final pair = _closestFavoritePair(teams);
//     final engine = SimulationMatchEngine(
//       balance: balance,
//       recordRandomRolls: false,
//     );
//     const contextFactory = MatchContextFactory();
//     var wins = 0;

//     for (var i = 0; i < favoriteMatchCount; i++) {
//       final favoriteHome = i.isEven;
//       final home = favoriteHome ? pair.favorite : pair.underdog;
//       final away = favoriteHome ? pair.underdog : pair.favorite;
//       final context = contextFactory.createForTeams(
//         home: home,
//         away: away,
//         seasonYear: year,
//         matchId: 'task24-favorite-$i',
//         saveSeed: saveSeed + 2,
//         week: i % 29 + 1,
//         homeMatchInWeek: i % 2 + 1,
//         awayMatchInWeek: i % 2 + 1,
//       );
//       final result = engine.simulateFull(
//         home: home,
//         away: away,
//         context: context,
//         rngSeed: context.seed,
//       );
//       final favoriteGoals = favoriteHome ? result.homeGoals : result.awayGoals;
//       final underdogGoals = favoriteHome ? result.awayGoals : result.homeGoals;
//       if (favoriteGoals > underdogGoals) wins++;
//     }

//     return _FavoriteAggregate(
//       matches: favoriteMatchCount,
//       wins: wins,
//       gap: pair.gap,
//     );
//   }

//   double _runSeasonCorrelation() {
//     final correlations = <double>[];
//     const scheduleGenerator = ScheduleGenerator();
//     const contextFactory = MatchContextFactory();

//     for (var season = 0; season < seasonCount; season++) {
//       final league = _league(seed: saveSeed + 100 + season);
//       final teamsById = {for (final team in league.teams) team.id: team};
//       final ovrByTeam = {
//         for (final team in league.teams) team.id: _startingElevenOvr(team),
//       };
//       final standings = {
//         for (final team in league.teams) team.id: Standing(teamId: team.id),
//       };
//       final schedule = scheduleGenerator.generateDoubleRoundRobin(
//         teamsById.keys.toList(),
//       );
//       final engine = SimulationMatchEngine(
//         balance: balance,
//         recordRandomRolls: false,
//       );

//       for (final match in schedule) {
//         final home = teamsById[match.homeTeamId]!;
//         final away = teamsById[match.awayTeamId]!;
//         final week = (match.round - 1) ~/ 2 + 1;
//         final slot = (match.round - 1) % 2 + 1;
//         final context = contextFactory.createForTeams(
//           home: home,
//           away: away,
//           seasonYear: year + season,
//           matchId: 'task24-season-$season-${match.id}',
//           saveSeed: saveSeed + 100 + season,
//           week: week,
//           homeMatchInWeek: slot,
//           awayMatchInWeek: slot,
//         );
//         final result = engine.simulateFull(
//           home: home,
//           away: away,
//           context: context,
//           rngSeed: context.seed,
//         );
//         standings[home.id] = standings[home.id]!.applyResult(
//           goalsFor: result.homeGoals,
//           goalsAgainst: result.awayGoals,
//         );
//         standings[away.id] = standings[away.id]!.applyResult(
//           goalsFor: result.awayGoals,
//           goalsAgainst: result.homeGoals,
//         );
//       }

//       correlations.add(
//         _pearson(ovrByTeam.values.toList(), [
//           for (final team in teamsById.values) standings[team.id]!.points,
//         ]),
//       );
//     }

//     return correlations.reduce((a, b) => a + b) / correlations.length;
//   }

//   double _measureRound() {
//     final league = _league(seed: saveSeed + 200);
//     final teamsById = {for (final team in league.teams) team.id: team};
//     final schedule = const ScheduleGenerator().generateDoubleRoundRobin(
//       teamsById.keys.toList(),
//     );
//     final fixtures = schedule.take(15).toList();
//     final engine = SimulationMatchEngine(
//       balance: balance,
//       recordRandomRolls: false,
//     );
//     const contextFactory = MatchContextFactory();

//     for (var i = 0; i < fixtures.length; i++) {
//       _simulateFixture(
//         engine: engine,
//         contextFactory: contextFactory,
//         teamsById: teamsById,
//         match: fixtures[i],
//         seed: saveSeed + 200,
//         seasonYear: year,
//         matchPrefix: 'task24-warmup-$i',
//       );
//     }

//     final stopwatch = Stopwatch()..start();
//     for (var i = 0; i < fixtures.length; i++) {
//       _simulateFixture(
//         engine: engine,
//         contextFactory: contextFactory,
//         teamsById: teamsById,
//         match: fixtures[i],
//         seed: saveSeed + 201,
//         seasonYear: year,
//         matchPrefix: 'task24-round-$i',
//       );
//     }
//     stopwatch.stop();
//     return stopwatch.elapsedMicroseconds / 1000.0;
//   }

//   void _simulateFixture({
//     required SimulationMatchEngine engine,
//     required MatchContextFactory contextFactory,
//     required Map<String, Team> teamsById,
//     required ScheduledMatch match,
//     required int seed,
//     required int seasonYear,
//     required String matchPrefix,
//     bool collectTraces = false,
//   }) {
//     final home = teamsById[match.homeTeamId]!;
//     final away = teamsById[match.awayTeamId]!;
//     final context = contextFactory.createForTeams(
//       home: home,
//       away: away,
//       seasonYear: seasonYear,
//       matchId: '$matchPrefix-${match.id}',
//       saveSeed: seed,
//       week: 1,
//       homeMatchInWeek: 1,
//       awayMatchInWeek: 1,
//     );
//     engine.simulateFull(
//       home: home,
//       away: away,
//       context: context,
//       rngSeed: context.seed,
//       collectTraces: collectTraces,
//     );
//   }

//   LeagueState _league({required int seed}) => SeedDataGenerator()
//       .generateLeague(year: year, seed: seed, playerTeamId: null);

//   double _startingElevenOvr(Team team) {
//     final lineup = team.startingEleven;
//     return lineup
//             .map((player) => player.overall(balance))
//             .reduce((a, b) => a + b) /
//         lineup.length;
//   }

//   _FavoritePair _closestFavoritePair(List<Team> teams) {
//     _FavoritePair? best;
//     for (var i = 0; i < teams.length; i++) {
//       for (var j = i + 1; j < teams.length; j++) {
//         final firstOvr = _startingElevenOvr(teams[i]);
//         final secondOvr = _startingElevenOvr(teams[j]);
//         final difference = firstOvr - secondOvr;
//         final gap = difference.abs();
//         if (gap == 0) continue;
//         final candidate = _FavoritePair(
//           favorite: difference > 0 ? teams[i] : teams[j],
//           underdog: difference > 0 ? teams[j] : teams[i],
//           gap: gap,
//         );
//         if (best == null ||
//             (candidate.gap - 10).abs() < (best.gap - 10).abs()) {
//           best = candidate;
//         }
//       }
//     }
//     if (best == null) throw StateError('Could not build a favorite fixture');
//     return best;
//   }

//   double _pearson(List<double> x, List<int> y) {
//     if (x.length != y.length || x.length < 2) return 0;
//     final meanX = x.reduce((a, b) => a + b) / x.length;
//     final meanY = y.reduce((a, b) => a + b) / y.length;
//     var numerator = 0.0;
//     var sumX = 0.0;
//     var sumY = 0.0;
//     for (var i = 0; i < x.length; i++) {
//       final dx = x[i] - meanX;
//       final dy = y[i] - meanY;
//       numerator += dx * dy;
//       sumX += dx * dx;
//       sumY += dy * dy;
//     }
//     final denominator = sqrt(sumX * sumY);
//     return denominator == 0 ? 0 : numerator / denominator;
//   }
// }

// class _MatchAggregate {
//   int matches = 0;
//   int totalGoals = 0;
//   int homeWins = 0;
//   int draws = 0;
//   int totalShots = 0;
//   int totalFouls = 0;
//   int totalYellowCards = 0;
//   int totalRedCards = 0;
//   int totalInjuries = 0;
//   int extremePossessionMatches = 0;

//   void add(SimulationResult result) {
//     matches++;
//     totalGoals += result.totalGoals;
//     if (result.homeGoals > result.awayGoals) {
//       homeWins++;
//     } else if (result.homeGoals == result.awayGoals) {
//       draws++;
//     }
//     final homeStats = result.homeStats;
//     final awayStats = result.awayStats;
//     totalShots += homeStats.shots + awayStats.shots;
//     totalFouls += homeStats.fouls + awayStats.fouls;
//     totalYellowCards += homeStats.yellowCards + awayStats.yellowCards;
//     totalRedCards += homeStats.redCards + awayStats.redCards;
//     totalInjuries += result.injuries.length;
//     if (result.homePossessionPercent > 65 ||
//         result.awayPossessionPercent > 65) {
//       extremePossessionMatches++;
//     }
//   }
// }

// class _FavoriteAggregate {
//   const _FavoriteAggregate({
//     required this.matches,
//     required this.wins,
//     required this.gap,
//   });

//   final int matches;
//   final int wins;
//   final double gap;
// }

// class _FavoritePair {
//   const _FavoritePair({
//     required this.favorite,
//     required this.underdog,
//     required this.gap,
//   });

//   final Team favorite;
//   final Team underdog;
//   final double gap;
// }

// class _CalibrationReport {
//   const _CalibrationReport({
//     required this.matches,
//     required this.goalsPerMatch,
//     required this.homeWinRate,
//     required this.drawRate,
//     required this.shotsPerTeam,
//     required this.foulsPerTeam,
//     required this.yellowCardsPerTeam,
//     required this.redCardsPerMatch,
//     required this.injuriesPerMatch,
//     required this.extremePossessionRate,
//     required this.ovrPointsCorrelation,
//     required this.favoriteOvrGap,
//     required this.favoriteWinRate,
//     required this.favoriteSamples,
//     required this.roundMilliseconds,
//   });

//   final int matches;
//   final double goalsPerMatch;
//   final double homeWinRate;
//   final double drawRate;
//   final double shotsPerTeam;
//   final double foulsPerTeam;
//   final double yellowCardsPerTeam;
//   final double redCardsPerMatch;
//   final double injuriesPerMatch;
//   final double extremePossessionRate;
//   final double ovrPointsCorrelation;
//   final double favoriteOvrGap;
//   final double favoriteWinRate;
//   final int favoriteSamples;
//   final double roundMilliseconds;

//   String format() =>
//       '''
// Task 24 calibration report
//   random matches:          $matches
//   goals per match:         ${goalsPerMatch.toStringAsFixed(3)} [2.400–2.900]
//   home wins:               ${_percent(homeWinRate)} [48.0–55.0%]
//   draws:                   ${_percent(drawRate)} [21.0–27.0%]
//   shots per team:          ${shotsPerTeam.toStringAsFixed(3)} [9.000–13.000]
//   fouls per team:          ${foulsPerTeam.toStringAsFixed(3)} [9.000–13.000]
//   yellow cards per team:   ${yellowCardsPerTeam.toStringAsFixed(3)} [1.500–2.300]
//   red cards per match:     ${redCardsPerMatch.toStringAsFixed(3)} [0.080–0.160]
//   injuries per match:      ${injuriesPerMatch.toStringAsFixed(3)} [0.250–0.450]
//   extreme possession:      ${_percent(extremePossessionRate)} [<8.0%]
//   OVR ↔ season points:     ${ovrPointsCorrelation.toStringAsFixed(3)} [0.650–0.900]
//   favorite OVR gap:         ${favoriteOvrGap.toStringAsFixed(3)}
//   favorite wins (+10 OVR):  ${_percent(favoriteWinRate)} [60.0–76.0%]
//   favorite samples:        $favoriteSamples
//   15-match round:          ${roundMilliseconds.toStringAsFixed(3)} ms [<150 ms]
// ''';

//   String _percent(double value) => '${(value * 100).toStringAsFixed(2)}%';
// }
