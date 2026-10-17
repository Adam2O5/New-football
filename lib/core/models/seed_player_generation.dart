part of 'seed_data_generator.dart';

mixin _SeedPlayerGeneration on _SeedGenerationShared {
  /// Offset (`lo`, `hi`) względem docelowego OVR `X` per waga atrybutu
  /// pozycji (`data_generation.md` §„Wagi atrybutów pozycji"). Klucz to
  /// waga × 100, żeby uniknąć porównań liczb zmiennoprzecinkowych.
  static const Map<int, (int lo, int hi)> _attrOffsetRangeForWeight = {
    5: (-18, -13),
    8: (-8, -5),
    10: (-6, -3),
    12: (-4, -2),
    14: (-3, 0),
    15: (-2, 0),
    18: (0, 1),
    20: (-1, 1),
    25: (2, 3),
    28: (3, 4),
    30: (3, 4),
    35: (4, 6),
    40: (3, 5),
  };

  /// Losuje wartość atrybutu wg wagi pozycji, względem docelowego OVR `X`
  /// (`data_generation.md` §„Generowanie OVR").
  int _attrForWeight(int targetOvr, double weight, Random rng) {
    final key = (weight * 100).round();
    final range = _attrOffsetRangeForWeight[key];
    if (range == null) {
      throw StateError(
        'Brak zdefiniowanego zakresu offsetu dla wagi $weight — '
        'zaktualizuj _attrOffsetRangeForWeight zgodnie z data_generation.md.',
      );
    }
    final (lo, hi) = range;
    return (targetOvr + lo + rng.nextInt(hi - lo + 1)).clamp(1, 99);
  }

  /// Atrybut bramkarza: waga 1/6 każdego atrybutu → zakres X-2…X+2
  /// (`data_generation.md` §„Bramkarze").
  int _gkAttrForOvr(int targetOvr, Random rng) =>
      (targetOvr - 2 + rng.nextInt(5)).clamp(1, 99);

  /// Atrybuty gracza wg wag pozycji i docelowego OVR — wspólna formuła dla
  /// startowego rosteru (`_generatePlayer`) i prospektów draftowych
  /// (`generateDraftClass`), zgodnie z `data_generation.md` §„Atrybuty:
  /// identyczna formuła jak u zawodników".
  @override
  PlayerAttributes _attributesForOvr(
    Position position,
    int targetOvr,
    Random rng,
  ) {
    if (position == Position.gk) {
      return PlayerAttributes.goalkeeper(
        stats: GoalkeeperAttributes(
          diving: _gkAttrForOvr(targetOvr, rng),
          handling: _gkAttrForOvr(targetOvr, rng),
          kicking: _gkAttrForOvr(targetOvr, rng),
          reflexes: _gkAttrForOvr(targetOvr, rng),
          speed: _gkAttrForOvr(targetOvr, rng),
          positioning: _gkAttrForOvr(targetOvr, rng),
        ),
      );
    }
    final weights =
        BalanceConfig.defaults.player.outfieldOverallWeights[position];
    if (weights == null) {
      throw StateError(
        'Brak wag atrybutów dla pozycji $position w '
        'BalanceConfig.defaults.player.outfieldOverallWeights.',
      );
    }
    return PlayerAttributes.outfield(
      stats: FieldPlayerAttributes(
        pace: _attrForWeight(targetOvr, weights.pace, rng),
        shooting: _attrForWeight(targetOvr, weights.shooting, rng),
        passing: _attrForWeight(targetOvr, weights.passing, rng),
        dribbling: _attrForWeight(targetOvr, weights.dribbling, rng),
        defending: _attrForWeight(targetOvr, weights.defending, rng),
        physicality: _attrForWeight(targetOvr, weights.physicality, rng),
      ),
    );
  }

  /// Potencjał (★) wg wieku i OVR (`data_generation.md` §„Potencjał").
  /// Wiersze/kolumny poza tabelą (np. wiek <18 albo OVR <50) są przycinane
  /// do najbliższego zdefiniowanego przedziału.
  static const List<
    (int ageMax, List<(int ovrMax, double starMin, double starMax)>)
  >
  _potentialTable = [
    (
      22,
      [
        (59, 2.0, 3.0),
        (69, 3.5, 4.5),
        (77, 3.0, 4.0),
        (83, 3.5, 4.5),
        (89, 4.5, 5.0),
        (95, 5.0, 5.0),
      ],
    ),
    (
      26,
      [
        (59, 2.0, 2.5),
        (69, 3.0, 4.0),
        (77, 3.0, 3.5),
        (83, 3.5, 4.0),
        (89, 4.5, 5.0),
        (95, 5.0, 5.0),
      ],
    ),
    (
      32,
      [
        (59, 1.0, 2.0),
        (69, 2.0, 3.5),
        (77, 2.5, 3.0),
        (83, 3.0, 4.0),
        (89, 4.5, 4.5),
        (95, 5.0, 5.0),
      ],
    ),
    (
      40,
      [
        (59, 0.5, 1.5),
        (69, 1.5, 2.5),
        (77, 2.5, 3.0),
        (83, 3.0, 3.5),
        (89, 4.5, 4.5),
        (95, 5.0, 5.0),
      ],
    ),
  ];

  double _rollPotentialStars(int age, int ovr, Random rng) {
    final ageRow = _potentialTable
        .firstWhere((row) => age <= row.$1, orElse: () => _potentialTable.last)
        .$2;
    final (_, starMin, starMax) = ageRow.firstWhere(
      (cell) => ovr <= cell.$1,
      orElse: () => ageRow.last,
    );
    final stars = starMin + rng.nextDouble() * (starMax - starMin);
    return (stars * 2).round() / 2.0;
  }

  /// Pensja wg wzoru z `salary_cap.md`/`data_generation.md`:
  /// `minSalary + (maxSalary - minSalary) * (((OVR-50)*2)/100)^3`.
  int _rollSalary(int ovr) {
    final cap = BalanceConfig.defaults.salaryCap;
    final t = (((ovr - 50) * 2) / 100).clamp(0.0, 1.0);
    final salary = cap.minSalary + (cap.maxSalary - cap.minSalary) * pow(t, 3);
    return salary.round();
  }

  @override
  Player _generatePlayer({
    required String teamId,
    required Position position,
    required int targetOvr,
    required int age,
    required Random rng,
    required int index,
  }) {
    final id = '${teamId}_player_$index';
    final nationality =
        Nationality.values[rng.nextInt(Nationality.values.length)];
    final name = _generateName(rng, nationality);

    final attrs = _attributesForOvr(position, targetOvr, rng);

    final salary = _rollSalary(targetOvr);
    final roundedStars = _rollPotentialStars(age, targetOvr, rng);

    final injuryProne = 1 + rng.nextInt(10);
    final determination = 1 + rng.nextInt(10);
    final heightCm = _heightCmFor(position, rng);
    final outcome = rollDevelopmentOutcome(determination, rng);

    final player = Player(
      id: id,
      name: name,
      position: position,
      nationality: nationality,
      age: age,
      attributes: attrs,
      personality: PlayerPersonality
          .values[rng.nextInt(PlayerPersonality.values.length)],
      potentialStars: roundedStars,
      heightCm: heightCm,
      optimalRole: _randomRoleFor(position, rng),
      contract: Contract(
        salary: salary,
        yearsRemaining: 1 + rng.nextInt(4),
        hasBirdRights: false,
      ),
      state: PlayerState(
        stamina: 100,
        form: (3 + rng.nextInt(6)).toDouble(),
        role: position.defaultAssignedRole,
        seasonsWithTeam: 0,
      ),
      hidden: PlayerHidden(
        injuryProne: injuryProne,
        determination: determination,
        overallProgress: (age <= 26 ? 40 + rng.nextInt(50) : rng.nextInt(30))
            .clamp(0.0, 99.0)
            .toDouble(),
        growthRate: BalanceConfig.defaults.development.baseGrowthRateFor(
          determination,
        ),
        developmentOutcome: outcome,
        developmentCeilingStars: rollDevelopmentCeilingStars(
          roundedStars,
          outcome,
          rng,
        ),
      ),
    );
    return player
        .copyWith(seasonStartOvr: player.overall())
        .recalculatePointValue();
  }

  /// Startowa pula wolnych agentów dostępnych od pierwszego dnia save'a
  /// (`data_generation.md` §„Wolni agenci na starcie save'a"): 25–35 graczy,
  /// OVR 73–78, wiek 22–32, potencjał 2,5–4,0★. Pozycja, narodowość, rola,
  /// temperament itd. są w pełni losowe (możliwe 0 bramkarzy w puli).
  List<Player> generateFreeAgentPlayers({required Random rng}) {
    final count = 25 + rng.nextInt(11); // 25..35
    return List.generate(count, (i) {
      final position = Position.values[rng.nextInt(Position.values.length)];
      final targetOvr = 73 + rng.nextInt(6); // 73..78
      final age = 22 + rng.nextInt(11); // 22..32
      return _generateFreeAgentPlayer(
        index: i,
        position: position,
        targetOvr: targetOvr,
        age: age,
        rng: rng,
      );
    });
  }

  /// Potencjał (★) wolnych agentów: 2,5–4,0★, zadany wprost i niezależny od
  /// `_potentialTable` (wiek/OVR) używanej dla rosterów startowych i draftu
  /// (`data_generation.md` §„Wolni agenci na starcie save'a").
  double _rollFreeAgentPotentialStars(Random rng) {
    const starMin = 2.5;
    const starMax = 4.0;
    final stars = starMin + rng.nextDouble() * (starMax - starMin);
    return (stars * 2).round() / 2.0;
  }

  Player _generateFreeAgentPlayer({
    required int index,
    required Position position,
    required int targetOvr,
    required int age,
    required Random rng,
  }) {
    final id = 'free_agent_start_$index';
    final nationality =
        Nationality.values[rng.nextInt(Nationality.values.length)];
    final name = _generateName(rng, nationality);

    final attrs = _attributesForOvr(position, targetOvr, rng);
    final salary = _rollSalary(targetOvr);
    final potentialStars = _rollFreeAgentPotentialStars(rng);

    final injuryProne = 1 + rng.nextInt(10);
    final determination = 1 + rng.nextInt(10);
    final heightCm = _heightCmFor(position, rng);
    final outcome = rollDevelopmentOutcome(determination, rng);

    final player = Player(
      id: id,
      name: name,
      position: position,
      nationality: nationality,
      age: age,
      attributes: attrs,
      personality: PlayerPersonality
          .values[rng.nextInt(PlayerPersonality.values.length)],
      potentialStars: potentialStars,
      heightCm: heightCm,
      optimalRole: _randomRoleFor(position, rng),
      // Brak klubu od startu save'a — ta sama konwencja `yearsRemaining: 0`
      // co dla graczy z wygasłym kontraktem (`contract_market_models.dart`).
      contract: Contract(salary: salary, yearsRemaining: 0),
      state: PlayerState(
        stamina: 100,
        form: (3 + rng.nextInt(6)).toDouble(),
        role: position.defaultAssignedRole,
        seasonsWithTeam: 0,
      ),
      hidden: PlayerHidden(
        injuryProne: injuryProne,
        determination: determination,
        overallProgress: (age <= 26 ? 40 + rng.nextInt(50) : rng.nextInt(30))
            .clamp(0.0, 99.0)
            .toDouble(),
        growthRate: BalanceConfig.defaults.development.baseGrowthRateFor(
          determination,
        ),
        developmentOutcome: outcome,
        developmentCeilingStars: rollDevelopmentCeilingStars(
          potentialStars,
          outcome,
          rng,
        ),
      ),
    );
    return player
        .copyWith(seasonStartOvr: player.overall())
        .recalculatePointValue();
  }

  @override
  int _heightCmFor(Position position, Random rng) {
    final (minH, maxH) = switch (position) {
      Position.gk => (175, 200),
      Position.cb => (175, 200),
      Position.st => (170, 195),
      Position.cdm => (170, 195),
      _ => (160, 190),
    };
    return minH + rng.nextInt(maxH - minH + 1);
  }

  /// Random optimal role for a given position (`data_generation.md`).
  @override
  AssignedRole _randomRoleFor(Position position, Random rng) {
    final roles = rolesForPosition(position);
    return roles[rng.nextInt(roles.length)];
  }
}
