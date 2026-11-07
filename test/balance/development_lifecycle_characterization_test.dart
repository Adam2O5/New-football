import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/match_post_match_service.dart';

void main() {
  const balance = BalanceConfig.defaults;
  for (final appearances in [0, 1, 2]) {
    test(
      '$appearances appearances: weekly rate replaces the post-match cache',
      () {
        final source = SeedDataGenerator()
            .generateLeague(seed: 42)
            .teams
            .first
            .roster
            .first;
        final initial = source.copyWith(
          age: 20,
          personality: PlayerPersonality.balanced,
          state: source.state.copyWith(minutesThisWeek: 0, form: 6),
          hidden: source.hidden.copyWith(
            growthRate: -1,
            overallProgress: 0,
            determination: 5,
            developmentCeilingStars: 5,
          ),
        );
        final service = DevelopmentService();
        final base = service.calculateGrowthRate(initial, atmosphere: 50);
        var player = initial;
        for (var i = 0; i < appearances; i++) {
          player = applyMatchPlayerEffects(
            player: player,
            teamId: 'home',
            result: const MatchResult(
              homeTeamId: 'home',
              awayTeamId: 'away',
              homeGoals: 0,
              awayGoals: 0,
              homeStats: TeamMatchStats(teamId: 'home'),
              awayStats: TeamMatchStats(teamId: 'away'),
            ),
            seasonYear: 2026,
            balance: balance,
            stats: PlayerMatchStats(
              playerId: player.id,
              minutes: 30,
              rating: 6,
            ),
          );
        }
        expect(player.state.minutesThisWeek, appearances * 30);
        expect(player.hidden.growthRate, closeTo(-1 + appearances * 0.3, 1e-9));
        final expectedRate = base + appearances * 0.3;
        final weekly = service
            .developPlayerWithContext(player, atmosphere: 50)
            .player;
        expect(weekly.hidden.growthRate, closeTo(expectedRate, 1e-9));
        expect(
          weekly.hidden.overallProgress,
          closeTo(balance.development.progressFor(expectedRate), 1e-9),
        );
        expect(weekly.state.minutesThisWeek, 0);
      },
    );
  }
}
