@Tags(['ui'])
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/load_game_screen_harness.dart';

void main() {
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
            final record = saveRecordFixture(
              'semantics-${locale.languageCode}-${compatibility.name}',
              name: 'Readable ${compatibility.name}',
              compatibility: compatibility,
            );
            final container = await pumpScreen(
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
}
