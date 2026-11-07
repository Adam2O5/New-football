class SalaryCapBalance {
  static const defaultSalaryCap = 350000000;
  static const defaultFirstApron = 396700000;
  static const defaultSecondApron = 431700000;
  static const defaultMidLevelException = 20400000;
  static const defaultMinSalary = 1000000;
  const SalaryCapBalance({
    this.earlyBirdSeasons = 2,
    this.earlyBirdSalaryMultiplier = 1.75,
    this.earlyBirdMaxSalaryShare = 0.60,
    this.earlyBirdMaxYears = 4,
    this.nonBirdSalaryMultiplier = 1.20,
    this.nonBirdMaxYears = 4,
    this.veteranExtensionMultiplier = 1.08,
    this.midLevelMaxYears = 4,
    this.tvResetYearsMin = 5,
    this.tvResetYearsMax = 7,
    this.tvIncreasePctMin = 4,
    this.tvIncreasePctMax = 12,
    this.salaryCap = defaultSalaryCap,
    this.firstApron = defaultFirstApron,
    this.secondApron = defaultSecondApron,
    this.midLevelException = defaultMidLevelException,
    this.minSalary = defaultMinSalary,
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
  final int earlyBirdSeasons;
  final double earlyBirdSalaryMultiplier;
  final double earlyBirdMaxSalaryShare;
  final int earlyBirdMaxYears;
  final double nonBirdSalaryMultiplier;
  final int nonBirdMaxYears;
  final double veteranExtensionMultiplier;
  final int midLevelMaxYears;
  final int tvResetYearsMin;
  final int tvResetYearsMax;
  final int tvIncreasePctMin;
  final int tvIncreasePctMax;
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
  static const defaultStartingCash = 75000000;
  const ClubCashBalance({
    this.startingCash = defaultStartingCash,
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
