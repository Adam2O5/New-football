import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/data/staff_data_compatibility.dart';

class SaveRepositoryException implements Exception {
  SaveRepositoryException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'SaveRepositoryException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Raised when a failed save could not be reconciled to the previous state.
///
/// Callers must not treat this exception as a successful save. The repository
/// leaves its recovery artifacts in place so a later reconciliation can inspect
/// the files instead of deleting the only remaining copy.
class SaveAmbiguousWriteException extends SaveRepositoryException {
  SaveAmbiguousWriteException({required this.saveId, Object? cause})
    : super(
        'Save $saveId has an ambiguous write outcome; reconciliation is '
        'required',
        cause: cause,
      );

  final String saveId;
}

enum SaveRepositoryWriteStage { gameFile, indexFile }

typedef SaveRepositoryPublishHook =
    Future<void> Function(SaveRepositoryWriteStage stage);

class SaveSchemaMismatchException extends SaveRepositoryException {
  SaveSchemaMismatchException({
    required this.foundVersion,
    required this.supportedVersion,
  }) : super(
         'Save schema $foundVersion is not compatible with supported '
         'schema $supportedVersion',
       );

  final int foundVersion;
  final int supportedVersion;

  bool get isOlder => foundVersion < supportedVersion;
  bool get isNewer => foundVersion > supportedVersion;
}

/// Raised when a canonical save file is required but is not present.
///
/// This is intentionally separate from [SaveRepositoryException] instances
/// for malformed serialized data so management callers can report an
/// unavailable source without treating it as a corrupt source.
class SaveFileNotFoundException extends SaveRepositoryException {
  SaveFileNotFoundException({required this.saveId})
    : super('Save file not found: $saveId');

  final String saveId;
}

/// Raised when a canonical save file cannot be parsed or has an invalid raw
/// object shape or identity.
class InvalidSerializedSaveException extends SaveRepositoryException {
  InvalidSerializedSaveException({
    required this.saveId,
    required String reason,
    Object? cause,
  }) : super('Invalid serialized save $saveId: $reason', cause: cause);

  final String saveId;
}

class SaveRepository {
  SaveRepository({
    Directory? overrideDirectory,
    SaveRepositoryPublishHook? beforePublish,
  }) : _overrideDirectory = overrideDirectory,
       _beforePublish = beforePublish;

  final Directory? _overrideDirectory;
  final SaveRepositoryPublishHook? _beforePublish;

  static int _transactionSequence = 0;

  /// Keep this alias stable for callers; the source of truth is [SaveSchema].
  static const currentSchemaVersion = SaveSchema.currentVersion;
  static const _indexFileName = 'saves_index.json';

  List<StaffDataDiagnostic> _lastStaffDiagnostics = const [];

  /// Recoverable staff-data issues found during the most recent load.
  ///
  /// The list is immutable and is replaced per load attempt. Schema errors and
  /// filesystem errors still throw as before; staff records that can be
  /// excluded safely are reported here while the valid save continues loading.
  List<StaffDataDiagnostic> get lastStaffDiagnostics => _lastStaffDiagnostics;

