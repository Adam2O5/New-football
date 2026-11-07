import 'package:new_football/core/models/enums.dart';

/// Per-club knowledge. Public draft-board noise belongs to DraftBalance.
class ScoutingBalance {
  const ScoutingBalance({
    this.firstTierWeeks = 30.0,
    this.laterTierWeeks = 20.0,
    this.weeksReductionPerEvaluationStar = 2.0,
    this.reportCandidateMultiplier = 2,
    this.combineChanceBase = 0.5,
    this.combineChancePerStar = 0.1,
    this.combineChanceMin = 0.5,
    this.combineChanceMax = 1.0,
    this.monthlyReplacementChance = 0.40,
    this.monthlyRankRiseMinExclusive = 20,
    this.ovrSpans = const {
      ScoutingTier.tier1: 5,
      ScoutingTier.tier2: 5,
      ScoutingTier.tier3: 3,
      ScoutingTier.tier4: 3,
      ScoutingTier.tier5: 1,
    },
    this.potentialSpan = 1.0,
    this.traitSpan = 2,
    this.unknownProspectUncertainty = 1000,
    this.unknownOvrUncertainty = 100,
    this.unknownPotentialUncertainty = 20,
    this.potentialUncertaintyWeight = 10.0,
    this.tierUncertaintyWeight = 100,
    this.slotBands = const [
      (1, EstimatedDraftSlot.top1),
      (3, EstimatedDraftSlot.top3),
      (5, EstimatedDraftSlot.top5),
      (10, EstimatedDraftSlot.top10),
      (30, EstimatedDraftSlot.r1),
      (60, EstimatedDraftSlot.r2),
      (90, EstimatedDraftSlot.r3),
    ],
    this.earlyMockNoiseMin = 10,
    this.earlyMockNoiseMax = 15,
    this.finalMockNoiseBase = 25,
    this.finalMockNoisePerStar = 4,
    this.finalMockNoiseMin = 5,
    this.finalMockNoiseMax = 25,
  });

  final int earlyMockNoiseMin;
  final double firstTierWeeks;
  final double laterTierWeeks;
  final double weeksReductionPerEvaluationStar;
  final int reportCandidateMultiplier;
  final double combineChanceBase;
  final double combineChancePerStar;
  final double combineChanceMin;
  final double combineChanceMax;
  final double monthlyReplacementChance;
  final int monthlyRankRiseMinExclusive;
  final Map<ScoutingTier, int> ovrSpans;
  final double potentialSpan;
  final int traitSpan;
  final int unknownProspectUncertainty;
  final int unknownOvrUncertainty;
  final int unknownPotentialUncertainty;
  final double potentialUncertaintyWeight;
  final int tierUncertaintyWeight;
  final List<(int rankExclusive, EstimatedDraftSlot slot)> slotBands;
  final int earlyMockNoiseMax;
  final int finalMockNoiseBase;
  final int finalMockNoisePerStar;
  final int finalMockNoiseMin;
  final int finalMockNoiseMax;
}
