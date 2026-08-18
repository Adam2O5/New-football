import 'dart:math';

import 'package:new_football/core/ai/ai_draft_models.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/ai/ai_evaluation_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';

/// Stateless AI policy for draft boards, scout assignments and rookie rights.
///
/// This class only produces decisions and plans. DraftState, Team and
/// ContractMarketService mutations remain in their existing owners.
class AiDraftService {
  AiDraftService({
    this.balance = BalanceConfig.defaults,
    AiEvaluationService? evaluator,
  }) : evaluator = evaluator ?? AiEvaluationService(balance: balance);

  final BalanceConfig balance;
  final AiEvaluationService evaluator;

  /// Assigns an AI scout using the documented 70% mock / 30% need split.
  /// A team without a scout deliberately receives no watchlist.
  TeamScouting assignWatchlist({
    required Team team,
    required DraftClass draftClass,
    LeagueState? league,
    int saveSeed = 0,
    int? seasonYear,
    int week = 46,
  }) {
    final scout = team.staff.scout;
    if (scout == null) return const TeamScouting();

    final year = seasonYear ?? league?.currentSeason.year ?? draftClass.year;
    final ranked = [...draftClass.prospects]
      ..sort((a, b) {
        final grade = b.scoutGrade.compareTo(a.scoutGrade);
        return grade != 0 ? grade : a.id.compareTo(b.id);
      });
    final limit =
        (balance.staff.maxWatched(scout.attributes.coverage) *
                balance.ai.scoutCoverageUsage)
            .round()
            .clamp(0, ranked.length);
    if (limit == 0) return const TeamScouting();

    final context = evaluator.contextForTeam(
      team: team,
      league: league,
      saveSeed: saveSeed,
      seasonYear: year,
      week: week,
      decisionType: DecisionType.scoutAssign,
    );
    final rankById = {
      for (var i = 0; i < ranked.length; i++) ranked[i].id: i + 1,
    };
    final tieSeed = aiSeed(
      saveSeed,
      year,
      week,
      team.id,
      DecisionType.scoutAssign,
    );
    int tieFor(String id) => teamEventSeed(
      tieSeed,
      year,
      week,
      team.id,
      'scout-assign-tie',
      playerId: id,
    );

    final needRanked = [...ranked]
      ..sort((a, b) {
        final aNeed =
            evaluator.needForPosition(context, a.position)?.needScore ?? 0;
        final bNeed =
            evaluator.needForPosition(context, b.position)?.needScore ?? 0;
        final need = bNeed.compareTo(aNeed);
        if (need != 0) return need;
        final rank = (rankById[a.id] ?? 0).compareTo(rankById[b.id] ?? 0);
        return rank != 0 ? rank : tieFor(a.id).compareTo(tieFor(b.id));
      });

    final mockTarget = (limit * balance.ai.scoutMockRankShare).round();
    final needTarget = limit - mockTarget;
    final selected = <String>[];
    final selectedIds = <String>{};

    void add(Prospect prospect) {
      if (selected.length >= limit || !selectedIds.add(prospect.id)) return;
      selected.add(prospect.id);
    }

    for (final prospect in ranked.take(mockTarget)) {
      add(prospect);
    }
    for (final prospect in needRanked.take(needTarget)) {
      add(prospect);
    }
    for (final prospect in ranked) {
      add(prospect);
    }
    for (final prospect in needRanked) {
      add(prospect);
    }

    final previous = team.scouting.forProspect;
    final knowledge = [
      for (final id in selected)
        previous(id) ?? ScoutingKnowledge(prospectId: id),
    ];
    return team.scouting.copyWith(
      watchlistProspectIds: selected,
      knowledge: knowledge,
      combineAssignedProspectIds: const [],
      mockRanks: {
        ...team.scouting.mockRanks,
        for (final entry in rankById.entries) entry.key: entry.value,
      },
    );
  }

