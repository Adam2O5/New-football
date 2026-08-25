import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart' show FontWeight;

/// The semantic role used when resolving a missing colour token.
enum ClubColorRole { primary, secondary }

/// Approved semantic colour tokens used by the club-branding reference table.
///
/// The registry stores token names rather than presentation-specific colours in
/// widgets. The production instance contains exactly the 15 names and values
/// documented by the club-branding design.
@immutable
class ColorTokenRegistry {
  /// Creates a registry with a defensive, unmodifiable copy of [values].
  ///
  /// A registry may intentionally contain a partial map in tests so callers
  /// can exercise fallback behaviour. The production registry is available as
  /// [production].
  ColorTokenRegistry(Map<String, Color> values)
    : values = Map<String, Color>.unmodifiable(values);

  /// Creates a registry from entries while rejecting duplicate token names.
  ///
  /// A `Map` cannot represent duplicate keys, so this constructor is useful
  /// when production data is assembled from a list of named entries and a
  /// repeated name must not be silently overwritten.
  factory ColorTokenRegistry.fromEntries(
    Iterable<MapEntry<String, Color>> entries,
  ) {
    final values = <String, Color>{};
    for (final entry in entries) {
      if (values.containsKey(entry.key)) {
        throw ArgumentError.value(
          entry.key,
          'entries',
          'Colour token names must be unique.',
        );
      }
      values[entry.key] = entry.value;
    }
    return ColorTokenRegistry(values);
  }

  /// The semantic name for the red token.
  static const String redToken = 'Czerwony';

  /// The semantic name for the white token.
  static const String whiteToken = 'Biały';

  /// The semantic name for the navy token.
  static const String navyToken = 'Granatowy';

  /// The semantic name for the light-blue token.
  static const String lightBlueToken = 'Jasnoniebieski';

  /// The semantic name for the gold token.
  static const String goldToken = 'Złoty';

  /// The semantic name for the burgundy token.
  static const String burgundyToken = 'Bordo';

  /// The semantic name for the yellow token.
  static const String yellowToken = 'Żółty';

  /// The semantic name for the sky-blue token.
  static const String skyBlueToken = 'Błękitny';

  /// The semantic name for the green token.
  static const String greenToken = 'Zielony';

  /// The semantic name for the black token.
  static const String blackToken = 'Czarny';

  /// The semantic name for the purple token.
  static const String purpleToken = 'Fioletowy';

  /// The semantic name for the orange token.
  static const String orangeToken = 'Pomarańczowy';

  /// The semantic name for the dark-blue token.
  static const String darkBlueToken = 'Ciemnoniebieski';

  /// The semantic name for the dark-red token.
  static const String darkRedToken = 'Ciemnoczerwony';

  /// The semantic name for the pink token.
  static const String pinkToken = 'Różowy';

  /// The approved primary-role fallback token.
  static const String primaryFallbackToken = darkBlueToken;

  /// The approved secondary-role fallback token.
  static const String secondaryFallbackToken = whiteToken;

  /// The approved primary-role fallback colour.
  static const Color primaryFallback = Color(0xFF1A237E);

  /// The approved secondary-role fallback colour.
  static const Color secondaryFallback = Color(0xFFFFFFFF);

  /// The exact production token values from the design reference.
  static const Map<String, Color> productionValues = <String, Color>{
    redToken: Color(0xFFD32F2F),
    whiteToken: Color(0xFFFFFFFF),
    navyToken: Color(0xFF0D47A1),
    lightBlueToken: Color(0xFF64B5F6),
    goldToken: Color(0xFFF9A825),
    burgundyToken: Color(0xFF7F1D1D),
    yellowToken: Color(0xFFFDD835),
    skyBlueToken: Color(0xFF29B6F6),
    greenToken: Color(0xFF2E7D32),
    blackToken: Color(0xFF121212),
    purpleToken: Color(0xFF6A1B9A),
    orangeToken: Color(0xFFEF6C00),
    darkBlueToken: Color(0xFF1A237E),
    darkRedToken: Color(0xFF8B0000),
    pinkToken: Color(0xFFD81B60),
  };

