part of 'seed_data_generator.dart';

mixin _SeedPlayerGeneration on _SeedGenerationShared {
  /// Offset (`lo`, `hi`) względem docelowego OVR `X` per waga atrybutu
  /// pozycji (`data_generation.md` §„Wagi atrybutów pozycji"). Klucz to
  /// waga × 100, żeby uniknąć porównań liczb zmiennoprzecinkowych.

  /// Losuje wartość atrybutu wg wagi pozycji, względem docelowego OVR `X`
  /// (`data_generation.md` §„Generowanie OVR").
  int _attrForWeight(int targetOvr, double weight, Random rng) {
    final key = (weight * 100).round();
    final range = balance.seed.attributeOffsets[key];
    if (range == null) {
      throw StateError(
        'Brak zdefiniowanego zakresu offsetu dla wagi $weight — '
        'zaktualizuj balance.seed.attributeOffsets zgodnie z data_generation.md.',
      );
    }
    final (lo, hi) = range;
    return balance.player.clampAttribute(
      targetOvr + lo + rng.nextInt(hi - lo + 1),
    );
  }

  /// Atrybut bramkarza: waga 1/6 każdego atrybutu → zakres X-2…X+2
  /// (`data_generation.md` §„Bramkarze").
  int _gkAttrForOvr(int targetOvr, Random rng) => balance.player.clampAttribute(
    targetOvr +
        balance.seed.gkAttributeOffsetMin +
        rng.nextInt(
          balance.seed.gkAttributeOffsetMax -
              balance.seed.gkAttributeOffsetMin +
              1,
        ),
  );

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
    final weights = balance.player.outfieldOverallWeights[position];
    if (weights == null) {
      throw StateError(
        'Brak wag atrybutów dla pozycji $position w '
        'balance.player.outfieldOverallWeights.',
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

  double _rollPotentialStars(int age, int ovr, Random rng) {
    final ageRow = balance.seed.potentialProfiles
        .firstWhere(
          (row) => age <= row.$1,
          orElse: () => balance.seed.potentialProfiles.last,
        )
        .$2;
    final (_, starMin, starMax) = ageRow.firstWhere(
      (cell) => ovr <= cell.$1,
      orElse: () => ageRow.last,
    );
    final stars = starMin + rng.nextDouble() * (starMax - starMin);
    return (stars * balance.seed.potentialRoundingSteps).round() /
        balance.seed.potentialRoundingSteps;
  }

  /// Pensja wg wzoru z `salary_cap.md`/`data_generation.md`:
  /// `minSalary + (maxSalary - minSalary) * (((OVR-50)*2)/100)^3`.
  int _rollSalary(int ovr) {
    final cap = balance.salaryCap;
    final t =
        (((ovr - balance.seed.salaryOvrBase) * balance.seed.salaryOvrScale) /
                balance.seed.salaryOvrDivisor)
            .clamp(0.0, 1.0);
    final salary =
        cap.minSalary +
        (cap.maxSalary - cap.minSalary) * pow(t, balance.seed.salaryExponent);
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

    final injuryProne =
        balance.player.traitMin +
        rng.nextInt(balance.player.traitMax - balance.player.traitMin + 1);
    final determination =
        balance.player.traitMin +
        rng.nextInt(balance.player.traitMax - balance.player.traitMin + 1);
    final heightCm = _heightCmFor(position, rng);
    final outcome = rollDevelopmentOutcome(determination, rng, balance);

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
        yearsRemaining:
            balance.seed.initialContractYearsMin +
            rng.nextInt(
              balance.seed.initialContractYearsMax -
                  balance.seed.initialContractYearsMin +
                  1,
            ),
        hasBirdRights: false,
      ),
      state: PlayerState(
        stamina: balance.player.initialStamina,
        form:
            (balance.seed.playerFormMin +
                    rng.nextInt(
                      balance.seed.playerFormMax -
                          balance.seed.playerFormMin +
                          1,
                    ))
                .toDouble(),
        role: position.defaultAssignedRole,
        seasonsWithTeam: 0,
      ),
      hidden: PlayerHidden(
        injuryProne: injuryProne,
        determination: determination,
        overallProgress:
            (age <= balance.seed.youngProgressMaxAge
                    ? balance.seed.youngProgressMin +
                          rng.nextInt(
                            balance.seed.youngProgressMax -
                                balance.seed.youngProgressMin +
                                1,
                          )
                    : balance.seed.matureProgressMin +
                          rng.nextInt(
                            balance.seed.matureProgressMax -
                                balance.seed.matureProgressMin +
                                1,
                          ))
                .clamp(
                  balance.seed.initialProgressMin,
                  balance.seed.initialProgressMax,
                )
                .toDouble(),
        growthRate: balance.development.baseGrowthRateFor(determination),
        developmentOutcome: outcome,
        developmentCeilingStars: rollDevelopmentCeilingStars(
          roundedStars,
          outcome,
          rng,
          balance,
        ),
      ),
    );
    return player
        .copyWith(seasonStartOvr: player.overall(balance))
        .recalculatePointValue(balance);
  }

  /// Startowa pula wolnych agentów dostępnych od pierwszego dnia save'a
  /// (`data_generation.md` §„Wolni agenci na starcie save'a"): 25–35 graczy,
  /// OVR 73–78, wiek 22–32, potencjał 2,5–4,0★. Pozycja, narodowość, rola,
  /// temperament itd. są w pełni losowe (możliwe 0 bramkarzy w puli).
  List<Player> generateFreeAgentPlayers({required Random rng}) {
    final count =
        balance.seed.freeAgentCountMin +
        rng.nextInt(
          balance.seed.freeAgentCountMax - balance.seed.freeAgentCountMin + 1,
        ); // 25..35
    return List.generate(count, (i) {
      final position = Position.values[rng.nextInt(Position.values.length)];
      final targetOvr =
          balance.seed.freeAgentOvrMin +
          rng.nextInt(
            balance.seed.freeAgentOvrMax - balance.seed.freeAgentOvrMin + 1,
          ); // 73..78
      final age =
          balance.seed.freeAgentAgeMin +
          rng.nextInt(
            balance.seed.freeAgentAgeMax - balance.seed.freeAgentAgeMin + 1,
          ); // 22..32
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
  /// `balance.seed.potentialProfiles` (wiek/OVR) używanej dla rosterów startowych i draftu
  /// (`data_generation.md` §„Wolni agenci na starcie save'a").
  double _rollFreeAgentPotentialStars(Random rng) {
    final starMin = balance.seed.freeAgentPotentialMin;
    final starMax = balance.seed.freeAgentPotentialMax;
    final stars = starMin + rng.nextDouble() * (starMax - starMin);
    return (stars * balance.seed.potentialRoundingSteps).round() /
        balance.seed.potentialRoundingSteps;
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

    final injuryProne =
        balance.player.traitMin +
        rng.nextInt(balance.player.traitMax - balance.player.traitMin + 1);
    final determination =
        balance.player.traitMin +
        rng.nextInt(balance.player.traitMax - balance.player.traitMin + 1);
    final heightCm = _heightCmFor(position, rng);
    final outcome = rollDevelopmentOutcome(determination, rng, balance);

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
        stamina: balance.player.initialStamina,
        form:
            (balance.seed.playerFormMin +
                    rng.nextInt(
                      balance.seed.playerFormMax -
                          balance.seed.playerFormMin +
                          1,
                    ))
                .toDouble(),
        role: position.defaultAssignedRole,
        seasonsWithTeam: 0,
      ),
      hidden: PlayerHidden(
        injuryProne: injuryProne,
        determination: determination,
        overallProgress:
            (age <= balance.seed.youngProgressMaxAge
                    ? balance.seed.youngProgressMin +
                          rng.nextInt(
                            balance.seed.youngProgressMax -
                                balance.seed.youngProgressMin +
                                1,
                          )
                    : balance.seed.matureProgressMin +
                          rng.nextInt(
                            balance.seed.matureProgressMax -
                                balance.seed.matureProgressMin +
                                1,
                          ))
                .clamp(
                  balance.seed.initialProgressMin,
                  balance.seed.initialProgressMax,
                )
                .toDouble(),
        growthRate: balance.development.baseGrowthRateFor(determination),
        developmentOutcome: outcome,
        developmentCeilingStars: rollDevelopmentCeilingStars(
          potentialStars,
          outcome,
          rng,
          balance,
        ),
      ),
    );
    return player
        .copyWith(seasonStartOvr: player.overall(balance))
        .recalculatePointValue(balance);
  }

  @override
  int _heightCmFor(Position position, Random rng) {
    final (minH, maxH) =
        balance.seed.heightRanges[position] ?? balance.seed.defaultHeightRange;
    return minH + rng.nextInt(maxH - minH + 1);
  }

  /// Random optimal role for a given position (`data_generation.md`).
  @override
  AssignedRole _randomRoleFor(Position position, Random rng) {
    final roles = rolesForPosition(position);
    return roles[rng.nextInt(roles.length)];
  }
}
