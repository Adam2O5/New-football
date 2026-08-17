import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/simulation/duel_resolver.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/goalkeeper_resolver.dart';
import 'package:new_football/core/simulation/sequence_resolver.dart';
import 'package:new_football/core/simulation/shot_models.dart';
import 'package:new_football/core/simulation/shot_resolver.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

/// Explicit trigger consumed by the SFG resolver. Task 20 will generate these
/// from fouls and corners; Task 18 keeps the trigger injectable and testable.
class SetPieceResolution {
  const SetPieceResolution({
    required this.type,
    required this.shooterId,
    required this.sfgMultiplier,
    required this.aerialEdge,
    required this.shot,
    required this.penaltyDuel,
  });

  final SetPieceType type;
  final String? shooterId;
  final double sfgMultiplier;
  final double aerialEdge;
  final ShotResolution shot;
  final DuelResult? penaltyDuel;

  bool get isGoal => shot.isGoal;
}

class SetPieceResolver {
  const SetPieceResolver({
    this.balance = BalanceConfig.defaults,
    GoalkeeperResolver? goalkeeperResolver,
    DuelResolver? duelResolver,
    ShotResolver? shotResolver,
  }) : _goalkeeperResolver = goalkeeperResolver,
       _duelResolver = duelResolver,
       _shotResolver = shotResolver;

  final BalanceConfig balance;
  final GoalkeeperResolver? _goalkeeperResolver;
  final DuelResolver? _duelResolver;
  final ShotResolver? _shotResolver;

  SetPieceResolution resolve({
    required SetPieceType type,
    required List<Player> attackingLineup,
    required List<Player> defendingLineup,
    required Map<String, EffectivePlayerAttributes> attackingAttributes,
    required Map<String, EffectivePlayerAttributes> defendingAttributes,
    required TacticsSetup attackingTactics,
    required MatchContext context,
    required MatchRandom random,
  }) {
    final shooter = _selectShooter(type, attackingLineup, attackingAttributes);
    final sfgMultiplier = balance.matchday.sfgMultiplier(
      type.name,
      attackingTactics,
    );
    final aerialEdge = _aerialEdge(attackingLineup, defendingLineup);
    final aerialMultiplier = switch (type) {
      SetPieceType.corner => 1 + aerialEdge * balance.matchday.aerialCornerCoef,
      SetPieceType.directFreeKick =>
        1 + aerialEdge * balance.matchday.aerialFkCoef,
      SetPieceType.penalty => 1.0,
    };
    final baseXg = balance.matchday.setPieceBaseXg(type.name);
    DuelResult? penaltyDuel;
    var qualityMultiplier = aerialMultiplier;
    if (type == SetPieceType.penalty && shooter != null) {
      final shooterRating =
          (_shooting(shooter, attackingAttributes[shooter.id]) * 0.60) +
          balance.matchday.clutchBonus(
            determination: shooter.hidden.determination,
            stake: context.stake,
            ambitious: shooter.personality == PlayerPersonality.ambitious,
          );
      final goalkeeper =
          (_goalkeeperResolver ?? GoalkeeperResolver(balance: balance)).resolve(
            shotKind: SequenceShotKind.penalty,
            defendingLineup: defendingLineup,
            effectiveAttributes: defendingAttributes,
            weather: context.weather,
          );
      penaltyDuel = (_duelResolver ?? DuelResolver(balance: balance)).contest(
        attackerRating: shooterRating,
        defenderRating: _goalkeeperRating(goalkeeper),
        random: random,
      );
      qualityMultiplier *=
          1 +
          (penaltyDuel.attackerProbability - 0.5) *
              balance.matchday.penaltyDuelInfluence;
    }

    final shot = shooter == null
        ? const ShotResolution.noShot()
        : (_shotResolver ?? ShotResolver(balance: balance)).resolve(
            sequenceType: SequenceType.setPiece,
            shotKind: switch (type) {
              SetPieceType.corner => SequenceShotKind.header,
              SetPieceType.directFreeKick => SequenceShotKind.distance,
              SetPieceType.penalty => SequenceShotKind.penalty,
            },
            shooter: shooter,
            defendingLineup: defendingLineup,
            context: context,
            random: random,
            shooterAttributes: attackingAttributes,
            defendingAttributes: defendingAttributes,
            chanceQualityMultiplier: qualityMultiplier,
            useSequenceGate: false,
            applyClutch: false,
            baseXgOverride: baseXg * sfgMultiplier,
          );

    return SetPieceResolution(
      type: type,
      shooterId: shooter?.id,
      sfgMultiplier: sfgMultiplier,
      aerialEdge: aerialEdge,
      shot: shot,
      penaltyDuel: penaltyDuel,
    );
  }

  Player? _selectShooter(
    SetPieceType type,
    List<Player> lineup,
    Map<String, EffectivePlayerAttributes> attributes,
  ) {
    final outfield = lineup.where((player) => player.position != Position.gk);
    if (outfield.isEmpty) return null;
    final usePassing = type == SetPieceType.corner;
    return outfield.reduce((best, candidate) {
      final bestValue = _value(best, attributes[best.id], usePassing);
      final candidateValue = _value(
        candidate,
        attributes[candidate.id],
        usePassing,
      );
      return candidateValue > bestValue ? candidate : best;
    });
  }

  double _value(
    Player player,
    EffectivePlayerAttributes? attributes,
    bool passing,
  ) => passing ? _passing(player, attributes) : _shooting(player, attributes);

  double _passing(Player player, EffectivePlayerAttributes? effective) =>
      effective?.passing ??
      player.attributes.map(
        outfield: (attributes) => attributes.stats.passing.toDouble(),
        goalkeeper: (attributes) => attributes.stats.kicking.toDouble(),
      );

  double _shooting(Player player, EffectivePlayerAttributes? effective) =>
      effective?.shooting ??
      player.attributes.map(
        outfield: (attributes) => attributes.stats.shooting.toDouble(),
        goalkeeper: (attributes) => attributes.stats.overall,
      );

  double _goalkeeperRating(GoalkeeperResolution goalkeeper) =>
      goalkeeper.gkRating;

  double _aerialEdge(List<Player> attack, List<Player> defense) {
    final attackValues =
        attack
            .where((player) => player.position != Position.gk)
            .map((player) => balance.matchday.aerialFactor(player.heightCm))
            .toList()
          ..sort((a, b) => b.compareTo(a));
    final goalkeeperValues =
        defense
            .where((player) => player.position == Position.gk)
            .map((player) => balance.matchday.aerialFactor(player.heightCm))
            .toList()
          ..sort((a, b) => b.compareTo(a));
    final defenderValues =
        defense
            .where((player) => player.position != Position.gk)
            .map((player) => balance.matchday.aerialFactor(player.heightCm))
            .toList()
          ..sort((a, b) => b.compareTo(a));
    final defenseSample = <double>[
      ...goalkeeperValues.take(1),
      ...defenderValues.take(3),
    ];
    final attackMean = _mean(attackValues.take(4));
    final defenseMean = _mean(defenseSample);
    return (attackMean - defenseMean)
        .clamp(
          -balance.matchday.aerialEdgeClamp.toDouble(),
          balance.matchday.aerialEdgeClamp.toDouble(),
        )
        .toDouble();
  }

  double _mean(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return balance.matchday.aerialFactor(180);
    return list.reduce((a, b) => a + b) / list.length;
  }
}
