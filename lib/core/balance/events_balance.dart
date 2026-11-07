import 'package:new_football/core/models/enums.dart';

/// Activation thresholds and roll probabilities from the team/player event
/// sections of `docs/team_management.md` and `docs/player_management.md`.
///
/// Consumed by the player/team event services and their persisted state.
class EventsBalance {
  static const defaultPromiseWeeks = 4;
  static const defaultPromiseMinutesShare = 0.40;
  static const defaultTransferSituationWeeks = 4;

  const EventsBalance({
    this.moreMinutesYoungAgeMax = 26,
    this.moreMinutesCooldownWeeks = 1,
    this.transferRequestCooldownWeeks = 1,
    this.dressingRoomConflictCooldownWeeks = 1,
    this.publicCriticismCandidates = 15,
    this.publicCriticismAgeMinExclusive = 25,
    this.aiMoreMinutesPriorityPlayers = 14,
    this.transferValueTopShare = 0.20,
    this.postPlayoffCandidates = 11,
    this.postPlayoffExpectedRounds = const {
      TeamStatus.elite: 3,
      TeamStatus.contender: 2,
      TeamStatus.pretender: 1,
    },
    this.futureUfaYearsMax = 1,
    this.minutesHistoryWeeks = 6,
    this.moreMinutesAcceptAtmosphere = -3,
    this.moreMinutesDeclineAtmosphere = -7,
    this.moreMinutesPersonalityPenalty = 3,
    this.transferAcceptAtmosphere = 3,
    this.transferPointValueMultiplier = 0.9,
    this.transferDeclineEffect = (-6, -2.0),
    this.transferExpiredEffect = (-15, -4.0),
    this.conflictInterveneSuccessChance = 0.5,
    this.conflictSuccessEffect = (2, -2.0),
    this.conflictFailureEffect = (-3, -2.0),
    this.conflictIgnoreEffect = (-3, -2.0),
    this.conflictNegativeEventBonus = 0.2,
    this.leaderSupportEffect = (4, 1.0),
    this.criticismPunishEffect = (-2, -2.0),
    this.criticismResponseEffect = (-1, -1.0),
    this.criticismIgnoreEffect = (-1, -1.0),
    this.promiseFulfilledAtmosphere = 5,
    this.promiseBrokenAtmosphere = -12,
    this.promiseBrokenPersonalityPenalty = 3,
    this.negativeEventMultiplierMin = 0.5,
    this.negativeEventMultiplierMax = 2.0,
    this.pointValueMultiplierMin = 0.5,
    this.pointValueMultiplierMax = 1.0,
    this.veteranMotivationAgeMin = 32,
    this.veteranMotivationSeasonsMin = 4,
    this.veteranMentorTargetAgeMax = 23,
    this.veteranMotivationCooldownWeeks = 4,
    this.veteranMotivationIgnoreFormPenalty = 1.0,
    this.extraTrainingDeterminationMin = 7,
    this.extraTrainingFormMin = 6.0,
    this.extraTrainingDeclineFormPenalty = 1.0,
    this.extraTrainingWeeksPerMonth = 4,
    this.coldStreakCooldownWeeks = 1,
    this.injuryComplicationCooldownWeeks = 52,
    this.cautiousRecurrenceCooldownWeeks = 52,
    this.recurrenceDaysMin = 1,
    this.recurringInjuryLookbackWeeks = 52,
    this.recurringInjuryProneMin = 7,
    this.coldStreakDecisionDays = 1,
    this.injuryComplicationDecisionDays = 1,
    this.veteranMotivationDecisionDays = 2,
    this.extraTrainingDecisionDays = 1,
    this.plateauDecisionDays = 2,
    this.personalSupportDecisionDays = 3,
    this.inspiringPerformanceFormBonus = 1.0,
    this.inspiringPerformanceProgressBonus = 5.0,
    this.minutesRequestChance = 0.03,
    this.minutesRequestAmbitiousChance = 0.05,
    this.transferRequestChance = 0.01,
    this.transferRequestAmbitiousMultiplier = 2.0,
    this.lowAtmosphereThreshold = 40,
    this.lowAtmosphereWeeks = 4,
    this.lockerRoomConflictPlayers = 2,
    this.lockerRoomConflictChance = 0.05,
    this.leaderSupportWinStreak = 3,
    this.leaderSupportChance = 0.15,
    this.leaderSupportCooldownMonths = 1,
    this.publicCriticismAtmosphereThreshold = 30,
    this.publicCriticismChance = 0.08,
    this.moreMinutesLowShareThreshold = 0.25,
    this.moreMinutesPromiseShare = defaultPromiseMinutesShare,
    this.moreMinutesPromiseWeeks = defaultPromiseWeeks,
    this.moreMinutesPromiseMatchScoreBonus = 0.08,
    this.transferSituationWeeks = defaultTransferSituationWeeks,
    this.transferTradeAppetiteMultiplier = 3.0,
    this.transferTradeSurplusShift = -8.0,
    this.aiMoreMinutesTopFourteenAcceptChance = 0.75,
    this.aiMoreMinutesDepthAcceptChance = 0.35,
    this.aiTransferRequestAcceptChance = 0.60,
    this.aiTransferRequestOtherAcceptChance = 0.30,
    this.aiTransferRequestIIAcceptChance = 0.70,
    this.aiDressingRoomInterveneChance = 0.60,
    this.aiPublicCriticismPunishChance = 0.45,
    this.aiPublicCriticismResponseCutoff = 0.80,
    this.aiPlateauAcceptChance = 0.70,
    this.aiColdStreakAcceptChance = 0.65,
    this.aiInjuryComplicationCautiousChance = 0.75,
    this.aiVeteranMentorChance = 0.80,
    this.aiExtraTrainingAcceptChance = 0.60,
    this.aiExtraTrainingPlayoffAcceptChance = 0.30,
    this.aiPersonalSupportAcceptChance = 0.85,
    this.transferRequestIChance = 0.01,
    this.transferRequestIIChanceAfterBrokenPromise = 0.20,
    this.dressingRoomConflictPenaltyWeeks = 2,
    this.leaderSupportCooldownWeeks = 4,
    this.publicCriticismPunishRollMultiplier = 0.5,
    this.publicCriticismIgnoreRollMultiplier = 1.5,
    this.teamEventDecisionExpiryDays = 1,
    this.breakthroughAgeMax = 26,
    this.breakthroughProgressMin = 70,
    this.breakthroughFormMin = 8,
    this.breakthroughFormWeeks = 4,
    this.breakthroughChance = 0.08,
    this.breakthroughGrowthRateBonus = 0.3,
    this.breakthroughDurationWeeks = 6,
    this.breakthroughCooldownSeasons = 1,
    this.coldStreakFormMax = 3,
    this.coldStreakWeeks = 3,
    this.coldStreakChance = 0.12,
    this.coldStreakAcceptRecoveryChance = 0.60,
    this.coldStreakAcceptFormBonus = 2.0,
    this.coldStreakDeclineFormFloor = 2.0,
    this.coldStreakDeclineFormFloorWeeks = 2,
    this.coldStreakDeclineGrowthPenalty = -0.1,
    this.coldStreakDeclineGrowthPenaltyWeeks = 4,
    this.coldStreakLineupRestrictionWeeks = 1,
    this.majorInjuryComplicationChance = 0.15,
    this.injuryComplicationCautiousExtraDaysMin = 7,
    this.injuryComplicationCautiousExtraDaysMax = 14,
    this.injuryComplicationFullRecurrenceChance = 0.25,
    this.injuryComplicationFullRecurrenceFractionMin = 0.30,
    this.injuryComplicationFullRecurrenceFractionMax = 0.50,
    this.veteranMotivationChance = 0.05,
    this.veteranMotivationGrowthPenalty = -0.2,
    this.veteranMotivationDurationWeeks = 4,
    this.veteranMentorDeterminationMin = 6,
    this.veteranMentorGrowthBonus = 0.1,
    this.veteranMentorDurationWeeks = 4,
    this.extraTrainingChance = 0.04,
    this.extraTrainingCooldownMonths = 3,
    this.extraTrainingGrowthRateBonus = 0.2,
    this.extraTrainingDurationWeeks = 4,
    this.extraTrainingStaminaPenalty = 5,
    this.extraTrainingInjuryRiskMultiplier = 1.15,
    this.personalProblemsChance = 0.005,
    this.professionalPersonalProblemsChance = 0.002,
    this.personalProblemsFormPenalty = -2.0,
    this.personalProblemsGrowthPenalty = -0.15,
    this.personalProblemsDurationWeeks = 3,
    this.personalSupportChance = 0.20,
    this.personalSupportDurationWeeks = 1,
    this.lateBloomerAgeMin = 22,
    this.lateBloomerAgeMax = 26,
    this.lateBloomerProgressMax = 30,
    this.lateBloomerChance = 0.03,
    this.lateBloomerAttributeBonus = 2,
    this.recurringInjuryChance = 0.03,
    this.recurringInjuryCooldownMonths = 12,
    this.nationalTeamFormBonus = 1.0,
    this.nationalTeamStaminaPenalty = 15,
    this.plateauWeeks = 8,
    this.plateauChance = 0.20,
    this.plateauGrowthRateBonus = 0.15,
    this.plateauGrowthRateDurationWeeks = 4,
    this.inspiringPerformanceRatingMin = 8.0,
    this.inspiringPerformanceChance = 0.03,
    this.majorInjuryPotentialLossChance = 0.10,
  });

