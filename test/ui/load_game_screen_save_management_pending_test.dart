@Tags(['ui'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/load_game_screen_harness.dart';

void main() {
  testWidgets(
    'gates duplicate while pending, reports ambiguous failure, and permits retry',
    (tester) async {
      final source = saveRecordFixture(
        'duplicate-gated',
        name: 'Gated checkpoint',
      );
      final service =
          MutableManagementService(
              repository: WidgetSaveRepository(),
              initial: [source],
            )
            ..duplicateStarted = Completer<void>()
            ..duplicateRelease = Completer<void>();
      final container = await pumpScreen(
        tester,
        locale: const Locale('en'),
        service: service,
      );
      await tester.pumpAndSettle();

      final duplicateKey = 'save-duplicate-${source.meta.id}';
      await tester.tap(find.byKey(ValueKey<String>(duplicateKey)));
      await service.duplicateStarted!.future;
      await tester.pump();
      expect(isActionEnabled(tester, duplicateKey), isFalse);

      service.duplicateRelease!.complete();
      await tester.pumpAndSettle();
      expect(isActionEnabled(tester, duplicateKey), isTrue);
      expect(service.records, hasLength(2));
      await removeCurrentSnackBar(tester);

      service.duplicateFailure = const SaveManagementException(
        SaveManagementFailure.ambiguousWrite,
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.byKey(ValueKey<String>(duplicateKey)));
      await pumpUntilSnackBar(
        tester,
        expectedText: l10n.loadGame_ambiguousWrite,
      );
      expect(find.text(l10n.loadGame_ambiguousWrite), findsOneWidget);
      expect(
        find.byKey(ValueKey<String>('save-row-${source.meta.id}')),
        findsOneWidget,
      );
      expect(isActionEnabled(tester, duplicateKey), isTrue);
      expect(find.textContaining('created'), findsNothing);
      await removeCurrentSnackBar(tester);

      service.duplicateFailure = null;
      await tester.tap(find.byKey(ValueKey<String>(duplicateKey)));
      await pumpFrames(tester);
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
      expect(
        find.byKey(const ValueKey<String>('save-row-copy-3')),
        findsOneWidget,
      );
      container.dispose();
      await resetWidget(tester);
    },
  );
}
