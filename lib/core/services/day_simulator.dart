import 'package:new_football/core/balance/injury_catalog.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/match_context_factory.dart';
import 'package:new_football/core/simulation/match_message_emitter.dart';
import 'package:new_football/core/simulation/pre_match_validator.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/ai/team_ai_service.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/discipline_service.dart';
import 'package:new_football/core/services/league_strength_service.dart';
import 'package:new_football/core/services/match_post_match_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/player_event_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/team_management_service.dart';
import 'package:new_football/core/services/team_event_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/services/scouting_service.dart';

class DaySimulationResult {
  const DaySimulationResult({
    required this.league,
    required this.pauseForUrgent,
    this.playerMatch,
    this.simulatedResults = const [],
    this.eventId,
  });

  final LeagueState league;
  final bool pauseForUrgent;

  /// Non-null when the player's team has a match today — UI should open matchday.
  final ScheduledMatch? playerMatch;
  final List<MatchResult> simulatedResults;

  /// If the simulation stopped because a calendar event needs attention, this
  /// is the event id. `null` when the stop reason is the player's match or
  /// other non-calendar reasons.
  final CalendarEventId? eventId;
}

/// Advances the calendar by one day and resolves non-interactive events.
class DaySimulator {
  DaySimulator({
    this.balance = BalanceConfig.defaults,
    SimulationMatchEngine? matchEngine,
    CalendarService? calendar,
    MatchContextFactory? contextFactory,
    MatchMessageEmitter? matchMessageEmitter,
    DevelopmentService? development,
    ScoutingService? scouting,
    ContractService? contracts,
    SalaryCapService? capService,
    MessageService? messages,
    TeamManagementService? teamManagement,
    PlayerEventService? playerEvents,
    TeamEventService? teamEvents,
  }) : matchEngine = matchEngine ?? SimulationMatchEngine(balance: balance),
       calendar = calendar ?? CalendarService(balance: balance),
       contextFactory =
           contextFactory ??
           MatchContextFactory(
             calendar: calendar ?? CalendarService(balance: balance),
           ),
       matchMessageEmitter =
           matchMessageEmitter ??
           MatchMessageEmitter(messages: messages ?? MessageService()),
       development = development ?? DevelopmentService(balance: balance),
       scouting = scouting ?? ScoutingService(balance: balance),
       contracts = contracts ?? ContractService(balance: balance),
       capService = capService ?? SalaryCapService(balance: balance),
       messages = messages ?? MessageService(),
       teamManagement = teamManagement ?? const TeamManagementService(),
       playerEvents =
           playerEvents ??
           PlayerEventService(balance: balance, messages: messages),
       teamEvents =
           teamEvents ?? TeamEventService(balance: balance, messages: messages);

  final BalanceConfig balance;
  final SimulationMatchEngine matchEngine;
  final CalendarService calendar;
  final MatchContextFactory contextFactory;
  final MatchMessageEmitter matchMessageEmitter;
  final DevelopmentService development;
  final ScoutingService scouting;
  final ContractService contracts;
  final SalaryCapService capService;
  final MessageService messages;
  final TeamManagementService teamManagement;
  final PlayerEventService playerEvents;
  final TeamEventService teamEvents;

