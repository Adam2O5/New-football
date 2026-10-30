@Tags(['long', 'slow', 'benchmark'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/services/contract_period_service.dart';
import 'package:new_football/core/services/day_pipeline.dart';
import 'package:new_football/core/services/league_strength_service.dart';
import 'package:new_football/core/services/simulation_worker.dart';
import 'package:new_football/core/tactics/lineup_slots.dart';

import '../../helpers/fixtures/game_fixtures.dart';

void main() {
  final generated = seededLeague();
  for (final teamCount in [1, 30]) {
    for (final days in [1, 5]) {
      test(
        '$days day pipeline measurements with $teamCount teams',
        () async {
          var initial = generated.copyWith(
            playerTeamId: null,
            currentWeek: 2,
            currentDay: 2,
            currentHour: null,
            teams: generated.teams
                .take(teamCount)
                .map(
                  (team) => team.copyWith(
                    ai: null,
                    roster: team.roster
                        .map(
                          (player) => player.copyWith(
                            state: player.state.copyWith(
                              stamina: 40,
                              injury: null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
            currentSeason: generated.currentSeason.copyWith(
              phase: SeasonPhase.regular,
              schedule: [],
            ),
          );
          initial = initial.copyWith(
            strengthTable: const LeagueStrengthService().calculate(
              initial,
              week: 2,
              day: 2,
              seasonYear: initial.currentSeason.year,
            ),
          );
          initial = reconcileLeagueLineups(
            const ContractPeriodService().normalizeLeague(initial),
          );
          debugPrintSynchronously(
            jsonEncode({
              'teams': teamCount,
              'days': days,
              'seed': fixtureSeed,
              'players': initial.teams.fold<int>(
                0,
                (n, team) => n + team.roster.length,
              ),
              'runtime': 'Flutter test / desktop / JIT',
              'platform': Platform.operatingSystem,
              'dart_version': Platform.version,
              'week': 2,
              'start_day': 2,
              'schedule_matches': 0,
              'ai_enabled': false,
              'resolve_contract_market': false,
              'first_run': 0,
              'warm_samples': 5,
            }),
          );
          // Untimed reference; full-state equality below also checks recovery.
          final referenceRunner = InlineSimulationRunner();
          var expected = initial;
          try {
            for (var i = 0; i < days; i++) {
              expected = (await referenceRunner.advanceDay(
                expected,
                saveSeed: fixtureSeed,
                resolveContractMarket: false,
              )).league;
            }
          } finally {
            referenceRunner.dispose();
          }
          for (final mode in [
            'inline',
            'worker-cached',
            if (days > 1) 'worker-full',
          ]) {
            final SimulationRunner runner = mode == 'inline'
                ? InlineSimulationRunner()
                : IsolateSimulationRunner();
            final samples = <int>[];
            try {
              for (var run = 0; run <= 5; run++) {
                debugPrintSynchronously(
                  'simulation measurement: teams=$teamCount days=$days mode=$mode run=$run',
                );
                var league = initial;
                final outputs = <DayStepOutput>[];
                final clock = Stopwatch()..start();
                for (var i = 0; i < days; i++) {
                  final step = await runner.advanceDay(
                    mode == 'worker-full' ? league.copyWith() : league,
                    saveSeed: fixtureSeed,
                    resolveContractMarket: false,
                  );
                  outputs.add(step);
                  league = step.league;
                }
                clock.stop();
                if (run > 0) samples.add(clock.elapsedMicroseconds);
                debugPrintSynchronously(
                  jsonEncode({
                    'teams': teamCount,
                    'days': days,
                    'mode': mode,
                    'run': run,
                    'elapsed_us': clock.elapsedMicroseconds,
                  }),
                );
                expect(
                  league == expected,
                  isTrue,
                  reason: '$mode must match full inline domain state',
                );
                expect(league.currentWeek, 2);
                expect(league.currentDay, 2 + days);
                expect(league.currentSeason.schedule, isEmpty);
                expect(league.inbox.messages, isEmpty);
                expect(
                  league.teams.first.roster.first.state.stamina,
                  greaterThan(40),
                );
                expect(initial.teams.first.roster.first.state.stamina, 40);
                expect(initial.currentDay, 2);
                for (var i = 0; i < outputs.length; i++) {
                  final step = outputs[i];
                  expect(step.result, isNotNull);
                  expect(step.result!.eventId, isNull);
                  expect(step.result!.playerMatch, isNull);
                  expect(step.result!.simulatedResults, isEmpty);
                  expect(step.result!.pauseForUrgent, isFalse);
                  expect(step.league.currentDay, 3 + i);
                }
              }
            } finally {
              runner.dispose();
            }
            samples.sort();
            expect(samples, hasLength(5));
            debugPrintSynchronously(
              jsonEncode({
                'warm_summary': mode,
                'teams': teamCount,
                'days': days,
                'samples': samples.length,
                'median_us': samples[2],
                'min_us': samples.first,
                'max_us': samples.last,
              }),
            );
          }
        },
        timeout: const Timeout(Duration(minutes: 2)),
      );
    }
  }
}
