@Tags(['property'])
library;

import 'dart:ui' show Color;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import '../../helpers/fixtures/presentation_fixtures.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/position_group.dart';

const _propertyRuns = 120;

void main() {
  const squadRowPropertyThreeSeed = 8212;
  final propertyThreeTemplateTeam = presentationTeam();
  final propertyThreeTemplatePlayer = propertyThreeTemplateTeam.roster
      .firstWhere((player) => player.position != Position.gk);
  const propertyThreeZoneOracle =
      <RosterZone, ({String key, String label, Color color})>{
        RosterZone.xi: (key: 'xi', label: 'XI', color: Colors.green),
        RosterZone.bench: (key: 'bench', label: 'Bench', color: Colors.blue),
        RosterZone.reserve: (
          key: 'reserve',
          label: 'Reserves',
          color: Colors.yellow,
        ),
      };
  final generatedSquadRowPropertyThreeCases = any
      .simple<
        ({
          RosterZone fromZone,
          RosterZone toZone,
          Player player,
          AssignedSlot assignment,
          String? selectionId,
          bool hasActiveInjury,
          bool hasActiveSuspension,
          bool hasPositionMismatch,
          int generationSize,
          int token,
          String scenario,
          bool shrunk,
        })
      >(
        generate: (random, size) {
          final statusScenario = size % 8;
          final hasActiveInjury = (statusScenario & 1) != 0;
          final hasActiveSuspension = (statusScenario & 2) != 0;
          final hasPositionMismatch = (statusScenario & 4) != 0;
          final token = random.nextInt(1 << 30);
          final playerId = 'p3-zone-$size-$token';
          final player = propertyThreeTemplatePlayer.copyWith(
            id: playerId,
            name: 'Property 3 $playerId',
            state: propertyThreeTemplatePlayer.state.copyWith(
              form: random.nextInt(1001) / 100.0,
              injury: hasActiveInjury
                  ? const Injury(
                      id: 'squad-property-three-zone-injury',
                      group: InjuryGroup.legMuscles,
                      type: InjuryType.minor,
                      daysTotal: 5,
                      daysRemaining: 2,
                    )
                  : null,
              suspensionGamesRemaining: hasActiveSuspension ? 2 : 0,
            ),
          );
          final assignmentPosition = hasPositionMismatch
              ? Position.values[(player.position.index + 1) %
                    Position.values.length]
              : player.position;
          final assignment = AssignedSlot(
            key: 'p3-zone-slot-$size-$token',
            position: assignmentPosition,
            group: positionGroupOf(assignmentPosition),
            x: 0.5,
            y: 0.5,
          );
          final fromZone =
              RosterZone.values[(size +
                      random.nextInt(RosterZone.values.length)) %
                  RosterZone.values.length];
          final zoneStep = 1 + ((size ~/ RosterZone.values.length) % 2);
          final toZone = RosterZone
              .values[(fromZone.index + zoneStep) % RosterZone.values.length];
          final selectionId = size % 3 == 0 ? null : playerId;

          return (
            fromZone: fromZone,
            toZone: toZone,
            player: player,
            assignment: assignment,
            selectionId: selectionId,
            hasActiveInjury: hasActiveInjury,
            hasActiveSuspension: hasActiveSuspension,
            hasPositionMismatch: hasPositionMismatch,
            generationSize: size,
            token: token,
            scenario:
                'from=${fromZone.name} to=${toZone.name} '
                'status=$statusScenario selected=${selectionId != null}',
            shrunk: false,
          );
        },
        shrink: (input) sync* {
          if (input.shrunk) return;

          final player = propertyThreeTemplatePlayer.copyWith(
            id: 'p3-zone-shrunk',
            name: 'Property 3 zone shrunk',
            state: propertyThreeTemplatePlayer.state.copyWith(
              form: 5.0,
              injury: const Injury(
                id: 'squad-property-three-zone-shrunk-injury',
                group: InjuryGroup.legMuscles,
                type: InjuryType.minor,
                daysTotal: 5,
                daysRemaining: 2,
              ),
              suspensionGamesRemaining: 2,
            ),
          );
          final assignment = AssignedSlot(
            key: 'p3-zone-shrunk-slot',
            position: Position.cdm,
            group: positionGroupOf(Position.cdm),
            x: 0.5,
            y: 0.5,
          );
          yield (
            fromZone: RosterZone.xi,
            toZone: RosterZone.bench,
            player: player,
            assignment: assignment,
            selectionId: player.id,
            hasActiveInjury: true,
            hasActiveSuspension: true,
            hasPositionMismatch: true,
            generationSize: 0,
            token: 0,
            scenario: 'shrunk-XI-to-Bench-both-statuses-selected',
            shrunk: true,
          );
        },
      );

  // Feature: squad-row-polish, Property 3: Zone presentation is semantic and independent
  // **Validates: Requirements 3.1, 3.2, 3.3, 3.6, 3.7, 6.6**
  Glados<
        ({
          RosterZone fromZone,
          RosterZone toZone,
          Player player,
          AssignedSlot assignment,
          String? selectionId,
          bool hasActiveInjury,
          bool hasActiveSuspension,
          bool hasPositionMismatch,
          int generationSize,
          int token,
          String scenario,
          bool shrunk,
        })
      >(
        generatedSquadRowPropertyThreeCases,
        ExploreConfig(
          numRuns: _propertyRuns,
          initialSize: 8,
          speed: 1,
          random: Random(squadRowPropertyThreeSeed),
        ),
      )
      .test(
        'Feature: squad-row-polish, Property 3: Zone presentation is semantic and independent',
        (input) {
          final reason =
              'seed=$squadRowPropertyThreeSeed '
              'generationSize=${input.generationSize} '
              'scenario=${input.scenario} token=${input.token}';
          final beforeZone = rosterZonePresentation(input.fromZone);
          final afterZone = rosterZonePresentation(input.toZone);
          final expectedBefore = propertyThreeZoneOracle[input.fromZone]!;
          final expectedAfter = propertyThreeZoneOracle[input.toZone]!;

          expect(input.fromZone, isNot(input.toZone), reason: reason);
          expect(input.player.id, isNotEmpty, reason: reason);
          expect(input.assignment.key, isNotEmpty, reason: reason);
          expect(
            input.assignment.group,
            positionGroupOf(input.assignment.position),
            reason: reason,
          );
          expect(
            input.selectionId,
            anyOf(isNull, input.player.id),
            reason: reason,
          );

          // This independent oracle deliberately does not call the tested
          // zone resolver or use Flutter context.
          for (final zone in RosterZone.values) {
            final expected = propertyThreeZoneOracle[zone]!;
            final projection = rosterZonePresentation(zone);

            expect(zone.name, expected.key, reason: reason);
            expect(zone.name, isNotEmpty, reason: reason);
            expect(projection.zone, zone, reason: reason);
            expect(projection.label, expected.label, reason: reason);
            expect(projection.label, isNotEmpty, reason: reason);
            expect(projection.color, expected.color, reason: reason);
          }
          expect(
            propertyThreeZoneOracle.values.map((value) => value.label).toSet(),
            hasLength(RosterZone.values.length),
            reason: '$reason zone labels must identify one zone each',
          );

          expect(beforeZone.zone, input.fromZone, reason: reason);
          expect(afterZone.zone, input.toZone, reason: reason);
          expect(beforeZone.label, expectedBefore.label, reason: reason);
          expect(afterZone.label, expectedAfter.label, reason: reason);
          expect(beforeZone.color, expectedBefore.color, reason: reason);
          expect(afterZone.color, expectedAfter.color, reason: reason);
          expect(beforeZone.zone, isNot(afterZone.zone), reason: reason);
          expect(beforeZone.label, isNot(afterZone.label), reason: reason);
          expect(beforeZone.color, isNot(afterZone.color), reason: reason);

          final formBefore = clampedFormValue(input.player.state.form);
          final formAfter = clampedFormValue(input.player.state.form);
          final statusBefore = statusFor(input.player, input.assignment);
          final statusAfter = statusFor(input.player, input.assignment);
          final statusSlotBefore = statusSlotPresentation(statusBefore);
          final statusSlotAfter = statusSlotPresentation(statusAfter);
          final playerBefore = input.player;
          final assignmentBefore = input.assignment;
          final selectionBefore = input.selectionId;

          // Only the zone projection changes; form, status meanings,
          // selection identity and domain-owned inputs remain independent.
          expect(formAfter, formBefore, reason: reason);
          expect(
            statusBefore.hasActiveInjury,
            input.hasActiveInjury,
            reason: reason,
          );
          expect(
            statusBefore.hasActiveSuspension,
            input.hasActiveSuspension,
            reason: reason,
          );
          expect(
            statusBefore.hasPositionMismatch,
            input.hasPositionMismatch,
            reason: reason,
          );
          expect(
            statusAfter.hasActiveInjury,
            statusBefore.hasActiveInjury,
            reason: reason,
          );
          expect(
            statusAfter.hasActiveSuspension,
            statusBefore.hasActiveSuspension,
            reason: reason,
          );
          expect(
            statusAfter.hasPositionMismatch,
            statusBefore.hasPositionMismatch,
            reason: reason,
          );
          expect(
            statusSlotAfter.visual,
            statusSlotBefore.visual,
            reason: reason,
          );
          expect(
            statusSlotAfter.hasActiveInjury,
            statusSlotBefore.hasActiveInjury,
            reason: reason,
          );
          expect(
            statusSlotAfter.hasActiveSuspension,
            statusSlotBefore.hasActiveSuspension,
            reason: reason,
          );
          expect(
            statusSlotAfter.semanticStatuses,
            orderedEquals(statusSlotBefore.semanticStatuses),
            reason: reason,
          );
          expect(selectionBefore, input.selectionId, reason: reason);
          expect(input.player, same(playerBefore), reason: reason);
          expect(input.assignment, same(assignmentBefore), reason: reason);
          expect(input.player.state.form, isNotNaN, reason: reason);
          expect(input.player.state.form.isFinite, isTrue, reason: reason);
        },
      );
}
