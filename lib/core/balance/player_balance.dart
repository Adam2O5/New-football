import 'package:new_football/core/models/enums.dart';

/// Stamina, fatigue and form knobs (`player_management.md`). Trade-value
/// knobs moved to `TradeValueBalance` (`trade_value_balance.dart`).
class PlayerBalance {
  const PlayerBalance({
    this.staminaMin = 0,
    this.staminaMax = 100,
    this.minutesPerMatch = 90,
    // Kept for compatibility with older callers; Task 12 uses positional
    // consumption through [staminaLossForMinutes].
    this.fatiguePerFullMatch = 15,
    this.recoveryBetweenMatches = 20,
    this.injuryDaysClampMax = 999,
    this.staminaOkThreshold = 80,
    this.staminaSoftThreshold = 60,
    this.staminaMidThreshold = 40,
    this.staminaLowThreshold = 20,
    this.injuryRiskOk = 0.90,
    this.injuryRiskSoft = 1.00,
    this.injuryRiskMid = 1.20,
    this.injuryRiskLow = 1.40,
    this.injuryRiskHard = 1.67,
    this.performanceOk = 1.00,
    this.performanceAtSoft = 0.97,
    this.performanceAtMid = 0.90,
    this.performanceAtLow = 0.75,
    this.performanceAtZero = 0.50,
    this.formMin = 1.0,
    this.formMax = 10.0,
    this.noAppearanceFormDrift = 0.2,
    this.outfieldOverallWeights = _defaultOutfieldOverallWeights,
    this.tallestOutfieldSampleSize = 5,
  });

  final int staminaMin;
  final int staminaMax;
  final int minutesPerMatch;
  final int fatiguePerFullMatch;
  final int recoveryBetweenMatches;
  final int injuryDaysClampMax;

  /// Stamina thresholds from `player_management.md`.
  final int staminaOkThreshold;
  final int staminaSoftThreshold;
  final int staminaMidThreshold;
  final int staminaLowThreshold;

  final double injuryRiskOk;
  final double injuryRiskSoft;
  final double injuryRiskMid;
  final double injuryRiskLow;
  final double injuryRiskHard;

  final double performanceOk;
  final double performanceAtSoft;
  final double performanceAtMid;
  final double performanceAtLow;

  /// Contribution multiplier when stamina is in the critical 0–19 band.
  final double performanceAtZero;

  final double formMin;
  final double formMax;
  final double noAppearanceFormDrift;

  /// Weighted OVR face-stats per outfield position (weights need not sum to 1).
  final Map<Position, OutfieldAttrWeights> outfieldOverallWeights;

  /// How many tallest outfield players feed set-piece / aerial averages.
  final int tallestOutfieldSampleSize;

  // wages untouchable
  static const _defaultOutfieldOverallWeights = <Position, OutfieldAttrWeights>{
    Position.cb: OutfieldAttrWeights(
      pace: 0.10,
      shooting: 0.05,
      passing: 0.15,
      dribbling: 0.05,
      defending: 0.40,
      physicality: 0.25,
    ),
    Position.lb: OutfieldAttrWeights(
      pace: 0.25,
      shooting: 0.05,
      passing: 0.20,
      dribbling: 0.10,
      defending: 0.25,
      physicality: 0.15,
    ),
    Position.rb: OutfieldAttrWeights(
      pace: 0.25,
      shooting: 0.05,
      passing: 0.20,
      dribbling: 0.10,
      defending: 0.25,
      physicality: 0.15,
    ),
    Position.lwb: OutfieldAttrWeights(
      pace: 0.28,
      shooting: 0.08,
      passing: 0.18,
      dribbling: 0.14,
      defending: 0.20,
      physicality: 0.12,
    ),
    Position.rwb: OutfieldAttrWeights(
      pace: 0.28,
      shooting: 0.08,
      passing: 0.18,
      dribbling: 0.14,
      defending: 0.20,
      physicality: 0.12,
    ),
    Position.cdm: OutfieldAttrWeights(
      pace: 0.10,
      shooting: 0.05,
      passing: 0.25,
      dribbling: 0.10,
      defending: 0.30,
      physicality: 0.20,
    ),
    Position.cm: OutfieldAttrWeights(
      pace: 0.15,
      shooting: 0.10,
      passing: 0.30,
      dribbling: 0.20,
      defending: 0.10,
      physicality: 0.15,
    ),
    Position.cam: OutfieldAttrWeights(
      pace: 0.15,
      shooting: 0.20,
      passing: 0.30,
      dribbling: 0.25,
      defending: 0.05,
      physicality: 0.05,
    ),
    Position.lw: OutfieldAttrWeights(
      pace: 0.30,
      shooting: 0.20,
      passing: 0.15,
      dribbling: 0.25,
      defending: 0.05,
      physicality: 0.05,
    ),
    Position.rw: OutfieldAttrWeights(
      pace: 0.30,
      shooting: 0.20,
      passing: 0.15,
      dribbling: 0.25,
      defending: 0.05,
      physicality: 0.05,
    ),
    Position.st: OutfieldAttrWeights(
      pace: 0.20,
      shooting: 0.35,
      passing: 0.05,
      dribbling: 0.15,
      defending: 0.05,
      physicality: 0.20,
    ),
  };

