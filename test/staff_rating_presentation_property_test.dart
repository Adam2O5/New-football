// Feature: staff-role-ratings, Property 4: Half-up tworzy dokładnie pięć
// segmentów.
//
// This is a deterministic property-like test rather than a new property-based
// testing dependency. The generated raw values cover below-range, in-range,
// above-range and exact half-up boundaries; every failure includes the case
// index, seed and raw input so it can be replayed.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';

import 'helpers/staff_role_ratings_test_helpers.dart';

const _propertyTag =
    'Feature: staff-role-ratings, Property 4: Half-up tworzy dokładnie pięć '
    'segmentów';
const _generatedCaseCount = 160;
const _propertySeed = staffFixtureSeed + 403;

void main() {
  group(_propertyTag, () {
    // **Validates: Requirements 4.1, 4.2, 4.5, 4.6, 4.7, 4.8, 4.12**
    test('displayed rating and stars satisfy the oracle for '
        '$_generatedCaseCount seeded cases', () {
      final cases = _generatedRawCases();
      expect(
        cases.length,
        greaterThanOrEqualTo(100),
        reason: '$_propertyTag must exercise at least 100 raw values',
      );

      for (var index = 0; index < cases.length; index++) {
        final raw = cases[index];
        final expectedDisplayed = expectedStaffDisplayedRating(raw);
        final expectedCounts = expectedStaffStarCounts(raw);
        final expectedStars = _starsFromCounts(expectedCounts);
        final displayed = StaffPresentation.displayedRatingForRaw(raw);
        final stars = StaffPresentation.starsForRaw(raw);
        final reason = _caseReason(
          index,
          raw,
          expectedDisplayed,
          displayed,
          expectedCounts,
        );

        expect(displayed, expectedDisplayed, reason: reason);
        expect(
          displayed,
          inInclusiveRange(0.0, 5.0),
          reason: '$reason\nDisplayedRating left the inclusive 0–5 scale',
        );
        expect(
          stars,
          hasLength(5),
          reason: '$reason\nExpected exactly five GraphicStar positions',
        );
        expect(
          stars,
          expectedStars,
          reason:
              '$reason\nGraphicStar order must be full, optional half, '
              'then empty',
        );
        expect(
          stars.where((star) => star == GraphicStar.full),
          hasLength(expectedCounts.full),
          reason: '$reason\nFull-star count changed',
        );
        expect(
          stars.where((star) => star == GraphicStar.half),
          hasLength(expectedCounts.half),
          reason: '$reason\nHalf-star count changed',
        );
        expect(
          stars.where((star) => star == GraphicStar.empty),
          hasLength(expectedCounts.empty),
          reason: '$reason\nEmpty-star count changed',
        );
      }
    });

    // **Validates: Requirements 4.2, 4.3, 4.4, 4.7, 4.8, 10.7, 10.8**
    test('explicit clamp and half-up boundary examples', () {
      for (final pair in staffDisplayedRatingCases) {
        final raw = pair.$1;
        final expectedDisplayed = pair.$2;
        final displayed = StaffPresentation.displayedRatingForRaw(raw);
        final stars = StaffPresentation.starsForRaw(raw);
        final counts = expectedStaffStarCounts(raw);
        final reason =
            '$_propertyTag raw=$raw expected=$expectedDisplayed actual=$displayed';

        expect(displayed, expectedDisplayed, reason: reason);
        expect(stars, _starsFromCounts(counts), reason: reason);
        expect(stars, hasLength(5), reason: '$reason\nStar count changed');
      }

      expect(
        StaffPresentation.starsForRaw(3.25),
        const [
          GraphicStar.full,
          GraphicStar.full,
          GraphicStar.full,
          GraphicStar.half,
          GraphicStar.empty,
        ],
        reason: 'Requirement 10.7: raw 3,25 must render 3 full + half + empty',
      );
      expect(
        StaffPresentation.starsForRaw(3.75),
        const [
          GraphicStar.full,
          GraphicStar.full,
          GraphicStar.full,
          GraphicStar.full,
          GraphicStar.empty,
        ],
        reason: 'Requirement 10.8: raw 3,75 must render 4 full + empty',
      );
      expect(
        StaffPresentation.starsForRaw(0.0),
        const [
          GraphicStar.empty,
          GraphicStar.empty,
          GraphicStar.empty,
          GraphicStar.empty,
          GraphicStar.empty,
        ],
        reason: 'raw 0,0 must render five empty segments',
      );
      expect(
        StaffPresentation.starsForRaw(5.0),
        const [
          GraphicStar.full,
          GraphicStar.full,
          GraphicStar.full,
          GraphicStar.full,
          GraphicStar.full,
        ],
        reason: 'raw 5,0 must render five full segments',
      );
    });

    // **Validates: Requirements 2.7, 4.1, 4.2, 4.12, 10.7, 10.8**
    test(
      'presentation keeps raw domain values separate from displayed values',
      () {
        for (final role in StaffRole.values) {
          final member = staffMemberFor(
            role,
            attributes: staffAttributesWithRawOverall(
              role,
              3.75,
              spread: relevantStaffAttributeNames(role).length == 1
                  ? 0.0
                  : 0.75,
              irrelevantValue: 5.0,
            ),
          );
          final slot = StaffPresentation.viewForMember(member);
          final rating = slot.rating;
          final reason = [_propertyTag, 'role=', role.name, ' raw=3.75'].join();

          expect(slot.state, StaffSlotState.occupied, reason: reason);
          expect(rating, isNotNull, reason: '$reason\nMissing rating view');
          expect(rating!.rawOverall, 3.75, reason: reason);
          expect(
            rating.displayedRating,
            4.0,
            reason: '$reason\nDisplayed value did not round half-up',
          );
          expect(rating.stars, const [
            GraphicStar.full,
            GraphicStar.full,
            GraphicStar.full,
            GraphicStar.full,
            GraphicStar.empty,
          ], reason: '$reason\nDisplayed stars do not match raw 3,75');
          expect(
            rating.accessibilityValue,
            '4.0',
            reason:
                '$reason\nAccessibility value must be derived from '
                'DisplayedRating',
          );
          expect(
            rating.accessibilityLabel,
            'Rating 4.0 out of 5',
            reason:
                '$reason\nAccessibility label must use the displayed value '
                'rather than raw 3,75',
          );
          expect(
            StaffRatingSystem.rawOverall(member.attributes, role),
            3.75,
            reason: '$reason\nPresentation must not round the domain value',
          );
        }
      },
    );
  });
}

