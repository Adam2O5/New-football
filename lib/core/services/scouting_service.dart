import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/random/seeds.dart';

/// Fog-of-war scouting: watchlists, tier progress, reports, Combine and mocks.
///
/// The service can use the legacy injected Random for existing callers, while
/// calendar-driven calls pass scoped seeds so results do not depend on call
/// order or on another team's scouting activity.
class ScoutingService {
  ScoutingService({this.balance = BalanceConfig.defaults, Random? random})
    : _random = random ?? Random();

  final BalanceConfig balance;
  final Random _random;

  int maxWatched(double coverageStars) =>
      balance.staff.maxWatched(coverageStars);

  TeamScouting setWatchlist(
    TeamScouting scouting,
    List<String> prospectIds, {
    required double coverageStars,
  }) {
    final limit = maxWatched(coverageStars);
    final capped = prospectIds.take(limit).toList();
    final cappedSet = capped.toSet();
    final existing = {for (final k in scouting.knowledge) k.prospectId: k};
    final knowledge = [
      for (final id in capped)
        existing[id] ?? ScoutingKnowledge(prospectId: id),
    ];
    return scouting.copyWith(
      watchlistProspectIds: capped,
      knowledge: knowledge,
      combineAssignedProspectIds: scouting.combineAssignedProspectIds
          .where(cappedSet.contains)
          .toList(),
    );
  }

  int combineAssignLimit(double coverageStars) =>
      balance.staff.combineAssignLimit(coverageStars);

  /// Stores player-selected Combine targets while enforcing the watchlist,
  /// draft-class membership and the Coverage-based limit in one place.
  TeamScouting setCombineAssignments(
    TeamScouting scouting,
    List<String> prospectIds, {
    required double coverageStars,
    Iterable<String>? availableProspectIds,
  }) {
    final available = availableProspectIds?.toSet();
    final allowed = scouting.watchlistProspectIds.where(
      (id) => available == null || available.contains(id),
    );
    final allowedSet = allowed.toSet();
    final limit = combineAssignLimit(coverageStars);
    final selected = <String>[];
    for (final id in prospectIds) {
      if (selected.length >= limit) break;
      if (allowedSet.contains(id) && !selected.contains(id)) {
        selected.add(id);
      }
    }
    return scouting.copyWith(combineAssignedProspectIds: selected);
  }

  /// Cotygodniowy progres tieru dla obserwowanych prospectów, ∝ Evaluation.
  TeamScouting tickKnowledge(
    TeamScouting scouting,
    double evaluationStars, {
    List<Prospect> prospects = const [],
    int? seed,
    int seasonYear = 0,
    int week = 1,
    String teamId = '',
  }) {
    final byId = {for (final p in prospects) p.id: p};
    final chance = (0.15 + evaluationStars * 0.09).clamp(0.05, 0.6);
    final updated = scouting.knowledge.map((knowledge) {
      if (knowledge.tier == ScoutingTier.tier5) return knowledge;
      final random = _scopedRandom(
        seed: seed,
        seasonYear: seasonYear,
        week: week,
        teamId: teamId,
        kind: 'scout-tier',
        prospectId: knowledge.prospectId,
      );
      if (random.nextDouble() >= chance) return knowledge;
      final nextIndex = ScoutingTier.values.indexOf(knowledge.tier) + 1;
      final nextTier = ScoutingTier.values[nextIndex];
      return _evidenceForTier(
        knowledge.copyWith(tier: nextTier),
        byId[knowledge.prospectId],
        nextTier,
      );
    }).toList();
    return scouting.copyWith(knowledge: updated);
  }

