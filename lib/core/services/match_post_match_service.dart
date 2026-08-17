import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

/// Applies the player-facing part of one completed match.
///
/// Runtime results carry the actual stamina left after the final minute. Old
/// hand-authored or older persisted results use [staminaAfterMatch] == -1 and
/// therefore retain the historical minute-based fallback.
Player applyMatchPlayerEffects({
  required Player player,
  required String teamId,
  required MatchResult result,
  required int seasonYear,
  required BalanceConfig balance,
  PlayerMatchStats? stats,
  MatchInjury? matchInjury,
}) {
  final minutes = stats?.minutes ?? 0;
  final tactics = teamId == result.homeTeamId
      ? result.homeTactics
      : result.awayTactics;
  final lost = teamId == result.homeTeamId
      ? result.homeGoals < result.awayGoals
      : result.awayGoals < result.homeGoals;

  final reportedStamina = stats?.staminaAfterMatch ?? -1;
  final afterMatchStamina = reportedStamina >= 0
      ? balance.player.clampStamina(reportedStamina)
      : _fallbackStaminaAfterMatch(
          player: player,
          minutes: minutes,
          tactics: tactics,
          result: result,
          balance: balance,
        );

  var next = player.copyWith(
    state: player.state.copyWith(
      // Runtime stamina already includes every per-minute weather, tempo,
      // pressing and short-handed multiplier. Add the documented immediate
      // post-match recovery exactly once here.
      stamina: balance.player.clampStamina(
        afterMatchStamina + balance.player.recoveryBetweenMatches,
      ),
      minutesThisWeek: player.state.minutesThisWeek + minutes,
    ),
  );

  next = next.withMatchForm(
    minutesPlayed: minutes,
    rating: stats?.rating ?? 6.0,
    lost: lost,
    balance: balance,
  );

  if (stats != null && _hasMatchContribution(stats)) {
    next = _recordSeasonStats(
      next,
      stats: stats,
      seasonYear: seasonYear,
      balance: balance,
    );
  }

  if (result.inspiredPerformancePlayerId == player.id) {
    next = next.copyWith(
      state: next.state.copyWith(
        form: balance.player.clampForm(next.state.form + 1.0),
      ),
      hidden: next.hidden.copyWith(
        overallProgress: (next.hidden.overallProgress + 5.0)
            .clamp(0.0, 100.0)
            .toDouble(),
      ),
    );
  }

  if (matchInjury != null) {
    final eventState = matchInjury.injury.type == InjuryType.major
        ? next.state.eventState.copyWith(
            lastMajorInjury: matchInjury.injury,
            majorInjuryActiveLastTick: true,
            weeksSinceMajorInjury: 0,
          )
        : next.state.eventState;
    next = next.copyWith(
      state: next.state.copyWith(
        injury: matchInjury.injury,
        eventState: eventState,
      ),
    );
    if (matchInjury.potentialLoss) {
      next = next
          .copyWith(
            potentialStars: (next.potentialStars - 0.5)
                .clamp(0.5, 5.0)
                .toDouble(),
            hidden: next.hidden.copyWith(
              developmentCeilingStars:
                  (next.hidden.developmentCeilingStars - 0.5)
                      .clamp(0.5, 5.0)
                      .toDouble(),
            ),
          )
          .recalculatePointValue(balance);
    }
  }
  return next;
}

int _fallbackStaminaAfterMatch({
  required Player player,
  required int minutes,
  required TacticsSetup tactics,
  required MatchResult result,
  required BalanceConfig balance,
}) {
  final loss = balance.player.staminaLossForMinutes(
    player.position,
    minutes,
    tempo: tactics.tempo,
    pressing: tactics.pressing,
    weather: result.context.weather,
    isDerby: result.context.isDerby,
  );
  return balance.player.clampStamina(
    (player.state.stamina.toDouble() - loss).round(),
  );
}

bool _hasMatchContribution(PlayerMatchStats stats) =>
    stats.minutes > 0 ||
    stats.goals != 0 ||
    stats.assists != 0 ||
    stats.shots != 0 ||
    stats.shotsOnTarget != 0 ||
    stats.xg != 0.0 ||
    stats.passes != 0 ||
    stats.duelsWon != 0 ||
    stats.offsides != 0 ||
    stats.corners != 0 ||
    stats.yellowCards != 0 ||
    stats.redCards != 0 ||
    stats.tackles != 0 ||
    stats.interceptions != 0 ||
    stats.saves != 0 ||
    stats.shotsFaced != 0 ||
    stats.ownGoals != 0 ||
    stats.cleanSheet;

Player _recordSeasonStats(
  Player player, {
  required PlayerMatchStats stats,
  required int seasonYear,
  required BalanceConfig balance,
}) {
  final seasons = [...player.seasonStats];
  final index = seasons.indexWhere((season) => season.year == seasonYear);
  final previous = index < 0
      ? PlayerSeasonStats(year: seasonYear)
      : seasons[index];
  final previousRatingWeight = previous.minutes > 0
      ? previous.minutes
      : previous.appearances;
  final currentRatingWeight = stats.minutes > 0 ? stats.minutes : 1;
  final ratingWeight = previousRatingWeight + currentRatingWeight;
  final passWeight = previous.passes + stats.passes;
  final weightedPassAccuracy =
      previous.passAccuracy * previous.passes +
      stats.passAccuracy * stats.passes;
  final next = previous.copyWith(
    minutes: previous.minutes + stats.minutes,
    goals: previous.goals + stats.goals,
    assists: previous.assists + stats.assists,
    appearances: previous.appearances + (stats.minutes > 0 ? 1 : 0),
    yellowCards: previous.yellowCards + stats.yellowCards,
    redCards: previous.redCards + stats.redCards,
    shots: previous.shots + stats.shots,
    shotsOnTarget: previous.shotsOnTarget + stats.shotsOnTarget,
    xg: previous.xg + stats.xg,
    passes: previous.passes + stats.passes,
    passAccuracy: passWeight == 0
        ? previous.passAccuracy
        : weightedPassAccuracy / passWeight,
    duelsWon: previous.duelsWon + stats.duelsWon,
    offsides: previous.offsides + stats.offsides,
    corners: previous.corners + stats.corners,
    tackles: previous.tackles + stats.tackles,
    interceptions: previous.interceptions + stats.interceptions,
    cleanSheets: previous.cleanSheets + (stats.cleanSheet ? 1 : 0),
    saves: previous.saves + stats.saves,
    shotsFaced: previous.shotsFaced + stats.shotsFaced,
    ratingAvg: ratingWeight == 0
        ? 0.0
        : (previous.ratingAvg * previousRatingWeight +
                  stats.rating * currentRatingWeight) /
              ratingWeight,
  );
  if (index < 0) {
    seasons.add(next);
  } else {
    seasons[index] = next;
  }

  final growthRate = (player.hidden.growthRate + stats.minutes * 0.01)
      .clamp(
        balance.development.growthRateMin,
        balance.development.growthRateMax,
      )
      .toDouble();
  return player.copyWith(
    seasonStats: seasons,
    hidden: player.hidden.copyWith(growthRate: growthRate),
  );
}
