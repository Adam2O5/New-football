@Tags(['unit'])
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/services/contract_service.dart';

import '../../helpers/barrier_cleanup.dart';
import '../../helpers/fixtures/game_fixtures.dart';
import '../../helpers/persistence/memory_save_repository.dart';

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

  tearDown(() async {
    repository.releasePendingWrites();
    await controller.enqueueSaveManagement(() async {});
    container.dispose();
  });

  test(
    'working state is published while its autosave is still blocked',
    () async {
      final started = Completer<void>();
      final gate = Completer<void>();
      releaseOnTearDown(gate);
      repository.writeStarted = started;
      repository.writeGate = gate;
      await controller.updateLeague((league) => league.copyWith(currentDay: 2));
      await started.future;
      expect(controller.save!.leagueState.currentDay, 2);
      expect(controller.state.hasError, isFalse);
      expect(repository.game.leagueState.currentDay, 1);
      gate.complete();
      await controller.flushPendingSave();
      expect(repository.game.leagueState.currentDay, 2);
    },
  );

  test(
    'concurrent mutations use the latest state and persist their combined result',
    () async {
      final gate = Completer<void>();
      releaseOnTearDown(gate);
      final blocking = controller.enqueueSaveManagement(() => gate.future);
      final first = controller.updateLeague(
        (l) => l.copyWith(currentDay: l.currentDay + 1),
      );
      final second = controller.updateLeague(
        (l) => l.copyWith(currentDay: l.currentDay + 1),
      );
      gate.complete();
      await blocking;
      await Future.wait([first, second]);
      expect(controller.save!.leagueState.currentDay, 3);
      await controller.flushPendingSave();
      expect(repository.game.leagueState.currentDay, 3);
      expect(
        repository.game.leagueState == controller.save!.leagueState,
        isTrue,
      );
    },
  );

  test('manual persist waits for the earlier blocked autosave', () async {
    final started = Completer<void>();
    final gate = Completer<void>();
    releaseOnTearDown(gate);
    repository.writeStarted = started;
    repository.writeGate = gate;
    await controller.updateLeague((l) => l.copyWith(currentDay: 2));
    await started.future;
    var persisted = false;
    final persist = controller.persist().then((_) => persisted = true);
    await Future<void>.value();
    await Future<void>.value();
    expect(persisted, isFalse);
    expect(controller.save!.leagueState.currentDay, 2);
    expect(repository.game.leagueState.currentDay, 1);
    gate.complete();
    await persist;
    expect(repository.game.leagueState.currentDay, 2);
  });

  test('manual save persists the latest published state', () async {
    await controller.updateLeague(
      (league) => league.copyWith(currentDay: 2),
      autosave: false,
    );
    expect(controller.save!.leagueState.currentDay, 2);
    expect(repository.game.leagueState.currentDay, 1);
    expect(repository.writes, isEmpty);
    await controller.persist();

    expect(repository.game.leagueState.currentDay, 2);
    expect(repository.writes, hasLength(1));
  });

  test('F02: flush waits for an autosave already writing', () async {
    final gate = Completer<void>();
    releaseOnTearDown(gate);
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
    releaseOnTearDown(gate);
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

  test('flush includes a mutation queued before its autosave exists', () async {
    final queueGate = Completer<void>();
    releaseOnTearDown(queueGate);
    final writeGate = Completer<void>();
    releaseOnTearDown(writeGate);
    final writeStarted = Completer<void>();
    repository.writeGate = writeGate;
    repository.writeStarted = writeStarted;
    final blocking = controller.enqueueSaveManagement(() => queueGate.future);
    final change = controller.updateLeague(
      (league) => league.copyWith(currentDay: 2),
    );
    var flushed = false;
    final flush = controller.flushPendingSave().then((_) => flushed = true);

    queueGate.complete();
    await blocking;
    await change;
    await writeStarted.future;
    await Future<void>.value();
    final flushedBeforeRelease = flushed;
    writeGate.complete();
    await flush;
    await controller.enqueueSaveManagement(() async {});

    expect(flushedBeforeRelease, isFalse);
    expect(repository.game.leagueState.currentDay, 2);
  });

  test('flush keeps reporting a failure while the state is unsaved', () async {
    final error = StateError('write failed');
    repository.writeError = error;
    await controller.updateLeague((league) => league.copyWith(currentDay: 2));
    await controller.enqueueSaveManagement(() async {});

    await expectLater(controller.flushPendingSave(), throwsA(same(error)));
    await expectLater(controller.flushPendingSave(), throwsA(same(error)));
    expect(controller.save!.leagueState.currentDay, 2);
    expect(controller.state.hasError, isFalse);
    expect(repository.game.leagueState.currentDay, 1);
  });

  test('a successful newer autosave supersedes an older failure', () async {
    repository.writeError = StateError('first write failed');
    await controller.updateLeague((league) => league.copyWith(currentDay: 2));
    await controller.enqueueSaveManagement(() async {});
    repository.writeError = null;
    await controller.updateLeague((league) => league.copyWith(currentDay: 3));
    await controller.enqueueSaveManagement(() async {});

    await expectLater(controller.flushPendingSave(), completes);
    expect(repository.game.leagueState.currentDay, 3);
  });

  test(
    'manual retry clears the failure after saving the current state',
    () async {
      repository.writeError = StateError('first write failed');
      await controller.updateLeague((league) => league.copyWith(currentDay: 2));
      await controller.enqueueSaveManagement(() async {});
      repository.writeError = null;

      await controller.persist();
      await expectLater(controller.flushPendingSave(), completes);
      expect(repository.game.leagueState.currentDay, 2);
    },
  );

  test(
    'F03: leaving the career persists a published queued autosave',
    () async {
      final gate = Completer<void>();
      releaseOnTearDown(gate);
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

      final leaving = controller.clear();
      gate.complete();
      await blocking;
      await leaving;
      await controller.enqueueSaveManagement(() async {});

      expect(controller.save, isNull);
      expect(repository.game.leagueState.currentDay, 2);
    },
  );
}
