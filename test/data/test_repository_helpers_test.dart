@Tags(['unit'])
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures/game_fixtures.dart';
import '../helpers/persistence/memory_save_repository.dart';
import '../helpers/simulation/controlled_simulation_runner.dart';
import '../helpers/widgets/widget_harness.dart';

void main() {
  test('memory repository rejects unsupported filesystem operations', () {
    final repository = MemorySaveRepository(controllerSave());
    expect(() => repository.listSaves(), throwsUnsupportedError);
    expect(() => repository.inspectFile('unused'), throwsUnsupportedError);
    expect(
      () => repository.isSaveIdAvailable('unused'),
      throwsUnsupportedError,
    );
    expect(
      () => repository.renameRaw(id: 'unused', newName: 'new'),
      throwsUnsupportedError,
    );
    expect(
      () => repository.duplicateRaw(
        sourceId: 'unused',
        duplicateMeta: repository.game.meta,
      ),
      throwsUnsupportedError,
    );
  });

  test('widget noop repository rejects reads and management', () {
    final repository = Task41NoopSaveRepository();
    expect(() => repository.load('unused'), throwsUnsupportedError);
    expect(() => repository.listSaves(), throwsUnsupportedError);
    expect(() => repository.delete('unused'), throwsUnsupportedError);
  });

  test(
    'write barrier releases after an interrupted test and is idempotent',
    () async {
      final repository = MemorySaveRepository(controllerSave());
      repository.writeGate = Completer<void>();
      final started = Completer<void>();
      repository.writeStarted = started;
      addTearDown(repository.releasePendingWrites);
      final writing = repository.save(repository.game);
      await started.future;
      expect(repository.writes, isEmpty);
      repository.releasePendingWrites();
      repository.releasePendingWrites();
      await writing;
      expect(repository.writes, hasLength(1));
    },
  );

  test('day barrier can be released safely by cleanup', () async {
    final runner = ControlledSimulationRunner();
    runner.dayGate = Completer<void>();
    addTearDown(runner.releasePendingDay);
    final game = controllerSave();
    final advancing = runner.advanceDay(
      game.leagueState,
      saveSeed: game.saveSeed,
    );
    await runner.dayStarted.future;
    runner.releasePendingDay();
    runner.releasePendingDay();
    expect((await advancing).league.currentDay, 2);
  });
}
