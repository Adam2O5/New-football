class RosterBalance {
  const RosterBalance({
    this.minSize = 20,
    this.maxSize = 30,
    this.seedSize = 25,
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
}

class ChemistryBalance {
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
