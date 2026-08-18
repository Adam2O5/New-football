import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/models/enums.dart';

const _defaultAiRosterGroups = <AiRosterGroupDefinition>[
  AiRosterGroupDefinition(
    group: AiRosterGroup.gk,
    positions: [Position.gk],
    min: 2,
    target: 3,
    max: 4,
  ),
  AiRosterGroupDefinition(
    group: AiRosterGroup.cb,
    positions: [Position.cb],
    min: 3,
    target: 4,
    max: 5,
  ),
  AiRosterGroupDefinition(
    group: AiRosterGroup.wideDefenders,
    positions: [Position.lb, Position.rb, Position.lwb, Position.rwb],
    min: 3,
    target: 4,
    max: 6,
  ),
  AiRosterGroupDefinition(
    group: AiRosterGroup.centralMidfield,
    positions: [Position.cdm, Position.cm],
    min: 4,
    target: 5,
    max: 7,
  ),
  AiRosterGroupDefinition(
    group: AiRosterGroup.cam,
    positions: [Position.cam],
    min: 1,
    target: 2,
    max: 3,
  ),
  AiRosterGroupDefinition(
    group: AiRosterGroup.wings,
    positions: [Position.lw, Position.rw],
    min: 3,
    target: 4,
    max: 6,
  ),
  AiRosterGroupDefinition(
    group: AiRosterGroup.st,
    positions: [Position.st],
    min: 2,
    target: 3,
    max: 4,
  ),
];

const _defaultAiStatusAgeMultipliers = <TeamStatus, List<double>>{
  TeamStatus.rebuild: [1.30, 1.00, 0.70, 0.45],
  TeamStatus.retool: [1.20, 1.05, 0.85, 0.60],
  TeamStatus.pretender: [1.05, 1.10, 1.00, 0.85],
  TeamStatus.contender: [0.95, 1.15, 1.10, 0.95],
  TeamStatus.elite: [0.90, 1.15, 1.15, 1.00],
};

const _defaultAiPickValuePoints = <AiPickValuePoint>[
  AiPickValuePoint(slot: 1, value: 900),
  AiPickValuePoint(slot: 2, value: 780),
  AiPickValuePoint(slot: 3, value: 780),
  AiPickValuePoint(slot: 4, value: 650),
  AiPickValuePoint(slot: 7, value: 650),
  AiPickValuePoint(slot: 8, value: 500),
  AiPickValuePoint(slot: 14, value: 500),
  AiPickValuePoint(slot: 15, value: 380),
  AiPickValuePoint(slot: 22, value: 380),
  AiPickValuePoint(slot: 23, value: 290),
  AiPickValuePoint(slot: 30, value: 290),
  AiPickValuePoint(slot: 31, value: 180),
  AiPickValuePoint(slot: 45, value: 180),
  AiPickValuePoint(slot: 46, value: 120),
  AiPickValuePoint(slot: 60, value: 120),
  AiPickValuePoint(slot: 61, value: 70),
  AiPickValuePoint(slot: 75, value: 70),
  AiPickValuePoint(slot: 76, value: 40),
  AiPickValuePoint(slot: 90, value: 40),
];

const _defaultAiUncertaintyMultipliers = <int, double>{
  1: 1.00,
  2: 0.96,
  3: 0.92,
  4: 0.88,
  5: 0.84,
  6: 0.80,
  7: 0.76,
};

const _defaultAiLotteryExpectedSlots = <int, double>{
  30: 3.5,
  29: 3.8,
  28: 4.1,
  27: 4.6,
  26: 5.2,
  25: 5.9,
  24: 6.7,
  23: 7.6,
  22: 8.5,
  21: 9.4,
};

const _defaultAiPayrollBands = <AiPayrollBand>[
  AiPayrollBand(
    status: TeamStatus.rebuild,
    minCapFraction: 0.60,
    maxCapFraction: 0.85,
    apronPenalty: 0,
  ),
  AiPayrollBand(
    status: TeamStatus.retool,
    minCapFraction: 0.80,
    maxCapFraction: 1.00,
    apronPenalty: 0,
  ),
  AiPayrollBand(
    status: TeamStatus.pretender,
    minCapFraction: 0.92,
    maxCapFraction: 1.05,
    apronPenalty: 40,
  ),
  AiPayrollBand(
    status: TeamStatus.contender,
    minCapFraction: 1.00,
    maxCapFraction: 1.13,
    apronPenalty: 25,
  ),
  AiPayrollBand(
    status: TeamStatus.elite,
    minCapFraction: 1.05,
    maxCapFraction: 1.23,
    apronPenalty: 15,
  ),
];

