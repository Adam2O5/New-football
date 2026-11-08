import 'package:new_football/core/balance/simulation_profiles_balance.dart';
import 'package:new_football/core/balance/rivalry_catalog.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

/// Seasonal weights and temperature offset; null boundaries are open.
class WeatherSeasonProfile {
  const WeatherSeasonProfile({
    this.firstWeek,
    this.lastWeek,
    this.temperatureBias = 0,
    this.deltas = const {},
    this.minimums = const {},
  });
  final int? firstWeek;
  final int? lastWeek;
  final int temperatureBias;
  final Map<Weather, int> deltas;
  final Map<Weather, int> minimums;
  bool contains(int week) =>
      (firstWeek == null || week >= firstWeek!) &&
      (lastWeek == null || week <= lastWeek!);
}

/// Numeric parameters and ordered profiles for the active match simulation.
class MatchdayBalance {
  static const defaultHomeAdvantage = 0.05;
  static const defaultSequenceTypeBaseWeights = <String, double>{
    'centralBuildUp': 22,
    'wingPlay': 20,
    'crossFromWide': 12,
    'throughBall': 11,
    'individualDribble': 10,
    'counterAttack': 9,
    'longBall': 8,
    'setPiece': 8,
  };
  static const defaultUnratedPlayerRating = 6.0;
  const MatchdayBalance({
    this.homeAdvantage = defaultHomeAdvantage,

    this.ratingUnrated = defaultUnratedPlayerRating,
    this.defaultPossessionPercent = 50.0,
    this.runtimeFallbackChemistry = 50.0,
    this.runtimeFallbackAtmosphere = 50,

    this.sequenceAttackerProfiles = const {
      SequenceType.centralBuildUp: {
        EffectiveAttribute.passing: 0.55,
        EffectiveAttribute.dribbling: 0.30,
        EffectiveAttribute.physicality: 0.15,
      },
      SequenceType.wingPlay: {
        EffectiveAttribute.pace: 0.40,
        EffectiveAttribute.dribbling: 0.45,
        EffectiveAttribute.physicality: 0.15,
      },
      SequenceType.crossFromWide: {
        EffectiveAttribute.passing: 0.80,
        EffectiveAttribute.pace: 0.20,
      },
      SequenceType.throughBall: {
        EffectiveAttribute.passing: 0.85,
        EffectiveAttribute.dribbling: 0.15,
      },
      SequenceType.individualDribble: {
        EffectiveAttribute.dribbling: 0.60,
        EffectiveAttribute.pace: 0.25,
        EffectiveAttribute.physicality: 0.15,
      },
      SequenceType.counterAttack: {
        EffectiveAttribute.pace: 0.55,
        EffectiveAttribute.dribbling: 0.30,
        EffectiveAttribute.passing: 0.15,
      },
      SequenceType.longBall: {
        EffectiveAttribute.passing: 0.55,
        EffectiveAttribute.physicality: 0.25,
        EffectiveAttribute.pace: 0.20,
      },
      SequenceType.setPiece: {
        EffectiveAttribute.passing: 0.50,
        EffectiveAttribute.shooting: 0.35,
        EffectiveAttribute.physicality: 0.15,
      },
    },
    this.sequenceDefenderProfiles = const {
      SequenceType.centralBuildUp: {
        EffectiveAttribute.defending: 0.55,
        EffectiveAttribute.physicality: 0.30,
        EffectiveAttribute.pace: 0.15,
      },
      SequenceType.wingPlay: {
        EffectiveAttribute.defending: 0.45,
        EffectiveAttribute.pace: 0.40,
        EffectiveAttribute.physicality: 0.15,
      },
      SequenceType.crossFromWide: {
        EffectiveAttribute.defending: 0.60,
        EffectiveAttribute.pace: 0.40,
      },
      SequenceType.throughBall: {
        EffectiveAttribute.defending: 0.50,
        EffectiveAttribute.physicality: 0.50,
      },
      SequenceType.individualDribble: {
        EffectiveAttribute.defending: 0.50,
        EffectiveAttribute.pace: 0.30,
        EffectiveAttribute.physicality: 0.20,
      },
      SequenceType.counterAttack: {
        EffectiveAttribute.pace: 0.55,
        EffectiveAttribute.defending: 0.45,
      },
      SequenceType.longBall: {
        EffectiveAttribute.defending: 0.50,
        EffectiveAttribute.physicality: 0.35,
        EffectiveAttribute.pace: 0.15,
      },
      SequenceType.setPiece: {
        EffectiveAttribute.defending: 0.55,
        EffectiveAttribute.physicality: 0.45,
      },
    },
    this.sequenceHighUnitThreshold = 70.0,
    this.sequenceHighAttributeThreshold = 75.0,
    this.sequenceTallForwardHeight = 185,
    this.sequenceFallbackAttribute = 50.0,
    this.sequenceAttackerBaseWeight = 1.0,
    this.sequenceDefenderBaseWeight = 1.0,
    this.sequenceSetPieceAttributeDivisor = 200.0,
    this.sequenceMatchingFlankWeight = 3.0,
    this.sequenceAttackerPositionBonuses = const {
      SequenceType.centralBuildUp: {
        Position.cm: 2,
        Position.cam: 2,
        Position.cdm: 1,
      },
      SequenceType.wingPlay: {
        Position.lw: 3,
        Position.rw: 3,
        Position.lb: 1.5,
        Position.rb: 1.5,
        Position.lwb: 1.5,
        Position.rwb: 1.5,
      },
      SequenceType.crossFromWide: {
        Position.lw: 3,
        Position.rw: 3,
        Position.lb: 1.5,
        Position.rb: 1.5,
        Position.lwb: 1.5,
        Position.rwb: 1.5,
      },
      SequenceType.throughBall: {
        Position.cam: 2,
        Position.cm: 2,
        Position.st: 1,
      },
      SequenceType.individualDribble: {
        Position.lw: 3,
        Position.rw: 3,
        Position.cam: 3,
      },
      SequenceType.counterAttack: {
        Position.st: 3,
        Position.lw: 3,
        Position.rw: 3,
      },
      SequenceType.longBall: {Position.st: 3, Position.lw: 1, Position.rw: 1},
    },
    this.sequenceDefenderPositionWeights = const {
      SequenceType.wingPlay: {Position.cb: 1.5, Position.cdm: 0.8},
      SequenceType.crossFromWide: {Position.cb: 1.5, Position.cdm: 0.8},
      SequenceType.centralBuildUp: {
        Position.cdm: 2.5,
        Position.cm: 1.5,
        Position.cb: 1.8,
      },
      SequenceType.throughBall: {Position.cb: 2.5, Position.cdm: 1.5},
      SequenceType.individualDribble: {
        Position.lb: 2.5,
        Position.rb: 2.5,
        Position.lwb: 2.5,
        Position.rwb: 2.5,
        Position.cb: 1.8,
      },
      SequenceType.counterAttack: {
        Position.cb: 2,
        Position.lb: 1.5,
        Position.rb: 1.5,
        Position.lwb: 1.5,
        Position.rwb: 1.5,
      },
      SequenceType.longBall: {Position.cb: 2.5, Position.cdm: 1.5},
      SequenceType.setPiece: {Position.cb: 2, Position.cdm: 1.3},
    },
    this.unitDefDefendingWeight = 0.45,
    this.unitDefPhysicalityWeight = 0.25,
    this.unitDefPaceWeight = 0.20,
    this.unitDefPassingWeight = 0.10,
    this.unitMidPassingWeight = 0.35,
    this.unitMidDribblingWeight = 0.25,
    this.unitMidDefendingWeight = 0.20,
    this.unitMidPhysicalityWeight = 0.20,
    this.unitAtkShootingWeight = 0.35,
    this.unitAtkPaceWeight = 0.25,
    this.unitAtkDribblingWeight = 0.25,
    this.unitAtkPassingWeight = 0.15,
    this.unitSupportingPositionWeight = 0.5,
    this.sequenceStages = const {
      SequenceType.centralBuildUp: [
        SequenceStageProfile(
          attackerPositions: {Position.cm, Position.cam, Position.cdm},
          defenderPositions: {Position.cdm, Position.cm, Position.cb},
          attackerWeights: {
            EffectiveAttribute.passing: 0.55,
            EffectiveAttribute.dribbling: 0.30,
            EffectiveAttribute.physicality: 0.15,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.55,
            EffectiveAttribute.physicality: 0.30,
            EffectiveAttribute.pace: 0.15,
          },
        ),
        SequenceStageProfile(
          attackerPositions: {Position.cam, Position.cm},
          defenderPositions: {Position.cb},
          attackerWeights: {
            EffectiveAttribute.passing: 0.70,
            EffectiveAttribute.dribbling: 0.30,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.60,
            EffectiveAttribute.pace: 0.40,
          },
        ),
      ],
      SequenceType.wingPlay: [
        SequenceStageProfile(
          attackerPositions: {
            Position.lw,
            Position.rw,
            Position.lb,
            Position.rb,
            Position.lwb,
            Position.rwb,
          },
          defenderPositions: {
            Position.lb,
            Position.rb,
            Position.lwb,
            Position.rwb,
          },
          attackerWeights: {
            EffectiveAttribute.pace: 0.40,
            EffectiveAttribute.dribbling: 0.45,
            EffectiveAttribute.physicality: 0.15,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.45,
            EffectiveAttribute.pace: 0.40,
            EffectiveAttribute.physicality: 0.15,
          },
        ),
        SequenceStageProfile(
          attackerPositions: {Position.lw, Position.rw, Position.cam},
          defenderPositions: {Position.cb},
          attackerWeights: {
            EffectiveAttribute.passing: 0.50,
            EffectiveAttribute.dribbling: 0.50,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.70,
            EffectiveAttribute.physicality: 0.30,
          },
        ),
      ],
      SequenceType.crossFromWide: [
        SequenceStageProfile(
          attackerPositions: {Position.lw, Position.rw},
          defenderPositions: {
            Position.lb,
            Position.rb,
            Position.lwb,
            Position.rwb,
          },
          attackerWeights: {
            EffectiveAttribute.passing: 0.80,
            EffectiveAttribute.pace: 0.20,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.60,
            EffectiveAttribute.pace: 0.40,
          },
        ),
        SequenceStageProfile(
          attackerPositions: {Position.st},
          defenderPositions: {Position.cb},
          attackerWeights: {
            EffectiveAttribute.physicality: 0.55,
            EffectiveAttribute.shooting: 0.30,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.50,
            EffectiveAttribute.physicality: 0.35,
          },
          attackerAerialWeight: 0.15,
          defenderAerialWeight: 0.15,
        ),
      ],
      SequenceType.throughBall: [
        SequenceStageProfile(
          attackerPositions: {Position.cam, Position.cm},
          defenderPositions: {Position.cdm},
          attackerWeights: {
            EffectiveAttribute.passing: 0.85,
            EffectiveAttribute.dribbling: 0.15,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.50,
            EffectiveAttribute.physicality: 0.50,
          },
        ),
        SequenceStageProfile(
          attackerPositions: {Position.st, Position.lw, Position.rw},
          defenderPositions: {Position.cb},
          attackerWeights: {
            EffectiveAttribute.pace: 0.70,
            EffectiveAttribute.dribbling: 0.30,
          },
          defenderWeights: {
            EffectiveAttribute.pace: 0.55,
            EffectiveAttribute.defending: 0.45,
          },
        ),
      ],
      SequenceType.individualDribble: [
        SequenceStageProfile(
          attackerPositions: {
            Position.lw,
            Position.rw,
            Position.cam,
            Position.st,
          },
          defenderPositions: {
            Position.lb,
            Position.rb,
            Position.lwb,
            Position.rwb,
            Position.cb,
          },
          attackerWeights: {
            EffectiveAttribute.dribbling: 0.60,
            EffectiveAttribute.pace: 0.25,
            EffectiveAttribute.physicality: 0.15,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.55,
            EffectiveAttribute.pace: 0.25,
            EffectiveAttribute.physicality: 0.20,
          },
        ),
        SequenceStageProfile(
          attackerPositions: {
            Position.lw,
            Position.rw,
            Position.cam,
            Position.st,
          },
          defenderPositions: {Position.cb},
          attackerWeights: {
            EffectiveAttribute.dribbling: 0.50,
            EffectiveAttribute.shooting: 0.50,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.80,
            EffectiveAttribute.physicality: 0.20,
          },
        ),
      ],
      SequenceType.counterAttack: [
        SequenceStageProfile(
          attackerPositions: {Position.st, Position.lw, Position.rw},
          defenderPositions: {Position.cb, Position.lb, Position.rb},
          attackerWeights: {
            EffectiveAttribute.pace: 0.50,
            EffectiveAttribute.dribbling: 0.30,
            EffectiveAttribute.passing: 0.20,
          },
          defenderWeights: {
            EffectiveAttribute.pace: 0.60,
            EffectiveAttribute.defending: 0.40,
          },
        ),
        SequenceStageProfile(
          attackerPositions: {Position.st, Position.lw, Position.rw},
          defenderPositions: {Position.cb, Position.lb, Position.rb},
          attackerWeights: {
            EffectiveAttribute.shooting: 0.55,
            EffectiveAttribute.dribbling: 0.25,
            EffectiveAttribute.pace: 0.20,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.65,
            EffectiveAttribute.pace: 0.35,
          },
        ),
      ],
      SequenceType.longBall: [
        SequenceStageProfile(
          attackerPositions: {Position.st},
          defenderPositions: {Position.cb},
          attackerWeights: {
            EffectiveAttribute.physicality: 0.50,
            EffectiveAttribute.dribbling: 0.35,
          },
          defenderWeights: {
            EffectiveAttribute.defending: 0.45,
            EffectiveAttribute.physicality: 0.40,
          },
          attackerAerialWeight: 0.15,
          defenderAerialWeight: 0.15,
        ),
      ],
      SequenceType.setPiece: [],
    },
    this.throughBallHighLineDefenderWeights = const {
      EffectiveAttribute.pace: 0.65,
      EffectiveAttribute.defending: 0.45,
    },

    this.rivalryKeys = rivalryCatalog,
    this.refereeRandomMin = 0.80,
    this.refereeRandomSpan = 0.40,
    this.refereeMin = 0.80,
    this.refereeMax = 1.20,
    this.playoffRefereeMultiplier = 0.95,
    this.crowdBase = 45,
    this.crowdFormWeight = 0.3,
    this.crowdDerbyBonus = 20,
    this.crowdMin = 0,
    this.crowdMax = 100,
    this.crowdInitialMomentumDivisor = 8.0,
    this.temperatureMin = -5,
    this.temperatureMax = 38,
    this.temperatureRandomRange = 44,
    this.stakeCrowdBonuses = const {
      MatchStake.regular: 0,
      MatchStake.playIn: 10,
      MatchStake.playoff: 15,
      MatchStake.playoffElimination: 25,
      MatchStake.leagueFinal: 30,
    },
    this.weatherBaseWeights = const {
      Weather.clear: 24,
      Weather.overcast: 15,
      Weather.rain: 14,
      Weather.heavyRain: 8,
      Weather.wind: 10,
      Weather.snow: 5,
      Weather.heat: 10,
      Weather.cold: 14,
    },
    this.weatherSeasons = const [
      WeatherSeasonProfile(
        lastWeek: 8,
        temperatureBias: 8,
        deltas: {
          Weather.heat: 22,
          Weather.clear: 8,
          Weather.snow: -4,
          Weather.cold: -8,
        },
        minimums: {Weather.snow: 1, Weather.cold: 2},
      ),
      WeatherSeasonProfile(
        firstWeek: 17,
        lastWeek: 25,
        temperatureBias: -8,
        deltas: {
          Weather.snow: 22,
          Weather.cold: 18,
          Weather.heavyRain: 8,
          Weather.heat: -9,
        },
        minimums: {Weather.heat: 1},
      ),
      WeatherSeasonProfile(
        firstWeek: 26,
        lastWeek: 34,
        deltas: {Weather.clear: 8, Weather.heat: 8, Weather.snow: -5},
        minimums: {Weather.snow: 1},
      ),
    ],

    this.duelLogisticBase = 10.0,
    this.clutchMinute = 85,
    this.shootingScale = 180.0,
    this.shotXgMin = 0.01,
    this.shotXgMax = 0.95,
    this.goalProbabilityMin = 0.005,
    this.goalProbabilityMax = 0.97,
    this.reboundXgMin = 0.005,
    this.reboundXgMax = 0.95,
    this.bigChanceXgThreshold = 0.4,
    this.fallbackGkPhysicalityWeight = 0.4,
    this.fallbackGkSpeedWeight = 0.3,
    this.fallbackGkDefendingWeight = 0.3,
    this.handlingErrorBaseline = 100.0,
    this.handlingErrorScale = 1200.0,
    this.scoreReactionMinute = 65,
    this.possessionProbabilityMin = 0.02,
    this.possessionProbabilityMax = 0.98,
    this.momentumCutoff = 0.01,
    this.momentumMin = -100.0,
    this.momentumMax = 100.0,
    this.firstHalfStoppageMax = 8,
    this.unitRatingMin = 0.0,
    this.unitRatingMax = 200.0,
    this.cohesionMultiplierMax = 2.0,
    this.ratingAssist = 0.7,
    this.ratingOffensiveDuel = 0.05,
    this.ratingDefensiveDuel = 0.06,
    this.ratingGoalCausingLoss = 0.45,
    this.ratingSave = 0.1,
    this.ratingPenaltySave = 1.2,
    this.cleanSheetMinutes = 60,
    this.ratingCleanSheet = 0.6,
    this.ratingOwnGoalPenalty = 1.5,
    this.ratingYellowPenalty = 0.3,
    this.ratingRedPenalty = 1.5,
    this.ratingMissedBigChancePenalty = 0.25,
    this.ratingShortAppearanceMinutes = 20,
    this.ratingBase = 6.0,
    this.ratingMin = 1.0,
    this.ratingMax = 10.0,
    this.ratingForwardGoal = 1.0,
    this.ratingMidfielderGoal = 1.3,
    this.ratingDefenderGoal = 1.6,
    this.roleMismatchMultiplier = 0.9,
    this.ambitiousClutchMultiplier = 0.03,
    this.loyalAdverseMomentumMultiplier = 0.8,
    this.weeklyThirdMatchThreshold = 3,
    this.weeklySecondMatchThreshold = 2,
    this.weeklyThirdMatchMultiplier = 0.96,
    this.weeklySecondMatchMultiplier = 0.98,
    this.chainLongBallProbabilityMin = 0.05,
    this.chainLongBallProbabilityMax = 0.95,
    this.chainLowQuality = 0.7,
    this.chainNormalQuality = 1.0,
    this.chainHighQuality = 1.4,
    this.chainRepeatPlayerMultiplier = 0.5,
    this.chainAllowedPositionWeight = 3.0,
    this.chainOtherPositionWeight = 1.0,
    this.sfgPenaltyShootingWeight = 0.6,
    this.sfgAttackingPlayers = 5,
    this.sfgDefendingOutfieldPlayers = 4,
    this.sfgDefendingGoalkeepers = 1,
    this.fallbackAerialHeight = 180,

    this.oneOnOneRedMultiplier = 2.0,
    this.duelInjuryMultiplier = 2.5,
    this.effectiveAttributeMin = 30.0,
    this.effectiveAttributeMax = 120.0,
    this.walkoverGoalsFor = 0,
    this.walkoverGoalsAgainst = 3,
    this.maxSubstitutions = 5,
    this.maxSubstitutionWindows = 3,
    this.cohesionTacticsPenalty = 2.0,
    this.cohesionPenaltyDurationMinutes = 10,
    this.adaptationAppearances = 5,
    this.adaptationPenaltyAtZero = 1.0,
    this.shapeBaseline = 55,
    this.shapeWeight = 0.0025,
    this.duelDispersion = 35,
    this.duelSigma = 10.5,
    this.possessionDuelDispersion = 65,
    this.possessionDuelSigma = 11.0,
    this.homeAdvantageAttackScale = 8.0,
    this.homeAdvantageAwayAttackPenaltyScale = 2.0,
    this.sequenceBase = 1.15,
    this.sequenceToShot = 0.22,
    this.shotToGoal = 0.115,
    this.foulBase = 0.2359,
    this.foulCardedPlayerMultiplier = 0.10,
    this.yellowFromFoul = 0.17,
    this.redDirect = 0.0045,
    this.foulPressingLowMultiplier = 0.85,
    this.foulPressingMediumMultiplier = 1.0,
    this.foulPressingHighMultiplier = 1.15,
    this.foulPressingGegenpressingMultiplier = 1.30,
    this.physGapDivisor = 300.0,
    this.derbyFoulMultiplier = 1.15,
    this.shortHandedTenAttackMultiplier = 0.86,
    this.shortHandedTenDefenseMultiplier = 0.92,
    this.shortHandedNineAttackMultiplier = 0.70,
    this.shortHandedNineDefenseMultiplier = 0.80,
    this.shortHandedTenStaminaMultiplier = 1.12,
    this.shortHandedNineStaminaMultiplier = 1.20,
    this.injuryProneMultipliers = const <int, double>{
      1: 0.50,
      2: 0.625,
      3: 0.75,
      4: 0.875,
      5: 1.00,
      6: 1.20,
      7: 1.40,
      8: 1.60,
      9: 1.80,
      10: 2.00,
    },
    this.injuryIntensityFast = 1.15,
    this.injuryIntensityGegenpressing = 1.20,
    this.injuryIntensitySlow = 0.92,
    this.injuryIntensityLowPress = 0.92,
    this.weatherInjuryMultipliers = const <String, double>{
      'clear': 1.00,
      'overcast': 1.00,
      'rain': 1.08,
      'heavyRain': 1.15,
      'wind': 1.00,
      'snow': 1.18,
      'heat': 1.10,
      'cold': 1.12,
    },
    this.injuryBase = 0.00010,
    this.clutchWeight = 1.2,
    this.momentumDecay = 0.96,
    this.momentumGoal = 25,
    this.momentumMissedBigChance = 8,
    this.momentumSavedPenalty = 18,
    this.momentumRedCard = 20,
    this.momentumKeyPlayerInjury = 8,
    this.derbyMomentumMultiplier = 1.25,
    this.derbySequenceMultiplier = 1.05,
    this.crowdHomeDivisor = 2500.0,
    this.crowdAwayDivisor = 4000.0,
    this.crowdRefereeDivisor = 1500.0,
    this.temperatureHotThreshold = 24,
    this.temperatureHotStep = 0.012,
    this.temperatureColdThreshold = 4,
    this.temperatureColdStep = 0.008,
    this.windLongBallWeightMultiplier = 1.40,
    this.scoreTrailingOneAttackDelta = 6,
    this.scoreTrailingOneDefenseDelta = -5,
    this.scoreTrailingOneLambdaMultiplier = 1.10,
    this.scoreTrailingTwoAttackDelta = 10,
    this.scoreTrailingTwoDefenseDelta = -9,
    this.scoreTrailingTwoLambdaMultiplier = 1.18,
    this.scoreTrailingTwoLongBallMultiplier = 1.60,
    this.scoreLeadingOneAttackDelta = -4,
    this.scoreLeadingOneDefenseDelta = 5,
    this.scoreLeadingOneLambdaMultiplier = 0.94,
    this.scoreLeadingTwoAttackDelta = -6,
    this.scoreLeadingTwoDefenseDelta = 7,
    this.scoreLeadingTwoLambdaMultiplier = 0.88,
    this.stakeRegularLambdaMultiplier = 1.0,
    this.stakePlayInLambdaMultiplier = 1.0,
    this.stakePlayoffLambdaMultiplier = 1.0,
    this.stakePlayoffEliminationLambdaMultiplier = 0.95,
    this.stakeLeagueFinalLambdaMultiplier = 1.0,
    this.stoppageBase = 1,
    this.stoppageEventWeight = 0.5,
    this.stoppageRandomMin = 0.7,
    this.stoppageRandomMax = 1.3,
    this.stoppageMin = 1,
    this.stoppageMax = 8,
    this.firstHalfStoppageDivisor = 3,
    this.roleFitBonus = 1.03,
    this.leaderBonus = 1.02,
    this.cardProneTemperamental = 1.35,
    this.injuryProfessional = 0.80,
    this.aerialBase = 60,
    this.aerialSlope = 1.2,
    this.aerialClampMin = 35,
    this.aerialClampMax = 85,
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
    this.sequenceTypeBaseWeights = defaultSequenceTypeBaseWeights,
    this.stakeRegularSequenceMultiplier = 1.0,
    this.stakePlayInSequenceMultiplier = 1.02,
    this.stakePlayoffSequenceMultiplier = 1.04,
    this.stakePlayoffEliminationSequenceMultiplier = 1.08,
    this.stakeLeagueFinalSequenceMultiplier = 1.10,
    this.sequenceBaseXg = const <String, double>{
      'centralBuildUp': 0.127,
      'wingPlay': 0.121,
      'crossFromWide': 0.157,
      'throughBall': 0.149,
      'individualDribble': 0.124,
      'counterAttack': 0.167,
      'longBall': 0.135,
      'setPiece': 0.038,
    },
    this.shootingBaseline = 70.0,
    this.gkRatingBaseline = 70.0,
    this.gkRatingDivisor = 240.0,
    this.shotSavedWeight = 0.42,
    this.shotOffTargetWeight = 0.33,
    this.shotBlockedWeight = 0.20,
    this.shotPostWeight = 0.05,
    this.reboundAfterSave = 0.25,
    this.reboundAfterPost = 0.30,
    this.reboundXgMultiplier = 0.60,
    this.cornerAfterBlock = 0.35,
    this.noGkRatingMultiplier = 0.55,
    this.longBallPassThreshold = 70.0,
    this.longBallPassBase = 0.50,
    this.counterAttackQualityMultiplier = 1.35,
    this.counterAttackHighLineMultiplier = 1.15,
    this.counterAttackDeepLineMultiplier = 0.85,
    this.penaltyDuelInfluence = 0.05,
    this.cornerBaseXg = 0.035,
    this.directFreeKickBaseXg = 0.07,
    this.penaltyBaseXg = 0.76,
    this.stakeRegularPressure = 0.5,
    this.stakePlayInPressure = 1.0,
    this.stakePlayoffPressure = 1.0,
    this.stakePlayoffEliminationPressure = 1.4,
    this.stakeLeagueFinalPressure = 1.6,
    this.weatherHandlingMultipliers = const <String, double>{
      'clear': 1.0,
      'overcast': 1.0,
      'rain': 1.25,
      'heavyRain': 1.60,
      'wind': 1.30,
      'snow': 1.45,
      'heat': 1.05,
      'cold': 1.08,
    },
    this.weatherPassingMultipliers = const <String, double>{
      'clear': 1.00,
      'overcast': 1.00,
      'rain': 0.96,
      'heavyRain': 0.90,
      'wind': 0.93,
      'snow': 0.88,
      'heat': 0.98,
      'cold': 0.98,
    },
    this.weatherPaceMultipliers = const <String, double>{
      'clear': 1.00,
      'overcast': 1.00,
      'rain': 0.98,
      'heavyRain': 0.94,
      'wind': 1.00,
      'snow': 0.90,
      'heat': 0.96,
      'cold': 0.97,
    },
    this.weatherStaminaMultipliers = const <String, double>{
      'clear': 1.00,
      'overcast': 0.98,
      'rain': 1.03,
      'heavyRain': 1.08,
      'wind': 1.02,
      'snow': 1.10,
      'heat': 1.15,
      'cold': 1.04,
    },
    this.weatherXgMultipliers = const <String, double>{
      'clear': 1.00,
      'overcast': 1.00,
      'rain': 1.02,
      'heavyRain': 1.05,
      'wind': 0.97,
      'snow': 0.95,
      'heat': 0.98,
      'cold': 1.00,
    },
    this.goalkeeperProfileWeights = const <String, Map<String, double>>{
      'distance': <String, double>{
        'reflexes': 0.40,
        'positioning': 0.35,
        'diving': 0.25,
      },
      'box': <String, double>{
        'reflexes': 0.35,
        'diving': 0.35,
        'positioning': 0.30,
      },
      'header': <String, double>{
        'positioning': 0.40,
        'handling': 0.35,
        'diving': 0.25,
      },
      'oneOnOne': <String, double>{
        'positioning': 0.35,
        'speed': 0.30,
        'diving': 0.35,
      },
      'penalty': <String, double>{
        'diving': 0.35,
        'reflexes': 0.35,
        'positioning': 0.30,
      },
    },
  });

