import 'dart:convert';
import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/staff_service.dart';

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
// Canonical oracle (docs/staff.md)
// ---------------------------------------------------------------------------

/// Serialized attribute names in `StaffAttributes` declaration order.
///
/// `regenaration` is the existing serialized spelling of Regeneration and must
/// not be renamed by this feature.
const staffAttributeNames = <String>[
  'tactics',
  'motivation',
  'development',
  'mentoring',
  'coverage',
  'evaluation',
  'rehabilitation',
  'regenaration',
  'prevention',
  'care',
  'negotiation',
];

/// Role → relevant attribute names, transcribed from `docs/staff.md`.
///
/// `headCoach` deliberately excludes `development`: the legacy value may exist
/// in old saves but is not part of the rating.
const staffRelevantAttributeNames = <StaffRole, List<String>>{
  StaffRole.headCoach: ['tactics', 'motivation'],
  StaffRole.youthCoach: ['development', 'mentoring'],
  StaffRole.scout: ['coverage', 'evaluation'],
  StaffRole.physio: ['rehabilitation', 'regenaration'],
  StaffRole.doctor: ['prevention', 'care'],
  StaffRole.cfo: ['negotiation'],
};

/// Relevant attribute names for [role], in canonical presentation order.
List<String> relevantStaffAttributeNames(StaffRole role) =>
    staffRelevantAttributeNames[role]!;

/// Every attribute name that must not influence the rating of [role].
List<String> irrelevantStaffAttributeNames(StaffRole role) {
  final relevant = relevantStaffAttributeNames(role);
  return staffAttributeNames
      .where((name) => !relevant.contains(name))
      .toList(growable: false);
}

/// Reads [name] from [attributes].
///
/// Throws for names outside [staffAttributeNames] so a typo in a fixture fails
/// loudly. Production lookups return `0.0` for an UnknownAttribute; assert that
/// behaviour against [unknownStaffAttributeName] directly.
double staffAttributeByName(StaffAttributes attributes, String name) =>
    switch (name) {
      'tactics' => attributes.tactics,
      'motivation' => attributes.motivation,
      'development' => attributes.development,
      'mentoring' => attributes.mentoring,
      'coverage' => attributes.coverage,
      'evaluation' => attributes.evaluation,
      'rehabilitation' => attributes.rehabilitation,
      'regenaration' => attributes.regenaration,
      'prevention' => attributes.prevention,
      'care' => attributes.care,
      'negotiation' => attributes.negotiation,
      _ => throw ArgumentError.value(name, 'name', 'Unknown staff attribute'),
    };

/// Copy of [attributes] with only [name] set to [value].
StaffAttributes withStaffAttribute(
  StaffAttributes attributes,
  String name,
  double value,
) => switch (name) {
  'tactics' => attributes.copyWith(tactics: value),
  'motivation' => attributes.copyWith(motivation: value),
  'development' => attributes.copyWith(development: value),
  'mentoring' => attributes.copyWith(mentoring: value),
  'coverage' => attributes.copyWith(coverage: value),
  'evaluation' => attributes.copyWith(evaluation: value),
  'rehabilitation' => attributes.copyWith(rehabilitation: value),
  'regenaration' => attributes.copyWith(regenaration: value),
  'prevention' => attributes.copyWith(prevention: value),
  'care' => attributes.copyWith(care: value),
  'negotiation' => attributes.copyWith(negotiation: value),
  _ => throw ArgumentError.value(name, 'name', 'Unknown staff attribute'),
};

/// Oracle for RawOverall: mean of the clamped relevant attributes, or the
/// clamped `Negotiation` value for `cfo`. Never rounded to a star step.
double expectedStaffRawOverall(StaffAttributes attributes, StaffRole role) {
  final values = relevantStaffAttributeNames(role)
      .map((name) => staffAttributeByName(attributes, name).clamp(0.0, 5.0))
      .toList(growable: false);
  final mean = values.reduce((a, b) => a + b) / values.length;
  return mean.clamp(0.0, 5.0).toDouble();
}

