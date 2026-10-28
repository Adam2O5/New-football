@Tags(['integration'])
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/fixtures/game_fixtures.dart';
import '../helpers/persistence/controlled_save_repository.dart';

void main() {
  test(
    'failed decision save rolls back on disk; save-only retry survives restart once',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'football-inbox-durable-',
      );
      final disk = SaveRepository(overrideDirectory: directory);
      final base = controllerSave();
      final team = base.leagueState.playerTeam!;
      final message = GameMessage(
        id: 'durable-team-decision',
        type: MessageType.teamEvent,
        kind: 'moreMinutesRequest',
        domain: MessageDomain.teamEvent,
        priority: MessagePriority.urgent,
        seasonYear: 2026,
        week: 1,
        titleKey: 'msg_teamEvent_moreMinutesRequest_title',
        bodyKey: 'msg_teamEvent_moreMinutesRequest_body',
        payload: {
          'teamId': team.id,
          'playerId': team.roster.first.id,
          'eventKind': 'moreMinutesRequest',
        },
        decision: const DecisionSpec(
          options: [MessageAction(id: 'accept', labelKey: 'accept')],
          defaultOnExpiry: 'accept',
        ),
      );
      final game = base.copyWith(
        leagueState: base.leagueState.copyWith(
          inbox: Inbox(messages: [message]),
        ),
      );
      final repository = ControlledSaveRepository(
        overrideDirectory: directory,
        failure: ControlledSaveFailure.afterPartialWrite,
      );
      final container = ProviderContainer(
        overrides: [saveRepositoryProvider.overrideWithValue(repository)],
      );
      final controller = container.read(gameControllerProvider.notifier);
      try {
        await disk.save(game);
        await controller.loadGame(game.meta.id);
        final confirmation = controller.createMessageConfirmation(message.id);
        await expectLater(
          confirmation.decide('accept'),
          throwsA(isA<MessageConfirmationSaveException>()),
        );
        expect(controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
        expect(
          controller.save!.leagueState.playerTeam!.eventState.promises,
          hasLength(1),
        );
        final rolledBack = await disk.load(game.meta.id);
        expect(rolledBack.leagueState.inbox.pendingUrgent, hasLength(1));
        expect(rolledBack.leagueState.playerTeam!.eventState.promises, isEmpty);
        final appliedLeague = controller.save!.leagueState;
        repository.failure = ControlledSaveFailure.none;
        await confirmation.decide('accept');
        expect(repository.completedSaves, hasLength(1));
        expect(controller.save!.leagueState, appliedLeague);
        final restarted = ProviderContainer(
          overrides: [
            saveRepositoryProvider.overrideWithValue(
              SaveRepository(overrideDirectory: directory),
            ),
          ],
        );
        try {
          final restored = restarted.read(gameControllerProvider.notifier);
          await restored.loadGame(game.meta.id);
          expect(restored.save!.leagueState.inbox.pendingUrgent, isEmpty);
          final promises =
              restored.save!.leagueState.playerTeam!.eventState.promises;
          expect(promises, hasLength(1));
          expect(promises.single.playerId, team.roster.first.id);
          expect(restored.save!.leagueState, controller.save!.leagueState);
        } finally {
          restarted.dispose();
        }
      } finally {
        repository.release();
        await controller.enqueueSaveManagement(() async {});
        container.dispose();
        await directory.delete(recursive: true);
      }
    },
  );
}
