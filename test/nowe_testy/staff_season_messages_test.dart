import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/core/services/message_text_service.dart';

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
      for (final message in result.inbox.messages) {
        for (final language in ['pl', 'en']) {
          final text = MessageTextService.resolve(
            message,
            languageCode: language,
          );
          expect(text.body, contains(member.name));
          expect(text.body, isNot(contains('{')));
        }
      }
      if (age == 35) {
        final message = result.inbox.messages.last;
        expect(message.args['previousRating'], member.overall);
        expect(message.args['rating'], result.playerTeam!.staff.scout!.overall);
        expect(message.payload['attributeChanges'], isNotEmpty);
      }
    });
  }
}