  /// Illegal roster → walkover score for the offending side.
  final double homeAdvantage;

  final double ratingUnrated;
  final double defaultPossessionPercent;
  final double runtimeFallbackChemistry;
  final int runtimeFallbackAtmosphere;

  final Map<SequenceType, Map<EffectiveAttribute, double>>
  sequenceAttackerProfiles;
  final Map<SequenceType, Map<EffectiveAttribute, double>>
  sequenceDefenderProfiles;
  final double sequenceHighUnitThreshold;
  final double sequenceHighAttributeThreshold;
  final int sequenceTallForwardHeight;
  final double sequenceFallbackAttribute;
  final double sequenceAttackerBaseWeight;
  final double sequenceDefenderBaseWeight;
  final double sequenceSetPieceAttributeDivisor;
  final double sequenceMatchingFlankWeight;
  final Map<SequenceType, Map<Position, double>>
  sequenceAttackerPositionBonuses;
  final Map<SequenceType, Map<Position, double>>
  sequenceDefenderPositionWeights;
  final double unitDefDefendingWeight;
  final double unitDefPhysicalityWeight;
  final double unitDefPaceWeight;
  final double unitDefPassingWeight;
  final double unitMidPassingWeight;
  final double unitMidDribblingWeight;
  final double unitMidDefendingWeight;
  final double unitMidPhysicalityWeight;
  final double unitAtkShootingWeight;
  final double unitAtkPaceWeight;
  final double unitAtkDribblingWeight;
  final double unitAtkPassingWeight;
  final double unitSupportingPositionWeight;
  final Map<SequenceType, List<SequenceStageProfile>> sequenceStages;
  final Map<EffectiveAttribute, double> throughBallHighLineDefenderWeights;

