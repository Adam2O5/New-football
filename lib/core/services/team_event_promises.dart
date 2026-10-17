part of 'team_event_service.dart';

mixin _TeamEventPromises on _TeamEventShared {
  LeagueState _settlePromises(LeagueState state, String teamId, int saveSeed) {
    final team = state.teamById(teamId);
    if (team == null || team.eventState.promises.isEmpty) return state;
    var nextState = state;
    final promises = <TeamPromise>[];
    for (final promise in team.eventState.promises) {
      final nextPromise = promise.copyWith(
        weeksElapsed: promise.weeksElapsed + 1,
      );
      final createdWeekKey = _calendarWeekKey(
        promise.createdSeasonYear,
        promise.createdWeek,
      );
      final currentWeekKey = _calendarWeekKey(
        state.currentSeason.year,
        state.currentWeek,
      );
      final elapsedCalendarWeeks = currentWeekKey - createdWeekKey;
      final history = team.eventState.minutesHistory
          .where(
            (entry) =>
                entry.playerId == promise.playerId &&
                _calendarWeekKey(entry.seasonYear, entry.week) > createdWeekKey,
          )
          .toList();
      final observedWeeks = history
          .map((entry) => _calendarWeekKey(entry.seasonYear, entry.week))
          .toSet()
          .length;
      final shouldSettle =
          nextPromise.weeksElapsed >= promise.durationWeeks &&
          (observedWeeks >= promise.durationWeeks ||
              elapsedCalendarWeeks > promise.durationWeeks);
      if (!shouldSettle) {
        promises.add(nextPromise);
        continue;
      }
      final possible = history.fold<int>(
        0,
        (sum, entry) => sum + entry.possibleMinutes,
      );
      final minutes = history.fold<int>(0, (sum, entry) => sum + entry.minutes);
      final fulfilled =
          possible > 0 && minutes / possible >= promise.requiredMinutesShare;
      final player = _findPlayer(team, promise.playerId);
      if (fulfilled) {
        nextState = _applyTeamDeltas(
          nextState,
          team.id,
          atmosphere: 5,
          reason: 'promiseFulfilled',
          payload: {'playerId': promise.playerId, 'promiseId': promise.id},
        );
      } else {
        final extraPenalty = player == null
            ? 0
            : (player.personality == PlayerPersonality.temperamental ||
                      player.personality == PlayerPersonality.ambitious
                  ? 3
                  : 0);
        nextState = _applyTeamDeltas(
          nextState,
          team.id,
          atmosphere: -12 - extraPenalty,
          reason: 'promiseBroken',
          payload: {
            'playerId': promise.playerId,
            'promiseId': promise.id,
            'minutes': minutes,
            'possibleMinutes': possible,
          },
        );
        nextState = _emitAutomatic(
          nextState,
          teamId: team.id,
          kind: 'promiseBroken',
          priority: MessagePriority.urgent,
          args: {if (player != null) 'playerName': player.name},
          payload: {
            'teamId': team.id,
            'playerId': promise.playerId,
            'promiseId': promise.id,
            'eventKind': 'promiseBroken',
          },
        );
        if (player != null &&
            _roll(
              nextState,
              team.id,
              player.id,
              'transferRequestIIAfterPromise',
              balance.events.transferRequestIIChanceAfterBrokenPromise,
              saveSeed,
            )) {
          nextState = _queueTransferRequest(
            nextState,
            team.id,
            player.id,
            'transferRequestII',
            saveSeed: saveSeed,
          );
        }
      }
    }
    final current = nextState.teamById(team.id);
    if (current == null) return nextState;
    return _setTeamEventState(
      nextState,
      team.id,
      current.eventState.copyWith(promises: promises),
    );
  }

  LeagueState _settleTransferSituations(LeagueState state, String teamId) {
    final team = state.teamById(teamId);
    if (team == null || team.eventState.transferSituations.isEmpty) {
      return state;
    }
    var nextState = state;
    final active = <TeamTransferSituation>[];
    for (final situation in team.eventState.transferSituations) {
      final windowOpen = calendar.isTradeWindowOpen(
        state.currentWeek,
        day: state.currentDay,
      );
      final weeksSinceCreated =
          _calendarWeekKey(state.currentSeason.year, state.currentWeek) -
          _calendarWeekKey(situation.createdSeasonYear, situation.createdWeek);
      // The first weekly tick after acceptance starts the first full week; it
      // must not consume a week that only contains the acceptance day.
      final isInitialClock =
          weeksSinceCreated <= 1 &&
          situation.weeksRemaining >= balance.events.transferSituationWeeks;
      final remaining = isInitialClock
          ? situation.weeksRemaining
          : situation.weeksRemaining - 1;
      if (remaining > 0 && windowOpen) {
        active.add(situation.copyWith(weeksRemaining: remaining));
        continue;
      }
      nextState = _applyTeamDeltas(
        nextState,
        team.id,
        atmosphere: -15,
        chemistry: -4,
        reason: 'transferRequestExpired',
        payload: {
          'playerId': situation.playerId,
          'eventKind': situation.kind,
          'transferSituationId': situation.id,
        },
      );
      nextState = _clearPointValueMultiplier(
        nextState,
        team.id,
        situation.playerId,
      );
    }
    final current = nextState.teamById(team.id);
    if (current == null) return nextState;
    return _setTeamEventState(
      nextState,
      team.id,
      current.eventState.copyWith(transferSituations: active),
    );
  }
}
