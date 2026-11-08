import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/simulation/duel_resolver.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/sequence_resolver.dart';
import 'package:new_football/core/simulation/shot_models.dart';

/// One stage in a Task 18 multi-duel chain.
class SequenceDuelTrace {
  const SequenceDuelTrace({
    required this.stage,
    required this.attackerId,
    required this.defenderId,
    required this.attackerWeights,
    required this.defenderWeights,
    required this.attackerAerialWeight,
    required this.defenderAerialWeight,
    required this.duel,
  });

  final int stage;
  final String attackerId;
  final String defenderId;
  final DuelAttributeWeights attackerWeights;
  final DuelAttributeWeights defenderWeights;
  final double attackerAerialWeight;
  final double defenderAerialWeight;
  final DuelResult duel;

  bool get attackerWon => duel.attackerWon == true;
}

/// Runtime-only resolution of a sequence before the shot funnel.
class SequenceResolution {
  const SequenceResolution({
    required this.type,
    required this.duels,
    required this.wonDuels,
    required this.chanceQualityMultiplier,
    required this.shooter,
    required this.shotKind,
    required this.canShoot,
    required this.longBallPassProbability,
    required this.longBallPassed,
  });

  final SequenceType type;
  final List<SequenceDuelTrace> duels;
  final int wonDuels;
  final double chanceQualityMultiplier;
  final Player? shooter;
  final SequenceShotKind shotKind;
  final bool canShoot;
  final double longBallPassProbability;
  final bool longBallPassed;

  DuelResult? get primaryDuel => duels.isEmpty ? null : duels.first.duel;
}

/// Resolves the documented 2-stage chains while keeping all random draws on
/// the match-owned [MatchRandom].
class SequenceChainResolver {
  const SequenceChainResolver({
    this.balance = BalanceConfig.defaults,
    DuelResolver? duelResolver,
  }) : _duelResolver = duelResolver;

  final BalanceConfig balance;
  final DuelResolver? _duelResolver;

