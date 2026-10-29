@Tags(['property'])
library;

import 'dart:ui' show Color;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/color_interpolation.dart';

const _propertyRuns = 120;

void main() {
  const propertyFiveSeed = 8206;
  const propertyFiveStops = <ColorStop>[
    ColorStop(value: 50, color: Colors.red),
    ColorStop(value: 60, color: Colors.orange),
    ColorStop(value: 70, color: Colors.yellow),
    ColorStop(value: 80, color: Colors.lightGreen),
    ColorStop(value: 90, color: Color(0xFF2E7D32)),
    ColorStop(value: 99, color: Colors.blue),
  ];

  int expectedRoundedOvr(double rawOvr) {
    if (rawOvr >= 0) {
      final lower = rawOvr.floor();
      return rawOvr - lower >= 0.5 ? lower + 1 : lower;
    }
    final upper = rawOvr.ceil();
    return upper - rawOvr >= 0.5 ? upper - 1 : upper;
  }

  int expectedColorByte(double channel) => (channel * 255.0).round();

  int expectedColorChannel(double lower, double upper, double fraction) {
    final lowerByte = expectedColorByte(lower);
    final upperByte = expectedColorByte(upper);
    return (lowerByte + ((upperByte - lowerByte) * fraction))
        .round()
        .clamp(0, 255)
        .toInt();
  }

  Color expectedInterpolatedOvrColor(int roundedOvr) {
    final value = roundedOvr.toDouble();
    final first = propertyFiveStops.first;
    final last = propertyFiveStops.last;
    if (value <= first.value) return first.color;
    if (value >= last.value) return last.color;

    for (var index = 1; index < propertyFiveStops.length; index++) {
      final upper = propertyFiveStops[index];
      if (value <= upper.value) {
        final lower = propertyFiveStops[index - 1];
        final fraction = ((value - lower.value) / (upper.value - lower.value))
            .clamp(0.0, 1.0)
            .toDouble();
        return Color.fromARGB(
          expectedColorChannel(lower.color.a, upper.color.a, fraction),
          expectedColorChannel(lower.color.r, upper.color.r, fraction),
          expectedColorChannel(lower.color.g, upper.color.g, fraction),
          expectedColorChannel(lower.color.b, upper.color.b, fraction),
        );
      }
    }

    return last.color;
  }

  final generatedPropertyFiveCases = any
      .simple<
        ({double rawOvr, int generationSize, String scenario, bool shrunk})
      >(
        generate: (random, size) {
          final scenario = size % 12;
          final rawOvr = switch (scenario) {
            0 => 49.5 - random.nextInt(1001),
            1 => 50.0,
            2 => 60.0,
            3 => 70.0,
            4 => 80.0,
            5 => 90.0,
            6 => 99.0,
            7 => 50.5 + random.nextInt(9),
            8 => 60.5 + random.nextInt(9),
            9 => 70.5 + random.nextInt(19),
            10 => 90.5 + random.nextInt(9),
            _ => 99.5 + random.nextInt(1001),
          };
          return (
            rawOvr: rawOvr,
            generationSize: size,
            scenario: switch (scenario) {
              0 => 'below-range-half-boundary',
              1 => 'exact-red-stop',
              2 => 'exact-orange-stop',
              3 => 'exact-yellow-stop',
              4 => 'exact-light-green-stop',
              5 => 'exact-dark-green-stop',
              6 => 'exact-blue-stop',
              7 => 'first-segment-half-boundary',
              8 => 'second-segment-half-boundary',
              9 => 'middle-segments-interpolation',
              10 => 'last-segment-half-boundary',
              _ => 'above-range-half-boundary',
            },
            shrunk: false,
          );
        },
        shrink: (input) sync* {
          if (input.shrunk) return;
          yield (
            rawOvr: 49.5,
            generationSize: 0,
            scenario: 'shrunk-below-range-half-boundary',
            shrunk: true,
          );
        },
      );

  // Feature: squad-screen-redesign, Property 5: OVR presentation is rounded, interpolated and contrast-safe
  // **Validates: Requirements 6.1, 6.3–6.7**
  Glados<({double rawOvr, int generationSize, String scenario, bool shrunk})>(
    generatedPropertyFiveCases,
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(propertyFiveSeed),
    ),
  ).test(
    'Feature: squad-screen-redesign, Property 5: OVR presentation is rounded, '
    'interpolated and contrast-safe for $_propertyRuns generated cases',
    (input) {
      final reason =
          'seed=$propertyFiveSeed generationSize=${input.generationSize} '
          'scenario=${input.scenario} rawOvr=${input.rawOvr}';
      final expectedRounded = expectedRoundedOvr(input.rawOvr);
      final expectedColor = expectedInterpolatedOvrColor(expectedRounded);
      final actualRounded = roundedOvrForDisplay(input.rawOvr);
      final actualColor = ovrColorForRawValue(input.rawOvr);
      final roundedColor = ovrColorForRoundedValue(actualRounded);
      final foreground = foregroundForContrast(actualColor);

      expect(input.rawOvr.isFinite, isTrue, reason: reason);
      expect(actualRounded, expectedRounded, reason: reason);
      expect(actualRounded, isA<int>(), reason: reason);
      expect(actualColor.a, expectedColor.a, reason: reason);
      expect(actualColor.r, expectedColor.r, reason: reason);
      expect(actualColor.g, expectedColor.g, reason: reason);
      expect(actualColor.b, expectedColor.b, reason: reason);
      expect(roundedColor, actualColor, reason: reason);
      expect(
        contrastRatio(foreground, actualColor),
        greaterThanOrEqualTo(4.5),
        reason: '$reason foreground=$foreground background=$actualColor',
      );
    },
  );
}
