import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/ai/ai_roster_management_service.dart';
import 'package:new_football/core/ai/ai_trade_service.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/draft_service.dart';
import 'package:new_football/core/services/draft_trade_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/player_event_service.dart';
import 'package:new_football/core/services/team_event_service.dart';
import 'package:new_football/core/simulation/match_context_factory.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/core/services/trade_service.dart';
import 'package:new_football/data/save_repository.dart';

final saveRepositoryProvider = Provider((ref) {
  return SaveRepository();
});

final gameFactoryProvider = Provider((ref) => GameFactory());

final calendarServiceProvider = Provider((ref) => const CalendarService());

final matchContextFactoryProvider = Provider(
  (ref) => MatchContextFactory(calendar: ref.watch(calendarServiceProvider)),
);

final matchEngineProvider = Provider((ref) => SimulationMatchEngine());

final aiMatchdayServiceProvider = Provider(
  (ref) => AiMatchdayService(matchEngine: ref.watch(matchEngineProvider)),
);

final aiTradeServiceProvider = Provider(
  (ref) => AiTradeService(tradeService: ref.watch(tradeServiceProvider)),
);

final aiRosterManagementServiceProvider = Provider(
  (ref) => AiRosterManagementService(
    contractMarket: ref.watch(contractMarketServiceProvider),
    tradeService: ref.watch(tradeServiceProvider),
    aiTradeService: ref.watch(aiTradeServiceProvider),
  ),
);

final playerEventServiceProvider = Provider((ref) => PlayerEventService());

final teamEventServiceProvider = Provider((ref) => TeamEventService());

final daySimulatorProvider = Provider((ref) {
  return DaySimulator(
    matchEngine: ref.watch(matchEngineProvider),
    aiMatchdayService: ref.watch(aiMatchdayServiceProvider),
    aiTradeService: ref.watch(aiTradeServiceProvider),
    rosterManagement: ref.watch(aiRosterManagementServiceProvider),
    playerEvents: ref.watch(playerEventServiceProvider),
    teamEvents: ref.watch(teamEventServiceProvider),
    contractMarket: ref.watch(contractMarketServiceProvider),
  );
});

final seasonServiceProvider = Provider(
  (ref) => SeasonService(
    matchEngine: ref.watch(matchEngineProvider),
    aiMatchdayService: ref.watch(aiMatchdayServiceProvider),
    teamEvents: ref.watch(teamEventServiceProvider),
    rosterManagement: ref.watch(aiRosterManagementServiceProvider),
    draftTrade: ref.watch(draftTradeServiceProvider),
  ),
);

final draftServiceProvider = Provider((ref) => DraftService());

final draftTradeServiceProvider = Provider(
  (ref) => DraftTradeService(calendar: ref.watch(calendarServiceProvider)),
);

final staffServiceProvider = Provider((ref) => StaffService());

final scoutingServiceProvider = Provider((ref) => ScoutingService());

final contractServiceProvider = Provider((ref) => ContractService());

final negotiationServiceProvider = Provider(
  (ref) => const NegotiationService(),
);

final tradeServiceProvider = Provider((ref) => TradeService());

final contractMarketServiceProvider = Provider(
  (ref) => ContractMarketService(
    calendar: ref.watch(calendarServiceProvider),
    contracts: ref.watch(contractServiceProvider),
    staff: ref.watch(staffServiceProvider),
    negotiations: ref.watch(negotiationServiceProvider),
  ),
);

final savesListProvider = FutureProvider.autoDispose<List<GameSaveMeta>>((
  ref,
) async {
  return ref.watch(saveRepositoryProvider).listSaves();
});

/// Why a batch simulation (`GameController.simulateTo...`) stopped.
enum SimulationStopReason {
  /// Target date / phase end reached without any blocking event.
  reachedTarget,

  /// The player's team has a match today — UI should open matchday.
  playerMatch,

  /// An urgent inbox message needs attention.
  urgent,

  /// The next registered calendar event needs player input (e.g. draft
  /// pick) — UI should navigate there. Draft has no separate stop reason:
  /// it is just a `playerAction` event like any other.
  event,

  /// User cancelled the batch simulation.
  cancelled,

  /// No active save (nothing to simulate).
  noSave,
}

class BatchSimulationResult {
  const BatchSimulationResult({
    required this.stopReason,
    required this.daysSimulated,
    this.lastResult,
    this.eventId,
  });

  final SimulationStopReason stopReason;
  final int daysSimulated;
  final DaySimulationResult? lastResult;

  /// Set when [stopReason] is [SimulationStopReason.event] — the id of the
  /// `CalendarEventSlot` that needs attention. `null` when the stop reason is
  /// the player's match or other non-calendar reasons.
  final CalendarEventId? eventId;
}

/// Next actionable thing on the calendar: the player's upcoming fixture, or
/// the next unresolved `CalendarEventSlot`. Drives the contextual button on
/// `HomeScreen` — `kind` decides which button(s) are shown.
class UpcomingAction {
  const UpcomingAction({
    required this.kind,
    required this.id,
    this.calendarEventId,
    required this.week,
    required this.day,
  });

  final CalendarEventKind kind;

  /// Registry event id, or `'match'` for the player's next fixture.
  final String id;

  /// If this action corresponds to a calendar event from the registry, this
  /// is its typed id. `null` for the player's match.
  final CalendarEventId? calendarEventId;
  final int week;
  final int day;
}

enum _MessageOperationKind { markRead, acknowledge, decision }

class _MessageOperationKey {
  const _MessageOperationKey(this.messageId, this.kind);

  final String messageId;
  final _MessageOperationKind kind;

  @override
  bool operator ==(Object other) =>
      other is _MessageOperationKey &&
      other.messageId == messageId &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(messageId, kind);
}

class GameController extends StateNotifier<AsyncValue<GameSave?>> {
  GameController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  SaveRepository get _repo => _ref.read(saveRepositoryProvider);
  DaySimulator get _days => _ref.read(daySimulatorProvider);
  PlayerEventService get _playerEvents => _ref.read(playerEventServiceProvider);
  TeamEventService get _teamEvents => _ref.read(teamEventServiceProvider);
  SeasonService get _season => _ref.read(seasonServiceProvider);
  CalendarService get _calendar => _ref.read(calendarServiceProvider);
  ContractMarketService get _market => _ref.read(contractMarketServiceProvider);
  DraftTradeService get _draftTrades => _ref.read(draftTradeServiceProvider);

  /// Every state mutation and persistence operation is appended to this
  /// future. Errors are returned to the operation that caused them, while the
  /// tail itself always completes successfully so a failed save cannot poison
  /// later mutations.
  Future<void> _mutationQueue = Future<void>.value();

  /// Invalidates callbacks that belong to a save which has been cleared or
  /// replaced while an asynchronous repository operation was pending.
  int _saveGeneration = 0;

  /// Message operations are keyed by message id and logical operation kind.
  /// A duplicate input receives the original future instead of entering the
  /// mutation queue a second time.
  final Map<_MessageOperationKey, Future<void>> _inFlightMessageOperations = {};

  GameSave? get save => state.value;

  Future<T> _enqueueMutation<T>(Future<T> Function() operation) {
    final queued = _mutationQueue.then<T>((_) => operation());
    _mutationQueue = queued.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return queued;
  }

