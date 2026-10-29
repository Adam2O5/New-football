part of 'staff_negotiation_harness.dart';

_ServiceObservation _observeService(
  _Scenario scenario,
  StaffMember member, {
  required TeamStatus offeringStatus,
  required TeamStatus currentStatus,
  required StaffMember? cfo,
  required int round,
  required int reactionSeed,
}) {
  const balance = BalanceConfig.defaults;
  final service = StaffService(random: Random(reactionSeed));
  final raw = expectedStaffRawOverall(member.attributes, member.role);
  final want = _oracleStaffWant(raw, currentStatus);
  final expectedSalary = _oracleExpectedSalary(want, balance);
  final expectedLength = _oracleExpectedLength(want, member.age);
  final cfoRaw = cfo == null
      ? null
      : expectedStaffRawOverall(cfo.attributes, StaffRole.cfo);
  final expectedBreakdown = NegotiationRules.score(
    salary: scenario.offer.salary,
    expectedSalary: expectedSalary,
    years: scenario.offer.years,
    expectedLength: expectedLength,
    offeringTeamStatus: offeringStatus,
    cfoNegotiation: cfoRaw,
    balance: balance.contracts,
  );
  final breakdown = service.staffOfferBreakdown(
    member,
    scenario.offer,
    offeringTeamStatus: offeringStatus,
    currentTeamStatus: currentStatus,
    cfo: cfo,
  );
  _expectBreakdownEqual(
    breakdown,
    expectedBreakdown,
    reason:
        '${_reason(scenario, caseIndex: -1, seed: reactionSeed)}: direct breakdown is not a raw/status/CFO/offer function',
  );

  final expectedCounter = _oracleCounter(
    member: member,
    offer: scenario.offer,
    round: round,
    offeringStatus: offeringStatus,
    currentStatus: currentStatus,
    cfoNegotiation: cfoRaw,
  );
  final counter = service.counterOfferForRound(
    member,
    scenario.offer,
    round: round,
    offeringTeamStatus: offeringStatus,
    currentTeamStatus: currentStatus,
    cfo: cfo,
  );
  _expectOffersEqual(
    counter,
    expectedCounter,
    reason:
        '${_reason(scenario, caseIndex: -1, seed: reactionSeed)}: direct counter path changed its raw oracle',
  );

  final belowExpectation = scenario.offer.salary < expectedSalary;
  final expectedReaction = _oracleReaction(
    score: expectedBreakdown.score,
    phase: scenario.phase,
    random: Random(reactionSeed),
    belowExpectation: belowExpectation,
  );
  final reaction = service.evaluateOffer(
    member,
    scenario.offer,
    phase: scenario.phase,
    offeringTeamStatus: offeringStatus,
    currentTeamStatus: currentStatus,
    cfo: cfo,
    belowExpectation: belowExpectation,
    random: Random(reactionSeed),
  );
  expect(
    reaction,
    expectedReaction,
    reason:
        '${_reason(scenario, caseIndex: -1, seed: reactionSeed)}: evaluateOffer diverged from the raw score/replay oracle',
  );

  return _ServiceObservation(
    want: service.staffWant(member, currentTeamStatus: currentStatus),
    expectedSalary: service.expectedSalary(
      member,
      currentTeamStatus: currentStatus,
    ),
    expectedLength: service.expectedLength(
      member,
      currentTeamStatus: currentStatus,
    ),
    breakdown: breakdown,
    score: service.staffOfferScore(
      member,
      scenario.offer,
      offeringTeamStatus: offeringStatus,
      currentTeamStatus: currentStatus,
      cfo: cfo,
    ),
    counter: counter,
    reaction: reaction,
  );
}

_MarketObservation _observeMarket(_Scenario scenario, StaffMember member) {
  final league = _marketLeague(scenario, member, playerControlled: true);
  final team = league.teamById(_teamId(scenario));
  if (team == null) {
    fail(
      '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: '
      'market fixture did not contain its offering team',
    );
  }
  final market = ContractMarketService();
  final result = market.submitStaffOffer(
    league: league,
    candidate: member,
    offer: scenario.offer,
    saveSeed: scenario.seed,
  );
  if (result == null) {
    fail(
      '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: '
      'ContractMarketService rejected a legal staff fixture',
    );
  }
  final negotiations = result.league.negotiations.where(
    (item) => item.subjectId == member.id,
  );
  if (negotiations.length != 1) {
    fail(
      '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: '
      'persisted ${negotiations.length} staff negotiations instead of one',
    );
  }
  final negotiation = negotiations.single;
  final expected = _observeService(
    scenario,
    member,
    offeringStatus: scenario.marketStatus,
    currentStatus: scenario.marketStatus,
    cfo: scenario.marketCfo,
    round: 1,
    reactionSeed: _marketSubmissionSeed(scenario),
  );
  expect(
    result.reaction,
    expected.reaction,
    reason:
        '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: UI/market reaction did not replay from the same raw score',
  );
  expect(
    negotiation.offerScore,
    closeTo(expected.score, 1e-9),
    reason:
        '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: persisted offerScore did not use StaffService RawOverall',
  );
  _expectNegotiationCounter(
    negotiation,
    expected.reaction == StaffReaction.counter ? expected.counter : null,
    reason:
        '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: persisted counter diverged from StaffService',
  );
  return _MarketObservation(
    score: negotiation.offerScore,
    reaction: result.reaction,
    counter: _staffOfferFromNegotiation(negotiation.counterOffer),
    negotiation: negotiation,
  );
}

