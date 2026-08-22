import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/controlled_save_repository.dart';

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

  test('commits one stamped snapshot to the game file and index', () async {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Consistent',
        playerTeamId: 'team_europe_0',
        seed: 103,
      ),
    );

    await repo.save(game);

    final gameJson =
        jsonDecode(
              await File('${tempDir.path}/${game.meta.id}.json').readAsString(),
            )
            as Map<String, dynamic>;
    final indexJson =
        jsonDecode(
              await File('${tempDir.path}/saves_index.json').readAsString(),
            )
            as List<dynamic>;
    final indexedMeta =
        indexJson.singleWhere(
              (entry) => (entry as Map<String, dynamic>)['id'] == game.meta.id,
            )
            as Map<String, dynamic>;

    expect(gameJson['schemaVersion'], SaveRepository.currentSchemaVersion);
    expect(
      (gameJson['meta'] as Map<String, dynamic>)['schemaVersion'],
      SaveRepository.currentSchemaVersion,
    );
    expect(indexedMeta, equals(gameJson['meta']));

    final loaded = await repo.load(game.meta.id);
    expect(loaded.meta.schemaVersion, SaveRepository.currentSchemaVersion);
    expect(loaded.schemaVersion, SaveRepository.currentSchemaVersion);
  });

  test('controlled repository supports zero and delayed gated saves', () async {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Controlled',
        playerTeamId: 'team_europe_0',
        seed: 104,
      ),
    );

    for (final delay in const [Duration.zero, Duration(milliseconds: 300)]) {
      final controlled = ControlledSaveRepository(
        overrideDirectory: tempDir,
        delay: delay,
        waitForRelease: true,
      );
      final saveFuture = controlled.save(game);
      await Future<void>.delayed(Duration.zero);

      expect(controlled.saveCount, 1);
      controlled.release();
      await saveFuture;
      expect(controlled.completedSaves, hasLength(1));
      expect(controlled.saveStarted, hasLength(1));
      expect(controlled.maxConcurrentSaves, 1);

      final loaded = await repo.load(game.meta.id);
      expect(loaded.meta.id, game.meta.id);
      expect(loaded.saveSeed, game.saveSeed);
      expect(loaded.leagueState, game.leagueState);
      expect(loaded.schemaVersion, SaveRepository.currentSchemaVersion);
      expect(loaded.meta.schemaVersion, SaveRepository.currentSchemaVersion);

      final index = await repo.listSaves();
      expect(index, hasLength(1));
      expect(index.single.id, loaded.meta.id);
      expect(index.single.schemaVersion, loaded.meta.schemaVersion);
    }
  });

  test('failure before write leaves the previous snapshot untouched', () async {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Before failure',
        playerTeamId: 'team_europe_0',
        seed: 105,
      ),
    );
    await repo.save(game);
    final gameFile = File('${tempDir.path}/${game.meta.id}.json');
    final indexFile = File('${tempDir.path}/saves_index.json');
    final gameBefore = await gameFile.readAsString();
    final indexBefore = await indexFile.readAsString();

    final failing = ControlledSaveRepository(
      overrideDirectory: tempDir,
      failure: ControlledSaveFailure.beforeWrite,
    );
    final changed = game.copyWith(
      meta: game.meta.copyWith(name: 'Should not commit'),
    );

    await expectLater(
      failing.save(changed),
      throwsA(isA<SaveRepositoryException>()),
    );

    expect(await gameFile.readAsString(), gameBefore);
    expect(await indexFile.readAsString(), indexBefore);
    expect(failing.completedSaves, isEmpty);
    expect((await repo.load(game.meta.id)).meta.name, 'Before failure');
  });

  test('failure after game publication rolls both files back', () async {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Partial failure',
        playerTeamId: 'team_europe_0',
        seed: 106,
      ),
    );
    await repo.save(game);
    final gameFile = File('${tempDir.path}/${game.meta.id}.json');
    final indexFile = File('${tempDir.path}/saves_index.json');
    final gameBefore = await gameFile.readAsString();
    final indexBefore = await indexFile.readAsString();

    final failing = ControlledSaveRepository(
      overrideDirectory: tempDir,
      failure: ControlledSaveFailure.afterPartialWrite,
    );
    final changed = game.copyWith(
      meta: game.meta.copyWith(name: 'Should roll back'),
    );

    await expectLater(
      failing.save(changed),
      throwsA(isA<SaveRepositoryException>()),
    );

    expect(await gameFile.readAsString(), gameBefore);
    expect(await indexFile.readAsString(), indexBefore);
    expect(failing.completedSaves, isEmpty);
    expect(jsonDecode(await gameFile.readAsString()), isA<Map>());
    expect(jsonDecode(await indexFile.readAsString()), isA<List>());
    expect((await repo.load(game.meta.id)).meta.name, 'Partial failure');
    expect(
      tempDir.listSync().where(
        (entity) =>
            entity.path.contains('.tmp-') ||
            entity.path.contains('.bak-') ||
            entity.path.contains('.old-'),
      ),
      isEmpty,
    );
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
