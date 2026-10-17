part of 'season_service.dart';

mixin _SeasonPlayIn on _SeasonServiceShared {
  /// Resolves the dated play-in flow without changing the existing atomic
  /// [setupPlayIn] API. Wednesday stores the two opening games for each
  /// conference; Saturday stores the deciding games and promotes the eight
  /// playoff teams.
  /// Advances one dated play-in slot. Returns the (possibly unchanged)
  /// league plus [playerMatch]: non-null when the player's team has an
  /// unresolved play-in fixture today, in which case that one game is left
  /// unsimulated (mirroring the regular season's `playerMatch` handoff) and
  /// the caller is expected to route to the interactive matchday flow, then
  /// call [applyPlayInPlayerResult] once it has a result.
  ({LeagueState league, ScheduledMatch? playerMatch}) advancePlayInForDate(
    LeagueState league, {
    required int week,
    required int day,
    int saveSeed = 0,
  }) {
    if (calendar.playInSlotsForDay(week, day).isEmpty) {
      return (league: league, playerMatch: null);
    }

    var state = league;
    final season = league.currentSeason;
    ScheduledMatch? pendingPlayerMatch;
    if (day == 3) {
      final progress = <PlayInProgress>[];
      for (final conference in Conference.values) {
        final progressForConference = season.playInProgress
            .where((p) => p.conference == conference)
            .toList();
        final existing = progressForConference.isEmpty
            ? null
            : progressForConference.first;
        final seeds = _playInSeeds(state, conference);
        if (seeds == null) continue;
        final current =
            existing ??
            PlayInProgress(
              conference: conference,
              seed7TeamId: seeds.s7,
              seed8TeamId: seeds.s8,
              seed9TeamId: seeds.s9,
              seed10TeamId: seeds.s10,
            );

        var game7v8 = current.game7v8;
        if (game7v8 == null) {
          final played = _simPostseason(
            state,
            current.seed7TeamId,
            current.seed8TeamId,
            saveSeed: saveSeed,
            matchId: 'playIn:${conference.name}:7v8',
            phase: SeasonPhase.playIn,
          );
          state = played.league;
          game7v8 = played.result;
          pendingPlayerMatch ??= played.playerMatch;
        }
        var game9v10 = current.game9v10;
        if (game9v10 == null) {
          final played = _simPostseason(
            state,
            current.seed9TeamId,
            current.seed10TeamId,
            saveSeed: saveSeed,
            matchId: 'playIn:${conference.name}:9v10',
            phase: SeasonPhase.playIn,
          );
          state = played.league;
          game9v10 = played.result;
          pendingPlayerMatch ??= played.playerMatch;
        }
        final updatedProgress = current.copyWith(
          game7v8: game7v8,
          game9v10: game9v10,
        );
        progress.add(updatedProgress);
        state = state.copyWith(
          currentSeason: state.currentSeason.copyWith(
            playInProgress: [
              for (final p in state.currentSeason.playInProgress)
                if (p.conference != conference) p,
              updatedProgress,
            ],
          ),
        );
        state = _maybeRevealPlayInProgress(state, conference);
      }
      return (
        league: state.copyWith(
          currentSeason: state.currentSeason.copyWith(
            phase: SeasonPhase.playIn,
            playInProgress: progress,
          ),
        ),
        playerMatch: pendingPlayerMatch,
      );
    }

    final results = [...season.playInResults];
    final remaining = <PlayInProgress>[];
    final finished = <PlayInResult>[];
    for (final progress in season.playInProgress) {
      final game7v8 = progress.game7v8;
      final game9v10 = progress.game9v10;
      if (game7v8 == null || game9v10 == null) {
        remaining.add(progress);
        continue;
      }
      var finalGame = progress.gameFinal;
      if (finalGame == null) {
        final played = _simPostseason(
          state,
          _winnerId(game7v8, progress.seed7TeamId, progress.seed8TeamId) ==
                  progress.seed7TeamId
              ? progress.seed8TeamId
              : progress.seed7TeamId,
          _winnerId(game9v10, progress.seed9TeamId, progress.seed10TeamId),
          saveSeed: saveSeed,
          matchId: 'playIn:${progress.conference.name}:final',
          phase: SeasonPhase.playIn,
        );
        state = played.league;
        finalGame = played.result;
        if (played.playerMatch != null) {
          pendingPlayerMatch ??= played.playerMatch;
          remaining.add(progress);
          continue;
        }
      }
      finished.add(_buildPlayInResult(progress, game7v8, game9v10, finalGame!));
    }
    for (final result in finished) {
      results.removeWhere((r) => r.conference == result.conference);
      results.add(result);
    }
    return (
      league: _sendPlayInResultMessages(
        state.copyWith(
          currentSeason: state.currentSeason.copyWith(
            phase: SeasonPhase.playIn,
            playInResults: results,
            playInProgress: remaining,
          ),
        ),
        finished,
      ),
      playerMatch: pendingPlayerMatch,
    );
  }

  /// Applies the result of a play-in fixture that was played interactively
  /// (paused for via `advancePlayInForDate`'s `playerMatch`) and performs
  /// exactly the bookkeeping that automatic simulation would have: tiebreak
  /// resolution, discipline, team-event hooks, and — if this was the
  /// deciding game — building the final `PlayInResult` and sending the same
  /// messages as the automatic path.
  LeagueState applyPlayInPlayerResult(
    LeagueState league, {
    required String matchId,
    required MatchResult rawResult,
    int saveSeed = 0,
  }) {
    final parts = matchId.split(':');
    if (parts.length != 3 || parts[0] != 'playIn') return league;
    Conference? conference;
    for (final c in Conference.values) {
      if (c.name == parts[1]) conference = c;
    }
    if (conference == null) return league;
    final kind = parts[2];

    final result = _resolvePostseasonTiebreak(
      rawResult,
      saveSeed: saveSeed,
      seasonYear: league.currentSeason.year,
      matchId: matchId,
    );
    var state = _applyMatchFatigue(league, result);
    state = _applyPostseasonDiscipline(
      state,
      result,
      SeasonPhase.playIn,
      matchId: matchId,
    );
    state = teamEvents.afterMatch(state, result, saveSeed: saveSeed);
    state = _recordFixtureResult(state, matchId, result);

    final progressList = state.currentSeason.playInProgress;
    final index = progressList.indexWhere((p) => p.conference == conference);
    if (index == -1) return state;
    final progress = progressList[index];

    final stored = result.slimForStorage();
    final updated = switch (kind) {
      '7v8' => progress.copyWith(game7v8: stored),
      '9v10' => progress.copyWith(game9v10: stored),
      'final' => progress.copyWith(gameFinal: stored),
      _ => progress,
    };

    final game7v8 = updated.game7v8;
    final game9v10 = updated.game9v10;
    final finalGame = updated.gameFinal;
    if (kind == 'final' &&
        game7v8 != null &&
        game9v10 != null &&
        finalGame != null) {
      final playInResult = _buildPlayInResult(
        progress,
        game7v8,
        game9v10,
        finalGame,
      );
      final remaining = [...progressList]..removeAt(index);
      final results = [...state.currentSeason.playInResults]
        ..removeWhere((r) => r.conference == conference)
        ..add(playInResult);
      return _sendPlayInResultMessages(
        state.copyWith(
          currentSeason: state.currentSeason.copyWith(
            playInResults: results,
            playInProgress: remaining,
          ),
        ),
        [playInResult],
      );
    }

    final nextProgress = [...progressList];
    nextProgress[index] = updated;
    state = state.copyWith(
      currentSeason: state.currentSeason.copyWith(playInProgress: nextProgress),
    );
    return _maybeRevealPlayInProgress(state, conference);
  }

  PlayInResult _buildPlayInResult(
    PlayInProgress progress,
    MatchResult game7v8,
    MatchResult game9v10,
    MatchResult finalGame,
  ) {
    final loser78 =
        _winnerId(game7v8, progress.seed7TeamId, progress.seed8TeamId) ==
            progress.seed7TeamId
        ? progress.seed8TeamId
        : progress.seed7TeamId;
    final winner910 = _winnerId(
      game9v10,
      progress.seed9TeamId,
      progress.seed10TeamId,
    );
    final playoff8 = _winnerId(finalGame, loser78, winner910);
    final playoff7 = _winnerId(
      game7v8,
      progress.seed7TeamId,
      progress.seed8TeamId,
    );
    return PlayInResult(
      conference: progress.conference,
      seed7TeamId: progress.seed7TeamId,
      seed8TeamId: progress.seed8TeamId,
      game7v8: game7v8,
      game9v10: game9v10,
      gameFinal: finalGame,
      playoffSeed7TeamId: playoff7,
      playoffSeed8TeamId: playoff8,
    );
  }

  ({String s7, String s8, String s9, String s10})? _playInSeeds(
    LeagueState league,
    Conference conference,
  ) {
    final standings = league.currentSeason.standings
        .firstWhere((s) => s.conference == conference)
        .sorted;
    if (standings.length < 10) return null;
    return (
      s7: standings[6].teamId,
      s8: standings[7].teamId,
      s9: standings[8].teamId,
      s10: standings[9].teamId,
    );
  }

  LeagueState setupPlayIn(LeagueState league, {int saveSeed = 0}) {
    final results = <PlayInResult>[];
    var state = league;
    for (final conf in Conference.values) {
      final cs = state.currentSeason.standings.firstWhere(
        (s) => s.conference == conf,
      );
      final sorted = cs.sorted;
      if (sorted.length < 10) continue;
      final s7 = sorted[6].teamId;
      final s8 = sorted[7].teamId;
      final s9 = sorted[8].teamId;
      final s10 = sorted[9].teamId;

      final first = _simPostseason(
        state,
        s7,
        s8,
        saveSeed: saveSeed,
        matchId: 'playIn:${conf.name}:7v8',
        phase: SeasonPhase.playIn,
        simulatePlayerMatch: true,
      );
      state = first.league;
      final second = _simPostseason(
        state,
        s9,
        s10,
        saveSeed: saveSeed,
        matchId: 'playIn:${conf.name}:9v10',
        phase: SeasonPhase.playIn,
        simulatePlayerMatch: true,
      );
      state = second.league;
      final g78 = first.result!;
      final g910 = second.result!;
      final loser78 = _winnerId(g78, s7, s8) == s7 ? s8 : s7;
      final winner910 = _winnerId(g910, s9, s10);
      final third = _simPostseason(
        state,
        loser78,
        winner910,
        saveSeed: saveSeed,
        matchId: 'playIn:${conf.name}:final',
        phase: SeasonPhase.playIn,
        simulatePlayerMatch: true,
      );
      state = third.league;
      final gFinal = third.result!;
      final playoff8 = _winnerId(gFinal, loser78, winner910);
      final playoff7 = _winnerId(g78, s7, s8);

      results.add(
        PlayInResult(
          conference: conf,
          seed7TeamId: s7,
          seed8TeamId: s8,
          game7v8: g78.slimForStorage(),
          game9v10: g910.slimForStorage(),
          gameFinal: gFinal.slimForStorage(),
          playoffSeed7TeamId: playoff7,
          playoffSeed8TeamId: playoff8,
        ),
      );
    }
    return _sendPlayInResultMessages(
      state.copyWith(
        currentSeason: state.currentSeason.copyWith(
          phase: SeasonPhase.playIn,
          playInResults: results,
        ),
      ),
      results,
    );
  }

  LeagueState _sendPlayInResultMessages(
    LeagueState league,
    Iterable<PlayInResult> results,
  ) {
    var state = league;
    for (final result in results) {
      final playoffTeams = {
        result.playoffSeed7TeamId,
        result.playoffSeed8TeamId,
      };
      final ownClub =
          state.playerTeamId != null &&
          playoffTeams.contains(state.playerTeamId);
      state = _messages.send(
        state,
        type: MessageType.playInResult,
        domain: MessageDomain.season,
        args: {
          'conference': result.conference.name,
          'seed7': _teamName(state, result.playoffSeed7TeamId),
          'seed8': _teamName(state, result.playoffSeed8TeamId),
          'ownClub': ownClub,
        },
        payload: {
          'conference': result.conference.name,
          'teamId': ownClub ? state.playerTeamId : null,
          'playoffSeed7TeamId': result.playoffSeed7TeamId,
          'playoffSeed8TeamId': result.playoffSeed8TeamId,
          'ownClub': ownClub,
          'isLeagueMessage': !ownClub,
        },
      );
    }
    return state;
  }

  @override
  LeagueState _sendPlayoffSeedingMessages(
    LeagueState league,
    Iterable<PlayoffBracket> brackets,
  ) {
    var state = league;
    for (final bracket in brackets) {
      final seededTeams = {
        for (final series in bracket.quarterFinals) ...[
          series.higherSeedTeamId,
          series.lowerSeedTeamId,
        ],
      };
      final ownClub =
          state.playerTeamId != null &&
          seededTeams.contains(state.playerTeamId);
      state = _messages.send(
        state,
        type: MessageType.playoffSeeding,
        domain: MessageDomain.season,
        args: {
          'conference': bracket.conference.name,
          'seed7': seededTeams.isEmpty
              ? '—'
              : _teamName(state, seededTeams.first),
          'seed8': seededTeams.length < 2
              ? '—'
              : _teamName(state, seededTeams.elementAt(1)),
          'ownClub': ownClub,
        },
        payload: {
          'conference': bracket.conference.name,
          'teamId': ownClub ? state.playerTeamId : null,
          'seededTeamIds': seededTeams.toList(),
          'ownClub': ownClub,
          'isLeagueMessage': !ownClub,
        },
      );
    }
    return state;
  }
}
