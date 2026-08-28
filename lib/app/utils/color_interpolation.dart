import 'dart:math' show pow;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Colors;

/// An immutable point in a colour gradient.
///
/// Stop values are interpreted on a numeric axis. [interpolateStops] makes a
/// sorted copy of any stop list it receives, so callers can safely reuse
/// their lists and the supplied order is never changed.
@immutable
class ColorStop {
  /// Creates a colour stop at [value].
  const ColorStop({required this.value, required this.color});

  /// The numeric value represented by this stop.
  final double value;

  /// The colour represented by this stop.
  final Color color;
}

/// The lower and upper OVR values represented by [ovrGradientStops].
const int minOvrGradientValue = 50;
const int maxOvrGradientValue = 99;

/// The lower and upper form values represented by [formGradientStops].
const double minFormGradientValue = 0;
const double maxFormGradientValue = 10;

/// The lower and upper values represented by [percentGradientStops].
const double minPercentGradientValue = 0;
const double maxPercentGradientValue = 100;

/// The semantic OVR gradient used by the squad presentation.
///
/// The dark-green token is deliberately darker than the light-green token so
/// that the foreground chooser can select a readable foreground at every
/// point in the gradient.
const List<ColorStop> ovrGradientStops = <ColorStop>[
  ColorStop(value: 50, color: Colors.red),
  ColorStop(value: 60, color: Colors.orange),
  ColorStop(value: 70, color: Colors.yellow),
  ColorStop(value: 80, color: Colors.lightGreen),
  ColorStop(value: 90, color: Color(0xFF2E7D32)),
  ColorStop(value: 99, color: Colors.blue),
];

/// The semantic form gradient used by the squad presentation.
const List<ColorStop> formGradientStops = <ColorStop>[
  ColorStop(value: 1, color: Colors.red),
  ColorStop(value: 3, color: Colors.orange),
  ColorStop(value: 5, color: Colors.yellow),
  ColorStop(value: 7, color: Colors.lightGreen),
  ColorStop(value: 9, color: Color(0xFF2E7D32)),
  ColorStop(value: 10, color: Colors.blue),
];

/// The semantic 0–100 gradient used by the squad metric bars (lineup
/// cohesion, chemistry, atmosphere).
const List<ColorStop> percentGradientStops = <ColorStop>[
  ColorStop(value: 0, color: Colors.red),
  ColorStop(value: 30, color: Colors.orange),
  ColorStop(value: 50, color: Colors.yellow),
  ColorStop(value: 70, color: Colors.lightGreen),
  ColorStop(value: 90, color: Color(0xFF2E7D32)),
  ColorStop(value: 100, color: Colors.blue),
];

/// Aliases that make the gradient purpose explicit at call sites.
const List<ColorStop> ovrColorStops = ovrGradientStops;
const List<ColorStop> formColorStops = formGradientStops;
const List<ColorStop> percentColorStops = percentGradientStops;

/// Linearly interpolates colour channels between [stops] at [value].
///
/// Values outside the stop range are clamped to the nearest endpoint. The
/// input list is copied and sorted locally. Empty or entirely non-finite stop
/// lists return transparent rather than throwing or constructing an invalid
/// colour. A non-finite [value] is treated as the corresponding safe endpoint
/// (`NaN` uses the first valid stop).
Color interpolateStops(double value, List<ColorStop> stops) {
  final validStops = stops
      .where((stop) => stop.value.isFinite)
      .toList(growable: true);
  if (validStops.isEmpty) return const Color(0x00000000);

  validStops.sort((a, b) => a.value.compareTo(b.value));

  if (validStops.length == 1) return validStops.first.color;

  final first = validStops.first;
  final last = validStops.last;
  if (value.isNaN || value == double.negativeInfinity) {
    return first.color;
  }
  if (value == double.infinity) return last.color;

  if (value <= first.value) return first.color;
  if (value >= last.value) return last.color;

  for (var index = 1; index < validStops.length; index++) {
    final upper = validStops[index];
    if (value <= upper.value) {
      final lower = validStops[index - 1];
      final span = upper.value - lower.value;
      if (!span.isFinite || span <= 0) return upper.color;

      final fraction = ((value - lower.value) / span)
          .clamp(0.0, 1.0)
          .toDouble();
      return _lerpColor(lower.color, upper.color, fraction);
    }
  }

  // The finite range checks above make this unreachable, but retaining an
  // endpoint fallback keeps the function total if the implementation changes.
  return last.color;
}

/// Returns the OVR background colour for an already rounded OVR value.
///
/// Values below 50 use the red endpoint and values above 99 use the blue
/// endpoint. The stop values are integers so no fractional numeric input can
/// leak into the presentation layer.
Color ovrColorForRoundedValue(int roundedOvr) =>
    interpolateStops(roundedOvr.toDouble(), ovrGradientStops);

/// Returns the form background colour after clamping [form] to 0–10.
///
/// Form values at or below 1 use the red endpoint; values at or above 10 use
/// the blue endpoint. `NaN` is treated as the safe lower endpoint and
/// infinities are clamped to the corresponding finite endpoint.
Color formColorForClampedValue(double form) =>
    interpolateStops(_clampForm(form), formGradientStops);

/// Clamps a raw form value to the inclusive 0–10 presentation scale.
double clampedFormValue(double form) => _clampForm(form);

/// Returns the filled fraction for a raw form value on a 0–10 track.
double formFillForValue(double form) =>
    (_clampForm(form) / maxFormGradientValue).clamp(0.0, 1.0).toDouble();

