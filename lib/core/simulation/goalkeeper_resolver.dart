import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/shot_models.dart';

/// The goalkeeper rating and profile used for one shot.
class GoalkeeperResolution {
  const GoalkeeperResolution({
    required this.goalkeeperId,
    required this.hasGoalkeeper,
    required this.profile,
    required this.profileWeights,
    required this.gkRating,
    required this.handling,
    required this.diving,
    required this.reflexes,
    required this.positioning,
    required this.speed,
    required this.handlingErrorProbability,
  });

  final String? goalkeeperId;
  final bool hasGoalkeeper;
  final SequenceShotKind profile;
  final Map<String, double> profileWeights;
  final double gkRating;
  final double handling;
  final double diving;
  final double reflexes;
  final double positioning;
  final double speed;
  final double handlingErrorProbability;

  bool get isFallback => !hasGoalkeeper;
}

/// Resolves the five documented goalkeeper profiles without changing the
/// six-attribute outfield [EffectivePlayerAttributes] contract.
class GoalkeeperResolver {
  const GoalkeeperResolver({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  GoalkeeperResolution resolve({
    required SequenceShotKind shotKind,
    required List<Player> defendingLineup,
    Map<String, EffectivePlayerAttributes> effectiveAttributes = const {},
    Weather weather = Weather.clear,
  }) {
    final profileWeights = balance.matchday.goalkeeperProfileFor(shotKind.name);
    final goalkeeper = defendingLineup
        .where((player) => player.position == Position.gk)
        .fold<Player?>(null, (best, candidate) {
          if (best == null) return candidate;
          return _goalkeeperOverall(candidate) > _goalkeeperOverall(best)
              ? candidate
              : best;
        });

    if (goalkeeper != null) {
      final values = goalkeeper.attributes.map(
        outfield: (_) => const _GoalkeeperValues.fallback(),
        goalkeeper: (attributes) => _GoalkeeperValues(
          diving: attributes.stats.diving.toDouble(),
          handling: attributes.stats.handling.toDouble(),
          reflexes: attributes.stats.reflexes.toDouble(),
          speed: attributes.stats.speed.toDouble(),
          positioning: attributes.stats.positioning.toDouble(),
        ),
      );
      final gkRating = _weighted(values, profileWeights);
      return GoalkeeperResolution(
        goalkeeperId: goalkeeper.id,
        hasGoalkeeper: true,
        profile: shotKind,
        profileWeights: Map.unmodifiable(profileWeights),
        gkRating: gkRating,
        handling: values.handling,
        diving: values.diving,
        reflexes: values.reflexes,
        positioning: values.positioning,
        speed: values.speed,
        handlingErrorProbability: _handlingError(values.handling, weather),
      );
    }

    final fallback = defendingLineup
        .where((player) => player.position != Position.gk)
        .fold<Player?>(null, (best, candidate) {
          if (best == null) return candidate;
          final candidateValue = _fallbackRating(
            candidate,
            effectiveAttributes[candidate.id],
          );
          final bestValue = _fallbackRating(best, effectiveAttributes[best.id]);
          return candidateValue > bestValue ? candidate : best;
        });
    final fallbackAttributes = fallback == null
        ? const _GoalkeeperValues.fallback()
        : _fallbackValues(fallback, effectiveAttributes[fallback.id]);
    final fallbackRating =
        (fallbackAttributes.physicality * 0.4 +
            fallbackAttributes.speed * 0.3 +
            fallbackAttributes.defending * 0.3) *
        balance.matchday.noGkRatingMultiplier;

    return GoalkeeperResolution(
      goalkeeperId: null,
      hasGoalkeeper: false,
      profile: shotKind,
      profileWeights: Map.unmodifiable(profileWeights),
      gkRating: fallbackRating,
      handling: fallbackAttributes.handling,
      diving: fallbackAttributes.diving,
      reflexes: fallbackAttributes.reflexes,
      positioning: fallbackAttributes.positioning,
      speed: fallbackAttributes.speed,
      handlingErrorProbability: _handlingError(
        fallbackAttributes.handling,
        weather,
      ),
    );
  }

  double _goalkeeperOverall(Player player) => player.attributes.map(
    outfield: (_) => 0.0,
    goalkeeper: (attributes) => attributes.stats.overall,
  );

  _GoalkeeperValues _fallbackValues(
    Player player,
    EffectivePlayerAttributes? effective,
  ) {
    final values = player.attributes.map(
      outfield: (attributes) => _GoalkeeperValues(
        diving:
            effective?.physicality ?? attributes.stats.physicality.toDouble(),
        handling: effective?.defending ?? attributes.stats.defending.toDouble(),
        reflexes: effective?.pace ?? attributes.stats.pace.toDouble(),
        speed: effective?.pace ?? attributes.stats.pace.toDouble(),
        positioning:
            effective?.defending ?? attributes.stats.defending.toDouble(),
        physicality:
            effective?.physicality ?? attributes.stats.physicality.toDouble(),
        defending:
            effective?.defending ?? attributes.stats.defending.toDouble(),
      ),
      goalkeeper: (attributes) => _GoalkeeperValues(
        diving: attributes.stats.diving.toDouble(),
        handling: attributes.stats.handling.toDouble(),
        reflexes: attributes.stats.reflexes.toDouble(),
        speed: attributes.stats.speed.toDouble(),
        positioning: attributes.stats.positioning.toDouble(),
      ),
    );
    return values;
  }

  double _fallbackRating(Player player, EffectivePlayerAttributes? effective) {
    final values = _fallbackValues(player, effective);
    return (values.physicality * 0.4 +
            values.speed * 0.3 +
            values.defending * 0.3) *
        balance.matchday.noGkRatingMultiplier;
  }

  double _weighted(_GoalkeeperValues values, Map<String, double> weights) {
    double valueFor(String key) => switch (key) {
      'diving' => values.diving,
      'handling' => values.handling,
      'reflexes' => values.reflexes,
      'speed' => values.speed,
      'positioning' => values.positioning,
      _ => 0.0,
    };
    return weights.entries.fold<double>(
      0.0,
      (sum, entry) => sum + valueFor(entry.key) * entry.value,
    );
  }

  double _handlingError(double handling, Weather weather) =>
      ((100.0 - handling) /
              1200.0 *
              balance.matchday.weatherHandlingMultiplier(weather))
          .clamp(0.0, 1.0)
          .toDouble();
}

class _GoalkeeperValues {
  const _GoalkeeperValues({
    required this.diving,
    required this.handling,
    required this.reflexes,
    required this.speed,
    required this.positioning,
    this.physicality = 0.0,
    this.defending = 0.0,
  });

  const _GoalkeeperValues.fallback()
    : diving = 0,
      handling = 0,
      reflexes = 0,
      speed = 0,
      positioning = 0,
      physicality = 0,
      defending = 0;

  final double diving;
  final double handling;
  final double reflexes;
  final double speed;
  final double positioning;
  final double physicality;
  final double defending;
}
