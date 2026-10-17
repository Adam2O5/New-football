part of 'game_provider.dart';

mixin _GameControllerSimulation on _GameControllerCalendarFeedback {
  Ref get _ref;

  DayPipeline get _pipeline;

  SimulationRunner get _runner;

  int get _saveGeneration;

  Future<void>? get _careerTransition;

  GameSave? get save;

  Future<T> _enqueueMutation<T>(Future<T> Function() operation);

  Future<void> persist();

  Future<void> updateLeague(
    LeagueState Function(LeagueState) transform, {
    bool autosave = true,
  });

  Future<void> _updateLeagueInQueue(
    LeagueState Function(LeagueState) transform, {
    required int generation,
  });

  _SimulationSession? get _activeSimulationSession;
  set _activeSimulationSession(_SimulationSession? session);

  int get _nextSimulationRunId;
  set _nextSimulationRunId(int runId);

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

  @override
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
}
