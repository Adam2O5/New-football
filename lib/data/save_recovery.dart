part of 'save_repository.dart';

class _SaveFingerprint {
  const _SaveFingerprint(this.bytes, this.hash);
  final int bytes;
  final String hash;

  Map<String, Object> toJson() => {'bytes': bytes, 'sha256': hash};

  factory _SaveFingerprint.fromJson(Object? value) {
    if (value is! Map ||
        value['bytes'] is! int ||
        (value['bytes'] as int) < 0 ||
        value['sha256'] is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(value['sha256'] as String)) {
      throw const FormatException('Invalid transaction fingerprint');
    }
    return _SaveFingerprint(value['bytes'] as int, value['sha256'] as String);
  }

  static Future<_SaveFingerprint?> read(File file) async {
    if (!await file.exists()) return null;
    return _SaveFingerprint(
      await file.length(),
      (await sha256.bind(file.openRead()).first).toString(),
    );
  }

  Future<bool> matches(File file) async {
    if (!await file.exists() || await file.length() != bytes) return false;
    return (await sha256.bind(file.openRead()).first).toString() == hash;
  }
}

/// The immutable journal describes the previous pair before any write starts.
/// A separate, flushed commit marker describes the verified new pair. Recovery
/// never infers a winner from modification times or a partially published pair.
class _SaveRecovery {
  static const journalName = '.save-transaction-v1.json';

