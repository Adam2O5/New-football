import 'dart:math';
import 'dart:ui' show Color;
import 'package:flutter/material.dart' show Colors;
import 'package:new_football/app/utils/color_interpolation.dart' show ColorStop;

const propertySixFormStops = <ColorStop>[
  ColorStop(value: 1, color: Colors.red),
  ColorStop(value: 3, color: Colors.orange),
  ColorStop(value: 5, color: Colors.yellow),
  ColorStop(value: 7, color: Colors.lightGreen),
  ColorStop(value: 9, color: Color(0xFF2E7D32)),
  ColorStop(value: 10, color: Colors.blue),
];

double formValueBetween(Random random, double lower, double upper) {
  const subdivisions = 1000;
  final numerator = 1 + random.nextInt(subdivisions - 1);
  return lower + ((upper - lower) * (numerator / subdivisions));
}

String formScenarioName(int scenario) => switch (scenario) {
  0 => 'below-zero',
  1 => 'at-zero',
  2 => 'at-one',
  3 => 'between-one-and-three',
  4 => 'at-three',
  5 => 'between-three-and-five',
  6 => 'at-five',
  7 => 'between-five-and-seven',
  8 => 'at-seven',
  9 => 'between-seven-and-nine',
  10 => 'at-nine',
  11 => 'between-nine-and-ten',
  12 => 'at-ten',
  _ => 'above-ten',
};

double expectedClampedFormForPropertySix(double rawForm) {
  if (rawForm.isNaN || rawForm == double.negativeInfinity) return 0.0;
  if (rawForm == double.infinity) return 10.0;
  return rawForm.clamp(0.0, 10.0).toDouble();
}

Color expectedFormColorForPropertySix(double clampedForm) {
  final value = expectedClampedFormForPropertySix(clampedForm);
  final first = propertySixFormStops.first;
  final last = propertySixFormStops.last;
  if (value <= first.value) return first.color;
  if (value >= last.value) return last.color;

  for (var index = 1; index < propertySixFormStops.length; index++) {
    final upper = propertySixFormStops[index];
    if (value <= upper.value) {
      final lower = propertySixFormStops[index - 1];
      if (value == upper.value) return upper.color;
      final fraction = ((value - lower.value) / (upper.value - lower.value))
          .clamp(0.0, 1.0)
          .toDouble();
      return interpolatePropertySixColor(lower.color, upper.color, fraction);
    }
  }

  return last.color;
}

Color interpolatePropertySixColor(Color lower, Color upper, double fraction) {
  return Color.fromARGB(
    interpolatePropertySixChannel(lower.a, upper.a, fraction),
    interpolatePropertySixChannel(lower.r, upper.r, fraction),
    interpolatePropertySixChannel(lower.g, upper.g, fraction),
    interpolatePropertySixChannel(lower.b, upper.b, fraction),
  );
}

int interpolatePropertySixChannel(double lower, double upper, double fraction) {
  final lowerByte = (lower * 255.0).round();
  final upperByte = (upper * 255.0).round();
  return (lowerByte + ((upperByte - lowerByte) * fraction))
      .round()
      .clamp(0, 255)
      .toInt();
}
