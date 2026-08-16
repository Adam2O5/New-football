import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/development.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/message_service.dart';

void main() {
  final developmentBalance = BalanceConfig.defaults.development;

  Player fixture({
    int age = 20,
    int determination = 5,
    double progress = 50.0,
    double ceilingStars = 5.0,
    int minutes = 0,
    double form = 6.0,
  }) {
    final source = SeedDataGenerator(random: null)
        .generateLeague(year: 2026, seed: 1313)
        .teams
        .first
        .roster
        .firstWhere((player) => player.position != Position.gk);
    return source.copyWith(
      age: age,
      attributes: const PlayerAttributes.outfield(
        stats: FieldPlayerAttributes(
          pace: 70,
          shooting: 70,
          passing: 70,
          dribbling: 70,
          defending: 70,
          physicality: 70,
        ),
      ),
      hidden: source.hidden.copyWith(
        determination: determination,
        overallProgress: progress,
        developmentCeilingStars: ceilingStars,
      ),
      state: source.state.copyWith(
        form: form,
        minutesThisWeek: minutes,
        injury: null,
      ),
    );
  }

  List<int> sixAttributes(Player player) => player.attributes.map(
    outfield: (value) => [
      value.stats.pace,
      value.stats.shooting,
      value.stats.passing,
      value.stats.dribbling,
      value.stats.defending,
      value.stats.physicality,
    ],
    goalkeeper: (value) => [
      value.stats.diving,
      value.stats.handling,
      value.stats.kicking,
      value.stats.reflexes,
      value.stats.speed,
      value.stats.positioning,
    ],
  );

  test('determination and age balance tables match the specification', () {
    expect(developmentBalance.determinationGrowthRates, [
      0.50,
      0.65,
      0.80,
      0.90,
      1.00,
      1.10,
      1.20,
      1.30,
      1.40,
      1.50,
    ]);
    expect(developmentBalance.outcomeChancesFor(1), (1, 20));
    expect(developmentBalance.outcomeChancesFor(10), (30, 65));
    expect(developmentBalance.ageBonusFor(18), 0.40);
    expect(developmentBalance.ageBonusFor(31), 0.00);
    expect(developmentBalance.ageBonusFor(35), -1.75);
    expect(developmentBalance.ageBonusFor(40), -3.00);
    expect(developmentBalance.ageBonusFor(45), -3.00);
  });

  test('young players with full minutes develop faster than older players', () {
    final service = DevelopmentService();
    final young = fixture(age: 18, determination: 9, minutes: 90);
    final older = fixture(age: 30, determination: 9, minutes: 90);

    expect(
      service.calculateGrowthRate(young, atmosphere: 50),
      greaterThan(service.calculateGrowthRate(older, atmosphere: 50)),
    );
    expect(
      service.calculateGrowthRate(
        fixture(age: 35, determination: 1),
        atmosphere: 50,
      ),
      lessThan(0),
    );
  });

  test('weekly progress applies all six attributes and loses overflow', () {
    final player = fixture(age: 18, determination: 10, progress: 98.0);
    final result = DevelopmentService().developPlayer(player);
    final before = sixAttributes(player);
    final after = sixAttributes(result);

    expect(result.state.lastDevelopmentOvrDelta, 1);
    expect(result.hidden.overallProgress, 0.0);
    expect(result.pointValue, result.computePointValue());
    expect(after, before.map((value) => value + 1).toList());

    final second = DevelopmentService().developPlayer(
      result.copyWith(hidden: result.hidden.copyWith(overallProgress: 98.0)),
    );
    expect(second.state.lastDevelopmentOvrDelta, 1);
    expect(second.hidden.overallProgress, 0.0);
    expect(sixAttributes(second), after.map((value) => value + 1).toList());
  });

  test('negative progress decreases all six attributes and wraps to 99%', () {
    final player = fixture(age: 40, determination: 1, progress: 1.0);
    final result = DevelopmentService().developPlayer(player);

    expect(result.hidden.overallProgress, 99.0);
    expect(result.state.lastDevelopmentOvrDelta, -1);
    expect(
      sixAttributes(result),
      sixAttributes(player).map((v) => v - 1).toList(),
    );
  });

  test('injury blocks only positive growth', () {
    final injury = playerInjury();
    final service = DevelopmentService();
    final positive = fixture(age: 18, determination: 10, progress: 50.0);
    final positiveWithInjury = positive.copyWith(
      state: positive.state.copyWith(injury: injury),
    );
    final positiveResult = service.developPlayer(positiveWithInjury);
    expect(
      positiveResult.hidden.overallProgress,
      positiveWithInjury.hidden.overallProgress,
    );
    expect(sixAttributes(positiveResult), sixAttributes(positiveWithInjury));

    final negative = fixture(age: 40, determination: 1, progress: 1.0);
    final negativeWithInjury = negative.copyWith(
      state: negative.state.copyWith(injury: injury),
    );
    final negativeResult = service.developPlayer(negativeWithInjury);
    expect(negativeResult.state.lastDevelopmentOvrDelta, -1);
  });

  test(
    'development outcome rolls follow the table and ceiling remains stable',
    () {
      final random = Random(13);
      var exceed = 0;
      var hit = 0;
      var under = 0;
      for (var i = 0; i < 20000; i++) {
        switch (rollDevelopmentOutcome(5, random)) {
          case DevelopmentOutcome.exceed:
            exceed++;
          case DevelopmentOutcome.hit:
            hit++;
          case DevelopmentOutcome.under:
            under++;
        }
      }
      expect(exceed / 20000, closeTo(0.10, 0.015));
      expect(hit / 20000, closeTo(0.50, 0.02));
      expect(under / 20000, closeTo(0.40, 0.02));

      final player = fixture();
      final service = DevelopmentService();
      final first = service.developPlayer(player);
      final second = service.developPlayer(first);
      expect(
        first.hidden.developmentCeilingStars,
        player.hidden.developmentCeilingStars,
      );
      expect(
        second.hidden.developmentCeilingStars,
        first.hidden.developmentCeilingStars,
      );
    },
  );

  test('Player JSON preserves fractional progress and Task 13 state', () {
    final player = fixture(progress: 42.75, minutes: 67).copyWith(
      state: fixture(progress: 42.75).state.copyWith(
        minutesThisWeek: 67,
        lastDevelopmentOvrDelta: -1,
        lastDevelopmentProgressDelta: -4.125,
      ),
    );
    final restored = Player.fromJson(
      jsonDecode(jsonEncode(player.toJson())) as Map<String, dynamic>,
    );

    expect(restored.hidden.overallProgress, 42.75);
    expect(
      restored.hidden.developmentCeilingStars,
      player.hidden.developmentCeilingStars,
    );
    expect(restored.state.minutesThisWeek, 67);
    expect(restored.state.lastDevelopmentOvrDelta, -1);
    expect(restored.state.lastDevelopmentProgressDelta, -4.125);
  });

  test('match minutes accumulate and weekly development resets them', () {
    final league = SeedDataGenerator(
      random: null,
    ).generateLeague(year: 2026, seed: 1314);
    final home = league.teams.first;
    final away = league.teams[1];
    final selected = home.roster.first;
    final match = ScheduledMatch(
      id: 'task13-minutes',
      homeTeamId: home.id,
      awayTeamId: away.id,
      round: 1,
    );
    final state = league.copyWith(
      teams: league.teams
          .map((team) => team.id == home.id ? home : team)
          .toList(),
      currentSeason: league.currentSeason.copyWith(schedule: [match]),
    );
    final result = MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: 1,
      awayGoals: 0,
      homeStats: TeamMatchStats(teamId: home.id),
      awayStats: TeamMatchStats(teamId: away.id),
      playerStats: [
        PlayerMatchStats(playerId: selected.id, minutes: 67, rating: 6.0),
      ],
    );

    final afterMatch = DaySimulator().applyPlayerMatchResult(
      state,
      match,
      result,
    );
    final afterMatchPlayer = afterMatch
        .teamById(home.id)!
        .roster
        .firstWhere((player) => player.id == selected.id);
    expect(afterMatchPlayer.state.minutesThisWeek, 67);

    final afterTick = DevelopmentService().developTeam(
      afterMatch.teamById(home.id)!,
    );
    expect(
      afterTick.roster
          .firstWhere((player) => player.id == selected.id)
          .state
          .minutesThisWeek,
      0,
    );
  });

  test('three own-club OVR messages compact into an OVR digest', () {
    final league = SeedDataGenerator(
      random: null,
    ).generateLeague(year: 2026, seed: 1315);
    final messages = MessageService();
    var state = league;
    for (var i = 0; i < 3; i++) {
      state = messages.send(
        state,
        type: MessageType.playerEvent,
        kind: 'ovrChange',
        titleKey: 'msg_ovrDigest_title',
        bodyKey: 'msg_ovrDigest_body',
        args: {'playerName': 'Player $i', 'delta': 1},
        payload: {'playerId': league.teams.first.roster[i].id, 'ovrDelta': 1},
        groupKey: 'ovr:own:7',
      );
    }

    expect(state.inbox.messages, hasLength(1));
    final digest = state.inbox.messages.single;
    expect(digest.type, MessageType.ovrDigest);
    expect(digest.kind, 'digest');
    expect(digest.args['count'], 3);
    expect(digest.groupKey, 'ovr:own:7');
    expect(digest.payload['messageIds'], hasLength(3));
  });
}

Injury playerInjury() => const Injury(
  id: 'task13-injury',
  group: InjuryGroup.anklesFeet,
  type: InjuryType.minor,
  daysTotal: 10,
  daysRemaining: 10,
);
