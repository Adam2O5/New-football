@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/core/services/save_name_policy.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/controlled_save_repository.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nf_save_management_flow_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'duplicates a raw save with a new id, preserved snapshot, fake timestamps, ordering and fresh size',
    () async {
      final source = _meta(
        id: 'duplicate-source',
        name: 'Checkpoint',
        createdAt: DateTime.utc(2038, 1, 1, 1, 2),
        updatedAt: DateTime.utc(2038, 1, 2, 1, 2),
      );
      final occupiedBase = _meta(
        id: 'occupied-base',
        name: 'Checkpoint-copy',
        createdAt: DateTime.utc(2037, 1, 1),
        updatedAt: DateTime.utc(2037, 1, 1),
      );
      final occupiedThird = _meta(
        id: 'occupied-third',
        name: 'Checkpoint-copy-3',
        createdAt: DateTime.utc(2036, 1, 1),
        updatedAt: DateTime.utc(2036, 1, 1),
      );
      for (final meta in [source, occupiedBase, occupiedThird]) {
        await _writeRawSave(tempDir, meta, marker: meta.id);
      }
      await _writeIndex(tempDir, [source, occupiedBase, occupiedThird]);

      final sourceJson = await _readJson(_saveFile(tempDir, source.id));
      final sourceContents = await _saveFile(tempDir, source.id).readAsString();
      final fixedTimestamp = DateTime.utc(2042, 6, 7, 8, 9, 10);
      final repository = SaveRepository(overrideDirectory: tempDir);
      final service = SaveManagementService(
        repository: repository,
        clock: () => fixedTimestamp,
        idGenerator: () => 'duplicate-id',
      );

      final result = await service.duplicate(source.id, localeCode: 'en');

      expect(result.isDuplicate, isTrue);
      expect(result.meta.id, 'duplicate-id');
      expect(result.meta.id, isNot(source.id));
      expect(result.meta.name, 'Checkpoint-copy-2');
      expect(result.meta.createdAt, fixedTimestamp);
      expect(result.meta.updatedAt, fixedTimestamp);
      expect(await repository.isSaveIdAvailable(result.meta.id), isFalse);

      final duplicateJson = await _readJson(_saveFile(tempDir, result.meta.id));
      expect(
        _withoutDuplicateOwnedFields(duplicateJson),
        _withoutDuplicateOwnedFields(sourceJson),
      );
      expect(
        (duplicateJson['meta'] as Map<String, dynamic>)['id'],
        result.meta.id,
      );
      expect(
        (duplicateJson['meta'] as Map<String, dynamic>)['name'],
        result.meta.name,
      );
      expect(
        (duplicateJson['meta'] as Map<String, dynamic>)['createdAt'],
        fixedTimestamp.toIso8601String(),
      );
      expect(
        (duplicateJson['meta'] as Map<String, dynamic>)['updatedAt'],
        fixedTimestamp.toIso8601String(),
      );
      expect(
        await _saveFile(tempDir, source.id).readAsString(),
        sourceContents,
      );

      final index = await repository.listSaves();
      expect(index.where((meta) => meta.id == source.id), hasLength(1));
      expect(index.where((meta) => meta.id == result.meta.id), hasLength(1));
      expect(
        index.where((meta) => meta.name == result.meta.name),
        hasLength(1),
      );
      for (var i = 1; i < index.length; i++) {
        expect(!index[i - 1].updatedAt.isBefore(index[i].updatedAt), isTrue);
      }

      final records = await service.listRecords();
      final duplicateRecord = records.singleWhere(
        (record) => record.meta.id == result.meta.id,
      );
      expect(
        duplicateRecord.sizeBytes,
        await _saveFile(tempDir, result.meta.id).length(),
      );
      expect(duplicateRecord.sizeBytes, isNot(0));
      expect(
        records.where((record) => record.meta.id == source.id),
        hasLength(1),
      );
      expect(
        records.where((record) => record.meta.id == result.meta.id),
        hasLength(1),
      );
    },
  );

  test(
    'uses the localized suffix and the smallest available copy number in Polish and English',
    () async {
      for (final locale in const ['pl', 'en']) {
        final directory = Directory('${tempDir.path}/suffix-$locale')
          ..createSync(recursive: true);
        final source = _meta(
          id: 'suffix-source-$locale',
          name: 'Checkpoint',
          updatedAt: DateTime.utc(2039, 1, 1),
        );
        final occupiedBase = _meta(
          id: 'suffix-base-$locale',
          name: locale == 'pl' ? 'Checkpoint-kopia' : 'Checkpoint-copy',
          updatedAt: DateTime.utc(2038, 1, 1),
        );
        final occupiedThird = _meta(
          id: 'suffix-third-$locale',
          name: locale == 'pl' ? 'Checkpoint-kopia-3' : 'Checkpoint-copy-3',
          updatedAt: DateTime.utc(2037, 1, 1),
        );
        for (final meta in [source, occupiedBase, occupiedThird]) {
          await _writeRawSave(directory, meta, marker: meta.id);
        }
        await _writeIndex(directory, [source, occupiedBase, occupiedThird]);

        final ids = <String>['suffix-copy-1-$locale', 'suffix-copy-2-$locale'];
        final repository = SaveRepository(overrideDirectory: directory);
        final service = SaveManagementService(
          repository: repository,
          clock: () => DateTime.utc(2040, 1, 2),
          idGenerator: () => ids.removeAt(0),
        );
        final first = await service.duplicate(source.id, localeCode: locale);
        final second = await service.duplicate(source.id, localeCode: locale);
        final suffix = locale == 'pl' ? '-kopia' : '-copy';

        expect(first.meta.name, 'Checkpoint$suffix-2');
        expect(second.meta.name, 'Checkpoint$suffix-4');
        expect(first.meta.id, isNot(second.meta.id));

        final names = (await repository.listSaves()).map((meta) => meta.name);
        final keys = names.map(SaveNamePolicy.nameKey).toList();
        expect(keys.toSet(), hasLength(keys.length));
      }
    },
  );

  test(
    'renames a raw save while preserving id, payload, metadata, timestamps, schema and changing size',
    () async {
      final source = _meta(
        id: 'rename-source',
        name: 'Short',
        schemaVersion: SaveRepository.currentSchemaVersion,
        createdAt: DateTime.utc(2035, 3, 4, 5, 6),
        updatedAt: DateTime.utc(2036, 4, 5, 6, 7),
      );
      await _writeRawSave(tempDir, source, marker: 'rename-source');
      await _writeIndex(tempDir, [source]);
      final repository = SaveRepository(overrideDirectory: tempDir);
      final service = SaveManagementService(repository: repository);
      final before = await _readJson(_saveFile(tempDir, source.id));
      final beforeLength = await _saveFile(tempDir, source.id).length();
      const proposed = '  A substantially longer Żółć checkpoint  ';

      final result = await service.rename(source.id, proposed);

      expect(result.isRename, isTrue);
      expect(result.meta.id, source.id);
      expect(result.meta.name, 'A substantially longer Żółć checkpoint');
      expect(result.meta.createdAt, source.createdAt);
      expect(result.meta.updatedAt, source.updatedAt);
      expect(result.meta.schemaVersion, source.schemaVersion);
      expect(
        result.meta.compatibilityWith(SaveRepository.currentSchemaVersion),
        SaveCompatibility.compatible,
      );

      final after = await _readJson(_saveFile(tempDir, source.id));
      expect(_withoutName(after), _withoutName(before));
      expect((after['meta'] as Map<String, dynamic>)['name'], result.meta.name);
      expect(
        await _saveFile(tempDir, source.id).length(),
        greaterThan(beforeLength),
      );

      final index = await _readIndex(tempDir);
      expect(index.where((meta) => meta['id'] == source.id), hasLength(1));
      expect(
        index.singleWhere((meta) => meta['id'] == source.id)['name'],
        result.meta.name,
      );
      expect((await repository.listSaves()).single, result.meta);
      expect(
        (await service.listRecords()).single.sizeBytes,
        await _saveFile(tempDir, source.id).length(),
      );
    },
  );

  test(
    'duplicates and renames older and newer schemas while load remains blocked',
    () async {
      for (final schemaVersion in <int>[
        SaveRepository.currentSchemaVersion - 1,
        SaveRepository.currentSchemaVersion + 1,
      ]) {
        final source = _meta(
          id: 'schema-source-$schemaVersion',
          name: 'Schema $schemaVersion',
          schemaVersion: schemaVersion,
        );
        await _writeRawSave(tempDir, source, marker: 'schema-$schemaVersion');
        await _writeIndex(tempDir, [source]);
        final repository = SaveRepository(overrideDirectory: tempDir);
        final ids = <String>['schema-copy-$schemaVersion'];
        final service = SaveManagementService(
          repository: repository,
          clock: () => DateTime.utc(2041, 2, 3),
          idGenerator: () => ids.removeAt(0),
        );

        expect(
          () => repository.load(source.id),
          throwsA(
            isA<SaveSchemaMismatchException>().having(
              (error) => error.foundVersion,
              'foundVersion',
              schemaVersion,
            ),
          ),
        );
        final duplicate = await service.duplicate(source.id, localeCode: 'en');
        expect(duplicate.meta.schemaVersion, schemaVersion);
        expect(
          (await _readJson(
            _saveFile(tempDir, duplicate.meta.id),
          ))['schemaVersion'],
          schemaVersion,
        );
        expect(
          () => repository.load(duplicate.meta.id),
          throwsA(isA<SaveSchemaMismatchException>()),
        );

        final renamed = await service.rename(
          source.id,
          'Renamed schema $schemaVersion',
        );
        expect(renamed.meta.id, source.id);
        expect(renamed.meta.schemaVersion, schemaVersion);
        expect(
          (await _readJson(_saveFile(tempDir, source.id)))['schemaVersion'],
          schemaVersion,
        );
        expect(
          (await service.listRecords())
              .singleWhere((record) => record.meta.id == source.id)
              .compatibility,
          schemaVersion < SaveRepository.currentSchemaVersion
              ? SaveCompatibility.older
              : SaveCompatibility.newer,
        );
      }
    },
  );

  test(
    'uses UTF-8 bytes for canonical file size, ignores the index, and preserves missing and unavailable states',
    () async {
      final utf8Meta = _meta(id: 'utf8-save', name: 'Zażółć ⚽');
      final missingMeta = _meta(id: 'missing-save', name: 'Missing');
      final raw = <String, dynamic>{
        'schemaVersion': SaveRepository.currentSchemaVersion,
        'meta': utf8Meta.toJson(),
        'leagueState': <String, dynamic>{'message': 'Zażółć gęślą jaźń'},
        'saveSeed': 99,
      };
      final contents = jsonEncode(raw);
      await _saveFile(tempDir, utf8Meta.id).writeAsString(contents);
      await _writeIndex(tempDir, [utf8Meta, missingMeta]);
      await File(
        '${_saveFile(tempDir, missingMeta.id).path}.tmp-stale',
      ).writeAsString('stale temporary copy');
      final repository = SaveRepository(overrideDirectory: tempDir);

      expect(
        await repository.inspectFile(utf8Meta.id),
        SaveFileInfo.available(utf8.encode(contents).length),
      );
      expect(
        await repository.inspectFile(utf8Meta.id),
        isNot(SaveFileInfo.available(await _indexFile(tempDir).length())),
      );

      final records = await SaveManagementService(
        repository: repository,
      ).listRecords();
      final utf8Record = records.singleWhere(
        (record) => record.meta.id == utf8Meta.id,
      );
      final missingRecord = records.singleWhere(
        (record) => record.meta.id == missingMeta.id,
      );
      expect(utf8Record.serializedFileAvailable, isTrue);
      expect(utf8Record.sizeBytes, utf8.encode(contents).length);
      expect(missingRecord.serializedFileAvailable, isFalse);
      expect(missingRecord.sizeBytes, isNull);
      expect(missingRecord.sizeReadFailed, isFalse);

      final directoryPath = _saveFile(tempDir, 'size-directory').path;
      await Directory(directoryPath).create();
      final directoryInspection = await repository.inspectFile(
        'size-directory',
      );
      expect(
        directoryInspection,
        anyOf(
          const SaveFileInfo.missing(),
          const SaveFileInfo.sizeUnavailable(),
        ),
      );
      if (directoryInspection.sizeReadFailed) {
        expect(directoryInspection.sizeBytes, isNull);
      }

      final failingRepository = _SizeUnavailableRepository(
        tempDir,
        unavailableId: utf8Meta.id,
      );
      final failingRecord = (await SaveManagementService(
        repository: failingRepository,
      ).listRecords()).singleWhere((record) => record.meta.id == utf8Meta.id);
      expect(failingRecord.serializedFileAvailable, isTrue);
      expect(failingRecord.sizeReadFailed, isTrue);
      expect(failingRecord.sizeBytes, isNull);
    },
  );

  test(
    'keeps source and index unchanged for pre-write and pre-index failures, cleans rollback artifacts, and retries',
    () async {
      for (final failure in const [
        ControlledManagementFailure.beforeWrite,
        ControlledManagementFailure.beforeIndexPublication,
      ]) {
        final directory = Directory('${tempDir.path}/failure-${failure.name}')
          ..createSync(recursive: true);
        final source = _meta(
          id: 'failure-source-${failure.name}',
          name: 'Failure source',
        );
        await _writeRawSave(directory, source, marker: failure.name);
        await _writeIndex(directory, [source]);
        final sourceContents = await _saveFile(
          directory,
          source.id,
        ).readAsString();
        final indexContents = await _indexFile(directory).readAsString();
        final repository = ControlledSaveRepository(
          overrideDirectory: directory,
          managementFailure: failure,
        );
        final service = SaveManagementService(
          repository: repository,
          idGenerator: () => 'failure-copy-${failure.name}',
          clock: () => DateTime.utc(2044, 1, 1),
        );

        await expectLater(
          service.duplicate(source.id, localeCode: 'en'),
          throwsA(
            isA<SaveManagementException>().having(
              (error) => error.code,
              'code',
              SaveManagementFailure.writeFailed,
            ),
          ),
        );
        expect(
          await _saveFile(directory, source.id).readAsString(),
          sourceContents,
        );
        expect(await _indexFile(directory).readAsString(), indexContents);
        expect(
          await _saveFile(directory, 'failure-copy-${failure.name}').exists(),
          isFalse,
        );
        expect(_transactionArtifacts(directory), isEmpty);

        repository.managementFailure = ControlledManagementFailure.none;
        final retry = await service.duplicate(source.id, localeCode: 'en');
        expect(retry.isDuplicate, isTrue);
        expect(
          (await repository.listSaves()).where(
            (meta) => meta.id == retry.meta.id,
          ),
          hasLength(1),
        );
        expect(_transactionArtifacts(directory), isEmpty);
      }
    },
  );

  test(
    'reports an ambiguous outcome without success and leaves recovery evidence',
    () async {
      final source = _meta(id: 'ambiguous-source', name: 'Ambiguous source');
      await _writeRawSave(tempDir, source, marker: 'ambiguous');
      await _writeIndex(tempDir, [source]);
      final sourceContents = await _saveFile(tempDir, source.id).readAsString();
      final indexContents = await _indexFile(tempDir).readAsString();
      var sabotaged = false;
      final repository = SaveRepository(
        overrideDirectory: tempDir,
        beforePublish: (stage) async {
          if (stage != SaveRepositoryWriteStage.indexFile || sabotaged) return;
          sabotaged = true;
          await _indexFile(tempDir).delete();
          await Directory(_indexFile(tempDir).path).create();
          throw SaveRepositoryException(
            'deterministic index publication failure',
          );
        },
      );
      final service = SaveManagementService(
        repository: repository,
        idGenerator: () => 'ambiguous-copy',
        clock: () => DateTime.utc(2045, 1, 1),
      );

      await expectLater(
        service.duplicate(source.id, localeCode: 'en'),
        throwsA(
          isA<SaveManagementException>().having(
            (error) => error.code,
            'code',
            SaveManagementFailure.ambiguousWrite,
          ),
        ),
      );

      expect(sabotaged, isTrue);
      expect(
        await _saveFile(tempDir, source.id).readAsString(),
        sourceContents,
      );
      expect(await _saveFile(tempDir, 'ambiguous-copy').exists(), isFalse);
      expect(await Directory(_indexFile(tempDir).path).exists(), isTrue);
      expect(
        _transactionArtifacts(
          tempDir,
        ).where((entity) => entity.path.contains('saves_index.json.bak-')),
        hasLength(1),
      );
      expect(
        await File(
          _transactionArtifacts(tempDir)
              .singleWhere(
                (entity) => entity.path.contains('saves_index.json.bak-'),
              )
              .path,
        ).readAsString(),
        indexContents,
      );
      expect(
        _transactionArtifacts(
          tempDir,
        ).where((entity) => entity.path.contains('.tmp-')),
        isEmpty,
      );
    },
  );

  test(
    'validates empty, equivalent and colliding names without modifying the save',
    () async {
      final source = _meta(id: 'name-source', name: 'Checkpoint');
      final other = _meta(id: 'name-other', name: 'Żółć');
      await _writeRawSave(tempDir, source, marker: source.id);
      await _writeRawSave(tempDir, other, marker: other.id);
      await _writeIndex(tempDir, [source, other]);
      final repository = SaveRepository(overrideDirectory: tempDir);
      final service = SaveManagementService(repository: repository);
      final sourceBefore = await _saveFile(tempDir, source.id).readAsString();
      final indexBefore = await _indexFile(tempDir).readAsString();

      for (final proposed in const ['   \t', 'CHECKPOINT', ' zÓŁć ']) {
        final expectedCode = proposed.trim().isEmpty
            ? SaveManagementFailure.emptyName
            : proposed == 'CHECKPOINT'
            ? SaveManagementFailure.sameName
            : SaveManagementFailure.nameTaken;
        await expectLater(
          service.rename(source.id, proposed),
          throwsA(
            isA<SaveManagementException>().having(
              (error) => error.code,
              'code',
              expectedCode,
            ),
          ),
        );
        expect(
          await _saveFile(tempDir, source.id).readAsString(),
          sourceBefore,
        );
        expect(await _indexFile(tempDir).readAsString(), indexBefore);
      }
    },
  );

  test(
    'runs pending persist before management and captures locale at invocation',
    () async {
      final directory = Directory('${tempDir.path}/pending')
        ..createSync(recursive: true);
      final active = _activeGame(id: 'queue-pending', name: 'Queue save');
      await SaveRepository(overrideDirectory: directory).save(active);
      final repository = ControlledSaveRepository(
        overrideDirectory: directory,
        waitForRelease: true,
        waitForManagementRelease: true,
      );
      final service = SaveManagementService(
        repository: repository,
        clock: () => DateTime.utc(2046, 2, 3, 4, 5),
        idGenerator: () => 'queue-pending-copy',
      );
      final harness = await _openControllerHarness(
        repository: repository,
        service: service,
        active: active,
        locale: 'en',
      );
      addTearDown(harness.dispose);
      final coordinator = harness.container.read(
        saveManagementCoordinatorProvider,
      );

      final persist = harness.controller.persist();
      await repository.firstSaveStarted;
      final duplicate = coordinator.duplicate(active.meta.id);
      await harness.container
          .read(localeProvider.notifier)
          .setLocale(const Locale('pl'));
      expect(repository.managementOperationCount, 0);
      repository.releaseSave();
      await repository.firstManagementOperationStarted;
      repository.releaseManagement();
      final duplicateResult = await duplicate;
      await persist;

      // The coordinator captured English before the queued operation started.
      expect(duplicateResult.meta.name, 'Queue save-copy');
      expect(repository.saveCount, 1);
      expect((await repository.listSaves()), hasLength(2));
    },
  );

  test(
    'synchronizes an active rename before the next persist without changing payload',
    () async {
      final directory = Directory('${tempDir.path}/active-rename')
        ..createSync(recursive: true);
      final active = _activeGame(id: 'queue-rename', name: 'Queue save');
      await SaveRepository(overrideDirectory: directory).save(active);
      final repository = ControlledSaveRepository(
        overrideDirectory: directory,
        waitForRelease: true,
        waitForManagementRelease: true,
      );
      final service = SaveManagementService(
        repository: repository,
        clock: () => DateTime.utc(2046, 2, 3),
        idGenerator: () => 'unused-rename-id',
      );
      final harness = await _openControllerHarness(
        repository: repository,
        service: service,
        active: active,
        locale: 'en',
      );
      addTearDown(harness.dispose);
      final coordinator = harness.container.read(
        saveManagementCoordinatorProvider,
      );
      final before = harness.controller.save!;
      final rename = coordinator.rename(active.meta.id, 'Queue save renamed');
      await repository.firstManagementOperationStarted;
      final nextPersist = harness.controller.persist();
      expect(repository.saveCount, 0);

      repository.releaseManagement();
      await repository.firstSaveStarted;
      expect(repository.attemptedSaves.single.meta.name, 'Queue save renamed');
      expect(harness.controller.save!.meta.name, 'Queue save renamed');
      expect(harness.controller.save!.leagueState, same(before.leagueState));
      expect(harness.controller.save!.saveSeed, before.saveSeed);
      repository.releaseSave();
      await Future.wait([rename, nextPersist]);
    },
  );

  test(
    'serializes two fast duplicates and leaves the active save unchanged',
    () async {
      final directory = Directory('${tempDir.path}/fast-duplicates')
        ..createSync(recursive: true);
      final active = _activeGame(id: 'queue-fast', name: 'Queue save');
      await SaveRepository(overrideDirectory: directory).save(active);
      final repository = ControlledSaveRepository(
        overrideDirectory: directory,
        waitForManagementRelease: true,
      );
      var nextId = 0;
      final service = SaveManagementService(
        repository: repository,
        clock: () => DateTime.utc(2046, 2, 3),
        idGenerator: () => 'queue-fast-copy-${nextId++}',
      );
      final harness = await _openControllerHarness(
        repository: repository,
        service: service,
        active: active,
        locale: 'en',
      );
      addTearDown(harness.dispose);
      final coordinator = harness.container.read(
        saveManagementCoordinatorProvider,
      );
      final before = harness.controller.save!;
      final first = coordinator.duplicate(active.meta.id);
      final second = coordinator.duplicate(active.meta.id);
      await repository.firstManagementOperationStarted;
      repository.releaseManagement();
      final results = await Future.wait([first, second]);

      expect(results.map((result) => result.meta.name), [
        'Queue save-copy',
        'Queue save-copy-2',
      ]);
      expect(repository.maxConcurrentManagementWrites, 1);
      expect(harness.controller.save, same(before));
      final ids = results.map((result) => result.meta.id).toSet();
      expect(ids, hasLength(2));
      final currentIndex = await repository.listSaves();
      for (final id in ids) {
        expect(currentIndex.where((meta) => meta.id == id), hasLength(1));
      }
    },
  );

  test(
    'recovers the shared queue after a failed management write and supports retry',
    () async {
      final active = _activeGame(id: 'retry-active', name: 'Retry save');
      await SaveRepository(overrideDirectory: tempDir).save(active);
      final repository = ControlledSaveRepository(
        overrideDirectory: tempDir,
        managementFailure: ControlledManagementFailure.beforeWrite,
      );
      final service = SaveManagementService(
        repository: repository,
        idGenerator: () => 'retry-copy',
        clock: () => DateTime.utc(2047, 1, 1),
      );
      final harness = await _openControllerHarness(
        repository: repository,
        service: service,
        active: active,
        locale: 'en',
      );
      addTearDown(harness.dispose);
      final coordinator = harness.container.read(
        saveManagementCoordinatorProvider,
      );

      await expectLater(
        coordinator.duplicate(active.meta.id),
        throwsA(
          isA<SaveManagementException>().having(
            (error) => error.code,
            'code',
            SaveManagementFailure.writeFailed,
          ),
        ),
      );
      expect(
        coordinator.isActionInFlight(
          active.meta.id,
          SaveManagementAction.duplicate,
        ),
        isFalse,
      );
      expect((await repository.listSaves()), hasLength(1));

      repository.managementFailure = ControlledManagementFailure.none;
      final retry = await coordinator.duplicate(active.meta.id);
      expect(retry.isDuplicate, isTrue);
      expect((await repository.listSaves()), hasLength(2));
    },
  );

  test(
    'preserves compatible loading and active deletion while blocking incompatible loading',
    () async {
      final active = _activeGame(id: 'regression-active', name: 'Regression');
      final repository = SaveRepository(overrideDirectory: tempDir);
      await repository.save(active);
      final loaded = await repository.load(active.meta.id);
      expect(loaded.meta.id, active.meta.id);
      expect(loaded.saveSeed, active.saveSeed);
      expect(loaded.leagueState, active.leagueState);

      final older = _meta(
        id: 'regression-older',
        name: 'Older',
        schemaVersion: SaveRepository.currentSchemaVersion - 1,
      );
      final newer = _meta(
        id: 'regression-newer',
        name: 'Newer',
        schemaVersion: SaveRepository.currentSchemaVersion + 1,
      );
      await _writeRawSave(tempDir, older, marker: older.id);
      await _writeRawSave(tempDir, newer, marker: newer.id);
      await _writeIndex(tempDir, [active.meta, older, newer]);
      for (final incompatible in [older, newer]) {
        await expectLater(
          repository.load(incompatible.id),
          throwsA(isA<SaveSchemaMismatchException>()),
        );
      }

      final harness = await _openControllerHarness(
        repository: repository,
        service: SaveManagementService(repository: repository),
        active: active,
        locale: 'en',
      );
      addTearDown(harness.dispose);
      await harness.controller.loadGame(active.meta.id);
      expect(harness.controller.save!.meta.id, active.meta.id);
      await harness.controller.loadGame(older.id);
      expect(harness.controller.state.hasError, isTrue);

      final coordinator = harness.container.read(
        saveManagementCoordinatorProvider,
      );
      await coordinator.delete(active.meta.id);
      expect(harness.controller.save, isNull);
      expect(await _saveFile(tempDir, active.meta.id).exists(), isFalse);
      expect(
        (await repository.listSaves()).where(
          (meta) => meta.id == active.meta.id,
        ),
        isEmpty,
      );
      expect(
        (await repository.listSaves()).map((meta) => meta.id),
        containsAll([older.id, newer.id]),
      );
    },
  );

  test(
    'provides distinct localized action descriptions and date/size labels in PL and EN',
    () async {
      final source = _meta(id: 'localized-source', name: 'Localized checkpoint');
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final l10n = await AppLocalizations.delegate.load(locale);
        final labels = [
          l10n.loadGame_loadSemantics(source.name),
          l10n.loadGame_deleteSemantics(source.name),
          l10n.loadGame_duplicateSemantics(source.name),
          l10n.loadGame_renameSemantics(source.name),
        ];
        expect(labels.toSet(), hasLength(4));
        expect(labels, everyElement(isNotEmpty));
        expect(l10n.loadGame_duplicateTooltip, isNotEmpty);
        expect(l10n.loadGame_renameTooltip, isNotEmpty);
        expect(l10n.loadGame_lastSaveDate, isNotEmpty);
        expect(l10n.loadGame_saveSize, isNotEmpty);
      }

      final older = _meta(
        id: 'localized-older',
        name: 'Older localized',
        schemaVersion: SaveRepository.currentSchemaVersion - 1,
      );
      final newer = _meta(
        id: 'localized-newer',
        name: 'Newer localized',
        schemaVersion: SaveRepository.currentSchemaVersion + 1,
      );
      await _writeRawSave(tempDir, older, marker: older.id);
      await _writeRawSave(tempDir, newer, marker: newer.id);
      await _writeIndex(tempDir, [older, newer]);
      final records = await SaveManagementService(
        repository: SaveRepository(overrideDirectory: tempDir),
      ).listRecords();
      expect(
        records.singleWhere((record) => record.meta.id == older.id).compatibility,
        SaveCompatibility.older,
      );
      expect(
        records.singleWhere((record) => record.meta.id == newer.id).compatibility,
        SaveCompatibility.newer,
      );
      expect(records.every((record) => record.serializedFileAvailable), isTrue);
    },
  );
}


