@Tags(['property'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/color_interpolation.dart';

import '../../helpers/presentation/form_color_oracle.dart';

const _propertyRuns = 120;
const _propertySixSeed = 8207;

void main() {
  Glados<_GeneratedFormPresentationCase>(
    _generatedFormPresentationCases,
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(_propertySixSeed),
    ),
  ).test('Feature: squad-screen-redesign, Property 6: Form presentation is '
      'clamped, proportional and interpolated for $_propertyRuns generated '
      'cases', (input) {
    final reason = input.diagnostics;
    final expectedClamped = expectedClampedFormForPropertySix(input.rawForm);
    final actualClamped = clampedFormValue(input.rawForm);
    final actualFill = formFillForValue(input.rawForm);
    final expectedColor = expectedFormColorForPropertySix(expectedClamped);
    final actualColor = formColorForClampedValue(input.rawForm);

    expect(input.rawForm.isFinite, isTrue, reason: reason);
    expect(actualClamped, expectedClamped, reason: reason);
    expect(actualClamped.isFinite, isTrue, reason: reason);
    expect(
      actualClamped,
      allOf(greaterThanOrEqualTo(0.0), lessThanOrEqualTo(10.0)),
      reason: reason,
    );
    expect(
      actualFill,
      closeTo(expectedClamped / 10.0, 0.000000000001),
      reason: reason,
    );
    expect(
      actualFill,
      allOf(greaterThanOrEqualTo(0.0), lessThanOrEqualTo(1.0)),
      reason: reason,
    );

    // Compare every channel so exact stop colors and independently computed
    // channel interpolation are both covered by the generated cases.
    expect(actualColor.a, expectedColor.a, reason: reason);
    expect(actualColor.r, expectedColor.r, reason: reason);
    expect(actualColor.g, expectedColor.g, reason: reason);
    expect(actualColor.b, expectedColor.b, reason: reason);
  });
}

final Generator<_GeneratedFormPresentationCase>
_generatedFormPresentationCases = any.simple<_GeneratedFormPresentationCase>(
  generate: (random, size) {
    final scenario = size % 14;
    final rawForm = switch (scenario) {
      0 => -1.0 - random.nextInt(1001),
      1 => 0.0,
      2 => 1.0,
      3 => formValueBetween(random, 1.0, 3.0),
      4 => 3.0,
      5 => formValueBetween(random, 3.0, 5.0),
      6 => 5.0,
      7 => formValueBetween(random, 5.0, 7.0),
      8 => 7.0,
      9 => formValueBetween(random, 7.0, 9.0),
      10 => 9.0,
      11 => formValueBetween(random, 9.0, 10.0),
      12 => 10.0,
      _ => 11.0 + random.nextInt(1001),
    };

    return _GeneratedFormPresentationCase(
      rawForm: rawForm,
      generationSize: size,
      scenario: formScenarioName(scenario),
      shrunk: false,
    );
  },
  shrink: (input) sync* {
    if (input.shrunk) return;
    yield const _GeneratedFormPresentationCase(
      rawForm: -1.0,
      generationSize: 0,
      scenario: 'shrunk-below-zero',
      shrunk: true,
    );
  },
);

class _GeneratedFormPresentationCase {
  const _GeneratedFormPresentationCase({
    required this.rawForm,
    required this.generationSize,
    required this.scenario,
    required this.shrunk,
  });

  final double rawForm;
  final int generationSize;
  final String scenario;
  final bool shrunk;

  String get diagnostics =>
      'seed=$_propertySixSeed generationSize=$generationSize '
      'scenario=$scenario rawForm=$rawForm';

  @override
  String toString() => diagnostics;
}