  /// Builds a board from public mock ranks and the team's scouting snapshot.
  /// Hidden Prospect fields are never read here.
  List<AiProspectBoardEntry> buildBoard({
    required Team team,
    required List<Prospect> prospects,
    List<Prospect>? mockRankedProspects,
    int pickNumber = 1,
    Set<String> unavailableProspectIds = const {},
    LeagueState? league,
    int saveSeed = 0,
    int? seasonYear,
    int week = 46,
  }) {
    final ranked = mockRankedProspects == null
        ? ([...prospects]..sort((a, b) {
            final grade = b.scoutGrade.compareTo(a.scoutGrade);
            return grade != 0 ? grade : a.id.compareTo(b.id);
          }))
        : [...mockRankedProspects];
    final rankById = {
      for (var i = 0; i < ranked.length; i++) ranked[i].id: i + 1,
    };
    final year = seasonYear ?? league?.currentSeason.year ?? 0;
    final context = evaluator.contextForTeam(
      team: team,
      league: league,
      saveSeed: saveSeed,
      seasonYear: year,
      week: week,
      decisionType: DecisionType.draftPick,
    );
    final entries = <AiProspectBoardEntry>[];

    for (final prospect in prospects) {
      if (unavailableProspectIds.contains(prospect.id)) continue;
      final knowledge = team.scouting.forProspect(prospect.id);
      final hasScout = team.staff.scout != null;
      final mockRank =
          team.scouting.mockRanks[prospect.id] ??
          rankById[prospect.id] ??
          ranked.length;
      final tier = knowledge?.tier ?? ScoutingTier.tier1;
      final hasOvrEstimate =
          knowledge?.estimatedOvrMin != null &&
          knowledge?.estimatedOvrMax != null &&
          tier.index >= ScoutingTier.tier2.index;
      final hasPotentialEstimate =
          knowledge?.estimatedPotentialMin != null &&
          knowledge?.estimatedPotentialMax != null &&
          tier.index >= ScoutingTier.tier4.index;

      final perceivedRank = hasOvrEstimate
          ? mockRank
          : _noisyRank(
              mockRank,
              ranked.length,
              hasScout
                  ? balance.ai.scoutKnownNoiseRank
                  : balance.ai.scoutNoScoutNoiseRank,
              saveSeed: saveSeed,
              seasonYear: year,
              week: week,
              teamId: team.id,
              prospectId: prospect.id,
            );
      final estimatedOvr = hasOvrEstimate
          ? (knowledge!.estimatedOvrMin! + knowledge.estimatedOvrMax!) / 2.0
          : _proxyOverall(perceivedRank, ranked.length);
      final estimatedPotential = hasPotentialEstimate
          ? (knowledge!.estimatedPotentialMin! +
                    knowledge.estimatedPotentialMax!) /
                2.0
          : _proxyPotential(perceivedRank, ranked.length);

      final need = evaluator.needForPosition(context, prospect.position);
      final needBonus = _needBonus(need, team, prospect.position, pickNumber);
      final noise =
          _gaussian(
            Random(
              teamEventSeed(
                saveSeed,
                year,
                week,
                team.id,
                'draft-score-noise',
                playerId: prospect.id,
                salt: pickNumber,
              ),
            ),
          ) *
          balance.ai.draftScoreNoiseSd;
      final score =
          0.55 * estimatedOvr +
          0.45 * (estimatedPotential * 12.0) +
          needBonus +
          noise;
      entries.add(
        AiProspectBoardEntry(
          prospect: prospect,
          mockRank: mockRank,
          perceivedMockRank: perceivedRank,
          estimatedOvrMid: estimatedOvr,
          estimatedPotentialStars: estimatedPotential,
          needBonus: needBonus,
          noise: noise,
          score: score,
          tier: tier,
        ),
      );
    }

    entries.sort((a, b) {
      final score = b.score.compareTo(a.score);
      if (score != 0) return score;
      final rank = a.mockRank.compareTo(b.mockRank);
      return rank != 0 ? rank : a.prospect.id.compareTo(b.prospect.id);
    });
    return List.unmodifiable(entries);
  }