  final Set<String> rivalryKeys;
  final double refereeRandomMin;
  final double refereeRandomSpan;
  final double refereeMin;
  final double refereeMax;
  final double playoffRefereeMultiplier;
  final int crowdBase;
  final double crowdFormWeight;
  final int crowdDerbyBonus;
  final int crowdMin;
  final int crowdMax;
  final double crowdInitialMomentumDivisor;
  final int temperatureMin;
  final int temperatureMax;
  final int temperatureRandomRange;
  final Map<MatchStake, int> stakeCrowdBonuses;
  final Map<Weather, int> weatherBaseWeights;
  final List<WeatherSeasonProfile> weatherSeasons;

  final double duelLogisticBase;
  final int clutchMinute;
  final double shootingScale;
  final double shotXgMin;
  final double shotXgMax;
  final double goalProbabilityMin;
  final double goalProbabilityMax;
  final double reboundXgMin;
  final double reboundXgMax;
  final double bigChanceXgThreshold;
  final double fallbackGkPhysicalityWeight;
  final double fallbackGkSpeedWeight;
  final double fallbackGkDefendingWeight;
  final double handlingErrorBaseline;
  final double handlingErrorScale;
  final int scoreReactionMinute;
  final double possessionProbabilityMin;
  final double possessionProbabilityMax;
  final double momentumCutoff;
  final double momentumMin;
  final double momentumMax;
  final int firstHalfStoppageMax;
  final double unitRatingMin;
  final double unitRatingMax;
  final double cohesionMultiplierMax;
  final double ratingAssist;
  final double ratingOffensiveDuel;
  final double ratingDefensiveDuel;
  final double ratingGoalCausingLoss;
  final double ratingSave;
  final double ratingPenaltySave;
  final int cleanSheetMinutes;
  final double ratingCleanSheet;
  final double ratingOwnGoalPenalty;
  final double ratingYellowPenalty;
  final double ratingRedPenalty;
  final double ratingMissedBigChancePenalty;
  final int ratingShortAppearanceMinutes;
  final double ratingBase;
  final double ratingMin;
  final double ratingMax;
  final double ratingForwardGoal;
  final double ratingMidfielderGoal;
  final double ratingDefenderGoal;
  final double roleMismatchMultiplier;
  final double ambitiousClutchMultiplier;
  final double loyalAdverseMomentumMultiplier;
  final int weeklyThirdMatchThreshold;
  final int weeklySecondMatchThreshold;
  final double weeklyThirdMatchMultiplier;
  final double weeklySecondMatchMultiplier;
  final double chainLongBallProbabilityMin;
  final double chainLongBallProbabilityMax;
  final double chainLowQuality;
  final double chainNormalQuality;
  final double chainHighQuality;
  final double chainRepeatPlayerMultiplier;
  final double chainAllowedPositionWeight;
  final double chainOtherPositionWeight;
  final double sfgPenaltyShootingWeight;
  final int sfgAttackingPlayers;
  final int sfgDefendingOutfieldPlayers;
  final int sfgDefendingGoalkeepers;
  final int fallbackAerialHeight;