  final double minutesRequestChance;
  final int moreMinutesYoungAgeMax;
  final int moreMinutesCooldownWeeks;
  final int transferRequestCooldownWeeks;
  final int dressingRoomConflictCooldownWeeks;
  final int publicCriticismCandidates;
  final int publicCriticismAgeMinExclusive;
  final int aiMoreMinutesPriorityPlayers;
  final double transferValueTopShare;
  final int postPlayoffCandidates;
  final Map<TeamStatus, int> postPlayoffExpectedRounds;
  final int futureUfaYearsMax;
  final int minutesHistoryWeeks;
  final int moreMinutesAcceptAtmosphere;
  final int moreMinutesDeclineAtmosphere;
  final int moreMinutesPersonalityPenalty;
  final int transferAcceptAtmosphere;
  final double transferPointValueMultiplier;
  final (int atmosphere, double chemistry) transferDeclineEffect;
  final (int atmosphere, double chemistry) transferExpiredEffect;
  final double conflictInterveneSuccessChance;
  final (int atmosphere, double chemistry) conflictSuccessEffect;
  final (int atmosphere, double chemistry) conflictFailureEffect;
  final (int atmosphere, double chemistry) conflictIgnoreEffect;
  final double conflictNegativeEventBonus;
  final (int atmosphere, double chemistry) leaderSupportEffect;
  final (int atmosphere, double chemistry) criticismPunishEffect;
  final (int atmosphere, double chemistry) criticismResponseEffect;
  final (int atmosphere, double chemistry) criticismIgnoreEffect;
  final int promiseFulfilledAtmosphere;
  final int promiseBrokenAtmosphere;
  final int promiseBrokenPersonalityPenalty;
  final double negativeEventMultiplierMin;
  final double negativeEventMultiplierMax;
  final double pointValueMultiplierMin;
  final double pointValueMultiplierMax;
  final int veteranMotivationAgeMin;
  final int veteranMotivationSeasonsMin;
  final int veteranMentorTargetAgeMax;
  final int veteranMotivationCooldownWeeks;
  final double veteranMotivationIgnoreFormPenalty;
  final int extraTrainingDeterminationMin;
  final double extraTrainingFormMin;
  final double extraTrainingDeclineFormPenalty;
  final int extraTrainingWeeksPerMonth;
  final int coldStreakCooldownWeeks;
  final int injuryComplicationCooldownWeeks;
  final int cautiousRecurrenceCooldownWeeks;
  final int recurrenceDaysMin;
  final int recurringInjuryLookbackWeeks;
  final int recurringInjuryProneMin;
  final int coldStreakDecisionDays;
  final int injuryComplicationDecisionDays;
  final int veteranMotivationDecisionDays;
  final int extraTrainingDecisionDays;
  final int plateauDecisionDays;
  final int personalSupportDecisionDays;
  final double inspiringPerformanceFormBonus;
  final double inspiringPerformanceProgressBonus;
  final double minutesRequestAmbitiousChance;
  final double transferRequestChance;
  final double transferRequestAmbitiousMultiplier;
  final int lowAtmosphereThreshold;
  final int lowAtmosphereWeeks;
  final int lockerRoomConflictPlayers;
  final double lockerRoomConflictChance;
  final int leaderSupportWinStreak;
  final double leaderSupportChance;
  final int leaderSupportCooldownMonths;
  final int publicCriticismAtmosphereThreshold;
  final double publicCriticismChance;
  final double moreMinutesLowShareThreshold;
  final double moreMinutesPromiseShare;
  final int moreMinutesPromiseWeeks;
  final double moreMinutesPromiseMatchScoreBonus;
  final int transferSituationWeeks;
  final double transferTradeAppetiteMultiplier;
  final double transferTradeSurplusShift;

