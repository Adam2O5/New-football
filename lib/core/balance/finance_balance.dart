class SalaryCapBalance {
  const SalaryCapBalance({
    this.salaryCap = 350000000,
    this.firstApron = 396700000,
    this.secondApron = 431700000,
    this.midLevelException = 20400000,
    this.minSalary = 1000000,
    this.maxSalary = 60000000,
    this.rookieBaseScale = 8000000,
    this.rookieMinSalary = 1000000,
    this.rookieMaxSalary = 8000000,
    this.rookieScaleYears = 2,
    this.rookiePickDecay = 0.06,
    this.birdRightsSeasons = 3,
    this.qualifyingOfferMultiplier = 1.25,
    this.qualifyingOfferMin = 1000000,
    this.salaryMatchPct = 1.25,
    this.salaryMatchBuffer = 500000,
    this.maxPicksPerTrade = 3,
    this.maxPlayersPerTrade = 5,
    this.maxPickYearsAhead = 7,
  });

  final int salaryCap;
  final int firstApron;
  final int secondApron;
  final int midLevelException;
  final int minSalary;
  final int maxSalary;

  final int rookieBaseScale;
  final int rookieMinSalary;
  final int rookieMaxSalary;
  final int rookieScaleYears;
  final double rookiePickDecay;

  final int birdRightsSeasons;
  final double qualifyingOfferMultiplier;
  final int qualifyingOfferMin;

  /// Incoming / outgoing salary matching above the cap (e.g. 125%).
  final double salaryMatchPct;
  final int salaryMatchBuffer;

  final int maxPicksPerTrade;
  final int maxPlayersPerTrade;
  final int maxPickYearsAhead;

  /// Rookie scale salary for [pickSlot] (1-based).
  int rookieSalaryForPick(int pickSlot) {
    final raw = rookieBaseScale / (1 + pickSlot * rookiePickDecay);
    final rounded = raw.round();
    if (rounded < rookieMinSalary) return rookieMinSalary;
    if (rounded > rookieMaxSalary) return rookieMaxSalary;
    return rounded;
  }
}

class ClubCashBalance {
  const ClubCashBalance({
    this.startingCash = 75000000,
    this.startingCashVariance = 15000000,
    this.tvBase = 90000000,
    this.tvBonusMax = 45000000,
    this.gateSponsorMin = 25000000,
    this.gateSponsorMax = 70000000,
    this.opsFixed = 18000000,
    this.healthyCashFloor = 20000000,
  });

  final int startingCash;
  final int startingCashVariance;
  final int tvBase;
  final int tvBonusMax;
  final int gateSponsorMin;
  final int gateSponsorMax;
  final int opsFixed;

  /// Below this → board warning / atmosphere drain.
  final int healthyCashFloor;
}
