@Tags(['property'])
library;

// Feature: staff-role-ratings, Property 2: RawOverall jest średnią roli
// i jest ograniczony.
//
// Deterministic property-like coverage of the RawOverall contract. No
// property-based testing library is used: every case comes from a seeded
// `Random` or from an exhaustive value sweep, so a failure always replays.
//
// Production code is compared against the independent oracle in
// `helpers/staff_role_ratings_test_helpers.dart`, never the other way round.

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

const _propertyTag =
    'Feature: staff-role-ratings, Property 2: RawOverall jest średnią roli '
    'i jest ograniczony';

/// Generated cases per recognized role. The plan requires at least 100.
const _casesPerRole = 120;

void main() {
  group(_propertyTag, () {
    _groupRoleMean();
    _groupExhaustiveSweep();
    _groupIrrelevantInvariance();
    _groupClampOrder();
    _groupUnroundedRaw();
    _groupDocumentedRegressions();
  });
}

// ---------------------------------------------------------------------------
// Property 2a: the formula is the mean of exactly the relevant clamped values
// ---------------------------------------------------------------------------

/// **Validates: Requirements 2.1, 2.2, 2.4, 2.5, 2.6**
void _groupRoleMean() {
  group('rawOverall is the clamped role mean', () {
    for (final role in StaffRole.values) {
      test('${role.name}: $_casesPerRole generated attribute sets', () {
        final random = staffFixtureRandom(_seedFor(role));
        final names = relevantStaffAttributeNames(role);
        var discriminating = 0;

        for (var i = 0; i < _casesPerRole; i++) {
          final attributes = randomStaffAttributes(
            random,
            includeOutOfRange: true,
          );
          final oracle = expectedStaffRawOverall(attributes, role);
          final inline = _inlineFormula(attributes, role);
          final member = staffMemberFor(
            role,
            attributes: attributes,
            index: i + 1,
          );
          final raw = StaffRatingSystem.rawOverall(attributes, role);

          expect(
            inline,
            oracle,
            reason: _reason(
              'case $i: the two oracles disagree, the fixture is wrong',
              role,
              attributes,
              expected: oracle,
              actual: inline,
            ),
          );
          expect(
            raw,
            oracle,
            reason: _reason(
              'case $i: StaffRatingSystem.rawOverall is not '
              '${names.length == 1 ? 'clamp(negotiation)' : 'mean(clamp(a), clamp(b))'}',
              role,
              attributes,
              expected: oracle,
              actual: raw,
            ),
          );
          expect(
            attributes.overallForRole(role),
            oracle,
            reason: _reason(
              'case $i: overallForRole diverged from the canonical map',
              role,
              attributes,
              expected: oracle,
              actual: attributes.overallForRole(role),
            ),
          );
          expect(
            member.overall,
            oracle,
            reason: _reason(
              'case $i: StaffMember.overall is not a thin delegation',
              role,
              attributes,
              expected: oracle,
              actual: member.overall,
            ),
          );
          expect(
            raw,
            inInclusiveRange(
              StaffRatingSystem.minRating,
              StaffRatingSystem.maxRating,
            ),
            reason: _reason(
              'case $i: raw left the inclusive 0–5 range',
              role,
              attributes,
              expected: '0.0 <= raw <= 5.0',
              actual: raw,
            ),
          );

          if (_allAttributeMean(attributes) != oracle) discriminating++;
        }

        // Without at least one such case the loop could not detect a
        // regression back to the all-attribute average.
        expect(
          discriminating,
          greaterThan(0),
          reason:
              '$_propertyTag\n${role.name}: no generated case separated the '
              'role mean from the all-attribute average',
        );
      });
    }
  });

  test('StaffMember.overall never averages every attribute', () {
    for (final role in StaffRole.values) {
      final attributes = staffAttributesWithRawOverall(
        role,
        1.0,
        irrelevantValue: 5.0,
      );
      final member = staffMemberFor(role, attributes: attributes);
      final globalMean = _allAttributeMean(attributes);

      expect(
        member.overall,
        1.0,
        reason: _reason(
          'relevant attributes at 1,0 must give raw 1,0',
          role,
          attributes,
          expected: 1.0,
          actual: member.overall,
        ),
      );
      expect(
        member.overall,
        isNot(globalMean),
        reason: _reason(
          'raw equals the all-attribute average, the second averaging is back',
          role,
          attributes,
          expected: 'anything but $globalMean',
          actual: member.overall,
        ),
      );
    }
  });
}

