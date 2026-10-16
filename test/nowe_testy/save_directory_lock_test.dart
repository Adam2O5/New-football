import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/data/save_repository.dart';

import 'support/game_fixtures.dart';
import 'support/save_process_control.dart';

void main() {
  test('another instance cannot recover an active write', () async {
    final directory = await Directory.systemTemp.createTemp(
      'football-instance-lock-',
    );
    final ready = Completer<void>();
    final release = Completer<void>();
    try {
      final repository = SaveRepository(overrideDirectory: directory);
      await repository.save(controllerSave());
      final old = await repository.load('stage-zero');
      final writer = SaveRepository(
        overrideDirectory: directory,
        onCheckpoint: (point) async {
          if (point == SaveRepositoryCheckpoint.gamePublished) {
            ready.complete();
            await release.future;
          }
        },
      );
      final writing = writer.save(
        old.copyWith(meta: old.meta.copyWith(name: 'new')),
      );
      await ready.future;
      var completed = false;
      final reading = repository.load('stage-zero').then((value) {
        completed = true;
        return value;
      });
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(completed, isFalse);
      expect(
        await File('${directory.path}/.save-transaction-v1.json').exists(),
        isTrue,
      );
      release.complete();
      await writing;
      expect((await reading).meta.name, 'new');
    } finally {
      if (!release.isCompleted) release.complete();
      await directory.delete(recursive: true);
    }
  });
  test('independent isolates serialize updates to the same index', () async {
    final directory = await Directory.systemTemp.createTemp(
      'football-isolate-lock-',
    );
    try {
      final repository = SaveRepository(overrideDirectory: directory);
      await repository.listSaves();
      final first = controllerSave();
      final second = saveForLeague(first.leagueState, id: 'second');
      final path = directory.path;
      await Future.wait([
        Isolate.run(
          () => SaveRepository(
            overrideDirectory: Directory(path),
            saveInIsolate: false,
          ).save(first),
        ),
        Isolate.run(
          () => SaveRepository(
            overrideDirectory: Directory(path),
            saveInIsolate: false,
          ).save(second),
        ),
      ]);
      expect((await repository.listSaves()).map((m) => m.id).toSet(), {
        'stage-zero',
        'second',
      });
    } finally {
      await directory.delete(recursive: true);
    }
  });
  test(
    'another process holds the OS lock until death, then recovery proceeds',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'football-process-lock-',
      );
      try {
        final repository = SaveRepository(overrideDirectory: directory);
        await repository.save(controllerSave());
        final old = await repository.load('stage-zero');
        var completed = false;
        late Future<Object> reading;
        await killInterruptedWriter(
          directory,
          whileBlocked: () async {
            reading = repository.load('stage-zero').then((value) {
              completed = true;
              return value;
            });
            await Future<void>.delayed(const Duration(milliseconds: 200));
            expect(completed, isFalse);
          },
        );
        expect(await reading, old);
      } finally {
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
