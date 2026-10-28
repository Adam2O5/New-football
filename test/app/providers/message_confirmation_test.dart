@Tags(['unit'])
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/team_event_service.dart';
import 'package:new_football/data/save_repository.dart';

import '../../helpers/fixtures/game_fixtures.dart';
import '../../helpers/persistence/memory_save_repository.dart';

const _message = GameMessage(
  id: 'durable-decision',
  type: MessageType.teamEvent,
  priority: MessagePriority.urgent,
  seasonYear: 2026,
  week: 1,
  titleKey: 'test_title',
  bodyKey: 'test_body',
  decision: DecisionSpec(
    options: [
      MessageAction(id: 'accept', labelKey: 'accept'),
      MessageAction(id: 'reject', labelKey: 'reject'),
    ],
    defaultOnExpiry: 'reject',
  ),
);

class _Decisions extends TeamEventService {
  final options = <String>[];
  Object? error;

  @override
  LeagueState resolveDecision(
    LeagueState league,
    GameMessage message,
    String optionId, {
    int saveSeed = 0,
  }) {
    options.add(optionId);
    if (error != null) throw error!;
    return league.copyWith(currentDay: league.currentDay + 1);
  }
}

void main() {
  final fixture = controllerSave();
  late MemorySaveRepository repository;
  late ProviderContainer container;
  late GameController controller;
  late _Decisions decisions;

  setUp(() async {
    repository = MemorySaveRepository(fixture);
    decisions = _Decisions();
    container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(repository),
        teamEventServiceProvider.overrideWithValue(decisions),
      ],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(fixture.meta.id);
    await controller.updateLeague(
      (league) => league.copyWith(inbox: const Inbox(messages: [_message])),
      autosave: false,
    );
    await controller.persist();
    repository.writes.clear();
  });

  tearDown(() async {
    repository.releasePendingWrites();
    await controller.enqueueSaveManagement(() async {});
    container.dispose();
  });

  test(
    'confirmation shares the durable future and keeps the first option',
    () async {
      final confirmation = controller.createMessageConfirmation(_message.id);
      final gate = Completer<void>();
      final started = Completer<void>();
      repository.writeGate = gate;
      repository.writeStarted = started;
      var completed = false;
      final first = confirmation.decide('accept');
      final repeated = confirmation.decide('reject');
      first.then((_) => completed = true);
      expect(identical(first, repeated), isTrue);
      await started.future;
      expect(completed, isFalse);
      expect(decisions.options, ['accept']);
      expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(repository.game.leagueState.inbox.pendingUrgent, hasLength(1));
      gate.complete();
      await first;
      expect(repository.writes, hasLength(1));
      expect(
        repository.game.leagueState.currentDay,
        fixture.leagueState.currentDay + 1,
      );
      await confirmation.decide('reject');
      expect(decisions.options, ['accept']);
      expect(repository.writes, hasLength(1));
    },
  );

  for (final ambiguous in [false, true]) {
    test(
      'save retry preserves the effect and current state (ambiguous=$ambiguous)',
      () async {
        final confirmation = controller.createMessageConfirmation(_message.id);
        final failure = ambiguous
            ? SaveAmbiguousWriteException(saveId: fixture.meta.id)
            : StateError('controlled I/O failure');
        repository.writeError = failure;
        final matcher = isA<MessageConfirmationSaveException>().having(
          (error) => error.cause,
          'cause',
          same(failure),
        );
        await expectLater(confirmation.decide('accept'), throwsA(matcher));
        await expectLater(confirmation.decide('accept'), throwsA(matcher));
        expect(decisions.options, ['accept']);
        expect(repository.writes, isEmpty);
        await controller.updateLeague(
          (league) => league.copyWith(currentDay: league.currentDay + 2),
          autosave: false,
        );
        repository.writeError = null;
        await confirmation.decide('accept');
        expect(decisions.options, ['accept']);
        expect(repository.writes, hasLength(1));
        expect(
          repository.game.leagueState.currentDay,
          fixture.leagueState.currentDay + 3,
        );
        expect(repository.game.leagueState.inbox.pendingUrgent, isEmpty);
      },
    );
  }

  test(
    'domain failure retries the command before acknowledgement or save',
    () async {
      final confirmation = controller.createMessageConfirmation(_message.id);
      final failure = StateError('controlled domain failure');
      decisions.error = failure;
      await expectLater(confirmation.decide('accept'), throwsA(same(failure)));
      expect(repository.writes, isEmpty);
      expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));
      decisions.error = null;
      await confirmation.decide('accept');
      expect(decisions.options, ['accept', 'accept']);
      expect(
        repository.game.leagueState.currentDay,
        fixture.leagueState.currentDay + 1,
      );
      expect(repository.writes, hasLength(1));
    },
  );

  test(
    'an in-progress career transition rejects an old sheet command',
    () async {
      final confirmation = controller.createMessageConfirmation(_message.id);
      final gate = Completer<void>();
      repository.loadOperation = (_) async {
        await gate.future;
        return repository.game;
      };
      final transition = controller.loadGame(fixture.meta.id);
      try {
        expect(confirmation.isCurrent, isFalse);
        await confirmation.decide('accept');
        expect(decisions.options, isEmpty);
        expect(repository.writes, isEmpty);
      } finally {
        gate.complete();
        await transition;
      }
    },
  );

  test('a same-ID reload invalidates an old sheet confirmation', () async {
    final confirmation = controller.createMessageConfirmation(_message.id);
    await controller.loadGame(fixture.meta.id);
    expect(confirmation.isCurrent, isFalse);
    await confirmation.decide('accept');
    expect(decisions.options, isEmpty);
    expect(repository.writes, isEmpty);
    expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));
  });

  test('a save retry cannot mutate or persist a replacement career', () async {
    final confirmation = controller.createMessageConfirmation(_message.id);
    repository.writeError = StateError('controlled I/O failure');
    await expectLater(
      confirmation.decide('accept'),
      throwsA(isA<MessageConfirmationSaveException>()),
    );
    repository.writeError = null;
    final other = repository.game.copyWith(
      meta: repository.game.meta.copyWith(id: 'other'),
    );
    repository.games['other'] = other;
    await controller.loadGame('other');
    repository.writes.clear();
    await confirmation.decide('accept');
    expect(decisions.options, ['accept']);
    expect(repository.writes, isEmpty);
    expect(controller.save!.meta.id, 'other');
    expect(controller.save!.leagueState.inbox.pendingUrgent, hasLength(1));
  });
}
