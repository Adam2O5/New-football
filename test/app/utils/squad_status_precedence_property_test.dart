@Tags(['property'])
library;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import '../../helpers/fixtures/presentation_fixtures.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/position_group.dart';

const _propertyRuns = 120;
const _propertyThreeSeed = 8204;

void main() {
  // Feature: squad-screen-redesign, Property 3: Status color precedence is consistent
  // **Validates: Requirements 4.2–4.6, 5.10–5.11, 8.7**
  Glados<_GeneratedStatusCase>(
    _generatedStatusCases(_assignmentTemplatePlayer()),
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(_propertyThreeSeed),
    ),
  ).test(
    'Feature: squad-screen-redesign, Property 3: Status color precedence is '
    'consistent for $_propertyRuns generated cases',
    (input) {
      final reason = input.diagnostics;
      final rowStatus = statusFor(input.player, input.assignment);
      final markerStatus = squadStatusFor(
        player: input.player,
        assignment: input.assignment,
      );
      final rowColor = statusColorFor(rowStatus);
      final markerColor = statusColorFor(markerStatus);
      final directPlayerColor = statusColorForPlayer(
        input.player,
        input.assignment,
      );
      final expectedColor = input.hasActiveInjury || input.hasActiveSuspension
          ? Colors.red
          : input.hasPositionMismatch
          ? Colors.orange
          : Colors.white;

      // Injury and suspension are separate flags for both consumers, even
      // though both active flags intentionally resolve to one red color.
      expect(rowStatus.hasActiveInjury, input.hasActiveInjury, reason: reason);
      expect(
        rowStatus.hasActiveSuspension,
        input.hasActiveSuspension,
        reason: reason,
      );
      expect(
        markerStatus.hasActiveInjury,
        input.hasActiveInjury,
        reason: reason,
      );
      expect(
        markerStatus.hasActiveSuspension,
        input.hasActiveSuspension,
        reason: reason,
      );
      expect(
        rowStatus.hasPositionMismatch,
        input.hasPositionMismatch,
        reason: reason,
      );
      expect(
        markerStatus.hasPositionMismatch,
        input.hasPositionMismatch,
        reason: reason,
      );

      // The row and marker pure APIs must resolve the same precedence table.
      expect(rowColor, expectedColor, reason: reason);
      expect(markerColor, expectedColor, reason: reason);
      expect(directPlayerColor, expectedColor, reason: reason);
      expect(rowColor, markerColor, reason: reason);
      expect(rowStatus.color, rowColor, reason: reason);
      expect(markerStatus.color, markerColor, reason: reason);

      final activeStatus = input.hasActiveInjury || input.hasActiveSuspension;
      expect(
        rowColor == Colors.orange,
        input.hasPositionMismatch && !activeStatus,
        reason: reason,
      );
      expect(
        markerColor == Colors.orange,
        input.hasPositionMismatch && !activeStatus,
        reason: reason,
      );
      expect(
        rowColor == Colors.white,
        !activeStatus && !input.hasPositionMismatch,
        reason: reason,
      );
      expect(
        markerColor == Colors.white,
        !activeStatus && !input.hasPositionMismatch,
        reason: reason,
      );

      if (input.hasActiveInjury && input.hasActiveSuspension) {
        // Both independent active statuses still produce one red visual
        // result for each consumer; neither can be replaced by orange.
        expect(rowColor, Colors.red, reason: reason);
        expect(markerColor, Colors.red, reason: reason);
      }
    },
  );
}

Player _assignmentTemplatePlayer() {
  return presentationTeam().roster.first;
}

