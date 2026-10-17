import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/core/balance/message_catalog.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/message_text_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

const _complete = GameMessage(
  id: 'complete',
  type: MessageType.contractSigned,
  seasonYear: 2026,
  week: 1,
  titleKey: 'msg_contractSigned_title',
  bodyKey: 'unused',
  args: {
    'subjectName': 'John',
    'teamName': 'Club',
    'years': 2,
    'salary': 100,
    '_legacyTitle': 'Stary tytuł',
    '_legacyBody': 'Stara treść',
  },
);
const _unknown = GameMessage(
  id: 'unknown',
  type: MessageType.system,
  seasonYear: 2026,
  week: 1,
  titleKey: 'unknown_title',
  bodyKey: 'unknown_body',
  args: {'_legacyTitle': 'Zachowany tytuł', '_legacyBody': 'Zachowana treść'},
);
const _incomplete = GameMessage(
  id: 'incomplete',
  type: MessageType.contractSigned,
  seasonYear: 2026,
  week: 1,
  titleKey: 'msg_contractSigned_title',
  bodyKey: 'unused',
  args: {
    '_legacyTitle': 'Niepełny stary zapis',
    '_legacyBody': 'Niepełna stara treść',
  },
);

void main() {
  test(
    'optional catalog resolution requires complete arguments; strict validation stays',
    () {
      expect(
        MessageTextService.tryResolve(_complete, languageCode: 'en'),
        MessageTextService.resolve(_complete, languageCode: 'en'),
      );
      expect(MessageTextService.tryResolve(_unknown), isNull);
      expect(MessageTextService.tryResolve(_incomplete), isNull);
      expect(() => MessageTextService.resolve(_incomplete), throwsStateError);
      expect(
        MessageTextService.tryResolve(_complete, languageCode: 'xx'),
        MessageTextService.resolve(_complete, languageCode: 'en'),
      );
    },
  );

  testWidgets(
    'inbox and open details follow PL/EN while legacy fallbacks survive',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final game = controllerSave();
      final repository = MemorySaveRepository(
        game.copyWith(
          leagueState: game.leagueState.copyWith(
            inbox: const Inbox(messages: [_complete, _unknown, _incomplete]),
          ),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          saveRepositoryProvider.overrideWithValue(repository),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);
      await controller.loadGame(game.meta.id);
      final locale = ValueNotifier(const Locale('pl'));
      addTearDown(locale.dispose);
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ValueListenableBuilder<Locale>(
            valueListenable: locale,
            builder: (_, current, _) => MaterialApp(
              locale: current,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: InboxScreen()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final pl = MessageTextService.resolve(_complete, languageCode: 'pl');
      final en = MessageTextService.resolve(_complete, languageCode: 'en');
      expect(find.text(pl.title), findsOneWidget);
      expect(find.text('Stary tytuł'), findsNothing);
      expect(find.text('Zachowany tytuł'), findsOneWidget);
      expect(find.text('Niepełny stary zapis'), findsOneWidget);
      await tester.tap(find.text(pl.title));
      await tester.pumpAndSettle();
      expect(find.text(pl.body), findsOneWidget);
      locale.value = const Locale('en');
      await tester.pumpAndSettle();
      expect(find.text(en.title), findsWidgets);
      expect(find.text(en.body), findsOneWidget);
      expect(find.text(pl.body), findsNothing);
      Navigator.of(tester.element(find.text(en.body))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zachowany tytuł'));
      await tester.pumpAndSettle();
      expect(find.text('Zachowana treść'), findsOneWidget);
      Navigator.of(tester.element(find.text('Zachowana treść'))).pop();
      await tester.pumpAndSettle();
      expect(
        controller.save!.leagueState.inbox.messages.first.args['_legacyTitle'],
        'Stary tytuł',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test('current season messages supply localized event context', () {
    final full = seededLeague();
    final league = full.copyWith(
      teams: [full.teams.first],
      playerTeamId: full.teams.first.id,
    );
    final service = SeasonService();
    for (final result in [
      service.runFreeAgencyOpen(league),
      service.runScoutReport(league, saveSeed: fixtureSeed),
      service.runCombine(league, saveSeed: fixtureSeed),
      service.runFinalMock(league, saveSeed: fixtureSeed),
    ]) {
      final message = result.inbox.messages.last;
      for (final language in ['pl', 'en']) {
        final text = MessageTextService.tryResolve(
          message,
          languageCode: language,
        );
        expect(text, isNotNull, reason: '${message.titleKey}/$language');
        expect(text!.body, isNot(contains('{')));
      }
      expect(
        MessageCatalog.resolve(message.type, kind: message.kind).titleKey,
        message.titleKey,
      );
    }
    final template = MessageCatalog.resolve(
      MessageType.draftPick,
      kind: 'selected',
    );
    final drafted = _complete.copyWith(
      type: MessageType.draftPick,
      kind: 'selected',
      titleKey: template.titleKey,
      args: {
        'playerName': 'John',
        'teamName': 'Club',
        'pickNumber': 1,
        'position': 'ST',
      },
    );
    for (final language in ['pl', 'en']) {
      final text = MessageTextService.resolve(drafted, languageCode: language);
      expect(text.title, contains('John'));
      expect(text.body, contains('ST'));
    }
  });
}
