import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/staff_service.dart';

import '../staff_role_ratings_test_helpers.dart';

const staffContractPropertyTag =
    'Feature: staff-role-ratings, Property 7: konsumenci kontraktowi są funkcją raw ratingu';
const staffContractCasesPerRole = 24;
const staffContractPropertySeed = staffFixtureSeed + 7075;
const staffContractBoundaryOffer = StaffOffer(salary: 2550000, years: 3);

class StaffContractScenario {
  const StaffContractScenario({
    required this.member,
    required this.offer,
    required this.offeringTeamStatus,
    required this.currentTeamStatus,
    required this.cfo,
    required this.phase,
    required this.round,
    required this.seed,
    required this.competingOffers,
    required this.forceWaiting,
  });

  final StaffMember member;
  final StaffOffer offer;
  final TeamStatus offeringTeamStatus;
  final TeamStatus currentTeamStatus;
  final StaffMember? cfo;
  final NegotiationPhase phase;
  final int round;
  final int seed;
  final bool competingOffers;
  final bool forceWaiting;
}

class StaffContractObservation {
  const StaffContractObservation({
    required this.marketSalary,
    required this.staffWant,
    required this.expectedSalary,
    required this.expectedLength,
    required this.breakdown,
    required this.score,
    required this.counter,
    required this.reaction,
    required this.persistedScore,
  });

  final double marketSalary;
  final double staffWant;
  final int expectedSalary;
  final int expectedLength;
  final OfferScoreBreakdown breakdown;
  final double score;
  final StaffOffer? counter;
  final StaffReaction reaction;
  final double persistedScore;
}

List<StaffContractScenario> staffContractScenariosForRole(
  StaffRole role,
  int seed,
) {
  final random = Random(seed);
  return List<StaffContractScenario>.generate(
    staffContractCasesPerRole,
    (caseIndex) => staffContractScenarioForRole(role, caseIndex, random),
    growable: false,
  );
}

StaffContractScenario staffContractScenarioForRole(
  StaffRole role,
  int caseIndex,
  Random random,
) {
  final specialRaw = switch (caseIndex) {
    0 => 3.25,
    1 => 3.5,
    2 => 3.75,
    3 => 0.0,
    4 => 5.0,
    _ => null,
  };
  final attributes = specialRaw == null
      ? randomStaffAttributes(random, includeOutOfRange: true)
      : staffAttributesWithRawOverall(
          role,
          specialRaw,
          spread:
              relevantStaffAttributeNames(role).length == 1 ||
                  specialRaw == 0.0 ||
                  specialRaw == 5.0
              ? 0.0
              : 0.25,
          irrelevantValue: caseIndex.isEven ? 5.0 : 0.0,
        );
  final age = specialRaw == 0.0 || specialRaw == 5.0
      ? 60
      : 35 + random.nextInt(26);
  final member = staffMemberFor(
    role,
    attributes: attributes,
    id: 'p7_${role.name}_${caseIndex.toString().padLeft(3, '0')}',
    index: caseIndex + 1,
    age: age,
  );
  final offeringTeamStatus =
      TeamStatus.values[(caseIndex + role.index) % TeamStatus.values.length];
  final currentTeamStatus = TeamStatus
      .values[(caseIndex * 2 + role.index + 1) % TeamStatus.values.length];
  final withCfo = role == StaffRole.cfo ? caseIndex.isEven : caseIndex % 3 != 0;
  final cfo = withCfo
      ? staffCfoMember(
          negotiation: const [0.0, 1.5, 2.5, 3.25, 3.75, 5.0][caseIndex % 6],
          irrelevantValue: 5.0,
          index: 900 + caseIndex,
        )
      : null;
  final raw = expectedStaffRawOverall(attributes, role);
  final expectedSalary = _oracleExpectedSalary(
    _oracleStaffWant(raw, currentTeamStatus),
    BalanceConfig.defaults,
  );
  final factor = switch (caseIndex) {
    0 || 1 => 1.0,
    2 => 0.9,
    3 => 0.8,
    4 => 1.15,
    _ => 0.8 + (caseIndex % 9) * 0.05,
  };
  final salary = specialRaw == 0.0
      ? BalanceConfig.defaults.staff.minSalary
      : specialRaw == 5.0
      ? BalanceConfig.defaults.staff.maxSalary
      : (expectedSalary * factor).round().clamp(
          BalanceConfig.defaults.staff.minSalary,
          BalanceConfig.defaults.staff.maxSalary,
        );
  final years = specialRaw == 0.0
      ? 1
      : specialRaw == 5.0
      ? 4
      : 1 + caseIndex % 4;

  return StaffContractScenario(
    member: member,
    offer: StaffOffer(salary: salary, years: years),
    offeringTeamStatus: offeringTeamStatus,
    currentTeamStatus: currentTeamStatus,
    cfo: cfo,
    phase: NegotiationPhase.values[caseIndex % NegotiationPhase.values.length],
    round: 1 + caseIndex % BalanceConfig.defaults.contracts.maxCounterRounds,
    seed: staffContractPropertySeed + role.index * 1009 + caseIndex * 37,
    competingOffers: caseIndex % 3 == 0,
    forceWaiting: caseIndex % 7 == 0,
  );
}