/// Tunable AI constants from `docs/AI_behaviour.md` §12.
///
/// Task 32 adds the canonical valuation tables here so the evaluator and
/// future AI decision systems share one balance source.
class AiBalance {
  const AiBalance({
    this.teamPowerSquadSize = 15,
    this.statusMaxTierChange = 1,
    this.rosterTargetTotal = 25,
    this.minGapThreshold = 40,
    this.evaluationNoiseSd = 4.0,
    this.pickFutureDiscount = 0.90,
    this.apronPenaltyPretender = 40,
    this.apronPenaltyContender = 25,
    this.apronPenaltyElite = 15,
    this.pSecondApronEntry = 0.20,
    this.pCounterFormation = 0.65,
    this.pTacticalMatchupAdjust = 0.70,
    this.pRoleOverride = 0.45,
    this.staminaReadinessFull = 1.00,
    this.staminaReadinessGood = 0.94,
    this.staminaReadinessMid = 0.82,
    this.staminaReadinessLow = 0.60,
    this.lineupSwapPasses = 2,
    this.formationFitWeight = 0.65,
    this.formationMatchupWeight = 0.35,
    this.counterFormationMinMatches = 2,
    this.pRotationShortRest = 0.80,
    this.pRotationCriticalStamina = 0.95,
    this.rotationInjuryProneThreshold = 7,
    this.pRotationMeaningless = 0.60,
    this.pRotationMajorReturn = 0.70,
    this.pPlayoffBestXi = 0.90,
    this.pSubstitutionStaminaLow = 0.85,
    this.pSubstitutionStaminaCritical = 0.95,
    this.pSubstitutionLowRating = 0.40,
    this.pSubstitutionYellowCard = 0.30,
    this.pSubstitutionTrailingOne = 0.70,
    this.pSubstitutionTrailingTwo = 0.80,
    this.pSubstitutionLeadingOne = 0.55,
    this.pSubstitutionLeadingTwo = 0.60,
    this.pTacticalLateCorrection = 0.50,
    this.sfgAerialAttackThreshold = 68,
    this.sfgShootingThreshold = 82,
    this.sfgStrongValue = 65,
    this.sfgDefaultValue = 50,
    this.sfgAerialDefenseThreshold = 68,
    this.sfgDefenseStrongValue = 60,
    this.tradeAcceptHigh = 0.12,
    this.tradeAcceptLow = 0.04,
    this.tradeHardReject = -0.30,
    this.tradeNeedShift = -8,
    this.tradeLastAtPositionShift = 12,
    this.tradeSameConferenceContenderShift = 10,
    this.tradeTransferRequestShift = -10,
    this.tradeDeadlineNeedShift = -6,
    this.tradeAcceptProbabilityHigh = 0.95,
    this.tradeAcceptProbabilityLow = 0.70,
    this.tradeCounterProbabilityHigh = 0.30,
    this.tradeCounterProbabilityNearFair = 0.60,
    this.tradeCounterProbabilityLow = 0.15,
    this.tradeRejectProbabilityNearFair = 0.40,
    this.tradeRejectProbabilityLow = 0.85,
    this.tradeRejectProbabilityHardBand = 0.70,
    this.tradeHardRejectProbabilityHardBand = 0.30,
    this.tradeCounterTargetRound1 = 10.0,
    this.tradeCounterTargetRound2 = 6.0,
    this.tradeCounterTargetRound3 = 2.0,
    this.tradeHardRejectProbabilityRound1 = 0.0,
    this.tradeHardRejectProbabilityRound2 = 0.15,
    this.tradeHardRejectProbabilityRound3 = 0.35,
    this.tradeMaxCounters = 3,
    this.tradeOfferTarget = 10.0,
    this.tradeOfferMinimum = 2.0,
    this.tradeHardRejectCooldownWeeks = 4,
    this.aiTradeCandidatePairs = 12,
    this.aiTradePackagesPerPair = 6,
    this.aiTradeWeeklyTeamLimit = 2,
    this.tradeFirstRoundLimit = 2,
    this.tradeFirstRoundWindowYears = 3,
    this.tradeDeadlineAppetiteMultiplier = 1.8,
    this.tradeDeadlinePickBump = 10.0,
    this.tradeDumpBurdenMaxNegative = -10.0,
    this.tradeDumpAnchorMaxNegative = -25.0,
    this.tradeDumpToxicMaxNegative = -40.0,
    this.tradeRebuildR1ContractProbability = 0.55,
    this.tradeRebuildR2ContractProbability = 0.35,
    this.tradeRetoolR2ContractProbability = 0.25,
    this.tradeVeteranSaleProbability = 0.45,
    this.tradeNtcPlanningMinConsent = 0.35,
    this.tradeNtcPlanningFallbackConsent = 0.70,
    this.tradeSuperteamStarOverall = 80,
    this.pOfferToUserRegular = 0.020,
    this.pOfferToUserOffseason = 0.045,
    this.pOfferToUserDeadline = 0.050,
    this.userOfferCooldownWeeks = 3,
    this.aiTradePairsPerWeek = 12,
    this.aiTradeMutualMin = 0.02,
    this.aiTradeSeasonLimit = 6,
    this.draftScoreNoiseSd = 3.5,
    this.pDraftTradeUp = 0.08,
    this.scoutCoverageUsage = 1.0,
    this.extTargetOfferScore = 72,
    this.extMaxOfferScore = 85,
    this.extensionCounterRaiseHighProbability = 0.70,
    this.extensionCounterRaiseNormalProbability = 0.35,
    this.faMaxSalaryMult = 1.35,
    this.faCompeteBump = 6,
    this.pFaCompete = 0.55,
    this.faPhaseOneTargetScores = const [
      70,
      70,
      72,
      74,
      74,
      76,
      78,
      80,
      82,
      88,
    ],
    this.faPhaseOneOfferProbabilities = const [
      0.65,
      0.70,
      0.70,
      0.75,
      0.75,
      0.80,
      0.80,
      0.85,
      0.85,
      0.40,
    ],
    this.faPhaseOneFinalHourProbability = 0.40,
    this.faPhaseOneFinalHourUnderRosterProbability = 0.95,
    this.faPhaseTwoTargetScore = 68,
    this.faPhaseTwoWeeklyOfferLimit = 2,
    this.faPhaseTwoNeedThreshold = 20,
    this.faPhaseTwoNeedRosterThreshold = 22,
    this.faRosterRepairSize = 20,
    this.faPositionMaxProbability = 0.05,
    this.faAge33MaxYears = 2,
    this.rfaQualifyingHighProbability = 0.90,
    this.rfaQualifyingDefaultProbability = 0.15,
    this.rfaMatchDepthProbability = 0.45,
    this.rfaMatchSurplusProbability = 0.05,
    this.rfaMatchCostMultiplier = 1.40,
    this.rfaCostScale = 100.0,
    this.staffCapUsageTargetMin = 0.90,
    this.staffCapUsageTargetMax = 1.00,
    this.staffHeadCoachMaxSalary = 5000000,
    this.staffPriorityRoleMinSalary = 2000000,
    this.staffPriorityRoleMaxSalary = 3000000,
    this.staffOtherRoleMinSalary = 500000,
    this.staffOtherRoleMaxSalary = 2000000,
    this.staffTargetOfferScore = 72,
    this.staffMaxOfferScore = 88,
    this.staffRenewalHighProbability = 0.85,
    this.staffRenewalLowProbability = 0.20,
    this.staffRenewalQualityHigh = 2.5,
    this.staffRenewalQualityLow = 1.5,
    this.staffRenewalMaxAge = 57,
    this.staffAge60MaxAge = 60,
    this.staffAge60MaxYears = 1,
    this.pMatchOfferSheetTop11 = 0.85,
    this.contractDragAnchor = 30,
    this.contractDragToxic = 60,
    this.dumpMaxNegativeSurplus = -0.40,
    this.pRebuildAbsorbsContract = 0.55,
    this.ntcMinConsentToPursue = 35,
    this.superteamBrakeThreshold = 12,
    this.rosterGroups = _defaultAiRosterGroups,
    this.statusAgeMultipliers = _defaultAiStatusAgeMultipliers,
    this.pickValuePoints = _defaultAiPickValuePoints,
    this.uncertaintyMultipliers = _defaultAiUncertaintyMultipliers,
    this.lotteryExpectedSlots = _defaultAiLotteryExpectedSlots,
    this.payrollBands = _defaultAiPayrollBands,
    this.transferRequestMult = 0.90,
    this.majorInjuryMult = 0.80,
    this.expiringContractMult = 0.92,
    this.rookieYearOneMult = 1.06,
    this.ntcMult = 0.92,
    this.overpaidContractMult = 0.85,
    this.rightsValueMult = 0.85,
  });

