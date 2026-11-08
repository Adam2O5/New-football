import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/cohesion_service.dart';
import 'package:new_football/core/services/injury_service.dart';
import 'package:new_football/core/simulation/live_match_state.dart';
import 'package:new_football/core/simulation/pre_match_validator.dart';

/// Validates and freezes the inputs for the active simulation engine.
class MatchBootstrap {
  const MatchBootstrap({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  LiveMatchState start({
    required Team home,
    required Team away,
    MatchContext context = const MatchContext(),
    required int rngSeed,
    Map<String, Position> homeAssignedPositions = const {},
    Map<String, Position> awayAssignedPositions = const {},
  }) {
    final report = PreMatchValidator(
      balance: balance,
    ).validate(home: home, away: away);
    final matchContext = context.copyWith(
      homeTeamId: context.homeTeamId.isEmpty ? home.id : context.homeTeamId,
      awayTeamId: context.awayTeamId.isEmpty ? away.id : context.awayTeamId,
      seed: context.seed == 0 ? rngSeed : context.seed,
    );

    final cohesionService = CohesionService(balance: balance);
    final homeCohesionMult = cohesionService.cohesionMult(
      cohesionService.computeCohesion(report.home.startingXi),
      headCoach: home.staff.headCoach,
    );
    final awayCohesionMult = cohesionService.cohesionMult(
      cohesionService.computeCohesion(report.away.startingXi),
      headCoach: away.staff.headCoach,
    );
    final homeSnapshot = _snapshotFor(
      home,
      report.home,
      cohesionMultiplier: homeCohesionMult,
      assignedPositions: homeAssignedPositions,
    );
    final awaySnapshot = _snapshotFor(
      away,
      report.away,
      cohesionMultiplier: awayCohesionMult,
      assignedPositions: awayAssignedPositions,
    );

    if (report.status != MatchStatus.played) {
      final homeGoals = report.status == MatchStatus.dsq
          ? 0
          : report.violatingTeamIds.contains(home.id)
          ? balance.matchday.walkoverGoalsFor
          : balance.matchday.walkoverGoalsAgainst;
      final awayGoals = report.status == MatchStatus.dsq
          ? 0
          : report.violatingTeamIds.contains(away.id)
          ? balance.matchday.walkoverGoalsFor
          : balance.matchday.walkoverGoalsAgainst;
      final administrativeResult = MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        homeStats: TeamMatchStats(teamId: home.id, goals: homeGoals),
        awayStats: TeamMatchStats(teamId: away.id, goals: awayGoals),
        status: report.status,
        reasonCode: report.reasonCode,
        violatingTeamIds: report.violatingTeamIds,
        isWalkover: true,
        context: matchContext,
        homeTactics: home.tactics,
        awayTactics: away.tactics,
        homeLineup: report.home.startingXi,
        awayLineup: report.away.startingXi,
        homeLineupPositions: homeSnapshot.assignedPositions,
        awayLineupPositions: awaySnapshot.assignedPositions,
        homeSnapshot: homeSnapshot,
        awaySnapshot: awaySnapshot,
      );
      return LiveMatchState(
        state: MatchState(
          minute: 90,
          homeGoals: homeGoals,
          awayGoals: awayGoals,
          homeLineup: report.home.startingXi,
          awayLineup: report.away.startingXi,
          homeBench: report.home.bench,
          awayBench: report.away.bench,
          homeTactics: home.tactics,
          awayTactics: away.tactics,
          context: matchContext,
          rngSeed: rngSeed,
        ),
        homeTeamId: home.id,
        awayTeamId: away.id,
        startingHomeLineup: report.home.startingXi,
        startingAwayLineup: report.away.startingXi,
        balance: balance,
        events: const [],
        administrativeResult: administrativeResult,
        homeSnapshot: homeSnapshot,
        awaySnapshot: awaySnapshot,
      );
    }

    final homeNoGk = report.noGkPenaltyTeamIds.contains(home.id);
    final awayNoGk = report.noGkPenaltyTeamIds.contains(away.id);
    final live = LiveMatchState(
      state: MatchState(
        minute: 0,
        homeLineup: List.of(report.home.startingXi),
        awayLineup: List.of(report.away.startingXi),
        homeBench: report.home.bench,
        awayBench: report.away.bench,
        homeTactics: home.tactics,
        awayTactics: away.tactics,
        context: matchContext,
        momentum: matchContext.crowdIntensity / 8,
        rngSeed: rngSeed,
      ),
      homeTeamId: home.id,
      awayTeamId: away.id,
      startingHomeLineup: report.home.startingXi,
      startingAwayLineup: report.away.startingXi,
      balance: balance,
      homeSnapshot: homeSnapshot,
      awaySnapshot: awaySnapshot,
      homeNoGkPenalty: homeNoGk,
      awayNoGkPenalty: awayNoGk,
      homeHeadCoach: home.staff.headCoach,
      awayHeadCoach: away.staff.headCoach,
      homeChemistry: home.chemistry,
      awayChemistry: away.chemistry,
      homeAtmosphere: home.atmosphere,
      awayAtmosphere: away.atmosphere,
      homeDoctorCareMult: InjuryService(
        balance: balance,
      ).doctorCareMult(home.staff.doctor),
      awayDoctorCareMult: InjuryService(
        balance: balance,
      ).doctorCareMult(away.staff.doctor),
    );
    return live;
  }

  MatchTeamSnapshot _snapshotFor(
    Team team,
    PreMatchTeamReport report, {
    required double cohesionMultiplier,
    Map<String, Position> assignedPositions = const {},
  }) => MatchTeamSnapshot(
    teamId: team.id,
    startingXi: report.startingXi,
    bench: report.bench,
    assignedPositions: [
      for (final player in report.startingXi)
        assignedPositions[player.id] ?? player.position,
    ],
    assignedRoles: [for (final player in report.startingXi) player.state.role],
    tactics: team.tactics,
    chemistry: team.chemistry,
    atmosphere: team.atmosphere,
    cohesionMultiplier: cohesionMultiplier,
    staff: team.staff,
  );
}
