part of 'season_service.dart';

mixin _SeasonFixtures on _SeasonServiceShared {
  /// Writes the two
  /// already-decided play-in games (7v8, 9v10 — seeding is final the moment
  /// the regular season ends) and creates all 4 quarterfinal series per
  /// conference: 3v6 and 4v5 are fully known now, while 1v8 and 2v7 are
  /// created with a placeholder lower seed since they depend on play-in.
  /// Every series' first 3 games are eagerly scheduled. The still-unknown
  /// play-in final and the 1v8/2v7 placeholders are filled in later by
  /// [revealPlayInFinal]/[revealPlayoffSeed8].
  LeagueState generatePostseasonFixtures(LeagueState league) {
    final season = league.currentSeason;
    if (season.schedule.isEmpty ||
        season.schedule.any((m) => m.result == null)) {
      return league;
    }
    final conferences = season.standings
        .where((s) => s.standings.length >= 10)
        .map((s) => s.conference)
        .toSet();
    if (conferences.isEmpty) return league;
    if (season.postseasonFixtures.isNotEmpty ||
        season.playInProgress.isNotEmpty ||
        season.playInResults.isNotEmpty ||
        season.playoffBrackets.isNotEmpty) {
      final ids = season.postseasonFixtures.map((m) => m.id).toSet();
      var complete =
          ids.length == season.postseasonFixtures.length &&
          season.playInProgress.length + season.playInResults.length ==
              conferences.length &&
          season.playoffBrackets.length == conferences.length;
      for (final conference in conferences) {
        final progress = season.playInProgress.where(
          (p) => p.conference == conference,
        );
        final results = season.playInResults.where(
          (r) => r.conference == conference,
        );
        final brackets = season.playoffBrackets.where(
          (b) => b.conference == conference,
        );
        if (progress.length + results.length != 1 ||
            brackets.length != 1 ||
            brackets.single.quarterFinals.length != 4) {
          complete = false;
          continue;
        }
        for (final slot in ['7v8', '9v10', 'final']) {
          complete =
              complete && ids.contains('playIn:${conference.name}:$slot');
        }
        for (final series in brackets.single.quarterFinals) {
          final count = series.isComplete ? series.games.length : 5;
          for (var i = 0; i < count; i++) {
            complete = complete && ids.contains('playoff:${series.id}:$i');
          }
        }
      }
      if (!complete) throw StateError('Incomplete postseason initialization');
      return league;
    }
    final fixtures = <ScheduledMatch>[
      ...league.currentSeason.postseasonFixtures,
    ];
    final progress = <PlayInProgress>[...league.currentSeason.playInProgress];
    final brackets = <PlayoffBracket>[];
    final playInWeek = balance.calendar.playInWeek;

    for (final conference in Conference.values) {
      final cs = league.currentSeason.standings
          .firstWhere((s) => s.conference == conference)
          .sorted;
      if (cs.length < 10) continue;
      final seeds = [for (final s in cs.take(10)) s.teamId];

      fixtures.add(
        ScheduledMatch(
          id: 'playIn:${conference.name}:7v8',
          homeTeamId: seeds[6],
          awayTeamId: seeds[7],
          round: -1,
          week: playInWeek,
          day: 3,
        ),
      );
      fixtures.add(
        ScheduledMatch(
          id: 'playIn:${conference.name}:9v10',
          homeTeamId: seeds[8],
          awayTeamId: seeds[9],
          round: -1,
          week: playInWeek,
          day: 3,
        ),
      );
      fixtures.add(
        ScheduledMatch(
          id: 'playIn:${conference.name}:final',
          homeTeamId: _placeholderToken(conference, 'playInFinalLoser78'),
          awayTeamId: _placeholderToken(conference, 'playInFinalWinner910'),
          round: -1,
          week: playInWeek,
          day: 6,
          confirmed: false,
          homePlaceholderLabel: 'Loser 7v8',
          awayPlaceholderLabel: 'Winner 9v10',
        ),
      );
      progress.add(
        PlayInProgress(
          conference: conference,
          seed7TeamId: seeds[6],
          seed8TeamId: seeds[7],
          seed9TeamId: seeds[8],
          seed10TeamId: seeds[9],
        ),
      );

      final quarterFinals = [
        _series(
          seeds[0],
          _placeholderToken(conference, 'seed8'),
        ).copyWith(lowerSeedPlaceholderLabel: 'Playin seed 8'),
        _series(
          seeds[1],
          _placeholderToken(conference, 'seed7'),
        ).copyWith(lowerSeedPlaceholderLabel: 'Playin seed 7'),
        _series(seeds[2], seeds[5]),
        _series(seeds[3], seeds[4]),
      ];
      brackets.add(
        PlayoffBracket(conference: conference, quarterFinals: quarterFinals),
      );
      for (final series in quarterFinals) {
        fixtures.addAll(_eagerFixturesForSeries(series, round: 1));
      }
    }

    return league.copyWith(
      currentSeason: league.currentSeason.copyWith(
        playInProgress: progress,
        playoffBrackets: brackets,
        postseasonFixtures: fixtures,
      ),
    );
  }

  /// Reveals seed 7 the moment 7v8 resolves (patches the 1v8/2v7
  /// quarterfinal placeholder in `playoffBrackets` wherever it's waiting on
  /// it — this is what turns the "?" in `standings_bracket_view.dart` into
  /// the real team's logo) and reveals the play-in final's real matchup —
  /// confirming its calendar fixture and clearing its placeholder — the
  /// moment both 7v8 and 9v10 are known. Both happen immediately, regardless
  /// of which calendar day that lands on: called from [advancePlayInForDate]
  /// right after a game resolves, and from [applyPlayInPlayerResult] for the
  /// interactive path, so there's never an artificial day's delay.
  @override
  LeagueState _maybeRevealPlayInProgress(
    LeagueState league,
    Conference conference,
  ) {
    var state = league;
    PlayInProgress? progress;
    for (final p in state.currentSeason.playInProgress) {
      if (p.conference == conference) {
        progress = p;
        break;
      }
    }
    if (progress == null) return state;

    final game7v8 = progress.game7v8;
    if (game7v8 != null) {
      final seed7Winner = _winnerId(
        game7v8,
        progress.seed7TeamId,
        progress.seed8TeamId,
      );
      state = _patchPlaceholder(state, conference, 'seed7', seed7Winner);
    }

    final game9v10 = progress.game9v10;
    if (game7v8 != null && game9v10 != null && progress.gameFinal == null) {
      final seed7Winner = _winnerId(
        game7v8,
        progress.seed7TeamId,
        progress.seed8TeamId,
      );
      final loser78 = seed7Winner == progress.seed7TeamId
          ? progress.seed8TeamId
          : progress.seed7TeamId;
      final winner910 = _winnerId(
        game9v10,
        progress.seed9TeamId,
        progress.seed10TeamId,
      );
      final finalId = 'playIn:${conference.name}:final';
      final fixtures = state.currentSeason.postseasonFixtures;
      final hasFixture = fixtures.any((f) => f.id == finalId);
      final playInWeek = balance.calendar.playInWeek;
      final updatedFixtures = hasFixture
          ? [
              for (final f in fixtures)
                if (f.id == finalId)
                  f.copyWith(
                    homeTeamId: loser78,
                    awayTeamId: winner910,
                    confirmed: true,
                    homePlaceholderLabel: null,
                    awayPlaceholderLabel: null,
                  )
                else
                  f,
            ]
          : [
              ...fixtures,
              ScheduledMatch(
                id: finalId,
                homeTeamId: loser78,
                awayTeamId: winner910,
                round: -1,
                week: playInWeek,
                day: 6,
              ),
            ];
      state = state.copyWith(
        currentSeason: state.currentSeason.copyWith(
          postseasonFixtures: updatedFixtures,
        ),
      );
    }
    return state;
  }

  /// Called Sunday of play-in week — the day after the play-in final
  /// concludes (per `game_calendar.md`): reveals seed 8 wherever a 1v8
  /// quarterfinal was waiting on it. Both play-in seeds are now known for
  /// every conference, so this is also when the (previously skipped, since
  /// the bracket still had placeholders) playoff seeding message goes out.
  LeagueState revealPlayoffSeed8(LeagueState league) {
    var state = league;
    for (final result in league.currentSeason.playInResults) {
      state = _patchPlaceholder(
        state,
        result.conference,
        'seed8',
        result.playoffSeed8TeamId,
      );
    }
    return _sendPlayoffSeedingMessages(
      state,
      state.currentSeason.playoffBrackets,
    );
  }

  /// Replaces every occurrence of the [conference]/[seedLabel] placeholder
  /// token — in both `playoffBrackets` and `postseasonFixtures` — with the
  /// now-known [realTeamId].
  LeagueState _patchPlaceholder(
    LeagueState league,
    Conference conference,
    String seedLabel,
    String realTeamId,
  ) {
    final token = _placeholderToken(conference, seedLabel);

    PlayoffSeries patchSeries(PlayoffSeries s) {
      if (s.lowerSeedTeamId != token) return s;
      return s.copyWith(
        lowerSeedTeamId: realTeamId,
        lowerSeedPlaceholderLabel: null,
      );
    }

    final brackets = league.currentSeason.playoffBrackets.map((b) {
      if (b.conference != conference) return b;
      return b.copyWith(
        quarterFinals: b.quarterFinals.map(patchSeries).toList(),
      );
    }).toList();

    final fixtures = league.currentSeason.postseasonFixtures.map((f) {
      var next = f;
      if (next.homeTeamId == token) {
        next = next.copyWith(
          homeTeamId: realTeamId,
          homePlaceholderLabel: null,
        );
      }
      if (next.awayTeamId == token) {
        next = next.copyWith(
          awayTeamId: realTeamId,
          awayPlaceholderLabel: null,
        );
      }
      return next;
    }).toList();

    return league.copyWith(
      currentSeason: league.currentSeason.copyWith(
        playoffBrackets: brackets,
        postseasonFixtures: fixtures,
      ),
    );
  }

  /// The six calendar slots available to playoff [round] — delegates to
  /// `CalendarService.playoffRoundSlotDates`, the single source of truth
  /// shared with [postseasonSlotForDay]'s gating, so the fixtures written
  /// here and the days the simulation actually plays on can never drift
  /// apart.
  List<(int week, int day)> _roundSlotDates(int round) =>
      calendar.playoffRoundSlotDates(round);

  /// Eagerly schedules all 5 potential games of [series] into playoff
  /// [round]'s slot calendar — not just the first 3, per `game_calendar.md`:
  /// a BO5 series' dead time (if decided early) still spans the full 3-week
  /// block. Games 1–3 are marked [ScheduledMatch.confirmed]; games 4–5 start
  /// unconfirmed (greyed out in the calendar) until [_reconcileSeriesFixtures]
  /// either confirms or removes them. A still-[PlayoffSeries.isPending]
  /// series produces fixtures with a placeholder label on whichever side the
  /// lower seed lands, per the 1-2-2 home pattern.
  @override
  List<ScheduledMatch> _eagerFixturesForSeries(
    PlayoffSeries series, {
    required int round,
  }) {
    final dates = _roundSlotDates(round);
    final fixtures = <ScheduledMatch>[];
    for (var i = 0; i < 5 && i < dates.length; i++) {
      final homeFirst = calendar.higherSeedHomeForGame(i);
      final (week, day) = dates[i];
      fixtures.add(
        ScheduledMatch(
          id: 'playoff:${series.id}:$i',
          homeTeamId: homeFirst
              ? series.higherSeedTeamId
              : series.lowerSeedTeamId,
          awayTeamId: homeFirst
              ? series.lowerSeedTeamId
              : series.higherSeedTeamId,
          round: -1,
          week: week,
          day: day,
          confirmed: i < 3,
          homePlaceholderLabel: homeFirst
              ? null
              : series.lowerSeedPlaceholderLabel,
          awayPlaceholderLabel: homeFirst
              ? series.lowerSeedPlaceholderLabel
              : null,
        ),
      );
    }
    return fixtures;
  }

  /// Attaches [result] to the already-scheduled fixture with id [matchId].
  /// Every postseason fixture is written to `postseasonFixtures` ahead of
  /// time (see `game_calendar.md`), so playing it never adds a row — it only
  /// fills in the one that's already there.
  @override
  LeagueState _recordFixtureResult(
    LeagueState league,
    String matchId,
    MatchResult result,
  ) {
    final stored = result.slimForStorage();
    final fixtures = [
      for (final f in league.currentSeason.postseasonFixtures)
        if (f.id == matchId) f.copyWith(result: stored) else f,
    ];
    return league.copyWith(
      currentSeason: league.currentSeason.copyWith(
        postseasonFixtures: fixtures,
      ),
    );
  }

  /// If [next] has a semifinal/conference-final round [previous] didn't,
  /// this call just created it — eagerly schedule its first 3 games into the
  /// following playoff round's slot calendar.
  @override
  LeagueState _scheduleNewlyCreatedRounds(
    LeagueState league,
    PlayoffBracket previous,
    PlayoffBracket next,
    int completedRound,
  ) {
    var state = league;
    void scheduleAll(List<PlayoffSeries> seriesList) {
      for (final s in seriesList) {
        state = state.copyWith(
          currentSeason: state.currentSeason.copyWith(
            postseasonFixtures: [
              ...state.currentSeason.postseasonFixtures,
              ..._eagerFixturesForSeries(s, round: completedRound + 1),
            ],
          ),
        );
      }
    }

    if (previous.semiFinals.isEmpty && next.semiFinals.isNotEmpty) {
      scheduleAll(next.semiFinals);
    }
    if (previous.conferenceFinal.isEmpty && next.conferenceFinal.isNotEmpty) {
      scheduleAll(next.conferenceFinal);
    }
    return state;
  }
}
