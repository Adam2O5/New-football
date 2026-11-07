import 'package:new_football/core/models/enums.dart';

class RosterBalance {
  static const defaultSeedSize = 26;
  const RosterBalance({
    this.minSize = 20,
    this.maxSize = 30,
    this.seedSize = defaultSeedSize,
    this.startingXi = 11,
    this.benchSize = 7,
  });

  final int minSize;
  final int maxSize;
  final int seedSize;
  final int startingXi;
  final int benchSize;

  int get matchdaySquadSize => startingXi + benchSize;
}

class CalendarBalance {
  static const winPoints = 3;
  static const drawPoints = 1;
  const CalendarBalance({
    this.scoutingMonthlyFirstWeek = 5,
    this.scoutingMonthlyIntervalWeeks = 4,
    this.scoutingMonthlyDay = 1,
    this.strengthRefreshFirstWeek = 5,
    this.strengthRefreshIntervalWeeks = 4,
    this.strengthRefreshDay = 1,
    this.strengthAwardsRefreshDay = 2,
    this.regularSeasonWeeks = 29,
    this.tradeDeadlineWeek = 23,
    this.playInWeek = 31,
    this.playoffStartWeek = 32,
    this.playoffEndWeek = 43,
    this.awardsWeek = 44,
    this.draftWeek = 46,
    this.freeAgencyWeek = 47,
    this.freeAgencyPhaseIIEndWeek = 45,
    this.tradeWindowOpenWeek = 44,
    this.breakWeek = 30,
    this.seasonCycleWeeks = 52,
    this.seasonStartMonth = 8,
    this.awardsDay = 1,
    this.staffGrowthDay = 2,
    this.retirementsDay = 3,
    this.lotteryDay = 5,
    this.scoutWeekOffset = 1,
    this.scoutReportDay = 1,
    this.combineDay = 3,
    this.finalMockDay = 5,
    this.draftDay = 1,
    this.tradeWindowOpenDay = 1,
    this.tradeDeadlineDay = 1,
    this.freeAgencyOpenDay = 1,
    this.contractExtensionStartDay = 2,
  });

  final int regularSeasonWeeks;
  final int scoutingMonthlyFirstWeek;
  final int scoutingMonthlyIntervalWeeks;
  final int scoutingMonthlyDay;
  final int strengthRefreshFirstWeek;
  final int strengthRefreshIntervalWeeks;
  final int strengthRefreshDay;
  final int strengthAwardsRefreshDay;
  final int tradeDeadlineWeek;
  final int playInWeek;
  final int playoffStartWeek;
  final int playoffEndWeek;
  final int awardsWeek;
  final int draftWeek;
  final int freeAgencyWeek;
  final int freeAgencyPhaseIIEndWeek;

  /// First week of open trade window after playoffs.
  final int tradeWindowOpenWeek;

  /// The regular calendar has one explicit break week before play-in.
  final int breakWeek;

  /// Number of seven-day weeks in one calendar cycle.
  final int seasonCycleWeeks;
  final int seasonStartMonth;
  final int awardsDay;
  final int staffGrowthDay;
  final int retirementsDay;
  final int lotteryDay;
  final int scoutWeekOffset;
  final int scoutReportDay;
  final int combineDay;
  final int finalMockDay;
  final int draftDay;
  final int tradeWindowOpenDay;
  final int tradeDeadlineDay;
  final int freeAgencyOpenDay;
  final int contractExtensionStartDay;
}

class ChemistryBalance {
  /// Shared rolling window for the stored results and the team-form display.
  static const recentResultsWindow = 8;

