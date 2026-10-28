import 'dart:convert';
import 'dart:io';

import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/prospect_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/services/season_service.dart';

/// Separate VM entry point: stdout is domain data, without wall-clock metadata.
void main(List<String> arguments) {
  final seed = int.parse(arguments.first);
  final league = arguments.length > 1
      ? GameSave.fromJson(
          jsonDecode(File(arguments[1]).readAsStringSync())
              as Map<String, dynamic>,
        ).leagueState
      : SeedDataGenerator().generateLeague(seed: seed);
  final lottery = SeasonService().runLottery(league, saveSeed: seed);
  // Exercise probabilistic retirement ages without playing matches or AI turns.
  final retirementInput = league.copyWith(
    teams: [
      for (final team in league.teams)
        team.copyWith(
          roster: [
            for (var i = 0; i < team.roster.length; i++)
              team.roster[i].copyWith(age: 35 + i % 5),
          ],
        ),
    ],
    freeAgents: [
      for (var i = 0; i < league.freeAgents.length; i++)
        league.freeAgents[i].copyWith(age: 35 + i % 5),
    ],
  );
  final retired = SeasonService().runPlayerRetirements(
    retirementInput,
    saveSeed: seed,
  );
  stdout.writeln(
    jsonEncode({
      'rosters': [
        for (final team in league.teams)
          team.roster.map((p) => p.toJson()).toList(),
      ],
      'class': league.currentSeason.draftState!.draftClass.toJson(),
      'next': ProspectService()
          .generateNextDraftClass(
            currentYear: league.currentSeason.year,
            seed: seed,
          )
          .toJson(),
      'dates': [
        for (final week in [1, 2, 15, 29, 32, 43])
          {
            'week': week,
            'midweek': matchDaysForWeek(week, seed: seed).midweekDay,
            'weekend': matchDaysForWeek(week, seed: seed).weekendDay,
          },
      ],
      'lottery': lottery.currentSeason.draftState!.lotteryResults
          .map((result) => result.toJson())
          .toList(),
      'draftOrder': lottery.currentSeason.draftState!.order
          .map((pick) => pick.toJson())
          .toList(),
      'retirement': {
        'done': retired.currentSeason.playerRetirementsDone,
        'rosters': [
          for (final team in retired.teams)
            team.roster.map((player) => player.id).toList(),
        ],
        'freeAgents': retired.freeAgents.map((player) => player.id).toList(),
      },
    }),
  );
}
