import 'package:new_football/core/models/enums.dart';

/// Base `def` / `mid` / `atk` power bars (0-100) for a [Formation].
///
/// Values are a game-balance opinion, not derived from a formula.
/// They do not need to sum to 100.
class FormationBaseStats {
  const FormationBaseStats({
    required this.def,
    required this.mid,
    required this.atk,
  });

  final int def;
  final int mid;
  final int atk;
}

/// Delta applied to `def` / `mid` / `atk` by a tactical setting value
/// (tempo, attack width, defensive line, pressing).
class TacticsDelta {
  const TacticsDelta({this.def = 0, this.mid = 0, this.atk = 0});

  final int def;
  final int mid;
  final int atk;

  TacticsDelta operator +(TacticsDelta other) {
    return TacticsDelta(
      def: def + other.def,
      mid: mid + other.mid,
      atk: atk + other.atk,
    );
  }
}

/// High-level formation family used for rock-paper-scissors balance.
enum FormationFamily {
  threeBackWide,
  fourBackWideBalanced,
  fourBackCentralControl,
  fourBackDirectTwoStriker,
  fiveBackBlock,
}

/// Optional semantic scale for matchup strength.
enum MatchupEdge {
  tiny(0.01),
  low(0.02),
  medium(0.03),
  high(0.04),
  veryHigh(0.05);

  const MatchupEdge(this.value);
  final double value;
}

/// Counter-formation bonus: [formationA] gets [bonusForA] vs [formationB].
class FormationMatchup {
  const FormationMatchup({
    required this.formationA,
    required this.formationB,
    required this.bonusForA,
  });

  final Formation formationA;
  final Formation formationB;
  final double bonusForA;
}

/// Counter-family bonus: [familyA] gets [bonusForA] vs [familyB].
class FormationFamilyMatchup {
  const FormationFamilyMatchup({
    required this.familyA,
    required this.familyB,
    required this.bonusForA,
  });

  final FormationFamily familyA;
  final FormationFamily familyB;
  final double bonusForA;
}

/// All tactical balance knobs: formation base stats, tactical-setting deltas,
/// formation families, family counter-matchups, and direct formation overrides.
///
/// Deliberately excludes formation layout / pitch coordinates.
class TacticsBalance {
  const TacticsBalance({
    this.matchupClamp = 0.15,
    this.formationBaseStats = _defaultFormationBaseStats,
    this.tempoDelta = _defaultTempoDelta,
    this.attackWidthDelta = _defaultAttackWidthDelta,
    this.defensiveLineDelta = _defaultDefensiveLineDelta,
    this.pressingDelta = _defaultPressingDelta,
    this.formationFamily = _defaultFormationFamily,
    this.formationFamilyMatchups = _defaultFormationFamilyMatchups,
    this.formationMatchups = _defaultFormationMatchups,
  });

  /// Total counter bonus (formation + tactical counters) clamp: ±this value.
  final double matchupClamp;

  final Map<Formation, FormationBaseStats> formationBaseStats;
  final Map<Tempo, TacticsDelta> tempoDelta;
  final Map<AttackWidth, TacticsDelta> attackWidthDelta;
  final Map<DefensiveLine, TacticsDelta> defensiveLineDelta;
  final Map<PressingIntensity, TacticsDelta> pressingDelta;

  final Map<Formation, FormationFamily> formationFamily;
  final List<FormationFamilyMatchup> formationFamilyMatchups;
  final List<FormationMatchup> formationMatchups;

  FormationBaseStats baseStatsFor(Formation formation) {
    final stats = formationBaseStats[formation];
    if (stats == null) {
      throw ArgumentError.value(
        formation,
        'formation',
        'No FormationBaseStats defined for this formation.',
      );
    }
    return stats;
  }

  FormationFamily familyFor(Formation formation) {
    final family = formationFamily[formation];
    if (family == null) {
      throw ArgumentError.value(
        formation,
        'formation',
        'No FormationFamily defined for this formation.',
      );
    }
    return family;
  }

  /// Sum of tactical-setting deltas (tempo, width, line, pressing).
  /// Formation base + role deltas are added separately by the caller.
  TacticsDelta settingsDeltaFor({
    required Tempo tempo,
    required AttackWidth attackWidth,
    required DefensiveLine defensiveLine,
    required PressingIntensity pressing,
  }) {
    final tempoD = tempoDelta[tempo] ?? const TacticsDelta();
    final widthD = attackWidthDelta[attackWidth] ?? const TacticsDelta();
    final lineD = defensiveLineDelta[defensiveLine] ?? const TacticsDelta();
    final pressD = pressingDelta[pressing] ?? const TacticsDelta();

    return tempoD + widthD + lineD + pressD;
  }

