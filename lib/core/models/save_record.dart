import 'package:new_football/core/models/game_save.dart';

/// Runtime-only information used to render and manage one save entry.
///
/// This model is intentionally separate from [GameSaveMeta]. In particular,
/// [serializedFileAvailable] and [sizeBytes] describe the current filesystem
/// state and must never be written to `saves_index.json`.
final class SaveRecord {
  const SaveRecord({
    required this.meta,
    required this.compatibility,
    required this.serializedFileAvailable,
    this.sizeBytes,
  });

  final GameSaveMeta meta;
  final SaveCompatibility compatibility;
  final bool serializedFileAvailable;
  final int? sizeBytes;

  /// Whether the canonical save file exists but its length could not be read.
  ///
  /// A missing file is represented by [serializedFileAvailable] being false,
  /// so it is not conflated with an unavailable file size.
  bool get sizeReadFailed =>
      serializedFileAvailable && sizeBytes == null;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SaveRecord &&
            other.meta == meta &&
            other.compatibility == compatibility &&
            other.serializedFileAvailable == serializedFileAvailable &&
            other.sizeBytes == sizeBytes;
  }

  @override
  int get hashCode => Object.hash(
    meta,
    compatibility,
    serializedFileAvailable,
    sizeBytes,
  );

  @override
  String toString() {
    return 'SaveRecord('
        'meta: $meta, '
        'compatibility: $compatibility, '
        'serializedFileAvailable: $serializedFileAvailable, '
        'sizeBytes: $sizeBytes)';
  }
}

/// Runtime-only inspection of a canonical `{id}.json` save file.
///
/// [exists] describes file presence. When it is true, a null [sizeBytes]
/// together with [sizeReadFailed] true means that reading the file length
/// failed. This is distinct from a missing file, where [exists] is false and
/// [sizeReadFailed] is false.
final class SaveFileInfo {
  const SaveFileInfo({
    required this.exists,
    this.sizeBytes,
    this.sizeReadFailed = false,
  });

  const SaveFileInfo.missing()
    : exists = false,
      sizeBytes = null,
      sizeReadFailed = false;

  const SaveFileInfo.available(int sizeBytes)
    : exists = true,
      sizeBytes = sizeBytes,
      sizeReadFailed = false;

  const SaveFileInfo.sizeUnavailable()
    : exists = true,
      sizeBytes = null,
      sizeReadFailed = true;

  final bool exists;
  final int? sizeBytes;
  final bool sizeReadFailed;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SaveFileInfo &&
            other.exists == exists &&
            other.sizeBytes == sizeBytes &&
            other.sizeReadFailed == sizeReadFailed;
  }

  @override
  int get hashCode => Object.hash(exists, sizeBytes, sizeReadFailed);

  @override
  String toString() {
    return 'SaveFileInfo('
        'exists: $exists, '
        'sizeBytes: $sizeBytes, '
        'sizeReadFailed: $sizeReadFailed)';
  }
}

/// The management operation represented by a successful result.
enum SaveManagementOperation { duplicate, rename }

/// Runtime-only result returned after a duplicate or rename succeeds.
///
/// The metadata is returned separately from [GameSave] because management
/// operations must preserve the serialized payload and do not need to decode
/// or persist this wrapper.
final class SaveManagementResult {
  const SaveManagementResult({required this.meta, required this.operation});

  const SaveManagementResult.duplicate(GameSaveMeta meta)
    : this(meta: meta, operation: SaveManagementOperation.duplicate);

  const SaveManagementResult.rename(GameSaveMeta meta)
    : this(meta: meta, operation: SaveManagementOperation.rename);

  final GameSaveMeta meta;
  final SaveManagementOperation operation;

  bool get isDuplicate => operation == SaveManagementOperation.duplicate;
  bool get isRename => operation == SaveManagementOperation.rename;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SaveManagementResult &&
            other.meta == meta &&
            other.operation == operation;
  }

  @override
  int get hashCode => Object.hash(meta, operation);

  @override
  String toString() {
    return 'SaveManagementResult(meta: $meta, operation: $operation)';
  }
}

/// Locale-independent, typed failure codes for save-management operations.
///
/// The enum deliberately carries no presentation text. The UI maps a code to
/// the active [AppLocalizations] string, while repository causes remain in
/// their original exceptions.
enum SaveManagementFailure {
  emptyName,
  sameName,
  nameTaken,
  sourceUnavailable,
  invalidSerializedSave,
  writeFailed,
  ambiguousWrite,
  indexReadFailed,
}