// ---------------------------------------------------------------------------
// Property 2b: exhaustive relevant-value sweep, including both clamp edges
// ---------------------------------------------------------------------------

/// **Validates: Requirements 2.1, 2.2, 2.5, 2.6**
void _groupExhaustiveSweep() {
  group('rawOverall stays inside the inclusive 0–5 range', () {
    for (final role in StaffRole.values) {
      test('${role.name}: exhaustive relevant-value sweep', () {
        var attained = <double>{};
        for (final combo in _sweepCases(role)) {
          final attributes = combo.attributes;
          final oracle = expectedStaffRawOverall(attributes, role);
          final raw = StaffRatingSystem.rawOverall(attributes, role);

          expect(
            raw,
            oracle,
            reason: _reason(
              'sweep ${combo.label}: raw diverged from the oracle',
              role,
              attributes,
              expected: oracle,
              actual: raw,
            ),
          );
          expect(
            raw,
            inInclusiveRange(
              StaffRatingSystem.minRating,
              StaffRatingSystem.maxRating,
            ),
            reason: _reason(
              'sweep ${combo.label}: raw left the inclusive 0–5 range',
              role,
              attributes,
              expected: '0.0 <= raw <= 5.0',
              actual: raw,
            ),
          );
          attained.add(raw);
        }

        // The range is inclusive: both bounds must be reachable, not merely
        // approached.
        expect(
          attained,
          containsAll(<double>[
            StaffRatingSystem.minRating,
            StaffRatingSystem.maxRating,
          ]),
          reason:
              '$_propertyTag\n${role.name}: the sweep never produced 0,0 and '
              '5,0, so the bounds are not inclusive',
        );
      });
    }
  });
}

// ---------------------------------------------------------------------------
// Property 2c: irrelevant fields cannot move the rating
// ---------------------------------------------------------------------------

/// **Validates: Requirements 1.7, 2.3, 2.4**
void _groupIrrelevantInvariance() {
  group('irrelevant attributes leave rawOverall unchanged', () {
    for (final role in StaffRole.values) {
      test('${role.name}: $_casesPerRole mutated attribute sets', () {
        final random = staffFixtureRandom(_seedFor(role) + 7);
        final irrelevant = irrelevantStaffAttributeNames(role);
        final relevant = relevantStaffAttributeNames(role);

        for (var i = 0; i < _casesPerRole; i++) {
          final base = randomStaffAttributes(random, includeOutOfRange: true);
          final baseRaw = StaffRatingSystem.rawOverall(base, role);
          final baseMember = staffMemberFor(
            role,
            attributes: base,
            index: i + 1,
          );

          for (final name in irrelevant) {
            final value =
                staffExtendedAttributeValues[random.nextInt(
                  staffExtendedAttributeValues.length,
                )];
            final mutated = withIrrelevantStaffAttribute(
              base,
              role,
              value: value,
              name: name,
            );
            final mutatedMember = baseMember.copyWith(attributes: mutated);

            for (final relevantName in relevant) {
              expect(
                staffAttributeByName(mutated, relevantName),
                staffAttributeByName(base, relevantName),
                reason: _reason(
                  'case $i: mutating $name changed relevant $relevantName, '
                  'the fixture is wrong',
                  role,
                  mutated,
                  expected: staffAttributeByName(base, relevantName),
                  actual: staffAttributeByName(mutated, relevantName),
                ),
              );
            }
            expect(
              StaffRatingSystem.rawOverall(mutated, role),
              baseRaw,
              reason: _reason(
                'case $i: irrelevant $name = $value changed rawOverall',
                role,
                mutated,
                expected: baseRaw,
                actual: StaffRatingSystem.rawOverall(mutated, role),
              ),
            );
            expect(
              mutatedMember.overall,
              baseRaw,
              reason: _reason(
                'case $i: irrelevant $name = $value changed '
                'StaffMember.overall',
                role,
                mutated,
                expected: baseRaw,
                actual: mutatedMember.overall,
              ),
            );
          }
        }
      });
    }
  });
}

