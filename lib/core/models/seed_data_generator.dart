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

    return LeagueState(
      teams: teams,
      currentSeason: Season(
        year: year,
        standings: standings,
        nextDraftState: nextDraftState,
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
    final roster = _generateRoster(
      teamId,
      rng,
      strengthBase: 55 + rng.nextInt(20),
    );

    final payroll = roster.fold<int>(0, (s, p) => s + p.contract.salary);

    return Team(
      id: teamId,
      name: name,
      city: city,
      conference: conference,
      roster: roster,
      finance: TeamFinance(totalPayroll: payroll),
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

  List<Player> _generateRoster(
    String teamId,
    Random rng, {
    required int strengthBase,
  }) {
    final formation = Formation.values[rng.nextInt(Formation.values.length)];
    final positions = _buildRosterPositions(formation);

    return positions.asMap().entries.map((entry) {
      final pos = entry.value;
      final variance = rng.nextInt(15) - 7;
      final base = (strengthBase + variance).clamp(40, 95);
      return _generatePlayer(
        teamId: teamId,
        position: pos,
        base: base,
        rng: rng,
        index: entry.key,
      );
    }).toList();
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

  Player _generatePlayer({
    required String teamId,
    required Position position,
    required int base,
    required Random rng,
    required int index,
  }) {
    final id = '${teamId}_player_$index';
    final nationality =
        Nationality.values[rng.nextInt(Nationality.values.length)];
    final name = _generateName(rng, nationality);
    final age = 19 + rng.nextInt(17);

    final PlayerAttributes attrs;
    if (position == Position.gk) {
      attrs = PlayerAttributes.goalkeeper(
        stats: GoalkeeperAttributes(
          diving: _attr(base, rng, boost: 5),
          handling: _attr(base, rng, boost: 5),
          kicking: _attr(base, rng),
          reflexes: _attr(base, rng, boost: 5),
          speed: _attr(base, rng),
          positioning: _attr(base, rng, boost: 3),
        ),
      );
    } else {
      attrs = PlayerAttributes.outfield(
        stats: FieldPlayerAttributes(
          pace: _attr(
            base,
            rng,
            boost: position.code == 'LW' || position.code == 'RW' ? 5 : 0,
          ),
          shooting: _attr(base, rng, boost: position.code == 'ST' ? 5 : 0),
          passing: _attr(base, rng),
          dribbling: _attr(base, rng),
          defending: _attr(base, rng, boost: position.code == 'CB' ? 5 : 0),
          physicality: _attr(base, rng),
        ),
      );
    }

    // Keep a ~25-player roster comfortably under the 300M salary cap on
    // average (elite ~90+ OVR ≈ 20-27M, replacement-level ≈ 1-1.5M).
    final salary = (1000000 + (base - 40) * 350000 + rng.nextInt(300000)).clamp(
      500000,
      80000000,
    );

    final potentialStars = ((base - 50) / 10).clamp(0.5, 5.0);
    final roundedStars = (potentialStars * 2).round() / 2.0;

    final injuryProne = 1 + rng.nextInt(10);
    final determination = 1 + rng.nextInt(10);
    final heightCm = _heightCmFor(position, rng);

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
        hasBirdRights: rng.nextBool(),
      ),
      state: PlayerState(
        stamina: 85 + rng.nextInt(15),
        form: (1 + rng.nextInt(10)).toDouble(),
        role: position.defaultAssignedRole,
        seasonsWithTeam: rng.nextInt(5),
      ),
      hidden: PlayerHidden(
        injuryProne: injuryProne,
        determination: determination,
        overallProgress: (age <= 26 ? 40 + rng.nextInt(50) : rng.nextInt(30))
            .clamp(0, 99),
        growthRate: (0.7 + rng.nextDouble() * 0.8).clamp(0.0, 2.0),
        developmentOutcome: rollDevelopmentOutcome(determination, rng),
      ),
    );
    return player.recalculatePointValue();
  }

  int _heightCmFor(Position position, Random rng) {
    final (minH, maxH) = switch (position) {
      Position.gk => (185, 200),
      Position.cb => (180, 195),
      Position.st => (175, 193),
      Position.cdm => (175, 190),
      _ => (168, 188),
    };
    return minH + rng.nextInt(maxH - minH + 1);
  }

  int _attr(int base, Random rng, {int boost = 0}) =>
      (base + boost + rng.nextInt(10) - 5).clamp(50, 99);

  /// Random optimal role for a given position (`data_generation.md`).
  AssignedRole _randomRoleFor(Position position, Random rng) {
    final roles = rolesForPosition(position);
    return roles[rng.nextInt(roles.length)];
  }

  DraftClass generateDraftClass({required int year, int prospectCount = 120}) {
    final prospects = <Prospect>[];
    for (var i = 0; i < prospectCount; i++) {
      final positions = Position.values.where((p) => p != Position.gk).toList();
      if (i < 3) {
        positions.insert(0, Position.gk);
      }
      final pos = positions[_random.nextInt(positions.length)];
      final base = (90 - i * 0.8 + _random.nextInt(10) - 5).round().clamp(
        50,
        95,
      );
      final nationality =
          Nationality.values[_random.nextInt(Nationality.values.length)];
      final potentialStars = ((base - 50) / 10).clamp(0.5, 5.0);
      final roundedStars = (potentialStars * 2).round() / 2.0;

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
          attributes: pos == Position.gk
              ? PlayerAttributes.goalkeeper(
                  stats: GoalkeeperAttributes(
                    diving: _attr(base, _random, boost: 5),
                    handling: _attr(base, _random, boost: 5),
                    kicking: _attr(base, _random),
                    reflexes: _attr(base, _random, boost: 5),
                    speed: _attr(base, _random),
                    positioning: _attr(base, _random, boost: 3),
                  ),
                )
              : PlayerAttributes.outfield(
                  stats: FieldPlayerAttributes(
                    pace: _attr(base, _random),
                    shooting: _attr(base, _random),
                    passing: _attr(base, _random),
                    dribbling: _attr(base, _random),
                    defending: _attr(base, _random),
                    physicality: _attr(base, _random),
                  ),
                ),
          scoutGrade: (base + _random.nextInt(8) - 4).clamp(30, 99),
          combineScore: (base + _random.nextInt(12) - 6).clamp(30, 99),
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

  /// Generates one free/unhired staff member (`docs/staff_rules.md` §1–2).
  StaffMember generateStaffMember(
    Random rng,
    StaffRole role, {
    BalanceConfig balance = BalanceConfig.defaults,
  }) {
    final nationality =
        Nationality.values[rng.nextInt(Nationality.values.length)];
    final name = _generateName(rng, nationality);
    final age = 35 + rng.nextInt(26); // 35–60
    final b = balance.staff;

    double star() {
      final steps = ((b.starMax - b.starMin) / b.starStep).round();
      // Skewed towards 1.5–3★: elite (6/6 max) staff should be rare.
      final roll = rng.nextDouble() * rng.nextDouble();
      final step = (roll * steps).round().clamp(0, steps);
      return b.starMin + step * b.starStep;
    }

    final attrs = switch (role) {
      StaffRole.headCoach => StaffAttributes(
        tactics: star(),
        motivation: star(),
        development: star(),
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
