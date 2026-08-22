@Tags(['property'])
library;

// Feature: staff-role-ratings, Property 5: Prezentacja respektuje rolę i stan
// slotu.
//
// This deterministic property-like test keeps its expected projection in the
// independent docs/staff.md oracle from the shared test fixtures. It never
// derives the expected role mapping from StaffPresentation or
// StaffRatingSystem, so a second production mapping cannot make the test pass.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

const _propertyTag =
    'Feature: staff-role-ratings, Property 5: Prezentacja respektuje rolę i '
    'stan slotu';
const _casesPerRole = 120;

int _seedFor(StaffRole role) => staffFixtureSeed + role.index * 1009 + 503;

void main() {
  group(_propertyTag, () {
    // **Validates: Requirements 3.9, 3.10, 4.9, 4.10, 4.11, 4.13, 9.7**
    for (final role in StaffRole.values) {
      test('${role.name}: occupied, empty and unavailable views satisfy the '
          'independent oracle for $_casesPerRole seeded cases', () {
        final seed = _seedFor(role);
        final random = Random(seed);

        for (var iteration = 0; iteration < _casesPerRole; iteration++) {
          final attributes = _attributesForCase(role, random, iteration);
          final member = staffMemberFor(
            role,
            attributes: attributes,
            index: iteration + 1,
            id: 'property5_${role.name}_${iteration.toString().padLeft(3, '0')}',
          );
          final reason = _caseReason(role, seed, iteration, attributes);

          _expectOccupiedView(
            StaffPresentation.viewForMember(member),
            member: member,
            role: role,
            attributes: attributes,
            reason: '$reason\nviewForMember',
          );
          _expectOccupiedView(
            StaffPresentation.viewForSlot(member, role),
            member: member,
            role: role,
            attributes: attributes,
            reason: '$reason\nviewForSlot occupied',
          );

          final empty = StaffPresentation.viewForSlot(null, role);
          _expectNeutralView(
            empty,
            state: StaffSlotState.empty,
            role: role,
            reason: '$reason\nviewForSlot EmptySlot',
          );

          final mismatchedRole =
              StaffRole.values[(role.index + 1) % StaffRole.values.length];
          final mismatchedMember = staffMemberFor(
            mismatchedRole,
            attributes: attributes,
            index: iteration + 1,
            id:
                'property5_mismatch_${role.name}_'
                '${iteration.toString().padLeft(3, '0')}',
          );
          final mismatched = StaffPresentation.viewForSlot(
            mismatchedMember,
            role,
          );
          _expectNeutralView(
            mismatched,
            state: StaffSlotState.unavailable,
            role: role,
            member: mismatchedMember,
            reason:
                '$reason\nviewForSlot mismatched role '
                '(declared ${mismatchedRole.name})',
          );

          final missingRole = StaffPresentation.viewForSlot(member);
          _expectNeutralView(
            missingRole,
            state: StaffSlotState.unavailable,
            role: null,
            member: member,
            reason: '$reason\nviewForSlot unavailable without a slot role',
          );
        }
      });
    }

    // A separate exhaustive boundary check makes the intended neutral states
    // explicit even if a future random generator changes its value pool.
    // **Validates: Requirements 3.9, 4.13, 9.7**
    test('all recognized roles keep EmptySlot and mismatch states neutral at '
        'rating boundaries', () {
      for (final role in StaffRole.values) {
        for (final value in const [-4.0, 0.0, 5.0, 9.5]) {
          final attributes = uniformStaffAttributes(value);
          final member = staffMemberFor(
            role,
            attributes: attributes,
            index: value.toInt().abs() + 1,
          );
          final mismatchRole =
              StaffRole.values[(role.index + 1) % StaffRole.values.length];

          final empty = StaffPresentation.viewForSlot(null, role);
          _expectNeutralView(
            empty,
            state: StaffSlotState.empty,
            role: role,
            reason:
                '$_propertyTag boundary=$value role=${role.name} '
                'EmptySlot',
          );

          final mismatched = StaffPresentation.viewForSlot(
            member.copyWith(role: mismatchRole),
            role,
          );
          _expectNeutralView(
            mismatched,
            state: StaffSlotState.unavailable,
            role: role,
            member: mismatched.member,
            reason:
                '$_propertyTag boundary=$value role=${role.name} '
                'mismatched=${mismatchRole.name}',
          );
        }
      }
    });
  });
}

/// The first cases are fixed boundary fixtures; the rest are seeded values
/// from both inside and outside the documented 0–5 input scale.
StaffAttributes _attributesForCase(
  StaffRole role,
  Random random,
  int iteration,
) {
  switch (iteration) {
    case 0:
      return uniformStaffAttributes(0.0);
    case 1:
      return uniformStaffAttributes(5.0);
    case 2:
      final relevant = relevantStaffAttributeNames(role).length;
      return staffAttributesForRole(
        role,
        relevant == 1 ? const [4.5] : const [4.5, 3.0],
        irrelevantValue: 5.0,
      );
    case 3:
      final relevant = relevantStaffAttributeNames(role).length;
      return staffAttributesForRole(
        role,
        relevant == 1 ? const [-4.0] : const [-4.0, 9.5],
        irrelevantValue: 5.0,
      );
    default:
      return randomStaffAttributes(random, includeOutOfRange: iteration.isEven);
  }
}

