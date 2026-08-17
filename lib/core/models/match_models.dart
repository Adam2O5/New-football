import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

part 'match_models.freezed.dart';
part 'match_models.g.dart';

@freezed
abstract class MatchEvent with _$MatchEvent {
  const factory MatchEvent({
    required MatchEventType type,
    required int minute,
    required String teamId,
    String? playerId,
    String? description,
  }) = _MatchEvent;

  factory MatchEvent.fromJson(Map<String, dynamic> json) =>
      _$MatchEventFromJson(json);
}

@freezed
abstract class MatchInjury with _$MatchInjury {
  const factory MatchInjury({
    required String teamId,
    required String playerId,
    required Injury injury,
    required bool playerInStartingXi,
    @Default(false) bool potentialLoss,
  }) = _MatchInjury;

  factory MatchInjury.fromJson(Map<String, dynamic> json) =>
      _$MatchInjuryFromJson(json);
}

@freezed
abstract class MatchDiscipline with _$MatchDiscipline {
  const factory MatchDiscipline({
    required String teamId,
    required String playerId,
    @Default(0) int yellowCardsInMatch,
    @Default(RedCardKind.none) RedCardKind redCardKind,
    @Default(0) int directRedSeverity,
    @Default(false) bool playerInStartingXi,
  }) = _MatchDiscipline;

  factory MatchDiscipline.fromJson(Map<String, dynamic> json) =>
      _$MatchDisciplineFromJson(json);
}

@freezed
abstract class TeamMatchStats with _$TeamMatchStats {
  const factory TeamMatchStats({
    required String teamId,
    @Default(0) int goals,
    @Default(0) int shots,
    @Default(0) int shotsOnTarget,
    @Default(0) int possession,
    @Default(0.0) double xg,
    @Default(0) int passes,
    @Default(0.0) double passAccuracy,
    @Default(0) int duelsWon,
    @Default(0) int offsides,
    @Default(0) int corners,
    @Default(0) int fouls,
    @Default(0) int yellowCards,
    @Default(0) int redCards,
    @Default(0) int saves,
  }) = _TeamMatchStats;

  factory TeamMatchStats.fromJson(Map<String, dynamic> json) =>
      _$TeamMatchStatsFromJson(json);
}

@freezed
abstract class MatchTeamSnapshot with _$MatchTeamSnapshot {
  const factory MatchTeamSnapshot({
    @Default('') String teamId,
    @Default([]) List<Player> startingXi,
    @Default([]) List<Player> bench,
    @Default([]) List<Position> assignedPositions,
    @Default([]) List<AssignedRole> assignedRoles,
    @Default(TacticsSetup()) TacticsSetup tactics,
    @Default(50.0) double chemistry,
    @Default(50) int atmosphere,
    @Default(1.0) double cohesionMultiplier,
    @Default(TeamStaff()) TeamStaff staff,
  }) = _MatchTeamSnapshot;

  factory MatchTeamSnapshot.fromJson(Map<String, dynamic> json) =>
      _$MatchTeamSnapshotFromJson(json);
}

@freezed
abstract class MatchResult with _$MatchResult {
  const factory MatchResult({
    required String homeTeamId,
    required String awayTeamId,
    required int homeGoals,
    required int awayGoals,
    required TeamMatchStats homeStats,
    required TeamMatchStats awayStats,
    @Default(MatchStatus.played) MatchStatus status,
    String? reasonCode,
    @Default([]) List<String> violatingTeamIds,
    @Default(false) bool isWalkover,
    @Default(false) bool noGkPenalty,
    @Default([]) List<String> noGkPenaltyTeamIds,
    @Default(MatchContext()) MatchContext context,
    @Default(TacticsSetup()) TacticsSetup homeTactics,
    @Default(TacticsSetup()) TacticsSetup awayTactics,
    @Default([]) List<Player> homeLineup,
    @Default([]) List<Player> awayLineup,
    @Default([]) List<Position> homeLineupPositions,
    @Default([]) List<Position> awayLineupPositions,
    @Default(MatchTeamSnapshot()) MatchTeamSnapshot homeSnapshot,
    @Default(MatchTeamSnapshot()) MatchTeamSnapshot awaySnapshot,
    @Default([]) List<PlayerMatchStats> playerStats,
    @Default([]) List<MatchEvent> events,
    @Default([]) List<MatchInjury> injuries,
    @Default([]) List<MatchDiscipline> disciplines,
    String? manOfTheMatchPlayerId,
    String? inspiredPerformancePlayerId,
    @Default(90) int matchEndMinute,
    @Default(0) int stoppageTime,
  }) = _MatchResult;

  factory MatchResult.fromJson(Map<String, dynamic> json) =>
      _$MatchResultFromJson(json);
}

@freezed
abstract class MatchSetup with _$MatchSetup {
  const factory MatchSetup({
    required String homeTeamId,
    required String awayTeamId,
    required List<Player> homeLineup,
    required List<Player> awayLineup,
    required TacticsSetup homeTactics,
    required TacticsSetup awayTactics,
    @Default(false) bool isHomeAdvantage,
    @Default(0) int roundNumber,
  }) = _MatchSetup;

  factory MatchSetup.fromJson(Map<String, dynamic> json) =>
      _$MatchSetupFromJson(json);
}

@freezed
abstract class ScheduledMatch with _$ScheduledMatch {
  const factory ScheduledMatch({
    required String id,
    required String homeTeamId,
    required String awayTeamId,
    required int round,
    MatchResult? result,
  }) = _ScheduledMatch;

  factory ScheduledMatch.fromJson(Map<String, dynamic> json) =>
      _$ScheduledMatchFromJson(json);
}

@freezed
abstract class PlayoffSeries with _$PlayoffSeries {
  const factory PlayoffSeries({
    required String id,
    required String higherSeedTeamId,
    required String lowerSeedTeamId,
    required int winsNeeded,
    @Default(0) int higherSeedWins,
    @Default(0) int lowerSeedWins,
    @Default([]) List<MatchResult> games,
    String? winnerTeamId,
  }) = _PlayoffSeries;

  factory PlayoffSeries.fromJson(Map<String, dynamic> json) =>
      _$PlayoffSeriesFromJson(json);
}

extension PlayoffSeriesX on PlayoffSeries {
  bool get isComplete => winnerTeamId != null;

  PlayoffSeries recordGame(MatchResult result) {
    final higherWon = result.homeTeamId == higherSeedTeamId
        ? result.homeGoals > result.awayGoals
        : result.awayGoals > result.homeGoals;
    final newHigherWins = higherWon ? higherSeedWins + 1 : higherSeedWins;
    final newLowerWins = higherWon ? lowerSeedWins : lowerSeedWins + 1;

    String? winner;
    if (newHigherWins >= winsNeeded) {
      winner = higherSeedTeamId;
    } else if (newLowerWins >= winsNeeded) {
      winner = lowerSeedTeamId;
    }

    return copyWith(
      higherSeedWins: newHigherWins,
      lowerSeedWins: newLowerWins,
      games: [...games, result],
      winnerTeamId: winner,
    );
  }
}