  /// Legacy single-value fatigue helper retained for older call sites.
  int fatigueForMinutes(int minutesPlayed) =>
      (minutesPlayed / minutesPerMatch * fatiguePerFullMatch).round();

  static const _staminaLossPer90 = <Position, double>{
    Position.gk: 15,
    Position.cb: 65,
    Position.lb: 75,
    Position.rb: 75,
    Position.lwb: 85,
    Position.rwb: 85,
    Position.cdm: 70,
    Position.cm: 70,
    Position.cam: 70,
    Position.lw: 80,
    Position.rw: 80,
    Position.st: 70,
  };

  static const formMultipliers = <double>[
    0.90,
    0.92,
    0.95,
    0.97,
    0.99,
    1.00,
    1.04,
    1.07,
    1.09,
    1.12,
  ];

  int clampStamina(int value) => value.clamp(staminaMin, staminaMax);

  double clampForm(double value) => value.clamp(formMin, formMax).toDouble();

  double staminaLossPer90(Position position) => _staminaLossPer90[position]!;

  double staminaConsumptionMultiplier({
    required Tempo tempo,
    required PressingIntensity pressing,
    required Weather weather,
    required bool isDerby,
    double additionalMultiplier = 1.0,
  }) {
    var multiplier = switch (tempo) {
      Tempo.fast => 1.15,
      Tempo.slow => 0.90,
      Tempo.balanced => 1.0,
    };
    multiplier *= switch (pressing) {
      PressingIntensity.high => 1.10,
      PressingIntensity.gegenpressing => 1.20,
      PressingIntensity.low => 0.90,
      PressingIntensity.medium => 1.0,
    };
    if (weather == Weather.heat) multiplier *= 1.15;
    if (isDerby) multiplier *= 1.05;
    return multiplier * additionalMultiplier;
  }

  double staminaLossForMinutes(
    Position position,
    int minutesPlayed, {
    Tempo tempo = Tempo.balanced,
    PressingIntensity pressing = PressingIntensity.medium,
    Weather weather = Weather.clear,
    bool isDerby = false,
    double additionalMultiplier = 1.0,
  }) {
    final minutes = minutesPlayed.clamp(0, minutesPerMatch);
    return staminaLossPer90(position) *
        minutes /
        minutesPerMatch *
        staminaConsumptionMultiplier(
          tempo: tempo,
          pressing: pressing,
          weather: weather,
          isDerby: isDerby,
          additionalMultiplier: additionalMultiplier,
        );
  }

  OutfieldAttrWeights outfieldWeightsFor(Position position) {
    final weights = outfieldOverallWeights[position];
    if (weights == null) {
      throw ArgumentError.value(
        position,
        'position',
        'No outfield overall weights for this position (GK uses GoalkeeperAttributes).',
      );
    }
    return weights;
  }

  /// Match contribution multiplier from current stamina (1.0 = full).
  double performanceMult(int stamina) {
    final s = clampStamina(stamina);
    if (s >= staminaOkThreshold) return performanceOk;
    if (s >= staminaSoftThreshold) return performanceAtSoft;
    if (s >= staminaMidThreshold) return performanceAtMid;
    if (s >= staminaLowThreshold) return performanceAtLow;
    return performanceAtZero;
  }

  /// Injury chance multiplier from current stamina (`player_management.md` §6).
  double injuryRiskMult(int stamina) {
    final s = clampStamina(stamina);
    if (s >= staminaOkThreshold) return injuryRiskOk;
    if (s >= staminaSoftThreshold) return injuryRiskSoft;
    if (s >= staminaMidThreshold) return injuryRiskMid;
    if (s >= staminaLowThreshold) return injuryRiskLow;
    return injuryRiskHard;
  }

  /// Table-driven form multiplier. Fractional form values are interpolated so
  /// the exact 0.2 no-appearance drift remains meaningful in match simulation.
  double formMult(double form) {
    final f = clampForm(form);
    if (f >= formMax) return formMultipliers.last;
    final lower = f.floor().clamp(1, formMultipliers.length);
    final index = lower - 1;
    final fraction = f - lower;
    if (fraction == 0 || index == formMultipliers.length - 1) {
      return formMultipliers[index];
    }
    return formMultipliers[index] +
        (formMultipliers[index + 1] - formMultipliers[index]) * fraction;
  }
}

/// Relative weights for PAC/SHO/PAS/DRI/DEF/PHY → position overall.
class OutfieldAttrWeights {
  const OutfieldAttrWeights({
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physicality,
  });

  final double pace;
  final double shooting;
  final double passing;
  final double dribbling;
  final double defending;
  final double physicality;

  double get total =>
      pace + shooting + passing + dribbling + defending + physicality;
}
