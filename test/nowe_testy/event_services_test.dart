import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/player_event_service.dart';
import 'package:new_football/core/services/team_event_service.dart';

import 'support/game_fixtures.dart';

const _balance = BalanceConfig(
  events: EventsBalance(
    minutesRequestChance: 0,
    minutesRequestAmbitiousChance: 0,
    transferRequestIChance: 0,
    transferRequestIIChanceAfterBrokenPromise: 0,
    lockerRoomConflictChance: 0,
    leaderSupportChance: 0,
    publicCriticismChance: 0,
    breakthroughChance: 0,
    coldStreakChance: 0,
    majorInjuryComplicationChance: 0,
    veteranMotivationChance: 0,
    extraTrainingChance: 0,
    personalProblemsChance: 0,
    professionalPersonalProblemsChance: 0,
    personalSupportChance: 0,
    lateBloomerChance: 0,
    recurringInjuryChance: 0,
    plateauWeeks: 1,
    plateauChance: 1,
    aiPlateauAcceptChance: 1,
  ),
);

LeagueState _league() {
  final league = controllerSave().leagueState;
  final team = league.teams.single;
  return league.updateTeam(
    team.copyWith(
      roster: team.roster.take(2).map((player) {
        return player.copyWith(
          state: player.state.copyWith(
            lastDevelopmentOvrDelta: 0,
            eventState: const PlayerEventState(),
          ),
        );
      }).toList(),
    ),
  );
}

void main() {
  test('team decision creates one promise and weekly tick settles it', () {
    final league = _league();
    final team = league.teams.single;
    final player = team.roster.first;
    final service = TeamEventService(balance: _balance);
    final message = GameMessage(
      id: 'minutes-decision',
      type: MessageType.teamEvent,
      kind: 'moreMinutesRequest',
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      titleKey: '',
      bodyKey: '',
      payload: {'teamId': team.id, 'playerId': player.id},
    );

    var accepted = service.resolveDecision(league, message, 'accept');
    accepted = service.resolveDecision(accepted, message, 'accept');
    final promisedTeam = accepted.teams.single;
    final promise = promisedTeam.eventState.promises.single;
    expect(promise.playerId, player.id);
    expect(promise.durationWeeks, _balance.events.moreMinutesPromiseWeeks);
    expect(
      promisedTeam.roster.first.state.eventState.modifiers.where(
        (modifier) => modifier.type == 'promiseMatchScoreBonus',
      ),
      hasLength(1),
    );

    final due = accepted.copyWith(
      currentWeek: league.currentWeek + promise.durationWeeks + 1,
      teams: [
        promisedTeam.copyWith(
          eventState: promisedTeam.eventState.copyWith(
            promises: [promise.copyWith(weeksElapsed: promise.durationWeeks)],
          ),
        ),
      ],
    );
    final settled = service.weeklyTick(due, saveSeed: fixtureSeed);
    expect(settled.teams.single.eventState.promises, isEmpty);
    expect(settled.teams.single.atmosphere, lessThan(promisedTeam.atmosphere));
    expect(
      settled.inbox.messages.where((item) => item.kind == 'promiseBroken'),
      hasLength(1),
    );
    final next = service.weeklyTick(settled, saveSeed: fixtureSeed);
    expect(next.teams.single.atmosphere, settled.teams.single.atmosphere);
    expect(next.inbox.messages, settled.inbox.messages);
  });

  test(
    'weekly player changes reach inbox and pending decisions deduplicate',
    () {
      final league = _league();
      final messages = _ObservedMessages();
      final service = PlayerEventService(balance: _balance, messages: messages);
      final result = service.weeklyTick(league, saveSeed: fixtureSeed);

      expect(result.inbox.messages, hasLength(2));
      expect(messages.inputs, hasLength(2));
      for (var index = 0; index < 2; index++) {
        final delivered = messages.inputs[index].teams.single.roster[index];
        expect(delivered.state.eventState.counterValue('plateauWeeks'), 1);
        expect(result.teams.single.roster[index], delivered);
      }
      final replay = PlayerEventService(
        balance: _balance,
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
        _balance.events.plateauGrowthRateBonus,
      );
    },
  );

  test(
    'failed weekly message releases roster map before another operation',
    () {
      final league = _league();
      final messages = _ObservedMessages()..failNext = true;
      final service = PlayerEventService(balance: _balance, messages: messages);
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
        balance: _balance,
      ).triggerNationalTeam(input, original.id);
      expect(calledUp.teams, expected.teams);
      expect(calledUp.teams.single.roster.first.state.stamina, 65);
      expect(calledUp.teams.single.roster.first.state.form, 5);

      final retried = service.weeklyTick(league, saveSeed: fixtureSeed);
      final fresh = PlayerEventService(
        balance: _balance,
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
    'AI player decision updates the shared roster without inbox messages',
    () {
      final league = _league().copyWith(playerTeamId: null);
      final result = PlayerEventService(
        balance: _balance,
      ).weeklyTick(league, saveSeed: fixtureSeed);
      expect(result.inbox.messages, isEmpty);
      for (final player in result.teams.single.roster) {
        expect(player.state.eventState.counterValue('plateauWeeks'), 0);
        expect(
          player.state.eventState.modifierValue('growthRate'),
          _balance.events.plateauGrowthRateBonus,
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