  /// The exact production token names, exposed as an immutable collection.
  static const Set<String> productionTokenNames = <String>{
    redToken,
    whiteToken,
    navyToken,
    lightBlueToken,
    goldToken,
    burgundyToken,
    yellowToken,
    skyBlueToken,
    greenToken,
    blackToken,
    purpleToken,
    orangeToken,
    darkBlueToken,
    darkRedToken,
    pinkToken,
  };

  /// The number of semantic tokens required by the reference table.
  static const int productionTokenCount = 15;

  /// The shared immutable production registry.
  static final ColorTokenRegistry production = ColorTokenRegistry(
    productionValues,
  );

  /// Alias for callers that prefer a default-registry name.
  static ColorTokenRegistry get defaultRegistry => production;

  /// The defensively copied token values.
  final Map<String, Color> values;

  /// All token names exposed through this registry, without mutation access.
  Set<String> get tokenNames => Set<String>.unmodifiable(values.keys);

  /// Alias for [tokenNames] used by manifest and validation callers.
  Set<String> get names => tokenNames;

  /// Looks up a token by its semantic name.
  ///
  /// This nullable operation intentionally preserves the distinction between
  /// a valid token and a missing token for registry diagnostics. Widget code
  /// should use [resolveOrFallback], [primaryColorFor], or
  /// [secondaryColorFor] when it needs a guaranteed renderable value.
  Color? resolve(String? colorName) =>
      colorName == null || colorName.isEmpty ? null : values[colorName];

  /// Resolves a token with the approved fallback for [role].
  Color resolveOrFallback(
    String? colorName, {
    ClubColorRole role = ClubColorRole.primary,
  }) => resolve(colorName) ?? fallbackFor(role);

  /// Resolves a primary-role token without exposing `null` to a widget.
  Color primaryColorFor(String? colorName) =>
      resolve(colorName) ?? primaryFallbackColor;

  /// Resolves a secondary-role token without exposing `null` to a widget.
  Color secondaryColorFor(String? colorName) =>
      resolve(colorName) ?? secondaryFallbackColor;

  /// Returns the approved fallback colour for a semantic role.
  Color fallbackFor(ClubColorRole role) => switch (role) {
    ClubColorRole.primary => primaryFallbackColor,
    ClubColorRole.secondary => secondaryFallbackColor,
  };

  /// The immutable primary-role fallback colour.
  Color get primaryFallbackColor => primaryFallback;

  /// The immutable secondary-role fallback colour.
  Color get secondaryFallbackColor => secondaryFallback;

  /// Alias for the primary fallback token name.
  String get fallbackPrimaryToken => primaryFallbackToken;

  /// Alias for the secondary fallback token name.
  String get fallbackSecondaryToken => secondaryFallbackToken;

  /// Alias for the primary fallback colour.
  Color get fallbackPrimaryColor => primaryFallbackColor;

  /// Alias for the secondary fallback colour.
  Color get fallbackSecondaryColor => secondaryFallbackColor;
}

/// Minimum contrast required for ordinary, small text and essential symbols.
const double smallTextContrastThreshold = 4.5;

/// Minimum contrast required for large text.
const double largeTextContrastThreshold = 3.0;

/// The regular-weight font-size boundary for large text, in logical pixels.
const double largeTextRegularFontSize = 18.0;

/// The bold-weight font-size boundary for large text, in logical pixels.
const double largeTextBoldFontSize = 14.0;

/// Returns the WCAG relative luminance of an sRGB [color].
///
/// Alpha is deliberately ignored: callers should pass the effective surface
/// and foreground colours that are actually painted. This keeps the helper
/// pure and deterministic for both widgets and unit tests.
double relativeLuminance(Color color) {
  final red = _linearizeChannel(color.r);
  final green = _linearizeChannel(color.g);
  final blue = _linearizeChannel(color.b);
  return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue);
}

