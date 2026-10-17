import 'dart:async';
import 'package:new_football/core/tactics/lineup_slots.dart';
import 'package:new_football/core/services/contract_period_service.dart';

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

part 'game_service_providers.dart';
part 'game_simulation_types.dart';
part 'game_controller_messages.dart';
part 'game_controller_calendar_feedback.dart';
part 'game_controller_simulation.dart';
part 'game_controller_contracts.dart';
part 'game_controller_draft_scouting.dart';

class GameController extends StateNotifier<AsyncValue<GameSave?>>
    with
        _GameControllerCalendarFeedback,
        _GameControllerSimulation,
        _GameControllerMessages,
        _GameControllerContracts,
        _GameControllerDraftScouting {
  GameController(this._ref) : super(const AsyncValue.data(null));

  @override
  final Ref _ref;

  SaveRepository get _repo => _ref.read(saveRepositoryProvider);
  @override
  DayPipeline get _pipeline => _ref.read(dayPipelineProvider);
  @override
  SimulationRunner get _runner => _ref.read(simulationRunnerProvider);
  @override
  PlayerEventService get _playerEvents => _ref.read(playerEventServiceProvider);
  @override
  TeamEventService get _teamEvents => _ref.read(teamEventServiceProvider);
  @override
  SeasonService get _season => _ref.read(seasonServiceProvider);
  @override
  CalendarService get _calendar => _ref.read(calendarServiceProvider);
  @override
  ContractMarketService get _market => _ref.read(contractMarketServiceProvider);
  DraftTradeService get _draftTrades => _ref.read(draftTradeServiceProvider);

  /// Every state mutation and persistence operation is appended to this
  /// future. Errors are returned to the operation that caused them, while the
  /// tail itself always completes successfully so a failed save cannot poison
  /// later mutations.
  Future<void> _mutationQueue = Future<void>.value();

  /// Invalidates callbacks that belong to a save which has been cleared or
  /// replaced while an asynchronous repository operation was pending.
  @override
  int _saveGeneration = 0;
  int _stateRevision = 0;
  int _persistedRevision = 0;
  @override
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
  @override
  final Map<_MessageOperationKey, Future<void>> _inFlightMessageOperations = {};

  @override
  GameSave? get save => state.value;

  @override
  Future<T> _enqueueMutation<T>(Future<T> Function() operation) {
    final queued = _mutationQueue.then<T>((_) => operation());
    _mutationQueue = queued.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return queued;
  }

  @override
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

  @override
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

  @override
  Future<void> persist() {
    final generation = _saveGeneration;
    return _enqueueMutation(
      () => _writeCurrentSaveInQueue(generation, force: true),
    );
  }

  @override
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

  @override
  Future<void> _updateLeagueInQueue(
    LeagueState Function(LeagueState) transform, {
    required int generation,
    bool autosave = true,
    bool skipIfUnchanged = false,
  }) async {
    if (generation != _saveGeneration) return;
    final current = save;
    if (current == null) return;
    final league = reconcileLeagueLineups(
      const ContractPeriodService().normalizeLeague(
        transform(current.leagueState),
      ),
    );
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
  @override
  _SimulationSession? _activeSimulationSession;
  @override
  int _nextSimulationRunId = 0;

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

  @override
  StaffService get _staff => _ref.read(staffServiceProvider);

  @override
  ScoutingService get _scouting => _ref.read(scoutingServiceProvider);

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
