@Tags(['ui'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/fixtures/game_fixtures.dart';
import '../helpers/persistence/memory_save_repository.dart';
import '../helpers/widgets/widget_harness.dart';

void main() {
  for (final locale in ['pl', 'en']) {
    for (final ambiguous in [false, true]) {
      testWidgets(
        'Inbox waits for durability and offers a save-only retry after I/O failure ($locale, ambiguous=$ambiguous)',
        (tester) async {
          final l10n = await AppLocalizations.delegate.load(Locale(locale));
          const message = GameMessage(
            id: 'inbox-save-boundary',
            type: MessageType.system,
            priority: MessagePriority.urgent,
            seasonYear: 2026,
            week: 1,
            titleKey: 'boundary_unknown_title',
            bodyKey: 'boundary_unknown_body',
            args: {
              '_legacyTitle': 'Boundary confirmation',
              '_legacyBody': 'Controlled persistence boundary.',
            },
            read: true,
          );
          final base = controllerSave();
          final game = base.copyWith(
            leagueState: base.leagueState.copyWith(
              inbox: const Inbox(messages: [message]),
            ),
          );
          final repository = MemorySaveRepository(game);
          final started = Completer<void>();
          final gate = Completer<void>();
          final failure = ambiguous
              ? SaveAmbiguousWriteException(saveId: game.meta.id)
              : StateError('controlled save failure');
          repository.writeStarted = started;
          repository.writeGate = gate;
          repository.writeError = failure;
          late GameController controller;

          try {
            await tester.pumpWidget(
              task41App(
                const Scaffold(body: InboxScreen()),
                game,
                locale: Locale(locale),
                saveRepository: repository,
                onController: (value) => controller = value,
              ),
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text('Boundary confirmation').first);
            await tester.pumpAndSettle();
            expect(find.byType(BottomSheet), findsOneWidget);

            await tester.tap(
              find.widgetWithText(FilledButton, l10n.inbox_acknowledge),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));

            expect(started.isCompleted, isTrue);
            expect(gate.isCompleted, isFalse);
            expect(find.byType(BottomSheet), findsOneWidget);
            expect(
              controller.save!.leagueState.inbox.messages.single.acknowledged,
              isTrue,
            );
            expect(
              repository.game.leagueState.inbox.messages.single.acknowledged,
              isFalse,
            );

            gate.complete();
            await expectLater(
              controller.flushPendingSave(),
              throwsA(same(failure)),
            );
            await tester.pumpAndSettle();
            expect(find.byType(BottomSheet), findsOneWidget);
            expect(find.text(l10n.inbox_retrySave), findsOneWidget);
            expect(
              find.text(
                ambiguous
                    ? l10n.inbox_saveUncertain
                    : l10n.inbox_confirmationSaveError,
              ),
              findsOneWidget,
            );
            expect(repository.writes, isEmpty);
            expect(
              repository.game.leagueState.inbox.messages.single.acknowledged,
              isFalse,
            );
            repository.writeError = null;
            await tester.tap(find.text(l10n.inbox_retrySave));
            await tester.pumpAndSettle();
            expect(find.byType(BottomSheet), findsNothing);
            expect(repository.writes, hasLength(1));
            expect(
              repository.game.leagueState.inbox.messages.single.acknowledged,
              isTrue,
            );
            expect(tester.takeException(), isNull);
          } finally {
            repository.releasePendingWrites();
            await controller.enqueueSaveManagement(() async {});
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpAndSettle();
          }
        },
      );
    }
  }

  for (final unmount in [false, true]) {
    testWidgets(
      'pending save survives ${unmount ? 'unmount' : 'a route above the sheet'}',
      (tester) async {
        final base = controllerSave();
        final game = base.copyWith(
          leagueState: base.leagueState.copyWith(
            inbox: const Inbox(
              messages: [
                GameMessage(
                  id: 'lifecycle-confirmation',
                  type: MessageType.system,
                  priority: MessagePriority.urgent,
                  seasonYear: 2026,
                  week: 1,
                  titleKey: 'unknown_title',
                  bodyKey: 'unknown_body',
                  read: true,
                  args: {
                    '_legacyTitle': 'Lifecycle confirmation',
                    '_legacyBody': 'Pending save.',
                  },
                ),
              ],
            ),
          ),
        );
        final repository = MemorySaveRepository(game);
        final gate = Completer<void>();
        repository.writeGate = gate;
        repository.writeStarted = Completer<void>();
        late GameController controller;
        try {
          await tester.pumpWidget(
            task41App(
              const Scaffold(body: InboxScreen()),
              game,
              saveRepository: repository,
              onController: (value) => controller = value,
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Lifecycle confirmation').first);
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(FilledButton, 'Potwierdź'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(repository.writeStarted, isNull);
          if (unmount) {
            await tester.pumpWidget(
              const MaterialApp(home: Text('Replacement')),
            );
          } else {
            Navigator.of(tester.element(find.byType(InboxScreen))).push<void>(
              MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Replacement')),
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 400));
          }
          gate.complete();
          await tester.pumpAndSettle();
          expect(find.text('Replacement'), findsOneWidget);
          expect(find.byType(BottomSheet), findsNothing);
          expect(
            repository.game.leagueState.inbox.messages.single.acknowledged,
            isTrue,
          );
          expect(repository.writes, hasLength(1));
          expect(tester.takeException(), isNull);
        } finally {
          repository.releasePendingWrites();
          await controller.enqueueSaveManagement(() async {});
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        }
      },
    );
  }
}
