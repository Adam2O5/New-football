@Tags(['unit'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/team_event_service.dart';

import '../helpers/fixtures/game_fixtures.dart';

import '../helpers/fixtures/event_service_fixtures.dart';

void main() {
  test('team decision creates one promise and weekly tick settles it', () {
    final league = eventLeague();
    final team = league.teams.single;
    final player = team.roster.first;
    final service = TeamEventService(balance: eventBalance);
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
    expect(promise.durationWeeks, eventBalance.events.moreMinutesPromiseWeeks);
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
}