  final double effectiveAttributeMin;
  final double oneOnOneRedMultiplier;
  final double duelInjuryMultiplier;
  final double effectiveAttributeMax;
  final int walkoverGoalsFor;
  final int walkoverGoalsAgainst;

  /// Maximum number of players replaced and ordinary substitution windows.
  final int maxSubstitutions;
  final int maxSubstitutionWindows;

  /// Task 19 live-match cohesion controls. The documented `-2` tactical
  /// correction is represented as two raw cohesion points before the existing
  /// 1.01–1.05 multiplier mapping is applied.
  final double cohesionTacticsPenalty;
  final int cohesionPenaltyDurationMinutes;
  final int adaptationAppearances;
  final double adaptationPenaltyAtZero;

  /// `SHAPE_BASELINE` and `SHAPE_WEIGHT`.
  final int shapeBaseline;
  final double shapeWeight;

  /// `DUEL_DISPERSION` and `DUEL_SIGMA`.
  final int duelDispersion;
  final double duelSigma;
  final int possessionDuelDispersion;
  final double possessionDuelSigma;
  final double homeAdvantageAttackScale;
  final double homeAdvantageAwayAttackPenaltyScale;

  /// Sequence, shot and goal conversion constants.
  final double sequenceBase;
  final double sequenceToShot;
  final double shotToGoal;

