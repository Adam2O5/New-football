import 'package:new_football/core/models/enums.dart';

/// Tunable constants from `docs/matchday_model.md` §19.
///
/// The walkover and no-GK fields are retained for the current engine contract;
/// the remaining fields are the documented model constants that later
/// simulation tasks will consume.
class MatchdayBalance {
  const MatchdayBalance({
    this.walkoverGoalsFor = 0,
    this.walkoverGoalsAgainst = 3,
    this.noGkGoalsFor = 0,
    this.noGkGoalsAgainst = 5,
    this.maxSubstitutions = 5,
    this.maxSubstitutionWindows = 3,
    this.shapeBaseline = 55,
    this.shapeWeight = 0.0025,
    this.duelDispersion = 35,
    this.duelSigma = 6.0,
    this.sequenceBase = 1.15,
    this.sequenceToShot = 0.22,
    this.shotToGoal = 0.115,
    this.foulBase = 0.085,
    this.yellowFromFoul = 0.13,
    this.redDirect = 0.007,
    this.injuryBase = 0.00018,
    this.clutchWeight = 1.2,
    this.momentumDecay = 0.96,
    this.momentumGoal = 25,
    this.roleFitBonus = 1.03,
    this.leaderBonus = 1.02,
    this.cardProneTemperamental = 1.35,
    this.injuryProfessional = 0.80,
    this.aerialBase = 60,
    this.aerialSlope = 1.2,
    this.aerialClampMin = 35,
    this.aerialClampMax = 85,
    this.aerialDuelWeight = 0.15,
    this.aerialEdgeClamp = 25,
    this.aerialCornerCoef = 0.006,
    this.aerialFkCoef = 0.003,
    this.possessionSlowBonus = 0.03,
    this.possessionFastPenalty = 0.03,
    this.possessionGegenpressingBonus = 0.04,
    this.tempoSlowMultiplier = 0.88,
    this.tempoBalancedMultiplier = 1.0,
    this.tempoFastMultiplier = 1.18,
    this.pressingLowMultiplier = 0.94,
    this.pressingMediumMultiplier = 1.0,
    this.pressingHighMultiplier = 1.08,
    this.pressingGegenpressingMultiplier = 1.14,
    this.sequenceMaxPerMinute = 3,
    this.momentumSequenceDivisor = 1500.0,
    this.sequenceConditionBonus = 4.0,
    this.sequenceStrongConditionBonus = 6.0,
    this.sequenceTypeBaseWeights = const <String, double>{
      'centralBuildUp': 22,
      'wingPlay': 20,
      'crossFromWide': 12,
      'throughBall': 11,
      'individualDribble': 10,
      'counterAttack': 9,
      'longBall': 8,
      'setPiece': 8,
    },
    this.stakeRegularSequenceMultiplier = 1.0,
    this.stakePlayInSequenceMultiplier = 1.02,
    this.stakePlayoffSequenceMultiplier = 1.04,
    this.stakePlayoffEliminationSequenceMultiplier = 1.08,
    this.stakeLeagueFinalSequenceMultiplier = 1.10,
  });

  /// Illegal roster → walkover score for the offending side.
  final int walkoverGoalsFor;
  final int walkoverGoalsAgainst;

  /// Outfield / empty GK slot → hard penalty score.
  final int noGkGoalsFor;
  final int noGkGoalsAgainst;

  /// Current engine names retained for backwards compatibility.
  final int maxSubstitutions;
  final int maxSubstitutionWindows;

  /// `SHAPE_BASELINE` and `SHAPE_WEIGHT`.
  final int shapeBaseline;
  final double shapeWeight;

  /// `DUEL_DISPERSION` and `DUEL_SIGMA`.
  final int duelDispersion;
  final double duelSigma;

  /// Sequence, shot and goal conversion constants.
  final double sequenceBase;
  final double sequenceToShot;
  final double shotToGoal;

  /// Foul and card probabilities.
  final double foulBase;
  final double yellowFromFoul;
  final double redDirect;

  final double injuryBase;
  final double clutchWeight;
  final double momentumDecay;
  final int momentumGoal;

  final double roleFitBonus;
  final double leaderBonus;
  final double cardProneTemperamental;
  final double injuryProfessional;

  /// Aerial-duel and set-piece constants.
  final int aerialBase;
  final double aerialSlope;
  final int aerialClampMin;
  final int aerialClampMax;
  final double aerialDuelWeight;
  final int aerialEdgeClamp;
  final double aerialCornerCoef;
  final double aerialFkCoef;

  /// Task 17 possession and sequence-loop parameters.
  final double possessionSlowBonus;
  final double possessionFastPenalty;
  final double possessionGegenpressingBonus;
  final double tempoSlowMultiplier;
  final double tempoBalancedMultiplier;
  final double tempoFastMultiplier;
  final double pressingLowMultiplier;
  final double pressingMediumMultiplier;
  final double pressingHighMultiplier;
  final double pressingGegenpressingMultiplier;
  final int sequenceMaxPerMinute;
  final double momentumSequenceDivisor;
  final double sequenceConditionBonus;
  final double sequenceStrongConditionBonus;
  final Map<String, double> sequenceTypeBaseWeights;
  final double stakeRegularSequenceMultiplier;
  final double stakePlayInSequenceMultiplier;
  final double stakePlayoffSequenceMultiplier;
  final double stakePlayoffEliminationSequenceMultiplier;
  final double stakeLeagueFinalSequenceMultiplier;

  double tempoMultiplier(Tempo tempo) => switch (tempo) {
    Tempo.slow => tempoSlowMultiplier,
    Tempo.balanced => tempoBalancedMultiplier,
    Tempo.fast => tempoFastMultiplier,
  };

  double pressingMultiplier(PressingIntensity pressing) => switch (pressing) {
    PressingIntensity.low => pressingLowMultiplier,
    PressingIntensity.medium => pressingMediumMultiplier,
    PressingIntensity.high => pressingHighMultiplier,
    PressingIntensity.gegenpressing => pressingGegenpressingMultiplier,
  };

  double stakeMultiplier(MatchStake stake) => switch (stake) {
    MatchStake.regular => stakeRegularSequenceMultiplier,
    MatchStake.playIn => stakePlayInSequenceMultiplier,
    MatchStake.playoff => stakePlayoffSequenceMultiplier,
    MatchStake.playoffElimination => stakePlayoffEliminationSequenceMultiplier,
    MatchStake.leagueFinal => stakeLeagueFinalSequenceMultiplier,
  };

  /// Documentation names for the substitution limits.
  int get subLimit => maxSubstitutions;
  int get subWindows => maxSubstitutionWindows;
}