GameSaveMeta _meta({
  required String id,
  required String name,
  int schemaVersion = SaveRepository.currentSchemaVersion,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? playerTeamName = 'Lions FC',
  SeasonPhase phase = SeasonPhase.regular,
}) {
  final created = createdAt ?? DateTime.utc(2030, 1, 1);
  return GameSaveMeta(
    id: id,
    name: name,
    createdAt: created,
    updatedAt: updatedAt ?? created.add(const Duration(days: 1)),
    seasonYear: 2030,
    phase: phase,
    playerTeamName: playerTeamName,
    schemaVersion: schemaVersion,
  );
}

Future<void> _writeRawSave(
  Directory directory,
  GameSaveMeta meta, {
  required String marker,
}) async {
  final raw = <String, dynamic>{
    'schemaVersion': meta.schemaVersion,
    'meta': <String, dynamic>{
      ...meta.toJson(),
      'persistentMetadata': <String, dynamic>{
        'marker': marker,
        'unicode': 'Zażółć gęślą jaźń ⚽',
        'nested': <dynamic>['preserve', 17],
      },
    },
    'leagueState': <String, dynamic>{
      'gamePayload': <dynamic>['unchanged', marker, 42],
      'nested': <String, dynamic>{'team': 'Lions FC'},
    },
    'saveSeed': 987654,
    'futureTopLevel': <String, dynamic>{'marker': marker},
  };
  await _saveFile(directory, meta.id).writeAsString(jsonEncode(raw));
}

