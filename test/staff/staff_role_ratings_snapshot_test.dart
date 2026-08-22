import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/development_snapshot.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

/// Unit and edge tests for the staff development snapshot.
///
/// The snapshot is the second place that used to know "which attributes belong
/// to this role". These tests hold it to the canonical map by comparing it
/// against the independent oracle in
/// `helpers/staff_role_ratings_test_helpers.dart`, which is transcribed from
/// `docs/staff.md`. Production is always the left-hand side of an expectation;
/// the oracle is never derived from `StaffRatingSystem`.
///
/// The interesting failures are the ones where current values look right but
/// something else is wrong: a name list containing the legacy `headCoach`
/// `development` field, a renamed `regenaration`, deltas taken against the
/// wrong attribute, or an EmptySlot rendered as an occupied member.
///
/// Covers Requirements 3.1–3.10, 9.1, 9.6 and 10.12.
void main() {
  /// Attributes where all eleven fields hold a distinct value (0,0 … 5,0).
  ///
  /// Any lookup that reads the wrong field returns a different number, so a
  /// mis-ordered or mis-mapped snapshot cannot pass by coincidence.
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

  /// Same eleven fields, each 0,25 lower than [distinctAttributes] except the
  /// first, which is 0,5 higher. Deltas are therefore distinct, non-zero and
  /// signed, so a delta computed against the wrong attribute is visible.
  final previousAttributes = () {
    var attributes = distinctAttributes;
    for (var i = 0; i < staffAttributeNames.length; i++) {
      final name = staffAttributeNames[i];
      final current = staffAttributeByName(distinctAttributes, name);
      attributes = withStaffAttribute(
        attributes,
        name,
        i == 0 ? current + 0.5 : (current - 0.25).clamp(0.0, 5.0).toDouble(),
      );
    }
    return attributes;
  }();

  /// Oracle current values of [role] read straight from [attributes].
  List<double> expectedCurrentValues(
    StaffAttributes attributes,
    StaffRole role,
  ) => relevantStaffAttributeNames(role)
      .map((name) => staffAttributeByName(attributes, name))
      .toList(growable: false);

  /// Oracle deltas of [role] between two attribute sets.
  List<double> expectedDeltas(
    StaffAttributes current,
    StaffAttributes previous,
    StaffRole role,
  ) => relevantStaffAttributeNames(role)
      .map(
        (name) =>
            staffAttributeByName(current, name) -
            staffAttributeByName(previous, name),
      )
      .toList(growable: false);

  group('canonical attribute names (Requirements 3.1-3.6, 10.12)', () {
    for (final role in StaffRole.values) {
      test(
        '${role.name} snapshot lists ${relevantStaffAttributeNames(role)}',
        () {
          final expectedNames = relevantStaffAttributeNames(role);
          final snapshot = StaffDevelopmentSnapshot.forSlot(
            role,
            staffMemberFor(role, attributes: distinctAttributes),
          );

          expect(
            snapshot.attributeNames,
            expectedNames,
            reason:
                'the snapshot must project the canonical map for ${role.name}',
          );
          expect(
            snapshot.attributeNames,
            attributesForRole(role),
            reason: 'the DTO must not keep a name list of its own',
          );
          expect(
            snapshot.currentValues,
            hasLength(expectedNames.length),
            reason: 'values must line up with the names',
          );
          expect(
            snapshot.deltas,
            hasLength(expectedNames.length),
            reason: 'deltas must line up with the names',
          );

          for (final name in irrelevantStaffAttributeNames(role)) {
            expect(
              snapshot.attributeNames,
              isNot(contains(name)),
              reason: '$name is irrelevant for ${role.name}',
            );
          }
        },
      );
    }

    test('headCoach snapshot never contains development '
        '(Requirements 3.1, 10.12)', () {
      const attributes = StaffAttributes(
        tactics: 4.0,
        motivation: 2.0,
        development: 5.0,
      );
      final snapshot = StaffDevelopmentSnapshot.forSlot(
        StaffRole.headCoach,
        staffMemberFor(StaffRole.headCoach, attributes: attributes),
      );

      expect(snapshot.attributeNames, const ['tactics', 'motivation']);
      expect(
        snapshot.attributeNames,
        isNot(contains('development')),
        reason:
            'the legacy headCoach Development field is not part of the '
            'snapshot',
      );
      expect(
        snapshot.currentValues,
        const [4.0, 2.0],
        reason: 'a third value would mean the legacy field is still read',
      );
      expect(
        snapshot.currentValues,
        isNot(contains(attributes.development)),
        reason: 'Development = 5,0 must not appear in the snapshot',
      );
    });

    test('physio snapshot reads the existing regenaration field '
        '(Requirement 3.4)', () {
      final snapshot = StaffDevelopmentSnapshot.forSlot(
        StaffRole.physio,
        staffMemberFor(StaffRole.physio, attributes: distinctAttributes),
      );

      expect(snapshot.attributeNames, const ['rehabilitation', 'regenaration']);
      expect(
        snapshot.attributeNames,
        isNot(contains('regeneration')),
        reason: 'the serialized spelling must not be renamed by this feature',
      );
      expect(
        snapshot.currentValues[1],
        distinctAttributes.regenaration,
        reason: 'regenaration must read the regenaration field verbatim',
      );
      expect(
        snapshot.currentValues[1],
        isNot(distinctAttributes.rehabilitation),
        reason: 'the fixture keeps the two physio fields distinct',
      );
    });

    test('cfo snapshot lists Negotiation alone (Requirement 3.6)', () {
      final snapshot = StaffDevelopmentSnapshot.forSlot(
        StaffRole.cfo,
        staffMemberFor(StaffRole.cfo, attributes: distinctAttributes),
      );

      expect(snapshot.attributeNames, const ['negotiation']);
      expect(snapshot.currentValues, [distinctAttributes.negotiation]);
    });
  });

  group('attribute value lookup (Requirements 3.7, 3.8)', () {
    test('every recognized name reads its own field', () {
      for (final name in staffAttributeNames) {
        expect(
          staffAttributeValue(distinctAttributes, name),
          staffAttributeByName(distinctAttributes, name),
          reason: '"$name" must read the $name field of StaffAttributes',
        );
      }
    });

    test('an UnknownAttribute returns 0,0 and does not throw '
        '(Requirement 3.8)', () {
      final attributes = uniformStaffAttributes(5.0);

      for (final name in const [
        unknownStaffAttributeName,
        'regeneration',
        'overall',
        '',
      ]) {
        expect(
          () => staffAttributeValue(attributes, name),
          returnsNormally,
          reason: 'an unknown name must never throw',
        );
        expect(
          staffAttributeValue(attributes, name),
          0.0,
          reason: '"$name" is not declared by StaffAttributes',
        );
      }
    });
  });

  group('occupied slot (Requirements 3.7, 3.10)', () {
    for (final role in StaffRole.values) {
      test('${role.name} reports current role-relevant values', () {
        final member = staffMemberFor(role, attributes: distinctAttributes);
        final snapshot = StaffDevelopmentSnapshot.forSlot(role, member);

        expect(snapshot.role, role);
        expect(snapshot.member, member);
        expect(snapshot.isEmptySlot, isFalse);
        expect(
          snapshot.currentValues,
          expectedCurrentValues(distinctAttributes, role),
          reason: 'values must be the persisted role-relevant fields',
        );
      });

      test('${role.name} ignores every irrelevant attribute '
          '(Requirements 3.1-3.6)', () {
        final base = staffAttributesForRole(
          role,
          List<double>.filled(relevantStaffAttributeNames(role).length, 2.0),
        );
        final expected = StaffDevelopmentSnapshot.forSlot(
          role,
          staffMemberFor(role, attributes: base),
        );

        for (final name in irrelevantStaffAttributeNames(role)) {
          final mutated = withIrrelevantStaffAttribute(
            base,
            role,
            value: 5.0,
            name: name,
          );
          final snapshot = StaffDevelopmentSnapshot.forSlot(
            role,
            staffMemberFor(role, attributes: mutated),
          );

          expect(
            snapshot.attributeNames,
            expected.attributeNames,
            reason: '$name = 5,0 must not change the ${role.name} names',
          );
          expect(
            snapshot.currentValues,
            expected.currentValues,
            reason: '$name = 5,0 must not change the ${role.name} values',
          );
        }
      });
    }
  });

  group('deltas for an occupied member (Requirement 3.10)', () {
    for (final role in StaffRole.values) {
      test('${role.name} subtracts previousAttributes field by field', () {
        final member = staffMemberFor(
          role,
          attributes: distinctAttributes,
          previousAttributes: previousAttributes,
        );
        final snapshot = StaffDevelopmentSnapshot.forSlot(role, member);

        expect(
          snapshot.currentValues,
          expectedCurrentValues(distinctAttributes, role),
          reason: 'previous data must not disturb the current values',
        );
        expect(
          snapshot.deltas,
          expectedDeltas(distinctAttributes, previousAttributes, role),
          reason: 'each delta must use its own attribute on both sides',
        );
        expect(
          snapshot.deltas,
          everyElement(isNotNull),
          reason: 'previousAttributes is present for this fixture',
        );
      });
    }

    test('a grown attribute reports a positive delta and an unchanged one '
        'reports zero', () {
      const previous = StaffAttributes(coverage: 2.5, evaluation: 3.0);
      const current = StaffAttributes(coverage: 4.0, evaluation: 3.0);
      final snapshot = StaffDevelopmentSnapshot.forSlot(
        StaffRole.scout,
        staffMemberFor(
          StaffRole.scout,
          attributes: current,
          previousAttributes: previous,
        ),
      );

      expect(snapshot.attributeNames, const ['coverage', 'evaluation']);
      expect(snapshot.currentValues, const [4.0, 3.0]);
      expect(snapshot.deltas.first, closeTo(1.5, 1e-9));
      expect(snapshot.deltas.last, closeTo(0.0, 1e-9));
    });

    test('a dropped attribute reports a negative delta', () {
      const previous = StaffAttributes(prevention: 3.0, care: 4.5);
      const current = StaffAttributes(prevention: 2.0, care: 4.5);
      final snapshot = StaffDevelopmentSnapshot.forSlot(
        StaffRole.doctor,
        staffMemberFor(
          StaffRole.doctor,
          attributes: current,
          previousAttributes: previous,
        ),
      );

      expect(snapshot.deltas.first, closeTo(-1.0, 1e-9));
      expect(snapshot.deltas.last, closeTo(0.0, 1e-9));
    });

    test('a legacy headCoach Development change produces no delta '
        '(Requirements 3.1, 10.12)', () {
      const previous = StaffAttributes(
        tactics: 3.0,
        motivation: 2.5,
        development: 0.0,
      );
      const current = StaffAttributes(
        tactics: 3.0,
        motivation: 2.5,
        development: 5.0,
      );
      final snapshot = StaffDevelopmentSnapshot.forSlot(
        StaffRole.headCoach,
        staffMemberFor(
          StaffRole.headCoach,
          attributes: current,
          previousAttributes: previous,
        ),
      );

      expect(snapshot.deltas, hasLength(2));
      expect(snapshot.deltas.map((d) => d!.abs()), everyElement(0.0));
    });
  });

  group('missing previous snapshot (Requirement 3.10)', () {
    for (final role in StaffRole.values) {
      test('${role.name} keeps current values and reports null deltas', () {
        final member = staffMemberFor(role, attributes: distinctAttributes);
        expect(
          member.previousAttributes,
          isNull,
          reason: 'this fixture has no previous data by design',
        );

        final snapshot = StaffDevelopmentSnapshot.forSlot(role, member);

        expect(
          snapshot.deltas,
          everyElement(isNull),
          reason: 'a missing previous snapshot has no deltas to report',
        );
        expect(
          snapshot.currentValues,
          expectedCurrentValues(distinctAttributes, role),
          reason: 'missing previous data must not zero the current values',
        );
        expect(
          snapshot.currentValues,
          isNot(everyElement(0.0)),
          reason: 'the fixture has non-zero relevant values',
        );
        expect(snapshot.isEmptySlot, isFalse);
      });
    }
  });

  group('EmptySlot (Requirements 3.9, 9.1)', () {
    for (final role in StaffRole.values) {
      test('${role.name} EmptySlot is neutral, not an occupied 0,0 member', () {
        final snapshot = StaffDevelopmentSnapshot.forSlot(role, null);

        expect(snapshot.role, role);
        expect(snapshot.member, isNull);
        expect(snapshot.isEmptySlot, isTrue);
        expect(
          snapshot.attributeNames,
          relevantStaffAttributeNames(role),
          reason: 'an EmptySlot still describes its own role',
        );
        expect(
          snapshot.currentValues,
          List<double>.filled(relevantStaffAttributeNames(role).length, 0.0),
          reason: 'an EmptySlot contributes 0,0 (Requirement 9.1)',
        );
        expect(
          snapshot.deltas,
          everyElement(isNull),
          reason: 'an EmptySlot has no growth to report',
        );
      });
    }

    test("an EmptySlot never borrows an occupied role's attributes", () {
      final staff = teamStaffOf({
        StaffRole.headCoach: staffMemberFor(
          StaffRole.headCoach,
          attributes: uniformStaffAttributes(5.0),
        ),
      });
      final snapshots = StaffDevelopmentSnapshot.forTeamStaff(staff);

      for (final snapshot in snapshots) {
        if (snapshot.role == StaffRole.headCoach) {
          expect(snapshot.isEmptySlot, isFalse);
          expect(snapshot.currentValues, const [5.0, 5.0]);
          continue;
        }
        expect(
          snapshot.isEmptySlot,
          isTrue,
          reason: '${snapshot.role.name} was never filled',
        );
        expect(
          snapshot.currentValues,
          everyElement(0.0),
          reason: '${snapshot.role.name} must not read the head coach fields',
        );
      }
    });

    test('emptying an occupied slot leaves no stale values behind', () {
      final staff = fullTeamStaff(relevantValue: 4.0, cfoNegotiation: 4.0);
      final before = StaffDevelopmentSnapshot.forTeamStaff(staff);
      final after = StaffDevelopmentSnapshot.forTeamStaff(
        teamStaffWithEmptySlot(staff, StaffRole.physio),
      );

      expect(
        before
            .firstWhere((entry) => entry.role == StaffRole.physio)
            .currentValues,
        const [4.0, 4.0],
      );

      final vacated = after.firstWhere(
        (entry) => entry.role == StaffRole.physio,
      );
      expect(vacated.isEmptySlot, isTrue);
      expect(vacated.member, isNull);
      expect(vacated.currentValues, const [0.0, 0.0]);
      expect(vacated.deltas, everyElement(isNull));

      for (final role in StaffRole.values) {
        if (role == StaffRole.physio) continue;
        expect(
          after.firstWhere((entry) => entry.role == role).currentValues,
          before.firstWhere((entry) => entry.role == role).currentValues,
          reason: 'emptying physio must not disturb ${role.name}',
        );
      }
    });

    test('forTeamStaff covers the six recognized slots in enum order', () {
      final snapshots = StaffDevelopmentSnapshot.forTeamStaff(emptyTeamStaff);

      expect(snapshots.map((entry) => entry.role).toList(), StaffRole.values);
      expect(
        snapshots.every((entry) => entry.isEmptySlot),
        isTrue,
        reason: 'an all-empty TeamStaff yields six EmptySlot snapshots',
      );
    });
  });

  group('legacy persisted data (Requirements 3.8, 9.6)', () {
    for (final role in StaffRole.values) {
      test('${role.name} with a missing relevant field decodes to 0,0', () {
        final omitted = relevantStaffAttributeNames(role).first;
        final json = staffJsonRecord(
          StaffJsonCase.missingRelevantAttribute,
          role: role,
        );

        expect(
          (json['attributes'] as Map<String, dynamic>).containsKey(omitted),
          isFalse,
          reason: 'the fixture must actually omit "$omitted"',
        );

        final member = StaffMember.fromJson(json);
        final snapshot = StaffDevelopmentSnapshot.forSlot(role, member);

        expect(snapshot.attributeNames, relevantStaffAttributeNames(role));
        expect(
          snapshot.currentValues,
          expectedCurrentValues(member.attributes, role),
          reason: 'the absent field must read through the same lookup',
        );
        expect(
          snapshot.currentValues.first,
          0.0,
          reason: 'an absent relevant field reads as 0,0 (Requirement 9.6)',
        );
        expect(
          snapshot.currentValues,
          everyElement(inInclusiveRange(0.0, 5.0)),
          reason: 'the 0-5 scale must survive incomplete legacy data',
        );
        expect(snapshot.deltas, everyElement(isNull));
      });

      test('${role.name} with an UnknownAttribute key is unaffected', () {
        final json = staffJsonRecord(
          StaffJsonCase.unknownAttribute,
          role: role,
        );

        expect(
          (json['attributes']
              as Map<String, dynamic>)[unknownStaffAttributeName],
          4.0,
          reason: 'the fixture must carry the undeclared key',
        );

        final member = StaffMember.fromJson(json);
        final snapshot = StaffDevelopmentSnapshot.forSlot(role, member);

        expect(snapshot.attributeNames, relevantStaffAttributeNames(role));
        expect(
          snapshot.attributeNames,
          isNot(contains(unknownStaffAttributeName)),
          reason: 'an undeclared key never enters the snapshot',
        );
        expect(
          snapshot.currentValues,
          expectedCurrentValues(member.attributes, role),
        );
        expect(
          staffAttributeValue(member.attributes, unknownStaffAttributeName),
          0.0,
        );
      });
    }

    test('physio reads the persisted regenaration key without renaming', () {
      final json = staffMemberJson(
        role: StaffRole.physio,
        attributes: const StaffAttributes(
          rehabilitation: 4.0,
          regenaration: 3.0,
        ),
      );
      final attributesJson = json['attributes'] as Map<String, dynamic>;

      expect(attributesJson['regenaration'], 3.0);
      expect(attributesJson.containsKey('regeneration'), isFalse);

      final snapshot = StaffDevelopmentSnapshot.forSlot(
        StaffRole.physio,
        StaffMember.fromJson(json),
      );

      expect(snapshot.attributeNames, const ['rehabilitation', 'regenaration']);
      expect(snapshot.currentValues, const [4.0, 3.0]);
    });
  });
}
