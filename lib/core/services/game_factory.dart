import 'dart:math';

import 'package:uuid/uuid.dart';

import 'package:new_football/core/ai/team_ai_service.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/league_strength_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/models/staff.dart';

class NewGameRequest {
  const NewGameRequest({
    required this.saveName,
    required this.playerTeamId,
    this.seasonYear = 2026,
    this.seed,
  });

  final String saveName;
  final String playerTeamId;
  final int seasonYear;
  final int? seed;
}

class GameFactory {
  GameFactory({SeedDataGenerator? seedGenerator})
    : _seedGenerator = seedGenerator ?? SeedDataGenerator();

  final SeedDataGenerator _seedGenerator;
  final _uuid = const Uuid();

  List<({String id, String name, String city, Conference conference})>
  previewTeams() {
    final league = _seedGenerator.generateLeague(year: 2026, seed: 1);
    return league.teams
        .map(
          (t) =>
              (id: t.id, name: t.name, city: t.city, conference: t.conference),
        )
        .toList();
  }

  GameSave create(NewGameRequest request) {
    // Generate the seed once so the initial world and every later match share
    // the same persisted deterministic root, even when the request omitted it.
    final saveSeed = request.seed ?? Random().nextInt(1 << 32);
    var league = _seedGenerator.generateLeague(
      year: request.seasonYear,
      playerTeamId: request.playerTeamId,
      seed: saveSeed,
    );

    final schedule = const ScheduleGenerator().generateDoubleRoundRobin(
      league.teams.map((t) => t.id).toList(),
    );

    final ai = TeamAiService();
    var teams = league.teams.map(ai.autoSelectLineup).toList();

    final staffRng = Random(saveSeed);
    teams = teams.map((t) => _seedInitialStaff(t, staffRng)).toList();
    final staffPool = _seedGenerator
        .generateStaffPool(90, random: staffRng)
        .map(
          (m) => m.copyWith(
            contract: null, // free agents: no contract until hired
          ),
        )
        .toList();

    league = league.copyWith(
      teams: teams,
      staffFreeAgents: staffPool,
      currentWeek: 1,
      currentDay: 1,
      currentRound: 0,
      currentSeason: league.currentSeason.copyWith(
        phase: SeasonPhase.regular,
        schedule: schedule,
      ),
    );

    // Initial strength table — no hysteresis on first calculation.
    final strengthService = const LeagueStrengthService();
    final strengthTable = strengthService.calculate(league, week: 1, day: 1);
    league = league.copyWith(strengthTable: strengthTable);

    final playerTeam = league.playerTeam;
    final now = DateTime.now();
    return GameSave(
      meta: GameSaveMeta(
        id: _uuid.v4(),
        name: request.saveName,
        createdAt: now,
        updatedAt: now,
        seasonYear: request.seasonYear,
        phase: SeasonPhase.regular,
        playerTeamName: playerTeam?.name,
        schemaVersion: SaveSchema.currentVersion,
      ),
      leagueState: league,
      saveSeed: saveSeed,
      schemaVersion: SaveSchema.currentVersion,
    );
  }

  /// Starting squads only have some slots filled (`docs/staff_rules.md` §3:
  /// hiring all 6 elite at once is not achievable via market generation).
  /// Startowy sztab drużyny (`data_generation.md` §„Generowanie na początku
  /// save'a"): wszystkie 6 ról obsadzone, ustalony rozkład gwiazdek/pensji/
  /// długości kontraktu przydzielony do losowo przetasowanych ról.
  static const List<(double stars, int years, int salary)>
  _initialStaffDistribution = [
    (2.0, 1, 750000),
    (2.0, 1, 750000),
    (2.0, 1, 750000),
    (2.5, 1, 1000000),
    (3.0, 2, 1500000),
    (3.5, 2, 2000000),
  ];

  Team _seedInitialStaff(Team team, Random rng) {
    var staff = team.staff;
    final roles = StaffRole.values.toList()..shuffle(rng);
    for (var i = 0; i < roles.length; i++) {
      final (stars, years, salary) = _initialStaffDistribution[i];
      final member = _seedGenerator.generateStaffMemberAtStars(
        rng,
        roles[i],
        stars,
      );
      final hired = member.copyWith(
        contract: StaffContract(salary: salary, yearsRemaining: years),
      );
      staff = staff.withMember(roles[i], hired);
    }
    return team.copyWith(staff: staff);
  }
}
