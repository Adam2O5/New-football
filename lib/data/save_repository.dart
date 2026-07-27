import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:new_football/core/models/game_save.dart';

class SaveRepositoryException implements Exception {
  SaveRepositoryException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'SaveRepositoryException: $message${cause != null ? ' ($cause)' : ''}';
}

class SaveRepository {
  SaveRepository({Directory? overrideDirectory})
      : _overrideDirectory = overrideDirectory;

  final Directory? _overrideDirectory;

  static const currentSchemaVersion = 1;
  static const _indexFileName = 'saves_index.json';

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
      const JsonEncoder.withIndent('  ').convert(
        metas.map((m) => m.toJson()).toList(),
      ),
    );
  }

  Future<GameSave> load(String id) async {
    final file = await _saveFile(id);
    if (!await file.exists()) {
      throw SaveRepositoryException('Save not found: $id');
    }
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final save = GameSave.fromJson(json);
      if (save.schemaVersion > currentSchemaVersion) {
        throw SaveRepositoryException(
          'Save schema ${save.schemaVersion} is newer than supported '
          '$currentSchemaVersion',
        );
      }
      return save;
    } catch (e) {
      if (e is SaveRepositoryException) rethrow;
      throw SaveRepositoryException('Failed to load save $id', cause: e);
    }
  }

  Future<void> save(GameSave gameSave) async {
    final stamped = gameSave.copyWith(
      schemaVersion: currentSchemaVersion,
      meta: gameSave.meta.copyWith(updatedAt: DateTime.now()),
    );
    final file = await _saveFile(stamped.meta.id);
    try {
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(stamped.toJson()),
      );
      final metas = await listSaves();
      final filtered = metas.where((m) => m.id != stamped.meta.id).toList();
      await _writeIndex([...filtered, stamped.meta]);
    } catch (e) {
      throw SaveRepositoryException(
        'Failed to write save ${stamped.meta.id}',
        cause: e,
      );
    }
  }

  Future<void> delete(String id) async {
    final file = await _saveFile(id);
    if (await file.exists()) await file.delete();
    final metas = await listSaves();
    await _writeIndex(metas.where((m) => m.id != id).toList());
  }
}
