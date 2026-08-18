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
    this.tradeAcceptHigh = 0.12,
    this.tradeAcceptLow = 0.04,
    this.tradeHardReject = -0.30,
    this.tradeNeedShift = -8,
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
    this.faMaxSalaryMult = 1.35,
    this.faCompeteBump = 6,
    this.pFaCompete = 0.55,
    this.staffCapUsageTargetMin = 0.90,
    this.staffCapUsageTargetMax = 1.00,
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

  /// Trade acceptance and need-shift values are percentage deltas.
  final double tradeAcceptHigh;
  final double tradeAcceptLow;
  final double tradeHardReject;
  final int tradeNeedShift;

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
  final double faMaxSalaryMult;
  final int faCompeteBump;
  final double pFaCompete;

  /// The documentation specifies a 90–100% target range.
  final double staffCapUsageTargetMin;
  final double staffCapUsageTargetMax;

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
