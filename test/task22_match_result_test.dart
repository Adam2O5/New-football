import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/simulation/match_engine.dart';

void main() {
  final league = SeedDataGenerator(
    random: null,
  ).generateLeague(year: 2026, seed: 2201);
  final home = league.teams[0];
  final away = league.teams[1];
  const engine = SimulationMatchEngine();

  test('agreguje statystyki z trace, a nie z wyniku końcowego', () {
    var foundNonHeuristicSample = false;
    for (var seed = 1; seed <= 20; seed++) {
      final runtime = engine.simulateFull(
        home: home,
        away: away,
        rngSeed: seed,
      );
      final result = engine.simulateFullMatch(
        home: home,
        away: away,
        rngSeed: seed,
      );

      expect(result.homeStats.shots, runtime.homeShots);
      expect(result.awayStats.shots, runtime.awayShots);
      expect(result.homeStats.shotsOnTarget, runtime.homeShotsOnTarget);
      expect(result.awayStats.shotsOnTarget, runtime.awayShotsOnTarget);
      expect(result.homeStats.xg, closeTo(runtime.homeXg, 0.000001));
      expect(result.awayStats.xg, closeTo(runtime.awayXg, 0.000001));
      expect(
        result.homeStats.possession,
        runtime.homePossessionPercent.round(),
      );
      expect(
        result.awayStats.possession,
        runtime.awayPossessionPercent.round(),
      );

      if (result.homeStats.shots != result.homeGoals + 4 ||
          result.awayStats.shots != result.awayGoals + 4 ||
          result.homeStats.possession != 50) {
        foundNonHeuristicSample = true;
      }
    }
    expect(foundNonHeuristicSample, isTrue);
  });

  test('rating mieści się w 1–10, a MotM pochodzi z najwyższego ratingu', () {
    final result = engine.simulateFullMatch(
      home: home,
      away: away,
      rngSeed: 2202,
    );
    for (final stat in result.playerStats) {
      expect(stat.rating, inInclusiveRange(1.0, 10.0));
    }
    final motmId = result.manOfTheMatchPlayerId;
    if (motmId != null) {
      final motm = result.playerStats.firstWhere(
        (stat) => stat.playerId == motmId,
      );
      expect(motm.minutes, greaterThan(0));
      expect(motm.rating, greaterThanOrEqualTo(7.0));
      expect(
        motm.rating,
        result.playerStats
            .where((stat) => stat.minutes > 0)
            .map((stat) => stat.rating)
            .reduce((a, b) => a > b ? a : b),
      );
    }
    final inspiredId = result.inspiredPerformancePlayerId;
    if (inspiredId != null) {
      expect(inspiredId, motmId);
    }
  });

  test('rozszerzone modele MatchResult przechodzą JSON round-trip', () {
    final playerStats = PlayerMatchStats(
      playerId: 'p-22',
      minutes: 73,
      goals: 1,
      assists: 1,
      shots: 4,
      shotsOnTarget: 3,
      xg: 1.27,
      passes: 42,
      passAccuracy: 88.1,
      duelsWon: 7,
      offsides: 1,
      corners: 2,
      yellowCards: 1,
      redCards: 0,
      tackles: 3,
      interceptions: 2,
      saves: 0,
      shotsFaced: 0,
      ownGoals: 0,
      cleanSheet: false,
      staminaAfterMatch: 38,
      rating: 8.4,
    );
    final source = MatchResult(
      homeTeamId: 'home-22',
      awayTeamId: 'away-22',
      homeGoals: 2,
      awayGoals: 1,
      homeStats: const TeamMatchStats(
        teamId: 'home-22',
        goals: 2,
        shots: 11,
        shotsOnTarget: 6,
        possession: 57,
        xg: 1.84,
        passes: 402,
        passAccuracy: 86.2,
        duelsWon: 31,
        offsides: 2,
        corners: 5,
        fouls: 9,
        yellowCards: 2,
        redCards: 0,
        saves: 3,
      ),
      awayStats: const TeamMatchStats(
        teamId: 'away-22',
        goals: 1,
        shots: 8,
        shotsOnTarget: 3,
        possession: 43,
        xg: 0.92,
        passes: 301,
        passAccuracy: 79.4,
        duelsWon: 27,
        offsides: 1,
        corners: 3,
        fouls: 12,
        yellowCards: 3,
        redCards: 1,
        saves: 4,
      ),
      context: const MatchContext(
        homeTeamId: 'home-22',
        awayTeamId: 'away-22',
        temperatureC: 24,
      ),
      playerStats: [playerStats],
      manOfTheMatchPlayerId: 'p-22',
      inspiredPerformancePlayerId: 'p-22',
      matchEndMinute: 96,
      stoppageTime: 6,
    );

    final restored = MatchResult.fromJson(
      jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>,
    );
    expect(restored, source);
    expect(restored.playerStats.single.staminaAfterMatch, 38);
    expect(restored.homeStats.xg, closeTo(1.84, 0.000001));
  });

  test('obserwowany i headless mecz kończą się identycznym MatchResult', () {
    const context = MatchContext(
      homeTeamId: 'team_east_0',
      awayTeamId: 'team_east_1',
      seed: 2203,
    );
    final headless = engine.simulateFullMatch(
      home: home,
      away: away,
      context: context.copyWith(homeTeamId: home.id, awayTeamId: away.id),
      rngSeed: 2203,
    );
    final live = engine.start(
      home: home,
      away: away,
      context: context.copyWith(homeTeamId: home.id, awayTeamId: away.id),
      rngSeed: 2203,
    );
    engine.runUntil(live, 90);
    final observed = engine.toMatchResult(live: live, home: home, away: away);

    expect(observed, headless);
  });

  test(
    'raport runtime zasila +20, seasonStats i growthRate bez podwójnej straty',
    () {
      final selected = home.roster.first;
      final match = ScheduledMatch(
        id: 'task22-effects',
        homeTeamId: home.id,
        awayTeamId: away.id,
        round: 1,
      );
      final state = league.copyWith(
        playerTeamId: home.id,
        currentSeason: league.currentSeason.copyWith(schedule: [match]),
      );
      final result = MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: 1,
        awayGoals: 0,
        homeStats: TeamMatchStats(teamId: home.id, goals: 1),
        awayStats: TeamMatchStats(teamId: away.id),
        context: MatchContext(homeTeamId: home.id, awayTeamId: away.id),
        playerStats: [
          PlayerMatchStats(
            playerId: selected.id,
            minutes: 90,
            shots: 5,
            shotsOnTarget: 3,
            xg: 1.1,
            passes: 20,
            passAccuracy: 80,
            rating: 8.0,
            staminaAfterMatch: 40,
          ),
        ],
      );

      final after = DaySimulator().applyPlayerMatchResult(state, match, result);
      final updated = after
          .teamById(home.id)!
          .roster
          .firstWhere((player) => player.id == selected.id);
      final season = updated.seasonStats.firstWhere(
        (stats) => stats.year == state.currentSeason.year,
      );

      // 40 after the runtime +20 post-match +20 end-of-day recovery.
      expect(updated.state.stamina, 80);
      expect(
        updated.state.minutesThisWeek,
        selected.state.minutesThisWeek + 90,
      );
      expect(season.minutes, 90);
      expect(season.shots, 5);
      expect(season.shotsOnTarget, 3);
      expect(season.xg, closeTo(1.1, 0.000001));
      expect(season.passes, 20);
      expect(season.passAccuracy, closeTo(80, 0.000001));
      expect(
        updated.hidden.growthRate,
        closeTo(
          (selected.hidden.growthRate + 0.9).clamp(-3.0, 3.0).toDouble(),
          0.000001,
        ),
      );
    },
  );
}
