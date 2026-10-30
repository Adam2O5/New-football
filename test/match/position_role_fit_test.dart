@Tags(['unit'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/services/cohesion_service.dart';
import 'package:new_football/core/services/team_management_service.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';

import '../helpers/fixtures/presentation_fixtures.dart';

void main() {
  // Expected natural-position groups are independent of production helpers.
  final cases = [
    (GkRole.values.map((r) => AssignedRole.gk(role: r)), {Position.gk}),
    (CbRole.values.map((r) => AssignedRole.cb(role: r)), {Position.cb}),
    (
      FullBackRole.values.map((r) => AssignedRole.fullBack(role: r)),
      {Position.lb, Position.rb},
    ),
    (
      WingBackRole.values.map((r) => AssignedRole.wingBack(role: r)),
      {Position.lwb, Position.rwb},
    ),
    (CdmRole.values.map((r) => AssignedRole.cdm(role: r)), {Position.cdm}),
    (CmRole.values.map((r) => AssignedRole.cm(role: r)), {Position.cm}),
    (CamRole.values.map((r) => AssignedRole.cam(role: r)), {Position.cam}),
    (
      WingerRole.values.map((r) => AssignedRole.winger(role: r)),
      {Position.lw, Position.rw},
    ),
    (
      StrikerRole.values.map((r) => AssignedRole.striker(role: r)),
      {Position.st},
    ),
  ];
  final source = presentationTeam();
  final template = source.roster.first;
  final result = MatchResult(
    homeTeamId: source.id,
    awayTeamId: 'opponent',
    homeGoals: 0,
    awayGoals: 0,
    homeStats: TeamMatchStats(teamId: source.id),
    awayStats: const TeamMatchStats(teamId: 'opponent'),
  );

  for (final consumer in ['cohesion', 'chemistry', 'effective attributes']) {
    test(
      '$consumer preserves natural-position groups for every role variant',
      () {
        for (final (roles, positions) in cases) {
          for (final role in roles) {
            for (final position in Position.values) {
              final player = template.copyWith(
                position: position,
                optimalRole: role,
                state: template.state.copyWith(role: role, seasonsWithTeam: 0),
              );
              final fits = positions.contains(position);
              final reason = '$consumer: $position / $role';
              switch (consumer) {
                case 'cohesion':
                  expect(
                    const CohesionService().computeCohesion([player]),
                    fits ? 54 : 47,
                    reason: reason,
                  );
                case 'chemistry':
                  final team = source.copyWith(
                    roster: [player],
                    chemistry: 50,
                    chemistryAppearances: {player.id: 5},
                  );
                  final update = const TeamManagementService().applyMatchResult(
                    team: team,
                    result: result,
                    startingEleven: [player],
                    seasonYear: 2026,
                  );
                  expect(
                    update.chemistryDelta,
                    closeTo(fits ? 0 : -0.4, 1e-9),
                    reason: reason,
                  );
                case 'effective attributes':
                  expect(
                    EffectiveAttributeCalculator.positionMultiplier(player),
                    fits ? 1.0 : 0.9,
                    reason: reason,
                  );
              }
            }
          }
        }
      },
    );
  }

  test('explicit formation slot retains exact position matching', () {
    final player = template.copyWith(
      position: Position.lb,
      state: template.state.copyWith(
        role: const AssignedRole.fullBack(),
        seasonsWithTeam: 0,
      ),
    );
    final team = source.copyWith(
      roster: [player],
      chemistry: 50,
      chemistryAppearances: {player.id: 5},
    );
    for (final slot in [Position.lb, Position.rb]) {
      expect(
        EffectiveAttributeCalculator.positionMultiplier(
          player,
          assignedPosition: slot,
        ),
        slot == Position.lb ? 1.0 : 0.9,
      );
      final update = const TeamManagementService().applyMatchResult(
        team: team,
        result: result,
        startingEleven: [player],
        seasonYear: 2026,
        assignedPositions: [slot],
      );
      expect(
        update.chemistryDelta,
        closeTo(slot == Position.lb ? 0 : -0.4, 1e-9),
      );
    }
  });
}
