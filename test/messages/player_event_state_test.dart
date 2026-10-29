@Tags(['unit'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/player_event_service.dart';

import '../helpers/fixtures/game_fixtures.dart';

import '../helpers/fixtures/event_service_fixtures.dart';

void main() {
  test(
    'weekly player changes reach inbox and pending decisions deduplicate',
    () {
      final league = eventLeague();
      final messages = _ObservedMessages();
      final service = PlayerEventService(
        balance: eventBalance,
        messages: messages,
      );
      final result = service.weeklyTick(league, saveSeed: fixtureSeed);

      expect(result.inbox.messages, hasLength(2));
      expect(messages.inputs, hasLength(2));
      for (var index = 0; index < 2; index++) {
        final delivered = messages.inputs[index].teams.single.roster[index];
        expect(delivered.state.eventState.counterValue('plateauWeeks'), 1);
        expect(result.teams.single.roster[index], delivered);
      }
      final replay = PlayerEventService(
        balance: eventBalance,
      ).weeklyTick(league, saveSeed: fixtureSeed);
      expect(result.teams, replay.teams);
      expect(
        result.inbox.messages.map(
          (message) => message.copyWith(id: 'normalized'),
        ),
        replay.inbox.messages.map(
          (message) => message.copyWith(id: 'normalized'),
        ),
      );
      final pending = service.weeklyTick(result, saveSeed: fixtureSeed);
      expect(messages.inputs, hasLength(2));
      expect(pending.inbox.messages, result.inbox.messages);

      final resolved = service.resolveDecision(
        pending,
        pending.inbox.messages.first,
        'accept',
      );
      final id = pending.inbox.messages.first.payload['playerId'];
      final player = resolved.teams.single.roster.firstWhere((p) => p.id == id);
      expect(player.state.eventState.counterValue('plateauWeeks'), 0);
      expect(
        player.state.eventState.modifierValue('growthRate'),
        eventBalance.events.plateauGrowthRateBonus,
      );
    },
  );

  test(
    'failed weekly message releases roster map before another operation',
    () {
      final league = eventLeague();
      final messages = _ObservedMessages()..failNext = true;
      final service = PlayerEventService(
        balance: eventBalance,
        messages: messages,
      );
      expect(
        () => service.weeklyTick(league, saveSeed: fixtureSeed),
        throwsStateError,
      );
      // A different input with the same IDs must win over the aborted tick.
      final team = league.teams.single;
      final original = team.roster.first;
      final input = league.updateTeam(
        team.copyWith(
          roster: [
            original.copyWith(
              state: original.state.copyWith(stamina: 80, form: 4),
            ),
            team.roster.last,
          ],
        ),
      );
      final calledUp = service.triggerNationalTeam(input, original.id);
      final expected = PlayerEventService(
        balance: eventBalance,
      ).triggerNationalTeam(input, original.id);
      expect(calledUp.teams, expected.teams);
      expect(calledUp.teams.single.roster.first.state.stamina, 65);
      expect(calledUp.teams.single.roster.first.state.form, 5);

      final retried = service.weeklyTick(league, saveSeed: fixtureSeed);
      final fresh = PlayerEventService(
        balance: eventBalance,
      ).weeklyTick(league, saveSeed: fixtureSeed);
      expect(retried.teams, fresh.teams);
      expect(
        retried.inbox.messages.map(
          (message) => message.copyWith(id: 'normalized'),
        ),
        fresh.inbox.messages.map(
          (message) => message.copyWith(id: 'normalized'),
        ),
      );
    },
  );

  test(
    'non-player event resolution updates the shared roster without inbox messages',
    () {
      final league = eventLeague().copyWith(playerTeamId: null);
      final result = PlayerEventService(
        balance: eventBalance,
      ).weeklyTick(league, saveSeed: fixtureSeed);
      expect(result.inbox.messages, isEmpty);
      for (final player in result.teams.single.roster) {
        expect(player.state.eventState.counterValue('plateauWeeks'), 0);
        expect(
          player.state.eventState.modifierValue('growthRate'),
          eventBalance.events.plateauGrowthRateBonus,
        );
      }
    },
  );
}

class _ObservedMessages extends MessageService {
  final inputs = <LeagueState>[];
  bool failNext = false;

  @override
  LeagueState send(
    LeagueState league, {
    required MessageType type,
    String? kind,
    MessageDomain? domain,
    MessagePriority priority = MessagePriority.normal,
    String? titleKey,
    String? bodyKey,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
    List<MessageAction> actions = const [],
    DecisionSpec? decision,
    String? expiresAt,
    String? groupKey,
    String? dedupKey,
    int? hour,
    int? deliveryWeek,
    int? deliveryDay,
    int? deliveryHour,
  }) {
    inputs.add(league);
    if (failNext) {
      failNext = false;
      throw StateError('Injected event message failure');
    }
    return super.send(
      league,
      type: type,
      kind: kind,
      domain: domain,
      priority: priority,
      titleKey: titleKey,
      bodyKey: bodyKey,
      args: args,
      payload: payload,
      actions: actions,
      decision: decision,
      expiresAt: expiresAt,
      groupKey: groupKey,
      dedupKey: dedupKey,
      hour: hour,
      deliveryWeek: deliveryWeek,
      deliveryDay: deliveryDay,
      deliveryHour: deliveryHour,
    );
  }
}
