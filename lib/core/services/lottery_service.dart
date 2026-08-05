import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/standing.dart';

/// Service responsible for computing lottery odds and results
/// for the draft lottery ceremony screen.
class LotteryService {
  /// Computes the percentage chance each team has of getting pick #1.
  ///
  /// Takes a list of [weights] (e.g. DraftBalance.lotteryWeights) and returns
  /// a list of percentages where each element is `weight / totalWeight * 100`.
  static List<double> computeOddsPercentages(List<int> weights) {
    final totalWeight = weights.fold<int>(0, (sum, w) => sum + w);
    if (totalWeight == 0) return List.filled(weights.length, 0.0);
    return weights.map((w) => w / totalWeight * 100).toList();
  }

  /// Implements the weighted lottery algorithm to determine draft pick order.
  ///
  /// Takes a list of 10 [lotteryTeams] sorted worst-first, uses
  /// [DraftBalance.lotteryWeights], and returns a [List<LotteryResult>]
  /// with 10 entries. An optional [random] can be provided for testing.
  static List<LotteryResult> computeResults(
    List<Standing> lotteryTeams, {
    Random? random,
  }) {
    final rng = random ?? Random();
    final weights = DraftBalance.lotteryWeights;
    final remaining = List<Standing>.from(lotteryTeams);
    final remainingWeights = List<int>.from(weights);
    final results = <LotteryResult>[];
    final totalOdds = weights.fold<int>(0, (s, w) => s + w);

    for (var pick = 1; pick <= 10; pick++) {
      final total = remainingWeights.fold<int>(0, (s, w) => s + w);
      var roll = rng.nextInt(total);
      var idx = 0;
      for (var i = 0; i < remainingWeights.length; i++) {
        roll -= remainingWeights[i];
        if (roll < 0) {
          idx = i;
          break;
        }
      }
      results.add(
        LotteryResult(
          teamId: remaining[idx].teamId,
          originalRank:
              lotteryTeams.indexWhere((s) => s.teamId == remaining[idx].teamId) +
                  1,
          assignedPick: pick,
          oddsForFirstPick:
              weights[lotteryTeams.indexWhere(
                    (s) => s.teamId == remaining[idx].teamId,
                  )] /
              totalOdds,
        ),
      );
      remaining.removeAt(idx);
      remainingWeights.removeAt(idx);
    }
    return results;
  }
}
