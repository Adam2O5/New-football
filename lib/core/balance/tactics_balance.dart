import 'package:new_football/core/models/enums.dart';

/// Base `def` / `mid` / `atk` power bars (0-100) for a [Formation].
///
/// Values are a game-balance opinion, not derived from a formula — tune
/// freely in `tactics.md` review passes. Not required to sum to 100.
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

/// All tactical balance knobs (`tactics.md`): formation base stats,
/// tactical-setting deltas, and formation counter-matchups.
///
/// Deliberately excludes formation *layout* (pitch coordinates) — that is
/// purely visual and lives in `formation_layout.dart`.
class TacticsBalance {
  const TacticsBalance({
    this.matchupClamp = 0.15,
    this.formationBaseStats = _defaultFormationBaseStats,
    this.tempoDelta = _defaultTempoDelta,
    this.attackWidthDelta = _defaultAttackWidthDelta,
    this.defensiveLineDelta = _defaultDefensiveLineDelta,
    this.pressingDelta = _defaultPressingDelta,
    this.formationMatchups = _defaultFormationMatchups,
  });

  /// Total counter bonus (formation + settings) clamp: ±this value.
  final double matchupClamp;

  final Map<Formation, FormationBaseStats> formationBaseStats;
  final Map<Tempo, TacticsDelta> tempoDelta;
  final Map<AttackWidth, TacticsDelta> attackWidthDelta;
  final Map<DefensiveLine, TacticsDelta> defensiveLineDelta;
  final Map<PressingIntensity, TacticsDelta> pressingDelta;
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

  /// Sum of tactical-setting deltas (tempo, width, line, pressing) for a
  /// given combination of settings. Formation base + role deltas are added
  /// separately by the caller.
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
    return TacticsDelta(
      def: tempoD.def + widthD.def + lineD.def + pressD.def,
      mid: tempoD.mid + widthD.mid + lineD.mid + pressD.mid,
      atk: tempoD.atk + widthD.atk + lineD.atk + pressD.atk,
    );
  }

  /// Counter-formation bonus for [formation] vs [opponent], from [formation]'s
  /// perspective. Looks up direct entries in both directions; no entry = 0.
  double formationMatchupBonus(Formation formation, Formation opponent) {
    for (final matchup in formationMatchups) {
      if (matchup.formationA == formation && matchup.formationB == opponent) {
        return matchup.bonusForA;
      }
      if (matchup.formationA == opponent && matchup.formationB == formation) {
        return -matchup.bonusForA;
      }
    }
    return 0;
  }

  /// `def` / `mid` / `atk` bases for all 21 in-game formations.
  ///
  /// Derived from shape philosophy (`tactics.md` §1-3): more defenders/deeper
  /// blocks push `def` up, congested/creative midfields push `mid` up, extra
  /// forward bodies push `atk` up. `attack` / `defend` / `wide` variants of
  /// the same numeric shape are shifted symmetrically around their base.
  static const _defaultFormationBaseStats = {
    // 3 at the back
    Formation.f343: FormationBaseStats(def: 42, mid: 55, atk: 68),
    Formation.f3421: FormationBaseStats(def: 46, mid: 64, atk: 60),
    Formation.f352: FormationBaseStats(def: 50, mid: 70, atk: 55),
    Formation.f3511: FormationBaseStats(def: 49, mid: 71, atk: 54),

    // 4 at the back — possession / control shapes
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

  static const _defaultTempoDelta = {
    Tempo.slow: TacticsDelta(def: 2, mid: 3, atk: -4),
    Tempo.balanced: TacticsDelta(),
    Tempo.fast: TacticsDelta(def: -4, mid: -3, atk: 6),
  };

  static const _defaultAttackWidthDelta = {
    AttackWidth.narrow: TacticsDelta(def: 1, mid: 2, atk: -2),
    AttackWidth.balanced: TacticsDelta(),
    AttackWidth.wide: TacticsDelta(def: -3, mid: -1, atk: 4),
  };

  static const _defaultDefensiveLineDelta = {
    DefensiveLine.deep: TacticsDelta(def: 6, atk: -3),
    DefensiveLine.normal: TacticsDelta(),
    DefensiveLine.high: TacticsDelta(def: -4, atk: 3),
  };

  static const _defaultPressingDelta = {
    PressingIntensity.low: TacticsDelta(def: 3, mid: -2, atk: -2),
    PressingIntensity.medium: TacticsDelta(),
    PressingIntensity.high: TacticsDelta(def: -2, mid: 2, atk: 1),
    PressingIntensity.gegenpressing: TacticsDelta(def: -5, mid: 3, atk: 2),
  };

  static const _defaultFormationMatchups = [
    FormationMatchup(
      formationA: Formation.f433,
      formationB: Formation.f442,
      bonusForA: 0.06,
    ),
    FormationMatchup(
      formationA: Formation.f442,
      formationB: Formation.f352,
      bonusForA: 0.05,
    ),
    FormationMatchup(
      formationA: Formation.f451,
      formationB: Formation.f433,
      bonusForA: 0.05,
    ),
    FormationMatchup(
      formationA: Formation.f352,
      formationB: Formation.f442,
      bonusForA: 0.05,
    ),
    FormationMatchup(
      formationA: Formation.f532,
      formationB: Formation.f424,
      bonusForA: 0.08,
    ),
    FormationMatchup(
      formationA: Formation.f442Defend,
      formationB: Formation.f424,
      bonusForA: 0.08,
    ),
    FormationMatchup(
      formationA: Formation.f424,
      formationB: Formation.f343,
      bonusForA: 0.05,
    ),
    FormationMatchup(
      formationA: Formation.f424,
      formationB: Formation.f532,
      bonusForA: 0.04,
    ),
    FormationMatchup(
      formationA: Formation.f523,
      formationB: Formation.f451,
      bonusForA: 0.04,
    ),
    FormationMatchup(
      formationA: Formation.f343,
      formationB: Formation.f532,
      bonusForA: -0.06,
    ),
    FormationMatchup(
      formationA: Formation.f433,
      formationB: Formation.f442Defend,
      bonusForA: -0.05,
    ),
  ];
}
