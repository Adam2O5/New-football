@Tags(['ui'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/branding/club_branding_registry.dart';
import 'package:new_football/app/screens/new_game_screen.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/team_selection_harness.dart';

void main() {
  testWidgets('mounts the reusable team-selection router harness', (
    tester,
  ) async {
    final harness = TeamSelectionHarness(
      locale: const Locale('en'),
      viewport: const Size(390, 844),
      textScale: 1.0,
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    final semanticsHandle = ensureSemantics(tester);
    try {
      expect(harness.router.state.uri.path, '/new-game');
      expect(find.byType(NewGameScreen), findsOneWidget);
      final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
      expect(teamList, findsOneWidget);
      expect(rect(tester, teamList).width, greaterThan(0));
      expect(takeException(tester), isNull);
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets('renders all preview teams in source order with shared logo', (
    tester,
  ) async {
    final harness = TeamSelectionHarness();
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final l10n = await AppLocalizations.delegate.load(harness.locale);

    final expectedTeams = harness.gameFactory.previewTeams();
    expect(expectedTeams, hasLength(30));

    final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
    final renderedRowKeys = <String>{};

    void recordRenderedRows() {
      for (final row in tester.widgetList<TeamRow>(find.byType(TeamRow))) {
        final key = row.key;
        expect(key, isA<ValueKey<String>>());
        renderedRowKeys.add((key! as ValueKey<String>).value);
      }
    }

    for (var index = 0; index < expectedTeams.length; index++) {
      final team = expectedTeams[index];
      final rowKey = ValueKey<String>('new-game-team-row-${team.id}');
      final rowFinder = find.byKey(rowKey);

      await tester.scrollUntilVisible(
        rowFinder,
        400,
        scrollable: teamListScrollable(teamList),
      );
      await Scrollable.ensureVisible(tester.element(rowFinder), alignment: 0.5);
      await tester.pumpAndSettle();
      expect(rowFinder, findsOneWidget);

      final row = tester.widget<TeamRow>(rowFinder);
      final branding = ClubBrandingRegistry.production.resolve(team.id);
      final conferenceLabel = selectionConferenceLabel(l10n, team.conference);
      expect(row.teamId, team.id);
      expect(row.name, team.name);
      expect(row.city, team.city);
      expect(row.conferenceLabel, conferenceLabel);
      expect(row.branding, isNotNull);
      expect(row.branding!.teamId, team.id);
      expect(row.branding!.logoAsset, branding.logoAsset);
      expect(row.branding!.primaryColor, branding.primaryColor);
      expect(row.branding!.secondaryColor, branding.secondaryColor);
      expect(
        find.descendant(of: rowFinder, matching: find.text(team.name)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: rowFinder,
          matching: find.text('${team.city} · $conferenceLabel'),
        ),
        findsOneWidget,
      );

      final imageFinder = find.descendant(
        of: rowFinder,
        matching: find.byType(Image),
      );
      expect(imageFinder, findsOneWidget);
      final image = tester.widget<Image>(imageFinder);
      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName, branding.logoAsset);
      expect(
        find.byKey(ValueKey<String>('team-row-secondary-${team.id}')),
        findsOneWidget,
      );

      expect(find.byKey(rowKey), findsOneWidget);
      recordRenderedRows();

      if (index > 0) {
        final previousTeam = expectedTeams[index - 1];
        final previousRow = find.byKey(
          ValueKey<String>('new-game-team-row-${previousTeam.id}'),
        );
        expect(previousRow, findsOneWidget);
        expect(
          tester.getRect(previousRow).top,
          lessThan(tester.getRect(rowFinder).top),
        );
      }
    }

    final scrollableState = tester.state<ScrollableState>(
      teamListScrollable(teamList),
    );
    scrollableState.position.jumpTo(scrollableState.position.maxScrollExtent);
    await tester.pumpAndSettle();
    recordRenderedRows();

    final expectedRowKeys = expectedTeams
        .map((team) => 'new-game-team-row-${team.id}')
        .toSet();
    expect(renderedRowKeys, hasLength(expectedTeams.length));
    expect(renderedRowKeys, expectedRowKeys);
  });

  testWidgets('replaces the first selection and keeps selection exclusive', (
    tester,
  ) async {
    final harness = TeamSelectionHarness();
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final teams = harness.gameFactory.previewTeams();
    final first = teams.first;
    final another = teams[1];
    final firstRow = teamRowFinder(first.id);
    final anotherRow = teamRowFinder(another.id);

    await activateTeam(tester, first.id);
    expect(tester.widget<TeamRow>(firstRow).selected, isTrue);
    expect(
      tester
          .widgetList<TeamRow>(find.byType(TeamRow))
          .where((row) => row.selected),
      hasLength(1),
    );

    await activateTeam(tester, another.id);
    expect(tester.widget<TeamRow>(firstRow).selected, isFalse);
    expect(tester.widget<TeamRow>(anotherRow).selected, isTrue);
    final selectedRows = tester
        .widgetList<TeamRow>(find.byType(TeamRow))
        .where((row) => row.selected)
        .toList();
    expect(selectedRows, hasLength(1));
    expect(selectedRows.single.teamId, another.id);
  });

  testWidgets(
    'rejects empty, whitespace-only, and unselected starts without saving',
    (tester) async {
      final cases = <({String name, bool selectTeam})>[
        (name: '', selectTeam: true),
        (name: '   \t  ', selectTeam: true),
        (name: 'Valid name', selectTeam: false),
      ];

      for (final testCase in cases) {
        final harness = TeamSelectionHarness();
        try {
          await harness.pump(tester);
          final l10n = await AppLocalizations.delegate.load(harness.locale);
          if (testCase.selectTeam) {
            await activateTeam(
              tester,
              harness.gameFactory.previewTeams().first.id,
            );
          }
          if (testCase.name != 'Valid name') {
            await tester.enterText(
              find.byKey(const ValueKey<String>('new-game-save-name')),
              testCase.name,
            );
          }

          await tester.tap(
            find.byKey(const ValueKey<String>('new-game-start-button')),
          );
          await pumpUntilSnackBar(
            tester,
            expectedText: l10n.newGame_missingFields,
          );

          expect(harness.repository.saveCalls, 0);
          expect(harness.router.state.uri.path, '/new-game');
          expect(find.byType(NewGameScreen), findsOneWidget);
        } finally {
          await harness.dispose(tester);
        }
      }
    },
  );

  testWidgets('creates a save for the selected team and navigates to game', (
    tester,
  ) async {
    final harness = TeamSelectionHarness();
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final selectedTeam = harness.gameFactory.previewTeams()[2];
    await activateTeam(tester, selectedTeam.id);
    await tester.enterText(
      find.byKey(const ValueKey<String>('new-game-save-name')),
      '  Deterministic career  ',
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('new-game-start-button')),
    );
    await tester.pumpAndSettle();

    expect(harness.repository.saveCalls, 1);
    expect(harness.repository.attemptedSaves, hasLength(1));
    expect(harness.repository.lastSaved, isNotNull);
    final savedGame = harness.repository.lastSaved!;
    expect(savedGame.meta.name, 'Deterministic career');
    expect(savedGame.leagueState.playerTeamId, selectedTeam.id);
    expect(harness.router.state.uri.path, '/game');
    expect(harness.destinationUris.map((uri) => uri.path), contains('/game'));
    expect(find.text('game-route'), findsOneWidget);
  });

  testWidgets(
    'disables start and shows the fixed progress indicator while saving',
    (tester) async {
      final repository = TeamSelectionSaveRepository()
        ..saveRelease = Completer<void>();
      final harness = TeamSelectionHarness(repository: repository);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final selectedTeam = harness.gameFactory.previewTeams().first;
      await activateTeam(tester, selectedTeam.id);
      await tester.enterText(
        find.byKey(const ValueKey<String>('new-game-save-name')),
        'Delayed career',
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('new-game-start-button')),
      );
      await repository.firstSaveStarted;
      await tester.pump();

      final startButton = find.byKey(
        const ValueKey<String>('new-game-start-button'),
      );
      expect(tester.widget<FilledButton>(startButton).onPressed, isNull);
      final progress = find.descendant(
        of: startButton,
        matching: find.byType(CircularProgressIndicator),
      );
      expect(progress, findsOneWidget);
      expect(tester.getSize(progress), const Size(22, 22));
      expect(tester.widget<CircularProgressIndicator>(progress).strokeWidth, 2);
      expect(harness.router.state.uri.path, '/new-game');

      repository.saveRelease!.complete();
      await tester.pumpAndSettle();
      expect(harness.router.state.uri.path, '/game');
    },
  );

  testWidgets('reports repository failure and preserves name and selection', (
    tester,
  ) async {
    final repository = TeamSelectionSaveRepository()
      ..saveFailure = SaveRepositoryException('controlled create failure');
    final harness = TeamSelectionHarness(repository: repository);
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final selectedTeam = harness.gameFactory.previewTeams()[3];
    final selectedRow = teamRowFinder(selectedTeam.id);
    const enteredName = '  Preserved career  ';
    await activateTeam(tester, selectedTeam.id);
    await tester.enterText(
      find.byKey(const ValueKey<String>('new-game-save-name')),
      enteredName,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('new-game-start-button')),
    );

    final l10n = await AppLocalizations.delegate.load(harness.locale);
    await pumpUntilSnackBar(tester, expectedText: l10n.newGame_createFailed);

    expect(repository.saveCalls, 1);
    expect(repository.savedGames, isEmpty);
    expect(harness.router.state.uri.path, '/new-game');
    expect(find.text('game-route'), findsNothing);
    final saveNameField = tester.widget<TextField>(
      find.byKey(const ValueKey<String>('new-game-save-name')),
    );
    expect(saveNameField.controller!.text, enteredName);
    expect(tester.widget<TeamRow>(selectedRow).selected, isTrue);
    final selectedRows = tester
        .widgetList<TeamRow>(find.byType(TeamRow))
        .where((row) => row.selected)
        .toList();
    expect(selectedRows, hasLength(1));
    expect(selectedRows.single.teamId, selectedTeam.id);
  });
}
