@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/screens/contract_screen.dart';
import 'package:new_football/app/screens/free_agency_screen.dart';
import 'package:new_football/app/screens/staff_screen.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/fixtures/game_fixtures.dart';
import '../helpers/widgets/career_dashboard_harness.dart';
import '../helpers/widgets/stateful_screen_harness.dart';

void main() {
  const balance = BalanceConfig(
    salaryCap: SalaryCapBalance(minSalary: 12345678, maxSalary: 12345678),
    contracts: ContractNegBalance(
      playerLengthTable: [
        (null, [2, 2, 2]),
      ],
    ),
    staff: StaffBalance(
      minSalary: 1234567,
      maxSalary: 1234567,
      desiredLengthTable: [
        (null, [1, 1, 1]),
      ],
    ),
  );
  for (final kind in ['contract', 'fa', 'staff']) {
    testWidgets('$kind offer editor uses the injected salary and length', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1600, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final screen = switch (kind) {
        'fa' => const FreeAgencyScreen(),
        'staff' => const StaffScreen(),
        _ => const ContractScreen(),
      };
      await tester.pumpWidget(
        dashboardApp(
          screen,
          saveForLeague(marketFormLeague()),
          balance: balance,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .widgetWithText(
              ListTile,
              kind == 'staff' ? 'R12 Scout' : 'R12 Agent',
            )
            .first,
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(screen.runtimeType)),
      )!;
      final salaryField = labelledField(
        kind == 'fa' ? l10n.freeAgency_offerSalary : l10n.contract_offerSalary,
      );
      final yearsField = labelledField(
        kind == 'fa' ? l10n.freeAgency_offerYears : l10n.contract_offerYears,
      );
      await tester.scrollUntilVisible(
        salaryField,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester.widget<TextField>(salaryField).controller!.text,
        kind == 'staff' ? '1234567' : '12345678',
      );
      expect(
        tester.widget<TextField>(yearsField).controller!.text,
        kind == 'staff' ? '1' : '2',
      );
    });
  }
}
