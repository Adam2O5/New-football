import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/controlled_save_repository.dart';

void main() {
  late Directory tempDir;
  late SaveRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nf_rename_raw_');
    repository = SaveRepository(overrideDirectory: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Future<GameSaveMeta> seedRawSave({
    required String id,
    required int schemaVersion,
    required String name,
  }) async {
    final meta = GameSaveMeta(
      id: id,
      name: name,
      createdAt: DateTime.utc(2024, 1, 2, 3, 4),
      updatedAt: DateTime.utc(2024, 2, 3, 4, 5),
      seasonYear: 2024,
      phase: SeasonPhase.regular,
      playerTeamName: 'Team',
      schemaVersion: schemaVersion,
    );
    final raw = <String, dynamic>{
      'schemaVersion': schemaVersion,
      'meta': <String, dynamic>{
        ...meta.toJson(),
        'unknownMeta': <String, dynamic>{'preserve': true},
      },
      'leagueState': <String, dynamic>{
        'unknownLeagueState': <dynamic>['preserve', 7],
      },
      'saveSeed': 987,
      'unknownTopLevel': <String, dynamic>{'preserve': 'verbatim'},
    };

    await File('${tempDir.path}/$id.json').writeAsString(jsonEncode(raw));
    await File('${tempDir.path}/saves_index.json').writeAsString(
      jsonEncode(<Map<String, dynamic>>[meta.toJson()]),
    );
    return meta;
  }

  test(
    'renames older and newer raw snapshots while preserving every other field',
    () async {
      for (final schemaVersion in <int>[
        SaveRepository.currentSchemaVersion - 1,
        SaveRepository.currentSchemaVersion + 1,
      ]) {
        final id = 'save-$schemaVersion';
        final originalMeta = await seedRawSave(
          id: id,
          schemaVersion: schemaVersion,
          name: 'Original $schemaVersion',
        );
        final originalJson =
            jsonDecode(
                  await File('${tempDir.path}/$id.json').readAsString(),
                )
                as Map<String, dynamic>;
        final renamedName = 'Renamed $schemaVersion';

        final returned = await repository.renameRaw(
          id: id,
          newName: renamedName,
        );

        final expectedMeta = originalMeta.copyWith(name: renamedName);
        expect(returned, expectedMeta);

        final renamedJson =
            jsonDecode(
                  await File('${tempDir.path}/$id.json').readAsString(),
                )
                as Map<String, dynamic>;
        final expectedRawMeta = Map<String, dynamic>.from(
          originalJson['meta'] as Map,
        )..['name'] = renamedName;

        expect(renamedJson['schemaVersion'], originalJson['schemaVersion']);
        expect(renamedJson['meta'], expectedRawMeta);
        expect(renamedJson['leagueState'], originalJson['leagueState']);
        expect(renamedJson['saveSeed'], originalJson['saveSeed']);
        expect(renamedJson['unknownTopLevel'], originalJson['unknownTopLevel']);

        final index =
            jsonDecode(
                  await File('${tempDir.path}/saves_index.json').readAsString(),
                )
                as List<dynamic>;
        final matchingEntries = index
            .whereType<Map<String, dynamic>>()
            .where((entry) => entry['id'] == id)
            .toList();
        expect(matchingEntries, hasLength(1));
        expect(matchingEntries.single, expectedMeta.toJson());
      }
    },
  );

  test('restores the old name in both artifacts when index publication fails',
      () async {
    const id = 'rollback-save';
    final originalMeta = await seedRawSave(
      id: id,
      schemaVersion: SaveRepository.currentSchemaVersion,
      name: 'Before rename',
    );
    final gameFile = File('${tempDir.path}/$id.json');
    final indexFile = File('${tempDir.path}/saves_index.json');
    final gameBefore = await gameFile.readAsString();
    final indexBefore = await indexFile.readAsString();

    final failing = ControlledSaveRepository(
      overrideDirectory: tempDir,
      managementFailure: ControlledManagementFailure.beforeIndexPublication,
    );

    await expectLater(
      failing.renameRaw(id: id, newName: 'Should roll back'),
      throwsA(isA<SaveRepositoryException>()),
    );

    expect(await gameFile.readAsString(), gameBefore);
    expect(await indexFile.readAsString(), indexBefore);
    expect((await repository.listSaves()).single, originalMeta);
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

  test('rejects a raw/index name mismatch before changing either artifact',
      () async {
    const id = 'mismatched-name';
    final originalMeta = await seedRawSave(
      id: id,
      schemaVersion: SaveRepository.currentSchemaVersion,
      name: 'File name',
    );
    final indexFile = File('${tempDir.path}/saves_index.json');
    await indexFile.writeAsString(
      jsonEncode(<Map<String, dynamic>>[
        originalMeta.copyWith(name: 'Index name').toJson(),
      ]),
    );
    final gameFile = File('${tempDir.path}/$id.json');
    final gameBefore = await gameFile.readAsString();
    final indexBefore = await indexFile.readAsString();

    await expectLater(
      repository.renameRaw(id: id, newName: 'New name'),
      throwsA(isA<SaveRepositoryException>()),
    );

    expect(await gameFile.readAsString(), gameBefore);
    expect(await indexFile.readAsString(), indexBefore);
  });
}
