@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/screens/shell_screen.dart';

import '../helpers/widgets/career_dashboard_harness.dart';

void main() {
  testWidgets('Shell pokazuje akcje ustawień i zapisu w AppBarze', (
    tester,
  ) async {
    await tester.pumpWidget(
      dashboardApp(const ShellScreen(), dashboardGame(seed: 4006)),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ustawienia'), findsOneWidget);
    expect(find.byTooltip('Zapisz'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.save_outlined), findsOneWidget);
  });
}
