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
      atmosphere: balance.chemistry.initialAtmosphere,
      chemistry: balance.chemistry.initialChemistry,
      finance: TeamFinance(
        totalPayroll: payroll,
        salaryCap: balance.salaryCap.salaryCap,
        firstApron: balance.salaryCap.firstApron,
        secondApron: balance.salaryCap.secondApron,
        midLevelExceptionAmount: balance.salaryCap.midLevelException,
        cashBalance: balance.cash.startingCash,
      ),
      tactics: TacticsSetup(
        formation: formation,
        cornersAttack: balance.tactics.initialCornersAttack,
        cornersDefense: balance.tactics.initialCornersDefense,
        freeKicks: balance.tactics.initialFreeKicks,
        penalties: balance.tactics.initialPenalties,
      ),
      lineupPlayerIds: roster
          .take(balance.roster.startingXi)
          .map((p) => p.id)
          .toList(),
      benchPlayerIds: roster
          .skip(balance.roster.startingXi)
          .take(balance.roster.benchSize)
          .map((p) => p.id)
          .toList(),
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
    for (
      var y = seasonYear + 1;
      y <= seasonYear + balance.salaryCap.maxPickYearsAhead;
      y++
    ) {
      for (var round = 1; round <= balance.draft.rounds; round++) {
        final pick = DraftPick(
          id: 'pick_${teamId}_${y}_r$round',
          year: y,
          round: round,
          teamId: teamId,
          originalTeamId: teamId,
        );
        picks.add(
          pick.recalculateTradeValue(currentYear: seasonYear, balance: balance),
        );
      }
    }
    return picks;
  }

  /// OVR i przedział wieku per slot rosteru startowego, posortowane malejąco
  /// wg OVR (`data_generation.md` §„Generowanie zawodników na początku save'a").
  /// Slot `i` tej tabeli odpowiada slotowi `i` z `_buildRosterPositions`,
  /// więc najsilniejsi gracze trafiają na początek listy i stają się
  /// startowym lineupem (`roster.take(balance.roster.startingXi)`).
  List<Player> _generateRoster(
    String teamId,
    Random rng, {
    required Formation formation,
  }) {
    final positions = _buildRosterPositions(formation);

    if (positions.length != balance.seed.rosterProfiles.length ||
        positions.length != balance.roster.seedSize) {
      throw StateError(
        'Liczba slotów rosteru (${positions.length}) dla formacji $formation, '
        'profili OVR/wiek (${balance.seed.rosterProfiles.length}) i '
        'roster.seedSize (${balance.roster.seedSize}) musi być zgodna.',
      );
    }

    return List.generate(positions.length, (i) {
      final pos = positions[i];
      final (ovr, ageMin, ageMax) = balance.seed.rosterProfiles[i];
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
      for (var i = 0; i < balance.seed.rosterFormationCopies; i++)
        ...formationPositions,
      ...balance.seed.rosterExtraPositions,
    ];
  }

  List<Position> _positionsForFormation(Formation formation) {
    return FormationLayout.of(
      formation,
    ).slots.map((slot) => slot.position).toList();
  }
}
