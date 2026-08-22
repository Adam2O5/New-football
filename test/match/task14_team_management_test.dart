import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/league_strength_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/team_management_service.dart';

void main() {
  final seededLeague = SeedDataGenerator(
    random: null,
  ).generateLeague(year: 2026, seed: 1414);
  final sourceTeam = seededLeague.teams.first;
  final sourcePlayer = sourceTeam.roster.firstWhere(
    (player) => player.position != Position.gk,
  );

  Player customPlayer(
    String id,
    FieldPlayerAttributes attributes, {
    Nationality nationality = Nationality.poland,
    int seasonsWithTeam = 0,
  }) {
    return sourcePlayer.copyWith(
      id: id,
      name: id,
      position: Position.st,
      nationality: nationality,
      attributes: PlayerAttributes.outfield(stats: attributes),
      contract: const Contract(salary: 1000000, yearsRemaining: 1),
      optimalRole: const AssignedRole.striker(),
      state: sourcePlayer.state.copyWith(
        injury: null,
        suspensionGamesRemaining: 0,
        seasonsWithTeam: seasonsWithTeam,
        role: const AssignedRole.striker(),
      ),
    );
  }

  Player uniformPlayer(String id, int value) => customPlayer(
    id,
    FieldPlayerAttributes(
      pace: value,
      shooting: value,
      passing: value,
      dribbling: value,
      defending: value,
      physicality: value,
    ),
  );

  Team strengthTeam(String id, int value, {int payroll = 100}) {
    return sourceTeam.copyWith(
      id: id,
      name: id,
      roster: [uniformPlayer('${id}_player', value)],
      lineupPlayerIds: const [],
      benchPlayerIds: const [],
      finance: TeamFinance(totalPayroll: payroll),
    );
  }

  MatchResult resultFor(
    String homeTeamId,
    String awayTeamId, {
    int homeGoals = 1,
    int awayGoals = 0,
    bool isWalkover = false,
    List<MatchEvent> events = const [],
    List<Player> homeLineup = const [],
    List<Player> awayLineup = const [],
    List<Position> homeLineupPositions = const [],
    List<Position> awayLineupPositions = const [],
  }) {
    return MatchResult(
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      homeStats: TeamMatchStats(teamId: homeTeamId),
      awayStats: TeamMatchStats(teamId: awayTeamId),
      isWalkover: isWalkover,
      events: events,
      homeLineup: homeLineup,
      awayLineup: awayLineup,
      homeLineupPositions: homeLineupPositions,
      awayLineupPositions: awayLineupPositions,
    );
  }

  PlayoffSeries completedSeries(
    String id,
    String higherSeedTeamId,
    String lowerSeedTeamId,
    String winnerTeamId,
  ) {
    final higherWon = winnerTeamId == higherSeedTeamId;
    return PlayoffSeries(
      id: id,
      higherSeedTeamId: higherSeedTeamId,
      lowerSeedTeamId: lowerSeedTeamId,
      winsNeeded: 3,
      higherSeedWins: higherWon ? 3 : 0,
      lowerSeedWins: higherWon ? 0 : 3,
      winnerTeamId: winnerTeamId,
    );
  }

  test(
    'chemistry and atmosphere multipliers respect every documented band',
    () {
      expect(TeamManagementService.chemistryMultiplier(-1), 0.95);
      expect(TeamManagementService.chemistryMultiplier(29), 0.95);
      expect(TeamManagementService.chemistryMultiplier(30), 0.98);
      expect(TeamManagementService.chemistryMultiplier(49), 0.98);
      expect(TeamManagementService.chemistryMultiplier(50), 1.00);
      expect(TeamManagementService.chemistryMultiplier(69), 1.00);
      expect(TeamManagementService.chemistryMultiplier(70), 1.02);
      expect(TeamManagementService.chemistryMultiplier(84), 1.02);
      expect(TeamManagementService.chemistryMultiplier(85), 1.05);
      expect(TeamManagementService.chemistryMultiplier(101), 1.05);

      expect(TeamManagementService.atmosphereMultiplier(-1), 0.95);
      expect(TeamManagementService.atmosphereMultiplier(29), 0.95);
      expect(TeamManagementService.atmosphereMultiplier(30), 0.97);
      expect(TeamManagementService.atmosphereMultiplier(44), 0.97);
      expect(TeamManagementService.atmosphereMultiplier(45), 1.00);
      expect(TeamManagementService.atmosphereMultiplier(69), 1.00);
      expect(TeamManagementService.atmosphereMultiplier(70), 1.02);
      expect(TeamManagementService.atmosphereMultiplier(84), 1.02);
      expect(TeamManagementService.atmosphereMultiplier(85), 1.04);
      expect(TeamManagementService.atmosphereMultiplier(101), 1.04);

      expect(
        TeamManagementService.eventProbabilityMultiplier(29, positive: false),
        1.25,
      );
      expect(
        TeamManagementService.eventProbabilityMultiplier(44, positive: false),
        1.10,
      );
      expect(
        TeamManagementService.eventProbabilityMultiplier(70, positive: true),
        1.10,
      );
      expect(
        TeamManagementService.eventProbabilityMultiplier(85, positive: true),
        1.20,
      );
    },
  );

  test(
    'expected wins and form use the documented formulas and last eight games',
    () {
      expect(TeamManagementService.expectedWins(0), 29);
      expect(TeamManagementService.expectedWins(1), 29);
      expect(TeamManagementService.expectedWins(30), 16);
      expect(TeamManagementService.expectedWins(31), 16);

      expect(
        TeamManagementService.teamForm([1, 1, 0, -1, -1, 1, 0, -1]),
        closeTo(11 / 24, 0.000001),
      );
      expect(TeamManagementService.teamForm([-1, 1, 1, 1, 1, 1, 1, 1, 1]), 1.0);
      expect(TeamManagementService.teamForm(const []), 0.5);
    },
  );

  test(
    'chemistry applies optimal positions, experience and nationality clusters',
    () {
      final lineup = sourceTeam.roster.take(11).toList();
      final preparedLineup = lineup.asMap().entries.map((entry) {
        return entry.value.copyWith(
          nationality: Nationality.poland,
          state: entry.value.state.copyWith(
            seasonsWithTeam: entry.key < 10 ? 3 : 0,
          ),
        );
      }).toList();
      final team = sourceTeam.copyWith(
        chemistry: 50,
        roster: [...preparedLineup, ...sourceTeam.roster.skip(11)],
        chemistryAppearances: {
          for (final player in preparedLineup) player.id: 5,
        },
      );
      final positions = preparedLineup
          .map((player) => player.position)
          .toList();
      final update = const TeamManagementService().applyMatchResult(
        team: team,
        result: resultFor(team.id, 'away'),
        startingEleven: preparedLineup,
        assignedPositions: positions,
      );

      // +0.3 optimal XI +0.3 experienced core +0.4 nationality cluster.
      expect(update.chemistryDelta, closeTo(1.0, 0.000001));
      expect(update.team.chemistry, closeTo(51.0, 0.000001));

      final wrongPositions = [...positions];
      wrongPositions[0] = positions[0] == Position.st
          ? Position.gk
          : Position.st;
      final outOfPosition = const TeamManagementService().applyMatchResult(
        team: team,
        result: resultFor(team.id, 'away'),
        startingEleven: preparedLineup,
        assignedPositions: wrongPositions,
      );
      // The optimal-XI bonus disappears and one player costs 0.4.
      expect(outOfPosition.chemistryDelta, closeTo(0.3, 0.000001));
    },
  );

  test(
    'new-transfer chemistry adaptation decays after the sixth appearance',
    () {
      final lineup = sourceTeam.roster.take(11).toList().asMap().entries.map((
        entry,
      ) {
        return entry.value.copyWith(
          nationality: Nationality.values[entry.key],
          state: entry.value.state.copyWith(seasonsWithTeam: 0),
        );
      }).toList();
      var team = sourceTeam.copyWith(
        chemistry: 50,
        roster: [...lineup, ...sourceTeam.roster.skip(11)],
        chemistryAppearances: {
          for (final player in lineup.skip(1)) player.id: 5,
          lineup.first.id: 0,
        },
      );
      final positions = lineup.map((player) => player.position).toList();
      const expected = [-0.7, -0.5, -0.3, -0.1, 0.1, 0.3];

      for (var i = 0; i < expected.length; i++) {
        final update = const TeamManagementService().applyMatchResult(
          team: team,
          result: resultFor(team.id, 'away'),
          startingEleven: lineup,
          assignedPositions: positions,
        );
        expect(update.chemistryDelta, closeTo(expected[i], 0.000001));
        team = update.team;
      }
    },
  );

  test(
    'chemistry clamp, weekly atmosphere update and history are persistent',
    () {
      final service = const TeamManagementService();
      final clampedHigh = service.applyChemistryDelta(
        sourceTeam.copyWith(chemistry: 99.9),
        10,
      );
      final clampedLow = service.applyAtmosphereDelta(
        sourceTeam.copyWith(atmosphere: 1),
        -10,
      );
      expect(clampedHigh.chemistry, 100.0);
      expect(clampedLow.atmosphere, 0);

      final weekly = service.updateWeekly(
        team: sourceTeam.copyWith(
          atmosphere: 50,
          chemistry: 70,
          recentMatchResults: [1, 1, 1],
        ),
        seasonYear: 2026,
        week: 5,
        expectedRank: 12,
        currentRank: 10,
      );
      expect(weekly.team.atmosphere, 54);
      expect(weekly.team.chemistry, 70.0);
      expect(weekly.atmosphereDelta, 4);
      expect(weekly.team.weeklyHistory, hasLength(1));
      expect(weekly.team.weeklyHistory.single.seasonYear, 2026);
      expect(weekly.team.weeklyHistory.single.week, 5);
      expect(weekly.team.weeklyHistory.single.wins, 3);
      expect(weekly.team.weeklyHistory.single.draws, 0);
      expect(weekly.team.weeklyHistory.single.losses, 0);

      final lowAtmosphere = service.updateWeekly(
        team: sourceTeam.copyWith(
          atmosphere: 20,
          chemistry: 99,
          recentMatchResults: [-1, -1, -1],
        ),
        seasonYear: 2026,
        week: 6,
        expectedRank: 15,
        currentRank: 15,
      );
      expect(lowAtmosphere.team.atmosphere, 17);
      expect(lowAtmosphere.team.chemistry, 97.0);
    },
  );

  test('walkover and no-goalkeeper results identify responsible teams', () {
    final result = resultFor(
      'home',
      'away',
      homeGoals: 0,
      awayGoals: 0,
      events: [
        const MatchEvent(
          type: MatchEventType.fullTime,
          minute: 0,
          teamId: 'home',
          description: 'Obie drużyny bez BR — 0:0',
        ),
      ],
    );

    expect(TeamManagementService.isWalkoverResult(result), isTrue);
    expect(TeamManagementService.walkoverTeamIds(result), {'home', 'away'});

    final oneTeam = resultFor(
      'home',
      'away',
      homeGoals: 0,
      awayGoals: 3,
      isWalkover: true,
      events: [
        const MatchEvent(
          type: MatchEventType.fullTime,
          minute: 0,
          teamId: 'home',
          description: 'Walkower — nielegalny roster gospodarzy',
        ),
      ],
    );
    expect(TeamManagementService.walkoverTeamIds(oneTeam), {'home'});
  });

  test('strength table follows four-week schedule and week 44 refresh', () {
    const service = LeagueStrengthService();
    final current = LeagueStrengthTable(
      entries: const [],
      lastCalculatedWeek: 1,
      lastCalculatedDay: 1,
      seasonYear: 2026,
    );

    expect(service.shouldRecalculate(1, 1, null, seasonYear: 2026), isTrue);
    expect(service.shouldRecalculate(1, 1, current, seasonYear: 2026), isFalse);
    expect(service.shouldRecalculate(5, 1, current, seasonYear: 2026), isTrue);
    expect(service.shouldRecalculate(9, 1, current, seasonYear: 2026), isTrue);
    expect(service.shouldRecalculate(23, 1, current, seasonYear: 2026), isTrue);
    expect(
      service.shouldRecalculate(44, 1, current, seasonYear: 2026),
      isFalse,
    );
    expect(service.shouldRecalculate(44, 2, current, seasonYear: 2026), isTrue);
    expect(service.shouldRecalculate(1, 1, current, seasonYear: 2027), isTrue);
  });

  test(
    'team power counts signed players and fills missing roster slots with 50',
    () {
      final signed = sourcePlayer.copyWith(
        contract: const Contract(salary: 1000000, yearsRemaining: 1),
      );
      final unsigned = sourcePlayer.copyWith(
        id: '${sourcePlayer.id}-unsigned',
        contract: const Contract(salary: 0, yearsRemaining: 0),
      );
      final team = sourceTeam.copyWith(roster: [signed, unsigned]);
      final service = const LeagueStrengthService();
      final expected = (signed.overall() + 14 * 50) / 15;

      expect(
        service.computeTeamPowerPrecise(team),
        closeTo(expected, 0.000001),
      );
      expect(
        service.computeTeamPower(team),
        double.parse(expected.toStringAsFixed(2)),
      );
    },
  );

  test(
    'strength-table tie-break uses full precision, previous points, payroll and id',
    () {
      const service = LeagueStrengthService();

      final lowerRaw = sourceTeam.copyWith(
        id: 'raw-low',
        name: 'raw-low',
        roster: [
          customPlayer(
            'raw-low-player',
            const FieldPlayerAttributes(
              pace: 71,
              shooting: 70,
              passing: 70,
              dribbling: 72,
              defending: 70,
              physicality: 70,
            ),
          ),
        ],
        finance: TeamFinance(totalPayroll: 100),
      );
      final higherRaw = sourceTeam.copyWith(
        id: 'raw-high',
        name: 'raw-high',
        roster: [
          customPlayer(
            'raw-high-player',
            const FieldPlayerAttributes(
              pace: 71,
              shooting: 70,
              passing: 70,
              dribbling: 72,
              defending: 71,
              physicality: 70,
            ),
          ),
        ],
        finance: TeamFinance(totalPayroll: 100),
      );
      expect(
        service.computeTeamPower(lowerRaw),
        service.computeTeamPower(higherRaw),
      );
      expect(
        service.computeTeamPowerPrecise(higherRaw),
        greaterThan(service.computeTeamPowerPrecise(lowerRaw)),
      );
      final rawTable = service.calculate(
        LeagueState(
          teams: [lowerRaw, higherRaw],
          currentSeason: Season(year: 2026),
        ),
        week: 1,
        seasonYear: 2026,
      );
      expect(rawTable.entries.first.teamId, 'raw-high');

      final pointA = strengthTeam('points-a', 70);
      final pointB = strengthTeam('points-b', 70);
      final pointLeague = LeagueState(
        teams: [pointA, pointB],
        currentSeason: Season(year: 2026),
        history: [
          SeasonHistory(
            year: 2025,
            finalStandings: [
              ConferenceStandings(
                conference: Conference.europe,
                standings: [
                  Standing(teamId: pointA.id, wins: 5),
                  Standing(teamId: pointB.id, wins: 4),
                ],
              ),
            ],
          ),
        ],
      );
      expect(
        service
            .calculate(pointLeague, week: 1, seasonYear: 2026)
            .entries
            .first
            .teamId,
        pointA.id,
      );

      final payrollA = strengthTeam('payroll-a', 70, payroll: 100);
      final payrollB = strengthTeam('payroll-b', 70, payroll: 200);
      final payrollTable = service.calculate(
        LeagueState(
          teams: [payrollB, payrollA],
          currentSeason: Season(year: 2026),
        ),
        week: 1,
        seasonYear: 2026,
      );
      expect(payrollTable.entries.first.teamId, payrollA.id);

      final idA = strengthTeam('id-a', 70);
      final idB = strengthTeam('id-b', 70);
      final idTable = service.calculate(
        LeagueState(teams: [idB, idA], currentSeason: Season(year: 2026)),
        week: 1,
        seasonYear: 2026,
      );
      expect(idTable.entries.first.teamId, idA.id);
    },
  );

  test(
    'hysteresis keeps the 3/6/9/7/5 distribution and limits tier movement',
    () {
      const service = LeagueStrengthService();
      final teams = [
        for (var i = 0; i < 30; i++) strengthTeam('tier-$i', 50 + i),
      ];
      final league = LeagueState(
        teams: teams,
        currentSeason: Season(year: 2026),
      );
      final first = service.calculate(league, week: 1, seasonYear: 2026);

      Map<TeamStatus, int> counts(LeagueStrengthTable table) {
        final result = <TeamStatus, int>{};
        for (final entry in table.entries) {
          result[entry.teamStatus] = (result[entry.teamStatus] ?? 0) + 1;
        }
        return result;
      }

      expect(counts(first), {
        TeamStatus.elite: 3,
        TeamStatus.contender: 6,
        TeamStatus.pretender: 9,
        TeamStatus.retool: 7,
        TeamStatus.rebuild: 5,
      });

      final changedTeams = [
        for (var i = 0; i < 30; i++)
          strengthTeam(
            'tier-$i',
            i == 27
                ? 76
                : i == 26
                ? 77
                : 50 + i,
          ),
      ];
      final second = service.calculate(
        league.copyWith(teams: changedTeams),
        previousTable: first,
        week: 5,
        day: 1,
        seasonYear: 2026,
      );

      for (final before in first.entries) {
        final after = second.entryFor(before.teamId)!;
        final movement =
            (TeamStatus.values.indexOf(after.teamStatus) -
                    TeamStatus.values.indexOf(before.teamStatus))
                .abs();
        expect(movement, lessThanOrEqualTo(1));
      }
      expect(counts(second), counts(first));
      expect(TeamManagementService.teamForm([1, 1, 1]), closeTo(1.0, 0.000001));
    },
  );

  test('weekly and match models preserve Task 14 state through JSON', () {
    final team = sourceTeam.copyWith(
      chemistry: 61.5,
      atmosphere: 82,
      recentMatchResults: [1, 0, -1],
      chemistryAppearances: {sourcePlayer.id: 4},
      weeklyHistory: [
        const TeamWeeklyHistory(
          seasonYear: 2026,
          week: 4,
          atmosphereDelta: 2,
          chemistryDelta: 0.3,
          atmosphere: 82,
          chemistry: 61.5,
          wins: 2,
          draws: 1,
        ),
      ],
    );
    final restoredTeam = Team.fromJson(
      jsonDecode(jsonEncode(team.toJson())) as Map<String, dynamic>,
    );
    expect(restoredTeam.chemistry, 61.5);
    expect(restoredTeam.atmosphere, 82);
    expect(restoredTeam.recentMatchResults, [1, 0, -1]);
    expect(restoredTeam.chemistryAppearances[sourcePlayer.id], 4);
    expect(restoredTeam.weeklyHistory.single.chemistryDelta, 0.3);

    final match = resultFor(
      'home',
      'away',
      homeLineup: [sourcePlayer],
      homeLineupPositions: [sourcePlayer.position],
    );
    final restoredMatch = MatchResult.fromJson(
      jsonDecode(jsonEncode(match.toJson())) as Map<String, dynamic>,
    );
    expect(restoredMatch.homeLineup.single.id, sourcePlayer.id);
    expect(restoredMatch.homeLineupPositions.single, sourcePlayer.position);

    final table = LeagueStrengthTable(
      entries: [
        TeamStrengthEntry(
          teamId: sourceTeam.id,
          teamPower: 71.23,
          expectedRank: 4,
          teamStatus: TeamStatus.contender,
        ),
      ],
      lastCalculatedWeek: 5,
      lastCalculatedDay: 1,
      seasonYear: 2026,
    );
    final save = GameSave(
      meta: GameSaveMeta(
        id: 'task14-save',
        name: 'Task 14',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
        seasonYear: 2026,
        phase: SeasonPhase.regular,
        schemaVersion: SaveSchema.currentVersion,
      ),
      leagueState: seededLeague.copyWith(
        teams: [team],
        strengthTable: table,
        currentSeason: seededLeague.currentSeason.copyWith(
          championshipAtmosphereApplied: true,
          playoffMissAtmosphereApplied: true,
        ),
      ),
      saveSeed: 14,
      schemaVersion: SaveSchema.currentVersion,
    );
    final restoredSave = GameSave.fromJson(
      jsonDecode(jsonEncode(save.toJson())) as Map<String, dynamic>,
    );
    expect(SaveSchema.currentVersion, 23);
    expect(restoredSave.schemaVersion, SaveSchema.currentVersion);
    expect(restoredSave.meta.schemaVersion, SaveSchema.currentVersion);
    expect(restoredSave.leagueState.strengthTable?.seasonYear, 2026);
    expect(
      restoredSave.leagueState.currentSeason.championshipAtmosphereApplied,
      isTrue,
    );
    expect(
      restoredSave.leagueState.currentSeason.playoffMissAtmosphereApplied,
      isTrue,
    );
  });

  test('DaySimulator emits atmosphere and status-change messages', () {
    final service = const LeagueStrengthService();
    final playerTeam = sourceTeam.copyWith(
      atmosphere: 50,
      recentMatchResults: [1, 1, 1],
    );
    final weeklyState = seededLeague.copyWith(
      teams: seededLeague.teams
          .map((team) => team.id == playerTeam.id ? playerTeam : team)
          .toList(),
      playerTeamId: playerTeam.id,
      currentWeek: 1,
      currentDay: 7,
      currentSeason: seededLeague.currentSeason.copyWith(schedule: const []),
      strengthTable: null,
    );
    final weeklyResult = DaySimulator().simulateDay(weeklyState);
    expect(
      weeklyResult.league.inbox.messages.any(
        (message) =>
            message.type == MessageType.teamEvent &&
            message.kind == 'atmosphereShift',
      ),
      isTrue,
    );
    expect(
      weeklyResult.league.teamById(playerTeam.id)!.atmosphere,
      greaterThan(50),
    );

    final compactTeams = [seededLeague.teams[0], seededLeague.teams[1]];
    final compactSeason = Season(
      year: 2026,
      schedule: const [],
      standings: [
        ConferenceStandings(
          conference: Conference.europe,
          standings: [
            Standing(teamId: compactTeams[0].id),
            Standing(teamId: compactTeams[1].id),
          ],
        ),
      ],
    );
    final compactLeague = LeagueState(
      teams: compactTeams,
      currentSeason: compactSeason,
      playerTeamId: compactTeams[0].id,
      currentWeek: 5,
      currentDay: 1,
    );
    final freshTable = service.calculate(
      compactLeague,
      week: 4,
      seasonYear: 2026,
    );
    final previousTable = freshTable.copyWith(
      lastCalculatedWeek: 4,
      lastCalculatedDay: 1,
      entries: freshTable.entries
          .map(
            (entry) => entry.teamId == compactTeams[0].id
                ? entry.copyWith(teamStatus: TeamStatus.rebuild)
                : entry,
          )
          .toList(),
    );
    final statusResult = DaySimulator().simulateDay(
      compactLeague.copyWith(strengthTable: previousTable),
    );
    expect(
      statusResult.league.inbox.messages.any(
        (message) => message.type == MessageType.teamStatusChange,
      ),
      isTrue,
    );
  });

  test(
    'championship and missed-playoff atmosphere deltas are applied once',
    () {
      final champion = seededLeague.teams[0].id;
      final east = seededLeague.teams.take(8).map((team) => team.id).toList();
      final west = seededLeague.teams
          .skip(8)
          .take(8)
          .map((team) => team.id)
          .toList();

      PlayoffBracket bracket(
        Conference conference,
        List<String> teams, {
        String? leagueWinner,
        required String opponent,
      }) {
        final quarters = [
          completedSeries(
            '${conference.name}-q1',
            teams[0],
            teams[7],
            teams[0],
          ),
          completedSeries(
            '${conference.name}-q2',
            teams[1],
            teams[6],
            teams[1],
          ),
          completedSeries(
            '${conference.name}-q3',
            teams[2],
            teams[5],
            teams[2],
          ),
          completedSeries(
            '${conference.name}-q4',
            teams[3],
            teams[4],
            teams[3],
          ),
        ];
        final semis = [
          completedSeries(
            '${conference.name}-s1',
            teams[0],
            teams[3],
            teams[0],
          ),
          completedSeries(
            '${conference.name}-s2',
            teams[1],
            teams[2],
            teams[1],
          ),
        ];
        return PlayoffBracket(
          conference: conference,
          quarterFinals: quarters,
          semiFinals: semis,
          conferenceFinal: [
            completedSeries(
              '${conference.name}-cf',
              teams[0],
              teams[1],
              teams[0],
            ),
          ],
          leagueFinal: leagueWinner == null
              ? null
              : completedSeries(
                  '${conference.name}-final',
                  leagueWinner,
                  opponent,
                  leagueWinner,
                ),
        );
      }

      final playoffLeague = seededLeague.copyWith(
        playerTeamId: champion,
        teams: seededLeague.teams
            .map(
              (team) =>
                  team.id == champion ? team.copyWith(atmosphere: 60) : team,
            )
            .toList(),
        currentSeason: seededLeague.currentSeason.copyWith(
          phase: SeasonPhase.playoff,
          playoffBrackets: [
            bracket(
              Conference.europe,
              east,
              leagueWinner: champion,
              opponent: west[0],
            ),
            bracket(Conference.restOfTheWorld, west, opponent: east[0]),
          ],
        ),
      );
      final seasonService = SeasonService(random: null);
      final afterChampionship = seasonService.advancePlayoffs(playoffLeague);
      expect(afterChampionship.teamById(champion)!.atmosphere, 90);
      expect(
        afterChampionship.currentSeason.championshipAtmosphereApplied,
        isTrue,
      );
      final repeatedChampionship = seasonService.advancePlayoffs(
        afterChampionship,
      );
      expect(repeatedChampionship.teamById(champion)!.atmosphere, 90);
      expect(
        repeatedChampionship.inbox.messages
            .where(
              (message) =>
                  message.type == MessageType.teamEvent &&
                  message.kind == 'atmosphereShift',
            )
            .length,
        1,
      );

      final missedTable = LeagueStrengthTable(
        entries: [
          TeamStrengthEntry(
            teamId: champion,
            teamPower: 80,
            expectedRank: 1,
            teamStatus: TeamStatus.elite,
          ),
        ],
        lastCalculatedWeek: 44,
        seasonYear: 2026,
      );
      final missedBase = seededLeague.copyWith(
        playerTeamId: champion,
        teams: seededLeague.teams
            .map(
              (team) =>
                  team.id == champion ? team.copyWith(atmosphere: 50) : team,
            )
            .toList(),
        strengthTable: missedTable,
        currentSeason: seededLeague.currentSeason.copyWith(
          playoffBrackets: const [],
          playoffMissAtmosphereApplied: false,
        ),
      );
      final afterMiss = seasonService.rolloverSeason(missedBase);
      expect(afterMiss.teamById(champion)!.atmosphere, 35);

      final flagged = seasonService.rolloverSeason(
        missedBase.copyWith(
          currentSeason: missedBase.currentSeason.copyWith(
            playoffMissAtmosphereApplied: true,
          ),
        ),
      );
      expect(flagged.teamById(champion)!.atmosphere, 50);
    },
  );
}
