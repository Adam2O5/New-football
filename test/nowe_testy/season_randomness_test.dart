import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/lottery_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/staff_service.dart';

import 'support/game_fixtures.dart';

LeagueState _reload(LeagueState league) => GameSave.fromJson(
  jsonDecode(jsonEncode(saveForLeague(league).toJson()))
      as Map<String, dynamic>,
).leagueState;

void main() {
  test('staff rolls survive restart, service history and team order', () {
    final initial = GameFactory()
        .create(
          const NewGameRequest(
            saveName: 'staff replay',
            playerTeamId: 'team_europe_0',
            seed: fixtureSeed,
          ),
        )
        .leagueState;
    final league = initial.copyWith(
      teams: [
        for (final team in initial.teams)
          team.copyWith(
            staff: TeamStaff(
              scout: team.staff.scout!.copyWith(age: 35),
              doctor: team.staff.doctor!.copyWith(age: 58),
            ),
          ),
      ],
    );
    Map<String, TeamStaff> staffByTeam(LeagueState state) => {
      for (final team in state.teams) team.id: team.staff,
    };
    final service = StaffService(random: Random(9));
    final continuous = service.growthAndRetireTick(
      league,
      saveSeed: fixtureSeed,
    );
    service.growthAndRetireTick(league);
    final replay = StaffService(
      random: Random(987),
    ).growthAndRetireTick(_reload(league), saveSeed: fixtureSeed);
    expect(staffByTeam(replay), staffByTeam(continuous));
    expect(
      staffByTeam(
        service.growthAndRetireTick(
          league.copyWith(teams: league.teams.reversed.toList()),
          saveSeed: fixtureSeed,
        ),
      ),
      staffByTeam(continuous),
    );
    expect(continuous.teams.any((t) => t.staff.doctor == null), isTrue);
    expect(
      continuous.teams.any(
        (t) =>
            t.staff.scout!.attributes !=
            league.teamById(t.id)!.staff.scout!.attributes,
      ),
      isTrue,
    );
  });

  test('player retirement rolls survive restart and player order', () {
    final initial = controllerSave().leagueState;
    final team = initial.playerTeam!;
    final league = initial.updateTeam(
      team.copyWith(
        roster: [
          for (var i = 0; i < team.roster.length; i++)
            team.roster[i].copyWith(age: 35 + i % 5),
        ],
      ),
    );
    List<String> survivors(LeagueState state) =>
        state.playerTeam!.roster.map((p) => p.id).toList()..sort();
    final service = SeasonService(random: Random(9));
    final continuous = service.runPlayerRetirements(
      league,
      saveSeed: fixtureSeed,
    );
    service.runPlayerRetirements(league, saveSeed: 999);
    final replay = SeasonService(
      random: Random(987),
    ).runPlayerRetirements(_reload(league), saveSeed: fixtureSeed);
    expect(survivors(replay), survivors(continuous));
    expect(
      survivors(
        service.runPlayerRetirements(
          league.updateTeam(
            league.playerTeam!.copyWith(
              roster: league.playerTeam!.roster.reversed.toList(),
            ),
          ),
          saveSeed: fixtureSeed,
        ),
      ),
      survivors(continuous),
    );
    expect(survivors(continuous).length, lessThan(team.roster.length));
    expect(continuous.currentSeason.playerRetirementsDone, isTrue);
  });

  test(
    'interactive lottery is seeded, keeps weights and allows injected RNG',
    () {
      final teams = List.generate(10, (i) => Standing(teamId: 'team-$i'));
      final first = LotteryService.computeResults(
        teams,
        saveSeed: fixtureSeed,
        seasonYear: 2026,
      );
      expect(
        LotteryService.computeResults(
          teams,
          saveSeed: fixtureSeed,
          seasonYear: 2026,
        ),
        first,
      );
      expect(
        first.map((r) => r.teamId).toSet(),
        teams.map((t) => t.teamId).toSet(),
      );
      expect(
        first.map((r) => r.assignedPick).toList(),
        List.generate(10, (i) => i + 1),
      );
      expect(first.first.oddsForFirstPick, greaterThan(0));
      expect(
        LotteryService.computeResults(teams, random: Random(7), saveSeed: 1),
        LotteryService.computeResults(teams, random: Random(7), saveSeed: 999),
      );
    },
  );
}
