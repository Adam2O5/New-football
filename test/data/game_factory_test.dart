import '../helpers/fixtures/game_fixtures.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameFactory.create — wolni agenci', () {
    test('nowy save ma wypełnioną pulę freeAgents (25–35 graczy)', () {
      final save = GameFactory().create(
        const NewGameRequest(
          saveName: 'test',
          playerTeamId: 'team_europe_0',
          seed: 12345,
        ),
      );

      final freeAgents = save.leagueState.freeAgents;
      expect(freeAgents.length, inInclusiveRange(25, 35));
      expect(freeAgents.map((p) => p.id).toSet().length, freeAgents.length);
    });

    test(
      'pula wolnych agentów jest deterministyczna dla tego samego seeda',
      () {
        const request = NewGameRequest(
          saveName: 'test',
          playerTeamId: 'team_europe_0',
          seed: 999,
        );
        final saveA = GameFactory().create(request);
        final saveB = GameFactory().create(request);

        expect(
          saveA.leagueState.freeAgents.map((p) => p.id).toList(),
          equals(saveB.leagueState.freeAgents.map((p) => p.id).toList()),
        );
      },
    );
  });
  test('unknown player club is rejected by factory', () {
    expect(
      () => GameFactory().create(
        const NewGameRequest(
          saveName: 'invalid',
          playerTeamId: 'unknown',
          seed: fixtureSeed,
        ),
      ),
      throwsArgumentError,
    );
  });
  test(
    'factory reuse and previews do not change the seeded world or staff IDs',
    () {
      final factory = GameFactory();
      const request = NewGameRequest(
        saveName: 'replay',
        playerTeamId: 'team_europe_3',
        seed: fixtureSeed,
      );
      final first = factory.create(request);
      factory.previewTeams();
      final replay = factory.create(request);
      expect(first.leagueState == replay.leagueState, isTrue);
      expect(
        first.leagueState.teams
            .where((t) => t.isPlayerControlled)
            .map((t) => t.id)
            .toList(),
        ['team_europe_3'],
      );
      final ids = [
        for (final team in replay.leagueState.teams)
          ...team.staff.members.map((m) => m.id),
        ...replay.leagueState.staffFreeAgents.map((m) => m.id),
      ];
      expect(ids.toSet().length, ids.length);
    },
  );
}
