@Tags(['unit'])
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';

import '../helpers/fixtures/presentation_fixtures.dart';

void main() {
  test('compact match keeps the result without transient player payloads', () {
    final player = presentationTeam().roster.first.copyWith(
      id: 'transient-player',
    );
    final full = MatchResult(
      homeTeamId: 'home',
      awayTeamId: 'away',
      homeGoals: 2,
      awayGoals: 2,
      homeStats: const TeamMatchStats(teamId: 'home', goals: 2),
      awayStats: const TeamMatchStats(teamId: 'away', goals: 2),
      homeLineup: [player],
      awayLineup: [player],
      homeSnapshot: MatchTeamSnapshot(startingXi: [player], bench: [player]),
      awaySnapshot: MatchTeamSnapshot(startingXi: [player], bench: [player]),
      playerStats: [PlayerMatchStats(playerId: player.id, minutes: 120)],
      events: [
        MatchEvent(
          type: MatchEventType.goal,
          minute: 10,
          teamId: 'home',
          playerId: player.id,
          description: 'transient-event',
        ),
      ],
      injuries: [
        MatchInjury(
          teamId: 'home',
          playerId: player.id,
          playerInStartingXi: true,
          injury: const Injury(
            id: 'transient-injury',
            group: InjuryGroup.legMuscles,
            type: InjuryType.minor,
            daysTotal: 2,
            daysRemaining: 2,
          ),
        ),
      ],
      disciplines: [
        MatchDiscipline(
          teamId: 'away',
          playerId: player.id,
          yellowCardsInMatch: 1,
        ),
      ],
      wentToExtraTime: true,
      wentToShootout: true,
      shootoutHomeGoals: 4,
      shootoutAwayGoals: 3,
      winnerTeamId: 'home',
      matchEndMinute: 120,
    );
    final compact = full.slimForStorage();
    final encoded = jsonEncode(compact.toJson());
    expect(encoded, isNot(contains('transient-')));
    expect(compact.homeGoals, 2);
    expect(compact.awayGoals, 2);
    expect(compact.homeTeamId, 'home');
    expect(compact.awayTeamId, 'away');
    expect(compact.wentToExtraTime, isTrue);
    expect(compact.wentToShootout, isTrue);
    expect(compact.shootoutHomeGoals, 4);
    expect(compact.shootoutAwayGoals, 3);
    expect(compact.winnerTeamId, 'home');
    expect(compact.matchEndMinute, 120);
    expect(compact.slimForStorage(), compact);
    expect(
      MatchResult.fromJson(jsonDecode(encoded) as Map<String, dynamic>),
      compact,
    );
    expect(utf8.encode(encoded).length, lessThan(4 * 1024));
    expect(
      utf8.encode(jsonEncode(full.toJson())).length,
      greaterThan(utf8.encode(encoded).length * 2),
    );
    expect(full.homeSnapshot.startingXi, [player]);
    expect(full.events.single.description, 'transient-event');
  });
}
