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
  const CalendarBalance({
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
    this.multMin = 0.92,
    this.multMax = 1.08,
    this.roleMultOkMin = 1.05,
    this.roleMultOkMax = 1.12,
    this.roleMultFailMin = 0.80,
    this.roleMultFailMax = 0.90,
    this.formationMatchupClamp = 0.15,
  });

  final double multMin;
  final double multMax;
  final double roleMultOkMin;
  final double roleMultOkMax;
  final double roleMultFailMin;
  final double roleMultFailMax;
  final double formationMatchupClamp;
}
