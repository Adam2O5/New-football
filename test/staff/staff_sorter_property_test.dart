@Tags(['property'])
library;

// Feature: staff-role-ratings, Property 6: wspólny sorter raw + ID.
//
// This deterministic property-like test compares StaffPresentation against an
// independent oracle transcribed from docs/staff.md in the shared fixtures. It
// exercises two seeded permutations of every generated candidate pool for every
// recognized role. Each failure reports the seed, role, iteration and complete
// input/order data so the case can be replayed without a clock-dependent RNG.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

const _propertyTag =
    'Feature: staff-role-ratings, Property 6: wspólny sorter raw + ID';
const _casesPerRole = 120;
const _propertySeed = staffFixtureSeed + 604;

void main() {
  group(_propertyTag, () {
    // **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5, 8.1, 8.2, 8.8**
    for (final role in StaffRole.values) {
      test('${role.name}: raw descending, ID tie-break and role filtering '
          'hold for $_casesPerRole seeded permutations', () {
        final seed = _seedFor(role);
        final random = Random(seed);

        for (var iteration = 0; iteration < _casesPerRole; iteration++) {
          final baseCandidates = _generatedCandidates(role, random, iteration);
          final firstPermutation = List<StaffMember>.of(baseCandidates)
            ..shuffle(random);
          final secondPermutation = List<StaffMember>.of(
            baseCandidates.reversed,
          )..shuffle(random);
          final reason = _caseReason(
            role: role,
            seed: seed,
            iteration: iteration,
            candidates: firstPermutation,
          );
          final firstPermutationBefore = List<StaffMember>.of(firstPermutation);
          final secondPermutationBefore = List<StaffMember>.of(
            secondPermutation,
          );

          final expectedForRole = _oracleSort(firstPermutation, role);
          final expectedForAllRoles = _oracleSort(firstPermutation);
          final firstForRole = StaffPresentation.sortStaffCandidates(
            firstPermutation,
            role,
          );
          final secondForRole = StaffPresentation.sortStaffCandidates(
            secondPermutation,
            role,
          );
          final firstForAllRoles = StaffPresentation.sortStaffCandidates(
            firstPermutation,
          );

          _expectIds(
            firstForRole,
            expectedForRole,
            reason: '$reason\nStaffScreen role-filtered order',
          );
          _expectIds(
            secondForRole,
            expectedForRole,
            reason: '$reason\nsecond input permutation changed order',
          );
          _expectIds(
            firstForAllRoles,
            expectedForAllRoles,
            reason: '$reason\nunfiltered role order',
          );
          _expectRoleFilter(firstForRole, firstPermutation, role, reason);

          // StaffScreen sorts one requested role, while FreeAgencyScreen
          // concatenates the same helper's result once for each configured
          // role. Their role-local order must therefore be identical.
          final freeAgencyRoleOrder = _freeAgencyRoleOrder(
            firstPermutation,
            role,
          );
          _expectIds(
            freeAgencyRoleOrder,
            firstForRole,
            reason: '$reason\nStaffScreen/FreeAgencyScreen order diverged',
          );

          _expectUnchanged(
            firstPermutation,
            firstPermutationBefore,
            reason: '$reason\nfirst input was mutated',
          );
          _expectUnchanged(
            secondPermutation,
            secondPermutationBefore,
            reason: '$reason\nsecond input was mutated',
          );
        }
      });
    }

    // **Validates: Requirements 5.3, 5.4, 10.9**
    test('raw order wins inside one displayed bucket and exact raw ties use '
        'ascending IDs for every role', () {
      for (final role in StaffRole.values) {
        final candidates = <StaffMember>[
          _memberWithRaw(role, 3.26, 'z_raw_326_${role.name}'),
          _memberWithRaw(role, 3.30, 'a_raw_330_${role.name}'),
          _memberWithRaw(role, 3.0, 'z_tie_300_${role.name}'),
          _memberWithRaw(role, 3.0, 'a_tie_300_${role.name}'),
        ];
        final input = <StaffMember>[
          candidates[2],
          candidates[0],
          candidates[3],
          candidates[1],
        ];
        final expected = _oracleSort(input, role);
        final actual = StaffPresentation.sortStaffCandidates(input, role);
        final reason =
            '$_propertyTag role=${role.name} seed=$_propertySeed '
            'explicit raw/display collision';

        expect(
          expectedStaffDisplayedRating(3.26),
          expectedStaffDisplayedRating(3.30),
          reason: '$reason\nfixture values must share DisplayedRating',
        );
        expect(
          _ids(actual),
          _ids(expected),
          reason: '$reason\nactual order used DisplayedRating or input order',
        );
        expect(
          _ids(actual),
          [
            'a_raw_330_${role.name}',
            'z_raw_326_${role.name}',
            'a_tie_300_${role.name}',
            'z_tie_300_${role.name}',
          ],
          reason: '$reason\nraw descending/ID ascending contract changed',
        );
      }
    });
  });
}

int _seedFor(StaffRole role) => _propertySeed + role.index * 1009;