  /// Foul and card probabilities.
  final double foulBase;
  final double foulCardedPlayerMultiplier;
  final double yellowFromFoul;
  final double redDirect;
  final double foulPressingLowMultiplier;
  final double foulPressingMediumMultiplier;
  final double foulPressingHighMultiplier;
  final double foulPressingGegenpressingMultiplier;
  final double physGapDivisor;
  final double derbyFoulMultiplier;

  /// Short-handed unit and stamina multipliers for the live runtime.
  final double shortHandedTenAttackMultiplier;
  final double shortHandedTenDefenseMultiplier;
  final double shortHandedNineAttackMultiplier;
  final double shortHandedNineDefenseMultiplier;
  final double shortHandedTenStaminaMultiplier;
  final double shortHandedNineStaminaMultiplier;

  /// Injury multipliers from `player_management.md` and `matchday_model.md`.
  final Map<int, double> injuryProneMultipliers;
  final double injuryIntensityFast;
  final double injuryIntensityGegenpressing;
  final double injuryIntensitySlow;
  final double injuryIntensityLowPress;
  final Map<String, double> weatherInjuryMultipliers;

  final double injuryBase;
  final double clutchWeight;
  final double momentumDecay;
  final int momentumGoal;
  final int momentumMissedBigChance;
  final int momentumSavedPenalty;
  final int momentumRedCard;
  final int momentumKeyPlayerInjury;
  final double derbyMomentumMultiplier;
  final double derbySequenceMultiplier;
  final double crowdHomeDivisor;
  final double crowdAwayDivisor;
  final double crowdRefereeDivisor;
  final int temperatureHotThreshold;
  final double temperatureHotStep;
  final int temperatureColdThreshold;
  final double temperatureColdStep;
  final double windLongBallWeightMultiplier;
  final int scoreTrailingOneAttackDelta;
  final int scoreTrailingOneDefenseDelta;
  final double scoreTrailingOneLambdaMultiplier;
  final int scoreTrailingTwoAttackDelta;
  final int scoreTrailingTwoDefenseDelta;
  final double scoreTrailingTwoLambdaMultiplier;
  final double scoreTrailingTwoLongBallMultiplier;
  final int scoreLeadingOneAttackDelta;
  final int scoreLeadingOneDefenseDelta;
  final double scoreLeadingOneLambdaMultiplier;
  final int scoreLeadingTwoAttackDelta;
  final int scoreLeadingTwoDefenseDelta;
  final double scoreLeadingTwoLambdaMultiplier;
  final double stakeRegularLambdaMultiplier;
  final double stakePlayInLambdaMultiplier;
  final double stakePlayoffLambdaMultiplier;
  final double stakePlayoffEliminationLambdaMultiplier;
  final double stakeLeagueFinalLambdaMultiplier;
  final int stoppageBase;
  final double stoppageEventWeight;
  final double stoppageRandomMin;
  final double stoppageRandomMax;
  final int stoppageMin;
  final int stoppageMax;
  final int firstHalfStoppageDivisor;

