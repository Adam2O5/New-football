@Tags(['property'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import '../../helpers/fixtures/presentation_fixtures.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/position_group.dart';

const _propertyRuns = 120;
const _propertyTwoSeed = 8203;

void main() {
  final assignmentTemplate = _assignmentTemplatePlayer();
  // Feature: squad-screen-redesign, Property 2: Shared exact position assignments
  // **Validates: Requirements 4.1**
  Glados<_GeneratedAssignmentCase>(
    _generatedAssignmentCases(assignmentTemplate),
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(_propertyTwoSeed),
    ),
  ).test('Feature: squad-screen-redesign, Property 2: Shared exact position '
      'assignments holds for $_propertyRuns generated cases', (input) {
    final reason = input.diagnostics;
    final slots = FormationLayout.of(input.formation).slots;
    final directPlacements = placePlayersOnSlots(
      slots: slots,
      lineupPlayerIds: input.lineupPlayerIds,
      playersById: input.playersById,
    );
    final directAssignments = <String, AssignedSlot>{
      for (final placement in directPlacements)
        if (placement.player != null) placement.player!.id: placement.slot,
    };

    // The roster-row index and marker assignments intentionally come from
    // the same direct placements used by the production squad path.
    final rowIndex = positionAssignmentIndexFor(
      slots: slots,
      lineupPlayerIds: input.lineupPlayerIds,
      playersById: input.playersById,
    );
    final markerIndex = positionAssignmentIndexFromPlacements(directPlacements);
    final markerAssignments = assignmentsByPlayerIdFromPlacements(
      directPlacements,
    );
    final explicitRowAssignments = assignmentsByPlayerIdFor(
      slots: slots,
      lineupPlayerIds: input.lineupPlayerIds,
      playersById: input.playersById,
    );

    expect(
      input.lineupPlayerIds.toSet().length,
      input.lineupPlayerIds.length,
      reason: reason,
    );
    expect(
      input.lineupPlayerIds.every(
        (playerId) => input.playersById.containsKey(playerId),
      ),
      isTrue,
      reason: reason,
    );
    expect(directPlacements, hasLength(slots.length), reason: reason);
    expect(
      rowIndex.playerIds.toSet(),
      directAssignments.keys.toSet(),
      reason: '$reason row index IDs must match direct placements',
    );
    expect(
      markerIndex.playerIds.toSet(),
      directAssignments.keys.toSet(),
      reason: '$reason marker index IDs must match direct placements',
    );
    expect(
      markerAssignments.keys.toSet(),
      directAssignments.keys.toSet(),
      reason: '$reason marker assignment IDs must match direct placements',
    );
    expect(
      explicitRowAssignments.keys.toSet(),
      directAssignments.keys.toSet(),
      reason:
          '$reason explicit row assignment IDs must match direct placements',
    );

    for (final player in input.playersById.values) {
      final expectedSlot = directAssignments[player.id];
      final rowSlot = rowIndex[player.id];
      final markerSlot = markerIndex[player.id];
      final markerAssignment = markerAssignments[player.id];
      final explicitRowSlot = explicitRowAssignments[player.id];

      expect(
        rowSlot?.key,
        expectedSlot?.key,
        reason: '$reason row slot key for ${player.id}',
      );
      expect(
        markerSlot?.key,
        expectedSlot?.key,
        reason: '$reason marker slot key for ${player.id}',
      );
      expect(
        markerAssignment?.key,
        expectedSlot?.key,
        reason: '$reason marker projection slot key for ${player.id}',
      );
      expect(
        explicitRowSlot?.key,
        expectedSlot?.key,
        reason: '$reason explicit row slot key for ${player.id}',
      );

      // Compare the exact Position used by both consumers, not merely the
      // broader PositionGroup or the presence of an assignment.
      expect(
        rowSlot?.position,
        expectedSlot?.position,
        reason: '$reason row exact position for ${player.id}',
      );
      expect(
        markerSlot?.position,
        expectedSlot?.position,
        reason: '$reason marker exact position for ${player.id}',
      );
      expect(
        markerAssignment?.position,
        expectedSlot?.position,
        reason: '$reason marker projection exact position for ${player.id}',
      );
      expect(
        explicitRowSlot?.position,
        expectedSlot?.position,
        reason: '$reason explicit row exact position for ${player.id}',
      );
      expect(
        rowSlot?.position,
        markerSlot?.position,
        reason: '$reason row/marker exact position for ${player.id}',
      );

      final expectedMismatch =
          expectedSlot != null && player.position != expectedSlot.position;
      final rowStatus = statusFor(player, rowSlot);
      final markerStatus = statusFor(player, markerSlot);
      expect(
        rowStatus.hasPositionMismatch,
        expectedMismatch,
        reason: '$reason row mismatch state for ${player.id}',
      );
      expect(
        markerStatus.hasPositionMismatch,
        expectedMismatch,
        reason: '$reason marker mismatch state for ${player.id}',
      );

      if (expectedSlot == null) {
        expect(
          rowSlot,
          isNull,
          reason: '$reason missing row assignment for ${player.id}',
        );
        expect(
          markerSlot,
          isNull,
          reason: '$reason missing marker assignment for ${player.id}',
        );
        expect(
          rowStatus.hasPositionMismatch,
          isFalse,
          reason:
              '$reason missing assignment cannot mismatch in row for ${player.id}',
        );
        expect(
          markerStatus.hasPositionMismatch,
          isFalse,
          reason:
              '$reason missing assignment cannot mismatch in marker for ${player.id}',
        );
      }
    }
  });
}

Player _assignmentTemplatePlayer() {
  return presentationTeam().roster.first;
}

Generator<_GeneratedAssignmentCase> _generatedAssignmentCases(
  Player template,
) => any.simple<_GeneratedAssignmentCase>(
  generate: (random, size) {
    final scenario = size % 8;
    final formation = Formation.values[random.nextInt(Formation.values.length)];
    final slots = FormationLayout.of(formation).slots;
    final slotCount = slots.length;
    final mapCount = switch (scenario) {
      0 => 1 + random.nextInt(4),
      1 => 1 + random.nextInt(slotCount),
      2 || 3 => slotCount,
      4 => slotCount + 1 + random.nextInt(3),
      5 => 1 + random.nextInt(slotCount + 3),
      6 => slotCount + random.nextInt(4),
      _ => 2 + random.nextInt(slotCount + 1),
    };
    final token = random.nextInt(1 << 30);
    final playersById = <String, Player>{};
    for (var index = 0; index < mapCount; index++) {
      final id = 'p2-$size-$token-$index';
      final position = _generatedAssignmentPosition(
        scenario: scenario,
        index: index,
        slots: slots,
        random: random,
      );
      playersById[id] = template.copyWith(
        id: id,
        name: 'Property 2 $id',
        position: position,
      );
    }

    final lineupCount = switch (scenario) {
      0 => 0,
      1 => mapCount,
      2 || 3 => slotCount,
      4 || 6 => slotCount,
      5 => min(mapCount, 1 + random.nextInt(slotCount)),
      _ => random.nextInt(min(mapCount, slotCount) + 1),
    };
    final shuffledIds = playersById.keys.toList()..shuffle(random);
    final lineupPlayerIds = shuffledIds.take(lineupCount).toList();

    return _GeneratedAssignmentCase(
      formation: formation,
      lineupPlayerIds: lineupPlayerIds,
      playersById: playersById,
      generationSize: size,
      scenario: _assignmentScenarioName(scenario),
      shrunk: false,
    );
  },
  shrink: (input) sync* {
    if (input.shrunk) return;

    const gkId = 'p2-shrunk-gk';
    const cmId = 'p2-shrunk-cm';
    const reserveId = 'p2-shrunk-reserve';
    yield _GeneratedAssignmentCase(
      formation: Formation.f343,
      lineupPlayerIds: const [gkId, cmId],
      playersById: <String, Player>{
        gkId: template.copyWith(
          id: gkId,
          name: 'Property 2 shrunk goalkeeper',
          position: Position.gk,
        ),
        cmId: template.copyWith(
          id: cmId,
          name: 'Property 2 shrunk midfielder',
          position: Position.cm,
        ),
        reserveId: template.copyWith(
          id: reserveId,
          name: 'Property 2 shrunk reserve',
          position: Position.st,
        ),
      },
      generationSize: 0,
      scenario: 'shrunk',
      shrunk: true,
    );
  },
);

Position _generatedAssignmentPosition({
  required int scenario,
  required int index,
  required List<AssignedSlot> slots,
  required Random random,
}) {
  final slot = slots[index % slots.length];
  switch (scenario) {
    case 2:
      // Exact-position-heavy cases exercise the successful exact match path.
      return slot.position;
    case 3:
      // Same-group cases exercise the group fallback while retaining a valid
      // exact Position value for every generated player.
      final alternatives = Position.values
          .where(
            (position) =>
                position != slot.position &&
                positionGroupOf(position) == slot.group,
          )
          .toList();
      return alternatives.isEmpty
          ? slot.position
          : alternatives[index % alternatives.length];
    case 4:
      // Deliberately broad positions exercise exact/group/final-slot choices.
      return Position.values[(index + 1) % Position.values.length];
    default:
      return Position.values[random.nextInt(Position.values.length)];
  }
}

String _assignmentScenarioName(int scenario) => switch (scenario) {
  0 => 'empty-lineup-with-roster-players',
  1 => 'short-or-full-valid-lineup',
  2 => 'exact-slot-positions',
  3 => 'same-group-positions',
  4 => 'extra-roster-players',
  5 => 'permuted-subset-lineup',
  6 => 'full-slot-capacity-lineup',
  _ => 'random-valid-subset-lineup',
};

class _GeneratedAssignmentCase {
  const _GeneratedAssignmentCase({
    required this.formation,
    required this.lineupPlayerIds,
    required this.playersById,
    required this.generationSize,
    required this.scenario,
    required this.shrunk,
  });

  final Formation formation;
  final List<String> lineupPlayerIds;
  final Map<String, Player> playersById;
  final int generationSize;
  final String scenario;
  final bool shrunk;

  String get diagnostics {
    final players = playersById.values
        .map((player) => '${player.id}:${player.position.code}')
        .join(',');
    return 'seed=$_propertyTwoSeed generationSize=$generationSize '
        'scenario=$scenario formation=${formation.name} '
        'lineup=${lineupPlayerIds.join(',')} players=$players';
  }

  @override
  String toString() => diagnostics;
}
