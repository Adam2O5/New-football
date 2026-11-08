export 'package:new_football/core/balance/tactics_balance.dart' show ShapeDelta;

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

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
      def: headCoachTacticsBoost(headCoach, balance.staff).toDouble(),
      mid: headCoachTacticsBoost(headCoach, balance.staff).toDouble(),
      atk: headCoachTacticsBoost(headCoach, balance.staff).toDouble(),
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
  static int headCoachTacticsBoost(
    StaffMember? headCoach, [
    StaffBalance balance = const StaffBalance(),
  ]) {
    if (headCoach == null || headCoach.attributes.tactics <= 0) {
      return balance.missingHeadCoachShapeBoost;
    }
    return ((headCoach.attributes.tactics * balance.headCoachShapePerStar) -
            balance.headCoachShapeOffset)
        .round()
        .clamp(balance.headCoachShapeMin, balance.headCoachShapeMax);
  }

  ShapeDelta _roleDelta(AssignedRole role) =>
      balance.tactics.roleShapeDeltas[role.map<Enum>(
        gk: (r) => r.role,
        cb: (r) => r.role,
        fullBack: (r) => r.role,
        wingBack: (r) => r.role,
        cdm: (r) => r.role,
        cm: (r) => r.role,
        cam: (r) => r.role,
        winger: (r) => r.role,
        striker: (r) => r.role,
      )] ??
      ShapeDelta.zero;

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
    final direct = balance.tactics.formationShapeMatchups;
    for (final entry in direct) {
      if (entry.$1 == ours && entry.$2 == opponent) return entry.$3;
      if (entry.$1 == opponent && entry.$2 == ours) return -entry.$3;
    }
    return null;
  }

  ShapeDelta? _familyDelta(FormationFamily ours, FormationFamily opponent) {
    final direct = balance.tactics.familyShapeMatchups;
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
      result +=
          balance.tactics.settingMatchupDeltas['deepVsFast'] ?? ShapeDelta.zero;
    }
    if (ours.defensiveLine == DefensiveLine.deep &&
        opponent.tempo == Tempo.slow) {
      result +=
          balance.tactics.settingMatchupDeltas['deepVsSlow'] ?? ShapeDelta.zero;
    }
    if (ours.defensiveLine == DefensiveLine.high &&
        opponent.tempo == Tempo.slow) {
      result +=
          balance.tactics.settingMatchupDeltas['highVsSlow'] ?? ShapeDelta.zero;
    }
    if (ours.defensiveLine == DefensiveLine.high &&
        opponent.tempo == Tempo.fast) {
      result +=
          balance.tactics.settingMatchupDeltas['highVsFast'] ?? ShapeDelta.zero;
    }

    if (ours.pressing == PressingIntensity.low &&
        opponent.tempo == Tempo.fast) {
      result +=
          balance.tactics.settingMatchupDeltas['lowPressVsFast'] ??
          ShapeDelta.zero;
    }
    if (ours.pressing == PressingIntensity.low &&
        opponent.pressing == PressingIntensity.gegenpressing) {
      result +=
          balance.tactics.settingMatchupDeltas['lowPressVsGegenpress'] ??
          ShapeDelta.zero;
    }
    if (ours.pressing == PressingIntensity.high &&
        opponent.tempo == Tempo.slow) {
      result +=
          balance.tactics.settingMatchupDeltas['highPressVsSlow'] ??
          ShapeDelta.zero;
    }
    if (ours.pressing == PressingIntensity.gegenpressing &&
        opponent.pressing == PressingIntensity.low) {
      result +=
          balance.tactics.settingMatchupDeltas['gegenpressVsLowPress'] ??
          ShapeDelta.zero;
    }
    if (ours.pressing == PressingIntensity.gegenpressing &&
        opponent.tempo == Tempo.fast) {
      result +=
          balance.tactics.settingMatchupDeltas['gegenpressVsFast'] ??
          ShapeDelta.zero;
    }

    if (ours.attackWidth == AttackWidth.wide &&
        opponent.attackWidth == AttackWidth.narrow) {
      result +=
          balance.tactics.settingMatchupDeltas['wideVsNarrow'] ??
          ShapeDelta.zero;
    }
    if (ours.attackWidth == AttackWidth.narrow &&
        opponent.attackWidth == AttackWidth.wide) {
      result +=
          balance.tactics.settingMatchupDeltas['narrowVsWide'] ??
          ShapeDelta.zero;
    }
    if (ours.attackWidth == AttackWidth.wide &&
        balance.tactics.familyFor(opponent.formation) ==
            FormationFamily.threeBackWide) {
      result +=
          balance.tactics.settingMatchupDeltas['wideVsThreeBack'] ??
          ShapeDelta.zero;
    }
    if (ours.attackWidth == AttackWidth.wide &&
        balance.tactics.familyFor(opponent.formation) ==
            FormationFamily.fiveBackBlock) {
      result +=
          balance.tactics.settingMatchupDeltas['wideVsFiveBack'] ??
          ShapeDelta.zero;
    }
    if (ours.attackWidth == AttackWidth.narrow &&
        opponent.formation == Formation.f442) {
      result +=
          balance.tactics.settingMatchupDeltas['narrowVs442'] ??
          ShapeDelta.zero;
    }
    if (ours.attackWidth == AttackWidth.narrow &&
        opponent.formation == Formation.f433) {
      result +=
          balance.tactics.settingMatchupDeltas['narrowVs433'] ??
          ShapeDelta.zero;
    }
    if (ours.attackWidth == AttackWidth.narrow &&
        balance.tactics.familyFor(opponent.formation) ==
            FormationFamily.fourBackCentralControl) {
      result +=
          balance.tactics.settingMatchupDeltas['narrowVsCentralControl'] ??
          ShapeDelta.zero;
    }

    if (ours.defensiveLine == DefensiveLine.deep &&
        (opponent.formation == Formation.f424 ||
            opponent.formation == Formation.f343)) {
      result +=
          balance.tactics.settingMatchupDeltas['deepVsAttackingFormation'] ??
          ShapeDelta.zero;
    }
    if (ours.defensiveLine == DefensiveLine.high &&
        balance.tactics.familyFor(opponent.formation) ==
            FormationFamily.fiveBackBlock) {
      result +=
          balance.tactics.settingMatchupDeltas['highVsFiveBack'] ??
          ShapeDelta.zero;
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
        result +=
            balance
                .tactics
                .roleSynergyDeltas['noNonsenseVsAttackingFormation'] ??
            ShapeDelta.zero;
      }
      if (_isDefensiveFullBack(role) &&
          opponentTactics.attackWidth == AttackWidth.wide &&
          _hasAttackingWideRole(opponentLineup)) {
        result +=
            balance.tactics.roleSynergyDeltas['defensiveFullBackVsWideRole'] ??
            ShapeDelta.zero;
      }
      if (_isAnchor(role) && _hasShadowOrCompleteForward(opponentLineup)) {
        result +=
            balance.tactics.roleSynergyDeltas['anchorVsShadowOrComplete'] ??
            ShapeDelta.zero;
      }
      if (_isBallPlayingDefender(role) &&
          opponentTactics.pressing == PressingIntensity.low &&
          opponentTactics.defensiveLine == DefensiveLine.deep) {
        result +=
            balance.tactics.roleSynergyDeltas['ballPlayingVsLowDeep'] ??
            ShapeDelta.zero;
      }
      if (_isRegistaOrDeepPlaymaker(role) &&
          opponentTactics.pressing == PressingIntensity.high &&
          opponentTactics.defensiveLine == DefensiveLine.high) {
        result +=
            balance
                .tactics
                .roleSynergyDeltas['registaOrDeepPlaymakerVsHighHigh'] ??
            ShapeDelta.zero;
      }
      if (_isPlaymaker(role) &&
          opponentTactics.attackWidth == AttackWidth.narrow &&
          (opponentTactics.formation == Formation.f451 ||
              opponentTactics.formation == Formation.f4141)) {
        result +=
            balance.tactics.roleSynergyDeltas['playmakerVsNarrowMidfield'] ??
            ShapeDelta.zero;
      }
      if (_isInvertedWingBack(role) &&
          (opponentTactics.formation == Formation.f41212Narrow ||
              opponentTactics.formation == Formation.f4312)) {
        result +=
            balance
                .tactics
                .roleSynergyDeltas['invertedWingBackVsNarrowFormation'] ??
            ShapeDelta.zero;
      }
      if (_isShadowStriker(role) &&
          opponentTactics.defensiveLine == DefensiveLine.high &&
          opponentTactics.attackWidth == AttackWidth.wide) {
        result +=
            balance.tactics.roleSynergyDeltas['shadowStrikerVsHighWide'] ??
            ShapeDelta.zero;
      }
      if (_isInvertedWinger(role) && _hasAttackingWideRole(opponentLineup)) {
        result +=
            balance.tactics.roleSynergyDeltas['invertedWingerVsWideRole'] ??
            ShapeDelta.zero;
      }
      if (_isFalseNine(role) &&
          opponentTactics.defensiveLine == DefensiveLine.deep &&
          _hasNoNonsenseDefender(opponentLineup)) {
        result +=
            balance.tactics.roleSynergyDeltas['falseNineVsDeepNoNonsense'] ??
            ShapeDelta.zero;
      }
      if (_isPressingForward(role) && _hasBallPlayingDefender(opponentLineup)) {
        result +=
            balance.tactics.roleSynergyDeltas['pressingForwardVsBallPlaying'] ??
            ShapeDelta.zero;
      }
      if (_isCompleteForward(role) &&
          balance.tactics.familyFor(opponentTactics.formation) ==
              FormationFamily.fiveBackBlock) {
        result +=
            balance.tactics.roleSynergyDeltas['completeForwardVsFiveBack'] ??
            ShapeDelta.zero;
      }
      if (_isAttackingFullBack(role) &&
          opponentTactics.tempo == Tempo.fast &&
          opponentTactics.attackWidth == AttackWidth.wide) {
        result +=
            balance.tactics.roleSynergyDeltas['attackingFullBackVsFastWide'] ??
            ShapeDelta.zero;
      }
      if (_isSweeperKeeper(role) && opponentTactics.tempo == Tempo.fast) {
        result +=
            balance.tactics.roleSynergyDeltas['sweeperKeeperVsFast'] ??
            ShapeDelta.zero;
      }
      if (_isBallPlayingDefender(role) &&
          opponentTactics.pressing == PressingIntensity.gegenpressing) {
        result +=
            balance.tactics.roleSynergyDeltas['ballPlayingVsGegenpress'] ??
            ShapeDelta.zero;
      }
      if (_isRegista(role) &&
          opponentTactics.pressing == PressingIntensity.gegenpressing &&
          opponentTactics.defensiveLine == DefensiveLine.high) {
        result +=
            balance.tactics.roleSynergyDeltas['registaVsGegenpressHigh'] ??
            ShapeDelta.zero;
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
