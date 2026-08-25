/// Immutable manifest of image assets used by club branding.
///
/// Logo paths are intentionally declared explicitly instead of being derived
/// from a team's display name. The production manifest contains one entry for
/// each logo in the Branding Reference Table; [fallbackLogoAsset] points to
/// one of those registered logos so it does not add a second bundled file.
class ClubAssetRegistry {
  const ClubAssetRegistry({
    required this.logoAssets,
    required this.fallbackLogoAsset,
  });

  /// Every registered club-logo asset path in table order.
  ///
  /// The production value is a compile-time constant set, and therefore cannot
  /// be changed by callers after it is constructed.
  final Set<String> logoAssets;

  /// The single registered logo used when a club logo cannot be read.
  final String fallbackLogoAsset;

  /// The background image is registered separately and is not a logo.
  static const String backgroundAssetPath =
      'assets/images/new-football-background.png';

  /// The approved fallback logo path.
  static const String fallbackLogoAssetPath = 'assets/images/Syrenka_FC.png';

  /// The exact 30 logo paths from the Branding Reference Table.
  static const Set<String> productionLogoAssets = <String>{
    'assets/images/Syrenka_FC.png',
    'assets/images/Eiffel_Town.png',
    'assets/images/Marseille_FC.png',
    'assets/images/Madrid_Royals.png',
    'assets/images/Gaudi_Athletic.png',
    'assets/images/London_Rovers.png',
    'assets/images/Manchester_Wanderers.png',
    'assets/images/Mersey_United.png',
    'assets/images/Berlin_Bears.png',
    'assets/images/Brussels_City.png',
    'assets/images/Amsterdam_Club.png',
    'assets/images/Lisbon_FC.png',
    'assets/images/Rome_Eagles.png',
    'assets/images/Lombardy_Milan.png',
    'assets/images/Neapol_Athletic.png',
    'assets/images/Sao_Paulo_FC.png',
    'assets/images/Joga_Bonito_FC.png',
    'assets/images/Buenos_Aires_Wanderers.png',
    'assets/images/Tokyo_Emperors.png',
    'assets/images/Liberty_New_York.png',
    'assets/images/Hollywood_FC.png',
    'assets/images/Chicago_Aces.png',
    'assets/images/Philadelphia_Warriors.png',
    'assets/images/Kyoto_Samurais.png',
    'assets/images/Shanghai_Dragons.png',
    'assets/images/Imperial_Beijing.png',
    'assets/images/Mexico_City_SC.png',
    'assets/images/Dynamo_Casablanca.png',
    'assets/images/Cairo_United.png',
    'assets/images/Lagos_Rovers.png',
  };

  /// The shared production manifest used by all branding consumers.
  static const ClubAssetRegistry production = ClubAssetRegistry(
    logoAssets: productionLogoAssets,
    fallbackLogoAsset: fallbackLogoAssetPath,
  );
}
