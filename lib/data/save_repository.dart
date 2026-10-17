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
part 'save_repository_raw_operations.dart';
part 'save_repository_transaction.dart';

class SaveRepository
    with
        _SaveRepositoryShared,
        _SaveRepositoryRawOperations,
        _SaveRepositoryTransaction {
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
  @override
  final SaveRepositoryPublishHook? _beforePublish;
  @override
  final SaveRepositoryCheckpointHook? _onCheckpoint;

  /// Re-decodes the committed game file into a [GameSave] and compares it to
  /// what was written. That is a second full model graph on top of the one
  /// being saved, which is why it is off by default — on Android it was a
  /// direct contributor to the process running out of memory. Callers that
  /// specifically test the write transaction can turn it back on.
  @override
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

  @override
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

  @override
  Future<File> _indexFile() async {
    final dir = await _savesDir();
    return File('${dir.path}/$_indexFileName');
  }

  @override
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

  @override
  bool get _runWorkInIsolate =>
      saveInIsolate && _beforePublish == null && _onCheckpoint == null;

  Future<List<GameSaveMeta>> listSaves() => _withAccess(_listSaves);

  @override
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

  @override
  Future<T> _withAccess<T>(Future<T> Function() operation) async {
    final directory = await _savesDir();
    return _SaveDirectoryCoordinator.run(directory, () async {
      await _SaveRecovery.recover(directory);
      return operation();
    });
  }

  Future<void> delete(String id) => _withAccess(() => _delete(id));

  Future<void> _delete(String id) async {
    final file = await _saveFile(id);
    if (await file.exists()) await file.delete();
    final metas = await _listSaves();
    await _writeIndex(metas.where((m) => m.id != id).toList());
  }
}

mixin _SaveRepositoryShared {
  SaveRepositoryPublishHook? get _beforePublish;

  SaveRepositoryCheckpointHook? get _onCheckpoint;

  bool get verifyTypedCommit;

  Future<Directory> _savesDir();

  Future<File> _indexFile();

  Future<File> _saveFile(String id);

  bool get _runWorkInIsolate;

  Future<List<GameSaveMeta>> _listSaves();

  Future<T> _withAccess<T>(Future<T> Function() operation);

  Future<void> _recoverAfterFailure(_PreparedSaveTransaction transaction);

  Future<_PreparedSaveTransaction> _prepareTwoFileTransaction({
    required String saveId,
    required File gameFile,
    required File indexFile,
  });

  Future<void> _writeTemporary(File file, String contents);

  Future<int> _writeJsonTemporary(File file, Object? json);

  Future<void> _commitPreparedFiles(
    _PreparedSaveTransaction transaction, {
    required Future<void> Function() verify,
  });

  Future<_CommittedSaveJson> _verifyRawCommit(
    _PreparedSaveTransaction transaction, {
    Map<String, dynamic>? expectedGameJson,
    Map<String, dynamic>? expectedIndexMeta,
  });
}