  final double roleFitBonus;
  final double leaderBonus;
  final double cardProneTemperamental;
  final double injuryProfessional;

  /// Aerial-duel and set-piece constants.
  final int aerialBase;
  final double aerialSlope;
  final int aerialClampMin;
  final int aerialClampMax;
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

  /// Task 18 ordinary-sequence xG calibration. `setPiece` is overridden by
  /// the explicit SFG base values below.
  final Map<String, double> sequenceBaseXg;
  final double shootingBaseline;
  final double gkRatingBaseline;
  final double gkRatingDivisor;
  final double shotSavedWeight;
  final double shotOffTargetWeight;
  final double shotBlockedWeight;
  final double shotPostWeight;
  final double reboundAfterSave;
  final double reboundAfterPost;
  final double reboundXgMultiplier;
  final double cornerAfterBlock;
  final double noGkRatingMultiplier;
  final double longBallPassThreshold;
  final double longBallPassBase;
  final double counterAttackQualityMultiplier;
  final double counterAttackHighLineMultiplier;
  final double counterAttackDeepLineMultiplier;
  final double penaltyDuelInfluence;
  final double cornerBaseXg;
  final double directFreeKickBaseXg;
  final double penaltyBaseXg;
  final double stakeRegularPressure;
  final double stakePlayInPressure;
  final double stakePlayoffPressure;
  final double stakePlayoffEliminationPressure;
  final double stakeLeagueFinalPressure;
  final Map<String, double> weatherHandlingMultipliers;
  final Map<String, double> weatherPassingMultipliers;
  final Map<String, double> weatherPaceMultipliers;
  final Map<String, double> weatherStaminaMultipliers;
  final Map<String, double> weatherXgMultipliers;
  final Map<String, Map<String, double>> goalkeeperProfileWeights;

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

