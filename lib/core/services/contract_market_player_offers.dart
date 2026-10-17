part of 'contract_market_service.dart';

mixin _ContractMarketPlayerOffers on _ContractMarketShared {
  /// Submits one user player offer through the same persisted negotiation
  /// state used by the AI resolver. A null result means the date/subject is
  /// outside the market or the offer cannot be created.
  ({LeagueState league, ContractReaction reaction})? submitPlayerOffer({
    required LeagueState league,
    required String playerId,
    required ContractOffer offer,
    required int saveSeed,
  }) {
    final phase = phaseAt(league);
    if (phase == null) return null;
    final team = league.playerTeam;
    if (team == null) return null;

    final isExtension = phase == NegotiationPhase.contractExtension;
    final player = isExtension
        ? team.roster.cast<Player?>().firstWhere(
            (item) => item?.id == playerId,
            orElse: () => null,
          )
        : league.freeAgents.cast<Player?>().firstWhere(
            (item) => item?.id == playerId,
            orElse: () => null,
          );
    if (player == null) return null;
    if (!isExtension && team.roster.length >= balance.roster.maxSize) {
      return null;
    }
    if (isExtension) {
      final isRookieExtensionCandidate =
          player.contract.isRookieScale && player.contract.yearsRemaining <= 1;
      if (isRookieExtensionCandidate &&
          offer.effectiveException != CapExceptionType.rookieExtension) {
        return null;
      }
    }

    final hour = phase == NegotiationPhase.freeAgencyPhaseII
        ? 0
        : (league.currentHour ?? 1);
    if (hour < 1 && phase != NegotiationPhase.freeAgencyPhaseII) return null;
    if (hour > balance.contracts.hoursPerDay) return null;
    final currentStatus =
        league.strengthTable?.entryFor(team.id)?.teamStatus ??
        TeamStatus.pretender;
    final sameDayNegotiation =
        phase != NegotiationPhase.freeAgencyPhaseII &&
        league.negotiations.any(
          (item) =>
              item.subjectId == player.id &&
              item.subjectKind == NegotiationSubjectKind.player &&
              item.teamId == team.id &&
              item.seasonYear == league.currentSeason.year &&
              item.week == league.currentWeek &&
              item.day == league.currentDay &&
              !item.isTerminal,
        );
    if (sameDayNegotiation) return null;
    if (phase == NegotiationPhase.freeAgencyPhaseI &&
        league.hourlyPlayerOfferUsed) {
      return null;
    }
    if (negotiations.isBlocked(
      league: league,
      subjectId: player.id,
      subjectKind: NegotiationSubjectKind.player,
      teamId: team.id,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
    )) {
      return null;
    }

    final legal = contracts.validateOffer(
      team: team,
      player: player,
      offer: offer,
    );
    if (!legal.ok) return null;
    final competingOffers = league.negotiations.any(
      (item) =>
          item.subjectId == player.id &&
          item.subjectKind == NegotiationSubjectKind.player &&
          item.teamId != team.id &&
          item.seasonYear == league.currentSeason.year &&
          item.week == league.currentWeek &&
          item.day == league.currentDay &&
          (phase == NegotiationPhase.freeAgencyPhaseII || item.hour == hour) &&
          !item.isTerminal,
    );
    final extensionMinutesAssessment = isExtension
        ? contracts.assessExtensionMinutes(team: team, player: player)
        : null;
    final reaction = extensionMinutesAssessment?.shouldHardReject == true
        ? ContractReaction.hardReject
        : contracts.evaluate(
            player,
            offer,
            phase: phase,
            offeringTeamStatus: currentStatus,
            currentTeamStatus: isExtension
                ? currentStatus
                : TeamStatus.pretender,
            cfo: team.staff.cfo,
            competingOffers: competingOffers,
            belowExpectation:
                offer.salary <
                contracts.expectedSalary(
                  player,
                  currentTeamStatus: isExtension
                      ? currentStatus
                      : TeamStatus.pretender,
                ),
            random: Random(
              _stableSeed(
                '$saveSeed:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour:${team.id}:${player.id}:submit:${phase.name}',
              ),
            ),
          );
    final id =
        '${isExtension ? 'extension' : 'player'}:${player.id}:${team.id}:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour';
    final initial = negotiations.start(
      id: id,
      subjectId: player.id,
      subjectKind: NegotiationSubjectKind.player,
      teamId: team.id,
      phase: phase,
      offer: NegotiationOffer(
        salary: offer.salary,
        years: offer.years,
        exception: offer.effectiveException,
        rookiePickSlot: offer.rookiePickSlot,
      ),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      offerScore: contracts.playerOfferScore(
        player,
        offer,
        offeringTeamStatus: currentStatus,
        currentTeamStatus: isExtension ? currentStatus : TeamStatus.pretender,
        cfo: team.staff.cfo,
      ),
    );
    final counter = reaction == ContractReaction.counter
        ? contracts.counterOfferForRound(
            player,
            offer,
            round: 1,
            offeringTeamStatus: currentStatus,
            currentTeamStatus: isExtension
                ? currentStatus
                : TeamStatus.pretender,
            cfo: team.staff.cfo,
          )
        : null;
    final decision = switch (reaction) {
      ContractReaction.accept => NegotiationDecision.accept,
      ContractReaction.hardReject => NegotiationDecision.hardReject,
      ContractReaction.reject => NegotiationDecision.reject,
      ContractReaction.waiting => NegotiationDecision.waiting,
      ContractReaction.counter => NegotiationDecision.counter,
    };
    final record = negotiations.applyDecision(
      negotiation: initial,
      decision: decision,
      counterOffer: counter == null
          ? null
          : NegotiationOffer(
              salary: counter.salary,
              years: counter.years,
              exception: counter.effectiveException,
              rookiePickSlot: counter.rookiePickSlot,
            ),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
    );
    var state = negotiations.upsert(league, record);
    if (reaction == ContractReaction.hardReject) {
      state = negotiations.upsert(
        state,
        record,
        block: negotiations.blockFor(
          subjectId: player.id,
          subjectKind: NegotiationSubjectKind.player,
          teamId: team.id,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          day: league.currentDay,
          hour: hour,
        ),
      );
    }
    if (phase == NegotiationPhase.freeAgencyPhaseI) {
      state = state.copyWith(hourlyPlayerOfferUsed: true);
    }
    state = messages.send(
      state,
      type: MessageType.contractOfferResponse,
      kind: reaction.name,
      domain: MessageDomain.contracts,
      hour: hour,
      args: {
        'subjectName': player.name,
        'playerName': player.name,
        'salary': (record.counterOffer ?? record.lastOffer).salary,
        'years': (record.counterOffer ?? record.lastOffer).years,
        'score': record.offerScore,
        'phase': phase.name,
      },
      payload: {
        'negotiationId': record.id,
        'playerId': player.id,
        'teamId': team.id,
        'counterSalary': record.counterOffer?.salary,
        'counterYears': record.counterOffer?.years,
        if (extensionMinutesAssessment != null)
          ...extensionMinutesAssessment.messagePayload,
      },
    );
    return (league: state, reaction: reaction);
  }
}
