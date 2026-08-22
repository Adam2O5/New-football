@Tags(['property'])
library;

// Feature: staff-role-ratings, Property 8: payroll zależy od aktywnych kontraktów.
//
// This property-like test uses only seeded values and an independent payroll
// oracle. A failure includes the seed, role, iteration, slot state and the
// complete fixture, so it can be replayed without clock-dependent randomness.
// The typed TeamStaff boundary can only carry recognized StaffRole values; a
// role/slot mismatch is therefore the defensive representation of a legacy or
// unsupported record before data compatibility removes it.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

const _propertyTag =
    'Feature: staff-role-ratings, Property 8: payroll zależy od aktywnych '
    'kontraktów';
const _casesPerRole = 120;
const _propertySeed = staffFixtureSeed + 806;

/// Slot states exercised by every role across the seeded iterations.
enum _PayrollSlotKind {
  empty,
  withoutContract,
  active,
  expired,
  invalidSalaryBelowMinimum,
  invalidSalaryAboveMaximum,
  invalidTerm,
  roleSlotMismatch,
}

void main() {
  group(_propertyTag, () {
    // **Validates: Requirements 6.8, 9.1, 9.3, 9.5, 10.9, 10.10**
    for (final role in StaffRole.values) {
      test('${role.name}: only active valid contracts contribute to payroll '
          'for $_casesPerRole seeded combinations', () {
        final seed = _seedFor(role);
        final random = Random(seed);

        for (var iteration = 0; iteration < _casesPerRole; iteration++) {
          final staff = _generatedTeamStaff(
            random,
            anchorRole: role,
            iteration: iteration,
          );
          final expected = _oraclePayroll(staff);
          final reason = _caseReason(
            role: role,
            seed: seed,
            iteration: iteration,
            staff: staff,
            expected: expected,
          );

          expect(staff.totalSalary, expected, reason: reason);
        }
      });
    }

    // **Validates: Requirements 2.7, 4.2, 6.8, 10.9**
    for (final role in StaffRole.values) {
      test('${role.name}: raw/displayed and irrelevant mutations never change '
          'payroll for $_casesPerRole seeded active contracts', () {
        final seed = _seedFor(role) + 10000;
        final random = Random(seed);

        for (var iteration = 0; iteration < _casesPerRole; iteration++) {
          final salary = _validSalaryFor(random, iteration);
          final contract = staffFixtureContract(
            salary: salary,
            yearsRemaining: 1 + random.nextInt(5),
          );
          final base = staffMemberFor(
            role,
            attributes: staffAttributesWithRawOverall(
              role,
              2.25,
              irrelevantValue: 0.0,
            ),
            contract: contract,
            id: 'payroll_mutation_${role.name}_$iteration',
            index: iteration + 1,
          );
          final rawMutation = base.copyWith(
            attributes: staffAttributesWithRawOverall(
              role,
              2.75,
              irrelevantValue: 5.0,
            ),
          );
          final irrelevantMutation = base.copyWith(
            attributes: withIrrelevantStaffAttribute(
              base.attributes,
              role,
              value: 5.0,
            ),
          );
          final basePayroll = teamStaffOf({role: base}).totalSalary;
          final rawMutationPayroll = teamStaffOf({
            role: rawMutation,
          }).totalSalary;
          final irrelevantMutationPayroll = teamStaffOf({
            role: irrelevantMutation,
          }).totalSalary;
          final rawBefore = base.overall;
          final rawAfter = rawMutation.overall;
          final displayedBefore = expectedStaffDisplayedRating(rawBefore);
          final displayedAfter = expectedStaffDisplayedRating(rawAfter);
          final reason =
              '$_propertyTag role=${role.name} seed=$seed case=$iteration '
              'salary=$salary rawBefore=$rawBefore rawAfter=$rawAfter '
              'displayedBefore=$displayedBefore displayedAfter=$displayedAfter '
              'base=$base rawMutation=$rawMutation '
              'irrelevantMutation=$irrelevantMutation';

          expect(
            rawAfter,
            isNot(rawBefore),
            reason: '$reason\nraw did not change',
          );
          expect(
            displayedAfter,
            isNot(displayedBefore),
            reason: '$reason\nDisplayedRating did not change',
          );
          expect(
            irrelevantMutation.overall,
            rawBefore,
            reason: '$reason\nirrelevant attribute changed RawOverall',
          );
          expect(
            rawMutationPayroll,
            basePayroll,
            reason: '$reason\npayroll consumed RawOverall or DisplayedRating',
          );
          expect(
            irrelevantMutationPayroll,
            basePayroll,
            reason: '$reason\npayroll consumed an irrelevant attribute',
          );
        }
      });
    }

    // **Validates: Requirements 6.8, 10.9**
    for (final role in StaffRole.values) {
      test('${role.name}: active contract salary changes payroll by exactly '
          'the signed delta for $_casesPerRole seeded boundaries', () {
        final seed = _seedFor(role) + 20000;
        final random = Random(seed);

        for (var iteration = 0; iteration < _casesPerRole; iteration++) {
          final beforeSalary = _boundarySalary(iteration);
          final requestedDelta = 1 + (iteration % 5);
          final afterSalary =
              beforeSalary <=
                  BalanceConfig.defaults.staff.maxSalary - requestedDelta
              ? beforeSalary + requestedDelta
              : beforeSalary - requestedDelta;
          final yearsRemaining = 1 + random.nextInt(5);
          final before = staffMemberFor(
            role,
            attributes: randomStaffAttributes(random, includeOutOfRange: true),
            contract: staffFixtureContract(
              salary: beforeSalary,
              yearsRemaining: yearsRemaining,
            ),
            id: 'payroll_delta_${role.name}_$iteration',
            index: iteration + 1,
          );
          final after = before.copyWith(
            contract: before.contract!.copyWith(salary: afterSalary),
          );
          final beforePayroll = teamStaffOf({role: before}).totalSalary;
          final afterPayroll = teamStaffOf({role: after}).totalSalary;
          final expectedDelta = afterSalary - beforeSalary;
          final reason =
              '$_propertyTag role=${role.name} seed=$seed case=$iteration '
              'beforeSalary=$beforeSalary afterSalary=$afterSalary '
              'expectedDelta=$expectedDelta years=$yearsRemaining';

          expect(
            beforePayroll,
            beforeSalary,
            reason: '$reason\nfixture before salary was not active',
          );
          expect(
            afterPayroll,
            afterSalary,
            reason: '$reason\nfixture after salary was not active',
          );
          expect(
            afterPayroll - beforePayroll,
            expectedDelta,
            reason:
                '$reason\npayroll change was not exactly contract salary delta',
          );
        }
      });
    }
  });
}

