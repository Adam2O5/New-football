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
    tempDir = await Directory.systemTemp.createTemp('nf_duplicate_raw_');
    repository = SaveRepository(overrideDirectory: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test(
    'duplicates raw older and newer snapshots without decoding GameSave',
    () async {
      for (final schemaVersion in <int>[
        SaveRepository.currentSchemaVersion - 1,
        SaveRepository.currentSchemaVersion + 1,
      ]) {
        final sourceId = 'source-$schemaVersion';
        final duplicateId = 'duplicate-$schemaVersion';
        final sourceMeta = GameSaveMeta(
          id: sourceId,
          name: 'Source $schemaVersion',
          createdAt: DateTime.utc(2024, 1, 2, 3, 4),
          updatedAt: DateTime.utc(2024, 2, 3, 4, 5),
          seasonYear: 2024,
          phase: SeasonPhase.regular,
          playerTeamName: 'Team',
          schemaVersion: schemaVersion,
        );
        final sourceJson = <String, dynamic>{
          'schemaVersion': schemaVersion,
          'meta': <String, dynamic>{
            ...sourceMeta.toJson(),
            'futureMeta': <String, dynamic>{'preserve': true},
          },
          'leagueState': <String, dynamic>{
            'futureLeagueState': <dynamic>['untouched', 7],
          },
          'saveSeed': 987,
          'futureTopLevel': <String, dynamic>{'preserve': 'verbatim'},
        };
        await File(
          '${tempDir.path}/$sourceId.json',
        ).writeAsString(jsonEncode(sourceJson));
        await File('${tempDir.path}/saves_index.json').writeAsString(
          jsonEncode(<Map<String, dynamic>>[sourceMeta.toJson()]),
        );

        final duplicateTime = DateTime.utc(2025, 6, 7, 8, 9);
        final duplicateMeta = sourceMeta.copyWith(
          id: duplicateId,
          name: 'Source copy $schemaVersion',
          createdAt: duplicateTime,
          updatedAt: duplicateTime,
        );
        final sourceBefore = jsonDecode(
          await File('${tempDir.path}/$sourceId.json').readAsString(),
        );

        final returned = await repository.duplicateRaw(
          sourceId: sourceId,
          duplicateMeta: duplicateMeta,
        );

        expect(returned, duplicateMeta);
        final duplicateJson =
            jsonDecode(
                  await File(
                    '${tempDir.path}/$duplicateId.json',
                  ).readAsString(),
                )
                as Map<String, dynamic>;
        expect(duplicateJson['schemaVersion'], sourceJson['schemaVersion']);
        expect(duplicateJson['leagueState'], sourceJson['leagueState']);
        expect(duplicateJson['saveSeed'], sourceJson['saveSeed']);
        expect(duplicateJson['futureTopLevel'], sourceJson['futureTopLevel']);
        expect(duplicateJson['meta'], <String, dynamic>{
          ...(sourceJson['meta'] as Map<String, dynamic>),
          ...duplicateMeta.toJson()
            ..remove('schemaVersion')
            ..remove('seasonYear')
            ..remove('phase')
            ..remove('playerTeamName'),
        });
        final duplicateMetaJson = duplicateJson['meta'] as Map<String, dynamic>;
        expect(duplicateMetaJson['id'], duplicateId);
        expect(duplicateMetaJson['name'], duplicateMeta.name);
        expect(
          duplicateMetaJson['createdAt'],
          duplicateMeta.toJson()['createdAt'],
        );
        expect(
          duplicateMetaJson['updatedAt'],
          duplicateMeta.toJson()['updatedAt'],
        );
        expect(
          jsonDecode(
            await File('${tempDir.path}/$sourceId.json').readAsString(),
          ),
          sourceBefore,
        );

        final index =
            jsonDecode(
                  await File('${tempDir.path}/saves_index.json').readAsString(),
                )
                as List<dynamic>;
        expect(
          index.where(
            (entry) => (entry as Map<String, dynamic>)['id'] == sourceId,
          ),
          hasLength(1),
        );
        expect(
          index.where(
            (entry) => (entry as Map<String, dynamic>)['id'] == duplicateId,
          ),
          hasLength(1),
        );
        expect(
          index.singleWhere(
            (entry) => (entry as Map<String, dynamic>)['id'] == duplicateId,
          ),
          duplicateMeta.toJson(),
        );
      }
    },
  );

  test('distinguishes a missing source from invalid raw source JSON', () async {
    final duplicateMeta = GameSaveMeta(
      id: 'copy',
      name: 'Copy',
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
      seasonYear: 2025,
      phase: SeasonPhase.preseason,
    );

    await expectLater(
      repository.duplicateRaw(
        sourceId: 'missing',
        duplicateMeta: duplicateMeta,
      ),
      throwsA(isA<SaveFileNotFoundException>()),
    );

    await File('${tempDir.path}/invalid.json').writeAsString('[]');
    await expectLater(
      repository.duplicateRaw(
        sourceId: 'invalid',
        duplicateMeta: duplicateMeta,
      ),
      throwsA(isA<InvalidSerializedSaveException>()),
    );

    await File('${tempDir.path}/mismatched.json').writeAsString(
      jsonEncode(<String, dynamic>{
        'meta': <String, dynamic>{'id': 'another-id'},
      }),
    );
    await expectLater(
      repository.duplicateRaw(
        sourceId: 'mismatched',
        duplicateMeta: duplicateMeta,
      ),
      throwsA(isA<InvalidSerializedSaveException>()),
    );
  });

  test('rolls back a published copy when index publication fails', () async {
    const sourceId = 'source';
    const duplicateId = 'copy';
    final sourceMeta = GameSaveMeta(
      id: sourceId,
      name: 'Source',
      createdAt: DateTime.utc(2024),
      updatedAt: DateTime.utc(2024, 2),
      seasonYear: 2024,
      phase: SeasonPhase.regular,
      schemaVersion: SaveRepository.currentSchemaVersion,
    );
    final sourceJson = <String, dynamic>{
      'schemaVersion': SaveRepository.currentSchemaVersion,
      'meta': sourceMeta.toJson(),
      'leagueState': <String, dynamic>{'state': 'source'},
      'saveSeed': 12,
    };
    final sourceFile = File('${tempDir.path}/$sourceId.json');
    final indexFile = File('${tempDir.path}/saves_index.json');
    await sourceFile.writeAsString(jsonEncode(sourceJson));
    await indexFile.writeAsString(
      jsonEncode(<Map<String, dynamic>>[sourceMeta.toJson()]),
    );
    final sourceBefore = await sourceFile.readAsString();
    final indexBefore = await indexFile.readAsString();

    final failing = ControlledSaveRepository(
      overrideDirectory: tempDir,
      managementFailure: ControlledManagementFailure.beforeIndexPublication,
    );
    final duplicateMeta = sourceMeta.copyWith(
      id: duplicateId,
      name: 'Copy',
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
    );

    await expectLater(
      failing.duplicateRaw(sourceId: sourceId, duplicateMeta: duplicateMeta),
      throwsA(isA<SaveRepositoryException>()),
    );

    expect(await sourceFile.readAsString(), sourceBefore);
    expect(await indexFile.readAsString(), indexBefore);
    expect(await File('${tempDir.path}/$duplicateId.json').exists(), isFalse);
    expect(await failing.listSaves(), hasLength(1));
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
}
