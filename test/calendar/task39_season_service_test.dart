import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/season_awards.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/season_service.dart';

const _playerTeamId = 'team_europe_0';

LeagueState _newLeague({int seed = 3901}) {
  return GameFactory()
      .create(
        NewGameRequest(
          saveName: 'Task 39',
          playerTeamId: _playerTeamId,
          seasonYear: 2026,
          seed: seed,
        ),
      )
      .leagueState;
}

Player _pickUnique(
  List<Player> players,
  Set<String> used,
  bool Function(Player) predicate,
) {
  for (final player in players) {
    if (!used.contains(player.id) && predicate(player)) {
      used.add(player.id);
      return player;
    }
  }
  for (final player in players) {
    if (used.add(player.id)) return player;
  }
  throw StateError('The fixture does not contain enough lineup players');
}

class _AwardsFixture {
  const _AwardsFixture({
    required this.league,
    required this.mvp,
    required this.roty,
    required this.dpoy,
    required this.topScorer,
    required this.topAssist,
    required this.bestGk,
  });

  final LeagueState league;
  final Player mvp;
  final Player roty;
  final Player dpoy;
  final Player topScorer;
  final Player topAssist;
  final Player bestGk;
}

_AwardsFixture _awardsFixture() {
  final base = _newLeague(seed: 3902);
  final year = base.currentSeason.year;
  var home = base.teamById(_playerTeamId)!;
  final away = base.teams.firstWhere((team) => team.id != home.id);
  final initialLineup = home.startingEleven;
  if (initialLineup.length < 11 || away.startingEleven.length < 11) {
    throw StateError('GameFactory did not create complete fixture lineups');
  }

  final used = <String>{};
  final initialMvp = _pickUnique(
    initialLineup,
    used,
    (player) => player.position != Position.gk,
  );
  final initialRoty = _pickUnique(
    initialLineup,
    used,
    (player) => player.position != Position.gk,
  );
  final initialDpoy = _pickUnique(
    initialLineup,
    used,
    (player) =>
        player.position == Position.cb ||
        player.position == Position.lb ||
        player.position == Position.rb,
  );
  final initialTopScorer = _pickUnique(
    initialLineup,
    used,
    (player) => player.position == Position.st,
  );
  final initialTopAssist = _pickUnique(
    initialLineup,
    used,
    (player) => player.position != Position.gk,
  );
  final initialBestGk = _pickUnique(
    initialLineup,
    used,
    (player) => player.position == Position.gk,
  );

  home = home.copyWith(
    roster: [
      for (final player in home.roster)
        player.id == initialRoty.id
            ? player.copyWith(draftYear: year - 1)
            : player,
    ],
  );
  final playersById = {for (final player in home.roster) player.id: player};
  final mvp = playersById[initialMvp.id]!;
  final roty = playersById[initialRoty.id]!;
  final dpoy = playersById[initialDpoy.id]!;
  final topScorer = playersById[initialTopScorer.id]!;
  final topAssist = playersById[initialTopAssist.id]!;
  final bestGk = playersById[initialBestGk.id]!;
  final homeLineup = [
    for (final player in initialLineup) playersById[player.id]!,
  ];
  final awayLineup = away.startingEleven;

  PlayerMatchStats statsFor(Player player) {
    if (player.id == mvp.id) {
      return PlayerMatchStats(
        playerId: player.id,
        minutes: 90,
        goals: 3,
        assists: 4,
        shots: 8,
        shotsOnTarget: 6,
        rating: 9.8,
      );
    }
    if (player.id == roty.id) {
      return PlayerMatchStats(
        playerId: player.id,
        minutes: 90,
        assists: 1,
        shots: 3,
        shotsOnTarget: 2,
        rating: 8.4,
      );
    }
    if (player.id == dpoy.id) {
      return PlayerMatchStats(
        playerId: player.id,
        minutes: 90,
        tackles: 8,
        interceptions: 5,
        rating: 8.8,
      );
    }
    if (player.id == topScorer.id) {
      return PlayerMatchStats(
        playerId: player.id,
        minutes: 90,
        goals: 5,
        shots: 10,
        shotsOnTarget: 7,
        rating: 7.5,
      );
    }
    if (player.id == topAssist.id) {
      return PlayerMatchStats(
        playerId: player.id,
        minutes: 90,
        assists: 6,
        passes: 80,
        passAccuracy: 0.9,
        rating: 7.4,
      );
    }
    return PlayerMatchStats(
      playerId: bestGk.id,
      minutes: 90,
      saves: 8,
      shotsFaced: 8,
      rating: 8.7,
      cleanSheet: true,
    );
  }

  final results = List.generate(
    24,
    (index) => MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: 12,
      awayGoals: 0,
      homeStats: TeamMatchStats(teamId: home.id, goals: 12),
      awayStats: TeamMatchStats(teamId: away.id),
      homeLineup: homeLineup,
      awayLineup: awayLineup,
      homeLineupPositions: homeLineup.map((player) => player.position).toList(),
      awayLineupPositions: awayLineup.map((player) => player.position).toList(),
      playerStats: [
        statsFor(mvp),
        statsFor(roty),
        statsFor(dpoy),
        statsFor(topScorer),
        statsFor(topAssist),
        statsFor(bestGk),
      ],
      reasonCode: 'task39-awards-$index',
    ),
  );

  final schedule = [
    for (var index = 0; index < results.length; index++)
      ScheduledMatch(
        id: 'task39-award-match-$index',
        homeTeamId: home.id,
        awayTeamId: away.id,
        round: index + 1,
        result: results[index],
      ),
  ];
  final league = base.copyWith(
    teams: [for (final team in base.teams) team.id == home.id ? home : team],
    currentSeason: base.currentSeason.copyWith(
      schedule: schedule,
      championTeamId: home.id,
    ),
  );

  return _AwardsFixture(
    league: league,
    mvp: mvp,
    roty: roty,
    dpoy: dpoy,
    topScorer: topScorer,
    topAssist: topAssist,
    bestGk: bestGk,
  );
}

