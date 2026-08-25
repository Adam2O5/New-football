@Tags(['property'])
library;

// Feature: club-branding, Property 2: Registry validation identifies every missing and duplicate ID

import 'dart:convert';
import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect;
import 'package:new_football/app/branding/club_asset_registry.dart';
import 'package:new_football/app/formatters/season_context_lines.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/app/branding/club_branding_data.dart';
import 'package:new_football/app/branding/club_branding_record.dart';
import 'package:new_football/app/branding/club_branding_registry.dart';
import 'package:new_football/app/branding/club_branding_types.dart';
import 'package:new_football/app/branding/club_color_tokens.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:new_football/l10n/generated/app_localizations_en.dart';
import 'package:new_football/l10n/generated/app_localizations_pl.dart';

const _propertyRuns = 120;

final Generator<_RegistryFixture> _registryFixtureGenerator = any
    .simple<_RegistryFixture>(
      generate: (random, size) {
        final mutation = _FixtureMutation.values[size % 3];
        final affectedIndex = random.nextInt(_expectedTeamIds.length);
        return _fixtureFor(mutation, affectedIndex);
      },
      shrink: (fixture) sync* {
        if (!fixture.isComplete) yield _completeFixture();
      },
    );

void main() {
  // Feature: club-branding, Property 1: Branding is immutable with respect to presentation fields
  // **Validates: Requirements 1.2, 1.3, 1.4, 5.7, 6.7**
  Glados<_PresentationFixture>(
    _presentationFixtureGenerator,
    ExploreConfig(
      numRuns: _presentationPropertyRuns,
      initialSize: 1,
      speed: 1,
      random: Random(0x1D01A5),
    ),
  ).test(
    'resolves branding by Team_ID regardless of presentation fields across '
    '$_presentationPropertyRuns generated preview entries',
    (fixture) {
      final registry = ClubBrandingRegistry.production;
      final resolution = registry.resolve(fixture.teamId);
      final expected = registry.resolve(fixture.teamId);

      _expectEquivalentResolution(resolution, expected);
      expect(resolution.teamId, fixture.teamId);
      expect(resolution.record, isNotNull);
      expect(resolution.record!.teamId, fixture.teamId);
      expect(
        resolution.record!.logoAsset,
        isNot(contains(fixture.presentationLogoStem)),
        reason:
            '${fixture.description}: presentation filename stem must not be a lookup key',
      );
      expect(fixture.name, isNotEmpty);
      expect(fixture.city, isNotEmpty);
      expect(fixture.conference, isA<Conference>());
    },
  );

  // Feature: club-branding, Property 3: Branding resolution does not mutate domain data
  // **Validates: Requirements 1.5**
  Glados<Team>(
    _domainTeamGenerator,
    ExploreConfig(
      numRuns: _domainPropertyRuns,
      initialSize: 1,
      speed: 1,
      random: Random(0xD0A11),
    ),
  ).test(
    'resolving branding leaves Team serialization unchanged across '
    '$_domainPropertyRuns generated teams',
    (team) {
      final before = jsonEncode(team.toJson());
      final resolution = ClubBrandingRegistry.production.resolve(team.id);
      final after = jsonEncode(team.toJson());

      expect(after, equals(before));
      expect(team.toJson(), isNot(contains('branding')));
      expect(resolution.teamId, team.id);
    },
  );

  // Feature: club-branding, Property 2: Registry validation identifies every missing and duplicate ID
  Glados<_RegistryFixture>(
    _registryFixtureGenerator,
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 1,
      speed: 1,
      random: Random(0x2A05),
    ),
  ).test('registry validation identifies every missing and duplicate ID across '
      '$_propertyRuns in-memory fixtures', (fixture) {
    final registry = ClubBrandingRegistry(
      records: fixture.records,
      assets: ClubAssetRegistry.production,
      colors: ColorTokenRegistry.production,
    );
    final actualFailures = registry.validate();
    final expectedSignatures = _failureSignatures(fixture.expectedFailures);
    final actualSignatures = _failureSignatures(actualFailures);

    expect(
      actualSignatures,
      unorderedEquals(expectedSignatures),
      reason: fixture.description,
    );

    if (fixture.isComplete) {
      expect(
        actualFailures.where(
          (failure) => failure.kind == RegistryValidationKind.absent,
        ),
        isEmpty,
        reason: '${fixture.description}: complete registry reported absent',
      );
      expect(
        actualFailures.where(
          (failure) => failure.kind == RegistryValidationKind.duplicated,
        ),
        isEmpty,
        reason: '${fixture.description}: complete registry reported duplicated',
      );
    } else {
      final affectedFailures = actualFailures
          .where((failure) => failure.teamId == fixture.affectedTeamId)
          .toList(growable: false);
      expect(affectedFailures, hasLength(1), reason: fixture.description);
      expect(
        affectedFailures.single.kind,
        fixture.expectedFailures.single.kind,
        reason: fixture.description,
      );
    }
  });

  // Feature: club-branding, Property 4: Selected foreground meets the requested contrast threshold
  // **Validates: Requirements 3.7, 3.8, 5.3**
  Glados<_ContrastFixture>(
    _contrastFixtureGenerator,
    ExploreConfig(
      numRuns: _contrastPropertyRuns,
      initialSize: 1,
      speed: 1,
      random: Random(0xC047),
    ),
  ).test('selected foreground meets the requested contrast threshold across '
      '$_contrastPropertyRuns generated renderable colours', (fixture) {
    final foreground = foregroundFor(
      fixture.surface,
      minimumRatio: fixture.threshold,
    );
    final actualContrast = contrastRatio(foreground, fixture.surface);

    expect(
      actualContrast,
      greaterThanOrEqualTo(fixture.threshold),
      reason:
          '${fixture.description}: foreground=$foreground contrast=$actualContrast',
    );
  });

  // Feature: club-branding, Property 5: Season context always formats three ordered localized lines
  // **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.7, 7.8, 7.9**
  Glados<_SeasonContextFixture>(
    _seasonContextFixtureGenerator,
    ExploreConfig(
      numRuns: _seasonContextPropertyRuns,
      initialSize: 1,
      speed: 1,
      random: Random(0x5EA50),
    ),
  ).test('season context always formats three ordered localized lines across '
      '$_seasonContextPropertyRuns generated fixtures', (fixture) {
    final lines = _seasonContextLinesFor(fixture, fixture.locale);
    _expectSeasonContextLines(lines, fixture, fixture.locale);

    final alternateLocale = fixture.locale == 'pl' ? 'en' : 'pl';
    final alternateLines = _seasonContextLinesFor(fixture, alternateLocale);
    _expectSeasonContextLines(alternateLines, fixture, alternateLocale);

    expect(lines.seasonLine, isNot(equals(alternateLines.seasonLine)));
    expect(lines.phaseLine, isNot(equals(alternateLines.phaseLine)));
    expect(lines.weekDayLine, isNot(equals(alternateLines.weekDayLine)));
  });

  // Feature: club-branding, Property 6: Unknown or damaged branding always resolves to complete fallback data
  // **Validates: Requirements 2.4, 5.1, 5.2, 5.3, 5.4, 5.5, 5.7**
  Glados<_FallbackFixture>(
    _fallbackFixtureGenerator,
    ExploreConfig(
      numRuns: _fallbackPropertyRuns,
      initialSize: 1,
      speed: 1,
      random: Random(0xFA11BAC),
    ),
  ).test(
    'unknown or damaged branding always resolves to complete fallback data '
    'across $_fallbackPropertyRuns in-memory fixtures',
    (fixture) {
      final registry = ClubBrandingRegistry(
        records: fixture.records,
        assets: fixture.assets,
        colors: fixture.colors,
      );

      late ClubBrandingResolution resolution;
      expect(
        () => resolution = registry.resolve(fixture.teamId),
        returnsNormally,
        reason: fixture.description,
      );

      expect(
        resolution.logoAsset,
        equals(fixture.expectedLogoAsset),
        reason: fixture.description,
      );
      expect(
        resolution.logoAsset.trim(),
        isNotEmpty,
        reason: '${fixture.description}: resolved logo path',
      );
      expect(
        resolution.primaryColor,
        equals(fixture.expectedPrimaryColor),
        reason: fixture.description,
      );
      expect(
        resolution.secondaryColor,
        equals(fixture.expectedSecondaryColor),
        reason: fixture.description,
      );
      expect(
        resolution.primaryColor.a,
        greaterThan(0.0),
        reason: '${fixture.description}: primary color is renderable',
      );
      expect(
        resolution.secondaryColor.a,
        greaterThan(0.0),
        reason: '${fixture.description}: secondary color is renderable',
      );

      expect(
        resolution.usedFallbackLogo,
        fixture.expectedFallbackLogo,
        reason: fixture.description,
      );
      expect(
        resolution.usedFallbackPrimaryColor,
        fixture.expectedFallbackPrimaryColor,
        reason: fixture.description,
      );
      expect(
        resolution.usedFallbackSecondaryColor,
        fixture.expectedFallbackSecondaryColor,
        reason: fixture.description,
      );
      expect(
        resolution.isFallback,
        isTrue,
        reason:
            '${fixture.description}: damaged or unknown input must fall back',
      );

      expect(
        resolution.diagnostics,
        hasLength(fixture.expectedDiagnosticCount),
        reason: fixture.description,
      );
      expect(
        resolution.diagnostics,
        everyElement(
          isA<BrandingDiagnostic>().having(
            (diagnostic) => diagnostic.teamId,
            'teamId',
            equals(fixture.teamId),
          ),
        ),
        reason: '${fixture.description}: diagnostics retain the exact Team_ID',
      );
    },
  );
}