/// Oracle for DisplayedRating: clamp to 0–5, then round half-up to 0,5.
double expectedStaffDisplayedRating(double raw) {
  final bounded = raw.clamp(0.0, 5.0).toDouble();
  return (bounded * 2 + 0.5).floor() / 2;
}

/// Oracle for the five graphic segments derived from [raw].
///
/// `full + half + empty` is always 5, and `half` is at most 1.
({int full, int half, int empty}) expectedStaffStarCounts(double raw) {
  final displayed = expectedStaffDisplayedRating(raw);
  final full = displayed.floor();
  final half = displayed - full >= 0.5 ? 1 : 0;
  return (full: full, half: half, empty: 5 - full - half);
}

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

// ---------------------------------------------------------------------------
// Raw persisted JSON fixtures
// ---------------------------------------------------------------------------

/// Compatibility cases a persisted staff record can be in.
enum StaffJsonCase {
  /// Fully populated, recognized record.
  valid,

  /// Recognized role, but a relevant attribute key is absent (legacy save).
  missingRelevantAttribute,

  /// Recognized role plus an attribute key the model does not declare.
  unknownAttribute,

  /// Role identifier outside `StaffRole`.
  unknownRole,
}

/// Raw attribute map.
///
/// [omit] removes keys so the generated decoder falls back to `0.0`, and
/// [extra] adds names the model does not declare.
Map<String, dynamic> staffAttributesJson(
  StaffAttributes attributes, {
  Set<String> omit = const {},
  Map<String, double> extra = const {},
}) => <String, dynamic>{
  for (final name in staffAttributeNames)
    if (!omit.contains(name)) name: staffAttributeByName(attributes, name),
  ...extra,
};

/// Raw persisted staff record.
///
/// [rawRole] overrides the serialized role with an arbitrary string, which is
/// how an UnknownRole reaches the loader before the generated decoder runs.
Map<String, dynamic> staffMemberJson({
  StaffRole role = StaffRole.headCoach,
  String? rawRole,
  String? id,
  int index = 1,
  String? name,
  Nationality nationality = Nationality.poland,
  int age = 45,
  StaffAttributes? attributes,
  Set<String> omitAttributes = const {},
  Map<String, double> extraAttributes = const {},
  StaffContract? contract,
  StaffAttributes? previousAttributes,
}) => <String, dynamic>{
  'id': id ?? staffFixtureId(role, index),
  'name': name ?? '${rawRole ?? role.name} #$index',
  'nationality': nationality.name,
  'age': age,
  'role': rawRole ?? role.name,
  'attributes': staffAttributesJson(
    attributes ?? staffAttributesWithRawOverall(role, 3.0),
    omit: omitAttributes,
    extra: extraAttributes,
  ),
  'contract': contract == null
      ? null
      : <String, dynamic>{
          'salary': contract.salary,
          'yearsRemaining': contract.yearsRemaining,
        },
  'previousAttributes': previousAttributes == null
      ? null
      : staffAttributesJson(previousAttributes),
};

/// Raw record for one [StaffJsonCase].
Map<String, dynamic> staffJsonRecord(
  StaffJsonCase kind, {
  StaffRole role = StaffRole.headCoach,
  int index = 1,
  StaffContract? contract,
}) => switch (kind) {
  StaffJsonCase.valid => staffMemberJson(
    role: role,
    index: index,
    contract: contract,
  ),
  StaffJsonCase.missingRelevantAttribute => staffMemberJson(
    role: role,
    index: index,
    contract: contract,
    omitAttributes: {relevantStaffAttributeNames(role).first},
  ),
  StaffJsonCase.unknownAttribute => staffMemberJson(
    role: role,
    index: index,
    contract: contract,
    extraAttributes: const {unknownStaffAttributeName: 4.0},
  ),
  StaffJsonCase.unknownRole => staffMemberJson(
    role: role,
    rawRole: unknownStaffRoleValue,
    index: index,
    contract: contract,
  ),
};

