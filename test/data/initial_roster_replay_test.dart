@Tags(['integration'])
library;

import 'dart:io';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/player.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/generation/initial_roster_assertions.dart';

void main() {
  const preservationSeeds = <int>[17, 42, 77, 1234];
  test(
    'preserves the seeded initial projection for repeated identical requests',
    () {
      for (final seed in preservationSeeds) {
        final request = NewGameRequest(
          saveName: 'initial-roster-preservation-$seed',
          playerTeamId: 'team_europe_0',
          seed: seed,
        );
        final first = GameFactory().create(request);
        final second = GameFactory().create(request);

        // This intentionally compares only the seeded initial-world contract:
        // UUIDs, timestamps, staff, and draft-class data are out of scope.
        expect(
          initialProjection(first),
          initialProjection(second),
          reason: 'seed=$seed repeated initial projection differs',
        );
      }
    },
  );

  test(
    'preserves the existing save round-trip contract without metadata fields',
    () async {
      const seed = 808;
      final game = GameFactory().create(
        const NewGameRequest(
          saveName: 'initial-roster-round-trip',
          playerTeamId: 'team_europe_0',
          seed: seed,
        ),
      );
      final tempDir = await Directory.systemTemp.createTemp(
        'initial_roster_preservation_',
      );

      try {
        final repository = SaveRepository(overrideDirectory: tempDir);
        await repository.save(game);
        final loaded = await repository.load(game.meta.id);

        expect(loaded.saveSeed, game.saveSeed);
        expect(loaded.schemaVersion, game.schemaVersion);
        expect(loaded.meta.schemaVersion, game.meta.schemaVersion);
        expect(initialProjection(loaded), initialProjection(game));
        for (final originalTeam in game.leagueState.teams) {
          final restoredTeam = loaded.leagueState.teamById(originalTeam.id)!;
          expect(
            restoredTeam.tactics.formation,
            originalTeam.tactics.formation,
          );
          expect(
            restoredTeam.roster.map(playerProjection).toList(),
            originalTeam.roster.map(playerProjection).toList(),
          );
          expect(restoredTeam.lineupPlayerIds, originalTeam.lineupPlayerIds);
          expect(restoredTeam.benchPlayerIds, originalTeam.benchPlayerIds);
        }
      } finally {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      }
    },
  );

  test('initial player state follows the documented creation contract', () {
    const seed = 24680;
    final league = GameFactory()
        .create(
          const NewGameRequest(
            saveName: 'initial-player-contract',
            playerTeamId: 'team_europe_0',
            seed: seed,
          ),
        )
        .leagueState;
    for (final team in league.teams) {
      for (final player in team.roster) {
        final reason = 'seed=$seed team=${team.id} player=${player.id}';
        expect(
          player.contract.yearsRemaining,
          inInclusiveRange(1, 4),
          reason: reason,
        );
        expect(player.contract.firstSeason, 2026, reason: reason);
        expect(
          player.contract.lastSeason,
          2026 + player.contract.yearsRemaining - 1,
          reason: reason,
        );
        expect(player.contract.hasBirdRights, isFalse, reason: reason);
        expect(player.state.stamina, 100, reason: reason);
        expect(player.state.form, inInclusiveRange(3, 8), reason: reason);
        expect(
          player.state.role,
          player.position.defaultAssignedRole,
          reason: reason,
        );
        expect(player.state.seasonsWithTeam, 0, reason: reason);
        expect(
          player.hidden.injuryProne,
          inInclusiveRange(1, 10),
          reason: reason,
        );
        expect(
          player.hidden.determination,
          inInclusiveRange(1, 10),
          reason: reason,
        );
        expect(
          player.hidden.overallProgress,
          player.age <= 26 ? inInclusiveRange(40, 89) : inInclusiveRange(0, 29),
          reason: reason,
        );
        expect(player.seasonStartOvr, player.overall(), reason: reason);
      }
    }
  });
}
