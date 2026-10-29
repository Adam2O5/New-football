@Tags(['unit'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import '../helpers/market/staff_negotiation_harness.dart';

void main() {
  for (final role in StaffRole.values) {
    test(
      '${role.name}: market phases preserve canonical score, stale recompute, waiting counter and replay',
      () {
        verifyStaffMarketScenarios(role);
      },
    );
    test(
      '${role.name}: market distinguishes raw 3.25 and 3.30 with equal displayed rating',
      () {
        verifyStaffMarketCollision(role);
      },
    );
  }
}
