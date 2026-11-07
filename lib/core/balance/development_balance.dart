class RetirementBalance {
  const RetirementBalance({
    this.minAge = 33,

    /// Age → base retirement chance (0–1). Ages below [minAge] use 0.
    this.baseChanceByAge = const <int, double>{
      33: 0.03,
      34: 0.08,
      35: 0.18,
      36: 0.32,
      37: 0.55,
      38: 0.78,
      39: 0.95,
    },
    this.age39PlusChance = 0.95,
  });

  final int minAge;
  final Map<int, double> baseChanceByAge;
  final double age39PlusChance;

  double baseChanceForAge(int age) {
    if (age < minAge) return 0;
    return baseChanceByAge[age] ?? age39PlusChance;
  }
}

class DevelopmentBalance {
  const DevelopmentBalance({
    this.minutesGrowthRate = 0.01,
    this.ambitiousGrowthMultiplier = 1.10,
    this.progressThreshold = 100.0,
    this.progressResetAfterGrowth = 0.0,
    this.progressResetAfterDecline = 99.0,
    this.progressAtCeiling = 99.0,
    this.ageBonusStartAge = 18,
    this.ageBonuses = defaultAgeBonuses,
    this.staffDevelopmentBonuses = defaultStaffDevelopmentBonuses,
    this.formLowThreshold = 3.0,
    this.formHighThreshold = 8.0,
    this.formLowBase = -0.20,
    this.formHighBase = 0.05,
    this.formBonusSlope = 0.05,
    this.atmosphereNeutral = 50.0,
    this.atmosphereBonusDivisor = 500.0,
    this.exceedSmallOffsetChance = 0.8,
    this.exceedSmallOffset = 0.5,
    this.exceedLargeOffset = 1.0,
    this.underSmallOffsetChance = 0.6,
    this.underSmallOffset = -0.5,
    this.underLargeOffset = -1.0,
    this.growthRateBase = 1.0,
    this.growthRateMin = -3.0,
    this.growthRateMax = 3.0,
    this.constDev = 3.67,
    this.plateauAgeMin = 27,
    this.plateauAgeMax = 32,
    this.declineAgeMin = 33,
    this.developmentAgeMax = 26,
    this.determinationGrowthRates = const [
      0.50,
      0.65,
      0.80,
      0.90,
      1.00,
      1.10,
      1.20,
      1.30,
      1.40,
      1.50,
    ],
    this.determinationOutcomeTable = const [
      (1, 20),
      (2, 28),
      (4, 36),
      (7, 43),
      (10, 50),
      (12, 58),
      (15, 65),
      (20, 70),
      (25, 68),
      (30, 65),
    ],
  });

  final double minutesGrowthRate;
  final double ambitiousGrowthMultiplier;
  final double progressThreshold;
  final double progressResetAfterGrowth;
  final double progressResetAfterDecline;
  final double progressAtCeiling;
  final int ageBonusStartAge;
  final List<double> ageBonuses;
  final List<(double, double)> staffDevelopmentBonuses;
  final double formLowThreshold;
  final double formHighThreshold;
  final double formLowBase;
  final double formHighBase;
  final double formBonusSlope;
  final double atmosphereNeutral;
  final double atmosphereBonusDivisor;
  final double exceedSmallOffsetChance;
  final double exceedSmallOffset;
  final double exceedLargeOffset;
  final double underSmallOffsetChance;
  final double underSmallOffset;
  final double underLargeOffset;
  final double growthRateBase;
  final double growthRateMin;
  final double growthRateMax;
  final double constDev;
  final int plateauAgeMin;
  final int plateauAgeMax;
  final int declineAgeMin;
  final int developmentAgeMax;
  final List<double> determinationGrowthRates;

  /// Index 0 = determination 1 … 9 = determination 10.
  /// Each entry: `(exceed%, hit%)`; under% = `100 − exceed − hit`.
  final List<(int exceed, int hit)> determinationOutcomeTable;

  static const defaultAgeBonuses = <double>[
    0.40,
    0.34,
    0.29,
    0.23,
    0.17,
    0.11,
    0.06,
    0.00,
    0.00,
    0.00,
    0.00,
    0.00,
    0.00,
    0.00,
    -0.50,
    -1.00,
    -1.50,
    -1.75,
    -2.00,
    -2.25,
    -2.50,
    -2.75,
    -3.00,
  ];

  static const defaultStaffDevelopmentBonuses = <(double, double)>[
    (0.0, -0.10),
    (0.5, 0.01),
    (1.0, 0.02),
    (1.5, 0.03),
    (2.0, 0.05),
    (2.5, 0.06),
    (3.0, 0.08),
    (3.5, 0.09),
    (4.0, 0.11),
    (4.5, 0.12),
    (5.0, 0.14),
  ];

  double baseGrowthRateFor(int determination) {
    final index =
        determination.clamp(1, determinationGrowthRates.length).toInt() - 1;
    return determinationGrowthRates[index];
  }

  double ageBonusFor(int age) {
    return ageBonuses[(age - ageBonusStartAge).clamp(0, ageBonuses.length - 1)];
  }

  double formBonusFor(double form) {
    final f = form.clamp(1.0, 10.0).toDouble();
    if (f <= formLowThreshold) return formLowBase + f * formBonusSlope;
    if (f >= formHighThreshold) {
      return formHighBase + (f - formHighThreshold) * formBonusSlope;
    }
    return 0.0;
  }

  double staffDevelopmentBonusFor(double stars) {
    final value = stars.clamp(0.0, 5.0).toDouble();
    for (var i = 1; i < staffDevelopmentBonuses.length; i++) {
      final (previousStars, previousBonus) = staffDevelopmentBonuses[i - 1];
      final (nextStars, nextBonus) = staffDevelopmentBonuses[i];
      if (value <= nextStars) {
        final fraction = (value - previousStars) / (nextStars - previousStars);
        return previousBonus + (nextBonus - previousBonus) * fraction;
      }
    }
    return staffDevelopmentBonuses.last.$2;
  }

  double atmosphereBonusFor(int atmosphere) {
    final value = atmosphere.clamp(0, 100).toDouble();
    return (value - atmosphereNeutral) / atmosphereBonusDivisor;
  }

  double progressFor(double growthRate) => growthRate * constDev;

  (int exceed, int hit) outcomeChancesFor(int determination) {
    final d = determination.clamp(1, determinationOutcomeTable.length);
    return determinationOutcomeTable[d - 1];
  }
}
