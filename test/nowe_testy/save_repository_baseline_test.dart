import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/data/save_repository.dart';

import 'support/game_fixtures.dart';

void main() {
  test(
    'baseline: save/load/rename/duplicate in a temporary directory',
    () async {
      final game = largerSave();
      final samples = <Map<String, Object>>[];
      for (var run = 0; run < 3; run++) {
        final directory = await Directory.systemTemp.createTemp(
          'football-baseline-',
        );
        try {
          final repository = SaveRepository(overrideDirectory: directory);
          final beforeSave = DateTime.now();
          final stopwatch = Stopwatch()..start();
          await repository.save(game);
          final saveMicros = stopwatch.elapsedMicroseconds;
          final afterSave = DateTime.now();
          final file = File('${directory.path}/${game.meta.id}.json');
          final compactBytes = await file.length();

          stopwatch.reset();
          final loaded = await repository.load(game.meta.id);
          final loadMicros = stopwatch.elapsedMicroseconds;
          expect(loaded.meta.updatedAt.isBefore(beforeSave), isFalse);
          expect(loaded.meta.updatedAt.isAfter(afterSave), isFalse);
          expect(
            loaded ==
                game.copyWith(
                  meta: game.meta.copyWith(updatedAt: loaded.meta.updatedAt),
                ),
            isTrue,
            reason: 'Only the save timestamp may change during save/load.',
          );

          stopwatch.reset();
          final renamed = await repository.renameRaw(
            id: game.meta.id,
            newName: 'renamed-fixture',
          );
          final renameMicros = stopwatch.elapsedMicroseconds;
          final renamedBytes = await file.length();
          expect(renamed.name, 'renamed-fixture');

          final duplicateMeta = renamed.copyWith(
            id: 'duplicate-fixture',
            name: 'duplicate-fixture',
          );
          stopwatch.reset();
          await repository.duplicateRaw(
            sourceId: game.meta.id,
            duplicateMeta: duplicateMeta,
          );
          final duplicateMicros = stopwatch.elapsedMicroseconds;
          stopwatch.stop();
          final duplicateFile = File(
            '${directory.path}/${duplicateMeta.id}.json',
          );

          expect(
            await repository.load(game.meta.id) ==
                loaded.copyWith(meta: renamed),
            isTrue,
            reason: 'Rename must preserve the payload and other metadata.',
          );
          expect(
            await repository.load(duplicateMeta.id) ==
                loaded.copyWith(meta: duplicateMeta),
            isTrue,
            reason: 'Duplicate must preserve the payload.',
          );
          expect(await repository.listSaves(), hasLength(2));
          samples.add({
            'run': run + 1,
            'save_us': saveMicros,
            'load_us': loadMicros,
            'rename_us': renameMicros,
            'duplicate_us': duplicateMicros,
            'compact_bytes': compactBytes,
            'renamed_bytes': renamedBytes,
            'duplicate_bytes': await duplicateFile.length(),
          });
        } finally {
          await directory.delete(recursive: true);
        }
      }
      debugPrint(
        jsonEncode({
          'baseline': 'windows-flutter-test',
          'schema': SaveSchema.currentVersion,
          'seed': fixtureSeed,
          'teams': game.leagueState.teams.length,
          'players': game.leagueState.teams.fold<int>(
            0,
            (count, team) => count + team.roster.length,
          ),
          'fixtures': game.leagueState.currentSeason.schedule.length,
          'synthetic_history_seasons': game.leagueState.history.length,
          'samples': samples,
        }),
        wrapWidth: 100000,
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
