part of 'team_event_service.dart';

mixin _TeamEventMessages on _TeamEventShared {
  @override
  LeagueState _queueTransferRequest(
    LeagueState state,
    String teamId,
    String playerId,
    String kind, {
    required int saveSeed,
    bool bypassWindow = false,
    Map<String, dynamic> payload = const {},
  }) {
    final team = state.teamById(teamId);
    final player = team == null ? null : _findPlayer(team, playerId);
    if (team == null || player == null) return state;
    if (player.personality == PlayerPersonality.loyal ||
        team.eventState.transferSituationFor(playerId) != null ||
        _hasPendingDecision(state, playerId, kind, teamId: team.id)) {
      return state;
    }
    if (!bypassWindow &&
        kind == 'transferRequestI' &&
        !calendar.isTradeWindowOpen(state.currentWeek, day: state.currentDay)) {
      return state;
    }
    if (kind == 'transferRequestII' && _isFutureUfa(player)) {
      return _emitDeclineToExtend(state, teamId, player);
    }
    var next = _setPointValueMultiplier(state, teamId, playerId, 0.9);
    return _queueDecision(
      next,
      teamId: teamId,
      playerId: playerId,
      kind: kind,
      saveSeed: saveSeed,
      payload: payload,
    );
  }

  LeagueState _emitDeclineToExtend(
    LeagueState state,
    String teamId,
    Player player,
  ) {
    final team = state.teamById(teamId);
    if (team == null ||
        team.eventState.hasSeasonFlag(
          'declineToExtend:${player.id}',
          state.currentSeason.year,
        )) {
      return state;
    }
    final flagged = team.eventState.withSeasonFlag(
      'declineToExtend:${player.id}',
      state.currentSeason.year,
    );
    final next = _setTeamEventState(state, teamId, flagged);
    return _emitAutomatic(
      next,
      teamId: teamId,
      kind: 'declineToExtend',
      args: {'playerName': player.name},
      payload: {
        'teamId': teamId,
        'playerId': player.id,
        'eventKind': 'declineToExtend',
      },
    );
  }

  @override
  LeagueState _queueDecision(
    LeagueState state, {
    required String teamId,
    String? playerId,
    required String kind,
    required int saveSeed,
    Map<String, dynamic> payload = const {},
  }) {
    final team = state.teamById(teamId);
    if (team == null) return state;
    final player = playerId == null ? null : _findPlayer(team, playerId);
    final expandedPayload = <String, dynamic>{
      'teamId': teamId,
      'eventKind': kind,
    };
    if (playerId != null) {
      expandedPayload['playerId'] = playerId;
    }
    expandedPayload.addAll(payload);
    if (state.playerTeamId == teamId) {
      return _emitDecisionMessage(
        state,
        teamId: teamId,
        player: player,
        kind: kind,
        payload: expandedPayload,
      );
    }
    final option = _aiDecisionOption(state, team, player, kind, saveSeed);
    return _applyDecision(
      state,
      teamId: teamId,
      playerId: playerId,
      kind: kind,
      optionId: option,
      saveSeed: saveSeed,
      payload: expandedPayload,
    );
  }

  String _aiDecisionOption(
    LeagueState state,
    Team team,
    Player? player,
    String kind,
    int saveSeed,
  ) {
    final roll = _aiDecisionRoll(state, team.id, kind, saveSeed);
    switch (kind) {
      case 'moreMinutesRequest':
        final acceptChance = player != null && _isTopFourteen(team, player.id)
            ? balance.events.aiMoreMinutesTopFourteenAcceptChance
            : balance.events.aiMoreMinutesDepthAcceptChance;
        return roll < acceptChance ? 'accept' : 'decline';
      case 'transferRequestI':
        // `TradeService.assetValue` has no player-only API here. pointValue is
        // its existing objective asset proxy; the temporary event multiplier
        // is included so a devalued player is not treated as a positive asset.
        final positiveAsset =
            player != null &&
            player.pointValue *
                    team.eventState.pointValueMultiplierFor(player.id) >
                0;
        final inTradeWindow = calendar.isTradeWindowOpen(
          state.currentWeek,
          day: state.currentDay,
        );
        final acceptChance = positiveAsset && inTradeWindow
            ? balance.events.aiTransferRequestAcceptChance
            : balance.events.aiTransferRequestOtherAcceptChance;
        return roll < acceptChance ? 'accept' : 'decline';
      case 'transferRequestII':
        return roll < balance.events.aiTransferRequestIIAcceptChance
            ? 'accept'
            : 'decline';
      case 'dressingRoomConflict':
        return roll < balance.events.aiDressingRoomInterveneChance
            ? 'intervene'
            : 'ignore';
      case 'publicCriticism':
        if (roll < balance.events.aiPublicCriticismPunishChance) {
          return 'punish';
        }
        if (roll < balance.events.aiPublicCriticismResponseCutoff) {
          return 'response';
        }
        return 'ignore';
      default:
        return 'decline';
    }
  }

  double _aiDecisionRoll(
    LeagueState state,
    String teamId,
    String kind,
    int saveSeed,
  ) => Random(
    teamEventSeed(
      saveSeed,
      state.currentSeason.year,
      state.currentWeek,
      teamId,
      'aiDecision:$kind',
    ),
  ).nextDouble();

  bool _isTopFourteen(Team team, String playerId) {
    final ranked = [...team.roster]
      ..sort((a, b) {
        final byOverall = _eventOverall(b).compareTo(_eventOverall(a));
        return byOverall != 0 ? byOverall : a.id.compareTo(b.id);
      });
    final rank = ranked.indexWhere((player) => player.id == playerId);
    return rank >= 0 && rank < 14;
  }

  LeagueState _emitDecisionMessage(
    LeagueState state, {
    required String teamId,
    required Player? player,
    required String kind,
    required Map<String, dynamic> payload,
  }) {
    // Team events are generated at the end of a simulated day and become
    // actionable at the next day's start. Keep the configured one actionable
    // day after that delivery boundary instead of expiring at that boundary.
    final expiry = logicalDate(state)
        .add(Duration(days: balance.events.teamEventDecisionExpiryDays + 1))
        .toIso8601String();
    return messages.send(
      state,
      type: MessageType.teamEvent,
      kind: kind,
      domain: MessageDomain.teamEvent,
      priority: MessagePriority.urgent,
      args: {if (player != null) 'playerName': player.name, ...payload},
      payload: payload,
      expiresAt: expiry,
      dedupKey:
          'teamEvent:$kind:$teamId:${player?.id ?? 'team'}:${state.currentSeason.year}:${state.currentWeek}',
    );
  }

  @override
  LeagueState _emitAutomatic(
    LeagueState state, {
    required String teamId,
    required String kind,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
    MessagePriority? priority,
  }) {
    if (state.playerTeamId != teamId) return state;
    final playerId = payload['playerId'] ?? args['playerId'];
    final team = state.teamById(teamId);
    final player = playerId is String && team != null
        ? _findPlayer(team, playerId)
        : null;
    return messages.send(
      state,
      type: MessageType.teamEvent,
      kind: kind,
      domain: MessageDomain.teamEvent,
      priority: priority ?? MessagePriority.normal,
      args: {if (player != null) 'playerName': player.name, ...args},
      payload: payload,
      dedupKey:
          'teamEvent:$kind:$teamId:${payload['playerId'] ?? 'team'}:${state.currentSeason.year}:${state.currentWeek}',
    );
  }
}
