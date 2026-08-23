@Tags(['ui'])
library;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/load_game_screen.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/core/services/save_name_policy.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'renders one row per record with metadata, date and size in Polish and English',
    (tester) async {
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1;

      for (final locale in const [Locale('pl'), Locale('en')]) {
        final records = [
          _record(
            'metadata-compatible',
            name: 'Recent checkpoint',
            playerTeamName: 'Lions FC',
            updatedAt: DateTime(2026, 2, 3, 14, 5),
            sizeBytes: 512,
          ),
          _record(
            'metadata-older',
            name: 'Older checkpoint',
            compatibility: SaveCompatibility.older,
            playerTeamName: 'Tigers FC',
            updatedAt: DateTime(2026, 1, 2, 9, 15),
            sizeBytes: 1024,
          ),
          _record(
            'metadata-newer',
            name: 'Future checkpoint',
            compatibility: SaveCompatibility.newer,
            playerTeamName: 'Future FC',
            updatedAt: DateTime(2025, 12, 31, 23, 59),
            sizeBytes: null,
          ),
          _record(
            'metadata-missing',
            name: 'Missing file checkpoint',
            playerTeamName: 'Missing FC',
            serializedFileAvailable: false,
            updatedAt: DateTime(2025, 11, 30, 8, 0),
            sizeBytes: null,
          ),
        ];
        final container = await _pumpScreen(
          tester,
          locale: locale,
          records: records,
        );
        await tester.pumpAndSettle();

        final l10n = await AppLocalizations.delegate.load(locale);
        for (final record in records) {
          final row = find.byKey(
            ValueKey<String>('save-row-${record.meta.id}'),
          );
          expect(row, findsOneWidget);
          expect(find.text(record.meta.name), findsOneWidget);
          expect(
            find.text(
              l10n.loadGame_subtitle(
                record.meta.playerTeamName ?? '—',
                record.meta.seasonYear,
                _phaseLabel(l10n, record.meta.phase),
              ),
            ),
            findsOneWidget,
          );
          expect(
            find.text(
              '${l10n.loadGame_lastSaveDate}: '
              '${formatSaveDate(record.meta.updatedAt, locale.languageCode)}',
            ),
            findsOneWidget,
          );
          final expectedSize = formatSaveSize(record.sizeBytes);
          expect(
            find.text(
              '${l10n.loadGame_saveSize}: '
              '${record.serializedFileAvailable && expectedSize != null ? expectedSize : l10n.loadGame_sizeUnavailable}',
            ),
            findsAtLeastNWidgets(1),
          );
        }
        expect(find.text(l10n.loadGame_schemaOlder), findsOneWidget);
        expect(find.text(l10n.loadGame_schemaNewer), findsOneWidget);
        expect(
          find.textContaining(l10n.loadGame_sizeUnavailable),
          findsNWidgets(2),
        );
        expect(find.text('0 B'), findsNothing);

        container.dispose();
      }
    },
  );

  testWidgets(
    'renders empty, loading and localized read-error states while staying mounted',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final emptyContainer = await _pumpScreen(
          tester,
          locale: locale,
          records: const [],
        );
        await tester.pumpAndSettle();
        final l10n = await AppLocalizations.delegate.load(locale);
        expect(find.text(l10n.loadGame_empty), findsOneWidget);
        expect(find.text(l10n.loadGame_title), findsOneWidget);
        emptyContainer.dispose();

        final errorService =
            _MutableManagementService(repository: _WidgetSaveRepository())
              ..listError = const SaveManagementException(
                SaveManagementFailure.indexReadFailed,
              );
        final errorContainer = await _pumpScreen(
          tester,
          locale: locale,
          service: errorService,
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.loadGame_indexReadFailed), findsOneWidget);
        expect(find.text(l10n.loadGame_title), findsOneWidget);
        errorContainer.dispose();

        final pendingService = _MutableManagementService(
          repository: _WidgetSaveRepository(),
        )..listCompleter = Completer<List<SaveRecord>>();
        final loadingContainer = await _pumpScreen(
          tester,
          locale: locale,
          service: pendingService,
        );
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        pendingService.listCompleter!.complete(const <SaveRecord>[]);
        await tester.pumpAndSettle();
        expect(find.text(l10n.loadGame_empty), findsOneWidget);
        loadingContainer.dispose();
      }
    },
  );

  testWidgets(
    'gates actions by compatibility and canonical-file availability',
    (tester) async {
      final cases = [
        (
          compatibility: SaveCompatibility.compatible,
          serializedFileAvailable: true,
          loadEnabled: true,
          manageEnabled: true,
        ),
        (
          compatibility: SaveCompatibility.older,
          serializedFileAvailable: true,
          loadEnabled: false,
          manageEnabled: true,
        ),
        (
          compatibility: SaveCompatibility.newer,
          serializedFileAvailable: true,
          loadEnabled: false,
          manageEnabled: true,
        ),
        (
          compatibility: SaveCompatibility.compatible,
          serializedFileAvailable: false,
          loadEnabled: true,
          manageEnabled: false,
        ),
        (
          compatibility: SaveCompatibility.older,
          serializedFileAvailable: false,
          loadEnabled: false,
          manageEnabled: false,
        ),
      ];

      for (final locale in const [Locale('pl'), Locale('en')]) {
        for (var index = 0; index < cases.length; index++) {
          final testCase = cases[index];
          final record = _record(
            'gating-$index',
            name: 'Gating ${testCase.compatibility.name} $index',
            compatibility: testCase.compatibility,
            serializedFileAvailable: testCase.serializedFileAvailable,
          );
          final container = await _pumpScreen(
            tester,
            locale: locale,
            records: [record],
          );
          await tester.pumpAndSettle();

          expect(
            _isActionEnabled(tester, 'save-load-${record.meta.id}'),
            testCase.loadEnabled,
          );
          expect(
            _isActionEnabled(tester, 'save-delete-${record.meta.id}'),
            isTrue,
          );
          expect(
            _isActionEnabled(tester, 'save-duplicate-${record.meta.id}'),
            testCase.manageEnabled,
          );
          expect(
            _isActionEnabled(tester, 'save-rename-${record.meta.id}'),
            testCase.manageEnabled,
          );

          final l10n = await AppLocalizations.delegate.load(locale);
          if (testCase.compatibility != SaveCompatibility.compatible) {
            expect(
              find.text(
                testCase.compatibility == SaveCompatibility.older
                    ? l10n.loadGame_schemaOlder
                    : l10n.loadGame_schemaNewer,
              ),
              findsOneWidget,
            );
          }
          container.dispose();
        }
      }
    },
  );

  testWidgets(
    'announces four distinct localized actions, tooltips and disabled schema load',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        for (final locale in const [Locale('pl'), Locale('en')]) {
          for (final compatibility in const [
            SaveCompatibility.compatible,
            SaveCompatibility.older,
            SaveCompatibility.newer,
          ]) {
            final record = _record(
              'semantics-${locale.languageCode}-${compatibility.name}',
              name: 'Readable ${compatibility.name}',
              compatibility: compatibility,
            );
            final container = await _pumpScreen(
              tester,
              locale: locale,
              records: [record],
            );
            await tester.pumpAndSettle();
            final l10n = await AppLocalizations.delegate.load(locale);
            final labels = [
              l10n.loadGame_loadSemantics(record.meta.name),
              l10n.loadGame_deleteSemantics(record.meta.name),
              l10n.loadGame_duplicateSemantics(record.meta.name),
              l10n.loadGame_renameSemantics(record.meta.name),
            ];

            expect(labels.toSet(), hasLength(4));
            for (final label in labels) {
              final semantics = tester.getSemantics(
                find.bySemanticsLabel(label),
              );
              expect(semantics.label, label);
              expect(semantics.flagsCollection.isButton, isTrue);
            }
            for (final tooltip in [
              l10n.loadGame_loadTooltip,
              l10n.loadGame_deleteTooltip,
              l10n.loadGame_duplicateTooltip,
              l10n.loadGame_renameTooltip,
            ]) {
              expect(find.byTooltip(tooltip), findsOneWidget);
            }

            final loadSemantics = tester.getSemantics(
              find.bySemanticsLabel(labels.first),
            );
            expect(
              loadSemantics.flagsCollection.isEnabled,
              compatibility == SaveCompatibility.compatible
                  ? Tristate.isTrue
                  : Tristate.isFalse,
            );
            container.dispose();
          }
        }
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'keeps existing delete confirmation and clears an active save only after confirmation',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final record = _record(
          'delete-active-${locale.languageCode}',
          name: 'Delete me',
        );
        final repository = _WidgetSaveRepository();
        final service = _MutableManagementService(
          repository: repository,
          initial: [record],
        );
        repository.onDelete = service.remove;
        final activeGame = _gameFor(record);
        GameController? controller;
        final container = await _pumpScreen(
          tester,
          locale: locale,
          repository: repository,
          service: service,
          activeGame: activeGame,
          onController: (value) => controller = value,
        );
        await tester.pumpAndSettle();
        final l10n = await AppLocalizations.delegate.load(locale);

        await tester.tap(
          find.byKey(ValueKey<String>('save-delete-${record.meta.id}')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text(l10n.loadGame_deleteConfirmTitle), findsOneWidget);
        expect(
          find.text(l10n.loadGame_deleteConfirmMessage(record.meta.name)),
          findsOneWidget,
        );
        expect(find.text(l10n.common_cancel), findsOneWidget);
        expect(find.text(l10n.loadGame_delete), findsOneWidget);

        await tester.tap(find.text(l10n.common_cancel));
        await tester.pumpAndSettle();
        expect(
          find.byKey(ValueKey<String>('save-row-${record.meta.id}')),
          findsOneWidget,
        );
        expect(repository.deleteCalls, 0);

        await tester.tap(
          find.byKey(ValueKey<String>('save-delete-${record.meta.id}')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.loadGame_delete));
        await tester.pumpAndSettle();
        expect(repository.deleteCalls, 1);
        expect(
          find.byKey(ValueKey<String>('save-row-${record.meta.id}')),
          findsNothing,
        );
        expect(controller!.save, isNull);

        container.dispose();
      }
    },
  );

  testWidgets(
    'keeps existing compatible load behavior and reports load failures without leaving the screen',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final record = _record(
          'load-${locale.languageCode}',
          name: 'Load checkpoint',
        );
        final loadedGame = _gameFor(record);
        final repository = _WidgetSaveRepository()
          ..loadedGames[record.meta.id] = loadedGame;
        final container = await _pumpScreen(
          tester,
          locale: locale,
          repository: repository,
          records: [record],
          router: true,
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(ValueKey<String>('save-load-${record.meta.id}')),
        );
        await tester.pumpAndSettle();
        expect(repository.loadCalls, 1);
        expect(find.text('game-route'), findsOneWidget);
        container.dispose();

        final failingRepository = _WidgetSaveRepository()
          ..loadError = SaveRepositoryException('controlled load failure');
        final failureContainer = await _pumpScreen(
          tester,
          locale: locale,
          repository: failingRepository,
          records: [record],
          router: true,
        );
        await tester.pumpAndSettle();
        final l10n = await AppLocalizations.delegate.load(locale);
        await tester.tap(
          find.byKey(ValueKey<String>('save-load-${record.meta.id}')),
        );
        await _pumpUntilSnackBar(
          tester,
          expectedText: l10n.loadGame_loadFailed,
        );
        expect(find.text(l10n.loadGame_loadFailed), findsOneWidget);
        expect(find.text(l10n.loadGame_title), findsOneWidget);
        expect(find.text('game-route'), findsNothing);
        failureContainer.dispose();
        await _resetWidget(tester);
      }
    },
  );

  testWidgets(
    'duplicates exactly once, refreshes the list, preserves the source and uses the active locale suffix',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final source = _record(
          'duplicate-source-${locale.languageCode}',
          name: 'Checkpoint',
          sizeBytes: 850,
        );
        final repository = _WidgetSaveRepository();
        final service = _MutableManagementService(
          repository: repository,
          initial: [source],
        );
        final container = await _pumpScreen(
          tester,
          locale: locale,
          repository: repository,
          service: service,
        );
        await tester.pumpAndSettle();
        final l10n = await AppLocalizations.delegate.load(locale);

        final expectedCopyName = locale.languageCode == 'pl'
            ? 'Checkpoint-kopia'
            : 'Checkpoint-copy';
        await tester.tap(
          find.byKey(ValueKey<String>('save-duplicate-${source.meta.id}')),
        );
        await _pumpUntilSnackBar(
          tester,
          expectedText: l10n.loadGame_duplicateSuccess(expectedCopyName),
        );
        expect(find.byType(SnackBar), findsOneWidget);

        expect(service.duplicateCalls, 1);
        expect(service.records, hasLength(2));
        expect(
          service.records.where((record) => record.meta.id == source.meta.id),
          hasLength(1),
        );
        final copy = service.records.singleWhere(
          (record) => record.meta.id != source.meta.id,
        );
        expect(
          copy.meta.name,
          endsWith(locale.languageCode == 'pl' ? '-kopia' : '-copy'),
        );
        expect(
          find.byKey(ValueKey<String>('save-row-${source.meta.id}')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey<String>('save-row-${copy.meta.id}')),
          findsOneWidget,
        );
        expect(find.text(source.meta.name), findsOneWidget);
        expect(find.text(copy.meta.name), findsOneWidget);
        expect(
          find.text(l10n.loadGame_duplicateSuccess(copy.meta.name)),
          findsOneWidget,
        );
        expect(
          find.text(
            '${l10n.loadGame_saveSize}: ${formatSaveSize(copy.sizeBytes)}',
          ),
          findsOneWidget,
        );
        container.dispose();
        await _resetWidget(tester);
      }
    },
  );

  testWidgets(
    'gates duplicate while pending, reports ambiguous failure, and permits retry',
    (tester) async {
      final source = _record('duplicate-gated', name: 'Gated checkpoint');
      final service =
          _MutableManagementService(
              repository: _WidgetSaveRepository(),
              initial: [source],
            )
            ..duplicateStarted = Completer<void>()
            ..duplicateRelease = Completer<void>();
      final container = await _pumpScreen(
        tester,
        locale: const Locale('en'),
        service: service,
      );
      await tester.pumpAndSettle();

      final duplicateKey = 'save-duplicate-${source.meta.id}';
      await tester.tap(find.byKey(ValueKey<String>(duplicateKey)));
      await service.duplicateStarted!.future;
      await tester.pump();
      expect(_isActionEnabled(tester, duplicateKey), isFalse);

      service.duplicateRelease!.complete();
      await tester.pumpAndSettle();
      expect(_isActionEnabled(tester, duplicateKey), isTrue);
      expect(service.records, hasLength(2));
      await _removeCurrentSnackBar(tester);

      service.duplicateFailure = const SaveManagementException(
        SaveManagementFailure.ambiguousWrite,
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.byKey(ValueKey<String>(duplicateKey)));
      await _pumpUntilSnackBar(
        tester,
        expectedText: l10n.loadGame_ambiguousWrite,
      );
      expect(find.text(l10n.loadGame_ambiguousWrite), findsOneWidget);
      expect(
        find.byKey(ValueKey<String>('save-row-${source.meta.id}')),
        findsOneWidget,
      );
      expect(_isActionEnabled(tester, duplicateKey), isTrue);
      expect(find.textContaining('created'), findsNothing);
      await _removeCurrentSnackBar(tester);

      service.duplicateFailure = null;
      await tester.tap(find.byKey(ValueKey<String>(duplicateKey)));
      await _pumpFrames(tester);
      expect(service.duplicateCalls, 3);
      expect(service.records, hasLength(3));
      expect(
        service.records.where((record) => record.meta.id == source.meta.id),
        hasLength(1),
      );
      expect(
        find.byKey(ValueKey<String>('save-row-${source.meta.id}')),
        findsOneWidget,
      );
      expect(find.byKey(ValueKey<String>('save-row-copy-3')), findsOneWidget);
      container.dispose();
      await _resetWidget(tester);
    },
  );

  testWidgets(
    'supports rename autofocus, trim, validation, gating, active-state sync and refresh without an extra row in both locales',
    (tester) async {
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1;

      for (final locale in const [Locale('pl'), Locale('en')]) {
        final source = _record(
          'rename-source-${locale.languageCode}',
          name: 'Alpha',
          sizeBytes: 400,
        );
        final other = _record(
          'rename-other-${locale.languageCode}',
          name: 'Beta',
          updatedAt: DateTime(2025, 1, 1),
          sizeBytes: 500,
        );
        final repository = _WidgetSaveRepository();
        final service = _MutableManagementService(
          repository: repository,
          initial: [source, other],
        );
        final activeGame = _gameFor(source);
        GameController? controller;
        final container = await _pumpScreen(
          tester,
          locale: locale,
          repository: repository,
          service: service,
          activeGame: activeGame,
          onController: (value) => controller = value,
        );
        await tester.pumpAndSettle();
        final l10n = await AppLocalizations.delegate.load(locale);
        final renameKey = 'save-rename-${source.meta.id}';
        final fieldKey = 'save-rename-field-${source.meta.id}';
        final confirmKey = 'save-rename-confirm-${source.meta.id}';

        await tester.tap(find.byKey(ValueKey<String>(renameKey)));
        await tester.pumpAndSettle();
        final field = find.byKey(ValueKey<String>(fieldKey));
        expect(
          find.byKey(ValueKey<String>('rename-dialog-${source.meta.id}')),
          findsOneWidget,
        );
        expect(tester.widget<TextField>(field).autofocus, isTrue);
        final editable = find.descendant(
          of: field,
          matching: find.byType(EditableText),
        );
        expect(
          tester.widget<EditableText>(editable).focusNode.hasFocus,
          isTrue,
        );
        expect(
          tester.widget<TextField>(field).controller!.text,
          source.meta.name,
        );

        await tester.enterText(field, '   ');
        await tester.tap(find.byKey(ValueKey<String>(confirmKey)));
        await tester.pump();
        expect(find.text(l10n.loadGame_nameEmpty), findsOneWidget);
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(service.renameCalls, 0);

        await tester.enterText(field, ' alpha ');
        await tester.tap(find.byKey(ValueKey<String>(confirmKey)));
        await tester.pump();
        expect(find.text(l10n.loadGame_nameSame), findsOneWidget);
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(service.renameCalls, 0);

        await tester.enterText(field, '  beta  ');
        await tester.tap(find.byKey(ValueKey<String>(confirmKey)));
        await tester.pump();
        expect(find.text(l10n.loadGame_nameTaken), findsOneWidget);
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(service.renameCalls, 0);

        await tester.enterText(field, '  Renamed checkpoint  ');
        service.renameStarted = Completer<void>();
        service.renameRelease = Completer<void>();
        await tester.tap(find.byKey(ValueKey<String>(confirmKey)));
        await service.renameStarted!.future;
        await tester.pump();
        expect(
          tester
              .widget<TextButton>(find.byKey(ValueKey<String>(confirmKey)))
              .onPressed,
          isNull,
        );
        service.renameRelease!.complete();
        await _pumpUntilSnackBar(
          tester,
          expectedText: l10n.loadGame_renameSuccess('Renamed checkpoint'),
        );

        expect(service.renameCalls, 1);
        expect(service.records, hasLength(2));
        final renamed = service.records.singleWhere(
          (record) => record.meta.id == source.meta.id,
        );
        expect(renamed.meta.name, 'Renamed checkpoint');
        expect(
          find.byKey(ValueKey<String>('save-row-${source.meta.id}')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey<String>('save-row-${other.meta.id}')),
          findsOneWidget,
        );
        expect(find.text('Renamed checkpoint'), findsOneWidget);
        expect(find.text('Alpha'), findsNothing);
        expect(
          find.text(l10n.loadGame_renameSuccess('Renamed checkpoint')),
          findsOneWidget,
        );
        expect(controller!.save!.meta.id, source.meta.id);
        expect(controller!.save!.meta.name, 'Renamed checkpoint');
        expect(controller!.save!.leagueState, same(activeGame.leagueState));
        expect(controller!.save!.saveSeed, activeGame.saveSeed);
        expect(
          find.text(
            '${l10n.loadGame_saveSize}: ${formatSaveSize(400 + 'Renamed checkpoint'.length)}',
          ),
          findsOneWidget,
        );

        container.dispose();
        await _resetWidget(tester);
      }
    },
  );
}

