import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/simulation/match_bootstrap.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/discipline_service.dart';
import 'package:new_football/core/services/season_service.dart';

void main() {
  final league = SeedDataGenerator(
    random: null,
  ).generateLeague(year: 2026, seed: 101);

  MatchResult resultFor(
    Team team, {
    SeasonPhase phase = SeasonPhase.regular,
    List<MatchDiscipline> disciplines = const [],
  }) {
    final opponent = league.teams.firstWhere((item) => item.id != team.id);
    return MatchResult(
      homeTeamId: team.id,
      awayTeamId: opponent.id,
      homeGoals: 0,
      awayGoals: 0,
      homeStats: TeamMatchStats(teamId: team.id),
      awayStats: TeamMatchStats(teamId: opponent.id),
      disciplines: disciplines,
    );
  }

  Team apply(
    Team team,
    MatchResult result, {
    SeasonPhase phase = SeasonPhase.regular,
  }) => const DisciplineService()
      .applyToTeam(team: team, result: result, phase: phase)
      .team;

  test(
    'fifth regular-season yellow imposes one match and resets only regular counter',
    () {
      final team = league.teams.first;
      final player = team.roster.first.copyWith(
        state: team.roster.first.state.copyWith(
          regularSeasonYellowCards: 4,
          playoffYellowCards: 2,
        ),
      );
      final changed = team.copyWith(roster: [player, ...team.roster.skip(1)]);
      final result = resultFor(
        changed,
        disciplines: [
          MatchDiscipline(
            teamId: changed.id,
            playerId: player.id,
            yellowCardsInMatch: 1,
          ),
        ],
      );

      final after = apply(changed, result).roster.first;
      expect(after.state.regularSeasonYellowCards, 0);
      expect(after.state.playoffYellowCards, 2);
      expect(after.state.suspensionGamesRemaining, 1);
    },
  );

  test('playoff yellow threshold is independent and play-in uses it', () {
    final team = league.teams.first;
    final player = team.roster.first.copyWith(
      state: team.roster.first.state.copyWith(
        regularSeasonYellowCards: 4,
        playoffYellowCards: 2,
      ),
    );
    final changed = team.copyWith(roster: [player, ...team.roster.skip(1)]);
    final result = resultFor(
      changed,
      disciplines: [
        MatchDiscipline(
          teamId: changed.id,
          playerId: player.id,
          yellowCardsInMatch: 1,
        ),
      ],
    );

    final after = apply(
      changed,
      result,
      phase: SeasonPhase.playIn,
    ).roster.first;
    expect(after.state.playoffYellowCards, 0);
    expect(after.state.regularSeasonYellowCards, 4);
    expect(after.state.suspensionGamesRemaining, 1);
  });

  test('second yellow creates a one-match suspension', () {
    final team = league.teams.first;
    final player = team.roster.first;
    final result = resultFor(
      team,
      disciplines: [
        MatchDiscipline(
          teamId: team.id,
          playerId: player.id,
          yellowCardsInMatch: 2,
          redCardKind: RedCardKind.secondYellow,
        ),
      ],
    );

    final after = apply(team, result).roster.first;
    expect(after.state.suspensionGamesRemaining, 1);
  });

  test('direct red severity is weighted within one to three matches', () {
    final random = Random(2026);
    final values = <int>{
      for (var i = 0; i < 1000; i++)
        DisciplineService.rollDirectRedSeverity(random),
    };
    expect(values, containsAll(<int>[1, 2, 3]));

    final team = league.teams.first;
    final player = team.roster.first;
    final result = resultFor(
      team,
      disciplines: [
        MatchDiscipline(
          teamId: team.id,
          playerId: player.id,
          redCardKind: RedCardKind.direct,
          directRedSeverity: 3,
        ),
      ],
    );
    expect(apply(team, result).roster.first.state.suspensionGamesRemaining, 3);
  });

  test('suspended players are excluded from availability, XI and bench', () {
    final team = league.teams.first;
    final suspended = team.roster.first.copyWith(
      state: team.roster.first.state.copyWith(suspensionGamesRemaining: 2),
    );
    final ids = team.roster.take(11).map((player) => player.id).toList();
    final changed = team.copyWith(
      roster: [suspended, ...team.roster.skip(1)],
      lineupPlayerIds: ids,
      benchPlayerIds: [
        suspended.id,
        ...team.roster.skip(11).take(2).map((p) => p.id),
      ],
    );

    expect(changed.availablePlayers, isNot(contains(suspended)));
    expect(changed.startingEleven, isNot(contains(suspended)));
    final live = const MatchEngine().start(
      home: changed,
      away: team,
      rngSeed: 7,
    );
    expect(live.state.homeLineup, isNot(contains(suspended)));
    expect(live.state.homeBench, isNot(contains(suspended)));
  });

  test('suspension decrements only when the player team plays', () {
    final team = league.teams.first;
    final opponent = league.teams.firstWhere((item) => item.id != team.id);
    final suspended = team.roster.first.copyWith(
      state: team.roster.first.state.copyWith(suspensionGamesRemaining: 2),
    );
    final changed = team.copyWith(roster: [suspended, ...team.roster.skip(1)]);
    final result = resultFor(changed);
    final afterTeam = apply(changed, result).roster.first;
    final untouched = apply(
      opponent,
      result,
    ).roster.firstWhere((player) => player.id == opponent.roster.first.id);

    expect(afterTeam.state.suspensionGamesRemaining, 1);
    expect(untouched.state.suspensionGamesRemaining, 0);
  });

  test(
    'suspension start escalates for a starting player and end is emitted',
    () {
      final team = league.teams.first;
      final opponent = league.teams.firstWhere((item) => item.id != team.id);
      final player = team.roster.first;
      final startTeam = team.copyWith(
        lineupPlayerIds: [player.id],
        roster: [player, ...team.roster.skip(1)],
      );
      final startLeague = league.copyWith(
        teams: [startTeam, ...league.teams.where((item) => item.id != team.id)],
        playerTeamId: team.id,
      );
      final match = ScheduledMatch(
        id: 'discipline-start',
        homeTeamId: team.id,
        awayTeamId: opponent.id,
        round: 1,
      );
      final startResult = resultFor(
        startTeam,
        disciplines: [
          MatchDiscipline(
            teamId: team.id,
            playerId: player.id,
            redCardKind: RedCardKind.secondYellow,
            yellowCardsInMatch: 2,
            playerInStartingXi: true,
          ),
        ],
      );
      final suspended = DaySimulator().applyPlayerMatchResult(
        startLeague,
        match,
        startResult,
      );
      final startMessage = suspended.inbox.messages.firstWhere(
        (message) => message.type == MessageType.suspensionStart,
      );
      expect(startMessage.priority, MessagePriority.urgent);
      expect(startMessage.payload['playerId'], player.id);
      expect(startMessage.payload['games'], 1);

      final endTeam = suspended.teamById(team.id)!;
      final endResult = resultFor(endTeam);
      final endApplication = const DisciplineService().applyToTeam(
        team: endTeam.copyWith(
          roster: [
            endTeam.roster.first.copyWith(
              state: endTeam.roster.first.state.copyWith(
                suspensionGamesRemaining: 1,
              ),
            ),
            ...endTeam.roster.skip(1),
          ],
        ),
        result: endResult,
        phase: SeasonPhase.regular,
      );
      expect(endApplication.notifications.single.ended, isTrue);
    },
  );

  test('discipline and player state survive JSON round-trip', () {
    final state = PlayerState(
      regularSeasonYellowCards: 4,
      playoffYellowCards: 2,
      suspensionGamesRemaining: 3,
    );
    final discipline = const MatchDiscipline(
      teamId: 'team',
      playerId: 'player',
      yellowCardsInMatch: 2,
      redCardKind: RedCardKind.direct,
      directRedSeverity: 3,
      playerInStartingXi: true,
    );
    final decodedState = PlayerState.fromJson(
      jsonDecode(jsonEncode(state.toJson())) as Map<String, dynamic>,
    );
    final decodedDiscipline = MatchDiscipline.fromJson(
      jsonDecode(jsonEncode(discipline.toJson())) as Map<String, dynamic>,
    );

    expect(decodedState, state);
    expect(decodedDiscipline, discipline);
  });

  test('season rollover resets yellow counters but preserves suspension', () {
    final team = league.teams.first;
    final player = team.roster.first.copyWith(
      state: team.roster.first.state.copyWith(
        regularSeasonYellowCards: 4,
        playoffYellowCards: 2,
        suspensionGamesRemaining: 2,
      ),
    );
    final changed = league.copyWith(
      teams: [
        team.copyWith(roster: [player, ...team.roster.skip(1)]),
        ...league.teams.where((item) => item.id != team.id),
      ],
    );
    final rolled = SeasonService().rolloverSeason(changed);
    final after = rolled.teamById(team.id)!.roster.first;

    expect(after.state.regularSeasonYellowCards, 0);
    expect(after.state.playoffYellowCards, 0);
    expect(after.state.suspensionGamesRemaining, 2);
  });

  test('save schema is version ten', () {
    expect(SaveSchema.currentVersion, 17);
  });
}
