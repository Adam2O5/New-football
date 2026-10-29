part of 'staff_negotiation_harness.dart';

class _Scenario {
  const _Scenario({
    required this.member,
    required this.offer,
    required this.assistingCfo,
    required this.marketStatus,
    required this.directOfferingStatus,
    required this.directCurrentStatus,
    required this.phase,
    required this.round,
    required this.seed,
  });

  final StaffMember member;
  final StaffOffer offer;
  final StaffMember? assistingCfo;
  final TeamStatus marketStatus;
  final TeamStatus directOfferingStatus;
  final TeamStatus directCurrentStatus;
  final NegotiationPhase phase;
  final int round;
  final int seed;

  /// A CFO subject cannot also be the team's assisting CFO. Direct service
  /// tests may provide a separate assistant, but market/AI paths must pass no
  /// assistant when the subject itself occupies the CFO slot.
  StaffMember? get marketCfo =>
      member.role == StaffRole.cfo ? null : assistingCfo;

  _Scenario withMember(StaffMember nextMember) => _Scenario(
    member: nextMember,
    offer: offer,
    assistingCfo: assistingCfo,
    marketStatus: marketStatus,
    directOfferingStatus: directOfferingStatus,
    directCurrentStatus: directCurrentStatus,
    phase: phase,
    round: round,
    seed: seed,
  );
}

class _ServiceObservation {
  const _ServiceObservation({
    required this.want,
    required this.expectedSalary,
    required this.expectedLength,
    required this.breakdown,
    required this.score,
    required this.counter,
    required this.reaction,
  });

  final double want;
  final int expectedSalary;
  final int expectedLength;
  final OfferScoreBreakdown breakdown;
  final double score;
  final StaffOffer? counter;
  final StaffReaction reaction;
}

class _MarketObservation {
  const _MarketObservation({
    required this.score,
    required this.reaction,
    required this.counter,
    required this.negotiation,
  });

  final double score;
  final StaffReaction reaction;
  final StaffOffer? counter;
  final ContractNegotiation negotiation;
}

List<_Scenario> _scenariosForRole(StaffRole role, int seed) {
  final random = Random(seed);
  return List<_Scenario>.generate(
    _casesPerRole,
    (caseIndex) => _scenarioForCase(role, caseIndex, random),
    growable: false,
  );
}

_Scenario _scenarioForCase(StaffRole role, int caseIndex, Random random) {
  final phase = _phases[(caseIndex + role.index) % _phases.length];
  final specialRaw = switch (caseIndex) {
    0 => _collisionLowRaw,
    1 => _collisionHighRaw,
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
          irrelevantValue: caseIndex.isEven ? 5.0 : -4.0,
        );
  final age = specialRaw == 0.0 || specialRaw == 5.0
      ? 60
      : 35 + random.nextInt(26);
  final member = staffMemberFor(
    role,
    attributes: attributes,
    id: 'p9_${role.name}_${caseIndex.toString().padLeft(3, '0')}',
    index: caseIndex + 1,
    age: age,
    contract: phase == NegotiationPhase.contractExtension
        ? staffFixtureContract(salary: 1100000, yearsRemaining: 1)
        : null,
  );
  final marketStatus =
      TeamStatus.values[(caseIndex + role.index) % TeamStatus.values.length];
  final directOfferingStatus = TeamStatus
      .values[(caseIndex * 2 + role.index + 1) % TeamStatus.values.length];
  final directCurrentStatus = TeamStatus
      .values[(caseIndex * 3 + role.index + 2) % TeamStatus.values.length];
  final cfo = caseIndex % 3 == 0
      ? null
      : staffCfoMember(
          negotiation: const [0.0, 1.5, 2.5, 3.25, 3.75, 5.0][caseIndex % 6],
          index: 900 + role.index * 100 + caseIndex,
        );
  final service = StaffService();
  final expected = service.expectedSalary(
    member,
    currentTeamStatus: marketStatus,
  );
  final factor = const [
    0.68,
    0.82,
    0.96,
    1.0,
    1.08,
    1.22,
    0.74,
    1.14,
  ][caseIndex % 8];
  final salary = (expected * factor).round().clamp(
    BalanceConfig.defaults.staff.minSalary,
    BalanceConfig.defaults.staff.maxSalary,
  );
  final phaseSeed = _propertySeed + role.index * 1009 + caseIndex * 37;

  return _Scenario(
    member: member,
    offer: StaffOffer(salary: salary, years: 1 + caseIndex % 4),
    assistingCfo: cfo,
    marketStatus: marketStatus,
    directOfferingStatus: directOfferingStatus,
    directCurrentStatus: directCurrentStatus,
    phase: phase,
    round: 1 + caseIndex % BalanceConfig.defaults.contracts.maxCounterRounds,
    seed: phaseSeed,
  );
}

_Scenario _scenarioForRaw(
  StaffRole role, {
  required double raw,
  required String id,
  required int seed,
}) {
  final phase = NegotiationPhase.freeAgencyPhaseI;
  final member = staffMemberFor(
    role,
    attributes: staffAttributesWithRawOverall(
      role,
      raw,
      spread: relevantStaffAttributeNames(role).length == 1 ? 0.0 : 0.25,
      irrelevantValue: 5.0,
    ),
    id: id,
    age: 45,
  );
  final cfo = staffCfoMember(negotiation: 4.0, index: 990 + role.index);
  return _Scenario(
    member: member,
    offer: const StaffOffer(salary: 2550000, years: 3),
    assistingCfo: cfo,
    marketStatus: TeamStatus.pretender,
    directOfferingStatus: TeamStatus.pretender,
    directCurrentStatus: TeamStatus.pretender,
    phase: phase,
    round: 1,
    seed: seed,
  );
}
