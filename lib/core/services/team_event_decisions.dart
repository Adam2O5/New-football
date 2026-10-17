part of 'team_event_service.dart';

mixin _TeamEventDecisions on _TeamEventShared {
  @override
  LeagueState _applyDecision(
    LeagueState state, {
    required String teamId,
    required String? playerId,
    required String kind,
    required String optionId,
    required int saveSeed,
    Map<String, dynamic> payload = const {},
  }) {
    final team = state.teamById(teamId);
    if (team == null) return state;
    final player = playerId == null ? null : _findPlayer(team, playerId);

    switch (kind) {
      case 'moreMinutesRequest':
        if (player == null) return state;
        if (optionId == 'accept') {
          final promise = TeamPromise(
            id: 'moreMinutes:${state.currentSeason.year}:${state.currentWeek}:${player.id}',
            playerId: player.id,
            kind: 'moreMinutesRequest',
            createdSeasonYear: state.currentSeason.year,
            createdWeek: state.currentWeek,
            durationWeeks: balance.events.moreMinutesPromiseWeeks,
            requiredMinutesShare: balance.events.moreMinutesPromiseShare,
          );
          var next = _applyTeamStateAndDeltas(
            state,
            teamId,
            team.eventState.copyWith(
              promises: [
                ...team.eventState.promises.where(
                  (item) => item.playerId != player.id,
                ),
                promise,
              ],
            ),
            atmosphere: -3,
            reason: 'moreMinutesAccept',
            payload: {'playerId': player.id, 'promiseId': promise.id},
          );
          final updatedTeam = next.teamById(teamId);
          if (updatedTeam == null) return next;
          final promisedPlayer = updatedTeam.roster.cast<Player?>().firstWhere(
            (candidate) => candidate?.id == player.id,
            orElse: () => null,
          );
          if (promisedPlayer == null) return next;
          return next.updateTeam(
            updatedTeam.copyWith(
              roster: updatedTeam.roster
                  .map(
                    (candidate) => candidate.id == player.id
                        ? candidate.copyWith(
                            state: candidate.state.copyWith(
                              eventState: candidate.state.eventState
                                  .replaceModifier(
                                    type: 'promiseMatchScoreBonus',
                                    value: balance
                                        .events
                                        .moreMinutesPromiseMatchScoreBonus,
                                    weeks:
                                        balance.events.moreMinutesPromiseWeeks,
                                  ),
                            ),
                          )
                        : candidate,
                  )
                  .toList(),
            ),
          );
        }
        if (optionId == 'decline') {
          final extra =
              player.personality == PlayerPersonality.temperamental ||
                  player.personality == PlayerPersonality.ambitious
              ? 3
              : 0;
          return _applyTeamDeltas(
            state,
            teamId,
            atmosphere: -7 - extra,
            reason: 'moreMinutesDecline',
            payload: {'playerId': player.id},
          );
        }
        return state;

      case 'transferRequestI':
      case 'transferRequestII':
        if (player == null) return state;
        if (optionId == 'accept') {
          final situation = TeamTransferSituation(
            id: '$kind:${state.currentSeason.year}:${state.currentWeek}:${player.id}',
            playerId: player.id,
            kind: kind,
            createdSeasonYear: state.currentSeason.year,
            createdWeek: state.currentWeek,
            weeksRemaining: balance.events.transferSituationWeeks,
          );
          var next = _applyTeamStateAndDeltas(
            state,
            teamId,
            team.eventState.copyWith(
              transferSituations: [
                ...team.eventState.transferSituations.where(
                  (item) => item.playerId != player.id,
                ),
                situation,
              ],
            ),
            atmosphere: 3,
            reason: '${kind}Accept',
            payload: {'playerId': player.id, 'situationId': situation.id},
          );
          next = _setPointValueMultiplier(next, teamId, player.id, 0.9);
          final updated = next.teamById(teamId);
          if (updated == null) return next;
          return _setTeamEventState(
            next,
            teamId,
            updated.eventState
                .replaceModifier(
                  type: 'tradeAppetite:${player.id}',
                  value: balance.events.transferTradeAppetiteMultiplier - 1.0,
                  weeks: balance.events.transferSituationWeeks,
                )
                .replaceModifier(
                  type: 'tradeSurplusPct:${player.id}',
                  value: balance.events.transferTradeSurplusShift,
                  weeks: balance.events.transferSituationWeeks,
                ),
          );
        }
        if (optionId == 'decline') {
          var next = _applyTeamDeltas(
            state,
            teamId,
            atmosphere: -6,
            chemistry: -2,
            reason: '${kind}Decline',
            payload: {'playerId': player.id},
          );
          next = _clearPointValueMultiplier(next, teamId, player.id);
          return next;
        }
        return state;

      case 'dressingRoomConflict':
        final ids =
            (payload['temperamentalPlayerIds'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            const <String>[];
        var next = _setTeamCooldown(state, teamId, 'dressingRoomConflict', 1);
        if (optionId == 'intervene') {
          final positive =
              _random(
                next,
                teamId,
                null,
                'dressingRoomConflictOutcome',
                saveSeed,
              ).nextDouble() <
              0.5;
          next = _applyTeamDeltas(
            next,
            teamId,
            atmosphere: positive ? 2 : -3,
            chemistry: -2,
            reason: 'dressingRoomConflictIntervene',
          );
          if (!positive) {
            next = _addTeamModifier(
              next,
              teamId,
              type: 'negativeEventMultiplier',
              value: 0.2,
              weeks: balance.events.dressingRoomConflictPenaltyWeeks,
            );
          }
          if (ids.isEmpty) return next;
          final transferPlayer = _findPlayer(next.teamById(teamId)!, ids.first);
          if (transferPlayer == null) return next;
          return _queueTransferRequest(
            next,
            teamId,
            transferPlayer.id,
            'transferRequestI',
            saveSeed: saveSeed,
            bypassWindow: true,
          );
        }
        if (optionId == 'ignore') {
          next = _applyTeamDeltas(
            next,
            teamId,
            atmosphere: -3,
            chemistry: -2,
            reason: 'dressingRoomConflictIgnore',
          );
          return _addTeamModifier(
            next,
            teamId,
            type: 'negativeEventMultiplier',
            value: 0.2,
            weeks: balance.events.dressingRoomConflictPenaltyWeeks,
          );
        }
        return state;

      case 'publicCriticism':
        if (player == null) return state;
        final nextMultiplier = switch (optionId) {
          'punish' => balance.events.publicCriticismPunishRollMultiplier,
          'ignore' => balance.events.publicCriticismIgnoreRollMultiplier,
          'response' => 1.0,
          _ => null,
        };
        if (nextMultiplier == null) return state;
        final (atmosphere, chemistry) = switch (optionId) {
          'punish' => (-2, -2.0),
          'response' => (-1, -1.0),
          _ => (-1, -1.0),
        };
        final current = team.eventState.copyWith(
          publicCriticismRollMultiplier: nextMultiplier,
        );
        return _applyTeamStateAndDeltas(
          state,
          teamId,
          current,
          atmosphere: atmosphere,
          chemistry: chemistry,
          reason: 'publicCriticism:$optionId',
          payload: {'playerId': player.id, 'option': optionId},
        );

      default:
        return state;
    }
  }
}