// ---------------------------------------------------------------------------
// Property 2d: each input is clamped before the mean, not after
// ---------------------------------------------------------------------------

/// **Validates: Requirements 2.5, 2.6**
void _groupClampOrder() {
  // (first relevant, second relevant, expected raw). A late clamp would
  // average the raw inputs first and produce a different value.
  const pairs = <(double, double, double)>[
    (-4.0, 6.0, 2.5),
    (-1.5, 3.0, 1.5),
    (5.25, 2.0, 3.5),
    (9.5, -0.5, 2.5),
    (-4.0, -1.5, 0.0),
    (6.0, 9.5, 5.0),
  ];

  test('two-attribute roles clamp both inputs before averaging', () {
    for (final role in StaffRole.values) {
      if (relevantStaffAttributeNames(role).length == 1) continue;
      for (final (first, second, expected) in pairs) {
        final attributes = staffAttributesForRole(role, [
          first,
          second,
        ], irrelevantValue: 5.0);
        final raw = StaffRatingSystem.rawOverall(attributes, role);
        final lateClamp = ((first + second) / 2)
            .clamp(StaffRatingSystem.minRating, StaffRatingSystem.maxRating)
            .toDouble();

        expect(
          raw,
          expected,
          reason: _reason(
            'clamp order: inputs ($first, $second) must clamp before the mean',
            role,
            attributes,
            expected: expected,
            actual: raw,
            extra: 'a late clamp would return $lateClamp',
          ),
        );
        expect(
          expectedStaffRawOverall(attributes, role),
          expected,
          reason: _reason(
            'clamp order: the oracle itself is wrong for ($first, $second)',
            role,
            attributes,
            expected: expected,
            actual: expectedStaffRawOverall(attributes, role),
          ),
        );
      }
    }
  });

  test('cfo clamps Negotiation without averaging any other field', () {
    const cases = <(double, double)>[
      (-4.0, 0.0),
      (-0.5, 0.0),
      (0.0, 0.0),
      (0.5, 0.5),
      (4.5, 4.5),
      (5.0, 5.0),
      (5.25, 5.0),
      (9.5, 5.0),
    ];
    for (final (negotiation, expected) in cases) {
      for (final irrelevantValue in staffExtendedAttributeValues) {
        final attributes = staffAttributesForRole(StaffRole.cfo, [
          negotiation,
        ], irrelevantValue: irrelevantValue);
        final raw = StaffRatingSystem.rawOverall(attributes, StaffRole.cfo);
        expect(
          raw,
          expected,
          reason: _reason(
            'cfo raw must be clamp(negotiation) alone',
            StaffRole.cfo,
            attributes,
            expected: expected,
            actual: raw,
            extra: 'every other field is $irrelevantValue',
          ),
        );
      }
    }
  });
}

// ---------------------------------------------------------------------------
// Property 2e: the domain keeps the unrounded value
// ---------------------------------------------------------------------------