List<double> _generatedRawCases() {
  final random = Random(_propertySeed);
  final cases = <double>[for (final pair in staffDisplayedRatingCases) pair.$1];

  for (var index = 0; index < _generatedCaseCount; index++) {
    final raw = switch (index % 4) {
      0 => -random.nextDouble() * 10.0,
      1 => random.nextDouble() * 5.0,
      2 => 5.0 + random.nextDouble() * 10.0,
      _ => (index ~/ 4) % 5 + (random.nextBool() ? 0.25 : 0.75),
    };
    cases.add(raw);
  }

  return List<double>.unmodifiable(cases);
}

List<GraphicStar> _starsFromCounts(({int full, int half, int empty}) counts) =>
    [
      ...List<GraphicStar>.filled(counts.full, GraphicStar.full),
      if (counts.half == 1) GraphicStar.half,
      ...List<GraphicStar>.filled(counts.empty, GraphicStar.empty),
    ];

String _caseReason(
  int index,
  double raw,
  double expected,
  double actual,
  ({int full, int half, int empty}) counts,
) =>
    '$_propertyTag seed=$_propertySeed case=$index raw=$raw '
    'expectedDisplayed=$expected actualDisplayed=$actual '
    'expectedStars=(full:${counts.full}, half:${counts.half}, '
    'empty:${counts.empty})';
