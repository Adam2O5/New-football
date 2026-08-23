library;

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/new_game_screen.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/app/widgets/team_selection/team_selection_assets.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

/// A repository double for the team-selection flow.
///
/// The double records both attempted and completed saves. Tests can assign
/// [saveRelease] before activation to keep the controller in its loading state
/// and can assign [saveFailure] to exercise the existing error path.
class _TeamSelectionSaveRepository extends SaveRepository {
  _TeamSelectionSaveRepository();

  final _firstSaveStarted = Completer<GameSave>();
  final attemptedSaves = <GameSave>[];
  final savedGames = <GameSave>[];

  Completer<void>? saveRelease;
  Object? saveFailure;
  int saveCalls = 0;

  Future<GameSave> get firstSaveStarted => _firstSaveStarted.future;

  GameSave? get lastSaved => savedGames.isEmpty ? null : savedGames.last;

  @override
  Future<void> save(GameSave gameSave) async {
    saveCalls++;
    attemptedSaves.add(gameSave);
    if (!_firstSaveStarted.isCompleted) {
      _firstSaveStarted.complete(gameSave);
    }

    final release = saveRelease;
    if (release != null) await release.future;

    final failure = saveFailure;
    if (failure != null) throw failure;

    savedGames.add(gameSave);
  }
}

/// Reusable widget/router fixture for all team-selection UI scenarios.
///
/// It intentionally uses the real [GameFactory] so preview data remains the
/// production deterministic 30-team data set. Only the factory, repository,
/// and controller providers are overridden; production routing and domain
/// objects are not changed.
class _TeamSelectionHarness {
  _TeamSelectionHarness({
    this.locale = const Locale('pl'),
    this.viewport = const Size(390, 844),
    this.textScale = 1.0,
    GameFactory? gameFactory,
    _TeamSelectionSaveRepository? repository,
  }) : gameFactory = gameFactory ?? GameFactory(),
       repository = repository ?? _TeamSelectionSaveRepository();

  Locale locale;
  final Size viewport;
  final double textScale;
  final GameFactory gameFactory;
  final _TeamSelectionSaveRepository repository;
  final destinationUris = <Uri>[];

  late final GoRouter router = _createRouter();
  late GameController controller;

  Future<void> pump(WidgetTester tester) async {
    _configureTestView(tester, viewport: viewport);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
  }

  Future<void> rebuildWithLocale(WidgetTester tester, Locale nextLocale) async {
    locale = nextLocale;
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await _resetWidget(tester);
    router.dispose();
    _resetTestView(tester);
  }

  Widget _app() {
    final overrides = <Override>[
      gameFactoryProvider.overrideWithValue(gameFactory),
      saveRepositoryProvider.overrideWithValue(repository),
      gameControllerProvider.overrideWith((ref) {
        final value = GameController(ref);
        controller = value;
        return value;
      }),
    ];

    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/new-game',
      routes: [
        GoRoute(
          path: '/new-game',
          builder: (context, state) => const NewGameScreen(),
        ),
        GoRoute(
          path: '/game',
          builder: (context, state) {
            destinationUris.add(state.uri);
            return const Scaffold(body: Text('game-route'));
          },
        ),
      ],
    );
  }
}