/// **Validates: Requirements 2.7, 2.8, 2.9**
void _groupUnroundedRaw() {
  test('quarter raw values are not rounded to a star step', () {
    for (final role in StaffRole.values) {
      final twoAttributes = relevantStaffAttributeNames(role).length == 2;
      for (final raw in staffQuarterRawValues) {
        final spreads = twoAttributes
            ? <double>[0.0, 0.25].where((s) => raw - s >= 0.0 && raw + s <= 5.0)
            : <double>[0.0];
        for (final spread in spreads) {
          final attributes = staffAttributesWithRawOverall(
            role,
            raw,
            spread: spread,
            irrelevantValue: 5.0,
          );
          final member = staffMemberFor(role, attributes: attributes);
          final displayed = expectedStaffDisplayedRating(raw);

          expect(
            member.overall,
            raw,
            reason: _reason(
              'spread $spread: the domain must expose the unrounded raw value',
              role,
              attributes,
              expected: raw,
              actual: member.overall,
            ),
          );
          expect(
            member.overall,
            isNot(displayed),
            reason: _reason(
              'spread $spread: the domain returned the DisplayedRating',
              role,
              attributes,
              expected: raw,
              actual: member.overall,
              extra: 'DisplayedRating for $raw is $displayed',
            ),
          );
        }
      }
    }
  });

  test('Requirement 2.9: 4,5 and 3,0 stay 3,75 in the domain', () {
    for (final role in StaffRole.values) {
      if (relevantStaffAttributeNames(role).length == 1) continue;
      final attributes = staffAttributesForRole(role, [
        4.5,
        3.0,
      ], irrelevantValue: 5.0);
      final raw = staffMemberFor(role, attributes: attributes).overall;
      expect(
        raw,
        3.75,
        reason: _reason(
          'Requirement 2.9: mean of 4,5 and 3,0 must stay 3,75',
          role,
          attributes,
          expected: 3.75,
          actual: raw,
          extra: 'visual rounding would report 4,0',
        ),
      );
      expect(
        raw,
        isNot(4.0),
        reason: _reason(
          'Requirement 2.9: raw was rounded up to 4,0',
          role,
          attributes,
          expected: 3.75,
          actual: raw,
        ),
      );
    }
  });

  test('Requirement 2.8: 0,5 and 0,5 stay 0,5', () {
    for (final role in StaffRole.values) {
      final relevantValues = relevantStaffAttributeNames(role).length == 1
          ? <double>[0.5]
          : <double>[0.5, 0.5];
      final attributes = staffAttributesForRole(
        role,
        relevantValues,
        irrelevantValue: 5.0,
      );
      final raw = staffMemberFor(role, attributes: attributes).overall;
      expect(
        raw,
        0.5,
        reason: _reason(
          'Requirement 2.8: relevant attributes at 0,5 must give raw 0,5',
          role,
          attributes,
          expected: 0.5,
          actual: raw,
        ),
      );
    }
  });
}

// ---------------------------------------------------------------------------
// Property 2f: documented regressions hold under irrelevant mutation
// ---------------------------------------------------------------------------

