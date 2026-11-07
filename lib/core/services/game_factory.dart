import 'dart:math';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/tactics/lineup_slots.dart';
import 'package:new_football/core/random/seeds.dart';

import 'package:uuid/uuid.dart';

import 'package:new_football/core/ai/team_ai_service.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/seed_clubs.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/league_strength_service.dart';
import 'package:new_football/core/services/contract_period_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/models/staff.dart';

class NewGameRequest {
  const NewGameRequest({
    required this.saveName,
    required this.playerTeamId,
    this.seasonYear,
    this.seed,
  });

  final String saveName;
  final String playerTeamId;
  final int? seasonYear;
  final int? seed;
}

class GameFactory {
  GameFactory({
    this.balance = BalanceConfig.defaults,
    SeedDataGenerator? seedGenerator,
  }) : _seedGenerator = seedGenerator ?? SeedDataGenerator(balance: balance);

  final BalanceConfig balance;

  final SeedDataGenerator _seedGenerator;
  final _uuid = const Uuid();

  List<({String id, String name, String city, Conference conference})>
  previewTeams() => seedTeamCatalog;

  GameSave create(NewGameRequest request) {
    final seasonYear = request.seasonYear ?? balance.seed.startYear;
    // Generate the seed once so the initial world and every later match share
    // the same persisted deterministic root, even when the request omitted it.
    final saveSeed = request.seed ?? Random().nextInt(1 << 32);
    var league = _seedGenerator.generateLeague(
      year: seasonYear,
      playerTeamId: request.playerTeamId,
      seed: saveSeed,
    );

    final schedule = const ScheduleGenerator().generateDoubleRoundRobin(
      league.teams.map((t) => t.id).toList(),
    );

    final ai = TeamAiService(balance: balance);
    var teams = league.teams.map(ai.autoSelectLineup).toList();

    final staffRng = Random(
      seasonEventSeed(saveSeed, seasonYear, 'initial-staff'),
    );
    teams = teams.map((t) => _seedInitialStaff(t, staffRng)).toList();
    final staffPool = _seedGenerator
        .generateStaffPool(balance.seed.staffPoolSize, random: staffRng)
        .map(
          (m) => m.copyWith(
            contract: null, // free agents: no contract until hired
          ),
        )
        .toList();

    final freeAgentRng = Random(
      seasonEventSeed(saveSeed, seasonYear, 'free-agents'),
    );
    final freeAgentPlayers = _seedGenerator.generateFreeAgentPlayers(
      rng: freeAgentRng,
    );

    league = league.copyWith(
      teams: teams,
      staffFreeAgents: staffPool,
      freeAgents: freeAgentPlayers,
      currentWeek: 1,
      currentDay: 1,
      currentRound: 0,
      currentSeason: league.currentSeason.copyWith(
        phase: SeasonPhase.regular,
        schedule: schedule,
      ),
    );

    // Initial strength table — no hysteresis on first calculation.
    final strengthService = LeagueStrengthService(balance: balance);
    final strengthTable = strengthService.calculate(league, week: 1, day: 1);
    league = league.copyWith(strengthTable: strengthTable);
    league = ContractPeriodService(
      balance: balance,
    ).normalizeLeague(league, initial: true);
    league = reconcileLeagueLineups(league);

    final playerTeam = league.playerTeam;
    final now = DateTime.now();
    return GameSave(
      meta: GameSaveMeta(
        id: _uuid.v4(),
        name: request.saveName,
        createdAt: now,
        updatedAt: now,
        seasonYear: seasonYear,
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
  Team _seedInitialStaff(Team team, Random rng) {
    var staff = team.staff;
    final roles = StaffRole.values.toList()..shuffle(rng);
    for (var i = 0; i < roles.length; i++) {
      final (stars, years, salary) = balance.seed.initialStaff[i];
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
