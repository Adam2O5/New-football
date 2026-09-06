import 'dart:async';
import 'dart:isolate';

import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/day_pipeline.dart';
import 'package:new_football/core/services/day_simulator.dart';

/// Executes the day-advancement steps of [DayPipeline] for `GameController`.
///
/// The interface is asynchronous so the same call sites work whether the work
/// runs inline on the calling isolate ([InlineSimulationRunner], used by
/// tests) or on a background isolate ([IsolateSimulationRunner], used by the
/// app).
abstract interface class SimulationRunner {
  Future<DayStepOutput> advanceDay(
    LeagueState league, {
    required int saveSeed,
    bool blockOnPendingUrgent = true,
    bool resolveContractMarket = true,
  });

  Future<HourStepOutput> advanceHour(
    LeagueState league, {
    required int saveSeed,
    bool blockOnPendingUrgent = true,
  });

  Future<LeagueState> resolveCalendarEvent(
    LeagueState league,
    CalendarEventId eventId, {
    int saveSeed = 0,
  });

  Future<LeagueState> applyPlayerMatchResult(
    LeagueState league,
    ScheduledMatch match,
    MatchResult result, {
    int saveSeed = 0,
  });

  Future<({LeagueState league, MatchResult? result})> autoSimulatePlayerMatch(
    LeagueState league,
    ScheduledMatch match, {
    required int saveSeed,
  });

  void dispose();
}

/// Runs every step on the calling isolate.
class InlineSimulationRunner implements SimulationRunner {
  InlineSimulationRunner([DayPipeline? pipeline])
    : _pipeline = pipeline ?? DayPipeline();

  final DayPipeline _pipeline;

  @override
  Future<DayStepOutput> advanceDay(
    LeagueState league, {
    required int saveSeed,
    bool blockOnPendingUrgent = true,
    bool resolveContractMarket = true,
  }) async => _pipeline.advanceDay(
    league,
    saveSeed: saveSeed,
    blockOnPendingUrgent: blockOnPendingUrgent,
    resolveContractMarket: resolveContractMarket,
  );

  @override
  Future<HourStepOutput> advanceHour(
    LeagueState league, {
    required int saveSeed,
    bool blockOnPendingUrgent = true,
  }) async => _pipeline.advanceHour(
    league,
    saveSeed: saveSeed,
    blockOnPendingUrgent: blockOnPendingUrgent,
  );

  @override
  Future<LeagueState> resolveCalendarEvent(
    LeagueState league,
    CalendarEventId eventId, {
    int saveSeed = 0,
  }) async => _pipeline.resolveCalendarEvent(
    league,
    eventId,
    saveSeed: saveSeed,
  );

  @override
  Future<LeagueState> applyPlayerMatchResult(
    LeagueState league,
    ScheduledMatch match,
    MatchResult result, {
    int saveSeed = 0,
  }) async => _pipeline.applyPlayerMatchResult(
    league,
    match,
    result,
    saveSeed: saveSeed,
  );

  @override
  Future<({LeagueState league, MatchResult? result})> autoSimulatePlayerMatch(
    LeagueState league,
    ScheduledMatch match, {
    required int saveSeed,
  }) async =>
      _pipeline.autoSimulatePlayerMatch(league, match, saveSeed: saveSeed);

  @override
  void dispose() {}
}

/// Failure raised inside the worker isolate, rethrown on the calling isolate.
class SimulationWorkerException implements Exception {
  const SimulationWorkerException(this.message);

  final String message;

  @override
  String toString() => 'SimulationWorkerException: $message';
}

/// Runs every step on a single long-lived background isolate.
///
/// `Isolate.run`/`compute` per day is deliberately avoided: each call copies
/// its argument on the *calling* isolate, so a hundred-day fast-forward would
/// pay a hundred copies of the league on the UI thread. This worker keeps the
/// state it last produced, so a step that continues from that state sends only
/// its parameters — the league then crosses the port once per day (the reply
/// the UI has to publish) instead of twice.
class IsolateSimulationRunner implements SimulationRunner {
  IsolateSimulationRunner();

  final Map<int, Completer<_StepResponse>> _pending = {};

  Isolate? _isolate;
  SendPort? _commands;
  ReceivePort? _responses;
  Future<void>? _spawning;
  int _nextRequestId = 0;
  bool _disposed = false;

  /// The state the worker holds, as observed from this isolate. Instance
  /// identity is the whole point: only a league that came out of the worker
  /// unchanged may be replaced by "continue from your own state".
  LeagueState? _workerLeague;

