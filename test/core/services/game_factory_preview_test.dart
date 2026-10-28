import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/game_factory.dart';
import '../../helpers/fixtures/game_fixtures.dart';

class _NoGeneration extends SeedDataGenerator {
  @override
  LeagueState generateLeague({
    int year = 2026,
    String? playerTeamId,
    int? seed,
  }) {
    throw StateError('Preview must not generate a league.');
  }
}

void main() {
  test('club catalog agrees with generated IDs without generating people', () {
    final factory = GameFactory(seedGenerator: _NoGeneration());
    final preview = factory.previewTeams();
    expect(factory.previewTeams(), same(preview));
    expect(
      preview,
      seededLeague().teams
          .map(
            (team) => (
              id: team.id,
              name: team.name,
              city: team.city,
              conference: team.conference,
            ),
          )
          .toList(),
    );
    expect(() => preview.clear(), throwsUnsupportedError);
  });
}
