@Tags(['ui'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/load_game_screen_harness.dart';

void main() {
  testWidgets(
    'supports rename autofocus, trim, validation, gating, active-state sync and refresh without an extra row in both locales',
    (tester) async {
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1;

      for (final locale in const [Locale('pl'), Locale('en')]) {
        final source = saveRecordFixture(
          'rename-source-${locale.languageCode}',
          name: 'Alpha',
          sizeBytes: 400,
        );
        final other = saveRecordFixture(
          'rename-other-${locale.languageCode}',
          name: 'Beta',
          updatedAt: DateTime(2025, 1, 1),
          sizeBytes: 500,
        );
        final repository = WidgetSaveRepository();
        final service = MutableManagementService(
          repository: repository,
          initial: [source, other],
        );
        final activeGame = gameFor(source);
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
        await pumpUntilSnackBar(
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
        await resetWidget(tester);
      }
    },
  );
}
