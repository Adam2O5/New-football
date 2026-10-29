@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/screens/finance_screen.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/salary_cap_service.dart';

import '../helpers/widgets/career_dashboard_harness.dart';

void main() {
  testWidgets(
    'FinanceScreen pokazuje dashboard capu, aprony i kondycję finansową',
    (tester) async {
      final game = dashboardGame(seed: 4001);
      await tester.pumpWidget(dashboardApp(const FinanceScreen(), game));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final snapshot = const SalaryCapService().snapshot(
        game.leagueState.playerTeam!,
      );
      expect(find.text('Salary cap i payroll'), findsOneWidget);
      expect(find.text('Aprony'), findsOneWidget);
      expect(find.text(formatMoney(context, snapshot.payroll)), findsOneWidget);
      expect(find.text(formatMoney(context, snapshot.cap)), findsOneWidget);
      await dashboardDragToBottom(
        tester,
        find.byKey(const ValueKey('finance-scroll')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kondycja finansowa'), findsOneWidget);
    },
  );

  testWidgets('FinanceScreen pokazuje ostrzeżenie po przekroczeniu capu', (
    tester,
  ) async {
    final game = dashboardGame(seed: 4002);
    final league = game.leagueState;
    final team = league.playerTeam!;
    final baseSnapshot = const SalaryCapService().snapshot(team);
    final overCapSalary =
        team.roster.first.contract.salary +
        baseSnapshot.cap -
        baseSnapshot.payroll +
        1;
    final expensivePlayer = team.roster.first.copyWith(
      contract: team.roster.first.contract.copyWith(salary: overCapSalary),
    );
    final overCapTeam = team.copyWith(
      roster: [expensivePlayer, ...team.roster.skip(1)],
    );
    final overCapLeague = league.copyWith(
      teams: [
        for (final candidate in league.teams)
          candidate.id == team.id ? overCapTeam : candidate,
      ],
    );
    final overCapGame = game.copyWith(leagueState: overCapLeague);

    await tester.pumpWidget(dashboardApp(const FinanceScreen(), overCapGame));
    await tester.pumpAndSettle();

    expect(find.text('Powyżej capu'), findsOneWidget);
    await dashboardDragToBottom(
      tester,
      find.byKey(const ValueKey('finance-scroll')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Payroll przekracza salary cap'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });
}