StaffContractScenario staffContractBoundaryScenario(
  StaffRole role, {
  required double raw,
  required String id,
  required int seed,
}) {
  return StaffContractScenario(
    member: staffMemberFor(
      role,
      attributes: staffAttributesWithRawOverall(
        role,
        raw,
        spread: relevantStaffAttributeNames(role).length == 1 ? 0.0 : 0.25,
        irrelevantValue: 5.0,
      ),
      id: id,
      age: 45,
    ),
    offer: staffContractBoundaryOffer,
    offeringTeamStatus: TeamStatus.pretender,
    currentTeamStatus: TeamStatus.pretender,
    cfo: null,
    phase: NegotiationPhase.contractExtension,
    round: 1,
    seed: seed,
    competingOffers: false,
    forceWaiting: false,
  );
}

void expectStaffContractConsumers(
  StaffContractScenario scenario, {
  required String reason,
}) {
  final member = scenario.member;
  final role = member.role;
  final raw = expectedStaffRawOverall(member.attributes, role);
  final displayed = expectedStaffDisplayedRating(raw);
  expect(member.overall, raw, reason: '$reason: fixture raw oracle mismatch');
  expect(
    StaffPresentation.viewForMember(member).rating!.displayedRating,
    displayed,
    reason: '$reason: displayed rating oracle mismatch',
  );

  final base = observeStaffContract(scenario, member, reason: reason);
  final irrelevantName = irrelevantStaffAttributeNames(role).first;
  final currentIrrelevant = staffAttributeByName(
    member.attributes,
    irrelevantName,
  );
  final irrelevantValue = currentIrrelevant == 5.0 ? 0.0 : 5.0;
  final irrelevantMember = member.copyWith(
    attributes: withIrrelevantStaffAttribute(
      member.attributes,
      role,
      name: irrelevantName,
      value: irrelevantValue,
    ),
  );
  final irrelevant = observeStaffContract(
    scenario,
    irrelevantMember,
    reason: '$reason irrelevant=$irrelevantName:$irrelevantValue',
  );

  expect(
    irrelevantMember.overall,
    raw,
    reason: '$reason: irrelevant attribute changed RawOverall',
  );
  expect(
    expectedStaffDisplayedRating(irrelevantMember.overall),
    displayed,
    reason: '$reason: irrelevant mutation changed DisplayedRating',
  );
  _expectObservedEqual(base, irrelevant, reason: reason);
}