/// **Validates: Requirements 1.7, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6**
void _groupDocumentedRegressions() {
  group('documented raw values survive irrelevant mutation', () {
    for (final ratingCase in staffRatingRegressionCases) {
      test(ratingCase.label, () {
        final role = ratingCase.role;
        final member = ratingCase.member();

        expect(
          expectedStaffRawOverall(ratingCase.attributes, role),
          ratingCase.expectedRaw,
          reason: _reason(
            'the oracle disagrees with the documented value',
            role,
            ratingCase.attributes,
            expected: ratingCase.expectedRaw,
            actual: expectedStaffRawOverall(ratingCase.attributes, role),
          ),
        );
        expect(
          member.overall,
          ratingCase.expectedRaw,
          reason: _reason(
            'documented raw value not reproduced',
            role,
            ratingCase.attributes,
            expected: ratingCase.expectedRaw,
            actual: member.overall,
          ),
        );

        final random = staffFixtureRandom(_seedFor(role) + 13);
        final irrelevant = irrelevantStaffAttributeNames(role);
        for (var i = 0; i < _casesPerRole; i++) {
          final name = irrelevant[i % irrelevant.length];
          final value =
              staffExtendedAttributeValues[random.nextInt(
                staffExtendedAttributeValues.length,
              )];
          final mutated = withStaffAttribute(
            ratingCase.attributes,
            name,
            value,
          );
          final mutatedRaw = StaffRatingSystem.rawOverall(mutated, role);

          expect(
            mutatedRaw,
            ratingCase.expectedRaw,
            reason: _reason(
              'case $i: irrelevant $name = $value changed the documented raw '
              'value',
              role,
              mutated,
              expected: ratingCase.expectedRaw,
              actual: mutatedRaw,
            ),
          );
          expect(
            member.copyWith(attributes: mutated).overall,
            ratingCase.expectedRaw,
            reason: _reason(
              'case $i: irrelevant $name = $value changed '
              'StaffMember.overall',
              role,
              mutated,
              expected: ratingCase.expectedRaw,
              actual: member.copyWith(attributes: mutated).overall,
            ),
          );
        }
      });
    }
  });
}

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------

/// One sweep case: the attributes plus a label for the failure message.
class _SweepCase {
  const _SweepCase(this.attributes, this.label);

  final StaffAttributes attributes;
  final String label;
}

/// Every combination of extended relevant values for [role].
///
/// Two-attribute roles cross both relevant fields; single-attribute roles
/// cross the relevant field with the shared irrelevant value, so each role
/// gets far more than the 100 required cases and both clamp edges appear.
List<_SweepCase> _sweepCases(StaffRole role) {
  final singleAttribute = relevantStaffAttributeNames(role).length == 1;
  final cases = <_SweepCase>[];
  for (final first in staffExtendedAttributeValues) {
    for (final second in staffExtendedAttributeValues) {
      cases.add(
        _SweepCase(
          staffAttributesForRole(
            role,
            singleAttribute ? [first] : [first, second],
            irrelevantValue: second,
          ),
          singleAttribute
              ? 'relevant=$first irrelevant=$second'
              : 'relevant=($first, $second)',
        ),
      );
    }
  }
  return cases;
}

/// Formula straight from Requirement 2.1/2.2, written inline so the assertion
/// does not depend on the shared oracle alone.
double _inlineFormula(StaffAttributes attributes, StaffRole role) {
  final names = relevantStaffAttributeNames(role);
  double clamped(String name) => staffAttributeByName(
    attributes,
    name,
  ).clamp(StaffRatingSystem.minRating, StaffRatingSystem.maxRating).toDouble();
  return names.length == 1
      ? clamped(names.first)
      : (clamped(names[0]) + clamped(names[1])) / 2;
}

/// Average of all eleven fields — the regression this property rules out.
double _allAttributeMean(StaffAttributes attributes) =>
    staffAttributeNames
        .map((name) => staffAttributeByName(attributes, name))
        .reduce((a, b) => a + b) /
    staffAttributeNames.length;

/// Per-role seed so each role replays its own independent case stream.
int _seedFor(StaffRole role) => staffFixtureSeed + role.index * 1000;

/// Failure message carrying the role, the inputs and expected/actual.
String _reason(
  String what,
  StaffRole role,
  StaffAttributes attributes, {
  required Object expected,
  required Object actual,
  String? extra,
}) {
  final relevant = relevantStaffAttributeNames(
    role,
  ).map((name) => '$name=${staffAttributeByName(attributes, name)}').join(', ');
  final all = staffAttributeNames
      .map((name) => '$name=${staffAttributeByName(attributes, name)}')
      .join(', ');
  return [
    _propertyTag,
    what,
    'role=${role.name}',
    'relevant=[$relevant]',
    'attributes=[$all]',
    'expected=$expected',
    'actual=$actual',
    ?extra,
  ].join('\n');
}
