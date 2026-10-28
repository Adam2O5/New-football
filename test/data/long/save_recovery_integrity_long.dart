@Tags(['long', 'slow', 'integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/data/save_repository.dart';

import '../../nowe_testy/support/game_fixtures.dart';
import '../../nowe_testy/support/save_process_control.dart';

Future<Map<String, List<int>>> _snapshot(Directory directory) async => {
  for (final file in (await directory.list().toList()).whereType<File>())
    file.uri.pathSegments.last: await file.readAsBytes(),
};

void main() {
  test(
    'missing verified index original preserves every recovery artifact',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'football-missing-original-',
      );
      try {
        final repository = SaveRepository(overrideDirectory: directory);
        await repository.save(controllerSave());
        await killInterruptedWriter(directory);
        for (final file
            in (await directory.list().toList()).whereType<File>()) {
          final name = file.uri.pathSegments.last;
          if (name == 'saves_index.json' ||
              name.startsWith('saves_index.json.bak-') ||
              name.startsWith('saves_index.json.old-')) {
            await file.writeAsString('broken');
          }
        }
        final before = await _snapshot(directory);
        await expectLater(
          repository.load('stage-zero'),
          throwsA(isA<SaveAmbiguousWriteException>()),
        );
        expect(await _snapshot(directory), before);
        await expectLater(
          repository.listSaves(),
          throwsA(isA<SaveAmbiguousWriteException>()),
        );
        expect(await _snapshot(directory), before);
      } finally {
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
  test(
    'same-size corruption after commit is rejected and artifacts survive',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'football-checksum-',
      );
      try {
        final repository = SaveRepository(overrideDirectory: directory);
        await repository.save(controllerSave());
        await killInterruptedWriter(directory, checkpoint: 'committed');
        final file = File('${directory.path}/stage-zero.json');
        final original = await file.readAsString();
        final corrupted = original.replaceFirst(
          '"currentDay":2',
          '"currentDay":3',
        );
        expect(corrupted, isNot(original));
        expect(utf8.encode(corrupted).length, utf8.encode(original).length);
        await file.writeAsString(corrupted);
        final before = await _snapshot(directory);
        await expectLater(
          repository.listSaves(),
          throwsA(isA<SaveAmbiguousWriteException>()),
        );
        expect(await _snapshot(directory), before);
      } finally {
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
  test(
    'validated displaced original wins over a newer damaged backup',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'football-valid-copy-',
      );
      try {
        final repository = SaveRepository(overrideDirectory: directory);
        await repository.save(controllerSave());
        final old = await repository.load('stage-zero');
        await killInterruptedWriter(directory);
        final backup = (await directory.list().toList())
            .whereType<File>()
            .singleWhere((f) => f.path.contains('stage-zero.json.bak-'));
        await backup.writeAsString('broken');
        await backup.setLastModified(DateTime.utc(2099));
        expect(await repository.load('stage-zero'), old);
        expect((await repository.listSaves()).single, old.meta);
      } finally {
        await directory.delete(recursive: true);
      }
    },
    skip: !Platform.isWindows,
    timeout: const Timeout(Duration(minutes: 3)),
  );
  test(
    'recovery retries a partial restoration without consuming the backup',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'football-recovery-retry-',
      );
      try {
        final repository = SaveRepository(overrideDirectory: directory);
        await repository.save(controllerSave());
        final old = await repository.load('stage-zero');
        await killInterruptedWriter(directory);
        final journal =
            jsonDecode(
                  await File(
                    '${directory.path}/.save-transaction-v1.json',
                  ).readAsString(),
                )
                as Map;
        await File('${directory.path}/stage-zero.json').delete();
        await File(
          '${directory.path}/stage-zero.json.restore-${journal['id']}-gameFile',
        ).writeAsString('partial restoration');
        expect(await repository.load('stage-zero'), old);
        expect(
          await SaveRepository(overrideDirectory: directory).load('stage-zero'),
          old,
        );
      } finally {
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
  test(
    'a commit marker left after cleanup validates the new pair',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'football-cleanup-retry-',
      );
      try {
        final repository = SaveRepository(overrideDirectory: directory);
        await repository.save(controllerSave());
        await killInterruptedWriter(directory, checkpoint: 'committed');
        for (final file
            in (await directory.list().toList()).whereType<File>()) {
          if (RegExp(r'\.(tmp|bak|old|restore)-').hasMatch(file.path) ||
              file.path.endsWith('/.save-transaction-v1.json') ||
              file.path.endsWith('\\.save-transaction-v1.json')) {
            await file.delete();
          }
        }
        final newSave = await repository.load('stage-zero');
        expect(newSave.leagueState.currentDay, 2);
        expect(newSave.meta, (await repository.listSaves()).single);
        expect(
          await File(
            '${directory.path}/.save-transaction-v1.json.commit',
          ).exists(),
          isFalse,
        );
      } finally {
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
