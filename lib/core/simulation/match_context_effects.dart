import 'package:new_football/core/balance/matchday_balance.dart';
import 'package:new_football/core/models/enums.dart';

/// Runtime-only score-state modifiers from Task 21 §12.2.
class ScoreStateModifiers {
  const ScoreStateModifiers({
    required this.goalDifference,
    required this.attackDelta,
    required this.defenseDelta,
    required this.lambdaMultiplier,
    required this.longBallWeightMultiplier,
    required this.automatic,
  });

  const ScoreStateModifiers.neutral()
    : goalDifference = 0,
      attackDelta = 0,
      defenseDelta = 0,
      lambdaMultiplier = 1.0,
      longBallWeightMultiplier = 1.0,
      automatic = false;

  final int goalDifference;
  final int attackDelta;
  final int defenseDelta;
  final double lambdaMultiplier;
  final double longBallWeightMultiplier;
  final bool automatic;

  bool get isTrailing => goalDifference < 0;
  bool get isLeading => goalDifference > 0;

  static ScoreStateModifiers forTeam({
    required int minute,
    required int homeGoals,
    required int awayGoals,
    required bool homeSide,
    required MatchdayBalance balance,
    bool manualTacticsAfter65 = false,
  }) {
    final difference = homeSide ? homeGoals - awayGoals : awayGoals - homeGoals;
    if (minute < 65 || difference == 0 || manualTacticsAfter65) {
      return ScoreStateModifiers.neutral();
    }

    if (difference < 0) {
      final deficit = difference.abs();
      if (deficit == 1) {
        return ScoreStateModifiers(
          goalDifference: difference,
          attackDelta: balance.scoreTrailingOneAttackDelta,
          defenseDelta: balance.scoreTrailingOneDefenseDelta,
          lambdaMultiplier: balance.scoreTrailingOneLambdaMultiplier,
          longBallWeightMultiplier: 1.0,
          automatic: true,
        );
      }
      return ScoreStateModifiers(
        goalDifference: difference,
        attackDelta: balance.scoreTrailingTwoAttackDelta,
        defenseDelta: balance.scoreTrailingTwoDefenseDelta,
        lambdaMultiplier: balance.scoreTrailingTwoLambdaMultiplier,
        longBallWeightMultiplier: balance.scoreTrailingTwoLongBallMultiplier,
        automatic: true,
      );
    }

    if (difference == 1) {
      return ScoreStateModifiers(
        goalDifference: difference,
        attackDelta: balance.scoreLeadingOneAttackDelta,
        defenseDelta: balance.scoreLeadingOneDefenseDelta,
        lambdaMultiplier: balance.scoreLeadingOneLambdaMultiplier,
        longBallWeightMultiplier: 1.0,
        automatic: true,
      );
    }
    return ScoreStateModifiers(
      goalDifference: difference,
      attackDelta: balance.scoreLeadingTwoAttackDelta,
      defenseDelta: balance.scoreLeadingTwoDefenseDelta,
      lambdaMultiplier: balance.scoreLeadingTwoLambdaMultiplier,
      longBallWeightMultiplier: 1.0,
      automatic: true,
    );
  }
}

/// The six explicit weather effects consumed by the runtime.
class MatchWeatherEffects {
  const MatchWeatherEffects({
    required this.passingMultiplier,
    required this.paceMultiplier,
    required this.goalkeeperErrorMultiplier,
    required this.staminaMultiplier,
    required this.injuryMultiplier,
    required this.xgMultiplier,
  });

  final double passingMultiplier;
  final double paceMultiplier;
  final double goalkeeperErrorMultiplier;
  final double staminaMultiplier;
  final double injuryMultiplier;
  final double xgMultiplier;
}

/// Pure Task 21 helpers. The class has no state and does not consume RNG.
class MatchContextEffects {
  const MatchContextEffects._();

  static MatchWeatherEffects weather(
    Weather weather,
    MatchdayBalance balance,
  ) => MatchWeatherEffects(
    passingMultiplier: balance.weatherPassingMultiplier(weather),
    paceMultiplier: balance.weatherPaceMultiplier(weather),
    goalkeeperErrorMultiplier: balance.weatherHandlingMultiplier(weather),
    staminaMultiplier: balance.weatherStaminaMultiplier(weather),
    injuryMultiplier: balance.weatherInjuryMultiplier(weather),
    xgMultiplier: balance.weatherXgMultiplier(weather),
  );

  static double momentumMultiplier(double momentum, MatchdayBalance balance) =>
      1.0 + momentum.clamp(-100.0, 100.0) / balance.momentumSequenceDivisor;

  static double temperatureStaminaMultiplier(
    int temperatureC,
    MatchdayBalance balance,
  ) {
    final hot = (temperatureC - balance.temperatureHotThreshold)
        .clamp(0, 100)
        .toDouble();
    final cold = (balance.temperatureColdThreshold - temperatureC)
        .clamp(0, 100)
        .toDouble();
    return 1.0 +
        hot * balance.temperatureHotStep +
        cold * balance.temperatureColdStep;
  }

  static double crowdMultiplier({
    required int crowdIntensity,
    required bool isHome,
    required MatchdayBalance balance,
  }) => isHome
      ? 1.0 + crowdIntensity / balance.crowdHomeDivisor
      : 1.0 - crowdIntensity / balance.crowdAwayDivisor;

  static double refereeCrowdMultiplier({
    required int crowdIntensity,
    required bool defendingHome,
    required MatchdayBalance balance,
  }) =>
      defendingHome ? 1.0 : 1.0 + crowdIntensity / balance.crowdRefereeDivisor;
}