  /// Family-level matchup bonus. No entry = 0.
  double formationFamilyMatchupBonus(
    FormationFamily family,
    FormationFamily opponent,
  ) {
    for (final matchup in formationFamilyMatchups) {
      if (matchup.familyA == family && matchup.familyB == opponent) {
        return matchup.bonusForA;
      }
      if (matchup.familyA == opponent && matchup.familyB == family) {
        return -matchup.bonusForA;
      }
    }
    return 0;
  }

  /// Final formation matchup bonus from [formation]'s perspective.
  ///
  /// Priority:
  /// 1. direct formation-vs-formation override,
  /// 2. family-vs-family fallback,
  /// 3. 0 if no rule exists.
  double formationMatchupBonus(Formation formation, Formation opponent) {
    for (final matchup in formationMatchups) {
      if (matchup.formationA == formation && matchup.formationB == opponent) {
        return matchup.bonusForA;
      }
      if (matchup.formationA == opponent && matchup.formationB == formation) {
        return -matchup.bonusForA;
      }
    }

    final family = familyFor(formation);
    final opponentFamily = familyFor(opponent);
    return formationFamilyMatchupBonus(family, opponentFamily);
  }

  /// `def` / `mid` / `atk` bases for all in-game formations.
  static const Map<Formation, FormationBaseStats> _defaultFormationBaseStats = {
    // 3 at the back
    Formation.f343: FormationBaseStats(def: 42, mid: 55, atk: 68),
    Formation.f3421: FormationBaseStats(def: 46, mid: 64, atk: 60),
    Formation.f352: FormationBaseStats(def: 50, mid: 70, atk: 55),
    Formation.f3511: FormationBaseStats(def: 49, mid: 71, atk: 54),

    // 4 at the back — control / central shapes
    Formation.f41212Narrow: FormationBaseStats(def: 56, mid: 64, atk: 58),
    Formation.f4132: FormationBaseStats(def: 53, mid: 67, atk: 59),
    Formation.f4141: FormationBaseStats(def: 62, mid: 74, atk: 42),
    Formation.f4231: FormationBaseStats(def: 56, mid: 68, atk: 57),
    Formation.f4231Wide: FormationBaseStats(def: 53, mid: 62, atk: 64),
    Formation.f4312: FormationBaseStats(def: 52, mid: 65, atk: 61),
    Formation.f4321: FormationBaseStats(def: 54, mid: 67, atk: 57),

    // 4 at the back — attacking extreme
    Formation.f424: FormationBaseStats(def: 40, mid: 45, atk: 75),

    // 4-3-3 family
    Formation.f433: FormationBaseStats(def: 55, mid: 60, atk: 62),
    Formation.f433Attack: FormationBaseStats(def: 50, mid: 58, atk: 68),
    Formation.f433Defend: FormationBaseStats(def: 61, mid: 58, atk: 55),

    // 4-4-2 family
    Formation.f442: FormationBaseStats(def: 58, mid: 55, atk: 60),
    Formation.f442Defend: FormationBaseStats(def: 64, mid: 56, atk: 51),

    // 4-5-1
    Formation.f451: FormationBaseStats(def: 60, mid: 72, atk: 48),

    // 5 at the back
    Formation.f5212: FormationBaseStats(def: 70, mid: 52, atk: 55),
    Formation.f523: FormationBaseStats(def: 68, mid: 48, atk: 62),
    Formation.f532: FormationBaseStats(def: 72, mid: 58, atk: 52),
  };

  static const Map<Tempo, TacticsDelta> _defaultTempoDelta = {
    Tempo.slow: TacticsDelta(def: 2, mid: 3, atk: -4),
    Tempo.balanced: TacticsDelta(mid: 1),
    Tempo.fast: TacticsDelta(def: -3, mid: -2, atk: 6),
  };

  static const Map<AttackWidth, TacticsDelta> _defaultAttackWidthDelta = {
    AttackWidth.narrow: TacticsDelta(def: 1, mid: 2, atk: -2),
    AttackWidth.balanced: TacticsDelta(mid: 1),
    AttackWidth.wide: TacticsDelta(def: -3, mid: -1, atk: 4),
  };

  static const Map<DefensiveLine, TacticsDelta> _defaultDefensiveLineDelta = {
    DefensiveLine.deep: TacticsDelta(def: 3, atk: -3),
    DefensiveLine.normal: TacticsDelta(),
    DefensiveLine.high: TacticsDelta(def: -4, atk: 4),
  };

