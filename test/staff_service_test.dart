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

  test('growthChanceForAge / retireChanceForAge stay within documented ranges', () {
    expect(balance.staff.growthChanceForAge(35), closeTo(0.22, 0.001));
    expect(balance.staff.growthChanceForAge(45), closeTo(0.14, 0.001));
    expect(balance.staff.growthChanceForAge(34), 0);
    expect(balance.staff.growthChanceForAge(46), 0);

    expect(balance.staff.retireChanceForAge(54), 0);
    expect(balance.staff.retireChanceForAge(55), closeTo(0.12, 0.001));
    expect(balance.staff.retireChanceForAge(60), 1.0);
  });

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
    final a = SeedDataGenerator().generateStaffMember(
      Random(2),
      StaffRole.cfo,
    );
    final b = SeedDataGenerator().generateStaffMember(
      Random(3),
      StaffRole.cfo,
    );
    const offer = StaffOffer(salary: 500000, years: 2);
    final withA = svc.hire(team: team, member: a, offer: offer)!;
    final withB = svc.hire(team: withA, member: b, offer: offer);
    expect(withB, isNull);
  });

  test('growthAndRetireTick eventually grows or retires an aged staff member', () {
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
  });

  test('DevelopmentService boosts growth with a strong Head Coach', () {
    final league = SeedDataGenerator().generateLeague(seed: 6);
    var team = league.teams.first;
    const strongHc = StaffMember(
      id: 'strong_hc',
      name: 'Strong Coach',
      nationality: Nationality.spain,
      age: 40,
      role: StaffRole.headCoach,
      attributes: StaffAttributes(development: 5.0),
    );
    final withHc = team.copyWith(staff: team.staff.copyWith(headCoach: strongHc));
    final without = team.copyWith(staff: const TeamStaff());

    final dev = DevelopmentService(random: Random(42));
    final devNoStaff = DevelopmentService(random: Random(42));

    final grownWith = dev.developTeam(withHc);
    final grownWithout = devNoStaff.developTeam(without);

    double totalProgress(Team team) => team.roster.fold<double>(
      0.0,
      (sum, p) => sum + p.hidden.overallProgress,
    );

    expect(totalProgress(grownWith), greaterThanOrEqualTo(totalProgress(grownWithout)));
  });
}
