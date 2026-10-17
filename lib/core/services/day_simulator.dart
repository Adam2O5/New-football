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

part 'day_simulation_result.dart';
part 'day_weekly_boundary.dart';
part 'day_world_updates.dart';
part 'day_match_result_application.dart';
part 'day_round_resolution.dart';

/// Advances the calendar by one day and resolves non-interactive events.
class DaySimulator
    with
        _DayWeeklyBoundary,
        _DayWorldUpdates,
        _DayMatchResultApplication,
        _DayRoundResolution {
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

  @override
  final BalanceConfig balance;
  final SimulationMatchEngine matchEngine;
  @override
  final AiMatchdayService aiMatchdayService;
  @override
  final AiTradeService aiTradeService;
  final AiRosterManagementService rosterManagement;
  @override
  final CalendarService calendar;
  @override
  final MatchContextFactory contextFactory;
  @override
  final MatchMessageEmitter matchMessageEmitter;
  @override
  final DevelopmentService development;
  @override
  final ScoutingService scouting;
  @override
  final ContractMarketService contractMarket;
  @override
  final MessageService messages;
  @override
  final TeamManagementService teamManagement;
  @override
  final PlayerEventService playerEvents;
  @override
  final TeamEventService teamEvents;
  @override
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
      CalendarEventId.staffGrowth => season.runStaffGrowthAndRetire(
        league,
        saveSeed: saveSeed,
      ),
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

    if (week == balance.calendar.playInWeek && day == 7) {
      state = season.revealPlayoffSeed8(state);
    }

    if (calendar.playInSlotsForDay(week, day).isNotEmpty) {
      final advanced = season.advancePlayInForDate(
        state,
        week: week,
        day: day,
        saveSeed: saveSeed,
      );
      state = advanced.league;
      if (advanced.playerMatch != null) {
        return DaySimulationResult(
          league: state,
          pauseForUrgent: true,
          playerMatch: advanced.playerMatch,
          stopReason: DaySimulationStopReason.playerMatch,
          moment: DaySimulationMoment.duringEvent,
        );
      }
    }
    if (calendar.postseasonSlotForDay(week, day) != null) {
      final advanced = season.advancePlayoffsForDate(
        state,
        week: week,
        day: day,
        saveSeed: saveSeed,
      );
      state = advanced.league;
      if (advanced.playerMatch != null) {
        return DaySimulationResult(
          league: state,
          pauseForUrgent: true,
          playerMatch: advanced.playerMatch,
          stopReason: DaySimulationStopReason.playerMatch,
          moment: DaySimulationMoment.duringEvent,
        );
      }
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

    state = season.finalizeRegularSeason(state);

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

    // Week boundary: Sunday → Monday. Shared with `applyPlayerMatchResult`
    // so it isn't silently skipped on weeks where the player's own match
    // (regular season, play-in, or playoff) falls on day 7 and this
    // function returns early before reaching this point.
    if (day == 7) {
      state = _runWeeklyBoundary(
        state,
        week: week,
        phase: phase,
        saveSeed: saveSeed,
        resolveContractMarket: resolveContractMarket,
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

  LeagueState applyPlayerMatchResult(
    LeagueState league,
    ScheduledMatch match,
    MatchResult result, {
    int saveSeed = 0,
    bool resolveContractMarket = true,
  }) {
    final week = league.currentWeek;
    final day = league.currentDay;
    final phase = calendar.phaseForWeek(week);
    var state = match.id.startsWith('playIn:')
        ? season.applyPlayInPlayerResult(
            league,
            matchId: match.id,
            rawResult: result,
            saveSeed: saveSeed,
          )
        : match.id.startsWith('playoff:')
        ? season.applyPlayoffPlayerResult(
            league,
            matchId: match.id,
            rawResult: result,
            saveSeed: saveSeed,
          )
        : _applyResult(league, match, result, saveSeed: saveSeed);
    state = season.finalizeRegularSeason(state);
    // Resolve the match day's market before advancing, as in simulateDay.
    if (resolveContractMarket) {
      state = contractMarket.resolveDay(state, saveSeed: saveSeed);
    }
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
    state = _notifyWalkover(state, result, matchId: match.id);

    // Week boundary can land on a day resolved through this path (the
    // player's own match falling on day 7) instead of `simulateDay` — run
    // the same weekly systems here so they are never silently skipped.
    if (day == 7) {
      state = _runWeeklyBoundary(
        state,
        week: week,
        phase: phase,
        saveSeed: saveSeed,
        resolveContractMarket: resolveContractMarket,
      );
    }
    return state;
  }
}
