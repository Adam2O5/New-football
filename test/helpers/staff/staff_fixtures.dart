part of '../staff_role_ratings_test_helpers.dart';

/// Deterministic fixtures for the `staff-role-ratings` feature.
///
/// Every unit, property-like, widget and integration test of the feature is
/// expected to build its data here instead of repeating literals. Two rules
/// keep the fixtures usable as regression evidence:
///
/// 1. Nothing is random unless a [Random] is passed in explicitly, and IDs are
///    stable and lexicographically ordered so tie-breaks are reproducible.
/// 2. The canonical role → attribute expectations in this file are an
///    independent oracle transcribed from `docs/staff.md`. Tests must compare
///    production code against these values, never the other way round.

// ---------------------------------------------------------------------------
// Determinism
// ---------------------------------------------------------------------------

/// Default seed for every generator in this file.
const staffFixtureSeed = 20250216;

/// Default `saveSeed`; AI market rolls are derived from it.
const staffFixtureSaveSeed = 987654321;

/// Season used by league fixtures.
const staffFixtureSeasonYear = 2026;

/// Salary inside the documented staff min/max range and under the cap.
const staffFixtureSalary = 1000000;

/// Team identifiers. The rival team keeps competing-offer fixtures stable.
const staffFixtureTeamId = 'staff_fixture_team';
const staffFixtureRivalTeamId = 'staff_fixture_rival';

/// Role identifier outside `StaffRole` — an UnknownRole in persisted data.
const unknownStaffRoleValue = 'analyticsLead';

/// Attribute name `StaffAttributes` does not declare — an UnknownAttribute.
const unknownStaffAttributeName = 'leadership';

/// Seeded [Random]; the same seed always replays the same scenario.
Random staffFixtureRandom([int seed = staffFixtureSeed]) => Random(seed);

/// [StaffService] with a seeded [Random] so reactions stay reproducible.
StaffService staffFixtureService({
  int seed = staffFixtureSeed,
  BalanceConfig balance = BalanceConfig.defaults,
}) => StaffService(balance: balance, random: Random(seed));

// ---------------------------------------------------------------------------
// Attribute builders
// ---------------------------------------------------------------------------

/// Star values inside the documented 0–5 scale, including quarter steps that
/// only a two-attribute mean can produce.
const staffInRangeAttributeValues = <double>[
  0.0,
  0.25,
  0.5,
  1.0,
  1.25,
  1.5,
  2.0,
  2.25,
  2.5,
  2.75,
  3.0,
  3.25,
  3.5,
  3.75,
  4.0,
  4.25,
  4.5,
  4.75,
  5.0,
];

/// Values outside 0–5 that must be clamped before the rating is produced.
const staffOutOfRangeAttributeValues = <double>[
  -4.0,
  -1.5,
  -0.5,
  5.25,
  6.0,
  9.5,
];

/// In-range plus out-of-range values, for clamp coverage.
const staffExtendedAttributeValues = <double>[
  ...staffInRangeAttributeValues,
  ...staffOutOfRangeAttributeValues,
];

/// Raw values that must survive the domain unrounded.
const staffQuarterRawValues = <double>[0.25, 2.25, 2.75, 3.25, 3.75, 4.75];

/// `(raw, displayed)` pairs covering half-up rounding and both clamp edges.
const staffDisplayedRatingCases = <(double, double)>[
  (-1.0, 0.0),
  (0.0, 0.0),
  (0.24, 0.0),
  (0.25, 0.5),
  (2.25, 2.5),
  (2.75, 3.0),
  (3.25, 3.5),
  (3.75, 4.0),
  (5.0, 5.0),
  (7.5, 5.0),
];

/// Raw pairs that differ in the domain but share one DisplayedRating bucket.
/// The left value is always the smaller raw.
const staffDisplayedCollisionPairs = <(double, double)>[
  (2.26, 2.49),
  (3.26, 3.30),
  (3.76, 3.99),
];

/// Attributes where every field is [value].
StaffAttributes uniformStaffAttributes(double value) => StaffAttributes(
  tactics: value,
  motivation: value,
  development: value,
  mentoring: value,
  coverage: value,
  evaluation: value,
  rehabilitation: value,
  regenaration: value,
  prevention: value,
  care: value,
  negotiation: value,
);

