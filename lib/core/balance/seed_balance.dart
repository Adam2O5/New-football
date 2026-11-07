/// Parameters used when creating a new game and its initial squads.
class SeedBalance {
  const SeedBalance({
    this.startYear = defaultStartYear,
    this.rosterProfiles = defaultRosterProfiles,
    this.initialStaff = defaultInitialStaff,
    this.staffPoolSize = 90,
  });

  static const defaultStartYear = 2026;
  final int startYear;
  final List<(int ovr, int ageMin, int ageMax)> rosterProfiles;
  final List<(double stars, int years, int salary)> initialStaff;
  final int staffPoolSize;

  static const defaultRosterProfiles = [
    (85, 27, 30),
    (85, 27, 30),
    (84, 32, 35),
    (82, 23, 26),
    (82, 23, 26),
    (81, 23, 24),
    (80, 27, 32),
    (80, 27, 32),
    (79, 27, 32),
    (79, 27, 32),
    (79, 23, 26),
    (79, 33, 40),
    (77, 27, 32),
    (77, 27, 32),
    (77, 27, 32),
    (77, 23, 26),
    (77, 23, 26),
    (77, 33, 40),
    (75, 18, 22),
    (75, 18, 22),
    (73, 27, 32),
    (72, 33, 40),
    (70, 38, 40),
    (68, 18, 22),
    (66, 18, 22),
    (63, 18, 22),
  ];
  static const defaultInitialStaff = [
    (2.0, 1, 750000),
    (2.0, 1, 750000),
    (2.0, 1, 750000),
    (2.5, 1, 1000000),
    (3.0, 2, 1500000),
    (3.5, 2, 2000000),
  ];
}