  /// Chooses a pick, trade-up or trade-down proposal. The returned trade
  /// action is a plan only; DraftService must validate and execute it.
  AiDraftDecision decidePick({
    required Team team,
    required List<Prospect> prospects,
    List<Prospect>? mockRankedProspects,
    int pickNumber = 1,
    int currentPickIndex = 0,
    List<DraftPick> draftOrder = const [],
    Set<String> unavailableProspectIds = const {},
    LeagueState? league,
    int saveSeed = 0,
    int? seasonYear,
    int week = 46,
    double? slotThreshold,
  }) {
    final board = buildBoard(
      team: team,
      prospects: prospects,
      mockRankedProspects: mockRankedProspects,
      pickNumber: pickNumber,
      unavailableProspectIds: unavailableProspectIds,
      league: league,
      saveSeed: saveSeed,
      seasonYear: seasonYear,
      week: week,
    );
    final year = seasonYear ?? league?.currentSeason.year ?? 0;
    final upRoll = Random(
      aiSeed(saveSeed, year, week, team.id, DecisionType.draftPick),
    ).nextDouble();
    final topTarget = board
        .take(5)
        .cast<AiProspectBoardEntry?>()
        .firstWhere(
          (entry) => entry!.mockRank >= pickNumber + 4,
          orElse: () => null,
        );
    if (topTarget != null && upRoll < balance.ai.pDraftTradeUp) {
      final targetIndex = draftOrder.isEmpty
          ? null
          : min(currentPickIndex + 4, draftOrder.length - 1);
      return AiDraftDecision(
        action: AiDraftAction.tradeUp,
        board: board,
        selection: topTarget,
        targetPickIndex: targetIndex,
        probability: balance.ai.pDraftTradeUp,
        surplusPct: balance.ai.draftTradeUpSurplusPct,
      );
    }

    final threshold = slotThreshold ?? _slotThreshold(pickNumber);
    final weakSlot = board.isEmpty || board.first.score <= threshold;
    final downRoll = Random(
      teamEventSeed(
        saveSeed,
        year,
        week,
        team.id,
        'draft-trade-down',
        salt: pickNumber,
      ),
    ).nextDouble();
    if (weakSlot && downRoll < balance.ai.pDraftTradeDown) {
      return AiDraftDecision(
        action: AiDraftAction.tradeDown,
        board: board,
        selection: board.isEmpty ? null : board.first,
        probability: balance.ai.pDraftTradeDown,
      );
    }
    return AiDraftDecision(
      action: AiDraftAction.pick,
      board: board,
      selection: board.isEmpty ? null : board.first,
    );
  }

  AiDraftSigningDecision draftedSigningDecision({
    required Team team,
    required int round,
    required String prospectId,
    double needScore = 0.0,
    int saveSeed = 0,
    int seasonYear = 0,
    int week = 46,
  }) {
    final probability = switch (round) {
      1 when team.roster.length < 30 => balance.ai.draftR1SigningProbability,
      2 when team.roster.length < 29 => balance.ai.draftR2SigningProbability,
      3 when team.roster.length < 28 && needScore > 0 =>
        balance.ai.draftR3SigningProbability,
      _ => 0.0,
    };
    final sign =
        probability > 0 &&
        _roll(
          saveSeed: saveSeed,
          seasonYear: seasonYear,
          week: week,
          teamId: team.id,
          kind: 'draft-sign',
          subjectId: prospectId,
          probability: probability,
        );
    return AiDraftSigningDecision(
      sign: sign,
      probability: probability,
      reason: sign ? 'draft-round-policy' : 'rights-retained',
    );
  }