  const ChemistryBalance({
    this.fullLineupChemistryBonus = 0.3,
    this.foreignPositionChemistryPenalty = 0.4,
    this.experiencedSeasonsMin = 3,
    this.experiencedPlayersMin = 10,
    this.experiencedChemistryBonus = 0.3,
    this.nationalityClusterSize = 4,
    this.nationalityClusterBonus = 0.2,
    this.nationalityBonusMax = 1.0,
    this.atmosphereStreakLength = 3,
    this.atmosphereStreakDelta = 3,
    this.rankAtmosphereBands = const [(6, 2), (2, 1)],
    this.expectedWinsRankPenalty = 0.45,
    this.expectedWinsBaseShare = 0.5,
    this.emptyTeamForm = 0.5,
    this.walkoverAtmospherePenalty = -15,
    this.championshipAtmosphereBonus = 30,
    this.playoffMissAtmosphere = const {
      TeamStatus.elite: -15,
      TeamStatus.contender: -12,
      TeamStatus.pretender: -8,
    },
    this.chemistryBands = const [
      (30.0, 0.95),
      (50.0, 0.98),
      (70.0, 1.0),
      (85.0, 1.02),
      (100.0, 1.05),
    ],
    this.atmosphereBands = const [
      (30, 0.95),
      (45, 0.97),
      (70, 1.0),
      (85, 1.02),
      (100, 1.04),
    ],
    this.negativeEventBands = const [(30, 1.25), (45, 1.10), (100, 1.0)],
    this.positiveEventBands = const [(70, 1.0), (85, 1.10), (100, 1.20)],
    this.atmosphereChemistryDrift = const [
      (30, -2.0),
      (45, -1.0),
      (70, 0.0),
      (85, 1.0),
      (100, 2.0),
    ],
    this.scoreMin = 0,
    this.scoreMax = 100,
    this.cohesionBase = 50,
    this.cohesionCorrectPosition = 2,
    this.cohesionForeignPosition = -5,
    this.cohesionOptimalRole = 2,
    this.cohesionMultipliers = const [
      (20.0, 1.01),
      (40.0, 1.02),
      (60.0, 1.03),
      (80.0, 1.04),
      (100.0, 1.05),
    ],
    this.headCoachMotivationMultipliers = const [
      (1.0, 0.97),
      (2.0, 0.99),
      (3.0, 1.00),
      (4.0, 1.01),
      (5.0, 1.03),
    ],
    this.multMin = 0.92,
    this.multMax = 1.08,
    this.roleMultOkMin = 1.05,
    this.roleMultOkMax = 1.12,
    this.roleMultFailMin = 0.80,
    this.roleMultFailMax = 0.90,
    this.formationMatchupClamp = 0.15,
  });

  final double multMin;
  final double fullLineupChemistryBonus;
  final double foreignPositionChemistryPenalty;
  final int experiencedSeasonsMin;
  final int experiencedPlayersMin;
  final double experiencedChemistryBonus;
  final int nationalityClusterSize;
  final double nationalityClusterBonus;
  final double nationalityBonusMax;
  final int atmosphereStreakLength;
  final int atmosphereStreakDelta;
  final List<(int minDifference, int delta)> rankAtmosphereBands;
  final double expectedWinsRankPenalty;
  final double expectedWinsBaseShare;
  final double emptyTeamForm;
  final int walkoverAtmospherePenalty;
  final int championshipAtmosphereBonus;
  final Map<TeamStatus, int> playoffMissAtmosphere;
  final List<(double upperBound, double multiplier)> chemistryBands;
  final List<(int upperBound, double multiplier)> atmosphereBands;
  final List<(int upperBound, double multiplier)> negativeEventBands;
  final List<(int upperBound, double multiplier)> positiveEventBands;
  final List<(int upperBound, double delta)> atmosphereChemistryDrift;
  final int scoreMin;
  final int scoreMax;
  final int cohesionBase;
  final int cohesionCorrectPosition;
  final int cohesionForeignPosition;
  final int cohesionOptimalRole;
  final List<(double upperBound, double multiplier)> cohesionMultipliers;
  final List<(double upperBound, double multiplier)>
  headCoachMotivationMultipliers;
  final double multMax;
  final double roleMultOkMin;
  final double roleMultOkMax;
  final double roleMultFailMin;
  final double roleMultFailMax;
  final double formationMatchupClamp;
}
