@Tags(['ui'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/app/screens/load_game_screen.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/load_game_screen_harness.dart';

void main() {
  testWidgets(
    'renders one row per record with metadata, date and size in Polish and English',
    (tester) async {
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1;

      for (final locale in const [Locale('pl'), Locale('en')]) {
        final records = [
          saveRecordFixture(
            'metadata-compatible',
            name: 'Recent checkpoint',
            playerTeamName: 'Lions FC',
            updatedAt: DateTime(2026, 2, 3, 14, 5),
            sizeBytes: 512,
          ),
          saveRecordFixture(
            'metadata-older',
            name: 'Older checkpoint',
            compatibility: SaveCompatibility.older,
            playerTeamName: 'Tigers FC',
            updatedAt: DateTime(2026, 1, 2, 9, 15),
            sizeBytes: 1024,
          ),
          saveRecordFixture(
            'metadata-newer',
            name: 'Future checkpoint',
            compatibility: SaveCompatibility.newer,
            playerTeamName: 'Future FC',
            updatedAt: DateTime(2025, 12, 31, 23, 59),
            sizeBytes: null,
          ),
          saveRecordFixture(
            'metadata-missing',
            name: 'Missing file checkpoint',
            playerTeamName: 'Missing FC',
            serializedFileAvailable: false,
            updatedAt: DateTime(2025, 11, 30, 8, 0),
            sizeBytes: null,
          ),
        ];
        final container = await pumpScreen(
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
                phaseLabel(l10n, record.meta.phase),
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
        final emptyContainer = await pumpScreen(
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
            MutableManagementService(repository: WidgetSaveRepository())
              ..listError = const SaveManagementException(
                SaveManagementFailure.indexReadFailed,
              );
        final errorContainer = await pumpScreen(
          tester,
          locale: locale,
          service: errorService,
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.loadGame_indexReadFailed), findsOneWidget);
        expect(find.text(l10n.loadGame_title), findsOneWidget);
        errorContainer.dispose();

        final pendingService = MutableManagementService(
          repository: WidgetSaveRepository(),
        )..listCompleter = Completer<List<SaveRecord>>();
        final loadingContainer = await pumpScreen(
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
          final record = saveRecordFixture(
            'gating-$index',
            name: 'Gating ${testCase.compatibility.name} $index',
            compatibility: testCase.compatibility,
            serializedFileAvailable: testCase.serializedFileAvailable,
          );
          final container = await pumpScreen(
            tester,
            locale: locale,
            records: [record],
          );
          await tester.pumpAndSettle();

          expect(
            isActionEnabled(tester, 'save-load-${record.meta.id}'),
            testCase.loadEnabled,
          );
          expect(
            isActionEnabled(tester, 'save-delete-${record.meta.id}'),
            isTrue,
          );
          expect(
            isActionEnabled(tester, 'save-duplicate-${record.meta.id}'),
            testCase.manageEnabled,
          );
          expect(
            isActionEnabled(tester, 'save-rename-${record.meta.id}'),
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

  for (final language in ['pl', 'en']) {
    testWidgets('save list displays ambiguous recovery message in $language', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            saveRecordsProvider.overrideWith((ref) async {
              throw const SaveManagementException(
                SaveManagementFailure.ambiguousWrite,
              );
            }),
          ],
          child: MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LoadGameScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(LoadGameScreen)),
      )!;
      expect(find.text(l10n.loadGame_ambiguousWrite), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
