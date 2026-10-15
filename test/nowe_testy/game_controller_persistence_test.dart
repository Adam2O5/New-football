import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/services/contract_service.dart';

import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

void main() {
  late MemorySaveRepository repository;
  late ProviderContainer container;
  late GameController controller;

  setUp(() async {
    repository = MemorySaveRepository(controllerSave());
    container = ProviderContainer(
      overrides: [saveRepositoryProvider.overrideWithValue(repository)],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(repository.game.meta.id);
  });

  tearDown(() {
    container.dispose();
  });

  test('manual save persists the latest published state', () async {
    await controller.updateLeague(
      (league) => league.copyWith(currentDay: 2),
      autosave: false,
    );
    await controller.persist();

    expect(repository.game.leagueState.currentDay, 2);
    expect(repository.writes, hasLength(1));
  });

  test('F02: flush waits for an autosave already writing', () async {
    final gate = Completer<void>();
    final started = Completer<void>();
    repository.writeGate = gate;
    repository.writeStarted = started;

    await controller.updateLeague((league) => league.copyWith(currentDay: 2));
    await started.future;

    var flushed = false;
    final flush = controller.flushPendingSave().then((_) => flushed = true);
    // A microtask checkpoint, not a wall-clock delay: let an early flush finish.
    await Future<void>.value();
    await Future<void>.value();
    final flushedBeforeRelease = flushed;

    gate.complete();
    await flush;
    await controller.enqueueSaveManagement(() async {});

    expect(repository.game.leagueState.currentDay, 2);
    expect(flushedBeforeRelease, isFalse);
  });

  test('F01: a queued offer preserves the preceding day change', () async {
    final gate = Completer<void>();
    final blocking = controller.enqueueSaveManagement(() => gate.future);
    final dayChange = controller.updateLeague(
      (league) => league.copyWith(currentDay: 2),
    );
    final offer = controller.offerFreeAgent(
      fixtureFreeAgentId,
      const ContractOffer(salary: 60000000, years: 2),
    );

    gate.complete();
    await blocking;
    await dayChange;
    final reaction = await offer;
    await controller.enqueueSaveManagement(() async {});

    expect(reaction, ContractReaction.accept);
    expect(controller.save!.leagueState.negotiations, isNotEmpty);
    expect(controller.save!.leagueState.currentDay, 2);
  });

  test(
    'F03: leaving the career persists a published queued autosave',
    () async {
      final gate = Completer<void>();
      final started = Completer<void>();
      final dayChange = controller.updateLeague(
        (league) => league.copyWith(currentDay: 2),
      );
      final blocking = controller.enqueueSaveManagement(() async {
        started.complete();
        await gate.future;
      });
      await dayChange;
      await started.future;
      expect(controller.save!.leagueState.currentDay, 2);

      // The current menu calls clear(). Follow the public leave operation if
      // stage 1 introduces a dedicated asynchronous method for this purpose.
      final leaving = Future<void>.sync(controller.clear);
      gate.complete();
      await blocking;
      await leaving;
      await controller.enqueueSaveManagement(() async {});

      expect(controller.save, isNull);
      expect(repository.game.leagueState.currentDay, 2);
    },
  );
}