Generator<_GeneratedStatusCase> _generatedStatusCases(Player template) =>
    any.simple<_GeneratedStatusCase>(
      generate: (random, size) {
        // The eight scenario slots cover every combination of injury,
        // suspension, and exact match/mismatch while the random values vary
        // the concrete player and slot inputs.
        final scenario = size % 8;
        final hasActiveInjury = (scenario & 1) != 0;
        final hasActiveSuspension = (scenario & 2) != 0;
        final hasPositionMismatch = (scenario & 4) != 0;
        final playerPosition =
            Position.values[(size + random.nextInt(Position.values.length)) %
                Position.values.length];
        final assignmentPosition = hasPositionMismatch
            ? Position.values[(playerPosition.index + 1) %
                  Position.values.length]
            : playerPosition;
        final token = random.nextInt(1 << 30);
        final playerId = 'p3-$size-$token';
        final player = template.copyWith(
          id: playerId,
          name: 'Property 3 $playerId',
          position: playerPosition,
          state: template.state.copyWith(
            injury: hasActiveInjury
                ? const Injury(
                    id: 'squad-property-three-injury',
                    group: InjuryGroup.legMuscles,
                    type: InjuryType.minor,
                    daysTotal: 5,
                    daysRemaining: 2,
                  )
                : null,
            suspensionGamesRemaining: hasActiveSuspension ? 2 : 0,
          ),
        );
        final assignment = AssignedSlot(
          key: 'p3-slot-$size-$token',
          position: assignmentPosition,
          group: positionGroupOf(assignmentPosition),
          x: 0.5,
          y: 0.5,
        );

        return _GeneratedStatusCase(
          player: player,
          assignment: assignment,
          hasActiveInjury: hasActiveInjury,
          hasActiveSuspension: hasActiveSuspension,
          hasPositionMismatch: hasPositionMismatch,
          generationSize: size,
          token: token,
          scenario: _statusScenarioName(scenario),
          shrunk: false,
        );
      },
      shrink: (input) sync* {
        if (input.shrunk) return;

        final player = template.copyWith(
          id: 'p3-shrunk',
          name: 'Property 3 shrunk',
          position: Position.cm,
          state: template.state.copyWith(
            injury: const Injury(
              id: 'squad-property-three-shrunk-injury',
              group: InjuryGroup.legMuscles,
              type: InjuryType.minor,
              daysTotal: 5,
              daysRemaining: 2,
            ),
            suspensionGamesRemaining: 2,
          ),
        );
        final assignment = AssignedSlot(
          key: 'p3-shrunk-slot',
          position: Position.cdm,
          group: positionGroupOf(Position.cdm),
          x: 0.5,
          y: 0.5,
        );
        yield _GeneratedStatusCase(
          player: player,
          assignment: assignment,
          hasActiveInjury: true,
          hasActiveSuspension: true,
          hasPositionMismatch: true,
          generationSize: 0,
          token: 0,
          scenario: 'shrunk-both-active-mismatch',
          shrunk: true,
        );
      },
    );

String _statusScenarioName(int scenario) {
  final injury = (scenario & 1) != 0;
  final suspension = (scenario & 2) != 0;
  final mismatch = (scenario & 4) != 0;
  return 'injury=$injury suspension=$suspension '
      'position=${mismatch ? 'mismatch' : 'match'}';
}

class _GeneratedStatusCase {
  const _GeneratedStatusCase({
    required this.player,
    required this.assignment,
    required this.hasActiveInjury,
    required this.hasActiveSuspension,
    required this.hasPositionMismatch,
    required this.generationSize,
    required this.token,
    required this.scenario,
    required this.shrunk,
  });

  final Player player;
  final AssignedSlot assignment;
  final bool hasActiveInjury;
  final bool hasActiveSuspension;
  final bool hasPositionMismatch;
  final int generationSize;
  final int token;
  final String scenario;
  final bool shrunk;

  String get diagnostics =>
      'seed=$_propertyThreeSeed generationSize=$generationSize '
      'scenario=$scenario token=$token player=${player.id} '
      'playerPosition=${player.position.code} '
      'assignmentPosition=${assignment.position.code} '
      'injury=$hasActiveInjury suspension=$hasActiveSuspension '
      'mismatch=$hasPositionMismatch';

  @override
  String toString() => diagnostics;
}
