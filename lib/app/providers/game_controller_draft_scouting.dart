part of 'game_provider.dart';

mixin _GameControllerDraftScouting {
  SeasonService get _season;

  int get _saveGeneration;

  Future<void>? get _careerTransition;

  GameSave? get save;

  Future<T> _mutateSave<T>(
    T unavailable,
    Future<T> Function(GameSave current) operation,
  );

  Future<void> _publishLeagueInQueue(
    LeagueState Function(LeagueState) transform,
  );

  Future<void> updateLeague(
    LeagueState Function(LeagueState) transform, {
    bool autosave = true,
  });

  Future<DaySimulationResult?> simulateDay({
    bool resolveContractMarket = true,
    bool interruptForUrgent = true,
  });

  ScoutingService get _scouting;

  Future<void> makeDraftPick(String prospectId) async {
    final generation = _saveGeneration;
    await updateLeague(
      (l) => _season.advanceDraft(
        l,
        playerPickProspectId: prospectId,
        saveSeed: save!.saveSeed,
      ),
    );
    if (generation != _saveGeneration || _careerTransition != null) return;
    final league = save?.leagueState;
    if (league != null &&
        CalendarEventRegistry.isDone(
          league.currentSeason,
          CalendarEventId.draft,
        )) {
      await simulateDay(interruptForUrgent: false);
    }
  }

  Future<void> simulateOneDraftPick() async {
    await updateLeague(
      (l) => _season.advanceDraftOnePick(l, saveSeed: save!.saveSeed),
    );
  }

  Future<void> simulateDraftToPlayerTurn() async {
    await updateLeague(
      (l) => _season.advanceDraft(l, saveSeed: save!.saveSeed),
    );
  }

  /// Sets the player team's scouting watchlist, capped by scout Coverage.
  Future<void> setScoutWatchlist(List<String> prospectIds) async {
    await updateLeague((l) {
      final team = l.playerTeam;
      if (team == null) return l;
      final coverage = team.staff.scout?.attributes.coverage ?? 0.0;
      final scouting = _scouting.setWatchlist(
        team.scouting,
        prospectIds,
        coverageStars: coverage,
      );
      return l.updateTeam(team.copyWith(scouting: scouting));
    });
  }

  /// Saves player-selected Combine targets only after Scout Report and before
  /// the automatic Combine event.
  Future<bool> setCombineAssignments(List<String> prospectIds) {
    return _mutateSave<bool>(false, (current) async {
      final league = current.leagueState;
      final team = league.playerTeam;
      final draftClass = league.currentSeason.draftState?.draftClass;
      if (team == null || draftClass == null) {
        return false;
      }
      final season = league.currentSeason;
      if (!season.scoutReportDone || season.combineDone) return false;
      if (team.scouting.watchlistProspectIds.isEmpty) return false;
      final coverage = team.staff.scout?.attributes.coverage ?? 0.0;
      final scouting = _scouting.setCombineAssignments(
        team.scouting,
        prospectIds,
        coverageStars: coverage,
        availableProspectIds: draftClass.prospects.map(
          (prospect) => prospect.id,
        ),
      );
      await _publishLeagueInQueue(
        (state) => state.updateTeam(team.copyWith(scouting: scouting)),
      );
      return true;
    });
  }
}
