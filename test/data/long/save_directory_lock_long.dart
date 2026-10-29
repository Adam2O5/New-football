@Tags(['long', 'slow', 'integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/data/save_repository.dart';

import '../../helpers/fixtures/game_fixtures.dart';
import '../../helpers/processes/save_process_control.dart';

void main() {
  setUp(() {
    // ignore: avoid_print
    print(
      'manual long: save_directory_lock_long.dart seed=123 starting; external budget and logs supplied by scripts/test.ps1',
    );
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
