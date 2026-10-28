@Tags(['long', 'slow', 'integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/data/save_repository.dart';

import '../../nowe_testy/support/game_fixtures.dart';
import '../../nowe_testy/support/save_process_control.dart';

void main() {
  test(
    'restart after process death never returns a mixed game/index pair',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'football-crash-',
      );
      try {
        await SaveRepository(
          overrideDirectory: directory,
        ).save(controllerSave());
        await killInterruptedWriter(directory);
        final restarted = SaveRepository(overrideDirectory: directory);
        final records = await restarted.listSaves();
        final loaded = await restarted.load('stage-zero');
        expect(loaded.meta, records.single);
        expect(loaded.leagueState.currentDay, 1);
      } finally {
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
  for (final operation in ['save', 'rename', 'duplicate']) {
    final phases = ['prepared', 'gamePublished', 'indexPublished', 'committed'];
    if (operation == 'save' && Platform.isWindows) {
      phases.addAll(['gameDisplaced', 'indexDisplaced']);
    }
    for (final phase in phases) {
      if (operation == 'save' && phase == 'gamePublished') continue;
      test(
        'restart $operation after death at $phase',
        () async {
          final directory = await Directory.systemTemp.createTemp(
            'football-crash-',
          );
          try {
            final repository = SaveRepository(overrideDirectory: directory);
            await repository.save(controllerSave());
            final old = await repository.load('stage-zero');
            await killInterruptedWriter(
              directory,
              operation: operation,
              checkpoint: phase,
            );
            final restarted = SaveRepository(overrideDirectory: directory);
            final records = await restarted.listSaves();
            final result = await restarted.load('stage-zero');
            expect(
              result.meta,
              records.singleWhere((m) => m.id == result.meta.id),
            );
            final committed = phase == 'committed';
            if (operation == 'duplicate') {
              expect(result, old);
              expect(records.length, committed ? 2 : 1);
              expect(
                await File('${directory.path}/copied.json').exists(),
                committed,
              );
              if (committed) {
                final copy = await restarted.load('copied');
                expect(copy.meta, records.singleWhere((m) => m.id == 'copied'));
              }
            } else {
              expect(
                result.meta.name,
                committed ? 'new snapshot' : old.meta.name,
              );
              expect(
                result.leagueState.currentDay,
                committed && operation == 'save' ? 2 : 1,
              );
            }
            expect(await restarted.listSaves(), records);
            expect(
              await File(
                '${directory.path}/.save-transaction-v1.json',
              ).exists(),
              isFalse,
            );
            expect(
              (await directory.list().toList()).where(
                (f) => RegExp(r'\.(tmp|bak|old|restore)-').hasMatch(f.path),
              ),
              isEmpty,
            );
          } finally {
            await directory.delete(recursive: true);
          }
        },
        timeout: const Timeout(Duration(minutes: 3)),
      );
    }
  }
  for (final phase in ['gamePublished', 'committed']) {
    test(
      'first-ever save interrupted at $phase has a complete outcome',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'football-first-save-',
        );
        try {
          await killInterruptedWriter(
            directory,
            checkpoint: phase,
            initial: true,
          );
          final repository = SaveRepository(overrideDirectory: directory);
          final records = await repository.listSaves();
          if (phase == 'committed') {
            final saved = await repository.load('stage-zero');
            expect(saved.meta, records.single);
            expect(saved.leagueState.currentDay, 2);
          } else {
            expect(records, isEmpty);
            expect(
              await File('${directory.path}/stage-zero.json').exists(),
              isFalse,
            );
            expect(
              await File('${directory.path}/saves_index.json').exists(),
              isFalse,
            );
          }
        } finally {
          await directory.delete(recursive: true);
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  }
}
