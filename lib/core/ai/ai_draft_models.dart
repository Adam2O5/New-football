import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';

/// Action selected by the draft policy before a legal draft mutation runs.
enum AiDraftAction { pick, tradeUp, tradeDown }

/// One prospect as seen by an AI club's information-limited draft board.
///
/// The model intentionally contains only estimates and proxy values. It does
/// not expose the prospect's hidden development fields to policy consumers.
class AiProspectBoardEntry {
  const AiProspectBoardEntry({
    required this.prospect,
    required this.mockRank,
    required this.perceivedMockRank,
    required this.estimatedOvrMid,
    required this.estimatedPotentialStars,
    required this.needBonus,
    required this.noise,
    required this.score,
    required this.tier,
  });

  final Prospect prospect;
  final int mockRank;
  final int perceivedMockRank;
  final double estimatedOvrMid;
  final double estimatedPotentialStars;
  final double needBonus;
  final double noise;
  final double score;
  final ScoutingTier tier;
}

/// Planned AI draft action. DraftService/SeasonService remain responsible for
/// checking ownership and mutating DraftState.
class AiDraftDecision {
  const AiDraftDecision({
    required this.action,
    required this.board,
    this.selection,
    this.targetPickIndex,
    this.probability = 0.0,
    this.surplusPct = 0.0,
  });

  final AiDraftAction action;
  final List<AiProspectBoardEntry> board;
  final AiProspectBoardEntry? selection;
  final int? targetPickIndex;
  final double probability;
  final double surplusPct;
}

/// Result of an AI decision to sign a drafted player or retain the rights.
class AiDraftSigningDecision {
  const AiDraftSigningDecision({
    required this.sign,
    required this.probability,
    required this.reason,
  });

  final bool sign;
  final double probability;
  final String reason;
}

/// Result of the undrafted-player policy. The offer shape is fixed by the
/// draft rules; only the decision probability is stochastic.
class AiUndraftedSigningDecision {
  const AiUndraftedSigningDecision({
    required this.offer,
    required this.probability,
    required this.reason,
  });

  final bool offer;
  final double probability;
  final String reason;

  int get salary => 1000000;
  int get years => 2;
}
