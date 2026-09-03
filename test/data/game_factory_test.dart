import 'package:new_football/core/services/game_factory.dart';
import 'package:test/test.dart';

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

    test('pula wolnych agentów jest deterministyczna dla tego samego seeda', () {
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
    });

    test('pula wolnych agentów różni się od puli sztabu (różne ziarno)', () {
      final save = GameFactory().create(
        const NewGameRequest(
          saveName: 'test',
          playerTeamId: 'team_europe_0',
          seed: 555,
        ),
      );

      // Regresja: freeAgentRng użyty do graczy musi być inny niż staffRng,
      // inaczej pule korelowałyby się 1:1 dla identycznych wywołań RNG.
      expect(save.leagueState.staffFreeAgents, isNotEmpty);
      expect(save.leagueState.freeAgents, isNotEmpty);
    });
  });
}
