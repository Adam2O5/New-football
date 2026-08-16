import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/balance/ai_balance.dart';
import 'package:new_football/core/balance/events_balance.dart';
import 'package:new_football/core/balance/matchday_balance.dart';
import 'package:new_football/core/balance/messages_balance.dart';
import 'package:new_football/core/balance/tactics_balance.dart';
import 'package:new_football/core/balance/trade_value_balance.dart';

export 'package:new_football/core/balance/ai_balance.dart';
export 'package:new_football/core/balance/events_balance.dart';
export 'package:new_football/core/balance/matchday_balance.dart';
export 'package:new_football/core/balance/messages_balance.dart';
export 'package:new_football/core/balance/tactics_balance.dart';
export 'package:new_football/core/balance/trade_value_balance.dart';

/// Immutable game balance knobs for the simulation core.
///
/// Source of numeric defaults: project docs under `/docs`.
/// Inject via constructor / DI; override in tests with `copy`-style
/// constructors on nested groups. Not persisted — save state holds
/// runtime values (payroll, cash), not this config.
class BalanceConfig {
  const BalanceConfig({
    this.roster = const RosterBalance(),
    this.matchday = const MatchdayBalance(),
    this.player = const PlayerBalance(),
    this.salaryCap = const SalaryCapBalance(),
    this.cash = const ClubCashBalance(),
    this.staff = const StaffBalance(),
    this.draft = const DraftBalance(),
    this.awards = const AwardsBalance(),
    this.retirement = const RetirementBalance(),
    this.development = const DevelopmentBalance(),
    this.contracts = const ContractNegBalance(),
    this.calendar = const CalendarBalance(),
    this.chemistry = const ChemistryBalance(),
    this.tactics = const TacticsBalance(),
    this.tradeValue = const TradeValueBalance(),
    this.ai = const AiBalance(),
    this.messages = const MessagesBalance(),
    this.events = const EventsBalance(),
  });

  final RosterBalance roster;
  final MatchdayBalance matchday;
  final PlayerBalance player;
  final SalaryCapBalance salaryCap;
  final ClubCashBalance cash;
  final StaffBalance staff;
  final DraftBalance draft;
  final AwardsBalance awards;
  final RetirementBalance retirement;
  final DevelopmentBalance development;
  final ContractNegBalance contracts;
  final CalendarBalance calendar;
  final ChemistryBalance chemistry;
  final TacticsBalance tactics;
  final TradeValueBalance tradeValue;
  final AiBalance ai;
  final MessagesBalance messages;
  final EventsBalance events;

  static const defaults = BalanceConfig();
}

// ---------------------------------------------------------------------------
// Roster / matchday
// ---------------------------------------------------------------------------

class RosterBalance {
  const RosterBalance({
    this.minSize = 20,
    this.maxSize = 30,
    this.seedSize = 25,
    this.startingXi = 11,
    this.benchSize = 7,
  });

  final int minSize;
  final int maxSize;
  final int seedSize;
  final int startingXi;
  final int benchSize;

  int get matchdaySquadSize => startingXi + benchSize;
}

/// Stamina, fatigue and form knobs (`player_management.md`). Trade-value
/// knobs moved to `TradeValueBalance` (`trade_value_balance.dart`).
class PlayerBalance {
  const PlayerBalance({
    this.staminaMin = 0,
    this.staminaMax = 100,
    this.minutesPerMatch = 90,
    this.fatiguePerFullMatch = 15,
    this.recoveryBetweenMatches = 20,
    this.injuryDaysClampMax = 999,
    this.staminaOkThreshold = 60,
    this.staminaSoftThreshold = 40,
    this.injuryRiskOk = 1.0,
    this.injuryRiskSoft = 1.25,
    this.injuryRiskHard = 1.75,
    this.performanceOk = 1.0,
    this.performanceAtSoft = 0.90,
    this.performanceAtZero = 0.35,
    this.outfieldOverallWeights = _defaultOutfieldOverallWeights,
    this.tallestOutfieldSampleSize = 5,
  });

