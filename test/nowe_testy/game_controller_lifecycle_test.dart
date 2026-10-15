import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/core/services/game_factory.dart';

import 'support/controlled_simulation_runner.dart';
import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

void main() {
  late MemorySaveRepository repository;
  late ProviderContainer container;
  late GameController controller;
  late ControlledSimulationRunner runner;

  setUp(() async {
    repository = MemorySaveRepository(controllerSave());
    runner = ControlledSimulationRunner();
    container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(repository),
        simulationRunnerProvider.overrideWithValue(runner),
      ],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(repository.game.meta.id);
  });

  tearDown(() => container.dispose());

  test('failed leave keeps the active career and can be retried', () async {
    await controller.updateLeague(
      (league) => league.copyWith(currentDay: 2),
      autosave: false,
    );
    repository.writeError = StateError('disk unavailable');
    await expectLater(controller.clear(), throwsStateError);
    expect(controller.save!.leagueState.currentDay, 2);
    expect(repository.game.leagueState.currentDay, 1);

    repository.writeError = null;
    await controller.clear();
    expect(controller.save, isNull);
    expect(repository.game.leagueState.currentDay, 2);
  });

  test(
    'leave waits for an in-flight save and shares repeated requests',
    () async {
      final gate = Completer<void>();
      final started = Completer<void>();
      repository.writeGate = gate;
      repository.writeStarted = started;
      await controller.updateLeague((league) => league.copyWith(currentDay: 2));
      await started.future;
      final first = controller.clear();
      final second = controller.clear();
      expect(identical(first, second), isTrue);
      await Future<void>.value();
      expect(controller.save, isNotNull);

      gate.complete();
      await first;
      expect(controller.save, isNull);
      expect(repository.game.leagueState.currentDay, 2);
      expect(repository.writes, hasLength(1));
    },
  );

  test(
    'leave finishes one started batch step and blocks new commands',
    () async {
      runner.dayGate = Completer<void>();
      final batch = controller.simulateToDate(
        1,
        5,
        pacer: CalendarSimulationPacer(target: Duration.zero),
      );
      await runner.dayStarted.future;
      final leaving = controller.clear();
      await controller.updateLeague((league) => league.copyWith(currentDay: 7));
      expect(await controller.advanceOneDay(), isNull);
      runner.dayGate!.complete();
      final result = await batch;
      await leaving;

      expect(result.stopReason, SimulationStopReason.cancelled);
      expect(runner.daysCalled, 1);
      expect(repository.game.leagueState.currentDay, 2);
      expect(controller.save, isNull);
    },
  );

  test('leave interrupts a pending presentation observer', () async {
    final observing = Completer<void>();
    final observerGate = Completer<void>();
    final batch = controller.simulateToDate(
      1,
      5,
      pacer: CalendarSimulationPacer(target: Duration.zero),
      observer: (_) {
        observing.complete();
        return observerGate.future;
      },
    );
    await observing.future;
    await controller.clear();
    expect((await batch).stopReason, SimulationStopReason.cancelled);
    expect(observerGate.isCompleted, isFalse);
    expect(repository.game.leagueState.currentDay, 2);
    observerGate.complete();
  });

  test('leave interrupts a pending pacer delay', () async {
    final delaying = Completer<void>();
    final delayGate = Completer<void>();
    final batch = controller.simulateToDate(
      1,
      5,
      pacer: CalendarSimulationPacer(
        elapsedSource: () => Duration.zero,
        delay: (_) {
          delaying.complete();
          return delayGate.future;
        },
      ),
    );
    await delaying.future;
    await controller.clear();
    expect((await batch).stopReason, SimulationStopReason.cancelled);
    expect(delayGate.isCompleted, isFalse);
    delayGate.complete();
  });

  test('load A then B ignores the late result of A', () async {
    final original = controller.save!;
    final first = original.copyWith(meta: original.meta.copyWith(id: 'A'));
    final second = original.copyWith(meta: original.meta.copyWith(id: 'B'));
    final started = Completer<void>();
    final loadGate = Completer<void>();
    repository.loadOperation = (id) async {
      if (id == 'A') {
        started.complete();
        await loadGate.future;
        return first;
      }
      return second;
    };
    final publishedIds = <String?>[];
    final subscription = container.listen(gameControllerProvider, (_, next) {
      publishedIds.add(next.value?.meta.id);
    });
    addTearDown(subscription.close);
    final loadA = controller.loadGame('A');
    await started.future;
    final loadB = controller.loadGame('B');
    loadGate.complete();
    await loadA;
    await loadB;

    expect(controller.save!.meta.id, 'B');
    expect(publishedIds, isNot(contains('A')));
  });

  test('switching career persists the previous state before loading', () async {
    final original = controller.save!;
    final target = original.copyWith(
      meta: original.meta.copyWith(id: 'target'),
    );
    repository.games[target.meta.id] = target;
    await controller.updateLeague(
      (league) => league.copyWith(currentDay: 2),
      autosave: false,
    );
    await controller.loadGame(target.meta.id);

    expect(repository.games[original.meta.id]!.leagueState.currentDay, 2);
    expect(controller.save!.meta.id, target.meta.id);
    expect(controller.save!.leagueState.currentDay, 1);
  });

  test(
    'loading another career waits for the old worker step to finish',
    () async {
      final original = controller.save!;
      final target = original.copyWith(
        meta: original.meta.copyWith(id: 'target'),
      );
      repository.games[target.meta.id] = target;
      runner.dayGate = Completer<void>();
      final batch = controller.simulateToDate(
        1,
        5,
        pacer: CalendarSimulationPacer(target: Duration.zero),
      );
      await runner.dayStarted.future;
      final loading = controller.loadGame(target.meta.id);
      expect(controller.save!.meta.id, original.meta.id);
      runner.dayGate!.complete();
      await batch;
      await loading;

      expect(repository.games[original.meta.id]!.leagueState.currentDay, 2);
      expect(controller.save!.meta.id, 'target');
      expect(controller.save!.leagueState.currentDay, 1);
      expect(runner.daysCalled, 1);
    },
  );

  test('failed load preserves the previous persisted career', () async {
    await controller.updateLeague(
      (league) => league.copyWith(currentDay: 2),
      autosave: false,
    );
    repository.loadOperation = (_) => Future.error(StateError('load failed'));
    await expectLater(controller.loadGame('missing'), throwsStateError);
    expect(controller.save!.leagueState.currentDay, 2);
    expect(repository.game.leagueState.currentDay, 2);
    repository.loadOperation = null;
    await controller.updateLeague((league) => league.copyWith(currentDay: 3));
    await controller.flushPendingSave();
    expect(repository.game.leagueState.currentDay, 3);
  });

  test(
    'a failed old write cannot leak into a subsequently loaded career',
    () async {
      final original = controller.save!;
      final target = original.copyWith(
        meta: original.meta.copyWith(id: 'target'),
      );
      repository.games[target.meta.id] = target;
      repository.writeError = StateError('old autosave failed');
      await controller.updateLeague((league) => league.copyWith(currentDay: 2));
      await controller.enqueueSaveManagement(() async {});
      repository.writeError = null;
      await controller.loadGame(target.meta.id);
      await expectLater(controller.flushPendingSave(), completes);
      expect(controller.save!.meta.id, 'target');
    },
  );

  test('creating a career first saves the previous one', () async {
    final original = controller.save!;
    await controller.updateLeague(
      (league) => league.copyWith(currentDay: 2),
      autosave: false,
    );
    await controller.createNewGame(
      NewGameRequest(
        saveName: 'new-career',
        playerTeamId: original.leagueState.playerTeamId!,
        seed: fixtureSeed,
      ),
    );

    expect(repository.games[original.meta.id]!.leagueState.currentDay, 2);
    expect(controller.save!.meta.name, 'new-career');
    expect(repository.games[controller.save!.meta.id], isNotNull);
  });

  test('failed initial load can be followed by a successful load', () async {
    await controller.clear();
    await expectLater(controller.loadGame('missing'), throwsStateError);
    expect(container.read(gameControllerProvider).hasError, isTrue);
    await controller.loadGame(repository.game.meta.id);
    expect(controller.save, isNotNull);
  });

  test('failed new career save keeps the previous career active', () async {
    final original = controller.save!;
    repository.writeError = StateError('new career save failed');
    await expectLater(
      controller.createNewGame(
        NewGameRequest(
          saveName: 'new-career',
          playerTeamId: original.leagueState.playerTeamId!,
          seed: fixtureSeed,
        ),
      ),
      throwsStateError,
    );
    expect(controller.save, original);
    expect(repository.games, hasLength(1));
    repository.writeError = null;
    await controller.updateLeague((league) => league.copyWith(currentDay: 2));
    await controller.flushPendingSave();
    expect(repository.game.leagueState.currentDay, 2);
  });

  test(
    'deleting the active save does not enqueue a save of the deleted file',
    () async {
      final id = controller.save!.meta.id;
      await controller.updateLeague(
        (league) => league.copyWith(currentDay: 2),
        autosave: false,
      );
      await container.read(saveManagementCoordinatorProvider).delete(id);
      await controller.enqueueSaveManagement(() async {});

      expect(controller.save, isNull);
      expect(repository.deletedIds, [id]);
      expect(repository.games.containsKey(id), isFalse);
      expect(repository.writes, isEmpty);
    },
  );
}
