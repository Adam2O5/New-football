import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_repository.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/data/save_management_repository_adapter.dart';
import 'package:new_football/data/save_repository.dart';

import 'support/game_fixtures.dart';

class _Store implements SaveManagementRepository {
  _Store(List<GameSaveMeta> initial)
    : metas = {for (final m in initial) m.id: m};
  final Map<String, GameSaveMeta> metas;
  final checkedIds = <String>[];
  @override
  Future<List<GameSaveMeta>> listSaves() async => metas.values.toList();
  @override
  Future<SaveFileInfo> inspectFile(String id) async =>
      const SaveFileInfo.available(123);
  @override
  Future<bool> isSaveIdAvailable(String id) async {
    checkedIds.add(id);
    return !metas.containsKey(id);
  }

  @override
  Future<GameSaveMeta> renameRaw({
    required String id,
    required String newName,
  }) async => metas[id] = metas[id]!.copyWith(name: newName);
  @override
  Future<GameSaveMeta> duplicateRaw({
    required String sourceId,
    required GameSaveMeta duplicateMeta,
  }) async => metas[duplicateMeta.id] = duplicateMeta;
}

class _FailingRepository extends SaveRepository {
  _FailingRepository(this.error);
  final Object error;
  @override
  Future<List<GameSaveMeta>> listSaves() async => throw error;
  @override
  Future<SaveFileInfo> inspectFile(String id) async => throw error;
  @override
  Future<bool> isSaveIdAvailable(String id) async => throw error;
  @override
  Future<GameSaveMeta> renameRaw({
    required String id,
    required String newName,
  }) async => throw error;
  @override
  Future<GameSaveMeta> duplicateRaw({
    required String sourceId,
    required GameSaveMeta duplicateMeta,
  }) async => throw error;
}

void main() {
  test(
    'core naming, ID collisions, timestamps and list projection use only interface',
    () async {
      final meta = controllerSave().meta.copyWith(name: 'Żółw');
      final store = _Store([
        meta,
        meta.copyWith(id: 'taken', name: 'Żółw-kopia'),
      ]);
      final ids = ['taken', 'copy'].iterator;
      final now = DateTime.utc(2030, 5, 6);
      final service = SaveManagementService(
        repository: store,
        clock: () => now,
        idGenerator: () {
          ids.moveNext();
          return ids.current;
        },
      );
      final copied = await service.duplicate(meta.id, localeCode: 'pl');
      expect(
        copied.meta,
        meta.copyWith(
          id: 'copy',
          name: 'Żółw-kopia-2',
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(store.checkedIds, ['taken', 'copy']);
      final renamed = await service.rename(meta.id, '  New name  ');
      expect(renamed.meta, meta.copyWith(name: 'New name'));
      final records = await service.listRecords();
      expect(records, hasLength(3));
      expect(
        records.every(
          (r) =>
              r.sizeBytes == 123 &&
              r.serializedFileAvailable &&
              r.compatibility == SaveCompatibility.compatible,
        ),
        isTrue,
      );
    },
  );

  test('rename validation retains neutral failure codes', () async {
    final meta = controllerSave().meta.copyWith(name: 'Żółw');
    final service = SaveManagementService(
      repository: _Store([meta, meta.copyWith(id: 'other', name: 'Other')]),
    );
    for (final (id, name, code) in [
      (meta.id, '  ', SaveManagementFailure.emptyName),
      (meta.id, 'zolw', SaveManagementFailure.sameName),
      (meta.id, ' OTHER ', SaveManagementFailure.nameTaken),
      ('missing', 'New name', SaveManagementFailure.sourceUnavailable),
    ]) {
      await expectLater(
        service.rename(id, name),
        throwsA(
          isA<SaveManagementException>().having((e) => e.code, 'code', code),
        ),
      );
    }
  });

  test(
    'adapter maps infrastructure errors for every persistence operation',
    () async {
      final meta = controllerSave().meta;
      for (final (error, expected) in <(Object, SaveManagementFailure?)>[
        (
          SaveAmbiguousWriteException(saveId: meta.id),
          SaveManagementFailure.ambiguousWrite,
        ),
        (
          SaveFileNotFoundException(saveId: meta.id),
          SaveManagementFailure.sourceUnavailable,
        ),
        (
          InvalidSerializedSaveException(saveId: meta.id, reason: 'bad JSON'),
          SaveManagementFailure.invalidSerializedSave,
        ),
        (SaveRepositoryException('I/O'), null),
        (
          const SaveManagementException(SaveManagementFailure.ambiguousWrite),
          SaveManagementFailure.ambiguousWrite,
        ),
      ]) {
        final adapter = SaveManagementRepositoryAdapter(
          _FailingRepository(error),
        );
        final operations =
            <(Future<Object?> Function(), SaveManagementFailure)>[
              (adapter.listSaves, SaveManagementFailure.indexReadFailed),
              (
                () => adapter.inspectFile(meta.id),
                SaveManagementFailure.writeFailed,
              ),
              (
                () => adapter.isSaveIdAvailable(meta.id),
                SaveManagementFailure.indexReadFailed,
              ),
              (
                () => adapter.renameRaw(id: meta.id, newName: 'New'),
                SaveManagementFailure.writeFailed,
              ),
              (
                () => adapter.duplicateRaw(
                  sourceId: meta.id,
                  duplicateMeta: meta.copyWith(id: 'copy'),
                ),
                SaveManagementFailure.writeFailed,
              ),
            ];
        for (final (operation, fallback) in operations) {
          await expectLater(
            operation(),
            throwsA(
              isA<SaveManagementException>()
                  .having((e) => e.code, 'code', expected ?? fallback)
                  .having(
                    (e) => error is SaveManagementException
                        ? identical(e, error)
                        : identical(e.cause, error),
                    'original cause is retained',
                    isTrue,
                  ),
            ),
          );
        }
      }
    },
  );

  test(
    'injected data adapter preserves actual disk rename and duplicate',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'stage-seven-store-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final repository = SaveRepository(overrideDirectory: directory);
      final game = controllerSave();
      await repository.save(game);
      final service = SaveManagementService(
        repository: SaveManagementRepositoryAdapter(repository),
        idGenerator: () => 'copy',
      );
      final renamed = await service.rename(game.meta.id, 'Renamed');
      final duplicated = await service.duplicate(
        game.meta.id,
        localeCode: 'en',
      );
      expect(duplicated.meta.name, 'Renamed-copy');
      expect((await repository.load(game.meta.id)).meta, renamed.meta);
      expect((await repository.load('copy')).leagueState, game.leagueState);
      expect(await service.listRecords(), hasLength(2));
    },
  );
}
