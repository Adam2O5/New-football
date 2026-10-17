part of 'seed_data_generator.dart';

mixin _SeedTeamGeneration on _SeedGenerationShared {
  Team _generateTeam({
    required String city,
    required String name,
    required Conference conference,
    required int index,
    required Random rng,
    required bool isPlayer,
    required int seasonYear,
  }) {
    final teamId = seedTeamId(conference, index);
    final formation = Formation.values[rng.nextInt(Formation.values.length)];
    final roster = _generateRoster(teamId, rng, formation: formation);

    final payroll = roster.fold<int>(0, (s, p) => s + p.contract.salary);

    return Team(
      id: teamId,
      name: name,
      city: city,
      conference: conference,
      roster: roster,
      finance: TeamFinance(totalPayroll: payroll),
      tactics: TacticsSetup(formation: formation),
      lineupPlayerIds: roster.take(11).map((p) => p.id).toList(),
      benchPlayerIds: roster.skip(11).take(7).map((p) => p.id).toList(),
      ownedPicks: _generateOwnedPicks(teamId, seasonYear),
      ai: isPlayer ? null : const TeamAiConfig(),
    );
  }

  /// Startowa pula przyszłych, handlowalnych picków drużyny: najbliższe
  /// 7 roczników × 3 rundy (`docs/trade_rules.md` — max 7 lat w przód).
  /// `pickNumber` jest `null` do czasu loterii/budowy `DraftState.order`
  /// dla danego roku (`SeasonService.runLottery`).
  List<DraftPick> _generateOwnedPicks(String teamId, int seasonYear) {
    final picks = <DraftPick>[];
    for (var y = seasonYear + 1; y <= seasonYear + 7; y++) {
      for (var round = 1; round <= 3; round++) {
        final pick = DraftPick(
          id: 'pick_${teamId}_${y}_r$round',
          year: y,
          round: round,
          teamId: teamId,
          originalTeamId: teamId,
        );
        picks.add(pick.recalculateTradeValue(currentYear: seasonYear));
      }
    }
    return picks;
  }

  /// OVR i przedział wieku per slot rosteru startowego, posortowane malejąco
  /// wg OVR (`data_generation.md` §„Generowanie zawodników na początku save'a").
  /// Slot `i` tej tabeli odpowiada slotowi `i` z `_buildRosterPositions`,
  /// więc najsilniejsi gracze trafiają na początek listy i stają się
  /// startowym lineupem (`roster.take(11)`).
  static const List<(int ovr, int ageMin, int ageMax)> _seedRosterOvrAgeTable =
      [
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

  List<Player> _generateRoster(
    String teamId,
    Random rng, {
    required Formation formation,
  }) {
    final positions = _buildRosterPositions(formation);

    if (positions.length != _seedRosterOvrAgeTable.length) {
      throw StateError(
        'Liczba slotów rosteru (${positions.length}) dla formacji $formation '
        'nie zgadza się z tabelą OVR/wiek '
        '(${_seedRosterOvrAgeTable.length}) z data_generation.md.',
      );
    }

    return List.generate(positions.length, (i) {
      final pos = positions[i];
      final (ovr, ageMin, ageMax) = _seedRosterOvrAgeTable[i];
      final age = ageMin + rng.nextInt(ageMax - ageMin + 1);
      return _generatePlayer(
        teamId: teamId,
        position: pos,
        targetOvr: ovr,
        age: age,
        rng: rng,
        index: i,
      );
    });
  }

  List<Position> _buildRosterPositions(Formation formation) {
    final formationPositions = _positionsForFormation(formation);

    return [
      ...formationPositions,
      ...formationPositions,
      Position.gk,
      Position.cb,
      Position.cm,
      Position.st,
    ];
  }

  List<Position> _positionsForFormation(Formation formation) {
    return FormationLayout.of(
      formation,
    ).slots.map((slot) => slot.position).toList();
  }
}
