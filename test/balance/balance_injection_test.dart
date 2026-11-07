import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/day_pipeline.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/mock_draft_service.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/services/simulation_worker.dart';

import '../helpers/fixtures/presentation_fixtures.dart';

void main() {
  test('initial salaries and cached growth rates use the supplied balance', () {
    final balance = BalanceConfig(
      salaryCap: const SalaryCapBalance(minSalary: 1230000, maxSalary: 1230000),
      development: DevelopmentBalance(
        determinationGrowthRates: List.filled(10, 0.125),
      ),
    );
    final league = SeedDataGenerator(balance: balance).generateLeague(seed: 19);
    for (final team in league.teams) {
      for (final player in team.roster) {
        expect(player.contract.salary, 1230000);
        expect(player.hidden.growthRate, 0.125);
      }
    }
  });

  test(
    'club mock noise can change independently of the public draft board',
    () {
      const balance = BalanceConfig(
        scouting: ScoutingBalance(
          earlyMockNoiseMin: 0,
          earlyMockNoiseMax: 0,
          finalMockNoiseBase: 0,
          finalMockNoisePerStar: 0,
          finalMockNoiseMin: 0,
          finalMockNoiseMax: 0,
        ),
      );
      final prospects = SeedDataGenerator()
          .generateDraftClass(year: 2026, seed: 11)
          .prospects;
      final publicBoard = MockDraftService().trueBoard(prospects);
      final scouting = TeamScouting(
        knowledge: [
          for (final prospect in publicBoard)
            ScoutingKnowledge(prospectId: prospect.id),
        ],
      );
      final service = ScoutingService(balance: balance);
      final early = service.runEarlyMock(scouting, publicBoard, 0, seed: 11);
      final finalMock = service.runFinalMock(
        scouting,
        publicBoard,
        0,
        seed: 11,
      );
      for (var i = 0; i < publicBoard.length; i++) {
        expect(early.knowledge[i].mockRank, i + 1);
        expect(finalMock.knowledge[i].mockRank, i + 1);
      }
      expect(
        MockDraftService(
          balance: balance,
        ).generateInitialMock(publicBoard, seed: 11),
        MockDraftService().generateInitialMock(publicBoard, seed: 11),
      );
    },
  );

  test('configured start year reaches factories and explicit years win', () {
    const balance = BalanceConfig(seed: SeedBalance(startYear: 2042));
    final generator = SeedDataGenerator(balance: balance);
    expect(generator.generateLeague(seed: 17).currentSeason.year, 2042);
    expect(
      generator.generateLeague(seed: 17, year: 2043).currentSeason.year,
      2043,
    );

    final container = ProviderContainer(
      overrides: [balanceProvider.overrideWithValue(balance)],
    );
    addTearDown(container.dispose);
    final factory = container.read(gameFactoryProvider);
    expect(
      factory
          .create(
            const NewGameRequest(
              saveName: 'balance',
              playerTeamId: 'team_europe_0',
              seed: 17,
            ),
          )
          .leagueState
          .currentSeason
          .year,
      2042,
    );
    expect(
      factory
          .create(
            const NewGameRequest(
              saveName: 'explicit',
              playerTeamId: 'team_europe_0',
              seasonYear: 2044,
              seed: 17,
            ),
          )
          .leagueState
          .currentSeason
          .year,
      2044,
    );
  });

  test(
    'configured roster profile changes its consumer without shifting RNG',
    () {
      final profiles = [...SeedBalance.defaultRosterProfiles];
      final original = profiles.first;
      profiles[0] = (63, original.$2, original.$3);
      final baseline = SeedDataGenerator().generateLeague(seed: 19);
      final configured = SeedDataGenerator(
        balance: BalanceConfig(seed: SeedBalance(rosterProfiles: profiles)),
      ).generateLeague(seed: 19);
      for (var i = 0; i < baseline.teams.length; i++) {
        final before = baseline.teams[i].roster;
        final after = configured.teams[i].roster;
        expect(after.length, before.length);
        expect(after.first.age, before.first.age);
        expect(after.first.overall(), lessThan(before.first.overall()));
        expect(after.skip(1), before.skip(1));
      }
    },
  );

  test(
    'worker and inline runner use non-default balance, including cached steps',
    () async {
      const balance = BalanceConfig(
        contracts: ContractNegBalance(hoursPerDay: 2),
      );
      final inline = InlineSimulationRunner(DayPipeline(balance: balance));
      final worker = IsolateSimulationRunner(balance: balance);
      addTearDown(worker.dispose);
      final team = presentationTeam();
      var local = LeagueState(
        teams: [team],
        playerTeamId: team.id,
        currentWeek: balance.calendar.freeAgencyWeek,
        currentDay: 2,
        currentHour: 1,
        currentSeason: const Season(year: 2026, phase: SeasonPhase.offseason),
      );
      var remote = local;
      for (var i = 0; i < 2; i++) {
        final expected = await inline.advanceHour(
          local,
          saveSeed: 91,
          blockOnPendingUrgent: false,
        );
        final actual = await worker.advanceHour(
          remote,
          saveSeed: 91,
          blockOnPendingUrgent: false,
        );
        expect(actual.outcome, expected.outcome);
        expect(actual.league, expected.league);
        expect(
          actual.outcome,
          i == 0
              ? HourStepOutcome.hourAdvanced
              : HourStepOutcome.lastHourReached,
        );
        local = expected.league;
        remote = actual.league;
      }
      // A new worker must use the supplied configuration as well.
      worker.dispose();
      final restarted = IsolateSimulationRunner(balance: balance);
      addTearDown(restarted.dispose);
      final result = await restarted.advanceHour(
        remote,
        saveSeed: 91,
        blockOnPendingUrgent: false,
      );
      expect(result.outcome, HourStepOutcome.lastHourReached);
    },
  );
}