class _TiedAiMatchdayService extends AiMatchdayService {
  @override
  MatchResult simulateFullMatch({
    required Team home,
    required Team away,
    required MatchContext context,
    required int saveSeed,
    required int seasonYear,
    required int week,
    required String matchId,
    SeasonPhase phase = SeasonPhase.regular,
    List<Formation> homeOpponentFormationHistory = const [],
    List<Formation> awayOpponentFormationHistory = const [],
    Set<String> homeReturningAfterMajorInjury = const {},
    Set<String> awayReturningAfterMajorInjury = const {},
    bool? homeNextMatchWithinThreeDays,
    bool? awayNextMatchWithinThreeDays,
    bool? mathematicallyMeaningless,
    bool includeStoppageTime = false,
  }) {
    return MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: 0,
      awayGoals: 0,
      homeStats: TeamMatchStats(teamId: home.id),
      awayStats: TeamMatchStats(teamId: away.id),
    );
  }
}

Map<String, Standing> _standingsForOrder(List<Team> order) {
  return {
    for (var index = 0; index < order.length; index++)
      order[index].id: Standing(
        teamId: order[index].id,
        wins: 40 - index,
        losses: 18 + index,
      ),
  };
}

void main() {
  test(
    'runs the dated play-in and playoff bracket to one logical league final',
    () {
      const seed = 3901;
      final service = SeasonService();
      var state = _newLeague(
        seed: seed,
      ).copyWith(currentWeek: 31, currentDay: 3);

      state = service.advancePlayInForDate(
        state,
        week: 31,
        day: 3,
        saveSeed: seed,
      );
      expect(state.currentSeason.playInProgress, hasLength(2));
      expect(state.currentSeason.playInResults, isEmpty);

      state = state.copyWith(currentWeek: 31, currentDay: 6);
      state = service.advancePlayInForDate(
        state,
        week: 31,
        day: 6,
        saveSeed: seed,
      );
      expect(state.currentSeason.playInProgress, isEmpty);
      expect(state.currentSeason.playInResults, hasLength(2));

      state = service.setupPlayoffs(state);
      expect(state.currentSeason.playoffBrackets, hasLength(2));
      expect(
        state.currentSeason.playoffBrackets,
        everyElement(
          predicate<PlayoffBracket>(
            (bracket) => bracket.quarterFinals.length == 4,
          ),
        ),
      );

      for (
        var week = 32;
        week <= 43 && state.currentSeason.championTeamId == null;
        week++
      ) {
        for (final day in [3, 6]) {
          if (state.currentSeason.championTeamId != null) break;
          state = state.copyWith(currentWeek: week, currentDay: day);
          state = service.advancePlayoffsForDate(
            state,
            week: week,
            day: day,
            saveSeed: seed,
          );
        }
      }

      final champion = state.currentSeason.championTeamId;
      expect(champion, isNotNull);
      final leagueFinals = [
        for (final bracket in state.currentSeason.playoffBrackets)
          if (bracket.leagueFinal != null) bracket.leagueFinal!,
      ];
      expect(leagueFinals, hasLength(2));
      expect(leagueFinals.map((series) => series.id).toSet(), hasLength(1));
      expect(leagueFinals.first.winnerTeamId, champion);
      expect(leagueFinals.first.isComplete, isTrue);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'resolves tied dated knockout games through extra time and shootout',
    () {
      const seed = 3903;
      final service = SeasonService(
        aiMatchdayService: _TiedAiMatchdayService(),
      );
      var state = _newLeague(
        seed: seed,
      ).copyWith(currentWeek: 31, currentDay: 3);

      state = service.advancePlayInForDate(
        state,
        week: 31,
        day: 3,
        saveSeed: seed,
      );
      state = state.copyWith(currentWeek: 31, currentDay: 6);
      state = service.advancePlayInForDate(
        state,
        week: 31,
        day: 6,
        saveSeed: seed,
      );

      final games = [
        for (final result in state.currentSeason.playInResults) ...[
          result.game7v8,
          result.game9v10,
          result.gameFinal,
        ],
      ];
      expect(games, hasLength(6));
      expect(
        games,
        everyElement(
          predicate<MatchResult>(
            (result) => result.wentToExtraTime && result.winnerTeamId != null,
          ),
        ),
      );
      expect(games.any((result) => result.wentToShootout), isTrue);
      expect(games.where((result) => result.wentToShootout), isNotEmpty);
    },
  );

  test('computes award leaders from player stats and is idempotent', () {
    final fixture = _awardsFixture();
    final service = SeasonService();
    final first = service.runAwards(fixture.league);
    final awards = first.currentSeason.awards!;

    expect(awards.year, fixture.league.currentSeason.year);
    expect(awards.mvpPlayerId, fixture.mvp.id);
    expect(awards.rotyPlayerId, fixture.roty.id);
    expect(awards.dpoyPlayerId, fixture.dpoy.id);
    expect(awards.topScorerPlayerId, fixture.topScorer.id);
    expect(awards.topAssistPlayerId, fixture.topAssist.id);
    expect(awards.bestGkPlayerId, fixture.bestGk.id);
    expect(awards.playerNames[fixture.mvp.id], fixture.mvp.name);
    expect(awards.teamOfSeason, isNotEmpty);
    expect(awards.championTeamId, _playerTeamId);
    expect(
      first.inbox.messages.where(
        (message) => message.type == MessageType.award,
      ),
      isNotEmpty,
    );
    expect(
      first.inbox.messages.where(
        (message) => message.type == MessageType.seasonSummary,
      ),
      hasLength(1),
    );

    final repeated = service.runAwards(first);
    expect(repeated.currentSeason.awards, awards);
    expect(repeated.inbox.messages, first.inbox.messages);
    expect(repeated.inbox.archive, first.inbox.archive);
  });

  test('rollover preserves season history and increments team tenure', () {
    final base = _newLeague(seed: 3904);
    final playerTeam = base.teamById(_playerTeamId)!;
    final tracked = playerTeam.roster.firstWhere(
      (player) => player.contract.yearsRemaining >= 2,
    );
    final trackedBefore = tracked.copyWith(
      contract: tracked.contract.copyWith(yearsRemaining: 2),
      state: tracked.state.copyWith(seasonsWithTeam: 4),
    );
    final updatedPlayerTeam = playerTeam.copyWith(
      roster: [
        for (final player in playerTeam.roster)
          player.id == tracked.id ? trackedBefore : player,
      ],
    );
    final awards = SeasonAwards(
      year: base.currentSeason.year,
      mvpPlayerId: tracked.id,
      playerNames: {tracked.id: tracked.name},
      championTeamId: playerTeam.id,
    );
    final state = base.copyWith(
      teams: [
        for (final team in base.teams)
          team.id == updatedPlayerTeam.id ? updatedPlayerTeam : team,
      ],
      currentSeason: base.currentSeason.copyWith(
        championTeamId: playerTeam.id,
        awards: awards,
        playoffMissAtmosphereApplied: true,
      ),
    );

    final rolled = SeasonService().rolloverSeason(state, saveSeed: 3904);
    expect(rolled.currentSeason.year, state.currentSeason.year + 1);
    expect(rolled.history, hasLength(1));
    final history = rolled.history.single;
    expect(history.year, state.currentSeason.year);
    expect(history.finalStandings, state.currentSeason.standings);
    expect(history.championTeamId, playerTeam.id);
    expect(history.awards, awards);

    final trackedAfter = rolled
        .teamById(playerTeam.id)!
        .roster
        .firstWhere((player) => player.id == tracked.id);
    expect(trackedAfter.state.seasonsWithTeam, 5);
    expect(trackedAfter.contract.yearsRemaining, 1);
  });

  test('Coach of the Year uses the best place versus preseason seed', () {
    final base = _newLeague(seed: 3905);
    final candidate = base.teams[0];
    final challenger = base.teams[1];
    final staffGenerator = SeedDataGenerator();
    final candidateCoach = staffGenerator
        .generateStaffMember(Random(3905), StaffRole.headCoach)
        .copyWith(id: 'task39-candidate-coach');
    final challengerCoach = staffGenerator
        .generateStaffMember(Random(3906), StaffRole.headCoach)
        .copyWith(id: 'task39-challenger-coach');

    final teams = [
      for (final team in base.teams)
        team.copyWith(
          staff: team.staff.withMember(
            StaffRole.headCoach,
            team.id == candidate.id
                ? candidateCoach
                : team.id == challenger.id
                ? challengerCoach
                : null,
          ),
        ),
    ];
    final orderedTeams = [
      teams.firstWhere((team) => team.id == candidate.id),
      teams.firstWhere((team) => team.id == challenger.id),
      ...teams.where(
        (team) => team.id != candidate.id && team.id != challenger.id,
      ),
    ];
    final standingsByTeam = _standingsForOrder(orderedTeams);
    final standings = [
      for (final conference in Conference.values)
        ConferenceStandings(
          conference: conference,
          standings: [
            for (final team in orderedTeams)
              if (team.conference == conference) standingsByTeam[team.id]!,
          ],
        ),
    ];
    final strengthTable = LeagueStrengthTable(
      entries: [
        for (var index = 0; index < orderedTeams.length; index++)
          TeamStrengthEntry(
            teamId: orderedTeams[index].id,
            teamPower: (100 - index).toDouble(),
            expectedRank: orderedTeams[index].id == candidate.id
                ? 30
                : orderedTeams[index].id == challenger.id
                ? 1
                : index + 1,
            teamStatus: TeamStatus.pretender,
          ),
      ],
      lastCalculatedWeek: 44,
      seasonYear: base.currentSeason.year,
    );
    final league = base.copyWith(
      teams: teams,
      strengthTable: strengthTable,
      currentSeason: base.currentSeason.copyWith(
        standings: standings,
        championTeamId: candidate.id,
      ),
    );

    final result = SeasonService().runAwards(league);
    expect(result.currentSeason.awards?.coachOfYearTeamId, candidate.id);
    expect(
      result.currentSeason.awards?.coachOfYearTeamId,
      isNot(challenger.id),
    );
  });
}