  static const Map<PressingIntensity, TacticsDelta> _defaultPressingDelta = {
    PressingIntensity.low: TacticsDelta(def: 3, mid: -1, atk: -2),
    PressingIntensity.medium: TacticsDelta(),
    PressingIntensity.high: TacticsDelta(def: -3, mid: 2, atk: 1),
    PressingIntensity.gegenpressing: TacticsDelta(def: -5, mid: 3, atk: 2),
  };

  /// Final family grouping based on the agreed 5-family model.
  static const Map<Formation, FormationFamily> _defaultFormationFamily = {
    // 1. 3-back wide
    Formation.f343: FormationFamily.threeBackWide,
    Formation.f3421: FormationFamily.threeBackWide,
    Formation.f352: FormationFamily.threeBackWide,
    Formation.f3511: FormationFamily.threeBackWide,

    // 2. 4-back wide balanced
    Formation.f433: FormationFamily.fourBackWideBalanced,
    Formation.f433Attack: FormationFamily.fourBackWideBalanced,
    Formation.f433Defend: FormationFamily.fourBackWideBalanced,
    Formation.f4231Wide: FormationFamily.fourBackWideBalanced,

    // 3. 4-back central control
    Formation.f4231: FormationFamily.fourBackCentralControl,
    Formation.f4141: FormationFamily.fourBackCentralControl,
    Formation.f451: FormationFamily.fourBackCentralControl,
    Formation.f41212Narrow: FormationFamily.fourBackCentralControl,
    Formation.f4312: FormationFamily.fourBackCentralControl,
    Formation.f4321: FormationFamily.fourBackCentralControl,

    // 4. 4-back direct two-striker
    Formation.f442: FormationFamily.fourBackDirectTwoStriker,
    Formation.f442Defend: FormationFamily.fourBackDirectTwoStriker,
    Formation.f4132: FormationFamily.fourBackDirectTwoStriker,
    Formation.f424: FormationFamily.fourBackDirectTwoStriker,

    // 5. 5-back block
    Formation.f5212: FormationFamily.fiveBackBlock,
    Formation.f523: FormationFamily.fiveBackBlock,
    Formation.f532: FormationFamily.fiveBackBlock,
  };

  /// Family rock-paper-scissors based on the agreed relation map:
  ///
  /// - 2, 3 < 1 < 4, 5
  /// - 3, 5 < 2 < 4, 1
  /// - 4, 5 < 3 < 1, 2
  /// - 1, 2 < 4 < 3, 5
  /// - 1, 4 < 5 < 2, 3
  ///
  /// Only one direction is stored; reverse lookup returns the negative value.
  static const List<FormationFamilyMatchup> _defaultFormationFamilyMatchups = [
    // 1 > 3, 4
    FormationFamilyMatchup(
      familyA: FormationFamily.threeBackWide,
      familyB: FormationFamily.fourBackCentralControl,
      bonusForA: 0.03,
    ),
    FormationFamilyMatchup(
      familyA: FormationFamily.threeBackWide,
      familyB: FormationFamily.fourBackDirectTwoStriker,
      bonusForA: 0.02,
    ),

    // 2 > 1, 4
    FormationFamilyMatchup(
      familyA: FormationFamily.fourBackWideBalanced,
      familyB: FormationFamily.threeBackWide,
      bonusForA: 0.03,
    ),
    FormationFamilyMatchup(
      familyA: FormationFamily.fourBackWideBalanced,
      familyB: FormationFamily.fourBackDirectTwoStriker,
      bonusForA: 0.02,
    ),

    // 3 > 2, 5
    FormationFamilyMatchup(
      familyA: FormationFamily.fourBackCentralControl,
      familyB: FormationFamily.fourBackWideBalanced,
      bonusForA: 0.03,
    ),
    FormationFamilyMatchup(
      familyA: FormationFamily.fourBackCentralControl,
      familyB: FormationFamily.fiveBackBlock,
      bonusForA: 0.02,
    ),

    // 4 > 1, 3
    FormationFamilyMatchup(
      familyA: FormationFamily.fourBackDirectTwoStriker,
      familyB: FormationFamily.threeBackWide,
      bonusForA: 0.03,
    ),
    FormationFamilyMatchup(
      familyA: FormationFamily.fourBackDirectTwoStriker,
      familyB: FormationFamily.fourBackCentralControl,
      bonusForA: 0.03,
    ),

    // 5 > 2, 4
    FormationFamilyMatchup(
      familyA: FormationFamily.fiveBackBlock,
      familyB: FormationFamily.fourBackWideBalanced,
      bonusForA: 0.03,
    ),
    FormationFamilyMatchup(
      familyA: FormationFamily.fiveBackBlock,
      familyB: FormationFamily.fourBackDirectTwoStriker,
      bonusForA: 0.04,
    ),
  ];

