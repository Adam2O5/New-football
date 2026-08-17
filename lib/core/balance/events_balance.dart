/// Activation thresholds and roll probabilities from the team/player event
/// sections of `docs/team_management.md` and `docs/player_management.md`.
///
/// This is a declaration-only balance surface for now. Event services will
/// consume these fields in the later event implementation tasks.
class EventsBalance {
  const EventsBalance({
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
    this.plateauGrowthRateBonus = 0.15,
    this.plateauGrowthRateDurationWeeks = 4,
    this.inspiringPerformanceRatingMin = 8.0,
    this.inspiringPerformanceChance = 0.03,
    this.majorInjuryPotentialLossChance = 0.10,
  });

  final double minutesRequestChance;
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
  final double plateauGrowthRateBonus;
  final int plateauGrowthRateDurationWeeks;

  final double inspiringPerformanceRatingMin;
  final double inspiringPerformanceChance;
  final double majorInjuryPotentialLossChance;
}
