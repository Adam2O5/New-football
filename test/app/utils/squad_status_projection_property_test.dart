@Tags(['property'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/squad_presentation.dart';

const _propertyRuns = 120;

void main() {
  const squadRowPropertyTwoSeed = 8211;
  final generatedSquadRowPropertyTwoCases = any
      .simple<
        ({
          SquadStatus source,
          bool hasActiveInjury,
          bool hasActiveSuspension,
          int generationSize,
          String scenario,
          bool shrunk,
        })
      >(
        generate: (_, size) {
          final scenario = size % 4;
          final hasActiveInjury = scenario == 1 || scenario == 3;
          final hasActiveSuspension = scenario == 2 || scenario == 3;
          return (
            source: SquadStatus(
              hasActiveInjury: hasActiveInjury,
              hasActiveSuspension: hasActiveSuspension,
            ),
            hasActiveInjury: hasActiveInjury,
            hasActiveSuspension: hasActiveSuspension,
            generationSize: size,
            scenario: switch (scenario) {
              0 => 'none',
              1 => 'injury-only',
              2 => 'suspension-only',
              _ => 'both-active',
            },
            shrunk: false,
          );
        },
        shrink: (input) sync* {
          if (input.shrunk) return;
          yield (
            source: const SquadStatus(),
            hasActiveInjury: false,
            hasActiveSuspension: false,
            generationSize: 0,
            scenario: 'shrunk-none-active',
            shrunk: true,
          );
        },
      );

  // Feature: squad-row-polish, Property 2: Status projection preserves visual priority and semantic state
  // **Validates: Requirements 2.2, 2.3, 2.4, 2.5, 2.6, 2.7**
  Glados<
        ({
          SquadStatus source,
          bool hasActiveInjury,
          bool hasActiveSuspension,
          int generationSize,
          String scenario,
          bool shrunk,
        })
      >(
        generatedSquadRowPropertyTwoCases,
        ExploreConfig(
          numRuns: _propertyRuns,
          initialSize: 8,
          speed: 1,
          random: Random(squadRowPropertyTwoSeed),
        ),
      )
      .test(
        'Feature: squad-row-polish, Property 2: Status projection preserves visual priority and semantic state',
        (input) {
          final reason =
              'seed=$squadRowPropertyTwoSeed '
              'generationSize=${input.generationSize} '
              'scenario=${input.scenario}';
          final source = input.source;
          final sourceInjuryBefore = source.hasActiveInjury;
          final sourceSuspensionBefore = source.hasActiveSuspension;
          final projection = statusSlotPresentation(source);
          final expectedVisual = input.hasActiveInjury
              ? StatusVisualKind.injury
              : input.hasActiveSuspension
              ? StatusVisualKind.suspension
              : StatusVisualKind.none;
          final expectedSemanticStatuses = <StatusVisualKind>[
            if (input.hasActiveInjury) StatusVisualKind.injury,
            if (input.hasActiveSuspension) StatusVisualKind.suspension,
          ];

          // The projection keeps both independent source flags visible.
          expect(source.hasActiveInjury, input.hasActiveInjury, reason: reason);
          expect(
            source.hasActiveSuspension,
            input.hasActiveSuspension,
            reason: reason,
          );
          expect(
            projection.hasActiveInjury,
            input.hasActiveInjury,
            reason: reason,
          );
          expect(
            projection.hasActiveSuspension,
            input.hasActiveSuspension,
            reason: reason,
          );

          // Injury has visual priority, while semantic meanings retain their
          // complete stable injury-then-suspension order.
          expect(projection.visual, expectedVisual, reason: reason);
          expect(
            projection.semanticStatuses,
            orderedEquals(expectedSemanticStatuses),
            reason: reason,
          );

          // Resolving the projection must not mutate the source status.
          expect(source.hasActiveInjury, sourceInjuryBefore, reason: reason);
          expect(
            source.hasActiveSuspension,
            sourceSuspensionBefore,
            reason: reason,
          );
        },
      );
}
