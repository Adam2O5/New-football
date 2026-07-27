import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/scouting.dart';

/// Fog-of-war skautingowy: watchlist, progres tierów, Scout Report / Combine
/// / Mock finalny (`docs/staff_rules.md` §5, `docs/offseason.md` §5–7).
class ScoutingService {
  ScoutingService({this.balance = BalanceConfig.defaults, Random? random})
    : _random = random ?? Random();

  final BalanceConfig balance;
  final Random _random;

  int maxWatched(double coverageStars) => balance.staff.maxWatched(coverageStars);

  TeamScouting setWatchlist(
    TeamScouting scouting,
    List<String> prospectIds, {
    required double coverageStars,
  }) {
    final limit = maxWatched(coverageStars);
    final capped = prospectIds.take(limit).toList();
    final cappedSet = capped.toSet();
    final existing = {for (final k in scouting.knowledge) k.prospectId: k};
    final knowledge = [
      for (final id in capped) existing[id] ?? ScoutingKnowledge(prospectId: id),
    ];
    return scouting.copyWith(
      watchlistProspectIds: capped,
      knowledge: knowledge,
      combineAssignedProspectIds: scouting.combineAssignedProspectIds
          .where(cappedSet.contains)
          .toList(),
    );
  }

  /// Cotygodniowy progres tieru dla obserwowanych prospectów, ∝ Evaluation.
  TeamScouting tickKnowledge(TeamScouting scouting, double evaluationStars) {
    final chance = (0.15 + evaluationStars * 0.09).clamp(0.05, 0.6);
    final updated = scouting.knowledge.map((k) {
      if (k.tier == ScoutingTier.tier5) return k;
      if (_random.nextDouble() >= chance) return k;
      final nextIndex = ScoutingTier.values.indexOf(k.tier) + 1;
      return k.copyWith(tier: ScoutingTier.values[nextIndex]);
    }).toList();
    return scouting.copyWith(knowledge: updated);
  }

  /// Scout Report (pon tyg. 45): przydział celów na Combine, limit ≈ ½
  /// Coverage.
  TeamScouting runScoutReport(TeamScouting scouting, double coverageStars) {
    final limit = balance.staff.combineAssignLimit(coverageStars);
    final targets = scouting.watchlistProspectIds.take(limit).toList();
    return scouting.copyWith(combineAssignedProspectIds: targets);
  }

  /// Draft Combine (śr tyg. 45): bonus odczytu injuryProne/determination dla
  /// przypisanych prospectów.
  TeamScouting runCombine(TeamScouting scouting, double evaluationStars) {
    final bonusChance = (0.5 + evaluationStars * 0.1).clamp(0.5, 1.0);
    final assigned = scouting.combineAssignedProspectIds.toSet();
    final updated = scouting.knowledge.map((k) {
      if (!assigned.contains(k.prospectId)) return k;
      final tier = k.tier.index < ScoutingTier.tier4.index
          ? ScoutingTier.tier4
          : k.tier;
      return k.copyWith(
        injuryProneKnown: k.injuryProneKnown || _random.nextDouble() < bonusChance,
        determinationKnown:
            k.determinationKnown || _random.nextDouble() < bonusChance,
        tier: tier,
      );
    }).toList();
    return scouting.copyWith(knowledge: updated);
  }

  /// Mock Draft finalny (pt tyg. 45): estymowany slot z szumem malejącym z
  /// Evaluation.
  TeamScouting runFinalMock(
    TeamScouting scouting,
    List<Prospect> rankedProspects,
    double evaluationStars,
  ) {
    final noiseRange = (25 - evaluationStars * 4).clamp(5, 25).round();
    final updated = scouting.knowledge.map((k) {
      final trueRank = rankedProspects.indexWhere((p) => p.id == k.prospectId);
      if (trueRank < 0) return k;
      final noisy = (trueRank + (_random.nextInt(noiseRange * 2 + 1) - noiseRange))
          .clamp(0, rankedProspects.length - 1);
      final tier = k.tier.index < ScoutingTier.tier3.index
          ? ScoutingTier.tier3
          : k.tier;
      return k.copyWith(estimatedSlot: _slotForRank(noisy), tier: tier);
    }).toList();
    return scouting.copyWith(knowledge: updated);
  }

  EstimatedDraftSlot _slotForRank(int rank) {
    if (rank == 0) return EstimatedDraftSlot.top1;
    if (rank < 3) return EstimatedDraftSlot.top3;
    if (rank < 5) return EstimatedDraftSlot.top5;
    if (rank < 10) return EstimatedDraftSlot.top10;
    if (rank < 30) return EstimatedDraftSlot.r1;
    if (rank < 60) return EstimatedDraftSlot.r2;
    if (rank < 90) return EstimatedDraftSlot.r3;
    return EstimatedDraftSlot.x;
  }
}
