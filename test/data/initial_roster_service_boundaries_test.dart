@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/trade_service.dart';

import '../helpers/generation/initial_roster_assertions.dart';

void main() {
  test(
    'preserves draft, free-agent, and trade service boundaries after creation',
    () {
      const seed = 1001;
      final game = GameFactory().create(
        const NewGameRequest(
          saveName: 'initial-roster-service-boundaries',
          playerTeamId: 'team_europe_0',
          seed: seed,
        ),
      );
      final league = game.leagueState;
      final season = SeasonService();

      // Finalize one explicit pick, with the other 89 supplied as test data.
      // Initial free agents must survive alongside the undrafted cohort.
      var draftLeague = season.runLottery(league);
      final draft = draftLeague.currentSeason.draftState!;
      final completed = [
        for (var i = 0; i < draft.order.length - 1; i++)
          draft.order[i].copyWith(prospectId: draft.draftClass.prospects[i].id),
      ];
      draftLeague = draftLeague.copyWith(
        playerTeamId: draft.order.last.teamId,
        currentSeason: draftLeague.currentSeason.copyWith(
          draftState: draft.copyWith(
            completedPicks: completed,
            currentPickIndex: draft.order.length - 1,
          ),
        ),
      );
      draftLeague = season.advanceDraft(
        draftLeague,
        saveSeed: seed,
        playerPickProspectId:
            draft.draftClass.prospects[draft.order.length - 1].id,
      );
      expect(
        draftLeague.currentSeason.draftState?.completedPicks,
        hasLength(90),
      );
      expect(draftLeague.freeAgents, hasLength(league.freeAgents.length + 30));
      for (final original in league.freeAgents) {
        expect(
          draftLeague.freeAgents.singleWhere((p) => p.id == original.id),
          original,
        );
      }
      expect(
        draftLeague.freeAgents.map((p) => p.id).toSet(),
        hasLength(draftLeague.freeAgents.length),
      );

      // Existing free-agent contract: expiring a roster player removes it
      // from the club and exposes the same player in the FA pool.
      final sourceTeam = league.teams.first;
      final expiringPlayer = sourceTeam.roster.first;
      final expiredTeam = sourceTeam.copyWith(
        roster: [
          expiringPlayer.copyWith(
            contract: expiringPlayer.contract.copyWith(
              yearsRemaining: 0,
              firstSeason: 2025,
              lastSeason: 2025,
            ),
          ),
          ...sourceTeam.roster.skip(1),
        ],
      );
      final expiredLeague = season.expireContracts(
        league.updateTeam(expiredTeam),
      );
      expect(
        expiredLeague
            .teamById(sourceTeam.id)!
            .roster
            .any((player) => player.id == expiringPlayer.id),
        isFalse,
      );
      expect(
        expiredLeague.freeAgents.any(
          (player) => player.id == expiringPlayer.id,
        ),
        isTrue,
      );

      // Existing trade contract: a valid proposal can be submitted through
      // the normal validator and rejected without moving either roster.
      final targetTeam = league.teams[1];
      final proposal = TradeProposal(
        teamAId: sourceTeam.id,
        teamBId: targetTeam.id,
        assetsFromA: [TradeAsset.player(sourceTeam.roster.first.id)],
        assetsFromB: [TradeAsset.player(targetTeam.roster.first.id)],
      );
      final beforeTrade = rosterIdsProjection(league);
      final trade = TradeService().submitLeague(
        league,
        proposal,
        aiAccepted: false,
        emitMessages: false,
        enforceWindow: false,
      );
      expect(trade.validation.ok, isTrue);
      expect(trade.executed, isFalse);
      expect(trade.outcome, 'rejected');
      expect(rosterIdsProjection(trade.league), beforeTrade);
    },
  );
}
