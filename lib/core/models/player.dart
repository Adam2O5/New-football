import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
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
    @Default(0) int shots,
    @Default(0) int shotsOnTarget,
    @Default(0.0) double xg,
    @Default(0) int passes,
    @Default(0.0) double passAccuracy,
    @Default(0) int duelsWon,
    @Default(0) int offsides,
    @Default(0) int corners,
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
  var shots = 0;
  var shotsOnTarget = 0;
  var xg = 0.0;
  var passes = 0;
  var passAccuracyWeighted = 0.0;
  var passAccuracyWeight = 0;
  var duelsWon = 0;
  var offsides = 0;
  var corners = 0;
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
    shots += s.shots;
    shotsOnTarget += s.shotsOnTarget;
    xg += s.xg;
    passes += s.passes;
    passAccuracyWeighted += s.passAccuracy * s.passes;
    passAccuracyWeight += s.passes;
    duelsWon += s.duelsWon;
    offsides += s.offsides;
    corners += s.corners;
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
    shots: shots,
    shotsOnTarget: shotsOnTarget,
    xg: xg,
    passes: passes,
    passAccuracy: passAccuracyWeight > 0
        ? passAccuracyWeighted / passAccuracyWeight
        : 0.0,
    duelsWon: duelsWon,
    offsides: offsides,
    corners: corners,
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
    @Default(0.0) double overallProgress,
    @Default(1.0) double growthRate,
    required DevelopmentOutcome developmentOutcome,
    @Default(0.0) double developmentCeilingStars,
  }) = _PlayerHidden;

  factory PlayerHidden.fromJson(Map<String, dynamic> json) =>
      _$PlayerHiddenFromJson(json);
}

/// Mutable matchday / roster state of a player.
@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
    @Default(100) int stamina,
    @Default(5.0) double form,
    Injury? injury,
    @Default(0) int regularSeasonYellowCards,
    @Default(0) int playoffYellowCards,
    @Default(0) int suspensionGamesRemaining,
    @Default(AssignedRole.cm()) AssignedRole role,
    @Default(0) int seasonsWithTeam,
    @Default(0) int minutesThisWeek,
    @Default(0) int lastDevelopmentOvrDelta,
    @Default(0.0) double lastDevelopmentProgressDelta,
  }) = _PlayerState;

  factory PlayerState.fromJson(Map<String, dynamic> json) =>
      _$PlayerStateFromJson(json);
}

extension PlayerStateX on PlayerState {
  /// Compatibility projections for call-sites that used the old flat model.
  bool get injured => injury?.isActive ?? false;

  int get injuryDaysRemaining => injury?.daysRemaining ?? 0;

  InjuryType? get injuryType => injury?.type;
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
    @Default(0) int pointValue,

    /// Optymalna rola taktyczna zawodnika (`player_management.md`).
    /// Gra w tej roli daje bonus cohesion +2 i `roleFitMult` ×1.03
    /// (`squad_management.md`, `matchday_model.md`).
    required AssignedRole optimalRole,

    /// Previous overall rating (rounded) captured at season start.
    /// Used by the Development screen to compute OVR delta.
    int? previousOvr,

    /// Previous potentialStars captured at season start.
    /// Used by the Development screen to compute potential delta.
    double? previousPotential,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

extension PlayerX on Player {
  double overall([BalanceConfig balance = BalanceConfig.defaults]) =>
      attributes.overallForPosition(position, balance);

