import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/matchday_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final game = saveForLeague(seededLeague());
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        saveRepositoryProvider.overrideWithValue(MemorySaveRepository(game)),
      ],
    );
    await container
        .read(gameControllerProvider.notifier)
        .loadGame(game.meta.id);
  });
  tearDown(() => container.dispose());

  Future<AppLocalizations> showMatch(
    WidgetTester tester,
    String language,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final teams = container.read(activeLeagueProvider)!.teams;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MatchdayScreen(
            match: ScheduledMatch(
              id: 'split-match',
              round: 1,
              homeTeamId: teams[0].id,
              awayTeamId: teams[1].id,
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('matchday-clock'))).data,
      "0'",
    );
    return AppLocalizations.of(tester.element(find.byType(MatchdayScreen)))!;
  }

  for (final language in ['pl', 'en']) {
    testWidgets(
      'auto-pause settings retain state while match stays paused ($language)',
      (tester) async {
        final l10n = await showMatch(tester, language);
        final screen = tester.element(find.byType(MatchdayScreen));
        await tester.tap(find.byTooltip(l10n.matchday_autoPause));
        await tester.pumpAndSettle();
        expect(find.byType(SwitchListTile), findsNWidgets(4));
        expect(
          tester
              .widget<SwitchListTile>(find.byType(SwitchListTile).first)
              .value,
          isTrue,
        );
        await tester.tap(
          find.widgetWithText(SwitchListTile, l10n.matchday_autoPauseInjury),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, l10n.common_save));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip(l10n.matchday_autoPause));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SwitchListTile>(find.byType(SwitchListTile).first)
              .value,
          isFalse,
        );
        expect(
          tester
              .widget<SwitchListTile>(find.byType(SwitchListTile).at(1))
              .value,
          isTrue,
        );
        Navigator.of(tester.element(find.byType(SwitchListTile).first)).pop();
        await tester.pumpAndSettle();
        expect(tester.element(find.byType(MatchdayScreen)), same(screen));
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('matchday-clock')))
              .data,
          "0'",
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'action sheets preserve selection lifecycle and tactic submission',
    (tester) async {
      final l10n = await showMatch(tester, 'en');
      await tester.tap(
        find.widgetWithText(OutlinedButton, l10n.matchday_substitutions),
      );
      await tester.pumpAndSettle();
      final dropdowns = find.byType(DropdownButtonFormField<String>);
      expect(dropdowns, findsNWidgets(2));
      final outgoing = tester.widget<DropdownButton<String>>(
        find.descendant(
          of: dropdowns.first,
          matching: find.byType(DropdownButton<String>),
        ),
      );
      final incoming = tester.widget<DropdownButton<String>>(
        find.descendant(
          of: dropdowns.last,
          matching: find.byType(DropdownButton<String>),
        ),
      );
      outgoing.onChanged!(outgoing.items!.first.value);
      incoming.onChanged!(incoming.items!.first.value);
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(
                FilledButton,
                l10n.matchday_confirmSubstitution,
              ),
            )
            .onPressed,
        isNotNull,
      );
      Navigator.of(tester.element(dropdowns.first)).pop();
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(OutlinedButton, l10n.matchday_substitutions),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(
                FilledButton,
                l10n.matchday_confirmSubstitution,
              ),
            )
            .onPressed,
        isNull,
      );
      Navigator.of(tester.element(dropdowns.first)).pop();
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(OutlinedButton, l10n.matchday_tactics),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButtonFormField<Formation>>(
              find.byType(DropdownButtonFormField<Formation>),
            )
            .onChanged,
        isNull,
      );
      final tempoFinder = find.byType(DropdownButtonFormField<Tempo>);
      final tempo = tester.widget<DropdownButtonFormField<Tempo>>(tempoFinder);
      final changed = Tempo.values.firstWhere(
        (value) => value != tempo.initialValue,
      );
      tempo.onChanged!(changed);
      await tester.pump();
      await tester.tap(
        find.widgetWithText(FilledButton, l10n.matchday_tacticsSuccess),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(OutlinedButton, l10n.matchday_tactics),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<DropdownButtonFormField<Tempo>>(tempoFinder).initialValue,
        changed,
      );
      Navigator.of(tester.element(tempoFinder)).pop();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('matchday-clock'))).data,
        "0'",
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
