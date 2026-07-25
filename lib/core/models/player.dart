import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player_attributes.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class PlayerSeasonStats with _$PlayerSeasonStats {
  const factory PlayerSeasonStats({
    required int year,
    @Default(0) int minutes,
    @Default(0) int goals,
    @Default(0) int assists,
    @Default(0) int appearances,
    @Default(0) int yellowCards,
    @Default(0) int redCards,
    @Default(0) int tackles,
    @Default(0) int interceptions,
    @Default(0) int cleanSheets,
    @Default(0) int saves,
    @Default(0) int shotsFaced,
    @Default(6.0) double ratingAvg,
  }) = _PlayerSeasonStats;

  factory PlayerSeasonStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerSeasonStatsFromJson(json);
}

/// Aggregates per-season rows into one career totals object (UI profile).
PlayerSeasonStats aggregatePlayerSeasonStats(
  Iterable<PlayerSeasonStats> seasons, {
  int year = 0,
}) {
  var minutes = 0;
  var goals = 0;
  var assists = 0;
  var appearances = 0;
  var yellowCards = 0;
  var redCards = 0;
  var tackles = 0;
  var interceptions = 0;
  var cleanSheets = 0;
  var saves = 0;
  var shotsFaced = 0;
  var ratingWeighted = 0.0;
  var ratingWeight = 0;

  for (final s in seasons) {
    minutes += s.minutes;
    goals += s.goals;
    assists += s.assists;
    appearances += s.appearances;
    yellowCards += s.yellowCards;
    redCards += s.redCards;
    tackles += s.tackles;
    interceptions += s.interceptions;
    cleanSheets += s.cleanSheets;
    saves += s.saves;
    shotsFaced += s.shotsFaced;
    final w = s.minutes > 0
        ? s.minutes
        : (s.appearances > 0 ? s.appearances : 0);
    if (w > 0) {
      ratingWeighted += s.ratingAvg * w;
      ratingWeight += w;
    }
  }

  return PlayerSeasonStats(
    year: year,
    minutes: minutes,
    goals: goals,
    assists: assists,
    appearances: appearances,
    yellowCards: yellowCards,
    redCards: redCards,
    tackles: tackles,
    interceptions: interceptions,
    cleanSheets: cleanSheets,
    saves: saves,
    shotsFaced: shotsFaced,
    ratingAvg: ratingWeight > 0 ? ratingWeighted / ratingWeight : 0.0,
  );
}

/// Hidden development / durability traits (`player_management.md` §3).
@freezed
class PlayerHidden with _$PlayerHidden {
  const factory PlayerHidden({
    required int injuryProne,
    required int determination,
    required int overallProgress,
    @Default(1.0) double growthRate,
    required DevelopmentOutcome developmentOutcome,
  }) = _PlayerHidden;

  factory PlayerHidden.fromJson(Map<String, dynamic> json) =>
      _$PlayerHiddenFromJson(json);
}

/// Mutable matchday / roster state of a player.
@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
    @Default(100) int stamina,
    @Default(5) int form,
    @Default(false) bool injured,
    @Default(0) int injuryDaysRemaining,
    InjuryType? injuryType,
    @Default(AssignedRole.cm()) AssignedRole role,
    @Default(0) int seasonsWithTeam,
  }) = _PlayerState;

  factory PlayerState.fromJson(Map<String, dynamic> json) =>
      _$PlayerStateFromJson(json);
}

@freezed
class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    required Position position,
    required Nationality nationality,
    required int age,
    required PlayerAttributes attributes,
    required Contract contract,
    required PlayerPersonality personality,
    required double potentialStars,
    required int heightCm,
    required PlayerState state,
    required PlayerHidden hidden,
    @Default([]) List<PlayerSeasonStats> seasonStats,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

extension PlayerX on Player {
  double overall([BalanceConfig balance = BalanceConfig.defaults]) =>
      attributes.overallForPosition(position, balance);

  /// Available for selection unless injured. Low stamina still allows play
  /// but hurts performance and raises injury risk (`PlayerBalance`).
  bool get isAvailable => !state.injured;

  /// Career totals across all seasons (profile UI).
  PlayerSeasonStats get careerSeasonStats =>
      aggregatePlayerSeasonStats(seasonStats);

  double staminaPerformanceMult([
    BalanceConfig balance = BalanceConfig.defaults,
  ]) => balance.player.performanceMult(state.stamina);

  double staminaInjuryRiskMult([
    BalanceConfig balance = BalanceConfig.defaults,
  ]) => balance.player.injuryRiskMult(state.stamina);

  /// Trade-value indicator (`player_management.md` §3), derived from visible
  /// attributes/age — not a stored field.
  int pointValue([BalanceConfig balance = BalanceConfig.defaults]) {
    final b = balance.player;
    final positionAvg = attributes.overallForPosition(position, balance);
    final ageAdj = age <= b.pointValueYoungAgeMax
        ? (potentialStars - b.pointValueYoungStarsPivot) *
              b.pointValueYoungStarsWeight
        : age >= b.pointValueOldAgeMin
        ? -(age - (b.pointValueOldAgeMin - 1)) * b.pointValueOldAgeWeight
        : 0.0;
    final raw =
        (overall(balance) - b.pointValueOverallPivot) *
            b.pointValueOverallWeight +
        (positionAvg - b.pointValueOverallPivot) * b.pointValueFutWeight +
        ageAdj;
    return raw.round().clamp(b.pointValueMin, b.pointValueMax);
  }

  Player withMatchFatigue(
    int minutesPlayed, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    final b = balance.player;
    final fatigue = b.fatigueForMinutes(minutesPlayed);
    return copyWith(
      state: state.copyWith(stamina: b.clampStamina(state.stamina - fatigue)),
    );
  }

  Player recoverBetweenMatches([
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    final b = balance.player;
    final days = state.injured
        ? (state.injuryDaysRemaining - 1).clamp(0, b.injuryDaysClampMax)
        : state.injuryDaysRemaining;
    return copyWith(
      state: state.copyWith(
        stamina: b.clampStamina(state.stamina + b.recoveryBetweenMatches),
        injuryDaysRemaining: days,
        injured: state.injured && state.injuryDaysRemaining > 1,
      ),
    );
  }
}

@freezed
class PlayerMatchStats with _$PlayerMatchStats {
  const factory PlayerMatchStats({
    required String playerId,
    @Default(0) int minutes,
    @Default(0) int goals,
    @Default(0) int assists,
    @Default(0) int shots,
    @Default(0) int yellowCards,
    @Default(0) int redCards,
    @Default(0) int tackles,
    @Default(0) int interceptions,
    @Default(0) int saves,
    @Default(6.0) double rating,
  }) = _PlayerMatchStats;

  factory PlayerMatchStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerMatchStatsFromJson(json);
}
