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

  /// Tygodnie potrzebne do przejścia z [currentTier] na kolejny tier, wg
  /// tabeli `staff.md` §4 "Evaluation": tier2 = 30 − 2×eval, tier3-5 = 20 −
  /// 2×eval (każdy z osobna). Zwraca null, gdy progres jest niemożliwy
  /// (tier5 = max, albo evaluationStars <= 0 = brak scouta).
  int? _weeksNeededForNextTier(
    ScoutingTier currentTier,
    double evaluationStars,
  ) {
    if (currentTier == ScoutingTier.tier5) return null;
    if (evaluationStars <= 0) return null;
    final base = currentTier == ScoutingTier.tier1
        ? balance.scouting.firstTierWeeks
        : balance.scouting.laterTierWeeks;
    return (base -
            balance.scouting.weeksReductionPerEvaluationStar * evaluationStars)
        .round()
        .clamp(1, 999);
  }

  /// Cotygodniowy progres tieru dla obserwowanych prospectów, deterministyczny
  /// wg czasu spędzonego na obecnym tierze — patrz `staff.md` §4.
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
    final updated = scouting.knowledge.map((knowledge) {
      final weeksNeeded = _weeksNeededForNextTier(
        knowledge.tier,
        evaluationStars,
      );
      if (weeksNeeded == null) return knowledge;
      final weeksAtTier = knowledge.weeksAtCurrentTier + 1;
      if (weeksAtTier < weeksNeeded) {
        return knowledge.copyWith(weeksAtCurrentTier: weeksAtTier);
      }
      final nextIndex = ScoutingTier.values.indexOf(knowledge.tier) + 1;
      final nextTier = ScoutingTier.values[nextIndex];
      return _evidenceForTier(
        knowledge.copyWith(tier: nextTier, weeksAtCurrentTier: 0),
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
      max(limit, limit * balance.scouting.reportCandidateMultiplier),
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
    int? week,
    String teamId = '',
  }) {
    final resolvedWeek =
        week ?? balance.calendar.draftWeek - balance.calendar.scoutWeekOffset;
    final byId = {for (final p in prospects) p.id: p};
    final bonusChance =
        (balance.scouting.combineChanceBase +
                evaluationStars * balance.scouting.combineChancePerStar)
            .clamp(
              balance.scouting.combineChanceMin,
              balance.scouting.combineChanceMax,
            );
    final assigned = scouting.combineAssignedProspectIds.toSet();
    final updated = scouting.knowledge.map((knowledge) {
      if (!assigned.contains(knowledge.prospectId)) return knowledge;
      final random = _scopedRandom(
        seed: seed,
        seasonYear: seasonYear,
        week: resolvedWeek,
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
    double? replacementProbability,
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
                  (previousRanks[entry.key] ?? entry.value) - entry.value >
                      balance.scouting.monthlyRankRiseMinExclusive,
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
    if (roll >=
        (replacementProbability ?? balance.scouting.monthlyReplacementChance)) {
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
    int? week,
    String teamId = '',
  }) {
    final resolvedWeek =
        week ?? balance.calendar.draftWeek - balance.calendar.scoutWeekOffset;
    final stars = evaluationStars.clamp(
      balance.staff.starMin,
      balance.staff.starMax,
    );
    final t = 1 - (stars / balance.staff.starMax);
    final noiseRange =
        (balance.scouting.earlyMockNoiseMin +
                (balance.scouting.earlyMockNoiseMax -
                        balance.scouting.earlyMockNoiseMin) *
                    t)
            .round();
    return _runMock(
      scouting,
      rankedProspects,
      noiseRange,
      ScoutingTier.tier2,
      seed: seed,
      seasonYear: seasonYear,
      week: resolvedWeek,
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
    int? week,
    String teamId = '',
  }) {
    final resolvedWeek =
        week ?? balance.calendar.draftWeek - balance.calendar.scoutWeekOffset;
    final noiseRange =
        (balance.scouting.finalMockNoiseBase -
                evaluationStars * balance.scouting.finalMockNoisePerStar)
            .clamp(
              balance.scouting.finalMockNoiseMin,
              balance.scouting.finalMockNoiseMax,
            )
            .round();
    return _runMock(
      scouting,
      rankedProspects,
      noiseRange,
      ScoutingTier.tier3,
      seed: seed,
      seasonYear: seasonYear,
      week: resolvedWeek,
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
    final span = balance.scouting.ovrSpans[tier]!;
    final evidence = knowledge.copyWith(
      estimatedOvrMin: tier.index >= ScoutingTier.tier2.index
          ? max(
              knowledge.estimatedOvrMin ?? balance.player.attributeMin,
              balance.player.clampAttribute(overall - span),
            )
          : null,
      estimatedOvrMax: tier.index >= ScoutingTier.tier2.index
          ? min(
              knowledge.estimatedOvrMax ?? balance.player.attributeMax,
              balance.player.clampAttribute(overall + span),
            )
          : null,
      estimatedPotentialMin: tier.index >= ScoutingTier.tier4.index
          ? max(
              knowledge.estimatedPotentialMin ?? balance.player.potentialMin,
              max(
                balance.player.potentialMin,
                prospect.potentialStars - balance.scouting.potentialSpan,
              ),
            )
          : null,
      estimatedPotentialMax: tier.index >= ScoutingTier.tier4.index
          ? min(
              knowledge.estimatedPotentialMax ?? balance.player.potentialMax,
              min(
                balance.player.potentialMax,
                prospect.potentialStars + balance.scouting.potentialSpan,
              ),
            )
          : null,
    );
    if (tier != ScoutingTier.tier5) return evidence;
    return _withTraitRange(
      evidence.copyWith(injuryProneKnown: true, determinationKnown: true),
      prospect,
      injuryKnown: true,
      determinationKnown: true,
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
          ? max(
              knowledge.injuryProneMin ?? balance.player.traitMin,
              max(
                balance.player.traitMin,
                prospect.injuryProne - balance.scouting.traitSpan,
              ),
            )
          : knowledge.injuryProneMin,
      injuryProneMax: injuryKnown
          ? min(
              knowledge.injuryProneMax ?? balance.player.traitMax,
              min(
                balance.player.traitMax,
                prospect.injuryProne + balance.scouting.traitSpan,
              ),
            )
          : knowledge.injuryProneMax,
      determinationMin: determinationKnown
          ? max(
              knowledge.determinationMin ?? balance.player.traitMin,
              max(
                balance.player.traitMin,
                prospect.determination - balance.scouting.traitSpan,
              ),
            )
          : knowledge.determinationMin,
      determinationMax: determinationKnown
          ? min(
              knowledge.determinationMax ?? balance.player.traitMax,
              min(
                balance.player.traitMax,
                prospect.determination + balance.scouting.traitSpan,
              ),
            )
          : knowledge.determinationMax,
    );
  }

  int _uncertainty(ScoutingKnowledge? knowledge) {
    if (knowledge == null) return balance.scouting.unknownProspectUncertainty;
    final ovrRange =
        knowledge.estimatedOvrMin == null || knowledge.estimatedOvrMax == null
        ? balance.scouting.unknownOvrUncertainty
        : knowledge.estimatedOvrMax! - knowledge.estimatedOvrMin!;
    final potentialRange =
        knowledge.estimatedPotentialMin == null ||
            knowledge.estimatedPotentialMax == null
        ? balance.scouting.unknownPotentialUncertainty
        : ((knowledge.estimatedPotentialMax! -
                      knowledge.estimatedPotentialMin!) *
                  balance.scouting.potentialUncertaintyWeight)
              .round();
    return (ScoutingTier.values.length - knowledge.tier.index) *
            balance.scouting.tierUncertaintyWeight +
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
    for (final (rankExclusive, slot) in balance.scouting.slotBands) {
      if (rank < rankExclusive) return slot;
    }
    return EstimatedDraftSlot.x;
  }
}