  DaySimulationResult simulateDay(LeagueState league, {int saveSeed = 0}) {
    final week = league.currentWeek;
    final day = league.currentDay;
    var state = league;
    final results = <MatchResult>[];
    ScheduledMatch? playerMatch;

    final phase = calendar.phaseForWeek(week);
    state = state.copyWith(
      currentSeason: state.currentSeason.copyWith(phase: phase),
    );

    if (phase == SeasonPhase.preseason) {
      final (nextWeek, nextDay) = calendar.advanceDay(week, day);
      return DaySimulationResult(
        league: state.copyWith(
          currentWeek: nextWeek,
          currentDay: nextDay,
          currentSeason: state.currentSeason.copyWith(
            phase: calendar.phaseForWeek(nextWeek),
          ),
        ),
        pauseForUrgent: state.inbox.pendingUrgent.isNotEmpty,
      );
    }

    // Periodic strength table recalculation (`team_management.md`).
    final strengthService = LeagueStrengthService(balance: balance);
    if (strengthService.shouldRecalculate(
      week,
      day,
      state.strengthTable,
      seasonYear: state.currentSeason.year,
    )) {
      final previousTable = state.strengthTable;
      final table = strengthService.calculate(
        state,
        previousTable: previousTable,
        week: week,
        day: day,
        seasonYear: state.currentSeason.year,
      );
      state = state.copyWith(strengthTable: table);
      state = _notifyStrengthTableChanges(state, previousTable, table);
    }

    if (calendar.isTradeDeadline(week, day)) {
      state = messages.send(
        state,
        type: MessageType.tradeWindowEvent,
        kind: 'deadline',
        domain: MessageDomain.trades,
        priority: MessagePriority.urgent,
        titleKey: 'msg_tradeWindowEvent_deadline_title',
        bodyKey: 'msg_tradeWindowEvent_deadline_body',
      );
    }

    if (calendar.isRegularSeasonWeek(week)) {
      final slot = calendar.regularSeasonSlotForDay(day);
      if (slot != null && calendar.isActualMatchDay(week, day)) {
        final round = scheduleRoundForWeekSlot(week, slot);
        final outcome = _resolveRound(state, round, saveSeed);
        state = outcome.league;
        results.addAll(outcome.results);
        playerMatch = outcome.playerMatch;
        if (playerMatch != null) {
          return DaySimulationResult(
            league: state,
            pauseForUrgent: true,
            playerMatch: playerMatch,
            simulatedResults: results,
          );
        }
      }
    }

    // Recover stamina lightly each day. Administrative participants are
    // excluded: a walkover/DSQ has no matchday recovery side effect.
    final administrativeTeamIds = <String>{
      for (final result in results)
        ...TeamManagementService.walkoverTeamIds(result),
    };
    state = _dailyRecovery(state, excludedTeamIds: administrativeTeamIds);

    // Free agency (`docs/contract_signing.md`): AI clubs bid on FA players
    // every day of the FA window; highest legal offerScore wins.
    if (week == balance.calendar.freeAgencyWeek) {
      state = _resolveFreeAgencyDay(state);
    }

    final (nextWeek, nextDay) = calendar.advanceDay(week, day);
    final nextPhase = calendar.phaseForWeek(nextWeek);
    state = state.copyWith(
      currentWeek: nextWeek,
      currentDay: nextDay,
      currentSeason: state.currentSeason.copyWith(phase: nextPhase),
    );

    // Week boundary: Sunday → Monday. Team indicators are updated before
    // development so the new week's atmosphere is the development input.
    if (day == 7) {
      final weeklyUpdates = <String, TeamWeeklyUpdate>{};
      final strengthTable = state.strengthTable;
      final weeklyTeams = state.teams.map((team) {
        final update = teamManagement.updateWeekly(
          team: team,
          seasonYear: state.currentSeason.year,
          week: week,
          expectedRank: strengthTable?.rankOf(team.id) ?? 15,
          currentRank: TeamManagementService.actualRankOf(state, team.id),
        );
        weeklyUpdates[team.id] = update;
        return update.team;
      }).toList();
      state = state.copyWith(teams: weeklyTeams);

      final playerWeeklyUpdate = state.playerTeamId == null
          ? null
          : weeklyUpdates[state.playerTeamId];
      if (playerWeeklyUpdate != null &&
          (playerWeeklyUpdate.atmosphereDelta != 0 ||
              playerWeeklyUpdate.chemistryDelta != 0)) {
        final oldAtmosphere =
            playerWeeklyUpdate.team.atmosphere -
            playerWeeklyUpdate.atmosphereDelta;
        state = messages.send(
          state,
          type: MessageType.teamEvent,
          kind: 'atmosphereShift',
          domain: MessageDomain.teamEvent,
          args: {
            'delta': playerWeeklyUpdate.atmosphereDelta,
            'chemistryDelta': playerWeeklyUpdate.chemistryDelta,
            'oldLevel': oldAtmosphere,
            'newLevel': playerWeeklyUpdate.team.atmosphere,
            'atmosphereBefore': oldAtmosphere,
            'atmosphereAfter': playerWeeklyUpdate.team.atmosphere,
            'atmosphere': playerWeeklyUpdate.team.atmosphere,
            'chemistry': playerWeeklyUpdate.team.chemistry,
          },
          payload: {
            'teamId': state.playerTeamId,
            'atmosphereDelta': playerWeeklyUpdate.atmosphereDelta,
            'chemistryDelta': playerWeeklyUpdate.chemistryDelta,
            'oldLevel': oldAtmosphere,
            'newLevel': playerWeeklyUpdate.team.atmosphere,
            'atmosphereBefore': oldAtmosphere,
            'atmosphereAfter': playerWeeklyUpdate.team.atmosphere,
            'atmosphere': playerWeeklyUpdate.team.atmosphere,
            'chemistry': playerWeeklyUpdate.team.chemistry,
          },
          groupKey: 'atmosphere:$week',
        );
      }

      state = teamEvents.weeklyTick(
        state,
        saveSeed: saveSeed,
        offseason:
            phase == SeasonPhase.offseason ||
            nextPhase == SeasonPhase.offseason,
      );

      final developmentChanges = <DevelopmentChange>[];
      final developedTeams = state.teams.map((team) {
        final tick = development.developTeamWithReport(team);
        if (team.id == state.playerTeamId) {
          developmentChanges.addAll(tick.changes.where((c) => c.ovrDelta != 0));
        }
        return tick.team;
      }).toList();
      state = state.copyWith(teams: developedTeams);

      for (final change in developmentChanges) {
        state = messages.send(
          state,
          type: MessageType.playerEvent,
          kind: 'ovrChange',
          domain: MessageDomain.playerEvent,
          titleKey: 'msg_ovrDigest_title',
          bodyKey: 'msg_ovrDigest_body',
          args: {'playerName': change.playerName, 'delta': change.ovrDelta},
          payload: {
            'playerId': change.playerId,
            'ovrDelta': change.ovrDelta,
            'growthRate': change.growthRate,
          },
          groupKey: 'ovr:own:$week',
        );
      }

      // Individual events consume the just-computed development result, so
      // their counters and rolls run after the weekly development tick.
      state = playerEvents.weeklyTick(
        state,
        saveSeed: saveSeed,
        offseason:
            phase == SeasonPhase.offseason ||
            nextPhase == SeasonPhase.offseason,
      );

      // Continuous scouting tick (`docs/staff_rules.md` §5), while a draft
      // class is known (from lottery through draft week).
      if (state.currentSeason.draftState != null) {
        state = state.copyWith(
          teams: state.teams.map((t) {
            final evalStars = t.staff.scout?.attributes.evaluation ?? 0.0;
            return t.copyWith(
              scouting: scouting.tickKnowledge(t.scouting, evalStars),
            );
          }).toList(),
        );
      }
      state = messages.send(
        state,
        type: MessageType.calendar,
        domain: MessageDomain.system,
        titleKey: 'msg_calendar_newWeek_title',
        bodyKey: 'msg_calendar_newWeek_body',
        args: {'week': nextWeek, 'phase': nextPhase.name},
      );
    }

    final urgent = state.inbox.pendingUrgent.isNotEmpty;
    return DaySimulationResult(
      league: state,
      pauseForUrgent: urgent,
      simulatedResults: results,
    );
  }