  Future<void> _runMessageOperation(
    String messageId,
    _MessageOperationKind kind,
    Future<void> Function() operation,
  ) {
    final key = _MessageOperationKey(messageId, kind);
    final existing = _inFlightMessageOperations[key];
    if (existing != null) return existing;

    final future = _enqueueMutation(operation);
    _inFlightMessageOperations[key] = future;
    future.then<void>(
      (_) => _removeMessageOperation(key, future),
      onError: (Object error, StackTrace stackTrace) {
        _removeMessageOperation(key, future);
      },
    );
    return future;
  }

  void _removeMessageOperation(
    _MessageOperationKey key,
    Future<void> operation,
  ) {
    if (identical(_inFlightMessageOperations[key], operation)) {
      _inFlightMessageOperations.remove(key);
    }
  }

  GameMessage? _messageById(LeagueState league, String id) {
    for (final message in league.inbox.messages) {
      if (message.id == id) return message;
    }
    return null;
  }

  Future<void> createNewGame(NewGameRequest request) async {
    _saveGeneration++;
    _inFlightMessageOperations.clear();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final game = _ref.read(gameFactoryProvider).create(request);
      await _repo.save(game);
      return game;
    });
  }

  Future<void> loadGame(String id) async {
    _saveGeneration++;
    _inFlightMessageOperations.clear();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => _repo.load(id));
  }

  Future<void> persist() {
    final generation = _saveGeneration;
    return _enqueueMutation(() async {
      if (generation != _saveGeneration) return;
      final current = save;
      if (current == null) return;
      await _repo.save(current);
    });
  }

  Future<void> updateLeague(
    LeagueState Function(LeagueState) transform, {
    bool autosave = true,
  }) {
    final generation = _saveGeneration;
    return _enqueueMutation(
      () => _updateLeagueInQueue(
        transform,
        generation: generation,
        autosave: autosave,
      ),
    );
  }

  Future<void> _updateLeagueInQueue(
    LeagueState Function(LeagueState) transform, {
    required int generation,
    bool autosave = true,
    bool skipIfUnchanged = false,
  }) async {
    if (generation != _saveGeneration) return;
    final current = save;
    if (current == null) return;
    final league = transform(current.leagueState);
    if (skipIfUnchanged && league == current.leagueState) return;
    final next = current.copyWith(
      leagueState: league,
      meta: current.meta.copyWith(
        updatedAt: DateTime.now(),
        seasonYear: league.currentSeason.year,
        phase: league.currentSeason.phase,
        playerTeamName: league.playerTeam?.name,
      ),
    );

    // Batch simulation deliberately publishes working state without saving
    // each intermediate day. All autosaved mutations, including message
    // operations, commit to the repository before exposing their result.
    final shouldPersist = autosave && !_batchSimulationActive;
    if (shouldPersist) {
      await _repo.save(next);
      if (generation != _saveGeneration) return;
    }
    if (generation == _saveGeneration) {
      state = AsyncValue.data(next);
    }
  }

  bool get _batchSimulationActive => _activeSimulationSession != null;
  _SimulationSession? _activeSimulationSession;
  int _nextSimulationRunId = 0;

  _SimulationSession _startSimulationSession() {
    // A second request invalidates the old session rather than resetting a
    // shared flag. The old loop will observe that it is no longer current
    // after its next await and cannot publish stale feedback or clear the new
    // session in its finally block.
    _activeSimulationSession?.cancelRequested = true;
    final session = _SimulationSession(_nextSimulationRunId++);
    _activeSimulationSession = session;
    return session;
  }

  bool _isCurrentSimulationSession(_SimulationSession session) =>
      identical(_activeSimulationSession, session);

  /// Requests that an in-progress batch stop as soon as possible (checked
  /// between simulated days).
  void cancelSimulation() {
    _activeSimulationSession?.cancelRequested = true;
  }

  bool _hasPendingUrgent(LeagueState league) =>
      league.inbox.pendingUrgent.isNotEmpty;

  bool _hasScheduledUrgentDue(LeagueState league) {
    final hour = league.currentHour;
    return league.inbox.scheduled.any((message) {
      final beforeDate =
          message.week < league.currentWeek ||
          (message.week == league.currentWeek &&
              message.day < league.currentDay);
      final sameDate =
          message.week == league.currentWeek &&
          message.day == league.currentDay;
      final hourDue =
          message.hour == null || hour == null || message.hour! <= hour;
      return message.priority == MessagePriority.urgent &&
          (beforeDate || (sameDate && hourDue));
    });
  }

  LeagueState _deliverStartOfDay(
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
    state = _ref
        .read(negotiationServiceProvider)
        .expireAt(
          league: state,
          seasonYear: state.currentSeason.year,
          week: state.currentWeek,
          day: state.currentDay,
          hour: state.currentHour ?? 0,
        );
    state = _draftTrades.expireOffers(state);
    state = _ref.read(tradeServiceProvider).expireOffers(state);
    state = _teamEvents.resolveExpiredDecisions(state, saveSeed: saveSeed);
    return _playerEvents.resolveExpiredDecisions(state, saveSeed: saveSeed);
  }

  LeagueState _setClockForDate(LeagueState league) {
    final hour = _calendar.initialHourForDate(
      league.currentWeek,
      league.currentDay,
    );
    return league.copyWith(
      currentHour: hour,
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
    );
  }

  /// Advances the calendar by exactly one day: no phase hooks, no
  /// calendar-event auto-resolution, no auto-simulating the player's match.
  /// This is the raw primitive `simulateToEvent`/`simulateToDate` build on.
  Future<DaySimulationResult?> advanceOneDay({
    bool resolveContractMarket = true,
  }) async {
    final current = save;
    if (current == null) return null;

    var league = _deliverStartOfDay(
      current.leagueState,
      hour: current.leagueState.currentHour,
      saveSeed: current.saveSeed,
    );
    if (_hasPendingUrgent(league)) {
      await updateLeague((_) => league);
      return null;
    }
    final calendar = _calendar;
    if (calendar
        .playInSlotsForDay(league.currentWeek, league.currentDay)
        .isNotEmpty) {
      league = _season.advancePlayInForDate(
        league,
        week: league.currentWeek,
        day: league.currentDay,
        saveSeed: current.saveSeed,
      );
    }
    if (calendar.phaseForWeek(league.currentWeek) == SeasonPhase.playoff &&
        league.currentSeason.playoffBrackets.isEmpty &&
        league.currentSeason.playInResults.isNotEmpty) {
      league = _season.setupPlayoffs(league);
    }
    if (calendar.postseasonSlotForDay(league.currentWeek, league.currentDay) !=
        null) {
      league = _season.advancePlayoffsForDate(
        league,
        week: league.currentWeek,
        day: league.currentDay,
        saveSeed: current.saveSeed,
      );
    }

    final result = _days.simulateDay(
      league,
      saveSeed: current.saveSeed,
      resolveContractMarket: resolveContractMarket,
    );
    var updatedLeague = result.league;
    final isCycleEnd =
        current.leagueState.currentWeek ==
            calendar.balance.calendar.seasonCycleWeeks &&
        current.leagueState.currentDay == 7;
    if (isCycleEnd) {
      updatedLeague = _season.rolloverSeason(
        updatedLeague,
        saveSeed: current.saveSeed,
      );
    }
    updatedLeague = _setClockForDate(updatedLeague);
    updatedLeague = _deliverStartOfDay(
      updatedLeague,
      hour: updatedLeague.currentHour,
      saveSeed: current.saveSeed,
      // Messages created by the day simulation are already in the inbox. Do
      // not expire them at the same boundary before the player can see them;
      // the next real start-of-day pass handles the deadline.
      resolveExpired: false,
    );
    if (isCycleEnd) {
      final updatedResult = DaySimulationResult(
        league: updatedLeague,
        pauseForUrgent: updatedLeague.inbox.pendingUrgent.isNotEmpty,
        playerMatch: result.playerMatch,
        simulatedResults: result.simulatedResults,
        eventId: result.eventId,
      );
      await updateLeague((_) => updatedLeague);
      return updatedResult;
    }
    await updateLeague((_) => updatedLeague);
    return result;
  }

  /// Advances one offer hour during extensions/FA phase I. The tenth hour
  /// delegates to the regular end-of-day pipeline, so matches and events are
  /// still resolved exactly once at the end of the calendar day.
  Future<DaySimulationResult?> advanceOneHour() async {
    final current = save;
    if (current == null) return null;

    var league = _deliverStartOfDay(
      current.leagueState,
      hour: current.leagueState.currentHour,
      saveSeed: current.saveSeed,
    );
    if (!_calendar.isHourlyContractMode(
      league.currentWeek,
      league.currentDay,
    )) {
      return null;
    }
    if (_hasPendingUrgent(league)) {
      await updateLeague((_) => league);
      return null;
    }

    final hour = league.currentHour ?? 1;
    final resolved = _market.resolveHour(
      league,
      hour: hour,
      saveSeed: current.saveSeed,
    );
    if (hour >= _calendar.balance.contracts.hoursPerDay) {
      await updateLeague(
        (_) => resolved.copyWith(
          currentHour: _calendar.balance.contracts.hoursPerDay,
        ),
        autosave: true,
      );
      return advanceOneDay(resolveContractMarket: false);
    }

    final next = resolved.copyWith(
      currentHour: hour + 1,
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
    );
    await updateLeague((_) => next);
    return DaySimulationResult(league: next, pauseForUrgent: false);
  }

  /// Earliest unplayed fixture of the player's team, mapped to its
  /// calendar (week, day). Uses the deterministic actual match day for the
  /// fixture's week/slot, so HomeScreen and batch simulation point to the
  /// same date as `DaySimulator`.
  (int week, int day)? _nextPlayerMatchDate(LeagueState league) {
    final playerId = league.playerTeamId;
    if (playerId == null) return null;
    final fixtures =
        league.currentSeason.schedule
            .where(
              (m) =>
                  (m.homeTeamId == playerId || m.awayTeamId == playerId) &&
                  m.result == null,
            )
            .toList()
          ..sort((a, b) => a.round.compareTo(b.round));
    if (fixtures.isEmpty) return null;
    final round = fixtures.first.round;
    if (round < 1 || round > 58) return null;

    final (week, slot) = weekSlotForRound(round);
    final matchDays = matchDaysForWeek(week);

    return (week, slot == 0 ? matchDays.midweekDay : matchDays.weekendDay);
  }

  /// Next actionable item on the calendar: the player's fixture or the next
  /// unresolved `CalendarEventSlot`, whichever comes first. Returns `null`
  /// only if neither exists (e.g. no player team and no pending events).
  UpcomingAction? nextEvent({LeagueState? league}) {
    final state = league ?? save?.leagueState;
    if (state == null) return null;

    final matchDate = _nextPlayerMatchDate(state);
    final eventSlot = CalendarEventRegistry.nextEvent(state);

    if (matchDate == null && eventSlot == null) return null;
    if (eventSlot == null) {
      return UpcomingAction(
        kind: CalendarEventKind.match,
        id: 'match',
        week: matchDate!.$1,
        day: matchDate.$2,
      );
    }
    if (matchDate == null) {
      return UpcomingAction(
        kind: eventSlot.kind,
        id: eventSlot.id.name,
        calendarEventId: eventSlot.id,
        week: eventSlot.week,
        day: eventSlot.day,
      );
    }

    final fromWeek = state.currentWeek;
    final fromDay = state.currentDay;
    int normWeek(int week, int day) =>
        (week < fromWeek || (week == fromWeek && day < fromDay))
        ? week + _calendar.balance.calendar.seasonCycleWeeks
        : week;

    final matchNorm = normWeek(matchDate.$1, matchDate.$2);
    final eventNorm = normWeek(eventSlot.week, eventSlot.day);
    final matchFirst = matchNorm != eventNorm
        ? matchNorm < eventNorm
        : matchDate.$2 < eventSlot.day;

    return matchFirst
        ? UpcomingAction(
            kind: CalendarEventKind.match,
            id: 'match',
            week: matchDate.$1,
            day: matchDate.$2,
          )
        : UpcomingAction(
            kind: eventSlot.kind,
            id: eventSlot.id.name,
            calendarEventId: eventSlot.id,
            week: eventSlot.week,
            day: eventSlot.day,
          );
  }

  /// Non-null only when a non-match calendar event is due exactly today.
  UpcomingAction? _dueActionToday(LeagueState league) {
    final action = nextEvent(league: league);
    if (action == null) return null;
    if (action.week != league.currentWeek || action.day != league.currentDay) {
      return null;
    }
    return action;
  }

  /// Returns true if the calendar event due today is a `playerAction` that
  /// the batch must stop for (for example the Scout Report/Combine target
  /// selection, lottery, or the player's turn to pick in the draft).
  bool _isBlockingPlayerEvent(LeagueState league, CalendarEventId eventId) {
    if (eventId == CalendarEventId.lottery) return true;
    if (eventId == CalendarEventId.scoutReport) {
      return league.playerTeam != null &&
          league.currentSeason.draftState?.draftClass != null;
    }
    if (eventId != CalendarEventId.draft) return false;
    final draft = league.currentSeason.draftState;
    if (draft == null) return false;
    if (draft.currentPickIndex >= draft.order.length) return false;
    return draft.order[draft.currentPickIndex].teamId == league.playerTeamId;
  }

  /// Runs the automatic/informational calendar event registered for
  /// [eventId] at the current date. No-op (besides validation) for
  /// `playerAction` events like `draft` — those are driven entirely by the
  /// dedicated UI + `makeDraftPick`.
  Future<void> runEventAtCurrentDay(CalendarEventId eventId) async {
    final saveSeed = save?.saveSeed ?? 0;
    await updateLeague((league) {
      switch (eventId) {
        case CalendarEventId.capUpdateTv:
          return _season.runCapUpdateTv(league, saveSeed: saveSeed);
        case CalendarEventId.staffGrowth:
          return _season.runStaffGrowthAndRetire(league);
        case CalendarEventId.retirements:
          return _season.runPlayerRetirements(league, saveSeed: saveSeed);
        case CalendarEventId.awards:
          return _season.runAwards(league);
        case CalendarEventId.lottery:
          // playerAction — handled by the lottery screen interactively.
          return league;
        case CalendarEventId.scoutReport:
          return _season.runScoutReport(league, saveSeed: saveSeed);
        case CalendarEventId.combine:
          return _season.runCombine(league, saveSeed: saveSeed);
        case CalendarEventId.finalMock:
          return _season.runFinalMock(league, saveSeed: saveSeed);
        case CalendarEventId.nextClassGeneration:
          return _season.runNextClassGeneration(league, saveSeed: saveSeed);
        case CalendarEventId.tradeWindowOpen:
        case CalendarEventId.contractExtensions:
          // Ranges are derived windows, not one-shot actions.
          return league;
        case CalendarEventId.draft:
          // playerAction — handled by the draft screen + makeDraftPick.
          return league;
        case CalendarEventId.freeAgencyOpen:
          return _season.runFreeAgencyOpen(league);
        case CalendarEventId.tradeDeadline:
          return league.copyWith(
            currentSeason: league.currentSeason.copyWith(
              tradeDeadlineAcked: true,
            ),
          );
      }
    });
  }

  /// Auto-simulates the player's fixture headlessly (same engine call as
  /// AI-vs-AI fixtures in `DaySimulator._resolveRound`) and applies the
  /// result via `applyPlayerMatchResult`. Used only by `simulateToDate` —
  /// `simulateToEvent` must hand the match off to `MatchdayScreen` instead
  /// (`DaySimulator.simulateDay` deliberately does not auto-sim it).
  /// Returns `null` if either team can't be resolved (should not happen in
  /// practice; treated as a hard stop by the caller).
  Future<MatchResult?> _autoSimulatePlayerMatch(ScheduledMatch match) async {
    final current = save;
    if (current == null) return null;
    final league = current.leagueState;
    final home = league.teamById(match.homeTeamId);
    final away = league.teamById(match.awayTeamId);
    if (home == null || away == null) return null;

    final context = _ref
        .read(matchContextFactoryProvider)
        .create(
          league: league,
          match: match,
          saveSeed: current.saveSeed,
          stake: MatchStake.regular,
        );
    final result = _ref
        .read(aiMatchdayServiceProvider)
        .simulateFullMatch(
          home: home,
          away: away,
          context: context,
          saveSeed: current.saveSeed,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          matchId: match.id,
          phase: league.currentSeason.phase,
        );
    await updateLeague(
      (l) => _days.applyPlayerMatchResult(
        l,
        match,
        result,
        saveSeed: current.saveSeed,
      ),
    );
    return result;
  }

  Future<bool> _publishCompletedCalendarDay({
    required _SimulationSession session,
    required int sequence,
    required int week,
    required int day,
    required LeagueState league,
    required DaySimulationResult result,
    CalendarDaySimulationObserver? observer,
    CalendarSimulationPacer? pacer,
  }) async {
    if (!_isCurrentSimulationSession(session)) return false;

    if (observer != null) {
      observer(
        CalendarDaySimulationFeedback(
          runId: session.runId,
          sequence: sequence,
          week: week,
          day: day,
          results: _calendarFeedbackResults(
            league: league,
            week: week,
            day: day,
            results: result.simulatedResults,
          ),
        ),
      );
    }

    // An observer may synchronously start a newer run. In that case this
    // session must not wait on or reset the newer run's pacer.
    if (!_isCurrentSimulationSession(session)) return false;

    if (pacer != null) {
      await pacer.completeDay();
      if (!_isCurrentSimulationSession(session)) return false;
    }
    return true;
  }

  List<MatchResult> _mergeCalendarSimulationResults({
    required LeagueState league,
    required int week,
    required int day,
    required List<MatchResult> simulatedResults,
    required MatchResult autoResult,
  }) {
    final merged = <MatchResult>[...simulatedResults];
    final autoResultAlreadyPresent = merged.any(
      (candidate) =>
          candidate.homeTeamId == autoResult.homeTeamId &&
          candidate.awayTeamId == autoResult.awayTeamId,
    );
    if (!autoResultAlreadyPresent) merged.add(autoResult);

    final daySchedule = _scheduledMatchesForCalendarDay(league, week, day);
    final rows =
        <({MatchResult result, int schedulePosition, int inputOrder})>[];

    for (var inputOrder = 0; inputOrder < merged.length; inputOrder++) {
      final result = merged[inputOrder];
      var schedulePosition = daySchedule.length + inputOrder;
      for (var index = 0; index < daySchedule.length; index++) {
        final scheduledMatch = daySchedule[index];
        if (scheduledMatch.homeTeamId == result.homeTeamId &&
            scheduledMatch.awayTeamId == result.awayTeamId) {
          schedulePosition = index;
          break;
        }
      }
      rows.add((
        result: result,
        schedulePosition: schedulePosition,
        inputOrder: inputOrder,
      ));
    }

    rows.sort((a, b) {
      final position = a.schedulePosition.compareTo(b.schedulePosition);
      return position == 0 ? a.inputOrder.compareTo(b.inputOrder) : position;
    });
    return [for (final row in rows) row.result];
  }

  List<CalendarMatchFeedback> _calendarFeedbackResults({
    required LeagueState league,
    required int week,
    required int day,
    required List<MatchResult> results,
  }) {
    final daySchedule = _scheduledMatchesForCalendarDay(league, week, day);
    final schedule = league.currentSeason.schedule;
    final rows = <({CalendarMatchFeedback feedback, int inputOrder})>[];

    for (var inputOrder = 0; inputOrder < results.length; inputOrder++) {
      final result = results[inputOrder];
      ScheduledMatch? scheduledMatch;

      for (final candidate in daySchedule) {
        if (candidate.result == result ||
            (candidate.homeTeamId == result.homeTeamId &&
                candidate.awayTeamId == result.awayTeamId &&
                candidate.result != null)) {
          scheduledMatch = candidate;
          break;
        }
      }
      if (scheduledMatch == null) {
        for (final candidate in schedule) {
          if (candidate.result == result ||
              (candidate.homeTeamId == result.homeTeamId &&
                  candidate.awayTeamId == result.awayTeamId &&
                  candidate.result != null)) {
            scheduledMatch = candidate;
            break;
          }
        }
      }

      var daySchedulePosition = -1;
      if (scheduledMatch != null) {
        for (var index = 0; index < daySchedule.length; index++) {
          if (daySchedule[index] == scheduledMatch) {
            daySchedulePosition = index;
            break;
          }
        }
      }
      final dayPosition = daySchedulePosition >= 0
          ? daySchedulePosition
          : inputOrder;
      final matchId =
          scheduledMatch?.id ??
          'calendar_${week}_${day}_${result.homeTeamId}_'
              '${result.awayTeamId}_$inputOrder';
      final homeName =
          league.teamById(result.homeTeamId)?.name ?? result.homeTeamId;
      final awayName =
          league.teamById(result.awayTeamId)?.name ?? result.awayTeamId;

      rows.add((
        feedback: CalendarMatchFeedback(
          matchId: matchId,
          homeTeamId: result.homeTeamId,
          homeTeamName: homeName,
          awayTeamId: result.awayTeamId,
          awayTeamName: awayName,
          homeGoals: result.homeGoals,
          awayGoals: result.awayGoals,
          schedulePosition: dayPosition,
          status: result.status.name,
          reasonCode: result.reasonCode,
        ),
        inputOrder: inputOrder,
      ));
    }

    rows.sort((a, b) {
      final position = a.feedback.schedulePosition.compareTo(
        b.feedback.schedulePosition,
      );
      return position == 0 ? a.inputOrder.compareTo(b.inputOrder) : position;
    });
    return [for (final row in rows) row.feedback];
  }

  List<ScheduledMatch> _scheduledMatchesForCalendarDay(
    LeagueState league,
    int week,
    int day,
  ) {
    final slot = _calendar.regularSeasonSlotForDay(day);
    if (slot == null || !_calendar.isActualMatchDay(week, day)) {
      return const [];
    }
    final round = scheduleRoundForWeekSlot(week, slot);
    return league.currentSeason.schedule
        .where((match) => match.round == round)
        .toList();
  }

  Future<BatchSimulationResult> _simulateUntil(
    bool Function(LeagueState league) reachedTarget, {
    bool autoResolveEvents = false,
    bool autoSimulatePlayerMatch = false,
    int maxDays = 400,
    CalendarDaySimulationObserver? observer,
    CalendarSimulationPacer? pacer,
  }) async {
    final session = _startSimulationSession();
    // A pacer can be reused by a resumed calendar run. Do not let an
    // incomplete cycle from an older run affect the new run's first day.
    pacer?.skipDay();
    try {
      return await _simulateUntilInternal(
        reachedTarget,
        autoResolveEvents: autoResolveEvents,
        autoSimulatePlayerMatch: autoSimulatePlayerMatch,
        maxDays: maxDays,
        session: session,
        observer: observer,
        pacer: pacer,
      );
    } finally {
      // Only the session that still owns the controller may clear the active
      // marker or persist. A stale batch must not reset a newer batch's state.
      if (identical(_activeSimulationSession, session)) {
        pacer?.skipDay();
        _activeSimulationSession = null;
        await persist();
      }
    }
  }

  /// Repeatedly advances one day at a time until [reachedTarget] holds
  /// (checked before each day), a due event/match/urgent condition stops
  /// the batch, cancellation is requested, or [maxDays] is hit as a safety
  /// cap.
  ///
  /// [autoResolveEvents] controls whether automatic/informational/
  /// non-blocking `playerAction` events encountered along the way are
  /// executed immediately (`simulateToDate` semantics) or left for the
  /// caller to react to (`simulateToEvent` semantics).
  ///
  /// [autoSimulatePlayerMatch] controls whether the player's own fixture is
  /// auto-simulated headlessly and the batch continues (`simulateToDate`:
  /// calendar fast-forward skips most matches/events), or the batch stops
  /// so the caller can hand off to `MatchdayScreen` (`simulateToEvent`:
  /// home-screen day-by-day / next-match-or-event, matching the FIFA-style
  /// "stop right before it happens" flow).
  Future<BatchSimulationResult> _simulateUntilInternal(
    bool Function(LeagueState league) reachedTarget, {
    bool autoResolveEvents = false,
    bool autoSimulatePlayerMatch = false,
    int maxDays = 400,
    required _SimulationSession session,
    CalendarDaySimulationObserver? observer,
    CalendarSimulationPacer? pacer,
  }) async {
    final calendarPresentation = observer != null || pacer != null;
    var daysSimulated = 0;
    var feedbackSequence = 0;
    DaySimulationResult? lastResult;

    while (true) {
      // A replaced session is cancelled even if its old cancellation flag was
      // set while it was suspended in an await. The active session alone may
      // continue publishing state and presentation feedback.
      if (!_isCurrentSimulationSession(session)) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.cancelled,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }

      final current = save;
      if (current == null) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.noSave,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
      if (session.cancelRequested) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.cancelled,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }

      final league = current.leagueState;
      final due = _dueActionToday(league);
      final dueEventId = (due != null && due.kind != CalendarEventKind.match)
          ? due.calendarEventId
          : null;

      if (dueEventId != null && _isBlockingPlayerEvent(league, dueEventId)) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.event,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
          eventId: dueEventId,
        );
      }

      if (reachedTarget(league)) {
        // A calendar target can be the first date on which a scheduled urgent
        // message is delivered. Surface that message before stopping at the
        // target, but do not simulate the target day or publish incomplete
        // feedback for it.
        if (calendarPresentation && _hasScheduledUrgentDue(league)) {
          final delivered = _deliverStartOfDay(
            league,
            hour: league.currentHour,
            saveSeed: current.saveSeed,
            resolveExpired: false,
          );
          await updateLeague((_) => delivered);
          if (!_isCurrentSimulationSession(session)) {
            return BatchSimulationResult(
              stopReason: SimulationStopReason.cancelled,
              daysSimulated: daysSimulated,
              lastResult: lastResult,
            );
          }
          if (_hasPendingUrgent(delivered)) {
            return BatchSimulationResult(
              stopReason: SimulationStopReason.urgent,
              daysSimulated: daysSimulated,
              lastResult: lastResult,
            );
          }
        }
        return BatchSimulationResult(
          stopReason: SimulationStopReason.reachedTarget,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }

      if (dueEventId != null) {
        if (!autoResolveEvents) {
          return BatchSimulationResult(
            stopReason: SimulationStopReason.event,
            daysSimulated: daysSimulated,
            lastResult: lastResult,
            eventId: dueEventId,
          );
        }
        await runEventAtCurrentDay(dueEventId);
        if (!_isCurrentSimulationSession(session)) {
          return BatchSimulationResult(
            stopReason: SimulationStopReason.cancelled,
            daysSimulated: daysSimulated,
            lastResult: lastResult,
          );
        }
        if (session.cancelRequested) {
          return BatchSimulationResult(
            stopReason: SimulationStopReason.cancelled,
            daysSimulated: daysSimulated,
            lastResult: lastResult,
          );
        }
      }

      if (daysSimulated >= maxDays) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.reachedTarget,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }

      final startWeek = league.currentWeek;
      final startDay = league.currentDay;
      final isHourly = _calendar.isHourlyContractMode(startWeek, startDay);
      final wasHourlyEnd = isHourly && (league.currentHour ?? 1) >= 10;
      if (pacer != null && (!isHourly || !pacer.hasActiveDay)) {
        pacer.startDay();
      }

      final result = isHourly ? await advanceOneHour() : await advanceOneDay();
      if (!_isCurrentSimulationSession(session)) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.cancelled,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
      if (result == null) {
        pacer?.skipDay();
        // A start-of-day urgent message makes the raw day primitive return
        // null after preserving the active save. Distinguish that stop from
        // a genuinely unavailable save so the calendar path keeps its
        // existing urgent lifecycle without publishing an incomplete day.
        final currentAfterNullStep = save;
        if (currentAfterNullStep != null &&
            _hasPendingUrgent(currentAfterNullStep.leagueState)) {
          return BatchSimulationResult(
            stopReason: SimulationStopReason.urgent,
            daysSimulated: daysSimulated,
            lastResult: lastResult,
          );
        }
        return BatchSimulationResult(
          stopReason: SimulationStopReason.noSave,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
      lastResult = result;

      // Keep the old count semantics for HomeScreen/day-by-day callers. The
      // calendar observer path counts only a date transition, so an hourly
      // slot or an incomplete player-match day cannot emit a false day.
      if (!calendarPresentation) {
        if (!wasHourlyEnd && !isHourly) {
          daysSimulated++;
        } else if (wasHourlyEnd) {
          daysSimulated++;
        }
      }

      if (result.playerMatch != null) {
        if (autoSimulatePlayerMatch) {
          final autoResult = await _autoSimulatePlayerMatch(
            result.playerMatch!,
          );
          if (!_isCurrentSimulationSession(session)) {
            return BatchSimulationResult(
              stopReason: SimulationStopReason.cancelled,
              daysSimulated: daysSimulated,
              lastResult: lastResult,
            );
          }
          if (autoResult != null) {
            final leagueAfter = save!.leagueState;
            final mergedResults = _mergeCalendarSimulationResults(
              league: leagueAfter,
              week: startWeek,
              day: startDay,
              simulatedResults: result.simulatedResults,
              autoResult: autoResult,
            );
            lastResult = DaySimulationResult(
              league: leagueAfter,
              pauseForUrgent: leagueAfter.inbox.pendingUrgent.isNotEmpty,
              simulatedResults: mergedResults,
              eventId: null,
            );

            if (calendarPresentation) {
              final completed = _dateAdvanced(
                leagueAfter,
                startWeek: startWeek,
                startDay: startDay,
              );
              if (completed) {
                daysSimulated++;
                final published = await _publishCompletedCalendarDay(
                  session: session,
                  sequence: feedbackSequence,
                  week: startWeek,
                  day: startDay,
                  league: leagueAfter,
                  result: lastResult,
                  observer: observer,
                  pacer: pacer,
                );
                if (!published) {
                  return BatchSimulationResult(
                    stopReason: SimulationStopReason.cancelled,
                    daysSimulated: daysSimulated,
                    lastResult: lastResult,
                  );
                }
                feedbackSequence++;
              } else {
                pacer?.skipDay();
              }
            }

            if (leagueAfter.inbox.pendingUrgent.isNotEmpty) {
              return BatchSimulationResult(
                stopReason: SimulationStopReason.urgent,
                daysSimulated: daysSimulated,
                lastResult: lastResult,
              );
            }
            continue;
          }
        }
        // A player match that could not be auto-resolved did not complete a
        // calendar day. Do not publish feedback for it.
        pacer?.skipDay();
        return BatchSimulationResult(
          stopReason: SimulationStopReason.playerMatch,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }

      if (calendarPresentation) {
        final leagueAfter = save?.leagueState;
        final completed =
            leagueAfter != null &&
            _dateAdvanced(
              leagueAfter,
              startWeek: startWeek,
              startDay: startDay,
            );
        if (completed) {
          daysSimulated++;
          final published = await _publishCompletedCalendarDay(
            session: session,
            sequence: feedbackSequence,
            week: startWeek,
            day: startDay,
            league: leagueAfter,
            result: result,
            observer: observer,
            pacer: pacer,
          );
          if (!published) {
            return BatchSimulationResult(
              stopReason: SimulationStopReason.cancelled,
              daysSimulated: daysSimulated,
              lastResult: lastResult,
            );
          }
          feedbackSequence++;
        } else if (!isHourly) {
          pacer?.skipDay();
        }

        // Preserve the existing urgent stop priority after the completed-day
        // presentation cycle has been given a chance to finish.
        if (result.pauseForUrgent) {
          return BatchSimulationResult(
            stopReason: SimulationStopReason.urgent,
            daysSimulated: daysSimulated,
            lastResult: lastResult,
          );
        }
        if (session.cancelRequested) {
          return BatchSimulationResult(
            stopReason: SimulationStopReason.cancelled,
            daysSimulated: daysSimulated,
            lastResult: lastResult,
          );
        }
      } else if (result.pauseForUrgent) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.urgent,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
    }
  }

  bool _dateAdvanced(
    LeagueState league, {
    required int startWeek,
    required int startDay,
  }) => league.currentWeek != startWeek || league.currentDay != startDay;

  /// Simulates day by day until the next unresolved calendar event or the
  /// player's match comes up — whichever happens first. Nic nie jest
  /// auto-resolwowane: to jest ścieżka `HomeScreen` (day-by-day / do
  /// następnego meczu-lub-eventu), caller reaguje na `BatchSimulationResult`.
  Future<BatchSimulationResult> simulateToEvent() {
    return _simulateUntil(
      (_) => false,
      autoResolveEvents: false,
      autoSimulatePlayerMatch: false,
    );
  }

  /// Szybka symulacja kalendarzowa: dociąga do (week, day), auto-resolwując
  /// po drodze zarówno automatyczne/informacyjne eventy, jak i mecze
  /// gracza (headlessly, silnikiem — bez otwierania `MatchdayScreen`).
  /// Zatrzymuje się wyłącznie na: pilnej wiadomości w skrzynce lub
  /// `playerAction` evencie, na który wymagana jest realna decyzja gracza
  /// (obecnie tylko tura draftu gracza).
  Future<BatchSimulationResult> simulateToDate(
    int targetWeek,
    int targetDay, {
    CalendarDaySimulationObserver? observer,
    CalendarSimulationPacer? pacer,
  }) {
    // A direct simulateToDate call is itself the calendar fast-forward path.
    // Keep feedback opt-in through [observer], but use the production pacing
    // boundary when the caller does not inject a test/route pacer. Other
    // flows call _simulateUntil directly and therefore retain their original
    // unpaced behavior.
    final effectivePacer = pacer ?? CalendarSimulationPacer();
    return _simulateUntil(
      (league) => _calendar.isAtOrAfter(
        league.currentWeek,
        league.currentDay,
        targetWeek,
        targetDay,
      ),
      autoResolveEvents: true,
      autoSimulatePlayerMatch: true,
      observer: observer,
      pacer: effectivePacer,
    );
  }

  /// Simulates through the last day of [phase] (inclusive), stopping at the
  /// first day of whatever comes next. Ta sama semantyka co `simulateToDate`
  /// (auto-resolve eventów i meczów gracza).
  Future<BatchSimulationResult> simulateUntilPhaseEnd(SeasonPhase phase) {
    final (endWeek, endDay) = _calendar.endOfPhase(phase);
    final (targetWeek, targetDay) = _calendar.advanceDay(endWeek, endDay);
    // Phase-end simulation is a non-calendar presentation flow. Keep its
    // historical pacing and stop behavior instead of routing it through the
    // calendar-only default pacer.
    return _simulateUntil(
      (league) => _calendar.isAtOrAfter(
        league.currentWeek,
        league.currentDay,
        targetWeek,
        targetDay,
      ),
      autoResolveEvents: true,
      autoSimulatePlayerMatch: true,
    );
  }

  Future<void> applyPlayerMatch(
    ScheduledMatch match,
    MatchResult result,
  ) async {
    await updateLeague(
      (l) => _days.applyPlayerMatchResult(
        l,
        match,
        result,
        saveSeed: save?.saveSeed ?? 0,
      ),
    );
  }

  /// Marks a message as read without acknowledging an urgent pause.
  Future<void> markMessageRead(String id) {
    final generation = _saveGeneration;
    return _runMessageOperation(
      id,
      _MessageOperationKind.markRead,
      () => _updateLeagueInQueue(
        (league) {
          final message = _messageById(league, id);
          if (message == null || message.read) return league;
          return league.copyWith(inbox: league.inbox.markRead(id));
        },
        generation: generation,
        skipIfUnchanged: true,
      ),
    );
  }

  /// Acknowledges an urgent message and releases its simulation pause.
  Future<void> acknowledgeMessage(String id) {
    final generation = _saveGeneration;
    return _runMessageOperation(
      id,
      _MessageOperationKind.acknowledge,
      () => _updateLeagueInQueue(
        (league) {
          final message = _messageById(league, id);
          if (message == null || message.acknowledged) return league;
          return league.copyWith(inbox: league.inbox.acknowledge(id));
        },
        generation: generation,
        skipIfUnchanged: true,
      ),
    );
  }

  Future<TradeOfferResult?> acceptTradeOffer(String offerId) async {
    final current = save;
    final actingTeamId = current?.leagueState.playerTeamId;
    if (current == null || actingTeamId == null) return null;
    final result = _draftTrades.isDraftOffer(current.leagueState, offerId)
        ? _draftTrades.acceptOffer(
            current.leagueState,
            offerId,
            actingTeamId: actingTeamId,
          )
        : _ref
              .read(tradeServiceProvider)
              .acceptOffer(
                current.leagueState,
                offerId,
                actingTeamId: actingTeamId,
              );
    await updateLeague((_) => result.league);
    return result;
  }

  Future<TradeOfferResult?> rejectTradeOffer(String offerId) async {
    final current = save;
    final actingTeamId = current?.leagueState.playerTeamId;
    if (current == null || actingTeamId == null) return null;
    final result = _draftTrades.isDraftOffer(current.leagueState, offerId)
        ? _draftTrades.rejectOffer(
            current.leagueState,
            offerId,
            actingTeamId: actingTeamId,
          )
        : _ref
              .read(tradeServiceProvider)
              .rejectOffer(
                current.leagueState,
                offerId,
                actingTeamId: actingTeamId,
              );
    await updateLeague((_) => result.league);
    return result;
  }

  Future<TradeOfferResult?> counterTradeOffer(
    String offerId,
    TradeProposal proposal,
  ) async {
    final current = save;
    final actingTeamId = current?.leagueState.playerTeamId;
    if (current == null || actingTeamId == null) return null;
    final result = _draftTrades.isDraftOffer(current.leagueState, offerId)
        ? _draftTrades.counterOffer(
            current.leagueState,
            offerId,
            proposal,
            actingTeamId: actingTeamId,
          )
        : _ref
              .read(tradeServiceProvider)
              .counterOffer(
                current.leagueState,
                offerId,
                proposal,
                actingTeamId: actingTeamId,
              );
    if (result.changed) await updateLeague((_) => result.league);
    return result;
  }

  Future<void> expireTradeOffers() async {
    await updateLeague((league) {
      final draftExpired = _draftTrades.expireOffers(league);
      return _ref.read(tradeServiceProvider).expireOffers(draftExpired);
    });
  }

  /// Applies a decision effect, then acknowledges the message.
  ///
  /// The optional dispatcher is deliberately injected by the caller because
  /// message effects belong to their owning domain service. Without one, the
  /// choice is still recorded and the urgent pause is released safely.
  Future<void> resolveMessageDecision(
    String id,
    String optionId, {
    MessageDecisionHandler? onDecision,
  }) {
    final generation = _saveGeneration;
    return _runMessageOperation(
      id,
      _MessageOperationKind.decision,
      () => _updateLeagueInQueue(
        (league) {
          final message = _messageById(league, id);
          if (message == null || message.acknowledged) return league;
          final decision = message.decision;
          if (decision == null ||
              !decision.options.any((option) => option.id == optionId)) {
            return league;
          }

          // The seed and dispatcher are resolved while the queued snapshot is
          // active. A concurrent mutation therefore cannot make this
          // operation dispatch against a stale save.
          final saveSeed = save?.saveSeed ?? 0;
          final dispatcher =
              onDecision ?? _defaultMessageDecisionDispatcher(saveSeed);
          return MessageService().resolveDecision(
            league,
            id,
            optionId,
            onDecision: dispatcher,
          );
        },
        generation: generation,
        skipIfUnchanged: true,
      ),
    );
  }

  MessageDecisionHandler _defaultMessageDecisionDispatcher(int saveSeed) {
    return (LeagueState league, GameMessage message, String option) {
      if (message.type == MessageType.teamEvent) {
        return _teamEvents.resolveDecision(
          league,
          message,
          option,
          saveSeed: saveSeed,
        );
      }
      if (message.type == MessageType.tradeOffer ||
          (message.type == MessageType.trade && message.kind == 'counter')) {
        final offerId = message.payload['tradeOfferId']?.toString();
        final actingTeamId = league.playerTeamId;
        if (offerId == null || actingTeamId == null) return league;
        final draftService = _ref.read(draftTradeServiceProvider);
        final service = _ref.read(tradeServiceProvider);
        final result = switch (option) {
          'accept' =>
            draftService.isDraftOffer(league, offerId)
                ? draftService.acceptOffer(
                    league,
                    offerId,
                    actingTeamId: actingTeamId,
                  )
                : service.acceptOffer(
                    league,
                    offerId,
                    actingTeamId: actingTeamId,
                  ),
          'reject' =>
            draftService.isDraftOffer(league, offerId)
                ? draftService.rejectOffer(
                    league,
                    offerId,
                    actingTeamId: actingTeamId,
                  )
                : service.rejectOffer(
                    league,
                    offerId,
                    actingTeamId: actingTeamId,
                  ),
          _ => null,
        };
        return result?.league ?? league;
      }
      return _playerEvents.resolveDecision(
        league,
        message,
        option,
        saveSeed: saveSeed,
      );
    };
  }

  Future<void> makeDraftPick(String prospectId) async {
    final seed = save?.saveSeed ?? 0;
    await updateLeague(
      (l) => _season.advanceDraft(
        l,
        playerPickProspectId: prospectId,
        saveSeed: seed,
      ),
    );
  }

  Future<void> simulateOneDraftPick() async {
    final seed = save?.saveSeed ?? 0;
    await updateLeague((l) => _season.advanceDraftOnePick(l, saveSeed: seed));
  }

  Future<void> simulateDraftToPlayerTurn() async {
    final seed = save?.saveSeed ?? 0;
    await updateLeague((l) => _season.advanceDraft(l, saveSeed: seed));
  }

  /// Submits a free-agent offer through the central contract-market
  /// resolver. Accept remains pending until explicit finalization.
  Future<ContractReaction> offerFreeAgent(
    String freeAgentId,
    ContractOffer offer,
  ) async {
    final current = save;
    if (current == null) return ContractReaction.hardReject;
    final submission = _market.submitPlayerOffer(
      league: current.leagueState,
      playerId: freeAgentId,
      offer: offer,
      saveSeed: current.saveSeed,
    );
    if (submission == null) return ContractReaction.hardReject;
    await updateLeague((_) => submission.league);
    return submission.reaction;
  }

  /// Submits a player extension through the central contract-market
  /// resolver. The accepted offer remains pending until finalization.
  Future<ContractReaction> offerContractExtension(
    String playerId,
    ContractOffer offer,
  ) async {
    final current = save;
    if (current == null) return ContractReaction.hardReject;
    final submission = _market.submitPlayerOffer(
      league: current.leagueState,
      playerId: playerId,
      offer: offer,
      saveSeed: current.saveSeed,
    );
    if (submission == null) return ContractReaction.hardReject;
    await updateLeague((_) => submission.league);
    return submission.reaction;
  }

  Future<bool> finalizeContractNegotiation(String negotiationId) async {
    final current = save;
    if (current == null) return false;
    final next = _market.finalizeNegotiation(
      current.leagueState,
      negotiationId,
      saveSeed: current.saveSeed,
    );
    if (next == null) return false;
    await updateLeague((_) => next);
    return true;
  }

  Future<bool> respondToContractCounter(
    String negotiationId, {
    required bool accept,
    ContractOffer? offer,
  }) async {
    final current = save;
    if (current == null) return false;
    final next = _market.resolveCounterResponse(
      current.leagueState,
      negotiationId,
      accept: accept,
      playerOffer: offer,
      saveSeed: current.saveSeed,
    );
    if (next == null) return false;
    await updateLeague((_) => next);
    return true;
  }

  Future<bool> respondToStaffCounter(
    String negotiationId, {
    required bool accept,
    StaffOffer? offer,
  }) async {
    final current = save;
    if (current == null) return false;
    final next = _market.resolveCounterResponse(
      current.leagueState,
      negotiationId,
      accept: accept,
      staffOffer: offer,
      saveSeed: current.saveSeed,
    );
    if (next == null) return false;
    await updateLeague((_) => next);
    return true;
  }

  Future<bool> submitQualifyingOffer(
    String playerId, {
    int? salary,
    int years = 1,
  }) async {
    final current = save;
    final teamId = current?.leagueState.playerTeamId;
    if (current == null || teamId == null) return false;
    final next = _market.submitQualifyingOffer(
      league: current.leagueState,
      ownerTeamId: teamId,
      playerId: playerId,
      salary: salary,
      years: years,
    );
    if (next == null) return false;
    await updateLeague((_) => next);
    return true;
  }

  Future<bool> declineQualifyingOffer(String playerId) async {
    final current = save;
    if (current == null || current.leagueState.playerTeamId == null) {
      return false;
    }
    await updateLeague(
      (league) => _market.declineQualifyingOffer(league, playerId),
    );
    return true;
  }

  Future<bool> submitRfaOfferSheet(String playerId, ContractOffer offer) async {
    final current = save;
    final teamId = current?.leagueState.playerTeamId;
    if (current == null || teamId == null) return false;
    final next = _market.submitOfferSheet(
      league: current.leagueState,
      offeringTeamId: teamId,
      playerId: playerId,
      offer: offer,
      saveSeed: current.saveSeed,
    );
    if (next == null) return false;
    await updateLeague((_) => next);
    return true;
  }

  Future<bool> matchRfaOfferSheet(String sheetId) async {
    final current = save;
    if (current == null) return false;
    final next = _market.matchOfferSheet(
      current.leagueState,
      sheetId,
      saveSeed: current.saveSeed,
    );
    if (next == null) return false;
    await updateLeague((_) => next);
    return true;
  }

  Future<bool> declineRfaOfferSheet(String sheetId) async {
    final current = save;
    if (current == null) return false;
    await updateLeague((league) => _market.declineOfferSheet(league, sheetId));
    return true;
  }

  Future<bool> signDraftedRight(String rightId) async {
    final current = save;
    if (current == null) return false;
    final next = _market.signDraftedRight(
      current.leagueState,
      rightId,
      saveSeed: current.saveSeed,
    );
    if (next == null) return false;
    await updateLeague((_) => next);
    return true;
  }

  StaffService get _staff => _ref.read(staffServiceProvider);

  /// Submits a staff offer through the central contract-market resolver.
  Future<StaffReaction> offerStaff(
    StaffMember candidate,
    StaffOffer offer,
  ) async {
    final current = save;
    if (current == null) return StaffReaction.hardReject;
    final submission = _market.submitStaffOffer(
      league: current.leagueState,
      candidate: candidate,
      offer: offer,
      saveSeed: current.saveSeed,
    );
    if (submission == null) return StaffReaction.hardReject;
    await updateLeague((_) => submission.league);
    return submission.reaction;
  }

  /// Compatibility wrapper for callers that only need to know whether the
  /// offer reached Accept. It no longer hires immediately; the returned true
  /// means a pending finalization record was created.
  Future<bool> hireStaff(StaffMember candidate, StaffOffer offer) async {
    final reaction = await offerStaff(candidate, offer);
    return reaction == StaffReaction.accept;
  }

  Future<bool> fireStaff(StaffRole role) async {
    final current = save;
    final team = current?.leagueState.playerTeam;
    if (current == null || team == null) return false;
    final updatedTeam = _staff.fire(team, role);
    if (updatedTeam == team) return false;
    await updateLeague((league) => league.updateTeam(updatedTeam));
    return true;
  }

  ScoutingService get _scouting => _ref.read(scoutingServiceProvider);

  /// Sets the player team's scouting watchlist, capped by scout Coverage.
  Future<void> setScoutWatchlist(List<String> prospectIds) async {
    await updateLeague((l) {
      final team = l.playerTeam;
      if (team == null) return l;
      final coverage = team.staff.scout?.attributes.coverage ?? 0.0;
      final scouting = _scouting.setWatchlist(
        team.scouting,
        prospectIds,
        coverageStars: coverage,
      );
      return l.updateTeam(team.copyWith(scouting: scouting));
    });
  }

  /// Saves player-selected Combine targets only after Scout Report and before
  /// the automatic Combine event.
  Future<bool> setCombineAssignments(List<String> prospectIds) async {
    final current = save;
    final league = current?.leagueState;
    final team = league?.playerTeam;
    final draftClass = league?.currentSeason.draftState?.draftClass;
    if (current == null ||
        league == null ||
        team == null ||
        draftClass == null) {
      return false;
    }
    final season = league.currentSeason;
    if (!season.scoutReportDone || season.combineDone) return false;
    if (team.scouting.watchlistProspectIds.isEmpty) return false;
    final coverage = team.staff.scout?.attributes.coverage ?? 0.0;
    final scouting = _scouting.setCombineAssignments(
      team.scouting,
      prospectIds,
      coverageStars: coverage,
      availableProspectIds: draftClass.prospects.map((prospect) => prospect.id),
    );
    await updateLeague(
      (state) => state.updateTeam(team.copyWith(scouting: scouting)),
    );
    return true;
  }

  /// Clears the active save immediately, then leaves a marker in the mutation
  /// queue so mutations requested after the clear cannot overtake earlier
  /// repository work. The generation check in those mutations prevents a late
  /// completion from publishing the cleared save again.
  void clear() {
    _saveGeneration++;
    _inFlightMessageOperations.clear();
    state = const AsyncValue.data(null);
    _enqueueMutation<void>(() async {});
  }
}

final class _SimulationSession {
  _SimulationSession(this.runId);

  final int runId;
  bool cancelRequested = false;
}

final gameControllerProvider =
    StateNotifierProvider<GameController, AsyncValue<GameSave?>>((ref) {
      return GameController(ref);
    });

final activeLeagueProvider = Provider((ref) {
  return ref.watch(gameControllerProvider).value?.leagueState;
});

/// Next fixture/event the player can act on, driving the contextual button
/// on `HomeScreen`. Recomputed whenever `activeLeagueProvider` changes.
final nextGameEventProvider = Provider<UpcomingAction?>((ref) {
  ref.watch(activeLeagueProvider);
  return ref.read(gameControllerProvider.notifier).nextEvent();
});
