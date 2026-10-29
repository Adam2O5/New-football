@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/generation/initial_roster_assertions.dart';

void main() {
  test(
    'preserves manual formation, lineup, and tactics serialization boundaries',
    () {
      final game = GameFactory().create(
        const NewGameRequest(
          saveName: 'initial-roster-manual-boundary',
          playerTeamId: 'team_europe_0',
          seed: 909,
        ),
      );
      final originalTeam = game.leagueState.playerTeam!;
      final alternateFormation = Formation.values.firstWhere(
        (formation) => formation != originalTeam.tactics.formation,
      );
      final manualLineup = [...originalTeam.lineupPlayerIds];
      final firstLineupId = manualLineup.removeAt(0);
      manualLineup.insert(1, firstLineupId);
      final manualTeam = originalTeam.copyWith(
        tactics: originalTeam.tactics.copyWith(
          formation: alternateFormation,
          tempo: Tempo.fast,
          attackWidth: AttackWidth.wide,
        ),
        lineupPlayerIds: manualLineup,
        benchPlayerIds: originalTeam.benchPlayerIds.reversed.toList(),
      );
      final manualSave = game.copyWith(
        leagueState: game.leagueState.updateTeam(manualTeam),
      );
      final restored = GameSave.fromJson(
        jsonDecode(jsonEncode(manualSave.toJson())) as Map<String, dynamic>,
      );
      final restoredTeam = restored.leagueState.teamById(originalTeam.id)!;

      // This is deliberately a model/serialization contract check only. It
      // does not impose the new initial-roster slot invariant on later manual
      // formation or lineup changes.
      expect(restoredTeam.tactics, manualTeam.tactics);
      expect(restoredTeam.lineupPlayerIds, manualTeam.lineupPlayerIds);
      expect(restoredTeam.benchPlayerIds, manualTeam.benchPlayerIds);
      expect(teamProjection(restoredTeam), teamProjection(manualTeam));
    },
  );

  test(
    'manual post-creation management survives repository save without reinitializing the roster',
    () async {
      const seed = 161803;
      final game = GameFactory().create(
        const NewGameRequest(
          saveName: 'initial-roster-integration-manual',
          playerTeamId: 'team_europe_0',
          seed: seed,
        ),
      );
      final originalTeam = game.leagueState.playerTeam!;
      final alternateFormation = Formation.values.firstWhere(
        (formation) => formation != originalTeam.tactics.formation,
      );
      final manualLineup = [...originalTeam.lineupPlayerIds];
      final firstLineupId = manualLineup.removeAt(0);
      manualLineup.insert(1, firstLineupId);
      final manualTeam = originalTeam.copyWith(
        tactics: originalTeam.tactics.copyWith(
          formation: alternateFormation,
          tempo: Tempo.fast,
          attackWidth: AttackWidth.wide,
        ),
        lineupPlayerIds: manualLineup,
        benchPlayerIds: originalTeam.benchPlayerIds.reversed.toList(),
      );
      final manualSave = game.copyWith(
        leagueState: game.leagueState.updateTeam(manualTeam),
      );
      final tempDir = await Directory.systemTemp.createTemp(
        'initial_roster_integration_manual_',
      );

      try {
        final repository = SaveRepository(overrideDirectory: tempDir);
        await repository.save(manualSave);
        final loaded = await repository.load(manualSave.meta.id);
        final restoredTeam = loaded.leagueState.teamById(originalTeam.id)!;

        expect(restoredTeam.tactics, manualTeam.tactics);
        expect(restoredTeam.lineupPlayerIds, manualTeam.lineupPlayerIds);
        expect(restoredTeam.benchPlayerIds, manualTeam.benchPlayerIds);
        expect(
          restoredTeam.roster.map((player) => player.id).toList(),
          originalTeam.roster.map((player) => player.id).toList(),
        );
        expect(
          restoredTeam.roster.map(playerProjection).toList(),
          originalTeam.roster.map(playerProjection).toList(),
        );
        expect(teamProjection(restoredTeam), teamProjection(manualTeam));
      } finally {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      }
    },
  );
}