  final int teamPowerSquadSize;
  final int statusMaxTierChange;
  final int rosterTargetTotal;
  final int minGapThreshold;
  final double evaluationNoiseSd;
  final double pickFutureDiscount;

  final int apronPenaltyPretender;
  final int apronPenaltyContender;
  final int apronPenaltyElite;
  final double pSecondApronEntry;

  final double pCounterFormation;
  final double pTacticalMatchupAdjust;
  final double pRoleOverride;

  final double staminaReadinessFull;
  final double staminaReadinessGood;
  final double staminaReadinessMid;
  final double staminaReadinessLow;
  final int lineupSwapPasses;
  final double formationFitWeight;
  final double formationMatchupWeight;
  final int counterFormationMinMatches;

  final double pRotationShortRest;
  final double pRotationCriticalStamina;
  final int rotationInjuryProneThreshold;
  final double pRotationMeaningless;
  final double pRotationMajorReturn;
  final double pPlayoffBestXi;

  final double pSubstitutionStaminaLow;
  final double pSubstitutionStaminaCritical;
  final double pSubstitutionLowRating;
  final double pSubstitutionYellowCard;
  final double pSubstitutionTrailingOne;
  final double pSubstitutionTrailingTwo;
  final double pSubstitutionLeadingOne;
  final double pSubstitutionLeadingTwo;
  final double pTacticalLateCorrection;