  /// Apply a finished player match and advance the day. Match-result
  /// messages are created after the date advances, so they are delivered as
  /// part of the next day's start-of-day package.
  LeagueState applyPlayerMatchResult(
    LeagueState league,
    ScheduledMatch match,
    MatchResult result, {
    int saveSeed = 0,
  }) {
    var state = _applyResult(league, match, result, saveSeed: saveSeed);
    final (nextWeek, nextDay) = calendar.advanceDay(
      state.currentWeek,
      state.currentDay,
    );
    state = state.copyWith(
      currentWeek: nextWeek,
      currentDay: nextDay,
      currentHour: calendar.initialHourForDate(nextWeek, nextDay),
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
      currentSeason: state.currentSeason.copyWith(
        phase: calendar.phaseForWeek(nextWeek),
      ),
    );
    // A player-controlled match follows the same end-of-day recovery stage as
    // an AI match: +20 immediately after the match and +20 for the day.
    // Administrative results are explicitly excluded from daily recovery.
    state = _dailyRecovery(
      state,
      excludedTeamIds: TeamManagementService.walkoverTeamIds(result),
    );
    return _notifyMatchResult(state, result, matchId: match.id);
  }

  ({LeagueState league, List<MatchResult> results, ScheduledMatch? playerMatch})
  _resolveRound(LeagueState league, int round, int saveSeed) {
    final schedule = league.currentSeason.schedule;
    final fixtures = schedule
        .where((m) => m.round == round && m.result == null)
        .toList();
    if (fixtures.isEmpty) {
      return (league: league, results: <MatchResult>[], playerMatch: null);
    }

    final playerId = league.playerTeamId;
    ScheduledMatch? playerFixture;
    final aiFixtures = <ScheduledMatch>[];
    for (final f in fixtures) {
      if (playerId != null &&
          (f.homeTeamId == playerId || f.awayTeamId == playerId)) {
        playerFixture = f;
      } else {
        aiFixtures.add(f);
      }
    }

    var state = league;
    final results = <MatchResult>[];
    for (final f in aiFixtures) {
      final home = state.teamById(f.homeTeamId);
      final away = state.teamById(f.awayTeamId);
      if (home == null || away == null) continue;
      final context = contextFactory.create(
        league: state,
        match: f,
        saveSeed: saveSeed,
        stake: MatchStake.regular,
      );
      final result = matchEngine.simulateFullMatch(
        home: home,
        away: away,
        context: context,
        rngSeed: context.seed,
      );
      state = _applyResult(state, f, result, saveSeed: saveSeed);
      results.add(result);
    }

    // The interactive fixture is not simulated here, but its pre-match
    // validation and context are created at the same boundary as AI matches.
    // This makes the preview deterministic and ensures warnings arrive before
    // MatchdayScreen starts the engine.
    if (playerFixture != null) {
      final home = state.teamById(playerFixture.homeTeamId);
      final away = state.teamById(playerFixture.awayTeamId);
      if (home != null && away != null) {
        final context = contextFactory.create(
          league: state,
          match: playerFixture,
          saveSeed: saveSeed,
          stake: MatchStake.regular,
        );
        final report = PreMatchValidator(
          balance: balance,
        ).validate(home: home, away: away);
        state = matchMessageEmitter.emitPreMatch(
          league: state,
          matchId: playerFixture.id,
          homeTeamId: home.id,
          awayTeamId: away.id,
          context: context,
          report: report,
        );
      }
    }

    return (league: state, results: results, playerMatch: playerFixture);
  }