/// Attributes where the relevant fields of [role] take [relevantValues] in
/// canonical order and every irrelevant field takes [irrelevantValue].
///
/// Raising [irrelevantValue] is the standard way to prove a rating, salary or
/// AI decision ignores fields outside the role.
StaffAttributes staffAttributesForRole(
  StaffRole role,
  List<double> relevantValues, {
  double irrelevantValue = 0.0,
}) {
  final names = relevantStaffAttributeNames(role);
  if (relevantValues.length != names.length) {
    throw ArgumentError.value(
      relevantValues,
      'relevantValues',
      '${role.name} needs exactly ${names.length} value(s)',
    );
  }
  var attributes = uniformStaffAttributes(irrelevantValue);
  for (var i = 0; i < names.length; i++) {
    attributes = withStaffAttribute(attributes, names[i], relevantValues[i]);
  }
  return attributes;
}

/// Attributes whose RawOverall for [role] is exactly [raw].
///
/// Two-attribute roles use `raw - spread` and `raw + spread`; the default
/// symmetric pair keeps the mean exact in floating point. `cfo` stores [raw]
/// in `Negotiation` and rejects a non-zero [spread].
StaffAttributes staffAttributesWithRawOverall(
  StaffRole role,
  double raw, {
  double spread = 0.0,
  double irrelevantValue = 0.0,
}) {
  final names = relevantStaffAttributeNames(role);
  if (names.length == 1) {
    if (spread != 0.0) {
      throw ArgumentError.value(
        spread,
        'spread',
        '${role.name} has a single relevant attribute',
      );
    }
    return staffAttributesForRole(role, [
      raw,
    ], irrelevantValue: irrelevantValue);
  }
  final low = raw - spread;
  final high = raw + spread;
  if (low < 0.0 || high > 5.0) {
    throw ArgumentError.value(
      spread,
      'spread',
      'raw $raw ± $spread leaves the 0–5 scale',
    );
  }
  return staffAttributesForRole(role, [
    low,
    high,
  ], irrelevantValue: irrelevantValue);
}

/// Copy of [attributes] with exactly one irrelevant field of [role] changed.
///
/// [name] defaults to the first irrelevant attribute, which for `headCoach` is
/// the legacy `development` field.
StaffAttributes withIrrelevantStaffAttribute(
  StaffAttributes attributes,
  StaffRole role, {
  double value = 5.0,
  String? name,
}) {
  final irrelevant = irrelevantStaffAttributeNames(role);
  final target = name ?? irrelevant.first;
  if (!irrelevant.contains(target)) {
    throw ArgumentError.value(
      target,
      'name',
      '$target is relevant for ${role.name}',
    );
  }
  return withStaffAttribute(attributes, target, value);
}

/// Copy of [attributes] with one relevant field of [role] raised by [delta]
/// and clamped to the 0–5 scale. Used for salary monotonicity checks.
StaffAttributes withRaisedRelevantStaffAttribute(
  StaffAttributes attributes,
  StaffRole role, {
  int index = 0,
  double delta = 0.5,
}) {
  final name = relevantStaffAttributeNames(role)[index];
  final raised = (staffAttributeByName(attributes, name) + delta).clamp(
    0.0,
    5.0,
  );
  return withStaffAttribute(attributes, name, raised.toDouble());
}

/// Deterministic attributes for all eleven fields.
///
/// With [includeOutOfRange] the pool also yields negative and above-5 values so
/// clamping is exercised.
StaffAttributes randomStaffAttributes(
  Random random, {
  bool includeOutOfRange = false,
}) {
  final pool = includeOutOfRange
      ? staffExtendedAttributeValues
      : staffInRangeAttributeValues;
  double next() => pool[random.nextInt(pool.length)];
  return StaffAttributes(
    tactics: next(),
    motivation: next(),
    development: next(),
    mentoring: next(),
    coverage: next(),
    evaluation: next(),
    rehabilitation: next(),
    regenaration: next(),
    prevention: next(),
    care: next(),
    negotiation: next(),
  );
}

