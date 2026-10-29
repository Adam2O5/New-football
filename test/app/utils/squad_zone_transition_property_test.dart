@Tags(['property'])
library;

import 'dart:ui' show Color;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import '../../helpers/fixtures/presentation_fixtures.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/position_group.dart';

const _propertyRuns = 120;
const _propertySevenSeed = 8208;

void main() {
  final zoneTemplateTeam = _propertySevenTemplateTeam();
  final zoneTemplatePlayer = zoneTemplateTeam.roster.first;
  Glados<_GeneratedZonePresentationCase>(
    _generatedZonePresentationCases(zoneTemplatePlayer),
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(_propertySevenSeed),
    ),
  ).test('Feature: squad-screen-redesign, Property 7: Zone presentation is '
      'stable and independent for $_propertyRuns generated cases', (input) {
    final reason = input.diagnostics;
    final beforeTeam = _propertySevenTeamForZone(
      zoneTemplateTeam,
      input.player,
      input.fromZone,
    );
    final afterTeam = _propertySevenTeamForZone(
      zoneTemplateTeam,
      input.player,
      input.toZone,
    );
    final beforeLineup = List<String>.from(beforeTeam.lineupPlayerIds);
    final beforeBench = List<String>.from(beforeTeam.benchPlayerIds);
    final afterLineup = List<String>.from(afterTeam.lineupPlayerIds);
    final afterBench = List<String>.from(afterTeam.benchPlayerIds);

    final beforeZone = rosterZoneOf(beforeTeam, input.player.id);
    final afterZone = rosterZoneOf(afterTeam, input.player.id);
    expect(beforeZone, input.fromZone, reason: reason);
    expect(afterZone, input.toZone, reason: reason);
    expect(beforeZone, isNot(afterZone), reason: reason);

    // Every zone has one stable, non-empty label and one semantic color.
    final allLabels = <String>{
      for (final zone in RosterZone.values) rosterZoneLabel(zone),
    };
    expect(allLabels, hasLength(RosterZone.values.length), reason: reason);
    expect(allLabels, everyElement(isNotEmpty), reason: reason);

    for (final zone in RosterZone.values) {
      final expected = _propertySevenExpectedZonePresentation[zone]!;
      final presentation = rosterZonePresentation(zone);

      expect(presentation.zone, zone, reason: reason);
      expect(presentation.label, expected.$1, reason: reason);
      expect(presentation.accessibilityLabel, expected.$1, reason: reason);
      expect(presentation.color, expected.$2, reason: reason);
      expect(rosterZoneLabel(zone), expected.$1, reason: reason);
      expect(rosterZoneColor(zone), expected.$2, reason: reason);
      expect(
        RosterZone.values.where(
          (candidate) => rosterZoneLabel(candidate) == presentation.label,
        ),
        hasLength(1),
        reason: '$reason exactly one label for ${zone.name}',
      );
    }

    final beforeZonePresentation = rosterZonePresentation(beforeZone);
    final afterZonePresentation = rosterZonePresentation(afterZone);
    final beforeSnapshot = playerPresentation(
      player: input.player,
      team: beforeTeam,
      assignment: input.assignment,
    );
    final afterSnapshot = playerPresentation(
      player: input.player,
      team: afterTeam,
      assignment: input.assignment,
    );
    final expectedBefore = _propertySevenExpectedZonePresentation[beforeZone]!;
    final expectedAfter = _propertySevenExpectedZonePresentation[afterZone]!;

    expect(beforeZonePresentation.label, expectedBefore.$1, reason: reason);
    expect(beforeZonePresentation.color, expectedBefore.$2, reason: reason);
    expect(afterZonePresentation.label, expectedAfter.$1, reason: reason);
    expect(afterZonePresentation.color, expectedAfter.$2, reason: reason);
    expect(beforeZonePresentation.color, isNot(afterZonePresentation.color));
    expect(
      beforeSnapshot.zoneLabel,
      beforeZonePresentation.label,
      reason: reason,
    );
    expect(
      afterSnapshot.zoneLabel,
      afterZonePresentation.label,
      reason: reason,
    );
    expect(
      beforeSnapshot.semanticSnapshot.zoneLabel,
      beforeZonePresentation.label,
      reason: reason,
    );
    expect(
      afterSnapshot.semanticSnapshot.zoneLabel,
      afterZonePresentation.label,
      reason: reason,
    );

    // Changing XI/Bench/Reserves must not alter the independent status
    // truth table or make status color depend on the frame's zone color.
    final expectedStatusColor =
        input.hasActiveInjury || input.hasActiveSuspension
        ? Colors.red
        : input.hasPositionMismatch
        ? Colors.orange
        : Colors.white;
    for (final status in [beforeSnapshot.status, afterSnapshot.status]) {
      expect(status.hasActiveInjury, input.hasActiveInjury, reason: reason);
      expect(
        status.hasActiveSuspension,
        input.hasActiveSuspension,
        reason: reason,
      );
      expect(
        status.hasPositionMismatch,
        input.hasPositionMismatch,
        reason: reason,
      );
      expect(statusColorFor(status), expectedStatusColor, reason: reason);
      expect(status.color, expectedStatusColor, reason: reason);
    }
    expect(
      statusColorForPlayer(input.player, input.assignment),
      expectedStatusColor,
      reason: reason,
    );
    expect(
      beforeSnapshot.status.color,
      afterSnapshot.status.color,
      reason: reason,
    );
    expect(beforeSnapshot.status.color, isNot(beforeZonePresentation.color));

    // Presentation must not mutate either team's assignment lists.
    expect(beforeTeam.lineupPlayerIds, beforeLineup, reason: reason);
    expect(beforeTeam.benchPlayerIds, beforeBench, reason: reason);
    expect(afterTeam.lineupPlayerIds, afterLineup, reason: reason);
    expect(afterTeam.benchPlayerIds, afterBench, reason: reason);
  });
}

