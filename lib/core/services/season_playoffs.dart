part of 'season_service.dart';

mixin _SeasonPlayoffs on _SeasonServiceShared {
  LeagueState setupPlayoffs(LeagueState league) {
    final brackets = <PlayoffBracket>[];
    for (final conf in Conference.values) {
      final cs = league.currentSeason.standings
          .firstWhere((s) => s.conference == conf)
          .sorted;
      final playIn = league.currentSeason.playInResults
          .cast<PlayInResult?>()
          .firstWhere((p) => p?.conference == conf, orElse: () => null);
      final seeds = <String>[
        cs[0].teamId,
        cs[1].teamId,
        cs[2].teamId,
        cs[3].teamId,
        cs[4].teamId,
        cs[5].teamId,
        playIn?.playoffSeed7TeamId ?? cs[6].teamId,
        playIn?.playoffSeed8TeamId ?? cs[7].teamId,
      ];
      brackets.add(
        PlayoffBracket(
          conference: conf,
          quarterFinals: [
            _series(seeds[0], seeds[7]),
            _series(seeds[1], seeds[6]),
            _series(seeds[2], seeds[5]),
            _series(seeds[3], seeds[4]),
          ],
        ),
      );
    }
    return _sendPlayoffSeedingMessages(
      league.copyWith(
        currentSeason: league.currentSeason.copyWith(
          phase: SeasonPhase.playoff,
          playoffBrackets: brackets,
        ),
      ),
      brackets,
    );
  }

  /// Advances one dated playoff slot by playing exactly the fixtures
  /// scheduled for [week]/[day] — and nothing else. This is what actually
  /// keeps a series inside its 3-week round window: a newly-created next
  /// round's series exist as soon as their predecessors decide it, but their
  /// fixtures are eagerly dated into the *next* round's window
  /// (`_scheduleNewlyCreatedRounds`), so there's simply nothing due for them
  /// until that window arrives — no separate "wait for the round boundary"
  /// check is needed. [playerMatch] is non-null when the player's team has
  /// an unresolved game today; the caller should route to the interactive
  /// matchday flow and later call [applyPlayoffPlayerResult].
  ({LeagueState league, ScheduledMatch? playerMatch}) advancePlayoffsForDate(
    LeagueState league, {
    required int week,
    required int day,
    int saveSeed = 0,
  }) {
    final round = calendar.playoffRoundForWeek(week);
    if (round == null) return (league: league, playerMatch: null);

    final dueIds = [
      for (final f in league.currentSeason.postseasonFixtures)
        if (f.id.startsWith('playoff:') &&
            f.week == week &&
            f.day == day &&
            f.result == null &&
            f.homePlaceholderLabel == null &&
            f.awayPlaceholderLabel == null)
          f.id,
    ];
    if (dueIds.isEmpty) return (league: league, playerMatch: null);

    var state = league;
    ScheduledMatch? pendingPlayerMatch;
    for (final matchId in dueIds) {
      final seriesId = matchId.split(':')[1];
      final series = _findSeriesById(state, seriesId);
      if (series == null || series.isComplete || series.isPending) continue;
      final played = _playOneGame(state, series, saveSeed);
      state = played.league;
      if (played.playerMatch != null) {
        pendingPlayerMatch ??= played.playerMatch;
        continue;
      }
      state = _writeSeriesBack(state, seriesId, played.series);
      state = _reconcileSeriesFixtures(state, played.series);
    }

    state = _progressPlayoffBracketsAndChampion(state, saveSeed: saveSeed);
    return (league: state, playerMatch: pendingPlayerMatch);
  }

  /// Applies the result of a playoff/league-final fixture that was played
  /// interactively (paused for via `advancePlayoffsForDate`'s
  /// `playerMatch`). Records the game into the series wherever it lives
  /// (quarterfinal/semifinal/conference final/league final, across either
  /// conference bracket) and performs the same round-progression and
  /// champion-crowning bookkeeping [advancePlayoffsForDate] does, without
  /// simulating any other fixture for the day.
  LeagueState applyPlayoffPlayerResult(
    LeagueState league, {
    required String matchId,
    required MatchResult rawResult,
    int saveSeed = 0,
  }) {
    final parts = matchId.split(':');
    if (parts.length != 3 || parts[0] != 'playoff') return league;
    final seriesId = parts[1];

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
      SeasonPhase.playoff,
      matchId: matchId,
    );
    state = teamEvents.afterMatch(state, result, saveSeed: saveSeed);
    state = _recordFixtureResult(state, matchId, result);

    final series = _findSeriesById(state, seriesId);
    if (series == null) return state;
    final updated = series.recordGame(result);
    state = _writeSeriesBack(state, seriesId, updated);
    state = _reconcileSeriesFixtures(state, updated);
    return _progressPlayoffBracketsAndChampion(state, saveSeed: saveSeed);
  }

  /// Finds a series by id anywhere across both conference brackets —
  /// quarterfinal, semifinal, conference final, or league final (which is
  /// duplicated onto both brackets once created, but always identical).
  PlayoffSeries? _findSeriesById(LeagueState league, String seriesId) {
    for (final b in league.currentSeason.playoffBrackets) {
      if (b.leagueFinal?.id == seriesId) return b.leagueFinal;
      for (final s in [
        ...b.quarterFinals,
        ...b.semiFinals,
        ...b.conferenceFinal,
      ]) {
        if (s.id == seriesId) return s;
      }
    }
    return null;
  }

  /// Writes [updated] back wherever a series with [seriesId] lives, across
  /// both conference brackets (a league final match applies to both, since
  /// it's duplicated onto each).
  LeagueState _writeSeriesBack(
    LeagueState league,
    String seriesId,
    PlayoffSeries updated,
  ) {
    final brackets = league.currentSeason.playoffBrackets.map((b) {
      if (b.leagueFinal?.id == seriesId) {
        return b.copyWith(leagueFinal: updated);
      }
      return b.copyWith(
        quarterFinals: [
          for (final s in b.quarterFinals) s.id == seriesId ? updated : s,
        ],
        semiFinals: [
          for (final s in b.semiFinals) s.id == seriesId ? updated : s,
        ],
        conferenceFinal: [
          for (final s in b.conferenceFinal) s.id == seriesId ? updated : s,
        ],
      );
    }).toList();
    return league.copyWith(
      currentSeason: league.currentSeason.copyWith(playoffBrackets: brackets),
    );
  }

  /// After a series' game is recorded: once it's complete, any never-played
  /// game-4/5 fixture is removed outright (per `game_calendar.md`: a series
  /// decided in 3 or 4 games leaves the rest of its 3-week block empty, it
  /// doesn't hand the winner an early fixture); otherwise, once 3 games are
  /// in, the next (4th/5th) game's fixture — already scheduled, just greyed
  /// out — is confirmed.
  LeagueState _reconcileSeriesFixtures(
    LeagueState league,
    PlayoffSeries series,
  ) {
    final played = series.games.length;
    List<ScheduledMatch> fixtures;
    if (series.isComplete) {
      fixtures = [
        for (final f in league.currentSeason.postseasonFixtures)
          if (!(f.id.startsWith('playoff:${series.id}:') &&
              f.result == null &&
              int.parse(f.id.split(':')[2]) >= played))
            f,
      ];
    } else if (played >= 3) {
      fixtures = [
        for (final f in league.currentSeason.postseasonFixtures)
          if (f.id == 'playoff:${series.id}:$played')
            f.copyWith(confirmed: true)
          else
            f,
      ];
    } else {
      return league;
    }
    return league.copyWith(
      currentSeason: league.currentSeason.copyWith(
        postseasonFixtures: fixtures,
      ),
    );
  }

  /// Creates the next playoff round(s) once every series in the current
  /// round is complete (pure bracket bookkeeping, plays no games), eagerly
  /// schedules the new round's fixtures, and crowns the champion once the
  /// league final resolves. Shared by [advancePlayoffsForDate] and
  /// [applyPlayoffPlayerResult] so both paths perform identical bookkeeping.
  LeagueState _progressPlayoffBracketsAndChampion(
    LeagueState league, {
    required int saveSeed,
  }) {
    var state = league;
    final updatedBrackets = <PlayoffBracket>[];
    for (final b in state.currentSeason.playoffBrackets) {
      final next = _progressBracketRounds(b);
      final completedRound =
          calendar.playoffRoundForWeek(state.currentWeek) ?? 1;
      state = _scheduleNewlyCreatedRounds(state, b, next, completedRound);
      updatedBrackets.add(next);
    }
    var brackets = updatedBrackets;

    String? champion = state.currentSeason.championTeamId;
    PlayoffBracket? east;
    PlayoffBracket? west;
    for (final b in brackets) {
      if (b.conference == Conference.europe) east = b;
      if (b.conference == Conference.restOfTheWorld) west = b;
    }
    if (east != null &&
        west != null &&
        east.conferenceFinal.isNotEmpty &&
        west.conferenceFinal.isNotEmpty &&
        east.conferenceFinal.first.isComplete &&
        west.conferenceFinal.first.isComplete) {
      final alreadyHadFinal =
          east.leagueFinal != null || west.leagueFinal != null;
      final leagueFinal =
          east.leagueFinal ??
          west.leagueFinal ??
          _series(
            east.conferenceFinal.first.winnerTeamId!,
            west.conferenceFinal.first.winnerTeamId!,
          );
      if (!alreadyHadFinal) {
        state = state.copyWith(
          currentSeason: state.currentSeason.copyWith(
            postseasonFixtures: [
              ...state.currentSeason.postseasonFixtures,
              ..._eagerFixturesForSeries(leagueFinal, round: 4),
            ],
          ),
        );
      }
      champion = leagueFinal.winnerTeamId ?? champion;
      brackets = brackets
          .map((b) => b.copyWith(leagueFinal: leagueFinal))
          .toList();
    }

    state = state.copyWith(
      currentSeason: state.currentSeason.copyWith(
        playoffBrackets: brackets,
        championTeamId: champion ?? state.currentSeason.championTeamId,
      ),
    );
    if (champion != null) {
      state = _crownChampion(state, champion, saveSeed: saveSeed);
    }
    return state;
  }

  /// Creates the next playoff round(s) once every series in the current
  /// round is complete. Plays no games — pure bracket bookkeeping.
  PlayoffBracket _progressBracketRounds(PlayoffBracket b) {
    var semis = b.semiFinals;
    if (semis.isEmpty &&
        b.quarterFinals.length == 4 &&
        b.quarterFinals.every((s) => s.isComplete)) {
      semis = [
        _series(
          b.quarterFinals[0].winnerTeamId!,
          b.quarterFinals[3].winnerTeamId!,
        ),
        _series(
          b.quarterFinals[1].winnerTeamId!,
          b.quarterFinals[2].winnerTeamId!,
        ),
      ];
    }
    var confFinal = b.conferenceFinal;
    if (confFinal.isEmpty &&
        semis.length == 2 &&
        semis.every((s) => s.isComplete)) {
      confFinal = [_series(semis[0].winnerTeamId!, semis[1].winnerTeamId!)];
    }
    return b.copyWith(semiFinals: semis, conferenceFinal: confFinal);
  }

  LeagueState _crownChampion(
    LeagueState league,
    String champion, {
    required int saveSeed,
  }) {
    var state = league;
    final alreadyApplied = state.currentSeason.championshipAtmosphereApplied;
    if (!alreadyApplied) {
      final championTeam = state.teamById(champion);
      if (championTeam != null) {
        final before = championTeam.atmosphere;
        final updated = const TeamManagementService().applyAtmosphereDelta(
          championTeam,
          30,
        );
        state = state
            .updateTeam(updated)
            .copyWith(
              currentSeason: state.currentSeason.copyWith(
                championshipAtmosphereApplied: true,
              ),
            );
        if (state.playerTeamId == champion) {
          state = _messages.send(
            state,
            type: MessageType.teamEvent,
            kind: 'atmosphereShift',
            domain: MessageDomain.teamEvent,
            args: {
              'delta': updated.atmosphere - before,
              'oldLevel': before,
              'newLevel': updated.atmosphere,
            },
            payload: {
              'teamId': champion,
              'atmosphereDelta': updated.atmosphere - before,
              'oldLevel': before,
              'newLevel': updated.atmosphere,
              'atmosphereBefore': before,
              'atmosphereAfter': updated.atmosphere,
              'reason': 'championship',
            },
            dedupKey: 'atmosphere:championship:${state.currentSeason.year}',
          );
        }
      } else {
        state = state.copyWith(
          currentSeason: state.currentSeason.copyWith(
            championshipAtmosphereApplied: true,
          ),
        );
      }
    }
    return teamEvents.afterPlayoffs(state, saveSeed: saveSeed);
  }

  ({LeagueState league, PlayoffSeries series, ScheduledMatch? playerMatch})
  _playOneGame(
    LeagueState league,
    PlayoffSeries series,
    int saveSeed, {
    MatchStake? stake,
  }) {
    final homeFirst = calendar.higherSeedHomeForGame(series.games.length);
    final homeId = homeFirst ? series.higherSeedTeamId : series.lowerSeedTeamId;
    final awayId = homeFirst ? series.lowerSeedTeamId : series.higherSeedTeamId;
    final played = _simPostseason(
      league,
      homeId,
      awayId,
      saveSeed: saveSeed,
      matchId: 'playoff:${series.id}:${series.games.length}',
      phase: SeasonPhase.playoff,
      stake: stake ?? _stakeForSeries(series),
    );
    if (played.playerMatch != null) {
      return (
        league: played.league,
        series: series,
        playerMatch: played.playerMatch,
      );
    }
    return (
      league: played.league,
      series: series.recordGame(played.result!),
      playerMatch: null,
    );
  }
}
