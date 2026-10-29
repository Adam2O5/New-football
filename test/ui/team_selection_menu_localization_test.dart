@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/team_selection_harness.dart';

void main() {
  testWidgets('uses generated locale text for chrome and both snackbars', (
    tester,
  ) async {
    for (final locale in const [Locale('pl'), Locale('en')]) {
      final missingFieldsHarness = TeamSelectionHarness(locale: locale);
      try {
        await missingFieldsHarness.pump(tester);
        final l10n = await AppLocalizations.delegate.load(locale);
        expectLocalizedNewGameChrome(tester, l10n);

        await tester.tap(
          find.byKey(const ValueKey<String>('new-game-start-button')),
        );
        await pumpUntilSnackBar(
          tester,
          expectedText: l10n.newGame_missingFields,
        );
        expect(find.text(l10n.newGame_missingFields), findsOneWidget);
      } finally {
        await missingFieldsHarness.dispose(tester);
      }

      final failureRepository = TeamSelectionSaveRepository()
        ..saveFailure = SaveRepositoryException('localized failure');
      final failureHarness = TeamSelectionHarness(
        locale: locale,
        repository: failureRepository,
      );
      try {
        await failureHarness.pump(tester);
        final l10n = await AppLocalizations.delegate.load(locale);
        await activateTeam(
          tester,
          failureHarness.gameFactory.previewTeams().first.id,
        );
        await tester.tap(
          find.byKey(const ValueKey<String>('new-game-start-button')),
        );
        await pumpUntilSnackBar(
          tester,
          expectedText: l10n.newGame_createFailed,
        );
        expect(find.text(l10n.newGame_createFailed), findsOneWidget);
      } finally {
        await failureHarness.dispose(tester);
      }
    }
  });

  testWidgets('preserves selection while rebuilding into another locale', (
    tester,
  ) async {
    final harness = TeamSelectionHarness(locale: const Locale('pl'));
    SemanticsHandle? semanticsHandle;
    try {
      await harness.pump(tester);
      semanticsHandle = ensureSemantics(tester);
      await tester.pump();

      final selectedTeam = harness.gameFactory.previewTeams().first;
      await activateTeam(tester, selectedTeam.id);
      expect(
        tester.widget<TeamRow>(teamRowFinder(selectedTeam.id)).selected,
        isTrue,
      );

      await harness.rebuildWithLocale(tester, const Locale('en'));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expectLocalizedNewGameChrome(tester, l10n);
      expect(harness.router.state.uri.path, '/new-game');
      expect(
        tester.widget<TeamRow>(teamRowFinder(selectedTeam.id)).selected,
        isTrue,
      );

      final expectedLabel = l10n.newGame_teamSemantics(
        selectedTeam.name,
        selectedTeam.city,
        selectionConferenceLabel(l10n, selectedTeam.conference),
        l10n.newGame_teamSelected,
      );
      expect(find.bySemanticsLabel(expectedLabel), findsOneWidget);
    } finally {
      semanticsHandle?.dispose();
      await harness.dispose(tester);
    }
  });
}
