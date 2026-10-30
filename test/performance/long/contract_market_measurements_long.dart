@Tags(['long', 'slow', 'benchmark'])
library;

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';

import '../../helpers/fixtures/game_fixtures.dart';

void main() {
  final generated = seededLeague();
  final target = generated.teams.first.roster.first.copyWith(
    id: 'measurement-target',
    contract: const Contract(salary: 0, yearsRemaining: 0),
  );
  for (final teamCount in [1, 30]) {
    final first = generated.teams.first.copyWith(
      ai: null,
      roster: generated.teams.first.roster.take(12).toList(),
      finance: generated.teams.first.finance.copyWith(salaryCap: 1000000000),
    );
    final initial = generated.copyWith(
      teams: [
        first,
        ...generated.teams
            .skip(1)
            .take(teamCount - 1)
            .map((team) => team.copyWith(ai: null)),
      ],
      playerTeamId: first.id,
      currentWeek: 47,
      currentDay: 2,
      currentHour: 1,
      currentSeason: generated.currentSeason.copyWith(
        phase: SeasonPhase.offseason,
      ),
      freeAgents: [
        for (var i = 0; i < 199; i++) target.copyWith(id: 'measurement-fa-$i'),
        target,
      ],
    );
    test(
      'manual hourly player market with $teamCount teams',
      () {
        _metadata('manual-hourly', initial, 20);
        final samples = <String, List<int>>{};
        for (var run = 0; run <= 5; run++) {
          final market = ContractMarketService();
          final totals = <String, int>{};
          T timed<T>(String stage, T Function() operation) {
            final clock = Stopwatch()..start();
            final result = operation();
            clock.stop();
            totals.update(
              stage,
              (v) => v + clock.elapsedMicroseconds,
              ifAbsent: () => clock.elapsedMicroseconds,
            );
            return result;
          }

          for (var iteration = 0; iteration < 20; iteration++) {
            final offered = timed(
              'submit-offer',
              () => market.submitPlayerOffer(
                league: initial,
                playerId: target.id,
                offer: const ContractOffer(salary: 60000000, years: 2),
                saveSeed: fixtureSeed,
              ),
            );
            expect(offered, isNotNull);
            final record = offered!.league.negotiations.single;
            expect(record.offerScore, greaterThanOrEqualTo(70));
            // Controlled persisted waiting case, prepared outside the clock.
            final waiting = offered.league.copyWith(
              currentHour: 2,
              negotiations: [
                record.copyWith(
                  status: NegotiationStatus.waiting,
                  waitingUntilSeasonYear: initial.currentSeason.year,
                  waitingUntilWeek: 47,
                  waitingUntilDay: 2,
                  waitingUntilHour: 2,
                ),
              ],
            );
            final resolved = timed(
              'resolve-waiting-hour',
              () => market.resolveHour(waiting, saveSeed: fixtureSeed),
            );
            expect(
              resolved.negotiations.single.status,
              NegotiationStatus.pendingFinalization,
            );
            final signed = timed(
              'finalize-offer',
              () => market.finalizeNegotiation(
                resolved,
                record.id,
                saveSeed: fixtureSeed,
              ),
            );
            expect(signed, isNotNull);
            expect(
              signed!.negotiations.single.status,
              NegotiationStatus.completed,
            );
            final player = signed.playerTeam!.roster.singleWhere(
              (p) => p.id == target.id,
            );
            expect(player.contract.salary, 60000000);
            expect(player.contract.yearsRemaining, 2);
            expect(signed.freeAgents.any((p) => p.id == target.id), isFalse);
            expect(
              signed.teams.skip(1).toList(),
              initial.teams.skip(1).toList(),
            );
            expect(initial.negotiations, isEmpty);
            expect(initial.freeAgents.last, same(target));
            expect(initial.playerTeam!.roster, hasLength(12));
          }
          for (final entry in totals.entries) {
            _record(
              samples,
              run,
              entry.key,
              initial.teams.length,
              20,
              entry.value,
            );
          }
        }
        _summaries(samples, teamCount, 20);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'lookup-only snapshot cache probe with $teamCount teams',
      () {
        const iterations = 100;
        _metadata('lookup-probe', initial, iterations);
        final samples = <String, List<int>>{};
        for (final mode in ['same-snapshot', 'new-snapshot']) {
          for (var run = 0; run <= 5; run++) {
            final reads = _Reads();
            final league = initial.copyWith(
              teams: initial.teams
                  .map(
                    (team) => team.copyWith(
                      roster: _CountingList(team.roster, reads),
                    ),
                  )
                  .toList(),
              freeAgents: _CountingList(initial.freeAgents, reads),
            );
            final population =
                initial.teams.fold<int>(
                  0,
                  (n, team) => n + team.roster.length,
                ) +
                initial.freeAgents.length;
            final market = ContractMarketService();
            var unexpectedOffers = 0;
            final clock = Stopwatch()..start();
            for (var i = 0; i < iterations; i++) {
              // Missing owner stops immediately after the real player lookup.
              if (market.submitQualifyingOffer(
                    league: mode == 'same-snapshot'
                        ? league
                        : league.copyWith(),
                    ownerTeamId: 'missing-owner',
                    playerId: target.id,
                  ) !=
                  null) {
                unexpectedOffers++;
              }
            }
            clock.stop();
            final expectedBuilds = mode == 'same-snapshot' ? 1 : iterations;
            expect(unexpectedOffers, 0);
            expect(reads.value, population * expectedBuilds);
            debugPrintSynchronously(
              jsonEncode({
                'teams': teamCount,
                'mode': mode,
                'run': run,
                'population': population,
                'source_reads': reads.value,
                'index_builds': reads.value ~/ population,
              }),
            );
            _record(
              samples,
              run,
              'lookup-$mode',
              teamCount,
              iterations,
              clock.elapsedMicroseconds,
            );
          }
        }
        _summaries(samples, teamCount, iterations);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  }
}

void _metadata(String scenario, LeagueState league, int iterations) {
  debugPrintSynchronously(
    jsonEncode({
      'scenario': scenario,
      'teams': league.teams.length,
      'players': league.teams.fold<int>(0, (n, team) => n + team.roster.length),
      'free_agents': league.freeAgents.length,
      'iterations': iterations,
      'seed': fixtureSeed,
      'week': 47,
      'day': 2,
      'first_run': 0,
      'warm_samples': 5,
      'runtime': 'Flutter test / desktop / JIT',
      'platform': Platform.operatingSystem,
      'dart_version': Platform.version,
      'ai_enabled': false,
    }),
  );
}

void _record(
  Map<String, List<int>> samples,
  int run,
  String stage,
  int teams,
  int iterations,
  int elapsed,
) {
  if (run > 0) samples.putIfAbsent(stage, () => []).add(elapsed);
  debugPrintSynchronously(
    jsonEncode({
      'teams': teams,
      'stage': stage,
      'run': run,
      'iterations': iterations,
      'batch_us': elapsed,
    }),
  );
}

void _summaries(Map<String, List<int>> samples, int teams, int iterations) {
  for (final entry in samples.entries) {
    final sorted = entry.value.toList()..sort();
    expect(sorted, hasLength(5));
    debugPrintSynchronously(
      jsonEncode({
        'warm_summary': entry.key,
        'teams': teams,
        'samples': sorted.length,
        'iterations': iterations,
        'median_batch_us': sorted[2],
        'min_batch_us': sorted.first,
        'max_batch_us': sorted.last,
      }),
    );
  }
}

class _Reads {
  int value = 0;
}

class _CountingList<T> extends ListBase<T> {
  _CountingList(this.values, this.reads);
  final List<T> values;
  final _Reads reads;
  @override
  int get length => values.length;
  @override
  set length(int value) => throw UnsupportedError('read only');
  @override
  T operator [](int index) {
    reads.value++;
    return values[index];
  }

  @override
  void operator []=(int index, T value) => throw UnsupportedError('read only');
}
