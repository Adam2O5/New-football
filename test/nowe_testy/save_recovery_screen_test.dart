import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/app/screens/load_game_screen.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
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