StaffContractObservation observeStaffContract(
  StaffContractScenario scenario,
  StaffMember member, {
  required String reason,
}) {
  const balance = BalanceConfig.defaults;
  final raw = expectedStaffRawOverall(member.attributes, member.role);
  final expectedWant = _oracleStaffWant(raw, scenario.currentTeamStatus);
  final expectedSalary = _oracleExpectedSalary(expectedWant, balance);
  final expectedLength = _oracleExpectedLength(expectedWant, member.age);
  final cfoRaw = scenario.cfo == null
      ? null
      : expectedStaffRawOverall(scenario.cfo!.attributes, StaffRole.cfo);
  final service = StaffService(random: Random(scenario.seed));
  final expectedBreakdown = NegotiationRules.score(
    salary: scenario.offer.salary,
    expectedSalary: expectedSalary,
    years: scenario.offer.years,
    expectedLength: expectedLength,
    offeringTeamStatus: scenario.offeringTeamStatus,
    cfoNegotiation: cfoRaw,
    balance: balance.contracts,
  );
  final breakdown = service.staffOfferBreakdown(
    member,
    scenario.offer,
    offeringTeamStatus: scenario.offeringTeamStatus,
    currentTeamStatus: scenario.currentTeamStatus,
    cfo: scenario.cfo,
  );

  expect(
    service.marketSalary(member),
    closeTo(balance.staff.salaryFor(member.role, raw), 1e-9),
    reason: '$reason: marketSalary is not based on canonical RawOverall',
  );
  expect(
    service.staffWant(member, currentTeamStatus: scenario.currentTeamStatus),
    closeTo(expectedWant, 1e-9),
    reason: '$reason: staffWant did not use raw/status inputs',
  );
  expect(
    service.expectedSalary(
      member,
      currentTeamStatus: scenario.currentTeamStatus,
    ),
    expectedSalary,
    reason: '$reason: expectedSalary did not use raw staffWant',
  );
  expect(
    service.expectedLength(
      member,
      currentTeamStatus: scenario.currentTeamStatus,
    ),
    expectedLength,
    reason: '$reason: expectedLength did not use raw staffWant/age',
  );
  _expectBreakdownEqual(
    breakdown,
    expectedBreakdown,
    reason: '$reason: offer breakdown ignored raw/status/CFO/offer inputs',
  );
  expect(
    service.staffOfferScore(
      member,
      scenario.offer,
      offeringTeamStatus: scenario.offeringTeamStatus,
      currentTeamStatus: scenario.currentTeamStatus,
      cfo: scenario.cfo,
    ),
    closeTo(expectedBreakdown.score, 1e-9),
    reason: '$reason: staffOfferScore diverged from the raw breakdown',
  );

  final expectedCounter = _oracleCounterOffer(
    member: member,
    offer: scenario.offer,
    round: scenario.round,
    offeringTeamStatus: scenario.offeringTeamStatus,
    currentTeamStatus: scenario.currentTeamStatus,
    cfoNegotiation: cfoRaw,
  );
  final counter = service.counterOfferForRound(
    member,
    scenario.offer,
    round: scenario.round,
    offeringTeamStatus: scenario.offeringTeamStatus,
    currentTeamStatus: scenario.currentTeamStatus,
    cfo: scenario.cfo,
  );
  _expectOffersEqual(
    counter,
    expectedCounter,
    reason: '$reason: counterOfferForRound ignored raw contract inputs',
  );
  _expectOffersEqual(
    service.counterOffer(
      member,
      scenario.offer,
      round: scenario.round,
      offeringTeamStatus: scenario.offeringTeamStatus,
      currentTeamStatus: scenario.currentTeamStatus,
      cfo: scenario.cfo,
    ),
    expectedCounter,
    reason: '$reason: counterOffer wrapper diverged from raw counter path',
  );

  final belowExpectation = scenario.offer.salary < expectedSalary;
  final expectedReaction = _oracleReaction(
    score: expectedBreakdown.score,
    phase: scenario.phase,
    random: Random(scenario.seed + 1),
    competingOffers: scenario.competingOffers,
    belowExpectation: belowExpectation,
    forceWaiting: scenario.forceWaiting,
  );
  final reaction = service.evaluateOffer(
    member,
    scenario.offer,
    phase: scenario.phase,
    offeringTeamStatus: scenario.offeringTeamStatus,
    currentTeamStatus: scenario.currentTeamStatus,
    cfo: scenario.cfo,
    competingOffers: scenario.competingOffers,
    belowExpectation: belowExpectation,
    forceWaiting: scenario.forceWaiting,
    random: Random(scenario.seed + 1),
  );
  expect(
    reaction,
    expectedReaction,
    reason: '$reason: evaluateOffer ignored raw/status/CFO/offer inputs',
  );

  final marketCfo = member.role == StaffRole.cfo ? null : scenario.cfo;
  final persistedScore = _persistedMarketScore(
    member,
    scenario,
    cfo: marketCfo,
    reason: reason,
  );
  final persistedExpectedScore = service.staffOfferScore(
    member,
    scenario.offer,
    offeringTeamStatus: scenario.offeringTeamStatus,
    currentTeamStatus: scenario.offeringTeamStatus,
    cfo: marketCfo,
  );
  expect(
    persistedScore,
    closeTo(persistedExpectedScore, 1e-9),
    reason:
        '$reason: ContractMarketService persisted a score different from '
        'StaffService RawOverall calculation',
  );

  return StaffContractObservation(
    marketSalary: service.marketSalary(member),
    staffWant: service.staffWant(
      member,
      currentTeamStatus: scenario.currentTeamStatus,
    ),
    expectedSalary: service.expectedSalary(
      member,
      currentTeamStatus: scenario.currentTeamStatus,
    ),
    expectedLength: service.expectedLength(
      member,
      currentTeamStatus: scenario.currentTeamStatus,
    ),
    breakdown: breakdown,
    score: service.staffOfferScore(
      member,
      scenario.offer,
      offeringTeamStatus: scenario.offeringTeamStatus,
      currentTeamStatus: scenario.currentTeamStatus,
      cfo: scenario.cfo,
    ),
    counter: counter,
    reaction: reaction,
    persistedScore: persistedScore,
  );
}

