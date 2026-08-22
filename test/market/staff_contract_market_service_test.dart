import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/staff_service.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

void main() {
  test(
    'submitStaffOffer scores the state-owned candidate, not stale UI data',
    () {
      final actualCandidate = staffMemberFor(
        StaffRole.headCoach,
        relevantValues: [4.5, 3.0],
        id: 'market-actual-staff',
        name: 'Actual staff member',
      );
      final staleUiCandidate = actualCandidate.copyWith(
        name: 'Stale UI staff member',
        attributes: staffAttributesForRole(StaffRole.headCoach, [
          1.0,
          1.0,
        ], irrelevantValue: 5.0),
      );
      final team = staffFixtureTeam();
      final league = staffFixtureLeague(
        teams: [team],
        staffFreeAgents: [actualCandidate],
      );
      const offer = StaffOffer(salary: staffFixtureSalary, years: 3);
      final market = ContractMarketService();

      final result = market.submitStaffOffer(
        league: league,
        candidate: staleUiCandidate,
        offer: offer,
        saveSeed: staffFixtureSaveSeed,
      );

      expect(result, isNotNull);
      final negotiation = result!.league.negotiations.single;
      final expectedScore = StaffService().staffOfferScore(
        actualCandidate,
        offer,
        offeringTeamStatus: TeamStatus.pretender,
        currentTeamStatus: TeamStatus.pretender,
      );
      expect(negotiation.subjectId, actualCandidate.id);
      expect(negotiation.offerScore, expectedScore);
      expect(
        negotiation.offerScore,
        isNot(StaffService().staffOfferScore(staleUiCandidate, offer)),
      );
    },
  );

  test('staff score recomputation uses the current role-specific member', () {
    final candidate = staffMemberFor(
      StaffRole.scout,
      relevantValues: [4.5, 3.5],
      id: 'market-recompute-staff',
    );
    final team = staffFixtureTeam();
    final offer = staffOfferFor(candidate, salaryFactor: 0.9);
    final negotiation = NegotiationService()
        .start(
          id: 'staff-recompute-negotiation',
          subjectId: candidate.id,
          subjectKind: NegotiationSubjectKind.staff,
          teamId: team.id,
          phase: NegotiationPhase.freeAgencyPhaseI,
          offer: NegotiationOffer(salary: offer.salary, years: offer.years),
          seasonYear: staffFixtureSeasonYear,
          week: staffFixtureFreeAgencyWeek(),
          day: 1,
          hour: 1,
          // This stale persisted value must not win over StaffService's raw
          // calculation when the market resolves the pending offer.
          offerScore: 1.0,
        )
        .copyWith(
          status: NegotiationStatus.pendingFinalization,
          requiresFinalization: true,
        );
    final league = staffFixtureLeague(
      teams: [team],
      staffFreeAgents: [candidate],
      negotiations: [negotiation],
    );
    final resolved = ContractMarketService().resolveHour(
      league,
      hour: 1,
      saveSeed: staffFixtureSaveSeed,
    );

    final updated = resolved.negotiationById(negotiation.id);
    final expectedScore = StaffService().staffOfferScore(
      candidate,
      offer,
      offeringTeamStatus: TeamStatus.pretender,
      currentTeamStatus: TeamStatus.pretender,
    );
    expect(updated, isNotNull);
    expect(updated!.offerScore, expectedScore);
    expect(updated.offerScore, isNot(1.0));
  });

  test('extension offers reject a member stored in a mismatched team slot', () {
    final mismatchedMember = staffMemberFor(
      StaffRole.doctor,
      relevantValues: [3.0, 3.0],
      id: 'market-mismatched-staff',
      contract: staffFixtureContract(yearsRemaining: 1),
    );
    final team = staffFixtureTeam(
      staff: TeamStaff(headCoach: mismatchedMember),
    );
    final league = staffFixtureLeague(
      teams: [team],
      currentWeek: staffFixtureExtensionWeek(),
      currentDay: 2,
      currentHour: 1,
    );

    final result = ContractMarketService().submitStaffOffer(
      league: league,
      candidate: mismatchedMember,
      offer: staffFixtureOffer(),
      saveSeed: staffFixtureSaveSeed,
    );

    expect(result, isNull);
  });
}
