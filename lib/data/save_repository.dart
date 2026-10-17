import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' show IsolateNameServer, RootIsolateToken;

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/data/staff_data_compatibility.dart';

part 'save_directory_coordinator.dart';
part 'save_recovery.dart';

part 'save_repository_types.dart';

class SaveRepository {
  SaveRepository({
    Directory? overrideDirectory,
    SaveRepositoryPublishHook? beforePublish,
    SaveRepositoryCheckpointHook? onCheckpoint,
    this.verifyTypedCommit = false,
    this.saveInIsolate = true,
  }) : _overrideDirectory = overrideDirectory,
       _beforePublish = beforePublish,
       _onCheckpoint = onCheckpoint;

  final Directory? _overrideDirectory;
  final SaveRepositoryPublishHook? _beforePublish;
  final SaveRepositoryCheckpointHook? _onCheckpoint;

  /// Re-decodes the committed game file into a [GameSave] and compares it to
  /// what was written. That is a second full model graph on top of the one
  /// being saved, which is why it is off by default — on Android it was a
  /// direct contributor to the process running out of memory. Callers that
  /// specifically test the write transaction can turn it back on.
  final bool verifyTypedCommit;

  /// Runs save, load, rename and duplicate work in a background isolate so
  /// JSON processing does not block the UI. Test hooks keep work in the calling
  /// isolate so callbacks observe the test's own state.
  final bool saveInIsolate;

  static int _transactionSequence = 0;

  /// Establishes the root-isolate coordinator before background clients start.
  static void initializeCoordinator() => _SaveDirectoryCoordinator._port();

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
  Future<SaveFileInfo> inspectFile(String id) =>
      _withAccess(() => _inspectFile(id));

  Future<SaveFileInfo> _inspectFile(String id) async {
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
  Future<bool> isSaveIdAvailable(String id) =>
      _withAccess(() => _isSaveIdAvailable(id));

  Future<bool> _isSaveIdAvailable(String id) async {
    final indexed = (await _listSaves()).any((meta) => meta.id == id);
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
    return _withAccess(() => _readRawSaveJson(sourceId));
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
  }) => _withAccess(
    () => _duplicateLocked(sourceId: sourceId, duplicateMeta: duplicateMeta),
  );

  bool get _runWorkInIsolate =>
      saveInIsolate && _beforePublish == null && _onCheckpoint == null;

  Future<GameSaveMeta> _duplicateLocked({
    required String sourceId,
    required GameSaveMeta duplicateMeta,
  }) async {
    if (!_runWorkInIsolate) {
      return _duplicateRaw(sourceId: sourceId, duplicateMeta: duplicateMeta);
    }
    final path = (await _savesDir()).path;
    return Isolate.run(
      () => SaveRepository(
        overrideDirectory: Directory(path),
        saveInIsolate: false,
      )._duplicateRaw(sourceId: sourceId, duplicateMeta: duplicateMeta),
    );
  }

