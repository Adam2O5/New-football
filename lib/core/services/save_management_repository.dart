import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';

/// A locale-independent failure raised by a save-management operation.
///
/// [code] is the only value the presentation layer should use for localized
/// feedback. [cause] keeps the repository exception (when one exists) for
/// logging and diagnostics without making repository text part of the domain
/// contract.
class SaveManagementException implements Exception {
  const SaveManagementException(this.code, {this.cause});

  final SaveManagementFailure code;
  final Object? cause;

  /// Alias that makes the domain nature of [code] explicit at call sites.
  SaveManagementFailure get failure => code;

  @override
  String toString() {
    return 'SaveManagementException: ${code.name}'
        '${cause == null ? '' : ' ($cause)'}';
  }
}

/// Compatibility alias for callers that use the failure-oriented name.
typedef SaveManagementFailureException = SaveManagementException;

/// The persistence operations needed by save management. Implementations
/// translate infrastructure failures into [SaveManagementException].
/// Serialization and directory locking stay with the implementation.
abstract interface class SaveManagementRepository {
  Future<List<GameSaveMeta>> listSaves();
  Future<SaveFileInfo> inspectFile(String id);
  Future<bool> isSaveIdAvailable(String id);
  Future<GameSaveMeta> renameRaw({required String id, required String newName});
  Future<GameSaveMeta> duplicateRaw({
    required String sourceId,
    required GameSaveMeta duplicateMeta,
  });
}
