import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/tactics/lineup_slots.dart';
import 'package:new_football/core/services/contract_period_service.dart';
import 'package:new_football/core/services/draft_trade_service.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/player_event_service.dart';
import 'package:new_football/core/services/team_event_service.dart';
import 'package:new_football/core/services/trade_service.dart';

/// One step of the "advance the calendar" pipeline.
///
/// [league] is always safe to publish, including when [result] is null because
/// the step stopped before simulating anything.
class DayStepOutput {
  const DayStepOutput({required this.league, this.result});

  final LeagueState league;

  /// Null when the step did not simulate a day — today's start-of-day package
  /// surfaced an urgent message, or the date is not in hourly contract mode.
  final DaySimulationResult? result;
}

/// The complete "advance one day" path as a pure function of [LeagueState].
///
/// Why [DayPipeline.advanceHour] stopped, which decides whether the caller
/// publishes the returned state and whether it has to run a full day next.
enum HourStepOutcome {
  /// The current date is not one of the hourly contract-market days.
  notHourly,

  /// Start-of-hour delivery surfaced an urgent message; nothing was resolved.
  blockedOnUrgent,

  /// The hour was resolved and the clock moved to the next one.
  hourAdvanced,

  /// The last hour of the day was resolved. The calendar deliberately does
  /// not move here — the caller runs [DayPipeline.advanceDay] so end-of-day
  /// work has a single owner.
  lastHourReached,
}

class HourStepOutput {
  const HourStepOutput({
    required this.outcome,
    required this.league,
    this.result,
  });

  final HourStepOutcome outcome;
  final LeagueState league;
  final DaySimulationResult? result;
}

/// Advancing a day is more than [DaySimulator.simulateDay]: expiring
/// negotiations, trade offers and open event decisions runs before and after
/// it. Those steps used to live in `GameController`, mixed with Riverpod reads
/// and persistence. Collected here they form a self-contained unit that can be
/// moved to a background isolate — every service it needs is constructible
/// without arguments and holds no state of its own.
class DayPipeline {
  DayPipeline({
    this.balance = BalanceConfig.defaults,
    CalendarService? calendar,
    DaySimulator? days,
    NegotiationService? negotiations,
    DraftTradeService? draftTrades,
    TradeService? trades,
    PlayerEventService? playerEvents,
    TeamEventService? teamEvents,
    ContractMarketService? contractMarket,
  }) : calendar = calendar ?? CalendarService(balance: balance),
       negotiations = negotiations ?? const NegotiationService(),
       draftTrades =
           draftTrades ??
           DraftTradeService(
             calendar: calendar ?? CalendarService(balance: balance),
           ),
       trades = trades ?? TradeService(balance: balance),
       playerEvents = playerEvents ?? PlayerEventService(balance: balance),
       teamEvents = teamEvents ?? TeamEventService(balance: balance),
       contractMarket =
           contractMarket ??
           ContractMarketService(
             balance: balance,
             calendar: calendar ?? CalendarService(balance: balance),
           ),
       days =
           days ??
           DaySimulator(
             balance: balance,
             calendar: calendar,
             playerEvents: playerEvents,
             teamEvents: teamEvents,
             contractMarket: contractMarket,
           );

  final BalanceConfig balance;
  final CalendarService calendar;
  final DaySimulator days;
  final NegotiationService negotiations;
  final DraftTradeService draftTrades;
  final TradeService trades;
  final PlayerEventService playerEvents;
  final TeamEventService teamEvents;
  final ContractMarketService contractMarket;

  /// Delivers everything due at the start of the current day or hour.
  ///
  /// [resolveExpired] is false right after a simulated day: the messages the
  /// simulation just created are already in the inbox and must not have their
  /// deadlines applied at the same boundary, before the player has seen them.
  LeagueState deliverStartOfDay(
    LeagueState league, {
    int? hour,
    int saveSeed = 0,
    bool resolveExpired = true,
  }) {
    var state = league.copyWith(
      inbox: league.inbox.deliverScheduled(
        league.currentWeek,
        league.currentDay,
        hour: hour,
      ),
    );
    if (!resolveExpired) return state;
    state = negotiations.expireAt(
      league: state,
      seasonYear: state.currentSeason.year,
      week: state.currentWeek,
      day: state.currentDay,
      hour: state.currentHour ?? 0,
    );
    state = draftTrades.expireOffers(state);
    state = trades.expireOffers(state);
    state = teamEvents.resolveExpiredDecisions(state, saveSeed: saveSeed);
    return playerEvents.resolveExpiredDecisions(state, saveSeed: saveSeed);
  }

  bool hasPendingUrgent(LeagueState league) =>
      league.inbox.pendingUrgent.isNotEmpty;

