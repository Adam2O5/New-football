import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/data/save_repository.dart';
import 'game_fixtures.dart';

void main() {
  test(
    'controlled save interruption worker',
    () async {
      final directory = Directory(Platform.environment['FOOTBALL_CRASH_DIR']!);
      final phase = SaveRepositoryCheckpoint.values.byName(
        Platform.environment['FOOTBALL_CRASH_PHASE'] ?? 'gamePublished',
      );
      final repository = SaveRepository(
        overrideDirectory: directory,
        onCheckpoint: (checkpoint) async {
          if (checkpoint != phase) return;
          final ready = File('${directory.path}/worker-ready.json.pending');
          await ready.writeAsString(jsonEncode({'pid': pid}), flush: true);
          await ready.rename('${directory.path}/worker-ready.json');
          await Completer<void>().future;
        },
      );
      final old = Platform.environment['FOOTBALL_CRASH_INITIAL'] == 'true'
          ? controllerSave()
          : await repository.load('stage-zero');
      try {
        switch (Platform.environment['FOOTBALL_CRASH_OPERATION'] ?? 'save') {
          case 'rename':
            await repository.renameRaw(
              id: old.meta.id,
              newName: 'new snapshot',
            );
          case 'duplicate':
            await repository.duplicateRaw(
              sourceId: old.meta.id,
              duplicateMeta: old.meta.copyWith(
                id: 'copied',
                name: 'new snapshot',
              ),
            );
          default:
            await repository.save(
              old.copyWith(
                meta: old.meta.copyWith(name: 'new snapshot'),
                leagueState: old.leagueState.copyWith(currentDay: 2),
              ),
            );
        }
      } finally {
        await File('${directory.path}/worker-finally').writeAsString('ran');
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
