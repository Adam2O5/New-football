import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';

import 'helpers/staff_role_ratings_test_helpers.dart';

/// Example and regression tests for the canonical staff rating.
///
/// Every assertion compares production code against the independent oracle in
/// `helpers/staff_role_ratings_test_helpers.dart`, which is transcribed from
/// `docs/staff.md`. The oracle is never derived from `StaffRatingSystem`, so a
/// wrong mapping cannot make both sides agree.
///
/// Covers Requirements 1.1–1.7, 2.1–2.9, 10.1–10.6 and 10.12.
void main() {
  /// Attributes where all eleven fields hold a distinct value (0,0 … 5,0).
  ///
  /// Any key that reads the wrong field therefore returns a different number.
  final distinctAttributes = () {
    var attributes = const StaffAttributes();
    for (var i = 0; i < staffAttributeNames.length; i++) {
      attributes = withStaffAttribute(
        attributes,
        staffAttributeNames[i],
        i * 0.5,
      );
    }
    return attributes;
  }();

  /// Mean of all eleven fields — the bug this feature removes.
  ///
  /// Fixtures are chosen so this value differs from the role rating, which is
  /// what makes a global average visible instead of accidentally passing.
  double allAttributeMean(StaffAttributes attributes) =>
      staffAttributeNames
          .map((name) => staffAttributeByName(attributes, name))
          .reduce((a, b) => a + b) /
      staffAttributeNames.length;

  group('canonical role mapping (Requirements 1.1-1.6, 10.12)', () {
    test('covers exactly the six recognized roles', () {
      expect(
        StaffRatingSystem.roleRelevantAttributes.keys,
        StaffRole.values,
        reason: 'the canonical map must have one entry per recognized role',
      );
    });

    test('headCoach excludes Development (Requirement 10.12)', () {
      final keys = StaffRatingSystem.keysForRole(StaffRole.headCoach);
      expect(keys, [StaffAttributeKey.tactics, StaffAttributeKey.motivation]);
      expect(
        keys,
        isNot(contains(StaffAttributeKey.development)),
        reason: 'legacy headCoach Development is not part of the rating',
      );
    });

    test('physio keeps the serialized spelling regenaration', () {
      expect(StaffRatingSystem.serializedNamesForRole(StaffRole.physio), [
        'rehabilitation',
        'regenaration',
      ]);
    });

    for (final role in StaffRole.values) {
      test(
        '${role.name} projects onto ${relevantStaffAttributeNames(role)}',
        () {
          final expectedNames = relevantStaffAttributeNames(role);

          expect(
            StaffRatingSystem.keysForRole(role).map((key) => key.name).toList(),
            expectedNames,
            reason: 'canonical keys and their order must match docs/staff.md',
          );
          expect(
            StaffRatingSystem.serializedNamesForRole(role),
            expectedNames,
            reason: 'serialized names are the stable identifiers of the keys',
          );
          expect(
            staffMemberFor(role).relevantAttributeKeys,
            StaffRatingSystem.keysForRole(role),
            reason: 'the member accessor must not keep a second mapping',
          );

          for (final name in expectedNames) {
            final key = StaffRatingSystem.keyForSerializedName(name);
            expect(key, isNotNull, reason: '$name must resolve to a key');
            expect(
              StaffRatingSystem.attributeValue(distinctAttributes, key!),
              staffAttributeByName(distinctAttributes, name),
              reason: '$name must read the $name field of StaffAttributes',
            );
          }

          for (final name in irrelevantStaffAttributeNames(role)) {
            expect(
              expectedNames,
              isNot(contains(name)),
              reason: '$name is irrelevant for ${role.name}',
            );
          }
        },
      );
    }
  });

  group('RawOverall formula and scale (Requirements 2.1-2.9)', () {
    for (final role in StaffRole.values) {
      final relevantCount = relevantStaffAttributeNames(role).length;

      test('${role.name} averages exactly its relevant attributes', () {
        final attributes = staffAttributesForRole(
          role,
          List<double>.filled(relevantCount, 3.0),
          irrelevantValue: 5.0,
        );

        expect(attributes.overallForRole(role), 3.0);
        expect(
          attributes.overallForRole(role),
          expectedStaffRawOverall(attributes, role),
        );
        expect(
          attributes.overallForRole(role),
          isNot(closeTo(allAttributeMean(attributes), 0.0001)),
          reason: 'a global all-attribute average must not produce the rating',
        );
      });

      test('${role.name} returns 0,5 for relevant values 0,5 '
          '(Requirement 2.8)', () {
        final attributes = staffAttributesForRole(
          role,
          List<double>.filled(relevantCount, 0.5),
          irrelevantValue: 5.0,
        );

        expect(attributes.overallForRole(role), 0.5);
      });

      test('${role.name} keeps the unrounded quarter value 3,75 '
          '(Requirement 2.9)', () {
        final attributes = role == StaffRole.cfo
            ? staffAttributesForRole(role, const [3.75])
            : staffAttributesForRole(role, const [4.5, 3.0]);

        final raw = attributes.overallForRole(role);
        expect(raw, 3.75);
        expect(raw, isNot(4.0), reason: 'the domain must not round to 0,5');
        expect(raw, expectedStaffRawOverall(attributes, role));
      });

      test('${role.name} clamps out-of-range inputs into 0-5 '
          '(Requirements 2.5, 2.6)', () {
        for (final value in staffOutOfRangeAttributeValues) {
          final attributes = staffAttributesForRole(
            role,
            List<double>.filled(relevantCount, value),
          );
          final raw = attributes.overallForRole(role);

          expect(
            raw,
            expectedStaffRawOverall(attributes, role),
            reason: 'clamping must happen before the mean for $value',
          );
          expect(raw, inInclusiveRange(0.0, 5.0));
        }

        final mixed = staffAttributesForRole(
          role,
          relevantCount == 1 ? const [9.5] : const [-1.5, 9.5],
        );
        expect(mixed.overallForRole(role), relevantCount == 1 ? 5.0 : 2.5);
      });

      test('${role.name} ignores every irrelevant attribute '
          '(Requirements 1.7, 2.3)', () {
        final base = staffAttributesForRole(
          role,
          List<double>.filled(relevantCount, 2.0),
        );
        final expected = base.overallForRole(role);

        for (final name in irrelevantStaffAttributeNames(role)) {
          for (final value in const [0.0, 2.5, 5.0]) {
            final mutated = withIrrelevantStaffAttribute(
              base,
              role,
              value: value,
              name: name,
            );

            expect(
              mutated.overallForRole(role),
              expected,
              reason: '$name = $value must not change the ${role.name} rating',
            );
            expect(
              staffMemberFor(role, attributes: mutated).overall,
              expected,
              reason: 'StaffMember.overall must ignore $name too',
            );
          }
        }
      });
    }

    test('cfo returns Negotiation without averaging (Requirement 2.2)', () {
      final attributes = uniformStaffAttributes(5.0).copyWith(negotiation: 4.5);

      expect(attributes.overallForRole(StaffRole.cfo), 4.5);
    });

    test('StaffMember.overall delegates without a second average '
        '(Requirement 2.4)', () {
      for (final role in StaffRole.values) {
        final member = staffMemberFor(
          role,
          attributes: distinctAttributes,
          name: 'distinct ${role.name}',
        );

        expect(
          member.overall,
          member.attributes.overallForRole(role),
          reason: 'the getter must delegate to the role rating',
        );
        expect(
          member.overall,
          expectedStaffRawOverall(distinctAttributes, role),
        );
        expect(
          member.overall,
          isNot(closeTo(allAttributeMean(distinctAttributes), 0.0001)),
          reason: 'the getter must not average all attributes',
        );
      }
    });
  });

  group('documented regression fixtures (Requirements 10.1-10.6)', () {
    for (final testCase in staffRatingRegressionCases) {
      test(testCase.label, () {
        final member = testCase.member();

        expect(
          testCase.attributes.overallForRole(testCase.role),
          testCase.expectedRaw,
        );
        expect(member.overall, testCase.expectedRaw);
        expect(
          member.overall,
          expectedStaffRawOverall(testCase.attributes, testCase.role),
        );
        expect(
          member.overall,
          isNot(closeTo(allAttributeMean(testCase.attributes), 0.0001)),
          reason: 'this fixture exposes a global average by design',
        );
      });
    }

    test('headCoach Tactics 4,0 / Motivation 2,0 / Development 5,0 rates 3,0 '
        'and Development is inert (Requirement 10.1)', () {
      const attributes = StaffAttributes(
        tactics: 4.0,
        motivation: 2.0,
        development: 5.0,
      );

      expect(attributes.overallForRole(StaffRole.headCoach), 3.0);
      expect(
        attributes
            .copyWith(development: 0.0)
            .overallForRole(StaffRole.headCoach),
        3.0,
        reason: 'changing only Development must not change the rating',
      );
    });

    test('youthCoach Development 4,0 / Mentoring 2,0 / Tactics 5,0 rates 3,0 '
        'and Tactics is inert (Requirement 10.2)', () {
      const attributes = StaffAttributes(
        development: 4.0,
        mentoring: 2.0,
        tactics: 5.0,
      );

      expect(attributes.overallForRole(StaffRole.youthCoach), 3.0);
      expect(
        attributes.copyWith(tactics: 0.0).overallForRole(StaffRole.youthCoach),
        3.0,
        reason: 'changing only Tactics must not change the rating',
      );
    });

    test('scout Coverage 5,0 / Evaluation 4,0 rates 4,5 '
        '(Requirement 10.3)', () {
      const attributes = StaffAttributes(coverage: 5.0, evaluation: 4.0);

      expect(attributes.overallForRole(StaffRole.scout), 4.5);
    });

    test('physio Rehabilitation 4,0 / Regeneration 3,0 rates 3,5 '
        '(Requirement 10.4)', () {
      const attributes = StaffAttributes(
        rehabilitation: 4.0,
        regenaration: 3.0,
      );

      expect(attributes.overallForRole(StaffRole.physio), 3.5);
    });

    test('doctor Prevention 2,0 / Care 5,0 rates 3,5 (Requirement 10.5)', () {
      const attributes = StaffAttributes(prevention: 2.0, care: 5.0);

      expect(attributes.overallForRole(StaffRole.doctor), 3.5);
    });

    test('cfo Negotiation 4,5 with every other attribute 5,0 rates 4,5 '
        '(Requirement 10.6)', () {
      final attributes = uniformStaffAttributes(5.0).copyWith(negotiation: 4.5);

      expect(attributes.overallForRole(StaffRole.cfo), 4.5);
      expect(
        staffMemberFor(StaffRole.cfo, attributes: attributes).overall,
        4.5,
      );
    });
  });
}
