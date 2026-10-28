@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/data/save_repository.dart';
import '../helpers/fixtures/game_fixtures.dart';

void main() {
  final fixture = controllerSave();
  // Failure before publication is also covered by the controlled repository
  // tests. Here every public two-file operation reaches real journal checkpoints.
  for (final operation in ['create', 'overwrite', 'rename', 'duplicate']) {
    for (final checkpoint in SaveRepositoryCheckpoint.values) {
      final hasOldGame = operation == 'overwrite' || operation == 'rename';
      final hasOldIndex = operation != 'create';
      final displacedWithoutOriginal =
          checkpoint == SaveRepositoryCheckpoint.gameDisplaced && !hasOldGame ||
          checkpoint == SaveRepositoryCheckpoint.indexDisplaced && !hasOldIndex;
      if (displacedWithoutOriginal ||
          checkpoint.name.endsWith('Displaced') && !Platform.isWindows) {
        continue;
      }
      test(
        '$operation exception at ${checkpoint.name} preserves a verified pair',
        () async {
          final directory = await Directory.systemTemp.createTemp(
            'football-checkpoint-',
          );
          addTearDown(() => directory.delete(recursive: true));
          final repository = SaveRepository(overrideDirectory: directory);
          if (hasOldIndex) await repository.save(fixture);
          final targetId = operation == 'duplicate' ? 'copy' : fixture.meta.id;
          final target = File('${directory.path}/$targetId.json');
          final index = File('${directory.path}/saves_index.json');
          final oldGame = await target.exists()
              ? await target.readAsString()
              : null;
          final oldIndex = await index.exists()
              ? await index.readAsString()
              : null;
          final source = File('${directory.path}/${fixture.meta.id}.json');
          final sourceBefore = operation == 'duplicate'
              ? await source.readAsString()
              : null;
          var reached = false;
          final failing = SaveRepository(
            overrideDirectory: directory,
            onCheckpoint: (point) async {
              if (point == checkpoint) {
                reached = true;
                throw const FileSystemException('controlled failure');
              }
            },
          );
          Future<Object?> write() => switch (operation) {
            'rename' => failing.renameRaw(id: targetId, newName: 'new'),
            'duplicate' => failing.duplicateRaw(
              sourceId: fixture.meta.id,
              duplicateMeta: fixture.meta.copyWith(id: targetId, name: 'new'),
            ),
            _ => failing.save(
              fixture.copyWith(meta: fixture.meta.copyWith(name: 'new')),
            ),
          };
          await expectLater(write(), throwsA(isA<SaveRepositoryException>()));
          expect(
            reached,
            isTrue,
            reason: 'The selected checkpoint must be exercised.',
          );
          final listed = await repository.listSaves();
          if (checkpoint == SaveRepositoryCheckpoint.committed) {
            final loaded = await repository.load(targetId);
            expect(loaded.meta, listed.singleWhere((m) => m.id == targetId));
            expect(loaded.meta.name, 'new');
            expect(
              loaded.leagueState == fixture.leagueState,
              isTrue,
              reason: 'The complete committed payload must survive recovery.',
            );
            expect(loaded.schemaVersion, SaveSchema.currentVersion);
            final raw = jsonDecode(await target.readAsString()) as Map;
            final entries = jsonDecode(await index.readAsString()) as List;
            expect(entries.where((m) => m['id'] == targetId), [raw['meta']]);
          } else {
            expect(await target.exists(), oldGame != null);
            if (oldGame != null) expect(await target.readAsString(), oldGame);
            expect(await index.exists(), oldIndex != null);
            if (oldIndex != null) expect(await index.readAsString(), oldIndex);
          }
          if (sourceBefore != null) {
            expect(await source.readAsString(), sourceBefore);
          }
          expect(
            directory.listSync().where(
              (e) =>
                  e.path.contains('.tmp-') ||
                  e.path.contains('.bak-') ||
                  e.path.contains('.old-') ||
                  e.path.contains('.restore-') ||
                  e.path.contains('.save-transaction-v1.json'),
            ),
            isEmpty,
          );
          // Recovery must release the directory for a subsequent successful write.
          await repository.save(fixture);
          expect(
            (await repository.load(fixture.meta.id)).meta.id,
            fixture.meta.id,
          );
        },
      );
    }
  }
}
