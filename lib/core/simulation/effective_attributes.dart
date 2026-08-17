import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/team_management_service.dart';

/// The six outfield attributes consumed by the Task 16 unit ratings.
enum EffectiveAttribute {
  pace,
  shooting,
  passing,
  dribbling,
  defending,
  physicality,
}

/// Multipliers used for one player's effective match profile.
class EffectiveAttributeMultipliers {
  const EffectiveAttributeMultipliers({
    required this.positionMult,
    required this.roleFitMult,
    required this.chemistryMult,
    required this.cohesionMult,
    required this.atmosphereMult,
    required this.formMult,
    required this.staminaMult,
    required this.contextMult,
    required this.leaderMult,
  });

  final double positionMult;
  final double roleFitMult;
  final double chemistryMult;
  final double cohesionMult;
  final double atmosphereMult;
  final double formMult;
  final double staminaMult;
  final Map<EffectiveAttribute, double> contextMult;
  final double leaderMult;

  double contextFor(EffectiveAttribute attribute) => contextMult[attribute]!;

  // Short aliases keep the breakdown convenient for diagnostics.
  double get position => positionMult;
  double get roleFit => roleFitMult;
  double get chemistry => chemistryMult;
  double get cohesion => cohesionMult;
  double get atmosphere => atmosphereMult;
  double get form => formMult;
  double get stamina => staminaMult;
  double get leader => leaderMult;
}

/// Effective attributes for one on-pitch player at one match minute.
///
/// This is deliberately runtime-only. It is derived from the immutable player,
/// the live stamina map and the frozen MatchContext, so it does not belong in
/// MatchState/MatchResult serialization yet.
class EffectivePlayerAttributes {
  const EffectivePlayerAttributes({
    required this.player,
    required this.values,
    required this.multipliers,
  });

  final Player player;
  final Map<EffectiveAttribute, double> values;
  final EffectiveAttributeMultipliers multipliers;

  double operator [](EffectiveAttribute attribute) => values[attribute]!;

  double get pace => this[EffectiveAttribute.pace];
  double get shooting => this[EffectiveAttribute.shooting];
  double get passing => this[EffectiveAttribute.passing];
  double get dribbling => this[EffectiveAttribute.dribbling];
  double get defending => this[EffectiveAttribute.defending];
  double get physicality => this[EffectiveAttribute.physicality];

  double valueFor(EffectiveAttribute attribute) => this[attribute];

  Map<EffectiveAttribute, double> get attributes => values;
}

