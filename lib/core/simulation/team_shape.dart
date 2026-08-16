import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

/// A tactical delta on the three TeamShape axes.
class ShapeDelta {
  const ShapeDelta({this.def = 0, this.mid = 0, this.atk = 0});

  static const zero = ShapeDelta();

  final double def;
  final double mid;
  final double atk;

  ShapeDelta operator +(ShapeDelta other) => ShapeDelta(
    def: def + other.def,
    mid: mid + other.mid,
    atk: atk + other.atk,
  );

  ShapeDelta operator -() => ShapeDelta(def: -def, mid: -mid, atk: -atk);

  factory ShapeDelta.fromTactics(TacticsDelta delta) => ShapeDelta(
    def: delta.def.toDouble(),
    mid: delta.mid.toDouble(),
    atk: delta.atk.toDouble(),
  );
}

enum ShapeAxis { def, mid, atk }

/// Tactical D/M/A shape calculated for one team in a specific fixture.
class TeamShape {
  const TeamShape({required this.def, required this.mid, required this.atk});

  final double def;
  final double mid;
  final double atk;

  double tacticalMult(
    ShapeAxis axis, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    final value = switch (axis) {
      ShapeAxis.def => def,
      ShapeAxis.mid => mid,
      ShapeAxis.atk => atk,
    };
    return 1 +
        (value - balance.matchday.shapeBaseline) * balance.matchday.shapeWeight;
  }

  double get defTacticalMult =>
      1 +
      (def - BalanceConfig.defaults.matchday.shapeBaseline) *
          BalanceConfig.defaults.matchday.shapeWeight;

  double get midTacticalMult =>
      1 +
      (mid - BalanceConfig.defaults.matchday.shapeBaseline) *
          BalanceConfig.defaults.matchday.shapeWeight;

  double get atkTacticalMult =>
      1 +
      (atk - BalanceConfig.defaults.matchday.shapeBaseline) *
          BalanceConfig.defaults.matchday.shapeWeight;

  double tacticalMultiplierFor(
    ShapeAxis axis, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) => tacticalMult(axis, balance);

  @override
  String toString() => 'TeamShape(def: $def, mid: $mid, atk: $atk)';
}

