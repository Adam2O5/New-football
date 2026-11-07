import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_value.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/staff_service.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(seed: 42);
  final team = league.teams.first;
  final player = team.roster.first;

  test(
    'point-value components and cached generated values use injected balance',
    () {
      const balance = BalanceConfig(
        tradeValue: TradeValueBalance(
          pointOvrBase: 50,
          pointOvrWeight: 2,
          pointYoungPotentialWeight: 0,
          pointOlderFactorBase: 0,
          pointOlderFactorMin: 0,
          pointAgeWeight: 0,
          pointContractWeight: 0,
        ),
      );
      expect(
        player.computePointValue(balance),
        ((player.overall(balance) - 50) * 2).round(),
      );
      final generated = SeedDataGenerator(
        balance: balance,
      ).generateLeague(seed: 42);
      for (final p in generated.teams.first.roster) {
        expect(p.pointValue, ((p.overall(balance) - 50) * 2).round());
      }
      const limited = BalanceConfig(
        tradeValue: TradeValueBalance(pointMin: -10, pointMax: 10),
      );
      expect(
        player.copyWith(age: 18).computePointValue(limited),
        inInclusiveRange(-10, 10),
      );
    },
  );

  test('potential table reaches career ceilings and point valuation', () {
    const balance = BalanceConfig(
      tradeValue: TradeValueBalance(
        potentialOvrTable: [(2.0, 60), (5.0, 90)],
        pointOvrWeight: 0,
        pointAgeWeight: 0,
        pointContractWeight: 0,
        pointYoungFactorBase: 1,
        pointYoungFactorDecay: 0,
        pointYoungPotentialWeight: 1,
      ),
    );
    final p = player.copyWith(
      age: 20,
      potentialStars: 5,
      hidden: player.hidden.copyWith(developmentCeilingStars: 2),
    );
    expect(p.developmentCeilingOvr(balance), 60);
    expect(
      p.computePointValue(balance),
      (90 - p.overall(balance)).clamp(0, 50).round(),
    );
  });

  test('asset salary anchor stays separate from negotiated salary and cap', () {
    const balance = BalanceConfig(
      tradeValue: TradeValueBalance(
        assetSalaryMin: 2000000,
        assetSalaryMax: 2000000,
      ),
    );
    expect(estimatedSalaryForOverall(80, balance), 2000000);
    expect(
      ContractService(balance: balance).expectedSalary(player),
      ContractService().expectedSalary(player),
    );
    expect(balance.salaryCap.maxSalary, 60000000);
    final p = player.copyWith(
      contract: player.contract.copyWith(salary: 2000000),
    );
    const isolated = BalanceConfig(
      tradeValue: TradeValueBalance(
        assetSalaryMin: 2000000,
        assetSalaryMax: 2000000,
        pointOvrWeight: 0,
        pointYoungPotentialWeight: 0,
        pointOlderFactorBase: 0,
        pointOlderFactorMin: 0,
        pointAgeWeight: 0,
      ),
    );
    expect(p.computePointValue(isolated), 0);
  });

  test(
    'TV schedule uses configured ranges in generator and service without changing default seed math',
    () {
      const balance = BalanceConfig(
        salaryCap: SalaryCapBalance(
          tvResetYearsMin: 2,
          tvResetYearsMax: 2,
          tvIncreasePctMin: 3,
          tvIncreasePctMax: 3,
        ),
      );
      final configured = const SalaryCapService(
        balance: balance,
      ).tvScheduleFor(currentYear: 2026, saveSeed: 42);
      expect(configured.nextTvCapResetSeason, 2028);
      expect(configured.nextTvCapIncreasePct, 3);
      final generated = SeedDataGenerator(
        balance: balance,
      ).generateLeague(seed: 42);
      expect(generated.currentSeason.nextTvCapResetSeason, 2028);
      expect(generated.currentSeason.nextTvCapIncreasePct, 3);
      final rng = Random((42 ^ (2026 * 1000003) ^ 0x5f3759df) & 0x7fffffff);
      final defaults = tvCapScheduleFor(currentYear: 2026, saveSeed: 42);
      expect(defaults.nextTvCapResetSeason, 2026 + 5 + rng.nextInt(3));
      expect(defaults.nextTvCapIncreasePct, 4 + rng.nextInt(9));
      final updated = const SalaryCapService(
        balance: balance,
      ).applyTvUpdate([team], increasePct: 50).single;
      expect(
        updated.finance.salaryCap,
        (team.finance.salaryCap * 1.03).round(),
      );
    },
  );

  for (final kind in NegotiationSubjectKind.values) {
    test(
      '${kind.name}: waiting is three hours by default and respects last slot',
      () {
        const service = NegotiationService();
        final started = service.start(
          id: 'test',
          subjectId: 'subject',
          subjectKind: kind,
          teamId: team.id,
          phase: NegotiationPhase.freeAgencyPhaseI,
          offer: const NegotiationOffer(salary: 1000000, years: 2),
          seasonYear: 2026,
          week: 47,
        );
        for (final (hour, expected) in [(1, 4), (9, 10)]) {
          final waiting = service.applyDecision(
            negotiation: started,
            decision: NegotiationDecision.waiting,
            seasonYear: 2026,
            week: 47,
            day: 1,
            hour: hour,
          );
          expect(waiting.waitingUntilHour, expected);
          expect(waiting.waitingUntilDay, 1);
        }
        const configured = NegotiationService(
          balance: BalanceConfig(
            contracts: ContractNegBalance(
              playerWaitingHours: 4,
              staffWaitingHours: 5,
            ),
          ),
        );
        final waiting = configured.applyDecision(
          negotiation: started,
          decision: NegotiationDecision.waiting,
          seasonYear: 2026,
          week: 47,
          day: 1,
          hour: 1,
        );
        expect(
          waiting.waitingUntilHour,
          kind == NegotiationSubjectKind.player ? 5 : 6,
        );
        expect(
          waiting.expiryHour,
          4,
        ); // Finalization remains a separate three-hour rule.
      },
    );
  }

  test(
    'CFO and prestige configuration reaches shared score and both contract services',
    () {
      const balance = BalanceConfig(
        contracts: ContractNegBalance(
          cfoMultipliers: [0.5, 0.5],
          teamStatusBonuses: {TeamStatus.elite: 20},
        ),
      );
      final score = NegotiationRules.score(
        salary: 1000000,
        expectedSalary: 1000000,
        years: 2,
        expectedLength: 2,
        offeringTeamStatus: TeamStatus.elite,
        cfoNegotiation: 5,
        balance: balance.contracts,
      );
      expect(score.score, 35);
      expect(
        ContractService(balance: balance).cfoDiscount(negotiation: 5),
        0.5,
      );
      expect(StaffService(balance: balance).cfoDiscount(negotiation: 5), 0.5);
      expect(score.teamStatus, 20);
    },
  );

  test('active waiting resolution uses configured rejection bands', () {
    const balance = BalanceConfig(
      contracts: ContractNegBalance(
        hardRejectScoreMax: 997,
        rejectScoreMax: 998,
        counterScoreMax: 999,
        acceptScoreMin: 1000,
      ),
    );
    final freeAgent = player.copyWith(
      id: 'free-agent',
      contract: player.contract.copyWith(yearsRemaining: 0),
    );
    final waiting = const NegotiationService()
        .start(
          id: 'waiting',
          subjectId: freeAgent.id,
          subjectKind: NegotiationSubjectKind.player,
          teamId: team.id,
          phase: NegotiationPhase.freeAgencyPhaseI,
          offer: const NegotiationOffer(salary: 60000000, years: 2),
          seasonYear: 2026,
          week: 47,
        )
        .copyWith(
          status: NegotiationStatus.waiting,
          waitingUntilSeasonYear: 2026,
          waitingUntilWeek: 47,
          waitingUntilDay: 1,
          waitingUntilHour: 4,
          expiryHour: 10,
        );
    final input = league.copyWith(
      teams: [team.copyWith(ai: null)],
      playerTeamId: team.id,
      currentWeek: 47,
      currentDay: 1,
      currentHour: 4,
      freeAgents: [freeAgent],
      negotiations: [waiting],
    );
    final resolved = ContractMarketService(
      balance: balance,
    ).resolveHour(input, hour: 4, saveSeed: 42);
    expect(
      resolved.negotiationById(waiting.id)!.status,
      NegotiationStatus.hardRejected,
    );
  });

  for (final (responseHour, deadlineHour) in [(4, 7), (10, 10)]) {
    test(
      'accepted waiting response at hour $responseHour gets a separate finalization deadline',
      () {
        const balance = BalanceConfig(
          contracts: ContractNegBalance(
            salaryFitBase: 100,
            salaryBelowPenaltyPerPct: 0,
            salaryAboveBonusPerPct: 0,
            lengthFitBase: 0,
            lengthPenaltyPerYear: 0,
            cfoMultipliers: [1, 1],
            teamStatusBonuses: {},
          ),
        );
        final freeAgent = player.copyWith(
          id: 'signable',
          contract: player.contract.copyWith(yearsRemaining: 0),
        );
        final waiting = const NegotiationService()
            .start(
              id: 'waiting-signable',
              subjectId: freeAgent.id,
              subjectKind: NegotiationSubjectKind.player,
              teamId: team.id,
              phase: NegotiationPhase.freeAgencyPhaseI,
              offer: const NegotiationOffer(salary: 1000000, years: 2),
              seasonYear: 2026,
              week: 47,
              hour: responseHour - 3,
            )
            .copyWith(
              status: NegotiationStatus.waiting,
              waitingUntilSeasonYear: 2026,
              waitingUntilWeek: 47,
              waitingUntilDay: 1,
              waitingUntilHour: responseHour,
            );
        final input = league.copyWith(
          teams: [team.copyWith(ai: null, roster: [])],
          playerTeamId: team.id,
          currentWeek: 47,
          currentDay: 1,
          currentHour: responseHour,
          freeAgents: [freeAgent],
          negotiations: [waiting],
        );
        final market = ContractMarketService(balance: balance);
        final accepted = market.resolveHour(
          input,
          hour: responseHour,
          saveSeed: 42,
        );
        final pending = accepted.negotiationById(waiting.id)!;
        expect(pending.status, NegotiationStatus.pendingFinalization);
        expect(pending.expiryHour, deadlineHour);
        final signed = market.finalizeNegotiation(
          accepted.copyWith(currentHour: deadlineHour),
          waiting.id,
          saveSeed: 42,
        );
        expect(signed, isNotNull);
        expect(signed!.playerTeam!.roster.single.id, freeAgent.id);
      },
    );
  }

  test('counter after waiting retains a usable response window', () {
    const balance = BalanceConfig(
      contracts: ContractNegBalance(
        salaryFitBase: 65,
        lengthFitBase: 0,
        lengthPenaltyPerYear: 0,
        cfoMultipliers: [1, 1],
        teamStatusBonuses: {},
        mixedAcceptProbabilityAtMidpoint: 0,
        mixedAcceptSlope: 0,
      ),
    );
    final freeAgent = player.copyWith(
      id: 'counter-subject',
      contract: player.contract.copyWith(yearsRemaining: 0),
    );
    final waiting = const NegotiationService()
        .start(
          id: 'waiting-counter',
          subjectId: freeAgent.id,
          subjectKind: NegotiationSubjectKind.player,
          teamId: team.id,
          phase: NegotiationPhase.freeAgencyPhaseI,
          offer: NegotiationOffer(
            salary: ContractService(balance: balance).expectedSalary(freeAgent),
            years: 2,
          ),
          seasonYear: 2026,
          week: 47,
          hour: 1,
        )
        .copyWith(
          status: NegotiationStatus.waiting,
          waitingUntilSeasonYear: 2026,
          waitingUntilWeek: 47,
          waitingUntilDay: 1,
          waitingUntilHour: 4,
        );
    final input = league.copyWith(
      teams: [team.copyWith(ai: null)],
      playerTeamId: team.id,
      currentWeek: 47,
      currentDay: 1,
      currentHour: 4,
      freeAgents: [freeAgent],
      negotiations: [waiting],
    );
    final resolved = ContractMarketService(
      balance: balance,
    ).resolveHour(input, hour: 4, saveSeed: 42);
    final counter = resolved.negotiationById(waiting.id)!;
    expect(counter.status, NegotiationStatus.counter);
    expect(counter.round, 2);
    expect(counter.expiryHour, 7);
    expect(counter.waitingUntilHour, isNull);
  });

  test('development compatibility API uses configured neutral atmosphere', () {
    const balance = BalanceConfig(
      development: DevelopmentBalance(atmosphereNeutral: 60),
    );
    final service = DevelopmentService(balance: balance);
    final p = player.copyWith(
      personality: PlayerPersonality.balanced,
      state: player.state.copyWith(form: 6, minutesThisWeek: 0),
    );
    expect(
      service.developPlayer(p),
      service.developPlayerWithContext(p, atmosphere: 60).player,
    );
    expect(const PlayerMatchStats(playerId: 'p').rating, 6);
    expect(const PlayerSeasonStats(year: 2026).ratingAvg, 6);
  });
}
