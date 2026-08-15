import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';

void main() {
  late Directory tempDir;
  late SaveRepository repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nf_saves_');
    repo = SaveRepository(overrideDirectory: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('save and load roundtrip', () async {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Test',
        playerTeamId: 'team_europe_0',
        seed: 99,
      ),
    );
    await repo.save(game);
    final list = await repo.listSaves();
    expect(list, isNotEmpty);
    expect(list.first.name, 'Test');

    final loaded = await repo.load(game.meta.id);
    expect(loaded.leagueState.teams.length, 30);
    expect(loaded.leagueState.currentSeason.schedule.length, 870);
    expect(loaded.leagueState.playerTeamId, 'team_europe_0');
  });
}