  /// Direct formation-vs-formation overrides.
  ///
  /// These take priority over family matchups and are used only for the most
  /// characteristic or deliberately stronger / weaker pairings.
  static const List<FormationMatchup> _defaultFormationMatchups = [
    // 4-back wide balanced vs 3-back wide
    FormationMatchup(
      formationA: Formation.f433,
      formationB: Formation.f343,
      bonusForA: 0.05,
    ),
    FormationMatchup(
      formationA: Formation.f4231Wide,
      formationB: Formation.f343,
      bonusForA: 0.05,
    ),
    FormationMatchup(
      formationA: Formation.f433Attack,
      formationB: Formation.f3421,
      bonusForA: 0.04,
    ),
    FormationMatchup(
      formationA: Formation.f433Defend,
      formationB: Formation.f352,
      bonusForA: 0.02,
    ),

    // 3-back wide vs central control / direct 2-ST
    FormationMatchup(
      formationA: Formation.f352,
      formationB: Formation.f451,
      bonusForA: 0.04,
    ),
    FormationMatchup(
      formationA: Formation.f3421,
      formationB: Formation.f4141,
      bonusForA: 0.03,
    ),
    FormationMatchup(
      formationA: Formation.f3511,
      formationB: Formation.f4312,
      bonusForA: 0.02,
    ),

    // direct two-striker vs 3-back wide
    FormationMatchup(
      formationA: Formation.f442,
      formationB: Formation.f352,
      bonusForA: 0.04,
    ),
    FormationMatchup(
      formationA: Formation.f4132,
      formationB: Formation.f3421,
      bonusForA: 0.04,
    ),
    FormationMatchup(
      formationA: Formation.f442Defend,
      formationB: Formation.f343,
      bonusForA: 0.03,
    ),
    FormationMatchup(
      formationA: Formation.f424,
      formationB: Formation.f343,
      bonusForA: 0.05,
    ),

    // central control vs wide balanced
    FormationMatchup(
      formationA: Formation.f451,
      formationB: Formation.f433,
      bonusForA: 0.04,
    ),
    FormationMatchup(
      formationA: Formation.f4141,
      formationB: Formation.f433Attack,
      bonusForA: 0.05,
    ),
    FormationMatchup(
      formationA: Formation.f4231,
      formationB: Formation.f4231Wide,
      bonusForA: 0.02,
    ),
    FormationMatchup(
      formationA: Formation.f41212Narrow,
      formationB: Formation.f433,
      bonusForA: 0.03,
    ),

    // central control vs 5-back block
    FormationMatchup(
      formationA: Formation.f4231,
      formationB: Formation.f532,
      bonusForA: 0.04,
    ),
    FormationMatchup(
      formationA: Formation.f4312,
      formationB: Formation.f5212,
      bonusForA: 0.03,
    ),
    FormationMatchup(
      formationA: Formation.f41212Narrow,
      formationB: Formation.f532,
      bonusForA: 0.04,
    ),

    // 5-back block vs wide balanced / direct 2-ST
    FormationMatchup(
      formationA: Formation.f532,
      formationB: Formation.f424,
      bonusForA: 0.05,
    ),
    FormationMatchup(
      formationA: Formation.f532,
      formationB: Formation.f442,
      bonusForA: 0.03,
    ),
    FormationMatchup(
      formationA: Formation.f5212,
      formationB: Formation.f442Defend,
      bonusForA: 0.02,
    ),
    FormationMatchup(
      formationA: Formation.f523,
      formationB: Formation.f433,
      bonusForA: 0.03,
    ),

    // negative overrides for especially poor pairings
    FormationMatchup(
      formationA: Formation.f433,
      formationB: Formation.f532,
      bonusForA: -0.04,
    ),
    FormationMatchup(
      formationA: Formation.f4231Wide,
      formationB: Formation.f532,
      bonusForA: -0.03,
    ),
    FormationMatchup(
      formationA: Formation.f442,
      formationB: Formation.f433,
      bonusForA: -0.03,
    ),
    FormationMatchup(
      formationA: Formation.f424,
      formationB: Formation.f532,
      bonusForA: -0.05,
    ),
    FormationMatchup(
      formationA: Formation.f451,
      formationB: Formation.f352,
      bonusForA: -0.04,
    ),
    FormationMatchup(
      formationA: Formation.f4141,
      formationB: Formation.f442,
      bonusForA: -0.03,
    ),
  ];
}
