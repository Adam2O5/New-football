import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/matchday_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

void main() {
  late MemorySaveRepository repository;
  late ProviderContainer container;
  late GameController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = MemorySaveRepository(saveForLeague(seededLeague()));
    container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(repository.game.meta.id);
    await controller.updateLeague(
      (league) => league.copyWith(currentDay: 2),
      autosave: false,
    );
  });
  tearDown(() => container.dispose());

  Future<GoRouter> showCareer(
    WidgetTester tester, {
    bool matchday = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1300, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final league = controller.save!.leagueState;
    final router = GoRouter(
      initialLocation: '/game',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Main menu')),
        ),
        GoRoute(
          path: '/game',
          builder: (_, _) => matchday
              ? MatchdayScreen(
                  match: ScheduledMatch(
                    id: 'fixture-match',
                    homeTeamId: league.teams[0].id,
                    awayTeamId: league.teams[1].id,
                    round: 1,
                  ),
                )
              : const ShellScreen(initialTab: 5),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    return router;
  }

  testWidgets('menu navigation waits until the active career is saved', (
    tester,
  ) async {
    late final Completer<void> gate;
    late final Completer<void> started;
    // These barriers belong to the same real async zone as setUp's queue.
    await tester.runAsync(() async {
      gate = Completer<void>();
      started = Completer<void>();
      repository.writeGate = gate;
      repository.writeStarted = started;
    });
    final router = await showCareer(tester);
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump();
    await tester.runAsync(() => started.future);
    expect(router.routeInformationProvider.value.uri.path, '/game');
    expect(controller.save, isNotNull);
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.logout))
          .onPressed,
      isNull,
    );
    await tester.runAsync(() async {
      gate.complete();
    });
    await tester.pumpAndSettle();
    expect(find.text('Main menu'), findsOneWidget);
    expect(repository.game.leagueState.currentDay, 2);
  });

  testWidgets('failed menu save stays in the career and permits retry', (
    tester,
  ) async {
    repository.writeError = StateError('disk unavailable');
    final router = await showCareer(tester);
    await tester.tap(find.byIcon(Icons.logout));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/game');
    expect(controller.save, isNotNull);
    expect(find.text('Could not save the changes.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    repository.writeError = null;
    await tester.tap(find.byIcon(Icons.logout));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(find.text('Main menu'), findsOneWidget);
    expect(repository.game.leagueState.currentDay, 2);
  });

  testWidgets('matchday reports a save failure before starting the match', (
    tester,
  ) async {
    repository.writeError = StateError('disk unavailable');
    await showCareer(tester, matchday: true);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(find.text('Could not save the changes.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(controller.save, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
