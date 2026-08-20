import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:new_football/core/models/game_save.dart';
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
    final gameFile = await _saveFile(stamped.meta.id);
    final indexFile = await _indexFile();
    final transactionId =
        '${DateTime.now().microsecondsSinceEpoch}-'
        '${_transactionSequence++}';
    final gameTemporary = File('${gameFile.path}.tmp-$transactionId-game');
    final indexTemporary = File('${indexFile.path}.tmp-$transactionId-index');
    final files = [
      _PreparedSaveFile(
        destination: gameFile,
        temporary: gameTemporary,
        backup: File('${gameFile.path}.bak-$transactionId-game'),
        stage: SaveRepositoryWriteStage.gameFile,
      ),
      _PreparedSaveFile(
        destination: indexFile,
        temporary: indexTemporary,
        backup: File('${indexFile.path}.bak-$transactionId-index'),
        stage: SaveRepositoryWriteStage.indexFile,
      ),
    ];

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
      await _commitPreparedFiles(files, stamped);
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

  Future<void> _writeTemporary(File file, String contents) async {
    await file.writeAsString(contents, flush: true);
  }

  Future<void> _commitPreparedFiles(
    List<_PreparedSaveFile> files,
    GameSave stamped,
  ) async {
    var committed = false;
    var rolledBack = false;

    try {
      for (final file in files) {
        if (await file.destination.exists()) {
          await file.destination.copy(file.backup.path);
          file.backupCreated = true;
        }

        await _beforePublish?.call(file.stage);
        await _publish(file);
      }

      await _verifyCommit(files, stamped);
      committed = true;
    } catch (e) {
      try {
        await _rollback(files);
        rolledBack = true;
      } catch (rollbackError) {
        throw SaveAmbiguousWriteException(
          saveId: stamped.meta.id,
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

  Future<void> _verifyCommit(
    List<_PreparedSaveFile> files,
    GameSave stamped,
  ) async {
    final gameFile = files.firstWhere(
      (file) => file.stage == SaveRepositoryWriteStage.gameFile,
    );
    final indexFile = files.firstWhere(
      (file) => file.stage == SaveRepositoryWriteStage.indexFile,
    );

    final gameJson =
        jsonDecode(await gameFile.destination.readAsString())
            as Map<String, dynamic>;
    final persistedGame = GameSave.fromJson(gameJson);
    if (persistedGame != stamped) {
      throw SaveRepositoryException(
        'Game save ${stamped.meta.id} does not match the committed snapshot',
      );
    }

    final indexJson =
        jsonDecode(await indexFile.destination.readAsString()) as List<dynamic>;
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
