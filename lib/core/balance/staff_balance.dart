import 'package:new_football/core/models/enums.dart';

class StaffBalance {
  const StaffBalance({
    this.salaryCap = 15000000,
    this.minSalary = 500000,
    this.maxSalary = 5000000,
    this.roleSlots = 6,
    this.starMin = 0.0,
    this.starMax = 5.0,
    this.starStep = 0.5,
    this.maxWatchedBase = 4,
    this.maxWatchedPerCoverageStar = 6,
    this.combineAssignCoverageFraction = 0.5,
    this.youthCoachMaxAge = 23,
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

  final int salaryCap;
  final int minSalary;
  final int maxSalary;
  final int roleSlots;
  final double starMin;
  final double starMax;
  final double starStep;

  final int maxWatchedBase;
  final int maxWatchedPerCoverageStar;

  /// Combine focus slots ≈ this × Coverage (stars), floored, min 1.
  final double combineAssignCoverageFraction;

  final int youthCoachMaxAge;
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
