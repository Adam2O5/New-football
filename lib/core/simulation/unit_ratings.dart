import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/team_shape.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';

/// Runtime ratings of the three D/M/A units.
class UnitRatings {
  const UnitRatings({
    required this.defRating,
    required this.midRating,
    required this.atkRating,
    this.defensivePlayerIds = const [],
    this.midfieldPlayerIds = const [],
    this.attackingPlayerIds = const [],
    this.defensiveWeights = const {},
    this.midfieldWeights = const {},
    this.attackingWeights = const {},
  });

  final double defRating;
  final double midRating;
  final double atkRating;
  final List<String> defensivePlayerIds;
  final List<String> midfieldPlayerIds;
  final List<String> attackingPlayerIds;
  final Map<String, double> defensiveWeights;
  final Map<String, double> midfieldWeights;
  final Map<String, double> attackingWeights;

  double get average => (defRating + midRating + atkRating) / 3.0;
}

/// Converts effective player attributes into weighted D/M/A unit ratings.
class UnitRatingCalculator {
  const UnitRatingCalculator({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  UnitRatings calculate({
    required List<Player> lineup,
    required Map<String, EffectivePlayerAttributes> effectiveAttributes,
    required TeamShape shape,
  }) {
    final defensive = _unitMembers(
      lineup,
      positions: const {
        Position.cb,
        Position.lb,
        Position.rb,
        Position.lwb,
        Position.rwb,
        Position.cdm,
      },
      supportingPositions: const {Position.cdm},
    );
    final midfield = _unitMembers(
      lineup,
      positions: const {
        Position.cdm,
        Position.cm,
        Position.cam,
        Position.lw,
        Position.rw,
      },
      supportingPositions: const {Position.lw, Position.rw},
    );
    final attacking = _unitMembers(
      lineup,
      positions: const {Position.st, Position.lw, Position.rw, Position.cam},
      supportingPositions: const {Position.lw, Position.rw, Position.cam},
    );

    return UnitRatings(
      defRating: _rating(
        defensive,
        effectiveAttributes,
        shape.tacticalMult(ShapeAxis.def, balance),
        UnitKind.def,
      ),
      midRating: _rating(
        midfield,
        effectiveAttributes,
        shape.tacticalMult(ShapeAxis.mid, balance),
        UnitKind.mid,
      ),
      atkRating: _rating(
        attacking,
        effectiveAttributes,
        shape.tacticalMult(ShapeAxis.atk, balance),
        UnitKind.atk,
      ),
      defensivePlayerIds: [for (final member in defensive) member.player.id],
      midfieldPlayerIds: [for (final member in midfield) member.player.id],
      attackingPlayerIds: [for (final member in attacking) member.player.id],
      defensiveWeights: {
        for (final member in defensive) member.player.id: member.weight,
      },
      midfieldWeights: {
        for (final member in midfield) member.player.id: member.weight,
      },
      attackingWeights: {
        for (final member in attacking) member.player.id: member.weight,
      },
    );
  }

  double _rating(
    List<_UnitMember> members,
    Map<String, EffectivePlayerAttributes> effectiveAttributes,
    double tacticalMultiplier,
    UnitKind kind,
  ) {
    if (members.isEmpty) return 0;
    var weightedSum = 0.0;
    var totalPositionWeight = 0.0;
    for (final member in members) {
      final attributes = effectiveAttributes[member.player.id];
      if (attributes == null) continue;
      final attributeRating = switch (kind) {
        UnitKind.def =>
          attributes.defending * 0.45 +
              attributes.physicality * 0.25 +
              attributes.pace * 0.20 +
              attributes.passing * 0.10,
        UnitKind.mid =>
          attributes.passing * 0.35 +
              attributes.dribbling * 0.25 +
              attributes.defending * 0.20 +
              attributes.physicality * 0.20,
        UnitKind.atk =>
          attributes.shooting * 0.35 +
              attributes.pace * 0.25 +
              attributes.dribbling * 0.25 +
              attributes.passing * 0.15,
      };
      weightedSum += attributeRating * member.weight;
      totalPositionWeight += member.weight;
    }
    if (totalPositionWeight == 0) return 0;
    return weightedSum / totalPositionWeight * tacticalMultiplier;
  }

  List<_UnitMember> _unitMembers(
    List<Player> lineup, {
    required Set<Position> positions,
    required Set<Position> supportingPositions,
  }) => [
    for (final player in lineup)
      if (positions.contains(player.position))
        _UnitMember(
          player: player,
          weight: supportingPositions.contains(player.position) ? 0.5 : 1.0,
        ),
  ];
}

enum UnitKind { def, mid, atk }

class _UnitMember {
  const _UnitMember({required this.player, required this.weight});

  final Player player;
  final double weight;
}