  double developmentCeilingOvr([
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    final stars = hidden.developmentCeilingStars > 0
        ? hidden.developmentCeilingStars
        : potentialStars;
    return _ceilingOvrForStars(stars);
  }

  /// Available for selection unless injured or suspended. Low stamina still
  /// allows play but hurts performance and raises injury risk.
  bool get isAvailable =>
      !(state.injury?.isActive ?? false) && state.suspensionGamesRemaining <= 0;

  /// Career totals across all seasons (profile UI).
  PlayerSeasonStats get careerSeasonStats =>
      aggregatePlayerSeasonStats(seasonStats);

  double staminaPerformanceMult([
    BalanceConfig balance = BalanceConfig.defaults,
  ]) => balance.player.performanceMult(state.stamina);

  double staminaInjuryRiskMult([
    BalanceConfig balance = BalanceConfig.defaults,
  ]) => balance.player.injuryRiskMult(state.stamina);

  double formMult([BalanceConfig balance = BalanceConfig.defaults]) =>
      balance.player.formMult(state.form);

  /// Applies the documented post-match form change while preserving every
  /// other PlayerState field (injury, cards, suspension and role included).
  Player withMatchForm({
    required int minutesPlayed,
    required double rating,
    required bool lost,
    BalanceConfig balance = BalanceConfig.defaults,
  }) {
    final b = balance.player;
    var nextForm = state.form;
    if (minutesPlayed <= 0) {
      if (nextForm < 6) {
        nextForm += b.noAppearanceFormDrift;
      } else if (nextForm > 6) {
        nextForm -= b.noAppearanceFormDrift;
      }
    } else {
      var delta = switch (rating) {
        >= 8.5 => 2.0,
        >= 7.5 => 1.0,
        >= 6.0 => 0.0,
        >= 4.5 => -1.0,
        _ => -2.0,
      };
      if (lost && delta < 0 && personality == PlayerPersonality.temperamental) {
        delta *= 1.5;
      }
      nextForm += delta;
    }
    return copyWith(state: state.copyWith(form: b.clampForm(nextForm)));
  }

  /// (`player_management.md` §pointValue).
  ///
  /// `pointValue = clamp(round(ovrComponent + potentialComponent +
  ///   ageComponent + contractComponent), -1000, 1000)`
  int computePointValue([BalanceConfig balance = BalanceConfig.defaults]) {
    final ovr = overall(balance);

    // 1. Komponent overall: (overall - 70) * 30  →  -600 … +870
    final ovrComponent = (ovr - 70) * 30;

    // 2. Komponent potencjału: potentialGap * (4.5*youngFactor + olderFactor)
    final ceilingOvr = _ceilingOvrForStars(potentialStars);
    final potentialGap = (ceilingOvr - ovr).clamp(0.0, 50.0);
    final youngFactor = age <= 26
        ? (4.5 - 0.5 * (age - 18)).clamp(0.0, 4.5)
        : 0.0;
    final olderFactor = age >= 27
        ? (0.8 - 0.08 * (age - 27)).clamp(0.15, 0.8)
        : 0.0;
    final potentialComponent = potentialGap * (4.5 * youngFactor + olderFactor);

    // 3. Komponent wieku: ageScore * 150  →  -150 … +150
    final double ageScore;
    if (age <= 24) {
      ageScore = 1.0;
    } else if (age >= 34) {
      ageScore = -1.0;
    } else {
      ageScore = 1.0 - 2.0 * (age - 24) / 10.0;
    }
    final ageComponent = ageScore * 150;

    // 4. Komponent kontraktowy: salaryScore * 260 * (0.5 + 0.5*lengthFactor)
    const pvMinSalary = 1000000;
    const pvMaxSalary = 60000000;
    final ovrNorm = ((ovr - 50) * 2 / 100).clamp(0.0, 1.0);
    final estimatedSalary =
        pvMinSalary +
        (pvMaxSalary - pvMinSalary) * (ovrNorm * ovrNorm * ovrNorm);
    final salaryScore = estimatedSalary > 0
        ? (1.0 - contract.salary / estimatedSalary).clamp(-1.0, 1.0)
        : 0.0;
    final lengthFactor = (contract.yearsRemaining / 5.0).clamp(0.0, 1.0);
    final contractComponent = salaryScore * 260 * (0.5 + 0.5 * lengthFactor);

    final raw =
        ovrComponent + potentialComponent + ageComponent + contractComponent;
    return raw.round().clamp(-1000, 1000);
  }

  /// Midpoint ceiling OVR for a given potential stars rating
  /// (`player_management.md` — tabela gwiazdek).
  static double _ceilingOvrForStars(double stars) {
    if (stars <= 0.5) return 52.5;
    if (stars <= 1.0) return 58.0;
    if (stars <= 1.5) return 63.0;
    if (stars <= 2.0) return 68.0;
    if (stars <= 2.5) return 73.0;
    if (stars <= 3.0) return 78.0;
    if (stars <= 3.5) return 82.5;
    if (stars <= 4.0) return 86.5;
    if (stars <= 4.5) return 90.5;
    return 96.0; // 5.0★
  }

  /// Przelicza i zapisuje [Player.pointValue] — wołać po każdej zmianie
  /// wpływającej na wynik (podpis / przedłużenie kontraktu, wymiana,
  /// rollover sezonu, tick developmentu).
  Player recalculatePointValue([
    BalanceConfig balance = BalanceConfig.defaults,
  ]) => copyWith(pointValue: computePointValue(balance));

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
    final activeInjury = state.injury;
    final remaining = activeInjury == null
        ? null
        : (activeInjury.daysRemaining - 1).clamp(0, b.injuryDaysClampMax);
    final nextInjury =
        activeInjury == null || remaining == null || remaining == 0
        ? null
        : activeInjury.copyWith(daysRemaining: remaining);
    return copyWith(
      state: state.copyWith(
        stamina: b.clampStamina(state.stamina + b.recoveryBetweenMatches),
        injury: nextInjury,
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
    @Default(0) int shotsOnTarget,
    @Default(0.0) double xg,
    @Default(0) int passes,
    @Default(0.0) double passAccuracy,
    @Default(0) int duelsWon,
    @Default(0) int offsides,
    @Default(0) int corners,
    @Default(0) int yellowCards,
    @Default(0) int redCards,
    @Default(0) int tackles,
    @Default(0) int interceptions,
    @Default(0) int saves,
    @Default(0) int shotsFaced,
    @Default(0) int ownGoals,
    @Default(false) bool cleanSheet,
    @Default(-1) int staminaAfterMatch,
    @Default(6.0) double rating,
  }) = _PlayerMatchStats;

  factory PlayerMatchStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerMatchStatsFromJson(json);
}
