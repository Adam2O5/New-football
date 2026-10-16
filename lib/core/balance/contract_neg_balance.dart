class ContractNegBalance {
  const ContractNegBalance({
    this.hoursPerDay = 10,
    this.offersPerHour = 1,

    // Canonical, non-overlapping offer-score bands (contracts.md §6–7).
    this.hardRejectScoreMax = 24,
    this.rejectScoreMax = 39,
    this.counterScoreMax = 54,
    this.mixedScoreMax = 69,
    this.acceptScoreMin = 70,
    this.mixedScoreMidpoint = 62,
    this.mixedAcceptProbabilityAtMidpoint = 0.5,
    this.mixedAcceptSlope = 0.03,

    // Offer-score components.
    this.salaryFitBase = 35,
    this.salaryBelowPenaltyPerPct = 2,
    this.salaryAboveBonusPerPct = 1,
    this.lengthFitBase = 15,
    this.lengthPenaltyPerYear = 5,

    // Three counter-offer rounds and their target score ranges.
    this.maxCounterRounds = 3,
    this.counterTargetScoreFirst = 82,
    this.counterTargetScoreSecond = 75,
    this.counterTargetScoreThird = 65,
    this.counterHardRejectChanceFirst = 0.15,
    this.counterHardRejectChanceSecond = 0.30,
    this.counterHardRejectChanceThird = 0.50,

    // Persistent negotiation windows.
    this.negotiationBlockDays = 30,
    this.phaseIFinalizationHours = 3,
    this.phaseIIFinalizationDays = 3,
    this.extensionFinalizationDays = 1,

    // Whole-season extension minutes rule.
    this.extensionMinutesMinimumPossibleMinutes = 1000,
    this.extensionMinutesHighOvr = 87,
    this.extensionMinutesMidOvr = 80,
    this.extensionMinutesLowOvr = 75,
    this.extensionMinutesMinimumOvr = 70,
    this.extensionMinutesHighRequiredShare = 0.65,
    this.extensionMinutesMidRequiredShare = 0.50,
    this.extensionMinutesLowRequiredShare = 0.35,
    this.extensionMinutesMinimumRequiredShare = 0.20,

    // Legacy knobs retained for compatibility with older balance callers.
    this.playerAcceptGap = 6,
    this.playerHardRejectGap = -14,
    this.playerNoiseAbs = 3,
    this.playerTemperamentalNoiseAbs = 5,
    this.staffAcceptGap = 5,
    this.staffHardRejectGap = -12,
    this.staffNoiseAbs = 2,
    this.playerWaitingHours = 3,
    this.staffWaitingHours = 2,
  });

  final int hoursPerDay;
  final int offersPerHour;

  final int hardRejectScoreMax;
  final int rejectScoreMax;
  final int counterScoreMax;
  final int mixedScoreMax;
  final int acceptScoreMin;
  final double mixedScoreMidpoint;
  final double mixedAcceptProbabilityAtMidpoint;
  final double mixedAcceptSlope;

  final double salaryFitBase;
  final double salaryBelowPenaltyPerPct;
  final double salaryAboveBonusPerPct;
  final double lengthFitBase;
  final double lengthPenaltyPerYear;

  final int maxCounterRounds;
  final double counterTargetScoreFirst;
  final double counterTargetScoreSecond;
  final double counterTargetScoreThird;
  final double counterHardRejectChanceFirst;
  final double counterHardRejectChanceSecond;
  final double counterHardRejectChanceThird;

  final int negotiationBlockDays;
  final int phaseIFinalizationHours;
  final int phaseIIFinalizationDays;
  final int extensionFinalizationDays;

  final int extensionMinutesMinimumPossibleMinutes;
  final double extensionMinutesHighOvr;
  final double extensionMinutesMidOvr;
  final double extensionMinutesLowOvr;
  final double extensionMinutesMinimumOvr;
  final double extensionMinutesHighRequiredShare;
  final double extensionMinutesMidRequiredShare;
  final double extensionMinutesLowRequiredShare;
  final double extensionMinutesMinimumRequiredShare;

  // Compatibility fields for code written against the pre-Task-28 balance.
  final int playerAcceptGap;
  final int playerHardRejectGap;
  final int playerNoiseAbs;
  final int playerTemperamentalNoiseAbs;
  final int staffAcceptGap;
  final int staffHardRejectGap;
  final int staffNoiseAbs;
  final int playerWaitingHours;
  final int staffWaitingHours;
}