void _assertStaleRecompute(
  _Scenario scenario,
  StaffMember member, {
  required String reason,
}) {
  final source = _marketLeague(scenario, member, playerControlled: true);
  final team = source.teamById(_teamId(scenario));
  if (team == null) fail('$reason: stale fixture lost its offering team');
  final date = _marketDate(scenario);
  final stale = const NegotiationService()
      .start(
        id: 'p9-stale:${member.id}:${scenario.phase.name}',
        subjectId: member.id,
        subjectKind: NegotiationSubjectKind.staff,
        teamId: team.id,
        phase: scenario.phase,
        offer: NegotiationOffer(
          salary: scenario.offer.salary,
          years: scenario.offer.years,
        ),
        seasonYear: date.seasonYear,
        week: date.week,
        day: date.day,
        hour: date.hour,
        offerScore: -999.0,
      )
      .copyWith(status: NegotiationStatus.pendingFinalization);
  final state = source.copyWith(negotiations: [stale]);
  final resolved = _resolveMarketState(state, scenario);
  final updated = resolved.negotiationById(stale.id);
  expect(updated, isNotNull, reason: '$reason: stale negotiation disappeared');
  final expected = StaffService().staffOfferScore(
    member,
    scenario.offer,
    offeringTeamStatus: scenario.marketStatus,
    currentTeamStatus: scenario.marketStatus,
    cfo: scenario.marketCfo,
  );
  expect(
    updated!.offerScore,
    closeTo(expected, 1e-9),
    reason: '$reason: persisted recompute kept stale/rounded score',
  );
}

void _assertWaitingCounter(
  _Scenario scenario,
  StaffMember member, {
  required String reason,
}) {
  final source = _marketLeague(scenario, member, playerControlled: true);
  final team = source.teamById(_teamId(scenario));
  if (team == null) fail('$reason: waiting fixture lost its offering team');
  final date = _marketDate(scenario);
  final waiting = const NegotiationService()
      .start(
        id: 'p9-waiting:${member.id}:${scenario.phase.name}',
        subjectId: member.id,
        subjectKind: NegotiationSubjectKind.staff,
        teamId: team.id,
        phase: scenario.phase,
        offer: NegotiationOffer(
          salary: scenario.offer.salary,
          years: scenario.offer.years,
        ),
        seasonYear: date.seasonYear,
        week: date.week,
        day: date.day,
        hour: date.hour,
        offerScore: -777.0,
      )
      .copyWith(
        status: NegotiationStatus.waiting,
        waitingUntilSeasonYear: date.seasonYear,
        waitingUntilWeek: date.week,
        waitingUntilDay: date.day,
        waitingUntilHour: date.hour,
      );
  final resolved = _resolveMarketState(
    source.copyWith(negotiations: [waiting]),
    scenario,
  );
  final updated = resolved.negotiationById(waiting.id);
  expect(
    updated,
    isNotNull,
    reason: '$reason: waiting negotiation disappeared',
  );
  final service = StaffService();
  final score = service.staffOfferScore(
    member,
    scenario.offer,
    offeringTeamStatus: scenario.marketStatus,
    currentTeamStatus: scenario.marketStatus,
    cfo: scenario.marketCfo,
  );
  expect(
    updated!.offerScore,
    closeTo(score, 1e-9),
    reason: '$reason: waiting recompute did not use the canonical raw score',
  );
  final expectedStatus = _waitingStatus(
    score: score,
    scenario: scenario,
    league: source,
    team: team,
    round: 1,
  );
  expect(
    updated.status,
    expectedStatus,
    reason: '$reason: waiting reaction changed with a non-raw heuristic',
  );
  if (expectedStatus == NegotiationStatus.counter) {
    final expectedCounter = service.counterOfferForRound(
      member,
      scenario.offer,
      round: 1,
      offeringTeamStatus: scenario.marketStatus,
      currentTeamStatus: scenario.marketStatus,
      cfo: scenario.marketCfo,
    );
    _expectNegotiationCounter(
      updated,
      expectedCounter,
      reason: '$reason: persisted waiting counter did not use raw terms',
    );
  }
}