/// Builds TeamShape from formation, settings, roles, matchups and head coach.
class TeamShapeCalculator {
  const TeamShapeCalculator({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  TeamShape calculate({
    required TacticsSetup tactics,
    required TacticsSetup opponentTactics,
    List<Player> lineup = const [],
    List<Player> opponentLineup = const [],
    StaffMember? headCoach,
  }) {
    final formation = balance.tactics.baseStatsFor(tactics.formation);
    final settings = ShapeDelta.fromTactics(
      balance.tactics.settingsDeltaFor(
        tempo: tactics.tempo,
        attackWidth: tactics.attackWidth,
        defensiveLine: tactics.defensiveLine,
        pressing: tactics.pressing,
      ),
    );
    final roles = lineup.fold<ShapeDelta>(
      ShapeDelta.zero,
      (sum, player) => sum + _roleDelta(player.state.role),
    );
    final formationMatchup = _formationMatchupDelta(
      tactics.formation,
      opponentTactics.formation,
    );
    final settingMatchup = _settingMatchupDelta(tactics, opponentTactics);
    final roleMatchup = _roleMatchupDelta(
      lineup,
      tactics,
      opponentTactics,
      opponentLineup,
    );
    final coachBoost = ShapeDelta(
      def: headCoachTacticsBoost(headCoach).toDouble(),
      mid: headCoachTacticsBoost(headCoach).toDouble(),
      atk: headCoachTacticsBoost(headCoach).toDouble(),
    );
    final total =
        settings +
        roles +
        formationMatchup +
        settingMatchup +
        roleMatchup +
        coachBoost;

    return TeamShape(
      def: formation.def + total.def,
      mid: formation.mid + total.mid,
      atk: formation.atk + total.atk,
    );
  }

  TeamShape calculateForTeams({
    required Team team,
    required Team opponent,
    List<Player>? lineup,
    List<Player>? opponentLineup,
  }) => calculate(
    tactics: team.tactics,
    opponentTactics: opponent.tactics,
    lineup: lineup ?? team.startingEleven,
    opponentLineup: opponentLineup ?? opponent.startingEleven,
    headCoach: team.staff.headCoach,
  );

  /// Staff Tactics ★ → the documented boost shared by def/mid/atk.
  static int headCoachTacticsBoost(StaffMember? headCoach) {
    if (headCoach == null || headCoach.attributes.tactics <= 0) return -5;
    return ((headCoach.attributes.tactics * 2) - 1).round().clamp(0, 9);
  }

  ShapeDelta _roleDelta(AssignedRole role) => role.map(
    gk: (r) => switch (r.role) {
      GkRole.standard => ShapeDelta.zero,
      GkRole.sweeperKeeper => const ShapeDelta(def: -1, mid: 2),
    },
    cb: (r) => switch (r.role) {
      CbRole.standard => ShapeDelta.zero,
      CbRole.ballPlayingDefender => const ShapeDelta(def: -1, mid: 2),
      CbRole.noNonsenseCentreBack => const ShapeDelta(def: 3, mid: -3),
    },
    fullBack: (r) => switch (r.role) {
      FullBackRole.standard => ShapeDelta.zero,
      FullBackRole.defensiveFullBack => const ShapeDelta(
        def: 3,
        mid: -1,
        atk: -2,
      ),
      FullBackRole.attackingFullBack => const ShapeDelta(
        def: -2,
        mid: 1,
        atk: 1,
      ),
    },
    wingBack: (r) => switch (r.role) {
      WingBackRole.standard => ShapeDelta.zero,
      WingBackRole.wingBack => const ShapeDelta(def: -2, atk: 2),
      WingBackRole.invertedWingBack => const ShapeDelta(
        def: -1,
        mid: 2,
        atk: -1,
      ),
    },
    cdm: (r) => switch (r.role) {
      CdmRole.standard => ShapeDelta.zero,
      CdmRole.regista => const ShapeDelta(def: -1, mid: 2, atk: -1),
      CdmRole.deepLyingPlaymaker => const ShapeDelta(def: -1, mid: 3, atk: -1),
      CdmRole.anchorMan => const ShapeDelta(def: 4, mid: -1, atk: -3),
    },
    cm: (r) => switch (r.role) {
      CmRole.standard => const ShapeDelta(mid: 1),
      CmRole.ballWinning => const ShapeDelta(def: 2, atk: -1),
      CmRole.playmaker => const ShapeDelta(def: -1, mid: 3, atk: -1),
      CmRole.boxToBox => const ShapeDelta(def: 1, mid: -1, atk: 1),
      CmRole.mezzala => const ShapeDelta(def: -2, mid: 1, atk: 2),
    },
    cam: (r) => switch (r.role) {
      CamRole.standard => ShapeDelta.zero,
      CamRole.playmaker => const ShapeDelta(def: -1, mid: 2, atk: -1),
      CamRole.shadowStriker => const ShapeDelta(def: -2, mid: -1, atk: 3),
    },
    winger: (r) => switch (r.role) {
      WingerRole.standard => ShapeDelta.zero,
      WingerRole.invertedWinger => const ShapeDelta(mid: 1, atk: -1),
      WingerRole.winger => const ShapeDelta(mid: -1, atk: 1),
    },
    striker: (r) => switch (r.role) {
      StrikerRole.standard => ShapeDelta.zero,
      StrikerRole.falseNine => const ShapeDelta(mid: 3, atk: -2),
      StrikerRole.deepLyingForward => const ShapeDelta(mid: -2, atk: 3),
      StrikerRole.pressingForward => const ShapeDelta(def: 2, atk: -1),
      StrikerRole.completeForward => const ShapeDelta(def: -1, mid: 1, atk: 1),
    },
  );

  ShapeDelta _formationMatchupDelta(Formation ours, Formation opponent) {
    final direct = _directFormationDelta(ours, opponent);
    if (direct != null) return direct;

    final a = balance.tactics.familyFor(ours);
    final b = balance.tactics.familyFor(opponent);
    if (a == b) return ShapeDelta.zero;
    final family = _familyDelta(a, b);
    return family ?? ShapeDelta.zero;
  }

  ShapeDelta? _directFormationDelta(Formation ours, Formation opponent) {
    final direct = <(Formation, Formation, ShapeDelta)>[
      (
        Formation.f4141,
        Formation.f343,
        const ShapeDelta(def: -1, mid: 2, atk: 1),
      ),
      (Formation.f4141, Formation.f3421, const ShapeDelta(def: -1, mid: 2)),
      (Formation.f4231, Formation.f352, const ShapeDelta(mid: 2, atk: 1)),
      (
        Formation.f352,
        Formation.f4141,
        const ShapeDelta(def: 1, mid: -2, atk: -1),
      ),
      (
        Formation.f451,
        Formation.f532,
        const ShapeDelta(def: 1, mid: -1, atk: -2),
      ),
      (
        Formation.f424,
        Formation.f5212,
        const ShapeDelta(def: 2, mid: -2, atk: -3),
      ),
      (
        Formation.f442,
        Formation.f41212Narrow,
        const ShapeDelta(def: -1, mid: 1, atk: 2),
      ),
      (
        Formation.f5212,
        Formation.f433,
        const ShapeDelta(def: -1, mid: 1, atk: 2),
      ),
      (
        Formation.f532,
        Formation.f4231,
        const ShapeDelta(def: -1, mid: 1, atk: 2),
      ),
    ];
    for (final entry in direct) {
      if (entry.$1 == ours && entry.$2 == opponent) return entry.$3;
      if (entry.$1 == opponent && entry.$2 == ours) return -entry.$3;
    }
    return null;
  }

  ShapeDelta? _familyDelta(FormationFamily ours, FormationFamily opponent) {
    final direct = <(FormationFamily, FormationFamily, ShapeDelta)>[
      (
        FormationFamily.threeBackWide,
        FormationFamily.fourBackWideBalanced,
        const ShapeDelta(mid: 1, atk: 2),
      ),
      (
        FormationFamily.threeBackWide,
        FormationFamily.fourBackCentralControl,
        const ShapeDelta(def: -1, mid: 1, atk: 2),
      ),
      (
        FormationFamily.threeBackWide,
        FormationFamily.fourBackDirectTwoStriker,
        const ShapeDelta(def: 1, atk: -2),
      ),
      (
        FormationFamily.threeBackWide,
        FormationFamily.fiveBackBlock,
        const ShapeDelta(def: 2, mid: -2, atk: -3),
      ),
      (
        FormationFamily.fourBackWideBalanced,
        FormationFamily.fourBackCentralControl,
        const ShapeDelta(mid: 1, atk: 1),
      ),
      (
        FormationFamily.fourBackWideBalanced,
        FormationFamily.fourBackDirectTwoStriker,
        const ShapeDelta(mid: 1, atk: 1),
      ),
      (
        FormationFamily.fourBackWideBalanced,
        FormationFamily.fiveBackBlock,
        const ShapeDelta(def: 1, mid: -1, atk: -2),
      ),
      (
        FormationFamily.fourBackCentralControl,
        FormationFamily.fourBackDirectTwoStriker,
        const ShapeDelta(def: -1, mid: 2),
      ),
      (
        FormationFamily.fourBackCentralControl,
        FormationFamily.fiveBackBlock,
        const ShapeDelta(def: -1, mid: 2),
      ),
      (
        FormationFamily.fourBackDirectTwoStriker,
        FormationFamily.fiveBackBlock,
        const ShapeDelta(def: -2, atk: 2),
      ),
    ];
    for (final entry in direct) {
      if (entry.$1 == ours && entry.$2 == opponent) return entry.$3;
      if (entry.$1 == opponent && entry.$2 == ours) return -entry.$3;
    }
    return null;
  }

  ShapeDelta _settingMatchupDelta(TacticsSetup ours, TacticsSetup opponent) {
    var result = ShapeDelta.zero;

    if (ours.defensiveLine == DefensiveLine.deep &&
        opponent.tempo == Tempo.fast) {
      result += const ShapeDelta(def: 1);
    }
    if (ours.defensiveLine == DefensiveLine.deep &&
        opponent.tempo == Tempo.slow) {
      result += const ShapeDelta(def: -1);
    }
    if (ours.defensiveLine == DefensiveLine.high &&
        opponent.tempo == Tempo.slow) {
      result += const ShapeDelta(mid: 1);
    }
    if (ours.defensiveLine == DefensiveLine.high &&
        opponent.tempo == Tempo.fast) {
      result += const ShapeDelta(def: -1, atk: -1);
    }

    if (ours.pressing == PressingIntensity.low &&
        opponent.tempo == Tempo.fast) {
      result += const ShapeDelta(mid: 1);
    }
    if (ours.pressing == PressingIntensity.low &&
        opponent.pressing == PressingIntensity.gegenpressing) {
      result += const ShapeDelta(def: 1, mid: 1);
    }
    if (ours.pressing == PressingIntensity.high &&
        opponent.tempo == Tempo.slow) {
      result += const ShapeDelta(mid: 1, atk: 1);
    }
    if (ours.pressing == PressingIntensity.gegenpressing &&
        opponent.pressing == PressingIntensity.low) {
      result += const ShapeDelta(mid: 1, atk: 1);
    }
    if (ours.pressing == PressingIntensity.gegenpressing &&
        opponent.tempo == Tempo.fast) {
      result += const ShapeDelta(mid: -1);
    }

    if (ours.attackWidth == AttackWidth.wide &&
        opponent.attackWidth == AttackWidth.narrow) {
      result += const ShapeDelta(atk: 1);
    }
    if (ours.attackWidth == AttackWidth.narrow &&
        opponent.attackWidth == AttackWidth.wide) {
      result += const ShapeDelta(mid: 1);
    }
    if (ours.attackWidth == AttackWidth.wide &&
        balance.tactics.familyFor(opponent.formation) ==
            FormationFamily.threeBackWide) {
      result += const ShapeDelta(atk: 1);
    }
    if (ours.attackWidth == AttackWidth.wide &&
        balance.tactics.familyFor(opponent.formation) ==
            FormationFamily.fiveBackBlock) {
      result += const ShapeDelta(def: 1, atk: -1);
    }
    if (ours.attackWidth == AttackWidth.narrow &&
        opponent.formation == Formation.f442) {
      result += const ShapeDelta(mid: 1);
    }
    if (ours.attackWidth == AttackWidth.narrow &&
        opponent.formation == Formation.f433) {
      result += const ShapeDelta(mid: 1);
    }
    if (ours.attackWidth == AttackWidth.narrow &&
        balance.tactics.familyFor(opponent.formation) ==
            FormationFamily.fourBackCentralControl) {
      result += const ShapeDelta(mid: -1);
    }

    if (ours.defensiveLine == DefensiveLine.deep &&
        (opponent.formation == Formation.f424 ||
            opponent.formation == Formation.f343)) {
      result += const ShapeDelta(def: 1);
    }
    if (ours.defensiveLine == DefensiveLine.high &&
        balance.tactics.familyFor(opponent.formation) ==
            FormationFamily.fiveBackBlock) {
      result += const ShapeDelta(atk: -1);
    }

    return result;
  }

  ShapeDelta _roleMatchupDelta(
    List<Player> lineup,
    TacticsSetup tactics,
    TacticsSetup opponentTactics,
    List<Player> opponentLineup,
  ) {
    var result = ShapeDelta.zero;
    for (final player in lineup) {
      final role = player.state.role;
      if (_isNoNonsense(role) &&
          (opponentTactics.formation == Formation.f424 ||
              opponentTactics.formation == Formation.f343)) {
        result += const ShapeDelta(def: 1);
      }
      if (_isDefensiveFullBack(role) &&
          opponentTactics.attackWidth == AttackWidth.wide &&
          _hasAttackingWideRole(opponentLineup)) {
        result += const ShapeDelta(def: 1);
      }
      if (_isAnchor(role) && _hasShadowOrCompleteForward(opponentLineup)) {
        result += const ShapeDelta(def: 1);
      }
      if (_isBallPlayingDefender(role) &&
          opponentTactics.pressing == PressingIntensity.low &&
          opponentTactics.defensiveLine == DefensiveLine.deep) {
        result += const ShapeDelta(mid: 1);
      }
      if (_isRegistaOrDeepPlaymaker(role) &&
          opponentTactics.pressing == PressingIntensity.high &&
          opponentTactics.defensiveLine == DefensiveLine.high) {
        result += const ShapeDelta(mid: 1);
      }
      if (_isPlaymaker(role) &&
          opponentTactics.attackWidth == AttackWidth.narrow &&
          (opponentTactics.formation == Formation.f451 ||
              opponentTactics.formation == Formation.f4141)) {
        result += const ShapeDelta(mid: 1);
      }
      if (_isInvertedWingBack(role) &&
          (opponentTactics.formation == Formation.f41212Narrow ||
              opponentTactics.formation == Formation.f4312)) {
        result += const ShapeDelta(mid: 1);
      }
      if (_isShadowStriker(role) &&
          opponentTactics.defensiveLine == DefensiveLine.high &&
          opponentTactics.attackWidth == AttackWidth.wide) {
        result += const ShapeDelta(atk: 1);
      }
      if (_isInvertedWinger(role) && _hasAttackingWideRole(opponentLineup)) {
        result += const ShapeDelta(atk: 1);
      }
      if (_isFalseNine(role) &&
          opponentTactics.defensiveLine == DefensiveLine.deep &&
          _hasNoNonsenseDefender(opponentLineup)) {
        result += const ShapeDelta(mid: 1);
      }
      if (_isPressingForward(role) && _hasBallPlayingDefender(opponentLineup)) {
        result += const ShapeDelta(atk: 1);
      }
      if (_isCompleteForward(role) &&
          balance.tactics.familyFor(opponentTactics.formation) ==
              FormationFamily.fiveBackBlock) {
        result += const ShapeDelta(atk: 1);
      }
      if (_isAttackingFullBack(role) &&
          opponentTactics.tempo == Tempo.fast &&
          opponentTactics.attackWidth == AttackWidth.wide) {
        result += const ShapeDelta(def: -1);
      }
      if (_isSweeperKeeper(role) && opponentTactics.tempo == Tempo.fast) {
        result += const ShapeDelta(mid: -1);
      }
      if (_isBallPlayingDefender(role) &&
          opponentTactics.pressing == PressingIntensity.gegenpressing) {
        result += const ShapeDelta(mid: -1);
      }
      if (_isRegista(role) &&
          opponentTactics.pressing == PressingIntensity.gegenpressing &&
          opponentTactics.defensiveLine == DefensiveLine.high) {
        result += const ShapeDelta(mid: -1);
      }
    }
    return result;
  }

  bool _hasAttackingWideRole(List<Player> players) => players.any(
    (player) =>
        _isAttackingFullBack(player.state.role) ||
        _isWingBack(player.state.role),
  );

  bool _hasShadowOrCompleteForward(List<Player> players) => players.any(
    (player) =>
        _isShadowStriker(player.state.role) ||
        _isCompleteForward(player.state.role),
  );

  bool _hasNoNonsenseDefender(List<Player> players) =>
      players.any((player) => _isNoNonsense(player.state.role));

  bool _hasBallPlayingDefender(List<Player> players) =>
      players.any((player) => _isBallPlayingDefender(player.state.role));

  bool _isNoNonsense(AssignedRole role) => role.map(
    cb: (r) => r.role == CbRole.noNonsenseCentreBack,
    gk: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isDefensiveFullBack(AssignedRole role) => role.map(
    fullBack: (r) => r.role == FullBackRole.defensiveFullBack,
    gk: (_) => false,
    cb: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isAttackingFullBack(AssignedRole role) => role.map(
    fullBack: (r) => r.role == FullBackRole.attackingFullBack,
    gk: (_) => false,
    cb: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isWingBack(AssignedRole role) => role.map(
    wingBack: (_) => true,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isAnchor(AssignedRole role) => role.map(
    cdm: (r) => r.role == CdmRole.anchorMan,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isBallPlayingDefender(AssignedRole role) => role.map(
    cb: (r) => r.role == CbRole.ballPlayingDefender,
    gk: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isRegistaOrDeepPlaymaker(AssignedRole role) => role.map(
    cdm: (r) =>
        r.role == CdmRole.regista || r.role == CdmRole.deepLyingPlaymaker,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isRegista(AssignedRole role) => role.map(
    cdm: (r) => r.role == CdmRole.regista,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isPlaymaker(AssignedRole role) => role.map(
    cm: (r) => r.role == CmRole.playmaker,
    cam: (r) => r.role == CamRole.playmaker,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isInvertedWingBack(AssignedRole role) => role.map(
    wingBack: (r) => r.role == WingBackRole.invertedWingBack,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isShadowStriker(AssignedRole role) => role.map(
    cam: (r) => r.role == CamRole.shadowStriker,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );

  bool _isInvertedWinger(AssignedRole role) => role.map(
    winger: (r) => r.role == WingerRole.invertedWinger,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    striker: (_) => false,
  );

  bool _isFalseNine(AssignedRole role) => role.map(
    striker: (r) => r.role == StrikerRole.falseNine,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
  );

  bool _isPressingForward(AssignedRole role) => role.map(
    striker: (r) => r.role == StrikerRole.pressingForward,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
  );

  bool _isCompleteForward(AssignedRole role) => role.map(
    striker: (r) => r.role == StrikerRole.completeForward,
    gk: (_) => false,
    cb: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
  );

  bool _isSweeperKeeper(AssignedRole role) => role.map(
    gk: (r) => r.role == GkRole.sweeperKeeper,
    cb: (_) => false,
    fullBack: (_) => false,
    wingBack: (_) => false,
    cdm: (_) => false,
    cm: (_) => false,
    cam: (_) => false,
    winger: (_) => false,
    striker: (_) => false,
  );
}
