import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;
import 'package:new_football/app/branding/club_branding_record.dart';

/// Immutable result of resolving branding for a stable team identifier.
///
/// A resolution contains complete renderable values even when one or more
/// values came from a fallback. [diagnostics] is copied into an unmodifiable
/// list, so neither the caller's input list nor the exposed result can be
/// changed after construction.
@immutable
class ClubBrandingResolution {
  ClubBrandingResolution({
    required this.teamId,
    required this.logoAsset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.usedFallbackLogo,
    required this.usedFallbackPrimaryColor,
    required this.usedFallbackSecondaryColor,
    this.record,
    List<BrandingDiagnostic> diagnostics = const <BrandingDiagnostic>[],
  }) : diagnostics = List<BrandingDiagnostic>.unmodifiable(diagnostics);

  /// The stable team identifier supplied to the resolver.
  final String teamId;

  /// The resolved logo asset path.
  final String logoAsset;

  /// The resolved primary colour.
  final Color primaryColor;

  /// The resolved secondary colour.
  final Color secondaryColor;

  /// Whether the logo value came from the approved fallback.
  final bool usedFallbackLogo;

  /// Whether the primary colour came from the approved fallback.
  final bool usedFallbackPrimaryColor;

  /// Whether the secondary colour came from the approved fallback.
  final bool usedFallbackSecondaryColor;

  /// The source record, when a record was available for [teamId].
  final ClubBrandingRecord? record;

  /// Non-fatal resolution diagnostics in deterministic resolution order.
  final List<BrandingDiagnostic> diagnostics;

  /// Whether any part of this resolution uses fallback data.
  bool get isFallback =>
      usedFallbackLogo ||
      usedFallbackPrimaryColor ||
      usedFallbackSecondaryColor;
}

/// The kind of completeness failure reported for an expected team identifier.
enum RegistryValidationKind { absent, duplicated }

/// A deterministic validation failure for an expected branding record.
@immutable
class BrandingValidationFailure {
  const BrandingValidationFailure({required this.teamId, required this.kind});

  /// The exact expected team identifier affected by the failure.
  final String teamId;

  /// Whether the identifier is absent or occurs more than once.
  final RegistryValidationKind kind;
}

/// The kind of non-fatal failure encountered while resolving branding.
enum BrandingFailureKind {
  missingRecord,
  missingLogoAsset,
  unreadableLogoAsset,
  missingColorToken,
  invalidColorToken,
}

/// A non-fatal diagnostic associated with one resolved team identifier.
@immutable
class BrandingDiagnostic {
  const BrandingDiagnostic({
    required this.teamId,
    required this.kind,
    required this.message,
  });

  /// The exact team identifier for which the diagnostic was produced.
  final String teamId;

  /// The resource or record failure represented by this diagnostic.
  final BrandingFailureKind kind;

  /// Human-readable diagnostic detail for logging and tests.
  final String message;
}
