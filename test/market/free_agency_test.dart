import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/season_service.dart';

void main() {
  test('advanceDraft moves undrafted prospects into league.freeAgents', () {
    final season = SeasonService();
    var league = SeedDataGenerator()
        .generateLeague(seed: 11)
        .copyWith(playerTeamId: null);
    league = season.runLottery(league);
    league = season.advanceDraft(league);
    // 90 picks made from a 120-prospect class → ~30 leftover free agents.
    expect(league.freeAgents.length, 30);
  });

  test('expireContracts moves 0-year players from roster to FA pool', () {
    final league = SeedDataGenerator().generateLeague(seed: 12);
    var team = league.teams.first;
    final expiredPlayer = team.roster.first.copyWith(
      contract: team.roster.first.contract.copyWith(yearsRemaining: 0),
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

  test('DaySimulator resolves free agency offers during week 47', () {
    final league = SeedDataGenerator().generateLeague(seed: 13);
    final fa = league.teams[0].roster.first.copyWith(
      contract: const Contract(salary: 500000, yearsRemaining: 0),
    );
    var state = league.copyWith(
      currentWeek: 47,
      currentDay: 1,
      playerTeamId: null,
      freeAgents: [fa],
    );

    final sim = DaySimulator();
    for (var i = 0; i < 7 && state.freeAgents.isNotEmpty; i++) {
      state = sim.simulateDay(state).league;
    }
    // A reasonably strong player with a modest salary should attract at
    // least one legal AI offer within the FA week.
    expect(state.freeAgents.any((p) => p.id == fa.id), isFalse);
  });
}
