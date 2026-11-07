import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_draft_service.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/core/services/trade_service.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(seed: 42);
  final team = league.teams.first;
  final source = team.roster.first;
  const member = StaffMember(
    id: 'staff',
    name: 'Staff',
    nationality: Nationality.poland,
    age: 40,
    role: StaffRole.headCoach,
    attributes: StaffAttributes(tactics: 2, motivation: 2),
  );

  test(
    'player demand, salary curve and age-length table use separate contract knobs',
    () {
      const balance = BalanceConfig(
        contracts: ContractNegBalance(
          playerWantOffset: 500,
          playerWantDivisor: 10,
          playerPersonalityWant: {PlayerPersonality.ambitious: 20},
          playerSalaryExponent: 1,
          lengthWantThresholds: [20, 60],
          playerLengthTable: [
            (24, [1, 1, 2]),
            (null, [1, 1, 1]),
          ],
        ),
      );
      final p = source.copyWith(
        pointValue: 0,
        age: 22,
        personality: PlayerPersonality.ambitious,
      );
      final service = ContractService(balance: balance);
      expect(service.playerWant(p), 70);
      expect(service.expectedSalary(p), 42300000);
      expect(service.expectedLength(p), 2);
      expect(service.expectedLength(p.copyWith(age: 25)), 1);
      expect(ContractService().playerWant(p), 55);
    },
  );

  test(
    'player bounds reach validation and counters, including direct service calls',
    () {
      const balance = BalanceConfig(
        contracts: ContractNegBalance(
          playerMaxYears: 2,
          playerLengthTable: [
            (null, [5, 5, 5]),
          ],
        ),
      );
      final service = ContractService(balance: balance);
      final counter = service.counterOfferForRound(
        source,
        const ContractOffer(salary: 1000000, years: 1),
        round: 1,
      );
      expect(counter!.years, 2);
      expect(
        service
            .validateOffer(
              team: team,
              player: source,
              offer: const ContractOffer(salary: 1000000, years: 3),
            )
            .ok,
        isFalse,
      );
      expect(
        ContractService()
            .validateOffer(
              team: team,
              player: source,
              offer: const ContractOffer(salary: 1000000, years: 6),
            )
            .ok,
        isFalse,
      );
    },
  );

  test(
    'staff demand and table retain their own curve and enforce configured years in sign and market',
    () {
      const balance = BalanceConfig(
        staff: StaffBalance(
          wantPerStar: 10,
          maxContractYears: 2,
          desiredLengthTable: [
            (45, [1, 2, 2]),
            (null, [1, 1, 1]),
          ],
        ),
        contracts: ContractNegBalance(lengthWantThresholds: [10, 30]),
      );
      final service = StaffService(balance: balance);
      expect(service.staffWant(member), 20);
      expect(service.expectedSalary(member), 680000);
      expect(service.expectedLength(member), 2);
      expect(service.expectedLength(member.copyWith(age: 46)), 1);
      final empty = team.copyWith(staff: const TeamStaff(), ai: null);
      expect(
        service.sign(
          team: empty,
          member: member,
          offer: const StaffOffer(salary: 1000000, years: 2),
        ),
        isNotNull,
      );
      expect(
        service.sign(
          team: empty,
          member: member,
          offer: const StaffOffer(salary: 1000000, years: 3),
        ),
        isNull,
      );
      final input = league.copyWith(
        teams: [empty],
        playerTeamId: empty.id,
        staffFreeAgents: [member],
        currentWeek: 47,
        currentDay: 1,
        currentHour: 1,
      );
      final market = ContractMarketService(balance: balance);
      expect(
        market.submitStaffOffer(
          league: input,
          candidate: member,
          offer: const StaffOffer(salary: 1000000, years: 3),
          saveSeed: 42,
        ),
        isNull,
      );
      expect(
        market.submitStaffOffer(
          league: input,
          candidate: member,
          offer: const StaffOffer(salary: 1000000, years: 2),
          saveSeed: 42,
        ),
        isNotNull,
      );
    },
  );

  test(
    'cap exception amounts, service thresholds and lengths read their owners',
    () {
      const balance = BalanceConfig(
        salaryCap: SalaryCapBalance(
          earlyBirdSeasons: 3,
          earlyBirdSalaryMultiplier: 1.5,
          earlyBirdMaxSalaryShare: 0.5,
          earlyBirdMaxYears: 2,
          nonBirdSalaryMultiplier: 1.1,
          nonBirdMaxYears: 3,
          veteranExtensionMultiplier: 1.05,
          midLevelMaxYears: 1,
        ),
        contracts: ContractNegBalance(playerMaxYears: 4),
      );
      const service = SalaryCapService(balance: balance);
      final p = source.copyWith(
        contract: source.contract.copyWith(
          salary: 10000000,
          isRookieScale: false,
        ),
        state: source.state.copyWith(seasonsWithTeam: 3),
      );
      final early = service.validateExceptionOffer(
        player: p,
        exception: CapExceptionType.earlyBirdRights,
        salary: 15000000,
        years: 2,
      );
      expect(early.ok, isTrue);
      expect(early.terms!.maxSalary, 15000000);
      expect(early.terms!.maxYears, 2);
      expect(
        service
            .validateExceptionOffer(
              player: p,
              exception: CapExceptionType.earlyBirdRights,
              salary: 15000001,
              years: 2,
            )
            .ok,
        isFalse,
      );
      expect(
        service
            .validateExceptionOffer(
              player: p,
              exception: CapExceptionType.earlyBirdRights,
              salary: 15000000,
              years: 3,
            )
            .ok,
        isFalse,
      );
      final nonBird = service.validateExceptionOffer(
        player: p.copyWith(state: p.state.copyWith(seasonsWithTeam: 2)),
        exception: CapExceptionType.nonBirdRights,
        salary: 11000000,
        years: 3,
      );
      expect(nonBird.ok, isTrue);
      expect(nonBird.terms!.maxSalary, 11000000);
      expect(
        service
            .validateExceptionOffer(
              player: p,
              exception: CapExceptionType.veteranExtensionRaiseCap,
              salary: 10500000,
              years: 4,
            )
            .terms!
            .maxSalary,
        10500000,
      );
      expect(
        service
            .validateExceptionOffer(
              player: p,
              exception: CapExceptionType.midLevelException,
              salary: 1000000,
              years: 2,
            )
            .ok,
        isFalse,
      );
      expect(
        service
            .validateExceptionOffer(
              player: p,
              exception: CapExceptionType.fullBirdRights,
              salary: 1000000,
              years: 5,
            )
            .ok,
        isFalse,
      );
    },
  );

  test('NTC eligibility and roll apply at the actual signing boundary', () {
    const balance = BalanceConfig(
      contracts: ContractNegBalance(
        ntcAgeMin: 29,
        ntcSeasonsMin: 3,
        ntcPointValueMin: 100,
        ntcYearsMin: 1,
        ntcSigningChance: 1,
      ),
    );
    final p = source.copyWith(
      age: 29,
      pointValue: 100,
      state: source.state.copyWith(seasonsWithTeam: 3),
      contract: source.contract.copyWith(salary: 1000000, noTradeClause: false),
    );
    const offer = ContractOffer(salary: 1000000, years: 1);
    final service = ContractService(balance: balance);
    expect(ContractService().isNtcEligible(p, offer), isFalse);
    expect(service.isNtcEligible(p, offer), isTrue);
    expect(service.isNtcEligible(p.copyWith(age: 28), offer), isFalse);
    final signed = service.signPlayer(
      team: team.copyWith(roster: [p]),
      player: p,
      offer: offer,
      ntcRandom: Random(42),
    );
    expect(signed!.roster.single.contract.noTradeClause, isTrue);
    final never = ContractService(
      balance: const BalanceConfig(
        contracts: ContractNegBalance(ntcSigningChance: 0),
      ),
    );
    final eligible = p.copyWith(
      age: 30,
      pointValue: 200,
      state: p.state.copyWith(seasonsWithTeam: 4),
    );
    expect(
      never
          .signPlayer(
            team: team.copyWith(roster: [eligible]),
            player: eligible,
            offer: const ContractOffer(salary: 1000000, years: 2),
            ntcRandom: Random(42),
          )!
          .roster
          .single
          .contract
          .noTradeClause,
      isFalse,
    );
  });

  test('NTC consent preserves separate context bonuses and clamps', () {
    const balance = BalanceConfig(
      contracts: ContractNegBalance(
        ntcConsentBase: 0.4,
        ntcHigherStatusBonus: 0.1,
        ntcLowerStatusPenalty: 0.2,
        ntcTransferRequestBonus: 0.2,
        ntcLoyalPenalty: 0.05,
        ntcAmbitiousBetterRankBonus: 0.03,
        ntcLowAtmosphereBonus: 0.1,
        ntcConsentMin: 0.2,
        ntcConsentMax: 0.8,
      ),
    );
    final p = source.copyWith(personality: PlayerPersonality.loyal);
    final home = team.copyWith(
      atmosphere: 30,
      eventState: TeamEventState(
        transferSituations: [
          TeamTransferSituation(
            id: 'request',
            playerId: p.id,
            kind: 'transferRequestI',
            createdSeasonYear: 2026,
            createdWeek: 1,
          ),
        ],
      ),
    );
    final destination = league.teams[1];
    final input = league.copyWith(
      strengthTable: LeagueStrengthTable(
        lastCalculatedWeek: 1,
        entries: [
          TeamStrengthEntry(
            teamId: home.id,
            teamPower: 70,
            expectedRank: 5,
            teamStatus: TeamStatus.pretender,
          ),
          TeamStrengthEntry(
            teamId: destination.id,
            teamPower: 90,
            expectedRank: 1,
            teamStatus: TeamStatus.elite,
          ),
        ],
      ),
    );
    final service = TradeService(balance: balance);
    expect(
      service.ntcConsentProbability(
        league: input,
        source: home,
        destination: destination,
        player: p,
      ),
      closeTo(0.75, 1e-9),
    );
    expect(
      service.ntcConsentProbability(
        league: input,
        source: home,
        destination: destination,
        player: p.copyWith(personality: PlayerPersonality.ambitious),
      ),
      0.8,
    );
  });

  test('trade NTC valuation is independent of the AI multiplier', () {
    const balance = BalanceConfig(
      tradeValue: TradeValueBalance(ntcAssetMultiplier: 0.5),
    );
    final p = source.copyWith(
      contract: source.contract.copyWith(noTradeClause: true),
    );
    final actual = TradeService(balance: balance).assetValue(
      team.copyWith(roster: [p]),
      TradeAsset.player(p.id),
      currentYear: 2026,
    );
    expect(actual, (p.computePointValue(balance) * 0.5).round());
    expect(balance.ai.ntcMult, 0.92);
    expect(BalanceConfig.defaults.tradeValue.ntcAssetMultiplier, 0.75);
  });

  test(
    'undrafted offer metadata and emergency signing read configured terms',
    () {
      const balance = BalanceConfig(
        draft: DraftBalance(undraftedContractYears: 3),
        salaryCap: SalaryCapBalance(minSalary: 2000000),
        contracts: ContractNegBalance(playerMaxYears: 3),
      );
      final decision = AiDraftService(balance: balance)
          .undraftedSigningDecision(
            team: team,
            prospectId: 'undrafted',
            needBand: AiNeedBand.critical,
            saveSeed: 42,
          );
      expect(decision.salary, 2000000);
      expect(decision.years, 3);
      final p = source.copyWith(
        contract: source.contract.copyWith(yearsRemaining: 0),
      );
      final input = league.copyWith(
        teams: [team.copyWith(roster: [], ai: null)],
        freeAgents: [p],
      );
      final signed = ContractMarketService(
        balance: balance,
      ).signEmergencyFreeAgent(input, teamId: team.id, years: 8, saveSeed: 42);
      expect(signed!.teams.single.roster.single.contract.yearsRemaining, 3);
      expect(signed.teams.single.roster.single.contract.salary, 2000000);
    },
  );
}