  final int sfgAerialAttackThreshold;
  final int sfgShootingThreshold;
  final int sfgStrongValue;
  final int sfgDefaultValue;
  final int sfgAerialDefenseThreshold;
  final int sfgDefenseStrongValue;

  /// Trade acceptance and need-shift values are percentage deltas.
  final double tradeAcceptHigh;
  final double tradeAcceptLow;
  final double tradeHardReject;
  final int tradeNeedShift;
  final double tradeLastAtPositionShift;
  final double tradeSameConferenceContenderShift;
  final double tradeTransferRequestShift;
  final double tradeDeadlineNeedShift;
  final double tradeAcceptProbabilityHigh;
  final double tradeAcceptProbabilityLow;
  final double tradeCounterProbabilityHigh;
  final double tradeCounterProbabilityNearFair;
  final double tradeCounterProbabilityLow;
  final double tradeRejectProbabilityNearFair;
  final double tradeRejectProbabilityLow;
  final double tradeRejectProbabilityHardBand;
  final double tradeHardRejectProbabilityHardBand;
  final double tradeCounterTargetRound1;
  final double tradeCounterTargetRound2;
  final double tradeCounterTargetRound3;
  final double tradeHardRejectProbabilityRound1;
  final double tradeHardRejectProbabilityRound2;
  final double tradeHardRejectProbabilityRound3;
  final int tradeMaxCounters;
  final double tradeOfferTarget;
  final double tradeOfferMinimum;
  final int tradeHardRejectCooldownWeeks;
  final int aiTradeCandidatePairs;
  final int aiTradePackagesPerPair;
  final int aiTradeWeeklyTeamLimit;
  final int tradeFirstRoundLimit;
  final int tradeFirstRoundWindowYears;
  final double tradeDeadlineAppetiteMultiplier;
  final double tradeDeadlinePickBump;
  final double tradeDumpBurdenMaxNegative;
  final double tradeDumpAnchorMaxNegative;
  final double tradeDumpToxicMaxNegative;
  final double tradeRebuildR1ContractProbability;
  final double tradeRebuildR2ContractProbability;
  final double tradeRetoolR2ContractProbability;
  final double tradeVeteranSaleProbability;
  final double tradeNtcPlanningMinConsent;
  final double tradeNtcPlanningFallbackConsent;
  final int tradeSuperteamStarOverall;

  final double pOfferToUserRegular;
  final double pOfferToUserOffseason;
  final double pOfferToUserDeadline;
  final int userOfferCooldownWeeks;

  final int aiTradePairsPerWeek;
  final double aiTradeMutualMin;
  final int aiTradeSeasonLimit;

  final double draftScoreNoiseSd;
  final double pDraftTradeUp;
  final double scoutCoverageUsage;

