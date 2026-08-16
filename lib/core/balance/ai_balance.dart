/// Tunable AI constants from `docs/AI_behaviour.md` §12.
///
/// These values are exposed for the AI implementation tasks. Existing AI
/// behavior is intentionally not rewired as part of the balance skeleton.
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
}
