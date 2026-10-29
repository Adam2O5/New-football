@Tags(['long', 'slow', 'integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/seed_data_generator.dart';

import '../../helpers/generation/initial_roster_assertions.dart';

void main() {
  test(
    'seeded formation frequencies stay within documented finite-sample tolerance',
    () {
      const maxSeedExclusive = 64;
      final counts = <Formation, int>{
        for (final formation in Formation.values) formation: 0,
      };
      var sampleSize = 0;

      for (var seed = 0; seed < maxSeedExclusive; seed++) {
        final league = SeedDataGenerator().generateLeague(seed: seed);
        for (final team in league.teams) {
          expectInitialTeamInvariant(team, seed);
          counts[team.tactics.formation] = counts[team.tactics.formation]! + 1;
          sampleSize++;
        }
        if ((seed + 1) % 8 == 0) {
          stdout.writeln(
            'formation distribution: seed=$seed completed=${seed + 1}/64 N=$sampleSize',
          );
        }
      }

      expect(
        counts.values.every((count) => count > 0),
        isTrue,
        reason: 'Every current formation must occur: $counts',
      );
      // A finite random sample is not expected to give exact equality. The
      // documented reproducible check allows ±40% around N/21 for N=30*64.
      final expected = sampleSize / Formation.values.length;
      final tolerance = expected * 0.40;
      final lowerBound = (expected - tolerance).floor();
      final upperBound = (expected + tolerance).ceil();
      for (final formation in Formation.values) {
        expect(
          counts[formation],
          inInclusiveRange(lowerBound, upperBound),
          reason:
              'formation=${formation.name} N=$sampleSize expected=$expected '
              'tolerance=±$tolerance seedRange=0..${maxSeedExclusive - 1} '
              'counts=$counts',
        );
      }
    },
  );
}