  @override
  Future<DayStepOutput> advanceDay(
    LeagueState league, {
    required int saveSeed,
    bool blockOnPendingUrgent = true,
    bool resolveContractMarket = true,
  }) async {
    final response = await _send(
      league,
      (id, payload) => _StepRequest(
        id: id,
        kind: _StepKind.advanceDay,
        saveSeed: saveSeed,
        league: payload,
        blockOnPendingUrgent: blockOnPendingUrgent,
        resolveContractMarket: resolveContractMarket,
      ),
    );
    return DayStepOutput(league: response.league, result: response.dayResult);
  }

  @override
  Future<HourStepOutput> advanceHour(
    LeagueState league, {
    required int saveSeed,
    bool blockOnPendingUrgent = true,
  }) async {
    final response = await _send(
      league,
      (id, payload) => _StepRequest(
        id: id,
        kind: _StepKind.advanceHour,
        saveSeed: saveSeed,
        league: payload,
        blockOnPendingUrgent: blockOnPendingUrgent,
      ),
    );
    return HourStepOutput(
      outcome: response.hourOutcome ?? HourStepOutcome.notHourly,
      league: response.league,
      result: response.dayResult,
    );
  }

  @override
  Future<LeagueState> resolveCalendarEvent(
    LeagueState league,
    CalendarEventId eventId, {
    int saveSeed = 0,
  }) async {
    final response = await _send(
      league,
      (id, payload) => _StepRequest(
        id: id,
        kind: _StepKind.resolveCalendarEvent,
        saveSeed: saveSeed,
        league: payload,
        eventId: eventId,
      ),
    );
    return response.league;
  }

  @override
  Future<LeagueState> applyPlayerMatchResult(
    LeagueState league,
    ScheduledMatch match,
    MatchResult result, {
    int saveSeed = 0,
  }) async {
    final response = await _send(
      league,
      (id, payload) => _StepRequest(
        id: id,
        kind: _StepKind.applyPlayerMatchResult,
        saveSeed: saveSeed,
        league: payload,
        match: match,
        matchResult: result,
      ),
    );
    return response.league;
  }

  @override
  Future<({LeagueState league, MatchResult? result})> autoSimulatePlayerMatch(
    LeagueState league,
    ScheduledMatch match, {
    required int saveSeed,
  }) async {
    final response = await _send(
      league,
      (id, payload) => _StepRequest(
        id: id,
        kind: _StepKind.autoSimulatePlayerMatch,
        saveSeed: saveSeed,
        league: payload,
        match: match,
      ),
    );
    return (league: response.league, result: response.matchResult);
  }

  @override
  void dispose() {
    _disposed = true;
    _commands?.send(const _Shutdown());
    _teardown(const SimulationWorkerException('Simulation worker disposed.'));
  }

  Future<_StepResponse> _send(
    LeagueState league,
    _StepRequest Function(int id, LeagueState? league) build,
  ) async {
    if (_disposed) {
      throw const SimulationWorkerException('Simulation worker disposed.');
    }
    await _ensureSpawned();
    final commands = _commands;
    if (commands == null) {
      throw const SimulationWorkerException('Simulation worker unavailable.');
    }

    final id = _nextRequestId++;
    final completer = Completer<_StepResponse>();
    _pending[id] = completer;
    commands.send(build(id, identical(_workerLeague, league) ? null : league));
    final response = await completer.future;
    _workerLeague = response.league;
    return response;
  }

  Future<void> _ensureSpawned() {
    final spawning = _spawning;
    if (spawning != null) return spawning;
    return _spawning = _spawn();
  }

  Future<void> _spawn() async {
    final responses = ReceivePort();
    final ready = Completer<SendPort>();
    responses.listen((Object? message) {
      switch (message) {
        case SendPort port:
          if (!ready.isCompleted) ready.complete(port);
        case _StepResponse response:
          _pending.remove(response.id)?.complete(response);
        case _StepError error:
          _pending.remove(error.id)?.completeError(
            SimulationWorkerException(error.error),
            StackTrace.fromString(error.stackTrace),
          );
        // An uncaught error arrives as [error, stackTrace] and isolate death
        // as null. Either way the worker's cached state is gone, so every
        // waiting step fails and the next one spawns a fresh worker.
        case final List<Object?> failure:
          _teardown(
            SimulationWorkerException('${failure.firstOrNull ?? 'unknown'}'),
          );
        case null:
          _teardown(
            const SimulationWorkerException('Simulation worker exited.'),
          );
      }
    });

    try {
      _isolate = await Isolate.spawn(
        _workerMain,
        responses.sendPort,
        onError: responses.sendPort,
        onExit: responses.sendPort,
        errorsAreFatal: false,
        debugName: 'simulation-worker',
      );
    } on Object {
      responses.close();
      _spawning = null;
      rethrow;
    }
    _responses = responses;
    _commands = await ready.future;
  }

