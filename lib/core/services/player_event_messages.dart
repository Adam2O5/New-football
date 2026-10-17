part of 'player_event_service.dart';

mixin _PlayerEventMessages on _PlayerEventShared {
  @override
  LeagueState _emitDecision(
    LeagueState state, {
    required String teamId,
    required Player player,
    required String kind,
    required int expiryDays,
    required int saveSeed,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
  }) {
    final completePayload = <String, dynamic>{
      'playerId': player.id,
      'teamId': teamId,
      'eventKind': kind,
      ...payload,
    };
    final completeArgs = <String, dynamic>{'playerName': player.name, ...args};

    // AI decisions are resolved synchronously. Building an in-memory message
    // keeps all six effects on the same [resolveDecision] path as the player
    // UI without putting an AI event into the human inbox.
    if (state.playerTeamId != teamId) {
      final message = GameMessage(
        id: 'ai:playerEvent:$kind:$teamId:${player.id}:${state.currentSeason.year}:${state.currentWeek}',
        type: MessageType.playerEvent,
        kind: kind,
        domain: MessageDomain.playerEvent,
        seasonYear: state.currentSeason.year,
        week: state.currentWeek,
        day: state.currentDay,
        titleKey: 'ai.playerEvent.$kind.title',
        bodyKey: 'ai.playerEvent.$kind.body',
        args: completeArgs,
        payload: completePayload,
      );
      return resolveDecision(
        state,
        message,
        _aiDecisionOption(state, player, kind, saveSeed),
        saveSeed: saveSeed,
      );
    }

    return _emit(
      state,
      teamId: teamId,
      player: player,
      kind: kind,
      args: completeArgs,
      payload: completePayload,
      expiryDays: expiryDays,
    );
  }

  String _aiDecisionOption(
    LeagueState state,
    Player player,
    String kind,
    int saveSeed,
  ) {
    final probability = switch (kind) {
      'plateau' => balance.events.aiPlateauAcceptChance,
      'coldStreak' => balance.events.aiColdStreakAcceptChance,
      'injuryComplication' => balance.events.aiInjuryComplicationCautiousChance,
      'veteranMotivation' => balance.events.aiVeteranMentorChance,
      'extraTraining' =>
        state.currentSeason.phase == SeasonPhase.playoff
            ? balance.events.aiExtraTrainingPlayoffAcceptChance
            : balance.events.aiExtraTrainingAcceptChance,
      'personalSupport' => balance.events.aiPersonalSupportAcceptChance,
      _ => 0.0,
    };
    final roll = Random(
      playerEventSeed(
        saveSeed,
        state.currentSeason.year,
        state.currentWeek,
        player.id,
        'aiDecision:$kind',
      ),
    ).nextDouble();

    return switch (kind) {
      'plateau' => roll < probability ? 'accept' : 'decline',
      'coldStreak' => roll < probability ? 'accept' : 'decline',
      'injuryComplication' => roll < probability ? 'cautious' : 'full',
      'veteranMotivation' =>
        player.hidden.determination >=
                    balance.events.veteranMentorDeterminationMin &&
                roll < probability
            ? 'mentor'
            : 'ignore',
      'extraTraining' => roll < probability ? 'accept' : 'decline',
      'personalSupport' => roll < probability ? 'accept' : 'decline',
      _ => 'decline',
    };
  }

  @override
  LeagueState _emit(
    LeagueState state, {
    required String teamId,
    required Player player,
    String? kind,
    MessageType type = MessageType.playerEvent,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
    int? expiryDays,
  }) {
    // The inbox is the manager's inbox; AI-club events still affect simulation
    // but are not actionable messages for the human manager.
    if (state.playerTeamId != teamId) return state;
    if (kind != null && expiryDays != null) {
      _pendingDecisionKeys?.add(
        PlayerEventService._pendingKey(player.id, kind),
      );
    }
    state = _publishTickTeams(state);
    final expiresAt = expiryDays == null
        ? null
        : logicalDate(state).add(Duration(days: expiryDays)).toIso8601String();
    return messages.send(
      state,
      type: type,
      kind: type == MessageType.playerEvent ? kind : null,
      domain: type == MessageType.playerEvent
          ? MessageDomain.playerEvent
          : MessageDomain.health,
      args: args,
      payload: payload,
      expiresAt: expiresAt,
      priority: type == MessageType.playerEvent && expiryDays != null
          ? MessagePriority.urgent
          : MessagePriority.normal,
      dedupKey:
          '${type.name}:$kind:${player.id}:${state.currentSeason.year}:${state.currentWeek}',
    );
  }
}
