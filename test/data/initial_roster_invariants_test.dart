@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/services/game_factory.dart';

import '../helpers/generation/initial_roster_assertions.dart';

void main() {
  const invariantSeeds = <int>[0, 1, 2, 7, 17, 42, 77, 1234, 2026];
  test('initial teams satisfy the formation roster and lineup contract', () {
    for (final seed in invariantSeeds) {
      final save = GameFactory().create(
        NewGameRequest(
          saveName: 'initial-roster-post-fix-$seed',
          playerTeamId: 'team_europe_0',
          seed: seed,
        ),
      );

      expect(
        save.leagueState.teams.length,
        30,
        reason: 'seed=$seed generated league size',
      );
      for (final team in save.leagueState.teams) {
        expectInitialTeamInvariant(team, seed);
      }
    }
  });
}
