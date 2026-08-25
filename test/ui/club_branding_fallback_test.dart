@Tags(['ui'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/branding/club_asset_registry.dart';
import 'package:new_football/app/branding/club_branding_data.dart';
import 'package:new_football/app/branding/club_branding_record.dart';
import 'package:new_football/app/branding/club_branding_registry.dart';
import 'package:new_football/app/branding/club_branding_types.dart';
import 'package:new_football/app/branding/club_color_tokens.dart';
import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/screens/new_game_screen.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widget_harness.dart';

const _fallbackTeamId = 'team_europe_0';
const _missingMappedLogo = 'assets/images/missing-mapped-logo.png';
const _fallbackTeamName = 'Syrenka FC';
const _fallbackCity = 'Warsaw';
const _fallbackConference = 'Europe';

void main() {
  testWidgets(
    'resolves a missing mapped logo, keeps fallback activation equivalent to normal',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        final registry = _registryFor(
          logoAsset: _missingMappedLogo,
          assets: ClubAssetRegistry.production,
        );
        await tester.pumpWidget(_selectionApp(registry));
        await tester.pumpAndSettle();

        final firstTeam = GameFactory().previewTeams().first;
        final firstRow = _teamRowFinder(firstTeam.id);
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        final firstConference = l10n.teamOverview_conferenceEurope;
        final firstLabel = l10n.newGame_teamSemantics(
          firstTeam.name,
          firstTeam.city,
          firstConference,
          l10n.newGame_teamNotSelected,
        );
        final resolution = registry.resolve(firstTeam.id);

        expect(resolution.usedFallbackLogo, isTrue);
        expect(resolution.logoAsset, ClubAssetRegistry.fallbackLogoAssetPath);
        expect(
          resolution.diagnostics,
          contains(
            isA<BrandingDiagnostic>()
                .having(
                  (diagnostic) => diagnostic.teamId,
                  'teamId',
                  firstTeam.id,
                )
                .having(
                  (diagnostic) => diagnostic.kind,
                  'kind',
                  BrandingFailureKind.missingLogoAsset,
                ),
          ),
        );

        final fallbackImage = find.descendant(
          of: firstRow,
          matching: find.byType(Image),
        );
        expect(fallbackImage, findsOneWidget);
        final fallbackImageWidget = tester.widget<Image>(fallbackImage);
        expect(fallbackImageWidget.image, isA<AssetImage>());
        expect(
          (fallbackImageWidget.image as AssetImage).assetName,
          ClubAssetRegistry.fallbackLogoAssetPath,
        );
        expect(
          find.descendant(
            of: firstRow,
            matching: find.byIcon(Icons.broken_image),
          ),
          findsNothing,
        );
        final unselectedNode = _expectTileSemantics(
          tester,
          firstLabel,
          selected: false,
        );

        await tester.tap(firstRow);
        await tester.pump();
        expect(tester.widget<TeamRow>(firstRow).selected, isTrue);
        _expectTileSemantics(
          tester,
          l10n.newGame_teamSemantics(
            firstTeam.name,
            firstTeam.city,
            firstConference,
            l10n.newGame_teamSelected,
          ),
          selected: true,
        );

        final secondTeam = GameFactory().previewTeams()[1];
        final secondRow = _teamRowFinder(secondTeam.id);
        await _showTeamRow(tester, secondTeam.id);
        await tester.tap(secondRow);
        await tester.pump();
        expect(tester.widget<TeamRow>(secondRow).selected, isTrue);
        expect(
          unselectedNode.getSemanticsData().hasAction(ui.SemanticsAction.tap),
          isTrue,
        );
        expect(tester.takeException(), isNull);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'uses a neutral placeholder when mapped and fallback assets are unreadable',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        final damagedAssets = const ClubAssetRegistry(
          logoAssets: <String>{_missingMappedLogo},
          fallbackLogoAsset: ClubAssetRegistry.fallbackLogoAssetPath,
        );
        final registry = _registryFor(
          logoAsset: _missingMappedLogo,
          assets: damagedAssets,
        );
        final bundle = _SelectiveFailureAssetBundle(rootBundle, <String>{
          _missingMappedLogo,
          ClubAssetRegistry.fallbackLogoAssetPath,
        });

        await tester.pumpWidget(
          DefaultAssetBundle(bundle: bundle, child: _selectionApp(registry)),
        );
        await tester.pumpAndSettle();

        final firstTeam = GameFactory().previewTeams().first;
        final firstRow = _teamRowFinder(firstTeam.id);
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        final label = l10n.newGame_teamSemantics(
          firstTeam.name,
          firstTeam.city,
          l10n.teamOverview_conferenceEurope,
          l10n.newGame_teamNotSelected,
        );

        final clubLogo = find.descendant(
          of: firstRow,
          matching: find.byType(ClubLogo),
        );
        expect(clubLogo, findsOneWidget);
        expect(tester.widget<ClubLogo>(clubLogo).assetPath, _missingMappedLogo);
        expect(
          find.descendant(
            of: firstRow,
            matching: find.byIcon(Icons.shield_outlined),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: firstRow, matching: find.byType(Image)),
          findsNothing,
        );
        expect(
          find.descendant(of: firstRow, matching: find.text(firstTeam.name)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: firstRow,
            matching: find.text(
              '${firstTeam.city} · ${l10n.teamOverview_conferenceEurope}',
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: firstRow,
            matching: find.byIcon(Icons.broken_image),
          ),
          findsNothing,
        );

        final node = _expectTileSemantics(tester, label, selected: false);
        _performSemanticsTap(node);
        await tester.pump();
        expect(tester.widget<TeamRow>(firstRow).selected, isTrue);
        expect(
          find.descendant(of: firstRow, matching: find.text(firstTeam.name)),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'keeps role-specific color fallbacks readable and diagnoses the exact Team_ID',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        final cases =
            <
              ({
                String name,
                ClubBrandingRegistry registry,
                Color expectedPrimary,
                Color expectedSecondary,
                BrandingFailureKind diagnosticKind,
                int diagnosticCount,
              })
            >[
              (
                name: 'missing primary',
                registry: _registryFor(primaryColorName: 'missing-primary'),
                expectedPrimary: ColorTokenRegistry.primaryFallback,
                expectedSecondary:
                    ColorTokenRegistry.productionValues['Biały']!,
                diagnosticKind: BrandingFailureKind.invalidColorToken,
                diagnosticCount: 1,
              ),
              (
                name: 'missing secondary',
                registry: _registryFor(secondaryColorName: 'missing-secondary'),
                expectedPrimary:
                    ColorTokenRegistry.productionValues['Czerwony']!,
                expectedSecondary: ColorTokenRegistry.secondaryFallback,
                diagnosticKind: BrandingFailureKind.invalidColorToken,
                diagnosticCount: 1,
              ),
              (
                name: 'missing record',
                registry: _registryWithoutRecord(),
                expectedPrimary: ColorTokenRegistry.primaryFallback,
                expectedSecondary: ColorTokenRegistry.secondaryFallback,
                diagnosticKind: BrandingFailureKind.missingRecord,
                diagnosticCount: 1,
              ),
            ];

        for (final testCase in cases) {
          final resolution = testCase.registry.resolve(_fallbackTeamId);
          expect(
            resolution.primaryColor,
            testCase.expectedPrimary,
            reason: testCase.name,
          );
          expect(
            resolution.secondaryColor,
            testCase.expectedSecondary,
            reason: testCase.name,
          );
          expect(
            resolution.diagnostics,
            hasLength(testCase.diagnosticCount),
            reason: testCase.name,
          );
          expect(
            resolution.diagnostics,
            everyElement(
              isA<BrandingDiagnostic>()
                  .having(
                    (diagnostic) => diagnostic.teamId,
                    'teamId',
                    _fallbackTeamId,
                  )
                  .having(
                    (diagnostic) => diagnostic.kind,
                    'kind',
                    testCase.diagnosticKind,
                  ),
            ),
            reason: testCase.name,
          );
          expect(resolution.isFallback, isTrue, reason: testCase.name);

          final rowKey = ValueKey<String>('color-fallback-${testCase.name}');
          await tester.pumpWidget(
            _teamRowApp(
              resolution,
              key: rowKey,
              semanticsLabel: _standaloneSemanticsLabel,
            ),
          );
          await tester.pumpAndSettle();

          final row = find.byKey(rowKey);
          final card = tester.widget<Card>(
            find.descendant(of: row, matching: find.byType(Card)),
          );
          expect(card.color, testCase.expectedPrimary, reason: testCase.name);
          final secondary = tester.widget<ColoredBox>(
            find.descendant(
              of: find.byKey(
                const ValueKey<String>('team-row-secondary-team_europe_0'),
              ),
              matching: find.byType(ColoredBox),
            ),
          );
          expect(
            secondary.color,
            testCase.expectedSecondary,
            reason: testCase.name,
          );

          final nameText = tester.widget<Text>(
            find.descendant(of: row, matching: find.text(_fallbackTeamName)),
          );
          final foreground = nameText.style?.color;
          expect(foreground, isNotNull, reason: testCase.name);
          expect(
            contrastRatio(foreground!, testCase.expectedPrimary),
            greaterThanOrEqualTo(smallTextContrastThreshold),
            reason: testCase.name,
          );
          expect(
            contrastRatio(
              foregroundFor(testCase.expectedSecondary),
              testCase.expectedSecondary,
            ),
            greaterThanOrEqualTo(smallTextContrastThreshold),
            reason: testCase.name,
          );
          _expectTileSemantics(
            tester,
            _standaloneSemanticsLabel,
            selected: false,
          );
          expect(
            find.descendant(of: row, matching: find.byIcon(Icons.broken_image)),
            findsNothing,
            reason: testCase.name,
          );
          expect(tester.takeException(), isNull, reason: testCase.name);
        }
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'Home follows the same logo fallback hierarchy and never renders a name initial',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        final game = task41Game(seed: 5630);
        final mappedMissingRegistry = _registryFor(
          logoAsset: _missingMappedLogo,
          assets: ClubAssetRegistry.production,
        );
        await tester.pumpWidget(
          _homeApp(game: game, registry: mappedMissingRegistry),
        );
        await tester.pumpAndSettle();

        final header = find.byKey(
          const ValueKey<String>('home-dashboard-header'),
        );
        final fallbackLogo = find.descendant(
          of: header,
          matching: find.byType(ClubLogo),
        );
        expect(fallbackLogo, findsOneWidget);
        expect(
          tester.widget<ClubLogo>(fallbackLogo).assetPath,
          ClubAssetRegistry.fallbackLogoAssetPath,
        );
        final fallbackImage = find.descendant(
          of: fallbackLogo,
          matching: find.byType(Image),
        );
        expect(fallbackImage, findsOneWidget);
        expect(
          (tester.widget<Image>(fallbackImage).image as AssetImage).assetName,
          ClubAssetRegistry.fallbackLogoAssetPath,
        );
        _expectHomeIdentity(
          tester,
          header,
          game.leagueState.teamById(_fallbackTeamId)!.name,
        );
        expect(tester.takeException(), isNull);

        final damagedAssets = const ClubAssetRegistry(
          logoAssets: <String>{_missingMappedLogo},
          fallbackLogoAsset: ClubAssetRegistry.fallbackLogoAssetPath,
        );
        final damagedRegistry = _registryFor(
          logoAsset: _missingMappedLogo,
          assets: damagedAssets,
        );
        final bundle = _SelectiveFailureAssetBundle(rootBundle, <String>{
          _missingMappedLogo,
          ClubAssetRegistry.fallbackLogoAssetPath,
        });
        await tester.pumpWidget(
          DefaultAssetBundle(
            bundle: bundle,
            child: _homeApp(game: game, registry: damagedRegistry),
          ),
        );
        await tester.pumpAndSettle();

        final damagedHeader = find.byKey(
          const ValueKey<String>('home-dashboard-header'),
        );
        final damagedLogo = find.descendant(
          of: damagedHeader,
          matching: find.byType(ClubLogo),
        );
        expect(damagedLogo, findsOneWidget);
        expect(
          find.descendant(
            of: damagedLogo,
            matching: find.byIcon(Icons.shield_outlined),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: damagedLogo, matching: find.byType(Image)),
          findsNothing,
        );
        expect(
          find.descendant(
            of: damagedLogo,
            matching: find.byIcon(Icons.broken_image),
          ),
          findsNothing,
        );
        _expectHomeIdentity(
          tester,
          damagedHeader,
          game.leagueState.teamById(_fallbackTeamId)!.name,
        );
        expect(tester.takeException(), isNull);
      } finally {
        semanticsHandle.dispose();
        tester.view.reset();
      }
    },
  );
}

const _standaloneSemanticsLabel = 'Syrenka FC, Warsaw, Europe, Not selected';

ClubBrandingRegistry _registryFor({
  String logoAsset = 'assets/images/Syrenka_FC.png',
  String primaryColorName = 'Czerwony',
  String secondaryColorName = 'Biały',
  ClubAssetRegistry assets = ClubAssetRegistry.production,
}) {
  final records = ClubBrandingData.productionRecords
      .map((record) {
        if (record.teamId != _fallbackTeamId) return record;
        return ClubBrandingRecord(
          teamId: record.teamId,
          logoAsset: logoAsset,
          primaryColorName: primaryColorName,
          secondaryColorName: secondaryColorName,
        );
      })
      .toList(growable: false);
  return ClubBrandingRegistry(
    records: records,
    assets: assets,
    colors: ColorTokenRegistry.production,
  );
}

ClubBrandingRegistry _registryWithoutRecord() {
  return ClubBrandingRegistry(
    records: ClubBrandingData.productionRecords
        .where((record) => record.teamId != _fallbackTeamId)
        .toList(growable: false),
    assets: ClubAssetRegistry.production,
    colors: ColorTokenRegistry.production,
  );
}

Widget _selectionApp(ClubBrandingRegistry registry) {
  return ProviderScope(
    overrides: [clubBrandingProvider.overrideWithValue(registry)],
    child: const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: NewGameScreen(),
    ),
  );
}

Widget _homeApp({
  required GameSave game,
  required ClubBrandingRegistry registry,
}) {
  return task41App(
    const HomeScreen(),
    game,
    extraOverrides: [clubBrandingProvider.overrideWithValue(registry)],
  );
}

Widget _teamRowApp(
  ClubBrandingResolution resolution, {
  required Key key,
  required String semanticsLabel,
}) {
  return MaterialApp(
    home: Scaffold(
      body: TeamRow(
        key: key,
        teamId: resolution.teamId,
        name: _fallbackTeamName,
        city: _fallbackCity,
        conferenceLabel: _fallbackConference,
        branding: resolution,
        selected: false,
        localizedSemanticsLabel: semanticsLabel,
        onActivate: () {},
      ),
    ),
  );
}

Future<void> _showTeamRow(WidgetTester tester, String teamId) async {
  final row = _teamRowFinder(teamId);
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
  expect(row, findsOneWidget);
  await tester.pumpAndSettle();
}

Finder _teamRowFinder(String teamId) =>
    find.byKey(ValueKey<String>('new-game-team-row-$teamId'));

SemanticsNode _expectTileSemantics(
  WidgetTester tester,
  String label, {
  required bool selected,
}) {
  final finder = find.bySemanticsLabel(label);
  expect(finder, findsOneWidget, reason: 'missing semantics label: $label');
  final node = tester.getSemantics(finder);
  expect(node.label, label);
  expect(node.flagsCollection.isButton, isTrue);
  expect(
    node.flagsCollection.isSelected,
    selected ? ui.Tristate.isTrue : ui.Tristate.isFalse,
  );
  expect(node.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);
  expect(_semanticsSubtree(node), hasLength(1));
  return node;
}

void _performSemanticsTap(SemanticsNode node) {
  final owner = node.owner;
  expect(owner, isNotNull);
  owner!.performAction(node.id, ui.SemanticsAction.tap);
}

void _expectHomeIdentity(WidgetTester tester, Finder header, String teamName) {
  expect(
    find.descendant(of: header, matching: find.text(teamName)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: header, matching: find.text(teamName.substring(0, 1))),
    findsNothing,
  );
  expect(
    find.descendant(of: header, matching: find.byType(CircleAvatar)),
    findsNothing,
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

class _SelectiveFailureAssetBundle extends CachingAssetBundle {
  _SelectiveFailureAssetBundle(this.delegate, this.failedKeys);

  final AssetBundle delegate;
  final Set<String> failedKeys;

  @override
  Future<ByteData> load(String key) {
    if (failedKeys.contains(key)) {
      throw FlutterError('Controlled unreadable asset: $key');
    }
    return delegate.load(key);
  }
}
