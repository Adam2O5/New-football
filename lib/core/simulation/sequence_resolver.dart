export 'package:new_football/core/models/enums.dart' show SequenceType;

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/simulation/duel_resolver.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/unit_ratings.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

class SequenceContext {
  const SequenceContext({
    required this.attackingTactics,
    required this.defendingTactics,
    required this.attackingLineup,
    required this.defendingLineup,
    required this.attackingEffectiveAttributes,
    required this.defendingEffectiveAttributes,
    required this.attackingRatings,
    required this.defendingRatings,
    required this.weather,
    this.attackingAssignedPositions = const {},
    this.defendingAssignedPositions = const {},
    this.counterAttackEligible = true,
    this.longBallWeightMultiplier = 1.0,
  });

  final TacticsSetup attackingTactics;
  final TacticsSetup defendingTactics;
  final List<Player> attackingLineup;
  final List<Player> defendingLineup;
  final Map<String, EffectivePlayerAttributes> attackingEffectiveAttributes;
  final Map<String, EffectivePlayerAttributes> defendingEffectiveAttributes;
  final UnitRatings attackingRatings;
  final UnitRatings defendingRatings;
  final Weather weather;
  final Map<String, Position> attackingAssignedPositions;
  final Map<String, Position> defendingAssignedPositions;
  final bool counterAttackEligible;
  final double longBallWeightMultiplier;
}

class SequenceSelection {
  const SequenceSelection({
    required this.type,
    required this.attacker,
    required this.defender,
    required this.attackerWeight,
    required this.defenderWeight,
    required this.attackerAttributeWeights,
    required this.defenderAttributeWeights,
  });

  final SequenceType type;
  final Player attacker;
  final Player defender;
  final double attackerWeight;
  final double defenderWeight;
  final DuelAttributeWeights attackerAttributeWeights;
  final DuelAttributeWeights defenderAttributeWeights;
}