  SequenceResolution resolve({
    required SequenceSelection selection,
    required SequenceContext context,
    required MatchRandom random,
  }) {
    if (selection.type == SequenceType.setPiece) {
      return SequenceResolution(
        type: selection.type,
        duels: const [],
        wonDuels: 0,
        chanceQualityMultiplier: 1.0,
        shooter: selection.attacker,
        shotKind: SequenceShotKind.box,
        canShoot: false,
        longBallPassProbability: 1.0,
        longBallPassed: true,
      );
    }

    final type = selection.type;
    final stages = _stages(type, context);
    final traces = <SequenceDuelTrace>[];
    var longBallPassProbability = 1.0;
    var longBallPassed = true;

    if (type == SequenceType.longBall) {
      final passer = _firstPlayer(
        selection.attacker,
        allowed: const {Position.cb, Position.cdm, Position.gk},
        context: context,
        attacking: true,
        random: random,
        type: type,
      );
      final passing = _value(
        passer,
        context.attackingEffectiveAttributes,
        EffectiveAttribute.passing,
      );
      longBallPassProbability =
          (balance.matchday.longBallPassBase +
                  (passing - balance.matchday.longBallPassThreshold) / 100.0)
              .clamp(
                balance.matchday.chainLongBallProbabilityMin,
                balance.matchday.chainLongBallProbabilityMax,
              )
              .toDouble();
      longBallPassed = random.nextDouble() < longBallPassProbability;
      if (!longBallPassed) {
        return SequenceResolution(
          type: type,
          duels: const [],
          wonDuels: 0,
          chanceQualityMultiplier: balance.matchday.chainLowQuality,
          shooter: passer,
          shotKind: SequenceShotKind.header,
          canShoot: false,
          longBallPassProbability: longBallPassProbability,
          longBallPassed: false,
        );
      }
    }

    Player? lastAttacker;
    Player? lastDefender;
    final duelResolver = _duelResolver ?? DuelResolver(balance: balance);
    for (var index = 0; index < stages.length; index++) {
      final stage = stages[index];
      final attacker = index == 0 && type != SequenceType.longBall
          ? _firstPlayer(
              selection.attacker,
              allowed: stage.attackerPositions,
              context: context,
              attacking: true,
              random: random,
              type: type,
            )
          : _choosePlayer(
              context: context,
              attacking: true,
              allowed: stage.attackerPositions,
              type: type,
              random: random,
              previous: lastAttacker,
            );
      final defender = index == 0 && type != SequenceType.longBall
          ? _firstPlayer(
              selection.defender,
              allowed: stage.defenderPositions,
              context: context,
              attacking: false,
              random: random,
              type: type,
            )
          : _choosePlayer(
              context: context,
              attacking: false,
              allowed: stage.defenderPositions,
              type: type,
              random: random,
              previous: lastDefender,
            );
      lastAttacker = attacker;
      lastDefender = defender;
      final attackerAttributes =
          context.attackingEffectiveAttributes[attacker.id];
      final defenderAttributes =
          context.defendingEffectiveAttributes[defender.id];
      final attackerRating = _rating(
        attacker,
        attackerAttributes,
        stage.attackerWeights,
        stage.attackerAerialWeight,
      );
      final defenderRating = _rating(
        defender,
        defenderAttributes,
        stage.defenderWeights,
        stage.defenderAerialWeight,
      );
      final duel = duelResolver.contest(
        attackerRating: attackerRating,
        defenderRating: defenderRating,
        random: random,
      );
      traces.add(
        SequenceDuelTrace(
          stage: index + 1,
          attackerId: attacker.id,
          defenderId: defender.id,
          attackerWeights: stage.attackerWeights,
          defenderWeights: stage.defenderWeights,
          attackerAerialWeight: stage.attackerAerialWeight,
          defenderAerialWeight: stage.defenderAerialWeight,
          duel: duel,
        ),
      );
    }

    final wonDuels = traces.where((trace) => trace.attackerWon).length;
    final canShoot = wonDuels > 0;
    var quality = switch (wonDuels) {
      0 || 1 => balance.matchday.chainLowQuality,
      2 => balance.matchday.chainNormalQuality,
      _ => balance.matchday.chainHighQuality,
    };
    if (type == SequenceType.counterAttack) {
      quality *= balance.matchday.counterAttackQualityMultiplier;
      if (context.defendingTactics.defensiveLine == DefensiveLine.high) {
        quality *= balance.matchday.counterAttackHighLineMultiplier;
      } else if (context.defendingTactics.defensiveLine == DefensiveLine.deep) {
        quality *= balance.matchday.counterAttackDeepLineMultiplier;
      }
    }

    return SequenceResolution(
      type: type,
      duels: List.unmodifiable(traces),
      wonDuels: wonDuels,
      chanceQualityMultiplier: quality,
      shooter: lastAttacker ?? selection.attacker,
      shotKind: _shotKind(type),
      canShoot: canShoot,
      longBallPassProbability: longBallPassProbability,
      longBallPassed: longBallPassed,
    );
  }

  List<SequenceStageProfile> _stages(
    SequenceType type,
    SequenceContext context,
  ) {
    final stages = balance.matchday.sequenceStages[type]!;
    if (type != SequenceType.throughBall ||
        context.defendingTactics.defensiveLine != DefensiveLine.high) {
      return stages;
    }
    final stage = stages[1];
    return [
      stages[0],
      SequenceStageProfile(
        attackerPositions: stage.attackerPositions,
        defenderPositions: stage.defenderPositions,
        attackerWeights: stage.attackerWeights,
        defenderWeights: balance.matchday.throughBallHighLineDefenderWeights,
        attackerAerialWeight: stage.attackerAerialWeight,
        defenderAerialWeight: stage.defenderAerialWeight,
      ),
    ];
  }

  SequenceShotKind _shotKind(SequenceType type) => switch (type) {
    SequenceType.crossFromWide ||
    SequenceType.longBall => SequenceShotKind.header,
    SequenceType.throughBall ||
    SequenceType.counterAttack => SequenceShotKind.oneOnOne,
    SequenceType.centralBuildUp ||
    SequenceType.wingPlay => SequenceShotKind.box,
    SequenceType.individualDribble => SequenceShotKind.box,
    SequenceType.setPiece => SequenceShotKind.box,
  };