  final int staminaMin;
  final int staminaMax;
  final int minutesPerMatch;
  final int fatiguePerFullMatch;
  final int recoveryBetweenMatches;
  final int injuryDaysClampMax;

  /// Stamina ≥ this → no injury / performance penalty.
  final int staminaOkThreshold;

  /// Between [staminaSoftThreshold] and [staminaOkThreshold] → soft penalties.
  final int staminaSoftThreshold;

  final double injuryRiskOk;
  final double injuryRiskSoft;
  final double injuryRiskHard;

  final double performanceOk;
  final double performanceAtSoft;

  /// Drastic contribution mult when stamina hits 0.
  final double performanceAtZero;

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

  int fatigueForMinutes(int minutesPlayed) =>
      (minutesPlayed / minutesPerMatch * fatiguePerFullMatch).round();

  int clampStamina(int value) => value.clamp(staminaMin, staminaMax);

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
    if (s <= staminaMin) return performanceAtZero;
    if (s >= staminaOkThreshold) return performanceOk;
    if (s >= staminaSoftThreshold) {
      final t =
          (s - staminaSoftThreshold) /
          (staminaOkThreshold - staminaSoftThreshold);
      return performanceAtSoft + (performanceOk - performanceAtSoft) * t;
    }
    // 1 … soft-1 → interpolate zero → soft
    final t = (s - staminaMin) / (staminaSoftThreshold - staminaMin);
    return performanceAtZero + (performanceAtSoft - performanceAtZero) * t;
  }

  /// Injury chance multiplier from current stamina (`player_management.md` §6).
  double injuryRiskMult(int stamina) {
    final s = clampStamina(stamina);
    if (s >= staminaOkThreshold) return injuryRiskOk;
    if (s >= staminaSoftThreshold) return injuryRiskSoft;
    return injuryRiskHard;
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

// ---------------------------------------------------------------------------
// Finance
// ---------------------------------------------------------------------------

class SalaryCapBalance {
  const SalaryCapBalance({
    this.salaryCap = 300000000,
    this.firstApron = 340000000,
    this.secondApron = 370000000,
    this.midLevelException = 20400000,
    this.minSalary = 500000,
    this.maxSalary = 80000000,
    this.rookieBaseScale = 8000000,
    this.rookieMinSalary = 500000,
    this.rookieMaxSalary = 8000000,
    this.rookieScaleYears = 2,
    this.rookiePickDecay = 0.08,
    this.birdRightsSeasons = 3,
    this.qualifyingOfferMultiplier = 1.25,
    this.qualifyingOfferMin = 1000000,
    this.salaryMatchPct = 1.25,
    this.salaryMatchBuffer = 500000,
    this.taxToFirstApron = 1.75,
    this.taxToSecondApron = 2.25,
    this.taxAboveSecondApron = 3.0,
    this.maxPicksPerTrade = 3,
    this.maxPickYearsAhead = 7,
  });

  final int salaryCap;
  final int firstApron;
  final int secondApron;
  final int midLevelException;
  final int minSalary;
  final int maxSalary;

  final int rookieBaseScale;
  final int rookieMinSalary;
  final int rookieMaxSalary;
  final int rookieScaleYears;
  final double rookiePickDecay;

  final int birdRightsSeasons;
  final double qualifyingOfferMultiplier;
  final int qualifyingOfferMin;

  /// Incoming / outgoing salary matching above the cap (e.g. 125%).
  final double salaryMatchPct;
  final int salaryMatchBuffer;

  final double taxToFirstApron;
  final double taxToSecondApron;
  final double taxAboveSecondApron;

  final int maxPicksPerTrade;
  final int maxPickYearsAhead;

  /// Rookie scale salary for [pickSlot] (1-based).
  int rookieSalaryForPick(int pickSlot) {
    final raw = rookieBaseScale / (1 + pickSlot * rookiePickDecay);
    final rounded = raw.round();
    if (rounded < rookieMinSalary) return rookieMinSalary;
    if (rounded > rookieMaxSalary) return rookieMaxSalary;
    return rounded;
  }
}

class ClubCashBalance {
  const ClubCashBalance({
    this.startingCash = 75000000,
    this.startingCashVariance = 15000000,
    this.tvBase = 90000000,
    this.tvBonusMax = 45000000,
    this.gateSponsorMin = 25000000,
    this.gateSponsorMax = 70000000,
    this.opsFixed = 18000000,
    this.healthyCashFloor = 20000000,
  });

  final int startingCash;
  final int startingCashVariance;
  final int tvBase;
  final int tvBonusMax;
  final int gateSponsorMin;
  final int gateSponsorMax;
  final int opsFixed;

  /// Below this → board warning / atmosphere drain.
  final int healthyCashFloor;
}

// ---------------------------------------------------------------------------
// Staff
// ---------------------------------------------------------------------------

class StaffBalance {
  const StaffBalance({
    this.salaryCap = 12000000,
    this.roleSlots = 6,
    this.starMin = 0.0,
    this.starMax = 5.0,
    this.starStep = 0.5,
    this.maxWatchedBase = 4,
    this.maxWatchedPerCoverageStar = 4,
    this.combineAssignCoverageFraction = 0.5,
    this.youthCoachMaxAge = 23,
    this.growthAgeMin = 35,
    this.growthAgeMax = 45,
    this.retireAgeMin = 55,
    this.retireAgeHardCap = 60,
    this.salaryMarketBand = 4200000,
    this.roleSalaryWeight = const <StaffRole, double>{
      StaffRole.headCoach: 1.0,
      StaffRole.youthCoach: 0.55,
      StaffRole.scout: 0.55,
      StaffRole.doctor: 0.55,
      StaffRole.physio: 0.4,
      StaffRole.cfo: 0.25,
    },
    this.growthAgeMinChance = 0.22,
    this.growthAgeMaxChance = 0.14,
    this.retireChanceByAge = const <int, double>{
      55: 0.12,
      56: 0.22,
      57: 0.38,
      58: 0.55,
      59: 0.75,
      60: 1.0,
    },
  });

  final int salaryCap;
  final int roleSlots;
  final double starMin;
  final double starMax;
  final double starStep;

  final int maxWatchedBase;
  final int maxWatchedPerCoverageStar;

  /// Combine focus slots ≈ this × Coverage (stars), floored, min 1.
  final double combineAssignCoverageFraction;

  final int youthCoachMaxAge;
  final int growthAgeMin;
  final int growthAgeMax;
  final int retireAgeMin;
  final int retireAgeHardCap;

  /// Reference salary (€) for an elite (5★) Head Coach; other roles/stars
  /// scale off this via [roleSalaryWeight] (`docs/staff_rules.md` §3).
  final int salaryMarketBand;
  final Map<StaffRole, double> roleSalaryWeight;

  /// Base P(growth roll succeeds) at [growthAgeMin] / [growthAgeMax]
  /// (`docs/staff_rules.md` §6), linearly interpolated between.
  final double growthAgeMinChance;
  final double growthAgeMaxChance;

  /// Base P(retire) by age, 55–60 (`docs/staff_rules.md` §7).
  final Map<int, double> retireChanceByAge;

  int maxWatched(double coverageStars) =>
      (maxWatchedBase + coverageStars * maxWatchedPerCoverageStar).round();

  int combineAssignLimit(double coverageStars) {
    if (coverageStars < 1) return 0;
    final raw = (coverageStars * combineAssignCoverageFraction).floor();
    return raw < 1 ? 1 : raw;
  }

  double salaryFor(StaffRole role, double avgStars) {
    final weight = roleSalaryWeight[role] ?? 0.5;
    final norm = (avgStars / starMax).clamp(0.0, 1.0);
    return weight * (0.4 + 0.6 * norm) * salaryMarketBand;
  }

  double growthChanceForAge(int age) {
    if (age < growthAgeMin || age > growthAgeMax) return 0;
    final span = (growthAgeMax - growthAgeMin).clamp(1, 1000);
    final t = (age - growthAgeMin) / span;
    return growthAgeMinChance + (growthAgeMaxChance - growthAgeMinChance) * t;
  }

  double retireChanceForAge(int age) {
    if (age < retireAgeMin) return 0;
    return retireChanceByAge[age] ?? (age >= retireAgeHardCap ? 1.0 : 0.0);
  }
}

// ---------------------------------------------------------------------------
// Draft / awards / career
// ---------------------------------------------------------------------------

class DraftBalance {
  const DraftBalance({
    this.classSize = 120,
    this.rounds = 3,
    this.teams = 30,
    this.lotteryTeams = 10,
    this.prospectAgeMin = 18,
    this.prospectAgeMax = 20,
    this.mockEarlyNoiseMin = 10,
    this.mockEarlyNoiseMax = 15,
    this.mockMidNoiseMin = 15,
    this.mockMidNoiseMax = 22,
    this.mockLateNoiseMin = 25,
    this.mockLateNoiseMax = 30,
    this.mockFinalEarlyNoiseMin = 8,
    this.mockFinalEarlyNoiseMax = 12,
    this.mockFinalMidNoiseMin = 12,
    this.mockFinalMidNoiseMax = 18,
    this.mockFinalLateNoiseMin = 18,
    this.mockFinalLateNoiseMax = 25,
  });

  final int classSize;
  final int rounds;
  final int teams;
  final int lotteryTeams;
  final int prospectAgeMin;
  final int prospectAgeMax;

  final int mockEarlyNoiseMin;
  final int mockEarlyNoiseMax;
  final int mockMidNoiseMin;
  final int mockMidNoiseMax;
  final int mockLateNoiseMin;
  final int mockLateNoiseMax;

  final int mockFinalEarlyNoiseMin;
  final int mockFinalEarlyNoiseMax;
  final int mockFinalMidNoiseMin;
  final int mockFinalMidNoiseMax;
  final int mockFinalLateNoiseMin;
  final int mockFinalLateNoiseMax;

  int get picksPerDraft => teams * rounds;

  /// Lottery weights for ranks 1–10 among lottery teams (worst first).
  static const lotteryWeights = <int>[
    140,
    140,
    140,
    125,
    105,
    90,
    75,
    60,
    45,
    30,
  ];
}

class AwardsBalance {
  const AwardsBalance({
    this.regularSeasonGames = 58,
    this.minutesPerGame = 90,
    this.mvpMinutesPct = 0.40,
    this.dpoyMinutesPct = 0.40,
    this.bestGkMinutesPct = 0.40,
    this.scoringTitleMinutesPct = 0.30,
    this.assistTitleMinutesPct = 0.30,
    this.totsSlotMinutesPct = 0.30,
    this.rotyMinutesPct = 0.25,
  });

  final int regularSeasonGames;
  final int minutesPerGame;
  final double mvpMinutesPct;
  final double dpoyMinutesPct;
  final double bestGkMinutesPct;
  final double scoringTitleMinutesPct;
  final double assistTitleMinutesPct;
  final double totsSlotMinutesPct;
  final double rotyMinutesPct;

  int get possibleMinutes => regularSeasonGames * minutesPerGame;
}

class RetirementBalance {
  const RetirementBalance({
    this.minAge = 33,

    /// Age → base retirement chance (0–1). Ages below [minAge] use 0.
    this.baseChanceByAge = const <int, double>{
      33: 0.03,
      34: 0.08,
      35: 0.18,
      36: 0.32,
      37: 0.55,
      38: 0.78,
      39: 0.95,
    },
    this.age39PlusChance = 0.95,
  });

  final int minAge;
  final Map<int, double> baseChanceByAge;
  final double age39PlusChance;

  double baseChanceForAge(int age) {
    if (age < minAge) return 0;
    return baseChanceByAge[age] ?? age39PlusChance;
  }
}

class DevelopmentBalance {
  const DevelopmentBalance({
    this.growthRateBase = 1.0,
    this.growthRateMin = 0.0,
    this.growthRateMax = 2.0,
    this.plateauAgeMin = 27,
    this.plateauAgeMax = 32,
    this.plateauGrowthMult = 0.35,
    this.declineAgeMin = 33,
    this.developmentAgeMax = 26,
    this.determinationOutcomeTable = const [
      (1, 20),
      (2, 28),
      (4, 36),
      (7, 43),
      (10, 50),
      (14, 54),
      (18, 57),
      (23, 57),
      (28, 57),
      (35, 55),
    ],
  });

  final double growthRateBase;
  final double growthRateMin;
  final double growthRateMax;
  final int plateauAgeMin;
  final int plateauAgeMax;
  final double plateauGrowthMult;
  final int declineAgeMin;
  final int developmentAgeMax;

  /// Index 0 = determination 1 … 9 = determination 10.
  /// Each entry: `(exceed%, hit%)`; under% = `100 − exceed − hit`.
  final List<(int exceed, int hit)> determinationOutcomeTable;

  (int exceed, int hit) outcomeChancesFor(int determination) {
    final d = determination.clamp(1, determinationOutcomeTable.length);
    return determinationOutcomeTable[d - 1];
  }
}

// ---------------------------------------------------------------------------
// Contracts / calendar / chemistry
// ---------------------------------------------------------------------------

class ContractNegBalance {
  const ContractNegBalance({
    this.hoursPerDay = 10,
    this.offersPerHour = 1,
    this.playerAcceptGap = 6,
    this.playerHardRejectGap = -14,
    this.playerNoiseAbs = 3,
    this.playerTemperamentalNoiseAbs = 5,
    this.staffAcceptGap = 5,
    this.staffHardRejectGap = -12,
    this.staffNoiseAbs = 2,
    this.playerWaitingHours = 3,
    this.staffWaitingHours = 2,
  });

  final int hoursPerDay;
  final int offersPerHour;
  final int playerAcceptGap;
  final int playerHardRejectGap;
  final int playerNoiseAbs;
  final int playerTemperamentalNoiseAbs;
  final int staffAcceptGap;
  final int staffHardRejectGap;
  final int staffNoiseAbs;
  final int playerWaitingHours;
  final int staffWaitingHours;
}

class CalendarBalance {
  const CalendarBalance({
    this.regularSeasonWeeks = 29,
    this.tradeDeadlineWeek = 23,
    this.playInWeek = 31,
    this.playoffStartWeek = 32,
    this.playoffEndWeek = 43,
    this.awardsWeek = 44,
    this.draftWeek = 46,
    this.freeAgencyWeek = 47,
    this.tradeWindowOpenWeek = 44,
  });

  final int regularSeasonWeeks;
  final int tradeDeadlineWeek;
  final int playInWeek;
  final int playoffStartWeek;
  final int playoffEndWeek;
  final int awardsWeek;
  final int draftWeek;
  final int freeAgencyWeek;

  /// First week of open trade window after playoffs.
  final int tradeWindowOpenWeek;
}

class ChemistryBalance {
  const ChemistryBalance({
    this.multMin = 0.92,
    this.multMax = 1.08,
    this.roleMultOkMin = 1.05,
    this.roleMultOkMax = 1.12,
    this.roleMultFailMin = 0.80,
    this.roleMultFailMax = 0.90,
    this.formationMatchupClamp = 0.15,
  });

  final double multMin;
  final double multMax;
  final double roleMultOkMin;
  final double roleMultOkMax;
  final double roleMultFailMin;
  final double roleMultFailMax;
  final double formationMatchupClamp;
}
