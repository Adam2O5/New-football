import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/load_game_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/core/services/save_name_policy.dart';
import 'package:new_football/data/save_management_repository_adapter.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../persistence/no_disk_save_repository.dart';

Future<ProviderContainer> pumpScreen(
  WidgetTester tester, {
  required Locale locale,
  SaveRepository? repository,
  SaveManagementService? service,
  List<SaveRecord>? records,
  GameSave? activeGame,
  bool router = false,
  void Function(GameController controller)? onController,
}) async {
  final effectiveRepository = repository ?? WidgetSaveRepository();
  final overrides = <Override>[
    saveRepositoryProvider.overrideWithValue(effectiveRepository),
    gameControllerProvider.overrideWith((ref) {
      final controller = GameController(ref);
      if (activeGame != null) {
        controller.state = AsyncValue.data(activeGame);
      }
      onController?.call(controller);
      return controller;
    }),
  ];
  if (service != null) {
    overrides.add(saveManagementServiceProvider.overrideWithValue(service));
  }
  if (records != null) {
    overrides.add(saveRecordsProvider.overrideWith((ref) async => records));
  }

  SharedPreferences.setMockInitialValues(<String, Object>{
    'app_locale': locale.languageCode,
  });
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString('app_locale', locale.languageCode);
  overrides.add(sharedPreferencesProvider.overrideWithValue(preferences));

  final container = ProviderContainer(overrides: overrides);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: localizedApp(locale, router: router),
    ),
  );
  return container;
}

Widget localizedApp(Locale locale, {required bool router}) {
  const delegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  if (!router) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LoadGameScreen(),
    );
  }

  final goRouter = GoRouter(
    initialLocation: '/load-game',
    routes: [
      GoRoute(
        path: '/load-game',
        builder: (context, state) => const LoadGameScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const Scaffold(body: Text('game-route')),
      ),
    ],
  );
  return MaterialApp.router(
    locale: locale,
    localizationsDelegates: delegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: goRouter,
  );
}

Future<void> pumpFrames(
  WidgetTester tester, {
  int count = 8,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var index = 0; index < count; index++) {
    await tester.pump(step);
  }
}

Future<void> pumpUntilSnackBar(
  WidgetTester tester, {
  String? expectedText,
  int maxPumps = 20,
  Duration step = const Duration(milliseconds: 20),
}) async {
  for (var index = 0; index < maxPumps; index++) {
    await tester.pump(step);
    final snackBar = find.byType(SnackBar);
    if (snackBar.evaluate().isEmpty) continue;
    if (expectedText == null ||
        find
            .descendant(of: snackBar, matching: find.text(expectedText))
            .evaluate()
            .isNotEmpty) {
      return;
    }
  }
}

Future<void> removeCurrentSnackBar(WidgetTester tester) async {
  final scaffold = find.byType(Scaffold);
  if (scaffold.evaluate().isEmpty) return;
  ScaffoldMessenger.of(tester.element(scaffold.first)).removeCurrentSnackBar();
  await tester.pump();
}

Future<void> resetWidget(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();
}

bool isActionEnabled(WidgetTester tester, String key) {
  return tester
          .widget<IconButton>(find.byKey(ValueKey<String>(key)))
          .onPressed !=
      null;
}

String phaseLabel(AppLocalizations l10n, SeasonPhase phase) {
  return switch (phase) {
    SeasonPhase.preseason => l10n.seasonPhase_preseason,
    SeasonPhase.regular => l10n.seasonPhase_regular,
    SeasonPhase.playIn => l10n.seasonPhase_playIn,
    SeasonPhase.playoff => l10n.seasonPhase_playoff,
    SeasonPhase.offseason => l10n.seasonPhase_offseason,
  };
}

SaveRecord saveRecordFixture(
  String id, {
  required String name,
  SaveCompatibility compatibility = SaveCompatibility.compatible,
  bool serializedFileAvailable = true,
  int? sizeBytes = 512,
  DateTime? updatedAt,
  String? playerTeamName = 'Lions FC',
  SeasonPhase phase = SeasonPhase.regular,
}) {
  final schemaVersion = switch (compatibility) {
    SaveCompatibility.compatible => SaveSchema.currentVersion,
    SaveCompatibility.older => SaveSchema.currentVersion - 1,
    SaveCompatibility.newer => SaveSchema.currentVersion + 1,
  };
  final timestamp = updatedAt ?? DateTime(2026, 1, 2, 3, 4);
  final meta = GameSaveMeta(
    id: id,
    name: name,
    createdAt: timestamp.subtract(const Duration(days: 10)),
    updatedAt: timestamp,
    seasonYear: 2026,
    phase: phase,
    playerTeamName: playerTeamName,
    schemaVersion: schemaVersion,
  );
  return SaveRecord(
    meta: meta,
    compatibility: compatibility,
    serializedFileAvailable: serializedFileAvailable,
    sizeBytes: sizeBytes,
  );
}

