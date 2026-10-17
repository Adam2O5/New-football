part of 'game_provider.dart';

mixin _GameControllerCalendarFeedback {
  CalendarService get _calendar;

  bool _isCurrentSimulationSession(_SimulationSession session);

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
}
