import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';

import 'support/game_fixtures.dart';

void main() {
  test('controller fixture is repeatable and has one player club', () {
    final first = controllerSave();
    expect(jsonEncode(controllerSave()), jsonEncode(first));
    expect(first.leagueState.teams, hasLength(1));
    expect(first.leagueState.playerTeam!.isPlayerControlled, isTrue);
    expect(first.leagueState.freeAgents.single.id, fixtureFreeAgentId);
  });

  test('FA II fixture starts active in week 48 with a future deadline', () {
    final league = phaseTwoNegotiation();
    final negotiation = league.negotiations.single;
    expect(league.currentWeek, 48);
    expect(negotiation.status, NegotiationStatus.active);
    expect(negotiation.expiryWeek, 48);
    expect(negotiation.expiryDay, greaterThan(league.currentDay));
  });

  test('rollover fixture has a one-year signing and all four populations', () {
    final league = beforeRollover();
    expect(league.currentWeek, 52);
    expect(league.currentDay, 7);
    expect(league.playerTeam!.roster.first.contract.yearsRemaining, 1);
    expect(
      league.playerTeam!.staff.canonicalMember(StaffRole.scout),
      isNotNull,
    );
    expect(league.staffFreeAgents.single.contract, isNull);
    expect(league.freeAgents.single.state.injury!.daysRemaining, 3);
  });

  test('last regular fixture has a manually supplied qualification result', () {
    final league = finalRegularSeasonDay();
    final match = league.currentSeason.schedule.single;
    final result = finalRegularSeasonResult(league);
    expect(league.currentWeek, 29);
    expect(league.currentDay, 7);
    expect(match.round, 58);
    expect(match.result, isNull);
    expect(result.homeTeamId, match.homeTeamId);
    expect(result.awayTeamId, match.awayTeamId);
    expect(result.homeGoals, 3);
    expect(result.awayGoals, 0);
    expect(league.currentSeason.standings, hasLength(2));
  });

  test(
    'fullbacks provide distinct identities and opposite natural positions',
    () {
      final players = fullBacks();
      expect(players.left.id, isNot(players.right.id));
      expect(players.left.position, Position.lb);
      expect(players.right.position, Position.rb);
    },
  );
}