const _fallbackPropertyRuns = 120;
const _memoryLogoAsset = 'memory/logo.png';
const _memoryFallbackLogoAsset = 'memory/fallback-logo.png';
const _memoryUnreadableLogoAsset = 'memory/unreadable-logo.png';
const _memoryPrimaryToken = 'memory-primary';
const _memorySecondaryToken = 'memory-secondary';
const _memoryPrimaryColor = Color(0xFF123456);
const _memorySecondaryColor = Color(0xFF654321);

const _memoryAssets = ClubAssetRegistry(
  logoAssets: <String>{_memoryLogoAsset, _memoryFallbackLogoAsset},
  fallbackLogoAsset: _memoryFallbackLogoAsset,
);

final _memoryColors = ColorTokenRegistry(<String, Color>{
  _memoryPrimaryToken: _memoryPrimaryColor,
  _memorySecondaryToken: _memorySecondaryColor,
});

enum _LogoFixtureState { valid, missing, unreadable }

enum _TokenFixtureState { valid, missing, invalid }

final Generator<_FallbackFixture> _fallbackFixtureGenerator = any
    .simple<_FallbackFixture>(
      generate: (random, size) {
        final teamId = 'property-fallback-$size-${random.nextInt(1_000_000)}';
        final scenario = size % 27;
        if (scenario == 0) {
          return _FallbackFixture.unknown(teamId);
        }

        // Values 1..26 cover every damaged combination while excluding the
        // all-valid case, which is outside this fallback property.
        final logoState = _LogoFixtureState.values[scenario ~/ 9];
        final tokenStates = scenario % 9;
        final primaryState = _TokenFixtureState.values[tokenStates ~/ 3];
        final secondaryState = _TokenFixtureState.values[tokenStates % 3];
        return _FallbackFixture.known(
          teamId: teamId,
          logoState: logoState,
          primaryState: primaryState,
          secondaryState: secondaryState,
        );
      },
      shrink: (_) sync* {},
    );

