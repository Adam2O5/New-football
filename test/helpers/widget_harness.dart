import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

GameSave task41Game({required int seed}) {
  return GameFactory().create(
    NewGameRequest(
      saveName: 'Task 41 UI',
      playerTeamId: 'team_europe_0',
      seed: seed,
    ),
  );
}

class Task41NoopSaveRepository extends SaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}

Widget task41App(
  Widget screen,
  GameSave game, {
  void Function(GameController controller)? onController,
}) {
  return ProviderScope(
    overrides: [
      saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
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