  final int extTargetOfferScore;
  final int extMaxOfferScore;
  final double extensionCounterRaiseHighProbability;
  final double extensionCounterRaiseNormalProbability;
  final double faMaxSalaryMult;
  final int faCompeteBump;
  final double pFaCompete;
  final List<int> faPhaseOneTargetScores;
  final List<double> faPhaseOneOfferProbabilities;
  final double faPhaseOneFinalHourProbability;
  final double faPhaseOneFinalHourUnderRosterProbability;
  final int faPhaseTwoTargetScore;
  final int faPhaseTwoWeeklyOfferLimit;
  final double faPhaseTwoNeedThreshold;
  final int faPhaseTwoNeedRosterThreshold;
  final int faRosterRepairSize;
  final double faPositionMaxProbability;
  final int faAge33MaxYears;
  final double rfaQualifyingHighProbability;
  final double rfaQualifyingDefaultProbability;
  final double rfaMatchDepthProbability;
  final double rfaMatchSurplusProbability;
  final double rfaMatchCostMultiplier;
  final double rfaCostScale;

  /// The documentation specifies a 90–100% target range.
  final double staffCapUsageTargetMin;
  final double staffCapUsageTargetMax;
  final int staffHeadCoachMaxSalary;
  final int staffPriorityRoleMinSalary;
  final int staffPriorityRoleMaxSalary;
  final int staffOtherRoleMinSalary;
  final int staffOtherRoleMaxSalary;
  final int staffTargetOfferScore;
  final int staffMaxOfferScore;
  final double staffRenewalHighProbability;
  final double staffRenewalLowProbability;
  final double staffRenewalQualityHigh;
  final double staffRenewalQualityLow;
  final int staffRenewalMaxAge;
  final int staffAge60MaxAge;
  final int staffAge60MaxYears;

  final double pMatchOfferSheetTop11;
  final int contractDragAnchor;
  final int contractDragToxic;
  final double dumpMaxNegativeSurplus;
  final double pRebuildAbsorbsContract;
  final int ntcMinConsentToPursue;
  final int superteamBrakeThreshold;

  final List<AiRosterGroupDefinition> rosterGroups;
  final Map<TeamStatus, List<double>> statusAgeMultipliers;
  final List<AiPickValuePoint> pickValuePoints;
  final Map<int, double> uncertaintyMultipliers;
  final Map<int, double> lotteryExpectedSlots;
  final List<AiPayrollBand> payrollBands;

  final double transferRequestMult;
  final double majorInjuryMult;
  final double expiringContractMult;
  final double rookieYearOneMult;
  final double ntcMult;
  final double overpaidContractMult;
  final double rightsValueMult;

  AiRosterGroupDefinition definitionFor(AiRosterGroup group) =>
      rosterGroups.firstWhere((definition) => definition.group == group);

  double statusAgeMultiplier(TeamStatus status, int age) {
    final band = age <= 23
        ? 0
        : age <= 29
        ? 1
        : age <= 32
        ? 2
        : 3;
    return (statusAgeMultipliers[status] ?? const [1.0, 1.0, 1.0, 1.0])[band];
  }

  double needMultiplier(AiPositionNeed need) => switch (need.band) {
    AiNeedBand.critical => 1.18,
    AiNeedBand.belowTarget => 1.08,
    AiNeedBand.target => 1.00,
    AiNeedBand.surplus => 0.88,
  };

  AiPayrollBand payrollBandFor(TeamStatus status) => payrollBands.firstWhere(
    (band) => band.status == status,
    orElse: () => const AiPayrollBand(
      status: TeamStatus.pretender,
      minCapFraction: 0.92,
      maxCapFraction: 1.05,
      apronPenalty: 40,
    ),
  );

  int apronPenaltyFor(TeamStatus status) => switch (status) {
    TeamStatus.pretender => apronPenaltyPretender,
    TeamStatus.contender => apronPenaltyContender,
    TeamStatus.elite => apronPenaltyElite,
    TeamStatus.rebuild || TeamStatus.retool => 0,
  };

  /// Linearly interpolates between the documented slot anchors.
  double pickValueForSlot(double slot) {
    if (pickValuePoints.isEmpty) return 0;
    if (slot <= pickValuePoints.first.slot) return pickValuePoints.first.value;
    if (slot >= pickValuePoints.last.slot) return pickValuePoints.last.value;
    for (var i = 1; i < pickValuePoints.length; i++) {
      final high = pickValuePoints[i];
      final low = pickValuePoints[i - 1];
      if (slot <= high.slot) {
        final fraction = (slot - low.slot) / (high.slot - low.slot);
        return low.value + (high.value - low.value) * fraction;
      }
    }
    return pickValuePoints.last.value;
  }

  double uncertaintyFor(int yearsAhead) =>
      uncertaintyMultipliers[yearsAhead.clamp(1, 7)] ??
      uncertaintyMultipliers[7] ??
      0.76;
}
