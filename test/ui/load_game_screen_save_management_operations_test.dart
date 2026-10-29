@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/load_game_screen_harness.dart';

void main() {
  testWidgets(
    'keeps existing delete confirmation and clears an active save only after confirmation',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final record = saveRecordFixture(
          'delete-active-${locale.languageCode}',
          name: 'Delete me',
        );
        final repository = WidgetSaveRepository();
        final service = MutableManagementService(
          repository: repository,
          initial: [record],
        );
        repository.onDelete = service.remove;
        final activeGame = gameFor(record);
        GameController? controller;
        final container = await pumpScreen(
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
        final record = saveRecordFixture(
          'load-${locale.languageCode}',
          name: 'Load checkpoint',
        );
        final loadedGame = gameFor(record);
        final repository = WidgetSaveRepository()
          ..loadedGames[record.meta.id] = loadedGame;
        final container = await pumpScreen(
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

        final failingRepository = WidgetSaveRepository()
          ..loadError = SaveRepositoryException('controlled load failure');
        final failureContainer = await pumpScreen(
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
        await pumpUntilSnackBar(tester, expectedText: l10n.loadGame_loadFailed);
        expect(find.text(l10n.loadGame_loadFailed), findsOneWidget);
        expect(find.text(l10n.loadGame_title), findsOneWidget);
        expect(find.text('game-route'), findsNothing);
        failureContainer.dispose();
        await resetWidget(tester);
      }
    },
  );

  testWidgets(
    'duplicates exactly once, refreshes the list, preserves the source and uses the active locale suffix',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final source = saveRecordFixture(
          'duplicate-source-${locale.languageCode}',
          name: 'Checkpoint',
          sizeBytes: 850,
        );
        final repository = WidgetSaveRepository();
        final service = MutableManagementService(
          repository: repository,
          initial: [source],
        );
        final container = await pumpScreen(
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
        await pumpUntilSnackBar(
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
        await resetWidget(tester);
      }
    },
  );
}
