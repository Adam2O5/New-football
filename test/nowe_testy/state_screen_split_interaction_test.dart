import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/contract_screen.dart';
import 'package:new_football/app/screens/free_agency_screen.dart';
import 'package:new_football/app/screens/prospects_screen.dart';
import 'package:new_football/app/screens/staff_screen.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

LeagueState _marketLeague({NegotiationSubjectKind? counter}) {
  final league = beforeRollover();
  final team = league.playerTeam!;
  final agent = league.freeAgents.single.copyWith(name: 'R12 Agent');
  final scout = team.staff.scout!.copyWith(name: 'R12 Scout');
  return league.copyWith(
    currentWeek: 48,
    currentDay: 1,
    teams: [
      team.copyWith(
        roster: team.roster.take(1).toList(),
        staff: team.staff.withMember(StaffRole.scout, scout),
      ),
    ],
    freeAgents: [agent],
    negotiations: [
      if (counter != null)
        ContractNegotiation(
          id: 'r12-counter',
          subjectId: counter == NegotiationSubjectKind.player
              ? agent.id
              : scout.id,
          subjectKind: counter,
          teamId: team.id,
          phase: NegotiationPhase.freeAgencyPhaseII,
          lastOffer: const NegotiationOffer(salary: 1000000, years: 2),
          counterOffer: const NegotiationOffer(salary: 1500000, years: 3),
          status: NegotiationStatus.counter,
          seasonYear: league.currentSeason.year,
          week: 48,
          expirySeasonYear: league.currentSeason.year,
          expiryWeek: 49,
        ),
    ],
  );
}

Future<ProviderContainer> _session(LeagueState league) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final game = saveForLeague(league);
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      saveRepositoryProvider.overrideWithValue(MemorySaveRepository(game)),
    ],
  );
  addTearDown(container.dispose);
  await container.read(gameControllerProvider.notifier).loadGame(game.meta.id);
  return container;
}