Future<ProviderContainer> _pumpScreen(
  WidgetTester tester, {
  required Locale locale,
  SaveRepository? repository,
  SaveManagementService? service,
  List<SaveRecord>? records,
  GameSave? activeGame,
  bool router = false,
  void Function(GameController controller)? onController,
}) async {
  final effectiveRepository = repository ?? _WidgetSaveRepository();
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
      child: _localizedApp(locale, router: router),
    ),
  );
  return container;
}

Widget _localizedApp(Locale locale, {required bool router}) {
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

Future<void> _pumpFrames(
  WidgetTester tester, {
  int count = 8,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var index = 0; index < count; index++) {
    await tester.pump(step);
  }
}

Future<void> _pumpUntilSnackBar(
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

Future<void> _removeCurrentSnackBar(WidgetTester tester) async {
  final scaffold = find.byType(Scaffold);
  if (scaffold.evaluate().isEmpty) return;
  ScaffoldMessenger.of(tester.element(scaffold.first)).removeCurrentSnackBar();
  await tester.pump();
}

Future<void> _resetWidget(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();
}

bool _isActionEnabled(WidgetTester tester, String key) {
  return tester
          .widget<IconButton>(find.byKey(ValueKey<String>(key)))
          .onPressed !=
      null;
}

String _phaseLabel(AppLocalizations l10n, SeasonPhase phase) {
  return switch (phase) {
    SeasonPhase.preseason => l10n.seasonPhase_preseason,
    SeasonPhase.regular => l10n.seasonPhase_regular,
    SeasonPhase.playIn => l10n.seasonPhase_playIn,
    SeasonPhase.playoff => l10n.seasonPhase_playoff,
    SeasonPhase.offseason => l10n.seasonPhase_offseason,
  };
}

SaveRecord _record(
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

GameSave _gameFor(SaveRecord record) {
  final generated = GameFactory().create(
    const NewGameRequest(
      saveName: 'Widget test game',
      playerTeamId: 'team_europe_0',
      seed: 9101,
    ),
  );
  return generated.copyWith(meta: record.meta);
}

class _WidgetSaveRepository extends SaveRepository {
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

class _MutableManagementService extends SaveManagementService {
  _MutableManagementService({
    required SaveRepository repository,
    Iterable<SaveRecord> initial = const [],
  }) : records = List<SaveRecord>.from(initial),
       super(repository: repository);

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
