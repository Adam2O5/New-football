import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/message_catalog.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/message_service.dart';

void main() {
  GameMessage message({
    required String id,
    MessageType type = MessageType.playerEvent,
    String? kind,
    MessagePriority priority = MessagePriority.normal,
    String? groupKey,
    String? dedupKey,
    Map<String, dynamic> payload = const {},
    List<MessageAction> actions = const [],
    DecisionSpec? decision,
    String? expiresAt,
    int seasonYear = 2026,
  }) {
    return GameMessage(
      id: id,
      type: type,
      kind: kind,
      domain: type == MessageType.ovrDigest
          ? MessageDomain.playerEvent
          : MessageDomain.system,
      priority: priority,
      seasonYear: seasonYear,
      week: 1,
      titleKey: 'title',
      bodyKey: 'body',
      groupKey: groupKey,
      dedupKey: dedupKey,
      payload: payload,
      actions: actions,
      decision: decision,
      expiresAt: expiresAt,
    );
  }

  test(
    'expired decision executes defaultOnExpiry and acknowledges message',
    () {
      final decision = DecisionSpec(
        options: [
          const MessageAction(id: 'accept', labelKey: 'accept'),
          const MessageAction(id: 'decline', labelKey: 'decline'),
        ],
        defaultOnExpiry: 'decline',
      );
      final league = GameFactory()
          .create(
            const NewGameRequest(
              saveName: 'Task 7',
              playerTeamId: 'team_europe_0',
              seed: 7,
            ),
          )
          .leagueState
          .copyWith(
            inbox: Inbox().addMessage(
              message(
                id: 'expired',
                kind: 'plateau',
                priority: MessagePriority.urgent,
                decision: decision,
                expiresAt: '2020-01-01T00:00:00Z',
              ),
            ),
          );
      String? selected;

      final resolved = MessageService().resolveExpiredDecisions(
        league,
        DateTime.utc(2026, 1, 1),
        onDecision: (state, _, optionId) {
          selected = optionId;
          return state;
        },
      );

      expect(selected, 'decline');
      expect(resolved.inbox.pendingUrgent, isEmpty);
      expect(resolved.inbox.messages.single.acknowledged, isTrue);
    },
  );

  test('three messages in one group become one digest', () {
    var inbox = const Inbox();
    for (var i = 0; i < 3; i++) {
      inbox = inbox.addMessage(message(id: 'ovr-$i', groupKey: 'ovr:own:1'));
    }

    expect(inbox.messages, hasLength(1));
    expect(inbox.messages.single.type, MessageType.ovrDigest);
    expect(inbox.messages.single.kind, 'digest');
    expect(inbox.messages.single.args['count'], 3);
    expect(inbox.archive, hasLength(3));
  });

  test('urgent messages never enter a digest', () {
    var inbox = const Inbox();
    for (var i = 0; i < 3; i++) {
      inbox = inbox.addMessage(
        message(
          id: 'urgent-$i',
          priority: MessagePriority.urgent,
          groupKey: 'trade:league:1',
        ),
      );
    }

    expect(inbox.messages, hasLength(3));
    expect(inbox.messages.where((item) => item.kind == 'digest'), isEmpty);
  });

  test('dedupKey blocks a duplicate injury', () {
    var inbox = const Inbox();
    for (var i = 0; i < 2; i++) {
      inbox = inbox.addMessage(
        message(
          id: 'injury-$i',
          type: MessageType.injury,
          dedupKey: 'injury:player-1:injury-1',
        ),
      );
    }

    expect(inbox.messages, hasLength(1));
  });

  test('muted type goes only to archive', () {
    final factoryLeague = GameFactory().create(
      const NewGameRequest(
        saveName: 'Task 7 muted',
        playerTeamId: 'team_europe_0',
        seed: 8,
      ),
    );
    final league = factoryLeague.leagueState.copyWith(
      messageSettings: const MessageSettings(
        overrides: {MessageType.matchResult: NotificationLevel.muted},
      ),
    );

    final result = MessageService().send(
      league,
      type: MessageType.matchResult,
      titleKey: 'msg_matchResult_title',
      bodyKey: 'msg_matchResult_body',
    );

    expect(result.inbox.messages, isEmpty);
    expect(result.inbox.archive, hasLength(1));
    expect(result.inbox.archive.single.priority, MessagePriority.silenced);
  });

  test('muting a decision type is rejected', () {
    expect(
      () => const MessageSettings().withTypeLevel(
        MessageType.playerEvent,
        NotificationLevel.muted,
      ),
      throwsArgumentError,
    );
  });

  test('domain setting is applied when a type has no override', () {
    final settings = const MessageSettings().withDomainLevel(
      MessageDomain.health,
      NotificationLevel.important,
    );

    expect(
      settings.levelFor(MessageType.injury, MessageDomain.health),
      NotificationLevel.important,
    );
  });

  test('inbox caps unread messages at fifty by auto-reading oldest first', () {
    var inbox = const Inbox();
    for (var i = 0; i < 51; i++) {
      inbox = inbox.addMessage(message(id: 'message-$i'));
    }

    expect(inbox.unread, hasLength(50));
    expect(inbox.messages.first.read, isTrue);
  });

  test('old messages move to unlimited archive after retention window', () {
    final inbox = Inbox(
      messages: [
        message(id: 'old', seasonYear: 2024),
        message(id: 'current', seasonYear: 2026),
      ],
    ).retainSeasons(2026);

    expect(inbox.messages.map((item) => item.id), ['current']);
    expect(inbox.archive.map((item) => item.id), ['old']);
  });

  test('missing payload reference removes actions and decision', () {
    final inbox = Inbox().addMessage(
      message(
        id: 'missing-player',
        payload: const {'playerId': 'deleted'},
        actions: [const MessageAction(id: 'open', labelKey: 'open')],
        decision: const DecisionSpec(
          options: [MessageAction(id: 'accept', labelKey: 'accept')],
          defaultOnExpiry: 'accept',
        ),
      ),
    );

    final degraded = inbox.degradeMissingPayload(playerIds: {'existing'});
    expect(degraded.messages.single.actions, isEmpty);
    expect(degraded.messages.single.decision, isNull);
  });

  test('ovrDigest catalog entry uses resolved discrepancy metadata', () {
    final template = MessageCatalog.resolve(MessageType.ovrDigest);

    expect(template.domain, MessageDomain.playerEvent);
    expect(template.defaultPriority, MessagePriority.silenced);
    expect(template.groupKey, 'ovr:own:{week}');
  });

  test('schema version is bumped for the serialized message model', () {
    expect(SaveSchema.currentVersion, 17);
  });
}