  AiDraftSigningDecision deferredRightsSigningDecision({
    required Team team,
    required String prospectId,
    int saveSeed = 0,
    int seasonYear = 0,
    int week = 47,
  }) {
    final probability = team.roster.length < 30
        ? balance.ai.draftDeferredSigningProbability
        : 0.0;
    final sign =
        probability > 0 &&
        _roll(
          saveSeed: saveSeed,
          seasonYear: seasonYear,
          week: week,
          teamId: team.id,
          kind: 'draft-deferred-sign',
          subjectId: prospectId,
          probability: probability,
        );
    return AiDraftSigningDecision(
      sign: sign,
      probability: probability,
      reason: sign ? 'deferred-rights-window' : 'rights-retained',
    );
  }

  AiUndraftedSigningDecision undraftedSigningDecision({
    required Team team,
    required String prospectId,
    required AiNeedBand needBand,
    int saveSeed = 0,
    int seasonYear = 0,
    int week = 47,
  }) {
    final probability = team.roster.length < 20
        ? balance.ai.draftUndraftedUnderRosterProbability
        : needBand == AiNeedBand.critical && team.roster.length < 26
        ? balance.ai.draftUndraftedCriticalProbability
        : needBand == AiNeedBand.belowTarget && team.roster.length < 24
        ? balance.ai.draftUndraftedBelowTargetProbability
        : balance.ai.draftUndraftedDefaultProbability;
    return AiUndraftedSigningDecision(
      offer: _roll(
        saveSeed: saveSeed,
        seasonYear: seasonYear,
        week: week,
        teamId: team.id,
        kind: 'undrafted-offer',
        subjectId: prospectId,
        probability: probability,
      ),
      probability: probability,
      reason: team.roster.length < 20 ? 'roster-repair' : needBand.name,
    );
  }

  double _needBonus(
    AiPositionNeed? need,
    Team team,
    Position position,
    int pickNumber,
  ) {
    if (position == Position.gk &&
        pickNumber > 45 &&
        team.roster.where((p) => p.position == Position.gk).length < 2) {
      return 20.0;
    }
    return switch (need?.band) {
      AiNeedBand.critical => 8.0,
      AiNeedBand.belowTarget => 4.0,
      AiNeedBand.target => 0.0,
      AiNeedBand.surplus => -6.0,
      null => 0.0,
    };
  }

  int _noisyRank(
    int rank,
    int length,
    int range, {
    required int saveSeed,
    required int seasonYear,
    required int week,
    required String teamId,
    required String prospectId,
  }) {
    final random = Random(
      teamEventSeed(
        saveSeed,
        seasonYear,
        week,
        teamId,
        'draft-rank-proxy',
        playerId: prospectId,
      ),
    );
    final noise = random.nextInt(range * 2 + 1) - range;
    return (rank + noise).clamp(1, max(1, length));
  }

  double _proxyOverall(int rank, int length) {
    final t = length <= 1 ? 0.0 : (rank - 1) / (length - 1);
    return (95.0 - t * 45.0).clamp(50.0, 95.0);
  }

  double _proxyPotential(int rank, int length) {
    final t = length <= 1 ? 0.0 : (rank - 1) / (length - 1);
    return (5.0 - t * 4.5).clamp(0.5, 5.0);
  }

  double _slotThreshold(int pickNumber) =>
      (84.0 - max(0, pickNumber - 1) * 0.45).clamp(40.0, 84.0);

  bool _roll({
    required int saveSeed,
    required int seasonYear,
    required int week,
    required String teamId,
    required String kind,
    required String subjectId,
    required double probability,
  }) {
    if (probability >= 1.0) return true;
    if (probability <= 0.0) return false;
    return Random(
          teamEventSeed(
            saveSeed,
            seasonYear,
            week,
            teamId,
            kind,
            playerId: subjectId,
          ),
        ).nextDouble() <
        probability;
  }

  double _gaussian(Random random) {
    final u1 = max(random.nextDouble(), 1e-12);
    final u2 = random.nextDouble();
    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }
}