// ---------------------------------------------------------------------------
// Member builders
// ---------------------------------------------------------------------------

/// Stable member ID. The zero-padded index keeps ascending string order equal
/// to ascending numeric order, which the ID tie-break relies on.
String staffFixtureId(StaffRole role, [int index = 1]) =>
    'staff_${role.name}_${index.toString().padLeft(3, '0')}';

/// Staff contract inside the legal salary range.
StaffContract staffFixtureContract({
  int salary = staffFixtureSalary,
  int yearsRemaining = 2,
}) => StaffContract(salary: salary, yearsRemaining: yearsRemaining);

/// One staff member with stable identity.
///
/// Pass either [attributes] or [relevantValues]; the default is a 3,0 rating
/// with every irrelevant field at [irrelevantValue].
StaffMember staffMemberFor(
  StaffRole role, {
  StaffAttributes? attributes,
  List<double>? relevantValues,
  double irrelevantValue = 0.0,
  int index = 1,
  String? id,
  String? name,
  Nationality nationality = Nationality.poland,
  int age = 45,
  StaffContract? contract,
  StaffAttributes? previousAttributes,
}) {
  if (attributes != null && relevantValues != null) {
    throw ArgumentError('Pass attributes or relevantValues, not both');
  }
  final resolved =
      attributes ??
      (relevantValues != null
          ? staffAttributesForRole(
              role,
              relevantValues,
              irrelevantValue: irrelevantValue,
            )
          : staffAttributesWithRawOverall(
              role,
              3.0,
              irrelevantValue: irrelevantValue,
            ));
  return StaffMember(
    id: id ?? staffFixtureId(role, index),
    name: name ?? '${role.name} #$index',
    nationality: nationality,
    age: age,
    role: role,
    attributes: resolved,
    contract: contract,
    previousAttributes: previousAttributes,
  );
}

/// CFO whose only relevant attribute is `Negotiation`. Use it both as the
/// negotiation subject and as the assisting CFO of a team.
StaffMember staffCfoMember({
  double negotiation = 4.0,
  double irrelevantValue = 5.0,
  int index = 1,
  int age = 45,
  StaffContract? contract,
}) => staffMemberFor(
  StaffRole.cfo,
  relevantValues: [negotiation],
  irrelevantValue: irrelevantValue,
  index: index,
  age: age,
  contract: contract,
);

/// Member whose declared role differs from the [slot] it is placed in.
///
/// The domain must skip such a record instead of adopting it for [slot].
StaffMember staffRoleMismatchedMember(
  StaffRole slot, {
  StaffRole? declaredRole,
  int index = 1,
}) {
  final resolved =
      declaredRole ??
      StaffRole.values[(slot.index + 1) % StaffRole.values.length];
  if (resolved == slot) {
    throw ArgumentError.value(declaredRole, 'declaredRole', 'equals the slot');
  }
  return staffMemberFor(
    resolved,
    index: index,
    id: staffFixtureId(slot, index),
  );
}

/// Candidates for one role, one per entry of [raws], with ascending IDs.
///
/// Equal raw values therefore resolve by ascending ID, and different raw values
/// that share a DisplayedRating keep their raw order.
List<StaffMember> staffCandidatesForRole(
  StaffRole role,
  List<double> raws, {
  double irrelevantValue = 0.0,
  int firstIndex = 1,
  int age = 45,
  StaffContract? contract,
}) => List<StaffMember>.generate(
  raws.length,
  (i) => staffMemberFor(
    role,
    attributes: staffAttributesWithRawOverall(
      role,
      raws[i],
      irrelevantValue: irrelevantValue,
    ),
    index: firstIndex + i,
    age: age,
    contract: contract,
  ),
  growable: false,
);

/// Deterministic member for property-like tests.
StaffMember randomStaffMember(
  Random random,
  StaffRole role, {
  int index = 1,
  bool includeOutOfRange = false,
  bool withContract = false,
}) {
  final attributes = randomStaffAttributes(
    random,
    includeOutOfRange: includeOutOfRange,
  );
  final age = 35 + random.nextInt(26);
  return staffMemberFor(
    role,
    attributes: attributes,
    index: index,
    age: age,
    contract: withContract ? staffFixtureContract() : null,
  );
}

