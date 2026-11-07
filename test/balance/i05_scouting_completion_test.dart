import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/prospect.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/mock_draft_service.dart';
import 'package:new_football/core/services/scouting_service.dart';

void main() {
  final prospects = SeedDataGenerator()
      .generateDraftClass(year: 2027, seed: 42)
      .prospects;
  final p = prospects.first.copyWith(
    potentialStars: 3,
    injuryProne: 6,
    determination: 6,
  );
  TeamScouting watched({
    ScoutingTier tier = ScoutingTier.tier1,
    int weeks = 0,
  }) => TeamScouting(
    watchlistProspectIds: [p.id],
    combineAssignedProspectIds: [p.id],
    knowledge: [
      ScoutingKnowledge(
        prospectId: p.id,
        tier: tier,
        weeksAtCurrentTier: weeks,
      ),
    ],
  );

  test(
    'configured tier tempo and OVR widths reach natural weekly advancement',
    () {
      const balance = BalanceConfig(
        scouting: ScoutingBalance(
          firstTierWeeks: 4,
          laterTierWeeks: 3,
          weeksReductionPerEvaluationStar: 1,
          ovrSpans: {
            ScoutingTier.tier1: 2,
            ScoutingTier.tier2: 2,
            ScoutingTier.tier3: 1,
            ScoutingTier.tier4: 1,
            ScoutingTier.tier5: 1,
          },
        ),
      );
      final service = ScoutingService(balance: balance);
      var state = watched();
      for (var week = 1; week <= 5; week++) {
        state = service.tickKnowledge(state, 1, prospects: [p]);
        expect(
          state.knowledge.single.tier,
          week < 3
              ? ScoutingTier.tier1
              : week < 5
              ? ScoutingTier.tier2
              : ScoutingTier.tier3,
        );
      }
      final ovr = p.projectedOverall(balance).round();
      expect(state.knowledge.single.estimatedOvrMin, max(50, ovr - 1));
      expect(state.knowledge.single.estimatedOvrMax, min(99, ovr + 1));
    },
  );

  test(
    'potential and trait estimates use their own spans and domain bounds',
    () {
      const balance = BalanceConfig(
        player: PlayerBalance(
          attributeMin: 60,
          attributeMax: 80,
          potentialMin: 2.5,
          potentialMax: 3.5,
          traitMin: 5,
          traitMax: 7,
        ),
        scouting: ScoutingBalance(
          laterTierWeeks: 2,
          weeksReductionPerEvaluationStar: 1,
          potentialSpan: 0.25,
          traitSpan: 1,
        ),
      );
      final updated = ScoutingService(
        balance: balance,
      ).tickKnowledge(watched(tier: ScoutingTier.tier4), 1, prospects: [p]);
      final evidence = updated.knowledge.single;
      expect(evidence.tier, ScoutingTier.tier5);
      expect(evidence.estimatedOvrMin, inInclusiveRange(60, 80));
      expect(evidence.estimatedOvrMax, inInclusiveRange(60, 80));
      expect(evidence.estimatedPotentialMin, 2.75);
      expect(evidence.estimatedPotentialMax, 3.25);
      expect(evidence.injuryProneMin, 5);
      expect(evidence.injuryProneMax, 7);
      expect(evidence.determinationMin, 5);
      expect(evidence.determinationMax, 7);
    },
  );

  test('Combine chance uses injected base, slope and limits', () {
    for (final chance in [0.0, 1.0]) {
      final balance = BalanceConfig(
        scouting: ScoutingBalance(
          combineChanceBase: chance,
          combineChancePerStar: 0,
          combineChanceMin: chance,
          combineChanceMax: chance,
        ),
      );
      final evidence = ScoutingService(
        balance: balance,
      ).runCombine(watched(), 1, prospects: [p], seed: 42).knowledge.single;
      expect(evidence.tier, ScoutingTier.tier4);
      expect(evidence.injuryProneKnown, chance == 1);
      expect(evidence.determinationKnown, chance == 1);
    }
  });

  test(
    'report candidate pool and uncertainty weights affect actual assignments',
    () {
      final targets = [
        for (final id in ['a', 'b', 'c']) p.copyWith(id: id),
      ];
      const state = TeamScouting(
        watchlistProspectIds: ['a', 'b', 'c'],
        knowledge: [
          ScoutingKnowledge(
            prospectId: 'a',
            tier: ScoutingTier.tier5,
            estimatedOvrMin: 70,
            estimatedOvrMax: 70,
          ),
          ScoutingKnowledge(
            prospectId: 'b',
            tier: ScoutingTier.tier5,
            estimatedOvrMin: 70,
            estimatedOvrMax: 70,
          ),
          ScoutingKnowledge(prospectId: 'c'),
        ],
      );
      for (final pool in [1, 3]) {
        final service = ScoutingService(
          balance: BalanceConfig(
            scouting: ScoutingBalance(reportCandidateMultiplier: pool),
          ),
        );
        final report = service.runScoutReport(
          state,
          2,
          prospects: targets,
          rankedProspects: targets,
        );
        expect(report.combineAssignedProspectIds, [pool == 1 ? 'a' : 'c']);
      }
      const weighted = TeamScouting(
        watchlistProspectIds: ['a', 'b'],
        knowledge: [
          ScoutingKnowledge(
            prospectId: 'a',
            tier: ScoutingTier.tier5,
            estimatedOvrMin: 70,
            estimatedOvrMax: 74,
            estimatedPotentialMin: 3,
            estimatedPotentialMax: 3,
          ),
          ScoutingKnowledge(
            prospectId: 'b',
            tier: ScoutingTier.tier5,
            estimatedOvrMin: 70,
            estimatedOvrMax: 70,
            estimatedPotentialMin: 3,
            estimatedPotentialMax: 4,
          ),
        ],
      );
      for (final weight in [1.0, 10.0]) {
        final service = ScoutingService(
          balance: BalanceConfig(
            scouting: ScoutingBalance(
              tierUncertaintyWeight: 0,
              potentialUncertaintyWeight: weight,
            ),
          ),
        );
        expect(
          service
              .runScoutReport(
                weighted,
                2,
                prospects: targets,
                rankedProspects: targets,
              )
              .combineAssignedProspectIds,
          [weight == 1 ? 'a' : 'b'],
        );
      }
    },
  );

  test(
    'monthly replacement reads default balance and preserves explicit caller override',
    () {
      final newcomer = p.copyWith(id: 'new'), old = p.copyWith(id: 'old');
      const state = TeamScouting(
        watchlistProspectIds: ['old'],
        knowledge: [ScoutingKnowledge(prospectId: 'old')],
        mockRanks: {'new': 5, 'old': 1},
      );
      for (final rise in [2, 6]) {
        final service = ScoutingService(
          balance: BalanceConfig(
            scouting: ScoutingBalance(
              monthlyRankRiseMinExclusive: rise,
              monthlyReplacementChance: 1,
            ),
          ),
        );
        final result = service.updateMonthlyWatchlist(
          state,
          rankedProspects: [newcomer, old],
          coverageStars: 1,
          seed: 42,
        );
        expect(result.watchlistProspectIds, [rise == 2 ? 'new' : 'old']);
        expect(
          service
              .updateMonthlyWatchlist(
                state,
                rankedProspects: [newcomer, old],
                coverageStars: 1,
                replacementProbability: 0,
                seed: 42,
              )
              .watchlistProspectIds,
          ['old'],
        );
      }
    },
  );

  test(
    'implicit scouting week follows calendar while club and public mocks stay independent',
    () {
      const balance = BalanceConfig(
        calendar: CalendarBalance(draftWeek: 40, scoutWeekOffset: 2),
        scouting: ScoutingBalance(
          earlyMockNoiseMin: 0,
          earlyMockNoiseMax: 0,
          finalMockNoiseBase: 0,
          finalMockNoiseMin: 0,
          finalMockNoiseMax: 0,
          slotBands: [(120, EstimatedDraftSlot.top10)],
        ),
      );
      final service = ScoutingService(balance: balance);
      expect(
        service.runCombine(
          watched(),
          1,
          prospects: [p],
          seed: 42,
          seasonYear: 2027,
        ),
        service.runCombine(
          watched(),
          1,
          prospects: [p],
          seed: 42,
          seasonYear: 2027,
          week: 38,
        ),
      );
      final early = service.runEarlyMock(
        watched(),
        prospects,
        1,
        seed: 42,
        seasonYear: 2027,
      );
      expect(
        early,
        service.runEarlyMock(
          watched(),
          prospects,
          1,
          seed: 42,
          seasonYear: 2027,
          week: 38,
        ),
      );
      expect(early.knowledge.single.estimatedSlot, EstimatedDraftSlot.top10);
      expect(
        service.runFinalMock(
          watched(),
          prospects,
          1,
          seed: 42,
          seasonYear: 2027,
        ),
        service.runFinalMock(
          watched(),
          prospects,
          1,
          seed: 42,
          seasonYear: 2027,
          week: 38,
        ),
      );
      final board = MockDraftService().trueBoard(prospects);
      expect(
        MockDraftService(
          balance: balance,
        ).generateInitialMock(board, seed: 42, seasonYear: 2027),
        MockDraftService().generateInitialMock(
          board,
          seed: 42,
          seasonYear: 2027,
        ),
      );
    },
  );

  test('monthly scouting calendar is consumed by real day simulation', () {
    const balance = BalanceConfig(
      calendar: CalendarBalance(
        scoutingMonthlyFirstWeek: 3,
        scoutingMonthlyIntervalWeeks: 2,
        scoutingMonthlyDay: 2,
      ),
    );
    final league = SeedDataGenerator().generateLeague(seed: 42);
    final source = league.copyWith(
      teams: [for (final t in league.teams) t.copyWith(ai: null)],
      playerTeamId: league.teams.first.id,
      currentSeason: league.currentSeason.copyWith(schedule: []),
    );
    for (final (week, day, expected) in [
      (3, 1, 0),
      (3, 2, 1),
      (4, 2, 0),
      (5, 2, 1),
    ]) {
      final result = DaySimulator(balance: balance)
          .simulateDay(
            source.copyWith(currentWeek: week, currentDay: day),
            saveSeed: 42,
            resolveContractMarket: false,
          )
          .league;
      expect(
        [...result.inbox.messages, ...result.inbox.scheduled].where(
          (m) => m.type == MessageType.scoutReport && m.kind == 'monthly',
        ),
        hasLength(expected),
      );
    }
  });
}