  /// AI choices from `docs/AI_behaviour.md` §10.
  final double aiMoreMinutesTopFourteenAcceptChance;
  final double aiMoreMinutesDepthAcceptChance;
  final double aiTransferRequestAcceptChance;
  final double aiTransferRequestOtherAcceptChance;
  final double aiTransferRequestIIAcceptChance;
  final double aiDressingRoomInterveneChance;
  final double aiPublicCriticismPunishChance;
  final double aiPublicCriticismResponseCutoff;
  final double aiPlateauAcceptChance;
  final double aiColdStreakAcceptChance;
  final double aiInjuryComplicationCautiousChance;
  final double aiVeteranMentorChance;
  final double aiExtraTrainingAcceptChance;
  final double aiExtraTrainingPlayoffAcceptChance;
  final double aiPersonalSupportAcceptChance;

  final double transferRequestIChance;
  final double transferRequestIIChanceAfterBrokenPromise;
  final int dressingRoomConflictPenaltyWeeks;
  final int leaderSupportCooldownWeeks;
  final double publicCriticismPunishRollMultiplier;
  final double publicCriticismIgnoreRollMultiplier;
  final int teamEventDecisionExpiryDays;

  final int breakthroughAgeMax;
  final int breakthroughProgressMin;
  final int breakthroughFormMin;
  final int breakthroughFormWeeks;
  final double breakthroughChance;
  final double breakthroughGrowthRateBonus;
  final int breakthroughDurationWeeks;
  final int breakthroughCooldownSeasons;

