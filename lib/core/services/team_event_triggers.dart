part of 'team_event_service.dart';

mixin _TeamEventTriggers on _TeamEventShared {
  LeagueState _tryMoreMinutes(LeagueState state, String teamId, int saveSeed) {
    final team = state.teamById(teamId);
    if (team == null || team.eventState.isOnCooldown('moreMinutesRequest')) {
      return state;
    }
    final events = balance.events;
    final xi = team.startingEleven;
    final averageOvr = xi.isEmpty
        ? 0.0
        : xi.map((player) => _eventOverall(player)).reduce((a, b) => a + b) /
              xi.length;
    final rosterAveragePotential = team.roster.isEmpty
        ? 0.0
        : team.roster
                  .map((player) => player.potentialStars)
                  .reduce((a, b) => a + b) /
              team.roster.length;
    final candidates =
        team.roster.where((player) {
          if (!player.isAvailable) return false;
          if (_hasPendingDecision(
            state,
            player.id,
            'moreMinutesRequest',
            teamId: team.id,
          )) {
            return false;
          }
          if (team.eventState.promiseFor(player.id) != null) return false;
          if (!_isUnderplayed(
            team,
            player.id,
            events.moreMinutesLowShareThreshold,
          )) {
            return false;
          }
          final betterThanXi =
              xi.isNotEmpty && _eventOverall(player) >= averageOvr;
          final youngWithPotential =
              player.age <= 26 &&
              player.potentialStars > rosterAveragePotential;
          return betterThanXi || youngWithPotential;
        }).toList()..sort((a, b) {
          final byOverall = _eventOverall(b).compareTo(_eventOverall(a));
          return byOverall != 0 ? byOverall : a.id.compareTo(b.id);
        });
    if (candidates.isEmpty) return state;

    final player = candidates.first;
    final chance = player.personality == PlayerPersonality.ambitious
        ? events.minutesRequestAmbitiousChance
        : events.minutesRequestChance;
    final effectiveChance =
        chance *
        TeamManagementService.negativeEventMultiplier(team.atmosphere) *
        team.eventState.negativeEventMultiplier;
    final rollState = _setTeamCooldown(state, team.id, 'moreMinutesRequest', 1);
    if (!_roll(
      rollState,
      team.id,
      player.id,
      'moreMinutesRequest',
      effectiveChance,
      saveSeed,
    )) {
      return rollState;
    }
    return _queueDecision(
      rollState,
      teamId: team.id,
      playerId: player.id,
      kind: 'moreMinutesRequest',
      saveSeed: saveSeed,
      payload: {
        'minutesShare': _minutesShare(team, player.id),
        'requiredMinutesShare': events.moreMinutesPromiseShare,
      },
    );
  }

  LeagueState _tryTransferRequestI(
    LeagueState state,
    String teamId,
    int saveSeed,
  ) {
    final team = state.teamById(teamId);
    if (team == null ||
        team.eventState.isOnCooldown('transferRequestI') ||
        !calendar.isTradeWindowOpen(state.currentWeek, day: state.currentDay)) {
      return state;
    }
    final events = balance.events;
    // Neither condition depends on the individual player, and the value cut-off
    // sorts every point value in the league. Resolving both once per team keeps
    // the weekly boundary from repeating that sort for each of its players.
    final lowAtmosphere =
        team.eventState.lowAtmosphereWeeks >= events.lowAtmosphereWeeks;
    final valuableThreshold = lowAtmosphere || !_isBottomHalf(state, team.id)
        ? null
        : _topTwentyPercentValueThreshold(state);
    final candidates =
        team.roster.where((player) {
          if (player.personality == PlayerPersonality.loyal ||
              !player.isAvailable) {
            return false;
          }
          if (team.eventState.transferSituationFor(player.id) != null ||
              _hasPendingDecision(
                state,
                player.id,
                'transferRequestI',
                teamId: team.id,
              )) {
            return false;
          }
          return lowAtmosphere ||
              (valuableThreshold != null &&
                  player.pointValue >= valuableThreshold);
        }).toList()..sort((a, b) {
          final byValue = b.pointValue.compareTo(a.pointValue);
          return byValue != 0 ? byValue : a.id.compareTo(b.id);
        });
    if (candidates.isEmpty) return state;

    final player = candidates.first;
    final reason = lowAtmosphere ? 'lowAtmosphere' : 'valuableInWeakClub';
    final chance =
        events.transferRequestIChance *
        (player.personality == PlayerPersonality.ambitious
            ? events.transferRequestAmbitiousMultiplier
            : 1.0) *
        TeamManagementService.negativeEventMultiplier(team.atmosphere) *
        team.eventState.negativeEventMultiplier;
    final rollState = _setTeamCooldown(state, team.id, 'transferRequestI', 1);
    if (!_roll(
      rollState,
      team.id,
      player.id,
      'transferRequestI',
      chance,
      saveSeed,
    )) {
      return rollState;
    }
    return _queueTransferRequest(
      rollState,
      team.id,
      player.id,
      'transferRequestI',
      saveSeed: saveSeed,
      payload: {'reason': reason},
    );
  }

  LeagueState _tryDressingRoomConflict(
    LeagueState state,
    String teamId,
    int saveSeed,
  ) {
    final team = state.teamById(teamId);
    if (team == null) return state;
    final events = balance.events;
    final temperamental = team.startingEleven
        .where(
          (player) => player.personality == PlayerPersonality.temperamental,
        )
        .toList();
    if (temperamental.length < events.lockerRoomConflictPlayers ||
        team.atmosphere >= events.lowAtmosphereThreshold ||
        team.eventState.isOnCooldown('dressingRoomConflict') ||
        _hasPendingDecision(
          state,
          null,
          'dressingRoomConflict',
          teamId: team.id,
        )) {
      return state;
    }
    final chance =
        events.lockerRoomConflictChance *
        TeamManagementService.negativeEventMultiplier(team.atmosphere) *
        team.eventState.negativeEventMultiplier;
    if (!_roll(
      state,
      team.id,
      null,
      'dressingRoomConflict',
      chance,
      saveSeed,
    )) {
      return state;
    }
    return _queueDecision(
      state,
      teamId: team.id,
      kind: 'dressingRoomConflict',
      saveSeed: saveSeed,
      payload: {
        'temperamentalPlayerIds': [
          for (final player in temperamental) player.id,
        ],
        'personA': temperamental[0].name,
        'personB': temperamental.length > 1
            ? temperamental[1].name
            : temperamental[0].name,
      },
    );
  }

  LeagueState _tryLeaderSupport(
    LeagueState state,
    String teamId,
    int saveSeed,
  ) {
    final team = state.teamById(teamId);
    if (team == null ||
        team.eventState.isOnCooldown('leaderSupport') ||
        _winStreak(team.recentMatchResults) <
            balance.events.leaderSupportWinStreak ||
        !team.startingEleven.any(
          (player) => player.personality == PlayerPersonality.leader,
        )) {
      return state;
    }
    final chance =
        balance.events.leaderSupportChance *
        TeamManagementService.positiveEventMultiplier(team.atmosphere);
    if (!_roll(state, team.id, null, 'leaderSupport', chance, saveSeed)) {
      return state;
    }
    var next = _setTeamEventState(
      state,
      team.id,
      team.eventState.withCooldown(
        'leaderSupport',
        balance.events.leaderSupportCooldownWeeks,
      ),
    );
    next = _applyTeamDeltas(
      next,
      team.id,
      atmosphere: 4,
      chemistry: 1,
      reason: 'leaderSupport',
    );
    final leader = team.startingEleven.firstWhere(
      (player) => player.personality == PlayerPersonality.leader,
    );
    return _emitAutomatic(
      next,
      teamId: team.id,
      kind: 'leaderSupport',
      args: {'playerName': leader.name},
      payload: {
        'teamId': team.id,
        'playerId': leader.id,
        'eventKind': 'leaderSupport',
      },
    );
  }

  LeagueState _tryPublicCriticism(
    LeagueState state,
    String teamId,
    int saveSeed,
  ) {
    final team = state.teamById(teamId);
    if (team == null ||
        team.atmosphere >= balance.events.publicCriticismAtmosphereThreshold ||
        _hasPendingDecision(state, null, 'publicCriticism', teamId: team.id)) {
      return state;
    }
    final candidate = [...team.roster]
      ..sort((a, b) {
        final byOverall = _eventOverall(b).compareTo(_eventOverall(a));
        return byOverall != 0 ? byOverall : a.id.compareTo(b.id);
      });
    final player = candidate
        .take(15)
        .where((candidate) => candidate.age > 25)
        .firstOrNull;
    if (player == null) return state;
    final rollMultiplier = team.eventState.publicCriticismRollMultiplier;
    final chance =
        balance.events.publicCriticismChance *
        TeamManagementService.negativeEventMultiplier(team.atmosphere) *
        team.eventState.negativeEventMultiplier *
        rollMultiplier;
    final resetMultiplier = _setTeamEventState(
      state,
      team.id,
      team.eventState.copyWith(publicCriticismRollMultiplier: 1.0),
    );
    if (!_roll(
      resetMultiplier,
      team.id,
      player.id,
      'publicCriticism',
      chance,
      saveSeed,
    )) {
      return resetMultiplier;
    }
    return _queueDecision(
      resetMultiplier,
      teamId: team.id,
      playerId: player.id,
      kind: 'publicCriticism',
      saveSeed: saveSeed,
      payload: {'publicCriticismMultiplier': rollMultiplier},
    );
  }
}
