@Tags(['ai'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_trade_service.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/trade_service.dart';

void main() {
  late GameSave save;

  setUp(() {
    save = GameFactory().create(
      const NewGameRequest(
        saveName: 'Task 34 trade AI',
        playerTeamId: 'team_europe_0',
        seed: 3401,
      ),
    );
  });

  LeagueState leagueAt({int week = 1, int day = 1}) =>
      save.leagueState.copyWith(currentWeek: week, currentDay: day);

  TradeProposal oneForOne(LeagueState league) {
    final a = league.teams[1];
    final b = league.teams[2];
    return TradeProposal(
      teamAId: a.id,
      teamBId: b.id,
      assetsFromA: [TradeAsset.player(a.roster.first.id)],
      assetsFromB: [TradeAsset.player(b.roster.first.id)],
    );
  }

  test('package salt makes evaluation rolls independent and replayable', () {
    final league = leagueAt();
    final proposal = oneForOne(league);
    final service = AiTradeService();

    final first = service.evaluateOffer(
      league: league,
      proposal: proposal,
      evaluatingTeamId: proposal.teamAId,
      saveSeed: save.saveSeed,
      packageSalt: 11,
    );
    final replay = service.evaluateOffer(
      league: league,
      proposal: proposal,
      evaluatingTeamId: proposal.teamAId,
      saveSeed: save.saveSeed,
      packageSalt: 11,
    );
    final otherPackage = service.evaluateOffer(
      league: league,
      proposal: proposal,
      evaluatingTeamId: proposal.teamAId,
      saveSeed: save.saveSeed,
      packageSalt: 12,
    );

    expect(replay.surplusPct, first.surplusPct);
    expect(
      replay.evaluation.evaluationNoisePp,
      first.evaluation.evaluationNoisePp,
    );
    expect(
      otherPackage.evaluation.evaluationNoisePp,
      isNot(first.evaluation.evaluationNoisePp),
    );
  });

  test(
    'AI response uses persisted offer lifecycle rather than direct execution',
    () {
      final league = leagueAt();
      final proposal = oneForOne(league);
      final tradeService = TradeService();
      final aiService = AiTradeService(tradeService: tradeService);
      final created = tradeService.createOffer(
        league,
        proposal,
        offeringTeamId: proposal.teamAId,
        emitMessages: false,
      );

      expect(created.changed, isTrue);
      final responded = aiService.respondToOffer(
        created.league,
        created.offerId!,
        saveSeed: save.saveSeed,
        emitMessages: false,
      );

      expect(responded.changed, isTrue);
      expect(responded.league.tradeOffers, isNotEmpty);
      expect(
        responded.outcome,
        anyOf('accepted', 'rejected', 'hardRejected', 'countered'),
      );
      if (responded.outcome == 'accepted') {
        expect(responded.league.tradeHistory.last.outcome, 'accepted');
      }
    },
  );

  test(
    'three counters are allowed and the fourth counter hard-rejects the pair',
    () {
      final league = leagueAt();
      final proposal = oneForOne(league);
      final service = TradeService();
      var state = league;
      var current = service.createOffer(
        state,
        proposal,
        offeringTeamId: proposal.teamAId,
        emitMessages: false,
      );
      state = current.league;

      var actingTeamId = proposal.teamBId;
      for (var counterNumber = 0; counterNumber < 3; counterNumber++) {
        current = service.counterOffer(
          state,
          current.offerId!,
          proposal,
          actingTeamId: actingTeamId,
          emitMessages: false,
        );
        expect(current.outcome, 'countered');
        state = current.league;
        actingTeamId = actingTeamId == proposal.teamAId
            ? proposal.teamBId
            : proposal.teamAId;
      }

      final fourth = service.counterOffer(
        state,
        current.offerId!,
        proposal,
        actingTeamId: actingTeamId,
        emitMessages: false,
      );

      expect(fourth.outcome, 'hardRejected');
      expect(fourth.league.tradeHistory.last.outcome, 'hardRejected');
      expect(
        service.isPairTradeBlocked(
          fourth.league,
          proposal.teamAId,
          proposal.teamBId,
        ),
        isTrue,
      );
      expect(
        service.validateLeague(fourth.league, proposal).code,
        'tradePairBlocked',
      );
    },
  );

  test(
    'weekly tick is a no-op outside the trade window and exposes appetite terms',
    () {
      final league = leagueAt(week: 24);
      final aiTeam = league.teams.firstWhere((team) => team.ai != null);
      final service = AiTradeService();
      final appetite = service.appetiteForTeam(league: league, team: aiTeam);
      final result = service.runWeeklyTick(league, saveSeed: save.saveSeed);

      expect(appetite.value, inInclusiveRange(0.0, 1.0));
      expect(appetite.maxNeedScore, inInclusiveRange(0.0, 100.0));
      expect(result.candidatePairs, 0);
      expect(result.createdPlayerOffers, 0);
      expect(result.league, league);
    },
  );
}