class _FallbackFixture {
  _FallbackFixture({
    required this.teamId,
    required List<ClubBrandingRecord> records,
    required this.assets,
    required this.colors,
    required this.expectedLogoAsset,
    required this.expectedPrimaryColor,
    required this.expectedSecondaryColor,
    required this.expectedFallbackLogo,
    required this.expectedFallbackPrimaryColor,
    required this.expectedFallbackSecondaryColor,
    required this.expectedDiagnosticCount,
    required this.scenario,
  }) : records = List<ClubBrandingRecord>.unmodifiable(records);

  factory _FallbackFixture.unknown(String teamId) => _FallbackFixture(
    teamId: teamId,
    records: <ClubBrandingRecord>[
      ClubBrandingRecord(
        teamId: '$teamId-unrelated',
        logoAsset: _memoryLogoAsset,
        primaryColorName: _memoryPrimaryToken,
        secondaryColorName: _memorySecondaryToken,
      ),
    ],
    assets: _memoryAssets,
    colors: _memoryColors,
    expectedLogoAsset: _memoryFallbackLogoAsset,
    expectedPrimaryColor: ColorTokenRegistry.primaryFallback,
    expectedSecondaryColor: ColorTokenRegistry.secondaryFallback,
    expectedFallbackLogo: true,
    expectedFallbackPrimaryColor: true,
    expectedFallbackSecondaryColor: true,
    expectedDiagnosticCount: 1,
    scenario: 'unknown record',
  );

