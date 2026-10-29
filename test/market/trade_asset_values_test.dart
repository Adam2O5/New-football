import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/trade_service.dart';

void main() {
  test('TradeService.assetValue wycenia pick po ID i po danych picka', () {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Task 41 pick valuation',
        playerTeamId: 'team_europe_0',
        seed: 4102,
      ),
    );
    final league = game.leagueState;
    final team = league.playerTeam!;
    final pick = team.ownedPicks.first;
    final service = TradeService();
    final expected = pick.computeTradeValue(
      currentYear: league.currentSeason.year,
    );

    final byId = TradeAsset.pick(
      pickId: pick.id,
      pickYear: pick.year,
      pickRound: pick.round,
      originalTeamId: pick.originalTeamId,
    );
    final byFields = TradeAsset.pick(
      pickYear: pick.year,
      pickRound: pick.round,
      originalTeamId: pick.originalTeamId,
    );

    expect(
      service.assetValue(team, byId, currentYear: league.currentSeason.year),
      expected,
    );
    expect(
      service.assetValue(
        team,
        byFields,
        currentYear: league.currentSeason.year,
      ),
      expected,
    );
    expect(
      service.assetValue(
        team,
        TradeAsset.pick(
          pickYear: pick.year + 100,
          pickRound: pick.round,
          originalTeamId: pick.originalTeamId,
        ),
        currentYear: league.currentSeason.year,
      ),
      greaterThanOrEqualTo(0),
    );
  });
}
