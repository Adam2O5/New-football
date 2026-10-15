import 'dart:async';

import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/data/save_repository.dart';

/// Never reads or writes the application's save directory.
class MemorySaveRepository extends SaveRepository {
  MemorySaveRepository(this.game) {
    games[game.meta.id] = game;
  }

  GameSave game;
  final writes = <GameSave>[];
  Completer<void>? writeGate;
  Completer<void>? writeStarted;
  Object? writeError;
  final games = <String, GameSave>{};
  Future<GameSave> Function(String id)? loadOperation;
  final deletedIds = <String>[];

  @override
  Future<GameSave> load(String id) async {
    final operation = loadOperation;
    if (operation != null) return operation(id);
    return games[id] ?? (throw StateError('Missing fixture: $id'));
  }

  @override
  Future<void> save(GameSave value) async {
    final started = writeStarted;
    writeStarted = null;
    started?.complete();
    await writeGate?.future;
    final error = writeError;
    if (error != null) throw error;
    game = value;
    games[value.meta.id] = value;
    writes.add(value);
  }

  @override
  Future<void> delete(String id) async {
    deletedIds.add(id);
    games.remove(id);
  }
}
