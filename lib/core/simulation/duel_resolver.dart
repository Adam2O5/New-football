import 'dart:math' as math;

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';

/// Result of one Task 17 contest, including both noisy ratings.
class DuelResult {
  const DuelResult({
    required this.attackerBaseRating,
    required this.defenderBaseRating,
    required this.attackerNoise,
    required this.defenderNoise,
    required this.attackerRating,
    required this.defenderRating,
    required this.attackerProbability,
    required this.attackerWon,
  });

  final double attackerBaseRating;
  final double defenderBaseRating;
  final double attackerNoise;
  final double defenderNoise;
  final double attackerRating;
  final double defenderRating;
  final double attackerProbability;

  /// Null when the caller requested only the probability and intentionally
  /// skipped the Bernoulli winner roll (used by the possession sample).
  final bool? attackerWon;
}

/// Implements the common noisy logistic duel core from matchday_model.md §7.1.
class DuelResolver {
  const DuelResolver({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  DuelResult contest({
    required double attackerRating,
    required double defenderRating,
    required MatchRandom random,
    bool resolveWinner = true,
    double? sigmaOverride,
    double? dispersionOverride,
  }) {
    final sigma = sigmaOverride ?? balance.matchday.duelSigma;
    final noisyAttacker = attackerRating + random.nextGaussian() * sigma;
    final noisyDefender = defenderRating + random.nextGaussian() * sigma;
    final dispersion = dispersionOverride ?? balance.matchday.duelDispersion;
    final probability =
        1.0 /
        (1.0 + math.pow(10.0, (noisyDefender - noisyAttacker) / dispersion));
    final winner = resolveWinner ? random.nextDouble() < probability : null;

    return DuelResult(
      attackerBaseRating: attackerRating,
      defenderBaseRating: defenderRating,
      attackerNoise: noisyAttacker - attackerRating,
      defenderNoise: noisyDefender - defenderRating,
      attackerRating: noisyAttacker,
      defenderRating: noisyDefender,
      attackerProbability: probability.clamp(0.0, 1.0).toDouble(),
      attackerWon: winner,
    );
  }

  /// Converts a weighted effective-attribute profile into a contest rating.
  double weightedRating(
    EffectivePlayerAttributes attributes,
    Map<EffectiveAttribute, double> weights,
  ) {
    var total = 0.0;
    for (final entry in weights.entries) {
      total += attributes.valueFor(entry.key) * entry.value;
    }
    return total;
  }
}

/// Attribute weights for a sequence duel.
typedef DuelAttributeWeights = Map<EffectiveAttribute, double>;
