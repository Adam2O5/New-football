import 'dart:ui' show Color;

import 'package:flutter/painting.dart' show FontWeight;
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/branding/club_asset_registry.dart';
import 'package:new_football/app/branding/club_branding_data.dart';
import 'package:new_football/app/branding/club_branding_record.dart';
import 'package:new_football/app/branding/club_branding_registry.dart';
import 'package:new_football/app/branding/club_branding_types.dart';
import 'package:new_football/app/branding/club_color_tokens.dart';

void main() {
  group('ClubBrandingRegistry production data', () {
    test('contains one complete record for each reference-table ID', () {
      final records = ClubBrandingData.productionRecords;
      final registry = ClubBrandingRegistry.production;

      expect(records, hasLength(30));
      expect(records.map((record) => record.teamId).toSet(), hasLength(30));
      expect(
        records.map((record) => record.teamId).toSet(),
        equals(ClubBrandingData.expectedTeamIds),
      );
      expect(registry.validate(), isEmpty);

      for (final record in records) {
        final resolution = registry.resolve(record.teamId);
        expect(resolution.record, equals(record));
        expect(resolution.logoAsset, record.logoAsset);
        expect(resolution.primaryColor, isNotNull);
        expect(resolution.secondaryColor, isNotNull);
        expect(resolution.isFallback, isFalse);
      }
    });

    test('resolves the explicit Marseille and Chicago mappings by Team_ID', () {
      final marseille = ClubBrandingRegistry.production.resolve(
        'team_europe_2',
      );
      final chicago = ClubBrandingRegistry.production.resolve(
        'team_restOfTheWorld_21',
      );

      expect(marseille.logoAsset, 'assets/images/Marseille_FC.png');
      expect(marseille.record!.teamId, 'team_europe_2');
      expect(marseille.usedFallbackLogo, isFalse);
      expect(chicago.logoAsset, 'assets/images/Chicago_Aces.png');
      expect(chicago.record!.teamId, 'team_restOfTheWorld_21');
      expect(chicago.usedFallbackLogo, isFalse);
    });

    test(
      'reports an absent ID and a duplicated ID without hiding either case',
      () {
        final target = ClubBrandingData.productionRecords[2];
        final absentRecords = List<ClubBrandingRecord>.of(
          ClubBrandingData.productionRecords,
        )..removeWhere((record) => record.teamId == target.teamId);
        final duplicatedRecords = List<ClubBrandingRecord>.of(
          ClubBrandingData.productionRecords,
        )..add(target);

        final absentFailures = ClubBrandingRegistry(
          records: absentRecords,
          assets: ClubAssetRegistry.production,
          colors: ColorTokenRegistry.production,
        ).validate();
        final duplicateFailures = ClubBrandingRegistry(
          records: duplicatedRecords,
          assets: ClubAssetRegistry.production,
          colors: ColorTokenRegistry.production,
        ).validate();

        expect(
          absentFailures,
          contains(
            isA<BrandingValidationFailure>()
                .having((failure) => failure.teamId, 'teamId', target.teamId)
                .having(
                  (failure) => failure.kind,
                  'kind',
                  RegistryValidationKind.absent,
                ),
          ),
        );
        expect(
          duplicateFailures,
          contains(
            isA<BrandingValidationFailure>()
                .having((failure) => failure.teamId, 'teamId', target.teamId)
                .having(
                  (failure) => failure.kind,
                  'kind',
                  RegistryValidationKind.duplicated,
                ),
          ),
        );
      },
    );
  });

  test(
    'unknown and damaged records resolve to complete independent fallbacks',
    () {
      const fallbackLogo = 'memory/fallback.png';
      const validLogo = 'memory/logo.png';
      const primaryName = 'primary';
      const secondaryName = 'secondary';
      const primaryColor = Color(0xFF123456);
      const secondaryColor = Color(0xFF654321);
      const assets = ClubAssetRegistry(
        logoAssets: {validLogo, fallbackLogo},
        fallbackLogoAsset: fallbackLogo,
      );
      final colors = ColorTokenRegistry(const {
        primaryName: primaryColor,
        secondaryName: secondaryColor,
      });
      final registry = ClubBrandingRegistry(
        records: const [
          ClubBrandingRecord(
            teamId: 'damaged-team',
            logoAsset: 'memory/missing.png',
            primaryColorName: primaryName,
            secondaryColorName: 'missing-secondary',
          ),
        ],
        assets: assets,
        colors: colors,
      );

      final damaged = registry.resolve('damaged-team');
      final unknown = registry.resolve('unknown-team');

      expect(damaged.logoAsset, fallbackLogo);
      expect(damaged.primaryColor, primaryColor);
      expect(damaged.secondaryColor, ColorTokenRegistry.secondaryFallback);
      expect(damaged.usedFallbackLogo, isTrue);
      expect(damaged.usedFallbackPrimaryColor, isFalse);
      expect(damaged.usedFallbackSecondaryColor, isTrue);
      expect(damaged.diagnostics, hasLength(2));
      expect(damaged.diagnostics, everyElement(isA<BrandingDiagnostic>()));

      expect(unknown.logoAsset, fallbackLogo);
      expect(unknown.primaryColor, ColorTokenRegistry.primaryFallback);
      expect(unknown.secondaryColor, ColorTokenRegistry.secondaryFallback);
      expect(unknown.isFallback, isTrue);
      expect(unknown.record, isNull);
      expect(unknown.diagnostics.single.teamId, 'unknown-team');
      expect(
        unknown.diagnostics.single.kind,
        BrandingFailureKind.missingRecord,
      );
    },
  );

  test(
    'production color tokens have one renderable value and readable foregrounds',
    () {
      final registry = ColorTokenRegistry.production;

      expect(
        registry.tokenNames,
        hasLength(ColorTokenRegistry.productionTokenCount),
      );
      expect(
        registry.tokenNames,
        equals(ColorTokenRegistry.productionTokenNames),
      );
      expect(
        registry.primaryFallbackColor,
        equals(ColorTokenRegistry.primaryFallback),
      );
      expect(
        registry.secondaryFallbackColor,
        equals(ColorTokenRegistry.secondaryFallback),
      );

      for (final surface in registry.values.values) {
        final smallForeground = foregroundFor(surface);
        final largeForeground = foregroundFor(
          surface,
          minimumRatio: largeTextContrastThreshold,
        );
        expect(
          contrastRatio(smallForeground, surface),
          greaterThanOrEqualTo(smallTextContrastThreshold),
        );
        expect(
          contrastRatio(largeForeground, surface),
          greaterThanOrEqualTo(largeTextContrastThreshold),
        );
      }

      expect(isLargeText(fontSize: 18), isTrue);
      expect(isLargeText(fontSize: 17.99), isFalse);
      expect(isLargeText(fontSize: 14, fontWeight: FontWeight.w700), isTrue);
      expect(
        isLargeText(fontSize: 13.99, fontWeight: FontWeight.w700),
        isFalse,
      );
    },
  );
}
