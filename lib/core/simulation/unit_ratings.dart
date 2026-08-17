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

/// Reusable cache for the position-based D/M/A membership of one lineup.
///
/// Effective attributes and tactical multipliers still refresh every minute;
/// only the stable lineup membership and weights are cached. The owner clears
/// this cache when a formation or lineup changes.
class UnitRatingMembershipCache {
  final Map<List<Player>, _UnitMemberships> _byLineup = {};

  _UnitMemberships? _get(List<Player> lineup) => _byLineup[lineup];

  void _put(List<Player> lineup, _UnitMemberships memberships) {
    _byLineup[lineup] = memberships;
  }

  void clear() => _byLineup.clear();
}

/// Converts effective player attributes into weighted D/M/A unit ratings.
class UnitRatingCalculator {
  const UnitRatingCalculator({
    this.balance = BalanceConfig.defaults,
    this.membershipCache,
  });

  final BalanceConfig balance;
  final UnitRatingMembershipCache? membershipCache;

  void clearMembershipCache() => membershipCache?.clear();

  UnitRatings calculate({
    required List<Player> lineup,
    required Map<String, EffectivePlayerAttributes> effectiveAttributes,
    required TeamShape shape,
    Map<String, Position> assignedPositions = const {},
    bool applyShortHanded = false,
  }) {
    final memberships = _memberships(
      lineup,
      assignedPositions: assignedPositions,
    );

    return UnitRatings(
      defRating: _rating(
        memberships.defensive,
        effectiveAttributes,
        shape.tacticalMult(ShapeAxis.def, balance),
        UnitKind.def,
        playersOnPitch: lineup.length,
        applyShortHanded: applyShortHanded,
      ),
      midRating: _rating(
        memberships.midfield,
        effectiveAttributes,
        shape.tacticalMult(ShapeAxis.mid, balance),
        UnitKind.mid,
        playersOnPitch: lineup.length,
        applyShortHanded: applyShortHanded,
      ),
      atkRating: _rating(
        memberships.attacking,
        effectiveAttributes,
        shape.tacticalMult(ShapeAxis.atk, balance),
        UnitKind.atk,
        playersOnPitch: lineup.length,
        applyShortHanded: applyShortHanded,
      ),
      defensivePlayerIds: memberships.defensivePlayerIds,
      midfieldPlayerIds: memberships.midfieldPlayerIds,
      attackingPlayerIds: memberships.attackingPlayerIds,
      defensiveWeights: memberships.defensiveWeights,
      midfieldWeights: memberships.midfieldWeights,
      attackingWeights: memberships.attackingWeights,
    );
  }

  _UnitMemberships _memberships(
    List<Player> lineup, {
    required Map<String, Position> assignedPositions,
  }) {
    final cached = membershipCache?._get(lineup);
    if (cached != null) return cached;

    final memberships = _UnitMemberships(
      defensive: _unitMembers(
        lineup,
        assignedPositions: assignedPositions,
        positions: const {
          Position.cb,
          Position.lb,
          Position.rb,
          Position.lwb,
          Position.rwb,
          Position.cdm,
        },
        supportingPositions: const {Position.cdm},
      ),
      midfield: _unitMembers(
        lineup,
        assignedPositions: assignedPositions,
        positions: const {
          Position.cdm,
          Position.cm,
          Position.cam,
          Position.lw,
          Position.rw,
        },
        supportingPositions: const {Position.lw, Position.rw},
      ),
      attacking: _unitMembers(
        lineup,
        assignedPositions: assignedPositions,
        positions: const {Position.st, Position.lw, Position.rw, Position.cam},
        supportingPositions: const {Position.lw, Position.rw, Position.cam},
      ),
    );
    membershipCache?._put(lineup, memberships);
    return memberships;
  }

  double _rating(
    List<_UnitMember> members,
    Map<String, EffectivePlayerAttributes> effectiveAttributes,
    double tacticalMultiplier,
    UnitKind kind, {
    required int playersOnPitch,
    required bool applyShortHanded,
  }) {
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
    return weightedSum /
        totalPositionWeight *
        tacticalMultiplier *
        (applyShortHanded ? _shortHandedMultiplier(kind, playersOnPitch) : 1.0);
  }

  double _shortHandedMultiplier(UnitKind kind, int playersOnPitch) {
    if (kind == UnitKind.atk) {
      return balance.matchday.shortHandedAttackMultiplier(playersOnPitch);
    }
    if (kind == UnitKind.def) {
      return balance.matchday.shortHandedDefenseMultiplier(playersOnPitch);
    }
    return 1.0;
  }

  List<_UnitMember> _unitMembers(
    List<Player> lineup, {
    required Map<String, Position> assignedPositions,
    required Set<Position> positions,
    required Set<Position> supportingPositions,
  }) => [
    for (final player in lineup)
      if (positions.contains(assignedPositions[player.id] ?? player.position))
        _UnitMember(
          player: player,
          weight:
              supportingPositions.contains(
                assignedPositions[player.id] ?? player.position,
              )
              ? 0.5
              : 1.0,
        ),
  ];
}

class _UnitMemberships {
  _UnitMemberships({
    required this.defensive,
    required this.midfield,
    required this.attacking,
  }) : defensivePlayerIds = List.unmodifiable([
         for (final member in defensive) member.player.id,
       ]),
       midfieldPlayerIds = List.unmodifiable([
         for (final member in midfield) member.player.id,
       ]),
       attackingPlayerIds = List.unmodifiable([
         for (final member in attacking) member.player.id,
       ]),
       defensiveWeights = Map.unmodifiable({
         for (final member in defensive) member.player.id: member.weight,
       }),
       midfieldWeights = Map.unmodifiable({
         for (final member in midfield) member.player.id: member.weight,
       }),
       attackingWeights = Map.unmodifiable({
         for (final member in attacking) member.player.id: member.weight,
       });

  final List<_UnitMember> defensive;
  final List<_UnitMember> midfield;
  final List<_UnitMember> attacking;
  final List<String> defensivePlayerIds;
  final List<String> midfieldPlayerIds;
  final List<String> attackingPlayerIds;
  final Map<String, double> defensiveWeights;
  final Map<String, double> midfieldWeights;
  final Map<String, double> attackingWeights;
}

enum UnitKind { def, mid, atk }

class _UnitMember {
  const _UnitMember({required this.player, required this.weight});

  final Player player;
  final double weight;
}