  Future<Directory> _savesDir() async {
    if (_overrideDirectory != null) {
      final dir = _overrideDirectory;
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/new_football/saves');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _indexFile() async {
    final dir = await _savesDir();
    return File('${dir.path}/$_indexFileName');
  }

  Future<File> _saveFile(String id) async {
    final dir = await _savesDir();
    return File('${dir.path}/$id.json');
  }

  /// Inspects only the canonical save file for [id].
  ///
  /// A missing canonical file is represented by [SaveFileInfo.missing]. If
  /// the file exists but its length cannot be read, the result preserves that
  /// distinction with [SaveFileInfo.sizeUnavailable] rather than reporting a
  /// misleading zero-byte file. Temporary, backup, and displaced files are
  /// never considered by this method.
  Future<SaveFileInfo> inspectFile(String id) async {
    final file = await _saveFile(id);
    if (!await file.exists()) return const SaveFileInfo.missing();

    try {
      return SaveFileInfo.available(await file.length());
    } catch (_) {
      return const SaveFileInfo.sizeUnavailable();
    }
  }

  /// Returns whether [id] is absent from the current index and from the
  /// canonical `{id}.json` path on disk.
  ///
  /// [listSaves] is deliberately called for every invocation so a caller
  /// cannot make an availability decision from a stale index snapshot.
  Future<bool> isSaveIdAvailable(String id) async {
    final indexed = (await listSaves()).any((meta) => meta.id == id);
    if (indexed) return false;

    final canonicalFile = await _saveFile(id);
    return !(await canonicalFile.exists());
  }

  /// Reads and validates the canonical raw JSON for [sourceId].
  ///
  /// This is a management-only raw read: it does not decode a [GameSave],
  /// so callers can inspect older or newer schemas without changing the
  /// existing [load] compatibility contract.
  Future<Map<String, dynamic>> readRawSave(String sourceId) {
    return _readRawSaveJson(sourceId);
  }

  /// Creates a duplicate from the canonical raw snapshot for [sourceId].
  ///
  /// This operation deliberately does not decode [GameSave]. The source may
  /// use an older or newer schema, and management must be able to copy its
  /// payload and unknown metadata verbatim. Only the four duplicate-owned
  /// metadata fields are replaced; all other raw fields remain unchanged.
  /// The game file and index are committed through the same two-file
  /// transaction used by [save], and success is returned only after the raw
  /// snapshot and exact-one index entry have been verified.
  Future<GameSaveMeta> duplicateRaw({
    required String sourceId,
    required GameSaveMeta duplicateMeta,
  }) async {
    // Read the source before doing any writes, and read it from the canonical
    // path only. This keeps a pending/old transaction artifact from becoming
    // the source and preserves the distinct missing-vs-invalid exceptions.
    final sourceJson = await _readRawSaveJson(sourceId);
    final sourceMeta = Map<String, dynamic>.from(sourceJson['meta'] as Map);
    final duplicateMetaJson = duplicateMeta.toJson();
    final duplicateRawMeta = Map<String, dynamic>.from(sourceMeta);
    for (final key in const ['id', 'name', 'createdAt', 'updatedAt']) {
      duplicateRawMeta[key] = duplicateMetaJson[key];
    }
    final duplicateJson = <String, dynamic>{
      ...sourceJson,
      'meta': duplicateRawMeta,
    };

    final currentMetas = await listSaves();
    if (duplicateMeta.id == sourceId ||
        currentMetas.any((meta) => meta.id == duplicateMeta.id)) {
      throw SaveRepositoryException(
        'Duplicate save id is already in use: ${duplicateMeta.id}',
      );
    }

    final duplicateFile = await _saveFile(duplicateMeta.id);
    if (await duplicateFile.exists()) {
      throw SaveRepositoryException(
        'Duplicate save file already exists: ${duplicateMeta.id}',
      );
    }

    final transaction = _prepareTwoFileTransaction(
      saveId: duplicateMeta.id,
      gameFile: duplicateFile,
      indexFile: await _indexFile(),
    );
    final gameTemporary = transaction.gameFile.temporary;
    final indexTemporary = transaction.indexFile.temporary;

    try {
      final indexJson = const JsonEncoder.withIndent('  ').convert(
        [...currentMetas, duplicateMeta].map((m) => m.toJson()).toList(),
      );
      final gameJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(duplicateJson);

      await _writeTemporary(gameTemporary, gameJson);
      await _writeTemporary(indexTemporary, indexJson);
      await _commitPreparedFiles(
        transaction,
        verify: () => _verifyRawCommit(
          transaction,
          expectedGameJson: duplicateJson,
          expectedIndexMeta: duplicateMetaJson,
        ),
      );
      return duplicateMeta;
    } catch (e) {
      if (e is SaveRepositoryException) rethrow;
      throw SaveRepositoryException(
        'Failed to duplicate save ${duplicateMeta.id}',
        cause: e,
      );
    } finally {
      await _deleteIfExists(gameTemporary);
      await _deleteIfExists(indexTemporary);
    }
  }

  /// Renames a canonical raw save without decoding its game payload.
  ///
  /// Only the raw `meta.name` field is changed. The source may use an older or
  /// newer schema, and unknown top-level and metadata fields are retained
  /// because the operation copies the decoded raw object and changes that one
  /// field. The index is rebuilt from its current entries with all entries for
  /// [id] replaced by exactly one renamed entry.
  ///
  /// The file and index are committed by the same two-file transaction used by
  /// [save] and [duplicateRaw]. Verification compares the complete raw file,
  /// the exact target index metadata, and the target ID before success is
  /// returned. Any publication failure therefore restores the previous name
  /// in both artifacts, or propagates [SaveAmbiguousWriteException] when that
  /// restoration cannot be completed.
  Future<GameSaveMeta> renameRaw({
    required String id,
    required String newName,
  }) async {
    // Read only the canonical file at operation time. This intentionally
    // avoids GameSave.fromJson so older/newer schemas remain manageable.
    final sourceJson = await _readRawSaveJson(id);
    final sourceMeta = Map<String, dynamic>.from(sourceJson['meta'] as Map);
    final previousName = sourceMeta['name'];
    if (previousName is! String) {
      throw InvalidSerializedSaveException(
        saveId: id,
        reason: 'metadata name is missing or invalid',
      );
    }

    final currentMetas = await listSaves();
    final indexedMetas = currentMetas.where((meta) => meta.id == id).toList();
    if (indexedMetas.isEmpty) {
      throw SaveRepositoryException(
        'Save index does not contain save $id',
      );
    }
    if (indexedMetas.any((meta) => meta.name != previousName)) {
      throw SaveRepositoryException(
        'Serialized save $id and save index have different names',
      );
    }

    // Replacing all existing entries for the ID both preserves the existing
    // index and guarantees that a malformed duplicate ID cannot result in a
    // second matching entry after rename.
    final renamedMeta = indexedMetas.first.copyWith(name: newName);
    final renamedIndex = <GameSaveMeta>[
      ...currentMetas.where((meta) => meta.id != id),
      renamedMeta,
    ];
    final renamedRawMeta = Map<String, dynamic>.from(sourceMeta)
      ..['name'] = newName;
    final renamedJson = <String, dynamic>{
      ...sourceJson,
      'meta': renamedRawMeta,
    };

    final transaction = _prepareTwoFileTransaction(
      saveId: id,
      gameFile: await _saveFile(id),
      indexFile: await _indexFile(),
    );
    final gameTemporary = transaction.gameFile.temporary;
    final indexTemporary = transaction.indexFile.temporary;

    try {
      final gameJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(renamedJson);
      final indexJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(renamedIndex.map((meta) => meta.toJson()).toList());

      await _writeTemporary(gameTemporary, gameJson);
      await _writeTemporary(indexTemporary, indexJson);
      await _commitPreparedFiles(
        transaction,
        verify: () => _verifyRawCommit(
          transaction,
          expectedGameJson: renamedJson,
          expectedIndexMeta: renamedMeta.toJson(),
        ),
      );
      return renamedMeta;
    } catch (e) {
      if (e is SaveRepositoryException) rethrow;
      throw SaveRepositoryException(
        'Failed to rename save $id',
        cause: e,
      );
    } finally {
      await _deleteIfExists(gameTemporary);
      await _deleteIfExists(indexTemporary);
    }
  }

  /// Reads and validates the canonical raw JSON for [sourceId].
  ///
  /// This helper is intentionally raw and does not call [GameSave.fromJson],
  /// allowing management operations to handle saves from older or newer
  /// schemas. It never searches the directory, so `.tmp-*`, `.bak-*`, and
  /// `.old-*` transaction artifacts cannot become a source accidentally.
  Future<Map<String, dynamic>> _readRawSaveJson(String sourceId) async {
    final file = await _saveFile(sourceId);
    if (!await file.exists()) {
      throw SaveFileNotFoundException(saveId: sourceId);
    }

    late final String contents;
    try {
      contents = await file.readAsString();
    } catch (e) {
      throw InvalidSerializedSaveException(
        saveId: sourceId,
        reason: 'file could not be read',
        cause: e,
      );
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(contents);
    } catch (e) {
      throw InvalidSerializedSaveException(
        saveId: sourceId,
        reason: 'JSON could not be decoded',
        cause: e,
      );
    }

    return _validateRawSaveJson(decoded, sourceId: sourceId);
  }

  /// Validates the minimum raw snapshot contract needed by management.
  ///
  /// Schema compatibility is intentionally not checked here. Management must
  /// be able to copy or rename an older/newer snapshot, but it must not accept
  /// a non-object, missing metadata, or a metadata object belonging to a
  /// different source ID.
  Map<String, dynamic> _validateRawSaveJson(
    Object? decoded, {
    required String sourceId,
  }) {
    if (decoded is! Map) {
      throw InvalidSerializedSaveException(
        saveId: sourceId,
        reason: 'root JSON value is not an object',
      );
    }

    final json = Map<String, dynamic>.from(decoded);
    final rawMeta = json['meta'];
    if (rawMeta is! Map) {
      throw InvalidSerializedSaveException(
        saveId: sourceId,
        reason: 'metadata object is missing',
      );
    }

    final meta = Map<String, dynamic>.from(rawMeta);
    if (meta['id'] != sourceId) {
      throw InvalidSerializedSaveException(
        saveId: sourceId,
        reason: 'metadata id does not match the source id',
      );
    }

    return json;
  }

  Future<List<GameSaveMeta>> listSaves() async {
    final file = await _indexFile();
    if (!await file.exists()) return [];
    try {
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      return raw
          .map((e) => GameSaveMeta.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      throw SaveRepositoryException('Failed to read saves index', cause: e);
    }
  }

  Future<void> _writeIndex(List<GameSaveMeta> metas) async {
    final file = await _indexFile();
    await file.writeAsString(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(metas.map((m) => m.toJson()).toList()),
    );
  }

  int _readSchemaVersion(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is num ? value.toInt() : SaveSchema.unknownVersion;
  }

  void _assertCompatible(int foundVersion) {
    if (foundVersion != currentSchemaVersion) {
      throw SaveSchemaMismatchException(
        foundVersion: foundVersion,
        supportedVersion: currentSchemaVersion,
      );
    }
  }

  Future<GameSave> load(String id) async {
    _lastStaffDiagnostics = const [];
    final file = await _saveFile(id);
    if (!await file.exists()) {
      throw SaveRepositoryException('Save not found: $id');
    }
    try {
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;

      // Check versions before decoding LeagueState. A future schema may no
      // longer be parseable by the current model.
      _assertCompatible(_readSchemaVersion(json, 'schemaVersion'));
      final metaJson = json['meta'];
      final metaVersion = metaJson is Map<String, dynamic>
          ? _readSchemaVersion(metaJson, 'schemaVersion')
          : SaveSchema.unknownVersion;
      _assertCompatible(metaVersion);

      // Generated StaffMember decoders use enum decoding for role. Normalize
      // only the staff subtrees after schema validation and before any
      // generated model decoder is invoked. The player/save transaction flow
      // remains untouched, and valid non-staff JSON is copied verbatim.
      final staffResult = StaffDataCompatibility.sanitizeGameSaveJson(json);
      _lastStaffDiagnostics = staffResult.diagnostics;
      return GameSave.fromJson(staffResult.sanitizedJson);
    } catch (e) {
      if (e is SaveRepositoryException) rethrow;
      throw SaveRepositoryException('Failed to load save $id', cause: e);
    }
  }

  Future<void> save(GameSave gameSave) async {
    final stamped = gameSave.copyWith(
      schemaVersion: currentSchemaVersion,
      meta: gameSave.meta.copyWith(
        schemaVersion: currentSchemaVersion,
        updatedAt: DateTime.now(),
      ),
    );
    final transaction = _prepareTwoFileTransaction(
      saveId: stamped.meta.id,
      gameFile: await _saveFile(stamped.meta.id),
      indexFile: await _indexFile(),
    );
    final gameTemporary = transaction.gameFile.temporary;
    final indexTemporary = transaction.indexFile.temporary;

    try {
      final metas = await listSaves();
      final filtered = metas.where((m) => m.id != stamped.meta.id).toList();
      final gameJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(stamped.toJson());
      final indexJson = const JsonEncoder.withIndent(
        '  ',
      ).convert([...filtered, stamped.meta].map((m) => m.toJson()).toList());

      await _writeTemporary(gameTemporary, gameJson);
      await _writeTemporary(indexTemporary, indexJson);
      await _commitPreparedFiles(
        transaction,
        verify: () => _verifyTypedCommit(transaction, stamped),
      );
    } catch (e) {
      if (e is SaveRepositoryException) rethrow;
      throw SaveRepositoryException(
        'Failed to write save ${stamped.meta.id}',
        cause: e,
      );
    } finally {
      await _deleteIfExists(gameTemporary);
      await _deleteIfExists(indexTemporary);
    }
  }

  _PreparedSaveTransaction _prepareTwoFileTransaction({
    required String saveId,
    required File gameFile,
    required File indexFile,
  }) {
    final transactionId =
        '${DateTime.now().microsecondsSinceEpoch}-'
        '${_transactionSequence++}';
    return _PreparedSaveTransaction(
      saveId: saveId,
      gameFile: _PreparedSaveFile(
        destination: gameFile,
        temporary: File('${gameFile.path}.tmp-$transactionId-game'),
        backup: File('${gameFile.path}.bak-$transactionId-game'),
        stage: SaveRepositoryWriteStage.gameFile,
      ),
      indexFile: _PreparedSaveFile(
        destination: indexFile,
        temporary: File('${indexFile.path}.tmp-$transactionId-index'),
        backup: File('${indexFile.path}.bak-$transactionId-index'),
        stage: SaveRepositoryWriteStage.indexFile,
      ),
    );
  }

  Future<void> _writeTemporary(File file, String contents) async {
    await file.writeAsString(contents, flush: true);
  }

  Future<void> _commitPreparedFiles(
    _PreparedSaveTransaction transaction, {
    required Future<void> Function() verify,
  }) async {
    final files = transaction.files;
    var committed = false;
    var rolledBack = false;

    try {
      // The order is part of the transaction contract: publish the game file
      // first and the index second. The index is never allowed to advertise a
      // snapshot whose game file has not been published and verified.
      for (final file in files) {
        if (await file.destination.exists()) {
          await file.destination.copy(file.backup.path);
          file.backupCreated = true;
        }

        await _beforePublish?.call(file.stage);
        await _publish(file);
      }

      await verify();
      committed = true;
    } catch (e) {
      try {
        await _rollback(files);
        rolledBack = true;
      } catch (rollbackError) {
        throw SaveAmbiguousWriteException(
          saveId: transaction.saveId,
          cause: SaveRepositoryException(
            'Save failed and rollback failed',
            cause: rollbackError,
          ),
        );
      }
      rethrow;
    } finally {
      // A successful commit or a completed rollback has a known safe state.
      // If rollback itself failed, retain recovery artifacts for inspection.
      if (committed || rolledBack) {
        for (final file in files) {
          await _deleteIfExists(file.backup);
          await _deleteIfExists(file.displaced);
        }
      }
    }
  }

  Future<void> _publish(_PreparedSaveFile file) async {
    try {
      // On POSIX this is an atomic replacement. The backup copy allows the
      // complete two-file operation to be rolled back if the next publish
      // fails.
      await file.temporary.rename(file.destination.path);
      file.published = true;
      return;
    } on FileSystemException {
      // Windows does not replace an existing file with rename. Move the old
      // destination aside and publish into the now-free path instead.
      if (!file.backupCreated) rethrow;
    }

    final displaced = File(
      '${file.destination.path}.old-${file.backup.path.hashCode}',
    );
    file.displaced = displaced;
    await file.destination.rename(displaced.path);
    try {
      await file.temporary.rename(file.destination.path);
      file.published = true;
    } catch (_) {
      // Restore the original immediately so the transaction rollback sees the
      // same state even when this individual replacement fails.
      await displaced.rename(file.destination.path);
      file.displaced = null;
      rethrow;
    }
  }

  Future<_CommittedSaveJson> _readCommittedJson(
    _PreparedSaveTransaction transaction,
  ) async {
    final gameJson =
        jsonDecode(await transaction.gameFile.destination.readAsString())
            as Map<String, dynamic>;
    final indexJson =
        jsonDecode(await transaction.indexFile.destination.readAsString())
            as List<dynamic>;
    return _CommittedSaveJson(gameJson: gameJson, indexJson: indexJson);
  }

  /// Verifies the shape and identity of a committed raw snapshot without
  /// decoding it through [GameSave.fromJson]. Management operations use the
  /// optional expected maps to validate older and newer schemas verbatim.
  Future<_CommittedSaveJson> _verifyRawCommit(
    _PreparedSaveTransaction transaction, {
    Map<String, dynamic>? expectedGameJson,
    Map<String, dynamic>? expectedIndexMeta,
  }) async {
    final committed = await _readCommittedJson(transaction);
    final metaJson = committed.gameJson['meta'];
    if (metaJson is! Map<String, dynamic> ||
        metaJson['id'] != transaction.saveId) {
      throw SaveRepositoryException(
        'Serialized save ${transaction.saveId} has invalid metadata',
      );
    }

    final matchingMeta = committed.indexJson
        .whereType<Map<String, dynamic>>()
        .where((meta) => meta['id'] == transaction.saveId)
        .toList();
    if (matchingMeta.length != 1) {
      throw SaveRepositoryException(
        'Save index does not contain exactly one save '
        '${transaction.saveId}',
      );
    }

    if (expectedGameJson != null &&
        !_jsonValuesEqual(committed.gameJson, expectedGameJson)) {
      throw SaveRepositoryException(
        'Serialized save ${transaction.saveId} does not match the '
        'expected raw snapshot',
      );
    }
    if (expectedIndexMeta != null &&
        (expectedIndexMeta['id'] != transaction.saveId ||
            !_jsonValuesEqual(matchingMeta.single, expectedIndexMeta))) {
      throw SaveRepositoryException(
        'Save index does not match the expected raw metadata for '
        '${transaction.saveId}',
      );
    }

    return committed;
  }

  Future<void> _verifyTypedCommit(
    _PreparedSaveTransaction transaction,
    GameSave stamped,
  ) async {
    final committed = await _verifyRawCommit(transaction);
    final persistedGame = GameSave.fromJson(committed.gameJson);
    if (persistedGame != stamped) {
      throw SaveRepositoryException(
        'Game save ${stamped.meta.id} does not match the committed snapshot',
      );
    }

    final matchingMeta = committed.indexJson
        .whereType<Map<String, dynamic>>()
        .where((meta) => meta['id'] == stamped.meta.id)
        .map(GameSaveMeta.fromJson)
        .toList();
    if (matchingMeta.length != 1 || matchingMeta.single != stamped.meta) {
      throw SaveRepositoryException(
        'Save index does not match save ${stamped.meta.id}',
      );
    }
  }

  bool _jsonValuesEqual(Object? left, Object? right) {
    if (left is Map && right is Map) {
      if (left.length != right.length) return false;
      for (final key in left.keys) {
        if (!right.containsKey(key) ||
            !_jsonValuesEqual(left[key], right[key])) {
          return false;
        }
      }
      return true;
    }
    if (left is List && right is List) {
      if (left.length != right.length) return false;
      for (var index = 0; index < left.length; index++) {
        if (!_jsonValuesEqual(left[index], right[index])) return false;
      }
      return true;
    }
    return left == right;
  }

  Future<void> _rollback(List<_PreparedSaveFile> files) async {
    Object? firstError;
    for (final file in files.reversed) {
      try {
        if (file.published && await file.destination.exists()) {
          await file.destination.delete();
        }
        final displaced = file.displaced;
        if (displaced != null && await displaced.exists()) {
          await displaced.rename(file.destination.path);
          file.displaced = null;
        } else if (file.backupCreated && await file.backup.exists()) {
          if (await file.destination.exists()) {
            await file.destination.delete();
          }
          await file.backup.rename(file.destination.path);
          file.backupCreated = false;
        }
      } catch (e) {
        firstError ??= e;
      }
    }
    final error = firstError;
    if (error != null) throw error;
  }

  static Future<void> _deleteIfExists(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Cleanup must never hide the original save result. On an ambiguous
      // transaction the backup is intentionally not cleaned up by the caller.
    }
  }

  Future<void> delete(String id) async {
    final file = await _saveFile(id);
    if (await file.exists()) await file.delete();
    final metas = await listSaves();
    await _writeIndex(metas.where((m) => m.id != id).toList());
  }
}

class _CommittedSaveJson {
  const _CommittedSaveJson({required this.gameJson, required this.indexJson});

  final Map<String, dynamic> gameJson;
  final List<dynamic> indexJson;
}

class _PreparedSaveTransaction {
  _PreparedSaveTransaction({
    required this.saveId,
    required this.gameFile,
    required this.indexFile,
  });

  final String saveId;
  final _PreparedSaveFile gameFile;
  final _PreparedSaveFile indexFile;

  List<_PreparedSaveFile> get files => [gameFile, indexFile];
}

class _PreparedSaveFile {
  _PreparedSaveFile({
    required this.destination,
    required this.temporary,
    required this.backup,
    required this.stage,
  });

  final File destination;
  final File temporary;
  final File backup;
  final SaveRepositoryWriteStage stage;

  bool backupCreated = false;
  bool published = false;
  File? displaced;
}
