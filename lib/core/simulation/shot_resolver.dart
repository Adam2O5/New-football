import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/goalkeeper_resolver.dart';
import 'package:new_football/core/simulation/sequence_resolver.dart';
import 'package:new_football/core/simulation/shot_models.dart';

/// Runtime-only result of a shot and its bounded follow-up.
class ShotResolution {
  const ShotResolution({
    required this.isShot,
    required this.xg,
    required this.goalProbability,
    required this.outcome,
    required this.shooterId,
    required this.goalkeeperId,
    required this.goalkeeperRating,
    required this.handlingErrorProbability,
    required this.reboundAttempted,
    required this.reboundGoal,
    required this.reboundXg,
    required this.cornerAwarded,
  });

  const ShotResolution.noShot({this.shooterId})
    : isShot = false,
      xg = 0.0,
      goalProbability = 0.0,
      outcome = null,
      goalkeeperId = null,
      goalkeeperRating = 0.0,
      handlingErrorProbability = 0.0,
      reboundAttempted = false,
      reboundGoal = false,
      reboundXg = 0.0,
      cornerAwarded = false;

  final bool isShot;
  final double xg;
  final double goalProbability;
  final ShotOutcome? outcome;
  final String? shooterId;
  final String? goalkeeperId;
  final double goalkeeperRating;
  final double handlingErrorProbability;
  final bool reboundAttempted;
  final bool reboundGoal;
  final double reboundXg;
  final bool cornerAwarded;

  bool get isGoal =>
      outcome == ShotOutcome.goal ||
      outcome == ShotOutcome.goalkeeperError ||
      outcome == ShotOutcome.reboundGoal;

  bool get isOnTarget => isGoal || outcome == ShotOutcome.saved;
}

/// Resolves the documented sequence-to-shot and shot-to-goal funnel.
class ShotResolver {
  const ShotResolver({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  ShotResolution resolve({
    required SequenceType sequenceType,
    required SequenceShotKind shotKind,
    required Player shooter,
    required List<Player> defendingLineup,
    required MatchContext context,
    required MatchRandom random,
    Map<String, EffectivePlayerAttributes> shooterAttributes = const {},
    Map<String, EffectivePlayerAttributes> defendingAttributes = const {},
    int wonDuels = 0,
    double chanceQualityMultiplier = 1.0,
    bool useSequenceGate = true,
    double? baseXgOverride,
    bool allowRebound = true,
    int minute = 0,
    bool applyClutch = true,
  }) {
    if (useSequenceGate &&
        random.nextDouble() >= balance.matchday.sequenceToShot) {
      return ShotResolution.noShot(shooterId: shooter.id);
    }

    final rawShooterValue = _shooting(shooter, shooterAttributes[shooter.id]);
    final decisiveSituation =
        shotKind == SequenceShotKind.penalty ||
        minute >= 85 ||
        context.stake == MatchStake.playoffElimination;
    final shooterValue =
        rawShooterValue +
        (applyClutch && decisiveSituation
            ? balance.matchday.clutchBonus(
                determination: shooter.hidden.determination,
                stake: context.stake,
                ambitious: shooter.personality == PlayerPersonality.ambitious,
              )
            : 0.0);
    final shooterFactor =
        1.0 + (shooterValue - balance.matchday.shootingBaseline) / 180.0;
    final baseXg =
        baseXgOverride ??
        balance.matchday.sequenceBaseXg[sequenceType.name] ??
        balance.matchday.shotToGoal;
    final weatherXgMultiplier = balance.matchday.weatherXgMultiplier(
      context.weather,
    );
    final xg =
        (baseXg * chanceQualityMultiplier * shooterFactor * weatherXgMultiplier)
            .clamp(0.01, 0.95)
            .toDouble();
    final goalkeeper = GoalkeeperResolver(balance: balance).resolve(
      shotKind: shotKind,
      defendingLineup: defendingLineup,
      effectiveAttributes: defendingAttributes,
      weather: context.weather,
    );
    final gkFactor =
        1.0 -
        (goalkeeper.gkRating - balance.matchday.gkRatingBaseline) /
            balance.matchday.gkRatingDivisor;
    final goalProbability = (xg * gkFactor).clamp(0.005, 0.97).toDouble();

    if (random.nextDouble() < goalProbability) {
      return ShotResolution(
        isShot: true,
        xg: xg,
        goalProbability: goalProbability,
        outcome: ShotOutcome.goal,
        shooterId: shooter.id,
        goalkeeperId: goalkeeper.goalkeeperId,
        goalkeeperRating: goalkeeper.gkRating,
        handlingErrorProbability: goalkeeper.handlingErrorProbability,
        reboundAttempted: false,
        reboundGoal: false,
        reboundXg: 0.0,
        cornerAwarded: false,
      );
    }

    if (random.nextDouble() < goalkeeper.handlingErrorProbability) {
      return ShotResolution(
        isShot: true,
        xg: xg,
        goalProbability: goalProbability,
        outcome: ShotOutcome.goalkeeperError,
        shooterId: shooter.id,
        goalkeeperId: goalkeeper.goalkeeperId,
        goalkeeperRating: goalkeeper.gkRating,
        handlingErrorProbability: goalkeeper.handlingErrorProbability,
        reboundAttempted: false,
        reboundGoal: false,
        reboundXg: 0.0,
        cornerAwarded: false,
      );
    }

    final outcome = random.pickWeighted<ShotOutcome>({
      ShotOutcome.saved: balance.matchday.shotSavedWeight,
      ShotOutcome.offTarget: balance.matchday.shotOffTargetWeight,
      ShotOutcome.blocked: balance.matchday.shotBlockedWeight,
      ShotOutcome.post: balance.matchday.shotPostWeight,
    });
    var reboundAttempted = false;
    var reboundGoal = false;
    var reboundXg = 0.0;
    var cornerAwarded = false;
    var finalOutcome = outcome;

    final reboundChance = switch (outcome) {
      ShotOutcome.saved => balance.matchday.reboundAfterSave,
      ShotOutcome.post => balance.matchday.reboundAfterPost,
      _ => 0.0,
    };
    if (reboundChance > 0 &&
        allowRebound &&
        random.nextDouble() < reboundChance) {
      reboundAttempted = true;
      reboundXg = (xg * balance.matchday.reboundXgMultiplier)
          .clamp(0.005, 0.95)
          .toDouble();
      final reboundProbability = (reboundXg * gkFactor)
          .clamp(0.005, 0.97)
          .toDouble();
      if (random.nextDouble() < reboundProbability) {
        reboundGoal = true;
        finalOutcome = ShotOutcome.reboundGoal;
      }
    }
    if (outcome == ShotOutcome.blocked &&
        random.nextDouble() < balance.matchday.cornerAfterBlock) {
      cornerAwarded = true;
    }

    return ShotResolution(
      isShot: true,
      xg: xg,
      goalProbability: goalProbability,
      outcome: finalOutcome,
      shooterId: shooter.id,
      goalkeeperId: goalkeeper.goalkeeperId,
      goalkeeperRating: goalkeeper.gkRating,
      handlingErrorProbability: goalkeeper.handlingErrorProbability,
      reboundAttempted: reboundAttempted,
      reboundGoal: reboundGoal,
      reboundXg: reboundXg,
      cornerAwarded: cornerAwarded,
    );
  }

  double _shooting(Player player, EffectivePlayerAttributes? effective) =>
      effective?.shooting ??
      player.attributes.map(
        outfield: (attributes) => attributes.stats.shooting.toDouble(),
        goalkeeper: (attributes) => attributes.stats.overall,
      );
}
