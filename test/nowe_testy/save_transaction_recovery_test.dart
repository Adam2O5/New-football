@Tags(['integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/fixtures/game_fixtures.dart';

void main() {
  test('ordinary I/O exception rolls back both files', () async {
    final directory = await Directory.systemTemp.createTemp(
      'football-rollback-',
    );
    try {
      final repository = SaveRepository(overrideDirectory: directory);
      await repository.save(controllerSave());
      final old = await repository.load('stage-zero');
      final failing = SaveRepository(
        overrideDirectory: directory,
        beforePublish: (stage) async {
          if (stage == SaveRepositoryWriteStage.indexFile) {
            throw const FileSystemException('controlled publication failure');
          }
        },
      );
      await expectLater(
        failing.save(old.copyWith(meta: old.meta.copyWith(name: 'new'))),
        throwsA(isA<SaveRepositoryException>()),
      );
      expect(await repository.load('stage-zero'), old);
      expect((await repository.listSaves()).single, old.meta);
    } finally {
      await directory.delete(recursive: true);
    }
  });
  for (final checkpoint in SaveRepositoryCheckpoint.values) {
    test(
      'exception at ${checkpoint.name} leaves a verified pair',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'football-checkpoint-',
        );
        try {
          final repository = SaveRepository(overrideDirectory: directory);
          await repository.save(controllerSave());
          final old = await repository.load('stage-zero');
          final failing = SaveRepository(
            overrideDirectory: directory,
            onCheckpoint: (point) async {
              if (point == checkpoint) {
                throw const FileSystemException('controlled failure');
              }
            },
          );
          await expectLater(
            failing.save(old.copyWith(meta: old.meta.copyWith(name: 'new'))),
            throwsA(isA<SaveRepositoryException>()),
          );
          final result = await repository.load('stage-zero');
          expect(result.meta, (await repository.listSaves()).single);
          expect(
            result.meta.name,
            checkpoint == SaveRepositoryCheckpoint.committed
                ? 'new'
                : old.meta.name,
          );
          await repository.save(result);
        } finally {
          await directory.delete(recursive: true);
        }
      },
      skip: checkpoint.name.endsWith('Displaced') && !Platform.isWindows,
    );
  }
}