  factory _FallbackFixture.known({
    required String teamId,
    required _LogoFixtureState logoState,
    required _TokenFixtureState primaryState,
    required _TokenFixtureState secondaryState,
  }) {
    final logoAsset = switch (logoState) {
      _LogoFixtureState.valid => _memoryLogoAsset,
      _LogoFixtureState.missing => '',
      _LogoFixtureState.unreadable => _memoryUnreadableLogoAsset,
    };
    final primaryToken = switch (primaryState) {
      _TokenFixtureState.valid => _memoryPrimaryToken,
      _TokenFixtureState.missing => '',
      _TokenFixtureState.invalid => 'memory-invalid-primary',
    };
    final secondaryToken = switch (secondaryState) {
      _TokenFixtureState.valid => _memorySecondaryToken,
      _TokenFixtureState.missing => '',
      _TokenFixtureState.invalid => 'memory-invalid-secondary',
    };
    final expectedFallbackLogo = logoState != _LogoFixtureState.valid;
    final expectedFallbackPrimaryColor =
        primaryState != _TokenFixtureState.valid;
    final expectedFallbackSecondaryColor =
        secondaryState != _TokenFixtureState.valid;

    return _FallbackFixture(
      teamId: teamId,
      records: <ClubBrandingRecord>[
        ClubBrandingRecord(
          teamId: teamId,
          logoAsset: logoAsset,
          primaryColorName: primaryToken,
          secondaryColorName: secondaryToken,
        ),
      ],
      assets: _memoryAssets,
      colors: _memoryColors,
      expectedLogoAsset: expectedFallbackLogo
          ? _memoryFallbackLogoAsset
          : _memoryLogoAsset,
      expectedPrimaryColor: expectedFallbackPrimaryColor
          ? ColorTokenRegistry.primaryFallback
          : _memoryPrimaryColor,
      expectedSecondaryColor: expectedFallbackSecondaryColor
          ? ColorTokenRegistry.secondaryFallback
          : _memorySecondaryColor,
      expectedFallbackLogo: expectedFallbackLogo,
      expectedFallbackPrimaryColor: expectedFallbackPrimaryColor,
      expectedFallbackSecondaryColor: expectedFallbackSecondaryColor,
      expectedDiagnosticCount:
          (expectedFallbackLogo ? 1 : 0) +
          (expectedFallbackPrimaryColor ? 1 : 0) +
          (expectedFallbackSecondaryColor ? 1 : 0),
      scenario:
          'logo=${logoState.name} primary=${primaryState.name} '
          'secondary=${secondaryState.name}',
    );
  }

