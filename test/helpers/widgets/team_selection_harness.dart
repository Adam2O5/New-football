import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/new_game_screen.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../persistence/no_disk_save_repository.dart';

/// A repository double for the team-selection flow.
///
/// The double records both attempted and completed saves. Tests can assign
/// [saveRelease] before activation to keep the controller in its loading state
/// and can assign [saveFailure] to exercise the existing error path.
class TeamSelectionSaveRepository extends NoDiskSaveRepository {
  TeamSelectionSaveRepository();

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
class TeamSelectionHarness {
  TeamSelectionHarness({
    this.locale = const Locale('pl'),
    this.viewport = const Size(390, 844),
    this.textScale = 1.0,
    GameFactory? gameFactory,
    TeamSelectionSaveRepository? repository,
  }) : gameFactory = gameFactory ?? GameFactory(),
       repository = repository ?? TeamSelectionSaveRepository();

  Locale locale;
  final Size viewport;
  final double textScale;
  final GameFactory gameFactory;
  final TeamSelectionSaveRepository repository;
  final destinationUris = <Uri>[];

  late final GoRouter router = _createRouter();
  late GameController controller;

  Future<void> pump(WidgetTester tester) async {
    configureTestView(tester, viewport: viewport);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
  }

  Future<void> rebuildWithLocale(WidgetTester tester, Locale nextLocale) async {
    locale = nextLocale;
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await resetWidget(tester);
    router.dispose();
    resetTestView(tester);
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

Finder teamRowFinder(String teamId) =>
    find.byKey(ValueKey<String>('new-game-team-row-$teamId'));

Future<void> activateTeam(WidgetTester tester, String teamId) async {
  final row = teamRowFinder(teamId);
  if (row.evaluate().isEmpty) {
    final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
    await tester.scrollUntilVisible(
      row,
      300,
      scrollable: teamListScrollable(teamList),
    );
  }
  expect(row, findsOneWidget);
  await tester.tap(row);
  await tester.pump();
}

Future<void> pumpUntilSnackBar(
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

const double geometryTolerance = 0.01;

Finder teamListScrollable(Finder teamList) =>
    find.descendant(of: teamList, matching: find.byType(Scrollable));

Rect testViewportRect(WidgetTester tester) {
  final physicalSize = tester.view.physicalSize;
  final devicePixelRatio = tester.view.devicePixelRatio;
  return Offset.zero &
      Size(
        physicalSize.width / devicePixelRatio,
        physicalSize.height / devicePixelRatio,
      );
}

void expectRectInside(Rect outer, Rect inner) {
  expect(inner.left, greaterThanOrEqualTo(outer.left - geometryTolerance));
  expect(inner.top, greaterThanOrEqualTo(outer.top - geometryTolerance));
  expect(inner.right, lessThanOrEqualTo(outer.right + geometryTolerance));
  expect(inner.bottom, lessThanOrEqualTo(outer.bottom + geometryTolerance));
}

void expectRectStable(Rect before, Rect after, {required String reason}) {
  expect(after.left, closeTo(before.left, geometryTolerance), reason: reason);
  expect(after.top, closeTo(before.top, geometryTolerance), reason: reason);
  expect(after.right, closeTo(before.right, geometryTolerance), reason: reason);
  expect(
    after.bottom,
    closeTo(before.bottom, geometryTolerance),
    reason: reason,
  );
}

void configureTestView(
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

void expectResponsiveGeometry(
  WidgetTester tester, {
  required String teamId,
  required String scenario,
}) {
  final viewportRect = testViewportRect(tester);
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

  final appBarRect = rect(tester, appBar);
  final saveNameRect = rect(tester, saveName);
  final teamListRect = rect(tester, teamList);
  final fixedActionRect = rect(tester, fixedAction);
  final startButtonRect = rect(tester, startButton);

  expectRectInside(viewportRect, appBarRect);
  expectRectInside(viewportRect, saveNameRect);
  expectRectInside(viewportRect, teamListRect);
  expectRectInside(viewportRect, fixedActionRect);
  expectRectInside(viewportRect, startButtonRect);
  expectRectInside(fixedActionRect, startButtonRect);
  expect(
    teamListRect.overlaps(fixedActionRect),
    isFalse,
    reason: '$scenario: list overlaps fixed action',
  );
  expect(
    teamListRect.bottom,
    lessThanOrEqualTo(fixedActionRect.top - 8.0 + geometryTolerance),
    reason: '$scenario: list/action gap is smaller than 8 logical pixels',
  );

  final row = teamRowFinder(teamId);
  expect(row, findsOneWidget, reason: '$scenario: missing measured team row');
  final rowRect = rect(tester, row);
  final image = find.descendant(of: row, matching: find.byType(Image));
  expect(image, findsOneWidget, reason: '$scenario: missing team icon');
  expectIconGeometry(tester, image, rowRect, reason: scenario);
}

Future<void> expectScaleTwoRowsRemainComplete(
  WidgetTester tester, {
  required Iterable<
    ({String id, String name, String city, Conference conference})
  >
  teams,
  required AppLocalizations l10n,
  required String scenario,
}) async {
  final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
  final scrollable = teamListScrollable(teamList);
  final scrollableState = tester.state<ScrollableState>(scrollable);
  final listHeight = rect(tester, teamList).height;
  final scrollStep = listHeight > 1.0 ? listHeight / 2 : 1.0;

  for (final team in teams) {
    final row = teamRowFinder(team.id);
    await scrollTeamRowIntoView(
      tester,
      row,
      scrollableState,
      scrollStep: scrollStep,
      reason: '$scenario: ${team.id}',
    );
    await Scrollable.ensureVisible(tester.element(row), alignment: 0.5);
    await tester.pumpAndSettle();
    expect(row, findsOneWidget, reason: '$scenario: row left the tree');

    final rowRect = rect(tester, row);
    final name = find.descendant(of: row, matching: find.text(team.name));
    final details = find.descendant(
      of: row,
      matching: find.text(
        '${team.city} · ${selectionConferenceLabel(l10n, team.conference)}',
      ),
    );
    final image = find.descendant(of: row, matching: find.byType(Image));
    expect(name, findsOneWidget, reason: '$scenario: name was not wrapped');
    expect(
      details,
      findsOneWidget,
      reason: '$scenario: city/conference was not wrapped',
    );
    expect(image, findsOneWidget, reason: '$scenario: icon disappeared');
    expectRectInside(rowRect, rect(tester, name));
    expectRectInside(rowRect, rect(tester, details));
    expectIconGeometry(tester, image, rowRect, reason: scenario);

    expectTeamRowSemantics(
      tester,
      l10n,
      teamId: team.id,
      name: team.name,
      city: team.city,
      conferenceLabel: selectionConferenceLabel(l10n, team.conference),
      selected: false,
    );
  }
}

Future<void> scrollTeamRowIntoView(
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
        'list=${rect(tester, find.byKey(const ValueKey<String>('new-game-team-list')))}, '
        'mountedRows=${find.byType(TeamRow).evaluate().length})',
  );
}

void expectIconGeometry(
  WidgetTester tester,
  Finder image,
  Rect rowRect, {
  required String reason,
}) {
  final imageRect = rect(tester, image);
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
    closeTo(imageRect.height, geometryTolerance),
    reason: '$reason: icon field is not square',
  );
  expectRectInside(rowRect, imageRect);
}

void resetTestView(WidgetTester tester) {
  tester.view.reset();
}

Future<void> resetWidget(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();
}

SemanticsHandle ensureSemantics(WidgetTester tester) {
  return tester.ensureSemantics();
}

void expectLocalizedNewGameChrome(WidgetTester tester, AppLocalizations l10n) {
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

String selectionConferenceLabel(AppLocalizations l10n, Conference conference) =>
    switch (conference) {
      Conference.europe => l10n.teamOverview_conferenceEurope,
      Conference.restOfTheWorld => l10n.teamOverview_conferenceRestOfWorld,
    };

SemanticsNode expectTeamRowSemantics(
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
  final activationRect = tester.getRect(teamRowFinder(teamId));
  expect(activationRect.width, greaterThanOrEqualTo(48.0));
  expect(activationRect.height, greaterThanOrEqualTo(48.0));

  final activatableNodes = semanticsSubtree(node)
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

void performSemanticsTap(SemanticsNode node) {
  final owner = node.owner;
  expect(owner, isNotNull);
  owner!.performAction(node.id, ui.SemanticsAction.tap);
}

List<SemanticsNode> semanticsSubtree(SemanticsNode root) {
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

SemanticsNode semanticsRoot(SemanticsNode node) {
  var root = node;
  while (true) {
    final parent = root.parent;
    if (parent is! SemanticsNode) return root;
    root = parent;
  }
}

void expectSemanticsPrecedes(SemanticsNode row, SemanticsNode start) {
  final orderedNodes = semanticsSubtree(semanticsRoot(row));
  final rowIndex = orderedNodes.indexWhere((node) => identical(node, row));
  final startIndex = orderedNodes.indexWhere((node) => identical(node, start));
  expect(rowIndex, greaterThanOrEqualTo(0));
  expect(startIndex, greaterThanOrEqualTo(0));
  expect(rowIndex, lessThan(startIndex));
}

Object? takeException(WidgetTester tester) {
  return tester.takeException();
}

Rect rect(WidgetTester tester, Finder finder) {
  return tester.getRect(finder);
}
