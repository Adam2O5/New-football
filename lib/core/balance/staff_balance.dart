import 'package:new_football/core/models/enums.dart';

class StaffBalance {
  static const defaultRatingMin = 0.0;
  static const defaultRatingMax = 5.0;
  const StaffBalance({
    this.extensionMaxYearsRemaining = 1,

    this.missingHeadCoachShapeBoost = -5,
    this.headCoachShapePerStar = 2,
    this.headCoachShapeOffset = 1,
    this.headCoachShapeMin = 0,
    this.headCoachShapeMax = 9,

    this.minContractYears = 1,
    this.maxContractYears = 4,
    this.wantPerStar = 20.0,
    this.desiredLengthTable = const [
      (54, [2, 3, 4]),
      (59, [1, 2, 2]),
      (null, [1, 1, 1]),
    ],
    this.salaryCap = 15000000,
    this.minSalary = 500000,
    this.maxSalary = 5000000,
    this.starMin = defaultRatingMin,
    this.starMax = defaultRatingMax,
    this.starStep = 0.5,
    this.maxWatchedBase = 4,
    this.maxWatchedPerCoverageStar = 6,
    this.combineAssignCoverageFraction = 0.5,
    this.growthAgeMin = 35,
    this.growthAgeMax = 45,
    this.retireAgeMin = 55,
    this.retireAgeHardCap = 60,
    this.salaryMarketBand = 4200000,
    this.roleSalaryWeight = const <StaffRole, double>{
      StaffRole.headCoach: 1.0,
      StaffRole.youthCoach: 0.55,
      StaffRole.scout: 0.55,
      StaffRole.doctor: 0.55,
      StaffRole.physio: 0.4,
      StaffRole.cfo: 0.25,
    },
    this.growthAgeMinChance = 0.22,
    this.growthAgeMaxChance = 0.14,
    this.retireChanceByAge = const <int, double>{
      55: 0.12,
      56: 0.22,
      57: 0.38,
      58: 0.55,
      59: 0.75,
      60: 1.0,
    },
  });

  final int extensionMaxYearsRemaining;

  final int missingHeadCoachShapeBoost;
  final int headCoachShapePerStar;
  final int headCoachShapeOffset;
  final int headCoachShapeMin;
  final int headCoachShapeMax;

  final int salaryCap;
  final int minContractYears;
  final int maxContractYears;
  final double wantPerStar;
  final List<(int? ageMax, List<int> years)> desiredLengthTable;

  int desiredLengthFor(int age, int wantBand) {
    final row = desiredLengthTable.firstWhere(
      (row) => row.$1 == null || age <= row.$1!,
      orElse: () => desiredLengthTable.last,
    );
    return row.$2[wantBand];
  }

  final int minSalary;
  final int maxSalary;
  final double starMin;
  final double starMax;
  final double starStep;

  final int maxWatchedBase;
  final int maxWatchedPerCoverageStar;

  /// Combine focus slots ≈ this × Coverage (stars), floored, min 1.
  final double combineAssignCoverageFraction;

  final int growthAgeMin;
  final int growthAgeMax;
  final int retireAgeMin;
  final int retireAgeHardCap;

  /// Reference salary (€) for an elite (5★) Head Coach; other roles/stars
  /// scale off this via [roleSalaryWeight] (`docs/staff_rules.md` §3).
  final int salaryMarketBand;
  final Map<StaffRole, double> roleSalaryWeight;

  /// Base P(growth roll succeeds) at [growthAgeMin] / [growthAgeMax]
  /// (`docs/staff_rules.md` §6), linearly interpolated between.
  final double growthAgeMinChance;
  final double growthAgeMaxChance;

  /// Base P(retire) by age, 55–60 (`docs/staff_rules.md` §7).
  final Map<int, double> retireChanceByAge;

  int maxWatched(double coverageStars) =>
      (maxWatchedBase + coverageStars * maxWatchedPerCoverageStar).round();

  int combineAssignLimit(double coverageStars) {
    if (coverageStars < 1) return 0;
    final raw = (coverageStars * combineAssignCoverageFraction).floor();
    return raw < 1 ? 1 : raw;
  }

  double salaryFor(StaffRole role, double avgStars) {
    final weight = roleSalaryWeight[role] ?? 0.5;
    final norm = (avgStars / starMax).clamp(0.0, 1.0);
    final salary = weight * (0.4 + 0.6 * norm) * salaryMarketBand;
    return salary.clamp(minSalary, maxSalary).toDouble();
  }

  double growthChanceForAge(int age) {
    if (age < growthAgeMin || age > growthAgeMax) return 0;
    final span = (growthAgeMax - growthAgeMin).clamp(1, 1000);
    final t = (age - growthAgeMin) / span;
    return growthAgeMinChance + (growthAgeMaxChance - growthAgeMinChance) * t;
  }

  double retireChanceForAge(int age) {
    if (age < retireAgeMin) return 0;
    return retireChanceByAge[age] ?? (age >= retireAgeHardCap ? 1.0 : 0.0);
  }
}
