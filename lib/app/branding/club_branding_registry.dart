import 'package:new_football/app/branding/club_asset_registry.dart';
import 'package:new_football/app/branding/club_branding_data.dart';
import 'package:new_football/app/branding/club_branding_record.dart';
import 'package:new_football/app/branding/club_branding_types.dart';
import 'package:new_football/app/branding/club_color_tokens.dart';

/// Resolves presentation branding by the stable team identifier.
class ClubBrandingRegistry {
  ClubBrandingRegistry({
    required Iterable<ClubBrandingRecord> records,
    required this.assets,
    required this.colors,
  }) : records = List<ClubBrandingRecord>.unmodifiable(records);

  /// The production registry shared by all branding-aware screens.
  static final ClubBrandingRegistry production = ClubBrandingRegistry(
    records: ClubBrandingData.productionRecords,
    assets: ClubAssetRegistry.production,
    colors: ColorTokenRegistry.production,
  );

  /// Alias used by callers that prefer an explicit default name.
  static ClubBrandingRegistry get defaultRegistry => production;

  /// Records are retained in reference-table order for deterministic iteration.
  final List<ClubBrandingRecord> records;

  final ClubAssetRegistry assets;
  final ColorTokenRegistry colors;

  /// The expected stable IDs for the production reference table.
  Set<String> get expectedTeamIds => ClubBrandingData.expectedTeamIds;

  /// Resolves one complete renderable presentation record by [teamId].
  ///
  /// No display field is consulted. Missing or invalid presentation resources
  /// fall back independently so a single problem never disables selection.
  ClubBrandingResolution resolve(String teamId) {
    final matches = records.where((record) => record.teamId == teamId);
    final record = matches.isEmpty ? null : matches.first;
    if (record == null) {
      return _fallbackResolution(
        teamId,
        diagnostics: <BrandingDiagnostic>[
          BrandingDiagnostic(
            teamId: teamId,
            kind: BrandingFailureKind.missingRecord,
            message: 'No club branding record exists for $teamId.',
          ),
        ],
      );
    }

    final diagnostics = <BrandingDiagnostic>[];
    var logoAsset = record.logoAsset;
    var usedFallbackLogo = false;
    if (logoAsset.isEmpty || !assets.logoAssets.contains(logoAsset)) {
      diagnostics.add(
        BrandingDiagnostic(
          teamId: teamId,
          kind: BrandingFailureKind.missingLogoAsset,
          message: 'No registered club logo exists at $logoAsset.',
        ),
      );
      logoAsset = assets.fallbackLogoAsset;
      usedFallbackLogo = true;
    }

    final primaryToken = colors.resolve(record.primaryColorName);
    final usedFallbackPrimaryColor = primaryToken == null;
    if (usedFallbackPrimaryColor) {
      diagnostics.add(
        BrandingDiagnostic(
          teamId: teamId,
          kind: record.primaryColorName.isEmpty
              ? BrandingFailureKind.missingColorToken
              : BrandingFailureKind.invalidColorToken,
          message:
              'Primary colour token ${record.primaryColorName} is not registered.',
        ),
      );
    }

    final secondaryToken = colors.resolve(record.secondaryColorName);
    final usedFallbackSecondaryColor = secondaryToken == null;
    if (usedFallbackSecondaryColor) {
      diagnostics.add(
        BrandingDiagnostic(
          teamId: teamId,
          kind: record.secondaryColorName.isEmpty
              ? BrandingFailureKind.missingColorToken
              : BrandingFailureKind.invalidColorToken,
          message:
              'Secondary colour token ${record.secondaryColorName} is not registered.',
        ),
      );
    }

    return ClubBrandingResolution(
      teamId: teamId,
      logoAsset: logoAsset,
      primaryColor: primaryToken ?? colors.primaryFallbackColor,
      secondaryColor: secondaryToken ?? colors.secondaryFallbackColor,
      usedFallbackLogo: usedFallbackLogo,
      usedFallbackPrimaryColor: usedFallbackPrimaryColor,
      usedFallbackSecondaryColor: usedFallbackSecondaryColor,
      record: record,
      diagnostics: diagnostics,
    );
  }

  /// Reports missing or duplicated expected IDs without hiding duplicates in
  /// a map-based lookup.
  List<BrandingValidationFailure> validate() {
    final failures = <BrandingValidationFailure>[];
    for (final teamId in ClubBrandingData.expectedTeamIds) {
      final count = records.where((record) => record.teamId == teamId).length;
      if (count == 0) {
        failures.add(
          BrandingValidationFailure(
            teamId: teamId,
            kind: RegistryValidationKind.absent,
          ),
        );
      } else if (count > 1) {
        failures.add(
          BrandingValidationFailure(
            teamId: teamId,
            kind: RegistryValidationKind.duplicated,
          ),
        );
      }
    }
    return List<BrandingValidationFailure>.unmodifiable(failures);
  }

  ClubBrandingResolution _fallbackResolution(
    String teamId, {
    required List<BrandingDiagnostic> diagnostics,
  }) => ClubBrandingResolution(
    teamId: teamId,
    logoAsset: assets.fallbackLogoAsset,
    primaryColor: colors.primaryFallbackColor,
    secondaryColor: colors.secondaryFallbackColor,
    usedFallbackLogo: true,
    usedFallbackPrimaryColor: true,
    usedFallbackSecondaryColor: true,
    record: null,
    diagnostics: diagnostics,
  );
}
