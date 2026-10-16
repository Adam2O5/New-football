import 'dart:convert';
import 'dart:io';

import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/prospect_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';

/// Separate VM entry point: stdout is domain data, without wall-clock metadata.
void main(List<String> arguments) {
  final seed = int.parse(arguments.first);
  final league = arguments.length > 1
      ? GameSave.fromJson(
          jsonDecode(File(arguments[1]).readAsStringSync())
              as Map<String, dynamic>,
        ).leagueState
      : SeedDataGenerator().generateLeague(seed: seed);
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
    }),
  );
}
