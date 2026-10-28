@Tags(['ai'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_matchday_models.dart';
import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/simulation/match_engine.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(year: 2026, seed: 3301);
  final aiTeam = league.teams[1];
  final opponent = league.teams[2];
  final service = AiMatchdayService();

  MatchContext contextFor(Team home, Team away, {int seed = 3301}) =>
      MatchContext(homeTeamId: home.id, awayTeamId: away.id, seed: seed);

  AiMatchdayPlan planFor(
    Team team,
    Team other, {
    required String matchId,
    int week = 1,
    MatchContext? matchContext,
    List<Formation> opponentHistory = const [],
    bool? nextMatchWithinThreeDays,
  }) {
    final context = matchContext ?? contextFor(team, other);
    return service.planForTeam(
      service.contextForTeam(
        team: team,
        opponent: other,
        matchId: matchId,
        matchContext: context,
        saveSeed: 33,
        seasonYear: 2026,
        week: week,
        opponentFormation: other.tactics.formation,
        opponentFormationHistory: opponentHistory,
        nextMatchWithinThreeDays: nextMatchWithinThreeDays,
      ),
    );
  }

  test('1000 deterministic plans always keep a capable GK in the GK slot', () {
    for (var index = 0; index < 1000; index++) {
      final plan = planFor(aiTeam, opponent, matchId: 'task33-gk-$index');
      expect(plan.lineupPlayerIds, hasLength(11));
      final goalkeeperIds = plan.assignedPositions.entries
          .where((entry) => entry.value == Position.gk)
          .map((entry) => entry.key)
          .toList();
      expect(goalkeeperIds, hasLength(1));
      expect(plan.lineupPlayerIds.first, goalkeeperIds.single);
    }
  });

  test('matchday readiness uses the four documented stamina bands', () {
    expect(service.staminaReadiness(100), 1.00);
    expect(service.staminaReadiness(80), 1.00);
    expect(service.staminaReadiness(79), 0.94);
    expect(service.staminaReadiness(60), 0.94);
    expect(service.staminaReadiness(59), 0.82);
    expect(service.staminaReadiness(40), 0.82);
    expect(service.staminaReadiness(39), 0.60);
    expect(service.staminaReadiness(0), 0.60);
  });

  test('counter-formation memory is applied at approximately the 65% rate', () {
    var counterPlans = 0;
    for (var index = 0; index < 1000; index++) {
      final plan = planFor(
        aiTeam,
        opponent,
        matchId: 'task33-counter-$index',
        opponentHistory: const [Formation.f343, Formation.f343],
      );
      if (plan.counterFormationApplied) counterPlans++;
    }
    final rate = counterPlans / 1000.0;
    expect(rate, closeTo(0.65, 0.06));
  });

  test('short rest rotates a low-stamina player out of the XI', () {
    final tired = aiTeam.roster.firstWhere(
      (player) => player.position != Position.gk,
    );
    final rotatedTeam = aiTeam.copyWith(
      roster: aiTeam.roster
          .map(
            (player) => player.id == tired.id
                ? player.copyWith(state: player.state.copyWith(stamina: 55))
                : player.copyWith(state: player.state.copyWith(stamina: 100)),
          )
          .toList(),
    );
    final plan = planFor(
      rotatedTeam,
      opponent,
      matchId: 'task33-rotation',
      nextMatchWithinThreeDays: true,
    );

    expect(plan.lineupPlayerIds, isNot(contains(tired.id)));
  });

  test(
    'an injury event forces a substitution through the canonical engine',
    () {
      final plan = planFor(aiTeam, opponent, matchId: 'task33-forced-injury');
      final plannedTeam = plan.applyTo(aiTeam);
      final context = contextFor(plannedTeam, opponent, seed: 3302);
      final engine = SimulationMatchEngine();
      final live = engine.start(
        home: plannedTeam,
        away: opponent,
        context: context,
        rngSeed: context.seed,
        homeAssignedPositions: plan.assignedPositions,
      );
      final outgoing = live.state.homeLineup.firstWhere(
        (player) => player.position != Position.gk,
      );
      final benchBefore = live.state.homeBench
          .map((player) => player.id)
          .toSet();
      live.legacyMatch.injuries.add(
        MatchInjury(
          teamId: plannedTeam.id,
          playerId: outgoing.id,
          injury: const Injury(
            id: 'task33-forced-injury',
            group: InjuryGroup.legMuscles,
            type: InjuryType.major,
            daysTotal: 30,
            daysRemaining: 30,
          ),
          playerInStartingXi: true,
        ),
      );

      service.applyInMatchDecisions(
        live: live,
        runtime: AiMatchdayRuntime(plan: plan),
        homeSide: true,
      );

      expect(live.state.homeLineup, isNot(contains(outgoing)));
      expect(live.homeSubsUsed, 1);
      expect(
        live.events.any(
          (event) =>
              event.type == MatchEventType.substitution &&
              event.teamId == plannedTeam.id &&
              benchBefore.contains(event.playerId),
        ),
        isTrue,
      );
    },
  );
}
