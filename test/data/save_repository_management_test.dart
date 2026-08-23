import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/controlled_save_repository.dart';

void main() {
  late Directory tempDir;
  late SaveRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nf_management_');
    repository = SaveRepository(overrideDirectory: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  File saveFile(String id) => File('${tempDir.path}/$id.json');

  File indexFile() => File('${tempDir.path}/saves_index.json');

  Future<void> writeIndex(Iterable<GameSaveMeta> metas) async {
    await indexFile().writeAsString(
      jsonEncode(metas.map((meta) => meta.toJson()).toList()),
    );
  }

  Future<Map<String, dynamic>> readJson(File file) async {
    return Map<String, dynamic>.from(
      jsonDecode(await file.readAsString()) as Map,
    );
  }

  Future<List<Map<String, dynamic>>> readIndex() async {
    final decoded =
        jsonDecode(await indexFile().readAsString()) as List<dynamic>;
    return decoded
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
  }

  GameSaveMeta makeMeta({
    required String id,
    String name = 'Source',
    int schemaVersion = SaveRepository.currentSchemaVersion,
  }) {
    return GameSaveMeta(
      id: id,
      name: name,
      createdAt: DateTime.utc(2024, 1, 2, 3, 4),
      updatedAt: DateTime.utc(2024, 2, 3, 4, 5),
      seasonYear: 2024,
      phase: SeasonPhase.regular,
      playerTeamName: 'Team',
      schemaVersion: schemaVersion,
    );
  }

  Future<GameSaveMeta> seedRawSave({
    required String id,
    required int schemaVersion,
    String name = 'Source',
    Iterable<GameSaveMeta>? indexEntries,
  }) async {
    final meta = makeMeta(id: id, name: name, schemaVersion: schemaVersion);
    final raw = <String, dynamic>{
      'schemaVersion': schemaVersion,
      'meta': <String, dynamic>{
        ...meta.toJson(),
        'futureMeta': <String, dynamic>{
          'preserve': true,
          'nested': <dynamic>['metadata', 7],
        },
      },
      'leagueState': <String, dynamic>{
        'futureLeagueState': <dynamic>['untouched', 7],
        'nested': <String, dynamic>{'keep': 'payload'},
      },
      'saveSeed': 987,
      'futureTopLevel': <String, dynamic>{'preserve': 'verbatim'},
    };
    await saveFile(id).writeAsString(jsonEncode(raw));
    await writeIndex(indexEntries ?? [meta]);
    return meta;
  }

  List<FileSystemEntity> transactionArtifacts() {
    return tempDir.listSync().where((entity) {
      final path = entity.path;
      return path.contains('.tmp-') ||
          path.contains('.bak-') ||
          path.contains('.old-');
    }).toList();
  }

  void expectNoTransactionArtifacts() {
    expect(transactionArtifacts(), isEmpty);
  }

  test(
    'inspectFile reads only canonical UTF-8 bytes and distinguishes missing and size-unavailable files',
    () async {
      const missingId = 'missing';
      await File(
        '${tempDir.path}/$missingId.json.tmp-stale',
      ).writeAsString('temporary copy');
      await File(
        '${tempDir.path}/$missingId.json.bak-stale',
      ).writeAsString('backup copy');
      await File(
        '${tempDir.path}/$missingId.json.old-stale',
      ).writeAsString('displaced copy');

      expect(
        await repository.inspectFile(missingId),
        const SaveFileInfo.missing(),
      );

      const contents = '{"name":"Zażółć gęślą jaźń ⚽"}';
      await saveFile('utf8').writeAsString(contents);
      expect(
        await repository.inspectFile('utf8'),
        SaveFileInfo.available(utf8.encode(contents).length),
      );

      // A directory is the only stable local fixture that could make
      // File.length() fail, but Dart's File.exists() deliberately reports it
      // as not-a-file on this runtime. If another supported runtime exposes
      // the length failure through this fixture, retain the stronger check;
      // otherwise preserve the missing-vs-unavailable distinction explicitly.
      await Directory(saveFile('size-unavailable').path).create();
      final sizeUnavailableCandidate = await repository.inspectFile(
        'size-unavailable',
      );
      expect(
        sizeUnavailableCandidate,
        anyOf(
          const SaveFileInfo.missing(),
          const SaveFileInfo.sizeUnavailable(),
        ),
      );
      if (sizeUnavailableCandidate == const SaveFileInfo.sizeUnavailable()) {
        expect(sizeUnavailableCandidate.sizeReadFailed, isTrue);
        expect(sizeUnavailableCandidate.sizeBytes, isNull);
      }
    },
  );

  test(
    'isSaveIdAvailable checks the fresh index and canonical disk file, not artifacts',
    () async {
      expect(await repository.isSaveIdAvailable('fresh'), isTrue);

      final indexed = makeMeta(id: 'indexed');
      await writeIndex([indexed]);
      expect(await repository.isSaveIdAvailable(indexed.id), isFalse);
      expect(await repository.isSaveIdAvailable('not-indexed'), isTrue);

      await saveFile('disk-only').writeAsString('canonical disk file');
      expect(await repository.isSaveIdAvailable('disk-only'), isFalse);

      await File(
        '${tempDir.path}/artifact-only.json.tmp-stale',
      ).writeAsString('temporary copy');
      await File(
        '${tempDir.path}/artifact-only.json.bak-stale',
      ).writeAsString('backup copy');
      expect(await repository.isSaveIdAvailable('artifact-only'), isTrue);
    },
  );

  test(
    'reads valid older and newer raw snapshots without load and rejects missing or mismatched sources',
    () async {
      for (final schemaVersion in <int>[
        SaveRepository.currentSchemaVersion - 1,
        SaveRepository.currentSchemaVersion + 1,
      ]) {
        final id = 'raw-$schemaVersion';
        await seedRawSave(id: id, schemaVersion: schemaVersion);
        final expected = await readJson(saveFile(id));

        expect(await repository.readRawSave(id), expected);
      }

      const tempOnlyId = 'temp-only';
      await File('${tempDir.path}/$tempOnlyId.json.tmp-valid').writeAsString(
        jsonEncode(<String, dynamic>{
          'schemaVersion': SaveRepository.currentSchemaVersion + 1,
          'meta': <String, dynamic>{'id': tempOnlyId},
        }),
      );
      await expectLater(
        repository.readRawSave(tempOnlyId),
        throwsA(
          isA<SaveFileNotFoundException>().having(
            (error) => error.saveId,
            'saveId',
            tempOnlyId,
          ),
        ),
      );

      await saveFile('invalid-json').writeAsString('{not-json');
      await expectLater(
        repository.readRawSave('invalid-json'),
        throwsA(isA<InvalidSerializedSaveException>()),
      );

      await saveFile('mismatched-id').writeAsString(
        jsonEncode(<String, dynamic>{
          'schemaVersion': SaveRepository.currentSchemaVersion + 1,
          'meta': <String, dynamic>{'id': 'different-id'},
          'futurePayload': <String, dynamic>{'preserve': true},
        }),
      );
      await expectLater(
        repository.readRawSave('mismatched-id'),
        throwsA(
          isA<InvalidSerializedSaveException>().having(
            (error) => error.saveId,
            'saveId',
            'mismatched-id',
          ),
        ),
      );
    },
  );

  test(
    'duplicateRaw preserves the raw payload and metadata for older and newer schemas',
    () async {
      for (final schemaVersion in <int>[
        SaveRepository.currentSchemaVersion - 1,
        SaveRepository.currentSchemaVersion + 1,
      ]) {
        final sourceId = 'duplicate-source-$schemaVersion';
        final duplicateId = 'duplicate-copy-$schemaVersion';
        final sourceMeta = await seedRawSave(
          id: sourceId,
          schemaVersion: schemaVersion,
          name: 'Source $schemaVersion',
        );
        final sourceFileBefore = await saveFile(sourceId).readAsString();
        final sourceJson = await readJson(saveFile(sourceId));
        final duplicateTime = DateTime.utc(2025, 6, 7, 8, 9);
        final duplicateMeta = sourceMeta.copyWith(
          id: duplicateId,
          name: 'Source copy $schemaVersion',
          createdAt: duplicateTime,
          updatedAt: duplicateTime,
        );

        expect(
          await repository.duplicateRaw(
            sourceId: sourceId,
            duplicateMeta: duplicateMeta,
          ),
          duplicateMeta,
        );

        final expectedRawMeta = Map<String, dynamic>.from(
          sourceJson['meta'] as Map,
        );
        final duplicateMetaJson = duplicateMeta.toJson();
        for (final key in const ['id', 'name', 'createdAt', 'updatedAt']) {
          expectedRawMeta[key] = duplicateMetaJson[key];
        }
        final expectedRaw = Map<String, dynamic>.from(sourceJson)
          ..['meta'] = expectedRawMeta;

        expect(await readJson(saveFile(duplicateId)), expectedRaw);
        expect(await saveFile(sourceId).readAsString(), sourceFileBefore);

        final index = await readIndex();
        expect(index.where((entry) => entry['id'] == sourceId), hasLength(1));
        expect(
          index.where((entry) => entry['id'] == duplicateId),
          hasLength(1),
        );
        expect(
          index.singleWhere((entry) => entry['id'] == duplicateId),
          duplicateMetaJson,
        );
        expectNoTransactionArtifacts();
      }
    },
  );

  test(
    'renameRaw changes only the raw name and leaves exactly one index entry for older and newer schemas',
    () async {
      for (final schemaVersion in <int>[
        SaveRepository.currentSchemaVersion - 1,
        SaveRepository.currentSchemaVersion + 1,
      ]) {
        final id = 'rename-$schemaVersion';
        final originalMeta = await seedRawSave(
          id: id,
          schemaVersion: schemaVersion,
          name: 'Original $schemaVersion',
        );
        // Duplicate source entries are intentionally malformed input for the
        // index; renameRaw must replace them with exactly one entry.
        await writeIndex([originalMeta, originalMeta]);
        final sourceJson = await readJson(saveFile(id));
        final renamedName = 'Renamed $schemaVersion';

        final returned = await repository.renameRaw(
          id: id,
          newName: renamedName,
        );
        final expectedMeta = originalMeta.copyWith(name: renamedName);
        expect(returned, expectedMeta);

        final expectedRawMeta = Map<String, dynamic>.from(
          sourceJson['meta'] as Map,
        )..['name'] = renamedName;
        final expectedRaw = Map<String, dynamic>.from(sourceJson)
          ..['meta'] = expectedRawMeta;
        expect(await readJson(saveFile(id)), expectedRaw);

        final index = await readIndex();
        expect(index.where((entry) => entry['id'] == id), hasLength(1));
        expect(
          index.singleWhere((entry) => entry['id'] == id),
          expectedMeta.toJson(),
        );
        expectNoTransactionArtifacts();
      }
    },
  );

  test(
    'duplicateRaw failure before write preserves source, index, and cleanup',
    () async {
      const sourceId = 'duplicate-before-source';
      const duplicateId = 'duplicate-before-copy';
      final sourceMeta = await seedRawSave(
        id: sourceId,
        schemaVersion: SaveRepository.currentSchemaVersion,
      );
      final sourceFileBefore = await saveFile(sourceId).readAsString();
      final indexBefore = await indexFile().readAsString();
      final failing = ControlledSaveRepository(
        overrideDirectory: tempDir,
        managementFailure: ControlledManagementFailure.beforeWrite,
      );

      await expectLater(
        failing.duplicateRaw(
          sourceId: sourceId,
          duplicateMeta: sourceMeta.copyWith(
            id: duplicateId,
            name: 'Copy before failure',
          ),
        ),
        throwsA(isA<SaveRepositoryException>()),
      );

      expect(await saveFile(sourceId).readAsString(), sourceFileBefore);
      expect(await indexFile().readAsString(), indexBefore);
      expect(await saveFile(duplicateId).exists(), isFalse);
      expect(await failing.listSaves(), [sourceMeta]);
      expect(failing.activeManagementOperationCount, 0);
      expectNoTransactionArtifacts();
    },
  );

  test(
    'renameRaw failure before write preserves source, index, and cleanup',
    () async {
      const id = 'rename-before-source';
      final sourceMeta = await seedRawSave(
        id: id,
        schemaVersion: SaveRepository.currentSchemaVersion,
      );
      final sourceFileBefore = await saveFile(id).readAsString();
      final indexBefore = await indexFile().readAsString();
      final failing = ControlledSaveRepository(
        overrideDirectory: tempDir,
        managementFailure: ControlledManagementFailure.beforeWrite,
      );

      await expectLater(
        failing.renameRaw(id: id, newName: 'Rename before failure'),
        throwsA(isA<SaveRepositoryException>()),
      );

      expect(await saveFile(id).readAsString(), sourceFileBefore);
      expect(await indexFile().readAsString(), indexBefore);
      expect(await failing.listSaves(), [sourceMeta]);
      expect(failing.activeManagementOperationCount, 0);
      expectNoTransactionArtifacts();
    },
  );

  test(
    'duplicateRaw failure before index publication rolls back the copy and preserves source and index',
    () async {
      const sourceId = 'duplicate-index-source';
      const duplicateId = 'duplicate-index-copy';
      final sourceMeta = await seedRawSave(
        id: sourceId,
        schemaVersion: SaveRepository.currentSchemaVersion,
      );
      final sourceFileBefore = await saveFile(sourceId).readAsString();
      final indexBefore = await indexFile().readAsString();
      final failing = ControlledSaveRepository(
        overrideDirectory: tempDir,
        managementFailure: ControlledManagementFailure.beforeIndexPublication,
      );

      await expectLater(
        failing.duplicateRaw(
          sourceId: sourceId,
          duplicateMeta: sourceMeta.copyWith(
            id: duplicateId,
            name: 'Copy index failure',
          ),
        ),
        throwsA(isA<SaveRepositoryException>()),
      );

      expect(await saveFile(sourceId).readAsString(), sourceFileBefore);
      expect(await indexFile().readAsString(), indexBefore);
      expect(await saveFile(duplicateId).exists(), isFalse);
      expect(await failing.listSaves(), [sourceMeta]);
      expect(failing.activeManagementOperationCount, 0);
      expectNoTransactionArtifacts();
    },
  );

  test(
    'renameRaw failure before index publication restores the old raw name and index',
    () async {
      const id = 'rename-index-source';
      final sourceMeta = await seedRawSave(
        id: id,
        schemaVersion: SaveRepository.currentSchemaVersion,
      );
      final sourceFileBefore = await saveFile(id).readAsString();
      final indexBefore = await indexFile().readAsString();
      final failing = ControlledSaveRepository(
        overrideDirectory: tempDir,
        managementFailure: ControlledManagementFailure.beforeIndexPublication,
      );

      await expectLater(
        failing.renameRaw(id: id, newName: 'Rename index failure'),
        throwsA(isA<SaveRepositoryException>()),
      );

      expect(await saveFile(id).readAsString(), sourceFileBefore);
      expect(await indexFile().readAsString(), indexBefore);
      expect(await failing.listSaves(), [sourceMeta]);
      expect(failing.activeManagementOperationCount, 0);
      expectNoTransactionArtifacts();
    },
  );

  test(
    'ambiguous rollback preserves a deterministic recovery artifact and does not report success',
    () async {
      const sourceId = 'ambiguous-source';
      const duplicateId = 'ambiguous-copy';
      final sourceMeta = await seedRawSave(
        id: sourceId,
        schemaVersion: SaveRepository.currentSchemaVersion,
      );
      final sourceFileBefore = await saveFile(sourceId).readAsString();
      final indexBefore = await indexFile().readAsString();
      var sabotaged = false;

      final ambiguous = SaveRepository(
        overrideDirectory: tempDir,
        beforePublish: (stage) async {
          if (stage != SaveRepositoryWriteStage.indexFile || sabotaged) {
            return;
          }
          sabotaged = true;
          // The game copy has already been published. Replacing the index
          // destination with a directory makes rollback's backup rename fail
          // deterministically, leaving the backup for reconciliation.
          final publishedIndex = indexFile();
          await publishedIndex.delete();
          await Directory(publishedIndex.path).create();
          throw SaveRepositoryException('Deterministic index failure');
        },
      );

      await expectLater(
        ambiguous.duplicateRaw(
          sourceId: sourceId,
          duplicateMeta: sourceMeta.copyWith(
            id: duplicateId,
            name: 'Ambiguous copy',
          ),
        ),
        throwsA(
          isA<SaveAmbiguousWriteException>().having(
            (error) => error.saveId,
            'saveId',
            duplicateId,
          ),
        ),
      );

      expect(sabotaged, isTrue);
      expect(await saveFile(sourceId).readAsString(), sourceFileBefore);
      expect(await Directory(indexFile().path).exists(), isTrue);
      expect(await saveFile(duplicateId).exists(), isFalse);

      final artifacts = transactionArtifacts();
      expect(
        artifacts.where((entity) => entity.path.contains('.tmp-')),
        isEmpty,
      );
      final indexBackups = artifacts
          .where((entity) => entity.path.contains('saves_index.json.bak-'))
          .toList();
      expect(indexBackups, hasLength(1));
      expect(await File(indexBackups.single.path).readAsString(), indexBefore);
      expect(
        artifacts.where(
          (entity) =>
              entity.path.contains('.bak-') || entity.path.contains('.old-'),
        ),
        isNotEmpty,
      );
    },
  );
}
