import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/data/staff_data_compatibility.dart';

import 'support/game_fixtures.dart';

// RSS is sampled from another isolate, including during synchronous UI work.
// It is process memory, including Flutter/test overhead, not Dart heap usage.
void _sampleMemory(SendPort parent) {
  final commands = ReceivePort();
  var peak = ProcessInfo.currentRss;
  final timer = Timer.periodic(const Duration(milliseconds: 2), (_) {
    final rss = ProcessInfo.currentRss;
    if (rss > peak) peak = rss;
  });
  parent.send(commands.sendPort);
  commands.listen((_) {
    timer.cancel();
    commands.close();
    Isolate.exit(parent, peak);
  });
}

Future<T> _measure<T>(String name, FutureOr<T> Function() operation) async {
  final samples = ReceivePort();
  final messages = StreamIterator<dynamic>(samples);
  await Isolate.spawn(_sampleMemory, samples.sendPort);
  await messages.moveNext();
  final control = messages.current as SendPort;
  final startRss = ProcessInfo.currentRss;
  final clock = Stopwatch()..start();
  var lastTick = Duration.zero;
  var maximumGap = Duration.zero;
  final heartbeat = Timer.periodic(const Duration(milliseconds: 2), (_) {
    final now = clock.elapsed;
    final gap = now - lastTick;
    if (gap > maximumGap) maximumGap = gap;
    lastTick = now;
  });
  try {
    return await operation();
  } finally {
    clock.stop();
    final finalGap = clock.elapsed - lastTick;
    if (finalGap > maximumGap) maximumGap = finalGap;
    heartbeat.cancel();
    control.send(null);
    await messages.moveNext();
    final peak = messages.current as int;
    await messages.cancel();
    samples.close();
    debugPrint(
      jsonEncode({
        'operation': name,
        'elapsed_us': clock.elapsedMicroseconds,
        'maximum_event_loop_gap_us': maximumGap.inMicroseconds,
        'start_rss_bytes': startRss,
        'sampled_peak_rss_bytes': peak,
      }),
    );
  }
}

void main() {
  test(
    'stage 6 local comparative measurements (not device profile)',
    () async {
      final game = largerSave();
      final directory = await Directory.systemTemp.createTemp('stage-six-');
      try {
        debugPrint(
          jsonEncode({
            'runtime': 'Flutter test / Windows / JIT',
            'seed': fixtureSeed,
            'schema': SaveSchema.currentVersion,
            'synthetic_history_seasons': game.leagueState.history.length,
            'rss_scope':
                'whole process, sampled every 2ms; GC/JIT affect results',
          }),
        );
        final repository = SaveRepository(overrideDirectory: directory);
        for (var run = 1; run <= 3; run++) {
          await _measure('preview-10/$run', () {
            final factory = GameFactory();
            for (var i = 0; i < 10; i++) {
              expect(factory.previewTeams(), hasLength(30));
            }
          });
          await _measure('save/$run', () => repository.save(game));
          final file = File('${directory.path}/${game.meta.id}.json');
          final compactBytes = await file.length();
          await _measure('load/$run', () => repository.load(game.meta.id));
          final phases = await _measure('isolated-load-phases/$run', () async {
            final path = file.path;
            final result = await Isolate.run(() async {
              final clock = Stopwatch()..start();
              final raw = await File(path).readAsString();
              final read = clock.elapsedMicroseconds;
              final json = jsonDecode(raw) as Map<String, dynamic>;
              final decode = clock.elapsedMicroseconds;
              final normalized = StaffDataCompatibility.sanitizeGameSaveJson(
                json,
              );
              final sanitize = clock.elapsedMicroseconds;
              final model = GameSave.fromJson(normalized.sanitizedJson);
              final build = clock.elapsedMicroseconds;
              return (
                model: model,
                diagnostics: normalized.diagnostics,
                read: read,
                decode: decode - read,
                sanitize: sanitize - decode,
                build: build - sanitize,
                finishedAt: DateTime.now().microsecondsSinceEpoch,
              );
            });
            final transfer =
                DateTime.now().microsecondsSinceEpoch - result.finishedAt;
            expect(
              result.model.leagueState.teams.length,
              game.leagueState.teams.length,
            );
            return {
              'read_us': result.read,
              'decode_us': result.decode,
              'sanitize_us': result.sanitize,
              'model_build_us': result.build,
              'return_and_scheduling_us': transfer,
            };
          });
          debugPrint(jsonEncode({'load_phases': phases}));
          final renamed = await _measure(
            'rename/$run',
            () => repository.renameRaw(
              id: game.meta.id,
              newName: 'renamed-fixture',
            ),
          );
          final renamedBytes = await file.length();
          final duplicate = renamed.copyWith(id: 'duplicate-$run');
          await _measure(
            'duplicate/$run',
            () => repository.duplicateRaw(
              sourceId: game.meta.id,
              duplicateMeta: duplicate,
            ),
          );
          debugPrint(
            jsonEncode({
              'run': run,
              'compact_bytes': compactBytes,
              'renamed_bytes': renamedBytes,
              'duplicate_bytes': await File(
                '${directory.path}/${duplicate.id}.json',
              ).length(),
            }),
          );
        }
        await _measure('save-snapshot-graph-sink-phases', () async {
          final path = '${directory.path}/stream-measurement.json';
          final report = await Isolate.run(() async {
            final rssBeforeGraph = ProcessInfo.currentRss;
            final clock = Stopwatch()..start();
            final json = game.toJson();
            final graph = clock.elapsedMicroseconds;
            final rssAfterGraph = ProcessInfo.currentRss;
            final sink = File(path).openWrite();
            var bytes = 0;
            var chunks = 0;
            try {
              await JsonUtf8Encoder(
                null,
                null,
                64 * 1024,
              ).bind(Stream.value(json)).forEach((chunk) {
                bytes += chunk.length;
                chunks++;
                sink.add(chunk);
              });
              final queued = clock.elapsedMicroseconds;
              final rssAfterQueue = ProcessInfo.currentRss;
              await sink.flush();
              return {
                'to_json_us': graph,
                'encode_and_enqueue_us': queued - graph,
                'drain_and_flush_us': clock.elapsedMicroseconds - queued,
                'encoded_bytes': bytes,
                'chunks': chunks,
                'rss_after_snapshot_bytes': rssBeforeGraph,
                'rss_after_graph_bytes': rssAfterGraph,
                'rss_after_enqueue_bytes': rssAfterQueue,
                'rss_after_flush_bytes': ProcessInfo.currentRss,
              };
            } finally {
              await sink.close();
            }
          });
          expect(await File(path).length(), report['encoded_bytes']);
          debugPrint(jsonEncode({'save_phases': report}));
        });
      } finally {
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