  /// Pressing multipliers used only after a lost defensive duel (§8.1).
  double foulPressingMultiplier(PressingIntensity pressing) =>
      switch (pressing) {
        PressingIntensity.low => foulPressingLowMultiplier,
        PressingIntensity.medium => foulPressingMediumMultiplier,
        PressingIntensity.high => foulPressingHighMultiplier,
        PressingIntensity.gegenpressing => foulPressingGegenpressingMultiplier,
      };

  double physGapMultiplier({
    required double defenderPhysicality,
    required double attackerPace,
  }) => 1.0 + (defenderPhysicality - attackerPace) / physGapDivisor;

  double shortHandedAttackMultiplier(int playersOnPitch) {
    if (playersOnPitch <= 9) return shortHandedNineAttackMultiplier;
    if (playersOnPitch == 10) return shortHandedTenAttackMultiplier;
    return 1.0;
  }

  double shortHandedDefenseMultiplier(int playersOnPitch) {
    if (playersOnPitch <= 9) return shortHandedNineDefenseMultiplier;
    if (playersOnPitch == 10) return shortHandedTenDefenseMultiplier;
    return 1.0;
  }

  double shortHandedStaminaMultiplier(int playersOnPitch) {
    if (playersOnPitch <= 9) return shortHandedNineStaminaMultiplier;
    if (playersOnPitch == 10) return shortHandedTenStaminaMultiplier;
    return 1.0;
  }

  double injuryProneMultiplier(int injuryProne) {
    final key = injuryProne.clamp(1, 10).toInt();
    return injuryProneMultipliers[key] ?? 1.0;
  }

