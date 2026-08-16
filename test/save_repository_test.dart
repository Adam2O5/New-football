import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
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
    expect(loaded.saveSeed, 99);
    expect(loaded.schemaVersion, SaveRepository.currentSchemaVersion);
  });

  test('rejects a save with an older schema version', () async {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Older',
        playerTeamId: 'team_europe_0',
        seed: 100,
      ),
    );
    await repo.save(game);

    final file = File('${tempDir.path}/${game.meta.id}.json');
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    json['schemaVersion'] = SaveRepository.currentSchemaVersion - 1;
    (json['meta'] as Map<String, dynamic>)['schemaVersion'] =
        SaveRepository.currentSchemaVersion - 1;
    await file.writeAsString(jsonEncode(json));

    await expectLater(
      repo.load(game.meta.id),
      throwsA(
        isA<SaveSchemaMismatchException>().having(
          (e) => e.isOlder,
          'isOlder',
          isTrue,
        ),
      ),
    );
  });

  test('rejects a save with a newer schema version', () async {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Newer',
        playerTeamId: 'team_europe_0',
        seed: 101,
      ),
    );
    await repo.save(game);

    final file = File('${tempDir.path}/${game.meta.id}.json');
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    json['schemaVersion'] = SaveRepository.currentSchemaVersion + 1;
    await file.writeAsString(jsonEncode(json));

    await expectLater(
      repo.load(game.meta.id),
      throwsA(
        isA<SaveSchemaMismatchException>().having(
          (e) => e.isNewer,
          'isNewer',
          isTrue,
        ),
      ),
    );
  });

  test('lists incompatible saves with their schema versions', () async {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Current',
        playerTeamId: 'team_europe_0',
        seed: 102,
      ),
    );
    await repo.save(game);

    final indexFile = File('${tempDir.path}/saves_index.json');
    final index = jsonDecode(await indexFile.readAsString()) as List<dynamic>;
    index.add(
      game.meta
          .copyWith(
            id: 'older-id',
            name: 'Older indexed save',
            schemaVersion: SaveRepository.currentSchemaVersion - 1,
            updatedAt: game.meta.updatedAt.add(const Duration(seconds: 1)),
          )
          .toJson(),
    );
    index.add(
      game.meta
          .copyWith(
            id: 'newer-id',
            name: 'Newer indexed save',
            schemaVersion: SaveRepository.currentSchemaVersion + 1,
            updatedAt: game.meta.updatedAt.add(const Duration(seconds: 2)),
          )
          .toJson(),
    );
    await indexFile.writeAsString(jsonEncode(index));

    final saves = await repo.listSaves();
    expect(
      saves.map((save) => save.schemaVersion),
      containsAll(<int>[
        SaveRepository.currentSchemaVersion,
        SaveRepository.currentSchemaVersion - 1,
        SaveRepository.currentSchemaVersion + 1,
      ]),
    );
    expect(
      saves
          .firstWhere((save) => save.id == 'older-id')
          .compatibilityWith(SaveRepository.currentSchemaVersion),
      SaveCompatibility.older,
    );
    expect(
      saves
          .firstWhere((save) => save.id == 'newer-id')
          .compatibilityWith(SaveRepository.currentSchemaVersion),
      SaveCompatibility.newer,
    );
  });
}