/// Calculates the WCAG contrast ratio between two effective colours.
double contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = relativeLuminance(foreground);
  final backgroundLuminance = relativeLuminance(background);
  final lighter = math.max(foregroundLuminance, backgroundLuminance);
  final darker = math.min(foregroundLuminance, backgroundLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Chooses black or white with the strongest available contrast for [surface].
///
/// If either candidate satisfies [minimumRatio], a satisfying candidate is
/// returned. If both satisfy it, the stronger candidate wins. If the caller
/// asks for an impossible ratio, the candidate with the strongest available
/// contrast is returned rather than exposing an unreadable or invalid colour.
Color foregroundFor(
  Color surface, {
  double minimumRatio = smallTextContrastThreshold,
}) {
  final requiredRatio = _safeMinimumContrast(minimumRatio);
  const black = Color(0xFF000000);
  const white = Color(0xFFFFFFFF);
  final blackContrast = contrastRatio(black, surface);
  final whiteContrast = contrastRatio(white, surface);
  final blackPasses = blackContrast >= requiredRatio;
  final whitePasses = whiteContrast >= requiredRatio;

  if (blackPasses && whitePasses) {
    return blackContrast >= whiteContrast ? black : white;
  }
  if (blackPasses) return black;
  if (whitePasses) return white;
  return blackContrast >= whiteContrast ? black : white;
}

/// Returns whether [foreground] satisfies the requested contrast threshold.
bool contrastMeetsThreshold(
  Color foreground,
  Color background, {
  double minimumRatio = smallTextContrastThreshold,
}) =>
    contrastRatio(foreground, background) >= _safeMinimumContrast(minimumRatio);

/// Alias for [contrastMeetsThreshold] with a descriptive predicate name.
bool hasRequiredContrast(
  Color foreground,
  Color background, {
  double minimumRatio = smallTextContrastThreshold,
}) =>
    contrastMeetsThreshold(foreground, background, minimumRatio: minimumRatio);

/// Returns whether a text style qualifies as large text for contrast rules.
///
/// The boundary is inclusive: regular-weight text is large at 18 logical
/// points, while bold (700 and heavier) text is large at 14 logical points.
bool isLargeText({
  required double fontSize,
  FontWeight fontWeight = FontWeight.normal,
}) {
  if (!fontSize.isFinite || fontSize < 0) return false;
  final isBold = fontWeight.value >= FontWeight.w700.value;
  final boundary = isBold ? largeTextBoldFontSize : largeTextRegularFontSize;
  return fontSize >= boundary;
}

/// Returns the contrast threshold appropriate for a text style.
double contrastThresholdForText({
  required double fontSize,
  FontWeight fontWeight = FontWeight.normal,
}) => isLargeText(fontSize: fontSize, fontWeight: fontWeight)
    ? largeTextContrastThreshold
    : smallTextContrastThreshold;

/// Positional convenience form of [isLargeText].
bool isLargeTextSize(
  double fontSize, {
  FontWeight fontWeight = FontWeight.normal,
}) => isLargeText(fontSize: fontSize, fontWeight: fontWeight);

/// Positional convenience form of [contrastThresholdForText].
double contrastThresholdFor(
  double fontSize, {
  FontWeight fontWeight = FontWeight.normal,
}) => contrastThresholdForText(fontSize: fontSize, fontWeight: fontWeight);

double _linearizeChannel(double channel) {
  final normalized = channel.clamp(0.0, 1.0).toDouble();
  if (normalized <= 0.03928) return normalized / 12.92;
  return math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
}

double _safeMinimumContrast(double value) {
  if (!value.isFinite || value < 1.0) return smallTextContrastThreshold;
  return value;
}
