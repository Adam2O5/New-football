part of 'season_service.dart';

mixin _SeasonScouting on _SeasonServiceShared {
  /// Scout Report (pon tyg. 45, `docs/offseason.md` §5): AI builds or
  /// refreshes its watchlist, then every team picks uncertain Combine targets.
  LeagueState runScoutReport(LeagueState league, {int saveSeed = 0}) {
    final draftClass = league.currentSeason.draftState?.draftClass;
    if (draftClass == null) return league;
    final ranked = [...draftClass.prospects]
      ..sort((a, b) {
        final grade = b.scoutGrade.compareTo(a.scoutGrade);
        return grade != 0 ? grade : a.id.compareTo(b.id);
      });
    final teams = league.teams.map((team) {
      final coverage = team.staff.scout?.attributes.coverage ?? 0.0;
      var scouting = team.scouting;
      if (!team.isPlayerControlled) {
        if (scouting.watchlistProspectIds.isEmpty) {
          scouting = aiDraftService.assignWatchlist(
            team: team,
            draftClass: draftClass,
            league: league,
            saveSeed: saveSeed,
            seasonYear: league.currentSeason.year,
            week: league.currentWeek,
          );
        }
        scouting = scoutingService.updateMonthlyWatchlist(
          scouting,
          rankedProspects: ranked,
          coverageStars: coverage,
          seed: saveSeed,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          teamId: team.id,
        );
        scouting = scoutingService.runScoutReport(
          scouting,
          coverage,
          prospects: draftClass.prospects,
          rankedProspects: ranked,
          seed: saveSeed,
        );
      } else {
        // The player receives the report but chooses Combine targets in the
        // Prospects screen instead of inheriting the AI assignment.
        scouting = scouting.copyWith(combineAssignedProspectIds: const []);
      }
      return team.copyWith(scouting: scouting);
    }).toList();
    return _msg(
      league.copyWith(
        teams: teams,
        currentSeason: league.currentSeason.copyWith(scoutReportDone: true),
      ),
      MessageType.scoutReport,
      'Raport skautingowy',
      'Sztab przygotował raporty z obserwacji i przydział na Combine.',
      kind: 'preCombine',
    );
  }

  /// Draft Combine (śr tyg. 45, `docs/offseason.md` §6).
  LeagueState runCombine(LeagueState league, {int saveSeed = 0}) {
    final draftClass = league.currentSeason.draftState?.draftClass;
    final teams = league.teams.map((team) {
      final evalStars = team.staff.scout?.attributes.evaluation ?? 0.0;
      return team.copyWith(
        scouting: scoutingService.runCombine(
          team.scouting,
          evalStars,
          prospects: draftClass?.prospects ?? const [],
          seed: saveSeed,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          teamId: team.id,
        ),
      );
    }).toList();
    return _msg(
      league.copyWith(
        teams: teams,
        currentSeason: league.currentSeason.copyWith(combineDone: true),
      ),
      MessageType.combine,
      'Draft Combine',
      'Testy fizyczne i mecz pokazowy zakończone.',
      kind: 'completed',
    );
  }

  /// Mock Draft finalny (pt tyg. 45, `docs/offseason.md` §7). Updates both
  /// the per-team scouting estimate (`ScoutingService.runFinalMock`, watched
  /// prospects only, noise scaled by that team's scout Evaluation) and the
  /// league-wide displayed board (`MockDraftService`, all 120 prospects,
  /// fixed noise bands — `draft.md` §"Mock finalny") that drives the
  /// Prospects screen's sort order and position-change indicator.
  LeagueState runFinalMock(LeagueState league, {int saveSeed = 0}) {
    final draftState = league.currentSeason.draftState;
    final draftClass = draftState?.draftClass;
    if (draftClass == null || draftState == null) return league;
    final ranked = [...draftClass.prospects]
      ..sort((a, b) {
        final grade = b.scoutGrade.compareTo(a.scoutGrade);
        return grade != 0 ? grade : a.id.compareTo(b.id);
      });
    final teams = league.teams.map((team) {
      final evalStars = team.staff.scout?.attributes.evaluation ?? 0.0;
      return team.copyWith(
        scouting: scoutingService.runFinalMock(
          team.scouting,
          ranked,
          evalStars,
          seed: saveSeed,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          teamId: team.id,
        ),
      );
    }).toList();

    final trueBoard = mockDraftService.trueBoard(draftClass.prospects);
    final previousBoard = draftState.mockDraftBoard ?? const MockDraftBoard();
    final finalBoard = mockDraftService.generateFinalMock(
      trueBoard,
      previousBoard,
      seed: saveSeed,
      seasonYear: league.currentSeason.year,
    );

    return _msg(
      league.copyWith(
        teams: teams,
        currentSeason: league.currentSeason.copyWith(
          finalMockDone: true,
          draftState: draftState.copyWith(mockDraftBoard: finalBoard),
        ),
      ),
      MessageType.mockDraft,
      'Mock Draft finalny',
      'Scouci opublikowali estymowane sloty draftu.',
      kind: 'final',
    );
  }
}
