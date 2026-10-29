import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../persistence/no_disk_save_repository.dart';

Future<void> dashboardDragToBottom(WidgetTester tester, Finder list) async {
  for (var i = 0; i < 8; i++) {
    await tester.drag(list, const Offset(0, -500));
    await tester.pump();
  }
}

GameSave dashboardGame({required int seed}) {
  return GameFactory().create(
    NewGameRequest(
      saveName: 'Task 40 UI',
      playerTeamId: 'team_europe_0',
      seed: seed,
    ),
  );
}

class DashboardNoopSaveRepository extends NoDiskSaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}

Widget dashboardRouterApp(GoRouter router, GameSave game) {
  return ProviderScope(
    overrides: [
      saveRepositoryProvider.overrideWithValue(DashboardNoopSaveRepository()),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        return controller;
      }),
    ],
    child: MaterialApp.router(
      locale: const Locale('pl'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Widget dashboardApp(Widget screen, GameSave game) {
  return dashboardAppWithOverrides(screen, game);
}

Widget dashboardAppWithOverrides(
  Widget screen,
  GameSave game, {
  void Function(GameController controller)? onController,
}) {
  return ProviderScope(
    overrides: [
      saveRepositoryProvider.overrideWithValue(DashboardNoopSaveRepository()),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        onController?.call(controller);
        return controller;
      }),
    ],
    child: MaterialApp(
      locale: const Locale('pl'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  );
}
