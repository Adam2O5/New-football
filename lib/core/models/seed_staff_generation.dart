part of 'seed_data_generator.dart';

mixin _SeedStaffGeneration on _SeedGenerationShared {
  /// Rozkład gwiazdek generowanego sztabu (`data_generation.md`
  /// §„Generowanie po staffGrowth"). Wagi sumują się do 1.0.

  StaffMember generateStaffMember(
    Random rng,
    StaffRole role, {
    BalanceConfig? balance,
  }) {
    final config = balance ?? this.balance;
    final nationality =
        Nationality.values[rng.nextInt(Nationality.values.length)];
    final name = _generateName(rng, nationality);
    final age =
        config.seed.staffAgeMin +
        rng.nextInt(
          config.seed.staffAgeMax - config.seed.staffAgeMin + 1,
        ); // 35–50

    double star() {
      final roll = rng.nextDouble();
      var cumulative = 0.0;
      for (final (stars, probability) in config.seed.staffStarWeights) {
        cumulative += probability;
        if (roll < cumulative) return stars;
      }
      return config.seed.staffStarWeights.last.$1;
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
    final config = balance;
    final nationality =
        Nationality.values[rng.nextInt(Nationality.values.length)];
    final name = _generateName(rng, nationality);
    final age =
        config.seed.staffAgeMin +
        rng.nextInt(
          config.seed.staffAgeMax - config.seed.staffAgeMin + 1,
        ); // 35–50
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
    BalanceConfig? balance,
  }) {
    final rng = random ?? _random;
    final roles = StaffRole.values;
    return List.generate(
      count,
      (i) => generateStaffMember(
        rng,
        roles[i % roles.length],
        balance: balance ?? this.balance,
      ),
    );
  }
}