  LeagueState _applyResult(
    LeagueState league,
    ScheduledMatch match,
    MatchResult result, {
    int saveSeed = 0,
  }) {
    final newSchedule = league.currentSeason.schedule.map((m) {
      if (m.id != match.id) return m;
      return m.copyWith(result: result);
    }).toList();

    var standings = result.status == MatchStatus.dsq
        ? league.currentSeason.standings
        : league.currentSeason.standings.map((cs) {
            final updated = cs.standings.map((s) {
              if (s.teamId == result.homeTeamId) {
                return s.applyResult(
                  goalsFor: result.homeGoals,
                  goalsAgainst: result.awayGoals,
                );
              }
              if (s.teamId == result.awayTeamId) {
                return s.applyResult(
                  goalsFor: result.awayGoals,
                  goalsAgainst: result.homeGoals,
                );
              }
              return s;
            }).toList();
            return cs.copyWith(standings: updated);
          }).toList();

    // Re-rank conferences.
    standings = standings
        .map((cs) => cs.copyWith(standings: cs.sorted))
        .toList();

    final isAdministrativeResult = TeamManagementService.isWalkoverResult(
      result,
    );
    final administrativeTeamIds = TeamManagementService.walkoverTeamIds(result);
    var teams = league.teams;
    final recoveryReturns =
        <({Player player, String injuryId, String teamId})>[];
    final disciplineNotifications =
        <({String teamId, DisciplineNotification notification})>[];
    teams = teams.map((t) {
      final isParticipant =
          t.id == result.homeTeamId || t.id == result.awayTeamId;
      final next = isParticipant && !isAdministrativeResult
          ? _applyFatigue(t, result, seasonYear: league.currentSeason.year)
          : _recoverTeam(t);
      for (final oldPlayer in t.roster) {
        final nextPlayer = next.roster.firstWhere(
          (p) => p.id == oldPlayer.id,
          orElse: () => oldPlayer,
        );
        if (oldPlayer.state.injured && !nextPlayer.state.injured) {
          recoveryReturns.add((
            player: oldPlayer,
            injuryId: oldPlayer.state.injury?.id ?? '',
            teamId: t.id,
          ));
        }
      }
      return next;
    }).toList();

    if (!isAdministrativeResult) {
      final disciplineService = const DisciplineService();
      teams = teams.map((team) {
        if (team.id != result.homeTeamId && team.id != result.awayTeamId) {
          return team;
        }
        final application = disciplineService.applyToTeam(
          team: team,
          result: result,
          phase: league.currentSeason.phase,
        );
        disciplineNotifications.addAll(
          application.notifications.map(
            (notification) => (teamId: team.id, notification: notification),
          ),
        );
        return application.team;
      }).toList();
    }

    final immediateAtmosphereDeltas = <String, int>{};
    teams = teams.map((team) {
      if (team.id != result.homeTeamId && team.id != result.awayTeamId) {
        return team;
      }
      final original = league.teamById(team.id);
      final isHome = team.id == result.homeTeamId;
      final snapshot = isHome ? result.homeLineup : result.awayLineup;
      final startingEleven = snapshot.isNotEmpty
          ? snapshot
          : original?.startingEleven ?? const <Player>[];
      final assignedPositions = isHome
          ? result.homeLineupPositions
          : result.awayLineupPositions;
      final update = teamManagement.applyMatchResult(
        team: team,
        result: result,
        startingEleven: startingEleven,
        assignedPositions: assignedPositions.isEmpty ? null : assignedPositions,
      );
      var next = update.team;
      if (administrativeTeamIds.contains(team.id)) {
        next = teamManagement.applyAtmosphereDelta(next, -15);
        immediateAtmosphereDeltas[team.id] = -15;
      }
      return next;
    }).toList();

    var state = league.copyWith(
      teams: teams,
      currentSeason: league.currentSeason.copyWith(
        schedule: newSchedule,
        standings: standings,
      ),
      currentRound: match.round,
    );

    final playerAtmosphereDelta = state.playerTeamId == null
        ? null
        : immediateAtmosphereDeltas[state.playerTeamId];
    if (playerAtmosphereDelta != null) {
      final playerTeam = state.teamById(state.playerTeamId!);
      final atmosphereAfter = playerTeam?.atmosphere ?? 0;
      final atmosphereBefore = atmosphereAfter - playerAtmosphereDelta;
      state = messages.send(
        state,
        type: MessageType.teamEvent,
        kind: 'atmosphereShift',
        domain: MessageDomain.teamEvent,
        priority: MessagePriority.urgent,
        args: {
          'delta': playerAtmosphereDelta,
          'oldLevel': atmosphereBefore,
          'newLevel': atmosphereAfter,
          'atmosphereBefore': atmosphereBefore,
          'atmosphereAfter': atmosphereAfter,
          'atmosphere': atmosphereAfter,
        },
        payload: {
          'teamId': state.playerTeamId,
          'atmosphereDelta': playerAtmosphereDelta,
          'oldLevel': atmosphereBefore,
          'newLevel': atmosphereAfter,
          'atmosphereBefore': atmosphereBefore,
          'atmosphereAfter': atmosphereAfter,
          'atmosphere': atmosphereAfter,
          'reason': 'walkover',
        },
        dedupKey: 'atmosphere:walkover:${match.id}',
      );
    }

    for (final injury in result.injuries) {
      final team = state.teamById(injury.teamId);
      final player = team?.roster.firstWhere(
        (p) => p.id == injury.playerId,
        orElse: () => throw StateError('Missing injured player'),
      );
      if (team == null || player == null) continue;
      if (state.playerTeamId != team.id) continue;
      final definition = InjuryCatalog.byId(injury.injury.id);
      state = messages.send(
        state,
        type: MessageType.injury,
        domain: MessageDomain.health,
        args: {
          'playerName': player.name,
          'injuryName': definition.name,
          'injuryType': injury.injury.type.name,
          'days': injury.injury.daysTotal,
        },
        payload: {
          'playerId': player.id,
          'teamId': team.id,
          'injuryId': injury.injury.id,
          'injuryType': injury.injury.type.name,
          'playerInStartingXi': injury.playerInStartingXi,
        },
        dedupKey: 'injury:${player.id}:${injury.injury.id}',
      );
      if (injury.potentialLoss) {
        state = messages.send(
          state,
          type: MessageType.potentialLoss,
          domain: MessageDomain.health,
          args: {'playerName': player.name},
          payload: {'playerId': player.id, 'injuryId': injury.injury.id},
          dedupKey: 'potentialLoss:${player.id}:${injury.injury.id}',
        );
      }
    }

    for (final returned in recoveryReturns) {
      if (state.playerTeamId != returned.teamId) continue;
      final definition = InjuryCatalog.byId(returned.injuryId);
      state = messages.send(
        state,
        type: MessageType.injuryReturn,
        domain: MessageDomain.health,
        args: {
          'playerName': returned.player.name,
          'injuryName': definition.name,
        },
        payload: {
          'playerId': returned.player.id,
          'injuryId': returned.injuryId,
        },
      );
    }
    for (final item in disciplineNotifications) {
      if (state.playerTeamId != item.teamId) continue;
      final notification = item.notification;
      if (notification.started) {
        state = messages.send(
          state,
          type: MessageType.suspensionStart,
          domain: MessageDomain.matchday,
          priority: notification.playerInStartingXi
              ? MessagePriority.urgent
              : MessagePriority.normal,
          args: {
            'playerName': notification.player.name,
            'games': notification.games,
          },
          payload: {
            'playerId': notification.player.id,
            'teamId': item.teamId,
            'games': notification.games,
            'reason': notification.reason,
            'playerInStartingXi': notification.playerInStartingXi,
          },
        );
      }
      if (notification.ended) {
        state = messages.send(
          state,
          type: MessageType.suspensionEnd,
          domain: MessageDomain.matchday,
          args: {'playerName': notification.player.name},
          payload: {'playerId': notification.player.id, 'teamId': item.teamId},
        );
      }
    }

    final inspiredId = result.inspiredPerformancePlayerId;
    final playerTeamId = state.playerTeamId;
    if (inspiredId != null &&
        playerTeamId != null &&
        (playerTeamId == result.homeTeamId ||
            playerTeamId == result.awayTeamId)) {
      final team = state.teamById(playerTeamId);
      final player = team?.roster.firstWhere(
        (candidate) => candidate.id == inspiredId,
        orElse: () => throw StateError('Missing inspired player'),
      );
      if (team != null && player != null) {
        final stat = result.playerStats.firstWhere(
          (candidate) => candidate.playerId == inspiredId,
          orElse: () => const PlayerMatchStats(playerId: ''),
        );
        state = messages.send(
          state,
          type: MessageType.playerEvent,
          kind: 'inspiredPerformance',
          domain: MessageDomain.playerEvent,
          args: {'playerName': player.name},
          payload: {
            'playerId': inspiredId,
            'teamId': team.id,
            'rating': stat.playerId.isEmpty ? 0.0 : stat.rating,
            'manOfTheMatch': true,
          },
          dedupKey: 'inspired:${match.id}:$inspiredId',
        );
      }
    }
    return teamEvents.afterMatch(state, result, saveSeed: saveSeed);
  }

