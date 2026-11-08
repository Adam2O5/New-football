import 'package:new_football/core/models/enums.dart';

class ContractNegBalance {
  const ContractNegBalance({
    this.offerScoreMin = 0.0,
    this.offerScoreMax = 100.0,
    this.playerMinYears = 1,
    this.qualifyingOfferYears = 1,
    this.playerMaxYears = 5,
    this.wantMin = 0.0,
    this.wantMax = 100.0,
    this.wantNormalization = 100.0,
    this.playerWantOffset = 1000,
    this.playerWantDivisor = 20.0,
    this.playerPersonalityWant = const {
      PlayerPersonality.ambitious: 5,
      PlayerPersonality.temperamental: 4,
      PlayerPersonality.leader: 1,
      PlayerPersonality.balanced: 0,
      PlayerPersonality.professional: -2,
      PlayerPersonality.loyal: -4,
    },
    this.playerSalaryExponent = 3,
    this.lengthWantThresholds = const [39.0, 69.0],
    this.playerLengthTable = const [
      (23, [2, 3, 4]),
      (29, [2, 3, 5]),
      (32, [1, 2, 3]),
      (null, [1, 1, 2]),
    ],
    this.ntcAgeMin = 30,
    this.ntcSeasonsMin = 4,
    this.ntcPointValueMin = 200,
    this.ntcYearsMin = 2,
    this.ntcSigningChance = 0.20,
    this.ntcConsentBase = 0.55,
    this.ntcHigherStatusBonus = 0.20,
    this.ntcLowerStatusPenalty = 0.15,
    this.ntcTransferRequestBonus = 0.30,
    this.ntcLoyalPenalty = 0.15,
    this.ntcAmbitiousBetterRankBonus = 0.10,
    this.ntcLowAtmosphereThreshold = 40,
    this.ntcLowAtmosphereBonus = 0.10,
    this.ntcConsentMin = 0.10,
    this.ntcConsentMax = 0.95,
    this.aiCounterOriginalSalaryFactor = 0.90,
    this.cfoMultipliers = const [
      0.95,
      1.00,
      1.01,
      1.02,
      1.04,
      1.05,
      1.07,
      1.08,
      1.10,
      1.11,
      1.13,
    ],
    this.cfoStepsPerStar = 2.0,
    this.teamStatusBonuses = const {
      TeamStatus.rebuild: -5,
      TeamStatus.retool: -3,
      TeamStatus.pretender: 0,
      TeamStatus.contender: 5,
      TeamStatus.elite: 7,
    },
    this.hoursPerDay = 10,

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
    this.tradePairBlockDays = 30,
    this.ntcTradeBlockDays = 30,

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
    // Active waiting clocks, separate from finalization windows above.
    this.playerWaitingHours = 3,
    this.staffWaitingHours = 3,
  });

  final int hoursPerDay;
  final double offerScoreMin;
  final double offerScoreMax;
  final int playerMinYears;
  final int qualifyingOfferYears;
  final int playerMaxYears;
  final double wantMin;
  final double wantMax;
  final double wantNormalization;
  final int playerWantOffset;
  final double playerWantDivisor;
  final Map<PlayerPersonality, int> playerPersonalityWant;
  final int playerSalaryExponent;
  final List<double> lengthWantThresholds;
  final List<(int? ageMax, List<int> years)> playerLengthTable;
  final int ntcAgeMin;
  final int ntcSeasonsMin;
  final int ntcPointValueMin;
  final int ntcYearsMin;
  final double ntcSigningChance;
  final double ntcConsentBase;
  final double ntcHigherStatusBonus;
  final double ntcLowerStatusPenalty;
  final double ntcTransferRequestBonus;
  final double ntcLoyalPenalty;
  final double ntcAmbitiousBetterRankBonus;
  final int ntcLowAtmosphereThreshold;
  final double ntcLowAtmosphereBonus;
  final double ntcConsentMin;
  final double ntcConsentMax;
  final double aiCounterOriginalSalaryFactor;

  int lengthWantBand(double want) {
    final index = lengthWantThresholds.indexWhere(
      (threshold) => want <= threshold,
    );
    return index < 0 ? lengthWantThresholds.length : index;
  }

  int playerLengthFor(int age, double want) {
    final row = playerLengthTable.firstWhere(
      (row) => row.$1 == null || age <= row.$1!,
      orElse: () => playerLengthTable.last,
    );
    return row.$2[lengthWantBand(want)];
  }

  final List<double> cfoMultipliers;
  final double cfoStepsPerStar;
  final Map<TeamStatus, int> teamStatusBonuses;
  final int tradePairBlockDays;
  final int ntcTradeBlockDays;

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
  // Active waiting clocks for the persistent negotiation lifecycle.
  final int playerWaitingHours;
  final int staffWaitingHours;
}