/// Candidate generation intentionally includes:
///
/// * exact raw ties with IDs in the opposite order from the input;
/// * different raw values in the same displayed bucket;
/// * values at both raw scale boundaries; and
/// * mismatched recognized roles, including a high-rated record that must not
///   leak into the requested role's result.
///
/// The random candidates also vary irrelevant and out-of-range persisted
/// fields. The independent oracle clamps the relevant fields and ignores the
/// rest, so a global-average regression cannot hide behind fixed fixtures.
List<StaffMember> _generatedCandidates(
  StaffRole role,
  Random random,
  int iteration,
) {
  final candidates = <StaffMember>[
    _memberWithRaw(role, 3.26, 'candidate_${role.name}_raw326_$iteration'),
    _memberWithRaw(role, 3.30, 'candidate_${role.name}_raw330_$iteration'),
    _memberWithRaw(role, 2.26, 'candidate_${role.name}_raw226_$iteration'),
    _memberWithRaw(role, 2.49, 'candidate_${role.name}_raw249_$iteration'),
    _memberWithRaw(role, 3.0, 'candidate_${role.name}_tie_z_$iteration'),
    _memberWithRaw(role, 3.0, 'candidate_${role.name}_tie_a_$iteration'),
    _memberWithRaw(role, 5.0, 'candidate_${role.name}_max_$iteration'),
    _memberWithRaw(role, 0.0, 'candidate_${role.name}_min_$iteration'),
  ];

  for (var index = 0; index < 6; index++) {
    candidates.add(
      staffMemberFor(
        role,
        attributes: randomStaffAttributes(random, includeOutOfRange: true),
        id: 'candidate_${role.name}_random_${iteration}_$index',
        index: iteration * 10 + index + 1,
      ),
    );
  }

  final firstMismatchRole = _otherRole(role, offset: 1);
  final secondMismatchRole = _otherRole(role, offset: 2);
  candidates.add(
    staffMemberFor(
      firstMismatchRole,
      attributes: staffAttributesWithRawOverall(
        firstMismatchRole,
        5.0,
        irrelevantValue: 5.0,
      ),
      id: 'mismatch_high_${role.name}_$iteration',
      index: iteration + 1,
    ),
  );
  candidates.add(
    staffMemberFor(
      secondMismatchRole,
      attributes: randomStaffAttributes(random, includeOutOfRange: true),
      id: 'mismatch_other_${role.name}_$iteration',
      index: iteration + 2,
    ),
  );

  return candidates;
}

StaffRole _otherRole(StaffRole role, {required int offset}) =>
    StaffRole.values[(role.index + offset) % StaffRole.values.length];

StaffMember _memberWithRaw(StaffRole role, double raw, String id) =>
    staffMemberFor(
      role,
      attributes: staffAttributesWithRawOverall(
        role,
        raw,
        irrelevantValue: 5.0,
      ),
      id: id,
    );

/// Independent Property 6 oracle. It uses the docs/staff.md fixture map and
/// raw formula, never StaffPresentation, StaffRatingSystem or member.overall.
List<StaffMember> _oracleSort(
  Iterable<StaffMember> candidates, [
  StaffRole? role,
]) {
  final eligible = candidates
      .where(
        (candidate) =>
            staffRelevantAttributeNames.containsKey(candidate.role) &&
            (role == null || candidate.role == role),
      )
      .toList();
  eligible.sort((a, b) {
    final rawOrder = expectedStaffRawOverall(
      b.attributes,
      b.role,
    ).compareTo(expectedStaffRawOverall(a.attributes, a.role));
    if (rawOrder != 0) return rawOrder;
    return a.id.compareTo(b.id);
  });
  return eligible;
}

/// The FreeAgencyScreen path: one role-filtered call per configured role,
/// concatenated in the configured role order. Selecting [role]'s group must
/// match StaffScreen's direct role-filtered call exactly.
List<StaffMember> _freeAgencyRoleOrder(
  Iterable<StaffMember> candidates,
  StaffRole role,
) {
  final concatenated = <StaffMember>[
    for (final configuredRole in StaffRole.values)
      ...StaffPresentation.sortStaffCandidates(candidates, configuredRole),
  ];
  return concatenated
      .where((candidate) => candidate.role == role)
      .toList(growable: false);
}

void _expectRoleFilter(
  List<StaffMember> actual,
  List<StaffMember> input,
  StaffRole role,
  String reason,
) {
  expect(
    actual,
    everyElement(
      predicate<StaffMember>(
        (candidate) =>
            candidate.role == role &&
            staffRelevantAttributeNames.containsKey(candidate.role),
      ),
    ),
    reason: '$reason\nrole filter admitted an unsupported/mismatched record',
  );

  final rejected = input.where((candidate) => candidate.role != role);
  for (final candidate in rejected) {
    expect(
      actual.any((selected) => selected.id == candidate.id),
      isFalse,
      reason:
          '$reason\nrole filter admitted mismatched candidate '
          '${candidate.id} (${candidate.role.name})',
    );
  }
}

void _expectIds(
  Iterable<StaffMember> actual,
  Iterable<StaffMember> expected, {
  required String reason,
}) {
  expect(_ids(actual), _ids(expected), reason: reason);
}

List<String> _ids(Iterable<StaffMember> members) =>
    members.map((member) => member.id).toList(growable: false);

void _expectUnchanged(
  List<StaffMember> actual,
  List<StaffMember> before, {
  required String reason,
}) {
  expect(actual, orderedEquals(before), reason: reason);
  expect(_ids(actual), _ids(before), reason: '$reason\ninput IDs changed');
}

String _caseReason({
  required StaffRole role,
  required int seed,
  required int iteration,
  required Iterable<StaffMember> candidates,
}) {
  final description = candidates
      .map(
        (candidate) =>
            '${candidate.id}:${candidate.role.name}:'
            '${expectedStaffRawOverall(candidate.attributes, candidate.role)}',
      )
      .join(', ');
  return '$_propertyTag role=${role.name} seed=$seed iteration=$iteration '
      'input=[$description]';
}
