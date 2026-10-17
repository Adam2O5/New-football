import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/lottery_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/team_management_service.dart';

import 'support/game_fixtures.dart';

void main() {
  for (final seed in [1, 123, 456]) {
    test(
      'career and ceremony use DraftBalance lottery weights (seed $seed)',
      () {
        final league = seededLeague();
        final standings =
            [
              for (final conference in league.currentSeason.standings)
                ...conference.standings,
            ]..sort((a, b) {
              final points = a.points.compareTo(b.points);
              return points != 0
                  ? points
                  : a.goalDifference.compareTo(b.goalDifference);
            });
        final expected = LotteryService.computeResults(
          standings.take(10).toList(),
          saveSeed: seed,
          seasonYear: league.currentSeason.year,
        );
        final actual = SeasonService().runLottery(league, saveSeed: seed);
        expect(actual.currentSeason.draftState!.lotteryResults, expected);
        final total = DraftBalance.lotteryWeights.reduce((a, b) => a + b);
        for (final result in expected) {
          expect(
            result.oddsForFirstPick,
            DraftBalance.lotteryWeights[result.originalRank - 1] / total,
          );
        }
      },
    );
  }

  test(
    'default award eligibility stays unchanged; configured thresholds work',
    () {
      final league = controllerSave().leagueState;
      final team = league.playerTeam!;
      final gk = team.roster
          .firstWhere((p) => p.position == Position.gk)
          .copyWith(
            seasonStats: [
              const PlayerSeasonStats(
                year: 2026,
                minutes: 2088,
                appearances: 24,
                saves: 50,
                shotsFaced: 70,
                ratingAvg: 8,
              ),
            ],
          );
      final striker = team.roster
          .firstWhere((p) => p.position != Position.gk)
          .copyWith(
            position: Position.st,
            draftYear: 2025,
            seasonStats: [
              const PlayerSeasonStats(
                year: 2026,
                minutes: 1305,
                appearances: 15,
                goals: 20,
                assists: 5,
                ratingAvg: 9,
              ),
            ],
          );
      final input = league.updateTeam(team.copyWith(roster: [gk, striker]));
      final defaults = SeasonService().runAwards(input).currentSeason.awards!;
      expect(defaults.mvpPlayerId, gk.id);
      expect(defaults.rotyPlayerId, striker.id);
      expect(defaults.bestGkPlayerId, gk.id);
      expect(defaults.topScorerPlayerId, striker.id);
      expect(defaults.teamOfSeason[TeamOfSeasonSlot.gk], gk.id);
      expect(defaults.teamOfSeason[TeamOfSeasonSlot.st], isNull);
      final configured = SeasonService(
        balance: const BalanceConfig(
          awards: AwardsBalance(
            mvpMinutesPct: 100,
            rotyMinutesPct: 100,
            dpoyMinutesPct: 100,
            bestGkMinutesPct: 100,
            totsSlotMinutesPct: 100,
          ),
        ),
      ).runAwards(input).currentSeason.awards!;
      expect(configured.mvpPlayerId, isNull);
      expect(configured.rotyPlayerId, isNull);
      expect(configured.dpoyPlayerId, isNull);
      expect(configured.bestGkPlayerId, isNull);
      expect(configured.teamOfSeason, isEmpty);
      // The existing scorer rule has no minimum-minutes filter; keep it so.
      expect(configured.topScorerPlayerId, defaults.topScorerPlayerId);
    },
  );

  test('team form still considers the last eight matches', () {
    expect(
      TeamManagementService.teamForm([for (var i = 0; i < 8; i++) 1, -1]),
      0.875,
    );
    expect(TeamManagementService.teamForm([]), 0.5);
  });
}
