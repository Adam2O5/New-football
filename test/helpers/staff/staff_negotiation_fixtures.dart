part of '../staff_role_ratings_test_helpers.dart';

// ---------------------------------------------------------------------------
// Offers and negotiation context
// ---------------------------------------------------------------------------

/// Offer inside the documented staff salary range.
StaffOffer staffFixtureOffer({
  int salary = staffFixtureSalary,
  int years = 3,
}) => StaffOffer(salary: salary, years: years);

/// Offer derived from the member's own expectations.
///
/// [salaryFactor] scales the expected salary before the legal clamp, so the
/// same fixture can produce accepting, countering and rejecting offers.
StaffOffer staffOfferFor(
  StaffMember member, {
  StaffService? service,
  TeamStatus currentTeamStatus = TeamStatus.pretender,
  double salaryFactor = 1.0,
  int? years,
  BalanceConfig balance = BalanceConfig.defaults,
}) {
  final resolved = service ?? staffFixtureService(balance: balance);
  final expected = resolved.expectedSalary(
    member,
    currentTeamStatus: currentTeamStatus,
  );
  final salary = (expected * salaryFactor).round().clamp(
    balance.staff.minSalary,
    balance.staff.maxSalary,
  );
  final length =
      years ??
      resolved
          .expectedLength(member, currentTeamStatus: currentTeamStatus)
          .clamp(1, 4);
  return StaffOffer(salary: salary, years: length);
}

/// One reproducible staff negotiation scenario.
///
/// The same fixture replayed with [random] produces the same reaction, counter
/// offer and score, which is what lets a test attribute any difference to the
/// rating path instead of to randomness.
class StaffNegotiationFixture {
  const StaffNegotiationFixture({
    required this.member,
    required this.offer,
    this.cfo,
    this.offeringTeamStatus = TeamStatus.pretender,
    this.currentTeamStatus = TeamStatus.pretender,
    this.phase = NegotiationPhase.freeAgencyPhaseI,
    this.round = 1,
    this.seed = staffFixtureSeed,
  });

  /// Negotiation subject. For a `cfo` subject the assisting [cfo] stays a
  /// separate input.
  final StaffMember member;
  final StaffOffer offer;

  /// Assisting CFO of the offering team; `null` is the no-CFO scenario.
  final StaffMember? cfo;
  final TeamStatus offeringTeamStatus;
  final TeamStatus currentTeamStatus;
  final NegotiationPhase phase;
  final int round;
  final int seed;

  /// Fresh seeded [Random]; call it per assertion so each run starts equal.
  Random get random => Random(seed);

  StaffNegotiationFixture withMember(StaffMember member) =>
      StaffNegotiationFixture(
        member: member,
        offer: offer,
        cfo: cfo,
        offeringTeamStatus: offeringTeamStatus,
        currentTeamStatus: currentTeamStatus,
        phase: phase,
        round: round,
        seed: seed,
      );

  StaffNegotiationFixture withOffer(StaffOffer offer) =>
      StaffNegotiationFixture(
        member: member,
        offer: offer,
        cfo: cfo,
        offeringTeamStatus: offeringTeamStatus,
        currentTeamStatus: currentTeamStatus,
        phase: phase,
        round: round,
        seed: seed,
      );

  StaffNegotiationFixture withRound(int round) => StaffNegotiationFixture(
    member: member,
    offer: offer,
    cfo: cfo,
    offeringTeamStatus: offeringTeamStatus,
    currentTeamStatus: currentTeamStatus,
    phase: phase,
    round: round,
    seed: seed,
  );

  /// Same scenario without an assisting CFO.
  StaffNegotiationFixture withoutCfo() => StaffNegotiationFixture(
    member: member,
    offer: offer,
    offeringTeamStatus: offeringTeamStatus,
    currentTeamStatus: currentTeamStatus,
    phase: phase,
    round: round,
    seed: seed,
  );

  /// Same scenario with exactly one irrelevant attribute of the subject
  /// changed. Every negotiation output must stay identical.
  StaffNegotiationFixture withIrrelevantSubjectAttribute({
    double value = 5.0,
    String? name,
  }) => withMember(
    member.copyWith(
      attributes: withIrrelevantStaffAttribute(
        member.attributes,
        member.role,
        value: value,
        name: name,
      ),
    ),
  );
}

/// Negotiation fixture with an offer derived from the subject's expectations.
StaffNegotiationFixture staffNegotiationFixture({
  StaffRole role = StaffRole.headCoach,
  StaffMember? member,
  StaffOffer? offer,
  StaffMember? cfo,
  bool withCfo = true,
  double cfoNegotiation = 4.0,
  TeamStatus offeringTeamStatus = TeamStatus.pretender,
  TeamStatus currentTeamStatus = TeamStatus.pretender,
  NegotiationPhase phase = NegotiationPhase.freeAgencyPhaseI,
  int round = 1,
  int seed = staffFixtureSeed,
  double salaryFactor = 1.0,
}) {
  final subject = member ?? staffMemberFor(role);
  return StaffNegotiationFixture(
    member: subject,
    offer:
        offer ??
        staffOfferFor(
          subject,
          currentTeamStatus: currentTeamStatus,
          salaryFactor: salaryFactor,
        ),
    cfo:
        cfo ??
        (withCfo
            ? staffCfoMember(negotiation: cfoNegotiation, index: 90)
            : null),
    offeringTeamStatus: offeringTeamStatus,
    currentTeamStatus: currentTeamStatus,
    phase: phase,
    round: round,
    seed: seed,
  );
}

/// Deterministic negotiation scenario for property-like tests: random but
/// always legal role, attributes, statuses, offer and round.
StaffNegotiationFixture randomStaffNegotiationFixture(
  Random random, {
  StaffRole? role,
  bool withCfo = true,
  int index = 1,
  BalanceConfig balance = BalanceConfig.defaults,
}) {
  final resolvedRole =
      role ?? StaffRole.values[random.nextInt(StaffRole.values.length)];
  final subject = randomStaffMember(random, resolvedRole, index: index);
  final offeringTeamStatus =
      TeamStatus.values[random.nextInt(TeamStatus.values.length)];
  final currentTeamStatus =
      TeamStatus.values[random.nextInt(TeamStatus.values.length)];
  final salaryFactor = 0.8 + random.nextInt(9) * 0.05;
  final round = 1 + random.nextInt(balance.contracts.maxCounterRounds);
  final cfoNegotiation =
      staffInRangeAttributeValues[random.nextInt(
        staffInRangeAttributeValues.length,
      )];
  final seed = staffFixtureSeed + random.nextInt(1 << 20);
  return staffNegotiationFixture(
    member: subject,
    withCfo: withCfo,
    cfoNegotiation: cfoNegotiation,
    offeringTeamStatus: offeringTeamStatus,
    currentTeamStatus: currentTeamStatus,
    round: round,
    seed: seed,
    salaryFactor: salaryFactor,
  );
}
