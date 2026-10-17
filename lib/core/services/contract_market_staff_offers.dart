part of 'contract_market_service.dart';

mixin _ContractMarketStaffOffers on _ContractMarketShared {
  /// Submits a user staff offer. Staff uses the same hourly FA-I limit and
  /// persisted response lifecycle as player negotiations.
  ({LeagueState league, StaffReaction reaction})? submitStaffOffer({
    required LeagueState league,
    required StaffMember candidate,
    required StaffOffer offer,
    required int saveSeed,
  }) {
    final phase = phaseAt(league);
    if (phase == null) return null;
    final team = league.playerTeam;
    if (team == null) return null;
    final isExtension = phase == NegotiationPhase.contractExtension;
    final resolvedCandidate = isExtension
        ? _staffMemberForTeam(team, candidate.id)
        : league.canonicalStaffFreeAgents.cast<StaffMember?>().firstWhere(
            (member) => member?.id == candidate.id,
            orElse: () => null,
          );
    if (resolvedCandidate == null) return null;
    final actualCandidate = resolvedCandidate;
    if (isExtension &&
        (actualCandidate.contract == null ||
            actualCandidate.contract!.yearsRemaining > 1)) {
      return null;
    }
    if (!isExtension &&
        team.staff.canonicalMember(actualCandidate.role) != null) {
      return null;
    }
    if (phase == NegotiationPhase.freeAgencyPhaseI &&
        league.hourlyStaffOfferUsed) {
      return null;
    }
    if (offer.years < 1 || offer.years > 4) return null;
    final replacingSalary = isExtension
        ? actualCandidate.contract?.salary ?? 0
        : 0;
    if (staff.hireValidationReason(
          team,
          offer.salary,
          replacingSalary: replacingSalary,
        ) !=
        null) {
      return null;
    }

    final hour = phase == NegotiationPhase.freeAgencyPhaseII
        ? 0
        : (league.currentHour ?? 1);
    if (hour < 1 && phase != NegotiationPhase.freeAgencyPhaseII) return null;
    if (hour > balance.contracts.hoursPerDay) return null;
    final status =
        league.strengthTable?.entryFor(team.id)?.teamStatus ??
        TeamStatus.pretender;
    final sameDayNegotiation =
        phase != NegotiationPhase.freeAgencyPhaseII &&
        league.negotiations.any(
          (item) =>
              item.subjectId == actualCandidate.id &&
              item.subjectKind == NegotiationSubjectKind.staff &&
              item.teamId == team.id &&
              item.seasonYear == league.currentSeason.year &&
              item.week == league.currentWeek &&
              item.day == league.currentDay &&
              !item.isTerminal,
        );
    if (sameDayNegotiation) return null;
    if (negotiations.isBlocked(
      league: league,
      subjectId: actualCandidate.id,
      subjectKind: NegotiationSubjectKind.staff,
      teamId: team.id,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
    )) {
      return null;
    }

    final competingOffers = league.negotiations.any(
      (item) =>
          item.subjectId == actualCandidate.id &&
          item.subjectKind == NegotiationSubjectKind.staff &&
          item.teamId != team.id &&
          item.seasonYear == league.currentSeason.year &&
          item.week == league.currentWeek &&
          item.day == league.currentDay &&
          (phase == NegotiationPhase.freeAgencyPhaseII || item.hour == hour) &&
          !item.isTerminal,
    );
    final reaction = staff.evaluateOffer(
      actualCandidate,
      offer,
      phase: phase,
      offeringTeamStatus: status,
      currentTeamStatus: status,
      cfo: actualCandidate.role == StaffRole.cfo ? null : team.staff.cfo,
      competingOffers: competingOffers,
      belowExpectation:
          offer.salary <
          staff.expectedSalary(actualCandidate, currentTeamStatus: status),
      random: Random(
        _stableSeed(
          '$saveSeed:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour:${team.id}:${actualCandidate.id}:submit:${phase.name}',
        ),
      ),
    );
    final id =
        'staff:${actualCandidate.id}:${team.id}:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour';
    final initial = negotiations.start(
      id: id,
      subjectId: actualCandidate.id,
      subjectKind: NegotiationSubjectKind.staff,
      teamId: team.id,
      phase: phase,
      offer: NegotiationOffer(salary: offer.salary, years: offer.years),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      offerScore: staff.staffOfferScore(
        actualCandidate,
        offer,
        offeringTeamStatus: status,
        currentTeamStatus: status,
        cfo: actualCandidate.role == StaffRole.cfo ? null : team.staff.cfo,
      ),
    );
    final counter = reaction == StaffReaction.counter
        ? staff.counterOfferForRound(
            actualCandidate,
            offer,
            round: 1,
            offeringTeamStatus: status,
            currentTeamStatus: status,
            cfo: actualCandidate.role == StaffRole.cfo ? null : team.staff.cfo,
          )
        : null;
    final decision = switch (reaction) {
      StaffReaction.accept => NegotiationDecision.accept,
      StaffReaction.hardReject => NegotiationDecision.hardReject,
      StaffReaction.reject => NegotiationDecision.reject,
      StaffReaction.waiting => NegotiationDecision.waiting,
      StaffReaction.counter => NegotiationDecision.counter,
    };
    final record = negotiations.applyDecision(
      negotiation: initial,
      decision: decision,
      counterOffer: counter == null
          ? null
          : NegotiationOffer(salary: counter.salary, years: counter.years),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
    );
    var state = negotiations.upsert(league, record);
    if (reaction == StaffReaction.hardReject) {
      state = negotiations.upsert(
        state,
        record,
        block: negotiations.blockFor(
          subjectId: actualCandidate.id,
          subjectKind: NegotiationSubjectKind.staff,
          teamId: team.id,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          day: league.currentDay,
          hour: hour,
        ),
      );
    }
    if (phase == NegotiationPhase.freeAgencyPhaseI) {
      state = state.copyWith(hourlyStaffOfferUsed: true);
    }
    state = messages.send(
      state,
      type: MessageType.staffOfferResponse,
      kind: reaction.name,
      domain: MessageDomain.staff,
      hour: hour,
      args: {
        'subjectName': actualCandidate.name,
        'staffName': actualCandidate.name,
        'staffRole': actualCandidate.role.name,
        'salary': (record.counterOffer ?? record.lastOffer).salary,
        'years': (record.counterOffer ?? record.lastOffer).years,
        'score': record.offerScore,
        'phase': phase.name,
      },
      payload: {
        'negotiationId': record.id,
        'staffId': actualCandidate.id,
        'teamId': team.id,
        'counterSalary': record.counterOffer?.salary,
        'counterYears': record.counterOffer?.years,
      },
    );
    return (league: state, reaction: reaction);
  }
}
