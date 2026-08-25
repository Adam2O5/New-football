import 'package:new_football/app/branding/club_asset_registry.dart';

/// Shared presentation assets for the team selection screen.
abstract final class TeamSelectionAssets {
  /// The registered fallback logo used by the existing team-row flow.
  static const String placeholderAsset =
      ClubAssetRegistry.fallbackLogoAssetPath;

  /// The uniform logical size reserved for each team logo.
  static const double iconSize = 48.0;
}
