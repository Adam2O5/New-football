import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/app/screens/load_game_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'announces actions and incompatible schema status in Polish and English',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      for (final locale in const [Locale('pl'), Locale('en')]) {
        for (final compatibility in const [
          SaveCompatibility.older,
          SaveCompatibility.newer,
        ]) {
          final record = _record(compatibility);
          await tester.pumpWidget(_app(locale, record));
          await tester.pumpAndSettle();

          final l10n = await AppLocalizations.delegate.load(locale);
          final actionLabels = [
            l10n.loadGame_loadSemantics(record.meta.name),
            l10n.loadGame_deleteSemantics(record.meta.name),
            l10n.loadGame_duplicateSemantics(record.meta.name),
            l10n.loadGame_renameSemantics(record.meta.name),
          ];

          expect(actionLabels.toSet(), hasLength(4));
          expect(
            find.byKey(ValueKey<String>('save-row-${record.meta.id}')),
            findsOneWidget,
          );
          for (final action in const [
            'load',
            'delete',
            'duplicate',
            'rename',
          ]) {
            expect(
              find.byKey(ValueKey<String>('save-$action-${record.meta.id}')),
              findsOneWidget,
            );
          }
          for (final tooltip in [
            l10n.loadGame_loadTooltip,
            l10n.loadGame_deleteTooltip,
            l10n.loadGame_duplicateTooltip,
            l10n.loadGame_renameTooltip,
          ]) {
            expect(find.byTooltip(tooltip), findsOneWidget);
          }
          for (final label in actionLabels) {
            expect(find.bySemanticsLabel(label), findsOneWidget);
          }

          final loadSemantics = tester.getSemantics(
            find.bySemanticsLabel(actionLabels[0]),
          );
          expect(loadSemantics.label, actionLabels[0]);
          expect(loadSemantics.flagsCollection.isButton, isTrue);
          expect(loadSemantics.flagsCollection.isEnabled, Tristate.isFalse);

          final statusLabel = compatibility == SaveCompatibility.older
              ? l10n.loadGame_schemaOlder
              : l10n.loadGame_schemaNewer;
          final reasonLabel = compatibility == SaveCompatibility.older
              ? l10n.loadGame_incompatibleOlder(
                  SaveSchema.currentVersion,
                  record.meta.schemaVersion,
                )
              : l10n.loadGame_incompatibleNewer(
                  SaveSchema.currentVersion,
                  record.meta.schemaVersion,
                );
          expect(find.bySemanticsLabel(statusLabel), findsOneWidget);
          expect(find.bySemanticsLabel(reasonLabel), findsOneWidget);
          expect(
            find.byKey(
              ValueKey<String>('save-schema-status-${record.meta.id}'),
            ),
            findsOneWidget,
          );
          expect(
            find.byKey(
              ValueKey<String>('save-schema-reason-${record.meta.id}'),
            ),
            findsOneWidget,
          );
        }
      }
      semanticsHandle.dispose();
    },
  );
}

SaveRecord _record(SaveCompatibility compatibility) {
  final schemaVersion = compatibility == SaveCompatibility.older
      ? SaveSchema.currentVersion - 1
      : SaveSchema.currentVersion + 1;
  final meta = GameSaveMeta(
    id: 'accessibility-${compatibility.name}',
    name: 'Accessibility ${compatibility.name}',
    createdAt: DateTime(2026, 1, 2, 3, 4),
    updatedAt: DateTime(2026, 1, 2, 5, 6),
    seasonYear: 2026,
    phase: SeasonPhase.regular,
    playerTeamName: 'Accessibility FC',
    schemaVersion: schemaVersion,
  );
  return SaveRecord(
    meta: meta,
    compatibility: compatibility,
    serializedFileAvailable: true,
    sizeBytes: 512,
  );
}

Widget _app(Locale locale, SaveRecord record) {
  return ProviderScope(
    key: ValueKey<String>(
      'load-accessibility-${locale.languageCode}-${record.meta.id}',
    ),
    overrides: [
      saveRecordsProvider.overrideWith((ref) async => [record]),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LoadGameScreen(),
    ),
  );
}