Future<void> _writeIndex(
  Directory directory,
  Iterable<GameSaveMeta> metas,
) async {
  await _indexFile(directory).writeAsString(
    const JsonEncoder.withIndent(
      '  ',
    ).convert(metas.map((meta) => meta.toJson()).toList()),
  );
}

File _saveFile(Directory directory, String id) =>
    File('${directory.path}/$id.json');

File _indexFile(Directory directory) =>
    File('${directory.path}/saves_index.json');

Future<Map<String, dynamic>> _readJson(File file) async {
  return Map<String, dynamic>.from(
    jsonDecode(await file.readAsString()) as Map,
  );
}

Future<List<Map<String, dynamic>>> _readIndex(Directory directory) async {
  final decoded =
      jsonDecode(await _indexFile(directory).readAsString()) as List;
  return decoded
      .map((entry) => Map<String, dynamic>.from(entry as Map))
      .toList();
}

Map<String, dynamic> _withoutDuplicateOwnedFields(Map<String, dynamic> value) {
  final clone = Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);
  final meta = Map<String, dynamic>.from(clone['meta'] as Map)
    ..remove('id')
    ..remove('name')
    ..remove('createdAt')
    ..remove('updatedAt');
  clone['meta'] = meta;
  return clone;
}

Map<String, dynamic> _withoutName(Map<String, dynamic> value) {
  final clone = Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);
  final meta = Map<String, dynamic>.from(clone['meta'] as Map)..remove('name');
  clone['meta'] = meta;
  return clone;
}

