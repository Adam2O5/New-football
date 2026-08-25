@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/branding/club_asset_registry.dart';
import 'package:new_football/app/branding/club_branding_registry.dart';
import 'package:new_football/app/branding/club_color_tokens.dart';
import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widget_harness.dart';

const _portrait = Size(390, 844);
const _landscape = Size(844, 390);
const _geometryTolerance = 1.0;
const _unknownTeamId = 'team_unknown_branding_fixture';

void main() {
  testWidgets(
    'Home resolves active-team logos by exact ID without initials and stays bounded',
    (tester) async {
      addTearDown(() => _resetTest(tester));

      const cases = <({String teamId, String logoAsset})>[
        (teamId: 'team_europe_0', logoAsset: 'assets/images/Syrenka_FC.png'),
        (teamId: 'team_europe_2', logoAsset: 'assets/images/Marseille_FC.png'),
        (
          teamId: 'team_restOfTheWorld_21',
          logoAsset: 'assets/images/Chicago_Aces.png',
        ),
      ];

      for (final testCase in cases) {
        final sourceGame = task41Game(seed: 5600 + cases.indexOf(testCase));
        final game = _withActiveTeam(sourceGame, testCase.teamId);
        await _pumpScreen(
          tester,
          screen: HomeScreen(key: ValueKey<String>(testCase.teamId)),
          game: game,
          viewport: _portrait,
        );

        final resolution = ClubBrandingRegistry.production.resolve(
          testCase.teamId,
        );
        expect(
          resolution.logoAsset,
          testCase.logoAsset,
          reason: 'the fixture must exercise the exact reference-table ID',
        );

        final header = find.byKey(
          const ValueKey<String>('home-dashboard-header'),
        );
        expect(game.leagueState.playerTeamId, testCase.teamId);
        final providerContainer = ProviderScope.containerOf(
          tester.element(find.byType(HomeScreen)),
        );
        expect(
          providerContainer.read(activeLeagueProvider)?.playerTeamId,
          testCase.teamId,
        );
        expect(
          providerContainer
              .read(clubBrandingProvider)
              .resolve(testCase.teamId)
              .logoAsset,
          testCase.logoAsset,
        );
        _expectHomeLogo(
          tester,
          header,
          expectedAsset: testCase.logoAsset,
          scenario: testCase.teamId,
        );

        final activeTeam = game.leagueState.teamById(testCase.teamId)!;
        expect(
          find.descendant(of: header, matching: find.text(activeTeam.name)),
          findsOneWidget,
          reason: '${testCase.teamId}: the active team name is missing',
        );
        expect(
          find.descendant(of: header, matching: find.byType(CircleAvatar)),
          findsNothing,
          reason: '${testCase.teamId}: initials/avatar fallback was rendered',
        );
        expect(
          find.descendant(
            of: header,
            matching: find.byIcon(Icons.shield_outlined),
          ),
          findsNothing,
          reason: '${testCase.teamId}: placeholder icon was rendered',
        );
        expect(tester.takeException(), isNull, reason: testCase.teamId);
      }
    },
  );

  testWidgets('Home uses the approved fallback logo for an unknown active ID', (
    tester,
  ) async {
    addTearDown(() => _resetTest(tester));

    final game = _withUnknownActiveTeam(task41Game(seed: 5604), _unknownTeamId);
    final fallbackRegistry = ClubBrandingRegistry(
      records: const [],
      assets: ClubAssetRegistry.production,
      colors: ColorTokenRegistry.production,
    );
    await _pumpScreen(
      tester,
      screen: const HomeScreen(),
      game: game,
      registry: fallbackRegistry,
      viewport: _portrait,
    );

    final resolution = fallbackRegistry.resolve(_unknownTeamId);
    expect(resolution.record, isNull);
    expect(resolution.usedFallbackLogo, isTrue);
    expect(resolution.logoAsset, ClubAssetRegistry.fallbackLogoAssetPath);

    final header = find.byKey(const ValueKey<String>('home-dashboard-header'));
    expect(header, findsOneWidget);
    _expectHomeLogo(
      tester,
      header,
      expectedAsset: ClubAssetRegistry.fallbackLogoAssetPath,
      scenario: _unknownTeamId,
    );
    expect(
      find.descendant(of: header, matching: find.text('Unknown Branding FC')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: header, matching: find.byType(CircleAvatar)),
      findsNothing,
    );
    expect(
      find.descendant(of: header, matching: find.byIcon(Icons.shield_outlined)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Home renders three ordered localized season lines and decorative logo semantics',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      addTearDown(() => _resetTest(tester));

      final sourceGame = _seasonFixture(task41Game(seed: 5605));
      final activeTeam = sourceGame.leagueState.teamById('team_europe_0')!;
      String? previousSeasonLine;

      for (final locale in const [Locale('pl'), Locale('en')]) {
        await _pumpScreen(
          tester,
          screen: const HomeScreen(),
          game: sourceGame,
          locale: locale,
          viewport: _portrait,
        );

        final l10n = await AppLocalizations.delegate.load(locale);
        final expectedLines = <String>[
          l10n.home_seasonLine(2042),
          l10n.home_phaseLine(l10n.seasonPhase_playoff),
          l10n.home_weekDayLine(17, 4),
        ];
        final lineKeys = <ValueKey<String>>[
          const ValueKey<String>('home-season-line'),
          const ValueKey<String>('home-phase-line'),
          const ValueKey<String>('home-week-day-line'),
        ];

        for (var index = 0; index < lineKeys.length; index++) {
          final line = find.byKey(lineKeys[index]);
          expect(line, findsOneWidget, reason: 'missing line ${index + 1}');
          expect(
            find.descendant(
              of: line,
              matching: find.text(expectedLines[index]),
            ),
            findsOneWidget,
            reason: '${locale.languageCode}: wrong line ${index + 1}',
          );
          expect(
            tester.getSize(line).height,
            closeTo(24.0, _geometryTolerance),
          );
          if (index > 0) {
            expect(
              tester.getRect(line).top,
              greaterThanOrEqualTo(
                tester.getRect(find.byKey(lineKeys[index - 1])).bottom -
                    _geometryTolerance,
              ),
              reason: '${locale.languageCode}: season lines are out of order',
            );
          }
        }

        final header = find.byKey(
          const ValueKey<String>('home-dashboard-header'),
        );
        final seasonContext = find.byKey(
          const ValueKey<String>('home-season-context'),
        );
        expect(seasonContext, findsOneWidget);
        final headerRect = tester.getRect(header);
        final seasonRect = tester.getRect(seasonContext);
        _expectRectInside(
          _testViewportRect(tester),
          headerRect,
          reason: '${locale.languageCode}: home header exceeds viewport',
        );
        _expectRectInside(
          headerRect,
          seasonRect,
          reason: '${locale.languageCode}: season context exceeds header',
        );

        final teamFinder = find.bySemanticsLabel(activeTeam.name);
        expect(teamFinder, findsOneWidget);
        final teamNode = tester.getSemantics(teamFinder);
        expect(teamNode.label, activeTeam.name);
        expect(teamNode.childrenCount, 0);

        final expectedNodes = expectedLines
            .map((line) => tester.getSemantics(find.bySemanticsLabel(line)))
            .toList(growable: false);
        final orderedNodes = _semanticsSubtree(_semanticsRoot(teamNode));
        final semanticIndices = [
          _indexOfNode(orderedNodes, teamNode),
          ...expectedNodes.map((node) => _indexOfNode(orderedNodes, node)),
        ];
        expect(
          semanticIndices,
          orderedEquals([...semanticIndices]..sort()),
          reason: '${locale.languageCode}: header semantics are not ordered',
        );
        expect(
          find.bySemanticsLabel(
            ClubBrandingRegistry.production.resolve('team_europe_0').logoAsset,
          ),
          findsNothing,
          reason: '${locale.languageCode}: decorative logo gained a label',
        );

        if (previousSeasonLine != null) {
          final previousLine = previousSeasonLine;
          expect(
            find.text(previousLine),
            findsNothing,
            reason: 'locale rebuild retained stale season text',
          );
        }
        previousSeasonLine = expectedLines.first;
        expect(tester.takeException(), isNull, reason: locale.languageCode);
      }
      semanticsHandle.dispose();
    },
  );

  testWidgets(
    'Shell resolves underline colors by active ID, including unknown fallback data',
    (tester) async {
      addTearDown(() => _resetTest(tester));

      final cases = <({String teamId, bool fallback, String expectedTeamName})>[
        (
          teamId: 'team_europe_2',
          fallback: false,
          expectedTeamName: 'Marseille CF',
        ),
        (
          teamId: 'team_restOfTheWorld_21',
          fallback: false,
          expectedTeamName: 'Chicago Wanderers',
        ),
        (
          teamId: _unknownTeamId,
          fallback: true,
          expectedTeamName: 'Unknown Branding FC',
        ),
      ];
      final fallbackRegistry = ClubBrandingRegistry(
        records: const [],
        assets: ClubAssetRegistry.production,
        colors: ColorTokenRegistry.production,
      );

      for (final testCase in cases) {
        final sourceGame = task41Game(seed: 5606 + cases.indexOf(testCase));
        final game = testCase.fallback
            ? _withUnknownActiveTeam(sourceGame, testCase.teamId)
            : _withActiveTeam(sourceGame, testCase.teamId);
        final registry = testCase.fallback
            ? fallbackRegistry
            : ClubBrandingRegistry.production;
        await _pumpScreen(
          tester,
          screen: const ShellScreen(),
          game: game,
          registry: registry,
          viewport: _portrait,
        );

        final title = find.byKey(const ValueKey<String>('shell-team-title'));
        expect(title, findsOneWidget);
        expect(
          find.descendant(
            of: title,
            matching: find.text(testCase.expectedTeamName),
          ),
          findsOneWidget,
        );
        final stripeBoxes = tester
            .widgetList<ColoredBox>(
              find.descendant(of: title, matching: find.byType(ColoredBox)),
            )
            .toList(growable: false);
        expect(stripeBoxes, hasLength(2));
        final resolution = registry.resolve(testCase.teamId);
        expect(stripeBoxes[0].color, resolution.primaryColor);
        expect(stripeBoxes[1].color, resolution.secondaryColor);
        expect(tester.takeException(), isNull, reason: testCase.teamId);
      }
    },
  );

  testWidgets(
    'Shell keeps a long active-team title leading, ellipsized, and clear of actions in both orientations',
    (tester) async {
      final frameworkErrors = <FlutterErrorDetails>[];
      final previousErrorHandler = FlutterError.onError;
      FlutterError.onError = frameworkErrors.add;
      addTearDown(() {
        FlutterError.onError = previousErrorHandler;
      });
      addTearDown(() => _resetTest(tester));

      const longTeamName =
          'Marseille International Athletic Association Football Club';
      final game = _withActiveTeam(
        task41Game(seed: 5610),
        'team_europe_2',
        name: longTeamName,
      );

      try {
        for (final locale in const [Locale('pl'), Locale('en')]) {
          final l10n = await AppLocalizations.delegate.load(locale);
          for (final viewport in const [_portrait, _landscape]) {
            await _pumpScreen(
              tester,
              screen: const ShellScreen(),
              game: game,
              locale: locale,
              viewport: viewport,
            );

            final appBar = find.byType(AppBar);
            final title = find.byKey(
              const ValueKey<String>('shell-team-title'),
            );
            final titleText = find.descendant(
              of: title,
              matching: find.byType(Text),
            );
            expect(appBar, findsOneWidget);
            expect(title, findsOneWidget);
            expect(titleText, findsOneWidget);
            final titleWidget = tester.widget<Text>(titleText);
            expect(titleWidget.data, longTeamName);
            expect(titleWidget.maxLines, 1);
            expect(titleWidget.overflow, TextOverflow.ellipsis);

            final appBarRect = tester.getRect(appBar);
            final titleRect = tester.getRect(title);
            final titleTextRect = tester.getRect(titleText);
            _expectRectInside(
              _testViewportRect(tester),
              appBarRect,
              reason:
                  '${locale.languageCode} ${viewport.width}: app bar exceeds viewport',
            );
            _expectRectInside(
              appBarRect,
              titleRect,
              reason:
                  '${locale.languageCode} ${viewport.width}: title exceeds app bar',
            );
            _expectRectInside(
              titleRect,
              titleTextRect,
              reason:
                  '${locale.languageCode} ${viewport.width}: title text exceeds title slot',
            );
            expect(
              titleRect.left,
              greaterThanOrEqualTo(appBarRect.left - _geometryTolerance),
            );
            expect(
              titleRect.left,
              lessThanOrEqualTo(appBarRect.left + 24.0),
              reason:
                  '${locale.languageCode} ${viewport.width}: title lost its leading alignment',
            );
            expect(
              titleTextRect.left,
              closeTo(titleRect.left, _geometryTolerance),
            );

            final actionFinders = [
              find.byTooltip(l10n.shell_settingsTooltip),
              find.byTooltip(l10n.shell_saveTooltip),
              find.byTooltip(l10n.shell_menuTooltip),
            ];
            final actionRects = <Rect>[];
            for (final action in actionFinders) {
              expect(action, findsOneWidget);
              actionRects.add(tester.getRect(action));
            }
            final firstActionLeft = actionRects
                .map((rect) => rect.left)
                .reduce((left, next) => left < next ? left : next);
            expect(
              titleRect.right,
              lessThanOrEqualTo(firstActionLeft + _geometryTolerance),
              reason:
                  '${locale.languageCode} ${viewport.width}: title collides with AppBar actions',
            );
            expect(
              actionRects.every(
                (rect) =>
                    _testViewportRect(tester).contains(rect.topLeft) &&
                    _testViewportRect(tester).contains(rect.bottomRight),
              ),
              isTrue,
              reason:
                  '${locale.languageCode} ${viewport.width}: AppBar action exceeds viewport',
            );
            expect(tester.takeException(), isNull);
            expect(
              frameworkErrors,
              isEmpty,
              reason:
                  '${locale.languageCode} ${viewport.width}: Flutter reported a layout/clipping error',
            );
            frameworkErrors.clear();
          }
        }
      } finally {
        FlutterError.onError = previousErrorHandler;
      }
    },
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required Widget screen,
  required GameSave game,
  Locale locale = const Locale('pl'),
  ClubBrandingRegistry? registry,
  required Size viewport,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = viewport;
  await tester.pumpWidget(
    _app(screen: screen, game: game, locale: locale, registry: registry),
  );
  await tester.pumpAndSettle();
}

Widget _app({
  required Widget screen,
  required GameSave game,
  required Locale locale,
  ClubBrandingRegistry? registry,
}) {
  return ProviderScope(
    key: UniqueKey(),
    overrides: [
      saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
      clubBrandingProvider.overrideWithValue(
        registry ?? ClubBrandingRegistry.production,
      ),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        return controller;
      }),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  );
}

GameSave _withActiveTeam(GameSave game, String teamId, {String? name}) {
  final league = game.leagueState;
  final teams = league.teams
      .map(
        (team) =>
            team.id == teamId ? team.copyWith(name: name ?? team.name) : team,
      )
      .toList(growable: false);
  return game.copyWith(
    leagueState: league.copyWith(playerTeamId: teamId, teams: teams),
  );
}

GameSave _withUnknownActiveTeam(GameSave game, String teamId) {
  final league = game.leagueState;
  final sourceTeam = league.teamById('team_europe_0')!;
  final unknownTeam = sourceTeam.copyWith(
    id: teamId,
    name: 'Unknown Branding FC',
  );
  return game.copyWith(
    leagueState: league.copyWith(
      playerTeamId: teamId,
      teams: [...league.teams, unknownTeam],
    ),
  );
}

GameSave _seasonFixture(GameSave game) {
  final league = game.leagueState;
  return game.copyWith(
    leagueState: league.copyWith(
      currentSeason: league.currentSeason.copyWith(
        year: 2042,
        phase: SeasonPhase.playoff,
      ),
      currentWeek: 17,
      currentDay: 4,
    ),
  );
}

void _expectHomeLogo(
  WidgetTester tester,
  Finder header, {
  required String expectedAsset,
  required String scenario,
}) {
  final logo = find.descendant(of: header, matching: find.byType(ClubLogo));
  final image = find.descendant(of: logo, matching: find.byType(Image));
  expect(logo, findsOneWidget, reason: '$scenario: missing fixed logo slot');
  expect(image, findsOneWidget, reason: '$scenario: missing logo image');

  final logoWidget = tester.widget<ClubLogo>(logo);
  expect(
    logoWidget.assetPath,
    expectedAsset,
    reason: '$scenario: ClubLogo was not resolved by stable ID',
  );
  final imageWidget = tester.widget<Image>(image);
  expect(imageWidget.image, isA<AssetImage>(), reason: scenario);
  expect(
    (imageWidget.image as AssetImage).assetName,
    expectedAsset,
    reason: '$scenario: logo was not resolved by stable ID',
  );
  expect(imageWidget.fit, BoxFit.contain, reason: scenario);
  expect(imageWidget.width, 48.0, reason: scenario);
  expect(imageWidget.height, 48.0, reason: scenario);

  final headerRect = tester.getRect(header);
  final logoRect = tester.getRect(logo);
  final imageRect = tester.getRect(image);
  expect(logoRect.width, closeTo(48.0, _geometryTolerance));
  expect(logoRect.height, closeTo(48.0, _geometryTolerance));
  expect(logoRect.width / logoRect.height, closeTo(1.0, 0.01));
  expect(imageRect.width / imageRect.height, closeTo(1.0, 0.01));
  _expectRectInside(
    _testViewportRect(tester),
    headerRect,
    reason: '$scenario: header exceeds viewport',
  );
  _expectRectInside(
    headerRect,
    logoRect,
    reason: '$scenario: logo exceeds header bounds',
  );
  _expectRectInside(
    logoRect,
    imageRect,
    reason: '$scenario: image exceeds fixed logo slot',
  );
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

int _indexOfNode(List<SemanticsNode> nodes, SemanticsNode target) {
  final index = nodes.indexWhere((node) => identical(node, target));
  expect(index, greaterThanOrEqualTo(0));
  return index;
}

Rect _testViewportRect(WidgetTester tester) {
  final physicalSize = tester.view.physicalSize;
  final devicePixelRatio = tester.view.devicePixelRatio;
  return Offset.zero &
      Size(
        physicalSize.width / devicePixelRatio,
        physicalSize.height / devicePixelRatio,
      );
}

void _expectRectInside(Rect outer, Rect inner, {required String reason}) {
  expect(
    inner.left,
    greaterThanOrEqualTo(outer.left - _geometryTolerance),
    reason: '$reason: left edge overflows',
  );
  expect(
    inner.top,
    greaterThanOrEqualTo(outer.top - _geometryTolerance),
    reason: '$reason: top edge overflows',
  );
  expect(
    inner.right,
    lessThanOrEqualTo(outer.right + _geometryTolerance),
    reason: '$reason: right edge overflows',
  );
  expect(
    inner.bottom,
    lessThanOrEqualTo(outer.bottom + _geometryTolerance),
    reason: '$reason: bottom edge overflows',
  );
}

Future<void> _resetTest(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  tester.view.reset();
}