  Team _applyFatigue(Team team, MatchResult result, {required int seasonYear}) {
    final statsByPlayer = {
      for (final stats in result.playerStats) stats.playerId: stats,
    };
    final injuries = {
      for (final injury in result.injuries.where((i) => i.teamId == team.id))
        injury.playerId: injury,
    };
    final roster = team.roster
        .map(
          (player) => applyMatchPlayerEffects(
            player: player,
            teamId: team.id,
            result: result,
            seasonYear: seasonYear,
            balance: balance,
            stats: statsByPlayer[player.id],
            matchInjury: injuries[player.id],
          ),
        )
        .toList();
    return team.copyWith(roster: roster);
  }

  /// Daily recovery is applied once by [_dailyRecovery]. Keeping this method
  /// side-effect free prevents teams in later fixtures from recovering twice
  /// when a round contains several matches.
  Team _recoverTeam(Team team) => team;

  LeagueState _resolveFreeAgencyDay(LeagueState league) {
    if (league.freeAgents.isEmpty) return league;
    final ai = TeamAiService(balance: balance);
    var state = league;
    final remaining = <Player>[];

    for (final player in state.freeAgents) {
      ({String teamId, ContractOffer offer, double score})? best;
      for (final team in state.teams) {
        // Player's own offers are submitted via the UI, not auto-bid here.
        if (team.id == state.playerTeamId) continue;
        if (team.roster.length >= balance.roster.maxSize) continue;
        final offer = ai.makeFaOffer(player, contracts);
        if (!capService.canSign(team: team, salary: offer.salary)) continue;
        if (contracts.evaluate(player, offer) != ContractReaction.accept) {
          continue;
        }
        final score = contracts.playerOfferScore(player, offer);
        if (best == null || score > best.score) {
          best = (teamId: team.id, offer: offer, score: score);
        }
      }

      if (best == null) {
        remaining.add(player);
        continue;
      }
      final winningTeam = state.teamById(best.teamId)!;
      final signed = contracts.signPlayer(
        team: winningTeam,
        player: player,
        offer: best.offer,
      );
      if (signed == null) {
        remaining.add(player);
        continue;
      }
      state = state.updateTeam(signed);
      state = messages.send(
        state,
        type: MessageType.contractSigned,
        domain: MessageDomain.contracts,
        titleKey: 'msg_contractSigned_fa_title',
        bodyKey: 'msg_contractSigned_fa_body',
        args: {'playerName': player.name, 'teamName': winningTeam.name},
      );
    }

    return state.copyWith(freeAgents: remaining);
  }

