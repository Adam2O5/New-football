part of '../staff_role_ratings_test_helpers.dart';

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
