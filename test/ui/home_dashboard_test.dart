@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/screens/home_screen.dart';

import 'package:new_football/core/models/league_state.dart';

import '../helpers/widgets/career_dashboard_harness.dart';

void main() {
  testWidgets('HomeScreen pokazuje nagłówek, kalendarz i kontekstową akcję', (
    tester,
  ) async {
    final game = dashboardGame(seed: 4003);
    await tester.pumpWidget(dashboardApp(const HomeScreen(), game));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-dashboard-header')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-next-seven-days')), findsOneWidget);
    expect(find.text(game.leagueState.playerTeam!.name), findsOneWidget);
    expect(find.text('Najbliższe 7 dni'), findsOneWidget);
    expect(find.text('Bilans drużyny'), findsOneWidget);
    expect(find.text('Najbliższa akcja'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
