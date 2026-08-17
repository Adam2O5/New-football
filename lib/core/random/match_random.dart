import 'dart:math';

/// One deterministic random stream owned by a simulated match.
///
/// The wrapper keeps the order of random consumption explicit. Simulation
/// helpers must receive this instance instead of constructing a new [Random].
class MatchRandomRoll {
  const MatchRandomRoll({required this.kind, required this.value});

  final String kind;
  final double value;
}

class MatchRandom {
  MatchRandom(this.seed, {this.recordRolls = true}) : _random = Random(seed);

  final Random _random;
  final int seed;
  final bool recordRolls;
  final List<MatchRandomRoll> _rolls = [];
  double? _gaussianCache;
  int _cursor = 0;

  /// Number of underlying uniform/integer draws consumed by this stream.
  int get cursor => _cursor;

  /// Raw draw trace for deterministic diagnostics and tests.
  List<MatchRandomRoll> get rolls => List.unmodifiable(_rolls);

  double nextDouble() {
    final value = _random.nextDouble();
    _cursor++;
    if (recordRolls) {
      _rolls.add(MatchRandomRoll(kind: 'double', value: value));
    }
    return value;
  }

  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'Must be greater than zero.');
    }
    final value = _random.nextInt(max);
    _cursor++;
    if (recordRolls) {
      _rolls.add(MatchRandomRoll(kind: 'int', value: value.toDouble()));
    }
    return value;
  }

  bool nextBool() => nextDouble() < 0.5;

  /// Standard normal variate generated from two uniforms.
  ///
  /// The cached second variate is still deterministic and does not consume a
  /// new underlying draw. [u1] is bounded away from zero for log safety.
  double nextGaussian() {
    final cached = _gaussianCache;
    if (cached != null) {
      _gaussianCache = null;
      return cached;
    }

    final u1 = max(nextDouble(), 1e-12);
    final u2 = nextDouble();
    final radius = sqrt(-2.0 * log(u1));
    final angle = 2.0 * pi * u2;
    final z0 = radius * cos(angle);
    _gaussianCache = radius * sin(angle);
    return z0;
  }

  /// Poisson variate using Knuth's product algorithm.
  ///
  /// Task 17 clamps the returned value at the call site because the matchday
  /// model limits the number of sequences in a minute to 0–3.
  int nextPoisson(double lambda) {
    if (lambda <= 0) return 0;
    final threshold = exp(-lambda);
    var product = 1.0;
    var count = 0;
    do {
      count++;
      product *= nextDouble();
    } while (product > threshold);
    return count - 1;
  }

  T pickWeighted<T>(Map<T, double> weights) {
    var total = 0.0;
    var hasPositive = false;
    for (final entry in weights.entries) {
      if (entry.value > 0) {
        hasPositive = true;
        total += entry.value;
      }
    }
    if (!hasPositive) {
      throw ArgumentError.value(
        weights,
        'weights',
        'At least one weight must be positive.',
      );
    }

    var roll = nextDouble() * total;
    late T lastPositive;
    for (final entry in weights.entries) {
      if (entry.value <= 0) continue;
      lastPositive = entry.key;
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }
    return lastPositive;
  }
}
