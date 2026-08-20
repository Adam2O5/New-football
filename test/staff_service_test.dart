import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/staff_service.dart';

void main() {
  const balance = BalanceConfig.defaults;

  test(
    'growthChanceForAge / retireChanceForAge stay within documented ranges',
    () {
      expect(balance.staff.growthChanceForAge(35), closeTo(0.22, 0.001));
      expect(balance.staff.growthChanceForAge(45), closeTo(0.14, 0.001));
      expect(balance.staff.growthChanceForAge(34), 0);
      expect(balance.staff.growthChanceForAge(46), 0);
      expect(balance.staff.retireChanceForAge(54), 0);
      expect(balance.staff.retireChanceForAge(55), closeTo(0.12, 0.001));
      expect(balance.staff.retireChanceForAge(60), 1.0);
    },
  );

  test('salaryFor scales with role weight and stars', () {
    final hcElite = balance.staff.salaryFor(StaffRole.headCoach, 5.0);
    final cfoElite = balance.staff.salaryFor(StaffRole.cfo, 5.0);
    final hcWeak = balance.staff.salaryFor(StaffRole.headCoach, 1.0);
    expect(hcElite, greaterThan(cfoElite));
    expect(hcElite, greaterThan(hcWeak));
  });

  test('StaffService.hire rejects offers exceeding the staff salary cap', () {
    final svc = StaffService(random: Random(1));
    var team = SeedDataGenerator().generateLeague(seed: 3).teams.first;
    final member = SeedDataGenerator().generateStaffMember(
      Random(1),
      StaffRole.headCoach,
    );
    final tooExpensive = StaffOffer(
      salary: balance.staff.salaryCap + 1,
      years: 3,
    );
    final hired = svc.hire(team: team, member: member, offer: tooExpensive);
    expect(hired, isNull);

    const affordable = StaffOffer(salary: 1000000, years: 3);
    final ok = svc.hire(team: team, member: member, offer: affordable);
    expect(ok, isNotNull);
    expect(ok!.staff.headCoach?.id, member.id);
  });

  test('StaffService.hire rejects when role slot already filled', () {
    final svc = StaffService();
    var team = SeedDataGenerator().generateLeague(seed: 4).teams.first;
    final a = SeedDataGenerator().generateStaffMember(Random(2), StaffRole.cfo);
    final b = SeedDataGenerator().generateStaffMember(Random(3), StaffRole.cfo);
    const offer = StaffOffer(salary: 500000, years: 2);
    final withA = svc.hire(team: team, member: a, offer: offer)!;
    final withB = svc.hire(team: withA, member: b, offer: offer);
    expect(withB, isNull);
  });

  test(
    'growthAndRetireTick eventually grows or retires an aged staff member',
    () {
      final league = SeedDataGenerator().generateLeague(seed: 5);
      var team = league.teams.first;
      const oldCoach = StaffMember(
        id: 'old_hc',
        name: 'Old Coach',
        nationality: Nationality.poland,
        age: 59,
        role: StaffRole.headCoach,
        attributes: StaffAttributes(tactics: 2.0),
        contract: StaffContract(salary: 1000000, yearsRemaining: 2),
      );
      team = team.copyWith(staff: team.staff.copyWith(headCoach: oldCoach));
      var state = league.updateTeam(team);
      // Age 59 → 75% retire chance; run several trials, at least one retires.
      var anyRetired = false;
      for (var i = 0; i < 20; i++) {
        final svc = StaffService(random: Random(i));
        final result = svc.growthAndRetireTick(state);
        if (result.teamById(team.id)!.staff.headCoach == null) {
          anyRetired = true;
          break;
        }
      }
      expect(anyRetired, isTrue);
    },
  );

  test('legacy headCoach development does not change player growth', () {
    final league = SeedDataGenerator().generateLeague(seed: 6);
    final team = league.teams.first;
    const legacyHc = StaffMember(
      id: 'legacy_hc',
      name: 'Legacy Coach',
      nationality: Nationality.spain,
      age: 40,
      role: StaffRole.headCoach,
      attributes: StaffAttributes(
        tactics: 3.0,
        motivation: 2.5,
        development: 5.0,
      ),
    );
    final inertHc = legacyHc.copyWith(
      attributes: legacyHc.attributes.copyWith(development: 0.0),
    );

    final withLegacy = team.copyWith(
      staff: team.staff.copyWith(headCoach: legacyHc),
    );
    final withoutLegacy = team.copyWith(
      staff: team.staff.copyWith(headCoach: inertHc),
    );

    final grownWithLegacy = DevelopmentService(
      random: Random(42),
    ).developTeam(withLegacy);
    final grownWithoutLegacy = DevelopmentService(
      random: Random(42),
    ).developTeam(withoutLegacy);

    double totalProgress(Team team) => team.roster.fold<double>(
      0.0,
      (sum, p) => sum + p.hidden.overallProgress,
    );

    expect(totalProgress(grownWithLegacy), totalProgress(grownWithoutLegacy));
  });

  test(
    'contract calculations use canonical raw role rating, not displayed rating',
    () {
      final service = StaffService();
      const member = StaffMember(
        id: 'raw-contract-member',
        name: 'Raw Contract Member',
        nationality: Nationality.poland,
        age: 40,
        role: StaffRole.headCoach,
        attributes: StaffAttributes(
          tactics: 4.5,
          motivation: 3.0,
          development: 0.0,
        ),
      );
      final irrelevantMutation = member.copyWith(
        attributes: member.attributes.copyWith(development: 5.0),
      );
      const offer = StaffOffer(salary: 2500000, years: 3);

      // 4.5 and 3.0 produce RawOverall 3.75. A presentation round to 4.0
      // must not be used by any contract calculation.
      expect(member.overall, 3.75);
      expect(service.staffWant(member), 75.0);
      expect(
        service.marketSalary(member),
        balance.staff.salaryFor(StaffRole.headCoach, 3.75),
      );
      final expectedSalary =
          balance.staff.minSalary +
          (balance.staff.maxSalary - balance.staff.minSalary) * 0.75 * 0.75;
      expect(service.expectedSalary(member), expectedSalary.round());
      expect(service.expectedLength(member), 4);

      final rawBreakdown = service.staffOfferBreakdown(
        member,
        offer,
        cfoNegotiation: 4.0,
      );
      final irrelevantBreakdown = service.staffOfferBreakdown(
        irrelevantMutation,
        offer,
        cfoNegotiation: 4.0,
      );
      expect(irrelevantBreakdown.salaryFit, rawBreakdown.salaryFit);
      expect(irrelevantBreakdown.lengthFit, rawBreakdown.lengthFit);
      expect(irrelevantBreakdown.cfoDiscount, rawBreakdown.cfoDiscount);
      expect(
        service.staffOfferScore(irrelevantMutation, offer, cfoNegotiation: 4.0),
        rawBreakdown.score,
      );
      final rawCounter = service.counterOfferForRound(
        member,
        offer,
        round: 1,
        cfoNegotiation: 4.0,
      );
      final irrelevantCounter = service.counterOfferForRound(
        irrelevantMutation,
        offer,
        round: 1,
        cfoNegotiation: 4.0,
      );
      expect(irrelevantCounter, isNotNull);
      expect(rawCounter, isNotNull);
      expect(irrelevantCounter!.salary, rawCounter!.salary);
      expect(irrelevantCounter.years, rawCounter.years);
      expect(
        service.evaluateOffer(
          irrelevantMutation,
          offer,
          cfoNegotiation: 4.0,
          random: Random(7),
        ),
        service.evaluateOffer(
          member,
          offer,
          cfoNegotiation: 4.0,
          random: Random(7),
        ),
      );
    },
  );

  test('contract rating inputs remain finite and within documented bounds', () {
    final service = StaffService();
    const malformed = StaffMember(
      id: 'malformed-contract-member',
      name: 'Malformed Contract Member',
      nationality: Nationality.poland,
      age: 40,
      role: StaffRole.headCoach,
      attributes: StaffAttributes(
        tactics: double.nan,
        motivation: double.infinity,
        development: double.negativeInfinity,
      ),
    );

    final marketSalary = service.marketSalary(malformed);
    final want = service.staffWant(
      malformed,
      currentTeamStatus: TeamStatus.elite,
    );
    final expectedSalary = service.expectedSalary(
      malformed,
      currentTeamStatus: TeamStatus.elite,
    );
    final expectedLength = service.expectedLength(
      malformed,
      currentTeamStatus: TeamStatus.elite,
    );
    final breakdown = service.staffOfferBreakdown(
      malformed,
      StaffOffer(salary: expectedSalary, years: expectedLength),
      cfoNegotiation: double.nan,
    );
    final counter = service.counterOfferForRound(
      malformed,
      StaffOffer(salary: expectedSalary, years: expectedLength),
      round: 1,
      cfoNegotiation: double.infinity,
    );

    expect(marketSalary.isFinite, isTrue);
    expect(
      marketSalary,
      inInclusiveRange(balance.staff.minSalary, balance.staff.maxSalary),
    );
    expect(want.isFinite, isTrue);
    expect(want, inInclusiveRange(0, 100));
    expect(
      expectedSalary,
      inInclusiveRange(balance.staff.minSalary, balance.staff.maxSalary),
    );
    expect(expectedLength, inInclusiveRange(1, 4));
    expect(breakdown.score.isFinite, isTrue);
    expect(breakdown.score, inInclusiveRange(0, 100));
    expect(counter, isNotNull);
    expect(
      counter!.salary,
      inInclusiveRange(balance.staff.minSalary, balance.staff.maxSalary),
    );
    expect(service.cfoDiscount(negotiation: double.nan), 0.95);
    expect(service.cfoDiscount(negotiation: double.infinity), 1.13);
  });
}
