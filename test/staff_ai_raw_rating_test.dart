import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/staff_service.dart';

import 'helpers/staff_role_ratings_test_helpers.dart';

void main() {
  test(
    'staff free-agent plans rank raw role ratings and use StaffService terms',
    () {
      final role = StaffRole.headCoach;
      final high = staffMemberFor(
        role,
        id: 'z-high-raw',
        attributes: staffAttributesWithRawOverall(
          role,
          3.30,
          irrelevantValue: 5.0,
        ),
      );
      final low = staffMemberFor(
        role,
        id: 'a-low-raw',
        attributes: staffAttributesWithRawOverall(
          role,
          3.26,
          irrelevantValue: 0.0,
        ),
      );
      final team = staffFixtureTeam(staff: const TeamStaff());
      final league = staffFixtureLeague(
        teams: [team],
        staffFreeAgents: [low, high],
      );
      final policy = AiContractMarketService();
      final plan = policy.staffFreeAgentPlan(
        league: league,
        team: team,
        saveSeed: staffFixtureSeed,
      );

      expect(plan, isNotNull);
      expect(plan!.member.id, high.id);
      expect(plan.role, role);

      final staff = StaffService();
      final expectedScore = staff.staffOfferScore(
        high,
        plan.offer,
        offeringTeamStatus: TeamStatus.pretender,
        currentTeamStatus: TeamStatus.pretender,
      );
      expect(plan.offerScore, closeTo(expectedScore, 1e-9));
      expect(
        plan.offer.years,
        staff
            .expectedLength(high, currentTeamStatus: TeamStatus.pretender)
            .clamp(1, 4),
      );

      final irrelevantMutation = high.copyWith(
        attributes: withIrrelevantStaffAttribute(
          high.attributes,
          role,
          value: 0.0,
        ),
      );
      final mutatedLeague = staffFixtureLeague(
        teams: [team],
        staffFreeAgents: [low, irrelevantMutation],
      );
      final mutatedPlan = policy.staffFreeAgentPlan(
        league: mutatedLeague,
        team: team,
        saveSeed: staffFixtureSeed,
      );
      expect(mutatedPlan, isNotNull);
      expect(mutatedPlan!.member.id, plan.member.id);
      expect(mutatedPlan.offer.salary, plan.offer.salary);
      expect(mutatedPlan.offer.years, plan.offer.years);
      expect(mutatedPlan.offerScore, closeTo(plan.offerScore, 1e-9));
    },
  );

  test('a CFO subject is not passed back as its own assisting CFO', () {
    final subject = staffCfoMember(
      negotiation: 2.0,
      irrelevantValue: 5.0,
      contract: const StaffContract(salary: 1000000, yearsRemaining: 1),
    );
    final team = staffFixtureTeam(staff: TeamStaff(cfo: subject));
    final league = staffFixtureLeague(
      teams: [team],
      playerTeamId: null,
      currentWeek: staffFixtureExtensionWeek(),
    );
    final policy = AiContractMarketService();
    AiStaffOfferPlan? plan;
    for (var saveSeed = 0; saveSeed < 200; saveSeed++) {
      plan = policy.staffExtensionPlan(
        league: league,
        team: team,
        saveSeed: saveSeed,
      );
      if (plan != null) break;
    }

    expect(plan, isNotNull);
    expect(plan!.member.id, subject.id);
    expect(plan.role, StaffRole.cfo);

    final staff = StaffService();
    final withoutAssistingCfo = staff.staffOfferScore(
      subject,
      plan.offer,
      offeringTeamStatus: TeamStatus.pretender,
      currentTeamStatus: TeamStatus.pretender,
      cfo: null,
    );
    final incorrectlySelfAssisted = staff.staffOfferScore(
      subject,
      plan.offer,
      offeringTeamStatus: TeamStatus.pretender,
      currentTeamStatus: TeamStatus.pretender,
      cfo: subject,
    );
    expect(plan.offerScore, closeTo(withoutAssistingCfo, 1e-9));
    expect(incorrectlySelfAssisted, greaterThan(withoutAssistingCfo));
  });
}
