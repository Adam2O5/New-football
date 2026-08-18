import 'dart:math';

import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

/// Immutable public input for one AI matchday decision.
///
/// The context is fixture-scoped and is never persisted. It may contain the
/// opponent's public tactics/history, but it deliberately has no foreign
/// hidden-player data.
class AiMatchdayContext {
  const AiMatchdayContext({
    required this.team,
    required this.opponent,
    required this.matchId,
    required this.matchContext,
    required this.saveSeed,
    required this.seasonYear,
    required this.week,
    this.phase = SeasonPhase.regular,
    this.opponentFormation,
    this.opponentFormationHistory = const [],
    this.returningAfterMajorInjury = const {},
    this.nextMatchWithinThreeDays = false,
    this.mathematicallyMeaningless = false,
  });

  final Team team;
  final Team opponent;
  final String matchId;
  final MatchContext matchContext;
  final int saveSeed;
  final int seasonYear;
  final int week;
  final SeasonPhase phase;
  final Formation? opponentFormation;
  final List<Formation> opponentFormationHistory;
  final Set<String> returningAfterMajorInjury;
  final bool nextMatchWithinThreeDays;
  final bool mathematicallyMeaningless;

  bool get isPlayoff =>
      phase == SeasonPhase.playIn || phase == SeasonPhase.playoff;
}

/// Explainable fixture plan produced for one club.
///
/// [assignedPositions] is keyed by player id because the canonical engine
/// keeps natural player positions separate from formation-slot assignments.
class AiMatchdayPlan {
  const AiMatchdayPlan({
    required this.teamId,
    required this.matchId,
    required this.lineupPlayerIds,
    required this.benchPlayerIds,
    required this.formation,
    required this.tactics,
    required this.assignedPositions,
    required this.assignedRoles,
    required this.playerScores,
    required this.rotationReasons,
    required this.counterFormationApplied,
    required this.substitutionSeed,
  });

  final String teamId;
  final String matchId;
  final List<String> lineupPlayerIds;
  final List<String> benchPlayerIds;
  final Formation formation;
  final TacticsSetup tactics;
  final Map<String, Position> assignedPositions;
  final Map<String, AssignedRole> assignedRoles;
  final Map<String, double> playerScores;
  final Map<String, String> rotationReasons;
  final bool counterFormationApplied;
  final int substitutionSeed;

  /// Applies only the transient match plan. The supplied [team] itself is
  /// immutable; callers should pass the returned copy to the engine and keep
  /// the league roster unchanged.
  Team applyTo(Team team) {
    final roster = team.roster
        .map((player) {
          final role = assignedRoles[player.id];
          if (role == null || role == player.state.role) return player;
          return player.copyWith(state: player.state.copyWith(role: role));
        })
        .toList(growable: false);
    return team.copyWith(
      roster: roster,
      lineupPlayerIds: lineupPlayerIds,
      benchPlayerIds: benchPlayerIds,
      tactics: tactics,
    );
  }

  bool containsInLineup(String playerId) => lineupPlayerIds.contains(playerId);
}

/// Mutable runtime-only state for one AI side during a live match.
class AiMatchdayRuntime {
  AiMatchdayRuntime({required this.plan})
    : random = Random(plan.substitutionSeed);

  final AiMatchdayPlan plan;
  final Random random;
  final Set<String> handledInjuryKeys = <String>{};
  final Set<String> handledTriggers = <String>{};

  bool hasHandled(String key) => handledTriggers.contains(key);

  void markHandled(String key) => handledTriggers.add(key);
}
