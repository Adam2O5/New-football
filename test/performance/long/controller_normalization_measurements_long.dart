@Tags(['long', 'slow', 'benchmark'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/contract_period_service.dart';
import 'package:new_football/core/tactics/lineup_slots.dart';

import '../../helpers/fixtures/game_fixtures.dart';
import '../../helpers/persistence/memory_save_repository.dart';

const _iterations = 100;

void main() {
  final generated = seededLeague();
  for (final teamCount in [1, 30]) {
    for (final scenario in ['inbox-mark-read', 'date-mutation']) {
      test(
        '$scenario normalization measurements with $teamCount teams',
        () async {
          final initial = reconcileLeagueLineups(
            const ContractPeriodService().normalizeLeague(
              generated.copyWith(
                teams: generated.teams.take(teamCount).toList(),
                inbox: Inbox(
                  messages: [
                    for (var i = 0; i < _iterations; i++)
                      GameMessage(
                        id: 'measurement-$i',
                        type: MessageType.contractSigned,
                        seasonYear: generated.currentSeason.year,
                        week: 1,
                        titleKey: 'measurement-title',
                        bodyKey: 'measurement-body',
                      ),
                  ],
                ),
              ),
            ),
          );
          debugPrintSynchronously(
            jsonEncode({
              'scenario': scenario,
              'teams': teamCount,
              'players': initial.teams.fold<int>(
                0,
                (n, team) => n + team.roster.length,
              ),
              'seed': fixtureSeed,
              'iterations': _iterations,
              'runtime': 'Flutter test / desktop / JIT',
              'platform': Platform.operatingSystem,
              'dart_version': Platform.version,
              'repository': 'memory; no disk or UI listeners',
              'first_run': 0,
              'warm_samples': 5,
            }),
          );
          LeagueState transform(LeagueState league, int index) =>
              scenario == 'inbox-mark-read'
              ? league.copyWith(
                  inbox: league.inbox.markRead('measurement-$index'),
                )
              : league.copyWith(currentDay: 2 + index % 5);
          final samples = <String, List<int>>{};
          for (var run = 0; run <= 5; run++) {
            debugPrintSynchronously(
              'normalization measurement: $scenario teams=$teamCount run=$run',
            );
            // Prepare cumulative inputs outside the timed component probes.
            var prepared = initial;
            final inputs = <LeagueState>[];
            for (var i = 0; i < _iterations; i++) {
              prepared = transform(prepared, i);
              inputs.add(prepared);
            }
            final expected = inputs.last;
            void record(String stage, int elapsed) {
              if (run > 0) samples.putIfAbsent(stage, () => []).add(elapsed);
              debugPrintSynchronously(
                jsonEncode({
                  'scenario': scenario,
                  'teams': teamCount,
                  'run': run,
                  'stage': stage,
                  'iterations': stage == 'memory-save-barrier'
                      ? 1
                      : _iterations,
                  'batch_us': elapsed,
                }),
              );
            }

            void probe(String stage, LeagueState Function(int) operation) {
              var last = initial;
              final clock = Stopwatch()..start();
              for (var i = 0; i < _iterations; i++) {
                last = operation(i);
              }
              clock.stop();
              record(stage, clock.elapsedMicroseconds);
              expect(
                last == expected,
                isTrue,
                reason: '$stage must preserve domain state',
              );
            }

            var transformed = initial;
            probe(
              'transform-only',
              (i) => transformed = transform(transformed, i),
            );
            probe(
              'contract-normalization-only',
              (i) => const ContractPeriodService().normalizeLeague(inputs[i]),
            );
            probe(
              'lineup-reconciliation-only',
              (i) => reconcileLeagueLineups(inputs[i]),
            );
            var pipeline = initial;
            probe(
              'transform-and-normalization',
              (i) => pipeline = reconcileLeagueLineups(
                const ContractPeriodService().normalizeLeague(
                  transform(pipeline, i),
                ),
              ),
            );

            final repository = MemorySaveRepository(saveForLeague(initial));
            final container = ProviderContainer(
              overrides: [saveRepositoryProvider.overrideWithValue(repository)],
            );
            try {
              final controller = container.read(
                gameControllerProvider.notifier,
              );
              await controller.loadGame(repository.game.meta.id);
              final clock = Stopwatch()..start();
              for (var i = 0; i < _iterations; i++) {
                if (scenario == 'inbox-mark-read') {
                  await controller.markMessageRead('measurement-$i');
                } else {
                  await controller.updateLeague(
                    (league) => transform(league, i),
                  );
                }
              }
              clock.stop();
              record('controller-publication', clock.elapsedMicroseconds);
              final flushClock = Stopwatch()..start();
              await controller.flushPendingSave();
              flushClock.stop();
              record('memory-save-barrier', flushClock.elapsedMicroseconds);
              expect(controller.save!.leagueState == expected, isTrue);
              expect(repository.game.leagueState == expected, isTrue);
              expect(repository.writes, isNotEmpty);
              expect(
                initial.inbox.messages.every((message) => !message.read),
                isTrue,
              );
              expect(initial.currentDay, 1);
              debugPrintSynchronously(
                jsonEncode({
                  'scenario': scenario,
                  'teams': teamCount,
                  'run': run,
                  'memory_writes': repository.writes.length,
                }),
              );
            } finally {
              container.dispose();
            }
          }
          for (final entry in samples.entries) {
            final sorted = entry.value.toList()..sort();
            expect(sorted, hasLength(5));
            debugPrintSynchronously(
              jsonEncode({
                'warm_summary': entry.key,
                'scenario': scenario,
                'teams': teamCount,
                'samples': sorted.length,
                'iterations': entry.key == 'memory-save-barrier'
                    ? 1
                    : _iterations,
                'median_batch_us': sorted[2],
                'min_batch_us': sorted.first,
                'max_batch_us': sorted.last,
              }),
            );
          }
        },
        timeout: const Timeout(Duration(minutes: 2)),
      );
    }
  }
}