/// Selects a sequence type and the representative players for its Task 17
/// core duel. Detailed multi-duel chains belong to Task 18.
class SequenceSelector {
  const SequenceSelector({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  Map<SequenceType, double> weightsFor(SequenceContext context) {
    final weights = <SequenceType, double>{
      for (final type in SequenceType.values)
        type:
            balance.matchday.sequenceTypeBaseWeights[type.name] ??
            MatchdayBalance.defaultSequenceTypeBaseWeights[type.name]!,
    };
    final normalBonus = balance.matchday.sequenceConditionBonus;
    final strongBonus = balance.matchday.sequenceStrongConditionBonus;
    final highMid =
        context.attackingRatings.midRating >=
        balance.matchday.sequenceHighUnitThreshold;
    final highAttack =
        context.attackingRatings.atkRating >=
        balance.matchday.sequenceHighUnitThreshold;
    final highPace =
        _averageAttribute(
          context.attackingLineup,
          context.attackingEffectiveAttributes,
          EffectiveAttribute.pace,
        ) >=
        balance.matchday.sequenceHighAttributeThreshold;
    final highPassing =
        _averageAttribute(
          context.attackingLineup,
          context.attackingEffectiveAttributes,
          EffectiveAttribute.passing,
        ) >=
        balance.matchday.sequenceHighAttributeThreshold;
    final highDribbling =
        _averageAttribute(
          context.attackingLineup,
          context.attackingEffectiveAttributes,
          EffectiveAttribute.dribbling,
        ) >=
        balance.matchday.sequenceHighAttributeThreshold;
    final tallForward =
        _forwardHeight(context.attackingLineup) >=
        balance.matchday.sequenceTallForwardHeight;

    if (context.attackingTactics.attackWidth == AttackWidth.narrow) {
      weights[SequenceType.centralBuildUp] =
          weights[SequenceType.centralBuildUp]! + strongBonus;
    }
    if (highMid) {
      weights[SequenceType.centralBuildUp] =
          weights[SequenceType.centralBuildUp]! + normalBonus;
    }

    if (context.attackingTactics.attackWidth == AttackWidth.wide) {
      weights[SequenceType.wingPlay] =
          weights[SequenceType.wingPlay]! + strongBonus;
      weights[SequenceType.crossFromWide] =
          weights[SequenceType.crossFromWide]! + normalBonus;
    }
    if (highPace) {
      weights[SequenceType.wingPlay] =
          weights[SequenceType.wingPlay]! + normalBonus;
      weights[SequenceType.counterAttack] =
          weights[SequenceType.counterAttack]! + normalBonus;
    }
    if (tallForward &&
        context.attackingTactics.attackWidth == AttackWidth.wide) {
      weights[SequenceType.crossFromWide] =
          weights[SequenceType.crossFromWide]! + strongBonus;
    }
    if (highPassing) {
      weights[SequenceType.throughBall] =
          weights[SequenceType.throughBall]! + strongBonus;
    }
    if (highDribbling) {
      weights[SequenceType.individualDribble] =
          weights[SequenceType.individualDribble]! + strongBonus;
    }
    if (context.attackingTactics.tempo == Tempo.fast) {
      weights[SequenceType.longBall] =
          weights[SequenceType.longBall]! + normalBonus;
      weights[SequenceType.counterAttack] =
          weights[SequenceType.counterAttack]! + normalBonus;
    }
    if (context.attackingTactics.defensiveLine == DefensiveLine.deep) {
      weights[SequenceType.longBall] =
          weights[SequenceType.longBall]! + normalBonus;
    }
    if (context.weather == Weather.wind ||
        context.weather == Weather.heavyRain) {
      weights[SequenceType.longBall] =
          weights[SequenceType.longBall]! + normalBonus;
    }
    final weatherLongBallMultiplier = context.weather == Weather.wind
        ? balance.matchday.windLongBallWeightMultiplier
        : 1.0;
    weights[SequenceType.longBall] =
        weights[SequenceType.longBall]! *
        weatherLongBallMultiplier *
        context.longBallWeightMultiplier;
    if (context.defendingTactics.defensiveLine == DefensiveLine.high &&
        (highPace || highAttack)) {
      weights[SequenceType.throughBall] =
          weights[SequenceType.throughBall]! + normalBonus;
      weights[SequenceType.counterAttack] =
          weights[SequenceType.counterAttack]! + normalBonus;
    }
    if (!context.counterAttackEligible) {
      weights[SequenceType.counterAttack] = 0.0;
    }

    return weights;
  }

  SequenceType selectType({
    required SequenceContext context,
    required MatchRandom random,
  }) => random.pickWeighted(weightsFor(context));

  SequenceSelection select({
    required SequenceContext context,
    required MatchRandom random,
  }) {
    final type = selectType(context: context, random: random);
    final attacker = selectAttacker(
      context: context,
      type: type,
      random: random,
    );
    final defender = selectDefender(
      context: context,
      type: type,
      attacker: attacker,
      random: random,
    );
    return SequenceSelection(
      type: type,
      attacker: attacker,
      defender: defender,
      attackerWeight: _attackerWeight(context, type, attacker),
      defenderWeight: _defenderWeight(context, type, defender, attacker),
      attackerAttributeWeights: _attackerProfile(type),
      defenderAttributeWeights: _defenderProfile(type),
    );
  }

  Player selectAttacker({
    required SequenceContext context,
    required SequenceType type,
    required MatchRandom random,
  }) {
    final candidates = context.attackingLineup
        .where((player) => player.position != Position.gk)
        .toList(growable: false);
    if (candidates.isEmpty) {
      throw StateError('A playable sequence needs an outfield attacker.');
    }
    return random.pickWeighted({
      for (final player in candidates)
        player: _attackerWeight(context, type, player),
    });
  }

  Player selectDefender({
    required SequenceContext context,
    required SequenceType type,
    required Player attacker,
    required MatchRandom random,
  }) {
    final candidates = context.defendingLineup
        .where((player) => player.position != Position.gk)
        .toList(growable: false);
    if (candidates.isEmpty) {
      throw StateError('A playable sequence needs an outfield defender.');
    }
    return random.pickWeighted({
      for (final player in candidates)
        player: _defenderWeight(context, type, player, attacker),
    });
  }

  DuelAttributeWeights _attackerProfile(SequenceType type) =>
      balance.matchday.sequenceAttackerProfiles[type]!;

  DuelAttributeWeights _defenderProfile(SequenceType type) =>
      balance.matchday.sequenceDefenderProfiles[type]!;

  double _attackerWeight(
    SequenceContext context,
    SequenceType type,
    Player player,
  ) {
    final position = _positionFor(player, context.attackingAssignedPositions);
    var weight = balance.matchday.sequenceAttackerBaseWeight;
    weight +=
        balance.matchday.sequenceAttackerPositionBonuses[type]?[position] ?? 0;
    if (type == SequenceType.setPiece) {
      final attributes = context.attackingEffectiveAttributes[player.id];
      if (attributes != null) {
        weight +=
            (attributes.passing + attributes.shooting) /
            balance.matchday.sequenceSetPieceAttributeDivisor;
      }
    }
    return weight;
  }

  double _defenderWeight(
    SequenceContext context,
    SequenceType type,
    Player defender,
    Player attacker,
  ) {
    final position = _positionFor(defender, context.defendingAssignedPositions);
    final attackerPosition = _positionFor(
      attacker,
      context.attackingAssignedPositions,
    );
    final leftAction =
        attackerPosition == Position.lw || attackerPosition == Position.lwb;
    final rightAction =
        attackerPosition == Position.rw || attackerPosition == Position.rwb;

    if ((type == SequenceType.wingPlay || type == SequenceType.crossFromWide) &&
        ((leftAction &&
                (position == Position.lb || position == Position.lwb)) ||
            (rightAction &&
                (position == Position.rb || position == Position.rwb)))) {
      return balance.matchday.sequenceMatchingFlankWeight;
    }
    final weight =
        balance.matchday.sequenceDefenderPositionWeights[type]?[position] ??
        balance.matchday.sequenceDefenderBaseWeight;
    return weight;
  }

  Position _positionFor(Player player, Map<String, Position> assigned) =>
      assigned[player.id] ?? player.position;

  double _averageAttribute(
    List<Player> players,
    Map<String, EffectivePlayerAttributes> attributes,
    EffectiveAttribute attribute,
  ) {
    final values = [
      for (final player in players)
        if (player.position != Position.gk && attributes[player.id] != null)
          attributes[player.id]!.valueFor(attribute),
    ];
    if (values.isEmpty) return balance.matchday.sequenceFallbackAttribute;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _forwardHeight(List<Player> players) {
    final forwards = players.where(
      (player) =>
          player.position == Position.st ||
          player.position == Position.lw ||
          player.position == Position.rw,
    );
    final list = forwards.map((player) => player.heightCm).toList();
    if (list.isEmpty) return balance.matchday.fallbackAerialHeight.toDouble();
    return list.reduce((a, b) => a + b) / list.length;
  }
}