  final int coldStreakFormMax;
  final int coldStreakWeeks;
  final double coldStreakChance;
  final double coldStreakAcceptRecoveryChance;
  final double coldStreakAcceptFormBonus;
  final double coldStreakDeclineFormFloor;
  final int coldStreakDeclineFormFloorWeeks;
  final double coldStreakDeclineGrowthPenalty;
  final int coldStreakDeclineGrowthPenaltyWeeks;
  final int coldStreakLineupRestrictionWeeks;

  final double majorInjuryComplicationChance;
  final int injuryComplicationCautiousExtraDaysMin;
  final int injuryComplicationCautiousExtraDaysMax;
  final double injuryComplicationFullRecurrenceChance;
  final double injuryComplicationFullRecurrenceFractionMin;
  final double injuryComplicationFullRecurrenceFractionMax;

  final double veteranMotivationChance;
  final double veteranMotivationGrowthPenalty;
  final int veteranMotivationDurationWeeks;
  final int veteranMentorDeterminationMin;
  final double veteranMentorGrowthBonus;
  final int veteranMentorDurationWeeks;

  final double extraTrainingChance;
  final int extraTrainingCooldownMonths;
  final double extraTrainingGrowthRateBonus;
  final int extraTrainingDurationWeeks;
  final int extraTrainingStaminaPenalty;
  final double extraTrainingInjuryRiskMultiplier;

  final double personalProblemsChance;
  final double professionalPersonalProblemsChance;
  final double personalProblemsFormPenalty;
  final double personalProblemsGrowthPenalty;
  final int personalProblemsDurationWeeks;
  final double personalSupportChance;
  final int personalSupportDurationWeeks;

  final int lateBloomerAgeMin;
  final int lateBloomerAgeMax;
  final int lateBloomerProgressMax;
  final double lateBloomerChance;
  final int lateBloomerAttributeBonus;

  final double recurringInjuryChance;
  final int recurringInjuryCooldownMonths;
  final double nationalTeamFormBonus;
  final int nationalTeamStaminaPenalty;

  final int plateauWeeks;
  final double plateauChance;
  final double plateauGrowthRateBonus;
  final int plateauGrowthRateDurationWeeks;

  final double inspiringPerformanceRatingMin;
  final double inspiringPerformanceChance;
  final double majorInjuryPotentialLossChance;
}
