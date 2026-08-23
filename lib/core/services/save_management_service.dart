import 'package:uuid/uuid.dart';

import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_name_policy.dart';
import 'package:new_football/data/save_repository.dart';

/// Supplies the timestamp used by a save-management operation.
typedef SaveManagementClock = DateTime Function();

/// Supplies candidate IDs for duplicated saves.
typedef SaveIdGenerator = String Function();

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

/// Coordinates save-list inspection and raw duplicate/rename operations.
///
/// This service intentionally does not own a queue. Application code must
/// enqueue its calls through the controller's shared mutation queue. The
/// repository remains responsible for canonical paths and two-file
/// transactions, while this class owns naming, ID selection, compatibility
/// projection, and domain-level failure mapping.
class SaveManagementService {
  SaveManagementService({
    SaveRepository? repository,
    SaveManagementClock? clock,
    SaveIdGenerator? idGenerator,
  }) : _repository = repository ?? SaveRepository(),
       _clock = clock ?? DateTime.now,
       _idGenerator = idGenerator ?? _defaultId;

  final SaveRepository _repository;
  final SaveManagementClock _clock;
  final SaveIdGenerator _idGenerator;

  static String _defaultId() => const Uuid().v4();

  /// Reads the current index and inspects the canonical file for every entry.
  ///
  /// The index remains the sole source of records. A failure to inspect one
  /// file is local to that row and is represented as an existing file with an
  /// unavailable size, so the other rows remain visible and no size is
  /// silently replaced with zero.
  Future<List<SaveRecord>> listRecords() async {
    final metas = await _readIndex();
    final records = <SaveRecord>[];

    for (final meta in metas) {
      final fileInfo = await _inspectForList(meta.id);
      records.add(
        SaveRecord(
          meta: meta,
          compatibility: meta.compatibilityWith(
            SaveRepository.currentSchemaVersion,
          ),
          serializedFileAvailable: fileInfo.exists,
          sizeBytes: fileInfo.sizeBytes,
        ),
      );
    }

    return records;
  }

  /// Creates a raw duplicate of the source save without decoding its payload.
  ///
  /// The index and source metadata are read at operation time. The repository
  /// then re-reads the canonical source inside [SaveRepository.duplicateRaw],
  /// which preserves management support for older and newer schemas.
  Future<SaveManagementResult> duplicate(
    String sourceId, {
    required String localeCode,
  }) async {
    final metas = await _readIndex();
    final source = _findMeta(metas, sourceId);
    if (source == null) {
      throw const SaveManagementException(
        SaveManagementFailure.sourceUnavailable,
      );
    }

    final duplicateName = _copyName(source, metas, localeCode);
    final duplicateId = await _nextAvailableId();
    final timestamp = _clock();
    final duplicateMeta = source.copyWith(
      id: duplicateId,
      name: duplicateName,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    try {
      final persistedMeta = await _repository.duplicateRaw(
        sourceId: sourceId,
        duplicateMeta: duplicateMeta,
      );
      return SaveManagementResult.duplicate(persistedMeta);
    } catch (error) {
      throw _mapRepositoryFailure(error);
    }
  }

  /// Renames a raw save while preserving its payload and all other metadata.
  ///
  /// Validation is performed against a fresh index before the repository is
  /// asked to publish anything. The stored name is trimmed display text; the
  /// canonical [SaveNamePolicy.nameKey] is used only for collision checks.
  Future<SaveManagementResult> rename(
    String saveId,
    String proposedName,
  ) async {
    final trimmedName = SaveNamePolicy.trimName(proposedName);
    if (trimmedName.isEmpty) {
      throw const SaveManagementException(SaveManagementFailure.emptyName);
    }

    final metas = await _readIndex();
    final current = _findMeta(metas, saveId);
    if (current == null) {
      throw const SaveManagementException(
        SaveManagementFailure.sourceUnavailable,
      );
    }

    final candidateKey = _nameKey(trimmedName);
    final currentKey = _nameKey(current.name);
    if (candidateKey == currentKey) {
      throw const SaveManagementException(SaveManagementFailure.sameName);
    }

    final nameTaken = metas.any(
      (meta) => meta.id != saveId && _nameKey(meta.name) == candidateKey,
    );
    if (nameTaken) {
      throw const SaveManagementException(SaveManagementFailure.nameTaken);
    }

    try {
      final persistedMeta = await _repository.renameRaw(
        id: saveId,
        newName: trimmedName,
      );
      return SaveManagementResult.rename(persistedMeta);
    } catch (error) {
      throw _mapRepositoryFailure(error);
    }
  }

  Future<List<GameSaveMeta>> _readIndex() async {
    try {
      return await _repository.listSaves();
    } catch (error) {
      throw _mapRepositoryFailure(
        error,
        fallback: SaveManagementFailure.indexReadFailed,
      );
    }
  }

  Future<SaveFileInfo> _inspectForList(String id) async {
    try {
      return await _repository.inspectFile(id);
    } catch (_) {
      // The repository normally converts File.length failures to this value.
      // Keep the service resilient to repository doubles and platform-specific
      // inspection failures as well; one unavailable size must not hide rows.
      return const SaveFileInfo.sizeUnavailable();
    }
  }

  Future<String> _nextAvailableId() async {
    while (true) {
      final candidate = _idGenerator();
      try {
        if (await _repository.isSaveIdAvailable(candidate)) {
          return candidate;
        }
      } catch (error) {
        throw _mapRepositoryFailure(
          error,
          fallback: SaveManagementFailure.indexReadFailed,
        );
      }
    }
  }

  String _copyName(
    GameSaveMeta source,
    Iterable<GameSaveMeta> metas,
    String localeCode,
  ) {
    try {
      final occupiedKeys = <String>{
        for (final meta in metas) _nameKey(meta.name),
      };
      return SaveNamePolicy.copyName(source.name, localeCode, occupiedKeys);
    } catch (error) {
      throw _mapRepositoryFailure(
        error,
        fallback: SaveManagementFailure.invalidSerializedSave,
      );
    }
  }

  String _nameKey(String name) {
    try {
      return SaveNamePolicy.nameKey(name);
    } catch (error) {
      throw _mapRepositoryFailure(
        error,
        fallback: SaveManagementFailure.invalidSerializedSave,
      );
    }
  }

  static GameSaveMeta? _findMeta(Iterable<GameSaveMeta> metas, String id) {
    for (final meta in metas) {
      if (meta.id == id) return meta;
    }
    return null;
  }

  SaveManagementException _mapRepositoryFailure(
    Object error, {
    SaveManagementFailure fallback = SaveManagementFailure.writeFailed,
  }) {
    if (error is SaveManagementException) return error;
    if (error is SaveAmbiguousWriteException) {
      return SaveManagementException(
        SaveManagementFailure.ambiguousWrite,
        cause: error,
      );
    }
    if (error is SaveFileNotFoundException) {
      return SaveManagementException(
        SaveManagementFailure.sourceUnavailable,
        cause: error,
      );
    }
    if (error is InvalidSerializedSaveException) {
      return SaveManagementException(
        SaveManagementFailure.invalidSerializedSave,
        cause: error,
      );
    }
    return SaveManagementException(fallback, cause: error);
  }
}
