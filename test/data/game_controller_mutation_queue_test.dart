import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/controlled_save_repository.dart';

void main() {
  late Directory tempDir;
  late ProviderContainer container;
  late ControlledSaveRepository repository;
  late GameController controller;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nf_controller_queue_');
    repository = ControlledSaveRepository(
      overrideDirectory: tempDir,
      waitForRelease: true,
    );
    container = ProviderContainer(
      overrides: [saveRepositoryProvider.overrideWithValue(repository)],
    );
    controller = container.read(gameControllerProvider.notifier);
    controller.state = AsyncValue.data(_game());
  });

  tearDown(() async {
    container.dispose();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('autosave persists before publishing the next provider state', () async {
    final before = controller.save!;
    final update = controller.updateLeague(
      (league) => league.copyWith(currentDay: league.currentDay + 1),
    );

    await _flushMicrotasks();
    expect(repository.saveCount, 1);
    expect(controller.save, same(before));
    expect(controller.state, isA<AsyncData<GameSave?>>());
    expect(controller.state.hasError, isFalse);

    repository.release();
    await update;

    expect(
      controller.save!.leagueState.currentDay,
      before.leagueState.currentDay + 1,
    );
    expect(repository.attemptedSaves, hasLength(1));
    expect(
      repository.attemptedSaves.single.leagueState.currentDay,
      controller.save!.leagueState.currentDay,
    );
  });

  test(
    'concurrent updateLeague calls use completed mutations as snapshots',
    () async {
      final before = controller.save!;
      final first = controller.updateLeague(
        (league) => league.copyWith(currentDay: league.currentDay + 1),
      );
      final second = controller.updateLeague(
        (league) => league.copyWith(currentDay: league.currentDay + 1),
      );

      await _flushMicrotasks();
      expect(repository.saveCount, 1);
      expect(controller.save, same(before));

      repository.release();
      await Future.wait([first, second]);

      expect(repository.attemptedSaves, hasLength(2));
      expect(
        repository.attemptedSaves.map((save) => save.leagueState.currentDay),
        [before.leagueState.currentDay + 1, before.leagueState.currentDay + 2],
      );
      expect(
        controller.save!.leagueState.currentDay,
        before.leagueState.currentDay + 2,
      );
    },
  );

  test(
    'persist waits for an earlier mutation and saves its committed snapshot',
    () async {
      final before = controller.save!;
      final update = controller.updateLeague(
        (league) => league.copyWith(currentDay: league.currentDay + 1),
      );
      final persist = controller.persist();

      await _flushMicrotasks();
      expect(repository.saveCount, 1);
      expect(controller.save, same(before));

      repository.release();
      await Future.wait([update, persist]);

      expect(repository.saveCount, 2);
      expect(
        repository.attemptedSaves[1].leagueState.currentDay,
        before.leagueState.currentDay + 1,
      );
      expect(
        controller.save!.leagueState.currentDay,
        before.leagueState.currentDay + 1,
      );
    },
  );

  test(
    'a failed save leaves the previous state and does not poison the queue',
    () async {
      repository.failure = ControlledSaveFailure.beforeWrite;
      repository.release();
      final before = controller.save!;

      await expectLater(
        controller.updateLeague(
          (league) => league.copyWith(currentDay: league.currentDay + 1),
        ),
        throwsA(isA<SaveRepositoryException>()),
      );

      expect(controller.save, same(before));
      expect(controller.state, isA<AsyncData<GameSave?>>());
      expect(controller.state.hasError, isFalse);

      repository.failure = ControlledSaveFailure.none;
      await controller.updateLeague(
        (league) => league.copyWith(currentDay: league.currentDay + 1),
      );

      expect(
        controller.save!.leagueState.currentDay,
        before.leagueState.currentDay + 1,
      );
      expect(repository.saveCount, 2);
    },
  );

  test(
    'autosave false publishes working state without persisting it',
    () async {
      repository.release();
      final before = controller.save!;

      await controller.updateLeague(
        (league) => league.copyWith(currentDay: league.currentDay + 1),
        autosave: false,
      );

      expect(repository.saveCount, 0);
      expect(
        controller.save!.leagueState.currentDay,
        before.leagueState.currentDay + 1,
      );
      expect(controller.state, isA<AsyncData<GameSave?>>());
      expect(controller.state.hasError, isFalse);
    },
  );

  test('message mutations share the same serialized snapshot queue', () async {
    final message = _urgentMessage();
    controller.state = AsyncValue.data(
      controller.save!.copyWith(
        leagueState: controller.save!.leagueState.copyWith(
          inbox: Inbox(messages: [message]),
        ),
      ),
    );

    final markRead = controller.markMessageRead(message.id);
    final acknowledge = controller.acknowledgeMessage(message.id);
    await _flushMicrotasks();
    expect(repository.saveCount, 1);
    expect(controller.save!.leagueState.inbox.messages.single, message);

    repository.release();
    await Future.wait([markRead, acknowledge]);

    expect(repository.saveCount, 2);
    expect(
      repository.attemptedSaves.map(
        (save) => save.leagueState.inbox.messages.single,
      ),
      [
        message.copyWith(read: true),
        message.copyWith(read: true, acknowledged: true),
      ],
    );
    final committed = controller.save!.leagueState.inbox.messages.single;
    expect(committed.read, isTrue);
    expect(committed.acknowledged, isTrue);
    expect(controller.state.hasError, isFalse);
  });

  test(
    'duplicate acknowledge calls share one in-flight operation and commit once',
    () async {
      final message = _urgentMessage();
      controller.state = AsyncValue.data(
        controller.save!.copyWith(
          leagueState: controller.save!.leagueState.copyWith(
            inbox: Inbox(messages: [message]),
          ),
        ),
      );

      final first = controller.acknowledgeMessage(message.id);
      final duplicate = controller.acknowledgeMessage(message.id);
      expect(identical(first, duplicate), isTrue);

      await _flushMicrotasks();
      expect(repository.saveCount, 1);
      expect(controller.save!.leagueState.inbox.messages.single, message);

      repository.release();
      await Future.wait([first, duplicate]);
      expect(repository.saveCount, 1);
      expect(
        controller.save!.leagueState.inbox.messages.single,
        message.copyWith(read: true, acknowledged: true),
      );
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);

      await controller.acknowledgeMessage(message.id);
      await controller.markMessageRead(message.id);
      expect(repository.saveCount, 1);
    },
  );

  test(
    'duplicate mark-read calls share one save and an already-read message is a no-op',
    () async {
      final message = _urgentMessage();
      controller.state = AsyncValue.data(
        controller.save!.copyWith(
          leagueState: controller.save!.leagueState.copyWith(
            inbox: Inbox(messages: [message]),
          ),
        ),
      );

      final first = controller.markMessageRead(message.id);
      final duplicate = controller.markMessageRead(message.id);
      expect(identical(first, duplicate), isTrue);

      await _flushMicrotasks();
      expect(repository.saveCount, 1);
      repository.release();
      await Future.wait([first, duplicate]);

      expect(repository.saveCount, 1);
      expect(
        controller.save!.leagueState.inbox.messages.single,
        message.copyWith(read: true),
      );
      await controller.markMessageRead(message.id);
      expect(repository.saveCount, 1);
    },
  );

  test(
    'duplicate decisions dispatch once, preserve effect-before-ack order, and reject no-ops',
    () async {
      final message = _decisionMessage();
      final before = controller.save!;
      controller.state = AsyncValue.data(
        before.copyWith(
          leagueState: before.leagueState.copyWith(
            inbox: Inbox(messages: [message]),
          ),
        ),
      );
      var effectCount = 0;
      String? selectedOption;
      bool? acknowledgedDuringEffect;

      LeagueState dispatch(
        LeagueState league,
        GameMessage selected,
        String option,
      ) {
        effectCount++;
        selectedOption = option;
        acknowledgedDuringEffect = league.inbox.messages.single.acknowledged;
        return league;
      }

      final first = controller.resolveMessageDecision(
        message.id,
        'accept',
        onDecision: dispatch,
      );
      final duplicate = controller.resolveMessageDecision(
        message.id,
        'decline',
        onDecision: dispatch,
      );
      expect(identical(first, duplicate), isTrue);

      await _flushMicrotasks();
      expect(repository.saveCount, 1);
      repository.release();
      await Future.wait([first, duplicate]);

      expect(effectCount, 1);
      expect(selectedOption, 'accept');
      expect(acknowledgedDuringEffect, isFalse);
      expect(repository.saveCount, 1);
      expect(
        controller.save!.leagueState.inbox.messages.single,
        message.copyWith(read: true, acknowledged: true),
      );
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);

      await controller.resolveMessageDecision(
        message.id,
        'accept',
        onDecision: dispatch,
      );
      await controller.resolveMessageDecision(
        'missing-message',
        'accept',
        onDecision: dispatch,
      );
      expect(effectCount, 1);
      expect(repository.saveCount, 1);
    },
  );

  test(
    'message operation entries are removed after a failed save so retry can run',
    () async {
      final message = _urgentMessage();
      controller.state = AsyncValue.data(
        controller.save!.copyWith(
          leagueState: controller.save!.leagueState.copyWith(
            inbox: Inbox(messages: [message]),
          ),
        ),
      );
      repository.failure = ControlledSaveFailure.beforeWrite;
      repository.release();

      await expectLater(
        controller.acknowledgeMessage(message.id),
        throwsA(isA<SaveRepositoryException>()),
      );
      expect(repository.saveCount, 1);
      expect(controller.save!.leagueState.inbox.messages.single, message);
      expect(controller.save!.leagueState.inbox.pendingUrgent, isNotEmpty);

      repository.failure = ControlledSaveFailure.none;
      await controller.acknowledgeMessage(message.id);
      expect(repository.saveCount, 2);
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
    },
  );

  test(
    'decision dispatch is resolved from the queued current snapshot',
    () async {
      final message = _decisionMessage();
      final before = controller.save!;
      controller.state = AsyncValue.data(
        before.copyWith(
          leagueState: before.leagueState.copyWith(
            inbox: Inbox(messages: [message]),
          ),
        ),
      );
      final observedDays = <int>[];

      final update = controller.updateLeague(
        (league) => league.copyWith(currentDay: league.currentDay + 1),
      );
      final decision = controller.resolveMessageDecision(
        message.id,
        'accept',
        onDecision: (league, selected, option) {
          observedDays.add(league.currentDay);
          return league.copyWith(currentDay: league.currentDay + 1);
        },
      );

      await _flushMicrotasks();
      expect(repository.saveCount, 1);
      repository.release();
      await Future.wait([update, decision]);

      expect(observedDays, [before.leagueState.currentDay + 1]);
      expect(
        controller.save!.leagueState.currentDay,
        before.leagueState.currentDay + 2,
      );
      expect(
        controller.save!.leagueState.inbox.messages.single.acknowledged,
        isTrue,
      );
    },
  );

  test('clear invalidates a late mutation publication', () async {
    final before = controller.save!;
    final update = controller.updateLeague(
      (league) => league.copyWith(currentDay: league.currentDay + 1),
    );

    await _flushMicrotasks();
    expect(repository.saveCount, 1);
    expect(controller.save, same(before));

    controller.clear();
    expect(controller.save, isNull);
    expect(controller.state, const AsyncValue<GameSave?>.data(null));

    repository.release();
    await update;
    await _flushMicrotasks();

    expect(controller.save, isNull);
    expect(controller.state.hasError, isFalse);
  });
}

Future<void> _flushMicrotasks() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

GameSave _game() {
  return GameFactory().create(
    const NewGameRequest(
      saveName: 'Mutation queue test',
      playerTeamId: 'team_europe_0',
      seed: 3202,
    ),
  );
}

GameMessage _urgentMessage() => const GameMessage(
  id: 'queue-urgent',
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

GameMessage _decisionMessage() => _urgentMessage().copyWith(
  id: 'queue-decision',
  decision: const DecisionSpec(
    options: [
      MessageAction(id: 'accept', labelKey: 'accept'),
      MessageAction(id: 'decline', labelKey: 'decline'),
    ],
    defaultOnExpiry: 'decline',
  ),
);