  final String teamId;
  final List<ClubBrandingRecord> records;
  final ClubAssetRegistry assets;
  final ColorTokenRegistry colors;
  final String expectedLogoAsset;
  final Color expectedPrimaryColor;
  final Color expectedSecondaryColor;
  final bool expectedFallbackLogo;
  final bool expectedFallbackPrimaryColor;
  final bool expectedFallbackSecondaryColor;
  final int expectedDiagnosticCount;
  final String scenario;

  String get description => 'teamId=$teamId scenario=$scenario';
}

enum _FixtureMutation { complete, absent, duplicated }

const _contrastPropertyRuns = 120;

final _productionContrastSurfaces = List<Color>.unmodifiable(
  ColorTokenRegistry.production.values.values,
);

const _helperContrastSurfaces = <Color>[
  ColorTokenRegistry.primaryFallback,
  ColorTokenRegistry.secondaryFallback,
  Color(0xFF000000),
  Color(0xFF808080),
];

final Generator<_ContrastFixture> _contrastFixtureGenerator = any
    .simple<_ContrastFixture>(
      generate: (random, size) {
        final fixedSurfaceCount =
            _productionContrastSurfaces.length + _helperContrastSurfaces.length;
        final surfaceIndex = size % (fixedSurfaceCount + 1);
        final surface = surfaceIndex == fixedSurfaceCount
            ? _randomOpaqueColor(random)
            : surfaceIndex < _productionContrastSurfaces.length
            ? _productionContrastSurfaces[surfaceIndex]
            : _helperContrastSurfaces[surfaceIndex -
                  _productionContrastSurfaces.length];
        final threshold = size.isEven
            ? smallTextContrastThreshold
            : largeTextContrastThreshold;
        return _ContrastFixture(surface: surface, threshold: threshold);
      },
      shrink: (fixture) sync* {
        if (fixture.threshold != largeTextContrastThreshold) {
          yield _ContrastFixture(
            surface: fixture.surface,
            threshold: largeTextContrastThreshold,
          );
        }
      },
    );

class _ContrastFixture {
  const _ContrastFixture({required this.surface, required this.threshold});

  final Color surface;
  final double threshold;

  String get description =>
      'surface=$surface threshold=${threshold.toStringAsFixed(1)}';
}

Color _randomOpaqueColor(Random random) => Color.fromARGB(
  0xFF,
  random.nextInt(0x100),
  random.nextInt(0x100),
  random.nextInt(0x100),
);

const _presentationPropertyRuns = 120;
const _domainPropertyRuns = 120;

final Generator<_PresentationFixture> _presentationFixtureGenerator = any
    .simple<_PresentationFixture>(
      generate: (random, size) {
        final teamId = _expectedTeamIds[size % _expectedTeamIds.length];
        return _PresentationFixture(
          teamId: teamId,
          name: 'Synthetic presentation name ${random.nextInt(1_000_000)}',
          city: 'Synthetic presentation city ${random.nextInt(1_000_000)}',
          conference: Conference.values[
            random.nextInt(Conference.values.length)
          ],
          presentationLogoStem: 'synthetic-logo-stem-$size',
        );
      },
      shrink: (_) sync* {},
    );

final Generator<Team> _domainTeamGenerator = any
    .simple<Team>(
      generate: (random, size) => Team(
        id: _expectedTeamIds[size % _expectedTeamIds.length],
        name: 'Synthetic Team ${random.nextInt(1_000_000)}',
        city: 'Synthetic City ${random.nextInt(1_000_000)}',
        conference: Conference.values[
          random.nextInt(Conference.values.length)
        ],
        roster: const [],
        finance: const TeamFinance(),
      ),
      shrink: (_) sync* {},
    );

class _PresentationFixture {
  const _PresentationFixture({
    required this.teamId,
    required this.name,
    required this.city,
    required this.conference,
    required this.presentationLogoStem,
  });

  final String teamId;
  final String name;
  final String city;
  final Conference conference;
  final String presentationLogoStem;

  String get description =>
      'teamId=$teamId name=$name city=$city conference=${conference.name}';
}