/// Independent oracle for Requirement 6.8 and the defensive staff boundary.
///
/// A contract is active and valid only while it has a positive remaining term
/// and a salary inside the documented staff range. A null slot, a member
/// without a contract, and a member whose declared role does not match its
/// slot are not payroll records. The production property under test is
/// intentionally only [TeamStaff.totalSalary]; this oracle does not call it,
/// [StaffMember.overall], [StaffRatingSystem] or any presentation helper.
int _oraclePayroll(TeamStaff staff) {
  const balance = BalanceConfig.defaults;
  var total = 0;

  for (final slot in StaffRole.values) {
    final member = staff.member(slot);
    if (member == null || member.role != slot) continue;
    final contract = member.contract;
    if (contract == null || contract.yearsRemaining <= 0) continue;
    if (contract.salary < balance.staff.minSalary ||
        contract.salary > balance.staff.maxSalary) {
      continue;
    }
    total += contract.salary;
  }

  return total;
}

TeamStaff _generatedTeamStaff(
  Random random, {
  required StaffRole anchorRole,
  required int iteration,
}) {
  final slots = <StaffRole, StaffMember?>{};
  for (final slot in StaffRole.values) {
    final kind =
        _PayrollSlotKind.values[(iteration + anchorRole.index + slot.index) %
            _PayrollSlotKind.values.length];
    final attributes = randomStaffAttributes(random, includeOutOfRange: true);
    final activeSalary = _validSalaryFor(random, iteration + slot.index);
    final contract = switch (kind) {
      _PayrollSlotKind.empty || _PayrollSlotKind.withoutContract => null,
      _PayrollSlotKind.active => staffFixtureContract(
        salary: activeSalary,
        yearsRemaining: 1 + random.nextInt(5),
      ),
      _PayrollSlotKind.expired => staffFixtureContract(
        salary: activeSalary,
        yearsRemaining: 0,
      ),
      _PayrollSlotKind.invalidSalaryBelowMinimum => staffFixtureContract(
        salary: BalanceConfig.defaults.staff.minSalary - 1,
        yearsRemaining: 2,
      ),
      _PayrollSlotKind.invalidSalaryAboveMaximum => staffFixtureContract(
        salary: BalanceConfig.defaults.staff.maxSalary + 1,
        yearsRemaining: 2,
      ),
      _PayrollSlotKind.invalidTerm => staffFixtureContract(
        salary: activeSalary,
        yearsRemaining: -1,
      ),
      _PayrollSlotKind.roleSlotMismatch => staffFixtureContract(
        salary: activeSalary,
        yearsRemaining: 2,
      ),
    };

    if (kind == _PayrollSlotKind.empty) {
      slots[slot] = null;
      continue;
    }

    final declaredRole = kind == _PayrollSlotKind.roleSlotMismatch
        ? _nextRole(slot)
        : slot;
    slots[slot] = staffMemberFor(
      declaredRole,
      attributes: attributes,
      contract: contract,
      id: 'payroll_${anchorRole.name}_${slot.name}_$iteration',
      index: iteration + slot.index + 1,
    );
  }
  return teamStaffOf(slots);
}

