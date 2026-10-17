part of 'season_service.dart';

mixin _SeasonDraft on _SeasonServiceShared {
  /// Generates the next draft class and immediately assigns AI scouting
  /// watchlists for the class that becomes active after the current draft.
  LeagueState runNextClassGeneration(LeagueState league, {int saveSeed = 0}) {
    var state = ProspectService(
      random: _random,
      balance: balance,
      mockDraftService: mockDraftService,
    ).generateNextClassForLeague(league, seed: saveSeed);
    final nextDraft = state.currentSeason.draftState;
    if (nextDraft == null) return state;
    final year = nextDraft.year;
    final teams = state.teams.map((team) {
      if (team.isPlayerControlled) return team;
      return team.copyWith(
        scouting: aiDraftService.assignWatchlist(
          team: team,
          draftClass: nextDraft.draftClass,
          league: state,
          saveSeed: saveSeed,
          seasonYear: year,
          week: state.currentWeek,
        ),
      );
    }).toList();
    return state.copyWith(teams: teams);
  }

  LeagueState _finalizeDraftFreeAgents(LeagueState state, DraftState draft) {
    if (draft.currentPickIndex < draft.order.length) return state;
    final draftedIds = draft.completedPicks
        .map((c) => c.prospectId)
        .whereType<String>()
        .toSet();

    // Draft finalization can be replayed after a save/load boundary. Keep the
    // first existing free-agent snapshot for each id and only create
    // provenance for players that are genuinely added by this finalization.
    final freeAgents = <Player>[];
    final freeAgentIds = <String>{};
    for (final player in state.freeAgents) {
      if (freeAgentIds.add(player.id)) freeAgents.add(player);
    }

    final freshByPlayerId = <String, FreshUndraftedPlayer>{};
    for (final record in state.freshUndraftedPlayers) {
      if (freeAgentIds.contains(record.playerId)) {
        freshByPlayerId.putIfAbsent(record.playerId, () => record);
      }
    }

    for (final prospect in draft.draftClass.prospects) {
      if (draftedIds.contains(prospect.id)) continue;
      final player = prospect
          .toPlayer(
            contract: Contract(
              salary: balance.salaryCap.minSalary,
              yearsRemaining: 0,
            ),
            draftYear: draft.year,
            rng: _random,
            balance: balance,
          )
          .recalculatePointValue(balance);
      if (!freeAgentIds.add(player.id)) continue;
      freeAgents.add(player);
      freshByPlayerId[player.id] = FreshUndraftedPlayer(
        playerId: player.id,
        draftYear: draft.year,
        activeFromSeasonYear: state.currentSeason.year,
        activeFromWeek: balance.calendar.freeAgencyWeek,
        activeUntilSeasonYear: state.currentSeason.year + 1,
        activeUntilWeek: balance.calendar.freeAgencyPhaseIIEndWeek,
      );
    }

    return state.copyWith(
      freeAgents: freeAgents,
      freshUndraftedPlayers: freshByPlayerId.values.toList(),
    );
  }

  AiDraftDecision _decideAiDraft(
    LeagueState state,
    DraftState draft,
    DraftPick pick,
    int overallPick, {
    required int saveSeed,
  }) {
    final team = state.teamById(pick.teamId);
    if (team == null) {
      return const AiDraftDecision(action: AiDraftAction.pick, board: []);
    }
    final taken = draft.completedPicks
        .map((completed) => completed.prospectId)
        .whereType<String>()
        .toSet();
    return aiDraftService.decidePick(
      team: team,
      prospects: draft.draftClass.prospects,
      pickNumber: overallPick,
      currentPickIndex: draft.currentPickIndex,
      draftOrder: draft.order,
      unavailableProspectIds: taken,
      league: state,
      saveSeed: saveSeed,
      seasonYear: state.currentSeason.year,
      week: state.currentWeek,
    );
  }

  Prospect _chooseAiDraftProspect(
    List<Prospect> remaining,
    AiDraftDecision decision,
  ) {
    final selectedId = decision.selection?.prospect.id;
    return remaining.firstWhere(
      (prospect) => prospect.id == selectedId,
      orElse: () => remaining.first,
    );
  }

  ({LeagueState state, bool swapped, bool pending}) _resolveAiDraftTrade(
    LeagueState state,
    DraftState draft,
    DraftPick pick,
    AiDraftDecision decision,
  ) {
    if (_draftSlotTradeAlreadyResolved(state, pick.id)) {
      return (state: state, swapped: false, pending: false);
    }
    if (decision.action == AiDraftAction.pick) {
      return (state: state, swapped: false, pending: false);
    }

    final targetIndex = decision.action == AiDraftAction.tradeUp
        ? decision.targetPickIndex
        : _tradeDownTargetIndex(state, draft, pick);
    if (targetIndex == null ||
        targetIndex < 0 ||
        targetIndex >= draft.order.length ||
        targetIndex == draft.currentPickIndex) {
      return (state: state, swapped: false, pending: false);
    }
    final target = draft.order[targetIndex];
    final targetValidation = draftTrade.validateActiveSwap(
      state,
      firstPickId: pick.id,
      secondPickId: target.id,
      firstOwnerId: pick.teamId,
      secondOwnerId: target.teamId,
    );
    if (!targetValidation.ok) {
      return (state: state, swapped: false, pending: false);
    }

    final targetTeam = state.teamById(target.teamId);
    if (targetTeam == null || target.teamId == pick.teamId) {
      return (state: state, swapped: false, pending: false);
    }

    // Only documented trade-up plans may pause the player's draft for a
    // response. A weak-board trade-down never creates a player-facing offer.
    if (target.teamId == state.playerTeamId) {
      if (decision.action != AiDraftAction.tradeUp) {
        return (state: state, swapped: false, pending: false);
      }
      final existing = draftTrade.pendingOfferForPick(state, pick.id);
      if (existing != null) {
        return (state: state, swapped: false, pending: true);
      }
      final created = draftTrade.createOfferForSlots(
        state,
        offeredPickId: pick.id,
        targetPickId: target.id,
        offeringTeamId: pick.teamId,
      );
      if (created.outcome != 'pending' || created.offerId == null) {
        return (state: state, swapped: false, pending: false);
      }
      return (state: created.league, swapped: false, pending: true);
    }

    final operationId =
        'draftSwap:${state.currentSeason.year}:${pick.id}:${target.id}';
    final swapped = draftTrade.swapActiveSlots(
      state,
      firstPickId: pick.id,
      secondPickId: target.id,
      firstOwnerId: pick.teamId,
      secondOwnerId: target.teamId,
      operationId: operationId,
      reason:
          'draftTrade:${decision.action.name}:surplus=${decision.surplusPct}',
    );
    return (state: swapped.league, swapped: swapped.changed, pending: false);
  }

  int? _tradeDownTargetIndex(
    LeagueState state,
    DraftState draft,
    DraftPick current,
  ) {
    for (
      var index = draft.currentPickIndex + 1;
      index < draft.order.length;
      index++
    ) {
      final candidate = draft.order[index];
      if (candidate.prospectId != null || candidate.playerName != null) {
        continue;
      }
      final team = state.teamById(candidate.teamId);
      if (team == null ||
          candidate.teamId == state.playerTeamId ||
          team.id == current.teamId) {
        continue;
      }
      return index;
    }
    return null;
  }

  bool _draftSlotTradeAlreadyResolved(LeagueState state, String pickId) {
    for (final entry in state.tradeHistory.reversed) {
      if (entry.seasonYear != state.currentSeason.year) continue;
      final isDraftOutcome = switch (entry.outcome) {
        'accepted' || 'rejected' || 'expired' || 'hardRejected' => true,
        _ => false,
      };
      if (!isDraftOutcome) continue;
      final assets = [...entry.assetsFromA, ...entry.assetsFromB];
      if (assets.any(
        (asset) => asset.type == 'pick' && asset.pickId == pickId,
      )) {
        return true;
      }
    }
    return false;
  }

  LeagueState _maybeSignAiDraftedRight(
    LeagueState state,
    DraftedPlayerRights right,
    DraftPick pick, {
    required int saveSeed,
  }) {
    final team = state.teamById(pick.teamId);
    if (team == null || team.isPlayerControlled) return state;
    final context = aiDraftService.evaluator.contextForTeam(
      team: team,
      league: state,
      saveSeed: saveSeed,
      seasonYear: state.currentSeason.year,
      week: state.currentWeek,
      decisionType: DecisionType.draftPick,
    );
    final needScore =
        aiDraftService.evaluator
            .needForPosition(context, right.player.position)
            ?.needScore ??
        0.0;
    final decision = aiDraftService.draftedSigningDecision(
      team: team,
      round: pick.round,
      prospectId: right.player.id,
      needScore: needScore,
      saveSeed: saveSeed,
      seasonYear: state.currentSeason.year,
      week: state.currentWeek,
    );
    if (!decision.sign) return state;
    return contractMarket.signDraftedRight(
          state,
          right.id,
          saveSeed: saveSeed,
        ) ??
        state;
  }

  LeagueState advanceDraft(
    LeagueState league, {
    String? playerPickProspectId,
    int saveSeed = 0,
  }) {
    var draft = league.currentSeason.draftState;
    if (draft == null) return league;
    final wasComplete = draft.currentPickIndex >= draft.order.length;
    var state = league;
    var draftedRights = List<DraftedPlayerRights>.from(state.draftedRights);
    while (draft!.currentPickIndex < draft.order.length) {
      final pick = draft.order[draft.currentPickIndex];
      final isPlayer = pick.teamId == state.playerTeamId;
      if (isPlayer && playerPickProspectId == null) {
        return state.copyWith(
          currentSeason: state.currentSeason.copyWith(draftState: draft),
        );
      }

      final taken = draft.completedPicks
          .map((c) => c.prospectId)
          .whereType<String>()
          .toSet();
      final remaining =
          draft.draftClass.prospects
              .where((p) => !taken.contains(p.id))
              .toList()
            ..sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));
      if (remaining.isEmpty) break;
      final overallPick = pick.pickNumber ?? draft.currentPickIndex + 1;
      final decision = isPlayer
          ? null
          : _decideAiDraft(state, draft, pick, overallPick, saveSeed: saveSeed);
      if (!isPlayer) {
        final trade = _resolveAiDraftTrade(state, draft, pick, decision!);
        if (trade.pending) {
          return trade.state;
        }
        if (trade.swapped) {
          state = trade.state;
          draft = state.currentSeason.draftState!;
          draftedRights = List<DraftedPlayerRights>.from(state.draftedRights);
          continue;
        }
      }
      final chosen = isPlayer
          ? remaining.firstWhere(
              (p) => p.id == playerPickProspectId,
              orElse: () => remaining.first,
            )
          : _chooseAiDraftProspect(remaining, decision!);
      final salary = balance.salaryCap.rookieSalaryForPick(overallPick);
      final player = chosen
          .toPlayer(
            contract: Contract(
              salary: salary,
              yearsRemaining: balance.salaryCap.rookieScaleYears,
              isRookieScale: true,
              rookiePickSlot: overallPick,
            ),
            draftYear: draft.year,
            rng: _random,
            balance: balance,
          )
          .recalculatePointValue(balance);

      final right = DraftedPlayerRights(
        id: 'rights:${state.currentSeason.year}:$overallPick:${chosen.id}',
        ownerTeamId: pick.teamId,
        player: player,
        draftYear: state.currentSeason.year,
        pickNumber: overallPick,
        reminderSent: isPlayer,
      );
      draftedRights.add(right);
      state = state.copyWith(draftedRights: draftedRights);
      if (!isPlayer) {
        state = _maybeSignAiDraftedRight(
          state,
          right,
          pick,
          saveSeed: saveSeed,
        );
        draftedRights = List<DraftedPlayerRights>.from(state.draftedRights);
      }

      final completed = pick.copyWith(
        prospectId: chosen.id,
        playerName: chosen.name,
      );
      final newOrder = List<DraftPick>.from(draft.order);
      newOrder[draft.currentPickIndex] = completed;
      draft = draft.copyWith(
        completedPicks: [...draft.completedPicks, completed],
        currentPickIndex: draft.currentPickIndex + 1,
        order: newOrder,
      );
      if (isPlayer) {
        state = state.copyWith(
          draftedRights: draftedRights,
          currentSeason: state.currentSeason.copyWith(draftState: draft),
        );
        state = _messages.send(
          state,
          type: MessageType.draftedRightsReminder,
          domain: MessageDomain.draft,
          args: {
            'playerName': chosen.name,
            'rosterCount': state.teamById(pick.teamId)?.roster.length ?? 0,
          },
          payload: {
            'rightsId': right.id,
            'playerId': player.id,
            'teamId': pick.teamId,
            'draftYear': state.currentSeason.year,
            'pickNumber': overallPick,
          },
          dedupKey:
              'draftedRightsReminder:${state.currentSeason.year}:${right.id}',
        );
        state = _msg(
          state,
          MessageType.draftPick,
          'Draft: wybrano ${chosen.name}',
          'Pick $overallPick: ${chosen.position.code}',
          kind: 'selected',
          args: {
            'pickNumber': overallPick,
            'playerName': chosen.name,
            'teamName': _teamName(state, pick.teamId),
            'position': chosen.position.code,
          },
          urgent: true,
        );
        playerPickProspectId = null;
      }
    }

    state = state.copyWith(
      draftedRights: draftedRights,
      currentSeason: state.currentSeason.copyWith(
        draftState: draft,
        phase: SeasonPhase.offseason,
      ),
    );

    // Draft just finished this call: undrafted prospects go to the FA pool
    // (`docs/offseason.md` §8).
    final nowComplete = draft.currentPickIndex >= draft.order.length;
    if (!wasComplete && nowComplete) {
      state = _finalizeDraftFreeAgents(state, draft);
    }

    return state;
  }

  /// Advances the draft by exactly one AI pick. Does nothing if:
  /// - draftState is null
  /// - draft is already complete
  /// - the current pick belongs to the player's team
  LeagueState advanceDraftOnePick(LeagueState league, {int saveSeed = 0}) {
    var draft = league.currentSeason.draftState;
    if (draft == null) return league;
    if (draft.currentPickIndex >= draft.order.length) return league;

    final pick = draft.order[draft.currentPickIndex];
    if (pick.teamId == league.playerTeamId) return league;

    final taken = draft.completedPicks
        .map((c) => c.prospectId)
        .whereType<String>()
        .toSet();
    final remaining =
        draft.draftClass.prospects.where((p) => !taken.contains(p.id)).toList()
          ..sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));
    if (remaining.isEmpty) return league;

    final overallPick = pick.pickNumber ?? draft.currentPickIndex + 1;
    final decision = _decideAiDraft(
      league,
      draft,
      pick,
      overallPick,
      saveSeed: saveSeed,
    );
    final trade = _resolveAiDraftTrade(league, draft, pick, decision);
    if (trade.pending || trade.swapped) return trade.state;
    final chosen = _chooseAiDraftProspect(remaining, decision);
    final salary = balance.salaryCap.rookieSalaryForPick(overallPick);
    final player = chosen
        .toPlayer(
          contract: Contract(
            salary: salary,
            yearsRemaining: balance.salaryCap.rookieScaleYears,
            isRookieScale: true,
            rookiePickSlot: overallPick,
          ),
          draftYear: draft.year,
          rng: _random,
          balance: balance,
        )
        .recalculatePointValue(balance);

    final right = DraftedPlayerRights(
      id: 'rights:${league.currentSeason.year}:$overallPick:${chosen.id}',
      ownerTeamId: pick.teamId,
      player: player,
      draftYear: league.currentSeason.year,
      pickNumber: overallPick,
    );
    final draftedRights = [
      ...league.draftedRights.where((item) => item.id != right.id),
      right,
    ];

    final completed = pick.copyWith(
      prospectId: chosen.id,
      playerName: chosen.name,
    );
    final newOrder = List<DraftPick>.from(draft.order);
    newOrder[draft.currentPickIndex] = completed;
    draft = draft.copyWith(
      completedPicks: [...draft.completedPicks, completed],
      currentPickIndex: draft.currentPickIndex + 1,
      order: newOrder,
    );

    var state = league.copyWith(
      draftedRights: draftedRights,
      currentSeason: league.currentSeason.copyWith(
        draftState: draft,
        phase: SeasonPhase.offseason,
      ),
    );
    state = _maybeSignAiDraftedRight(state, right, pick, saveSeed: saveSeed);
    return _finalizeDraftFreeAgents(state, draft);
  }
}