  LeagueState _dailyRecovery(
    LeagueState league, {
    Set<String> excludedTeamIds = const {},
  }) {
    var state = league;
    for (final team in league.teams) {
      if (excludedTeamIds.contains(team.id)) continue;
      final recoveryReturns = <({Player player, String injuryId})>[];
      final roster = team.roster.map((player) {
        final recovered = player.recoverBetweenMatches(balance);
        if (player.state.injured && !recovered.state.injured) {
          final injuryId = player.state.injury?.id;
          if (injuryId != null) {
            recoveryReturns.add((player: player, injuryId: injuryId));
          }
        }
        return recovered;
      }).toList();
      state = state.copyWith(
        teams: state.teams.map((candidate) {
          return candidate.id == team.id
              ? team.copyWith(roster: roster)
              : candidate;
        }).toList(),
      );
      for (final returned in recoveryReturns) {
        if (state.playerTeamId != team.id) continue;
        final definition = InjuryCatalog.byId(returned.injuryId);
        state = messages.send(
          state,
          type: MessageType.injuryReturn,
          domain: MessageDomain.health,
          args: {
            'playerName': returned.player.name,
            'injuryName': definition.name,
          },
          payload: {
            'playerId': returned.player.id,
            'injuryId': returned.injuryId,
          },
        );
      }
    }
    return state;
  }

