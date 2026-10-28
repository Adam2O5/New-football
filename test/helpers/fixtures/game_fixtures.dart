import 'dart:math';

import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';

const fixtureSeed = 123;
const fixtureFreeAgentId = 'audit-free-agent';

LeagueState seededLeague() => SeedDataGenerator(
  random: Random(fixtureSeed),
).generateLeague(seed: fixtureSeed);

GameSave saveForLeague(LeagueState league, {String id = 'stage-zero'}) {
  final date = DateTime.utc(2026, 1, 1);
  return GameSave(
    schemaVersion: SaveSchema.currentVersion,
    meta: GameSaveMeta(
      id: id,
      name: id,
      createdAt: date,
      updatedAt: date,
      seasonYear: league.currentSeason.year,
      phase: league.currentSeason.phase,
      playerTeamName: league.playerTeam?.name,
      schemaVersion: SaveSchema.currentVersion,
    ),
    leagueState: league,
    saveSeed: fixtureSeed,
  );
}

/// One club and one free agent; no AI or match simulation is needed.
GameSave controllerSave() {
  final initial = seededLeague();
  final original = initial.teams.first;
  final team = original.copyWith(
    roster: original.roster.take(12).toList(),
    finance: const TeamFinance(salaryCap: 1000000000),
  );
  final freeAgent = original.roster.first.copyWith(
    id: fixtureFreeAgentId,
    contract: const Contract(salary: 0, yearsRemaining: 0),
  );
  return saveForLeague(
    LeagueState(
      teams: [team],
      playerTeamId: team.id,
      currentSeason: const Season(year: 2026, phase: SeasonPhase.regular),
      freeAgents: [freeAgent],
    ),
  );
}

LeagueState phaseTwoNegotiation() {
  final league = controllerSave().leagueState;
  final negotiation = const NegotiationService().start(
    id: 'phase-two-week-48',
    subjectId: fixtureFreeAgentId,
    subjectKind: NegotiationSubjectKind.player,
    teamId: league.playerTeamId!,
    phase: NegotiationPhase.freeAgencyPhaseII,
    offer: const NegotiationOffer(salary: 1000000, years: 1),
    seasonYear: 2026,
    week: 48,
    day: 1,
  );
  return league.copyWith(
    currentWeek: 48,
    negotiations: [negotiation],
    currentSeason: league.currentSeason.copyWith(phase: SeasonPhase.offseason),
  );
}

/// Includes the four populations needed to verify annual ageing later.
LeagueState beforeRollover() {
  final league = controllerSave().leagueState;
  final team = league.playerTeam!;
  final signed = team.roster.first.copyWith(
    contract: const Contract(
      salary: 1000000,
      yearsRemaining: 1,
      firstSeason: 2026,
      lastSeason: 2026,
    ),
  );
  const scout = StaffMember(
    id: 'employed-scout',
    name: 'Fixture Scout',
    nationality: Nationality.poland,
    age: 46,
    role: StaffRole.scout,
    contract: StaffContract(salary: 1000000, yearsRemaining: 3),
  );
  final injuredFreeAgent = league.freeAgents.single.copyWith(
    age: 28,
    state: const PlayerState(
      injury: Injury(
        id: 'fixture-injury',
        group: InjuryGroup.legMuscles,
        type: InjuryType.minor,
        daysTotal: 5,
        daysRemaining: 3,
      ),
    ),
  );
  return league
      .updateTeam(
        team.copyWith(
          roster: [signed, ...team.roster.skip(1)],
          staff: team.staff.withMember(StaffRole.scout, scout),
        ),
      )
      .copyWith(
        currentWeek: 52,
        currentDay: 7,
        currentSeason: league.currentSeason.copyWith(
          phase: SeasonPhase.offseason,
        ),
        freeAgents: [injuredFreeAgent],
        staffFreeAgents: [
          scout.copyWith(id: 'unemployed-scout', contract: null),
        ],
      );
}

/// Full conference tables are required for the postseason qualification case.
LeagueState finalRegularSeasonDay() {
  final initial = seededLeague();
  final lastMatch = ScheduledMatch(
    id: 'last-regular-fixture',
    homeTeamId: initial.teams[0].id,
    awayTeamId: initial.teams[1].id,
    round: 58,
  );
  final standings = initial.currentSeason.standings.map((conference) {
    return conference.copyWith(
      standings: [
        for (var i = 0; i < conference.standings.length; i++)
          conference.standings[i].copyWith(wins: i >= 1 && i <= 6 ? i : 0),
      ],
    );
  }).toList();
  return initial.copyWith(
    currentWeek: 29,
    currentDay: 7,
    // Disable management of test clubs; results will be supplied manually.
    teams: initial.teams.map((team) => team.copyWith(ai: null)).toList(),
    currentSeason: initial.currentSeason.copyWith(
      schedule: [lastMatch],
      standings: standings,
    ),
  );
}

MatchResult finalRegularSeasonResult(LeagueState league) {
  final match = league.currentSeason.schedule.single;
  return MatchResult(
    homeTeamId: match.homeTeamId,
    awayTeamId: match.awayTeamId,
    homeGoals: 3,
    awayGoals: 0,
    homeStats: TeamMatchStats(teamId: match.homeTeamId, goals: 3),
    awayStats: TeamMatchStats(teamId: match.awayTeamId),
  );
}

({Player left, Player right}) fullBacks() {
  final player = controllerSave().leagueState.playerTeam!.roster.firstWhere(
    (player) => player.position != Position.gk,
  );
  return (
    left: player.copyWith(id: 'fixture-left', position: Position.lb),
    right: player.copyWith(id: 'fixture-right', position: Position.rb),
  );
}

/// Synthetic data volume, not the outcome of simulating five seasons.
GameSave largerSave() {
  final initial = seededLeague();
  final teams = initial.teams.map((team) {
    return team.copyWith(
      roster: team.roster.map((player) {
        return player.copyWith(
          seasonStats: [
            for (var year = 2021; year <= 2025; year++)
              PlayerSeasonStats(
                year: year,
                minutes: 2000,
                appearances: 30,
                goals: 5,
                assists: 3,
              ),
          ],
        );
      }).toList(),
    );
  }).toList();
  final schedule = const ScheduleGenerator()
      .generateDoubleRoundRobin(teams.map((team) => team.id).toList())
      .map(
        (match) => match.copyWith(
          result: MatchResult(
            homeTeamId: match.homeTeamId,
            awayTeamId: match.awayTeamId,
            homeGoals: 1,
            awayGoals: 0,
            homeStats: TeamMatchStats(teamId: match.homeTeamId, goals: 1),
            awayStats: TeamMatchStats(teamId: match.awayTeamId),
          ).slimForStorage(),
        ),
      )
      .toList();
  return saveForLeague(
    initial.copyWith(
      teams: teams,
      history: [
        for (var year = 2021; year <= 2025; year++)
          SeasonHistory(
            year: year,
            finalStandings: initial.currentSeason.standings,
          ),
      ],
      currentSeason: initial.currentSeason.copyWith(schedule: schedule),
    ),
    id: 'larger-fixture',
  );
}