  Player _firstPlayer(
    Player selected, {
    required Set<Position> allowed,
    required SequenceContext context,
    required bool attacking,
    required MatchRandom random,
    required SequenceType type,
  }) {
    final assigned = attacking
        ? context.attackingAssignedPositions
        : context.defendingAssignedPositions;
    final selectedPosition = assigned[selected.id] ?? selected.position;
    if (allowed.contains(selectedPosition)) return selected;
    return _choosePlayer(
      context: context,
      attacking: attacking,
      allowed: allowed,
      type: type,
      random: random,
    );
  }

  Player _choosePlayer({
    required SequenceContext context,
    required bool attacking,
    required Set<Position> allowed,
    required SequenceType type,
    required MatchRandom random,
    Player? previous,
  }) {
    final players = attacking
        ? context.attackingLineup
        : context.defendingLineup;
    final assigned = attacking
        ? context.attackingAssignedPositions
        : context.defendingAssignedPositions;
    var candidates = players
        .where((player) {
          final position = assigned[player.id] ?? player.position;
          return allowed.contains(position) &&
              (player.position != Position.gk || allowed.contains(Position.gk));
        })
        .toList(growable: false);
    if (candidates.isEmpty) {
      candidates = players
          .where((player) => player.position != Position.gk)
          .toList(growable: false);
    }
    if (candidates.isEmpty) {
      candidates = players;
    }
    if (candidates.isEmpty) {
      throw StateError('A sequence stage requires a player.');
    }
    return random.pickWeighted({
      for (final player in candidates)
        player: _positionWeight(
          assigned[player.id] ?? player.position,
          allowed,
          previous == player
              ? balance.matchday.chainRepeatPlayerMultiplier
              : 1.0,
        ),
    });
  }

  double _positionWeight(
    Position position,
    Set<Position> allowed,
    double repeatPenalty,
  ) =>
      (allowed.contains(position)
          ? balance.matchday.chainAllowedPositionWeight
          : balance.matchday.chainOtherPositionWeight) *
      repeatPenalty;

  double _rating(
    Player player,
    EffectivePlayerAttributes? attributes,
    DuelAttributeWeights weights,
    double aerialWeight,
  ) {
    final total = attributes == null
        ? _rawWeighted(player, weights)
        : const DuelResolver().weightedRating(attributes, weights);
    return total +
        aerialWeight * balance.matchday.aerialFactor(player.heightCm);
  }

  double _rawWeighted(Player player, DuelAttributeWeights weights) =>
      player.attributes.map(
        goalkeeper: (attributes) =>
            attributes.stats.overall *
            weights.values.fold<double>(0, (sum, value) => sum + value),
        outfield: (attributes) => weights.entries.fold<double>(
          0.0,
          (sum, entry) =>
              sum +
              entry.value *
                  switch (entry.key) {
                    EffectiveAttribute.pace => attributes.stats.pace,
                    EffectiveAttribute.shooting => attributes.stats.shooting,
                    EffectiveAttribute.passing => attributes.stats.passing,
                    EffectiveAttribute.dribbling => attributes.stats.dribbling,
                    EffectiveAttribute.defending => attributes.stats.defending,
                    EffectiveAttribute.physicality =>
                      attributes.stats.physicality,
                  },
        ),
      );

  double _value(
    Player player,
    Map<String, EffectivePlayerAttributes> attributes,
    EffectiveAttribute attribute,
  ) =>
      attributes[player.id]?.valueFor(attribute) ??
      player.attributes.map(
        goalkeeper: (value) => attribute == EffectiveAttribute.passing
            ? value.stats.kicking.toDouble()
            : value.stats.overall,
        outfield: (value) => switch (attribute) {
          EffectiveAttribute.pace => value.stats.pace.toDouble(),
          EffectiveAttribute.shooting => value.stats.shooting.toDouble(),
          EffectiveAttribute.passing => value.stats.passing.toDouble(),
          EffectiveAttribute.dribbling => value.stats.dribbling.toDouble(),
          EffectiveAttribute.defending => value.stats.defending.toDouble(),
          EffectiveAttribute.physicality => value.stats.physicality.toDouble(),
        },
      );
}
