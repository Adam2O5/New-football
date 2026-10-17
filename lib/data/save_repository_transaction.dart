part of 'save_repository.dart';

mixin _SaveRepositoryTransaction on _SaveRepositoryShared {
  @override
  Future<void> _recoverAfterFailure(_PreparedSaveTransaction transaction) =>
      _SaveRecovery.recover(transaction.journal.parent);

  @override
  Future<_PreparedSaveTransaction> _prepareTwoFileTransaction({
    required String saveId,
    required File gameFile,
    required File indexFile,
  }) async {
    _SaveRecovery.validateId(saveId);
    final id =
        '$pid-${DateTime.now().microsecondsSinceEpoch}-${SaveRepository._transactionSequence++}';
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

  @override
  Future<void> _writeTemporary(File file, String contents) async {
    await file.writeAsString(contents, flush: true);
  }

  /// Streams [json] to [file] as compact UTF-8 and returns the byte count.
  ///
  /// [JsonUtf8Encoder] emits fixed-size chunks, so the encoded document never
  /// exists as a single allocation. IOSink may still queue multiple chunks;
  /// this is not a guarantee of constant memory for the entire save pipeline.
  @override
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

  @override
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
  @override
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
}
