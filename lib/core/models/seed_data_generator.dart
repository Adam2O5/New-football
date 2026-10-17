import 'dart:math';
import 'package:new_football/core/random/seeds.dart';

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
import 'package:new_football/core/services/mock_draft_service.dart';
import 'package:new_football/core/services/contract_period_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';
import 'package:new_football/core/tactics/formation_layout.dart';

part 'seed_team_generation.dart';
part 'seed_player_generation.dart';
part 'seed_draft_generation.dart';
part 'seed_staff_generation.dart';

class SeedDataGenerator
    with
        _SeedGenerationShared,
        _SeedTeamGeneration,
        _SeedPlayerGeneration,
        _SeedDraftGeneration,
        _SeedStaffGeneration {
  SeedDataGenerator({
    Random? random,
    this.balance = BalanceConfig.defaults,
    MockDraftService? mockDraftService,
  }) : _random = random ?? Random(),
       _mockDraftService =
           mockDraftService ?? MockDraftService(balance: balance);

  @override
  final Random _random;
  final BalanceConfig balance;
  final MockDraftService _mockDraftService;

  LeagueState generateLeague({
    int year = 2026,
    String? playerTeamId,
    int? seed,
  }) {
    final rng = seed != null
        ? Random(seasonEventSeed(seed, year, 'rosters'))
        : _random;
    _staffCounter = 0;
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
          isPlayer: false,
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
          index: i + europeTeams.length,
          rng: rng,
          isPlayer: false,
          seasonYear: year,
        ),
      );
    }

    final actualPlayerTeamId = playerTeamId ?? teams[0].id;
    final playerIndex = teams.indexWhere((t) => t.id == actualPlayerTeamId);
    if (playerIndex < 0) {
      throw ArgumentError.value(playerTeamId, 'playerTeamId', 'Unknown team');
    }
    teams[playerIndex] = teams[playerIndex].copyWith(ai: null);

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

    final year0Class = generateDraftClass(year: year, seed: seed);
    final trueBoard = _mockDraftService.trueBoard(year0Class.prospects);
    final draftState = DraftState(
      year: year,
      draftClass: year0Class,
      mockDraftBoard: _mockDraftService.generateInitialMock(
        trueBoard,
        seed: seed,
        seasonYear: year,
      ),
    );
    final tvSchedule = tvCapScheduleFor(currentYear: year, saveSeed: seed ?? 0);

    return ContractPeriodService(balance: balance).normalizeLeague(
      LeagueState(
        teams: teams,
        currentSeason: Season(
          year: year,
          standings: standings,
          draftState: draftState,
          nextTvCapResetSeason: tvSchedule.nextTvCapResetSeason,
          nextTvCapIncreasePct: tvSchedule.nextTvCapIncreasePct,
        ),
        playerTeamId: actualPlayerTeamId,
      ),
      initial: true,
    );
  }

  @override
  int _staffCounter = 0;

  @override
  String _generateName(Random rng, Nationality nationality) {
    final pool = namePools[nationality]!;
    final firstName = pool.firstNames[rng.nextInt(pool.firstNames.length)];
    final lastName = pool.lastNames[rng.nextInt(pool.lastNames.length)];
    return '$firstName $lastName';
  }
}

mixin _SeedGenerationShared {
  Random get _random;

  PlayerAttributes _attributesForOvr(
    Position position,
    int targetOvr,
    Random rng,
  );

  Player _generatePlayer({
    required String teamId,
    required Position position,
    required int targetOvr,
    required int age,
    required Random rng,
    required int index,
  });

  int _heightCmFor(Position position, Random rng);

  AssignedRole _randomRoleFor(Position position, Random rng);

  int get _staffCounter;

  set _staffCounter(int value);

  String _generateName(Random rng, Nationality nationality);
}