  LeagueState _notifyStrengthTableChanges(
    LeagueState league,
    LeagueStrengthTable? previous,
    LeagueStrengthTable next,
  ) {
    final teamId = league.playerTeamId;
    if (teamId == null || previous == null) return league;
    final before = previous.entryFor(teamId);
    final after = next.entryFor(teamId);
    if (before == null ||
        after == null ||
        before.teamStatus == after.teamStatus) {
      return league;
    }
    return messages.send(
      league,
      type: MessageType.teamStatusChange,
      domain: MessageDomain.season,
      args: {
        'oldStatus': before.teamStatus.name,
        'newStatus': after.teamStatus.name,
        'expectedRank': after.expectedRank,
        'teamPower': after.teamPower,
      },
      payload: {
        'teamId': teamId,
        'oldStatus': before.teamStatus.name,
        'newStatus': after.teamStatus.name,
        'expectedRank': after.expectedRank,
        'teamPower': after.teamPower,
      },
      dedupKey:
          'teamStatus:${teamId}:${next.lastCalculatedWeek}:${next.lastCalculatedDay}',
    );
  }

  LeagueState _notifyMatchResult(
    LeagueState league,
    MatchResult result, {
    String? matchId,
  }) {
    final administrative = TeamManagementService.isWalkoverResult(result);
    final type = administrative
        ? MessageType.walkover
        : MessageType.matchResult;
    final responsibleTeamId = result.violatingTeamIds.isEmpty
        ? result.homeTeamId
        : result.violatingTeamIds.first;
    String? motm;
    final motmId = result.manOfTheMatchPlayerId;
    if (motmId != null) {
      for (final team in league.teams) {
        for (final player in team.roster) {
          if (player.id == motmId) {
            motm = player.name;
            break;
          }
        }
        if (motm != null) break;
      }
    }
    return messages.send(
      league,
      type: type,
      priority: administrative
          ? MessagePriority.urgent
          : MessagePriority.normal,
      args: {
        'homeTeam':
            league.teamById(result.homeTeamId)?.name ?? result.homeTeamId,
        'awayTeam':
            league.teamById(result.awayTeamId)?.name ?? result.awayTeamId,
        'homeGoals': result.homeGoals,
        'awayGoals': result.awayGoals,
        'team': league.teamById(responsibleTeamId)?.name ?? responsibleTeamId,
        'reason': result.reasonCode ?? 'administrative_result',
        'posA': result.homeStats.possession,
        'posB': result.awayStats.possession,
        'xgA': result.homeStats.xg,
        'xgB': result.awayStats.xg,
        'motm': motm ?? '—',
      },
      payload: {
        'matchId': matchId,
        'homeTeamId': result.homeTeamId,
        'awayTeamId': result.awayTeamId,
        'homeGoals': result.homeGoals,
        'awayGoals': result.awayGoals,
        'status': result.status.name,
        'reasonCode': result.reasonCode,
        'violatingTeamIds': result.violatingTeamIds,
        'homeStats': result.homeStats.toJson(),
        'awayStats': result.awayStats.toJson(),
        'manOfTheMatchPlayerId': result.manOfTheMatchPlayerId,
        'inspiredPerformancePlayerId': result.inspiredPerformancePlayerId,
      },
      dedupKey: matchId == null ? null : '${type.name}:result:$matchId',
    );
  }
}