/// Deterministic pool spread evenly across all six roles.
List<StaffMember> randomStaffPool(
  Random random, {
  int count = 12,
  bool includeOutOfRange = false,
  bool withContracts = false,
}) => List<StaffMember>.generate(
  count,
  (i) => randomStaffMember(
    random,
    StaffRole.values[i % StaffRole.values.length],
    index: i + 1,
    includeOutOfRange: includeOutOfRange,
    withContract: withContracts,
  ),
  growable: false,
);

// ---------------------------------------------------------------------------
// TeamStaff builders
// ---------------------------------------------------------------------------

/// Six recognized slots, all EmptySlot.
const emptyTeamStaff = TeamStaff();

/// Staff built from [members]; every role absent from the map stays an
/// EmptySlot, which is a different state from an UnknownRole record.
TeamStaff teamStaffOf(Map<StaffRole, StaffMember?> members) {
  var staff = emptyTeamStaff;
  for (final role in StaffRole.values) {
    staff = staff.withMember(role, members[role]);
  }
  return staff;
}

/// Staff with every role occupied at the same rating.
///
/// [cfoNegotiation] of `null` leaves the CFO slot empty, which is the no-CFO
/// fixture for negotiation discounts.
TeamStaff fullTeamStaff({
  double relevantValue = 3.0,
  double irrelevantValue = 0.0,
  double? cfoNegotiation = 4.0,
  bool withContracts = true,
  int salary = staffFixtureSalary,
  int index = 1,
}) {
  final contract = withContracts ? staffFixtureContract(salary: salary) : null;
  return teamStaffOf({
    for (final role in StaffRole.values)
      if (role != StaffRole.cfo)
        role: staffMemberFor(
          role,
          attributes: staffAttributesWithRawOverall(
            role,
            relevantValue,
            irrelevantValue: irrelevantValue,
          ),
          index: index,
          contract: contract,
        ),
    if (cfoNegotiation != null)
      StaffRole.cfo: staffCfoMember(
        negotiation: cfoNegotiation,
        irrelevantValue: irrelevantValue,
        index: index,
        contract: contract,
      ),
  });
}

/// Copy of [staff] with [role] emptied — the occupied → EmptySlot transition
/// that must not leave a stale rating behind.
TeamStaff teamStaffWithEmptySlot(TeamStaff staff, StaffRole role) =>
    staff.withMember(role, null);

// ---------------------------------------------------------------------------
// Team and league builders
// ---------------------------------------------------------------------------

/// Team fixture for staff tests. The roster stays empty by default because
/// staff payroll, ratings and negotiations do not read it.
Team staffFixtureTeam({
  String id = staffFixtureTeamId,
  String? name,
  String city = 'Fixture City',
  Conference conference = Conference.europe,
  TeamStaff staff = emptyTeamStaff,
  TeamFinance finance = const TeamFinance(),
  List<Player> roster = const [],
  TeamAiConfig? ai,
}) => Team(
  id: id,
  name: name ?? id,
  city: city,
  conference: conference,
  roster: roster,
  finance: finance,
  staff: staff,
  ai: ai,
);

