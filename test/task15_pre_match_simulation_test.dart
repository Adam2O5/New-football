import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/simulation/match_bootstrap.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/simulation/match_context_factory.dart';
import 'package:new_football/core/simulation/match_message_emitter.dart';
import 'package:new_football/core/simulation/pre_match_validator.dart';
import 'package:new_football/core/services/team_management_service.dart';

void main() {
  final baseLeague = SeedDataGenerator().generateLeague(year: 2026, seed: 42);
  final baseHome = baseLeague.teams[0];
  final baseAway = baseLeague.teams[1];
  const validator = PreMatchValidator();
  const engine = MatchEngine();

  Team teamWithRoster(
    Team source, {
    required int size,
    bool goalkeeperInXi = true,
  }) {
    final sourceGoalkeeper = source.roster.firstWhere(
      (player) => player.position == Position.gk,
    );
    final outfield = source.roster
        .where((player) => player.position != Position.gk)
        .toList();
    final roster = size <= source.roster.length
        ? <Player>[sourceGoalkeeper, ...outfield.take(size - 1)]
        : <Player>[
            ...source.roster,
            for (var i = source.roster.length; i < size; i++)
              source.roster[i % source.roster.length].copyWith(
                id: '${source.id}_extra_$i',
              ),
          ];

    final xi = <Player>[];
    if (goalkeeperInXi)
      xi.add(roster.firstWhere((p) => p.position == Position.gk));
    xi.addAll(
      roster
          .where((player) => player.position != Position.gk)
          .take(11 - xi.length),
    );
    final xiIds = xi.map((player) => player.id).toSet();
    final benchIds = roster
        .where((player) => !xiIds.contains(player.id))
        .take(7)
        .map((player) => player.id)
        .toList();

    return source.copyWith(
      roster: roster,
      lineupPlayerIds: xi.map((player) => player.id).toList(),
      benchPlayerIds: benchIds,
    );
  }

  Team teamWithBench(Team source, int benchCount) {
    final team = teamWithRoster(source, size: 20);
    final xiIds = team.lineupPlayerIds.toSet();
    final availableBenchIds = team.roster
        .where((player) => !xiIds.contains(player.id))
        .map((player) => player.id)
        .toList();
    final benchIds = benchCount == 0
        ? const ['missing-bench-player']
        : availableBenchIds.take(benchCount).toList();
    return team.copyWith(benchPlayerIds: benchIds);
  }

  Team teamWithAvailablePlayers(Team source, int availableCount) {
    final legal = teamWithRoster(source, size: 20);
    final roster = legal.roster.asMap().entries.map((entry) {
      if (entry.key < availableCount) return entry.value;
      return entry.value.copyWith(
        state: entry.value.state.copyWith(
          injury: const Injury(
            id: 'task15-unavailable',
            group: InjuryGroup.headFace,
            type: InjuryType.minor,
            daysTotal: 5,
            daysRemaining: 5,
          ),
        ),
      );
    }).toList();
    return legal.copyWith(
      roster: roster,
      lineupPlayerIds: roster.take(11).map((player) => player.id).toList(),
      benchPlayerIds: const [],
    );
  }

  ScheduledMatch fixture(String id, Team home, Team away, {int round = 1}) =>
      ScheduledMatch(
        id: id,
        homeTeamId: home.id,
        awayTeamId: away.id,
        round: round,
      );

  LeagueState leagueWithFixture(Team home, Team away, ScheduledMatch match) {
    final updatedTeams = baseLeague.updateTeam(home).updateTeam(away);
    return updatedTeams.copyWith(
      currentSeason: updatedTeams.currentSeason.copyWith(schedule: [match]),
    );
  }

  group('Task 15 — walidacja pre-match', () {
    test('roster 19 i 31 kończą się walkowerem 0:3', () {
      final smallHome = teamWithRoster(baseHome, size: 19);
      final largeAway = teamWithRoster(baseAway, size: 31);

      final smallReport = validator.validate(
        home: smallHome,
        away: teamWithRoster(baseAway, size: 25),
      );
      final largeReport = validator.validate(
        home: teamWithRoster(baseHome, size: 25),
        away: largeAway,
      );
      final smallResult = engine.simulateFull(
        home: smallHome,
        away: teamWithRoster(baseAway, size: 25),
        rngSeed: 11,
      );
      final largeResult = engine.simulateFull(
        home: teamWithRoster(baseHome, size: 25),
        away: largeAway,
        rngSeed: 12,
      );

      expect(smallReport.status, MatchStatus.walkover);
      expect(largeReport.status, MatchStatus.walkover);
      expect(smallResult.homeGoals, 0);
      expect(smallResult.awayGoals, 3);
      expect(largeResult.homeGoals, 3);
      expect(largeResult.awayGoals, 0);
      expect(smallResult.events, isEmpty);
      expect(largeResult.events, isEmpty);
    });

    test('obie nielegalne strony dają DSQ 0:0 bez punktów', () {
      final home = teamWithRoster(baseHome, size: 19);
      final away = teamWithRoster(baseAway, size: 31);
      final report = validator.validate(home: home, away: away);
      final result = engine.simulateFull(home: home, away: away, rngSeed: 13);

      expect(report.status, MatchStatus.dsq);
      expect(report.violatingTeamIds, {home.id, away.id});
      expect(result.status, MatchStatus.dsq);
      expect(result.homeGoals, 0);
      expect(result.awayGoals, 0);
      expect(result.events, isEmpty);
      expect(result.playerStats, isEmpty);
      expect(result.isWalkover, isTrue);
    });

    test('mniej niż 11 dostępnych zawodników daje walkower', () {
      final home = teamWithAvailablePlayers(baseHome, 10);
      final away = teamWithRoster(baseAway, size: 25);
      final report = validator.validate(home: home, away: away);

      expect(report.home.availablePlayerCount, 10);
      expect(
        report.home.reasonCode,
        PreMatchReasonCode.insufficientAvailablePlayers,
      );
      expect(report.status, MatchStatus.walkover);
      expect(report.violatingTeamIds, [home.id]);
    });

    test('duplikat zawodnika w XI jest twardym naruszeniem', () {
      final legal = teamWithRoster(baseHome, size: 25);
      final xi = legal.startingEleven;
      final duplicate = legal.copyWith(
        lineupPlayerIds: [
          ...xi.take(10).map((player) => player.id),
          xi.first.id,
        ],
      );
      final report = validator.validate(
        home: duplicate,
        away: teamWithRoster(baseAway, size: 25),
      );

      expect(report.home.hasDuplicateStartingPlayer, isTrue);
      expect(
        report.home.reasonCode,
        PreMatchReasonCode.duplicateStartingPlayer,
      );
      expect(report.status, MatchStatus.walkover);
      expect(report.violatingTeamIds, [duplicate.id]);
    });

    test('brak GK pozostawia mecz grywalny z karą i statystykami', () {
      final noGoalkeeper = teamWithRoster(
        baseHome,
        size: 25,
        goalkeeperInXi: false,
      );
      final opponent = teamWithRoster(baseAway, size: 25);
      final report = validator.validate(home: noGoalkeeper, away: opponent);
      final result = engine.simulateFull(
        home: noGoalkeeper,
        away: opponent,
        rngSeed: 14,
      );

      expect(report.status, MatchStatus.played);
      expect(report.noGkPenaltyTeamIds, [noGoalkeeper.id]);
      expect(result.status, MatchStatus.played);
      expect(result.noGkPenalty, isTrue);
      expect(result.noGkPenaltyTeamIds, [noGoalkeeper.id]);
      expect(result.events, isNotEmpty);
      expect(
        result.events,
        contains(
          predicate<MatchEvent>(
            (event) => event.type == MatchEventType.fullTime,
          ),
        ),
      );
      expect(result.playerStats, isNotEmpty);
      expect(
        result.playerStats.where((stats) => stats.minutes == 90),
        isNotEmpty,
      );
    });

    test('ławka 0–6 nie blokuje meczu, a ławka ponad 7 jest przycinana', () {
      for (final count in [0, 6]) {
        final home = teamWithBench(baseHome, count);
        final report = validator.validate(
          home: home,
          away: teamWithRoster(baseAway, size: 25),
        );
        expect(report.status, MatchStatus.played);
        expect(report.home.benchCount, count);
        expect(report.incompleteBenchTeamIds, [home.id]);
      }

      final oversized = teamWithBench(baseHome, 8);
      final report = validator.validate(
        home: oversized,
        away: teamWithRoster(baseAway, size: 25),
      );
      expect(report.status, MatchStatus.played);
      expect(report.home.benchCount, 7);
      expect(report.home.benchWasTrimmed, isTrue);
      expect(report.incompleteBenchTeamIds, isEmpty);
    });
  });

  group('Task 15 — skutki administracyjne', () {
    test(
      'DSQ nie zmienia punktów, statystyk indywidualnych ani stanu zawodników',
      () {
        final home = teamWithRoster(baseHome, size: 19);
        final away = teamWithRoster(baseAway, size: 31);
        final match = fixture('task15-dsq', home, away);
        final league = leagueWithFixture(home, away, match);
        final beforeHome = league.teamById(home.id)!;
        final beforeAway = league.teamById(away.id)!;
        final beforeHomeStanding = league.currentSeason.standings
            .firstWhere((group) => group.conference == home.conference)
            .standings
            .firstWhere((standing) => standing.teamId == home.id);
        final beforeAwayStanding = league.currentSeason.standings
            .firstWhere((group) => group.conference == away.conference)
            .standings
            .firstWhere((standing) => standing.teamId == away.id);
        final result = engine.simulateFull(home: home, away: away, rngSeed: 15);
        final updated = DaySimulator().applyPlayerMatchResult(
          league,
          match,
          result,
        );
        final afterHome = updated.teamById(home.id)!;
        final afterAway = updated.teamById(away.id)!;
        final afterHomeStanding = updated.currentSeason.standings
            .firstWhere((group) => group.conference == home.conference)
            .standings
            .firstWhere((standing) => standing.teamId == home.id);
        final afterAwayStanding = updated.currentSeason.standings
            .firstWhere((group) => group.conference == away.conference)
            .standings
            .firstWhere((standing) => standing.teamId == away.id);

        expect(result.playerStats, isEmpty);
        expect(result.events, isEmpty);
        expect(result.injuries, isEmpty);
        expect(result.disciplines, isEmpty);
        expect(afterHome.atmosphere, beforeHome.atmosphere - 15);
        expect(afterAway.atmosphere, beforeAway.atmosphere - 15);
        expect(afterHomeStanding.points, beforeHomeStanding.points);
        expect(afterAwayStanding.points, beforeAwayStanding.points);
        expect(afterHomeStanding.gamesPlayed, beforeHomeStanding.gamesPlayed);
        expect(afterAwayStanding.gamesPlayed, beforeAwayStanding.gamesPlayed);
        for (final player in beforeHome.roster) {
          expect(
            afterHome.roster
                .firstWhere((candidate) => candidate.id == player.id)
                .state,
            player.state,
          );
        }
        for (final player in beforeAway.roster) {
          expect(
            afterAway.roster
                .firstWhere((candidate) => candidate.id == player.id)
                .state,
            player.state,
          );
        }
      },
    );
  });

  group('Task 15 — MatchContext i snapshoty', () {
    final factory = MatchContextFactory();
    final regularHome = teamWithRoster(baseHome, size: 25);
    final regularAway = teamWithRoster(baseAway, size: 25);

    test('kontekst jest deterministyczny i mapuje match-in-week 1/2', () {
      final firstMatch = fixture('task15-context-1', regularHome, regularAway);
      final first = factory.create(
        league: baseLeague,
        match: firstMatch,
        saveSeed: 99,
      );
      final repeat = factory.create(
        league: baseLeague,
        match: firstMatch,
        saveSeed: 99,
      );
      final second = factory.create(
        league: baseLeague,
        match: fixture('task15-context-2', regularHome, regularAway, round: 2),
        saveSeed: 99,
      );

      expect(first, repeat);
      expect(first.seed, matchSeed(99, 2026, firstMatch.id));
      expect(first.homeTeamId, regularHome.id);
      expect(first.awayTeamId, regularAway.id);
      expect(first.homeMatchInWeek, 1);
      expect(first.awayMatchInWeek, 1);
      expect(second.homeMatchInWeek, 2);
      expect(second.awayMatchInWeek, 2);
      expect(first.temperatureC, inInclusiveRange(-5, 38));
      expect(first.refereeStrictness, inInclusiveRange(0.80, 1.20));
      expect(first.crowdIntensity, inInclusiveRange(0, 100));
    });

    test(
      'rozkład pogody i temperatury różni się między początkiem a zimą sezonu',
      () {
        final summer = [
          for (var i = 0; i < 240; i++)
            factory.createForTeams(
              home: regularHome,
              away: regularAway,
              seasonYear: 2026,
              matchId: 'task15-summer-$i',
              saveSeed: 101,
              week: 4,
            ),
        ];
        final winter = [
          for (var i = 0; i < 240; i++)
            factory.createForTeams(
              home: regularHome,
              away: regularAway,
              seasonYear: 2026,
              matchId: 'task15-winter-$i',
              saveSeed: 101,
              week: 20,
            ),
        ];
        final summerWarm = summer
            .where(
              (context) =>
                  context.weather == Weather.clear ||
                  context.weather == Weather.heat,
            )
            .length;
        final winterWarm = winter
            .where(
              (context) =>
                  context.weather == Weather.clear ||
                  context.weather == Weather.heat,
            )
            .length;
        final summerCold = summer
            .where(
              (context) =>
                  context.weather == Weather.snow ||
                  context.weather == Weather.cold,
            )
            .length;
        final winterCold = winter
            .where(
              (context) =>
                  context.weather == Weather.snow ||
                  context.weather == Weather.cold,
            )
            .length;
        final summerAverage =
            summer
                .map((context) => context.temperatureC)
                .reduce((a, b) => a + b) /
            summer.length;
        final winterAverage =
            winter
                .map((context) => context.temperatureC)
                .reduce((a, b) => a + b) /
            winter.length;

        expect(summerWarm, greaterThan(winterWarm));
        expect(winterCold, greaterThan(summerCold));
        expect(summerAverage, greaterThan(winterAverage));
        expect(
          [...summer, ...winter].every(
            (context) =>
                context.temperatureC >= -5 && context.temperatureC <= 38,
          ),
          isTrue,
        );
      },
    );

    test('obsługiwane są wszystkie stawki, derby i konferencja', () {
      for (final stake in MatchStake.values) {
        final context = factory.createForTeams(
          home: regularHome,
          away: regularAway,
          seasonYear: 2026,
          matchId: 'task15-stake-${stake.name}',
          saveSeed: 103,
          stake: stake,
        );
        expect(context.stake, stake);
      }

      final sameConferenceDerby = factory.createForTeams(
        home: baseLeague.teams[0],
        away: baseLeague.teams[1],
        seasonYear: 2026,
        matchId: 'task15-derby-default',
        saveSeed: 104,
      );
      final sameConferenceNonDerby = factory.createForTeams(
        home: baseLeague.teams[0],
        away: baseLeague.teams[2],
        seasonYear: 2026,
        matchId: 'task15-derby-no',
        saveSeed: 104,
      );
      final crossConferenceWithKey =
          MatchContextFactory(
            rivalryKeys: {
              MatchContextFactory.rivalryKey(
                baseLeague.teams[0].id,
                baseLeague.teams[15].id,
              ),
            },
          ).createForTeams(
            home: baseLeague.teams[0],
            away: baseLeague.teams[15],
            seasonYear: 2026,
            matchId: 'task15-derby-cross-conference',
            saveSeed: 104,
          );

      expect(sameConferenceDerby.isDerby, isTrue);
      expect(sameConferenceNonDerby.isDerby, isFalse);
      expect(crossConferenceWithKey.isDerby, isFalse);
    });

    PlayoffSeries completedSeries(
      String id,
      String higherSeedTeamId,
      String lowerSeedTeamId,
      String winnerTeamId,
    ) {
      final higherSeedWins = winnerTeamId == higherSeedTeamId ? 3 : 0;
      final lowerSeedWins = winnerTeamId == lowerSeedTeamId ? 3 : 0;
      return PlayoffSeries(
        id: id,
        higherSeedTeamId: higherSeedTeamId,
        lowerSeedTeamId: lowerSeedTeamId,
        winsNeeded: 3,
        higherSeedWins: higherSeedWins,
        lowerSeedWins: lowerSeedWins,
        winnerTeamId: winnerTeamId,
      );
    }

    PlayoffBracket completedBracket(
      Conference conference,
      List<Team> teams, {
      PlayoffSeries? leagueFinal,
    }) => PlayoffBracket(
      conference: conference,
      quarterFinals: [
        completedSeries(
          '${conference.name}-q1',
          teams[0].id,
          teams[7].id,
          teams[0].id,
        ),
        completedSeries(
          '${conference.name}-q2',
          teams[1].id,
          teams[6].id,
          teams[1].id,
        ),
        completedSeries(
          '${conference.name}-q3',
          teams[2].id,
          teams[5].id,
          teams[2].id,
        ),
        completedSeries(
          '${conference.name}-q4',
          teams[3].id,
          teams[4].id,
          teams[3].id,
        ),
      ],
      semiFinals: [
        completedSeries(
          '${conference.name}-s1',
          teams[0].id,
          teams[3].id,
          teams[0].id,
        ),
        completedSeries(
          '${conference.name}-s2',
          teams[1].id,
          teams[2].id,
          teams[1].id,
        ),
      ],
      conferenceFinal: [
        completedSeries(
          '${conference.name}-cf',
          teams[0].id,
          teams[1].id,
          teams[0].id,
        ),
      ],
      leagueFinal: leagueFinal,
    );

    test(
      'oznacza mecz zamykający serię jako playoffElimination także w preview',
      () {
        final teams = baseLeague.teams
            .where((team) => team.conference == Conference.europe)
            .take(8)
            .toList();
        final eliminationSeries = PlayoffSeries(
          id: 'task15-elimination',
          higherSeedTeamId: teams[0].id,
          lowerSeedTeamId: teams[7].id,
          winsNeeded: 3,
          higherSeedWins: 2,
        );
        final playoffLeague = baseLeague.copyWith(
          playerTeamId: teams[0].id,
          currentSeason: baseLeague.currentSeason.copyWith(
            phase: SeasonPhase.playoff,
            playoffBrackets: [
              PlayoffBracket(
                conference: Conference.europe,
                quarterFinals: [
                  eliminationSeries,
                  completedSeries(
                    'task15-q2',
                    teams[1].id,
                    teams[6].id,
                    teams[1].id,
                  ),
                  completedSeries(
                    'task15-q3',
                    teams[2].id,
                    teams[5].id,
                    teams[2].id,
                  ),
                  completedSeries(
                    'task15-q4',
                    teams[3].id,
                    teams[4].id,
                    teams[3].id,
                  ),
                ],
              ),
            ],
          ),
        );

        final updated = SeasonService().advancePlayoffs(
          playoffLeague,
          saveSeed: 115,
        );
        final result = updated
            .currentSeason
            .playoffBrackets
            .single
            .quarterFinals
            .first
            .games
            .single;
        final preview = updated.inbox.messages
            .where((message) => message.type == MessageType.matchPreview)
            .single;

        expect(result.context.stake, MatchStake.playoffElimination);
        expect(preview.payload['stake'], MatchStake.playoffElimination.name);
      },
    );

    test('każdy mecz finału ligi otrzymuje stawkę leagueFinal', () {
      final east = baseLeague.teams
          .where((team) => team.conference == Conference.europe)
          .take(8)
          .toList();
      final west = baseLeague.teams
          .where((team) => team.conference == Conference.restOfTheWorld)
          .take(8)
          .toList();
      final leagueFinal = PlayoffSeries(
        id: 'task15-league-final',
        higherSeedTeamId: east[0].id,
        lowerSeedTeamId: west[0].id,
        winsNeeded: 3,
        higherSeedWins: 2,
      );
      final playoffLeague = baseLeague.copyWith(
        playerTeamId: east[0].id,
        currentSeason: baseLeague.currentSeason.copyWith(
          phase: SeasonPhase.playoff,
          playoffBrackets: [
            completedBracket(Conference.europe, east, leagueFinal: leagueFinal),
            completedBracket(Conference.restOfTheWorld, west),
          ],
        ),
      );

      final updated = SeasonService().advancePlayoffs(
        playoffLeague,
        saveSeed: 116,
      );
      final result =
          updated.currentSeason.playoffBrackets.first.leagueFinal!.games.single;
      final preview = updated.inbox.messages
          .where((message) => message.type == MessageType.matchPreview)
          .single;

      expect(result.context.stake, MatchStake.leagueFinal);
      expect(preview.payload['stake'], MatchStake.leagueFinal.name);
    });

    test('snapshot i MatchResult przechodzą JSON round-trip', () {
      final context = factory.createForTeams(
        home: regularHome,
        away: regularAway,
        seasonYear: 2026,
        matchId: 'task15-snapshot',
        saveSeed: 105,
        stake: MatchStake.playoff,
      );
      final result = engine.simulateFull(
        home: regularHome,
        away: regularAway,
        context: context,
        rngSeed: context.seed,
      );
      final restored = MatchResult.fromJson(
        jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>,
      );

      expect(result.homeSnapshot.startingXi, isNotEmpty);
      expect(result.homeSnapshot.bench.length, lessThanOrEqualTo(7));
      expect(result.homeSnapshot.assignedPositions.length, 11);
      expect(result.homeSnapshot.assignedRoles.length, 11);
      expect(result.homeSnapshot.tactics, regularHome.tactics);
      expect(result.homeSnapshot.chemistry, regularHome.chemistry);
      expect(result.homeSnapshot.atmosphere, regularHome.atmosphere);
      expect(result.homeSnapshot.staff, regularHome.staff);
      expect(restored.context, result.context);
      expect(restored.homeSnapshot, result.homeSnapshot);
      expect(restored.awaySnapshot, result.awaySnapshot);
      expect(restored.playerStats, result.playerStats);
    });
  });

  group('Task 15 — komunikaty i regresja Task 10–14', () {
    test(
      'emituje preview, brak GK, niepełną ławkę i walkower z priorytetami',
      () {
        final playerLeague = baseLeague.copyWith(playerTeamId: baseHome.id);
        final noGkHome = teamWithBench(baseHome, 0).copyWith(
          lineupPlayerIds: teamWithRoster(
            baseHome,
            size: 25,
            goalkeeperInXi: false,
          ).lineupPlayerIds,
        );
        final away = teamWithRoster(baseAway, size: 25);
        final context = MatchContextFactory().createForTeams(
          home: noGkHome,
          away: away,
          seasonYear: 2026,
          matchId: 'task15-messages-played',
          saveSeed: 106,
        );
        final report = validator.validate(home: noGkHome, away: away);
        final emitter = MatchMessageEmitter(messages: MessageService());
        final withWarnings = emitter.emitPreMatch(
          league: playerLeague.updateTeam(noGkHome).updateTeam(away),
          matchId: 'task15-messages-played',
          homeTeamId: noGkHome.id,
          awayTeamId: away.id,
          context: context,
          report: report,
        );

        expect(withWarnings.inbox.messages, hasLength(3));
        expect(
          withWarnings.inbox.messages.map((message) => message.type),
          containsAll(<MessageType>[
            MessageType.matchPreview,
            MessageType.lineupNoGk,
            MessageType.benchIncomplete,
          ]),
        );
        expect(
          withWarnings.inbox.messages
              .firstWhere((message) => message.type == MessageType.lineupNoGk)
              .priority,
          MessagePriority.urgent,
        );
        expect(
          withWarnings.inbox.messages
              .firstWhere(
                (message) => message.type == MessageType.benchIncomplete,
              )
              .priority,
          MessagePriority.normal,
        );

        final walkoverHome = teamWithRoster(baseHome, size: 19);
        final walkoverLeague = playerLeague
            .updateTeam(walkoverHome)
            .copyWith(inbox: const Inbox());
        final walkoverContext = MatchContextFactory().createForTeams(
          home: walkoverHome,
          away: away,
          seasonYear: 2026,
          matchId: 'task15-messages-walkover',
          saveSeed: 107,
        );
        final walkover = emitter.emitPreMatch(
          league: walkoverLeague,
          matchId: 'task15-messages-walkover',
          homeTeamId: walkoverHome.id,
          awayTeamId: away.id,
          context: walkoverContext,
          report: validator.validate(home: walkoverHome, away: away),
        );
        final walkoverMessage = walkover.inbox.messages.firstWhere(
          (message) => message.type == MessageType.walkover,
        );

        expect(walkoverMessage.priority, MessagePriority.urgent);
        expect(
          walkover.inbox.messages.where(
            (message) => message.type == MessageType.matchResult,
          ),
          isEmpty,
        );
      },
    );

    test('mecz AI-only nie wysyła komunikatu do inboxa gracza', () {
      final aiLeague = baseLeague.copyWith(
        playerTeamId: baseLeague.teams[2].id,
        inbox: const Inbox(),
      );
      final home = teamWithRoster(baseHome, size: 25);
      final away = teamWithRoster(baseAway, size: 25);
      final context = MatchContextFactory().createForTeams(
        home: home,
        away: away,
        seasonYear: 2026,
        matchId: 'task15-ai-only',
        saveSeed: 108,
      );
      final state = MatchMessageEmitter().emitPreMatch(
        league: aiLeague,
        matchId: 'task15-ai-only',
        homeTeamId: home.id,
        awayTeamId: away.id,
        context: context,
        report: validator.validate(home: home, away: away),
      );

      expect(state.inbox.messages, isEmpty);
    });

    test('zachowuje legacy fallback Task 10–14 dla opisu bez GK', () {
      final legacy = MatchResult(
        homeTeamId: baseHome.id,
        awayTeamId: baseAway.id,
        homeGoals: 0,
        awayGoals: 0,
        homeStats: TeamMatchStats(teamId: baseHome.id),
        awayStats: TeamMatchStats(teamId: baseAway.id),
        events: [
          MatchEvent(
            type: MatchEventType.fullTime,
            minute: 0,
            teamId: baseHome.id,
            description: 'Obie drużyny bez BR — 0:0',
          ),
        ],
      );

      expect(TeamManagementService.isWalkoverResult(legacy), isTrue);
      expect(TeamManagementService.walkoverTeamIds(legacy), {
        baseHome.id,
        baseAway.id,
      });

      final playedNoGk = engine.simulateFull(
        home: teamWithRoster(baseHome, size: 25, goalkeeperInXi: false),
        away: teamWithRoster(baseAway, size: 25),
        rngSeed: 109,
      );
      expect(TeamManagementService.isWalkoverResult(playedNoGk), isFalse);
    });
  });
}
