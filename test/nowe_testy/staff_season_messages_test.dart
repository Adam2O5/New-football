import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/staff_service.dart';

import 'support/game_fixtures.dart';

class _SuccessfulRoll implements Random {
  @override
  double nextDouble() => 0;
  @override
  bool nextBool() => false;
  @override
  int nextInt(int max) => 0;
}

void main() {
  for (final age in [35, 60]) {
    test('staff seasonal event at age $age creates a valid message', () {
      final league = beforeRollover();
      final team = league.playerTeam!;
      final member = team.staff.scout!.copyWith(age: age);
      final input = league.updateTeam(
        team.copyWith(staff: team.staff.withMember(StaffRole.scout, member)),
      );
      final result = StaffService(
        random: _SuccessfulRoll(),
      ).growthAndRetireTick(input);
      if (age == 60) {
        expect(result.playerTeam!.staff.scout, isNull);
      } else {
        expect(
          result.playerTeam!.staff.scout!.attributes,
          isNot(member.attributes),
        );
      }
      expect(
        result.inbox.messages.length,
        greaterThan(input.inbox.messages.length),
      );
    });
  }
}
