import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

part 'match_state.freezed.dart';
part 'match_state.g.dart';

@freezed
abstract class MatchContext with _$MatchContext {
  const factory MatchContext({
    @Default('') String homeTeamId,
    @Default('') String awayTeamId,
    @Default(Weather.clear) Weather weather,
    @Default(0) int temperatureC,
    @Default(false) bool isDerby,
    @Default(MatchStake.regular) MatchStake stake,
    @Default(1.0) double refereeStrictness,
    @Default(0) int crowdIntensity,
    @Default(1) int homeMatchInWeek,
    @Default(1) int awayMatchInWeek,
    @Default(0) int seed,
    @Default(0.05) double homeAdvantage,
  }) = _MatchContext;

  factory MatchContext.fromJson(Map<String, dynamic> json) =>
      _$MatchContextFromJson(json);
}

@freezed
abstract class MatchState with _$MatchState {
  const factory MatchState({
    @Default(0) int minute,
    @Default(0) int homeGoals,
    @Default(0) int awayGoals,
    @Default([]) List<Player> homeLineup,
    @Default([]) List<Player> awayLineup,
    @Default([]) List<Player> homeBench,
    @Default([]) List<Player> awayBench,
    @Default(TacticsSetup()) TacticsSetup homeTactics,
    @Default(TacticsSetup()) TacticsSetup awayTactics,
    @Default({}) Map<String, int> yellowCardCounts,
    @Default([]) List<String> sentOffPlayerIds,
    @Default([]) List<String> injuriesThisMatch,
    @Default(0.0) double momentum,
    @Default(0.0) double moraleModHome,
    @Default(0.0) double moraleModAway,
    @Default(MatchContext()) MatchContext context,
    int? rngSeed,
  }) = _MatchState;

  factory MatchState.fromJson(Map<String, dynamic> json) =>
      _$MatchStateFromJson(json);
}
