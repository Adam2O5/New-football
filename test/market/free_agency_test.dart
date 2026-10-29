import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/season_service.dart';

void main() {
  test('advanceDraft moves undrafted prospects into league.freeAgents', () {
    final season = SeasonService();
    var league = SeedDataGenerator()
        .generateLeague(seed: 11)
        .copyWith(playerTeamId: null);
    league = season.runLottery(league);
    final draft = league.currentSeason.draftState!;
    expect(draft.order, hasLength(90));
    expect(draft.draftClass.prospects, hasLength(120));
    final completed = [
      for (var index = 0; index < draft.order.length - 1; index++)
        draft.order[index].copyWith(
          prospectId: draft.draftClass.prospects[index].id,
        ),
    ];
    league = league.copyWith(
      playerTeamId: draft.order.last.teamId,
      currentSeason: league.currentSeason.copyWith(
        draftState: draft.copyWith(
          completedPicks: completed,
          currentPickIndex: draft.order.length - 1,
        ),
      ),
    );
    league = season.advanceDraft(
      league,
      saveSeed: 11,
      playerPickProspectId:
          draft.draftClass.prospects[draft.order.length - 1].id,
    );
    // 90 picks made from a 120-prospect class → ~30 leftover free agents.
    expect(league.freeAgents.length, 30);
  });

  test('expireContracts moves 0-year players from roster to FA pool', () {
    final league = SeedDataGenerator().generateLeague(seed: 12);
    var team = league.teams.first;
    final expiredPlayer = team.roster.first.copyWith(
      contract: team.roster.first.contract.copyWith(
        yearsRemaining: 0,
        firstSeason: league.currentSeason.year - 1,
        lastSeason: league.currentSeason.year - 1,
      ),
    );
    team = team.copyWith(roster: [expiredPlayer, ...team.roster.skip(1)]);
    final state = league.updateTeam(team);

    final season = SeasonService();
    final result = season.expireContracts(state);
    expect(
      result.teamById(team.id)!.roster.any((p) => p.id == expiredPlayer.id),
      isFalse,
    );
    expect(result.freeAgents.any((p) => p.id == expiredPlayer.id), isTrue);
  });
}
