@Tags(['property'])
library;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/squad_presentation.dart';

const _propertyRuns = 120;
const _propertySeed = 8202;

void main() {
  // Feature: squad-screen-redesign, Property 1: Roster size projection is bounded and state-consistent
  // **Validates: Requirements 2.3, 2.4, 2.5, 2.6, 2.7, 2.9, 11.2**
  Glados<_GeneratedRosterSize>(
    _generatedRosterSizes,
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(_propertySeed),
    ),
  ).test(
    'Feature: squad-screen-redesign, Property 1: Roster size projection is '
    'bounded and state-consistent for $_propertyRuns generated cases',
    (input) {
      final expectedInRange =
          input.count >= input.min && input.count <= input.max;
      final expectedProgress =
          ((input.count - input.min) / (input.max - input.min))
              .clamp(0.0, 1.0)
              .toDouble();
      final projection = rosterSizePresentation(
        count: input.count,
        min: input.min,
        max: input.max,
      );
      final reason = input.diagnostics;

      expect(input.min, lessThan(input.max), reason: reason);
      expect(
        projection.clampedProgress,
        allOf(greaterThanOrEqualTo(0.0), lessThanOrEqualTo(1.0)),
        reason: reason,
      );
      expect(
        projection.clampedProgress,
        closeTo(expectedProgress, 0.000000000001),
        reason: reason,
      );

      // The projection must preserve the live inputs exposed to semantics,
      // rather than only exposing the derived progress value.
      expect(projection.count, input.count, reason: reason);
      expect(projection.min, input.min, reason: reason);
      expect(projection.max, input.max, reason: reason);
      expect(projection.isInRange, expectedInRange, reason: reason);
      expect(projection.isOutOfRange, !expectedInRange, reason: reason);

      if (expectedInRange) {
        expect(projection.state, RosterSizeState.inRange, reason: reason);
        expect(projection.trackColor, Colors.green, reason: reason);
        expect(projection.iconState, RosterSizeIconState.check, reason: reason);
        expect(projection.iconToken, 'check', reason: reason);
      } else {
        expect(projection.state, RosterSizeState.outOfRange, reason: reason);
        expect(projection.trackColor, Colors.red, reason: reason);
        expect(projection.iconState, RosterSizeIconState.x, reason: reason);
        expect(projection.iconToken, 'x', reason: reason);
      }
    },
  );
}

final Generator<_GeneratedRosterSize> _generatedRosterSizes = any
    .simple<_GeneratedRosterSize>(
      generate: (random, size) {
        final min = random.nextInt(200001) - 100000;
        final width = random.nextInt(1000) + 1;
        final max = min + width;
        final scenario = size % 5;
        final count = switch (scenario) {
          0 => min - random.nextInt(1001) - 1,
          1 => min,
          2 => min + random.nextInt(width + 1),
          3 => max,
          _ => max + random.nextInt(1001) + 1,
        };

        return _GeneratedRosterSize(
          min: min,
          max: max,
          count: count,
          generationSize: size,
          scenario: _scenarioName(scenario),
        );
      },
      shrink: (input) sync* {
        if (input.min == 0 && input.max == 1 && input.count == 0) return;
        yield const _GeneratedRosterSize(
          min: 0,
          max: 1,
          count: 0,
          generationSize: 0,
          scenario: 'shrunk-minimum',
        );
      },
    );

String _scenarioName(int scenario) => switch (scenario) {
  0 => 'below-minimum',
  1 => 'at-minimum',
  2 => 'inside-range',
  3 => 'at-maximum',
  _ => 'above-maximum',
};

class _GeneratedRosterSize {
  const _GeneratedRosterSize({
    required this.min,
    required this.max,
    required this.count,
    required this.generationSize,
    required this.scenario,
  });

  final int min;
  final int max;
  final int count;
  final int generationSize;
  final String scenario;

  String get diagnostics =>
      'seed=$_propertySeed generationSize=$generationSize '
      'scenario=$scenario min=$min max=$max count=$count';
}
