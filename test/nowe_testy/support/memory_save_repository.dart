import 'dart:async';

import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/data/save_repository.dart';

/// Never reads or writes the application's save directory.
class MemorySaveRepository extends SaveRepository {
  MemorySaveRepository(this.game);

  GameSave game;
  final writes = <GameSave>[];
  Completer<void>? writeGate;
  Completer<void>? writeStarted;

  @override
  Future<GameSave> load(String id) async => game;

  @override
  Future<void> save(GameSave value) async {
    final started = writeStarted;
    writeStarted = null;
    started?.complete();
    await writeGate?.future;
    game = value;
    writes.add(value);
  }
}