/// Raw `TeamStaff` map. Roles absent from [slots] stay `null`, i.e. EmptySlot.
///
/// Any record may be placed in any slot, which is how a role/slot mismatch is
/// built: `teamStaffJson({StaffRole.headCoach: staffMemberJson(role:
/// StaffRole.scout)})`.
Map<String, dynamic> teamStaffJson(
  Map<StaffRole, Map<String, dynamic>?> slots,
) => <String, dynamic>{
  for (final role in StaffRole.values) role.name: slots[role],
};

/// Raw staff data covering every compatibility case at once: valid records, a
/// missing relevant attribute, an UnknownAttribute, an EmptySlot, a role/slot
/// mismatch and an UnknownRole free agent.
({
  Map<String, dynamic> teamStaff,
  List<Map<String, dynamic>> freeAgents,
  List<String> validIds,
  List<String> invalidIds,
})
mixedStaffJson() {
  final valid = staffJsonRecord(
    StaffJsonCase.valid,
    role: StaffRole.headCoach,
    contract: staffFixtureContract(),
  );
  final missing = staffJsonRecord(
    StaffJsonCase.missingRelevantAttribute,
    role: StaffRole.scout,
  );
  final unknownAttribute = staffJsonRecord(
    StaffJsonCase.unknownAttribute,
    role: StaffRole.doctor,
  );
  final mismatched = staffMemberJson(
    role: StaffRole.youthCoach,
    index: 2,
    id: staffFixtureId(StaffRole.physio, 2),
  );
  final unknownRole = staffJsonRecord(
    StaffJsonCase.unknownRole,
    role: StaffRole.cfo,
    index: 3,
  );
  final validFreeAgent = staffJsonRecord(
    StaffJsonCase.valid,
    role: StaffRole.youthCoach,
    index: 4,
  );
  return (
    teamStaff: teamStaffJson({
      StaffRole.headCoach: valid,
      StaffRole.scout: missing,
      StaffRole.doctor: unknownAttribute,
      StaffRole.physio: mismatched,
      StaffRole.cfo: unknownRole,
    }),
    freeAgents: [validFreeAgent, unknownRole],
    validIds: [
      valid['id'] as String,
      missing['id'] as String,
      unknownAttribute['id'] as String,
      validFreeAgent['id'] as String,
    ],
    invalidIds: [mismatched['id'] as String, unknownRole['id'] as String],
  );
}

/// Pure JSON tree for [save].
///
/// `toJson` on a freezed model keeps nested models as objects, so a raw-map
/// test has to round-trip through [jsonEncode] first.
Map<String, dynamic> decodedSaveJson(GameSave save) =>
    jsonDecode(jsonEncode(save.toJson())) as Map<String, dynamic>;

/// Copy of a serialized save with raw staff data injected.
///
/// Only the staff subtree of [teamId] and the raw free-agent list change; the
/// rest of the save, including `schemaVersion`, is left untouched.
Map<String, dynamic> withRawStaffJson(
  Map<String, dynamic> saveJson, {
  String teamId = staffFixtureTeamId,
  Map<String, dynamic>? teamStaff,
  List<Map<String, dynamic>>? staffFreeAgents,
}) {
  final copy = jsonDecode(jsonEncode(saveJson)) as Map<String, dynamic>;
  final league = copy['leagueState'] as Map<String, dynamic>;
  if (teamStaff != null) {
    final teams = (league['teams'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final team = teams.firstWhere(
      (item) => item['id'] == teamId,
      orElse: () => throw ArgumentError.value(
        teamId,
        'teamId',
        'Not present in the serialized league',
      ),
    );
    team['staff'] = teamStaff;
  }
  if (staffFreeAgents != null) {
    league['staffFreeAgents'] = staffFreeAgents;
  }
  return copy;
}
