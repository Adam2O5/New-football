part of 'contract_market_service.dart';

mixin _ContractMarketDraftRights on _ContractMarketShared {
  /// Runs the draft-specific AI market work once at the Sunday → Monday
  /// boundary. It deliberately lives outside [resolveDay]: the calendar
  /// transition owns the weekly cadence, while this service owns all contract
  /// legality and persisted negotiation mutations.
  LeagueState weeklyTick(LeagueState league, {int saveSeed = 0}) {
    final marketPhase = phaseAt(league);
    if (marketPhase == null ||
        (marketPhase != NegotiationPhase.freeAgencyPhaseI &&
            marketPhase != NegotiationPhase.freeAgencyPhaseII)) {
      return league;
    }
    var state = _resolveDeferredRightsWeekly(league, saveSeed: saveSeed);
    state = _addFreshUndraftedOffersWeekly(
      state,
      phase: marketPhase,
      saveSeed: saveSeed,
    );
    return state;
  }

  LeagueState _resolveDeferredRightsWeekly(
    LeagueState league, {
    required int saveSeed,
  }) {
    final rights = [...league.draftedRights]
      ..sort((a, b) {
        final owner = a.ownerTeamId.compareTo(b.ownerTeamId);
        if (owner != 0) return owner;
        final player = a.player.id.compareTo(b.player.id);
        return player != 0 ? player : a.id.compareTo(b.id);
      });
    var state = league;
    for (final right in rights) {
      if (!state.draftedRights.any((item) => item.id == right.id)) continue;
      final team = state.teamById(right.ownerTeamId);
      if (team == null || team.isPlayerControlled) continue;
      final decision = aiDraftService.deferredRightsSigningDecision(
        team: team,
        prospectId: right.player.id,
        saveSeed: saveSeed,
        seasonYear: state.currentSeason.year,
        week: state.currentWeek,
      );
      if (!decision.sign) continue;
      state = signDraftedRight(state, right.id, saveSeed: saveSeed) ?? state;
    }
    return state;
  }

  LeagueState _addFreshUndraftedOffersWeekly(
    LeagueState league, {
    required NegotiationPhase phase,
    required int saveSeed,
  }) {
    final active = [...league.freshUndraftedPlayers]
      ..removeWhere(
        (record) =>
            !record.isActiveAt(
              seasonYear: league.currentSeason.year,
              week: league.currentWeek,
            ) ||
            !league.freeAgents.any((player) => player.id == record.playerId),
      )
      ..sort((a, b) {
        final year = a.draftYear.compareTo(b.draftYear);
        return year != 0 ? year : a.playerId.compareTo(b.playerId);
      });
    var state = league.copyWith(freshUndraftedPlayers: active);

    final aiTeamIds = [
      for (final team in state.teams)
        if (!team.isPlayerControlled) team.id,
    ]..sort();
    final hour = phase == NegotiationPhase.freeAgencyPhaseII
        ? 0
        : (state.currentHour ?? 1).clamp(1, balance.contracts.hoursPerDay);

    for (final teamId in aiTeamIds) {
      final currentTeam = state.teamById(teamId);
      if (currentTeam == null ||
          currentTeam.roster.length >= balance.roster.maxSize) {
        continue;
      }

      var remaining = phase == NegotiationPhase.freeAgencyPhaseII
          ? balance.ai.faPhaseTwoWeeklyOfferLimit -
                _aiPlayerOfferCountForWeek(state, teamId: teamId, phase: phase)
          : _aiPlayerOfferCountForSlot(
                  state,
                  teamId: teamId,
                  phase: phase,
                  day: state.currentDay,
                  hour: hour,
                ) ==
                0
          ? 1
          : 0;
      if (remaining <= 0) continue;

      final context = aiDraftService.evaluator.contextForTeam(
        team: currentTeam,
        league: state,
        saveSeed: saveSeed,
        seasonYear: state.currentSeason.year,
        week: state.currentWeek,
        decisionType: DecisionType.faOffer,
      );
      for (final record in active) {
        if (remaining <= 0) break;
        final player = state.freeAgents.cast<Player?>().firstWhere(
          (candidate) => candidate?.id == record.playerId,
          orElse: () => null,
        );
        if (player == null ||
            _hasAiPlayerNegotiationThisWeek(
              state,
              teamId: teamId,
              playerId: player.id,
              phase: phase,
            )) {
          continue;
        }

        final needBand =
            aiDraftService.evaluator
                .needForPosition(context, player.position)
                ?.band ??
            AiNeedBand.target;
        final decision = aiDraftService.undraftedSigningDecision(
          team: currentTeam,
          prospectId: player.id,
          needBand: needBand,
          saveSeed: saveSeed,
          seasonYear: state.currentSeason.year,
          week: state.currentWeek,
        );
        if (!decision.offer) continue;

        final offer = ContractOffer(
          salary: balance.salaryCap.minSalary,
          years: 2,
        );
        final legal = contracts.validateOffer(
          team: currentTeam,
          player: player,
          offer: offer,
        );
        if (!legal.ok) continue;

        final negotiation = negotiations
            .start(
              id: 'ai:undrafted:${player.id}:$teamId:${state.currentSeason.year}:${state.currentWeek}:${phase.name}',
              subjectId: player.id,
              subjectKind: NegotiationSubjectKind.player,
              teamId: teamId,
              phase: phase,
              offer: NegotiationOffer(
                salary: offer.salary,
                years: offer.years,
                exception: offer.effectiveException,
                rookiePickSlot: offer.rookiePickSlot,
              ),
              seasonYear: state.currentSeason.year,
              week: state.currentWeek,
              day: state.currentDay,
              hour: hour,
              offerScore: contracts.playerOfferScore(
                player,
                offer,
                offeringTeamStatus: context.teamStatus,
                currentTeamStatus: TeamStatus.pretender,
                cfo: currentTeam.staff.cfo,
              ),
              isAiOffer: true,
            )
            .copyWith(
              status: NegotiationStatus.pendingFinalization,
              requiresFinalization: true,
            );
        state = state.upsertNegotiation(negotiation);
        remaining--;
      }
    }
    return state;
  }

  int _aiPlayerOfferCountForWeek(
    LeagueState league, {
    required String teamId,
    required NegotiationPhase phase,
  }) => league.negotiations
      .where(
        (item) =>
            item.isAiOffer &&
            item.subjectKind == NegotiationSubjectKind.player &&
            item.teamId == teamId &&
            item.phase == phase &&
            item.seasonYear == league.currentSeason.year &&
            item.week == league.currentWeek,
      )
      .length;

  int _aiPlayerOfferCountForSlot(
    LeagueState league, {
    required String teamId,
    required NegotiationPhase phase,
    required int day,
    required int hour,
  }) => league.negotiations
      .where(
        (item) =>
            item.isAiOffer &&
            item.subjectKind == NegotiationSubjectKind.player &&
            item.teamId == teamId &&
            item.phase == phase &&
            item.seasonYear == league.currentSeason.year &&
            item.week == league.currentWeek &&
            item.day == day &&
            item.hour == hour,
      )
      .length;

  bool _hasAiPlayerNegotiationThisWeek(
    LeagueState league, {
    required String teamId,
    required String playerId,
    required NegotiationPhase phase,
  }) => league.negotiations.any(
    (item) =>
        item.isAiOffer &&
        item.subjectKind == NegotiationSubjectKind.player &&
        item.teamId == teamId &&
        item.subjectId == playerId &&
        item.phase == phase &&
        item.seasonYear == league.currentSeason.year &&
        item.week == league.currentWeek,
  );

  /// Signs a draft right without counting the right as a roster slot before
  /// this call. The operation is available whenever the destination has room.
  LeagueState? signDraftedRight(
    LeagueState league,
    String rightId, {
    int saveSeed = 0,
  }) {
    final right = league.draftedRights.cast<DraftedPlayerRights?>().firstWhere(
      (item) => item?.id == rightId,
      orElse: () => null,
    );
    if (right == null) return null;
    final team = league.teamById(right.ownerTeamId);
    if (team == null || team.roster.length >= balance.roster.maxSize) {
      return null;
    }
    final offer = ContractOffer(
      salary: right.player.contract.salary,
      years: right.player.contract.yearsRemaining,
      exception: CapExceptionType.rookieScale,
      rookiePickSlot: right.pickNumber,
    );
    final signed = contracts.signPlayer(
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      team: team,
      player: right.player,
      offer: offer,
      ntcRandom: Random(
        _seed(saveSeed, league, team.id, right.player.id, 'rights'),
      ),
    );
    if (signed == null) return null;
    var state = league
        .updateTeam(signed)
        .copyWith(
          draftedRights: league.draftedRights
              .where((item) => item.id != right.id)
              .toList(),
        );
    return messages.send(
      state,
      type: MessageType.contractSigned,
      domain: MessageDomain.contracts,
      args: {
        'subjectName': right.player.name,
        'playerName': right.player.name,
        'teamName': team.name,
        'salary': offer.salary,
        'years': offer.years,
      },
      payload: {
        'playerId': right.player.id,
        'teamId': team.id,
        'rightsId': right.id,
      },
    );
  }
}
