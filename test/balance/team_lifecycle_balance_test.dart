import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/league_strength_service.dart';
import 'package:new_football/core/services/player_event_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/team_management_service.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(seed: 42);
  final source = league.teams.first;
  final result = MatchResult(
    homeTeamId: source.id,
    awayTeamId: league.teams[1].id,
    homeGoals: 1,
    awayGoals: 0,
    homeStats: TeamMatchStats(teamId: source.id),
    awayStats: TeamMatchStats(teamId: league.teams[1].id),
  );

  test('chemistry uses configured XI, experience and nationality bonuses', () {
    const balance = BalanceConfig(
      roster: RosterBalance(startingXi: 2),
      chemistry: ChemistryBalance(
        fullLineupChemistryBonus: 1,
        foreignPositionChemistryPenalty: 2,
        experiencedSeasonsMin: 1,
        experiencedPlayersMin: 2,
        experiencedChemistryBonus: 3,
        nationalityClusterSize: 2,
        nationalityClusterBonus: 4,
        nationalityBonusMax: 4,
      ),
    );
    final lineup = source.roster
        .take(2)
        .map(
          (p) => p.copyWith(
            nationality: Nationality.poland,
            state: p.state.copyWith(seasonsWithTeam: 1),
          ),
        )
        .toList();
    final team = source.copyWith(
      chemistry: 50,
      roster: lineup,
      chemistryAppearances: {for (final p in lineup) p.id: 5},
    );
    const service = TeamManagementService(balance: balance);
    final update = service.applyMatchResult(
      team: team,
      result: result,
      startingEleven: lineup,
      seasonYear: 2026,
      assignedPositions: lineup.map((p) => p.position).toList(),
    );
    expect(update.chemistryDelta, 8);
    final foreign = service.applyMatchResult(
      team: team,
      result: result,
      startingEleven: lineup,
      seasonYear: 2026,
      assignedPositions: [Position.st, lineup[1].position],
    );
    expect(foreign.chemistryDelta, 5);
  });

  test(
    'match chemistry and active match adaptation share configured duration and penalty',
    () {
      const balance = BalanceConfig(
        roster: RosterBalance(startingXi: 1),
        matchday: MatchdayBalance(
          adaptationAppearances: 2,
          adaptationPenaltyAtZero: 2,
        ),
        chemistry: ChemistryBalance(
          fullLineupChemistryBonus: 0,
          experiencedChemistryBonus: 0,
          nationalityClusterBonus: 0,
        ),
      );
      final player = source.roster.first;
      final team = source.copyWith(
        roster: [player],
        chemistry: 50,
        chemistryAppearances: {},
      );
      const service = TeamManagementService(balance: balance);
      final first = service.applyMatchResult(
        team: team,
        result: result,
        startingEleven: [player],
        seasonYear: 2026,
        assignedPositions: [player.position],
      );
      final second = service.applyMatchResult(
        team: first.team,
        result: result,
        startingEleven: [player],
        seasonYear: 2026,
        assignedPositions: [player.position],
      );
      final third = service.applyMatchResult(
        team: second.team,
        result: result,
        startingEleven: [player],
        seasonYear: 2026,
        assignedPositions: [player.position],
      );
      expect(
        [first.chemistryDelta, second.chemistryDelta, third.chemistryDelta],
        [-2, -1, 0],
      );
    },
  );

  test('weekly atmosphere uses configured streak, rank bands and bounds', () {
    const balance = BalanceConfig(
      chemistry: ChemistryBalance(
        atmosphereStreakLength: 2,
        atmosphereStreakDelta: 4,
        rankAtmosphereBands: [(3, 5), (1, 2)],
        scoreMax: 60,
      ),
    );
    const service = TeamManagementService(balance: balance);
    final team = source.copyWith(atmosphere: 50, recentMatchResults: [1, 1]);
    final positive = service.updateWeekly(
      team: team,
      seasonYear: 2026,
      week: 1,
      expectedRank: 6,
      currentRank: 3,
    );
    expect(positive.atmosphereDelta, 9);
    final negative = service.updateWeekly(
      team: team.copyWith(recentMatchResults: [-1, -1]),
      seasonYear: 2026,
      week: 1,
      expectedRank: 3,
      currentRank: 6,
    );
    expect(negative.atmosphereDelta, -9);
    expect(service.applyAtmosphereDelta(team, 50).atmosphere, 60);
    expect(service.applyChemistryDelta(team, 50).chemistry, 60);
    expect(
      TeamManagementService.expectedWins(
        30,
        const BalanceConfig(
          chemistry: ChemistryBalance(
            expectedWinsRankPenalty: 0,
            expectedWinsBaseShare: 0.5,
          ),
        ),
      ),
      29,
    );
    expect(const Standing(teamId: 'a', wins: 2, draws: 1).points, 7);
  });

  test(
    'strength table uses custom sample, missing OVR, tier distribution and hysteresis',
    () {
      const balance = BalanceConfig(
        ai: AiBalance(
          teamPowerSquadSize: 2,
          missingTeamPowerOvr: 60,
          statusDistribution: [6, 6, 6, 6, 6],
          statusMaxTierChange: 0,
          expectedRankFallback: 12,
        ),
      );
      const service = LeagueStrengthService(balance: balance);
      expect(service.computeTeamPowerPrecise(source.copyWith(roster: [])), 60);
      final signed = source.roster.first;
      expect(
        service.computeTeamPowerPrecise(source.copyWith(roster: [signed])),
        (signed.overall(balance) + 60) / 2,
      );
      final table = service.calculate(league, week: 1);
      for (final status in TeamStatus.values) {
        expect(
          table.entries.where((e) => e.teamStatus == status),
          hasLength(6),
        );
      }
      final recalculated = service.calculate(
        league.copyWith(teams: league.teams.reversed.toList()),
        previousTable: table,
        week: 5,
      );
      for (final entry in recalculated.entries) {
        expect(entry.teamStatus, table.statusOf(entry.teamId));
      }
      expect(table.rankOf('missing', balance), 12);
      expect(
        TeamManagementService.actualRankOf(league, 'missing', balance),
        12,
      );
      expect(
        LeagueStrengthService.applyHysteresis(
          TeamStatus.elite,
          TeamStatus.rebuild,
          balance,
        ),
        TeamStatus.rebuild,
      );
    },
  );

  test(
    'strength refresh respects its calendar independently of scouting cadence',
    () {
      const service = LeagueStrengthService(
        balance: BalanceConfig(
          calendar: CalendarBalance(
            strengthRefreshFirstWeek: 3,
            strengthRefreshIntervalWeeks: 2,
            strengthRefreshDay: 3,
            tradeDeadlineDay: 4,
            strengthAwardsRefreshDay: 4,
          ),
        ),
      );
      final table = const LeagueStrengthService().calculate(league, week: 1);
      expect(service.shouldRecalculate(3, 3, table), isTrue);
      expect(service.shouldRecalculate(4, 3, table), isFalse);
      expect(service.shouldRecalculate(5, 3, table), isTrue);
      expect(service.shouldRecalculate(5, 1, table), isFalse);
      expect(service.shouldRecalculate(44, 4, table), isTrue);
      expect(service.shouldRecalculate(44, 2, table), isFalse);
      expect(service.shouldRecalculate(23, 4, table), isTrue);
      expect(service.shouldRecalculate(23, 3, table), isFalse);
    },
  );

  test(
    'rollover uses distinct stamina and configurable penalty for missing playoffs',
    () {
      const balance = BalanceConfig(
        player: PlayerBalance(initialStamina: 100, rolloverStamina: 77),
        chemistry: ChemistryBalance(
          playoffMissAtmosphere: {
            TeamStatus.elite: -4,
            TeamStatus.contender: -3,
            TeamStatus.pretender: -2,
          },
        ),
      );
      final team = source.copyWith(atmosphere: 50);
      final table = LeagueStrengthTable(
        entries: [
          TeamStrengthEntry(
            teamId: team.id,
            teamPower: 80,
            expectedRank: 1,
            teamStatus: TeamStatus.elite,
          ),
        ],
        lastCalculatedWeek: 1,
      );
      final rolled = SeasonService(balance: balance).rolloverSeason(
        league.updateTeam(team).copyWith(strengthTable: table),
        saveSeed: 42,
      );
      final next = rolled.teamById(team.id)!;
      expect(next.atmosphere, 46);
      final survivingIds = source.roster.map((p) => p.id).toSet();
      expect(
        next.roster
            .where((p) => survivingIds.contains(p.id))
            .map((p) => p.state.stamina),
        isNotEmpty,
      );
      expect(
        next.roster
            .where((p) => survivingIds.contains(p.id))
            .map((p) => p.state.stamina),
        everyElement(77),
      );
      expect(balance.player.initialStamina, 100);
    },
  );

  test(
    'award weights change actual MVP, defender and team-of-season selections',
    () {
      final template = source.roster.firstWhere(
        (p) => p.position == Position.st,
      );
      Player candidate(String id, double rating, int goals, int tackles) =>
          template.copyWith(
            id: id,
            seasonStats: [
              PlayerSeasonStats(
                year: 2026,
                minutes: 3000,
                appearances: 35,
                ratingAvg: rating,
                goals: goals,
                tackles: tackles,
              ),
            ],
          );
      final a = candidate('rating', 8, 0, 0),
          b = candidate('production', 6, 20, 100);
      final input = league.copyWith(
        teams: [
          source.copyWith(roster: [a, b]),
        ],
      );
      final defaults = SeasonService().runAwards(input).currentSeason.awards!;
      expect(defaults.mvpPlayerId, a.id);
      expect(defaults.dpoyPlayerId, b.id);
      expect(defaults.teamOfSeason[TeamOfSeasonSlot.st], b.id);
      const balance = BalanceConfig(
        awards: AwardsBalance(
          mvpRatingWeight: 0,
          mvpProductionWeight: 1,
          mvpOverallWeight: 0,
          dpoyRatingWeight: 1,
          dpoyCleanSheetsWeight: 0,
          dpoyActionsWeight: 0,
          totsRatingWeight: 1,
          totsProductionWeight: 0,
          totsDefensiveWeight: 0,
        ),
      );
      final configured = SeasonService(
        balance: balance,
      ).runAwards(input).currentSeason.awards!;
      expect(configured.mvpPlayerId, b.id);
      expect(configured.dpoyPlayerId, a.id);
      expect(configured.teamOfSeason[TeamOfSeasonSlot.st], a.id);
    },
  );

  test('goalkeeper award reads its own weights', () {
    final template = source.roster.firstWhere((p) => p.position == Position.gk);
    Player candidate(String id, double rating, int saves) => template.copyWith(
      id: id,
      seasonStats: [
        PlayerSeasonStats(
          year: 2026,
          minutes: 3000,
          appearances: 35,
          ratingAvg: rating,
          saves: saves,
          shotsFaced: 100,
        ),
      ],
    );
    final a = candidate('saves', 6, 90), b = candidate('rating', 10, 30);
    final input = league.copyWith(
      teams: [
        source.copyWith(roster: [a, b]),
      ],
    );
    expect(
      SeasonService().runAwards(input).currentSeason.awards!.bestGkPlayerId,
      a.id,
    );
    final configured = SeasonService(
      balance: const BalanceConfig(
        awards: AwardsBalance(
          gkSaveWeight: 0,
          gkCleanSheetsWeight: 0,
          gkGoalsPreventedWeight: 0,
          gkRatingWeight: 1,
        ),
      ),
    ).runAwards(input).currentSeason.awards!;
    expect(configured.bestGkPlayerId, b.id);
  });

  test(
    'extra training reads configured eligibility, decision time, cooldown and decline effect',
    () {
      const balance = BalanceConfig(
        events: EventsBalance(
          extraTrainingChance: 1,
          extraTrainingDeterminationMin: 4,
          extraTrainingFormMin: 5,
          extraTrainingDecisionDays: 3,
          extraTrainingWeeksPerMonth: 2,
          extraTrainingCooldownMonths: 2,
          extraTrainingDeclineFormPenalty: 0.5,
        ),
      );
      final player = source.roster.first.copyWith(
        personality: PlayerPersonality.ambitious,
        hidden: source.roster.first.hidden.copyWith(determination: 4),
        state: source.roster.first.state.copyWith(
          form: 5,
          lastDevelopmentOvrDelta: 1,
        ),
      );
      final input = league.copyWith(
        playerTeamId: source.id,
        teams: [
          source.copyWith(roster: [player], ai: null),
        ],
      );
      final service = PlayerEventService(balance: balance);
      final pending = service.weeklyTick(input, saveSeed: 42);
      final message = pending.inbox.messages.singleWhere(
        (m) => m.kind == 'extraTraining',
      );
      const calendar = CalendarService(balance: balance);
      final expected = calendar.addDays(
        input.currentSeason.year,
        input.currentWeek,
        input.currentDay,
        0,
        3,
      );
      expect(
        message.expiresAt,
        calendar
            .dateTimeForMoment(
              expected.$1,
              expected.$2,
              expected.$3,
              expected.$4,
            )
            .toIso8601String(),
      );
      final resolved = service.resolveDecision(pending, message, 'decline');
      final next = resolved.playerTeam!.roster.first;
      expect(next.state.form, 4.5);
      expect(next.state.eventState.cooldowns['extraTraining'], 4);
    },
  );

  test(
    'veteran mentoring keeps its own age threshold and configurable target eligibility',
    () {
      const balance = BalanceConfig(
        events: EventsBalance(
          veteranMotivationChance: 1,
          veteranMotivationAgeMin: 30,
          veteranMotivationSeasonsMin: 3,
          veteranMentorTargetAgeMax: 24,
          veteranMotivationCooldownWeeks: 2,
          veteranMotivationDecisionDays: 4,
          extraTrainingChance: 0,
          lateBloomerChance: 0,
          personalProblemsChance: 0,
        ),
      );
      final veteran = source.roster.first.copyWith(
        id: 'veteran',
        age: 31,
        personality: PlayerPersonality.balanced,
        hidden: source.roster.first.hidden.copyWith(determination: 8),
        state: source.roster.first.state.copyWith(
          seasonsWithTeam: 3,
          form: 6,
          lastDevelopmentOvrDelta: 1,
        ),
      );
      final young = veteran.copyWith(
        id: 'young',
        age: 24,
        state: veteran.state.copyWith(seasonsWithTeam: 0),
      );
      final input = league
          .updateTeam(source.copyWith(roster: [veteran, young], ai: null))
          .copyWith(
            playerTeamId: source.id,
            currentSeason: league.currentSeason.copyWith(
              standings: [
                for (final conference in Conference.values)
                  ConferenceStandings(
                    conference: conference,
                    standings: [
                      for (final t in league.teams.where(
                        (t) => t.conference == conference,
                      ))
                        Standing(teamId: t.id, wins: t.id == source.id ? 0 : 1),
                    ],
                  ),
              ],
            ),
          );
      final service = PlayerEventService(balance: balance);
      final pending = service.weeklyTick(input, saveSeed: 42);
      final message = pending.inbox.messages.singleWhere(
        (m) => m.kind == 'veteranMotivation',
      );
      expect(
        message.expiresAt,
        const CalendarService()
            .dateAfterDays(
              input.currentSeason.year,
              input.currentWeek,
              input.currentDay,
              4,
            )
            .toIso8601String(),
      );
      final resolved = service.resolveDecision(pending, message, 'mentor');
      final roster = resolved.playerTeam!.roster;
      expect(
        roster
            .singleWhere((p) => p.id == young.id)
            .state
            .eventState
            .modifierValue('growthRate'),
        0.1,
      );
      expect(
        roster
            .singleWhere((p) => p.id == veteran.id)
            .state
            .eventState
            .cooldowns['veteranMotivation'],
        2,
      );
      expect(balance.events.extraTrainingDeterminationMin, 7);
      expect(balance.development.developmentAgeMax, 26);
    },
  );
}
