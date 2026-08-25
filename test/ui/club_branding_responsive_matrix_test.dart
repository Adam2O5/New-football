@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/branding/club_asset_registry.dart';
import 'package:new_football/app/branding/club_branding_data.dart';
import 'package:new_football/app/branding/club_branding_registry.dart';
import 'package:new_football/app/branding/club_branding_record.dart';
import 'package:new_football/app/branding/club_branding_types.dart';
import 'package:new_football/app/branding/club_color_tokens.dart';
import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widget_harness.dart';
import 'team_selection_menu_test.dart' as selection_test;

const _matrixViewports = <Size>[
  Size(320, 568),
  Size(360, 800),
  Size(390, 844),
  Size(844, 390),
];

const _matrixTextScales = <double>[1.0, 1.3, 2.0];
const _portraitSmall = Size(320, 568);
const _landscapeSmall = Size(844, 390);
const _geometryTolerance = 1.0;
const _seasonYear = 2042;
const _seasonWeek = 17;
const _seasonDay = 4;

void main() {
  test(
    'covers all 30 branding IDs, render tokens, and local fallback data',
    () {
      final registry = ClubBrandingRegistry.production;
      final records = ClubBrandingData.productionRecords;
      final previewTeams = GameFactory().previewTeams();

      expect(records, hasLength(30));
      expect(previewTeams, hasLength(30));
      expect(records.map((record) => record.teamId).toSet(), hasLength(30));
      expect(
        records.map((record) => record.teamId),
        orderedEquals(previewTeams.map((team) => team.id)),
      );
      expect(registry.assets.logoAssets, hasLength(30));
      expect(
        records.map((record) => record.logoAsset).toSet(),
        equals(registry.assets.logoAssets),
      );

      for (var index = 0; index < records.length; index++) {
        final record = records[index];
        final team = previewTeams[index];
        final resolution = registry.resolve(team.id);

        expect(team.id, record.teamId);
        expect(resolution.record, same(record));
        expect(resolution.logoAsset, record.logoAsset);
        expect(
          resolution.primaryColor,
          registry.colors.values[record.primaryColorName],
        );
        expect(
          resolution.secondaryColor,
          registry.colors.values[record.secondaryColorName],
        );
        expect(resolution.usedFallbackLogo, isFalse);
        expect(resolution.usedFallbackPrimaryColor, isFalse);
        expect(resolution.usedFallbackSecondaryColor, isFalse);
        expect(resolution.diagnostics, isEmpty);
      }

      final fallbackTeamId = 'matrix-unknown-team';
      final fallback = registry.resolve(fallbackTeamId);
      expect(fallback.record, isNull);
      expect(fallback.logoAsset, registry.assets.fallbackLogoAsset);
      expect(fallback.primaryColor, registry.colors.primaryFallbackColor);
      expect(fallback.secondaryColor, registry.colors.secondaryFallbackColor);
      expect(fallback.usedFallbackLogo, isTrue);
      expect(fallback.usedFallbackPrimaryColor, isTrue);
      expect(fallback.usedFallbackSecondaryColor, isTrue);
      expect(fallback.diagnostics, hasLength(1));
      expect(fallback.diagnostics.single.teamId, fallbackTeamId);
      expect(
        fallback.diagnostics.single.kind,
        BrandingFailureKind.missingRecord,
      );

      final brokenRegistry = ClubBrandingRegistry(
        records: const [
          ClubBrandingRecord(
            teamId: 'matrix-broken-team',
            logoAsset: 'assets/images/missing.png',
            primaryColorName: 'Missing primary',
            secondaryColorName: '',
          ),
        ],
        assets: const ClubAssetRegistry(
          logoAssets: <String>{},
          fallbackLogoAsset: ClubAssetRegistry.fallbackLogoAssetPath,
        ),
        colors: ColorTokenRegistry(const <String, Color>{}),
      );
      final broken = brokenRegistry.resolve('matrix-broken-team');
      expect(broken.logoAsset, ClubAssetRegistry.fallbackLogoAssetPath);
      expect(broken.primaryColor, ColorTokenRegistry.primaryFallback);
      expect(broken.secondaryColor, ColorTokenRegistry.secondaryFallback);
      expect(broken.usedFallbackLogo, isTrue);
      expect(broken.usedFallbackPrimaryColor, isTrue);
      expect(broken.usedFallbackSecondaryColor, isTrue);
      expect(
        broken.diagnostics.map((diagnostic) => diagnostic.teamId),
        everyElement('matrix-broken-team'),
      );
    },
  );

  testWidgets(
    'keeps the selection screen inside the complete viewport and text matrix',
    (tester) async {
      final previewTeams = GameFactory().previewTeams();

      for (final viewport in _matrixViewports) {
        for (final textScale in _matrixTextScales) {
          for (final locale in _localesFor(viewport)) {
            final harness = selection_test.TeamSelectionHarness(
              locale: locale,
              viewport: viewport,
              textScale: textScale,
            );
            final scenario = _scenario(viewport, textScale, locale);
            try {
              await harness.pump(tester);
              _expectSelectionChrome(tester, scenario: scenario);
              _expectVisibleTiles(tester, scenario: scenario);

              final selectedTeam = previewTeams.first;
              await _activateSelectionTeam(tester, selectedTeam.id);
              final selectedRow = _selectionRowFinder(selectedTeam.id);
              expect(
                tester.widget<TeamRow>(selectedRow).selected,
                isTrue,
                reason: '$scenario: selected Team_ID was not retained',
              );
              _expectVisibleTiles(tester, scenario: '$scenario after select');
              expect(
                tester.takeException(),
                isNull,
                reason: '$scenario: Flutter reported an exception or overflow',
              );
            } finally {
              await harness.dispose(tester);
            }
          }
        }
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  testWidgets(
    'renders every branding tile with its ID mapping and selected state',
    (tester) async {
      final harness = selection_test.TeamSelectionHarness(
        locale: const Locale('en'),
        viewport: const Size(390, 844),
        textScale: 1.0,
      );
      try {
        await harness.pump(tester);
        final previewTeams = harness.gameFactory.previewTeams();
        final registry = ClubBrandingRegistry.production;
        expect(previewTeams, hasLength(30));

        for (final team in previewTeams) {
          await _ensureSelectionTeamVisible(tester, team.id);
          final rowFinder = _selectionRowFinder(team.id);
          final row = tester.widget<TeamRow>(rowFinder);
          final branding = registry.resolve(team.id);
          final logoFinder = find.descendant(
            of: rowFinder,
            matching: find.byType(ClubLogo),
          );
          final imageFinder = find.descendant(
            of: rowFinder,
            matching: find.byType(Image),
          );

          expect(row.branding, isNotNull, reason: team.id);
          expect(row.branding!.teamId, team.id);
          expect(row.branding!.logoAsset, branding.logoAsset);
          expect(row.branding!.primaryColor, branding.primaryColor);
          expect(row.branding!.secondaryColor, branding.secondaryColor);
          expect(row.name, team.name);
          expect(row.city, team.city);
          expect(row.conferenceLabel, isNotEmpty);
          expect(logoFinder, findsOneWidget, reason: team.id);
          expect(imageFinder, findsOneWidget, reason: team.id);

          final logo = tester.widget<ClubLogo>(logoFinder);
          expect(logo.assetPath, branding.logoAsset, reason: team.id);
          expect(logo.size, 48.0, reason: team.id);
          final image = tester.widget<Image>(imageFinder);
          expect(image.image, isA<AssetImage>(), reason: team.id);
          expect(
            (image.image as AssetImage).assetName,
            branding.logoAsset,
            reason: team.id,
          );
          _expectLogoBounds(tester, rowFinder, reason: '${team.id}: logo slot');

          await tester.tap(rowFinder);
          await tester.pump();
          expect(
            tester.widget<TeamRow>(rowFinder).selected,
            isTrue,
            reason: '${team.id}: activation did not select the Team_ID',
          );
          expect(tester.getSize(rowFinder).height, greaterThanOrEqualTo(48.0));
        }

        final fallbackRegistry = ClubBrandingRegistry(
          records: const <ClubBrandingRecord>[],
          assets: ClubAssetRegistry.production,
          colors: ColorTokenRegistry.production,
        );
        final fallback = fallbackRegistry.resolve('matrix-fallback-tile');
        var activated = false;
        var selected = false;
        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) => TeamRow(
                key: const ValueKey<String>('matrix-fallback-tile'),
                teamId: 'matrix-fallback-tile',
                name: 'Fallback Matrix FC',
                city: 'Test City',
                conferenceLabel: 'Test Conference',
                branding: fallback,
                selected: selected,
                localizedSemanticsLabel:
                    'Fallback Matrix FC, Test City, Test Conference, '
                    '${selected ? 'Selected' : 'Not selected'}',
                onActivate: () => setState(() {
                  activated = true;
                  selected = true;
                }),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final fallbackRow = find.byKey(
          const ValueKey<String>('matrix-fallback-tile'),
        );
        expect(fallbackRow, findsOneWidget);
        expect(
          tester.widget<TeamRow>(fallbackRow).branding!.usedFallbackLogo,
          isTrue,
        );
        expect(
          tester
              .widget<ClubLogo>(
                find.descendant(
                  of: fallbackRow,
                  matching: find.byType(ClubLogo),
                ),
              )
              .assetPath,
          ClubAssetRegistry.fallbackLogoAssetPath,
        );
        await tester.tap(fallbackRow);
        await tester.pump();
        expect(activated, isTrue);
        expect(tester.widget<TeamRow>(fallbackRow).selected, isTrue);
        expect(tester.takeException(), isNull);
      } finally {
        await harness.dispose(tester);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  testWidgets(
    'preserves Selected_Club through locale rebuild and portrait resize',
    (tester) async {
      final harness = selection_test.TeamSelectionHarness(
        locale: const Locale('pl'),
        viewport: const Size(390, 844),
        textScale: 1.0,
      );
      try {
        await harness.pump(tester);
        final selectedTeam = harness.gameFactory.previewTeams()[14];
        await _activateSelectionTeam(tester, selectedTeam.id);
        expect(_selectedMountedTeamId(tester), selectedTeam.id);

        await harness.rebuildWithLocale(tester, const Locale('en'));
        await _ensureSelectionTeamVisible(tester, selectedTeam.id);
        expect(_selectedMountedTeamId(tester), selectedTeam.id);
        expect(harness.router.state.uri.path, '/new-game');

        _configureViewport(tester, _landscapeSmall);
        await tester.pumpAndSettle();
        await _ensureSelectionTeamVisible(tester, selectedTeam.id);
        expect(_selectedMountedTeamId(tester), selectedTeam.id);
        expect(harness.router.state.uri.path, '/new-game');
        expect(tester.takeException(), isNull);
      } finally {
        await harness.dispose(tester);
      }
    },
  );

  testWidgets(
    'keeps the Shell title in its title area and clear of action controls',
    (tester) async {
      final game = _withActiveTeam(
        task41Game(seed: 7230),
        'team_europe_2',
        name: 'Marseille International Athletic Association Football Club',
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        tester.view.reset();
      });

      for (final viewport in _matrixViewports) {
        for (final textScale in _matrixTextScales) {
          for (final locale in _localesFor(viewport)) {
            final scenario = _scenario(viewport, textScale, locale);
            await _pumpCareerScreen(
              tester,
              screen: const ShellScreen(),
              game: game,
              locale: locale,
              viewport: viewport,
              textScale: textScale,
            );

            final appBar = find.byType(AppBar);
            final title = find.byKey(
              const ValueKey<String>('shell-team-title'),
            );
            final titleText = find.descendant(
              of: title,
              matching: find.byType(Text),
            );
            expect(appBar, findsOneWidget, reason: scenario);
            expect(title, findsOneWidget, reason: scenario);
            expect(titleText, findsOneWidget, reason: scenario);
            final titleWidget = tester.widget<Text>(titleText);
            expect(titleWidget.maxLines, 1, reason: scenario);
            expect(
              titleWidget.overflow,
              TextOverflow.ellipsis,
              reason: scenario,
            );

            final viewportRect = _testViewportRect(tester);
            final appBarRect = tester.getRect(appBar);
            final titleRect = tester.getRect(title);
            final titleTextRect = tester.getRect(titleText);
            _expectRectInside(viewportRect, appBarRect, reason: scenario);
            _expectRectInside(appBarRect, titleRect, reason: scenario);
            _expectRectInside(titleRect, titleTextRect, reason: scenario);
            expect(
              titleRect.left,
              greaterThanOrEqualTo(appBarRect.left - _geometryTolerance),
              reason: '$scenario: title starts outside AppBar',
            );
            expect(
              titleTextRect.left,
              closeTo(titleRect.left, _geometryTolerance),
              reason: '$scenario: title lost leading alignment',
            );

            final l10n = await AppLocalizations.delegate.load(locale);
            final actionFinders = [
              find.byTooltip(l10n.shell_settingsTooltip),
              find.byTooltip(l10n.shell_saveTooltip),
              find.byTooltip(l10n.shell_menuTooltip),
            ];
            final actionRects = <Rect>[];
            for (final action in actionFinders) {
              expect(action, findsOneWidget, reason: scenario);
              final actionRect = tester.getRect(action);
              _expectRectInside(
                viewportRect,
                actionRect,
                reason: '$scenario: action exceeds viewport',
              );
              actionRects.add(actionRect);
            }
            final firstActionLeft = actionRects
                .map((rect) => rect.left)
                .reduce((left, next) => left < next ? left : next);
            expect(
              titleRect.right,
              lessThanOrEqualTo(firstActionLeft + _geometryTolerance),
              reason: '$scenario: title collides with an AppBar action',
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '$scenario: Shell layout raised an exception/overflow',
            );
          }
        }
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  testWidgets(
    'keeps Home logo, name, and exactly three season lines visible at scale 2',
    (tester) async {
      final game = _seasonFixture(
        _withActiveTeam(task41Game(seed: 7231), 'team_europe_0'),
      );
      final semanticsHandle = tester.ensureSemantics();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        tester.view.reset();
      });

      try {
        for (final viewport in _matrixViewports) {
          for (final locale in _localesFor(viewport)) {
            final scenario = _scenario(viewport, 2.0, locale);
            await _pumpCareerScreen(
              tester,
              screen: const HomeScreen(),
              game: game,
              locale: locale,
              viewport: viewport,
              textScale: 2.0,
            );

            final l10n = await AppLocalizations.delegate.load(locale);
            final header = find.byKey(
              const ValueKey<String>('home-dashboard-header'),
            );
            final logoFinder = find.descendant(
              of: header,
              matching: find.byType(ClubLogo),
            );
            final team = game.leagueState.teamById('team_europe_0')!;
            final teamName = find.descendant(
              of: header,
              matching: find.text(team.name),
            );
            final seasonContext = find.byKey(
              const ValueKey<String>('home-season-context'),
            );
            final lineKeys = const [
              ValueKey<String>('home-season-line'),
              ValueKey<String>('home-phase-line'),
              ValueKey<String>('home-week-day-line'),
            ];
            final expectedLines = [
              l10n.home_seasonLine(_seasonYear),
              l10n.home_phaseLine(l10n.seasonPhase_playoff),
              l10n.home_weekDayLine(_seasonWeek, _seasonDay),
            ];

            expect(header, findsOneWidget, reason: scenario);
            expect(teamName, findsOneWidget, reason: '$scenario: team name');
            expect(logoFinder, findsOneWidget, reason: '$scenario: logo');
            expect(seasonContext, findsOneWidget, reason: scenario);
            expect(lineKeys, hasLength(3), reason: scenario);

            final headerRect = tester.getRect(header);
            final logoRect = tester.getRect(logoFinder);
            final teamNameRect = tester.getRect(teamName);
            final seasonRect = tester.getRect(seasonContext);
            _expectRectInside(
              _testViewportRect(tester),
              headerRect,
              reason: '$scenario: Home header exceeds viewport',
            );
            _expectRectInside(
              headerRect,
              logoRect,
              reason: '$scenario: logo exceeds Home header',
            );
            _expectRectInside(
              headerRect,
              seasonRect,
              reason: '$scenario: season context exceeds Home header',
            );
            _expectRectInside(
              headerRect,
              teamNameRect,
              reason: '$scenario: team name exceeds Home header',
            );
            expect(
              logoRect.width,
              inInclusiveRange(40.0, 56.0),
              reason: '$scenario: logo width outside 40–56',
            );
            expect(
              logoRect.height,
              inInclusiveRange(40.0, 56.0),
              reason: '$scenario: logo height outside 40–56',
            );
            expect(
              teamNameRect.overlaps(logoRect),
              isFalse,
              reason: '$scenario: name overlaps logo',
            );
            expect(
              logoRect.overlaps(seasonRect),
              isFalse,
              reason: '$scenario: logo overlaps season context',
            );

            for (var index = 0; index < lineKeys.length; index++) {
              final line = find.byKey(lineKeys[index]);
              final lineText = find.descendant(
                of: line,
                matching: find.byType(Text),
              );
              expect(
                line,
                findsOneWidget,
                reason: '$scenario: missing line $index',
              );
              expect(
                find.descendant(
                  of: line,
                  matching: find.text(expectedLines[index]),
                ),
                findsOneWidget,
                reason: '$scenario: line $index text was clipped or omitted',
              );
              expect(
                lineText,
                findsOneWidget,
                reason: '$scenario: line $index text',
              );
              _expectRectInside(
                seasonRect,
                tester.getRect(line),
                reason: '$scenario: line $index exceeds season context',
              );
              _expectRectInside(
                tester.getRect(line),
                tester.getRect(lineText),
                reason: '$scenario: line $index text exceeds its slot',
              );
              final semanticLine = find.bySemanticsLabel(expectedLines[index]);
              expect(
                semanticLine,
                findsOneWidget,
                reason:
                    '$scenario: line $index was merged or lost from semantics',
              );
              expect(
                tester.getSemantics(semanticLine).label,
                expectedLines[index],
              );
              if (index > 0) {
                final previousLine = tester.getRect(
                  find.byKey(lineKeys[index - 1]),
                );
                expect(
                  tester.getRect(line).overlaps(previousLine),
                  isFalse,
                  reason: '$scenario: season lines overlap or merge',
                );
              }
            }

            expect(
              find.bySemanticsLabel(ClubAssetRegistry.fallbackLogoAssetPath),
              findsNothing,
              reason: '$scenario: decorative logo exposed an asset label',
            );
            expect(
              tester.widget<ClubLogo>(logoFinder).assetPath,
              ClubAssetRegistry.fallbackLogoAssetPath,
              reason: '$scenario: Home logo was not resolved by Team_ID',
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '$scenario: Home layout raised an exception/overflow',
            );
          }
        }
      } finally {
        semanticsHandle.dispose();
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

List<Locale> _localesFor(Size viewport) {
  final isExtreme = viewport == _portraitSmall || viewport == _landscapeSmall;
  return isExtreme ? const [Locale('pl'), Locale('en')] : const [Locale('pl')];
}

String _scenario(Size viewport, double textScale, Locale locale) =>
    '${viewport.width.toInt()}x${viewport.height.toInt()} '
    'scale $textScale ${locale.languageCode}';

Future<void> _activateSelectionTeam(WidgetTester tester, String teamId) async {
  await _ensureSelectionTeamVisible(tester, teamId);
  await tester.tap(_selectionRowFinder(teamId));
  await tester.pump();
}

Future<void> _ensureSelectionTeamVisible(
  WidgetTester tester,
  String teamId,
) async {
  final row = _selectionRowFinder(teamId);
  final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
  final scrollable = find.descendant(
    of: teamList,
    matching: find.byType(Scrollable),
  );
  if (row.evaluate().isEmpty) {
    final scrollableState = tester.state<ScrollableState>(scrollable);
    final listHeight = tester.getRect(teamList).height;
    final scrollStep = listHeight > 1.0 ? listHeight / 2 : 1.0;
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
  }
  expect(row, findsOneWidget, reason: 'team $teamId was not mounted');
  // A lazy ListView can keep a row mounted while the fixed start action
  // obscures its center. Centering the row makes activation deterministic.
  await Scrollable.ensureVisible(tester.element(row), alignment: 0.5);
  await tester.pumpAndSettle();
  expect(row, findsOneWidget, reason: 'team $teamId was not mounted');
}

Finder _selectionRowFinder(String teamId) =>
    find.byKey(ValueKey<String>('new-game-team-row-$teamId'));

String _selectedMountedTeamId(WidgetTester tester) {
  final selectedRows = tester
      .widgetList<TeamRow>(find.byType(TeamRow))
      .where((row) => row.selected)
      .toList(growable: false);
  expect(selectedRows, hasLength(1));
  return selectedRows.single.teamId;
}

void _expectSelectionChrome(WidgetTester tester, {required String scenario}) {
  final viewport = _testViewportRect(tester);
  final appBar = find.byType(AppBar);
  final list = find.byKey(const ValueKey<String>('new-game-team-list'));
  final fixedAction = find.byKey(
    const ValueKey<String>('new-game-fixed-action'),
  );
  final startButton = find.byKey(
    const ValueKey<String>('new-game-start-button'),
  );
  expect(appBar, findsOneWidget, reason: '$scenario: AppBar');
  expect(list, findsOneWidget, reason: '$scenario: team list');
  expect(fixedAction, findsOneWidget, reason: '$scenario: fixed action');
  expect(startButton, findsOneWidget, reason: '$scenario: start action');

  final appBarRect = tester.getRect(appBar);
  final listRect = tester.getRect(list);
  final fixedActionRect = tester.getRect(fixedAction);
  final startRect = tester.getRect(startButton);
  _expectRectInside(viewport, appBarRect, reason: '$scenario: AppBar');
  _expectRectInside(viewport, listRect, reason: '$scenario: team list');
  _expectRectInside(
    viewport,
    fixedActionRect,
    reason: '$scenario: fixed action',
  );
  _expectRectInside(viewport, startRect, reason: '$scenario: start action');
  _expectRectInside(
    fixedActionRect,
    startRect,
    reason: '$scenario: start action slot',
  );
  expect(
    listRect.overlaps(fixedActionRect),
    isFalse,
    reason: '$scenario: list overlaps start action',
  );
  expect(
    listRect.bottom,
    lessThanOrEqualTo(fixedActionRect.top - 8.0 + _geometryTolerance),
    reason: '$scenario: list/start gap is too small',
  );
  expect(startRect.width, greaterThanOrEqualTo(48.0));
  expect(startRect.height, greaterThanOrEqualTo(48.0));
}

void _expectVisibleTiles(WidgetTester tester, {required String scenario}) {
  final viewport = _testViewportRect(tester);
  final list = find.byKey(const ValueKey<String>('new-game-team-list'));
  final listRect = tester.getRect(list);
  final rows = find.descendant(of: list, matching: find.byType(TeamRow));
  expect(rows, findsWidgets, reason: '$scenario: no tile is mounted');
  final rowRects = <Rect>[];

  for (final row in tester.widgetList<TeamRow>(rows)) {
    final rowFinder = find.byKey(row.key!);
    final rowRect = tester.getRect(rowFinder);
    rowRects.add(rowRect);
    expect(rowRect.width, greaterThanOrEqualTo(48.0), reason: scenario);
    expect(rowRect.height, greaterThanOrEqualTo(48.0), reason: scenario);
    expect(
      rowRect.left,
      greaterThanOrEqualTo(viewport.left - _geometryTolerance),
      reason: '$scenario: tile left edge overflows',
    );
    expect(
      rowRect.right,
      lessThanOrEqualTo(viewport.right + _geometryTolerance),
      reason: '$scenario: tile right edge overflows',
    );
    expect(
      rowRect.left,
      greaterThanOrEqualTo(listRect.left - _geometryTolerance),
      reason: '$scenario: tile leaves list bounds horizontally',
    );
    expect(
      rowRect.right,
      lessThanOrEqualTo(listRect.right + _geometryTolerance),
      reason: '$scenario: tile leaves list bounds horizontally',
    );
    _expectLogoBounds(tester, rowFinder, reason: scenario);
  }

  for (var first = 0; first < rowRects.length; first++) {
    for (var second = first + 1; second < rowRects.length; second++) {
      expect(
        rowRects[first].overlaps(rowRects[second]),
        isFalse,
        reason: '$scenario: mounted tiles overlap',
      );
    }
  }
}

void _expectLogoBounds(
  WidgetTester tester,
  Finder rowFinder, {
  required String reason,
}) {
  final rowRect = tester.getRect(rowFinder);
  final logoFinder = find.descendant(
    of: rowFinder,
    matching: find.byType(ClubLogo),
  );
  final imageFinder = find.descendant(
    of: rowFinder,
    matching: find.byType(Image),
  );
  expect(logoFinder, findsOneWidget, reason: '$reason: missing ClubLogo');
  expect(imageFinder, findsOneWidget, reason: '$reason: missing Image');
  final logoRect = tester.getRect(logoFinder);
  final imageRect = tester.getRect(imageFinder);
  expect(logoRect.width, inInclusiveRange(40.0, 56.0), reason: reason);
  expect(logoRect.height, inInclusiveRange(40.0, 56.0), reason: reason);
  expect(imageRect.width, inInclusiveRange(40.0, 56.0), reason: reason);
  expect(imageRect.height, inInclusiveRange(40.0, 56.0), reason: reason);
  expect(logoRect.width, closeTo(logoRect.height, _geometryTolerance));
  _expectRectInside(rowRect, logoRect, reason: '$reason: logo slot');
  _expectRectInside(logoRect, imageRect, reason: '$reason: image');
}

Future<void> _pumpCareerScreen(
  WidgetTester tester, {
  required Widget screen,
  required GameSave game,
  required Locale locale,
  required Size viewport,
  required double textScale,
}) async {
  _configureViewport(tester, viewport);
  await tester.pumpWidget(
    _careerApp(
      screen: screen,
      game: game,
      locale: locale,
      textScale: textScale,
    ),
  );
  await tester.pumpAndSettle();
}

Widget _careerApp({
  required Widget screen,
  required GameSave game,
  required Locale locale,
  required double textScale,
}) {
  return ProviderScope(
    key: UniqueKey(),
    overrides: [
      saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
      clubBrandingProvider.overrideWithValue(ClubBrandingRegistry.production),
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
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
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

GameSave _seasonFixture(GameSave game) {
  final league = game.leagueState;
  return game.copyWith(
    leagueState: league.copyWith(
      currentSeason: league.currentSeason.copyWith(
        year: _seasonYear,
        phase: SeasonPhase.playoff,
      ),
      currentWeek: _seasonWeek,
      currentDay: _seasonDay,
    ),
  );
}

void _configureViewport(WidgetTester tester, Size viewport) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = viewport;
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