/// Calculates the nine multipliers in the documented effAttr pipeline.
class EffectiveAttributeCalculator {
  const EffectiveAttributeCalculator({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  EffectivePlayerAttributes calculate({
    required Player player,
    required MatchContext context,
    required double chemistry,
    required int atmosphere,
    required double cohesionMultiplier,
    required bool isHome,
    StaffMember? headCoach,
    Iterable<Player> lineup = const [],
    double? currentStamina,
    Position? assignedPosition,
  }) {
    final lineupList = lineup.toList(growable: false);
    final positionMult = positionMultiplier(
      player,
      assignedPosition: assignedPosition,
    );
    final roleFitMult = roleFitMultiplier(player);
    final chemistryMult = TeamManagementService.chemistryMultiplier(chemistry);
    final atmosphereMult = TeamManagementService.atmosphereMultiplier(
      atmosphere,
    );
    final formMult = balance.player.formMult(player.state.form);
    final staminaMult = balance.player.performanceMult(
      (currentStamina ?? player.state.stamina.toDouble()).round(),
    );
    final contextMult = {
      for (final attribute in EffectiveAttribute.values)
        attribute: contextMultiplier(
          attribute: attribute,
          context: context,
          isHome: isHome,
        ),
    };
    final leaderMult =
        lineupList.any(
          (candidate) => candidate.personality == PlayerPersonality.leader,
        )
        ? balance.matchday.leaderBonus
        : 1.0;
    final multipliers = EffectiveAttributeMultipliers(
      positionMult: positionMult,
      roleFitMult: roleFitMult,
      chemistryMult: chemistryMult,
      cohesionMult: cohesionMultiplier,
      atmosphereMult: atmosphereMult,
      formMult: formMult,
      staminaMult: staminaMult,
      contextMult: Map.unmodifiable(contextMult),
      leaderMult: leaderMult,
    );

    final base = _baseAttributes(player);
    final values = <EffectiveAttribute, double>{};
    for (final attribute in EffectiveAttribute.values) {
      final effective =
          base[attribute]! *
          positionMult *
          roleFitMult *
          chemistryMult *
          cohesionMultiplier *
          atmosphereMult *
          formMult *
          staminaMult *
          contextMult[attribute]! *
          leaderMult;
      values[attribute] = effective.clamp(1.0, 120.0).toDouble();
    }

    return EffectivePlayerAttributes(
      player: player,
      values: Map.unmodifiable(values),
      multipliers: multipliers,
    );
  }

  Map<String, EffectivePlayerAttributes> calculateLineup({
    required List<Player> lineup,
    required MatchContext context,
    required double chemistry,
    required int atmosphere,
    required double cohesionMultiplier,
    required bool isHome,
    StaffMember? headCoach,
    Map<String, double> staminaRemaining = const {},
    Map<String, Position> assignedPositions = const {},
  }) {
    return {
      for (final player in lineup)
        player.id: calculate(
          player: player,
          context: context,
          chemistry: chemistry,
          atmosphere: atmosphere,
          cohesionMultiplier: cohesionMultiplier,
          isHome: isHome,
          headCoach: headCoach,
          lineup: lineup,
          currentStamina: staminaRemaining[player.id],
          assignedPosition: assignedPositions[player.id],
        ),
    };
  }

  EffectivePlayerAttributes calculateForTeam({
    required Player player,
    required Team team,
    required MatchContext context,
    required double cohesionMultiplier,
    required bool isHome,
    Iterable<Player> lineup = const [],
    double? currentStamina,
    Position? assignedPosition,
  }) => calculate(
    player: player,
    context: context,
    chemistry: team.chemistry,
    atmosphere: team.atmosphere,
    cohesionMultiplier: cohesionMultiplier,
    isHome: isHome,
    headCoach: team.staff.headCoach,
    lineup: lineup,
    currentStamina: currentStamina,
    assignedPosition: assignedPosition,
  );

  /// Natural position is used when no explicit formation-slot assignment exists.
  static double positionMultiplier(
    Player player, {
    Position? assignedPosition,
  }) {
    if (assignedPosition != null) {
      return player.position == assignedPosition ? 1.0 : 0.90;
    }
    return _positionFitsRole(player.position, player.state.role) ? 1.0 : 0.90;
  }

  /// Role fit is independent from natural-position fit and chemistry cohesion.
  double roleFitMultiplier(Player player) =>
      player.state.role == player.optimalRole
      ? balance.matchday.roleFitBonus
      : 1.0;

  /// Public so Task 18 can use the same personality contract for cards.
  double cardProneMultiplier(Player player) =>
      player.personality == PlayerPersonality.temperamental
      ? balance.matchday.cardProneTemperamental
      : 1.0;

  /// Public so Task 10/18 can use the same professional injury contract.
  double injuryMultiplier(Player player) =>
      player.personality == PlayerPersonality.professional
      ? balance.matchday.injuryProfessional
      : 1.0;

  /// Ambitious players receive the documented clutch addition later in Task 18.
  double clutchBonus(Player player) =>
      player.personality == PlayerPersonality.ambitious ? 0.03 : 0.0;

  /// Loyal players absorb only 80% of adverse team momentum.
  double momentumForPlayer(Player player, double teamMomentum) {
    if (teamMomentum < 0 && player.personality == PlayerPersonality.loyal) {
      return teamMomentum * 0.80;
    }
    return teamMomentum;
  }

  double contextMultiplier({
    required EffectiveAttribute attribute,
    required MatchContext context,
    required bool isHome,
  }) {
    final weather = switch (attribute) {
      EffectiveAttribute.passing => balance.matchday.weatherPassingMultiplier(
        context.weather,
      ),
      EffectiveAttribute.pace => balance.matchday.weatherPaceMultiplier(
        context.weather,
      ),
      _ => 1.0,
    };
    final crowd = isHome
        ? balance.matchday.crowdHomeMultiplier(context.crowdIntensity)
        : balance.matchday.crowdAwayMultiplier(context.crowdIntensity);
    final matchLoad =
        (isHome ? context.homeMatchInWeek : context.awayMatchInWeek) >= 3
        ? 0.96
        : (isHome ? context.homeMatchInWeek : context.awayMatchInWeek) == 2
        ? 0.98
        : 1.0;
    return weather * crowd * matchLoad;
  }

  Map<EffectiveAttribute, double> _baseAttributes(
    Player player,
  ) => player.attributes.map(
    outfield: (attributes) => {
      EffectiveAttribute.pace: attributes.stats.pace.toDouble(),
      EffectiveAttribute.shooting: attributes.stats.shooting.toDouble(),
      EffectiveAttribute.passing: attributes.stats.passing.toDouble(),
      EffectiveAttribute.dribbling: attributes.stats.dribbling.toDouble(),
      EffectiveAttribute.defending: attributes.stats.defending.toDouble(),
      EffectiveAttribute.physicality: attributes.stats.physicality.toDouble(),
    },
    // GK is not included in D/M/A unit membership yet. Keeping a stable
    // fallback here makes the diagnostic pipeline total and avoids making
    // Task 16 depend on the Task 18 goalkeeper model.
    goalkeeper: (attributes) {
      final overall = attributes.stats.overall;
      return {
        for (final attribute in EffectiveAttribute.values) attribute: overall,
      };
    },
  );

  static bool _positionFitsRole(Position position, AssignedRole role) =>
      role.map(
        gk: (_) => position == Position.gk,
        cb: (_) => position == Position.cb,
        fullBack: (_) => position == Position.lb || position == Position.rb,
        wingBack: (_) => position == Position.lwb || position == Position.rwb,
        cdm: (_) => position == Position.cdm,
        cm: (_) => position == Position.cm,
        cam: (_) => position == Position.cam,
        winger: (_) => position == Position.lw || position == Position.rw,
        striker: (_) => position == Position.st,
      );
}
