part of 'team_event_service.dart';

mixin _TeamEventHelpers on _TeamEventShared {
  /// Returns the event-ranking OVR without assuming that a test fixture's
  /// position matches the attribute-card variant. Valid production players
  /// produce the same value as [PlayerX.overall].
  @override
  double _eventOverall(Player player) => switch (player.attributes) {
    OutfieldPlayerAttributes(:final stats) => stats.overallForPosition(
      player.position,
      balance,
    ),
    GoalkeeperPlayerAttributes(:final stats) => stats.overall,
    _ => 0.0,
  };

  @override
  LeagueState _applyTeamDeltas(
    LeagueState state,
    String teamId, {
    int atmosphere = 0,
    double chemistry = 0,
    required String reason,
    Map<String, dynamic> payload = const {},
  }) {
    if (atmosphere == 0 && chemistry == 0) return state;
    final team = state.teamById(teamId);
    if (team == null) return state;
    final updated = teamManagement.applyChemistryDelta(
      teamManagement.applyAtmosphereDelta(team, atmosphere),
      chemistry,
    );
    var next = state.updateTeam(updated);
    final actualAtmosphere = updated.atmosphere - team.atmosphere;
    final actualChemistry = updated.chemistry - team.chemistry;
    if (state.playerTeamId != teamId) return next;
    next = messages.send(
      next,
      type: MessageType.teamEvent,
      kind: 'atmosphereShift',
      domain: MessageDomain.teamEvent,
      args: {
        'delta': actualAtmosphere,
        'chemistryDelta': actualChemistry,
        'oldLevel': team.atmosphere,
        'newLevel': updated.atmosphere,
        'atmosphereBefore': team.atmosphere,
        'atmosphereAfter': updated.atmosphere,
        'atmosphere': updated.atmosphere,
        'chemistry': updated.chemistry,
        ...payload,
      },
      payload: {
        'teamId': teamId,
        'eventKind': 'atmosphereShift',
        'atmosphereDelta': actualAtmosphere,
        'chemistryDelta': actualChemistry,
        'oldLevel': team.atmosphere,
        'newLevel': updated.atmosphere,
        'atmosphereBefore': team.atmosphere,
        'atmosphereAfter': updated.atmosphere,
        'atmosphere': updated.atmosphere,
        'chemistry': updated.chemistry,
        'reason': reason,
        ...payload,
      },
      dedupKey:
          'atmosphere:event:$reason:$teamId:${state.currentSeason.year}:${state.currentWeek}',
    );
    return next;
  }

  @override
  LeagueState _applyTeamStateAndDeltas(
    LeagueState state,
    String teamId,
    TeamEventState eventState, {
    int atmosphere = 0,
    double chemistry = 0,
    required String reason,
    Map<String, dynamic> payload = const {},
  }) {
    final stateWithEvent = _setTeamEventState(state, teamId, eventState);
    return _applyTeamDeltas(
      stateWithEvent,
      teamId,
      atmosphere: atmosphere,
      chemistry: chemistry,
      reason: reason,
      payload: payload,
    );
  }

  @override
  LeagueState _setTeamEventState(
    LeagueState state,
    String teamId,
    TeamEventState eventState,
  ) {
    final team = state.teamById(teamId);
    return team == null
        ? state
        : state.updateTeam(team.copyWith(eventState: eventState));
  }

  @override
  LeagueState _setTeamCooldown(
    LeagueState state,
    String teamId,
    String key,
    int weeks,
  ) {
    final team = state.teamById(teamId);
    return team == null
        ? state
        : _setTeamEventState(
            state,
            teamId,
            team.eventState.withCooldown(key, weeks),
          );
  }

  @override
  LeagueState _addTeamModifier(
    LeagueState state,
    String teamId, {
    required String type,
    required double value,
    required int weeks,
  }) {
    final team = state.teamById(teamId);
    return team == null
        ? state
        : _setTeamEventState(
            state,
            teamId,
            team.eventState.addModifier(type: type, value: value, weeks: weeks),
          );
  }

  @override
  LeagueState _setPointValueMultiplier(
    LeagueState state,
    String teamId,
    String playerId,
    double multiplier,
  ) {
    final team = state.teamById(teamId);
    return team == null
        ? state
        : _setTeamEventState(
            state,
            teamId,
            team.eventState.withPointValueMultiplier(playerId, multiplier),
          );
  }

  @override
  LeagueState _clearPointValueMultiplier(
    LeagueState state,
    String teamId,
    String playerId,
  ) {
    final team = state.teamById(teamId);
    if (team == null) return state;
    final eventState = team.eventState
        .clearPointValueMultiplier(playerId)
        .clearModifier('tradeAppetite:$playerId')
        .clearModifier('tradeSurplusPct:$playerId');
    return _setTeamEventState(state, teamId, eventState);
  }

  @override
  bool _isUnderplayed(Team team, String playerId, double threshold) {
    final entries = team.eventState.minutesHistory
        .where((entry) => entry.playerId == playerId)
        .toList();
    if (entries.isEmpty) return false;
    final minutes = entries.fold<int>(0, (sum, entry) => sum + entry.minutes);
    final possible = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.possibleMinutes,
    );
    return possible > 0 && minutes / possible < threshold;
  }

  @override
  double _minutesShare(Team team, String playerId) {
    final entries = team.eventState.minutesHistory
        .where((entry) => entry.playerId == playerId)
        .toList();
    final minutes = entries.fold<int>(0, (sum, entry) => sum + entry.minutes);
    final possible = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.possibleMinutes,
    );
    return possible == 0 ? 0 : minutes / possible;
  }

  /// Lowest point value still inside the league's most valuable fifth, or null
  /// when the league has no players.
  @override
  int? _topTwentyPercentValueThreshold(LeagueState state) {
    if (_valueThresholdReady) return _valueThresholdCache;
    final values = [
      for (final team in state.teams)
        for (final candidate in team.roster) candidate.pointValue,
    ]..sort((a, b) => b.compareTo(a));
    if (values.isEmpty) {
      _valueThresholdCache = null;
    } else {
      final count = max(1, (values.length * 0.20).ceil());
      _valueThresholdCache = values[min(count - 1, values.length - 1)];
    }
    _valueThresholdReady = true;
    return _valueThresholdCache;
  }

  @override
  bool _isBottomHalf(LeagueState state, String teamId) {
    final rank = TeamManagementService.actualRankOf(state, teamId);
    return rank > state.teams.length / 2;
  }

  int _playoffRoundReached(LeagueState league, String teamId) {
    var reached = 0;
    for (final bracket in league.currentSeason.playoffBrackets) {
      bool includes(Iterable<PlayoffSeries> series) => series.any(
        (item) =>
            item.higherSeedTeamId == teamId || item.lowerSeedTeamId == teamId,
      );
      if (includes(bracket.quarterFinals)) reached = max(reached, 1);
      if (includes(bracket.semiFinals)) reached = max(reached, 2);
      if (includes(bracket.conferenceFinal)) reached = max(reached, 3);
      final finalSeries = bracket.leagueFinal;
      if (finalSeries != null &&
          (finalSeries.higherSeedTeamId == teamId ||
              finalSeries.lowerSeedTeamId == teamId)) {
        reached = max(reached, 4);
      }
    }
    return reached;
  }

  int _possibleMinutes(Player player) =>
      player.isAvailable ? balance.player.minutesPerMatch : 0;

  @override
  int _winStreak(List<int> results) {
    if (results.isEmpty || results.last != 1) return 0;
    var count = 0;
    for (var index = results.length - 1; index >= 0; index--) {
      if (results[index] != 1) break;
      count++;
    }
    return count;
  }

  @override
  bool _roll(
    LeagueState state,
    String teamId,
    String? playerId,
    String eventKind,
    double probability,
    int saveSeed,
  ) {
    if (probability <= 0) return false;
    if (probability >= 1) return true;
    return _random(state, teamId, playerId, eventKind, saveSeed).nextDouble() <
        probability;
  }

  @override
  Random _random(
    LeagueState state,
    String teamId,
    String? playerId,
    String eventKind,
    int saveSeed, {
    int salt = 0,
  }) => Random(
    teamEventSeed(
      saveSeed,
      state.currentSeason.year,
      state.currentWeek,
      teamId,
      eventKind,
      playerId: playerId,
      salt: salt,
    ),
  );

  @override
  bool _hasPendingDecision(
    LeagueState state,
    String? playerId,
    String kind, {
    String? teamId,
  }) {
    bool pending(GameMessage message) =>
        !message.acknowledged &&
        message.type == MessageType.teamEvent &&
        message.kind == kind &&
        (teamId == null || message.payload['teamId'] == teamId) &&
        (playerId == null || message.payload['playerId'] == playerId);
    return state.inbox.messages.any(pending) ||
        state.inbox.scheduled.any(pending);
  }

  @override
  Player? _findPlayer(Team team, String playerId) {
    for (final player in team.roster) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  @override
  bool _isFutureUfa(Player player) {
    // Contract has no explicit QO/RFA flag yet. Rookie-scale contracts are
    // the only restricted path represented by the current model, so avoid
    // emitting a UFA declaration for them; veteran contracts are treated as
    // UFA candidates when their remaining term reaches one year.
    return player.contract.yearsRemaining <= 1 &&
        !player.contract.isRookieScale;
  }

  @override
  int _calendarWeekKey(int seasonYear, int week) => seasonYear * 52 + week;
}
