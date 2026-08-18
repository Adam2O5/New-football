import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/trade_service.dart';

/// The four reactions available to an AI trade decision.
enum AiTradeAction { accept, counter, reject, hardReject }

/// Explainable result of evaluating one offer from one club's perspective.
///
/// This is a runtime model only. It is deliberately not persisted; the
/// persisted offer/history remains the source of truth for the negotiation
/// lifecycle.
class AiTradeDecision {
  const AiTradeDecision({
    required this.action,
    required this.surplusPct,
    required this.rawSurplusPct,
    required this.thresholdShiftPp,
    required this.evaluation,
    this.acceptProbability = 0.0,
    this.counterProbability = 0.0,
    this.rejectProbability = 0.0,
    this.hardRejectProbability = 0.0,
    this.counterTargetPct,
    this.contractDump = false,
    this.reason,
  });

  final AiTradeAction action;
  final double surplusPct;
  final double rawSurplusPct;
  final double thresholdShiftPp;
  final AiPackageEvaluation evaluation;
  final double acceptProbability;
  final double counterProbability;
  final double rejectProbability;
  final double hardRejectProbability;
  final double? counterTargetPct;
  final bool contractDump;
  final String? reason;

  bool get accepted => action == AiTradeAction.accept;
  bool get isCounter => action == AiTradeAction.counter;
  bool get rejected =>
      action == AiTradeAction.reject || action == AiTradeAction.hardReject;
  bool get hardRejected => action == AiTradeAction.hardReject;
}

/// A legal (or previewed) package considered for a pair of teams.
class AiTradePackage {
  const AiTradePackage({
    required this.proposal,
    required this.teamAEvaluation,
    required this.teamBEvaluation,
    this.packageIndex = 0,
    this.validation,
    this.contractDump = false,
    this.buyerAcceptsContract = false,
  });

  final TradeProposal proposal;
  final AiPackageEvaluation teamAEvaluation;
  final AiPackageEvaluation teamBEvaluation;
  final int packageIndex;
  final TradeValidation? validation;
  final bool contractDump;
  final bool buyerAcceptsContract;

  bool get isMutuallyBeneficial =>
      (teamAEvaluation.surplusPct >= 2.0 &&
          teamBEvaluation.surplusPct >= 2.0) ||
      (contractDump && buyerAcceptsContract);
}

/// A deterministic pair sampled by the weekly AI↔AI market.
class AiTradeCandidate {
  const AiTradeCandidate({
    required this.teamAId,
    required this.teamBId,
    required this.appetiteA,
    required this.appetiteB,
    this.packages = const [],
  });

  final String teamAId;
  final String teamBId;
  final double appetiteA;
  final double appetiteB;
  final List<AiTradePackage> packages;
}

/// The four appetite terms from `AI_behaviour.md` §5.5.
class AiTradeAppetite {
  const AiTradeAppetite({
    required this.maxNeedScore,
    required this.surplusPositionPressure,
    required this.deadlineProximity,
    required this.injuryPressure,
    required this.value,
  });

  final double maxNeedScore;
  final double surplusPositionPressure;
  final double deadlineProximity;
  final double injuryPressure;
  final double value;
}

/// Result of one headless weekly AI trade tick.
class AiTradeWeeklyResult {
  const AiTradeWeeklyResult({
    required this.league,
    this.candidatePairs = 0,
    this.testedPackages = 0,
    this.executedAiTrades = 0,
    this.createdPlayerOffers = 0,
    this.rejectedCandidates = 0,
    this.changed = false,
  });

  final LeagueState league;
  final int candidatePairs;
  final int testedPackages;
  final int executedAiTrades;
  final int createdPlayerOffers;
  final int rejectedCandidates;
  final bool changed;
}
