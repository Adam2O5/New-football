@Tags(['unit'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/prospect_service.dart';

import '../helpers/fixtures/game_fixtures.dart';

void main() {
  for (final teamId in [
    null,
    'team_europe_0',
    'team_europe_3',
    'team_restOfTheWorld_15',
  ]) {
    test('exactly one controlled club for $teamId', () {
      final league = SeedDataGenerator().generateLeague(
        seed: fixtureSeed,
        playerTeamId: teamId,
      );
      expect(
        league.teams
            .where((t) => t.isPlayerControlled)
            .map((t) => t.id)
            .toList(),
        [teamId ?? 'team_europe_0'],
      );
      expect(league.playerTeamId, teamId ?? 'team_europe_0');
    });
  }
  test('initial and next draft classes ignore unseeded service history', () {
    final generator = SeedDataGenerator(random: Random(1));
    final first = generator.generateLeague(seed: fixtureSeed);
    generator.generateDraftClass(year: 2035);
    expect(generator.generateLeague(seed: fixtureSeed) == first, isTrue);
    final service = ProspectService(random: Random(2));
    final next = service.generateNextDraftClass(
      currentYear: 2026,
      seed: fixtureSeed,
    );
    service.generateNextDraftClass(currentYear: 2035);
    expect(
      service.generateNextDraftClass(currentYear: 2026, seed: fixtureSeed),
      next,
    );
    expect(
      ProspectService(
        random: Random(9),
      ).generateNextDraftClass(currentYear: 2026, seed: fixtureSeed),
      next,
    );
    expect(
      ProspectService().generateNextDraftClass(
            currentYear: 2026,
            seed: fixtureSeed + 1,
          ) ==
          next,
      isFalse,
    );
  });
}
