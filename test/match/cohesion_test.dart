import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/cohesion_service.dart';
import 'package:new_football/core/services/game_factory.dart';

void main() {
  const cohesion = CohesionService();

  test('CohesionService liczy bazę, fit pozycji i karę za obcą rolę', () {
    final team = GameFactory()
        .create(
          const NewGameRequest(
            saveName: 'Task 41 cohesion',
            playerTeamId: 'team_europe_0',
            seed: 4101,
          ),
        )
        .leagueState
        .playerTeam!;
    final source = team.roster.firstWhere(
      (player) => player.position == Position.cm,
    );
    final natural = source.copyWith(
      position: Position.cm,
      state: source.state.copyWith(role: const AssignedRole.cm()),
      optimalRole: const AssignedRole.cm(),
    );
    final foreign = natural.copyWith(
      state: natural.state.copyWith(role: const AssignedRole.striker()),
    );

    expect(cohesion.computeCohesion(const []), 50);
    expect(cohesion.computeCohesion([natural]), 54);
    expect(cohesion.computeCohesion([foreign]), 45);
    expect(cohesion.computeCohesion([natural, foreign]), 49);
  });

  test('CohesionService stosuje tier multiplier i motywację head coacha', () {
    final coach = const StaffMember(
      id: 'task41-head-coach',
      name: 'Task 41 HC',
      nationality: Nationality.poland,
      age: 44,
      role: StaffRole.headCoach,
      attributes: StaffAttributes(motivation: 4.5),
    );

    expect(cohesion.cohesionMult(0), closeTo(1.01, 1e-9));
    expect(cohesion.cohesionMult(20), closeTo(1.01, 1e-9));
    expect(cohesion.cohesionMult(21), closeTo(1.02, 1e-9));
    expect(cohesion.cohesionMult(41), closeTo(1.03, 1e-9));
    expect(cohesion.cohesionMult(61), closeTo(1.04, 1e-9));
    expect(cohesion.cohesionMult(81), closeTo(1.05, 1e-9));
    expect(cohesion.cohesionMult(81, headCoach: coach), closeTo(1.0815, 1e-9));
  });
}
