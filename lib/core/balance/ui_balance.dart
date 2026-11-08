import 'package:new_football/core/models/enums.dart';

/// Semantic presentation thresholds; geometry and animation stay in app.
class UiBalance {
  const UiBalance({
    this.matchEventPriorities = const {
      MatchEventType.goal: 100,
      MatchEventType.scoredPenalty: 100,
      MatchEventType.redCard: 90,
      MatchEventType.majorInjury: 85,
      MatchEventType.minorInjury: 75,
      MatchEventType.halfTime: 70,
      MatchEventType.fullTime: 70,
      MatchEventType.yellowCard: 60,
      MatchEventType.substitution: 40,
      MatchEventType.foul: 20,
      MatchEventType.missedPenalty: 80,
    },
    this.eventErrorPriorityMin = 90,
    this.eventOrangePriorityMin = 70,
    this.eventAmberPriorityMin = 50,

    this.visibleSubstituteCandidateLimit = 10,

    this.lowStaminaWarning = 35,
    this.formDisplayMin = 0.0,
    this.formDisplayMax = 10.0,
    this.freeAgencyOvrOptions = const [0, 60, 70, 80, 90],
    this.playerFilterAgeMin = 15,
    this.playerFilterAgeMax = 45,
    this.prospectFilterAgeMin = 16,
    this.prospectFilterAgeMax = 25,
    this.filterOvrMin = 50,
    this.filterOvrMax = 99,
    this.filterPotentialMin = 0.0,
    this.filterPotentialMax = 5.0,
    this.filterPotentialStep = 0.5,
    this.filterSalaryMin = 0.0,
    this.filterSalaryMax = 60000000.0,
    this.filterSalaryStep = 1000000.0,
    this.filterContractYearsMin = 0,
    this.filterContractYearsMax = 6,
    this.pickFilterFallbackYears = 3,
    this.youngRankingAgeMin = 18,
    this.youngRankingAgeMax = 21,
    this.rankingPlayerLimit = 30,
    this.statsLeaderLimit = 15,
    this.contractFreeAgentLimit = 30,
    this.defaultPlayerOfferYears = 3,
    this.defaultStaffOfferYears = 3,
    this.expiringContractMaxYears = 1,
    this.developingPotentialMaxAge = 26,
    this.matchEventListLimit = 35,
  });

  final Map<MatchEventType, int> matchEventPriorities;
  final int eventErrorPriorityMin;
  final int eventOrangePriorityMin;
  final int eventAmberPriorityMin;

  final int visibleSubstituteCandidateLimit;

  final int lowStaminaWarning;
  final double formDisplayMin;
  final double formDisplayMax;
  final List<int> freeAgencyOvrOptions;
  final int playerFilterAgeMin;
  final int playerFilterAgeMax;
  final int prospectFilterAgeMin;
  final int prospectFilterAgeMax;
  final int filterOvrMin;
  final int filterOvrMax;
  final double filterPotentialMin;
  final double filterPotentialMax;
  final double filterPotentialStep;
  final double filterSalaryMin;
  final double filterSalaryMax;
  final double filterSalaryStep;
  final int filterContractYearsMin;
  final int filterContractYearsMax;
  final int pickFilterFallbackYears;
  final int youngRankingAgeMin;
  final int youngRankingAgeMax;
  final int rankingPlayerLimit;
  final int statsLeaderLimit;
  final int contractFreeAgentLimit;
  final int defaultPlayerOfferYears;
  final int defaultStaffOfferYears;
  final int expiringContractMaxYears;
  final int developingPotentialMaxAge;
  final int matchEventListLimit;
}