  static void validateId(String id) {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id) || id == 'saves_index') {
      throw SaveRepositoryException('Invalid save file id: $id');
    }
  }

  static Future<void> begin(_PreparedSaveTransaction transaction) async {
    for (final file in transaction.files) {
      file.original = await _SaveFingerprint.read(file.destination);
    }
    await _writeMarker(transaction.journal, {
      'version': 1,
      'id': transaction.id,
      'saveId': transaction.saveId,
      'originals': {
        for (final file in transaction.files)
          file.stage.name: file.original?.toJson(),
      },
    });
  }

  static Future<void> commit(_PreparedSaveTransaction transaction) async {
    final fingerprints = <String, Object>{};
    for (final file in transaction.files) {
      final fingerprint = await _SaveFingerprint.read(file.destination);
      if (fingerprint == null) {
        throw SaveRepositoryException('Published transaction file is missing');
      }
      fingerprints[file.stage.name] = fingerprint.toJson();
    }
    await _writeMarker(transaction.commitMarker, {
      'version': 1,
      'id': transaction.id,
      'saveId': transaction.saveId,
      'files': fingerprints,
    });
  }

  static Future<void> _writeMarker(File destination, Object json) async {
    final temporary = File('${destination.path}.pending');
    await temporary.writeAsString(jsonEncode(json), flush: true);
    await temporary.rename(destination.path);
  }

  static _PreparedSaveTransaction _readTransaction(
    Directory directory,
    Map<String, dynamic> marker,
  ) {
    final id = marker['id'];
    final saveId = marker['saveId'];
    if (marker['version'] != 1 ||
        id is! String ||
        !RegExp(r'^\d+-\d+-\d+$').hasMatch(id) ||
        saveId is! String) {
      throw const FormatException('Invalid save transaction journal');
    }
    validateId(saveId);
    return _PreparedSaveTransaction(
      id: id,
      saveId: saveId,
      gameFile: _PreparedSaveFile(
        destination: File('${directory.path}/$saveId.json'),
        transactionId: id,
        stage: SaveRepositoryWriteStage.gameFile,
      ),
      indexFile: _PreparedSaveFile(
        destination: File('${directory.path}/saves_index.json'),
        transactionId: id,
        stage: SaveRepositoryWriteStage.indexFile,
      ),
    );
  }

  static Future<Map<String, dynamic>> _readMarker(File file) async {
    final json = jsonDecode(await file.readAsString());
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid transaction marker');
    }
    return json;
  }

  static Future<void> recover(Directory directory) async {
    final journal = File('${directory.path}/$journalName');
    final committed = File('${journal.path}.commit');
    var saveId = 'unknown';
    try {
      if (!await journal.exists()) {
        // A crash after deleting the journal may leave only the commit marker.
        if (await committed.exists()) {
          final marker = await _readMarker(committed);
          final transaction = _readTransaction(directory, marker);
          saveId = transaction.saveId;
          await _verifyNewPair(transaction, marker);
          await _remove(committed);
        }
        // Before journal publication no payload or index can be changed.
        await _remove(File('${journal.path}.pending'));
        await _remove(File('${committed.path}.pending'));
        return;
      }
      final marker = await _readMarker(journal);
      final transaction = _readTransaction(directory, marker);
      saveId = transaction.saveId;
      if (await committed.exists()) {
        final commit = await _readMarker(committed);
        if (commit['id'] != transaction.id ||
            commit['saveId'] != saveId ||
            commit['version'] != 1) {
          throw const FormatException(
            'Commit marker belongs to another transaction',
          );
        }
        await _verifyNewPair(transaction, commit);
      } else {
        await _restoreOldPair(transaction, marker);
      }
      await cleanup(transaction);
    } catch (error) {
      if (error is SaveAmbiguousWriteException) rethrow;
      throw SaveAmbiguousWriteException(saveId: saveId, cause: error);
    }
  }

  static Future<void> _verifyNewPair(
    _PreparedSaveTransaction transaction,
    Map<String, dynamic> marker,
  ) async {
    final files = marker['files'];
    if (files is! Map || files.length != 2) {
      throw const FormatException('Incomplete committed transaction');
    }
    for (final file in transaction.files) {
      final expected = _SaveFingerprint.fromJson(files[file.stage.name]);
      if (!await expected.matches(file.destination)) {
        throw SaveRepositoryException(
          'Committed ${file.stage.name} is not intact',
        );
      }
    }
  }

  static Future<void> _restoreOldPair(
    _PreparedSaveTransaction transaction,
    Map<String, dynamic> marker,
  ) async {
    final originals = marker['originals'];
    if (originals is! Map ||
        originals.length != 2 ||
        !originals.containsKey('gameFile') ||
        !originals.containsKey('indexFile')) {
      throw const FormatException('Incomplete original transaction manifest');
    }
    final sources = <_PreparedSaveFile, File?>{};
    // Validate both originals before mutating either canonical file.
    for (final file in transaction.files) {
      final raw = originals[file.stage.name];
      if (raw == null) {
        sources[file] = null;
        continue;
      }
      file.original = _SaveFingerprint.fromJson(raw);
      for (final candidate in [file.destination, file.backup, file.displaced]) {
        if (await file.original!.matches(candidate)) {
          sources[file] = candidate;
          break;
        }
      }
      if (!sources.containsKey(file)) {
        throw SaveRepositoryException(
          'No verified original ${file.stage.name}',
        );
      }
    }
    for (final file in transaction.files.reversed) {
      final source = sources[file];
      if (source == null) {
        await _remove(file.destination);
      } else if (source.path != file.destination.path) {
        // Keep the validated backup until the entire recovery is complete.
        await source.copy(file.restoring.path);
        await _remove(file.destination);
        await file.restoring.rename(file.destination.path);
      }
    }
    for (final file in transaction.files) {
      final original = file.original;
      if (original == null
          ? await file.destination.exists()
          : !await original.matches(file.destination)) {
        throw SaveRepositoryException('Original pair was not restored');
      }
    }
  }

  static Future<void> cleanup(_PreparedSaveTransaction transaction) async {
    for (final file in transaction.files) {
      for (final artifact in [
        file.temporary,
        file.backup,
        file.displaced,
        file.restoring,
      ]) {
        await _remove(artifact);
      }
    }
    await _remove(File('${transaction.journal.path}.pending'));
    await _remove(File('${transaction.commitMarker.path}.pending'));
    await _remove(transaction.journal);
    await _remove(transaction.commitMarker);
  }

  static Future<void> _remove(File file) async {
    if (await file.exists()) await file.delete();
  }
}
