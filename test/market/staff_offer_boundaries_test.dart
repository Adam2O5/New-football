@Tags(['unit'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/staff_service.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

import '../helpers/market/staff_contract_oracle.dart';

void main() {
  group(staffContractPropertyTag, () {
    // **Validates: Requirements 2.7, 6.1, 6.2, 6.3, 6.4, 7.1, 7.2, 7.3**
    test('raw 3.25 and 3.5 share DisplayedRating but produce distinct '
        'contract and negotiation results', () {
      for (final role in StaffRole.values) {
        final low = staffContractBoundaryScenario(
          role,
          raw: 3.25,
          id: 'p7_boundary_low_${role.name}',
          seed: staffContractPropertySeed + role.index * 1009 + 1,
        );
        final high = staffContractBoundaryScenario(
          role,
          raw: 3.5,
          id: 'p7_boundary_high_${role.name}',
          seed: staffContractPropertySeed + role.index * 1009 + 2,
        );
        final highEdge = staffContractBoundaryScenario(
          role,
          raw: 3.75,
          id: 'p7_boundary_high_edge_${role.name}',
          seed: staffContractPropertySeed + role.index * 1009 + 3,
        );
        final lowObserved = observeStaffContract(
          low,
          low.member,
          reason: '$staffContractPropertyTag role=${role.name} raw=3.25',
        );
        final highObserved = observeStaffContract(
          high,
          high.member,
          reason: '$staffContractPropertyTag role=${role.name} raw=3.5',
        );
        final highEdgeObserved = observeStaffContract(
          highEdge,
          highEdge.member,
          reason: '$staffContractPropertyTag role=${role.name} raw=3.75',
        );

        expect(
          expectedStaffDisplayedRating(low.member.overall),
          3.5,
          reason:
              '$staffContractPropertyTag role=${role.name}: 3.25 display oracle',
        );
        expect(
          expectedStaffDisplayedRating(high.member.overall),
          3.5,
          reason:
              '$staffContractPropertyTag role=${role.name}: 3.5 display oracle',
        );
        expect(
          expectedStaffDisplayedRating(highEdge.member.overall),
          4.0,
          reason:
              '$staffContractPropertyTag role=${role.name}: 3.75 display oracle',
        );
        expect(
          StaffPresentation.viewForMember(low.member).rating!.displayedRating,
          StaffPresentation.viewForMember(high.member).rating!.displayedRating,
          reason:
              '$staffContractPropertyTag role=${role.name}: display bucket changed the '
              'domain comparison setup',
        );

        expect(
          lowObserved.marketSalary,
          isNot(highObserved.marketSalary),
          reason:
              '$staffContractPropertyTag role=${role.name}: marketSalary ignored raw '
              'precision at the 3.25/3.5 display tie',
        );
        expect(
          lowObserved.staffWant,
          isNot(highObserved.staffWant),
          reason:
              '$staffContractPropertyTag role=${role.name}: staffWant ignored raw '
              'precision at the 3.25/3.5 display tie',
        );
        expect(
          lowObserved.expectedSalary,
          isNot(highObserved.expectedSalary),
          reason:
              '$staffContractPropertyTag role=${role.name}: expectedSalary ignored raw '
              'precision at the 3.25/3.5 display tie',
        );
        expect(lowObserved.expectedLength, 3);
        expect(highObserved.expectedLength, 4);
        expect(
          lowObserved.breakdown.score,
          isNot(highObserved.breakdown.score),
          reason:
              '$staffContractPropertyTag role=${role.name}: offer score ignored raw '
              'precision at the 3.25/3.5 display tie',
        );
        expect(
          lowObserved.reaction,
          StaffReaction.counter,
          reason:
              '$staffContractPropertyTag role=${role.name}: raw 3.25 boundary should '
              'reach the counter band',
        );
        expect(
          highObserved.reaction,
          StaffReaction.reject,
          reason:
              '$staffContractPropertyTag role=${role.name}: raw 3.5 boundary should '
              'reach the reject band for the fixed offer',
        );
        expectStaffCounterOffersDifferent(
          lowObserved.counter,
          highObserved.counter,
          reason:
              '$staffContractPropertyTag role=${role.name}: counter offer ignored raw '
              'precision',
        );
        expect(
          lowObserved.persistedScore,
          isNot(highObserved.persistedScore),
          reason:
              '$staffContractPropertyTag role=${role.name}: persisted market score '
              'ignored raw precision',
        );
        expect(
          highEdgeObserved.expectedSalary,
          isNot(highObserved.expectedSalary),
          reason:
              '$staffContractPropertyTag role=${role.name}: 3.75 edge did not reach a '
              'different raw contract band',
        );
      }
    });

    // **Validates: Requirements 6.7, 7.3**
    test('salary boundaries and invalid counter rounds remain safe for every '
        'role', () {
      for (final role in StaffRole.values) {
        for (final raw in [0.0, 5.0]) {
          final member = staffMemberFor(
            role,
            attributes: staffAttributesWithRawOverall(
              role,
              raw,
              spread:
                  relevantStaffAttributeNames(role).length == 1 ||
                      raw == 0.0 ||
                      raw == 5.0
                  ? 0.0
                  : 0.25,
              irrelevantValue: 5.0,
            ),
            id: 'p7_edge_${role.name}_${raw.toStringAsFixed(1)}',
            age: 60,
          );
          final service = StaffService(
            random: Random(staffContractPropertySeed),
          );
          final reason =
              '$staffContractPropertyTag role=${role.name} raw=$raw seed=$staffContractPropertySeed';

          expect(member.overall, raw, reason: reason);
          expect(
            service.marketSalary(member),
            inInclusiveRange(
              BalanceConfig.defaults.staff.minSalary,
              BalanceConfig.defaults.staff.maxSalary,
            ),
            reason: '$reason: market salary escaped legal bounds',
          );
          expect(
            service.expectedSalary(member),
            inInclusiveRange(
              BalanceConfig.defaults.staff.minSalary,
              BalanceConfig.defaults.staff.maxSalary,
            ),
            reason: '$reason: expected salary escaped legal bounds',
          );
          expect(
            service.expectedLength(member),
            1,
            reason: '$reason: age 60 should use the one-year band',
          );
          expect(
            service.counterOfferForRound(
              member,
              staffFixtureOffer(salary: BalanceConfig.defaults.staff.minSalary),
              round: 0,
            ),
            isNull,
            reason: '$reason: round 0 must not create a counter offer',
          );
          expect(
            service.counterOfferForRound(
              member,
              staffFixtureOffer(salary: BalanceConfig.defaults.staff.maxSalary),
              round: BalanceConfig.defaults.contracts.maxCounterRounds + 1,
            ),
            isNull,
            reason: '$reason: an exhausted round must not create a counter',
          );
        }
      }
    });
  });
}
