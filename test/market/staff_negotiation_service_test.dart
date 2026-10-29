@Tags(['unit'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';

import '../helpers/market/staff_contract_oracle.dart';

void main() {
  group(staffContractPropertyTag, () {
    for (final role in StaffRole.values) {
      test('${role.name}: $staffContractCasesPerRole seeded contract consumers use only '
          'canonical RawOverall', () {
        final seed = staffContractSeedFor(role);
        final scenarios = staffContractScenariosForRole(role, seed);

        expect(
          scenarios,
          hasLength(staffContractCasesPerRole),
          reason: staffContractScenarioReason(
            role: role,
            seed: seed,
            caseIndex: -1,
            scenario: scenarios.isEmpty
                ? staffContractScenarioForRole(role, 0, Random(seed))
                : scenarios.first,
          ),
        );
        for (final status in TeamStatus.values) {
          expect(
            scenarios.any(
              (scenario) =>
                  scenario.offeringTeamStatus == status ||
                  scenario.currentTeamStatus == status,
            ),
            isTrue,
            reason:
                '$staffContractPropertyTag role=${role.name} seed=$seed: '
                'status ${status.name} was not exercised',
          );
        }
        expect(
          scenarios.any((scenario) => scenario.cfo == null),
          isTrue,
          reason:
              '$staffContractPropertyTag role=${role.name} seed=$seed: no-CFO input '
              'was not exercised',
        );
        expect(
          scenarios.any((scenario) => scenario.cfo != null),
          isTrue,
          reason:
              '$staffContractPropertyTag role=${role.name} seed=$seed: assisting CFO '
              'input was not exercised',
        );

        for (var caseIndex = 0; caseIndex < scenarios.length; caseIndex++) {
          final scenario = scenarios[caseIndex];
          final reason = staffContractScenarioReason(
            role: role,
            seed: seed,
            caseIndex: caseIndex,
            scenario: scenario,
          );
          expectStaffContractConsumers(scenario, reason: reason);
        }
      });
    }
  });
}
