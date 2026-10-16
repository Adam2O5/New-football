import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/services/scouting_service.dart';

import 'support/game_fixtures.dart';

void main() {
  test('natural tier 4 to 5 reveals traits and survives serialization', () {
    final prospect =
        seededLeague().currentSeason.draftState!.draftClass.prospects.first;
    final scouting = TeamScouting(
      watchlistProspectIds: [prospect.id],
      knowledge: [
        ScoutingKnowledge(
          prospectId: prospect.id,
          tier: ScoutingTier.tier4,
          weeksAtCurrentTier: 9,
        ),
      ],
    );
    final next = ScoutingService().tickKnowledge(
      scouting,
      5,
      prospects: [prospect],
    );
    final knowledge = next.knowledge.single;
    expect(knowledge.tier, ScoutingTier.tier5);
    expect(knowledge.injuryProneKnown && knowledge.determinationKnown, isTrue);
    expect(
      prospect.injuryProne,
      inInclusiveRange(knowledge.injuryProneMin!, knowledge.injuryProneMax!),
    );
    expect(
      prospect.determination,
      inInclusiveRange(
        knowledge.determinationMin!,
        knowledge.determinationMax!,
      ),
    );
    expect(
      TeamScouting.fromJson(
        jsonDecode(jsonEncode(next.toJson())) as Map<String, dynamic>,
      ),
      next,
    );
  });
  test('Combine and tier advancement never widen prior evidence', () {
    final prospect =
        seededLeague().currentSeason.draftState!.draftClass.prospects.first;
    final ovr = prospect.projectedOverall().round();
    final scouting = TeamScouting(
      watchlistProspectIds: [prospect.id],
      combineAssignedProspectIds: [prospect.id],
      knowledge: [
        ScoutingKnowledge(
          prospectId: prospect.id,
          tier: ScoutingTier.tier4,
          weeksAtCurrentTier: 9,
          injuryProneKnown: true,
          determinationKnown: true,
          injuryProneMin: prospect.injuryProne,
          injuryProneMax: prospect.injuryProne,
          determinationMin: prospect.determination,
          determinationMax: prospect.determination,
          estimatedOvrMin: ovr,
          estimatedOvrMax: ovr,
        ),
      ],
    );
    final service = ScoutingService();
    for (final input in [
      scouting,
      service.runCombine(scouting, 5, prospects: [prospect], seed: fixtureSeed),
    ]) {
      final tierFive = service.tickKnowledge(input, 5, prospects: [prospect]);
      final combined = service.runCombine(
        tierFive,
        5,
        prospects: [prospect],
        seed: fixtureSeed,
      );
      for (final result in [tierFive, combined]) {
        final knowledge = result.knowledge.single;
        expect(knowledge.injuryProneMin, prospect.injuryProne);
        expect(knowledge.injuryProneMax, prospect.injuryProne);
        expect(knowledge.determinationMin, prospect.determination);
        expect(knowledge.determinationMax, prospect.determination);
        expect(knowledge.estimatedOvrMin, ovr);
        expect(knowledge.estimatedOvrMax, ovr);
      }
    }
  });
}