  Future<GameSaveMeta> _duplicateRaw({
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

    final currentMetas = await _listSaves();
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

    final transaction = await _prepareTwoFileTransaction(
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
      await _writeJsonTemporary(gameTemporary, duplicateJson);
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
      await _recoverAfterFailure(transaction);
      if (e is SaveRepositoryException) rethrow;
      throw SaveRepositoryException(
        'Failed to duplicate save ${duplicateMeta.id}',
        cause: e,
      );
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
  }) => _withAccess(() => _renameLocked(id: id, newName: newName));

  Future<GameSaveMeta> _renameLocked({
    required String id,
    required String newName,
  }) async {
    if (!_runWorkInIsolate) return _renameRaw(id: id, newName: newName);
    final path = (await _savesDir()).path;
    return Isolate.run(
      () => SaveRepository(
        overrideDirectory: Directory(path),
        saveInIsolate: false,
      )._renameRaw(id: id, newName: newName),
    );
  }

  Future<GameSaveMeta> _renameRaw({
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

    final currentMetas = await _listSaves();
    final indexedMetas = currentMetas.where((meta) => meta.id == id).toList();
    if (indexedMetas.isEmpty) {
      throw SaveRepositoryException('Save index does not contain save $id');
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

    final transaction = await _prepareTwoFileTransaction(
      saveId: id,
      gameFile: await _saveFile(id),
      indexFile: await _indexFile(),
    );
    final gameTemporary = transaction.gameFile.temporary;
    final indexTemporary = transaction.indexFile.temporary;

    try {
      final indexJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(renamedIndex.map((meta) => meta.toJson()).toList());

      await _writeJsonTemporary(gameTemporary, renamedJson);
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
      await _recoverAfterFailure(transaction);
      if (e is SaveRepositoryException) rethrow;
      throw SaveRepositoryException('Failed to rename save $id', cause: e);
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

  Future<List<GameSaveMeta>> listSaves() => _withAccess(_listSaves);

  Future<List<GameSaveMeta>> _listSaves() async {
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

  Future<GameSave> load(String id) => _withAccess(() => _loadLocked(id));

  Future<GameSave> _loadLocked(String id) async {
    _lastStaffDiagnostics = const [];
    final path = (await _savesDir()).path;
    final result = _runWorkInIsolate
        ? await Isolate.run(
            () => SaveRepository(
              overrideDirectory: Directory(path),
              saveInIsolate: false,
            )._loadInPlace(id),
          )
        : await _loadInPlace(id);
    _lastStaffDiagnostics = result.diagnostics;
    if (result.error != null) throw result.error!;
    return result.save!;
  }

  Future<
    ({
      GameSave? save,
      List<StaffDataDiagnostic> diagnostics,
      SaveRepositoryException? error,
    })
  >
  _loadInPlace(String id) async {
    var diagnostics = const <StaffDataDiagnostic>[];
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
      // remains untouched; valid non-staff JSON subtrees are shared read-only.
      final staffResult = StaffDataCompatibility.sanitizeGameSaveJson(json);
      diagnostics = staffResult.diagnostics;
      return (
        save: GameSave.fromJson(staffResult.sanitizedJson),
        diagnostics: diagnostics,
        error: null,
      );
    } catch (e) {
      return (
        save: null,
        diagnostics: diagnostics,
        error: e is SaveRepositoryException
            ? e
            : SaveRepositoryException('Failed to load save $id', cause: e),
      );
    }
  }

  Future<void> save(GameSave gameSave) =>
      _withAccess(() => _saveLocked(gameSave));

  Future<void> _saveLocked(GameSave gameSave) async {
    // The directory has to be resolved here: `getApplicationDocumentsDirectory`
    // is a platform channel call and does not work in a plain isolate.
    final directory = await _savesDir();
    if (!_runWorkInIsolate) {
      return _saveInPlace(gameSave);
    }
    final path = directory.path;
    final verifyTyped = verifyTypedCommit;
    await Isolate.run(
      () => SaveRepository(
        overrideDirectory: Directory(path),
        verifyTypedCommit: verifyTyped,
        saveInIsolate: false,
      )._saveInPlace(gameSave),
    );
  }

  Future<void> _saveInPlace(GameSave gameSave) async {
    final stamped = gameSave.copyWith(
      schemaVersion: currentSchemaVersion,
      meta: gameSave.meta.copyWith(
        schemaVersion: currentSchemaVersion,
        updatedAt: DateTime.now(),
      ),
    );
    final transaction = await _prepareTwoFileTransaction(
      saveId: stamped.meta.id,
      gameFile: await _saveFile(stamped.meta.id),
      indexFile: await _indexFile(),
    );
    final gameTemporary = transaction.gameFile.temporary;
    final indexTemporary = transaction.indexFile.temporary;

    try {
      final metas = await _listSaves();
      final filtered = metas.where((m) => m.id != stamped.meta.id).toList();
      final indexJson = const JsonEncoder.withIndent(
        '  ',
      ).convert([...filtered, stamped.meta].map((m) => m.toJson()).toList());

      // The game file is streamed compact: nobody edits it by hand, and
      // holding the whole document as a Dart string first cost twice its
      // size in memory (strings are UTF-16) on top of the JSON map graph.
      final gameBytes = await _writeJsonTemporary(
        gameTemporary,
        stamped.toJson(),
      );
      await _writeTemporary(indexTemporary, indexJson);
      await _commitPreparedFiles(
        transaction,
        verify: () => _verifyCommittedSave(
          transaction,
          stamped,
          expectedGameBytes: gameBytes,
        ),
      );
    } catch (e) {
      await _recoverAfterFailure(transaction);
      if (e is SaveRepositoryException) rethrow;
      throw SaveRepositoryException(
        'Failed to write save ${stamped.meta.id}',
        cause: e,
      );
    }
  }

  Future<T> _withAccess<T>(Future<T> Function() operation) async {
    final directory = await _savesDir();
    return _SaveDirectoryCoordinator.run(directory, () async {
      await _SaveRecovery.recover(directory);
      return operation();
    });
  }

  Future<void> _recoverAfterFailure(_PreparedSaveTransaction transaction) =>
      _SaveRecovery.recover(transaction.journal.parent);

  Future<_PreparedSaveTransaction> _prepareTwoFileTransaction({
    required String saveId,
    required File gameFile,
    required File indexFile,
  }) async {
    _SaveRecovery.validateId(saveId);
    final id =
        '$pid-${DateTime.now().microsecondsSinceEpoch}-${_transactionSequence++}';
    final transaction = _PreparedSaveTransaction(
      id: id,
      saveId: saveId,
      gameFile: _PreparedSaveFile(
        destination: gameFile,
        transactionId: id,
        stage: SaveRepositoryWriteStage.gameFile,
      ),
      indexFile: _PreparedSaveFile(
        destination: indexFile,
        transactionId: id,
        stage: SaveRepositoryWriteStage.indexFile,
      ),
    );
    await _SaveRecovery.begin(transaction);
    return transaction;
  }

  Future<void> _writeTemporary(File file, String contents) async {
    await file.writeAsString(contents, flush: true);
  }

  /// Streams [json] to [file] as compact UTF-8 and returns the byte count.
  ///
  /// [JsonUtf8Encoder] emits fixed-size chunks, so the encoded document never
  /// exists as a single allocation. IOSink may still queue multiple chunks;
  /// this is not a guarantee of constant memory for the entire save pipeline.
  Future<int> _writeJsonTemporary(File file, Object? json) async {
    const chunkBytes = 64 * 1024;
    final sink = file.openWrite();
    var written = 0;
    try {
      await JsonUtf8Encoder(
        null,
        null,
        chunkBytes,
      ).bind(Stream.value(json)).forEach((chunk) {
        written += chunk.length;
        sink.add(chunk);
      });
      await sink.flush();
    } finally {
      await sink.close();
    }
    return written;
  }

  Future<void> _commitPreparedFiles(
    _PreparedSaveTransaction transaction, {
    required Future<void> Function() verify,
  }) async {
    // Both originals must be secured before either canonical file is changed.
    for (final file in transaction.files) {
      if (file.original != null) {
        await file.destination.copy(file.backup.path);
        if (!await file.original!.matches(file.backup)) {
          throw SaveRepositoryException('Backup does not match the original');
        }
      }
    }
    await _onCheckpoint?.call(SaveRepositoryCheckpoint.prepared);
    for (final file in transaction.files) {
      await _beforePublish?.call(file.stage);
      await _publish(file);
      await _onCheckpoint?.call(
        file.stage == SaveRepositoryWriteStage.gameFile
            ? SaveRepositoryCheckpoint.gamePublished
            : SaveRepositoryCheckpoint.indexPublished,
      );
    }
    await verify();
    await _SaveRecovery.commit(transaction);
    await _onCheckpoint?.call(SaveRepositoryCheckpoint.committed);
    await _SaveRecovery.cleanup(transaction);
  }

  Future<void> _publish(_PreparedSaveFile file) async {
    if (!Platform.isWindows || !await file.destination.exists()) {
      try {
        await file.temporary.rename(file.destination.path);
        return;
      } on FileSystemException {
        if (file.original == null || !await file.destination.exists()) rethrow;
      }
    }
    await file.destination.rename(file.displaced.path);
    await _onCheckpoint?.call(
      file.stage == SaveRepositoryWriteStage.gameFile
          ? SaveRepositoryCheckpoint.gameDisplaced
          : SaveRepositoryCheckpoint.indexDisplaced,
    );
    await file.temporary.rename(file.destination.path);
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

  /// Confirms the published pair without re-reading the game document.
  ///
  /// The game file is checked by size against what the encoder reported, so a
  /// truncated or partially published write is still caught. The index is
  /// small enough to parse and compare exactly. Set [verifyTypedCommit] to
  /// additionally decode the game file back into a [GameSave] and compare it
  /// field by field.
  Future<void> _verifyCommittedSave(
    _PreparedSaveTransaction transaction,
    GameSave stamped, {
    required int expectedGameBytes,
  }) async {
    final gameFile = transaction.gameFile.destination;
    final actualBytes = await gameFile.length();
    if (actualBytes != expectedGameBytes) {
      throw SaveRepositoryException(
        'Game save ${stamped.meta.id} was published with $actualBytes bytes '
        'instead of $expectedGameBytes',
      );
    }

    final indexJson =
        jsonDecode(await transaction.indexFile.destination.readAsString())
            as List<dynamic>;
    final matchingMeta = indexJson
        .whereType<Map<String, dynamic>>()
        .where((meta) => meta['id'] == stamped.meta.id)
        .map(GameSaveMeta.fromJson)
        .toList();
    if (matchingMeta.length != 1 || matchingMeta.single != stamped.meta) {
      throw SaveRepositoryException(
        'Save index does not match save ${stamped.meta.id}',
      );
    }

    if (!verifyTypedCommit) return;
    final gameJson =
        jsonDecode(await gameFile.readAsString()) as Map<String, dynamic>;
    if (GameSave.fromJson(gameJson) != stamped) {
      throw SaveRepositoryException(
        'Game save ${stamped.meta.id} does not match the committed snapshot',
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

  Future<void> delete(String id) => _withAccess(() => _delete(id));

  Future<void> _delete(String id) async {
    final file = await _saveFile(id);
    if (await file.exists()) await file.delete();
    final metas = await _listSaves();
    await _writeIndex(metas.where((m) => m.id != id).toList());
  }
}

