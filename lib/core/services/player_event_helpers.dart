part of 'player_event_service.dart';

mixin _PlayerEventHelpers on _PlayerEventShared {
  @override
  bool _rollFor(
    LeagueState state,
    Player player,
    String eventKind,
    double probability,
    int saveSeed,
  ) => _roll(
    saveSeed,
    state.currentSeason.year,
    state.currentWeek,
    player.id,
    eventKind,
    probability,
  );

  @override
  bool _roll(
    int saveSeed,
    int seasonYear,
    int week,
    String playerId,
    String eventKind,
    double probability, {
    int salt = 0,
  }) {
    if (probability <= 0) return false;
    if (probability >= 1) return true;
    return Random(
          playerEventSeed(
            saveSeed,
            seasonYear,
            week,
            playerId,
            eventKind,
            salt: salt,
          ),
        ).nextDouble() <
        probability;
  }

  @override
  Random _randomFor(
    LeagueState state,
    Player player,
    String eventKind,
    int saveSeed, {
    int salt = 0,
  }) => Random(
    playerEventSeed(
      saveSeed,
      state.currentSeason.year,
      state.currentWeek,
      player.id,
      eventKind,
      salt: salt,
    ),
  );

  @override
  bool _hasPendingDecision(LeagueState state, String playerId, String kind) {
    final keys = _pendingDecisionKeys;
    if (keys != null) {
      return keys.contains(PlayerEventService._pendingKey(playerId, kind));
    }
    bool pending(GameMessage message) =>
        !message.acknowledged &&
        message.type == MessageType.playerEvent &&
        message.kind == kind &&
        message.payload['playerId'] == playerId;
    return state.inbox.messages.any(pending) ||
        state.inbox.scheduled.any(pending);
  }

  Set<String> _indexPendingDecisions(LeagueState state) {
    final keys = <String>{};
    void consider(GameMessage message) {
      if (message.acknowledged || message.type != MessageType.playerEvent) {
        return;
      }
      final playerId = message.payload['playerId'];
      final kind = message.kind;
      if (playerId is String && kind != null) {
        keys.add(PlayerEventService._pendingKey(playerId, kind));
      }
    }

    for (final message in state.inbox.messages) {
      consider(message);
    }
    for (final message in state.inbox.scheduled) {
      consider(message);
    }
    return keys;
  }

  Set<String> _indexBottomHalf(LeagueState state) {
    final all = [
      for (final conference in state.currentSeason.standings)
        ...conference.standings,
    ];
    if (all.isEmpty) return {};
    final sorted = [...all]
      ..sort((a, b) {
        final points = b.points.compareTo(a.points);
        if (points != 0) return points;
        return b.goalDifference.compareTo(a.goalDifference);
      });
    final cutoff = (sorted.length / 2).ceil();
    return {for (var i = cutoff; i < sorted.length; i++) sorted[i].teamId};
  }

  @override
  bool _isBottomHalf(LeagueState state, String teamId) {
    final cached = _bottomHalfTeamIds;
    if (cached != null) return cached.contains(teamId);
    return _indexBottomHalf(state).contains(teamId);
  }

  @override
  Team? _teamById(LeagueState state, String teamId) =>
      _tickTeams?[teamId] ?? state.teamById(teamId);

  @override
  LeagueState _publishTickTeams(LeagueState state) {
    final tickTeams = _tickTeams;
    if (tickTeams == null) return state;
    return state.copyWith(
      teams: [for (final team in state.teams) tickTeams[team.id] ?? team],
    );
  }

  Team? _findTeamWithPlayer(LeagueState state, String playerId) {
    final tickTeams = _tickTeams;
    if (tickTeams != null) {
      for (final team in tickTeams.values) {
        if (_findPlayer(team, playerId) != null) return team;
      }
      return null;
    }
    for (final team in state.teams) {
      if (_findPlayer(team, playerId) != null) return team;
    }
    return null;
  }

  Player? _findPlayer(Team team, String? playerId) {
    if (playerId == null) return null;
    for (final player in team.roster) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  @override
  Player? _currentPlayer(LeagueState state, String teamId, String? playerId) {
    final team = _teamById(state, teamId);
    if (team == null) return null;
    if (playerId != null) return _findPlayer(team, playerId);
    return team.roster.isEmpty ? null : team.roster.first;
  }

  @override
  LeagueState _replacePlayer(LeagueState state, String teamId, Player player) {
    final tickTeams = _tickTeams;
    if (tickTeams != null) {
      final team = tickTeams[teamId];
      if (team == null) return state;
      tickTeams[teamId] = team.copyWith(
        roster: [
          for (final candidate in team.roster)
            candidate.id == player.id ? player : candidate,
        ],
      );
      return state;
    }
    final team = state.teamById(teamId);
    if (team == null) return state;
    return state.updateTeam(
      team.copyWith(
        roster: [
          for (final candidate in team.roster)
            candidate.id == player.id ? player : candidate,
        ],
      ),
    );
  }

  @override
  int _range(Random random, int minValue, int maxValue) => minValue == maxValue
      ? minValue
      : minValue + random.nextInt(maxValue - minValue + 1);
}
