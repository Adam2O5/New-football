import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/day_pipeline.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/controlled_simulation_runner.dart';
import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

class _Clock {
  Duration elapsed = Duration.zero;
  final phases = <String, int>{};
  void advance(String phase, int ms) {
    phases.update(phase, (n) => n + ms, ifAbsent: () => ms);
    elapsed += Duration(milliseconds: ms);
  }
}

class _TimedRunner extends ControlledSimulationRunner {
  _TimedRunner(this.clock);
  final _Clock clock;
  @override
  Future<DayStepOutput> advanceDay(
    LeagueState league, {
    required int saveSeed,
    bool blockOnPendingUrgent = true,
    bool resolveContractMarket = true,
  }) {
    clock.advance('day', 300);
    return super.advanceDay(
      league,
      saveSeed: saveSeed,
      blockOnPendingUrgent: blockOnPendingUrgent,
      resolveContractMarket: resolveContractMarket,
    );
  }
}

class _TimedRepository extends MemorySaveRepository {
  _TimedRepository(this.clock) : super(controllerSave());
  final _Clock clock;
  @override
  Future<void> save(GameSave value) async {
    clock.advance('save', 50);
    await super.save(value);
  }
}

void main() {
  for (final popup in [false, true]) {
    test('controlled clock: day/save/observer/pacer (popup: $popup)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final clock = _Clock();
      final repository = _TimedRepository(clock);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          saveRepositoryProvider.overrideWithValue(repository),
          simulationRunnerProvider.overrideWithValue(_TimedRunner(clock)),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);
      await controller.loadGame(repository.game.meta.id);
      clock.phases.clear();
      clock.elapsed = Duration.zero;
      final pacer = CalendarSimulationPacer(
        elapsedSource: () => clock.elapsed,
        delay: (duration) async =>
            clock.advance('pacer', duration.inMilliseconds),
      );
      await controller.simulateToDate(
        1,
        2,
        pacer: pacer,
        observer: (_) {
          clock.advance('observer', popup ? 500 : 0);
        },
      );
      expect(clock.phases['day'], 300);
      expect(clock.phases['observer'], popup ? 500 : 0);
      expect(clock.phases['pacer'] ?? 0, popup ? 0 : 200);
      // Batch persistence is a final barrier, after the day cadence. It is
      // measured separately and must not shorten a popup or cause two waits.
      expect(clock.phases['save'], 50);
      expect(clock.elapsed.inMilliseconds, popup ? 850 : 550);
      expect(controller.save!.leagueState.currentDay, 2);
      debugPrint(
        jsonEncode({
          'controlled_clock_popup': popup,
          'phases_ms': clock.phases,
          'total_ms': clock.elapsed.inMilliseconds,
        }),
      );
    });
  }

  test(
    'cancel interrupts a pending observer without waiting for its timer',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = MemorySaveRepository(controllerSave());
      final runner = ControlledSimulationRunner();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          saveRepositoryProvider.overrideWithValue(repository),
          simulationRunnerProvider.overrideWithValue(runner),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);
      await controller.loadGame(repository.game.meta.id);
      final showing = Completer<void>();
      final dismissal = Completer<void>();
      final delays = <Duration>[];
      final result = controller.simulateToDate(
        1,
        5,
        pacer: CalendarSimulationPacer(
          elapsedSource: () => Duration.zero,
          delay: (duration) async => delays.add(duration),
        ),
        observer: (_) {
          showing.complete();
          return dismissal.future;
        },
      );
      await showing.future;
      controller.cancelSimulation();
      await result;
      expect(dismissal.isCompleted, isFalse);
      expect(delays, isEmpty);
      expect(runner.daysCalled, 1);
      expect(repository.game.leagueState.currentDay, 2);
      dismissal.complete();
    },
  );
}
