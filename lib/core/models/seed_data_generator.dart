import 'dart:math';

import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/development.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/seed_data.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';
import 'package:new_football/core/tactics/formation_layout.dart';

class SeedDataGenerator {
  SeedDataGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  LeagueState generateLeague({
    int year = 2026,
    String? playerTeamId,
    int? seed,
  }) {
    final rng = seed != null ? Random(seed) : Random();
    final teams = <Team>[];

    for (var i = 0; i < europeTeams.length; i++) {
      final (city, name) = europeTeams[i];
      teams.add(
        _generateTeam(
          city: city,
          name: name,
          conference: Conference.europe,
          index: i,
          rng: rng,
          isPlayer: playerTeamId != null && i == 0,
          seasonYear: year,
        ),
      );
    }

    for (var i = 0; i < restOfTheWorldTeams.length; i++) {
      final (city, name) = restOfTheWorldTeams[i];
      teams.add(
        _generateTeam(
          city: city,
          name: name,
          conference: Conference.restOfTheWorld,
          index: i + 15,
          rng: rng,
          isPlayer: false,
          seasonYear: year,
        ),
      );
    }

    if (playerTeamId != null) {
      final idx = teams.indexWhere((t) => t.id == playerTeamId);
      if (idx >= 0) {
        teams[idx] = teams[idx].copyWith(ai: null);
      }
    } else {
      teams[0] = teams[0].copyWith(ai: null);
    }

    final actualPlayerTeamId = playerTeamId ?? teams[0].id;

    final standings = [
      ConferenceStandings(
        conference: Conference.europe,
        standings: teams
            .where((t) => t.conference == Conference.europe)
            .map((t) => Standing(teamId: t.id))
            .toList(),
      ),
      ConferenceStandings(
        conference: Conference.restOfTheWorld,
        standings: teams
            .where((t) => t.conference == Conference.restOfTheWorld)
            .map((t) => Standing(teamId: t.id))
            .toList(),
      ),
    ];

    final nextDraftState = DraftState(
      year: year + 1,
      draftClass: generateDraftClass(year: year + 1),
    );
    final tvSchedule = tvCapScheduleFor(currentYear: year, saveSeed: seed ?? 0);

    return LeagueState(
      teams: teams,
      currentSeason: Season(
        year: year,
        standings: standings,
        nextDraftState: nextDraftState,
        nextTvCapResetSeason: tvSchedule.nextTvCapResetSeason,
        nextTvCapIncreasePct: tvSchedule.nextTvCapIncreasePct,
      ),
      playerTeamId: actualPlayerTeamId,
    );
  }

  Team _generateTeam({
    required String city,
    required String name,
    required Conference conference,
    required int index,
    required Random rng,
    required bool isPlayer,
    required int seasonYear,
  }) {
    final teamId = 'team_${conference.name}_$index';
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
  AssignedRole _randomRoleFor(Position position, Random rng) {
    final roles = rolesForPosition(position);
    return roles[rng.nextInt(roles.length)];
  }

  /// Liczba prospektów, przedział OVR i przedział potencjału per kubełek
  /// (`data_generation.md` §„Potencjał i OVR”). Suma liczebności musi
  /// odpowiadać `prospectCount` (domyślnie 120).
  static const List<
    (int count, int ovrMin, int ovrMax, double starMin, double starMax)
  >
  _draftClassOvrTable = [
    (3, 77, 79, 4.0, 5.0),
    (8, 74, 76, 3.5, 4.5),
    (12, 70, 73, 3.5, 4.0),
    (10, 65, 75, 3.0, 4.5),
    (20, 66, 69, 3.0, 3.5),
    (20, 62, 65, 2.5, 3.0),
    (20, 58, 61, 2.0, 2.5),
    (27, 58, 79, 2.0, 5.0),
  ];

  DraftClass generateDraftClass({required int year, int prospectCount = 120}) {
    final ovrTargets =
        <(int ovrMin, int ovrMax, double starMin, double starMax)>[];
    for (final (count, ovrMin, ovrMax, starMin, starMax)
        in _draftClassOvrTable) {
      ovrTargets.addAll(List.filled(count, (ovrMin, ovrMax, starMin, starMax)));
    }
    if (ovrTargets.length != prospectCount) {
      throw StateError(
        'Suma liczebności w _draftClassOvrTable (${ovrTargets.length}) nie '
        'zgadza się z prospectCount ($prospectCount) — zaktualizuj tabelę '
        'zgodnie z data_generation.md.',
      );
    }
    ovrTargets.shuffle(_random);

    final prospects = <Prospect>[];
    for (var i = 0; i < prospectCount; i++) {
      final positions = Position.values.where((p) => p != Position.gk).toList();
      if (i < 3) {
        positions.insert(0, Position.gk);
      }
      final pos = positions[_random.nextInt(positions.length)];

      final (ovrMin, ovrMax, starMin, starMax) = ovrTargets[i];
      final ovr = ovrMin + _random.nextInt(ovrMax - ovrMin + 1);
      final stars = starMin + _random.nextDouble() * (starMax - starMin);
      final roundedStars = (stars * 2).round() / 2.0;

      final nationality =
          Nationality.values[_random.nextInt(Nationality.values.length)];

      prospects.add(
        Prospect(
          id: 'prospect_${year}_$i',
          personality: PlayerPersonality
              .values[_random.nextInt(PlayerPersonality.values.length)],
          name: _generateName(_random, nationality),
          nationality: nationality,
          position: pos,
          age: 18 + _random.nextInt(3),
          optimalRole: _randomRoleFor(pos, _random),
          attributes: _attributesForOvr(pos, ovr, _random),
          scoutGrade: (ovr + _random.nextInt(8) - 4).clamp(30, 99),
          combineScore: (ovr + _random.nextInt(12) - 6).clamp(30, 99),
          potentialStars: roundedStars,
          heightCm: _heightCmFor(pos, _random),
          injuryProne: 1 + _random.nextInt(10),
          determination: 1 + _random.nextInt(10),
        ),
      );
    }
    prospects.sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));
    return DraftClass(year: year, prospects: prospects);
  }

  int _staffCounter = 0;

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

  String _generateName(Random rng, Nationality nationality) {
    final pool = namePools[nationality]!;
    final firstName = pool.firstNames[rng.nextInt(pool.firstNames.length)];
    final lastName = pool.lastNames[rng.nextInt(pool.lastNames.length)];
    return '$firstName $lastName';
  }
}