LeagueState _marketLeague(
  _Scenario scenario,
  StaffMember member, {
  required bool playerControlled,
}) {
  final team = _marketTeam(
    scenario,
    member,
    playerControlled: playerControlled,
  );
  final date = _marketDate(scenario);
  return staffFixtureLeague(
    teams: [team],
    playerTeamId: playerControlled ? team.id : null,
    staffFreeAgents: scenario.phase == NegotiationPhase.contractExtension
        ? const []
        : [member],
    currentWeek: date.week,
    currentDay: date.day,
    currentHour: date.hour,
    teamStatus: scenario.marketStatus,
  );
}

Team _marketTeam(
  _Scenario scenario,
  StaffMember member, {
  required bool playerControlled,
}) {
  final slots = <StaffRole, StaffMember?>{};
  if (scenario.phase == NegotiationPhase.contractExtension) {
    slots[scenario.member.role] = member;
  }
  if (scenario.marketCfo != null && scenario.member.role != StaffRole.cfo) {
    slots[StaffRole.cfo] = scenario.marketCfo;
  }
  if (!playerControlled) {
    for (final role in StaffRole.values) {
      if (role == scenario.member.role) continue;
      if (role == StaffRole.cfo) {
        if (scenario.marketCfo != null) continue;
        // A missing assisting CFO must remain an EmptySlot; a low-rated
        // filler would change the negotiation multiplier.
        continue;
      }
      slots[role] = staffMemberFor(
        role,
        attributes: staffAttributesWithRawOverall(role, 1.0),
        id: 'p9_ai_fill_${scenario.member.role.name}_${role.name}',
      );
    }
  }
  return staffFixtureTeam(
    id: _teamId(scenario),
    staff: teamStaffOf(slots),
    ai: playerControlled ? null : const TeamAiConfig(),
  );
}

LeagueState _resolveMarketState(LeagueState state, _Scenario scenario) {
  final market = ContractMarketService();
  return scenario.phase == NegotiationPhase.freeAgencyPhaseII
      ? market.resolveDay(state, saveSeed: scenario.seed)
      : market.resolveHour(
          state,
          hour: _marketDate(scenario).hour,
          saveSeed: scenario.seed,
        );
}

({int seasonYear, int week, int day, int hour}) _marketDate(
  _Scenario scenario,
) {
  switch (scenario.phase) {
    case NegotiationPhase.freeAgencyPhaseI:
      return (
        seasonYear: staffFixtureSeasonYear,
        week: staffFixtureFreeAgencyWeek(),
        day: 1,
        hour: 1,
      );
    case NegotiationPhase.freeAgencyPhaseII:
      return (
        seasonYear: staffFixtureSeasonYear,
        // Phase II wraps into weeks 1–45. Week 1 keeps the resolver before
        // its documented phase-II expiry boundary.
        week: 1,
        day: 1,
        hour: 0,
      );
    case NegotiationPhase.contractExtension:
      return (
        seasonYear: staffFixtureSeasonYear,
        week: staffFixtureExtensionWeek(),
        day: 2,
        hour: 1,
      );
  }
}

String _teamId(_Scenario scenario) =>
    'p9_team_${scenario.member.role.name}_${scenario.seed}';

int _marketSubmissionSeed(_Scenario scenario) {
  final date = _marketDate(scenario);
  final value =
      '${scenario.seed}:${date.seasonYear}:${date.week}:'
      '${date.day}:${date.hour}:${_teamId(scenario)}:'
      '${scenario.member.id}:submit:${scenario.phase.name}';
  return _stableSeed(value);
}

int _marketWaitingSeed(_Scenario scenario, LeagueState league, Team team) {
  final date = _marketDate(scenario);
  final value =
      '${scenario.seed}:${date.seasonYear}:${date.week}:'
      '${date.day}:${date.hour}:${team.id}:${scenario.member.id}:waiting:1';
  return _stableSeed(value);
}

NegotiationStatus _waitingStatus({
  required double score,
  required _Scenario scenario,
  required LeagueState league,
  required Team team,
  required int round,
}) {
  final balance = BalanceConfig.defaults.contracts;
  if (score >= 70) return NegotiationStatus.pendingFinalization;
  if (score >= 55) {
    final random = Random(_marketWaitingSeed(scenario, league, team));
    final probability = (0.50 + (score - 62) * 0.03).clamp(0.0, 1.0);
    if (random.nextDouble() < probability) {
      return NegotiationStatus.pendingFinalization;
    }
  }
  if (score >= 40) return NegotiationStatus.counter;
  return score <= balance.hardRejectScoreMax
      ? NegotiationStatus.hardRejected
      : NegotiationStatus.rejected;
}