void _expectObservedEqual(
  StaffContractObservation expected,
  StaffContractObservation actual, {
  required String reason,
}) {
  expect(actual.marketSalary, expected.marketSalary, reason: '$reason: market');
  expect(actual.staffWant, expected.staffWant, reason: '$reason: want');
  expect(
    actual.expectedSalary,
    expected.expectedSalary,
    reason: '$reason: expected salary',
  );
  expect(
    actual.expectedLength,
    expected.expectedLength,
    reason: '$reason: expected length',
  );
  _expectBreakdownEqual(
    actual.breakdown,
    expected.breakdown,
    reason: '$reason: irrelevant mutation changed breakdown',
  );
  expect(actual.score, expected.score, reason: '$reason: score');
  _expectOffersEqual(
    actual.counter,
    expected.counter,
    reason: '$reason: irrelevant mutation changed counter',
  );
  expect(actual.reaction, expected.reaction, reason: '$reason: reaction');
  expect(
    actual.persistedScore,
    expected.persistedScore,
    reason: '$reason: irrelevant mutation changed persisted score',
  );
}

void _expectBreakdownEqual(
  OfferScoreBreakdown actual,
  OfferScoreBreakdown expected, {
  required String reason,
}) {
  expect(
    actual.salaryFit,
    closeTo(expected.salaryFit, 1e-9),
    reason: '$reason salaryFit',
  );
  expect(
    actual.lengthFit,
    closeTo(expected.lengthFit, 1e-9),
    reason: '$reason lengthFit',
  );
  expect(
    actual.teamStatus,
    closeTo(expected.teamStatus, 1e-9),
    reason: '$reason teamStatus',
  );
  expect(
    actual.cfoDiscount,
    closeTo(expected.cfoDiscount, 1e-9),
    reason: '$reason cfoDiscount',
  );
  expect(actual.score, closeTo(expected.score, 1e-9), reason: '$reason score');
}

void _expectOffersEqual(
  StaffOffer? actual,
  StaffOffer? expected, {
  required String reason,
}) {
  expect(actual?.salary, expected?.salary, reason: '$reason salary');
  expect(actual?.years, expected?.years, reason: '$reason years');
}

void expectStaffCounterOffersDifferent(
  StaffOffer? first,
  StaffOffer? second, {
  required String reason,
}) {
  expect(first, isNotNull, reason: '$reason first counter was null');
  expect(second, isNotNull, reason: '$reason second counter was null');
  expect(
    first!.salary != second!.salary || first.years != second.years,
    isTrue,
    reason: reason,
  );
}