int _validSalaryFor(Random random, int iteration) {
  const balance = BalanceConfig.defaults;
  final boundary = switch (iteration % 5) {
    0 => balance.staff.minSalary,
    1 => balance.staff.minSalary + 1,
    2 => balance.staff.maxSalary - 1,
    3 => balance.staff.maxSalary,
    _ =>
      balance.staff.minSalary +
          random.nextInt(balance.staff.maxSalary - balance.staff.minSalary + 1),
  };
  return boundary;
}

int _boundarySalary(int iteration) {
  const balance = BalanceConfig.defaults;
  return switch (iteration % 4) {
    0 => balance.staff.minSalary,
    1 => balance.staff.minSalary + 1,
    2 => balance.staff.maxSalary - 1,
    _ => balance.staff.maxSalary,
  };
}

StaffRole _nextRole(StaffRole role) =>
    StaffRole.values[(role.index + 1) % StaffRole.values.length];

int _seedFor(StaffRole role) => _propertySeed + role.index * 1009;

String _caseReason({
  required StaffRole role,
  required int seed,
  required int iteration,
  required TeamStaff staff,
  required int expected,
}) {
  final slots = [
    for (final slot in StaffRole.values)
      '${slot.name}:${_describeMember(staff.member(slot))}',
  ].join(' | ');
  return '$_propertyTag role=${role.name} seed=$seed case=$iteration '
      'expected=$expected actual=${staff.totalSalary} slots=[$slots]';
}

String _describeMember(StaffMember? member) {
  if (member == null) return 'EmptySlot';
  final contract = member.contract;
  final contractDescription = contract == null
      ? 'none'
      : 'salary=${contract.salary},years=${contract.yearsRemaining}';
  return 'id=${member.id},declaredRole=${member.role.name},contract=$contractDescription,'
      'raw=${member.overall}';
}