/// League fixture positioned inside a contract-market window.
///
/// The defaults land on free agency phase I hour 1 with [staffFixtureTeamId] as
/// the player team. The strength table is filled for every team so
/// `teamStatus` — and therefore every salary and score expectation — is fixed
/// rather than falling back to a default.
LeagueState staffFixtureLeague({
  List<Team>? teams,
  List<StaffMember> staffFreeAgents = const [],
  String? playerTeamId = staffFixtureTeamId,
  int seasonYear = staffFixtureSeasonYear,
  SeasonPhase phase = SeasonPhase.offseason,
  int? currentWeek,
  int currentDay = 1,
  int? currentHour = 1,
  TeamStatus teamStatus = TeamStatus.pretender,
  List<ContractNegotiation> negotiations = const [],
  bool hourlyStaffOfferUsed = false,
  BalanceConfig balance = BalanceConfig.defaults,
}) {
  final resolvedTeams = teams ?? [staffFixtureTeam()];
  final week = currentWeek ?? balance.calendar.freeAgencyWeek;
  return LeagueState(
    teams: resolvedTeams,
    currentSeason: Season(year: seasonYear, phase: phase),
    playerTeamId: playerTeamId,
    currentWeek: week,
    currentDay: currentDay,
    currentHour: currentHour,
    hourlyStaffOfferUsed: hourlyStaffOfferUsed,
    staffFreeAgents: staffFreeAgents,
    negotiations: negotiations,
    strengthTable: LeagueStrengthTable(
      entries: [
        for (var i = 0; i < resolvedTeams.length; i++)
          TeamStrengthEntry(
            teamId: resolvedTeams[i].id,
            teamPower: 70.0 - i,
            expectedRank: i + 1,
            teamStatus: teamStatus,
          ),
      ],
      lastCalculatedWeek: week,
      lastCalculatedDay: currentDay,
      seasonYear: seasonYear,
    ),
  );
}

/// Week of the hourly free-agency staff market.
int staffFixtureFreeAgencyWeek({
  BalanceConfig balance = BalanceConfig.defaults,
}) => balance.calendar.freeAgencyWeek;

/// Week of the contract-extension window (Tuesday–Sunday, so use day >= 2).
int staffFixtureExtensionWeek({
  BalanceConfig balance = BalanceConfig.defaults,
}) => balance.calendar.draftWeek;

// ---------------------------------------------------------------------------
// Requirement 10 regression fixtures
// ---------------------------------------------------------------------------

/// One documented rating regression case.
class StaffRatingCase {
  const StaffRatingCase({
    required this.label,
    required this.role,
    required this.attributes,
    required this.expectedRaw,
  });

  /// Requirement reference, used as the test description.
  final String label;
  final StaffRole role;
  final StaffAttributes attributes;

  /// RawOverall the domain must produce, before any visual rounding.
  final double expectedRaw;

  StaffMember member({int index = 1}) =>
      staffMemberFor(role, attributes: attributes, index: index, name: label);
}

/// Requirement 10.1–10.6: one fixture per role, each with a deliberately high
/// irrelevant attribute so a global average would be visible.
const staffRatingRegressionCases = <StaffRatingCase>[
  StaffRatingCase(
    label: 'Requirement 10.1 headCoach ignores legacy Development',
    role: StaffRole.headCoach,
    attributes: StaffAttributes(
      tactics: 4.0,
      motivation: 2.0,
      development: 5.0,
    ),
    expectedRaw: 3.0,
  ),
  StaffRatingCase(
    label: 'Requirement 10.2 youthCoach ignores Tactics',
    role: StaffRole.youthCoach,
    attributes: StaffAttributes(development: 4.0, mentoring: 2.0, tactics: 5.0),
    expectedRaw: 3.0,
  ),
  StaffRatingCase(
    label: 'Requirement 10.3 scout uses Coverage and Evaluation',
    role: StaffRole.scout,
    attributes: StaffAttributes(coverage: 5.0, evaluation: 4.0),
    expectedRaw: 4.5,
  ),
  StaffRatingCase(
    label: 'Requirement 10.4 physio uses Rehabilitation and regenaration',
    role: StaffRole.physio,
    attributes: StaffAttributes(rehabilitation: 4.0, regenaration: 3.0),
    expectedRaw: 3.5,
  ),
  StaffRatingCase(
    label: 'Requirement 10.5 doctor uses Prevention and Care',
    role: StaffRole.doctor,
    attributes: StaffAttributes(prevention: 2.0, care: 5.0),
    expectedRaw: 3.5,
  ),
  StaffRatingCase(
    label: 'Requirement 10.6 cfo uses Negotiation only',
    role: StaffRole.cfo,
    attributes: StaffAttributes(
      tactics: 5.0,
      motivation: 5.0,
      development: 5.0,
      mentoring: 5.0,
      coverage: 5.0,
      evaluation: 5.0,
      rehabilitation: 5.0,
      regenaration: 5.0,
      prevention: 5.0,
      care: 5.0,
      negotiation: 4.5,
    ),
    expectedRaw: 4.5,
  ),
];