  /// Scout Report (pon tyg. 45): assign Combine targets from the most
  /// uncertain prospects among the team's highest-ranked watched targets.
  TeamScouting runScoutReport(
    TeamScouting scouting,
    double coverageStars, {
    List<Prospect> prospects = const [],
    List<Prospect>? rankedProspects,
    int? seed,
  }) {
    final limit = balance.staff.combineAssignLimit(coverageStars);
    if (limit == 0 || scouting.watchlistProspectIds.isEmpty) {
      return scouting.copyWith(combineAssignedProspectIds: const []);
    }
    if (prospects.isEmpty) {
      return scouting.copyWith(
        combineAssignedProspectIds: scouting.watchlistProspectIds
            .take(limit)
            .toList(),
      );
    }

    final ranked = rankedProspects == null
        ? ([...prospects]..sort((a, b) {
            final grade = b.scoutGrade.compareTo(a.scoutGrade);
            return grade != 0 ? grade : a.id.compareTo(b.id);
          }))
        : [...rankedProspects];
    final rankById = {
      for (var i = 0; i < ranked.length; i++) ranked[i].id: i + 1,
    };
    final byId = {for (final p in prospects) p.id: p};
    final topTargetCount = min(
      scouting.watchlistProspectIds.length,
      max(limit, limit * 2),
    );
    final topTargets =
        scouting.watchlistProspectIds.where(byId.containsKey).toList()..sort(
          (a, b) => (rankById[a] ?? ranked.length).compareTo(
            rankById[b] ?? ranked.length,
          ),
        );
    final knowledgeById = {for (final k in scouting.knowledge) k.prospectId: k};
    topTargets.length = min(topTargets.length, topTargetCount);
    topTargets.sort((a, b) {
      final uncertainty = _uncertainty(knowledgeById[b]);
      final other = _uncertainty(knowledgeById[a]);
      if (uncertainty != other) return uncertainty.compareTo(other);
      return (rankById[a] ?? ranked.length).compareTo(
        rankById[b] ?? ranked.length,
      );
    });
    return scouting.copyWith(
      combineAssignedProspectIds: topTargets.take(limit).toList(),
    );
  }

  /// Draft Combine (śr tyg. 45): improves role/trait estimates for assigned
  /// prospects, using a stable per-prospect roll when [seed] is supplied.
  TeamScouting runCombine(
    TeamScouting scouting,
    double evaluationStars, {
    List<Prospect> prospects = const [],
    int? seed,
    int seasonYear = 0,
    int week = 45,
    String teamId = '',
  }) {
    final byId = {for (final p in prospects) p.id: p};
    final bonusChance = (0.5 + evaluationStars * 0.1).clamp(0.5, 1.0);
    final assigned = scouting.combineAssignedProspectIds.toSet();
    final updated = scouting.knowledge.map((knowledge) {
      if (!assigned.contains(knowledge.prospectId)) return knowledge;
      final random = _scopedRandom(
        seed: seed,
        seasonYear: seasonYear,
        week: week,
        teamId: teamId,
        kind: 'scout-combine',
        prospectId: knowledge.prospectId,
      );
      final prospect = byId[knowledge.prospectId];
      final targetTier = knowledge.tier.index < ScoutingTier.tier4.index
          ? ScoutingTier.tier4
          : knowledge.tier;
      final upgraded = _evidenceForTier(
        knowledge.copyWith(tier: targetTier),
        prospect,
        targetTier,
      );
      final injuryKnown =
          upgraded.injuryProneKnown || random.nextDouble() < bonusChance;
      final determinationKnown =
          upgraded.determinationKnown || random.nextDouble() < bonusChance;
      return _withTraitRange(
        upgraded.copyWith(
          injuryProneKnown: injuryKnown,
          determinationKnown: determinationKnown,
        ),
        prospect,
        injuryKnown: injuryKnown,
        determinationKnown: determinationKnown,
      );
    }).toList();
    return scouting.copyWith(knowledge: updated);
  }

