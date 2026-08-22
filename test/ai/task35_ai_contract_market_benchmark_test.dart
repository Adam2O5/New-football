@Tags(['ai', 'benchmark', 'slow'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/salary_cap_service.dart';

void main() {
  const balance = BalanceConfig.defaults;
  final policy = AiContractMarketService(balance: balance);
  final market = ContractMarketService(balance: balance);
  final capService = SalaryCapService(balance: balance);

  Player freeAgentFrom(Player source, {required String id}) {
    return source.copyWith(
      id: id,
      name: 'Task 35 benchmark $id',
      contract: source.contract.copyWith(
        salary: balance.salaryCap.minSalary,
        yearsRemaining: 0,
        isRookieScale: false,
        rookiePickSlot: 0,
        hasBirdRights: false,
        exceptionType: null,
        noTradeClause: false,
        blockedTeamIds: const [],
      ),
      state: source.state.copyWith(seasonsWithTeam: 0),
    );
  }

  Player samePositionClone(
    Player source, {
    required String id,
    required Position position,
  }) {
    return source.copyWith(
      id: id,
      name: 'Task 35 benchmark $id',
      position: position,
    );
  }

  LeagueState allAiLeague(int seed) {
    final generated = GameFactory()
        .create(
          NewGameRequest(
            saveName: 'task35-benchmark',
            playerTeamId: 'team_europe_0',
            seed: seed,
          ),
        )
        .leagueState;
    final generator = SeedDataGenerator();
    final teams = [
      for (final team in generated.teams)
        team.copyWith(ai: const TeamAiConfig()),
    ];
    // Keep the pool comfortably above one candidate per slot. This keeps the
    // benchmark focused on AI priorities and cap legality, not pool scarcity.
    final staffPool = generator.generateStaffPool(
      teams.length * StaffRole.values.length * 2,
      random: Random(seed ^ 0x35_35_35),
    );
    return generated.copyWith(
      teams: teams,
      playerTeamId: null,
      currentWeek: 48,
      currentDay: 1,
      currentHour: null,
      freeAgents: const [],
      staffFreeAgents: staffPool,
    );
  }

  LeagueState resolveFaTwoWindow(LeagueState league, {required int seed}) {
    var state = league;
    var week = 47;
    var day = 1;
    for (var elapsedDay = 0; elapsedDay < 364; elapsedDay++) {
      state = state.copyWith(
        currentWeek: week,
        currentDay: day,
        currentHour: null,
      );
      state = market.resolveDay(state, saveSeed: seed);
      if (week == 45 && day == 7) break;
      if (day == 7) {
        day = 1;
        week = week == 52 ? 1 : week + 1;
      } else {
        day++;
      }
    }
    return state;
  }

  ({int filled, int expected}) staffSlotCounts(
    LeagueState league,
    Team team,
    int saveSeed,
  ) {
    final context = policy.evaluator.contextForTeam(
      team: team,
      league: league,
      saveSeed: saveSeed,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      decisionType: DecisionType.faOffer,
    );
    final order = policy.staffRolePriority(context.teamStatus);
    var filled = 0;
    var expected = 0;
    for (final role in StaffRole.values) {
      final member = team.staff.member(role);
      final active =
          member?.contract?.yearsRemaining != null &&
          member!.contract!.yearsRemaining > 0;
      if (active) filled++;
      if (active) {
        expected++;
        continue;
      }
      final roleIndex = order.indexOf(role);
      final minimum = roleIndex == 0
          ? balance.staff.minSalary
          : roleIndex <= 2
          ? balance.ai.staffPriorityRoleMinSalary
          : balance.ai.staffOtherRoleMinSalary;
      final candidateAvailable = league.staffFreeAgents.any(
        (candidate) => candidate.role == role,
      );
      if (candidateAvailable &&
          policy.staff.hireValidationReason(team, minimum) == null) {
        expected++;
      }
    }
    return (filled: filled, expected: expected);
  }

  test(
    'FA decisions react to roster need instead of maximizing UFA volume',
    () {
      final generated = SeedDataGenerator().generateLeague(seed: 3501);
      final sourceTeam = generated.teams.firstWhere((team) => team.ai != null);
      final source = sourceTeam.roster.firstWhere(
        (player) => player.position != Position.gk,
      );
      final group = balance.ai.rosterGroups.firstWhere(
        (definition) => definition.contains(source.position),
      );
      final fillers = sourceTeam.roster
          .where((player) => player.position != source.position)
          .take(22 - group.max)
          .toList();
      final saturatedRoster = [
        for (var i = 0; i < group.max; i++)
          samePositionClone(
            source,
            id: 'task35-saturated-$i',
            position: source.position,
          ),
        ...fillers,
      ];
      final saturatedTeam = sourceTeam.copyWith(roster: saturatedRoster);
      final candidate = freeAgentFrom(source, id: 'task35-quality-candidate');
      final saturatedState = generated.copyWith(
        teams: [saturatedTeam],
        playerTeamId: null,
        currentWeek: 47,
        currentDay: 1,
        currentHour: 1,
        freeAgents: [candidate],
      );

      var saturatedPlans = 0;
      for (var seed = 0; seed < 1000; seed++) {
        final plan = policy.phaseOnePlayerPlan(
          league: saturatedState,
          team: saturatedTeam,
          hour: 1,
          saveSeed: 3501 + seed,
        );
        if (plan == null) continue;
        saturatedPlans++;
        final validation = policy.contracts.validateOffer(
          team: saturatedTeam,
          player: plan.player,
          offer: plan.offer,
        );
        expect(validation.ok, isTrue);
        final expectedSalary = policy.contracts.expectedSalary(plan.player);
        final expectedLength = policy.contracts.expectedLength(plan.player);
        expect(
          plan.offer.salary,
          lessThanOrEqualTo(
            (expectedSalary * balance.ai.faMaxSalaryMult).round(),
          ),
        );
        expect(
          plan.offer.salary,
          lessThanOrEqualTo(balance.salaryCap.maxSalary),
        );
        expect(plan.offer.years, lessThanOrEqualTo(expectedLength + 1));
        if (plan.player.age >= 33) {
          expect(plan.offer.years, lessThanOrEqualTo(2));
        }
      }

      final underfilledTeam = saturatedTeam.copyWith(
        roster: saturatedRoster.take(19).toList(),
      );
      final underfilledState = saturatedState.copyWith(
        teams: [underfilledTeam],
      );
      for (var seed = 0; seed < 100; seed++) {
        final plan = policy.phaseTwoPlayerPlan(
          league: underfilledState,
          team: underfilledTeam,
          saveSeed: 3501 + seed,
        );
        expect(plan, isNotNull);
        expect(plan!.emergency, isTrue);
        expect(plan.offer.salary, balance.salaryCap.minSalary);
        expect(plan.offer.years, 1);
      }

      expect(saturatedPlans, greaterThan(0));
      expect(saturatedPlans, lessThanOrEqualTo(100));
    },
  );

  test('FA-II staff fill and player payroll benchmark AI lifecycle', () {
    final seeds = List.generate(8, (index) => 3501 + index);
    final rawStaffRates = <double>[];
    final affordableStaffRates = <double>[];
    final payrollRates = <double>[];
    final maxPayrollRates = <double>[];

    for (final seed in seeds) {
      final finalState = resolveFaTwoWindow(allAiLeague(seed), seed: seed);
      final aiTeams = finalState.teams
          .where((team) => team.ai != null)
          .toList();
      var filled = 0;
      var expected = 0;
      final payrollPercentages = <double>[];
      for (final team in aiTeams) {
        final counts = staffSlotCounts(finalState, team, seed);
        filled += counts.filled;
        expected += counts.expected;
        final snapshot = capService.snapshot(team);
        payrollPercentages.add(snapshot.payroll / snapshot.cap * 100.0);
      }
      final totalSlots = aiTeams.length * StaffRole.values.length;
      rawStaffRates.add(filled / totalSlots);
      affordableStaffRates.add(expected == 0 ? 1.0 : filled / expected);
      payrollRates.add(
        payrollPercentages.reduce((a, b) => a + b) / payrollPercentages.length,
      );
      maxPayrollRates.add(payrollPercentages.reduce(max));
    }

    final meanRawStaffRate =
        rawStaffRates.reduce((a, b) => a + b) / rawStaffRates.length;
    final meanAffordableStaffRate =
        affordableStaffRates.reduce((a, b) => a + b) /
        affordableStaffRates.length;
    final meanPayrollPercent =
        payrollRates.reduce((a, b) => a + b) / payrollRates.length;
    final maximumPayrollPercent = maxPayrollRates.reduce(max);

    print(
      'Task 35 benchmark: rawStaff=${(meanRawStaffRate * 100).toStringAsFixed(2)}%, '
      'affordableStaff=${(meanAffordableStaffRate * 100).toStringAsFixed(2)}%, '
      'payroll=${meanPayrollPercent.toStringAsFixed(2)}%, '
      'maxPayroll=${maximumPayrollPercent.toStringAsFixed(2)}%',
    );

    expect(meanAffordableStaffRate, greaterThanOrEqualTo(0.92));
    // A lower payroll bound would reward needless FA signings. The benchmark
    // reports the mean and only enforces the upper flexibility guardrail.
    expect(meanPayrollPercent, greaterThan(0.0));
    expect(maximumPayrollPercent, lessThanOrEqualTo(108.0));
  });
}