StaffOffer? _oracleCounterOffer({
  required StaffMember member,
  required StaffOffer offer,
  required int round,
  required TeamStatus offeringTeamStatus,
  required TeamStatus currentTeamStatus,
  required double? cfoNegotiation,
}) {
  const balance = BalanceConfig.defaults;
  if (round < 1 || round > balance.contracts.maxCounterRounds) return null;
  final raw = expectedStaffRawOverall(member.attributes, member.role);
  final want = _oracleStaffWant(raw, currentTeamStatus);
  final expectedLength = _oracleExpectedLength(want, member.age);
  final years = expectedLength.clamp(1, 4);
  final expectedSalary = _oracleExpectedSalary(want, balance);
  final target = NegotiationRules.counterTargetScore(
    round,
    balance: balance.contracts,
  );
  final discount = NegotiationRules.cfoDiscount(cfoNegotiation);
  final length = NegotiationRules.lengthFit(
    years: years,
    expectedLength: expectedLength,
    balance: balance.contracts,
  );
  final desiredSalaryFit =
      target / discount -
      length -
      NegotiationRules.teamStatusBonus(offeringTeamStatus) -
      balance.contracts.salaryFitBase;
  final percentage = desiredSalaryFit >= 0
      ? desiredSalaryFit / balance.contracts.salaryAboveBonusPerPct
      : desiredSalaryFit / balance.contracts.salaryBelowPenaltyPerPct;
  final salary = (expectedSalary * (1 + percentage / 100)).round().clamp(
    balance.staff.minSalary,
    balance.staff.maxSalary,
  );
  return StaffOffer(salary: salary, years: years);
}

double _oracleStaffWant(double raw, TeamStatus status) =>
    (raw * 20.0 + NegotiationRules.teamStatusBonus(status))
        .clamp(0.0, 100.0)
        .toDouble();

int _oracleExpectedSalary(double want, BalanceConfig balance) {
  final normalized = want / 100.0;
  final salary =
      balance.staff.minSalary +
      (balance.staff.maxSalary - balance.staff.minSalary) *
          normalized *
          normalized;
  return salary.round().clamp(balance.staff.minSalary, balance.staff.maxSalary);
}

int _oracleExpectedLength(double want, int age) {
  final band = want <= 39
      ? 0
      : want <= 69
      ? 1
      : 2;
  if (age <= 54) return const [2, 3, 4][band];
  if (age <= 59) return const [1, 2, 2][band];
  return 1;
}

StaffReaction _oracleReaction({
  required double score,
  required NegotiationPhase phase,
  required Random random,
  required bool competingOffers,
  required bool belowExpectation,
  required bool forceWaiting,
}) {
  final decision = NegotiationRules.decisionForScore(
    score: score,
    phase: phase,
    random: random,
    competingOffers: competingOffers,
    belowExpectation: belowExpectation,
    forceWaiting: forceWaiting,
    balance: BalanceConfig.defaults.contracts,
  );
  return switch (decision) {
    NegotiationDecision.accept => StaffReaction.accept,
    NegotiationDecision.hardReject => StaffReaction.hardReject,
    NegotiationDecision.reject => StaffReaction.reject,
    NegotiationDecision.waiting => StaffReaction.waiting,
    NegotiationDecision.counter => StaffReaction.counter,
  };
}

double _persistedMarketScore(
  StaffMember member,
  StaffContractScenario scenario, {
  required StaffMember? cfo,
  required String reason,
}) {
  final team = staffFixtureTeam(
    staff: cfo == null ? emptyTeamStaff : teamStaffOf({StaffRole.cfo: cfo}),
  );
  final result = ContractMarketService().submitStaffOffer(
    league: staffFixtureLeague(
      teams: [team],
      staffFreeAgents: [member],
      teamStatus: scenario.offeringTeamStatus,
    ),
    candidate: member,
    offer: scenario.offer,
    saveSeed: scenario.seed,
  );
  if (result == null) {
    fail('$reason: ContractMarketService rejected a legal persisted fixture');
  }
  final negotiations = result.league.negotiations;
  if (negotiations.length != 1) {
    fail(
      '$reason: ContractMarketService persisted ${negotiations.length} '
      'negotiations instead of one',
    );
  }
  return negotiations.single.offerScore;
}

int staffContractSeedFor(StaffRole role) =>
    staffContractPropertySeed + role.index * 1009;

String staffContractScenarioReason({
  required StaffRole role,
  required int seed,
  required int caseIndex,
  required StaffContractScenario scenario,
}) {
  final raw = expectedStaffRawOverall(scenario.member.attributes, role);
  final displayed = expectedStaffDisplayedRating(raw);
  return '$staffContractPropertyTag role=${role.name} seed=$seed '
      'case=$caseIndex replaySeed=${scenario.seed} raw=$raw '
      'displayed=$displayed offer=${scenario.offer.salary}/'
      '${scenario.offer.years} offering=${scenario.offeringTeamStatus.name} '
      'current=${scenario.currentTeamStatus.name} '
      'cfo=${scenario.cfo?.overall} age=${scenario.member.age}';
}