  /// Start-of-day delivery, one simulated day, then delivery of what the day
  /// produced. Stops before simulating if the delivery raised an urgent
  /// message and [blockOnPendingUrgent] is set.
  DayStepOutput advanceDay(
    LeagueState league, {
    required int saveSeed,
    bool blockOnPendingUrgent = true,
    bool resolveContractMarket = true,
  }) {
    final delivered = deliverStartOfDay(
      league,
      hour: league.currentHour,
      saveSeed: saveSeed,
    );
    if (blockOnPendingUrgent && hasPendingUrgent(delivered)) {
      return DayStepOutput(league: delivered);
    }

    final result = days.simulateDay(
      delivered,
      saveSeed: saveSeed,
      resolveContractMarket: resolveContractMarket,
    );
    final advanced = deliverStartOfDay(
      reconcileLeagueLineups(
        ContractPeriodService(balance: balance).normalizeLeague(result.league),
      ),
      hour: result.league.currentHour,
      saveSeed: saveSeed,
      resolveExpired: false,
    );
    return DayStepOutput(
      league: advanced,
      result: DaySimulationResult(
        league: advanced,
        pauseForUrgent: advanced.inbox.pendingUrgent.isNotEmpty,
        playerMatch: result.playerMatch,
        simulatedResults: result.simulatedResults,
        eventId: result.eventId,
        stopReason: result.stopReason,
        moment: result.moment,
      ),
    );
  }

  /// Advances one offer hour of the extension/FA phase-I days.
  HourStepOutput advanceHour(
    LeagueState league, {
    required int saveSeed,
    bool blockOnPendingUrgent = true,
  }) {
    final delivered = deliverStartOfDay(
      league,
      hour: league.currentHour,
      saveSeed: saveSeed,
    );
    if (!calendar.isHourlyContractMode(
      delivered.currentWeek,
      delivered.currentDay,
    )) {
      return HourStepOutput(
        outcome: HourStepOutcome.notHourly,
        league: league,
      );
    }
    if (blockOnPendingUrgent && hasPendingUrgent(delivered)) {
      return HourStepOutput(
        outcome: HourStepOutcome.blockedOnUrgent,
        league: delivered,
      );
    }

    final hour = delivered.currentHour ?? 1;
    final resolved = contractMarket.resolveHour(
      delivered,
      hour: hour,
      saveSeed: saveSeed,
    );
    if (calendar.isLastHour(
      delivered.currentWeek,
      delivered.currentDay,
      hour,
    )) {
      return HourStepOutput(
        outcome: HourStepOutcome.lastHourReached,
        league: resolved.copyWith(currentHour: balance.contracts.hoursPerDay),
      );
    }

    final next = resolved.copyWith(
      currentHour: hour + 1,
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
    );
    return HourStepOutput(
      outcome: HourStepOutcome.hourAdvanced,
      league: next,
      result: DaySimulationResult(
        league: next,
        pauseForUrgent: false,
        stopReason: DaySimulationStopReason.hourAdvanced,
      ),
    );
  }

  LeagueState resolveCalendarEvent(
    LeagueState league,
    CalendarEventId eventId, {
    int saveSeed = 0,
  }) => days.resolveCalendarEvent(league, eventId, saveSeed: saveSeed);

  LeagueState applyPlayerMatchResult(
    LeagueState league,
    ScheduledMatch match,
    MatchResult result, {
    int saveSeed = 0,
  }) => days.applyPlayerMatchResult(league, match, result, saveSeed: saveSeed);

  /// Resolves the player's own fixture headlessly during a calendar
  /// fast-forward — the same engine call `DaySimulator` makes for AI-vs-AI
  /// fixtures, applied through the regular post-match path.
  ///
  /// [result] is null when a team of the fixture cannot be resolved, which the
  /// caller treats as a hard stop.
  ({LeagueState league, MatchResult? result}) autoSimulatePlayerMatch(
    LeagueState league,
    ScheduledMatch match, {
    required int saveSeed,
  }) {
    final home = league.teamById(match.homeTeamId);
    final away = league.teamById(match.awayTeamId);
    if (home == null || away == null) return (league: league, result: null);

    final isPostseason =
        match.id.startsWith('playIn:') || match.id.startsWith('playoff:');
    final context = isPostseason
        ? days.contextFactory.createForPostseason(
            home: home,
            away: away,
            seasonYear: league.currentSeason.year,
            matchId: match.id,
            saveSeed: saveSeed,
            stake: days.season.stakeForPendingMatch(league, match.id),
            week: league.currentWeek,
          )
        : days.contextFactory.create(
            league: league,
            match: match,
            saveSeed: saveSeed,
            stake: MatchStake.regular,
          );
    final result = days.aiMatchdayService.simulateFullMatch(
      home: home,
      away: away,
      context: context,
      saveSeed: saveSeed,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      matchId: match.id,
      phase: league.currentSeason.phase,
    );
    return (
      league: applyPlayerMatchResult(league, match, result, saveSeed: saveSeed),
      result: result,
    );
  }
}
