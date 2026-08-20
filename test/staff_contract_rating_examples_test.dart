import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/staff_service.dart';

import 'helpers/staff_role_ratings_test_helpers.dart';

/// Deterministic unit and regression coverage for task 7.3.
///
/// Contract expectations are intentionally exercised through observable
/// service outputs. Raw/displayed separation uses the independent fixtures in
/// [staff_role_ratings_test_helpers.dart]; no production rating formula is
/// copied into this file.
void main() {
  const balance = BalanceConfig.defaults;
  final service = StaffService();

  test(
    'salary and expected terms use role RawOverall, not displayed rounding',
    () {
      for (final role in StaffRole.values) {
        // 3.45 is deliberately below the 3.5 half-up boundary. It produces
        // staffWant 69 and expectedLength 3, while a displayed 3.5 input
        // would produce staffWant 70 and expectedLength 4.
        final member = staffMemberFor(
          role,
          attributes: staffAttributesWithRawOverall(role, 3.45),
          age: 45,
        );
        final roundedInput = staffMemberFor(
          role,
          attributes: staffAttributesWithRawOverall(role, 3.5),
          age: 45,
        );
        final irrelevantMutation = member.copyWith(
          attributes: withIrrelevantStaffAttribute(
            member.attributes,
            role,
            value: 5.0,
          ),
        );

        expect(
          member.overall,
          expectedStaffRawOverall(member.attributes, role),
          reason: '${role.name} must expose the canonical raw rating',
        );
        expect(member.overall, 3.45);
        expect(expectedStaffDisplayedRating(member.overall), 3.5);
        expect(
          irrelevantMutation.overall,
          member.overall,
          reason:
              '${role.name}: irrelevant attributes, including legacy '
              'headCoach.development, must not change RawOverall',
        );

        final marketSalary = service.marketSalary(member);
        expect(
          marketSalary,
          balance.staff.salaryFor(role, member.overall),
          reason: '${role.name}: market salary must receive RawOverall',
        );
        expect(
          marketSalary,
          isNot(
            balance.staff.salaryFor(
              role,
              expectedStaffDisplayedRating(member.overall),
            ),
          ),
          reason:
              '${role.name}: market salary must not receive DisplayedRating',
        );
        expect(
          service.marketSalary(irrelevantMutation),
          marketSalary,
          reason:
              '${role.name}: market salary changed with an irrelevant field',
        );

        final want = service.staffWant(member);
        expect(want, 69.0);
        expect(
          service.staffWant(irrelevantMutation),
          want,
          reason: '${role.name}: staffWant changed with an irrelevant field',
        );
        expect(
          service.expectedSalary(member),
          inInclusiveRange(balance.staff.minSalary, balance.staff.maxSalary),
        );
        expect(
          service.expectedLength(member),
          3,
          reason: '${role.name}: raw 3.45 belongs to the 3-year band',
        );
        expect(
          service.expectedSalary(irrelevantMutation),
          service.expectedSalary(member),
          reason:
              '${role.name}: expected salary changed with an irrelevant field',
        );
        expect(
          service.expectedLength(irrelevantMutation),
          service.expectedLength(member),
          reason:
              '${role.name}: expected length changed with an irrelevant field',
        );

        // These differential assertions catch a domain consumer that rounds
        // 3.45 to 3.5 before calculating the contract terms.
        expect(service.staffWant(roundedInput), 70.0);
        expect(
          service.marketSalary(roundedInput),
          isNot(marketSalary),
          reason: '${role.name}: rounded market input masked the raw value',
        );
        expect(
          service.expectedSalary(roundedInput),
          isNot(service.expectedSalary(member)),
          reason:
              '${role.name}: rounded expected-salary input masked RawOverall',
        );
        expect(
          service.expectedLength(roundedInput),
          4,
          reason: '${role.name}: displayed rounding must not move the raw band',
        );
      }
    },
  );

  test('salary bounds and cap replacement use contract payroll', () {
    for (final role in StaffRole.values) {
      final minimum = staffMemberFor(
        role,
        attributes: staffAttributesWithRawOverall(role, 0.0),
      );
      final maximum = staffMemberFor(
        role,
        attributes: staffAttributesWithRawOverall(role, 5.0),
      );

      expect(
        service.marketSalary(minimum),
        inInclusiveRange(balance.staff.minSalary, balance.staff.maxSalary),
      );
      expect(
        service.marketSalary(maximum),
        inInclusiveRange(balance.staff.minSalary, balance.staff.maxSalary),
      );
      expect(
        service.expectedSalary(minimum),
        inInclusiveRange(balance.staff.minSalary, balance.staff.maxSalary),
      );
      expect(
        service.expectedSalary(maximum),
        inInclusiveRange(balance.staff.minSalary, balance.staff.maxSalary),
      );
      expect(service.expectedLength(minimum), inInclusiveRange(1, 4));
      expect(service.expectedLength(maximum), inInclusiveRange(1, 4));
    }

    expect(service.isSalaryInRange(balance.staff.minSalary), isTrue);
    expect(service.isSalaryInRange(balance.staff.maxSalary), isTrue);
    expect(service.isSalaryInRange(balance.staff.minSalary - 1), isFalse);
    expect(service.isSalaryInRange(balance.staff.maxSalary + 1), isFalse);

    final headCoach = staffMemberFor(
      StaffRole.headCoach,
      contract: staffFixtureContract(
        salary: balance.staff.maxSalary,
        yearsRemaining: 1,
      ),
    );
    final youthCoach = staffMemberFor(
      StaffRole.youthCoach,
      contract: staffFixtureContract(
        salary: balance.staff.maxSalary,
        yearsRemaining: 1,
      ),
    );
    final scout = staffMemberFor(
      StaffRole.scout,
      contract: staffFixtureContract(
        salary: balance.staff.maxSalary,
        yearsRemaining: 1,
      ),
    );
    final team = staffFixtureTeam(
      staff: teamStaffOf({
        StaffRole.headCoach: headCoach,
        StaffRole.youthCoach: youthCoach,
        StaffRole.scout: scout,
      }),
    );

    expect(team.staff.totalSalary, balance.staff.salaryCap);
    expect(
      service.canHire(team, balance.staff.minSalary),
      isFalse,
      reason: 'a full staff payroll must enforce the staff salary cap',
    );
    expect(
      service.canHire(
        team,
        balance.staff.maxSalary,
        replacingSalary: headCoach.contract!.salary,
      ),
      isTrue,
      reason: 'an extension replaces the old salary before cap validation',
    );

    final extended = service.sign(
      team: team,
      member: headCoach,
      offer: StaffOffer(salary: balance.staff.maxSalary, years: 3),
    );
    expect(extended, isNotNull);
    expect(extended!.staff.totalSalary, balance.staff.salaryCap);
    expect(extended.staff.headCoach!.contract!.yearsRemaining, 3);
  });

  test(
    'CFO discount uses canonical Negotiation and stays separate from subject',
    () {
      final assistingCfo = staffCfoMember(
        negotiation: 4.5,
        irrelevantValue: 5.0,
        index: 90,
      );
      expect(
        service.cfoDiscount(cfo: assistingCfo),
        NegotiationRules.cfoDiscount(4.5),
      );
      expect(service.cfoDiscount(), 0.95);

      final subject = staffCfoMember(
        negotiation: 2.0,
        irrelevantValue: 5.0,
        index: 1,
      );
      const offer = StaffOffer(salary: staffFixtureSalary, years: 3);
      final withAssistant = service.staffOfferBreakdown(
        subject,
        offer,
        cfo: assistingCfo,
      );
      final withoutAssistant = service.staffOfferBreakdown(subject, offer);

      expect(withAssistant.cfoDiscount, NegotiationRules.cfoDiscount(4.5));
      expect(withAssistant.cfoDiscount, isNot(withoutAssistant.cfoDiscount));
      expect(
        withAssistant.salaryFit,
        isNot(withoutAssistant.salaryFit),
        reason:
            'subject terms and the assisting CFO multiplier are separate inputs',
      );

      final irrelevantSubjectMutation = subject.copyWith(
        attributes: withIrrelevantStaffAttribute(
          subject.attributes,
          StaffRole.cfo,
          value: 0.0,
        ),
      );
      final unchangedSubjectBreakdown = service.staffOfferBreakdown(
        irrelevantSubjectMutation,
        offer,
        cfo: assistingCfo,
      );
      expect(irrelevantSubjectMutation.overall, subject.overall);
      expect(unchangedSubjectBreakdown.salaryFit, withAssistant.salaryFit);
      expect(unchangedSubjectBreakdown.lengthFit, withAssistant.lengthFit);
      expect(unchangedSubjectBreakdown.cfoDiscount, withAssistant.cfoDiscount);
      expect(unchangedSubjectBreakdown.score, withAssistant.score);

      final strongerSubject = subject.copyWith(
        attributes: subject.attributes.copyWith(negotiation: 4.0),
      );
      final strongerSubjectBreakdown = service.staffOfferBreakdown(
        strongerSubject,
        offer,
        cfo: assistingCfo,
      );
      expect(strongerSubjectBreakdown.cfoDiscount, withAssistant.cfoDiscount);
      expect(
        strongerSubjectBreakdown.salaryFit,
        isNot(withAssistant.salaryFit),
        reason: 'a CFO subject rating must affect its own expected terms',
      );
    },
  );

  test('TeamStaff payroll counts only contracted occupied slots', () {
    final headCoach = staffMemberFor(
      StaffRole.headCoach,
      relevantValues: [4.5, 3.0],
      contract: staffFixtureContract(salary: 1250000),
    );
    final scout = staffMemberFor(
      StaffRole.scout,
      relevantValues: [4.0, 4.0],
      contract: staffFixtureContract(salary: 2750000),
    );
    final memberWithoutContract = staffMemberFor(StaffRole.doctor);
    final staff = teamStaffOf({
      StaffRole.headCoach: headCoach,
      StaffRole.scout: scout,
      StaffRole.doctor: memberWithoutContract,
    });

    expect(staff.totalSalary, 4000000);
    expect(emptyTeamStaff.totalSalary, 0);
    expect(
      teamStaffOf({StaffRole.doctor: memberWithoutContract}).totalSalary,
      0,
    );
    expect(staff.member(StaffRole.physio), isNull);

    final ratingMutation = staff.withMember(
      StaffRole.headCoach,
      headCoach.copyWith(
        attributes: staffAttributesWithRawOverall(
          StaffRole.headCoach,
          0.0,
          irrelevantValue: 5.0,
        ),
      ),
    );
    expect(
      ratingMutation.totalSalary,
      staff.totalSalary,
      reason: 'payroll must not be reconstructed from raw or displayed rating',
    );

    final emptyHeadCoach = teamStaffWithEmptySlot(
      ratingMutation,
      StaffRole.headCoach,
    );
    expect(emptyHeadCoach.member(StaffRole.headCoach), isNull);
    expect(emptyHeadCoach.totalSalary, scout.contract!.salary);
    expect(
      teamStaffWithEmptySlot(emptyHeadCoach, StaffRole.scout).totalSalary,
      0,
      reason: 'an empty/unavailable staff slot must not generate cost',
    );
  });

  test(
    'expired staff contracts leave slots and payroll without duplicates',
    () {
      final expired = staffMemberFor(
        StaffRole.headCoach,
        contract: staffFixtureContract(salary: 1400000, yearsRemaining: 0),
        id: 'expired-staff',
      );
      final active = staffMemberFor(
        StaffRole.scout,
        contract: staffFixtureContract(salary: 2100000, yearsRemaining: 2),
        id: 'active-staff',
      );
      final league = staffFixtureLeague(
        teams: [
          staffFixtureTeam(
            staff: teamStaffOf({
              StaffRole.headCoach: expired,
              StaffRole.scout: active,
            }),
          ),
        ],
      );

      final service = SeasonService();
      final expiredState = service.expireContracts(league);
      final expiredTeam = expiredState.playerTeam!;

      expect(expiredTeam.staff.headCoach, isNull);
      expect(expiredTeam.staff.scout!.id, active.id);
      expect(expiredTeam.staff.totalSalary, active.contract!.salary);
      expect(
        expiredState.staffFreeAgents.where((member) => member.id == expired.id),
        hasLength(1),
      );
      expect(
        expiredState.staffFreeAgents
            .singleWhere((member) => member.id == expired.id)
            .contract,
        isNull,
      );

      final repeated = service.expireContracts(expiredState);
      expect(repeated.playerTeam!.staff.totalSalary, active.contract!.salary);
      expect(
        repeated.staffFreeAgents.where((member) => member.id == expired.id),
        hasLength(1),
        reason: 'contract expiry must be idempotent',
      );
    },
  );
}
