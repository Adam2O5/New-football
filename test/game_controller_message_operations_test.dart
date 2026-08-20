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

import 'helpers/controlled_save_repository.dart';

void main() {
  late Directory tempDir;
  late ProviderContainer container;
  late ControlledSaveRepository repository;
  late GameController controller;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nf_message_ops_');
    repository = ControlledSaveRepository(
      overrideDirectory: tempDir,
      waitForRelease: true,
    );
    container = ProviderContainer(
      overrides: [saveRepositoryProvider.overrideWithValue(repository)],
    );
    controller = container.read(gameControllerProvider.notifier);
    controller.state = AsyncValue.data(_gameWithInbox(const []));
  });

  tearDown(() async {
    container.dispose();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  GameSave setInbox(List<GameMessage> messages) {
    final game = _gameWithInbox(messages);
    controller.state = AsyncValue.data(game);
    return game;
  }

  test(
    'invalid, missing, and already confirmed decisions are no-ops',
    () async {
      final pending = _decisionMessage('pending-decision');
      final confirmed = _decisionMessage(
        'confirmed-decision',
      ).copyWith(read: true, acknowledged: true);
      final before = setInbox([pending, confirmed]);
      repository.release();
      var dispatcherCount = 0;

      LeagueState dispatch(
        LeagueState state,
        GameMessage message,
        String option,
      ) {
        dispatcherCount++;
        return state;
      }

      await controller.resolveMessageDecision(
        pending.id,
        'not-an-option',
        onDecision: dispatch,
      );
      await controller.resolveMessageDecision(
        'missing-decision',
        'accept',
        onDecision: dispatch,
      );
      await controller.resolveMessageDecision(
        confirmed.id,
        'accept',
        onDecision: dispatch,
      );

      expect(controller.save, same(before));
      expect(repository.saveCount, 0);
      expect(dispatcherCount, 0);
      expect(controller.save!.leagueState.inbox.pendingUrgent, [pending]);
    },
  );

  test(
    'persist waits for an acknowledgement and sees its committed snapshot',
    () async {
      final message = _urgentMessage('persist-after-ack');
      final before = setInbox([message]);

      final acknowledgement = controller.acknowledgeMessage(message.id);
      final persist = controller.persist();
      await repository.firstSaveStarted;

      expect(repository.saveCount, 1);
      expect(repository.maxConcurrentSaves, 1);
      expect(controller.save, same(before));
      expect(controller.save!.leagueState.inbox.pendingUrgent, [message]);

      repository.release();
      await Future.wait([acknowledgement, persist]);

      expect(repository.saveCount, 2);
      expect(repository.maxConcurrentSaves, 1);
      expect(
        repository.attemptedSaves
            .map((save) => save.leagueState.inbox.messages.single.acknowledged)
            .toList(),
        [true, true],
      );
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
    },
  );

  test(
    'a failed acknowledgement can be retried without global error state',
    () async {
      final message = _urgentMessage('retry-ack');
      final before = setInbox([message]);
      repository.failure = ControlledSaveFailure.beforeWrite;
      repository.release();

      await expectLater(
        controller.acknowledgeMessage(message.id),
        throwsA(isA<SaveRepositoryException>()),
      );

      expect(controller.save, same(before));
      expect(controller.state, isA<AsyncData<GameSave?>>());
      expect(controller.state.hasError, isFalse);
      expect(controller.save!.leagueState.inbox.pendingUrgent, [message]);

      repository.failure = ControlledSaveFailure.none;
      await controller.acknowledgeMessage(message.id);

      expect(repository.saveCount, 2);
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(
        controller.save!.leagueState.inbox.messages.single.acknowledged,
        isTrue,
      );
    },
  );

  test('missing and already-read markRead operations do not persist', () async {
    final alreadyRead = _urgentMessage('already-read').copyWith(read: true);
    final before = setInbox([alreadyRead]);
    repository.release();

    await controller.markMessageRead('missing-message');
    await controller.markMessageRead(alreadyRead.id);

    expect(controller.save, same(before));
    expect(repository.saveCount, 0);
    expect(controller.save!.leagueState.inbox.messages.single, alreadyRead);
  });
}

GameSave _gameWithInbox(List<GameMessage> messages) {
  final game = GameFactory().create(
    const NewGameRequest(
      saveName: 'Message operations test',
      playerTeamId: 'team_europe_0',
      seed: 3606,
    ),
  );
  return game.copyWith(
    leagueState: game.leagueState.copyWith(inbox: Inbox(messages: messages)),
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
