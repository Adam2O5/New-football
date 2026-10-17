part of 'day_simulator.dart';

mixin _DayRoundResolution on _DayMatchResultApplication {
  AiMatchdayService get aiMatchdayService;

  MatchContextFactory get contextFactory;

  MatchMessageEmitter get matchMessageEmitter;

  ({LeagueState league, List<MatchResult> results, ScheduledMatch? playerMatch})
  _resolveRound(
    LeagueState league,
    int round,
    int saveSeed, {
    bool simulatePlayerMatch = false,
  }) {
    final schedule = league.currentSeason.schedule;
    final fixtures = schedule
        .where((m) => m.round == round && m.result == null)
        .toList();
    if (fixtures.isEmpty) {
      return (league: league, results: <MatchResult>[], playerMatch: null);
    }

    final playerId = league.playerTeamId;
    ScheduledMatch? playerFixture;
    final aiFixtures = <ScheduledMatch>[];
    for (final f in fixtures) {
      if (playerId != null &&
          (f.homeTeamId == playerId || f.awayTeamId == playerId) &&
          !simulatePlayerMatch) {
        playerFixture = f;
      } else {
        aiFixtures.add(f);
      }
    }

    var state = league;
    final results = <MatchResult>[];
    for (final f in aiFixtures) {
      final home = state.teamById(f.homeTeamId);
      final away = state.teamById(f.awayTeamId);
      if (home == null || away == null) continue;
      final context = contextFactory.create(
        league: state,
        match: f,
        saveSeed: saveSeed,
        stake: MatchStake.regular,
      );
      final result = aiMatchdayService.simulateFullMatch(
        home: home,
        away: away,
        context: context,
        saveSeed: saveSeed,
        seasonYear: state.currentSeason.year,
        week: state.currentWeek,
        matchId: f.id,
        phase: SeasonPhase.regular,
        homeOpponentFormationHistory:
            AiMatchdayService.formationHistoryFromSchedule(
              state.currentSeason.schedule,
              home.id,
              away.id,
            ),
        awayOpponentFormationHistory:
            AiMatchdayService.formationHistoryFromSchedule(
              state.currentSeason.schedule,
              away.id,
              home.id,
            ),
      );
      state = _applyResult(state, f, result, saveSeed: saveSeed);
      results.add(result);
    }

    // The interactive fixture is not simulated here, but its pre-match
    // validation and context are created at the same boundary as AI matches.
    // This makes the preview deterministic and ensures warnings arrive before
    // MatchdayScreen starts the engine.
    if (playerFixture != null) {
      final home = state.teamById(playerFixture.homeTeamId);
      final away = state.teamById(playerFixture.awayTeamId);
      if (home != null && away != null) {
        final context = contextFactory.create(
          league: state,
          match: playerFixture,
          saveSeed: saveSeed,
          stake: MatchStake.regular,
        );
        final report = PreMatchValidator(
          balance: balance,
        ).validate(home: home, away: away);
        state = matchMessageEmitter.emitPreMatch(
          league: state,
          matchId: playerFixture.id,
          homeTeamId: home.id,
          awayTeamId: away.id,
          context: context,
          report: report,
        );
      }
    }

    return (league: state, results: results, playerMatch: playerFixture);
  }
}
