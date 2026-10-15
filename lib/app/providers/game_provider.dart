import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/providers/settings_provider.dart';
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
import 'package:new_football/core/services/day_pipeline.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/simulation_worker.dart';
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
    season: ref.watch(seasonServiceProvider),
  );
});

final dayPipelineProvider = Provider(
  (ref) => DayPipeline(
    calendar: ref.watch(calendarServiceProvider),
    days: ref.watch(daySimulatorProvider),
    negotiations: ref.watch(negotiationServiceProvider),
    draftTrades: ref.watch(draftTradeServiceProvider),
    trades: ref.watch(tradeServiceProvider),
    playerEvents: ref.watch(playerEventServiceProvider),
    teamEvents: ref.watch(teamEventServiceProvider),
    contractMarket: ref.watch(contractMarketServiceProvider),
  ),
);

/// Day advancement runs inline by default so tests stay deterministic and
/// free of isolate lifecycles. `main.dart` overrides this with
/// [IsolateSimulationRunner] so the app keeps simulation off the UI isolate.
final simulationRunnerProvider = Provider<SimulationRunner>((ref) {
  final runner = InlineSimulationRunner(ref.watch(dayPipelineProvider));
  ref.onDispose(runner.dispose);
  return runner;
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
  DayPipeline get _pipeline => _ref.read(dayPipelineProvider);
  SimulationRunner get _runner => _ref.read(simulationRunnerProvider);
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
  int _stateRevision = 0;
  int _persistedRevision = 0;
  Future<void>? _careerTransition;
  int _careerRequestId = 0;
  bool _leavingCareer = false;

  /// Generation captured by the management operation currently executing in
  /// [_mutationQueue]. It lets [applyManagedMeta] reject a result that was
  /// produced for a save which was cleared or replaced while repository I/O
  /// was pending.
  int? _saveManagementGeneration;

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

  Future<T> _mutateSave<T>(
    T unavailable,
    Future<T> Function(GameSave current) operation,
  ) {
    if (_careerTransition != null) return Future<T>.value(unavailable);
    final generation = _saveGeneration;
    return _enqueueMutation(() async {
      final current = save;
      if (generation != _saveGeneration || current == null) return unavailable;
      return operation(current);
    });
  }

  Future<void> _publishLeagueInQueue(
    LeagueState Function(LeagueState) transform,
  ) => _updateLeagueInQueue(transform, generation: _saveGeneration);

  /// Enqueues save-management work on the same queue as all state mutations
  /// and persistence operations.
  ///
  /// The generation is captured when the operation is requested rather than
  /// when it reaches the queue. This prevents a late management result from
  /// updating a newly loaded or newly created save after the original active
  /// save was cleared or replaced while the operation was waiting or doing
  /// repository I/O.
  Future<T> enqueueSaveManagement<T>(Future<T> Function() operation) {
    final generation = _saveGeneration;
    return _enqueueMutation(() async {
      final previousGeneration = _saveManagementGeneration;
      _saveManagementGeneration = generation;
      try {
        return await operation();
      } finally {
        _saveManagementGeneration = previousGeneration;
      }
    });
  }

  /// Applies metadata returned by a completed management transaction to the
  /// active in-memory save, without changing its payload.
  ///
  /// Call this from the operation passed to [enqueueSaveManagement]. The
  /// active ID and the generation captured at enqueue time are checked again
  /// after repository I/O, so a late rename cannot publish metadata to a
  /// cleared, replaced, or otherwise different active save. The supplied
  /// metadata must carry the same ID as [saveId].
  bool applyManagedMeta(String saveId, GameSaveMeta meta) {
    final generation = _saveManagementGeneration;
    if (generation != null && generation != _saveGeneration) return false;
    if (meta.id != saveId) return false;

    final current = save;
    if (current == null || current.meta.id != saveId) return false;

    // copyWith replaces only the metadata object; leagueState and saveSeed
    // remain the exact payload instances from the active save.
    state = AsyncValue.data(current.copyWith(meta: meta));
    return true;
  }

  Future<void> _runMessageOperation(
    String messageId,
    _MessageOperationKind kind,
    Future<void> Function() operation,
  ) {
    if (_careerTransition != null) return Future<void>.value();
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

  Future<void> createNewGame(NewGameRequest request) {
    return _changeCareer(() async {
      final game = _ref.read(gameFactoryProvider).create(request);
      await _repo.save(game);
      return game;
    });
  }

  Future<void> loadGame(String id) => _changeCareer(() => _repo.load(id));

  Future<void> _changeCareer(
    Future<GameSave?> Function() open, {
    bool leaving = false,
  }) {
    final requestId = ++_careerRequestId;
    _leavingCareer = leaving;
    final session = _activeSimulationSession;
    session?.cancel();
    late final Future<void> transition;
    transition = () async {
      try {
        // The batch's finally block uses the same mutation queue. Wait for
        // it outside that queue, including when presentation was cancelled.
        if (session != null) await session.done.future;
        await _enqueueMutation(() async {
          if (requestId != _careerRequestId) return;
          await _writeCurrentSaveInQueue(_saveGeneration);
          if (requestId != _careerRequestId) return;
          final previous = save;
          _saveGeneration++;
          _resetPersistence();
          try {
            if (previous == null && !leaving) {
              state = const AsyncValue.loading();
            }
            final next = await open();
            if (requestId == _careerRequestId) state = AsyncValue.data(next);
          } catch (error, stackTrace) {
            if (requestId == _careerRequestId) {
              state = previous == null
                  ? AsyncValue.error(error, stackTrace)
                  : AsyncValue.data(previous);
            }
            rethrow;
          }
        });
      } finally {
        if (identical(_careerTransition, transition)) {
          _careerTransition = null;
          _leavingCareer = false;
        }
      }
    }();
    _careerTransition = transition;
    return transition;
  }

  void _resetPersistence() {
    _stateRevision = 0;
    _persistedRevision = 0;
    _pendingAutosave = null;
    _autosaveScheduled = false;
    _autosaveError = null;
    _autosaveStackTrace = null;
    _failedSaveRevision = null;
    _inFlightMessageOperations.clear();
  }

  Future<void> persist() {
    final generation = _saveGeneration;
    return _enqueueMutation(
      () => _writeCurrentSaveInQueue(generation, force: true),
    );
  }

  Future<void> updateLeague(
    LeagueState Function(LeagueState) transform, {
    bool autosave = true,
  }) {
    return _mutateSave<void>(
      null,
      (_) => _updateLeagueInQueue(
        transform,
        generation: _saveGeneration,
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
    // each intermediate day.
    final shouldPersist = autosave && !_batchSimulationActive;
    if (generation == _saveGeneration) {
      _stateRevision++;
      state = AsyncValue.data(next);
    }
    // The state is published before the write starts, so advancing a day does
    // not wait for several megabytes to reach the disk. Ordering is still
    // guaranteed: the write is appended to the same mutation queue. Callers
    // that must not lose the write — manual save, entering matchday, app
    // backgrounding, end of a batch — go through [flushPendingSave].
    if (shouldPersist) {
      _scheduleAutosave(next, generation);
    }
  }

  GameSave? _pendingAutosave;
  bool _autosaveScheduled = false;
  Object? _autosaveError;
  StackTrace? _autosaveStackTrace;
  int? _failedSaveRevision;

  Future<void> _writeCurrentSaveInQueue(
    int generation, {
    bool force = false,
  }) async {
    if (generation != _saveGeneration) return;
    final current = save;
    if (current == null || (!force && _stateRevision == _persistedRevision)) {
      return;
    }
    final revision = _stateRevision;
    _pendingAutosave = null;
    try {
      await _repo.save(current);
      if (generation != _saveGeneration) return;
      _persistedRevision = revision;
      _autosaveError = null;
      _autosaveStackTrace = null;
      _failedSaveRevision = null;
    } catch (error, stackTrace) {
      if (generation == _saveGeneration) {
        _autosaveError = error;
        _autosaveStackTrace = stackTrace;
        _failedSaveRevision = revision;
      }
      rethrow;
    }
  }

  void _scheduleAutosave(GameSave next, int generation) {
    // Only the newest state is worth writing; a day advanced while the
    // previous write was still queued makes that write redundant.
    _pendingAutosave = next;
    if (_autosaveScheduled) return;
    _autosaveScheduled = true;
    _enqueueMutation(() async {
      if (generation != _saveGeneration) return;
      _autosaveScheduled = false;
      final pending = _pendingAutosave;
      _pendingAutosave = null;
      if (pending == null) return;
      // Read inside the queue so metadata updated by save management is kept.
      await _writeCurrentSaveInQueue(generation);
    }).then<void>(
      (_) {},
      // The queued writer records the error before another queue entry runs.
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  /// Persists mutations requested before this barrier, including mutations
  /// whose background autosave has not yet been scheduled.
  ///
  /// An unsaved revision's failure remains visible until a successful write;
  /// a newer successfully persisted revision supersedes an older failure.
  Future<void> flushPendingSave() {
    final generation = _saveGeneration;
    return _enqueueMutation(() async {
      if (generation != _saveGeneration) return;
      final error = _autosaveError;
      if (error != null && _failedSaveRevision == _stateRevision) {
        Error.throwWithStackTrace(
          error,
          _autosaveStackTrace ?? StackTrace.current,
        );
      }
      await _writeCurrentSaveInQueue(generation);
    });
  }

  bool get _batchSimulationActive => _activeSimulationSession != null;
  _SimulationSession? _activeSimulationSession;
  int _nextSimulationRunId = 0;

  /// Tests that construct a [GameController] without prefs still get the
  /// production default instead of crashing mid-batch.
  bool _readUrgentInterruptionEnabled() {
    try {
      return _ref.read(urgentInterruptionSettingProvider);
    } catch (_) {
      return defaultUrgentInterruptionSetting;
    }
  }

  _SimulationSession _startSimulationSession({
    required bool urgentInterruptionEnabled,
  }) {
    // A second request invalidates the old session rather than resetting a
    // shared flag. The old loop will observe that it is no longer current
    // after its next await and cannot publish stale feedback or clear the new
    // session in its finally block.
    _activeSimulationSession?.cancel();
    final session = _SimulationSession(
      _nextSimulationRunId++,
      urgentInterruptionEnabled: urgentInterruptionEnabled,
    );
    _activeSimulationSession = session;
    return session;
  }

  bool _isCurrentSimulationSession(_SimulationSession session) =>
      identical(_activeSimulationSession, session) && !session.cancelRequested;

  /// Requests that an in-progress batch stop as soon as possible (checked
  /// between simulated days).
  void cancelSimulation() {
    _activeSimulationSession?.cancel();
  }

  bool _hasPendingUrgent(LeagueState league) =>
      league.inbox.pendingUrgent.isNotEmpty;

  bool _shouldStopForUrgent(_SimulationSession session, LeagueState league) =>
      session.urgentInterruptionEnabled && _hasPendingUrgent(league);

  bool _hasScheduledUrgentDue(LeagueState league) {
    return league.inbox.scheduled.any((message) {
      final beforeDate =
          message.week < league.currentWeek ||
          (message.week == league.currentWeek &&
              message.day < league.currentDay);
      final sameDate =
          message.week == league.currentWeek &&
          message.day == league.currentDay;
      return message.priority == MessagePriority.urgent &&
          (beforeDate || sameDate);
    });
  }

  LeagueState _deliverStartOfDay(
    LeagueState league, {
    int? hour,
    int saveSeed = 0,
    bool resolveExpired = true,
  }) => _pipeline.deliverStartOfDay(
    league,
    hour: hour,
    saveSeed: saveSeed,
    resolveExpired: resolveExpired,
  );

  Future<DaySimulationResult?> simulateDay({
    bool resolveContractMarket = true,
    bool interruptForUrgent = true,
  }) async {
    return _advanceOneDay(
      resolveContractMarket: resolveContractMarket,
      blockOnPendingUrgent: interruptForUrgent,
    );
  }

  Future<DaySimulationResult?> advanceOneDay({
    bool resolveContractMarket = true,
  }) => simulateDay(resolveContractMarket: resolveContractMarket);

  Future<DaySimulationResult?> _advanceOneDay({
    required bool blockOnPendingUrgent,
    bool resolveContractMarket = true,
  }) {
    if (_careerTransition != null) return Future.value(null);
    final generation = _saveGeneration;
    // Read, simulate and publish are one queue entry. The simulation is now
    // awaited — it may be running on the worker isolate — and any mutation
    // that slipped in during that await would be overwritten by the day.
    return _enqueueMutation(() async {
      final current = save;
      if (current == null || generation != _saveGeneration) return null;

      final step = await _runner.advanceDay(
        current.leagueState,
        saveSeed: current.saveSeed,
        blockOnPendingUrgent: blockOnPendingUrgent,
        resolveContractMarket: resolveContractMarket,
      );
      if (generation != _saveGeneration) return null;
      await _updateLeagueInQueue((_) => step.league, generation: generation);
      return step.result;
    });
  }

  /// Advances one offer hour during extensions/FA phase I. The tenth hour
  /// delegates to the regular end-of-day pipeline, so matches and events are
  /// still resolved exactly once at the end of the calendar day.
  Future<DaySimulationResult?> advanceOneHour() async {
    return _advanceOneHour(blockOnPendingUrgent: true);
  }

  Future<DaySimulationResult?> _advanceOneHour({
    required bool blockOnPendingUrgent,
  }) async {
    if (_careerTransition != null) return null;
    final generation = _saveGeneration;
    final step = await _enqueueMutation(() async {
      final current = save;
      if (current == null || generation != _saveGeneration) return null;

      final hour = await _runner.advanceHour(
        current.leagueState,
        saveSeed: current.saveSeed,
        blockOnPendingUrgent: blockOnPendingUrgent,
      );
      if (generation != _saveGeneration ||
          hour.outcome == HourStepOutcome.notHourly) {
        return null;
      }
      await _updateLeagueInQueue((_) => hour.league, generation: generation);
      return hour;
    });
    if (step == null) return null;

    // The tenth hour leaves the calendar where it is on purpose, so the
    // regular day path stays the only place that resolves end-of-day work.
    if (step.outcome == HourStepOutcome.lastHourReached) {
      return simulateDay(
        resolveContractMarket: false,
        interruptForUrgent: blockOnPendingUrgent,
      );
    }
    return step.result;
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

  /// Runs the automatic/informational calendar event registered for
  /// [eventId] at the current date. No-op (besides validation) for
  /// `playerAction` events like `draft` — those are driven entirely by the
  /// dedicated UI + `makeDraftPick`.
  Future<void> runEventAtCurrentDay(CalendarEventId eventId) async {
    await completeEventAtCurrentDay(eventId);
  }

  Future<DaySimulationResult?> completeEventAtCurrentDay(
    CalendarEventId eventId,
  ) async {
    await _resolveCalendarEventInQueue(eventId);
    final league = save?.leagueState;
    if (league == null ||
        !CalendarEventRegistry.isDone(league.currentSeason, eventId)) {
      return null;
    }
    return simulateDay(interruptForUrgent: false);
  }

  Future<void> _resolveCalendarEventInQueue(CalendarEventId eventId) {
    if (_careerTransition != null) return Future<void>.value();
    final generation = _saveGeneration;
    return _enqueueMutation(() async {
      final current = save;
      if (current == null || generation != _saveGeneration) return;
      final resolved = await _runner.resolveCalendarEvent(
        current.leagueState,
        eventId,
        saveSeed: current.saveSeed,
      );
      if (generation != _saveGeneration) return;
      await _updateLeagueInQueue((_) => resolved, generation: generation);
    });
  }

  /// Auto-simulates the player's fixture headlessly (same engine call as
  /// AI-vs-AI fixtures in `DaySimulator._resolveRound`) and applies the
  /// result via `applyPlayerMatchResult`. Used only by `simulateToDate` —
  /// `simulateToEvent` must hand the match off to `MatchdayScreen` instead
  /// (`DaySimulator.simulateDay` deliberately does not auto-sim it).
  /// Returns `null` if either team can't be resolved (should not happen in
  /// practice; treated as a hard stop by the caller).
  Future<MatchResult?> _autoSimulatePlayerMatch(ScheduledMatch match) {
    if (_careerTransition != null) return Future.value(null);
    final generation = _saveGeneration;
    return _enqueueMutation(() async {
      final current = save;
      if (current == null || generation != _saveGeneration) return null;

      final auto = await _runner.autoSimulatePlayerMatch(
        current.leagueState,
        match,
        saveSeed: current.saveSeed,
      );
      if (auto.result == null || generation != _saveGeneration) return null;
      await _updateLeagueInQueue((_) => auto.league, generation: generation);
      return auto.result;
    });
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
      final feedback = CalendarDaySimulationFeedback(
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
      );
      await Future.any<void>([
        Future<void>.sync(() => observer(feedback)),
        session.cancelled.future,
      ]);
    }

    // An observer may start a newer run while this session is suspended. In
    // that case this session must not wait on or reset the newer run's pacer.
    if (!_isCurrentSimulationSession(session)) return false;

    if (pacer != null) {
      await Future.any<void>([pacer.completeDay(), session.cancelled.future]);
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
    if (_careerTransition != null) {
      return const BatchSimulationResult(
        stopReason: SimulationStopReason.cancelled,
        daysSimulated: 0,
      );
    }
    final session = _startSimulationSession(
      urgentInterruptionEnabled: _readUrgentInterruptionEnabled(),
    );
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
      try {
        if (identical(_activeSimulationSession, session)) {
          pacer?.skipDay();
          _activeSimulationSession = null;
          await persist();
        }
      } finally {
        session.done.complete();
      }
    }
  }

  /// Repeatedly invokes the same day primitive until [reachedTarget] holds
  /// (checked before each day), an interactive event/match/urgent condition
  /// stops the batch, cancellation is requested, or [maxDays] is hit.
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

      if (reachedTarget(league)) {
        // A calendar target can be the first date on which a scheduled urgent
        // message is delivered. Surface that message before stopping at the
        // target, but do not simulate the target day or publish incomplete
        // feedback for it.
        if (calendarPresentation && _hasScheduledUrgentDue(league)) {
          await updateLeague(
            (latest) => _deliverStartOfDay(
              latest,
              hour: latest.currentHour,
              saveSeed: save!.saveSeed,
              resolveExpired: false,
            ),
          );
          if (!_isCurrentSimulationSession(session)) {
            return BatchSimulationResult(
              stopReason: SimulationStopReason.cancelled,
              daysSimulated: daysSimulated,
              lastResult: lastResult,
            );
          }
          if (_shouldStopForUrgent(session, save!.leagueState)) {
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
      final wasHourlyEnd =
          isHourly &&
          _calendar.isLastHour(startWeek, startDay, league.currentHour ?? 1);
      if (pacer != null && (!isHourly || !pacer.hasActiveDay)) {
        pacer.startDay();
      }

      final result = isHourly
          ? await _advanceOneHour(
              blockOnPendingUrgent: session.urgentInterruptionEnabled,
            )
          : await simulateDay(
              interruptForUrgent: session.urgentInterruptionEnabled,
            );
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
            _shouldStopForUrgent(session, currentAfterNullStep.leagueState)) {
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

      if (result.eventId != null) {
        if (autoResolveEvents && result.eventId != CalendarEventId.draft) {
          final eventId = result.eventId!;
          await _resolveCalendarEventInQueue(eventId);
          if (!_isCurrentSimulationSession(session)) {
            return BatchSimulationResult(
              stopReason: SimulationStopReason.cancelled,
              daysSimulated: daysSimulated,
              lastResult: lastResult,
            );
          }
          final resolvedLeague = save?.leagueState;
          if (resolvedLeague != null &&
              CalendarEventRegistry.isDone(
                resolvedLeague.currentSeason,
                eventId,
              )) {
            pacer?.skipDay();
            continue;
          }
        }
        pacer?.skipDay();
        return BatchSimulationResult(
          stopReason: SimulationStopReason.event,
          daysSimulated: daysSimulated,
          lastResult: result,
          eventId: result.eventId,
        );
      }

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

            if (_shouldStopForUrgent(session, leagueAfter)) {
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
        if (result.pauseForUrgent &&
            _shouldStopForUrgent(session, result.league)) {
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
      } else if (result.pauseForUrgent &&
          _shouldStopForUrgent(session, result.league)) {
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
    return _simulateUntil((_) => false, autoSimulatePlayerMatch: false);
  }

  /// Invokes [simulateDay] until the beginning of (week, day). The target day
  /// itself is not simulated.
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

  Future<void> applyPlayerMatch(ScheduledMatch match, MatchResult result) {
    if (_careerTransition != null) return Future<void>.value();
    final generation = _saveGeneration;
    return _enqueueMutation(() async {
      final current = save;
      if (current == null || generation != _saveGeneration) return;
      final applied = await _runner.applyPlayerMatchResult(
        current.leagueState,
        match,
        result,
        saveSeed: current.saveSeed,
      );
      if (generation != _saveGeneration) return;
      await _updateLeagueInQueue((_) => applied, generation: generation);
    });
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

  Future<TradeOfferResult?> acceptTradeOffer(String offerId) {
    return _mutateSave<TradeOfferResult?>(null, (current) async {
      final actingTeamId = current.leagueState.playerTeamId;
      if (actingTeamId == null) return null;
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
      await _publishLeagueInQueue((_) => result.league);
      return result;
    });
  }

  Future<TradeOfferResult?> rejectTradeOffer(String offerId) {
    return _mutateSave<TradeOfferResult?>(null, (current) async {
      final actingTeamId = current.leagueState.playerTeamId;
      if (actingTeamId == null) return null;
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
      await _publishLeagueInQueue((_) => result.league);
      return result;
    });
  }

  Future<TradeOfferResult?> counterTradeOffer(
    String offerId,
    TradeProposal proposal,
  ) {
    return _mutateSave<TradeOfferResult?>(null, (current) async {
      final actingTeamId = current.leagueState.playerTeamId;
      if (actingTeamId == null) return null;
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
      if (result.changed) await _publishLeagueInQueue((_) => result.league);
      return result;
    });
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
    final generation = _saveGeneration;
    await updateLeague(
      (l) => _season.advanceDraft(
        l,
        playerPickProspectId: prospectId,
        saveSeed: save!.saveSeed,
      ),
    );
    if (generation != _saveGeneration || _careerTransition != null) return;
    final league = save?.leagueState;
    if (league != null &&
        CalendarEventRegistry.isDone(
          league.currentSeason,
          CalendarEventId.draft,
        )) {
      await simulateDay(interruptForUrgent: false);
    }
  }

  Future<void> simulateOneDraftPick() async {
    await updateLeague(
      (l) => _season.advanceDraftOnePick(l, saveSeed: save!.saveSeed),
    );
  }

  Future<void> simulateDraftToPlayerTurn() async {
    await updateLeague(
      (l) => _season.advanceDraft(l, saveSeed: save!.saveSeed),
    );
  }

  /// Submits a free-agent offer through the central contract-market
  /// resolver. Accept remains pending until explicit finalization.
  Future<ContractReaction> offerFreeAgent(
    String freeAgentId,
    ContractOffer offer,
  ) {
    return _mutateSave<ContractReaction>(ContractReaction.hardReject, (
      current,
    ) async {
      final submission = _market.submitPlayerOffer(
        league: current.leagueState,
        playerId: freeAgentId,
        offer: offer,
        saveSeed: current.saveSeed,
      );
      if (submission == null) return ContractReaction.hardReject;
      await _publishLeagueInQueue((_) => submission.league);
      return submission.reaction;
    });
  }

  /// Submits a player extension through the central contract-market
  /// resolver. The accepted offer remains pending until finalization.
  Future<ContractReaction> offerContractExtension(
    String playerId,
    ContractOffer offer,
  ) {
    return _mutateSave<ContractReaction>(ContractReaction.hardReject, (
      current,
    ) async {
      final submission = _market.submitPlayerOffer(
        league: current.leagueState,
        playerId: playerId,
        offer: offer,
        saveSeed: current.saveSeed,
      );
      if (submission == null) return ContractReaction.hardReject;
      await _publishLeagueInQueue((_) => submission.league);
      return submission.reaction;
    });
  }

  Future<bool> finalizeContractNegotiation(String negotiationId) {
    return _mutateSave<bool>(false, (current) async {
      final next = _market.finalizeNegotiation(
        current.leagueState,
        negotiationId,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> respondToContractCounter(
    String negotiationId, {
    required bool accept,
    ContractOffer? offer,
  }) {
    return _mutateSave<bool>(false, (current) async {
      final next = _market.resolveCounterResponse(
        current.leagueState,
        negotiationId,
        accept: accept,
        playerOffer: offer,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> respondToStaffCounter(
    String negotiationId, {
    required bool accept,
    StaffOffer? offer,
  }) {
    return _mutateSave<bool>(false, (current) async {
      final next = _market.resolveCounterResponse(
        current.leagueState,
        negotiationId,
        accept: accept,
        staffOffer: offer,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> submitQualifyingOffer(
    String playerId, {
    int? salary,
    int years = 1,
  }) {
    return _mutateSave<bool>(false, (current) async {
      final teamId = current.leagueState.playerTeamId;
      if (teamId == null) return false;
      final next = _market.submitQualifyingOffer(
        league: current.leagueState,
        ownerTeamId: teamId,
        playerId: playerId,
        salary: salary,
        years: years,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> declineQualifyingOffer(String playerId) {
    return _mutateSave<bool>(false, (current) async {
      if (current.leagueState.playerTeamId == null) {
        return false;
      }
      await _publishLeagueInQueue(
        (league) => _market.declineQualifyingOffer(league, playerId),
      );
      return true;
    });
  }

  Future<bool> submitRfaOfferSheet(String playerId, ContractOffer offer) {
    return _mutateSave<bool>(false, (current) async {
      final teamId = current.leagueState.playerTeamId;
      if (teamId == null) return false;
      final next = _market.submitOfferSheet(
        league: current.leagueState,
        offeringTeamId: teamId,
        playerId: playerId,
        offer: offer,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> matchRfaOfferSheet(String sheetId) {
    return _mutateSave<bool>(false, (current) async {
      final next = _market.matchOfferSheet(
        current.leagueState,
        sheetId,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> declineRfaOfferSheet(String sheetId) {
    return _mutateSave<bool>(false, (current) async {
      await _publishLeagueInQueue(
        (league) => _market.declineOfferSheet(league, sheetId),
      );
      return true;
    });
  }

  Future<bool> signDraftedRight(String rightId) {
    return _mutateSave<bool>(false, (current) async {
      final next = _market.signDraftedRight(
        current.leagueState,
        rightId,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  StaffService get _staff => _ref.read(staffServiceProvider);

  /// Submits a staff offer through the central contract-market resolver.
  Future<StaffReaction> offerStaff(StaffMember candidate, StaffOffer offer) {
    return _mutateSave<StaffReaction>(StaffReaction.hardReject, (
      current,
    ) async {
      final submission = _market.submitStaffOffer(
        league: current.leagueState,
        candidate: candidate,
        offer: offer,
        saveSeed: current.saveSeed,
      );
      if (submission == null) return StaffReaction.hardReject;
      await _publishLeagueInQueue((_) => submission.league);
      return submission.reaction;
    });
  }

  /// Compatibility wrapper for callers that only need to know whether the
  /// offer reached Accept. It no longer hires immediately; the returned true
  /// means a pending finalization record was created.
  Future<bool> hireStaff(StaffMember candidate, StaffOffer offer) async {
    final reaction = await offerStaff(candidate, offer);
    return reaction == StaffReaction.accept;
  }

  Future<bool> fireStaff(StaffRole role) {
    return _mutateSave<bool>(false, (current) async {
      final team = current.leagueState.playerTeam;
      if (team == null) return false;
      final updatedTeam = _staff.fire(team, role);
      if (updatedTeam == team) return false;
      await _publishLeagueInQueue((league) => league.updateTeam(updatedTeam));
      return true;
    });
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
  Future<bool> setCombineAssignments(List<String> prospectIds) {
    return _mutateSave<bool>(false, (current) async {
      final league = current.leagueState;
      final team = league.playerTeam;
      final draftClass = league.currentSeason.draftState?.draftClass;
      if (team == null || draftClass == null) {
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
        availableProspectIds: draftClass.prospects.map(
          (prospect) => prospect.id,
        ),
      );
      await _publishLeagueInQueue(
        (state) => state.updateTeam(team.copyWith(scouting: scouting)),
      );
      return true;
    });
  }

  /// Stops the active batch and persists its final state before leaving.
  /// Repeated clicks share the same operation; a write failure keeps the save.
  Future<void> clear() {
    if (_leavingCareer && _careerTransition != null) return _careerTransition!;
    return _changeCareer(() async => null, leaving: true);
  }

  /// Called only inside save management, after an explicitly requested delete.
  /// It must not save the deleted career or enqueue work behind itself.
  void clearDeletedSave(String id) {
    if (_saveManagementGeneration != _saveGeneration || save?.meta.id != id) {
      return;
    }
    cancelSimulation();
    _saveGeneration++;
    _resetPersistence();
    state = const AsyncValue.data(null);
  }
}

final class _SimulationSession {
  _SimulationSession(this.runId, {required this.urgentInterruptionEnabled});

  final int runId;
  final bool urgentInterruptionEnabled;
  final cancelled = Completer<void>();
  final done = Completer<void>();

  bool get cancelRequested => cancelled.isCompleted;

  void cancel() {
    if (!cancelled.isCompleted) cancelled.complete();
  }
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
