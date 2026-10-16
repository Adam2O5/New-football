import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/day_pipeline.dart';

import 'support/game_fixtures.dart';

void main() {
  test(
    'conditional QO precedes expiry; original club retains match rights in FA I',
    () {
      final initial = seededLeague();
      final base = controllerSave().leagueState;
      final owner = base.playerTeam!;
      final rookie = owner.roster.first.copyWith(
        contract: const Contract(
          salary: 1000000,
          yearsRemaining: 1,
          firstSeason: 2026,
          lastSeason: 2026,
          isRookieScale: true,
          rookiePickSlot: 1,
        ),
      );
      var league = base.copyWith(
        teams: [
          owner.copyWith(roster: [rookie]),
          initial.teams[1].copyWith(
            roster: [],
            ai: null,
            finance: owner.finance,
          ),
        ],
        currentWeek: 46,
        currentDay: 7,
        currentHour: 10,
      );
      final market = ContractMarketService();
      league = market.submitQualifyingOffer(
        league: league,
        ownerTeamId: owner.id,
        playerId: rookie.id,
      )!;
      expect(league.playerTeam!.roster.single.contract.yearsRemaining, 1);
      expect(league.rfaQualifyingOffers.single.ownerTeamId, owner.id);
      league = DayPipeline()
          .advanceDay(
            league,
            saveSeed: fixtureSeed,
            blockOnPendingUrgent: false,
            resolveContractMarket: false,
          )
          .league;
      expect(league.currentWeek, 47);
      expect(league.playerTeam!.roster, isEmpty);
      expect(league.freeAgents.where((p) => p.id == rookie.id), hasLength(1));
      league = market.submitOfferSheet(
        league: league,
        offeringTeamId: initial.teams[1].id,
        playerId: rookie.id,
        offer: const ContractOffer(salary: 2000000, years: 1),
      )!;
      final matched = market.matchOfferSheet(
        league,
        league.rfaOfferSheets.single.id,
        saveSeed: fixtureSeed,
      )!;
      final contract = matched.playerTeam!.roster.single.contract;
      expect(
        (contract.firstSeason, contract.lastSeason, contract.yearsRemaining),
        (2027, 2027, 1),
      );
      expect(matched.rfaOfferSheets.single.matched, isTrue);
    },
  );
  test(
    'rookie right signing starts in the next season, not in the draft year',
    () {
      final base = controllerSave().leagueState.copyWith(currentWeek: 46);
      final prospect =
          seededLeague().currentSeason.draftState!.draftClass.prospects.first;
      final player = prospect.toPlayer(
        contract: Contract(
          salary: BalanceConfig.defaults.salaryCap.rookieSalaryForPick(1),
          yearsRemaining: 2,
          isRookieScale: true,
          rookiePickSlot: 1,
        ),
        rng: Random(fixtureSeed),
        draftYear: 2026,
      );
      final right = DraftedPlayerRights(
        id: 'rookie-right',
        ownerTeamId: base.playerTeamId!,
        player: player,
        draftYear: 2026,
        pickNumber: 1,
      );
      final signed = ContractMarketService().signDraftedRight(
        base.copyWith(draftedRights: [right]),
        right.id,
        saveSeed: fixtureSeed,
      )!;
      final added = signed.playerTeam!.roster.last;
      expect(
        (
          added.contract.firstSeason,
          added.contract.lastSeason,
          added.contract.yearsRemaining,
        ),
        (2027, 2028, 2),
      );
      expect(signed.draftedRights, isEmpty);
    },
  );
  test('emergency signature uses the date boundary too', () {
    final base = controllerSave().leagueState.copyWith(currentWeek: 44);
    final signed = ContractMarketService().signEmergencyFreeAgent(
      base,
      teamId: base.playerTeamId!,
      years: 1,
      saveSeed: fixtureSeed,
    )!;
    expect(signed.playerTeam!.roster.last.contract.firstSeason, 2027);
    expect(signed.playerTeam!.roster.last.contract.yearsRemaining, 1);
  });
}
