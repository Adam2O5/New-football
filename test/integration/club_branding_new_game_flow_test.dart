library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/app/screens/new_game_screen.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../ui/team_selection_menu_test.dart' as selection_test;

/// Captures the existing request contract while delegating creation to the
/// production factory. [previewTeams] therefore remains the real 30-team
/// production preview used by [NewGameScreen].
class _RecordingGameFactory extends GameFactory {
  NewGameRequest? lastRequest;

  @override
  GameSave create(NewGameRequest request) {
    lastRequest = request;
    return super.create(request);
  }
}

void main() {
  testWidgets(
    'touch and semantics activation select the same real preview club',
    (tester) async {
      final targetTeam = GameFactory().previewTeams()[1];
      String? touchSelection;
      String? semanticsSelection;

      final touchHarness = selection_test.TeamSelectionHarness();
      try {
        await touchHarness.pump(tester);
        expect(touchHarness.gameFactory.previewTeams(), hasLength(30));
        await _tapTeam(tester, targetTeam.id);
        touchSelection = _selectedTeamId(tester);
      } finally {
        await touchHarness.dispose(tester);
      }

      final semanticsHarness = selection_test.TeamSelectionHarness();
      final semanticsHandle = tester.ensureSemantics();
      try {
        await semanticsHarness.pump(tester);
        await tester.pump();
        final l10n = await AppLocalizations.delegate.load(
          semanticsHarness.locale,
        );
        await _ensureTeamVisible(tester, targetTeam.id);
        final label = l10n.newGame_teamSemantics(
          targetTeam.name,
          targetTeam.city,
          switch (targetTeam.conference) {
            Conference.europe => l10n.teamOverview_conferenceEurope,
            Conference.restOfTheWorld =>
              l10n.teamOverview_conferenceRestOfWorld,
          },
          l10n.newGame_teamNotSelected,
        );
        final semanticsFinder = find.bySemanticsLabel(label);
        expect(semanticsFinder, findsOneWidget);
        final node = tester.getSemantics(semanticsFinder);
        expect(node.flagsCollection.isButton, isTrue);
        expect(
          node.getSemanticsData().hasAction(ui.SemanticsAction.tap),
          isTrue,
        );
        final owner = node.owner;
        expect(owner, isNotNull);
        owner!.performAction(node.id, ui.SemanticsAction.tap);
        await tester.pump();
        semanticsSelection = _selectedTeamId(tester);
      } finally {
        semanticsHandle.dispose();
        await semanticsHarness.dispose(tester);
      }

      expect(touchSelection, targetTeam.id);
      expect(semanticsSelection, targetTeam.id);
      expect(semanticsSelection, touchSelection);
    },
  );

  testWidgets('changing clubs leaves exactly one selected tile', (
    tester,
  ) async {
    final harness = selection_test.TeamSelectionHarness();
    try {
      await harness.pump(tester);
      final teams = harness.gameFactory.previewTeams();
      expect(teams, hasLength(30));

      await _tapTeam(tester, teams.first.id);
      expect(_selectedTeamId(tester), teams.first.id);

      await _tapTeam(tester, teams[1].id);
      final selectedRows = _selectedRows(tester);
      expect(selectedRows, hasLength(1));
      expect(selectedRows.single.teamId, teams[1].id);
      expect(
        tester.widget<TeamRow>(_rowFinder(teams.first.id)).selected,
        isFalse,
      );
      expect(tester.widget<TeamRow>(_rowFinder(teams[1].id)).selected, isTrue);
    } finally {
      await harness.dispose(tester);
    }
  });

  testWidgets(
    'saves the selected Team_ID through the existing request and goes to game',
    (tester) async {
      final factory = _RecordingGameFactory();
      final harness = selection_test.TeamSelectionHarness(gameFactory: factory);
      try {
        await harness.pump(tester);
        final teams = factory.previewTeams();
        expect(teams, hasLength(30));
        final selectedTeam = teams[2];
        await _tapTeam(tester, selectedTeam.id);
        await tester.enterText(
          find.byKey(const ValueKey<String>('new-game-save-name')),
          '  Integration career  ',
        );

        await tester.tap(
          find.byKey(const ValueKey<String>('new-game-start-button')),
        );
        await tester.pumpAndSettle();

        final request = factory.lastRequest;
        expect(request, isNotNull);
        // This observes the unchanged NewGameRequest contract rather than
        // introducing branding data into the domain request.
        expect(request!.saveName, 'Integration career');
        expect(request.playerTeamId, selectedTeam.id);
        expect(harness.repository.saveCalls, 1);
        expect(harness.repository.savedGames, hasLength(1));
        expect(
          harness.repository.lastSaved!.leagueState.playerTeamId,
          selectedTeam.id,
        );
        expect(harness.router.state.uri.path, '/game');
        expect(
          harness.destinationUris.map((uri) => uri.path),
          contains('/game'),
        );
        expect(find.text('game-route'), findsOneWidget);
      } finally {
        await harness.dispose(tester);
      }
    },
  );

  testWidgets(
    'shows the localized missing-fields message and never saves invalid starts',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        for (final name in const ['', '   \t  ']) {
          final harness = selection_test.TeamSelectionHarness(locale: locale);
          try {
            await harness.pump(tester);
            final l10n = await AppLocalizations.delegate.load(locale);
            final selectedTeam = harness.gameFactory.previewTeams().first;
            await _tapTeam(tester, selectedTeam.id);
            await tester.enterText(
              find.byKey(const ValueKey<String>('new-game-save-name')),
              name,
            );
            await tester.tap(
              find.byKey(const ValueKey<String>('new-game-start-button')),
            );
            await _pumpUntilSnackBar(
              tester,
              expectedText: l10n.newGame_missingFields,
            );

            expect(harness.repository.saveCalls, 0);
            expect(harness.repository.savedGames, isEmpty);
            expect(harness.router.state.uri.path, '/new-game');
            expect(find.byType(NewGameScreen), findsOneWidget);
            expect(_selectedTeamId(tester), selectedTeam.id);
          } finally {
            await harness.dispose(tester);
          }
        }

        final noSelectionHarness = selection_test.TeamSelectionHarness(
          locale: locale,
        );
        try {
          await noSelectionHarness.pump(tester);
          final l10n = await AppLocalizations.delegate.load(locale);
          await tester.enterText(
            find.byKey(const ValueKey<String>('new-game-save-name')),
            'Valid career',
          );
          await tester.tap(
            find.byKey(const ValueKey<String>('new-game-start-button')),
          );
          await _pumpUntilSnackBar(
            tester,
            expectedText: l10n.newGame_missingFields,
          );

          expect(noSelectionHarness.repository.saveCalls, 0);
          expect(noSelectionHarness.repository.savedGames, isEmpty);
          expect(noSelectionHarness.router.state.uri.path, '/new-game');
          expect(
            tester
                .widgetList<TeamRow>(find.byType(TeamRow))
                .where((row) => row.selected),
            isEmpty,
          );
        } finally {
          await noSelectionHarness.dispose(tester);
        }
      }
    },
  );

  testWidgets(
    'shows localized creation failure and preserves name and Selected_Club',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final repository = selection_test.TeamSelectionSaveRepository()
          ..saveFailure = SaveRepositoryException('controlled failure');
        final factory = _RecordingGameFactory();
        final harness = selection_test.TeamSelectionHarness(
          locale: locale,
          gameFactory: factory,
          repository: repository,
        );
        const enteredName = '  Preserved integration career  ';
        try {
          await harness.pump(tester);
          final l10n = await AppLocalizations.delegate.load(locale);
          final selectedTeam = factory.previewTeams()[3];
          await _tapTeam(tester, selectedTeam.id);
          await tester.enterText(
            find.byKey(const ValueKey<String>('new-game-save-name')),
            enteredName,
          );
          await tester.tap(
            find.byKey(const ValueKey<String>('new-game-start-button')),
          );
          await _pumpUntilSnackBar(
            tester,
            expectedText: l10n.newGame_createFailed,
          );

          expect(repository.saveCalls, 1);
          expect(repository.savedGames, isEmpty);
          expect(harness.router.state.uri.path, '/new-game');
          expect(find.text('game-route'), findsNothing);
          expect(factory.lastRequest!.playerTeamId, selectedTeam.id);
          expect(factory.lastRequest!.saveName, 'Preserved integration career');
          final field = tester.widget<TextField>(
            find.byKey(const ValueKey<String>('new-game-save-name')),
          );
          expect(field.controller!.text, enteredName);
          expect(_selectedTeamId(tester), selectedTeam.id);
        } finally {
          await harness.dispose(tester);
        }
      }
    },
  );

  testWidgets('keeps Selected_Club through locale and resize before starting', (
    tester,
  ) async {
    final factory = _RecordingGameFactory();
    final harness = selection_test.TeamSelectionHarness(
      locale: const Locale('pl'),
      viewport: const Size(390, 844),
      gameFactory: factory,
    );
    try {
      await harness.pump(tester);
      final selectedTeam = factory.previewTeams()[4];
      await _tapTeam(tester, selectedTeam.id);
      await tester.enterText(
        find.byKey(const ValueKey<String>('new-game-save-name')),
        'Locale and resize career',
      );

      await harness.rebuildWithLocale(tester, const Locale('en'));
      await _ensureTeamVisible(tester, selectedTeam.id);
      expect(_selectedTeamId(tester), selectedTeam.id);
      expect(harness.router.state.uri.path, '/new-game');

      tester.view.physicalSize = const Size(844, 390);
      await tester.pumpAndSettle();
      await _ensureTeamVisible(tester, selectedTeam.id);
      expect(_selectedTeamId(tester), selectedTeam.id);
      expect(harness.router.state.uri.path, '/new-game');

      await tester.tap(
        find.byKey(const ValueKey<String>('new-game-start-button')),
      );
      await tester.pumpAndSettle();
      expect(factory.lastRequest!.playerTeamId, selectedTeam.id);
      expect(harness.repository.saveCalls, 1);
      expect(harness.router.state.uri.path, '/game');
    } finally {
      await harness.dispose(tester);
    }
  });
}

