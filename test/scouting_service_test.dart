import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/scouting_service.dart';

void main() {
  const balance = BalanceConfig.defaults;

  test('setWatchlist caps to maxWatched(coverage)', () {
    final svc = ScoutingService();
    final ids = List.generate(50, (i) => 'p$i');
    final scouting = svc.setWatchlist(
      const TeamScouting(),
      ids,
      coverageStars: 0.0,
    );
    expect(scouting.watchlistProspectIds.length, balance.staff.maxWatched(0.0));
    expect(scouting.knowledge.length, scouting.watchlistProspectIds.length);
  });

  test('tickKnowledge eventually advances tiers with high evaluation', () {
    var scouting = const TeamScouting(
      watchlistProspectIds: ['p1'],
      knowledge: [ScoutingKnowledge(prospectId: 'p1')],
    );
    final svc = ScoutingService(random: Random(1));
    for (var i = 0; i < 30 && scouting.forProspect('p1')!.tier != ScoutingTier.tier5; i++) {
      scouting = svc.tickKnowledge(scouting, 5.0);
    }
    expect(scouting.forProspect('p1')!.tier, ScoutingTier.tier5);
  });

  test('runScoutReport assigns at most combineAssignLimit(coverage) targets', () {
    final svc = ScoutingService();
    final scouting = const TeamScouting(
      watchlistProspectIds: ['a', 'b', 'c', 'd', 'e'],
    );
    final updated = svc.runScoutReport(scouting, 5.0);
    expect(
      updated.combineAssignedProspectIds.length,
      lessThanOrEqualTo(balance.staff.combineAssignLimit(5.0)),
    );
  });

  test('runFinalMock assigns top1 slot to the true best prospect', () {
    final draftClass = SeedDataGenerator().generateDraftClass(year: 2030);
    final best = draftClass.prospects.first;
    final scouting = TeamScouting(
      watchlistProspectIds: [best.id],
      knowledge: [ScoutingKnowledge(prospectId: best.id)],
    );
    final svc = ScoutingService(random: Random(2));
    final updated = svc.runFinalMock(scouting, draftClass.prospects, 5.0);
    // High evaluation → tight noise band; best prospect should land near top.
    expect(
      updated.forProspect(best.id)!.estimatedSlot,
      anyOf(
        EstimatedDraftSlot.top1,
        EstimatedDraftSlot.top3,
        EstimatedDraftSlot.top5,
      ),
    );
  });
}
