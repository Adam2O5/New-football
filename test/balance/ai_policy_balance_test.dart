import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/ai/ai_draft_service.dart';
import 'package:new_football/core/ai/ai_evaluation_context.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/ai/ai_evaluation_service.dart';
import 'package:new_football/core/ai/ai_matchday_models.dart';
import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/ai/ai_trade_models.dart';
import 'package:new_football/core/ai/ai_trade_service.dart';
import 'package:new_football/core/ai/team_ai_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/trade_service.dart';
import 'package:new_football/core/simulation/match_engine.dart';

class _CountingContracts extends ContractService {
  _CountingContracts(BalanceConfig balance) : super(balance: balance);
  int validations = 0;
  @override
  ContractOfferValidation validateOffer({
    required Team team,
    required Player player,
    required ContractOffer offer,
  }) {
    validations++;
    return super.validateOffer(team: team, player: player, offer: offer);
  }
}

void main() {
  final league = GameFactory()
      .create(
        const NewGameRequest(
          saveName: 'AI policy balance',
          playerTeamId: 'team_europe_0',
          seed: 42,
        ),
      )
      .leagueState;
  final aiTeam = league.teams.firstWhere((t) => t.ai != null);
  final opponent = league.teams.firstWhere((t) => t.id != aiTeam.id);
  final source = aiTeam.roster.reduce(
    (a, b) => a.overall() >= b.overall() ? a : b,
  );
  Player player(int age, {String id = 'policy-player'}) => source.copyWith(
    id: id,
    age: age,
    pointValue: 240,
    potentialStars: 5,
    contract: source.contract.copyWith(
      salary: 1000000,
      yearsRemaining: 1,
      firstSeason: 2026,
      lastSeason: 2026,
      isRookieScale: false,
      noTradeClause: false,
      blockedTeamIds: [],
    ),
    state: source.state.copyWith(
      seasonsWithTeam: 3,
      injury: null,
      suspensionGamesRemaining: 0,
    ),
  );
  BalanceConfig terms(int preferred, {AiBalance ai = const AiBalance()}) =>
      BalanceConfig(
        ai: ai,
        contracts: ContractNegBalance(
          playerLengthTable: [
            (null, [preferred, preferred, preferred]),
          ],
        ),
      );

  for (final age in [32, 33]) {
    for (final preferred in [1, 2, 5]) {
      test(
        'age $age extension and counter respect preference $preferred and shared senior cap',
        () {
          final balance = terms(preferred);
          final p = player(age);
          final team = aiTeam.copyWith(roster: [p]);
          final input = league.updateTeam(team);
          final contracts = ContractService(balance: balance);
          final policy = AiContractMarketService(balance: balance);
          final expected = age == 33 ? min(preferred, 2) : preferred;
          expect(contracts.expectedLength(p), preferred);
          final plan = policy.extensionPlan(
            league: input,
            team: team,
            player: p,
            saveSeed: 42,
          );
          expect(plan, isNotNull);
          expect(plan!.offer.years, expected);
          final counter = policy.extensionCounterOffer(
            league: input,
            team: team,
            player: p,
            original: const ContractOffer(
              salary: 1000000,
              years: 5,
              exception: CapExceptionType.fullBirdRights,
            ),
            playerCounter: ContractOffer(
              salary: 1000000,
              years: preferred,
              exception: CapExceptionType.fullBirdRights,
            ),
            saveSeed: 42,
          );
          expect(counter, isNotNull);
          expect(counter!.years, expected);
        },
      );
    }

    test('age $age FA-I, FA-II and repair offers obey the same cap', () {
      final balance = terms(
        5,
        ai: const AiBalance(
          faPhaseOneOfferProbabilities: [1],
          faPositionMaxProbability: 1,
          faPhaseTwoNeedRosterThreshold: 100,
          rosterEmergencyOfferYears: 4,
        ),
      );
      final p = player(age, id: 'fa-$age').copyWith(
        contract: source.contract.copyWith(
          salary: 1000000,
          yearsRemaining: 0,
          isRookieScale: false,
        ),
      );
      final input = league.copyWith(
        freeAgents: [p],
        currentWeek: 47,
        currentDay: 1,
        currentHour: 1,
      );
      final policy = AiContractMarketService(balance: balance);
      final phaseOne = policy.phaseOnePlayerPlan(
        league: input,
        team: aiTeam,
        hour: 1,
        saveSeed: 42,
      );
      final phaseTwo = policy.phaseTwoPlayerPlan(
        league: input,
        team: aiTeam,
        saveSeed: 42,
      );
      expect(phaseOne, isNotNull);
      expect(phaseTwo, isNotNull);
      expect(phaseOne!.offer.years, age == 33 ? 2 : 5);
      expect(phaseTwo!.offer.years, age == 33 ? 2 : 5);
      final repairTeam = aiTeam.copyWith(roster: [aiTeam.roster.first]);
      final repaired = policy.phaseTwoPlayerPlan(
        league: input.updateTeam(repairTeam),
        team: repairTeam,
        saveSeed: 42,
      );
      expect(repaired, isNotNull);
      expect(repaired!.offer.years, age == 33 ? 2 : 4);
    });
  }

  test('senior threshold and maximum are read by actual extension offers', () {
    final balance = terms(
      5,
      ai: const AiBalance(seniorContractAge: 32, faAge33MaxYears: 1),
    );
    final p = player(32);
    final team = aiTeam.copyWith(roster: [p]);
    final plan = AiContractMarketService(balance: balance).extensionPlan(
      league: league.updateTeam(team),
      team: team,
      player: p,
      saveSeed: 42,
    );
    expect(plan!.offer.years, 1);
  });

  test('helper FA offers keep both RNG draws and apply senior policy', () {
    final balance = terms(5);
    final contracts = ContractService(balance: balance);
    final normal = TeamAiService(balance: balance, random: Random(42));
    final senior = TeamAiService(balance: balance, random: Random(42));
    final first = normal.makeFaOffer(player(32), contracts);
    final capped = senior.makeFaOffer(player(33), contracts);
    expect(capped.years, 2);
    expect(first.years, greaterThan(2));
    expect(capped.salary, first.salary);
    final nextA = normal.makeFaOffer(player(32), contracts);
    final nextB = senior.makeFaOffer(player(32), contracts);
    expect((nextB.salary, nextB.years), (nextA.salary, nextA.years));
  });

  test('actual emergency signings cap AI seniors and preserve human terms', () {
    const balance = BalanceConfig(ai: AiBalance(rosterEmergencyOfferYears: 4));
    final p = player(33).copyWith(
      contract: source.contract.copyWith(salary: 1000000, yearsRemaining: 0),
    );
    final team = aiTeam.copyWith(roster: []);
    final input = league.copyWith(
      teams: [team],
      freeAgents: [p],
      playerTeamId: null,
    );
    final service = ContractMarketService(balance: balance);
    final result = service.signEmergencyFreeAgent(
      input,
      teamId: team.id,
      saveSeed: 42,
    );
    expect(result!.teams.single.roster.single.contract.yearsRemaining, 2);
    final human = team.copyWith(ai: null);
    final humanResult = service.signEmergencyFreeAgent(
      input.copyWith(teams: [human]),
      teamId: team.id,
      saveSeed: 42,
    );
    expect(humanResult!.teams.single.roster.single.contract.yearsRemaining, 4);
  });

  test(
    'senior QO stores and reports capped AI terms while human QO stays unchanged',
    () {
      final p = player(
        33,
      ).copyWith(contract: player(33).contract.copyWith(isRookieScale: true));
      final team = aiTeam.copyWith(roster: [p]);
      final input = league.copyWith(
        teams: [team],
        currentWeek: 46,
        currentDay: 2,
      );
      final service = ContractMarketService();
      final result = service.submitQualifyingOffer(
        league: input,
        ownerTeamId: team.id,
        playerId: p.id,
        years: 3,
      );
      expect(result, isNotNull);
      expect(result!.rfaQualifyingOffers.single.years, 2);
      expect(
        result.inbox.messages
            .firstWhere((m) => m.kind == 'rfaQualifyingOffer')
            .payload['years'],
        2,
      );
      final human = service.submitQualifyingOffer(
        league: input.copyWith(teams: [team.copyWith(ai: null)]),
        ownerTeamId: team.id,
        playerId: p.id,
        years: 3,
      );
      expect(human!.rfaQualifyingOffers.single.years, 3);
    },
  );

  test(
    'AI declines a senior offer sheet it cannot match within the shared term cap',
    () {
      const balance = BalanceConfig(
        ai: AiBalance(
          rfaMatchCostMultiplier: 10000,
          pMatchOfferSheetTop11: 1,
          rfaMatchDepthProbability: 1,
          rfaMatchSurplusProbability: 1,
        ),
      );
      final p = player(33);
      final team = aiTeam.copyWith(roster: [p]);
      final input = league.updateTeam(team);
      final sheet = RfaOfferSheet(
        id: 'sheet',
        playerId: p.id,
        originalTeamId: team.id,
        offeringTeamId: opponent.id,
        salary: 1000000,
        years: 2,
        phase: NegotiationPhase.freeAgencyPhaseI,
        seasonYear: 2026,
        week: 47,
        expirySeasonYear: 2026,
        expiryWeek: 47,
      );
      final policy = AiContractMarketService(balance: balance);
      expect(
        policy.shouldMatchOfferSheet(league: input, sheet: sheet, saveSeed: 42),
        isTrue,
      );
      expect(
        policy.shouldMatchOfferSheet(
          league: input,
          sheet: sheet.copyWith(years: 3),
          saveSeed: 42,
        ),
        isFalse,
      );
      final younger = input.updateTeam(
        team.copyWith(roster: [p.copyWith(age: 32)]),
      );
      expect(
        policy.shouldMatchOfferSheet(
          league: younger,
          sheet: sheet.copyWith(years: 3),
          saveSeed: 42,
        ),
        isTrue,
      );
    },
  );

  test('actual draft-right signing applies the AI senior cap', () {
    const balance = BalanceConfig(
      salaryCap: SalaryCapBalance(rookieScaleYears: 3),
    );
    final p = player(33).copyWith(
      contract: source.contract.copyWith(
        salary: balance.salaryCap.rookieSalaryForPick(1),
        yearsRemaining: 3,
        isRookieScale: true,
        rookiePickSlot: 1,
      ),
    );
    final team = aiTeam.copyWith(roster: []);
    final right = DraftedPlayerRights(
      id: 'right',
      ownerTeamId: team.id,
      player: p,
      draftYear: 2026,
      pickNumber: 1,
    );
    final input = league.copyWith(teams: [team], draftedRights: [right]);
    final result = ContractMarketService(
      balance: balance,
    ).signDraftedRight(input, right.id, saveSeed: 42);
    expect(result, isNotNull);
    expect(result!.teams.single.roster.single.contract.yearsRemaining, 2);
    expect(result.draftedRights, isEmpty);
  });

  test('salary search budget limits real legal-offer evaluations', () {
    final p = player(32);
    final team = aiTeam.copyWith(roster: [p]);
    for (final steps in [2, 80]) {
      final balance = terms(2, ai: AiBalance(playerSalarySearchSteps: steps));
      final contracts = _CountingContracts(balance);
      final plan =
          AiContractMarketService(
            balance: balance,
            contracts: contracts,
          ).extensionPlan(
            league: league.updateTeam(team),
            team: team,
            player: p,
            saveSeed: 42,
          );
      expect(plan, isNotNull);
      expect(contracts.validations, steps + 1);
    }
  });

  test('pair and package budgets limit the actual weekly market search', () {
    final teams = league.teams.where((t) => t.ai != null).take(3).toList();
    final input = league.copyWith(
      teams: teams,
      playerTeamId: null,
      currentWeek: 1,
      currentDay: 1,
    );
    for (final limit in [0, 1]) {
      final balance = BalanceConfig(
        ai: AiBalance(
          aiTradeCandidatePairs: limit,
          aiTradePackagesPerPair: 1,
          tradeEligibleAppetiteMin: 0,
        ),
      );
      final result = AiTradeService(
        balance: balance,
      ).runWeeklyTick(input, saveSeed: 42);
      expect(result.candidatePairs, limit);
      expect(result.testedPackages, lessThanOrEqualTo(limit));
      if (limit == 1) expect(result.testedPackages, 1);
    }
  });

  AiPackageEvaluation packageEvaluation(double surplus) => AiPackageEvaluation(
    incoming: [],
    outgoing: [],
    inValue: 102,
    outValue: 100,
    netValue: 2,
    rawSurplusPct: surplus,
    surplusPct: surplus,
    evaluationNoisePp: 0,
    apronPenalty: 0,
    resultingPayroll: 0,
    secondApronBlocked: false,
    secondApronRoll: null,
  );

  test(
    'mutual surplus percentage reads the same .02 owner and accepts equality',
    () {
      final proposal = TradeProposal(
        teamAId: aiTeam.id,
        teamBId: opponent.id,
        assetsFromA: [],
        assetsFromB: [],
      );
      final a = packageEvaluation(2);
      final b = packageEvaluation(2.1);
      expect(
        AiTradePackage(
          proposal: proposal,
          teamAEvaluation: a,
          teamBEvaluation: b,
        ).isMutuallyBeneficial,
        isTrue,
      );
      const balance = BalanceConfig(ai: AiBalance(aiTradeMutualMin: 0.025));
      expect(
        AiTradePackage(
          proposal: proposal,
          teamAEvaluation: a,
          teamBEvaluation: b,
          mutualMinSurplusPct: balance.ai.aiTradeMutualMin * 100,
        ).isMutuallyBeneficial,
        isFalse,
      );
    },
  );

  test(
    'matchday readiness, context and bench composition use policy configuration',
    () {
      const balance = BalanceConfig(
        ai: AiBalance(
          staminaReadinessFullMin: 90,
          matchdayShortRestMatchCount: 3,
          meaninglessFirstWeek: 5,
          meaninglessLastWeek: 6,
          benchGoalkeepers: 2,
        ),
      );
      final keeper = aiTeam.roster.firstWhere((p) => p.position == Position.gk);
      final benchTeam = aiTeam.copyWith(
        roster: [
          ...aiTeam.roster,
          for (final id in ['third-gk', 'fourth-gk'])
            keeper.copyWith(
              id: id,
              attributes: const PlayerAttributes.goalkeeper(
                stats: GoalkeeperAttributes(
                  diving: 1,
                  handling: 1,
                  kicking: 1,
                  reflexes: 1,
                  speed: 1,
                  positioning: 1,
                ),
              ),
              state: keeper.state.copyWith(
                injury: null,
                suspensionGamesRemaining: 0,
              ),
            ),
        ],
      );
      final service = AiMatchdayService(balance: balance);
      expect(service.staminaReadiness(85), balance.ai.staminaReadinessGood);
      expect(AiMatchdayService().staminaReadiness(85), 1);
      final context = service.contextForTeam(
        team: benchTeam,
        opponent: opponent,
        matchId: 'context',
        matchContext: MatchContext(
          homeTeamId: aiTeam.id,
          awayTeamId: opponent.id,
          homeMatchInWeek: 2,
        ),
        saveSeed: 42,
        seasonYear: 2026,
        week: 5,
      );
      expect(context.nextMatchWithinThreeDays, isFalse);
      expect(context.mathematicallyMeaningless, isTrue);
      final plan = service.planForTeam(context);
      final goalkeepers = plan.benchPlayerIds.where(
        (id) =>
            benchTeam.roster.firstWhere((p) => p.id == id).position ==
            Position.gk,
      );
      expect(goalkeepers, hasLength(2));
    },
  );

  test(
    'configured critical-stamina minute causes a real live substitution',
    () {
      const balance = BalanceConfig(
        ai: AiBalance(
          subCriticalMinute: 10,
          subCriticalStamina: 40,
          pSubstitutionStaminaCritical: 1,
          subLowMinute: 99,
          subRatingMinute: 99,
          subYellowMinute: 99,
        ),
        matchday: MatchdayBalance(injuryBase: 0, sequenceBase: 0),
      );
      final service = AiMatchdayService(balance: balance);
      final context = service.contextForTeam(
        team: aiTeam,
        opponent: opponent,
        matchId: 'sub',
        matchContext: const MatchContext(),
        saveSeed: 42,
        seasonYear: 2026,
        week: 1,
      );
      final runtime = AiMatchdayRuntime(plan: service.planForTeam(context));
      final live = SimulationMatchEngine(
        balance: balance,
      ).start(home: aiTeam, away: opponent, rngSeed: 42);
      final outgoing = live.state.homeLineup.firstWhere(
        (p) => p.position != Position.gk,
      );
      live.runtime.staminaRemaining[outgoing.id] = 39;
      live.runtime.state = live.state.copyWith(minute: 9);
      service.applyInMatchDecisions(
        live: live,
        runtime: runtime,
        homeSide: true,
      );
      expect(live.homeSubsUsed, 0);
      live.runtime.state = live.state.copyWith(minute: 10);
      service.applyInMatchDecisions(
        live: live,
        runtime: runtime,
        homeSide: true,
      );
      expect(live.homeSubsUsed, 1);
      expect(live.state.homeLineup.any((p) => p.id == outgoing.id), isFalse);
    },
  );

  test('need, overpayment and drag parameters reach real asset valuation', () {
    const balance = BalanceConfig(
      tradeValue: TradeValueBalance(
        assetSalaryMin: 1000000,
        assetSalaryMax: 1000000,
      ),
      ai: AiBalance(
        contractDragBurden: 8,
        overpaidSalaryRatio: 5,
        needBelowMinBase: 11,
        needBelowMinPerPlayer: 2,
        needQualityGapWeight: 0,
      ),
    );
    final p = player(32).copyWith(
      contract: player(
        32,
      ).contract.copyWith(salary: 4000000, yearsRemaining: 3),
    );
    final team = aiTeam.copyWith(roster: [p]);
    const evaluator = AiEvaluationService(balance: balance);
    final context = evaluator.contextForTeam(team: team, saveSeed: 42);
    final need = evaluator
        .rosterNeeds(context)
        .firstWhere(
          (n) =>
              n.definition.group == AiRosterGroup.gk &&
              !n.definition.contains(p.position),
          orElse: () =>
              evaluator.rosterNeeds(context).firstWhere((n) => n.count == 0),
        );
    expect(need.gapPenalty, 11 + need.definition.min * 2);
    expect(evaluator.contractDrag(p), 9);
    expect(evaluator.contractDragClass(p), AiContractDragClass.burden);
    expect(
      evaluator.evaluatePlayer(p, context).contextFactors,
      isNot(contains('overpaidContract')),
    );
    expect(
      const AiEvaluationService(
        balance: BalanceConfig(
          tradeValue: TradeValueBalance(
            assetSalaryMin: 1000000,
            assetSalaryMax: 1000000,
          ),
        ),
      ).evaluatePlayer(p, context).contextFactors,
      contains('overpaidContract'),
    );
  });

  test(
    'draft target is 26, legal maximum stays separate, and round reserves can change',
    () {
      expect(league.teams.every((t) => t.roster.length == 26), isTrue);
      expect(BalanceConfig.defaults.ai.rosterTargetTotal, 26);
      final at25 = aiTeam.copyWith(roster: aiTeam.roster.take(25).toList());
      final normal = AiDraftService();
      expect(
        normal
            .undraftedSigningDecision(
              team: at25,
              prospectId: 'target',
              needBand: AiNeedBand.critical,
            )
            .probability,
        0.6,
      );
      expect(
        normal
            .undraftedSigningDecision(
              team: aiTeam,
              prospectId: 'target',
              needBand: AiNeedBand.critical,
            )
            .probability,
        0.05,
      );
      final configured = AiDraftService(
        balance: const BalanceConfig(
          ai: AiBalance(rosterTargetTotal: 27, draftRoundThreeReservedSlots: 0),
        ),
      );
      expect(
        configured
            .undraftedSigningDecision(
              team: aiTeam,
              prospectId: 'target',
              needBand: AiNeedBand.critical,
            )
            .probability,
        0.6,
      );
      final at28 = aiTeam.copyWith(
        roster: [
          ...aiTeam.roster,
          player(23, id: 'extra1'),
          player(24, id: 'extra2'),
        ],
      );
      expect(
        normal
            .draftedSigningDecision(
              team: at28,
              round: 3,
              prospectId: 'round',
              needScore: 1,
            )
            .probability,
        0,
      );
      expect(
        configured
            .draftedSigningDecision(
              team: at28,
              round: 3,
              prospectId: 'round',
              needScore: 1,
            )
            .probability,
        0.55,
      );
      expect(BalanceConfig.defaults.roster.maxSize, 30);
    },
  );

  test(
    'draft proxy curve, score weights and default calendar week reach the board',
    () {
      const balance = BalanceConfig(
        calendar: CalendarBalance(draftWeek: 40),
        ai: AiBalance(
          draftOverallWeight: 1,
          draftPotentialWeight: 0,
          draftScoreNoiseSd: 0,
          draftProxyOverallMin: 70,
          draftProxyOverallMax: 70,
          draftProxyOverallSpread: 0,
          draftProxyPotentialMin: 2,
          draftProxyPotentialMax: 2,
          draftProxyPotentialSpread: 0,
          draftNeedBonuses: {},
        ),
      );
      final prospects = SeedDataGenerator()
          .generateDraftClass(year: 2026, seed: 42)
          .prospects
          .take(10)
          .toList();
      final team = aiTeam.copyWith(staff: const TeamStaff());
      final service = AiDraftService(balance: balance);
      final implicit = service.buildBoard(
        team: team,
        prospects: prospects,
        saveSeed: 42,
      );
      final explicit = service.buildBoard(
        team: team,
        prospects: prospects,
        saveSeed: 42,
        week: 40,
      );
      expect(implicit.map((e) => e.score), everyElement(70));
      expect(implicit.map((e) => e.estimatedPotentialStars), everyElement(2));
      expect(
        implicit.map((e) => (e.prospect.id, e.perceivedMockRank)),
        explicit.map((e) => (e.prospect.id, e.perceivedMockRank)),
      );
    },
  );

  test(
    'trade appetite weights and deadline proximity use balance and calendar owners',
    () {
      const balance = BalanceConfig(
        calendar: CalendarBalance(tradeDeadlineWeek: 10),
        ai: AiBalance(
          tradeNeedAppetiteWeight: 1,
          tradeSurplusAppetiteWeight: 0,
          tradeDeadlineAppetiteWeight: 0,
          tradeInjuryAppetiteWeight: 0,
          tradeDeadlineAppetiteMultiplier: 1,
          superteamBrakeThreshold: 10000,
        ),
      );
      final input = league.copyWith(currentWeek: 9);
      final appetite = AiTradeService(
        balance: balance,
      ).appetiteForTeam(league: input, team: aiTeam);
      expect(appetite.deadlineProximity, 1);
      expect(appetite.value, closeTo(appetite.maxNeedScore / 100, 1e-12));
      expect(
        AiTradeService()
            .appetiteForTeam(league: input, team: aiTeam)
            .deadlineProximity,
        0,
      );
    },
  );

  test('AI NTC value stays independent from trade asset valuation', () {
    const balance = BalanceConfig(ai: AiBalance(ntcMult: 0.5));
    final p = player(32).copyWith(
      contract: player(
        32,
      ).contract.copyWith(noTradeClause: true, yearsRemaining: 3),
    );
    final context = AiEvaluationContext(
      team: aiTeam,
      teamStatus: TeamStatus.pretender,
      expectedRank: 15,
    );
    final value = const AiEvaluationService(
      balance: balance,
    ).evaluatePlayer(p, context);
    expect(value.contextMult, 0.5);
    expect(balance.tradeValue.ntcAssetMultiplier, 0.75);
  });
}