void _expectOccupiedView(
  StaffSlotView view, {
  required StaffMember member,
  required StaffRole role,
  required StaffAttributes attributes,
  required String reason,
}) {
  final expectedNames = relevantStaffAttributeNames(role);
  final expectedValues = expectedNames
      .map((name) => staffAttributeByName(attributes, name))
      .toList(growable: false);
  final expectedRaw = expectedStaffRawOverall(attributes, role);
  final expectedDisplayed = expectedStaffDisplayedRating(expectedRaw);
  final expectedStars = _starsForRaw(expectedRaw);

  expect(view.state, StaffSlotState.occupied, reason: reason);
  expect(view.role, role, reason: '$reason\nslot role changed');
  expect(view.member, member, reason: '$reason\noccupied member changed');
  expect(view.rating, isNotNull, reason: '$reason\noccupied rating missing');
  expect(
    view.relevantAttributes,
    hasLength(expectedNames.length),
    reason: '$reason\nrole-relevant attribute count changed',
  );
  expect(
    view.relevantAttributes.map((attribute) => attribute.name).toList(),
    expectedNames,
    reason: '$reason\nattribute names are not the canonical role projection',
  );
  expect(
    view.relevantAttributes.map((attribute) => attribute.serializedName),
    expectedNames,
    reason: '$reason\nserialized names are not canonical',
  );
  expect(
    view.relevantAttributes.map((attribute) => attribute.key.name),
    expectedNames,
    reason: '$reason\nattribute keys are not canonical',
  );

  for (var index = 0; index < expectedNames.length; index++) {
    final attribute = view.relevantAttributes[index];
    final name = expectedNames[index];
    final expectedValue = expectedValues[index];
    final expectedAttributeDisplayed = expectedStaffDisplayedRating(
      expectedValue,
    );

    expect(
      attribute.value,
      closeTo(expectedValue, 1e-9),
      reason: '$reason\n$name read the wrong StaffAttributes field',
    );
    expect(
      attribute.displayedRating,
      closeTo(expectedAttributeDisplayed, 1e-9),
      reason: '$reason\n$name displayed rating is not half-up/clamped',
    );
    expect(
      attribute.stars,
      _starsForRaw(expectedValue),
      reason: '$reason\n$name graphic projection changed',
    );
  }

  final rating = view.rating!;
  expect(
    rating.rawOverall,
    closeTo(expectedRaw, 1e-9),
    reason: '$reason\nrole-specific RawOverall changed',
  );
  expect(
    rating.displayedRating,
    closeTo(expectedDisplayed, 1e-9),
    reason: '$reason\nrole-specific DisplayedRating changed',
  );
  expect(
    rating.stars,
    expectedStars,
    reason: '$reason\nrole-specific GraphicStar projection changed',
  );
  expect(
    rating.accessibilityValue,
    expectedDisplayed.toStringAsFixed(1),
    reason: '$reason\naccessibility value is not derived from displayed rating',
  );
  expect(
    view.relevantAttributes,
    everyElement(
      predicate<StaffAttributeView>(
        (attribute) =>
            !irrelevantStaffAttributeNames(role).contains(attribute.name),
      ),
    ),
    reason: '$reason\nan attribute outside the role leaked into the view',
  );
}

void _expectNeutralView(
  StaffSlotView view, {
  required StaffSlotState state,
  required StaffRole? role,
  StaffMember? member,
  required String reason,
}) {
  expect(view.state, state, reason: reason);
  expect(view.role, role, reason: '$reason\nneutral slot role changed');
  expect(view.member, member, reason: '$reason\nneutral slot member changed');
  expect(view.rating, isNull, reason: '$reason\nfabricated/stale rating');
  expect(
    view.relevantAttributes,
    isEmpty,
    reason: '$reason\nneutral slot contains role attributes',
  );
  expect(view.rawOverall, isNull, reason: '$reason\nraw rating leaked');
  expect(
    view.displayedRating,
    isNull,
    reason: '$reason\ndisplayed rating leaked',
  );
  expect(view.stars, isEmpty, reason: '$reason\nstar segments leaked');
  expect(
    view.accessibilityLabel,
    isNull,
    reason: '$reason\naccessibility rating leaked',
  );
}

List<GraphicStar> _starsForRaw(double raw) {
  final counts = expectedStaffStarCounts(raw);
  return [
    ...List<GraphicStar>.filled(counts.full, GraphicStar.full),
    if (counts.half == 1) GraphicStar.half,
    ...List<GraphicStar>.filled(counts.empty, GraphicStar.empty),
  ];
}

String _caseReason(
  StaffRole role,
  int seed,
  int iteration,
  StaffAttributes attributes,
) {
  final values = staffAttributeNames
      .map((name) => '$name=${staffAttributeByName(attributes, name)}')
      .join(', ');
  return '$_propertyTag role=${role.name} seed=$seed iteration=$iteration '
      'attributes=[$values]';
}
