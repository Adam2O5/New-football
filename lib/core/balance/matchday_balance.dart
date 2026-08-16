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

  /// Documentation names for the substitution limits.
  int get subLimit => maxSubstitutions;
  int get subWindows => maxSubstitutionWindows;
}
