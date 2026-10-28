@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/data/save_repository.dart';
import '../helpers/fixtures/game_fixtures.dart';

void main() {
  for (final enabled in [false, true]) {
    test(
      'global urgent setting $enabled stays separate from message state across real saves and restart',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'football-urgent-flow-',
        );
        final repository = SaveRepository(overrideDirectory: directory);
        SharedPreferences.setMockInitialValues({
          urgentInterruptionSettingKey: !enabled,
        });
        final preferences = await SharedPreferences.getInstance();
        final fixture = controllerSave();
        const message = GameMessage(
          id: 'persisted-urgent',
          type: MessageType.playerEvent,
          domain: MessageDomain.playerEvent,
          priority: MessagePriority.urgent,
          seasonYear: 2026,
          week: 1,
          day: 1,
          titleKey: 'msg_playerEvent_title',
          bodyKey: 'msg_playerEvent_body',
        );
        final first = fixture.copyWith(
          leagueState: fixture.leagueState.copyWith(
            inbox: const Inbox(messages: [message]),
          ),
        );
        final second = fixture.copyWith(
          meta: fixture.meta.copyWith(id: 'second-save'),
        );
        final container = ProviderContainer(
          overrides: [
            saveRepositoryProvider.overrideWithValue(repository),
            sharedPreferencesProvider.overrideWithValue(preferences),
          ],
        );
        final controller = container.read(gameControllerProvider.notifier);
        try {
          await repository.save(first);
          await repository.save(second);
          await controller.loadGame(first.meta.id);
          final file = File('${directory.path}/${first.meta.id}.json');
          final beforePreferenceWrite = await file.readAsString();
          await container
              .read(urgentInterruptionSettingProvider.notifier)
              .setUrgentInterruption(enabled);
          expect(await file.readAsString(), beforePreferenceWrite);
          expect(controller.save!.leagueState.inbox.pendingUrgent, [message]);
          await controller.markMessageRead(message.id);
          await controller.flushPendingSave();
          final readMessage = message.copyWith(read: true);
          expect(
            (await repository.load(
              first.meta.id,
            )).leagueState.inbox.pendingUrgent,
            [readMessage],
          );
          await controller.clear();
          await controller.loadGame(second.meta.id);
          expect(container.read(urgentInterruptionSettingProvider), enabled);
          expect(controller.save!.leagueState.inbox.messages, isEmpty);
          await controller.loadGame(first.meta.id);
          expect(controller.save!.leagueState.inbox.pendingUrgent, [
            readMessage,
          ]);
          await controller.acknowledgeMessage(message.id);
          await controller.persist();
          final durable = controller.save!;
          await controller.clear();

          final restarted = ProviderContainer(
            overrides: [
              saveRepositoryProvider.overrideWithValue(
                SaveRepository(overrideDirectory: directory),
              ),
              sharedPreferencesProvider.overrideWithValue(preferences),
            ],
          );
          try {
            final restored = restarted.read(gameControllerProvider.notifier);
            await restored.loadGame(first.meta.id);
            expect(restarted.read(urgentInterruptionSettingProvider), enabled);
            expect(
              restored.save!.leagueState == durable.leagueState,
              isTrue,
              reason:
                  'The complete saved league must survive a new provider/repository.',
            );
            expect(restored.save!.leagueState.inbox.pendingUrgent, isEmpty);
            expect(
              restored.save!.leagueState.inbox.messages.single,
              message.copyWith(read: true, acknowledged: true),
            );
          } finally {
            restarted.dispose();
          }
          for (final game in [first, second]) {
            final json = jsonDecode(
              await File(
                '${directory.path}/${game.meta.id}.json',
              ).readAsString(),
            );
            expect(
              _containsPreferenceKey(json),
              isFalse,
              reason:
                  'The global setting must not enter any nested domain JSON.',
            );
          }
        } finally {
          try {
            await controller.enqueueSaveManagement(() async {});
          } finally {
            container.dispose();
            await directory.delete(recursive: true);
          }
        }
      },
    );
  }
}

bool _containsPreferenceKey(Object? value) {
  if (value is Map) {
    return value.containsKey(urgentInterruptionSettingKey) ||
        value.values.any(_containsPreferenceKey);
  }
  return value is Iterable && value.any(_containsPreferenceKey);
}
