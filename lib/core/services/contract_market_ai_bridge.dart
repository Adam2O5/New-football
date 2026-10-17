part of 'contract_market_service.dart';

mixin _ContractMarketAiBridge on _ContractMarketShared {
  @override
  LeagueState _addAiOffers(
    LeagueState league, {
    required NegotiationPhase phase,
    required int hour,
    required int saveSeed,
  }) {
    var state = _applyAiRfaDecisions(league, phase: phase, saveSeed: saveSeed);
    final aiTeamIds = [
      for (final team in state.teams)
        if (!team.isPlayerControlled) team.id,
    ];
    for (final teamId in aiTeamIds) {
      final team = state.teamById(teamId);
      if (team == null) continue;

      if (phase == NegotiationPhase.contractExtension) {
        final extension = _bestAiExtensionPlan(state, team, saveSeed: saveSeed);
        if (extension != null &&
            !_hasAiNegotiation(
              state,
              team.id,
              extension.player.id,
              NegotiationSubjectKind.player,
              phase,
              hour,
              onePerDay: true,
            )) {
          state = _insertAiPlayerPlan(
            state,
            team: team,
            plan: extension,
            phase: phase,
            hour: hour,
          );
        }
        final currentTeam = state.teamById(team.id) ?? team;
        final staffPlan = aiPolicy.staffExtensionPlan(
          league: state,
          team: currentTeam,
          saveSeed: saveSeed,
        );
        if (staffPlan != null &&
            !_hasAiNegotiation(
              state,
              currentTeam.id,
              staffPlan.member.id,
              NegotiationSubjectKind.staff,
              phase,
              hour,
              onePerDay: true,
            )) {
          state = _insertAiStaffPlan(
            state,
            team: currentTeam,
            plan: staffPlan,
            phase: phase,
            hour: hour,
          );
        }
        continue;
      }

      final playerPlan = phase == NegotiationPhase.freeAgencyPhaseI
          ? aiPolicy.phaseOnePlayerPlan(
              league: state,
              team: team,
              hour: hour,
              saveSeed: saveSeed,
            )
          : aiPolicy.phaseTwoPlayerPlan(
              league: state,
              team: team,
              saveSeed: saveSeed,
            );
      if (playerPlan != null &&
          !_hasAiNegotiation(
            state,
            team.id,
            playerPlan.player.id,
            NegotiationSubjectKind.player,
            phase,
            hour,
          )) {
        state = _insertAiPlayerPlan(
          state,
          team: team,
          plan: playerPlan,
          phase: phase,
          hour: hour,
        );
      }

      final currentTeam = state.teamById(team.id) ?? team;
      final staffPlan = aiPolicy.staffFreeAgentPlan(
        league: state,
        team: currentTeam,
        saveSeed: saveSeed,
      );
      if (staffPlan != null &&
          !_hasAiNegotiation(
            state,
            currentTeam.id,
            staffPlan.member.id,
            NegotiationSubjectKind.staff,
            phase,
            hour,
          )) {
        state = _insertAiStaffPlan(
          state,
          team: currentTeam,
          plan: staffPlan,
          phase: phase,
          hour: hour,
        );
      }
    }
    return state;
  }

  AiPlayerOfferPlan? _bestAiExtensionPlan(
    LeagueState league,
    Team team, {
    required int saveSeed,
  }) {
    final plans = <AiPlayerOfferPlan>[];
    for (final player in team.roster) {
      if (_hasAiNegotiation(
        league,
        team.id,
        player.id,
        NegotiationSubjectKind.player,
        NegotiationPhase.contractExtension,
        league.currentHour ?? 1,
        onePerDay: true,
      )) {
        continue;
      }
      final plan = aiPolicy.extensionPlan(
        league: league,
        team: team,
        player: player,
        saveSeed: saveSeed,
      );
      if (plan != null) plans.add(plan);
    }
    plans.sort((a, b) {
      final priority = _extensionPriority(
        a.exception,
      ).compareTo(_extensionPriority(b.exception));
      if (priority != 0) return priority;
      final score = b.offerScore.compareTo(a.offerScore);
      return score != 0 ? score : a.player.id.compareTo(b.player.id);
    });
    return plans.isEmpty ? null : plans.first;
  }

  int _extensionPriority(CapExceptionType? exception) => switch (exception) {
    CapExceptionType.rookieExtension => 1,
    CapExceptionType.fullBirdRights => 2,
    CapExceptionType.earlyBirdRights => 3,
    CapExceptionType.veteranExtensionRaiseCap => 4,
    CapExceptionType.nonBirdRights => 5,
    _ => 99,
  };

  LeagueState _insertAiPlayerPlan(
    LeagueState league, {
    required Team team,
    required AiPlayerOfferPlan plan,
    required NegotiationPhase phase,
    required int hour,
  }) {
    final initial = negotiations.start(
      id: _aiId('player', plan.player.id, team.id, league, phase, hour),
      subjectId: plan.player.id,
      subjectKind: NegotiationSubjectKind.player,
      teamId: team.id,
      phase: phase,
      offer: NegotiationOffer(
        salary: plan.offer.salary,
        years: plan.offer.years,
        exception: plan.offer.effectiveException,
        rookiePickSlot: plan.offer.rookiePickSlot,
      ),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      offerScore: plan.offerScore,
      isAiOffer: true,
    );
    return _upsertAiNegotiation(
      league,
      negotiation: initial.copyWith(
        status: NegotiationStatus.pendingFinalization,
        requiresFinalization: true,
      ),
    );
  }

  LeagueState _insertAiStaffPlan(
    LeagueState league, {
    required Team team,
    required AiStaffOfferPlan plan,
    required NegotiationPhase phase,
    required int hour,
  }) {
    final initial = negotiations.start(
      id: _aiId('staff', plan.member.id, team.id, league, phase, hour),
      subjectId: plan.member.id,
      subjectKind: NegotiationSubjectKind.staff,
      teamId: team.id,
      phase: phase,
      offer: NegotiationOffer(
        salary: plan.offer.salary,
        years: plan.offer.years,
      ),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      offerScore: plan.offerScore,
      isAiOffer: true,
    );
    return _upsertAiNegotiation(
      league,
      negotiation: initial.copyWith(
        status: NegotiationStatus.pendingFinalization,
        requiresFinalization: true,
      ),
    );
  }

  bool _hasAiNegotiation(
    LeagueState league,
    String teamId,
    String subjectId,
    NegotiationSubjectKind subjectKind,
    NegotiationPhase phase,
    int hour, {
    bool onePerDay = false,
  }) => league.negotiations.any(
    (item) =>
        item.isAiOffer &&
        item.teamId == teamId &&
        item.subjectId == subjectId &&
        item.subjectKind == subjectKind &&
        item.phase == phase &&
        item.seasonYear == league.currentSeason.year &&
        item.week == league.currentWeek &&
        item.day == league.currentDay &&
        (onePerDay || item.hour == hour),
  );

  LeagueState _applyAiRfaDecisions(
    LeagueState league, {
    required NegotiationPhase phase,
    required int saveSeed,
  }) {
    if (phase == NegotiationPhase.contractExtension) return league;
    var state = league;
    final aiTeams = [
      for (final team in state.teams)
        if (!team.isPlayerControlled) team.id,
    ];
    for (final teamId in aiTeams) {
      final team = state.teamById(teamId);
      if (team == null) continue;
      for (final player in team.roster) {
        if (!aiPolicy.shouldSubmitQualifyingOffer(
          league: state,
          team: team,
          player: player,
          saveSeed: saveSeed,
        )) {
          continue;
        }
        final next = submitQualifyingOffer(
          league: state,
          ownerTeamId: team.id,
          playerId: player.id,
        );
        if (next != null) state = next;
      }
    }
    final sheets = [
      for (final sheet in state.rfaOfferSheets)
        if (!sheet.isTerminal &&
            sheet.phase == phase &&
            state.teamById(sheet.originalTeamId)?.isPlayerControlled == false)
          sheet,
    ];
    for (final sheet in sheets) {
      if (aiPolicy.shouldMatchOfferSheet(
        league: state,
        sheet: sheet,
        saveSeed: saveSeed,
      )) {
        state = matchOfferSheet(state, sheet.id, saveSeed: saveSeed) ?? state;
      } else {
        state = declineOfferSheet(state, sheet.id);
      }
    }
    return state;
  }

  @override
  LeagueState _resolveAiCounters(
    LeagueState league, {
    required NegotiationPhase phase,
    required int hour,
    required int saveSeed,
  }) {
    if (phase != NegotiationPhase.contractExtension) return league;
    var state = league;
    for (final current in [...league.negotiations]) {
      if (!current.isAiOffer ||
          current.phase != phase ||
          current.status != NegotiationStatus.counter ||
          current.week != league.currentWeek ||
          current.day != league.currentDay) {
        continue;
      }
      final team = state.teamById(current.teamId);
      final player = _findPlayer(state, current.subjectId);
      if (team == null || player == null) continue;
      final shouldRaise = aiPolicy.shouldRaiseExtensionCounter(
        league: state,
        team: team,
        player: player,
        saveSeed: saveSeed,
        round: current.round,
      );
      if (!shouldRaise) {
        state = state.upsertNegotiation(
          current.copyWith(
            status: NegotiationStatus.rejected,
            counterOffer: null,
            requiresFinalization: false,
          ),
        );
        continue;
      }
      final playerCounter = ContractOffer(
        salary: current.lastOffer.salary,
        years: current.lastOffer.years,
        exception: current.lastOffer.exception,
        rookiePickSlot: current.lastOffer.rookiePickSlot,
      );
      final original = ContractOffer(
        salary: max(
          balance.salaryCap.minSalary,
          (playerCounter.salary * 0.90).round(),
        ),
        years: playerCounter.years,
        exception: playerCounter.exception,
        rookiePickSlot: playerCounter.rookiePickSlot,
      );
      final raised = aiPolicy.extensionCounterOffer(
        league: state,
        team: team,
        player: player,
        original: original,
        playerCounter: playerCounter,
        saveSeed: saveSeed,
      );
      if (raised == null) {
        state = state.upsertNegotiation(
          current.copyWith(
            status: NegotiationStatus.rejected,
            counterOffer: null,
            requiresFinalization: false,
          ),
        );
        continue;
      }
      state = state.upsertNegotiation(
        current.copyWith(
          lastOffer: NegotiationOffer(
            salary: raised.salary,
            years: raised.years,
            exception: raised.effectiveException,
            rookiePickSlot: raised.rookiePickSlot,
          ),
          counterOffer: null,
          status: NegotiationStatus.pendingFinalization,
          requiresFinalization: true,
          offerScore: contracts.playerOfferScore(
            player,
            raised,
            offeringTeamStatus:
                league.strengthTable?.entryFor(team.id)?.teamStatus ??
                TeamStatus.pretender,
            currentTeamStatus:
                league.strengthTable?.entryFor(team.id)?.teamStatus ??
                TeamStatus.pretender,
            cfo: team.staff.cfo,
          ),
        ),
      );
    }
    return state;
  }
}
