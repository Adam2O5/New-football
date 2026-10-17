import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_repository.dart';
import 'package:new_football/data/save_repository.dart';

/// Translates filesystem/recovery errors at the data boundary without adding
/// a queue or taking over the repository's directory lock and transactions.
class SaveManagementRepositoryAdapter implements SaveManagementRepository {
  SaveManagementRepositoryAdapter(this._repository);

  final SaveRepository _repository;

  @override
  Future<List<GameSaveMeta>> listSaves() => _run(
    _repository.listSaves,
    fallback: SaveManagementFailure.indexReadFailed,
  );

  @override
  Future<SaveFileInfo> inspectFile(String id) =>
      _run(() => _repository.inspectFile(id));

  @override
  Future<bool> isSaveIdAvailable(String id) => _run(
    () => _repository.isSaveIdAvailable(id),
    fallback: SaveManagementFailure.indexReadFailed,
  );

  @override
  Future<GameSaveMeta> renameRaw({
    required String id,
    required String newName,
  }) => _run(() => _repository.renameRaw(id: id, newName: newName));

  @override
  Future<GameSaveMeta> duplicateRaw({
    required String sourceId,
    required GameSaveMeta duplicateMeta,
  }) => _run(
    () => _repository.duplicateRaw(
      sourceId: sourceId,
      duplicateMeta: duplicateMeta,
    ),
  );

  Future<T> _run<T>(
    Future<T> Function() operation, {
    SaveManagementFailure fallback = SaveManagementFailure.writeFailed,
  }) async {
    try {
      return await operation();
    } catch (error) {
      if (error is SaveManagementException) rethrow;
      final code = switch (error) {
        SaveAmbiguousWriteException() => SaveManagementFailure.ambiguousWrite,
        SaveFileNotFoundException() => SaveManagementFailure.sourceUnavailable,
        InvalidSerializedSaveException() =>
          SaveManagementFailure.invalidSerializedSave,
        _ => fallback,
      };
      throw SaveManagementException(code, cause: error);
    }
  }
}
