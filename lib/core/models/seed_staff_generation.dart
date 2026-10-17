part of 'seed_data_generator.dart';

mixin _SeedStaffGeneration on _SeedGenerationShared {
  /// Rozkład gwiazdek generowanego sztabu (`data_generation.md`
  /// §„Generowanie po staffGrowth"). Wagi sumują się do 1.0.
  static const List<(double stars, double probability)> _staffStarWeights = [
    (0.5, 0.10),
    (1.0, 0.10),
    (1.5, 0.10),
    (2.0, 0.15),
    (2.5, 0.20),
    (3.0, 0.15),
    (3.5, 0.10),
    (4.0, 0.06),
    (4.5, 0.03),
    (5.0, 0.01),
  ];

  StaffMember generateStaffMember(
    Random rng,
    StaffRole role, {
    BalanceConfig balance = BalanceConfig.defaults,
  }) {
    final nationality =
        Nationality.values[rng.nextInt(Nationality.values.length)];
    final name = _generateName(rng, nationality);
    final age = 35 + rng.nextInt(16); // 35–50

    double star() {
      final roll = rng.nextDouble();
      var cumulative = 0.0;
      for (final (stars, probability) in _staffStarWeights) {
        cumulative += probability;
        if (roll < cumulative) return stars;
      }
      return _staffStarWeights.last.$1;
    }

    final attrs = switch (role) {
      // `docs/staff.md` §5: the head coach is rated by Tactics and Motivation
      // only. Legacy saves may still carry a `development` value, but the
      // generator must never produce a new one for this role.
      StaffRole.headCoach => StaffAttributes(
        tactics: star(),
        motivation: star(),
      ),
      StaffRole.youthCoach => StaffAttributes(
        development: star(),
        mentoring: star(),
      ),
      StaffRole.scout => StaffAttributes(coverage: star(), evaluation: star()),
      StaffRole.physio => StaffAttributes(
        rehabilitation: star(),
        regenaration: star(),
      ),
      StaffRole.doctor => StaffAttributes(prevention: star(), care: star()),
      StaffRole.cfo => StaffAttributes(negotiation: star()),
    };

    _staffCounter++;
    return StaffMember(
      id: 'staff_${_staffCounter}_${rng.nextInt(1 << 32)}',
      name: name,
      nationality: nationality,
      age: age,
      role: role,
      attributes: attrs,
    );
  }

  /// Generuje członka sztabu z atrybutami relevantnymi dla [role] ustawionymi
  /// wprost na [stars] — deterministyczny target zamiast losowego rozkładu z
  /// [generateStaffMember] (`data_generation.md` §„Generowanie na początku
  /// save'a").
  StaffMember generateStaffMemberAtStars(
    Random rng,
    StaffRole role,
    double stars,
  ) {
    final nationality =
        Nationality.values[rng.nextInt(Nationality.values.length)];
    final name = _generateName(rng, nationality);
    final age = 35 + rng.nextInt(16); // 35–50
    final clamped = StaffRatingSystem.clampToScale(stars);

    final attrs = switch (role) {
      StaffRole.headCoach => StaffAttributes(
        tactics: clamped,
        motivation: clamped,
      ),
      StaffRole.youthCoach => StaffAttributes(
        development: clamped,
        mentoring: clamped,
      ),
      StaffRole.scout => StaffAttributes(
        coverage: clamped,
        evaluation: clamped,
      ),
      StaffRole.physio => StaffAttributes(
        rehabilitation: clamped,
        regenaration: clamped,
      ),
      StaffRole.doctor => StaffAttributes(prevention: clamped, care: clamped),
      StaffRole.cfo => StaffAttributes(negotiation: clamped),
    };

    _staffCounter++;
    return StaffMember(
      id: 'staff_${_staffCounter}_${rng.nextInt(1 << 32)}',
      name: name,
      nationality: nationality,
      age: age,
      role: role,
      attributes: attrs,
    );
  }

  /// Generates a pool of unhired staff, roughly evenly spread across roles.
  List<StaffMember> generateStaffPool(
    int count, {
    Random? random,
    BalanceConfig balance = BalanceConfig.defaults,
  }) {
    final rng = random ?? _random;
    final roles = StaffRole.values;
    return List.generate(
      count,
      (i) =>
          generateStaffMember(rng, roles[i % roles.length], balance: balance),
    );
  }
}
