import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';

/// Common, deterministic rules used by player and staff negotiations.
///
/// Keeping the bands and formulas here prevents playerOfferScore and
/// staffOfferScore from drifting apart again. The only contextual difference
/// is the want/expected-salary formula implemented by each service.
class NegotiationRules {
  const NegotiationRules._();

  static const List<double> _cfoMultipliers = [
    0.95,
    1.00,
    1.01,
    1.02,
    1.04,
    1.05,
    1.07,
    1.08,
    1.10,
    1.11,
    1.13,
  ];

  static int teamStatusBonus(TeamStatus status) => switch (status) {
    TeamStatus.rebuild => -5,
    TeamStatus.retool => -3,
    TeamStatus.pretender => 0,
    TeamStatus.contender => 5,
    TeamStatus.elite => 7,
  };

  /// Returns the documented CFO multiplier. Missing/zero negotiation gives
  /// the no-CFO value of ×0.95; half-star values map to the nearest table row.
  static double cfoDiscount(double? negotiation) {
    if (negotiation == null || negotiation <= 0) return _cfoMultipliers.first;
    final index = (negotiation * 2).round().clamp(1, 10);
    return _cfoMultipliers[index];
  }

  static double salaryFit({
    required int salary,
    required int expectedSalary,
    ContractNegBalance balance = const ContractNegBalance(),
  }) {
    if (expectedSalary <= 0) return 0;
    final percentage = (salary - expectedSalary) / expectedSalary * 100.0;
    final fit = percentage >= 0
        ? balance.salaryFitBase + percentage * balance.salaryAboveBonusPerPct
        : balance.salaryFitBase + percentage * balance.salaryBelowPenaltyPerPct;
    return fit;
  }

  static double lengthFit({
    required int years,
    required int expectedLength,
    ContractNegBalance balance = const ContractNegBalance(),
  }) {
    return balance.lengthFitBase -
        (years - expectedLength).abs() * balance.lengthPenaltyPerYear;
  }

  static OfferScoreBreakdown score({
    required int salary,
    required int expectedSalary,
    required int years,
    required int expectedLength,
    required TeamStatus offeringTeamStatus,
    double? cfoNegotiation,
    ContractNegBalance balance = const ContractNegBalance(),
  }) {
    final salaryComponent = salaryFit(
      salary: salary,
      expectedSalary: expectedSalary,
      balance: balance,
    );
    final lengthComponent = lengthFit(
      years: years,
      expectedLength: expectedLength,
      balance: balance,
    );
    final teamComponent = teamStatusBonus(offeringTeamStatus).toDouble();
    final discount = cfoDiscount(cfoNegotiation);
    final total = ((salaryComponent + lengthComponent + teamComponent) *
            discount)
        .clamp(0.0, 100.0)
        .toDouble();
    return OfferScoreBreakdown(
      salaryFit: salaryComponent,
      lengthFit: lengthComponent,
      teamStatus: teamComponent,
      cfoDiscount: discount,
      score: total,
    );
  }

  /// In the mixed 55–69 band score 62 is exactly 50/50. Each point changes
  /// the Accept probability by three percentage points, i.e. six points in
  /// the two-outcome distribution.
  static double mixedAcceptProbability(
    double score, {
    ContractNegBalance balance = const ContractNegBalance(),
  }) {
    return (balance.mixedAcceptProbabilityAtMidpoint +
            (score - balance.mixedScoreMidpoint) *
                balance.mixedAcceptSlope)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static NegotiationDecision decisionForScore({
    required double score,
    required NegotiationPhase phase,
    required Random random,
    bool competingOffers = false,
    bool belowExpectation = false,
    bool forceWaiting = false,
    ContractNegBalance balance = const ContractNegBalance(),
  }) {
    if (score <= balance.hardRejectScoreMax) {
      return NegotiationDecision.hardReject;
    }
    if (score <= balance.rejectScoreMax) return NegotiationDecision.reject;
    if (score <= balance.counterScoreMax) return NegotiationDecision.counter;

    final phaseOneWaiting = phase == NegotiationPhase.freeAgencyPhaseI &&
        (competingOffers || belowExpectation || forceWaiting);
    if (score <= balance.mixedScoreMax) {
      if (phaseOneWaiting) return NegotiationDecision.waiting;
      return random.nextDouble() < mixedAcceptProbability(score, balance: balance)
          ? NegotiationDecision.accept
          : NegotiationDecision.counter;
    }
    if (phaseOneWaiting) return NegotiationDecision.waiting;
    return NegotiationDecision.accept;
  }

  static double counterHardRejectChance(
    int round, {
    ContractNegBalance balance = const ContractNegBalance(),
  }) {
    return switch (round.clamp(1, 3)) {
      1 => balance.counterHardRejectChanceFirst,
      2 => balance.counterHardRejectChanceSecond,
      _ => balance.counterHardRejectChanceThird,
    };
  }

  static double counterTargetScore(
    int round, {
    ContractNegBalance balance = const ContractNegBalance(),
  }) {
    return switch (round.clamp(1, 3)) {
      1 => balance.counterTargetScoreFirst,
      2 => balance.counterTargetScoreSecond,
      _ => balance.counterTargetScoreThird,
    };
  }
}

class OfferScoreBreakdown {
  const OfferScoreBreakdown({
    required this.salaryFit,
    required this.lengthFit,
    required this.teamStatus,
    required this.cfoDiscount,
    required this.score,
  });

  final double salaryFit;
  final double lengthFit;
  final double teamStatus;
  final double cfoDiscount;
  final double score;
}

enum NegotiationDecision { accept, hardReject, reject, waiting, counter }
