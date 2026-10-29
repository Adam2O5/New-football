@Tags(['unit'])
library;

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/message_service.dart';
import '../helpers/fixtures/game_fixtures.dart';

void main() {
  test('fixed Inbox order puts urgent ahead of unread and read messages', () {
    final messages = [
      _message(
        id: 'read',
        title: 'Read',
        domain: MessageDomain.system,
        read: true,
      ),
      _message(id: 'unread', title: 'Unread', domain: MessageDomain.system),
      _message(
        id: 'urgent',
        title: 'Urgent',
        domain: MessageDomain.system,
        priority: MessagePriority.urgent,
      ),
    ];
    expect(sortInboxMessages(messages).map((message) => message.id), [
      'urgent',
      'unread',
      'read',
    ]);
  });
  test(
    'every existing decision option preserves effect ordering and meaning',
    () {
      final base = controllerSave().leagueState;
      final options = <String, int>{'accept': 2, 'decline': 3};

      for (final entry in options.entries) {
        final message = _decisionMessage(
          id: 'decision-${entry.key}',
          title: 'Decyzja ${entry.key}',
        );
        final league = base.copyWith(inbox: Inbox(messages: [message]));
        final effectTrace = <String>[];

        final resolved = MessageService().resolveDecision(
          league,
          message.id,
          entry.key,
          onDecision: (state, selected, optionId) {
            effectTrace.add(
              '${state.inbox.messages.single.acknowledged}:$optionId:${selected.id}',
            );
            return state.copyWith(currentDay: entry.value);
          },
        );

        expect(effectTrace, ['false:${entry.key}:${message.id}']);
        expect(resolved.currentDay, entry.value);
        expect(resolved.inbox.messages.single.read, isTrue);
        expect(resolved.inbox.messages.single.acknowledged, isTrue);
        expect(resolved.inbox.pendingUrgent, isEmpty);
      }
    },
  );

  test('seeded inbox ordering keeps urgent first and unread before read', () {
    for (final seed in [4103, 4104, 4105]) {
      final random = Random(seed);
      final messages = <GameMessage>[
        _message(
          id: 'seed-$seed-urgent',
          title: 'Seed urgent $seed',
          domain: MessageDomain.playerEvent,
          priority: MessagePriority.urgent,
          read: random.nextBool(),
        ),
        for (var index = 0; index < 6; index++)
          _message(
            id: 'seed-$seed-$index',
            title: 'Seed $seed $index',
            domain: MessageDomain.values[index % MessageDomain.values.length],
            read: index.isEven ? false : random.nextBool(),
          ),
      ];

      final sorted = sortInboxMessages(messages);
      expect(sorted, hasLength(messages.length));
      expect(
        sorted.map((message) => message.id),
        unorderedEquals(messages.map((message) => message.id)),
      );
      final firstNormal = sorted.indexWhere(
        (message) => message.priority != MessagePriority.urgent,
      );
      expect(firstNormal, greaterThanOrEqualTo(1));
      expect(
        sorted
            .take(firstNormal)
            .every((message) => message.priority == MessagePriority.urgent),
        isTrue,
      );
      final normalMessages = sorted.skip(firstNormal).toList();
      final firstReadNormal = normalMessages.indexWhere(
        (message) => message.read,
      );
      if (firstReadNormal >= 0) {
        expect(
          normalMessages.skip(firstReadNormal).every((message) => message.read),
          isTrue,
        );
      }
    }
  });
}

GameMessage _message({
  required String id,
  required String title,
  required MessageDomain domain,
  MessagePriority priority = MessagePriority.normal,
  bool read = false,
}) => GameMessage(
  id: id,
  type: MessageType.system,
  domain: domain,
  priority: priority,
  seasonYear: 2026,
  week: 1,
  titleKey: title,
  bodyKey: 'body',
  read: read,
);

GameMessage _decisionMessage({required String id, required String title}) =>
    _message(
      id: id,
      title: title,
      domain: MessageDomain.playerEvent,
      priority: MessagePriority.urgent,
    ).copyWith(
      decision: const DecisionSpec(
        options: [
          MessageAction(id: 'accept', labelKey: 'accept'),
          MessageAction(id: 'decline', labelKey: 'decline'),
        ],
        defaultOnExpiry: 'decline',
      ),
    );