  double injuryIntensityMultiplier({
    required Tempo tempo,
    required PressingIntensity pressing,
  }) {
    final tempoMultiplier = switch (tempo) {
      Tempo.fast => injuryIntensityFast,
      Tempo.slow => injuryIntensitySlow,
      Tempo.balanced => 1.0,
    };
    final pressingMultiplier = switch (pressing) {
      PressingIntensity.gegenpressing => injuryIntensityGegenpressing,
      PressingIntensity.low => injuryIntensityLowPress,
      PressingIntensity.medium || PressingIntensity.high => 1.0,
    };
    return tempoMultiplier * pressingMultiplier;
  }

  double weatherInjuryMultiplier(Weather weather) =>
      weatherInjuryMultipliers[weather.name] ?? 1.0;

  double adaptationPenaltyForAppearances(int appearances) {
    if (adaptationAppearances <= 0 || appearances >= adaptationAppearances) {
      return 0.0;
    }
    final remaining = (adaptationAppearances - appearances).clamp(
      0,
      adaptationAppearances,
    );
    return adaptationPenaltyAtZero * remaining / adaptationAppearances;
  }

  double stakeMultiplier(MatchStake stake) => switch (stake) {
    MatchStake.regular => stakeRegularSequenceMultiplier,
    MatchStake.playIn => stakePlayInSequenceMultiplier,
    MatchStake.playoff => stakePlayoffSequenceMultiplier,
    MatchStake.playoffElimination => stakePlayoffEliminationSequenceMultiplier,
    MatchStake.leagueFinal => stakeLeagueFinalSequenceMultiplier,
  };

  double stakePressure(MatchStake stake) => switch (stake) {
    MatchStake.regular => stakeRegularPressure,
    MatchStake.playIn => stakePlayInPressure,
    MatchStake.playoff => stakePlayoffPressure,
    MatchStake.playoffElimination => stakePlayoffEliminationPressure,
    MatchStake.leagueFinal => stakeLeagueFinalPressure,
  };

  double aerialFactor(int heightCm) =>
      (aerialBase + (heightCm - 180) * aerialSlope)
          .clamp(aerialClampMin.toDouble(), aerialClampMax.toDouble())
          .toDouble();

  double weatherHandlingMultiplier(Weather weather) =>
      weatherHandlingMultipliers[weather.name] ?? 1.0;

  double weatherPassingMultiplier(Weather weather) =>
      weatherPassingMultipliers[weather.name] ?? 1.0;

  double weatherPaceMultiplier(Weather weather) =>
      weatherPaceMultipliers[weather.name] ?? 1.0;

  double weatherStaminaMultiplier(Weather weather) =>
      weatherStaminaMultipliers[weather.name] ?? 1.0;

  double weatherXgMultiplier(Weather weather) =>
      weatherXgMultipliers[weather.name] ?? 1.0;

  double temperatureStaminaMultiplier(int temperatureC) {
    final hot = (temperatureC - temperatureHotThreshold)
        .clamp(0, 100)
        .toDouble();
    final cold = (temperatureColdThreshold - temperatureC)
        .clamp(0, 100)
        .toDouble();
    return 1.0 + hot * temperatureHotStep + cold * temperatureColdStep;
  }

  double stakeLambdaMultiplier(MatchStake stake) => switch (stake) {
    MatchStake.regular => stakeRegularLambdaMultiplier,
    MatchStake.playIn => stakePlayInLambdaMultiplier,
    MatchStake.playoff => stakePlayoffLambdaMultiplier,
    MatchStake.playoffElimination => stakePlayoffEliminationLambdaMultiplier,
    MatchStake.leagueFinal => stakeLeagueFinalLambdaMultiplier,
  };

  double crowdHomeMultiplier(int crowdIntensity) =>
      1.0 + crowdIntensity / crowdHomeDivisor;

  double crowdAwayMultiplier(int crowdIntensity) =>
      1.0 - crowdIntensity / crowdAwayDivisor;

  double refereeCrowdMultiplier({
    required int crowdIntensity,
    required bool defendingHome,
  }) => defendingHome ? 1.0 : 1.0 + crowdIntensity / crowdRefereeDivisor;

  Map<String, double> goalkeeperProfileFor(String shotKind) =>
      goalkeeperProfileWeights[shotKind] ?? goalkeeperProfileWeights['box']!;

  double setPieceBaseXg(String type) => switch (type) {
    'corner' => cornerBaseXg,
    'directFreeKick' => directFreeKickBaseXg,
    'penalty' => penaltyBaseXg,
    _ => sequenceBaseXg['setPiece'] ?? shotToGoal,
  };

  double sfgMultiplier(String type, TacticsSetup tactics) {
    final setting = switch (type) {
      'corner' => tactics.cornersAttack,
      'directFreeKick' => tactics.freeKicks,
      'penalty' => tactics.penalties,
      _ => 50,
    };
    return 1.0 + (setting - 50) / 250.0;
  }

  double clutchBonus({
    required int determination,
    required MatchStake stake,
    required bool ambitious,
  }) {
    final base = (determination - 5.5) * clutchWeight * stakePressure(stake);
    return base * (ambitious ? 1.03 : 1.0);
  }

  int stoppageMinutes({
    required int goals,
    required int cards,
    required int injuries,
    required int substitutions,
    required double randomUnit,
  }) {
    final boundedRandom = randomUnit.clamp(0.0, 1.0).toDouble();
    final eventCount = goals + cards + injuries + substitutions;
    final randomMultiplier =
        stoppageRandomMin +
        (stoppageRandomMax - stoppageRandomMin) * boundedRandom;
    final raw =
        stoppageBase +
        (stoppageEventWeight * eventCount * randomMultiplier).round();
    return raw.clamp(stoppageMin, stoppageMax).toInt();
  }

  /// Documentation names for the substitution limits.
  int get subLimit => maxSubstitutions;
  int get subWindows => maxSubstitutionWindows;
}