/// Returns the background colour for a 0–100 metric value after clamping.
///
/// Values at or below 0 use the red endpoint; values at or above 100 use the
/// blue endpoint. `NaN` is treated as the safe lower endpoint and infinities
/// are clamped to the corresponding finite endpoint.
Color percentColorForClampedValue(double value) =>
    interpolateStops(_clampPercent(value), percentGradientStops);

/// Clamps a raw value to the inclusive 0–100 presentation scale.
double clampedPercentValue(double value) => _clampPercent(value);

/// Returns the filled fraction for a raw value on a 0–100 track.
double percentFillForValue(double value) =>
    (_clampPercent(value) / maxPercentGradientValue).clamp(0.0, 1.0).toDouble();

/// Rounds a finite numeric value to the nearest integer using half-up ties.
///
/// Positive values are handled explicitly instead of relying on a widget or
/// platform rounding convention: 2.5 becomes 3. Negative values use the
/// symmetric half-away-from-zero result. Non-finite input maps to zero so a
/// malformed value cannot produce an exception or `NaN` presentation value.
int roundHalfUp(double value) {
  if (!value.isFinite) return 0;

  if (value >= 0) {
    final lower = value.floor();
    return value - lower >= 0.5 ? lower + 1 : lower;
  }

  final upper = value.ceil();
  return upper - value >= 0.5 ? upper - 1 : upper;
}

/// Rounds a raw OVR value and defensively maps it into the display domain.
///
/// Finite values use explicit half-up rounding. A non-finite lower value or
/// `NaN` resolves to the lower visual endpoint, while positive infinity
/// resolves to the upper endpoint; this keeps downstream colour/layout code
/// finite and deterministic.
int roundedOvrForDisplay(double rawOvr) {
  if (rawOvr.isNaN || rawOvr == double.negativeInfinity) {
    return minOvrGradientValue;
  }
  if (rawOvr == double.infinity) return maxOvrGradientValue;
  return roundHalfUp(rawOvr);
}

/// Returns the OVR colour for a raw, potentially fractional OVR value.
Color ovrColorForRawValue(double rawOvr) =>
    ovrColorForRoundedValue(roundedOvrForDisplay(rawOvr));

/// Calculates the WCAG relative contrast ratio between two colours.
///
/// RGB channels are interpreted as sRGB values. Alpha is intentionally not
/// used in the luminance calculation: callers pass the effective foreground
/// and background colours that are actually painted by the badge.
double contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = _relativeLuminance(foreground);
  final backgroundLuminance = _relativeLuminance(background);
  final lighter = foregroundLuminance >= backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance >= backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Chooses a black or white foreground with at least [minimumRatio] contrast.
///
/// The default ratio is the required WCAG 4.5:1 text contrast. For ordinary
/// badge colours at least one of black and white meets that threshold; when a
/// caller requests an impossible ratio, the candidate with the strongest
/// available contrast is returned instead of producing an invalid colour or
/// throwing. Invalid requested ratios fall back to 4.5.
Color foregroundForContrast(Color background, {double minimumRatio = 4.5}) {
  final requiredRatio = _safeMinimumContrast(minimumRatio);
  final blackContrast = contrastRatio(Colors.black, background);
  final whiteContrast = contrastRatio(Colors.white, background);

  final blackPasses = blackContrast >= requiredRatio;
  final whitePasses = whiteContrast >= requiredRatio;
  if (blackPasses && whitePasses) {
    return blackContrast >= whiteContrast ? Colors.black : Colors.white;
  }
  if (blackPasses) return Colors.black;
  if (whitePasses) return Colors.white;

  return blackContrast >= whiteContrast ? Colors.black : Colors.white;
}

Color _lerpColor(Color lower, Color upper, double fraction) {
  final t = fraction.isFinite ? fraction.clamp(0.0, 1.0).toDouble() : 0.0;
  return Color.fromARGB(
    _lerpChannel(_colorByte(lower.a), _colorByte(upper.a), t),
    _lerpChannel(_colorByte(lower.r), _colorByte(upper.r), t),
    _lerpChannel(_colorByte(lower.g), _colorByte(upper.g), t),
    _lerpChannel(_colorByte(lower.b), _colorByte(upper.b), t),
  );
}

int _colorByte(double channel) =>
    (channel.clamp(0.0, 1.0) * 255.0).round().clamp(0, 255).toInt();

int _lerpChannel(int lower, int upper, double fraction) {
  final value = lower + ((upper - lower) * fraction);
  if (!value.isFinite) return lower;
  return value.round().clamp(0, 255).toInt();
}

double _clampForm(double value) {
  if (value.isNaN || value == double.negativeInfinity) {
    return minFormGradientValue;
  }
  if (value == double.infinity) return maxFormGradientValue;
  return value.clamp(minFormGradientValue, maxFormGradientValue).toDouble();
}

double _clampPercent(double value) {
  if (value.isNaN || value == double.negativeInfinity) {
    return minPercentGradientValue;
  }
  if (value == double.infinity) return maxPercentGradientValue;
  return value
      .clamp(minPercentGradientValue, maxPercentGradientValue)
      .toDouble();
}

double _relativeLuminance(Color color) {
  final red = _linearizeChannel(_colorByte(color.r));
  final green = _linearizeChannel(_colorByte(color.g));
  final blue = _linearizeChannel(_colorByte(color.b));
  return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue);
}

double _linearizeChannel(int channel) {
  final normalized = channel.clamp(0, 255).toDouble() / 255.0;
  if (normalized <= 0.03928) return normalized / 12.92;
  return pow((normalized + 0.055) / 1.055, 2.4).toDouble();
}

double _safeMinimumContrast(double value) {
  if (!value.isFinite || value < 1.0) return 4.5;
  return value;
}