const _propertySevenExpectedZonePresentation = <RosterZone, (String, Color)>{
  RosterZone.xi: ('XI', Colors.green),
  RosterZone.bench: ('Bench', Colors.blue),
  RosterZone.reserve: ('Reserves', Colors.yellow),
};

Team _propertySevenTemplateTeam() {
  return presentationTeam();
}

Team _propertySevenTeamForZone(Team template, Player player, RosterZone zone) {
  return template.copyWith(
    roster: [player],
    lineupPlayerIds: zone == RosterZone.xi ? [player.id] : const [],
    benchPlayerIds: zone == RosterZone.bench ? [player.id] : const [],
  );
}

Generator<_GeneratedZonePresentationCase> _generatedZonePresentationCases(
  Player template,
) => any.simple<_GeneratedZonePresentationCase>(
  generate: (random, size) {
    // The first six scenarios cover every distinct non-self zone transition;
    // the eight status scenarios cover every injury/suspension/mismatch truth
    // table while randomizing the concrete player and assignment values.
    final transition = size % 6;
    final fromZone = RosterZone.values[transition % RosterZone.values.length];
    final zoneStep = transition < RosterZone.values.length ? 1 : 2;
    final toZone = RosterZone
        .values[(fromZone.index + zoneStep) % RosterZone.values.length];
    final statusScenario = size % 8;
    final hasActiveInjury = (statusScenario & 1) != 0;
    final hasActiveSuspension = (statusScenario & 2) != 0;
    final hasPositionMismatch = (statusScenario & 4) != 0;
    final playerPosition = template.position;
    final assignmentPosition = hasPositionMismatch
        ? Position.values[(playerPosition.index + 1) % Position.values.length]
        : playerPosition;
    final token = random.nextInt(1 << 30);
    final playerId = 'p7-$size-$token';
    final player = template.copyWith(
      id: playerId,
      name: 'Property 7 $playerId',
      position: playerPosition,
      state: template.state.copyWith(
        injury: hasActiveInjury
            ? const Injury(
                id: 'squad-property-seven-injury',
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
      key: 'p7-slot-$size-$token',
      position: assignmentPosition,
      group: positionGroupOf(assignmentPosition),
      x: 0.5,
      y: 0.5,
    );

    return _GeneratedZonePresentationCase(
      fromZone: fromZone,
      toZone: toZone,
      player: player,
      assignment: assignment,
      hasActiveInjury: hasActiveInjury,
      hasActiveSuspension: hasActiveSuspension,
      hasPositionMismatch: hasPositionMismatch,
      generationSize: size,
      token: token,
      transitionScenario: _propertySevenTransitionScenarioName(
        fromZone,
        toZone,
      ),
      statusScenario: _propertySevenStatusScenarioName(statusScenario),
      shrunk: false,
    );
  },
  shrink: (input) sync* {
    if (input.shrunk) return;

    final player = template.copyWith(
      id: 'p7-shrunk',
      name: 'Property 7 shrunk',
      position: Position.cm,
      state: template.state.copyWith(
        injury: const Injury(
          id: 'squad-property-seven-shrunk-injury',
          group: InjuryGroup.legMuscles,
          type: InjuryType.minor,
          daysTotal: 5,
          daysRemaining: 2,
        ),
        suspensionGamesRemaining: 2,
      ),
    );
    yield _GeneratedZonePresentationCase(
      fromZone: RosterZone.xi,
      toZone: RosterZone.bench,
      player: player,
      assignment: AssignedSlot(
        key: 'p7-shrunk-slot',
        position: Position.cdm,
        group: positionGroupOf(Position.cdm),
        x: 0.5,
        y: 0.5,
      ),
      hasActiveInjury: true,
      hasActiveSuspension: true,
      hasPositionMismatch: true,
      generationSize: 0,
      token: 0,
      transitionScenario: 'XI-to-Bench',
      statusScenario: 'injury=true suspension=true position=mismatch',
      shrunk: true,
    );
  },
);

String _propertySevenTransitionScenarioName(
  RosterZone fromZone,
  RosterZone toZone,
) => '${fromZone.name}-to-${toZone.name}';

String _propertySevenStatusScenarioName(int scenario) {
  final injury = (scenario & 1) != 0;
  final suspension = (scenario & 2) != 0;
  final mismatch = (scenario & 4) != 0;
  return 'injury=$injury suspension=$suspension '
      'position=${mismatch ? 'mismatch' : 'match'}';
}

class _GeneratedZonePresentationCase {
  const _GeneratedZonePresentationCase({
    required this.fromZone,
    required this.toZone,
    required this.player,
    required this.assignment,
    required this.hasActiveInjury,
    required this.hasActiveSuspension,
    required this.hasPositionMismatch,
    required this.generationSize,
    required this.token,
    required this.transitionScenario,
    required this.statusScenario,
    required this.shrunk,
  });

  final RosterZone fromZone;
  final RosterZone toZone;
  final Player player;
  final AssignedSlot assignment;
  final bool hasActiveInjury;
  final bool hasActiveSuspension;
  final bool hasPositionMismatch;
  final int generationSize;
  final int token;
  final String transitionScenario;
  final String statusScenario;
  final bool shrunk;

  String get diagnostics =>
      'seed=$_propertySevenSeed generationSize=$generationSize '
      'transition=$transitionScenario status=$statusScenario token=$token '
      'player=${player.id} playerPosition=${player.position.code} '
      'assignmentPosition=${assignment.position.code}';

  @override
  String toString() => diagnostics;
}
