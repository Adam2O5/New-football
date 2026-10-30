@Tags(['long', 'slow', 'benchmark'])
library;

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

import '../../helpers/fixtures/game_fixtures.dart';

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

Future<T> _measure<T>(
  String name,
  FutureOr<T> Function() operation, {
  void Function(int elapsedMicroseconds)? onElapsed,
}) async {
  debugPrint('measurement start: seed=$fixtureSeed operation=$name');
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
    onElapsed?.call(clock.elapsedMicroseconds);
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
  _registerMeasurements('initial');
  _registerMeasurements('synthetic-history');
}

void _registerMeasurements(String fixture) {
  test(
    '$fixture save pipeline measurements (not device profile)',
    () async {
      final game = fixture == 'initial'
          ? saveForLeague(seededLeague())
          : largerSave();
      final directory = await Directory.systemTemp.createTemp('save-pipeline-');
      try {
        debugPrint(
          jsonEncode({
            'runtime': 'Flutter test / desktop / JIT',
            'platform': Platform.operatingSystem,
            'dart_version': Platform.version,
            'fixture': fixture,
            'first_run': 0,
            'warm_samples': 5,
            'teams': game.leagueState.teams.length,
            'players': game.leagueState.teams.fold<int>(
              0,
              (sum, team) => sum + team.roster.length,
            ),
            'seed': fixtureSeed,
            'schema': SaveSchema.currentVersion,
            'synthetic_history_seasons': game.leagueState.history.length,
            'rss_scope':
                'whole process, sampled every 2ms; GC/JIT affect results',
          }),
        );
        final repository = SaveRepository(overrideDirectory: directory);
        final elapsedSamples = <String, List<int>>{};
        for (var run = 0; run <= 5; run++) {
          // Run zero is reported separately, not included in warm summaries.
          Future<T> measure<T>(
            String operation,
            FutureOr<T> Function() action,
          ) => _measure(
            '$fixture/$operation/$run',
            action,
            onElapsed: run == 0
                ? null
                : (elapsed) => elapsedSamples
                      .putIfAbsent(operation, () => [])
                      .add(elapsed),
          );
          await measure('preview-10', () {
            final factory = GameFactory();
            for (var i = 0; i < 10; i++) {
              expect(factory.previewTeams(), hasLength(30));
            }
          });
          await measure('save', () => repository.save(game));
          final file = File('${directory.path}/${game.meta.id}.json');
          final compactBytes = await file.length();
          final loaded = await measure(
            'load',
            () => repository.load(game.meta.id),
          );
          expect(
            loaded.leagueState == game.leagueState,
            isTrue,
            reason:
                'The complete league payload must survive each measured load.',
          );
          expect(loaded.saveSeed, game.saveSeed);
          expect(
            loaded.meta,
            game.meta.copyWith(updatedAt: loaded.meta.updatedAt),
          );
          final phases = await measure('isolated-load-phases', () async {
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
          debugPrint(
            jsonEncode({'fixture': fixture, 'run': run, 'load_phases': phases}),
          );
          final renamed = await measure(
            'rename',
            () => repository.renameRaw(
              id: game.meta.id,
              newName: 'renamed-fixture-$run',
            ),
          );
          expect(renamed.name, 'renamed-fixture-$run');
          final renamedBytes = await file.length();
          final duplicate = renamed.copyWith(id: 'duplicate-$run');
          await measure(
            'duplicate',
            () => repository.duplicateRaw(
              sourceId: game.meta.id,
              duplicateMeta: duplicate,
            ),
          );
          debugPrint(
            jsonEncode({
              'fixture': fixture,
              'run': run,
              'compact_bytes': compactBytes,
              'renamed_bytes': renamedBytes,
              'duplicate_bytes': await File(
                '${directory.path}/${duplicate.id}.json',
              ).length(),
            }),
          );
          // Keep index cardinality fixed across samples; cleanup is not timed.
          await repository.delete(duplicate.id);
        }
        for (final entry in elapsedSamples.entries) {
          final sorted = entry.value.toList()..sort();
          expect(sorted, hasLength(5));
          debugPrint(
            jsonEncode({
              'warm_summary': entry.key,
              'fixture': fixture,
              'samples': sorted.length,
              'median_us': sorted[sorted.length ~/ 2],
              'min_us': sorted.first,
              'max_us': sorted.last,
            }),
          );
        }
        await _measure('$fixture/save-snapshot-graph-sink-phases', () async {
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
          debugPrint(jsonEncode({'fixture': fixture, 'save_phases': report}));
        });
      } finally {
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
