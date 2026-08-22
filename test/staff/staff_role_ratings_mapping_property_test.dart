@Tags(['property'])
library;

// Feature: staff-role-ratings, Property 1: Kanoniczna projekcja rola →
// atrybuty.
//
// For any recognized `StaffRole` and any `StaffAttributes`, the canonical map
// returns exactly the attributes documented in `docs/staff.md`,
// `attributesForRole` returns their stable serialized names in the same order,
// and reading any of those names returns the value of the very same
// `StaffAttributes` field. No other attribute is part of the projection.
//
// Every case is deterministic: the seed is derived from the role index and the
// iteration counter, never from the clock, and each failure reports role, seed
// and iteration so a single case can be replayed on its own.

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/development_snapshot.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

/// Deterministic cases per recognized role (minimum 100 required by the plan).
const _casesPerRole = 120;

/// Correct English spelling of Regeneration. It is deliberately *not* a
/// serialized name: renaming `regenaration` would need a save migration, which
/// is out of scope for this feature.
const _renamedRegenerationName = 'regeneration';

/// Seed of one case. Stable for a given role/iteration and clock independent.
int _seedFor(StaffRole role, int iteration) =>
    staffFixtureSeed + role.index * 10007 + iteration * 31;

void main() {
  group('Feature: staff-role-ratings, '
      'Property 1: Kanoniczna projekcja rola → atrybuty', () {
    // **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 3.1, 3.2, 3.3,
    // 3.4, 3.5, 3.6, 3.7, 10.12**
    for (final role in StaffRole.values) {
      test('${role.name}: canonical map, snapshot names and value lookup agree '
          'for $_casesPerRole seeded cases', () {
        final expectedNames = relevantStaffAttributeNames(role);
        final irrelevantNames = irrelevantStaffAttributeNames(role);

        for (var iteration = 0; iteration < _casesPerRole; iteration++) {
          final seed = _seedFor(role, iteration);
          final random = staffFixtureRandom(seed);
          // Half of the cases leave the 0–5 scale: the projection reports
          // the persisted field verbatim, clamping belongs to the rating.
          final attributes = randomStaffAttributes(
            random,
            includeOutOfRange: iteration.isOdd,
          );
          final where =
              'role=${role.name} seed=$seed iteration=$iteration '
              'attributes=$attributes';

          // The canonical map holds exactly the documented attributes, in
          // presentation order, for this role and nothing else.
          final keys = StaffRatingSystem.keysForRole(role);
          expect(
            keys.map((key) => key.name).toList(growable: false),
            expectedNames,
            reason: '$where: canonical map keys or their order changed',
          );
          expect(
            keys.length,
            expectedNames.length,
            reason:
                '$where: canonical map holds ${keys.length} attribute(s) '
                'instead of ${expectedNames.length}',
          );
          expect(
            StaffRatingSystem.serializedNamesForRole(role),
            expectedNames,
            reason: '$where: serialized names or their order changed',
          );

          // The development snapshot projects the same names, in the same
          // order, instead of keeping a second role switch.
          expect(
            attributesForRole(role),
            expectedNames,
            reason:
                '$where: attributesForRole is not the canonical '
                'projection',
          );

          // Projected names resolve to the matching StaffAttributes field,
          // through the snapshot helper and through the domain accessor.
          for (var i = 0; i < expectedNames.length; i++) {
            final name = expectedNames[i];
            final field = staffAttributeByName(attributes, name);
            expect(
              staffAttributeValue(attributes, name),
              field,
              reason:
                  '$where: staffAttributeValue("$name") is not the '
                  '$name field',
            );
            expect(
              StaffRatingSystem.attributeValue(attributes, keys[i]),
              field,
              reason:
                  '$where: attributeValue(${keys[i].name}) is not the '
                  '$name field',
            );
            expect(
              StaffRatingSystem.keyForSerializedName(name),
              keys[i],
              reason:
                  '$where: "$name" does not resolve to '
                  '${keys[i].name}',
            );
          }

          // Every recognized name keeps reading its own field, so the
          // projection cannot be right by reading a neighbouring one.
          for (final name in staffAttributeNames) {
            expect(
              staffAttributeValue(attributes, name),
              staffAttributeByName(attributes, name),
              reason:
                  '$where: staffAttributeValue("$name") does not '
                  'match the $name field',
            );
          }

          // Attributes outside the role never enter the projection.
          for (final name in irrelevantNames) {
            expect(
              attributesForRole(role),
              isNot(contains(name)),
              reason:
                  '$where: irrelevant "$name" leaked into '
                  'attributesForRole',
            );
            expect(
              StaffRatingSystem.serializedNamesForRole(role),
              isNot(contains(name)),
              reason:
                  '$where: irrelevant "$name" leaked into the '
                  'canonical map',
            );
          }

          // Requirement 10.12: headCoach must not project the legacy
          // Development field, whatever its persisted value is.
          expect(
            attributesForRole(StaffRole.headCoach),
            const ['tactics', 'motivation'],
            reason:
                '$where: headCoach projection is not exactly Tactics '
                'and Motivation',
          );
          expect(
            StaffRatingSystem.serializedNamesForRole(StaffRole.headCoach),
            isNot(contains(StaffAttributeKey.development.name)),
            reason:
                '$where: headCoach regained the legacy Development '
                'attribute',
          );

          // Requirement 3.4: physio keeps the persisted `regenaration`
          // spelling and reads that field.
          expect(
            attributesForRole(StaffRole.physio),
            const ['rehabilitation', 'regenaration'],
            reason:
                '$where: physio projection lost the serialized '
                '`regenaration` spelling',
          );
          expect(
            staffAttributeValue(attributes, 'regenaration'),
            attributes.regenaration,
            reason:
                '$where: "regenaration" does not read the '
                'regenaration field',
          );
          expect(
            StaffRatingSystem.keyForSerializedName(_renamedRegenerationName),
            isNull,
            reason:
                '$where: "$_renamedRegenerationName" became a '
                'serialized name, which would need a save migration',
          );

          // Requirement 3.8: an UnknownAttribute is neutral, never a throw.
          expect(
            staffAttributeValue(attributes, unknownStaffAttributeName),
            0.0,
            reason: '$where: UnknownAttribute lookup is not neutral',
          );
          expect(
            StaffRatingSystem.keyForSerializedName(unknownStaffAttributeName),
            isNull,
            reason: '$where: UnknownAttribute resolved to a canonical key',
          );

          // Changing one attribute outside the role changes neither the
          // projected names nor the projected values.
          final mutatedName =
              irrelevantNames[random.nextInt(irrelevantNames.length)];
          final mutatedValue =
              staffExtendedAttributeValues[random.nextInt(
                staffExtendedAttributeValues.length,
              )];
          final mutated = withIrrelevantStaffAttribute(
            attributes,
            role,
            name: mutatedName,
            value: mutatedValue,
          );
          expect(
            attributesForRole(role),
            expectedNames,
            reason:
                '$where: projection changed after setting '
                '$mutatedName=$mutatedValue',
          );
          for (final name in expectedNames) {
            expect(
              staffAttributeValue(mutated, name),
              staffAttributeByName(attributes, name),
              reason:
                  '$where: projected "$name" changed after setting '
                  '$mutatedName=$mutatedValue',
            );
          }
        }
      });
    }

    // The map covers the six recognized roles and nothing else, so no role
    // can silently fall back to another role's attributes.
    // **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 10.12**
    test('canonical map covers exactly the six recognized roles', () {
      expect(
        StaffRatingSystem.roleRelevantAttributes.keys.toSet(),
        StaffRole.values.toSet(),
        reason: 'canonical map does not cover exactly the recognized roles',
      );
      expect(
        {
          for (final role in StaffRole.values)
            role: StaffRatingSystem.serializedNamesForRole(role),
        },
        staffRelevantAttributeNames,
        reason: 'canonical map diverged from the docs/staff.md oracle',
      );
    });
  });
}
