@Tags(['unit'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import '../helpers/staff_role_ratings_test_helpers.dart';

void main() {
  for (final role in StaffRole.values) {
    test(
      '${role.name}: only a state-owned candidate can fill the empty role',
      () {
        final occupiedRole =
            StaffRole.values[(role.index + 1) % StaffRole.values.length];
        final employed = staffMemberFor(
          occupiedRole,
          id: 'employed',
          contract: staffFixtureContract(),
        );
        final target = staffMemberFor(role, id: 'target');
        final occupiedCandidate = staffMemberFor(
          occupiedRole,
          id: 'occupied-candidate',
        );
        final team = staffFixtureTeam(
          staff: const TeamStaff().withMember(occupiedRole, employed),
        );
        final league = staffFixtureLeague(
          teams: [team],
          staffFreeAgents: [target, occupiedCandidate],
        );
        final market = ContractMarketService();
        final offer = staffFixtureOffer();
        expect(
          market.submitStaffOffer(
            league: league,
            candidate: occupiedCandidate,
            offer: offer,
            saveSeed: staffFixtureSaveSeed,
          ),
          isNull,
        );
        expect(
          market.submitStaffOffer(
            league: league,
            candidate: target.copyWith(id: 'forged'),
            offer: offer,
            saveSeed: staffFixtureSaveSeed,
          ),
          isNull,
        );
        final result = market.submitStaffOffer(
          league: league,
          candidate: target,
          offer: offer,
          saveSeed: staffFixtureSaveSeed,
        );
        expect(result, isNotNull);
        expect(
          result!.league.negotiations.where(
            (item) => item.subjectId == target.id,
          ),
          hasLength(1),
        );
        expect(result.league.playerTeam!.staff.member(role), isNull);
        expect(
          result.league.playerTeam!.staff.totalSalary,
          employed.contract!.salary,
        );
        final missing = league.copyWith(staffFreeAgents: const []);
        expect(
          market.submitStaffOffer(
            league: missing,
            candidate: target,
            offer: offer,
            saveSeed: staffFixtureSaveSeed,
          ),
          isNull,
        );
        final negotiation = ContractNegotiation(
          id: 'missing-member',
          subjectId: target.id,
          subjectKind: NegotiationSubjectKind.staff,
          teamId: team.id,
          phase: NegotiationPhase.freeAgencyPhaseI,
          lastOffer: NegotiationOffer(salary: offer.salary, years: offer.years),
          status: NegotiationStatus.pendingFinalization,
          requiresFinalization: true,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          day: league.currentDay,
          hour: league.currentHour ?? 1,
          expirySeasonYear: league.currentSeason.year,
          expiryWeek: league.currentWeek,
          expiryDay: league.currentDay,
          expiryHour: league.currentHour ?? 1,
        );
        final pending = missing.copyWith(negotiations: [negotiation]);
        expect(
          market.finalizeNegotiation(
            pending,
            negotiation.id,
            saveSeed: staffFixtureSaveSeed,
          ),
          isNull,
        );
        expect(pending.playerTeam!.staff.member(role), isNull);
        expect(
          pending.playerTeam!.staff.totalSalary,
          employed.contract!.salary,
        );
      },
    );
  }
}