  /// Replaces the lowest-ranked watched prospect after a >20-place rise in a
  /// monthly mock, with the documented 40% probability.
  TeamScouting updateMonthlyWatchlist(
    TeamScouting scouting, {
    required List<Prospect> rankedProspects,
    required double coverageStars,
    int? seed,
    int seasonYear = 0,
    int week = 1,
    String teamId = '',
    double replacementProbability = 0.40,
  }) {
    if (scouting.watchlistProspectIds.isEmpty || rankedProspects.isEmpty) {
      return scouting;
    }
    final currentRanks = {
      for (var i = 0; i < rankedProspects.length; i++)
        rankedProspects[i].id: i + 1,
    };
    final previousRanks = scouting.mockRanks;
    if (previousRanks.isEmpty) {
      return scouting.copyWith(mockRanks: currentRanks);
    }
    final watched = scouting.watchlistProspectIds.toSet();
    final rising =
        currentRanks.entries
            .where(
              (entry) =>
                  !watched.contains(entry.key) &&
                  (previousRanks[entry.key] ?? entry.value) - entry.value > 20,
            )
            .toList()
          ..sort((a, b) => a.value.compareTo(b.value));
    if (rising.isEmpty) {
      return scouting.copyWith(mockRanks: currentRanks);
    }
    final roll = _scopedRandom(
      seed: seed,
      seasonYear: seasonYear,
      week: week,
      teamId: teamId,
      kind: 'scout-watchlist-replacement',
      prospectId: rising.first.key,
    ).nextDouble();
    if (roll >= replacementProbability) {
      return scouting.copyWith(mockRanks: currentRanks);
    }

    final lowest = [...scouting.watchlistProspectIds]
      ..sort(
        (a, b) => (currentRanks[b] ?? rankedProspects.length).compareTo(
          currentRanks[a] ?? rankedProspects.length,
        ),
      );
    if (lowest.isEmpty) return scouting.copyWith(mockRanks: currentRanks);
    final replacement = rising.first.key;
    final ids = [...scouting.watchlistProspectIds]
      ..remove(lowest.first)
      ..add(replacement);
    return setWatchlist(
      scouting.copyWith(mockRanks: currentRanks),
      ids,
      coverageStars: coverageStars,
    ).copyWith(mockRanks: currentRanks);
  }

  /// Mock Draft wczesny: estymowany slot z większym szumem niż finalny.
  TeamScouting runEarlyMock(
    TeamScouting scouting,
    List<Prospect> rankedProspects,
    double evaluationStars, {
    int? seed,
    int seasonYear = 0,
    int week = 45,
    String teamId = '',
  }) {
    final stars = evaluationStars.clamp(0.0, 5.0);
    final t = 1 - (stars / 5.0);
    final noiseRange =
        (balance.draft.mockEarlyNoiseMin +
                (balance.draft.mockEarlyNoiseMax -
                        balance.draft.mockEarlyNoiseMin) *
                    t)
            .round();
    return _runMock(
      scouting,
      rankedProspects,
      noiseRange,
      ScoutingTier.tier2,
      seed: seed,
      seasonYear: seasonYear,
      week: week,
      teamId: teamId,
    );
  }

  /// Mock Draft finalny (pt tyg. 45): estymowany slot z szumem malejącym z
  /// Evaluation.
  TeamScouting runFinalMock(
    TeamScouting scouting,
    List<Prospect> rankedProspects,
    double evaluationStars, {
    int? seed,
    int seasonYear = 0,
    int week = 45,
    String teamId = '',
  }) {
    final noiseRange = (25 - evaluationStars * 4).clamp(5, 25).round();
    return _runMock(
      scouting,
      rankedProspects,
      noiseRange,
      ScoutingTier.tier3,
      seed: seed,
      seasonYear: seasonYear,
      week: week,
      teamId: teamId,
    );
  }

  TeamScouting _runMock(
    TeamScouting scouting,
    List<Prospect> rankedProspects,
    int noiseRange,
    ScoutingTier minimumTier, {
    int? seed,
    required int seasonYear,
    required int week,
    required String teamId,
  }) {
    if (rankedProspects.isEmpty) return scouting;
    final rankById = {
      for (var i = 0; i < rankedProspects.length; i++) rankedProspects[i].id: i,
    };
    final byId = {for (final p in rankedProspects) p.id: p};
    final updated = scouting.knowledge.map((knowledge) {
      final trueRank = rankById[knowledge.prospectId];
      if (trueRank == null) return knowledge;
      final random = _scopedRandom(
        seed: seed,
        seasonYear: seasonYear,
        week: week,
        teamId: teamId,
        kind: 'scout-mock',
        prospectId: knowledge.prospectId,
      );
      final noisyRank =
          (trueRank + (random.nextInt(noiseRange * 2 + 1) - noiseRange)).clamp(
            0,
            rankedProspects.length - 1,
          );
      final tier = knowledge.tier.index < minimumTier.index
          ? minimumTier
          : knowledge.tier;
      return _evidenceForTier(
        knowledge.copyWith(
          estimatedSlot: _slotForRank(noisyRank),
          mockRank: noisyRank + 1,
          tier: tier,
        ),
        byId[knowledge.prospectId],
        tier,
      );
    }).toList();
    return scouting.copyWith(
      knowledge: updated,
      mockRanks: {
        ...scouting.mockRanks,
        for (var i = 0; i < rankedProspects.length; i++)
          rankedProspects[i].id: i + 1,
      },
    );
  }