  void _teardown(SimulationWorkerException reason) {
    final pending = List.of(_pending.values);
    _pending.clear();
    for (final completer in pending) {
      if (!completer.isCompleted) completer.completeError(reason);
    }
    _responses?.close();
    _responses = null;
    _commands = null;
    _workerLeague = null;
    _spawning = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }
}

enum _StepKind {
  advanceDay,
  advanceHour,
  resolveCalendarEvent,
  applyPlayerMatchResult,
  autoSimulatePlayerMatch,
}

class _Shutdown {
  const _Shutdown();
}

class _StepRequest {
  const _StepRequest({
    required this.id,
    required this.kind,
    required this.saveSeed,
    this.league,
    this.blockOnPendingUrgent = true,
    this.resolveContractMarket = true,
    this.eventId,
    this.match,
    this.matchResult,
  });

  final int id;
  final _StepKind kind;
  final int saveSeed;

  /// Null asks the worker to continue from the state it last produced.
  final LeagueState? league;
  final bool blockOnPendingUrgent;
  final bool resolveContractMarket;
  final CalendarEventId? eventId;
  final ScheduledMatch? match;
  final MatchResult? matchResult;
}

class _StepResponse {
  const _StepResponse({
    required this.id,
    required this.league,
    this.dayResult,
    this.hourOutcome,
    this.matchResult,
  });

  final int id;
  final LeagueState league;
  final DaySimulationResult? dayResult;
  final HourStepOutcome? hourOutcome;
  final MatchResult? matchResult;
}

class _StepError {
  const _StepError(this.id, this.error, this.stackTrace);

  final int id;
  final String error;
  final String stackTrace;
}

void _workerMain(SendPort responses) {
  final commands = ReceivePort();
  responses.send(commands.sendPort);

  final pipeline = DayPipeline();
  LeagueState? cached;

  commands.listen((Object? message) {
    if (message is _Shutdown) {
      commands.close();
      return;
    }
    if (message is! _StepRequest) return;

    try {
      final league = message.league ?? cached;
      if (league == null) {
        throw StateError(
          'Simulation worker was asked to continue without a cached state.',
        );
      }
      final response = _runStep(pipeline, message, league);
      cached = response.league;
      responses.send(response);
    } catch (error, stackTrace) {
      responses.send(
        _StepError(message.id, error.toString(), stackTrace.toString()),
      );
    }
  });
}

_StepResponse _runStep(
  DayPipeline pipeline,
  _StepRequest request,
  LeagueState league,
) {
  switch (request.kind) {
    case _StepKind.advanceDay:
      final step = pipeline.advanceDay(
        league,
        saveSeed: request.saveSeed,
        blockOnPendingUrgent: request.blockOnPendingUrgent,
        resolveContractMarket: request.resolveContractMarket,
      );
      return _StepResponse(
        id: request.id,
        league: step.league,
        dayResult: step.result,
      );
    case _StepKind.advanceHour:
      final step = pipeline.advanceHour(
        league,
        saveSeed: request.saveSeed,
        blockOnPendingUrgent: request.blockOnPendingUrgent,
      );
      return _StepResponse(
        id: request.id,
        league: step.league,
        dayResult: step.result,
        hourOutcome: step.outcome,
      );
    case _StepKind.resolveCalendarEvent:
      return _StepResponse(
        id: request.id,
        league: pipeline.resolveCalendarEvent(
          league,
          request.eventId!,
          saveSeed: request.saveSeed,
        ),
      );
    case _StepKind.applyPlayerMatchResult:
      return _StepResponse(
        id: request.id,
        league: pipeline.applyPlayerMatchResult(
          league,
          request.match!,
          request.matchResult!,
          saveSeed: request.saveSeed,
        ),
      );
    case _StepKind.autoSimulatePlayerMatch:
      final auto = pipeline.autoSimulatePlayerMatch(
        league,
        request.match!,
        saveSeed: request.saveSeed,
      );
      return _StepResponse(
        id: request.id,
        league: auto.league,
        matchResult: auto.result,
      );
  }
}
