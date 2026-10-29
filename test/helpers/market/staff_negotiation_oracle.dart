part of 'staff_negotiation_harness.dart';

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

StaffOffer? _oracleCounter({
  required StaffMember member,
  required StaffOffer offer,
  required int round,
  required TeamStatus offeringStatus,
  required TeamStatus currentStatus,
  required double? cfoNegotiation,
}) {
  const balance = BalanceConfig.defaults;
  if (round < 1 || round > balance.contracts.maxCounterRounds) return null;
  final raw = expectedStaffRawOverall(member.attributes, member.role);
  final want = _oracleStaffWant(raw, currentStatus);
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
      NegotiationRules.teamStatusBonus(offeringStatus) -
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

StaffReaction _oracleReaction({
  required double score,
  required NegotiationPhase phase,
  required Random random,
  required bool belowExpectation,
}) {
  final decision = NegotiationRules.decisionForScore(
    score: score,
    phase: phase,
    random: random,
    belowExpectation: belowExpectation,
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

void _expectMarketEqual(
  _MarketObservation expected,
  _MarketObservation actual, {
  required String reason,
}) {
  expect(actual.score, expected.score, reason: '$reason: persisted score');
  expect(
    actual.reaction,
    expected.reaction,
    reason: '$reason: persisted reaction',
  );
  _expectOffersEqual(
    actual.counter,
    expected.counter,
    reason: '$reason: persisted counter',
  );
  expect(
    actual.negotiation.status,
    expected.negotiation.status,
    reason: '$reason: persisted status',
  );
  expect(
    actual.negotiation.lastOffer.salary,
    expected.negotiation.lastOffer.salary,
    reason: '$reason: persisted last salary',
  );
  expect(
    actual.negotiation.lastOffer.years,
    expected.negotiation.lastOffer.years,
    reason: '$reason: persisted last years',
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
    reason: '$reason: salary fit',
  );
  expect(
    actual.lengthFit,
    closeTo(expected.lengthFit, 1e-9),
    reason: '$reason: length fit',
  );
  expect(
    actual.teamStatus,
    closeTo(expected.teamStatus, 1e-9),
    reason: '$reason: team status',
  );
  expect(
    actual.cfoDiscount,
    closeTo(expected.cfoDiscount, 1e-9),
    reason: '$reason: CFO discount',
  );
  expect(actual.score, closeTo(expected.score, 1e-9), reason: '$reason: score');
}

void _expectOffersEqual(
  StaffOffer? actual,
  StaffOffer? expected, {
  required String reason,
}) {
  expect(actual?.salary, expected?.salary, reason: '$reason: salary');
  expect(actual?.years, expected?.years, reason: '$reason: years');
}

void _expectOffersDifferent(
  StaffOffer? first,
  StaffOffer? second, {
  required String reason,
  required bool allowNullEquality,
}) {
  if (allowNullEquality && (first == null || second == null)) return;
  expect(first, isNotNull, reason: '$reason: first counter was null');
  expect(second, isNotNull, reason: '$reason: second counter was null');
  expect(
    first!.salary != second!.salary || first.years != second.years,
    isTrue,
    reason: reason,
  );
}

void _expectNegotiationCounter(
  ContractNegotiation negotiation,
  StaffOffer? expected, {
  required String reason,
}) {
  expect(
    negotiation.counterOffer?.salary,
    expected?.salary,
    reason: '$reason: salary',
  );
  expect(
    negotiation.counterOffer?.years,
    expected?.years,
    reason: '$reason: years',
  );
}

StaffOffer? _staffOfferFromNegotiation(NegotiationOffer? offer) =>
    offer == null ? null : StaffOffer(salary: offer.salary, years: offer.years);

int _stableSeed(String value) {
  var result = 0x45d9f3b;
  for (final code in value.codeUnits) {
    result = ((result * 33) ^ code) & 0x7fffffff;
  }
  return result == 0 ? 1 : result;
}

int _seedFor(StaffRole role) => _propertySeed + role.index * 1009;

String _reason(
  _Scenario scenario, {
  required int caseIndex,
  required int seed,
}) {
  final raw = expectedStaffRawOverall(
    scenario.member.attributes,
    scenario.member.role,
  );
  final displayed = expectedStaffDisplayedRating(raw);
  return '$_propertyTag role=${scenario.member.role.name} seed=$seed '
      'case=$caseIndex replaySeed=${scenario.seed} raw=$raw '
      'displayed=$displayed offer=${scenario.offer.salary}/'
      '${scenario.offer.years} marketStatus=${scenario.marketStatus.name} '
      'directOffering=${scenario.directOfferingStatus.name} '
      'directCurrent=${scenario.directCurrentStatus.name} '
      'phase=${scenario.phase.name} round=${scenario.round} '
      'cfo=${scenario.assistingCfo?.overall}';
}
