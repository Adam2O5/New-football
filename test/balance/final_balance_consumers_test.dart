import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:new_football/app/screens/lottery_screen.dart';
import 'package:new_football/app/widgets/lottery_odds_table.dart';
import 'package:new_football/core/services/season_service.dart';
import '../helpers/widgets/career_dashboard_harness.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/prospect_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/core/tactics/substitute_candidates.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

void main() {
  final game = GameFactory().create(
    const NewGameRequest(
      saveName: 'I10',
      playerTeamId: 'team_europe_0',
      seed: 42,
    ),
  );
  final team = game.leagueState.playerTeam!;

  test(
    'new game reads team initial state and tactical setup configuration',
    () {
      const balance = BalanceConfig(
        chemistry: ChemistryBalance(
          initialAtmosphere: 61,
          initialChemistry: 62,
        ),
        tactics: TacticsBalance(
          initialCornersAttack: 41,
          initialCornersDefense: 42,
          initialFreeKicks: 43,
          initialPenalties: 44,
        ),
      );
      final result = GameFactory(balance: balance).create(
        const NewGameRequest(
          saveName: 'Configured defaults',
          playerTeamId: 'team_europe_0',
          seed: 42,
        ),
      );
      for (final team in result.leagueState.teams) {
        expect(team.atmosphere, 61);
        expect(team.chemistry, 62);
        expect(team.tactics.cornersAttack, 41);
        expect(team.tactics.cornersDefense, 42);
        expect(team.tactics.freeKicks, 43);
        expect(team.tactics.penalties, 44);
      }
    },
  );

  test(
    'generated constructor and JSON defaults have the same balance owners',
    () {
      const defaults = BalanceConfig.defaults;
      final data = (jsonDecode(jsonEncode(team)) as Map<String, dynamic>)
        ..remove('chemistry')
        ..remove('atmosphere');
      final decoded = Team.fromJson(data);
      expect(decoded.chemistry, defaults.chemistry.initialChemistry);
      expect(decoded.atmosphere, defaults.chemistry.initialAtmosphere);
      final tactics = TacticsSetup.fromJson({});
      expect(tactics.cornersAttack, defaults.tactics.initialCornersAttack);
      expect(tactics.cornersDefense, defaults.tactics.initialCornersDefense);
      expect(tactics.freeKicks, defaults.tactics.initialFreeKicks);
      expect(tactics.penalties, defaults.tactics.initialPenalties);
      final context = MatchTeamSnapshot.fromJson({});
      expect(context.chemistry, defaults.chemistry.initialChemistry);
      expect(context.atmosphere, defaults.chemistry.initialAtmosphere);
    },
  );

  test('empty team strength uses configured fallback', () {
    const balance = BalanceConfig(player: PlayerBalance(emptyTeamOverall: 73));
    expect(team.copyWith(roster: []).teamStrengthFor(balance), 73);
  });

  test(
    'staff payroll and hiring cap use the same configured salary bounds',
    () {
      const balance = BalanceConfig(
        staff: StaffBalance(minSalary: 1, maxSalary: 20, salaryCap: 15),
      );
      final member = team.staff.headCoach!.copyWith(
        contract: const StaffContract(salary: 10, yearsRemaining: 1),
      );
      final staff = TeamStaff(headCoach: member);
      expect(staff.totalSalary, 0);
      expect(staff.totalSalaryFor(balance), 10);
      final service = StaffService(balance: balance);
      final employer = team.copyWith(staff: staff);
      expect(service.canHire(employer, 5), isTrue);
      expect(service.canHire(employer, 6), isFalse);
    },
  );

  test('visible substitute limit reaches the real candidate selection', () {
    const balance = BalanceConfig(
      ui: UiBalance(visibleSubstituteCandidateLimit: 3),
    );
    final out = team.roster.firstWhere((p) => p.position == Position.st);
    final candidates = [
      for (var i = 0; i < 7; i++) out.copyWith(id: 'candidate-$i'),
    ];
    final source = team.copyWith(roster: candidates, lineupPlayerIds: []);
    expect(
      substituteCandidatesFor(team: source, outPlayer: out, balance: balance),
      hasLength(3),
    );
    expect(
      substituteCandidatesFor(
        team: source,
        outPlayer: out,
        balance: balance,
        limit: 2,
      ),
      hasLength(2),
    );
  });

  test('next draft class uses the configured rolling pick horizon', () {
    const balance = BalanceConfig(
      salaryCap: SalaryCapBalance(maxPickYearsAhead: 4),
    );
    final input = game.leagueState.copyWith(
      teams: [team.copyWith(ownedPicks: [])],
    );
    final result = ProspectService(
      balance: balance,
    ).generateNextClassForLeague(input, seed: 42);
    final picks = result.teams.single.ownedPicks;
    expect(picks, hasLength(balance.draft.rounds));
    expect(picks.every((p) => p.year == input.currentSeason.year + 4), isTrue);
  });

  test('rookie extension boundary comes from the salary-cap rule', () {
    final player = team.roster.first.copyWith(
      contract: team.roster.first.contract.copyWith(
        salary: 1000000,
        yearsRemaining: 2,
        isRookieScale: true,
      ),
    );
    bool valid(BalanceConfig balance) => SalaryCapService(balance: balance)
        .validateExceptionOffer(
          player: player,
          exception: CapExceptionType.rookieExtension,
          salary: 1000000,
          years: 2,
        )
        .ok;
    expect(valid(BalanceConfig.defaults), isFalse);
    expect(
      valid(
        const BalanceConfig(
          salaryCap: SalaryCapBalance(rookieExtensionMaxYearsRemaining: 2),
        ),
      ),
      isTrue,
    );
  });

  test('message display priority table covers every event type', () {
    expect(
      BalanceConfig.defaults.ui.matchEventPriorities.keys.toSet(),
      MatchEventType.values.toSet(),
    );
  });
  test(
    'retirement age and probability table reach the actual seasonal action',
    () {
      const balance = BalanceConfig(
        retirement: RetirementBalance(
          minAge: 32,
          baseChanceByAge: {32: 1},
          age39PlusChance: 0,
        ),
      );
      final player = team.roster.first.copyWith(age: 32);
      final input = game.leagueState.copyWith(
        teams: [
          team.copyWith(roster: [player]),
        ],
        freeAgents: [],
      );
      final unchanged = SeasonService().runPlayerRetirements(
        input,
        saveSeed: 42,
      );
      expect(unchanged.teams.single.roster.single.id, player.id);
      final result = SeasonService(
        balance: balance,
      ).runPlayerRetirements(input, saveSeed: 42);
      expect(result.teams.single.roster, isEmpty);
      expect(result.currentSeason.playerRetirementsDone, isTrue);
    },
  );

  testWidgets(
    'configured lottery table reaches career results and ceremony odds',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const balance = BalanceConfig(
        draft: DraftBalance(
          lotteryWeightTable: [1000, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        ),
      );
      final result = SeasonService(
        balance: balance,
      ).runLottery(game.leagueState, saveSeed: 42);
      final lottery = result.currentSeason.draftState!.lotteryResults;
      expect(lottery, hasLength(10));
      expect(
        lottery.firstWhere((r) => r.originalRank == 1).oddsForFirstPick,
        closeTo(1000 / 1009, 1e-12),
      );
      await tester.pumpWidget(
        dashboardApp(const LotteryScreen(), game, balance: balance),
      );
      await tester.pumpAndSettle();
      final table = tester.widget<LotteryOddsTable>(
        find.byType(LotteryOddsTable),
      );
      expect(table.teams.first.oddsPercent, closeTo(1000 / 1009 * 100, 1e-10));
      expect(tester.takeException(), isNull);
    },
  );
}