void _expectEquivalentResolution(
  ClubBrandingResolution actual,
  ClubBrandingResolution expected,
) {
  expect(actual.teamId, expected.teamId);
  expect(actual.logoAsset, expected.logoAsset);
  expect(actual.primaryColor, expected.primaryColor);
  expect(actual.secondaryColor, expected.secondaryColor);
  expect(actual.usedFallbackLogo, expected.usedFallbackLogo);
  expect(actual.usedFallbackPrimaryColor, expected.usedFallbackPrimaryColor);
  expect(actual.usedFallbackSecondaryColor, expected.usedFallbackSecondaryColor);
  expect(actual.record?.teamId, expected.record?.teamId);
  expect(actual.record?.logoAsset, expected.record?.logoAsset);
  expect(actual.record?.primaryColorName, expected.record?.primaryColorName);
  expect(actual.record?.secondaryColorName, expected.record?.secondaryColorName);
  expect(actual.diagnostics.length, expected.diagnostics.length);
  for (var index = 0; index < actual.diagnostics.length; index++) {
    expect(actual.diagnostics[index].teamId, expected.diagnostics[index].teamId);
    expect(actual.diagnostics[index].kind, expected.diagnostics[index].kind);
    expect(actual.diagnostics[index].message, expected.diagnostics[index].message);
  }
}

class _RegistryFixture {
  _RegistryFixture({
    required List<ClubBrandingRecord> records,
    required List<BrandingValidationFailure> expectedFailures,
    required this.mutation,
    required this.affectedTeamId,
  }) : records = List<ClubBrandingRecord>.unmodifiable(records),
       expectedFailures = List<BrandingValidationFailure>.unmodifiable(
         expectedFailures,
       );

  final List<ClubBrandingRecord> records;
  final List<BrandingValidationFailure> expectedFailures;
  final _FixtureMutation mutation;
  final String? affectedTeamId;

  bool get isComplete => mutation == _FixtureMutation.complete;

  String get description =>
      'mutation=${mutation.name} affected=${affectedTeamId ?? 'none'} '
      'ids=${records.map((record) => record.teamId).join(',')}';
}

_RegistryFixture _completeFixture() =>
    _fixtureFor(_FixtureMutation.complete, 0);

_RegistryFixture _fixtureFor(_FixtureMutation mutation, int affectedIndex) {
  final records = _completeRecords();
  if (mutation == _FixtureMutation.complete) {
    return _RegistryFixture(
      records: records,
      expectedFailures: const <BrandingValidationFailure>[],
      mutation: mutation,
      affectedTeamId: null,
    );
  }

  final affectedTeamId = _expectedTeamIds[affectedIndex];
  final targetIndex = records.indexWhere(
    (record) => record.teamId == affectedTeamId,
  );
  if (targetIndex < 0) {
    throw StateError('Expected fixture ID is missing: $affectedTeamId');
  }
  final failureKind = mutation == _FixtureMutation.absent
      ? RegistryValidationKind.absent
      : RegistryValidationKind.duplicated;

  if (mutation == _FixtureMutation.absent) {
    records.removeAt(targetIndex);
  } else {
    records.insert(targetIndex + 1, records[targetIndex]);
  }

  return _RegistryFixture(
    records: records,
    expectedFailures: [
      BrandingValidationFailure(teamId: affectedTeamId, kind: failureKind),
    ],
    mutation: mutation,
    affectedTeamId: affectedTeamId,
  );
}

List<ClubBrandingRecord> _completeRecords() =>
    List<ClubBrandingRecord>.of(ClubBrandingData.productionRecords);

List<String> _failureSignatures(Iterable<BrandingValidationFailure> failures) =>
    failures
        .map((failure) => '${failure.teamId}|${failure.kind.name}')
        .toList(growable: false);

final _expectedTeamIds = List<String>.unmodifiable(
  ClubBrandingData.expectedTeamIds,
);

const _seasonContextPropertyRuns = 120;

