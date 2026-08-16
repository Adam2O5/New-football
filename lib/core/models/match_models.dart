import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

part 'match_models.freezed.dart';
part 'match_models.g.dart';

@freezed
class MatchEvent with _$MatchEvent {
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
class MatchInjury with _$MatchInjury {
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
class TeamMatchStats with _$TeamMatchStats {
  const factory TeamMatchStats({
    required String teamId,
    @Default(0) int goals,
    @Default(0) int shots,
    @Default(0) int shotsOnTarget,
    @Default(0) int possession,
    @Default(0.0) double xg,
    @Default(0) int corners,
    @Default(0) int fouls,
    @Default(0) int yellowCards,
    @Default(0) int redCards,
  }) = _TeamMatchStats;

  factory TeamMatchStats.fromJson(Map<String, dynamic> json) =>
      _$TeamMatchStatsFromJson(json);
}

@freezed
class MatchResult with _$MatchResult {
  const factory MatchResult({
    required String homeTeamId,
    required String awayTeamId,
    required int homeGoals,
    required int awayGoals,
    required TeamMatchStats homeStats,
    required TeamMatchStats awayStats,
    @Default([]) List<PlayerMatchStats> playerStats,
    @Default([]) List<MatchEvent> events,
    @Default([]) List<MatchInjury> injuries,
  }) = _MatchResult;

  factory MatchResult.fromJson(Map<String, dynamic> json) =>
      _$MatchResultFromJson(json);
}

@freezed
class MatchSetup with _$MatchSetup {
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
class ScheduledMatch with _$ScheduledMatch {
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
class PlayoffSeries with _$PlayoffSeries {
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
