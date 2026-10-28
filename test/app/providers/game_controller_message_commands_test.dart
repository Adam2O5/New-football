@Tags(['unit'])
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import '../../helpers/barrier_cleanup.dart';
import '../../helpers/fixtures/game_fixtures.dart';
import '../../helpers/persistence/memory_save_repository.dart';

void main() {
  final fixture = controllerSave();
  late MemorySaveRepository repository;
  late ProviderContainer container;
  late GameController controller;

  Future<GameSave> setInbox(List<GameMessage> messages) async {
    // Prepare a normalized, already-persisted state before measuring commands.
    // A partial roster fixture otherwise needs lineup reconciliation even for
    // a no-op message, which is unrelated to command deduplication.
    await controller.updateLeague(
      (league) => league.copyWith(inbox: Inbox(messages: messages)),
      autosave: false,
    );
    await controller.persist();
    repository.writes.clear();
    return controller.save!;
  }

  setUp(() async {
    repository = MemorySaveRepository(fixture);
    container = ProviderContainer(
      overrides: [saveRepositoryProvider.overrideWithValue(repository)],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(fixture.meta.id);
  });
  tearDown(() async {
    repository.releasePendingWrites();
    await controller.enqueueSaveManagement(() async {});
    container.dispose();
  });

  test(
    'read and acknowledge publish ordered changes and persist the final inbox',
    () async {
      final message = _urgentMessage('ordered');
      await setInbox([message]);
      final published = <(bool, bool)>[];
      final subscription = container.listen(gameControllerProvider, (_, next) {
        final current = next.value!.leagueState.inbox.messages.single;
        published.add((current.read, current.acknowledged));
      });
      addTearDown(subscription.close);
      final read = controller.markMessageRead(message.id);
      final acknowledge = controller.acknowledgeMessage(message.id);
      await Future.wait([read, acknowledge]);
      await controller.flushPendingSave();
      expect(published, [(true, false), (true, true)]);
      expect(
        repository.game.leagueState.inbox.messages.single,
        message.copyWith(read: true, acknowledged: true),
      );
    },
  );

  for (final acknowledge in [false, true]) {
    test(
      'duplicate ${acknowledge ? 'acknowledge' : 'mark-read'} commands share one operation and later calls are no-ops',
      () async {
        final message = _urgentMessage('duplicate');
        await setInbox([message]);
        final gate = Completer<void>();
        releaseOnTearDown(gate);
        final blocking = controller.enqueueSaveManagement(() => gate.future);
        Future<void> command() => acknowledge
            ? controller.acknowledgeMessage(message.id)
            : controller.markMessageRead(message.id);
        final first = command();
        final repeated = command();
        expect(identical(first, repeated), isTrue);
        gate.complete();
        await blocking;
        await Future.wait([first, repeated]);
        await controller.flushPendingSave();
        expect(repository.writes, hasLength(1));
        expect(
          repository.game.leagueState.inbox.messages.single,
          message.copyWith(read: true, acknowledged: acknowledge),
        );
        await command();
        await controller.markMessageRead(message.id);
        await controller.flushPendingSave();
        expect(repository.writes, hasLength(1));
      },
    );
  }

  test(
    'duplicate decisions dispatch once before acknowledgement and keep the first option',
    () async {
      final message = _decisionMessage('decision');
      await setInbox([message]);
      final gate = Completer<void>();
      releaseOnTearDown(gate);
      final blocking = controller.enqueueSaveManagement(() => gate.future);
      final options = <String>[];
      final acknowledgedDuringEffect = <bool>[];
      LeagueState dispatch(
        LeagueState league,
        GameMessage selected,
        String option,
      ) {
        options.add(option);
        acknowledgedDuringEffect.add(selected.acknowledged);
        return league;
      }

      final first = controller.resolveMessageDecision(
        message.id,
        'accept',
        onDecision: dispatch,
      );
      final repeated = controller.resolveMessageDecision(
        message.id,
        'decline',
        onDecision: dispatch,
      );
      expect(identical(first, repeated), isTrue);
      gate.complete();
      await blocking;
      await Future.wait([first, repeated]);
      await controller.flushPendingSave();
      expect(options, ['accept']);
      expect(acknowledgedDuringEffect, [false]);
      expect(repository.writes, hasLength(1));
      expect(
        repository.game.leagueState.inbox.messages.single,
        message.copyWith(read: true, acknowledged: true),
      );
      await controller.resolveMessageDecision(
        message.id,
        'decline',
        onDecision: dispatch,
      );
      await controller.flushPendingSave();
      expect(options, ['accept']);
      expect(repository.writes, hasLength(1));
    },
  );

  test(
    'failed decision transformation releases the command for a successful retry',
    () async {
      final message = _decisionMessage('retry');
      await setInbox([message]);
      await expectLater(
        controller.resolveMessageDecision(
          message.id,
          'accept',
          onDecision: (_, _, _) =>
              throw StateError('controlled effect failure'),
        ),
        throwsStateError,
      );
      expect(controller.save!.leagueState.inbox.messages.single, message);
      expect(controller.state.hasError, isFalse);
      var effects = 0;
      await controller.resolveMessageDecision(
        message.id,
        'accept',
        onDecision: (league, _, _) {
          effects++;
          return league.copyWith(currentDay: 2);
        },
      );
      await controller.flushPendingSave();
      expect(effects, 1);
      expect(repository.game.leagueState.currentDay, 2);
      expect(repository.game.leagueState.inbox.pendingUrgent, isEmpty);
    },
  );

  test(
    'failed acknowledgement autosave preserves working state and needs a save retry',
    () async {
      final message = _urgentMessage('failed-write');
      await setInbox([message]);
      final error = StateError('controlled write failure');
      repository.writeError = error;
      await controller.acknowledgeMessage(message.id);
      await expectLater(controller.flushPendingSave(), throwsA(same(error)));
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(controller.state.hasError, isFalse);
      expect(repository.game.leagueState.inbox.messages.single, message);
      // Repeating an already applied domain command does not replay its effect.
      await controller.acknowledgeMessage(message.id);
      await expectLater(controller.flushPendingSave(), throwsA(same(error)));
      repository.writeError = null;
      await controller.persist();
      await controller.flushPendingSave();
      expect(
        repository.game.leagueState.inbox.messages.single,
        message.copyWith(read: true, acknowledged: true),
      );
    },
  );

  test('decision dispatch sees a preceding queued mutation', () async {
    final message = _decisionMessage('queued');
    await setInbox([message]);
    final observedDays = <int>[];
    final update = controller.updateLeague(
      (l) => l.copyWith(currentDay: l.currentDay + 1),
    );
    final decision = controller.resolveMessageDecision(
      message.id,
      'accept',
      onDecision: (league, _, _) {
        observedDays.add(league.currentDay);
        return league.copyWith(currentDay: league.currentDay + 1);
      },
    );
    await Future.wait([update, decision]);
    await controller.flushPendingSave();
    expect(observedDays, [2]);
    expect(repository.game.leagueState.currentDay, 3);
    expect(repository.game.leagueState.inbox.pendingUrgent, isEmpty);
  });

  test(
    'invalid, missing and confirmed decisions do not dispatch or persist',
    () async {
      final pending = _decisionMessage('pending');
      final confirmed = _decisionMessage(
        'confirmed',
      ).copyWith(read: true, acknowledged: true);
      final before = await setInbox([pending, confirmed]);
      var effects = 0;
      LeagueState dispatch(LeagueState league, GameMessage _, String _) {
        effects++;
        return league;
      }

      for (final (id, option) in [
        (pending.id, 'invalid'),
        ('missing', 'accept'),
        (confirmed.id, 'accept'),
      ]) {
        await controller.resolveMessageDecision(
          id,
          option,
          onDecision: dispatch,
        );
      }
      await controller.flushPendingSave();
      expect(
        identical(controller.save, before),
        isTrue,
        reason: 'A no-op must preserve the published state instance.',
      );
      expect(repository.writes, isEmpty);
      expect(effects, 0);
      expect(controller.save!.leagueState.inbox.pendingUrgent, [pending]);
    },
  );

  test('missing and already-read markRead operations do not persist', () async {
    final message = _urgentMessage('read').copyWith(read: true);
    final before = await setInbox([message]);
    await controller.markMessageRead('missing');
    await controller.markMessageRead(message.id);
    await controller.flushPendingSave();
    expect(
      identical(controller.save, before),
      isTrue,
      reason: 'A no-op must preserve the published state instance.',
    );
    expect(repository.writes, isEmpty);
  });

  test(
    'manual persist waits for acknowledgement I/O and writes the updated inbox',
    () async {
      final message = _urgentMessage('persist');
      await setInbox([message]);
      final gate = Completer<void>();
      releaseOnTearDown(gate);
      final started = Completer<void>();
      repository.writeGate = gate;
      repository.writeStarted = started;
      await controller.acknowledgeMessage(message.id);
      await started.future;
      var persisted = false;
      final persist = controller.persist().then((_) => persisted = true);
      await Future<void>.value();
      await Future<void>.value();
      expect(persisted, isFalse);
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(repository.game.leagueState.inbox.pendingUrgent, [message]);
      gate.complete();
      await persist;
      expect(
        repository.game.leagueState.inbox.messages.single,
        message.copyWith(read: true, acknowledged: true),
      );
    },
  );
}

GameMessage _urgentMessage(String id) => GameMessage(
  id: id,
  type: MessageType.playerEvent,
  domain: MessageDomain.playerEvent,
  priority: MessagePriority.urgent,
  seasonYear: 2026,
  week: 1,
  day: 1,
  titleKey: 'msg_playerEvent_title',
  bodyKey: 'msg_playerEvent_body',
  args: const {'_legacyTitle': 'Pilna wiadomość', '_legacyBody': 'Treść'},
);

GameMessage _decisionMessage(String id) => _urgentMessage(id).copyWith(
  decision: const DecisionSpec(
    options: [
      MessageAction(id: 'accept', labelKey: 'accept'),
      MessageAction(id: 'decline', labelKey: 'decline'),
    ],
    defaultOnExpiry: 'decline',
  ),
);
