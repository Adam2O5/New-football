@Tags(['unit'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_repository.dart';
import 'package:new_football/data/save_management_repository_adapter.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/fixtures/game_fixtures.dart';
import '../helpers/persistence/no_disk_save_repository.dart';

void main() {
  late GameSaveMeta meta;
  setUpAll(() => meta = controllerSave().meta);
  final operations =
      <String, Future<Object?> Function(SaveManagementRepositoryAdapter)>{
        'list': (adapter) => adapter.listSaves(),
        'inspect': (adapter) => adapter.inspectFile('source'),
        'available': (adapter) => adapter.isSaveIdAvailable('candidate'),
        'rename': (adapter) => adapter.renameRaw(id: 'source', newName: 'new'),
        'duplicate': (adapter) =>
            adapter.duplicateRaw(sourceId: 'source', duplicateMeta: meta),
      };
  final failures = [
    (
      SaveFileNotFoundException(saveId: 'source'),
      SaveManagementFailure.sourceUnavailable,
    ),
    (
      InvalidSerializedSaveException(saveId: 'source', reason: 'broken'),
      SaveManagementFailure.invalidSerializedSave,
    ),
    (
      SaveAmbiguousWriteException(saveId: 'source'),
      SaveManagementFailure.ambiguousWrite,
    ),
  ];
  for (final operation in operations.entries) {
    for (final (cause, expected) in failures) {
      test(
        '${operation.key} translates ${cause.runtimeType} at the data boundary',
        () async {
          final adapter = SaveManagementRepositoryAdapter(
            _FailingRepository(cause),
          );
          await expectLater(
            operation.value(adapter),
            throwsA(
              isA<SaveManagementException>()
                  .having((e) => e.code, 'code', expected)
                  .having((e) => e.cause, 'cause', same(cause)),
            ),
          );
        },
      );
    }
    test('${operation.key} uses its operation-specific fallback', () async {
      final expected = operation.key == 'list' || operation.key == 'available'
          ? SaveManagementFailure.indexReadFailed
          : SaveManagementFailure.writeFailed;
      final adapter = SaveManagementRepositoryAdapter(
        _FailingRepository(StateError('I/O failed')),
      );
      await expectLater(
        operation.value(adapter),
        throwsA(
          isA<SaveManagementException>().having(
            (e) => e.code,
            'code',
            expected,
          ),
        ),
      );
    });
    test('${operation.key} preserves an already typed failure', () async {
      const failure = SaveManagementException(
        SaveManagementFailure.ambiguousWrite,
      );
      final adapter = SaveManagementRepositoryAdapter(
        _FailingRepository(failure),
      );
      await expectLater(operation.value(adapter), throwsA(same(failure)));
    });
  }
}

class _FailingRepository extends NoDiskSaveRepository {
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
