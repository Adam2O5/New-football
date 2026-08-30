import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/ai/ai_roster_management_service.dart';
import 'package:new_football/core/ai/ai_trade_service.dart';
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
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/discipline_service.dart';
import 'package:new_football/core/services/league_strength_service.dart';
import 'package:new_football/core/services/match_post_match_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/player_event_service.dart';
import 'package:new_football/core/services/team_management_service.dart';
import 'package:new_football/core/services/team_event_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/services/season_service.dart';

enum DaySimulationStopReason {
  advanced,
  playerMatch,
  calendarEvent,
  urgent,
  hourAdvanced,
}

enum DaySimulationMoment { beforeEvent, duringEvent }

class DaySimulationResult {
  const DaySimulationResult({
    required this.league,
    required this.pauseForUrgent,
    this.playerMatch,
    this.simulatedResults = const [],
    this.eventId,
    this.stopReason = DaySimulationStopReason.advanced,
    this.moment = DaySimulationMoment.beforeEvent,
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
  final DaySimulationStopReason stopReason;
  final DaySimulationMoment moment;
}

/// Advances the calendar by one day and resolves non-interactive events.
class DaySimulator {
  DaySimulator({
    this.balance = BalanceConfig.defaults,
    SimulationMatchEngine? matchEngine,
    AiMatchdayService? aiMatchdayService,
    AiTradeService? aiTradeService,
    AiRosterManagementService? rosterManagement,
    CalendarService? calendar,
    MatchContextFactory? contextFactory,
    MatchMessageEmitter? matchMessageEmitter,
    DevelopmentService? development,
    ScoutingService? scouting,
    ContractMarketService? contractMarket,
    MessageService? messages,
    TeamManagementService? teamManagement,
    PlayerEventService? playerEvents,
    TeamEventService? teamEvents,
    SeasonService? season,
  }) : matchEngine = matchEngine ?? SimulationMatchEngine(balance: balance),
       aiMatchdayService =
           aiMatchdayService ??
           AiMatchdayService(
             balance: balance,
             matchEngine:
                 matchEngine ?? SimulationMatchEngine(balance: balance),
           ),
       aiTradeService = aiTradeService ?? AiTradeService(balance: balance),
       rosterManagement =
           rosterManagement ??
           AiRosterManagementService(
             balance: balance,
             contractMarket: contractMarket,
             aiTradeService: aiTradeService,
           ),
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
       contractMarket =
           contractMarket ?? ContractMarketService(balance: balance),
       messages = messages ?? MessageService(),
       teamManagement = teamManagement ?? const TeamManagementService(),
       playerEvents =
           playerEvents ??
           PlayerEventService(balance: balance, messages: messages),
       teamEvents =
           teamEvents ?? TeamEventService(balance: balance, messages: messages),
       season = season ?? SeasonService(balance: balance);

  final BalanceConfig balance;
  final SimulationMatchEngine matchEngine;
  final AiMatchdayService aiMatchdayService;
  final AiTradeService aiTradeService;
  final AiRosterManagementService rosterManagement;
  final CalendarService calendar;
  final MatchContextFactory contextFactory;
  final MatchMessageEmitter matchMessageEmitter;
  final DevelopmentService development;
  final ScoutingService scouting;
  final ContractMarketService contractMarket;
  final MessageService messages;
  final TeamManagementService teamManagement;
  final PlayerEventService playerEvents;
  final TeamEventService teamEvents;
  final SeasonService season;

  LeagueState resolveCalendarEvent(
    LeagueState league,
    CalendarEventId eventId, {
    int saveSeed = 0,
  }) {
    return switch (eventId) {
      CalendarEventId.capUpdateTv => season.runCapUpdateTv(
        league,
        saveSeed: saveSeed,
      ),
      CalendarEventId.staffGrowth => season.runStaffGrowthAndRetire(league),
      CalendarEventId.awards => season.runAwards(league),
      CalendarEventId.retirements => season.runPlayerRetirements(
        league,
        saveSeed: saveSeed,
      ),
      CalendarEventId.scoutReport => season.runScoutReport(
        league,
        saveSeed: saveSeed,
      ),
      CalendarEventId.combine => season.runCombine(league, saveSeed: saveSeed),
      CalendarEventId.finalMock => season.runFinalMock(
        league,
        saveSeed: saveSeed,
      ),
      CalendarEventId.nextClassGeneration => season.runNextClassGeneration(
        league,
        saveSeed: saveSeed,
      ),
      CalendarEventId.freeAgencyOpen => season.runFreeAgencyOpen(league),
      CalendarEventId.tradeDeadline => league.copyWith(
        currentSeason: league.currentSeason.copyWith(tradeDeadlineAcked: true),
      ),
      CalendarEventId.lottery ||
      CalendarEventId.draft ||
      CalendarEventId.tradeWindowOpen ||
      CalendarEventId.contractExtensions => league,
    };
  }

  DaySimulationResult simulateDay(
    LeagueState league, {
    int saveSeed = 0,
    bool resolveContractMarket = true,
    bool simulatePlayerMatch = false,
  }) {
    final week = league.currentWeek;
    final day = league.currentDay;
    var state = league;
    final results = <MatchResult>[];
    ScheduledMatch? playerMatch;

    final phase = calendar.phaseForWeek(week);
    state = state.copyWith(
      currentSeason: state.currentSeason.copyWith(phase: phase),
    );

    while (true) {
      final due = CalendarEventRegistry.unresolvedEventsOn(
        state,
        week,
        day,
        balance: balance,
      );
      if (due.isEmpty) break;
      final event = due.first;
      if (event.execution == CalendarEventExecution.playerAction) {
        return DaySimulationResult(
          league: state,
          pauseForUrgent: false,
          eventId: event.id,
          stopReason: DaySimulationStopReason.calendarEvent,
          moment: DaySimulationMoment.duringEvent,
        );
      }
      final resolved = resolveCalendarEvent(
        state,
        event.id,
        saveSeed: saveSeed,
      );
      if (identical(resolved, state) ||
          !CalendarEventRegistry.isDone(resolved.currentSeason, event.id)) {
        break;
      }
      state = resolved;
    }

    if (phase == SeasonPhase.preseason) {
      final (nextWeek, nextDay) = calendar.advanceDay(week, day);
      return DaySimulationResult(
        league: state.copyWith(
          currentWeek: nextWeek,
          currentDay: nextDay,
          currentHour: calendar.initialHourForDate(nextWeek, nextDay),
          hourlyPlayerOfferUsed: false,
          hourlyStaffOfferUsed: false,
          currentSeason: state.currentSeason.copyWith(
            phase: calendar.phaseForWeek(nextWeek),
          ),
        ),
        pauseForUrgent: state.inbox.pendingUrgent.isNotEmpty,
      );
    }

    if (calendar.playInSlotsForDay(week, day).isNotEmpty) {
      state = season.advancePlayInForDate(
        state,
        week: week,
        day: day,
        saveSeed: saveSeed,
      );
    }
    if (phase == SeasonPhase.playoff &&
        state.currentSeason.playoffBrackets.isEmpty &&
        state.currentSeason.playInResults.isNotEmpty) {
      state = season.setupPlayoffs(state);
    }
    if (calendar.postseasonSlotForDay(week, day) != null) {
      state = season.advancePlayoffsForDate(
        state,
        week: week,
        day: day,
        saveSeed: saveSeed,
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

    if (_isMonthlyScoutingReport(week, day)) {
      state = _runMonthlyScoutingReport(state, saveSeed: saveSeed);
    }

    if (week == balance.calendar.tradeWindowOpenWeek && day == 1) {
      state = messages.send(
        state,
        type: MessageType.tradeWindowEvent,
        kind: 'open',
        domain: MessageDomain.trades,
        priority: MessagePriority.normal,
        titleKey: 'msg_tradeWindowEvent_open_title',
        bodyKey: 'msg_tradeWindowEvent_open_body',
      );
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
        state = rosterManagement.ensurePreMatchdaySafety(
          state,
          saveSeed: saveSeed,
        );
        final round = scheduleRoundForWeekSlot(week, slot);
        final outcome = _resolveRound(
          state,
          round,
          saveSeed,
          simulatePlayerMatch: simulatePlayerMatch,
        );
        state = outcome.league;
        results.addAll(outcome.results);
        playerMatch = outcome.playerMatch;
        if (playerMatch != null) {
          return DaySimulationResult(
            league: state,
            pauseForUrgent: true,
            playerMatch: playerMatch,
            simulatedResults: results,
            stopReason: DaySimulationStopReason.playerMatch,
            moment: DaySimulationMoment.duringEvent,
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

    if (resolveContractMarket) {
      state = contractMarket.resolveDay(state, saveSeed: saveSeed);
    }

    final (nextWeek, nextDay) = calendar.advanceDay(week, day);
    final nextPhase = calendar.phaseForWeek(nextWeek);
    state = state.copyWith(
      currentWeek: nextWeek,
      currentDay: nextDay,
      currentHour: calendar.initialHourForDate(nextWeek, nextDay),
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
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
          titleKey: 'msg_ovrDigest_digest_title',
          bodyKey: 'msg_ovrDigest_digest_body',
          args: {'count': 1, 'week': week},
          payload: {
            'playerId': change.playerId,
            'playerName': change.playerName,
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
        final draftClass = state.currentSeason.draftState!.draftClass;
        state = state.copyWith(
          teams: state.teams.map((team) {
            final evalStars = team.staff.scout?.attributes.evaluation ?? 0.0;
            return team.copyWith(
              scouting: scouting.tickKnowledge(
                team.scouting,
                evalStars,
                prospects: draftClass.prospects,
                seed: saveSeed,
                seasonYear: state.currentSeason.year,
                week: state.currentWeek,
                teamId: team.id,
              ),
            );
          }).toList(),
        );
      }

      // The market runs once at the same Sunday → Monday boundary as the
      // other weekly AI systems. It is headless and therefore also runs when
      // the player is not looking at TradeScreen.
      if (resolveContractMarket) {
        state = contractMarket.weeklyTick(state, saveSeed: saveSeed);
      }
      state = aiTradeService.weeklyTick(state, saveSeed: saveSeed).league;

      state = messages.send(
        state,
        type: MessageType.calendar,
        domain: MessageDomain.system,
        titleKey: 'msg_calendar_newWeek_title',
        bodyKey: 'msg_calendar_newWeek_body',
        args: {'week': nextWeek, 'phase': nextPhase.name},
      );
    }

    if (week == balance.calendar.seasonCycleWeeks && day == 7) {
      state = season.rolloverSeason(state, saveSeed: saveSeed);
      state = state.copyWith(
        currentHour: calendar.initialHourForDate(
          state.currentWeek,
          state.currentDay,
        ),
        hourlyPlayerOfferUsed: false,
        hourlyStaffOfferUsed: false,
      );
    }

    final urgent = state.inbox.pendingUrgent.isNotEmpty;
    return DaySimulationResult(
      league: state,
      pauseForUrgent: urgent,
      simulatedResults: results,
      stopReason: urgent
          ? DaySimulationStopReason.urgent
          : DaySimulationStopReason.advanced,
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
    return _notifyWalkover(state, result, matchId: match.id);
  }

  ({LeagueState league, List<MatchResult> results, ScheduledMatch? playerMatch})
  _resolveRound(
    LeagueState league,
    int round,
    int saveSeed, {
    bool simulatePlayerMatch = false,
  }) {
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
          (f.homeTeamId == playerId || f.awayTeamId == playerId) &&
          !simulatePlayerMatch) {
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
      final result = aiMatchdayService.simulateFullMatch(
        home: home,
        away: away,
        context: context,
        saveSeed: saveSeed,
        seasonYear: state.currentSeason.year,
        week: state.currentWeek,
        matchId: f.id,
        phase: SeasonPhase.regular,
        homeOpponentFormationHistory:
            AiMatchdayService.formationHistoryFromSchedule(
              state.currentSeason.schedule,
              home.id,
              away.id,
            ),
        awayOpponentFormationHistory:
            AiMatchdayService.formationHistoryFromSchedule(
              state.currentSeason.schedule,
              away.id,
              home.id,
            ),
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
          'severity': injury.injury.type.name,
          'days': injury.injury.daysTotal,
          'recoveryTime': injury.injury.daysTotal,
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
            'matches': notification.games,
            'reason': notification.reason,
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
      Player? player;
      if (team != null) {
        for (final candidate in team.roster) {
          if (candidate.id == inspiredId) {
            player = candidate;
            break;
          }
        }
      }
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

  bool _isMonthlyScoutingReport(int week, int day) {
    return day == 1 &&
        week >= 5 &&
        week < balance.calendar.tradeDeadlineWeek &&
        (week - 1) % 4 == 0;
  }

  LeagueState _runMonthlyScoutingReport(
    LeagueState league, {
    required int saveSeed,
  }) {
    final draftClass = league.currentSeason.draftState?.draftClass;
    if (draftClass == null) return league;

    final ranked = [...draftClass.prospects]
      ..sort((a, b) {
        final grade = b.scoutGrade.compareTo(a.scoutGrade);
        return grade != 0 ? grade : a.id.compareTo(b.id);
      });
    final teams = league.teams.map((team) {
      if (team.isPlayerControlled) return team;
      final coverage = team.staff.scout?.attributes.coverage ?? 0.0;
      return team.copyWith(
        scouting: scouting.updateMonthlyWatchlist(
          team.scouting,
          rankedProspects: ranked,
          coverageStars: coverage,
          seed: saveSeed,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          teamId: team.id,
        ),
      );
    }).toList();

    return messages.send(
      league.copyWith(teams: teams),
      type: MessageType.scoutReport,
      kind: 'monthly',
      domain: MessageDomain.draft,
      args: {'draftYear': draftClass.year, 'count': ranked.length},
      payload: {'draftYear': draftClass.year, 'count': ranked.length},
      groupKey: 'scout:monthly:${league.currentSeason.year}',
      dedupKey:
          'scoutReport:monthly:${league.currentSeason.year}:${league.currentWeek}',
    );
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
          'teamStatus:$teamId:${next.lastCalculatedWeek}:${next.lastCalculatedDay}',
    );
  }

  LeagueState _notifyWalkover(
    LeagueState league,
    MatchResult result, {
    String? matchId,
  }) {
    if (!TeamManagementService.isWalkoverResult(result)) {
      return league;
    }

    final responsibleTeamId = result.violatingTeamIds.isEmpty
        ? result.homeTeamId
        : result.violatingTeamIds.first;
    final playerTeamId = league.playerTeamId;
    final opponentTeamId = playerTeamId == result.homeTeamId
        ? result.awayTeamId
        : result.homeTeamId;

    return messages.send(
      league,
      type: MessageType.walkover,
      priority: MessagePriority.urgent,
      args: {
        'homeTeam':
            league.teamById(result.homeTeamId)?.name ?? result.homeTeamId,
        'awayTeam':
            league.teamById(result.awayTeamId)?.name ?? result.awayTeamId,
        'team': league.teamById(responsibleTeamId)?.name ?? responsibleTeamId,
        'reason': result.reasonCode ?? 'administrative_result',
        'opponentName': league.teamById(opponentTeamId)?.name ?? opponentTeamId,
      },
      payload: {
        'matchId': matchId,
        'homeTeamId': result.homeTeamId,
        'awayTeamId': result.awayTeamId,
        'reasonCode': result.reasonCode,
        'violatingTeamIds': result.violatingTeamIds,
      },
      dedupKey: matchId == null ? null : 'walkover:$matchId',
    );
  }
}
