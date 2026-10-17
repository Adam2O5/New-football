part of 'save_repository.dart';

mixin _SaveRepositoryRawOperations on _SaveRepositoryShared {
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
}