GameSave gameFor(SaveRecord record) {
  final generated = GameFactory().create(
    const NewGameRequest(
      saveName: 'Widget test game',
      playerTeamId: 'team_europe_0',
      seed: 9101,
    ),
  );
  return generated.copyWith(meta: record.meta);
}

class WidgetSaveRepository extends NoDiskSaveRepository {
  final Map<String, GameSave> loadedGames = {};
  FutureOr<void> Function(String id)? onDelete;
  Object? loadError;
  Object? deleteError;
  int loadCalls = 0;
  int deleteCalls = 0;

  @override
  Future<GameSave> load(String id) async {
    loadCalls++;
    final error = loadError;
    if (error != null) throw error;
    final game = loadedGames[id];
    if (game == null) {
      throw SaveRepositoryException('Missing controlled game $id');
    }
    return game;
  }

  @override
  Future<void> delete(String id) async {
    deleteCalls++;
    final error = deleteError;
    if (error != null) throw error;
    await onDelete?.call(id);
  }
}

class MutableManagementService extends SaveManagementService {
  MutableManagementService({
    required SaveRepository repository,
    Iterable<SaveRecord> initial = const [],
  }) : records = List<SaveRecord>.from(initial),
       super(repository: SaveManagementRepositoryAdapter(repository));

  final List<SaveRecord> records;
  Object? listError;
  Completer<List<SaveRecord>>? listCompleter;
  SaveManagementException? duplicateFailure;
  SaveManagementException? renameFailure;
  Completer<void>? duplicateStarted;
  Completer<void>? duplicateRelease;
  Completer<void>? renameStarted;
  Completer<void>? renameRelease;
  int listRecordsCalls = 0;
  int duplicateCalls = 0;
  int renameCalls = 0;

  @override
  Future<List<SaveRecord>> listRecords() async {
    listRecordsCalls++;
    final error = listError;
    if (error != null) throw error;
    final pending = listCompleter;
    if (pending != null) return pending.future;
    return List<SaveRecord>.unmodifiable(records);
  }

  @override
  Future<SaveManagementResult> duplicate(
    String sourceId, {
    required String localeCode,
  }) async {
    duplicateCalls++;
    final started = duplicateStarted;
    if (started != null && !started.isCompleted) started.complete();
    final release = duplicateRelease;
    if (release != null) await release.future;
    final failure = duplicateFailure;
    if (failure != null) throw failure;

    final source = records.singleWhere((record) => record.meta.id == sourceId);
    final occupied = records
        .map((record) => SaveNamePolicy.nameKey(record.meta.name))
        .toSet();
    final copyName = SaveNamePolicy.copyName(
      source.meta.name,
      localeCode,
      occupied,
    );
    final copyMeta = source.meta.copyWith(
      id: 'copy-$duplicateCalls',
      name: copyName,
      createdAt: DateTime.utc(2040, 1, 2, 3, 4, 5),
      updatedAt: DateTime.utc(2040, 1, 2, 3, 4, 5),
    );
    final copy = SaveRecord(
      meta: copyMeta,
      compatibility: source.compatibility,
      serializedFileAvailable: source.serializedFileAvailable,
      sizeBytes: source.sizeBytes == null
          ? null
          : source.sizeBytes! + copyName.length,
    );
    records.add(copy);
    return SaveManagementResult.duplicate(copyMeta);
  }

  @override
  Future<SaveManagementResult> rename(
    String saveId,
    String proposedName,
  ) async {
    renameCalls++;
    final started = renameStarted;
    if (started != null && !started.isCompleted) started.complete();
    final release = renameRelease;
    if (release != null) await release.future;
    final failure = renameFailure;
    if (failure != null) throw failure;

    final trimmedName = proposedName.trim();
    final index = records.indexWhere((record) => record.meta.id == saveId);
    if (index < 0) {
      throw const SaveManagementException(
        SaveManagementFailure.sourceUnavailable,
      );
    }
    final current = records[index];
    final updatedMeta = current.meta.copyWith(name: trimmedName);
    records[index] = SaveRecord(
      meta: updatedMeta,
      compatibility: current.compatibility,
      serializedFileAvailable: current.serializedFileAvailable,
      sizeBytes: current.sizeBytes == null
          ? null
          : current.sizeBytes! + trimmedName.length,
    );
    return SaveManagementResult.rename(updatedMeta);
  }

  void remove(String id) {
    records.removeWhere((record) => record.meta.id == id);
  }
}