List<FileSystemEntity> _transactionArtifacts(Directory directory) {
  if (!directory.existsSync()) return const [];
  return directory.listSync().where((entity) {
    return entity.path.contains('.tmp-') ||
        entity.path.contains('.bak-') ||
        entity.path.contains('.old-');
  }).toList();
}

GameSave _activeGame({required String id, required String name}) {
  final generated = GameFactory().create(
    const NewGameRequest(
      saveName: 'Generated active game',
      playerTeamId: 'team_europe_0',
      seed: 7811,
    ),
  );
  final timestamp = DateTime.utc(2032, 1, 2, 3, 4, 5);
  return generated.copyWith(
    meta: generated.meta.copyWith(
      id: id,
      name: name,
      createdAt: timestamp,
      updatedAt: timestamp,
      schemaVersion: SaveRepository.currentSchemaVersion,
    ),
  );
}

Future<_ControllerHarness> _openControllerHarness({
  required SaveRepository repository,
  required SaveManagementService service,
  required GameSave active,
  required String locale,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'app_locale': locale,
  });
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      saveRepositoryProvider.overrideWithValue(repository),
      saveManagementServiceProvider.overrideWithValue(service),
      sharedPreferencesProvider.overrideWithValue(preferences),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(active);
        return controller;
      }),
    ],
  );
  return _ControllerHarness(
    container: container,
    controller: container.read(gameControllerProvider.notifier),
  );
}

class _ControllerHarness {
  const _ControllerHarness({required this.container, required this.controller});

  final ProviderContainer container;
  final GameController controller;

  void dispose() => container.dispose();
}

class _SizeUnavailableRepository extends SaveRepository {
  _SizeUnavailableRepository(Directory directory, {required this.unavailableId})
    : super(overrideDirectory: directory);

  final String unavailableId;

  @override
  Future<SaveFileInfo> inspectFile(String id) async {
    if (id == unavailableId) return const SaveFileInfo.sizeUnavailable();
    return super.inspectFile(id);
  }
}