Finder _rowFinder(String teamId) =>
    find.byKey(ValueKey<String>('new-game-team-row-$teamId'));

Future<void> _ensureTeamVisible(WidgetTester tester, String teamId) async {
  final row = _rowFinder(teamId);
  if (row.evaluate().isEmpty) {
    final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
    await tester.scrollUntilVisible(
      row,
      300,
      scrollable: find.descendant(
        of: teamList,
        matching: find.byType(Scrollable),
      ),
    );
  }
  await tester.pumpAndSettle();
  expect(row, findsOneWidget);
}

Future<void> _tapTeam(WidgetTester tester, String teamId) async {
  await _ensureTeamVisible(tester, teamId);
  await tester.tap(_rowFinder(teamId));
  await tester.pump();
}

List<TeamRow> _selectedRows(WidgetTester tester) => tester
    .widgetList<TeamRow>(find.byType(TeamRow))
    .where((row) => row.selected)
    .toList();

String _selectedTeamId(WidgetTester tester) {
  final selectedRows = _selectedRows(tester);
  expect(selectedRows, hasLength(1));
  return selectedRows.single.teamId;
}

Future<void> _pumpUntilSnackBar(
  WidgetTester tester, {
  required String expectedText,
  int maxPumps = 40,
}) async {
  for (var index = 0; index < maxPumps; index++) {
    await tester.pump(const Duration(milliseconds: 20));
    if (find.text(expectedText).evaluate().isNotEmpty) return;
  }
  expect(find.text(expectedText), findsOneWidget);
}