  ScoutingKnowledge _evidenceForTier(
    ScoutingKnowledge knowledge,
    Prospect? prospect,
    ScoutingTier tier,
  ) {
    if (prospect == null) return knowledge;
    final overall = prospect.projectedOverall(balance).round();
    final span = tier.index >= ScoutingTier.tier5.index
        ? 1
        : tier.index >= ScoutingTier.tier3.index
        ? 3
        : 5;
    return knowledge.copyWith(
      estimatedOvrMin: tier.index >= ScoutingTier.tier2.index
          ? (overall - span).clamp(0, 99)
          : null,
      estimatedOvrMax: tier.index >= ScoutingTier.tier2.index
          ? (overall + span).clamp(0, 99)
          : null,
      estimatedPotentialMin: tier.index >= ScoutingTier.tier4.index
          ? max(0.5, prospect.potentialStars - 1.0)
          : null,
      estimatedPotentialMax: tier.index >= ScoutingTier.tier4.index
          ? min(5.0, prospect.potentialStars + 1.0)
          : null,
    );
  }

  ScoutingKnowledge _withTraitRange(
    ScoutingKnowledge knowledge,
    Prospect? prospect, {
    required bool injuryKnown,
    required bool determinationKnown,
  }) {
    if (prospect == null) return knowledge;
    return knowledge.copyWith(
      injuryProneMin: injuryKnown
          ? max(1, prospect.injuryProne - 2)
          : knowledge.injuryProneMin,
      injuryProneMax: injuryKnown
          ? min(10, prospect.injuryProne + 2)
          : knowledge.injuryProneMax,
      determinationMin: determinationKnown
          ? max(1, prospect.determination - 2)
          : knowledge.determinationMin,
      determinationMax: determinationKnown
          ? min(10, prospect.determination + 2)
          : knowledge.determinationMax,
    );
  }

  int _uncertainty(ScoutingKnowledge? knowledge) {
    if (knowledge == null) return 1000;
    final ovrRange =
        knowledge.estimatedOvrMin == null || knowledge.estimatedOvrMax == null
        ? 100
        : knowledge.estimatedOvrMax! - knowledge.estimatedOvrMin!;
    final potentialRange =
        knowledge.estimatedPotentialMin == null ||
            knowledge.estimatedPotentialMax == null
        ? 20
        : ((knowledge.estimatedPotentialMax! -
                      knowledge.estimatedPotentialMin!) *
                  10)
              .round();
    return (ScoutingTier.values.length - knowledge.tier.index) * 100 +
        ovrRange +
        potentialRange;
  }

  Random _scopedRandom({
    required int? seed,
    required int seasonYear,
    required int week,
    required String teamId,
    required String kind,
    required String prospectId,
  }) {
    if (seed == null) return _random;
    return Random(
      teamEventSeed(
        seed,
        seasonYear,
        week,
        teamId.isEmpty ? 'scouting' : teamId,
        kind,
        playerId: prospectId,
      ),
    );
  }

  EstimatedDraftSlot _slotForRank(int rank) {
    if (rank == 0) return EstimatedDraftSlot.top1;
    if (rank < 3) return EstimatedDraftSlot.top3;
    if (rank < 5) return EstimatedDraftSlot.top5;
    if (rank < 10) return EstimatedDraftSlot.top10;
    if (rank < 30) return EstimatedDraftSlot.r1;
    if (rank < 60) return EstimatedDraftSlot.r2;
    if (rank < 90) return EstimatedDraftSlot.r3;
    return EstimatedDraftSlot.x;
  }
}