final Generator<_SeasonContextFixture> _seasonContextFixtureGenerator = any
    .simple<_SeasonContextFixture>(
      generate: (random, size) {
        final year = 1900 + random.nextInt(201);
        final phase = SeasonPhase.values[size % SeasonPhase.values.length];
        final week = 1 + random.nextInt(52);
        final day = 1 + random.nextInt(7);
        return _SeasonContextFixture(
          league: LeagueState(
            teams: const [],
            currentSeason: Season(year: year, phase: phase),
            currentWeek: week,
            currentDay: day,
          ),
          locale: size.isEven ? 'pl' : 'en',
        );
      },
      shrink: (fixture) sync* {
        final league = fixture.league;
        if (league.currentSeason.year != 2000 ||
            league.currentWeek != 1 ||
            league.currentDay != 1) {
          yield _SeasonContextFixture(
            league: league.copyWith(
              currentSeason: league.currentSeason.copyWith(year: 2000),
              currentWeek: 1,
              currentDay: 1,
            ),
            locale: fixture.locale,
          );
        }
      },
    );

class _SeasonContextFixture {
  const _SeasonContextFixture({required this.league, required this.locale});

  final LeagueState league;
  final String locale;

  String get description {
    final season = league.currentSeason;
    return 'locale=$locale year=${season.year} phase=${season.phase.name} '
        'week=${league.currentWeek} day=${league.currentDay}';
  }
}

SeasonContextLines _seasonContextLinesFor(
  _SeasonContextFixture fixture,
  String locale,
) {
  final l10n = _localizationsFor(locale);
  final season = fixture.league.currentSeason;
  final phaseLabel = _seasonPhaseLabel(l10n, season.phase);
  return SeasonContextLines(
    seasonLine: l10n.home_seasonLine(season.year),
    phaseLine: l10n.home_phaseLine(phaseLabel),
    weekDayLine: l10n.home_weekDayLine(
      fixture.league.currentWeek,
      fixture.league.currentDay,
    ),
  );
}

void _expectSeasonContextLines(
  SeasonContextLines lines,
  _SeasonContextFixture fixture,
  String locale,
) {
  final l10n = _localizationsFor(locale);
  final season = fixture.league.currentSeason;
  final phaseLabel = _seasonPhaseLabel(l10n, season.phase);
  final expectedValues = <String>[
    l10n.home_seasonLine(season.year),
    l10n.home_phaseLine(phaseLabel),
    l10n.home_weekDayLine(
      fixture.league.currentWeek,
      fixture.league.currentDay,
    ),
  ];
  final reason = '${fixture.description} checkedLocale=$locale';

  expect(lines.values, hasLength(3), reason: reason);
  expect(
    lines.values.every((line) => line.trim().isNotEmpty),
    isTrue,
    reason: reason,
  );
  expect(lines.values, equals(expectedValues), reason: reason);
  expect(
    lines.values[0],
    contains(season.year.toString()),
    reason: '$reason season year is visible',
  );
  expect(
    lines.values[1],
    contains(phaseLabel),
    reason: '$reason localized phase is visible',
  );
  expect(
    lines.values[2],
    allOf(
      contains(fixture.league.currentWeek.toString()),
      contains(fixture.league.currentDay.toString()),
    ),
    reason: '$reason week and day are visible on the same line',
  );
}

AppLocalizations _localizationsFor(String locale) => switch (locale) {
  'pl' => AppLocalizationsPl(),
  'en' => AppLocalizationsEn(),
  _ => throw ArgumentError.value(locale, 'locale', 'Unsupported locale'),
};

String _seasonPhaseLabel(AppLocalizations l10n, SeasonPhase phase) =>
    switch (phase) {
      SeasonPhase.preseason => l10n.seasonPhase_preseason,
      SeasonPhase.regular => l10n.seasonPhase_regular,
      SeasonPhase.playIn => l10n.seasonPhase_playIn,
      SeasonPhase.playoff => l10n.seasonPhase_playoff,
      SeasonPhase.offseason => l10n.seasonPhase_offseason,
    };