Future<void> _mount(
  WidgetTester tester,
  ProviderContainer container,
  Widget screen,
  String language,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

void main() {
  for (final kind in ['fa', 'staff', 'contract']) {
    for (final language in ['pl', 'en']) {
      testWidgets(
        '$kind keeps selection and form across locale rebuild ($language)',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 2200));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final container = await _session(_marketLeague());
          final screen = switch (kind) {
            'fa' => const FreeAgencyScreen(),
            'staff' => const StaffScreen(),
            _ => const ContractScreen(),
          };
          await _mount(tester, container, screen, language);
          final l10n = AppLocalizations.of(
            tester.element(find.byType(screen.runtimeType)),
          )!;
          if (kind == 'fa') {
            await tester.enterText(
              _field(l10n.freeAgency_search),
              'no such player',
            );
            await tester.pumpAndSettle();
            expect(find.text(l10n.freeAgency_empty), findsOneWidget);
            await tester.enterText(_field(l10n.freeAgency_search), 'R12 Agent');
            await tester.pumpAndSettle();
          }
          await tester.tap(
            find
                .widgetWithText(
                  ListTile,
                  kind == 'staff' ? 'R12 Scout' : 'R12 Agent',
                )
                .first,
          );
          await tester.pumpAndSettle();
          final salaryLabel = kind == 'fa'
              ? l10n.freeAgency_offerSalary
              : l10n.contract_offerSalary;
          final yearsLabel = kind == 'fa'
              ? l10n.freeAgency_offerYears
              : l10n.contract_offerYears;
          await tester.scrollUntilVisible(
            _field(salaryLabel),
            300,
            scrollable: find.byType(Scrollable).first,
          );
          final salary = tester
              .widget<TextField>(_field(salaryLabel))
              .controller!;
          final years = tester
              .widget<TextField>(_field(yearsLabel))
              .controller!;
          await tester.enterText(_field(salaryLabel), '1234567');
          await tester.enterText(_field(yearsLabel), '2');
          await tester.pumpAndSettle();

          await _mount(
            tester,
            container,
            screen,
            language == 'pl' ? 'en' : 'pl',
          );
          final translated = AppLocalizations.of(
            tester.element(find.byType(screen.runtimeType)),
          )!;
          final translatedSalary = kind == 'fa'
              ? translated.freeAgency_offerSalary
              : translated.contract_offerSalary;
          final translatedYears = kind == 'fa'
              ? translated.freeAgency_offerYears
              : translated.contract_offerYears;
          expect(
            tester.widget<TextField>(_field(translatedSalary)).controller,
            same(salary),
          );
          expect(
            tester.widget<TextField>(_field(translatedYears)).controller,
            same(years),
          );
          expect(salary.text, '1234567');
          expect(years.text, '2');
          if (kind == 'fa') {
            await tester.scrollUntilVisible(
              _field(translated.freeAgency_search),
              -300,
              scrollable: find.byType(Scrollable).first,
            );
            expect(
              tester
                  .widget<TextField>(_field(translated.freeAgency_search))
                  .controller!
                  .text,
              'R12 Agent',
            );
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final kind in [
    NegotiationSubjectKind.player,
    NegotiationSubjectKind.staff,
  ]) {
    testWidgets('$kind counter dialog validates, cancels and reopens cleanly', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1600, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = await _session(_marketLeague(counter: kind));
      final screen = kind == NegotiationSubjectKind.player
          ? const ContractScreen()
          : const StaffScreen();
      await _mount(tester, container, screen, 'en');
      final l10n = AppLocalizations.of(
        tester.element(find.byType(screen.runtimeType)),
      )!;
      final edit = find.widgetWithText(
        OutlinedButton,
        l10n.contract_counterEdit,
      );
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      Finder dialogField(String label) => find.descendant(
        of: find.byType(AlertDialog),
        matching: _field(label),
      );
      expect(
        tester
            .widget<TextField>(dialogField(l10n.contract_offerSalary))
            .controller!
            .text,
        '1500000',
      );
      await tester.enterText(dialogField(l10n.contract_offerYears), '0');
      await tester.tap(find.widgetWithText(FilledButton, l10n.common_save));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.contract_invalidOffer),
        ),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.common_cancel));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        container.read(activeLeagueProvider)!.negotiations.single.status,
        NegotiationStatus.counter,
      );
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(dialogField(l10n.contract_offerYears))
            .controller!
            .text,
        '3',
      );
      await tester.tap(find.widgetWithText(FilledButton, l10n.common_save));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }

  for (final combine in [false, true]) {
    testWidgets(
      'prospect table persists selections on exit (Combine: $combine)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1600, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final original = seededLeague();
        final prospects = original
            .currentSeason
            .draftState!
            .draftClass
            .prospects
            .take(3)
            .toList();
        final scout = beforeRollover().playerTeam!.staff.scout!.copyWith(
          attributes: const StaffAttributes(coverage: 5, evaluation: 5),
        );
        final team = original.playerTeam!;
        final watchlist = combine
            ? prospects.take(2).map((p) => p.id).toList()
            : <String>[];
        final league = original.copyWith(
          teams: [
            team.copyWith(
              staff: team.staff.withMember(StaffRole.scout, scout),
              scouting: TeamScouting(watchlistProspectIds: watchlist),
            ),
          ],
          currentSeason: original.currentSeason.copyWith(
            scoutReportDone: true,
            draftState: original.currentSeason.draftState!.copyWith(
              draftClass: DraftClass(
                year: original.currentSeason.year,
                prospects: prospects,
              ),
            ),
          ),
        );
        final container = await _session(league);
        await _mount(
          tester,
          container,
          ProspectsScreen(initialCombine: combine),
          'en',
        );
        expect(find.byType(Checkbox), findsNWidgets(combine ? 2 : 3));
        final selectedRow = find.ancestor(
          of: find.text(prospects.first.name),
          matching: find.byType(InkWell),
        );
        final checkbox = find.descendant(
          of: selectedRow,
          matching: find.byType(Checkbox),
        );
        await tester.tap(checkbox);
        await tester.pumpAndSettle();
        expect(tester.widget<Checkbox>(checkbox).value, isTrue);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.runAsync(
          () => container
              .read(gameControllerProvider.notifier)
              .flushPendingSave(),
        );
        await tester.pumpAndSettle();
        final saved = container
            .read(activeLeagueProvider)!
            .playerTeam!
            .scouting;
        expect(
          saved.watchlistProspectIds,
          combine ? watchlist : [prospects.first.id],
        );
        expect(
          saved.combineAssignedProspectIds,
          combine ? [prospects.first.id] : isEmpty,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
