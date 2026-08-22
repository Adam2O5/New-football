import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/trade_service.dart';

void main() {
  const balance = BalanceConfig.defaults;
  final market = ContractMarketService();

  LeagueState leagueAt({required int week, required int day, int? hour}) {
    return SeedDataGenerator()
        .generateLeague(seed: 29)
        .copyWith(currentWeek: week, currentDay: day, currentHour: hour);
  }

  Player freeAgent(LeagueState league, String id) {
    final source = league.teams.first.roster.first;
    return source.copyWith(
      id: id,
      name: 'Task 29 $id',
      contract: source.contract.copyWith(
        yearsRemaining: 0,
        hasBirdRights: false,
        isRookieScale: false,
        rookiePickSlot: 0,
        exceptionType: null,
        noTradeClause: false,
        blockedTeamIds: const [],
      ),
      state: source.state.copyWith(seasonsWithTeam: 0),
    );
  }

  Player rookieFreeAgent(LeagueState league, String id) {
    final source = league.teams.first.roster.first;
    return source.copyWith(
      id: id,
      name: 'Task 29 Rookie $id',
      contract: source.contract.copyWith(
        salary: 8000000,
        yearsRemaining: 0,
        hasBirdRights: false,
        isRookieScale: true,
        rookiePickSlot: 1,
        exceptionType: null,
        noTradeClause: false,
        blockedTeamIds: const [],
      ),
      state: source.state.copyWith(seasonsWithTeam: 0),
    );
  }

  test('contract windows include the draft buffer and phase II wrap', () {
    final extensionStart = leagueAt(week: 46, day: 2, hour: 1);
    final extensionEnd = leagueAt(week: 46, day: 7, hour: 10);
    final phaseIStart = leagueAt(week: 47, day: 1, hour: 1);
    final phaseIEnd = leagueAt(week: 47, day: 7, hour: 10);
    final phaseIIStart = leagueAt(week: 48, day: 1);
    final phaseIIEnd = leagueAt(week: 45, day: 7);
    final draftBuffer = leagueAt(week: 46, day: 1);

    expect(market.windowAt(extensionStart), ContractMarketWindow.extensions);
    expect(market.windowAt(extensionEnd), ContractMarketWindow.extensions);
    expect(market.windowAt(phaseIStart), ContractMarketWindow.freeAgencyPhaseI);
    expect(market.windowAt(phaseIEnd), ContractMarketWindow.freeAgencyPhaseI);
    expect(
      market.windowAt(phaseIIStart),
      ContractMarketWindow.freeAgencyPhaseII,
    );
    expect(market.windowAt(phaseIIEnd), ContractMarketWindow.freeAgencyPhaseII);
    expect(market.windowAt(draftBuffer), ContractMarketWindow.closed);
    expect(market.phaseAt(draftBuffer), isNull);
  });

  test('QO uses the 1.25x rookie salary floor and supports RFA match', () {
    final base = leagueAt(week: 47, day: 1, hour: 1);
    final owner = base.playerTeam!;
    final player = rookieFreeAgent(base, 'task29-rfa');
    final state = base.copyWith(freeAgents: [player]);
    final floor = market.qualifyingOfferMinimum(player);

    expect(floor, 10000000);
    expect(
      market.submitQualifyingOffer(
        league: state,
        ownerTeamId: owner.id,
        playerId: player.id,
        salary: floor - 1,
      ),
      isNull,
    );

    final qualified = market.submitQualifyingOffer(
      league: state,
      ownerTeamId: owner.id,
      playerId: player.id,
      salary: floor,
      years: 1,
    );
    expect(qualified, isNotNull);
    expect(qualified!.rfaQualifyingOffers.single.salary, floor);

    final rival = qualified.teams.firstWhere((team) => team.id != owner.id);
    final sheetState = market.submitOfferSheet(
      league: qualified,
      offeringTeamId: rival.id,
      playerId: player.id,
      offer: ContractOffer(salary: floor + 1000000, years: 2),
    );
    expect(sheetState, isNotNull);
    final sheet = sheetState!.rfaOfferSheets.single;

    final matched = market.matchOfferSheet(sheetState, sheet.id, saveSeed: 29);
    expect(matched, isNotNull);
    expect(matched!.rfaOfferSheets.single.matched, isTrue);
    expect(
      matched.playerTeam!.roster.any((item) => item.id == player.id),
      isTrue,
    );
  });

  test('NTC roll is deterministic and statistically close to 20 percent', () {
    final base = leagueAt(week: 47, day: 1, hour: 1);
    final originalTeam = base.playerTeam!;
    final source = originalTeam.roster.first;
    final eligible = source.copyWith(
      age: 30,
      pointValue: 200,
      state: source.state.copyWith(seasonsWithTeam: 4),
      contract: source.contract.copyWith(
        salary: balance.salaryCap.minSalary,
        yearsRemaining: 1,
        noTradeClause: false,
        blockedTeamIds: const [],
      ),
    );
    final team = originalTeam.copyWith(
      roster: originalTeam.roster
          .map((item) => item.id == source.id ? eligible : item)
          .toList(),
    );
    final offer = ContractOffer(salary: balance.salaryCap.minSalary, years: 2);
    final service = ContractService();

    expect(service.isNtcEligible(eligible, offer), isTrue);
    final first = service.signPlayer(
      team: team,
      player: eligible,
      offer: offer,
      ntcRandom: Random(2901),
    );
    final second = service.signPlayer(
      team: team,
      player: eligible,
      offer: offer,
      ntcRandom: Random(2901),
    );
    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(
      first!.roster
          .firstWhere((item) => item.id == eligible.id)
          .contract
          .noTradeClause,
      second!.roster
          .firstWhere((item) => item.id == eligible.id)
          .contract
          .noTradeClause,
    );

    var granted = 0;
    for (var seed = 0; seed < 1000; seed++) {
      final signed = service.signPlayer(
        team: team,
        player: eligible,
        offer: offer,
        ntcRandom: Random(seed),
      );
      expect(signed, isNotNull);
      if (signed!.roster
          .firstWhere((item) => item.id == eligible.id)
          .contract
          .noTradeClause) {
        granted++;
      }
    }
    expect(granted, inInclusiveRange(120, 280));
  });

  test('signing a free agent is blocked when the roster already has 30', () {
    final base = leagueAt(week: 47, day: 1, hour: 1);
    final originalTeam = base.playerTeam!;
    final candidate = freeAgent(base, 'task29-full-roster');
    final fullRoster = [...originalTeam.roster];
    while (fullRoster.length < balance.roster.maxSize) {
      final filler = fullRoster.first.copyWith(
        id: 'task29-filler-${fullRoster.length}',
      );
      fullRoster.add(filler);
    }
    final fullTeam = originalTeam.copyWith(roster: fullRoster);
    final state = base.copyWith(
      teams: base.teams
          .map((team) => team.id == fullTeam.id ? fullTeam : team)
          .toList(),
      freeAgents: [candidate],
    );

    final result = market.submitPlayerOffer(
      league: state,
      playerId: candidate.id,
      offer: ContractOffer(salary: balance.salaryCap.minSalary, years: 1),
      saveSeed: 29,
    );
    expect(result, isNull);
    expect(state.negotiations, isEmpty);
  });

  test('phase II accepts multiple distinct player offers on one day', () {
    final base = leagueAt(week: 48, day: 1);
    final first = freeAgent(base, 'task29-phase2-a');
    final second = freeAgent(base, 'task29-phase2-b');
    final state = base.copyWith(freeAgents: [first, second]);
    const offer = ContractOffer(salary: 1000000, years: 1);

    final firstSubmission = market.submitPlayerOffer(
      league: state,
      playerId: first.id,
      offer: offer,
      saveSeed: 29,
    );
    expect(firstSubmission, isNotNull);

    final secondSubmission = market.submitPlayerOffer(
      league: firstSubmission!.league,
      playerId: second.id,
      offer: offer,
      saveSeed: 29,
    );
    expect(secondSubmission, isNotNull);
    expect(secondSubmission!.league.negotiations, hasLength(2));
  });

  test(
    'phase II negotiations cancel at the end without a hard-reject block',
    () {
      final base = leagueAt(week: 45, day: 7);
      final candidate = freeAgent(base, 'task29-phase2-expiry');
      final negotiationService = NegotiationService();
      final started = negotiationService.start(
        id: 'task29-phase2-expiry',
        subjectId: candidate.id,
        subjectKind: NegotiationSubjectKind.player,
        teamId: base.playerTeamId!,
        phase: NegotiationPhase.freeAgencyPhaseII,
        offer: const NegotiationOffer(salary: 1000000, years: 2),
        seasonYear: base.currentSeason.year,
        week: base.currentWeek,
        day: base.currentDay,
      );
      final pending = negotiationService.applyDecision(
        negotiation: started,
        decision: NegotiationDecision.accept,
        seasonYear: base.currentSeason.year,
        week: base.currentWeek,
        day: base.currentDay,
      );
      final state = base.copyWith(
        freeAgents: [candidate],
        negotiations: [pending],
      );

      final resolved = market.resolveDay(state, saveSeed: 29);
      expect(
        resolved.negotiationById(pending.id)!.status,
        NegotiationStatus.cancelled,
      );
      expect(resolved.negotiationBlocks, isEmpty);
    },
  );

  test('waiting lasts two hours and collapses to hour 10 from hour 9', () {
    final base = leagueAt(week: 47, day: 1, hour: 9);
    final team = base.playerTeam!;
    final candidate = freeAgent(base, 'task29-waiting');
    final isolated = base.copyWith(
      teams: [team],
      playerTeamId: team.id,
      freeAgents: [candidate],
    );
    final negotiationService = NegotiationService();
    final started = negotiationService.start(
      id: 'task29-waiting',
      subjectId: candidate.id,
      subjectKind: NegotiationSubjectKind.player,
      teamId: team.id,
      phase: NegotiationPhase.freeAgencyPhaseI,
      offer: const NegotiationOffer(salary: 1000000, years: 2),
      seasonYear: isolated.currentSeason.year,
      week: isolated.currentWeek,
      day: isolated.currentDay,
      hour: 9,
      offerScore: 80,
    );
    final waiting = negotiationService.applyDecision(
      negotiation: started,
      decision: NegotiationDecision.waiting,
      seasonYear: isolated.currentSeason.year,
      week: isolated.currentWeek,
      day: isolated.currentDay,
      hour: 9,
    );
    expect(waiting.waitingUntilHour, 10);

    final beforeDeadline = market.resolveHour(
      isolated.copyWith(negotiations: [waiting]),
      hour: 9,
      saveSeed: 29,
    );
    expect(
      beforeDeadline.negotiationById(waiting.id)!.status,
      NegotiationStatus.waiting,
    );

    final atDeadline = market.resolveHour(
      beforeDeadline.copyWith(currentHour: 10),
      hour: 10,
      saveSeed: 29,
    );
    expect(
      atDeadline.negotiationById(waiting.id)!.status,
      NegotiationStatus.pendingFinalization,
    );
  });

  test('higher user offer score beats an AI pending finalization', () {
    final base = leagueAt(week: 46, day: 2, hour: 1);
    final userTeam = base.playerTeam!;
    final aiTeam = base.teams.firstWhere((team) => !team.isPlayerControlled);
    final player = userTeam.roster.first;
    final negotiationService = NegotiationService();
    final user = negotiationService
        .start(
          id: 'task29-user-rank',
          subjectId: player.id,
          subjectKind: NegotiationSubjectKind.player,
          teamId: userTeam.id,
          phase: NegotiationPhase.contractExtension,
          offer: const NegotiationOffer(salary: 1000000, years: 2),
          seasonYear: base.currentSeason.year,
          week: base.currentWeek,
          day: base.currentDay,
          hour: 1,
          offerScore: 80,
        )
        .copyWith(
          status: NegotiationStatus.pendingFinalization,
          requiresFinalization: true,
        );
    final ai = negotiationService
        .start(
          id: 'task29-ai-rank',
          subjectId: player.id,
          subjectKind: NegotiationSubjectKind.player,
          teamId: aiTeam.id,
          phase: NegotiationPhase.contractExtension,
          offer: const NegotiationOffer(salary: 1000000, years: 2),
          seasonYear: base.currentSeason.year,
          week: base.currentWeek,
          day: base.currentDay,
          hour: 1,
          offerScore: 70,
          isAiOffer: true,
        )
        .copyWith(
          status: NegotiationStatus.pendingFinalization,
          requiresFinalization: true,
        );

    final resolved = market.resolveHour(
      base.copyWith(negotiations: [user, ai]),
      hour: 1,
      saveSeed: 29,
    );
    expect(
      resolved.negotiationById(user.id)!.status,
      NegotiationStatus.pendingFinalization,
    );
    expect(
      resolved.negotiationById(ai.id)!.status,
      NegotiationStatus.cancelled,
    );
    expect(resolved.negotiationById(ai.id)!.selectedByRival, isTrue);
  });

  test(
    'accepting a counter signs immediately without pending finalization',
    () {
      final base = leagueAt(week: 47, day: 1, hour: 1);
      final team = base.playerTeam!;
      final candidate = freeAgent(base, 'task29-counter-sign');
      final negotiationService = NegotiationService();
      final started = negotiationService
          .start(
            id: 'task29-counter-sign',
            subjectId: candidate.id,
            subjectKind: NegotiationSubjectKind.player,
            teamId: team.id,
            phase: NegotiationPhase.freeAgencyPhaseI,
            offer: const NegotiationOffer(salary: 1000000, years: 2),
            seasonYear: base.currentSeason.year,
            week: base.currentWeek,
            day: base.currentDay,
            hour: 1,
          )
          .copyWith(
            status: NegotiationStatus.counter,
            counterOffer: const NegotiationOffer(salary: 1000000, years: 2),
          );
      final state = base.copyWith(
        teams: [team],
        playerTeamId: team.id,
        freeAgents: [candidate],
        negotiations: [started],
      );

      LeagueState? signed;
      for (var seed = 0; seed < 100; seed++) {
        final result = market.resolveCounterResponse(
          state,
          started.id,
          accept: true,
          saveSeed: seed,
        );
        if (result?.negotiationById(started.id)?.status ==
            NegotiationStatus.completed) {
          signed = result;
          break;
        }
      }

      expect(signed, isNotNull);
      expect(
        signed!.negotiationById(started.id)!.status,
        NegotiationStatus.completed,
      );
      expect(
        signed.playerTeam!.roster.any((item) => item.id == candidate.id),
        isTrue,
      );
      expect(signed.freeAgents.any((item) => item.id == candidate.id), isFalse);
    },
  );

  test('drafted rights transfer without consuming a roster slot', () {
    final base = leagueAt(week: 44, day: 1);
    final owner = base.teams.first;
    final recipient = base.teams[1];
    final draftedPlayer = owner.roster.first.copyWith(
      id: 'task29-right-player',
      name: 'Task 29 Drafted Right',
    );
    final right = DraftedPlayerRights(
      id: 'task29-right',
      ownerTeamId: owner.id,
      player: draftedPlayer,
      draftYear: base.currentSeason.year + 1,
      pickNumber: 12,
    );
    final state = base.copyWith(draftedRights: [right]);
    final proposal = TradeProposal(
      teamAId: owner.id,
      teamBId: recipient.id,
      assetsFromA: [TradeAsset.draftedRights(right.id)],
      assetsFromB: const [],
    );
    final service = TradeService();

    expect(service.validateLeague(state, proposal, currentWeek: 44).ok, isTrue);
    final traded = service.executeLeague(state, proposal);
    expect(traded, isNotNull);
    expect(traded!.draftedRights.single.ownerTeamId, recipient.id);
    expect(traded.teamById(owner.id)!.roster, hasLength(owner.roster.length));
    expect(
      traded.teamById(recipient.id)!.roster,
      hasLength(recipient.roster.length),
    );
  });
}
