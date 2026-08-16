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
    this.coldStreakFormMax = 3,
    this.coldStreakWeeks = 3,
    this.coldStreakChance = 0.12,
    this.majorInjuryComplicationChance = 0.15,
    this.veteranMotivationChance = 0.05,
    this.extraTrainingChance = 0.04,
    this.extraTrainingCooldownMonths = 3,
    this.personalProblemsChance = 0.005,
    this.professionalPersonalProblemsChance = 0.002,
    this.lateBloomerChance = 0.03,
    this.recurringInjuryChance = 0.03,
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
  final int coldStreakFormMax;
  final int coldStreakWeeks;
  final double coldStreakChance;
  final double majorInjuryComplicationChance;
  final double veteranMotivationChance;
  final double extraTrainingChance;
  final int extraTrainingCooldownMonths;
  final double personalProblemsChance;
  final double professionalPersonalProblemsChance;
  final double lateBloomerChance;
  final double recurringInjuryChance;
  final double inspiringPerformanceRatingMin;
  final double inspiringPerformanceChance;
  final double majorInjuryPotentialLossChance;
}