void main() {
  testWidgets('mounts the reusable team-selection router harness', (
    tester,
  ) async {
    final harness = _TeamSelectionHarness(
      locale: const Locale('en'),
      viewport: const Size(390, 844),
      textScale: 1.0,
    );
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

    final semanticsHandle = _ensureSemantics(tester);
    try {
      expect(harness.router.state.uri.path, '/new-game');
      expect(find.byType(NewGameScreen), findsOneWidget);
      final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
      expect(teamList, findsOneWidget);
      expect(_rect(tester, teamList).width, greaterThan(0));
      expect(_takeException(tester), isNull);
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets('renders all preview teams in source order with shared logo', (
    tester,
  ) async {
    final harness = _TeamSelectionHarness();
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);

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
        scrollable: _teamListScrollable(teamList),
      );
      await Scrollable.ensureVisible(tester.element(rowFinder), alignment: 0.5);
      await tester.pumpAndSettle();
      expect(rowFinder, findsOneWidget);

      final row = tester.widget<TeamRow>(rowFinder);
      expect(row.teamId, team.id);
      expect(row.name, team.name);
      expect(row.city, team.city);
      expect(row.conferenceLabel, team.conference.label);
      expect(
        find.descendant(of: rowFinder, matching: find.text(team.name)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: rowFinder,
          matching: find.text('${team.city} · ${team.conference.label}'),
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
      expect(
        (image.image as AssetImage).assetName,
        TeamSelectionAssets.placeholderAsset,
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
      _teamListScrollable(teamList),
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

  testWidgets(
    'keeps one bounded team scroll region and a stable fixed action',
    (tester) async {
      final harness = _TeamSelectionHarness(
        viewport: const Size(320, 568),
        textScale: 1.0,
      );
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);

      final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
      final fixedAction = find.byKey(
        const ValueKey<String>('new-game-fixed-action'),
      );
      final startButton = find.byKey(
        const ValueKey<String>('new-game-start-button'),
      );
      final verticalScrollables = find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      );
      final listScrollable = _teamListScrollable(teamList);
      final expectedTeams = harness.gameFactory.previewTeams();
      final expectedRowKeys = expectedTeams
          .map((team) => 'new-game-team-row-${team.id}')
          .toSet();
      final listWidget = tester.widget<ListView>(teamList);
      final visibleListRows = find.descendant(
        of: teamList,
        matching: find.byType(TeamRow),
      );

      void expectVisibleListRowsOnly() {
        final rows = tester.widgetList<TeamRow>(visibleListRows).toList();
        expect(rows, isNotEmpty);
        for (final row in rows) {
          final key = row.key;
          expect(key, isA<ValueKey<String>>());
          expect(expectedRowKeys, contains((key! as ValueKey<String>).value));
        }
        expect(
          find.byType(TeamRow),
          findsNWidgets(rows.length),
          reason: 'all mounted TeamRow widgets must belong to the team list',
        );
      }

      expect(listWidget.childrenDelegate, isA<SliverChildBuilderDelegate>());
      expect(
        (listWidget.childrenDelegate as SliverChildBuilderDelegate).childCount,
        expectedTeams.length,
      );
      expect(verticalScrollables, findsOneWidget);
      expect(listScrollable, findsOneWidget);
      expect(
        find.descendant(of: teamList, matching: find.byType(Scrollable)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: teamList, matching: fixedAction),
        findsNothing,
      );
      expect(
        find.descendant(of: teamList, matching: startButton),
        findsNothing,
      );
      expect(
        find.descendant(of: fixedAction, matching: startButton),
        findsOneWidget,
      );

      final scrollableState = tester.state<ScrollableState>(
        verticalScrollables,
      );
      final scrollPosition = scrollableState.position;
      expect(
        scrollableState.position,
        same(scrollPosition),
        reason: 'the single Scrollable must retain one scroll position',
      );
      expect(scrollPosition.maxScrollExtent, greaterThan(0));

      final teamListRect = _rect(tester, teamList);
      final fixedActionRect = _rect(tester, fixedAction);
      final startButtonRect = _rect(tester, startButton);
      final viewportRect = _testViewportRect(tester);

      expect(teamListRect.height, greaterThan(0));
      expect(fixedActionRect.height, greaterThan(0));
      expect(
        teamListRect.bottom,
        lessThanOrEqualTo(fixedActionRect.top - 8.0 + _geometryTolerance),
      );
      expect(teamListRect.overlaps(fixedActionRect), isFalse);
      _expectRectInside(viewportRect, teamListRect);
      _expectRectInside(viewportRect, fixedActionRect);
      _expectRectInside(fixedActionRect, startButtonRect);
      _expectRectInside(viewportRect, startButtonRect);

      expectVisibleListRowsOnly();
      scrollPosition.jumpTo(0);
      await tester.pumpAndSettle();
      expect(scrollPosition.pixels, closeTo(0, _geometryTolerance));

      final firstTeam = expectedTeams.first;
      final firstRow = find.byKey(
        ValueKey<String>('new-game-team-row-${firstTeam.id}'),
      );
      expect(firstRow, findsOneWidget);
      _expectRectInside(teamListRect, _rect(tester, firstRow));
      expectVisibleListRowsOnly();
      _expectRectStable(
        fixedActionRect,
        _rect(tester, fixedAction),
        reason: 'fixed action moved at the beginning of the team list',
      );
      _expectRectStable(
        startButtonRect,
        _rect(tester, startButton),
        reason: 'start button moved at the beginning of the team list',
      );
      _expectRectInside(viewportRect, _rect(tester, startButton));

      scrollPosition.jumpTo(scrollPosition.maxScrollExtent);
      await tester.pumpAndSettle();
      scrollPosition.jumpTo(scrollPosition.maxScrollExtent);
      await tester.pumpAndSettle();

      expect(
        scrollPosition.pixels,
        closeTo(scrollPosition.maxScrollExtent, _geometryTolerance),
      );
      final lastTeam = expectedTeams.last;
      final lastRow = find.byKey(
        ValueKey<String>('new-game-team-row-${lastTeam.id}'),
      );
      expect(lastRow, findsOneWidget);
      final lastRowRect = _rect(tester, lastRow);
      expect(
        lastRowRect.top,
        greaterThanOrEqualTo(teamListRect.top - _geometryTolerance),
      );
      expect(
        lastRowRect.bottom,
        lessThanOrEqualTo(teamListRect.bottom + _geometryTolerance),
      );
      expectVisibleListRowsOnly();
      _expectRectStable(
        fixedActionRect,
        _rect(tester, fixedAction),
        reason: 'fixed action moved to the end of the team list',
      );
      _expectRectStable(
        startButtonRect,
        _rect(tester, startButton),
        reason: 'start button moved to the end of the team list',
      );
      _expectRectInside(viewportRect, _rect(tester, startButton));
      expect(
        find.descendant(of: teamList, matching: fixedAction),
        findsNothing,
      );
      expect(
        find.descendant(of: teamList, matching: startButton),
        findsNothing,
      );
    },
  );

  testWidgets('replaces the first selection and keeps selection exclusive', (
    tester,
  ) async {
    final harness = _TeamSelectionHarness();
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final teams = harness.gameFactory.previewTeams();
    final first = teams.first;
    final another = teams[1];
    final firstRow = _teamRowFinder(first.id);
    final anotherRow = _teamRowFinder(another.id);

    await _activateTeam(tester, first.id);
    expect(tester.widget<TeamRow>(firstRow).selected, isTrue);
    expect(
      tester
          .widgetList<TeamRow>(find.byType(TeamRow))
          .where((row) => row.selected),
      hasLength(1),
    );

    await _activateTeam(tester, another.id);
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
        final harness = _TeamSelectionHarness();
        try {
          await harness.pump(tester);
          final l10n = await AppLocalizations.delegate.load(harness.locale);
          if (testCase.selectTeam) {
            await _activateTeam(
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
          await _pumpUntilSnackBar(
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
    final harness = _TeamSelectionHarness();
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final selectedTeam = harness.gameFactory.previewTeams()[2];
    await _activateTeam(tester, selectedTeam.id);
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
      final repository = _TeamSelectionSaveRepository()
        ..saveRelease = Completer<void>();
      final harness = _TeamSelectionHarness(repository: repository);
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);
      final selectedTeam = harness.gameFactory.previewTeams().first;
      await _activateTeam(tester, selectedTeam.id);
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
    final repository = _TeamSelectionSaveRepository()
      ..saveFailure = SaveRepositoryException('controlled create failure');
    final harness = _TeamSelectionHarness(repository: repository);
    addTearDown(() => harness.dispose(tester));

    await harness.pump(tester);
    final selectedTeam = harness.gameFactory.previewTeams()[3];
    final selectedRow = _teamRowFinder(selectedTeam.id);
    const enteredName = '  Preserved career  ';
    await _activateTeam(tester, selectedTeam.id);
    await tester.enterText(
      find.byKey(const ValueKey<String>('new-game-save-name')),
      enteredName,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('new-game-start-button')),
    );

    final l10n = await AppLocalizations.delegate.load(harness.locale);
    await _pumpUntilSnackBar(tester, expectedText: l10n.newGame_createFailed);

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
  testWidgets(
    'exposes localized row semantics and orders every row before start',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final harness = _TeamSelectionHarness(locale: locale);
        SemanticsHandle? semanticsHandle;
        try {
          await harness.pump(tester);
          semanticsHandle = _ensureSemantics(tester);
          await tester.pump();

          final l10n = await AppLocalizations.delegate.load(locale);
          _expectLocalizedNewGameChrome(tester, l10n);
          final teams = harness.gameFactory.previewTeams();
          final startFinder = find.bySemanticsLabel(l10n.newGame_start);
          expect(startFinder, findsOneWidget);
          final startNode = tester.getSemantics(startFinder);
          expect(startNode.label, l10n.newGame_start);
          expect(startNode.flagsCollection.isButton, isTrue);
          expect(
            startNode.getSemanticsData().hasAction(ui.SemanticsAction.tap),
            isTrue,
          );
          expect(l10n.newGame_start, isNotEmpty);

          for (final team in teams) {
            final rowFinder = _teamRowFinder(team.id);
            if (rowFinder.evaluate().isEmpty) {
              final teamList = find.byKey(
                const ValueKey<String>('new-game-team-list'),
              );
              await tester.scrollUntilVisible(
                rowFinder,
                300,
                scrollable: _teamListScrollable(teamList),
              );
            }
            await tester.pumpAndSettle();
            expect(rowFinder, findsOneWidget);

            final rowNode = _expectTeamRowSemantics(
              tester,
              l10n,
              teamId: team.id,
              name: team.name,
              city: team.city,
              conferenceLabel: team.conference.label,
              selected: false,
            );
            _expectSemanticsPrecedes(rowNode, startNode);

            final imageFinder = find.descendant(
              of: rowFinder,
              matching: find.byType(Image),
            );
            expect(imageFinder, findsOneWidget);
            expect(
              _semanticsSubtree(rowNode),
              hasLength(1),
              reason:
                  'the decorative logo must not add a semantics or focus node',
            );
          }

          final selectedTeam = teams.first;
          final teamList = find.byKey(
            const ValueKey<String>('new-game-team-list'),
          );
          final listScrollableState = tester.state<ScrollableState>(
            _teamListScrollable(teamList),
          );
          listScrollableState.position.jumpTo(0);
          await tester.pumpAndSettle();
          await _activateTeam(tester, selectedTeam.id);
          final selectedNode = _expectTeamRowSemantics(
            tester,
            l10n,
            teamId: selectedTeam.id,
            name: selectedTeam.name,
            city: selectedTeam.city,
            conferenceLabel: selectedTeam.conference.label,
            selected: true,
          );
          _expectSemanticsPrecedes(selectedNode, startNode);

          final selectedRow = _teamRowFinder(selectedTeam.id);
          expect(tester.widget<TeamRow>(selectedRow).selected, isTrue);
          final secondTeam = teams[1];
          final secondNode = _expectTeamRowSemantics(
            tester,
            l10n,
            teamId: secondTeam.id,
            name: secondTeam.name,
            city: secondTeam.city,
            conferenceLabel: secondTeam.conference.label,
            selected: false,
          );
          _performSemanticsTap(secondNode);
          await tester.pump();

          expect(tester.widget<TeamRow>(selectedRow).selected, isFalse);
          expect(
            tester.widget<TeamRow>(_teamRowFinder(secondTeam.id)).selected,
            isTrue,
          );
          _expectTeamRowSemantics(
            tester,
            l10n,
            teamId: selectedTeam.id,
            name: selectedTeam.name,
            city: selectedTeam.city,
            conferenceLabel: selectedTeam.conference.label,
            selected: false,
          );
          _expectTeamRowSemantics(
            tester,
            l10n,
            teamId: secondTeam.id,
            name: secondTeam.name,
            city: secondTeam.city,
            conferenceLabel: secondTeam.conference.label,
            selected: true,
          );
        } finally {
          semanticsHandle?.dispose();
          await harness.dispose(tester);
        }
      }
    },
  );

  testWidgets('semantic activation has the same result as a tap', (
    tester,
  ) async {
    final targetTeam = GameFactory().previewTeams().first;

    for (final locale in const [Locale('pl'), Locale('en')]) {
      final tapHarness = _TeamSelectionHarness(locale: locale);
      try {
        await tapHarness.pump(tester);
        await _activateTeam(tester, targetTeam.id);
        final tapSelection = tester
            .widget<TeamRow>(_teamRowFinder(targetTeam.id))
            .selected;
        expect(tapSelection, isTrue);
      } finally {
        await tapHarness.dispose(tester);
      }

      final semanticHarness = _TeamSelectionHarness(locale: locale);
      SemanticsHandle? semanticsHandle;
      try {
        await semanticHarness.pump(tester);
        semanticsHandle = _ensureSemantics(tester);
        await tester.pump();
        final l10n = await AppLocalizations.delegate.load(locale);
        final rowNode = _expectTeamRowSemantics(
          tester,
          l10n,
          teamId: targetTeam.id,
          name: targetTeam.name,
          city: targetTeam.city,
          conferenceLabel: targetTeam.conference.label,
          selected: false,
        );
        _performSemanticsTap(rowNode);
        await tester.pump();

        expect(
          tester.widget<TeamRow>(_teamRowFinder(targetTeam.id)).selected,
          isTrue,
        );
      } finally {
        semanticsHandle?.dispose();
        await semanticHarness.dispose(tester);
      }
    }
  });

  testWidgets('uses generated locale text for chrome and both snackbars', (
    tester,
  ) async {
    for (final locale in const [Locale('pl'), Locale('en')]) {
      final missingFieldsHarness = _TeamSelectionHarness(locale: locale);
      try {
        await missingFieldsHarness.pump(tester);
        final l10n = await AppLocalizations.delegate.load(locale);
        _expectLocalizedNewGameChrome(tester, l10n);

        await tester.tap(
          find.byKey(const ValueKey<String>('new-game-start-button')),
        );
        await _pumpUntilSnackBar(
          tester,
          expectedText: l10n.newGame_missingFields,
        );
        expect(find.text(l10n.newGame_missingFields), findsOneWidget);
      } finally {
        await missingFieldsHarness.dispose(tester);
      }

      final failureRepository = _TeamSelectionSaveRepository()
        ..saveFailure = SaveRepositoryException('localized failure');
      final failureHarness = _TeamSelectionHarness(
        locale: locale,
        repository: failureRepository,
      );
      try {
        await failureHarness.pump(tester);
        final l10n = await AppLocalizations.delegate.load(locale);
        await _activateTeam(
          tester,
          failureHarness.gameFactory.previewTeams().first.id,
        );
        await tester.tap(
          find.byKey(const ValueKey<String>('new-game-start-button')),
        );
        await _pumpUntilSnackBar(
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
    final harness = _TeamSelectionHarness(locale: const Locale('pl'));
    SemanticsHandle? semanticsHandle;
    try {
      await harness.pump(tester);
      semanticsHandle = _ensureSemantics(tester);
      await tester.pump();

      final selectedTeam = harness.gameFactory.previewTeams().first;
      await _activateTeam(tester, selectedTeam.id);
      expect(
        tester.widget<TeamRow>(_teamRowFinder(selectedTeam.id)).selected,
        isTrue,
      );

      await harness.rebuildWithLocale(tester, const Locale('en'));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      _expectLocalizedNewGameChrome(tester, l10n);
      expect(harness.router.state.uri.path, '/new-game');
      expect(
        tester.widget<TeamRow>(_teamRowFinder(selectedTeam.id)).selected,
        isTrue,
      );

      final expectedLabel = l10n.newGame_teamSemantics(
        selectedTeam.name,
        selectedTeam.city,
        selectedTeam.conference.label,
        l10n.newGame_teamSelected,
      );
      expect(find.bySemanticsLabel(expectedLabel), findsOneWidget);
    } finally {
      semanticsHandle?.dispose();
      await harness.dispose(tester);
    }
  });

  testWidgets(
    'keeps the selection screen bounded across the viewport and text-scale matrix',
    (tester) async {
      const viewports = <Size>[
        Size(320, 568),
        Size(360, 800),
        Size(390, 844),
        Size(844, 390),
      ];
      const textScales = <double>[1.0, 1.3, 2.0];

      for (final viewport in viewports) {
        for (final textScale in textScales) {
          final harness = _TeamSelectionHarness(
            viewport: viewport,
            textScale: textScale,
          );
          SemanticsHandle? semanticsHandle;
          final scenario =
              '${viewport.width.toInt()}x${viewport.height.toInt()} '
              'at text scale $textScale';
          try {
            await harness.pump(tester);
            if (textScale == 2.0) {
              semanticsHandle = _ensureSemantics(tester);
              await tester.pump();
            }

            final teams = harness.gameFactory.previewTeams();
            _expectResponsiveGeometry(
              tester,
              teamId: teams.first.id,
              scenario: scenario,
            );
            expect(
              _takeException(tester),
              isNull,
              reason: 'layout exception for $scenario',
            );

            if (textScale == 2.0) {
              final l10n = await AppLocalizations.delegate.load(harness.locale);
              await _expectScaleTwoRowsRemainComplete(
                tester,
                teams: teams,
                l10n: l10n,
                scenario: scenario,
              );
            }
            expect(
              _takeException(tester),
              isNull,
              reason: 'overflow after scrolling for $scenario',
            );
          } finally {
            semanticsHandle?.dispose();
            await harness.dispose(tester);
          }
        }
      }
    },
  );

  testWidgets(
    'retains the selected team when resizing from portrait to landscape',
    (tester) async {
      final harness = _TeamSelectionHarness(
        viewport: const Size(390, 844),
        textScale: 1.0,
      );
      try {
        await harness.pump(tester);
        final selectedTeam = harness.gameFactory.previewTeams()[4];
        await _activateTeam(tester, selectedTeam.id);
        expect(
          tester.widget<TeamRow>(_teamRowFinder(selectedTeam.id)).selected,
          isTrue,
        );
        expect(_takeException(tester), isNull);

        _configureTestView(tester, viewport: const Size(844, 390));
        await tester.pumpAndSettle();
        expect(
          _takeException(tester),
          isNull,
          reason: 'portrait-to-landscape resize produced an exception',
        );

        final selectedRow = _teamRowFinder(selectedTeam.id);
        await tester.scrollUntilVisible(
          selectedRow,
          300,
          scrollable: _teamListScrollable(
            find.byKey(const ValueKey<String>('new-game-team-list')),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.widget<TeamRow>(selectedRow).selected, isTrue);
        final selectedRows = tester
            .widgetList<TeamRow>(find.byType(TeamRow))
            .where((row) => row.selected)
            .toList();
        expect(selectedRows, hasLength(1));
        expect(selectedRows.single.teamId, selectedTeam.id);

        _expectResponsiveGeometry(
          tester,
          teamId: selectedTeam.id,
          scenario: 'portrait-to-landscape resize',
        );
      } finally {
        await harness.dispose(tester);
      }
    },
  );

  testWidgets(
    'loads and decodes the active placeholder asset before rendering it',
    (tester) async {
      var assetLength = 0;
      var decodedWidth = 0;
      var decodedHeight = 0;
      await tester.runAsync(() async {
        final assetData = await rootBundle.load(
          TeamSelectionAssets.placeholderAsset,
        );
        assetLength = assetData.lengthInBytes;
        final codec = await ui.instantiateImageCodec(
          assetData.buffer.asUint8List(
            assetData.offsetInBytes,
            assetData.lengthInBytes,
          ),
        );
        try {
          final frame = await codec.getNextFrame();
          decodedWidth = frame.image.width;
          decodedHeight = frame.image.height;
          frame.image.dispose();
        } finally {
          codec.dispose();
        }
      });
      expect(assetLength, greaterThan(0));
      expect(decodedWidth, greaterThan(0));
      expect(decodedHeight, greaterThan(0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamRow(
              teamId: 'asset-smoke-team',
              name: 'Asset Smoke FC',
              city: 'Test City',
              conferenceLabel: 'Test Conference',
              selected: false,
              placeholderAsset: TeamSelectionAssets.placeholderAsset,
              localizedSemanticsLabel:
                  'Asset Smoke FC, Test City, Test Conference, Not selected',
              onActivate: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        TeamSelectionAssets.placeholderAsset,
      );
      expect(_takeException(tester), isNull);
    },
  );

  testWidgets('keeps an unavailable placeholder out of semantics', (
    tester,
  ) async {
    var activations = 0;
    const label = 'Fallback FC, Test City, Test Conference, Not selected';
    final semanticsHandle = _ensureSemantics(tester);
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamRow(
              key: const ValueKey<String>('fallback-team-row'),
              teamId: 'fallback-team',
              name: 'Fallback FC',
              city: 'Test City',
              conferenceLabel: 'Test Conference',
              selected: false,
              placeholderAsset: 'assets/images/not-available.png',
              localizedSemanticsLabel: label,
              onActivate: () => activations++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rowFinder = find.bySemanticsLabel(label);
      expect(rowFinder, findsOneWidget);
      final rowNode = tester.getSemantics(rowFinder);
      expect(rowNode.flagsCollection.isButton, isTrue);
      expect(
        rowNode.getSemanticsData().hasAction(ui.SemanticsAction.tap),
        isTrue,
      );
      expect(_semanticsSubtree(rowNode), hasLength(1));
      expect(find.text('Fallback FC'), findsOneWidget);
      expect(find.text('Test City · Test Conference'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(_takeException(tester), isNull);

      await tester.tap(find.byKey(const ValueKey<String>('fallback-team-row')));
      await tester.pump();
      expect(activations, 1);

      _performSemanticsTap(rowNode);
      await tester.pump();
      expect(activations, 2);
    } finally {
      semanticsHandle.dispose();
    }
  });
}

Finder _teamRowFinder(String teamId) =>
    find.byKey(ValueKey<String>('new-game-team-row-$teamId'));

Future<void> _activateTeam(WidgetTester tester, String teamId) async {
  final row = _teamRowFinder(teamId);
  if (row.evaluate().isEmpty) {
    final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
    await tester.scrollUntilVisible(
      row,
      300,
      scrollable: _teamListScrollable(teamList),
    );
  }
  expect(row, findsOneWidget);
  await tester.tap(row);
  await tester.pump();
}

Future<void> _pumpUntilSnackBar(
  WidgetTester tester, {
  required String expectedText,
  int maxPumps = 40,
  Duration step = const Duration(milliseconds: 20),
}) async {
  for (var index = 0; index < maxPumps; index++) {
    await tester.pump(step);
    if (find.text(expectedText).evaluate().isNotEmpty) return;
  }
  expect(find.text(expectedText), findsOneWidget);
}

const double _geometryTolerance = 0.01;

Finder _teamListScrollable(Finder teamList) =>
    find.descendant(of: teamList, matching: find.byType(Scrollable));

Rect _testViewportRect(WidgetTester tester) {
  final physicalSize = tester.view.physicalSize;
  final devicePixelRatio = tester.view.devicePixelRatio;
  return Offset.zero &
      Size(
        physicalSize.width / devicePixelRatio,
        physicalSize.height / devicePixelRatio,
      );
}

void _expectRectInside(Rect outer, Rect inner) {
  expect(inner.left, greaterThanOrEqualTo(outer.left - _geometryTolerance));
  expect(inner.top, greaterThanOrEqualTo(outer.top - _geometryTolerance));
  expect(inner.right, lessThanOrEqualTo(outer.right + _geometryTolerance));
  expect(inner.bottom, lessThanOrEqualTo(outer.bottom + _geometryTolerance));
}

void _expectRectStable(Rect before, Rect after, {required String reason}) {
  expect(after.left, closeTo(before.left, _geometryTolerance), reason: reason);
  expect(after.top, closeTo(before.top, _geometryTolerance), reason: reason);
  expect(
    after.right,
    closeTo(before.right, _geometryTolerance),
    reason: reason,
  );
  expect(
    after.bottom,
    closeTo(before.bottom, _geometryTolerance),
    reason: reason,
  );
}

void _configureTestView(
  WidgetTester tester, {
  required Size viewport,
  double devicePixelRatio = 1.0,
}) {
  tester.view.devicePixelRatio = devicePixelRatio;
  tester.view.physicalSize = Size(
    viewport.width * devicePixelRatio,
    viewport.height * devicePixelRatio,
  );
}

void _expectResponsiveGeometry(
  WidgetTester tester, {
  required String teamId,
  required String scenario,
}) {
  final viewportRect = _testViewportRect(tester);
  final appBar = find.byType(AppBar);
  final saveName = find.byKey(const ValueKey<String>('new-game-save-name'));
  final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
  final fixedAction = find.byKey(
    const ValueKey<String>('new-game-fixed-action'),
  );
  final startButton = find.byKey(
    const ValueKey<String>('new-game-start-button'),
  );

  expect(appBar, findsOneWidget, reason: '$scenario: missing AppBar');
  expect(saveName, findsOneWidget, reason: '$scenario: missing save field');
  expect(teamList, findsOneWidget, reason: '$scenario: missing team list');
  expect(
    fixedAction,
    findsOneWidget,
    reason: '$scenario: missing fixed action region',
  );
  expect(
    startButton,
    findsOneWidget,
    reason: '$scenario: missing start button',
  );

  final appBarRect = _rect(tester, appBar);
  final saveNameRect = _rect(tester, saveName);
  final teamListRect = _rect(tester, teamList);
  final fixedActionRect = _rect(tester, fixedAction);
  final startButtonRect = _rect(tester, startButton);

  _expectRectInside(viewportRect, appBarRect);
  _expectRectInside(viewportRect, saveNameRect);
  _expectRectInside(viewportRect, teamListRect);
  _expectRectInside(viewportRect, fixedActionRect);
  _expectRectInside(viewportRect, startButtonRect);
  _expectRectInside(fixedActionRect, startButtonRect);
  expect(
    teamListRect.overlaps(fixedActionRect),
    isFalse,
    reason: '$scenario: list overlaps fixed action',
  );
  expect(
    teamListRect.bottom,
    lessThanOrEqualTo(fixedActionRect.top - 8.0 + _geometryTolerance),
    reason: '$scenario: list/action gap is smaller than 8 logical pixels',
  );

  final row = _teamRowFinder(teamId);
  expect(row, findsOneWidget, reason: '$scenario: missing measured team row');
  final rowRect = _rect(tester, row);
  final image = find.descendant(of: row, matching: find.byType(Image));
  expect(image, findsOneWidget, reason: '$scenario: missing team icon');
  _expectIconGeometry(tester, image, rowRect, reason: scenario);
}

Future<void> _expectScaleTwoRowsRemainComplete(
  WidgetTester tester, {
  required Iterable<
    ({String id, String name, String city, Conference conference})
  >
  teams,
  required AppLocalizations l10n,
  required String scenario,
}) async {
  final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
  final scrollable = _teamListScrollable(teamList);
  final scrollableState = tester.state<ScrollableState>(scrollable);
  final listHeight = _rect(tester, teamList).height;
  final scrollStep = listHeight > 1.0 ? listHeight / 2 : 1.0;

  for (final team in teams) {
    final row = _teamRowFinder(team.id);
    await _scrollTeamRowIntoView(
      tester,
      row,
      scrollableState,
      scrollStep: scrollStep,
      reason: '$scenario: ${team.id}',
    );
    await Scrollable.ensureVisible(tester.element(row), alignment: 0.5);
    await tester.pumpAndSettle();
    expect(row, findsOneWidget, reason: '$scenario: row left the tree');

    final rowRect = _rect(tester, row);
    final name = find.descendant(of: row, matching: find.text(team.name));
    final details = find.descendant(
      of: row,
      matching: find.text('${team.city} · ${team.conference.label}'),
    );
    final image = find.descendant(of: row, matching: find.byType(Image));
    expect(name, findsOneWidget, reason: '$scenario: name was not wrapped');
    expect(
      details,
      findsOneWidget,
      reason: '$scenario: city/conference was not wrapped',
    );
    expect(image, findsOneWidget, reason: '$scenario: icon disappeared');
    _expectRectInside(rowRect, _rect(tester, name));
    _expectRectInside(rowRect, _rect(tester, details));
    _expectIconGeometry(tester, image, rowRect, reason: scenario);

    _expectTeamRowSemantics(
      tester,
      l10n,
      teamId: team.id,
      name: team.name,
      city: team.city,
      conferenceLabel: team.conference.label,
      selected: false,
    );
  }
}

Future<void> _scrollTeamRowIntoView(
  WidgetTester tester,
  Finder row,
  ScrollableState scrollableState, {
  required double scrollStep,
  required String reason,
}) async {
  for (var attempt = 0; row.evaluate().isEmpty && attempt < 300; attempt++) {
    final position = scrollableState.position;
    final nextOffset = position.pixels + scrollStep;
    position.jumpTo(
      nextOffset > position.maxScrollExtent
          ? position.maxScrollExtent
          : nextOffset,
    );
    await tester.pumpAndSettle();
    if (position.pixels >= position.maxScrollExtent) break;
  }
  expect(
    row,
    findsOneWidget,
    reason:
        '$reason: row could not be mounted '
        '(offset=${scrollableState.position.pixels}, '
        'max=${scrollableState.position.maxScrollExtent}, '
        'list=${_rect(tester, find.byKey(const ValueKey<String>('new-game-team-list')))}, '
        'mountedRows=${find.byType(TeamRow).evaluate().length})',
  );
}

void _expectIconGeometry(
  WidgetTester tester,
  Finder image,
  Rect rowRect, {
  required String reason,
}) {
  final imageRect = _rect(tester, image);
  expect(
    imageRect.width,
    inInclusiveRange(40.0, 56.0),
    reason: '$reason: icon width is outside 40–56 logical pixels',
  );
  expect(
    imageRect.height,
    inInclusiveRange(40.0, 56.0),
    reason: '$reason: icon height is outside 40–56 logical pixels',
  );
  expect(
    imageRect.width,
    closeTo(imageRect.height, _geometryTolerance),
    reason: '$reason: icon field is not square',
  );
  _expectRectInside(rowRect, imageRect);
}

void _resetTestView(WidgetTester tester) {
  tester.view.reset();
}

Future<void> _resetWidget(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();
}

SemanticsHandle _ensureSemantics(WidgetTester tester) {
  return tester.ensureSemantics();
}

void _expectLocalizedNewGameChrome(WidgetTester tester, AppLocalizations l10n) {
  expect(find.text(l10n.newGame_title), findsOneWidget);
  expect(find.text(l10n.newGame_chooseTeam), findsOneWidget);
  expect(
    tester
        .widget<TextField>(
          find.byKey(const ValueKey<String>('new-game-save-name')),
        )
        .decoration
        ?.labelText,
    l10n.newGame_saveName,
  );
  expect(find.text(l10n.newGame_start), findsOneWidget);
  expect(l10n.newGame_start, isNotEmpty);
  expect(
    tester
        .widget<FilledButton>(
          find.byKey(const ValueKey<String>('new-game-start-button')),
        )
        .onPressed,
    isNotNull,
  );
}

SemanticsNode _expectTeamRowSemantics(
  WidgetTester tester,
  AppLocalizations l10n, {
  required String teamId,
  required String name,
  required String city,
  required String conferenceLabel,
  required bool selected,
}) {
  final state = selected
      ? l10n.newGame_teamSelected
      : l10n.newGame_teamNotSelected;
  final expectedLabel = l10n.newGame_teamSemantics(
    name,
    city,
    conferenceLabel,
    state,
  );
  final semanticsFinder = find.bySemanticsLabel(expectedLabel);
  expect(semanticsFinder, findsOneWidget, reason: 'semantics for $teamId');

  final node = tester.getSemantics(semanticsFinder);
  expect(node.label, expectedLabel);
  expect(node.label, contains(name));
  expect(node.label, contains(city));
  expect(node.label, contains(conferenceLabel));
  expect(node.label, contains(state));
  expect(node.flagsCollection.isButton, isTrue);
  expect(
    node.flagsCollection.isSelected,
    selected ? ui.Tristate.isTrue : ui.Tristate.isFalse,
  );
  expect(node.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);
  final activationRect = tester.getRect(_teamRowFinder(teamId));
  expect(activationRect.width, greaterThanOrEqualTo(48.0));
  expect(activationRect.height, greaterThanOrEqualTo(48.0));

  final activatableNodes = _semanticsSubtree(node)
      .where(
        (candidate) =>
            candidate.flagsCollection.isButton ||
            candidate.getSemanticsData().hasAction(ui.SemanticsAction.tap),
      )
      .toList();
  expect(activatableNodes, hasLength(1));
  expect(identical(activatableNodes.single, node), isTrue);
  return node;
}

void _performSemanticsTap(SemanticsNode node) {
  final owner = node.owner;
  expect(owner, isNotNull);
  owner!.performAction(node.id, ui.SemanticsAction.tap);
}

List<SemanticsNode> _semanticsSubtree(SemanticsNode root) {
  final nodes = <SemanticsNode>[];

  void visit(SemanticsNode node) {
    nodes.add(node);
    for (final child in node.debugListChildrenInOrder(
      DebugSemanticsDumpOrder.traversalOrder,
    )) {
      visit(child);
    }
  }

  visit(root);
  return nodes;
}

SemanticsNode _semanticsRoot(SemanticsNode node) {
  var root = node;
  while (true) {
    final parent = root.parent;
    if (parent is! SemanticsNode) return root;
    root = parent;
  }
}

void _expectSemanticsPrecedes(SemanticsNode row, SemanticsNode start) {
  final orderedNodes = _semanticsSubtree(_semanticsRoot(row));
  final rowIndex = orderedNodes.indexWhere((node) => identical(node, row));
  final startIndex = orderedNodes.indexWhere((node) => identical(node, start));
  expect(rowIndex, greaterThanOrEqualTo(0));
  expect(startIndex, greaterThanOrEqualTo(0));
  expect(rowIndex, lessThan(startIndex));
}

Object? _takeException(WidgetTester tester) {
  return tester.takeException();
}

Rect _rect(WidgetTester tester, Finder finder) {
  return tester.getRect(finder);
}
