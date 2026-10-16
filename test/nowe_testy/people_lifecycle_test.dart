import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/season_service.dart';

import 'support/game_fixtures.dart';

class _ProvidedMatch extends AiMatchdayService {
  _ProvidedMatch(this.result);
  final MatchResult result;
  @override
  MatchResult simulateFullMatch({
    dynamic home,
    dynamic away,
    dynamic context,
    dynamic saveSeed,
    dynamic seasonYear,
    dynamic week,
    dynamic matchId,
    dynamic phase,
    dynamic homeOpponentFormationHistory,
    dynamic awayOpponentFormationHistory,
    dynamic homeNextMatchWithinThreeDays,
    dynamic awayNextMatchWithinThreeDays,
    dynamic homeReturningAfterMajorInjury,
    dynamic awayReturningAfterMajorInjury,
    dynamic includeStoppageTime,
    dynamic mathematicallyMeaningless,
  }) => result;
}

void main() {
  test(
    'ordinary day and resumed player match give FA exactly one daily/weekly tick',
    () {
      final base = finalRegularSeasonDay();
      final league = base.copyWith(freeAgents: beforeRollover().freeAgents);
      final result = finalRegularSeasonResult(league);
      final days = DaySimulator(aiMatchdayService: _ProvidedMatch(result));
      final headless = days
          .simulateDay(
            league,
            saveSeed: fixtureSeed,
            simulatePlayerMatch: true,
            resolveContractMarket: false,
          )
          .league;
      final paused = days.simulateDay(
        league,
        saveSeed: fixtureSeed,
        resolveContractMarket: false,
      );
      final resumed = days.applyPlayerMatchResult(
        paused.league,
        paused.playerMatch!,
        result,
        saveSeed: fixtureSeed,
        resolveContractMarket: false,
      );
      expect(resumed.freeAgents, headless.freeAgents);
      expect(
        resumed.freeAgents.single.state.injury!.daysRemaining,
        league.freeAgents.single.state.injury!.daysRemaining - 1,
      );
    },
  );
  test('rollover ages roster, FA, employed staff and staff FA once', () {
    final full = seededLeague();
    final fixture = beforeRollover();
    final playerTeam = fixture.playerTeam!;
    final league = full.copyWith(
      teams: [
        playerTeam,
        ...full.teams.skip(1).map((t) => t.copyWith(ai: null)),
      ],
      currentWeek: 52,
      currentDay: 7,
      freeAgents: fixture.freeAgents,
      staffFreeAgents: fixture.staffFreeAgents,
    );
    final next = SeasonService().rolloverSeason(league, saveSeed: fixtureSeed);
    expect(
      next.freeAgents
          .firstWhere((p) => p.id == fixture.freeAgents.single.id)
          .age,
      fixture.freeAgents.single.age + 1,
    );
    expect(next.playerTeam!.staff.scout!.age, playerTeam.staff.scout!.age + 1);
    expect(
      next.staffFreeAgents.single.age,
      fixture.staffFreeAgents.single.age + 1,
    );
    final oldPlayer = playerTeam.roster.first;
    final allPlayers = [...next.playerTeam!.roster, ...next.freeAgents];
    expect(
      allPlayers.singleWhere((p) => p.id == oldPlayer.id).age,
      oldPlayer.age + 1,
    );
  });
  test(
    'FA injury and stamina advance daily and hiring preserves the counters',
    () {
      final base = beforeRollover();
      final league = base.copyWith(
        currentWeek: 48,
        currentDay: 1,
        freeAgents: [
          base.freeAgents.single.copyWith(
            state: base.freeAgents.single.state.copyWith(stamina: 20),
          ),
        ],
      );
      final original = league.freeAgents.single;
      final next = DaySimulator()
          .simulateDay(league, resolveContractMarket: false)
          .league;
      final player = next.freeAgents.single;
      expect(
        player.state.injury!.daysRemaining,
        original.state.injury!.daysRemaining - 1,
      );
      expect(player.age, original.age);
      expect(player.state.stamina, greaterThan(original.state.stamina));
      expect(
        player.state.stamina,
        original.recoverBetweenMatches().state.stamina,
      );
      final hired = ContractService().signPlayer(
        team: next.playerTeam!,
        player: player,
        offer: const ContractOffer(salary: 1000000, years: 1),
        seasonYear: 2026,
        week: 48,
      )!;
      expect(hired.roster.last.age, player.age);
      expect(hired.roster.last.state.injury, player.state.injury);
      final dayTwo = DaySimulator()
          .simulateDay(next, resolveContractMarket: false)
          .league;
      final dayThree = DaySimulator()
          .simulateDay(dayTwo, resolveContractMarket: false)
          .league;
      expect(dayThree.freeAgents.single.state.injured, isFalse);
    },
  );
  test(
    'weekly FA development has no club bonuses or carried match minutes',
    () {
      final base = beforeRollover();
      final player = base.freeAgents.single.copyWith(
        state: base.freeAgents.single.state.copyWith(
          injury: null,
          minutesThisWeek: 300,
        ),
      );
      final league = base.copyWith(
        currentWeek: 48,
        currentDay: 7,
        freeAgents: [player],
      );
      final recovered = player.recoverBetweenMatches();
      final expected = DevelopmentService()
          .developPlayerWithContext(
            recovered.copyWith(
              state: recovered.state.copyWith(minutesThisWeek: 0),
            ),
            atmosphere: 50,
          )
          .player;
      final next = DaySimulator()
          .simulateDay(
            league,
            saveSeed: fixtureSeed,
            resolveContractMarket: false,
          )
          .league;
      expect(next.freeAgents.single, expected);
    },
  );
  test('unattached players and staff retire using the annual event once', () {
    final base = controllerSave().leagueState;
    final member = beforeRollover().staffFreeAgents.single.copyWith(age: 60);
    final league = base.copyWith(
      freeAgents: [base.freeAgents.single.copyWith(age: 45)],
      staffFreeAgents: [member],
    );
    final service = SeasonService();
    final retired = service.runPlayerRetirements(league, saveSeed: fixtureSeed);
    expect(retired.freeAgents, isEmpty);
    expect(
      identical(
        service.runPlayerRetirements(retired, saveSeed: fixtureSeed),
        retired,
      ),
      isTrue,
    );
    final staff = service.runStaffGrowthAndRetire(
      retired,
      saveSeed: fixtureSeed,
    );
    expect(staff.staffFreeAgents, isEmpty);
    expect(
      identical(
        service.runStaffGrowthAndRetire(staff, saveSeed: fixtureSeed),
        staff,
      ),
      isTrue,
    );
  });
}
