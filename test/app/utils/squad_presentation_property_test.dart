@Tags(['property'])
library;

import 'dart:math';
import 'dart:ui' show Color;

import 'package:flutter/material.dart' show Colors, Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/position_group.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

const _propertyRuns = 120;
const _propertySeed = 8202;
const _propertyTwoSeed = 8203;
const _propertyThreeSeed = 8204;
const _propertyFourSeed = 8205;
const _propertySixSeed = 8207;
const _propertySevenSeed = 8208;
const _propertyNineSeed = 8210;

void main() {
  const propertyOneSeed = 8201;
  final propertyOneTemplateTeam = GameFactory()
      .create(
        const NewGameRequest(
          saveName: 'Squad presentation Property 1',
          playerTeamId: 'team_europe_0',
          seed: propertyOneSeed,
        ),
      )
      .leagueState
      .teams
      .firstWhere((team) => team.id == 'team_europe_0');

  double propertyOneRawForm(Random random, int size) {
    switch (size % 10) {
      case 0:
        return -1000.0 - random.nextInt(1001);
      case 1:
        return 0.0;
      case 2:
        return random.nextInt(1001) / 100.0;
      case 3:
        return 10.0;
      case 4:
        return 10.5 + random.nextInt(1001);
      case 5:
        return -random.nextInt(1001) / 100.0;
      case 6:
        return 0.01 + random.nextInt(999) / 100.0;
      case 7:
        return 5.0 + random.nextInt(501) / 100.0;
      case 8:
        return 9.0 + random.nextInt(101) / 100.0;
      default:
        return 1.0 + random.nextInt(401) / 100.0;
    }
  }

  double propertyOneChangedForm(double rawForm) {
    if (rawForm < 0.0 || rawForm > 10.0) return 5.0;
    return rawForm <= 5.0 ? 10.0 : 0.0;
  }

  AssignedSlot? propertyOneAssignment({
    required Position playerPosition,
    required int size,
    required int token,
  }) {
    if (size % 3 == 0) return null;
    final assignmentPosition = size.isEven
        ? playerPosition
        : Position.values[(playerPosition.index + 1) % Position.values.length];
    return AssignedSlot(
      key: 'p1-slot-$size-$token',
      position: assignmentPosition,
      group: positionGroupOf(assignmentPosition),
      x: 0.5,
      y: 0.5,
    );
  }

  final generatedPropertyOneCases = any
      .simple<
        ({
          double rawForm,
          double changedForm,
          Player player,
          Team team,
          AssignedSlot? assignment,
          int generationSize,
          String scenario,
          bool shrunk,
        })
      >(
        generate: (random, size) {
          final scenario = size % 10;
          final rawForm = propertyOneRawForm(random, size);
          final changedForm = propertyOneChangedForm(rawForm);
          final token = random.nextInt(1 << 30);
          final templatePlayer = propertyOneTemplateTeam
              .roster[random.nextInt(propertyOneTemplateTeam.roster.length)];
          final hasActiveInjury = size.isOdd;
          final hasActiveSuspension = (size ~/ 2).isOdd;
          final playerId = 'p1-$size-$token';
          final player = templatePlayer.copyWith(
            id: playerId,
            name: 'Property 1 $playerId',
            state: templatePlayer.state.copyWith(
              form: rawForm,
              injury: hasActiveInjury
                  ? const Injury(
                      id: 'squad-property-one-injury',
                      group: InjuryGroup.legMuscles,
                      type: InjuryType.minor,
                      daysTotal: 5,
                      daysRemaining: 2,
                    )
                  : null,
              suspensionGamesRemaining: hasActiveSuspension ? 2 : 0,
            ),
          );
          final zone =
              RosterZone.values[(size +
                      random.nextInt(RosterZone.values.length)) %
                  RosterZone.values.length];
          final team = propertyOneTemplateTeam.copyWith(
            roster: [player],
            lineupPlayerIds: zone == RosterZone.xi
                ? [player.id]
                : const <String>[],
            benchPlayerIds: zone == RosterZone.bench
                ? [player.id]
                : const <String>[],
          );

          return (
            rawForm: rawForm,
            changedForm: changedForm,
            player: player,
            team: team,
            assignment: propertyOneAssignment(
              playerPosition: player.position,
              size: size,
              token: token,
            ),
            generationSize: size,
            scenario: 'form-scenario=$scenario zone=${zone.name}',
            shrunk: false,
          );
        },
        shrink: (input) sync* {
          if (input.shrunk) return;
          final player = input.player.copyWith(
            id: 'p1-shrunk',
            name: 'Property 1 shrunk',
            state: input.player.state.copyWith(form: -1.0),
          );
          final team = input.team.copyWith(
            roster: [player],
            lineupPlayerIds: const <String>[],
            benchPlayerIds: const <String>[],
          );
          yield (
            rawForm: -1.0,
            changedForm: 5.0,
            player: player,
            team: team,
            assignment: null,
            generationSize: 0,
            scenario: 'shrunk-below-zero',
            shrunk: true,
          );
        },
      );

  // Feature: squad-row-polish, Property 1: Form projection remains bounded and value-stable
  // **Validates: Requirements 1.5, 6.2**
  Glados<
        ({
          double rawForm,
          double changedForm,
          Player player,
          Team team,
          AssignedSlot? assignment,
          int generationSize,
          String scenario,
          bool shrunk,
        })
      >(
        generatedPropertyOneCases,
        ExploreConfig(
          numRuns: _propertyRuns,
          initialSize: 8,
          speed: 1,
          random: Random(propertyOneSeed),
        ),
      )
      .test(
        'Feature: squad-row-polish, Property 1: Form projection remains bounded and value-stable',
        (input) {
          final reason =
              'seed=$propertyOneSeed generationSize=${input.generationSize} '
              'scenario=${input.scenario} rawForm=${input.rawForm} '
              'changedForm=${input.changedForm}';
          final expectedClamped = input.rawForm.clamp(0.0, 10.0).toDouble();
          final expectedChangedClamped = input.changedForm
              .clamp(0.0, 10.0)
              .toDouble();
          final beforePlayer = input.player;
          final beforeTeam = input.team;
          final rosterBefore = List<Player>.from(beforeTeam.roster);
          final lineupBefore = List<String>.from(beforeTeam.lineupPlayerIds);
          final benchBefore = List<String>.from(beforeTeam.benchPlayerIds);
          final before = playerPresentation(
            player: beforePlayer,
            team: beforeTeam,
            assignment: input.assignment,
          );
          final changedPlayer = beforePlayer.copyWith(
            state: beforePlayer.state.copyWith(form: input.changedForm),
          );
          final after = playerPresentation(
            player: changedPlayer,
            team: beforeTeam,
            assignment: input.assignment,
          );

          expect(input.rawForm.isFinite, isTrue, reason: reason);
          expect(input.changedForm.isFinite, isTrue, reason: reason);
          expect(
            before.clampedForm,
            allOf(
              greaterThanOrEqualTo(0.0),
              lessThanOrEqualTo(10.0),
              isA<double>(),
            ),
            reason: reason,
          );
          expect(before.clampedForm, expectedClamped, reason: reason);
          expect(
            formFillForValue(input.rawForm),
            closeTo(expectedClamped / 10.0, 0.000000000001),
            reason: reason,
          );
          expect(
            formFillForValue(input.rawForm),
            allOf(greaterThanOrEqualTo(0.0), lessThanOrEqualTo(1.0)),
            reason: reason,
          );
          final expectedColor = _expectedFormColorForPropertySix(
            expectedClamped,
          );
          final actualColor = formColorForClampedValue(input.rawForm);
          expect(actualColor.a, expectedColor.a, reason: reason);
          expect(actualColor.r, expectedColor.r, reason: reason);
          expect(actualColor.g, expectedColor.g, reason: reason);
          expect(actualColor.b, expectedColor.b, reason: reason);

          // The pure numeric form value is the payload from which the widget
          // builds its localized semantics; no rendered semantics are used.
          expect(
            before.semanticSnapshot.clampedForm,
            isA<double>(),
            reason: reason,
          );
          expect(
            before.semanticSnapshot.clampedForm,
            expectedClamped,
            reason: reason,
          );

          expect(after.clampedForm, expectedChangedClamped, reason: reason);
          expect(
            formFillForValue(input.changedForm),
            closeTo(expectedChangedClamped / 10.0, 0.000000000001),
            reason: reason,
          );
          final changedExpectedColor = _expectedFormColorForPropertySix(
            expectedChangedClamped,
          );
          final changedActualColor = formColorForClampedValue(
            input.changedForm,
          );
          expect(changedActualColor.a, changedExpectedColor.a, reason: reason);
          expect(changedActualColor.r, changedExpectedColor.r, reason: reason);
          expect(changedActualColor.g, changedExpectedColor.g, reason: reason);
          expect(changedActualColor.b, changedExpectedColor.b, reason: reason);
          expect(
            after.semanticSnapshot.clampedForm,
            expectedChangedClamped,
            reason: reason,
          );

          // Changing only form must not alter the rest of the pure row
          // projection or any domain-owned input.
          expect(after.zone, before.zone, reason: reason);
          expect(after.assignment, same(before.assignment), reason: reason);
          expect(
            after.status.hasActiveInjury,
            before.status.hasActiveInjury,
            reason: reason,
          );
          expect(
            after.status.hasActiveSuspension,
            before.status.hasActiveSuspension,
            reason: reason,
          );
          expect(
            after.status.hasPositionMismatch,
            before.status.hasPositionMismatch,
            reason: reason,
          );
          expect(after.roundedOvr, before.roundedOvr, reason: reason);
          expect(
            after.nameParts.firstLine,
            before.nameParts.firstLine,
            reason: reason,
          );
          expect(
            after.nameParts.secondLine,
            before.nameParts.secondLine,
            reason: reason,
          );
          expect(
            after.nameParts.original,
            before.nameParts.original,
            reason: reason,
          );
          expect(after.zoneLabel, before.zoneLabel, reason: reason);

          final beforeSemantic = before.semanticSnapshot;
          final afterSemantic = after.semanticSnapshot;
          expect(
            afterSemantic.playerId,
            beforeSemantic.playerId,
            reason: reason,
          );
          expect(
            afterSemantic.playerName,
            beforeSemantic.playerName,
            reason: reason,
          );
          expect(
            afterSemantic.position,
            beforeSemantic.position,
            reason: reason,
          );
          expect(
            afterSemantic.roundedOvr,
            beforeSemantic.roundedOvr,
            reason: reason,
          );
          expect(afterSemantic.zone, beforeSemantic.zone, reason: reason);
          expect(
            afterSemantic.zoneLabel,
            beforeSemantic.zoneLabel,
            reason: reason,
          );
          expect(
            afterSemantic.hasActiveInjury,
            beforeSemantic.hasActiveInjury,
            reason: reason,
          );
          expect(
            afterSemantic.hasActiveSuspension,
            beforeSemantic.hasActiveSuspension,
            reason: reason,
          );
          expect(
            afterSemantic.hasPositionMismatch,
            beforeSemantic.hasPositionMismatch,
            reason: reason,
          );

          expect(
            after.player.copyWith(
              state: after.player.state.copyWith(
                form: before.player.state.form,
              ),
            ),
            before.player,
            reason: '$reason only Player.state.form may change',
          );
          expect(input.player, same(beforePlayer), reason: reason);
          expect(input.team, same(beforeTeam), reason: reason);
          expect(beforeTeam.roster, rosterBefore, reason: reason);
          expect(beforeTeam.lineupPlayerIds, lineupBefore, reason: reason);
          expect(beforeTeam.benchPlayerIds, benchBefore, reason: reason);
        },
      );

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

  const squadRowPropertyThreeSeed = 8212;
  final propertyThreeTemplateTeam = GameFactory()
      .create(
        const NewGameRequest(
          saveName: 'Squad presentation Property 3',
          playerTeamId: 'team_europe_0',
          seed: squadRowPropertyThreeSeed,
        ),
      )
      .leagueState
      .teams
      .firstWhere((team) => team.id == 'team_europe_0');
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

  const squadRowPropertyFourSeed = 8213;
  final propertyFourTemplateTeam = GameFactory()
      .create(
        const NewGameRequest(
          saveName: 'Squad presentation Property 4',
          playerTeamId: 'team_europe_0',
          seed: squadRowPropertyFourSeed,
        ),
      )
      .leagueState
      .teams
      .firstWhere((team) => team.id == 'team_europe_0');

  RosterZone propertyFourZoneOracle(Team team, String playerId) {
    if (team.lineupPlayerIds.contains(playerId)) return RosterZone.xi;
    if (team.benchPlayerIds.contains(playerId)) return RosterZone.bench;
    return RosterZone.reserve;
  }

  int propertyFourZoneRank(Team team, String playerId) =>
      switch (propertyFourZoneOracle(team, playerId)) {
        RosterZone.xi => 0,
        RosterZone.bench => 1,
        RosterZone.reserve => 2,
      };

  int propertyFourRoundOvr(double rawOvr) {
    if (!rawOvr.isFinite) return rawOvr == double.infinity ? 99 : 50;
    if (rawOvr >= 0) {
      final lower = rawOvr.floor();
      return rawOvr - lower >= 0.5 ? lower + 1 : lower;
    }
    final upper = rawOvr.ceil();
    return upper - rawOvr >= 0.5 ? upper - 1 : upper;
  }

  double propertyFourFormValue(double rawForm) {
    if (rawForm.isNaN || rawForm == double.negativeInfinity) return 0.0;
    if (rawForm == double.infinity) return 10.0;
    return rawForm < 0.0
        ? 0.0
        : rawForm > 10.0
        ? 10.0
        : rawForm;
  }

  int propertyFourCompare(
    Team team,
    Player left,
    Player right,
    PlayerSortMode mode,
  ) => switch (mode) {
    PlayerSortMode.overall => right.overall().compareTo(left.overall()),
    PlayerSortMode.assignedZone =>
      propertyFourZoneRank(team, left.id) !=
              propertyFourZoneRank(team, right.id)
          ? propertyFourZoneRank(
              team,
              left.id,
            ).compareTo(propertyFourZoneRank(team, right.id))
          : Position.values
                .indexOf(left.position)
                .compareTo(Position.values.indexOf(right.position)),
    PlayerSortMode.form => right.state.form.compareTo(left.state.form),
    PlayerSortMode.position =>
      Position.values
          .indexOf(left.position)
          .compareTo(Position.values.indexOf(right.position)),
  };

  List<Player> propertyFourOrderingOracle(
    Team team,
    Iterable<Player> players,
    PlayerSortMode mode,
  ) {
    final ordered = [...players];
    ordered.sort((left, right) {
      return propertyFourCompare(team, left, right, mode);
    });
    return ordered;
  }

  List<num> propertyFourOrderingSignature(
    Team team,
    Player player,
    PlayerSortMode mode,
  ) => switch (mode) {
    PlayerSortMode.overall => [player.overall()],
    PlayerSortMode.assignedZone => [
      propertyFourZoneRank(team, player.id),
      Position.values.indexOf(player.position),
    ],
    PlayerSortMode.form => [player.state.form],
    PlayerSortMode.position => [Position.values.indexOf(player.position)],
  };

  final generatedSquadRowPropertyFourCases = any
      .simple<
        ({
          Team team,
          PlayerSortMode mode,
          PositionAssignmentIndex assignmentIndex,
          Map<String, AssignedSlot> assignments,
          List<PlacedPlayer> placements,
          Formation formation,
          int generationSize,
          String scenario,
          String diagnostics,
        })
      >(
        generate: (random, size) {
          final maxRosterSize = propertyFourTemplateTeam.roster.length;
          final minimumRosterSize = min(3, maxRosterSize);
          final rosterSize = minimumRosterSize == maxRosterSize
              ? maxRosterSize
              : minimumRosterSize +
                    random.nextInt(maxRosterSize - minimumRosterSize + 1);
          final token = random.nextInt(1 << 30);
          final templates = [...propertyFourTemplateTeam.roster]
            ..shuffle(random);
          final roster = <Player>[
            for (var index = 0; index < rosterSize; index++)
              templates[index].copyWith(
                id: 'p4-$size-$token-$index',
                name: 'Property 4 p4-$size-$token-$index',
                state: templates[index].state.copyWith(
                  // Keep generated forms finite and distinct where possible,
                  // while retaining the domain's valid 0–10 presentation range.
                  form: rosterSize == 0
                      ? 5.0
                      : ((index + 1) * 10.0) / (rosterSize + 1),
                ),
              ),
          ];
          roster.shuffle(random);

          final membershipOrder = [...roster]..shuffle(random);
          final membershipScenario = size % 6;
          final maxLineupCount = min(11, roster.length);
          final lineupCount = maxLineupCount == 0
              ? 0
              : switch (membershipScenario) {
                  0 => 0,
                  1 => maxLineupCount,
                  2 => 1,
                  3 => min(maxLineupCount, 2 + size % maxLineupCount),
                  4 => random.nextInt(maxLineupCount + 1),
                  _ => maxLineupCount,
                };
          final remainingPlayers = membershipOrder.skip(lineupCount).toList();
          final maxBenchCount = min(7, remainingPlayers.length);
          final benchScenario = (size ~/ 6) % 4;
          final benchCount = maxBenchCount == 0
              ? 0
              : switch (benchScenario) {
                  0 => 0,
                  1 => maxBenchCount,
                  2 => 1,
                  _ => random.nextInt(maxBenchCount + 1),
                };
          final lineupPlayers = membershipOrder.take(lineupCount).toList()
            ..shuffle(random);
          final benchPlayers = remainingPlayers.take(benchCount).toList()
            ..shuffle(random);
          final lineupPlayerIds = [
            for (final player in lineupPlayers) player.id,
          ];
          final benchPlayerIds = [for (final player in benchPlayers) player.id];

          final formation =
              Formation.values[(size +
                      random.nextInt(Formation.values.length)) %
                  Formation.values.length];
          final team = propertyFourTemplateTeam.copyWith(
            roster: roster,
            tactics: propertyFourTemplateTeam.tactics.copyWith(
              formation: formation,
            ),
            lineupPlayerIds: lineupPlayerIds,
            benchPlayerIds: benchPlayerIds,
          );

          final slotPool = [...FormationLayout.of(formation).slots]
            ..shuffle(random);
          final assignmentPlayers = [...lineupPlayers]..shuffle(random);
          final assignmentCount = min(
            slotPool.length,
            assignmentPlayers.length,
          );
          final placements = <PlacedPlayer>[
            for (var index = 0; index < assignmentCount; index++)
              PlacedPlayer(
                slot: slotPool[index],
                player: assignmentPlayers[index],
              ),
          ];
          final immutablePlacements = List<PlacedPlayer>.unmodifiable(
            placements,
          );
          final assignmentValues = <String, AssignedSlot>{
            for (final placement in immutablePlacements)
              if (placement.player != null)
                placement.player!.id: placement.slot,
          };
          final immutableAssignments = Map<String, AssignedSlot>.unmodifiable(
            assignmentValues,
          );
          final assignmentIndex = positionAssignmentIndexFromPlacements(
            immutablePlacements,
          );
          final rosterSummary = roster
              .map(
                (player) =>
                    '${player.id}:${player.position.code}:form=${player.state.form}:ovr=${player.overall()}',
              )
              .join('|');

          return (
            team: team,
            mode: PlayerSortMode.values[size % PlayerSortMode.values.length],
            assignmentIndex: assignmentIndex,
            assignments: immutableAssignments,
            placements: immutablePlacements,
            formation: formation,
            generationSize: size,
            scenario:
                'mode=${PlayerSortMode.values[size % PlayerSortMode.values.length].name} '
                'rosterSize=$rosterSize membership=$membershipScenario/$benchScenario',
            diagnostics:
                'seed=$squadRowPropertyFourSeed generationSize=$size '
                'mode=${PlayerSortMode.values[size % PlayerSortMode.values.length].name} '
                'formation=${formation.name} roster=$rosterSummary '
                'lineup=${lineupPlayerIds.join(',')} '
                'bench=${benchPlayerIds.join(',')}',
          );
        },
        shrink: (input) sync* {
          if (input.team.roster.length <= 1) return;
          final player = input.team.roster.first.copyWith(
            id: 'p4-shrunk',
            name: 'Property 4 shrunk reserve',
            state: input.team.roster.first.state.copyWith(form: 5.0),
          );
          final team = input.team.copyWith(
            roster: [player],
            lineupPlayerIds: const <String>[],
            benchPlayerIds: const <String>[],
          );
          const placements = <PlacedPlayer>[];
          yield (
            team: team,
            mode: input.mode,
            assignmentIndex: positionAssignmentIndexFromPlacements(placements),
            assignments: const <String, AssignedSlot>{},
            placements: placements,
            formation: input.formation,
            generationSize: 0,
            scenario: 'shrunk-single-reserve',
            diagnostics:
                'seed=$squadRowPropertyFourSeed generationSize=0 '
                'scenario=shrunk-single-reserve mode=${input.mode.name}',
          );
        },
      );

  // Feature: squad-row-polish, Property 4: Full roster projection preserves membership, order rules and domain inputs
  // **Validates: Requirements 7.3, 7.7**
  Glados<
        ({
          Team team,
          PlayerSortMode mode,
          PositionAssignmentIndex assignmentIndex,
          Map<String, AssignedSlot> assignments,
          List<PlacedPlayer> placements,
          Formation formation,
          int generationSize,
          String scenario,
          String diagnostics,
        })
      >(
        generatedSquadRowPropertyFourCases,
        ExploreConfig(
          numRuns: _propertyRuns,
          initialSize: 8,
          speed: 1,
          random: Random(squadRowPropertyFourSeed),
        ),
      )
      .test(
        'Feature: squad-row-polish, Property 4: Full roster projection preserves membership, order rules and domain inputs',
        (input) {
          final reason = '${input.diagnostics} scenario=${input.scenario}';
          final teamBefore = input.team;
          final rosterBefore = List<Player>.from(teamBefore.roster);
          final rosterIdsBefore = rosterBefore
              .map((player) => player.id)
              .toList();
          final lineupBefore = List<String>.from(teamBefore.lineupPlayerIds);
          final benchBefore = List<String>.from(teamBefore.benchPlayerIds);
          final tacticsBefore = teamBefore.tactics;
          final placementsBefore = List<PlacedPlayer>.from(input.placements);
          final assignmentsBefore = Map<String, AssignedSlot>.from(
            input.assignments,
          );
          final indexedAssignmentsBefore = Map<String, AssignedSlot>.from(
            input.assignmentIndex.assignmentsByPlayerId,
          );

          final projection = playerPresentationsForRoster(
            input.team,
            assignmentIndex: input.assignmentIndex,
          );
          final projectionIds = projection
              .map((presentation) => presentation.player.id)
              .toList();

          expect(projection, hasLength(rosterBefore.length), reason: reason);
          expect(projectionIds, rosterIdsBefore, reason: reason);
          expect(
            projectionIds.toSet(),
            hasLength(rosterIdsBefore.length),
            reason: '$reason projected IDs must be unique',
          );
          expect(
            projectionIds,
            unorderedEquals(rosterIdsBefore),
            reason: '$reason projection must contain exactly the full roster',
          );
          for (final rosterId in rosterIdsBefore) {
            expect(
              projectionIds.where((id) => id == rosterId),
              hasLength(1),
              reason: '$reason roster ID $rosterId must appear once',
            );
          }

          for (final player in rosterBefore) {
            final presentation = projection.singleWhere(
              (candidate) => candidate.player.id == player.id,
            );
            final expectedAssignment = input.assignments[player.id];
            final expectedZone = propertyFourZoneOracle(teamBefore, player.id);
            final expectedForm = propertyFourFormValue(player.state.form);
            final expectedInjury = player.state.injury?.isActive ?? false;
            final expectedSuspension =
                player.state.suspensionGamesRemaining > 0;
            final expectedMismatch =
                expectedAssignment != null &&
                player.position != expectedAssignment.position;

            // The row projection keeps the exact domain Player and assignment
            // objects while deriving each display value from independent data.
            expect(presentation.player, same(player), reason: reason);
            expect(
              presentation.assignment,
              same(expectedAssignment),
              reason: '$reason assignment for ${player.id}',
            );
            expect(presentation.zone, expectedZone, reason: reason);
            expect(
              presentation.roundedOvr,
              propertyFourRoundOvr(player.overall()),
              reason: '$reason OVR for ${player.id}',
            );
            expect(
              presentation.clampedForm,
              expectedForm,
              reason: '$reason form for ${player.id}',
            );
            expect(
              presentation.player.position,
              player.position,
              reason: '$reason position for ${player.id}',
            );
            expect(
              presentation.status.hasActiveInjury,
              expectedInjury,
              reason: '$reason injury state for ${player.id}',
            );
            expect(
              presentation.status.hasActiveSuspension,
              expectedSuspension,
              reason: '$reason suspension state for ${player.id}',
            );
            expect(
              presentation.status.hasPositionMismatch,
              expectedMismatch,
              reason: '$reason assignment mismatch for ${player.id}',
            );
          }

          final sortedRoster = sortRoster(
            teamBefore,
            teamBefore.roster,
            input.mode,
          );
          final oracleRoster = propertyFourOrderingOracle(
            teamBefore,
            rosterBefore,
            input.mode,
          );
          expect(
            sortedRoster
                .map(
                  (player) => propertyFourOrderingSignature(
                    teamBefore,
                    player,
                    input.mode,
                  ),
                )
                .toList(),
            oracleRoster
                .map(
                  (player) => propertyFourOrderingSignature(
                    teamBefore,
                    player,
                    input.mode,
                  ),
                )
                .toList(),
            reason: '$reason independent ordering oracle',
          );
          final sortedIds = sortedRoster.map((player) => player.id).toList();
          expect(
            sortedIds.toSet(),
            equals(rosterIdsBefore.toSet()),
            reason: reason,
          );
          expect(sortedIds, hasLength(rosterIdsBefore.length), reason: reason);

          // The complete projection preserves whichever pure roster order the
          // caller supplies after applying the independent sort oracle.
          final sortedTeam = teamBefore.copyWith(roster: sortedRoster);
          final sortedProjection = playerPresentationsForRoster(
            sortedTeam,
            assignmentIndex: input.assignmentIndex,
          );
          expect(
            sortedProjection.map((presentation) => presentation.player.id),
            sortedIds,
            reason: '$reason sorted projection order',
          );

          expect(input.team, same(teamBefore), reason: '$reason Team identity');
          expect(
            teamBefore.roster,
            rosterBefore,
            reason: '$reason Team.roster',
          );
          expect(
            teamBefore.lineupPlayerIds,
            lineupBefore,
            reason: '$reason Team.lineupPlayerIds',
          );
          expect(
            teamBefore.benchPlayerIds,
            benchBefore,
            reason: '$reason Team.benchPlayerIds',
          );
          expect(teamBefore.tactics, tacticsBefore, reason: '$reason tactics');
          expect(
            input.placements,
            placementsBefore,
            reason: '$reason placements',
          );
          expect(
            input.assignments,
            assignmentsBefore,
            reason: '$reason assignments',
          );
          expect(
            input.assignmentIndex.assignmentsByPlayerId,
            indexedAssignmentsBefore,
            reason: '$reason indexed assignments',
          );
          expect(input.formation, teamBefore.tactics.formation, reason: reason);
        },
      );

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
        expect(projection.semanticState, 'in-range', reason: reason);
        expect(projection.trackColor, Colors.green, reason: reason);
        expect(projection.iconState, RosterSizeIconState.check, reason: reason);
        expect(projection.iconToken, 'check', reason: reason);
      } else {
        expect(projection.state, RosterSizeState.outOfRange, reason: reason);
        expect(projection.semanticState, 'out-of-range', reason: reason);
        expect(projection.trackColor, Colors.red, reason: reason);
        expect(projection.iconState, RosterSizeIconState.x, reason: reason);
        expect(projection.iconToken, 'x', reason: reason);
      }
    },
  );

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

  // Feature: squad-screen-redesign, Property 4: Whitespace name normalization
  // **Validates: Requirements 5.3, 5.4**
  Glados<_GeneratedNameNormalizationCase>(
    _generatedNameNormalizationCases,
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(_propertyFourSeed),
    ),
  ).test('Feature: squad-screen-redesign, Property 4: Whitespace name '
      'normalization holds for $_propertyRuns generated cases', (input) {
    final reason = input.diagnostics;
    final presentation = splitPlayerName(input.rawName);
    final expectedFirstLine = input.expectedPortions.isEmpty
        ? ''
        : input.expectedPortions.first;
    final expectedSecondLine = input.expectedPortions.length <= 1
        ? ''
        : input.expectedPortions.skip(1).join(' ');

    expect(presentation.firstLine, expectedFirstLine, reason: reason);
    expect(presentation.secondLine, expectedSecondLine, reason: reason);

    // A whitespace-only name and a name with one non-empty portion both have
    // no lower name line after empty portions are discarded.
    if (input.expectedPortions.length <= 1) {
      expect(presentation.secondLine, isEmpty, reason: reason);
    }
  });

  // Feature: squad-screen-redesign, Property 5: OVR presentation is rounded, interpolated and contrast-safe
  // **Validates: Requirements 6.1, 6.3–6.7**
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

  // Feature: squad-screen-redesign, Property 6: Form presentation is clamped, proportional and interpolated
  // **Validates: Requirements 7.2–7.8**
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
    final expectedClamped = _expectedClampedFormForPropertySix(input.rawForm);
    final actualClamped = clampedFormValue(input.rawForm);
    final actualFill = formFillForValue(input.rawForm);
    final expectedColor = _expectedFormColorForPropertySix(expectedClamped);
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

  // Feature: squad-screen-redesign, Property 7: Zone presentation is stable and independent
  // **Validates: Requirements 8.3–8.5, 8.7–8.8, 11.5**
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

  const propertyEightSeed = 8209;
  final propertyEightTemplateTeam = GameFactory()
      .create(
        const NewGameRequest(
          saveName: 'Squad presentation Property 8',
          playerTeamId: 'team_europe_0',
          seed: propertyEightSeed,
        ),
      )
      .leagueState
      .teams
      .firstWhere((team) => team.id == 'team_europe_0');

  int propertyEightZoneRank(Team team, String playerId) {
    if (team.lineupPlayerIds.contains(playerId)) return 0;
    if (team.benchPlayerIds.contains(playerId)) return 1;
    return 2;
  }

  int propertyEightCompare(
    Team team,
    Player left,
    Player right,
    PlayerSortMode mode,
  ) {
    switch (mode) {
      case PlayerSortMode.overall:
        return right.overall().compareTo(left.overall());
      case PlayerSortMode.assignedZone:
        final zoneCompare = propertyEightZoneRank(
          team,
          left.id,
        ).compareTo(propertyEightZoneRank(team, right.id));
        if (zoneCompare != 0) return zoneCompare;
        return Position.values
            .indexOf(left.position)
            .compareTo(Position.values.indexOf(right.position));
      case PlayerSortMode.form:
        return right.state.form.compareTo(left.state.form);
      case PlayerSortMode.position:
        return Position.values
            .indexOf(left.position)
            .compareTo(Position.values.indexOf(right.position));
    }
  }

  List<Player> propertyEightOracle(
    Team team,
    List<Player> players,
    PlayerSortMode mode,
  ) {
    final oracle = [...players];
    oracle.sort((left, right) {
      return propertyEightCompare(team, left, right, mode);
    });
    return oracle;
  }

  List<num> propertyEightOrderingSignature(
    Team team,
    Player player,
    PlayerSortMode mode,
  ) {
    switch (mode) {
      case PlayerSortMode.overall:
        return [player.overall()];
      case PlayerSortMode.assignedZone:
        return [
          propertyEightZoneRank(team, player.id),
          Position.values.indexOf(player.position),
        ];
      case PlayerSortMode.form:
        return [player.state.form];
      case PlayerSortMode.position:
        return [Position.values.indexOf(player.position)];
    }
  }

  final generatedPropertyEightCases = any
      .simple<
        ({
          Team team,
          PlayerSortMode mode,
          int generationSize,
          String scenario,
          String diagnostics,
        })
      >(
        generate: (random, size) {
          final scenarioIndex = size % 12;
          final maxRosterSize = propertyEightTemplateTeam.roster.length;
          final minimumRosterSize = min(3, maxRosterSize);
          final rosterSize = minimumRosterSize == maxRosterSize
              ? maxRosterSize
              : minimumRosterSize +
                    random.nextInt(maxRosterSize - minimumRosterSize + 1);
          final shuffledTemplates = [...propertyEightTemplateTeam.roster]
            ..shuffle(random);
          final token = random.nextInt(1 << 30);
          final roster = <Player>[
            for (var index = 0; index < rosterSize; index++)
              shuffledTemplates[index].copyWith(
                id: 'p8-$size-$token-$index',
                name: 'Property 8 p8-$size-$token-$index',
                // Keep each generated player's valid attribute/position
                // pairing; goalkeeper attributes cannot be evaluated at an
                // outfield code.
                state: shuffledTemplates[index].state.copyWith(
                  form: switch (index % 4) {
                    0 => 0.0,
                    1 => 10.0,
                    2 => random.nextInt(1001) / 100.0,
                    _ => (scenarioIndex + random.nextInt(1001)) % 1001 / 100.0,
                  },
                ),
              ),
          ];

          // Keep every generated Team structurally valid: lineup and bench IDs
          // are unique roster members, and at least one reserve remains when the
          // generated roster has enough players for all three zones.
          final lineupCapacity = max(1, roster.length - 2);
          final lineupCount = roster.isEmpty
              ? 0
              : min(
                  11,
                  1 + ((scenarioIndex + random.nextInt(3)) % lineupCapacity),
                );
          final remainingAfterLineup = roster.length - lineupCount;
          final benchCapacity = max(0, remainingAfterLineup - 1);
          final benchCount = benchCapacity == 0
              ? 0
              : min(
                  7,
                  1 + ((scenarioIndex + random.nextInt(3)) % benchCapacity),
                );
          final lineupPlayerIds = [
            for (final player in roster.take(lineupCount)) player.id,
          ];
          final benchPlayerIds = [
            for (final player in roster.skip(lineupCount).take(benchCount))
              player.id,
          ];
          final team = propertyEightTemplateTeam.copyWith(
            roster: roster,
            lineupPlayerIds: lineupPlayerIds,
            benchPlayerIds: benchPlayerIds,
          );
          final mode = PlayerSortMode
              .values[scenarioIndex % PlayerSortMode.values.length];
          final rosterSummary = roster
              .map(
                (player) =>
                    '${player.id}:${player.position.code}:form=${player.state.form}:'
                    'ovr=${player.overall()}',
              )
              .join('|');

          return (
            team: team,
            mode: mode,
            generationSize: size,
            scenario: 'mode=${mode.name},rosterSize=$rosterSize,token=$token',
            diagnostics:
                'seed=$propertyEightSeed generationSize=$size '
                'scenario=mode=${mode.name},rosterSize=$rosterSize,token=$token '
                'roster=$rosterSummary lineup=${lineupPlayerIds.join(',')} '
                'bench=${benchPlayerIds.join(',')}',
          );
        },
        shrink: (input) sync* {
          if (input.team.roster.length <= 1) return;
          final shrunkPlayer = input.team.roster.first;
          final shrunkTeam = input.team.copyWith(
            roster: [shrunkPlayer],
            lineupPlayerIds: const [],
            benchPlayerIds: const [],
          );
          yield (
            team: shrunkTeam,
            mode: input.mode,
            generationSize: 0,
            scenario: 'shrunk-single-reserve',
            diagnostics:
                'seed=$propertyEightSeed generationSize=0 '
                'scenario=shrunk-single-reserve mode=${input.mode.name} '
                'roster=${shrunkPlayer.id}',
          );
        },
      );

  // Feature: squad-screen-redesign, Property 8: Full roster sorting preserves membership and domain state
  // **Validates: Requirements 3.4, 3.7, 9.2, 9.3, 9.4, 9.5, 9.6**
  Glados<
        ({
          Team team,
          PlayerSortMode mode,
          int generationSize,
          String scenario,
          String diagnostics,
        })
      >(
        generatedPropertyEightCases,
        ExploreConfig(
          numRuns: _propertyRuns,
          initialSize: 8,
          speed: 1,
          random: Random(propertyEightSeed),
        ),
      )
      .test('Feature: squad-screen-redesign, Property 8: Full roster sorting '
          'preserves membership and domain state for $_propertyRuns generated '
          'cases (seed=$propertyEightSeed)', (input) {
        final reason = input.diagnostics;
        final rosterBefore = List<Player>.from(input.team.roster);
        final rosterIdsBefore = rosterBefore
            .map((player) => player.id)
            .toList();
        final lineupBefore = List<String>.from(input.team.lineupPlayerIds);
        final benchBefore = List<String>.from(input.team.benchPlayerIds);
        final rosterIdSet = rosterIdsBefore.toSet();

        expect(
          rosterIdSet,
          hasLength(rosterIdsBefore.length),
          reason: '$reason generated roster IDs must be unique',
        );
        expect(
          input.team.lineupPlayerIds.every(rosterIdSet.contains),
          isTrue,
          reason: '$reason lineup IDs must belong to Team.roster',
        );
        expect(
          input.team.benchPlayerIds.every(rosterIdSet.contains),
          isTrue,
          reason: '$reason bench IDs must belong to Team.roster',
        );
        expect(
          input.team.lineupPlayerIds.toSet().intersection(
            input.team.benchPlayerIds.toSet(),
          ),
          isEmpty,
          reason: '$reason lineup and bench IDs must not overlap',
        );

        final sorted = sortRoster(input.team, input.team.roster, input.mode);
        final oracle = propertyEightOracle(
          input.team,
          rosterBefore,
          input.mode,
        );
        final sortedSignatures = sorted
            .map(
              (player) => propertyEightOrderingSignature(
                input.team,
                player,
                input.mode,
              ),
            )
            .toList();
        final oracleSignatures = oracle
            .map(
              (player) => propertyEightOrderingSignature(
                input.team,
                player,
                input.mode,
              ),
            )
            .toList();

        expect(
          sortedSignatures,
          oracleSignatures,
          reason: '$reason sortRoster ordering differs from independent oracle',
        );

        final sortedIds = sorted.map((player) => player.id).toList();
        expect(sortedIds, hasLength(rosterIdsBefore.length), reason: reason);
        expect(
          sortedIds.toSet(),
          hasLength(rosterIdsBefore.length),
          reason: '$reason sorted IDs must occur exactly once',
        );
        expect(
          sortedIds.toSet(),
          rosterIdSet,
          reason: '$reason sorted IDs must equal the full roster ID set',
        );
        for (final rosterId in rosterIdsBefore) {
          expect(
            sortedIds.where((id) => id == rosterId),
            hasLength(1),
            reason: '$reason roster ID $rosterId must appear exactly once',
          );
        }

        // Sorting is presentation-only and must not mutate any domain list.
        expect(input.team.roster, rosterBefore, reason: '$reason Team.roster');
        expect(
          input.team.lineupPlayerIds,
          lineupBefore,
          reason: '$reason Team.lineupPlayerIds',
        );
        expect(
          input.team.benchPlayerIds,
          benchBefore,
          reason: '$reason Team.benchPlayerIds',
        );
      });

  final propertyNineTemplateTeam = _propertyNineTemplateTeam();
  // Feature: squad-screen-redesign, Property 9: Accessible player summary mirrors active state
  // **Validates: Requirements 11.3, 11.4, 11.6, 11.7, 11.9**
  Glados<_GeneratedPropertyNineCase>(
    _generatedPropertyNineCases(propertyNineTemplateTeam),
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(_propertyNineSeed),
    ),
  ).test(
    'Feature: squad-screen-redesign, Property 9: Accessible player summary '
    'mirrors active state for $_propertyRuns generated cases '
    '(seed=$_propertyNineSeed)',
    (input) {
      final reason = input.diagnostics;
      final presentation = input.presentation;
      final snapshot = playerSemanticSnapshot(presentation);
      final status = presentation.status;
      final localizedZone = _propertyNineLocalizedZoneLabel(
        input.l10n,
        snapshot.zone,
      );
      final formText = _propertyNineFormatForm(snapshot.clampedForm);
      final localizedStatusLabels = <String>[
        if (status.hasActiveInjury) input.l10n.squad_statusInjury,
        if (status.hasActiveSuspension) input.l10n.squad_statusSuspension,
        if (status.hasPositionMismatch) input.l10n.squad_positionMismatch,
      ];
      final rowBaseLabel = input.l10n.squad_playerRowSemantics(
        snapshot.playerName,
        snapshot.positionCode,
        snapshot.roundedOvr,
        formText,
        localizedZone,
      );
      final rowLabel = localizedStatusLabels.isEmpty
          ? rowBaseLabel
          : '$rowBaseLabel. ${localizedStatusLabels.join('. ')}.';
      final markerLabel = input.l10n.squad_playerMarkerSemantics(
        snapshot.playerName,
        snapshot.positionCode,
        localizedStatusLabels.join(', '),
      );
      final semanticLabel = presentation.semanticLabel;

      expect(input.localeCode, anyOf('en', 'pl'), reason: reason);
      expect(
        input.l10n.localeName,
        startsWith(input.localeCode),
        reason: reason,
      );
      expect(input.team.roster, hasLength(1), reason: reason);
      expect(
        input.team.roster.single.id,
        snapshot.playerId,
        reason: '$reason presentation must describe the generated team player',
      );
      expect(presentation.zone, input.zone, reason: reason);
      expect(snapshot.zone, input.zone, reason: reason);
      expect(
        snapshot.zoneLabel,
        rosterZoneLabel(input.zone),
        reason: '$reason stable presentation zone label',
      );
      expect(snapshot.playerName, presentation.player.name, reason: reason);
      expect(
        snapshot.position,
        presentation.player.position,
        reason: '$reason exact presentation position',
      );
      expect(
        snapshot.positionCode,
        presentation.player.position.code,
        reason: '$reason exact position code',
      );
      expect(
        snapshot.roundedOvr,
        roundedOvrForDisplay(presentation.player.overall()),
        reason: '$reason rounded OVR must match public presentation API',
      );
      expect(
        snapshot.clampedForm,
        clampedFormValue(presentation.player.state.form),
        reason: '$reason clamped form must match public presentation API',
      );
      expect(
        snapshot.clampedForm,
        allOf(greaterThanOrEqualTo(0.0), lessThanOrEqualTo(10.0), isNotNaN),
        reason: '$reason clamped form must stay on the 0–10 scale',
      );
      expect(
        presentation.assignment?.key,
        input.assignment?.key,
        reason: '$reason assignment key must remain visible to semantics',
      );
      expect(
        status.hasActiveInjury,
        input.hasActiveInjury,
        reason: '$reason injury state must be independently projected',
      );
      expect(
        status.hasActiveSuspension,
        input.hasActiveSuspension,
        reason: '$reason suspension state must be independently projected',
      );
      expect(
        status.hasPositionMismatch,
        input.hasPositionMismatch,
        reason: '$reason mismatch state must use the exact assignment',
      );
      if (input.assignment == null) {
        expect(
          status.hasPositionMismatch,
          isFalse,
          reason: '$reason missing assignment cannot create a mismatch',
        );
      }

      // PlayerPresentation exposes the locale-neutral accessibility snapshot;
      // the generated PL/EN labels below mirror the widget row and marker
      // contracts without depending on private widget implementation details.
      expect(semanticLabel, snapshot.label, reason: reason);
      for (final fragment in [
        snapshot.playerName,
        snapshot.positionCode,
        snapshot.roundedOvr.toString(),
        formText,
        snapshot.zoneLabel,
      ]) {
        expect(
          fragment,
          isNotEmpty,
          reason: '$reason non-empty summary fragment',
        );
        expect(
          semanticLabel,
          contains(fragment),
          reason: '$reason neutral summary fragment $fragment',
        );
      }

      final neutralStatusCases = <(String, bool)>[
        ('injury', status.hasActiveInjury),
        ('suspension', status.hasActiveSuspension),
        ('position-mismatch', status.hasPositionMismatch),
      ];
      for (final (token, active) in neutralStatusCases) {
        expect(
          _propertyNineOccurrenceCount(semanticLabel, token),
          active ? 1 : 0,
          reason:
              '$reason neutral status token $token must mirror active state',
        );
      }

      // The row summary contains the complete localized player data contract.
      expect(rowLabel, contains(snapshot.playerName), reason: reason);
      expect(rowLabel, contains(snapshot.positionCode), reason: reason);
      expect(
        rowLabel,
        contains(snapshot.roundedOvr.toString()),
        reason: '$reason localized row rounded OVR',
      );
      expect(
        rowLabel,
        contains(formText),
        reason: '$reason localized row form',
      );
      expect(
        rowLabel,
        contains(localizedZone),
        reason: '$reason localized row zone',
      );
      expect(
        localizedZone,
        isNotEmpty,
        reason: '$reason generated ${input.localeCode} zone label',
      );
      expect(
        input.l10n.squad_zoneFrameSemantics(localizedZone),
        contains(localizedZone),
        reason: '$reason localized zone frame semantics',
      );
      expect(markerLabel, contains(snapshot.playerName), reason: reason);
      expect(markerLabel, contains(snapshot.positionCode), reason: reason);

      final localizedStatusCases = <(String, bool)>[
        (input.l10n.squad_statusInjury, status.hasActiveInjury),
        (input.l10n.squad_statusSuspension, status.hasActiveSuspension),
        (input.l10n.squad_positionMismatch, status.hasPositionMismatch),
      ];
      for (final (label, active) in localizedStatusCases) {
        expect(label, isNotEmpty, reason: '$reason generated status label');
        final expectedOccurrences = active ? 1 : 0;
        expect(
          _propertyNineOccurrenceCount(rowLabel, label),
          expectedOccurrences,
          reason: '$reason row status $label must match active state',
        );
        expect(
          _propertyNineOccurrenceCount(markerLabel, label),
          expectedOccurrences,
          reason: '$reason marker status $label must match active state',
        );
      }
    },
  );
}

final Generator<_GeneratedFormPresentationCase>
_generatedFormPresentationCases = any.simple<_GeneratedFormPresentationCase>(
  generate: (random, size) {
    final scenario = size % 14;
    final rawForm = switch (scenario) {
      0 => -1.0 - random.nextInt(1001),
      1 => 0.0,
      2 => 1.0,
      3 => _formValueBetween(random, 1.0, 3.0),
      4 => 3.0,
      5 => _formValueBetween(random, 3.0, 5.0),
      6 => 5.0,
      7 => _formValueBetween(random, 5.0, 7.0),
      8 => 7.0,
      9 => _formValueBetween(random, 7.0, 9.0),
      10 => 9.0,
      11 => _formValueBetween(random, 9.0, 10.0),
      12 => 10.0,
      _ => 11.0 + random.nextInt(1001),
    };

    return _GeneratedFormPresentationCase(
      rawForm: rawForm,
      generationSize: size,
      scenario: _formScenarioName(scenario),
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

const _propertySixFormStops = <ColorStop>[
  ColorStop(value: 1, color: Colors.red),
  ColorStop(value: 3, color: Colors.orange),
  ColorStop(value: 5, color: Colors.yellow),
  ColorStop(value: 7, color: Colors.lightGreen),
  ColorStop(value: 9, color: Color(0xFF2E7D32)),
  ColorStop(value: 10, color: Colors.blue),
];

double _formValueBetween(Random random, double lower, double upper) {
  const subdivisions = 1000;
  final numerator = 1 + random.nextInt(subdivisions - 1);
  return lower + ((upper - lower) * (numerator / subdivisions));
}

String _formScenarioName(int scenario) => switch (scenario) {
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

double _expectedClampedFormForPropertySix(double rawForm) {
  if (rawForm.isNaN || rawForm == double.negativeInfinity) return 0.0;
  if (rawForm == double.infinity) return 10.0;
  return rawForm.clamp(0.0, 10.0).toDouble();
}

Color _expectedFormColorForPropertySix(double clampedForm) {
  final value = _expectedClampedFormForPropertySix(clampedForm);
  final first = _propertySixFormStops.first;
  final last = _propertySixFormStops.last;
  if (value <= first.value) return first.color;
  if (value >= last.value) return last.color;

  for (var index = 1; index < _propertySixFormStops.length; index++) {
    final upper = _propertySixFormStops[index];
    if (value <= upper.value) {
      final lower = _propertySixFormStops[index - 1];
      if (value == upper.value) return upper.color;
      final fraction = ((value - lower.value) / (upper.value - lower.value))
          .clamp(0.0, 1.0)
          .toDouble();
      return _interpolatePropertySixColor(lower.color, upper.color, fraction);
    }
  }

  return last.color;
}

Color _interpolatePropertySixColor(Color lower, Color upper, double fraction) {
  return Color.fromARGB(
    _interpolatePropertySixChannel(lower.a, upper.a, fraction),
    _interpolatePropertySixChannel(lower.r, upper.r, fraction),
    _interpolatePropertySixChannel(lower.g, upper.g, fraction),
    _interpolatePropertySixChannel(lower.b, upper.b, fraction),
  );
}

int _interpolatePropertySixChannel(
  double lower,
  double upper,
  double fraction,
) {
  final lowerByte = (lower * 255.0).round();
  final upperByte = (upper * 255.0).round();
  return (lowerByte + ((upperByte - lowerByte) * fraction))
      .round()
      .clamp(0, 255)
      .toInt();
}

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

final Generator<_GeneratedNameNormalizationCase>
_generatedNameNormalizationCases = any.simple<_GeneratedNameNormalizationCase>(
  generate: (random, size) {
    final scenario = size % 5;
    if (scenario == 0) {
      final whitespace = _repeatedNameWhitespace(random);
      return _GeneratedNameNormalizationCase(
        rawName: '$whitespace${_repeatedNameWhitespace(random)}',
        expectedPortions: const <String>[],
        generationSize: size,
        scenario: 'whitespace-only',
        shrunk: false,
      );
    }

    final portionCount = scenario == 1 ? 1 : 2 + random.nextInt(4);
    final portions = <String>[
      for (var index = 0; index < portionCount; index++)
        _randomNamePortion(random, size, index),
    ];
    final rawName = StringBuffer(_repeatedNameWhitespace(random));
    for (var index = 0; index < portions.length; index++) {
      if (index > 0) rawName.write(_repeatedNameWhitespace(random));
      rawName.write(portions[index]);
    }
    rawName.write(_repeatedNameWhitespace(random));

    return _GeneratedNameNormalizationCase(
      rawName: rawName.toString(),
      expectedPortions: List<String>.unmodifiable(portions),
      generationSize: size,
      scenario: scenario == 1 ? 'single-portion' : 'multiple-portions',
      shrunk: false,
    );
  },
  shrink: (input) sync* {
    if (input.shrunk) return;
    yield const _GeneratedNameNormalizationCase(
      rawName: ' \t  ',
      expectedPortions: <String>[],
      generationSize: 0,
      scenario: 'shrunk-whitespace-only',
      shrunk: true,
    );
  },
);

const _nameWhitespaceCharacters = <String>[' ', '\t', '\n', '\r'];

String _repeatedNameWhitespace(Random random) {
  final count = 2 + random.nextInt(5);
  final whitespace = StringBuffer();
  for (var index = 0; index < count; index++) {
    whitespace.write(
      _nameWhitespaceCharacters[random.nextInt(
        _nameWhitespaceCharacters.length,
      )],
    );
  }
  return whitespace.toString();
}

String _randomNamePortion(Random random, int size, int index) {
  const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const lowercase = 'abcdefghijklmnopqrstuvwxyz';
  final length = 1 + random.nextInt(8);
  final portion = StringBuffer(uppercase[random.nextInt(uppercase.length)]);
  for (var character = 1; character < length; character++) {
    portion.write(lowercase[random.nextInt(lowercase.length)]);
  }
  return '${portion.toString()}-$size-$index';
}

String _nameForDiagnostics(String rawName) => rawName
    .replaceAll(' ', '·')
    .replaceAll('\t', r'\t')
    .replaceAll('\r', r'\r')
    .replaceAll('\n', r'\n');

class _GeneratedNameNormalizationCase {
  const _GeneratedNameNormalizationCase({
    required this.rawName,
    required this.expectedPortions,
    required this.generationSize,
    required this.scenario,
    required this.shrunk,
  });

  final String rawName;
  final List<String> expectedPortions;
  final int generationSize;
  final String scenario;
  final bool shrunk;

  String get diagnostics =>
      'seed=$_propertyFourSeed generationSize=$generationSize '
      'scenario=$scenario raw=${_nameForDiagnostics(rawName)} '
      'portions=${expectedPortions.join('|')}';

  @override
  String toString() => diagnostics;
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

Player _assignmentTemplatePlayer() {
  final game = GameFactory().create(
    const NewGameRequest(
      saveName: 'Squad presentation Property 2',
      playerTeamId: 'team_europe_0',
      seed: _propertyTwoSeed,
    ),
  );
  return game.leagueState.teams
      .firstWhere((team) => team.id == 'team_europe_0')
      .roster
      .first;
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

const _propertySevenExpectedZonePresentation = <RosterZone, (String, Color)>{
  RosterZone.xi: ('XI', Colors.green),
  RosterZone.bench: ('Bench', Colors.blue),
  RosterZone.reserve: ('Reserves', Colors.yellow),
};

Team _propertySevenTemplateTeam() {
  final game = GameFactory().create(
    const NewGameRequest(
      saveName: 'Squad presentation Property 7',
      playerTeamId: 'team_europe_0',
      seed: _propertySevenSeed,
    ),
  );
  return game.leagueState.teams.firstWhere(
    (team) => team.id == 'team_europe_0',
  );
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

Team _propertyNineTemplateTeam() {
  final game = GameFactory().create(
    const NewGameRequest(
      saveName: 'Squad presentation Property 9',
      playerTeamId: 'team_europe_0',
      seed: _propertyNineSeed,
    ),
  );
  return game.leagueState.teams.firstWhere(
    (team) => team.id == 'team_europe_0',
  );
}

Generator<_GeneratedPropertyNineCase> _generatedPropertyNineCases(
  Team template,
) => any.simple<_GeneratedPropertyNineCase>(
  generate: (random, size) {
    final statusScenario = size % 8;
    final assignmentScenario = (size ~/ 8) % 3;
    final localeCode = size.isEven ? 'en' : 'pl';
    final zone =
        RosterZone.values[(size + random.nextInt(RosterZone.values.length)) %
            RosterZone.values.length];
    final templatePlayer =
        template.roster[random.nextInt(template.roster.length)];
    final token = random.nextInt(1 << 30);
    final player = templatePlayer.copyWith(
      id: 'p9-$size-$token',
      name: 'Property 9 p9-$size-$token',
      state: templatePlayer.state.copyWith(
        form: _propertyNineRawForm(random, size),
        injury: (statusScenario & 1) != 0
            ? const Injury(
                id: 'squad-property-nine-injury',
                group: InjuryGroup.legMuscles,
                type: InjuryType.minor,
                daysTotal: 5,
                daysRemaining: 2,
              )
            : null,
        suspensionGamesRemaining: (statusScenario & 2) != 0 ? 2 : 0,
      ),
    );
    final assignment = switch (assignmentScenario) {
      0 => null,
      1 => _propertyNineAssignedSlot(
        player: player,
        position: player.position,
        size: size,
        token: token,
      ),
      _ => _propertyNineAssignedSlot(
        player: player,
        position: _propertyNineDifferentPosition(player.position),
        size: size,
        token: token,
      ),
    };
    final team = _propertyNineTeamForZone(template, player, zone);
    final presentation = playerPresentation(
      player: player,
      team: team,
      assignment: assignment,
    );
    final hasPositionMismatch =
        assignment != null && player.position != assignment.position;

    return _GeneratedPropertyNineCase(
      team: team,
      presentation: presentation,
      l10n: lookupAppLocalizations(Locale(localeCode)),
      localeCode: localeCode,
      zone: zone,
      assignment: assignment,
      hasActiveInjury: (statusScenario & 1) != 0,
      hasActiveSuspension: (statusScenario & 2) != 0,
      hasPositionMismatch: hasPositionMismatch,
      generationSize: size,
      token: token,
      scenario:
          'locale=$localeCode zone=${zone.name} '
          'assignment=${_propertyNineAssignmentScenarioName(assignmentScenario)} '
          '${_propertyNineStatusScenarioName(statusScenario)}',
      shrunk: false,
    );
  },
  shrink: (input) sync* {
    if (input.shrunk) return;

    final player = input.presentation.player.copyWith(
      id: 'p9-shrunk',
      name: 'Property 9 shrunk',
      state: input.presentation.player.state.copyWith(
        form: 0.0,
        injury: null,
        suspensionGamesRemaining: 0,
      ),
    );
    final team = _propertyNineTeamForZone(
      input.team,
      player,
      RosterZone.reserve,
    );
    yield _GeneratedPropertyNineCase(
      team: team,
      presentation: playerPresentation(
        player: player,
        team: team,
        assignment: null,
      ),
      l10n: lookupAppLocalizations(const Locale('en')),
      localeCode: 'en',
      zone: RosterZone.reserve,
      assignment: null,
      hasActiveInjury: false,
      hasActiveSuspension: false,
      hasPositionMismatch: false,
      generationSize: 0,
      token: 0,
      scenario: 'shrunk-no-assignment',
      shrunk: true,
    );
  },
);

AssignedSlot _propertyNineAssignedSlot({
  required Player player,
  required Position position,
  required int size,
  required int token,
}) => AssignedSlot(
  key: 'p9-slot-$size-$token-${player.id}',
  position: position,
  group: positionGroupOf(position),
  x: 0.5,
  y: 0.5,
);

Position _propertyNineDifferentPosition(Position position) {
  final nextIndex = (position.index + 1) % Position.values.length;
  return Position.values[nextIndex];
}

Team _propertyNineTeamForZone(Team template, Player player, RosterZone zone) =>
    template.copyWith(
      roster: [player],
      lineupPlayerIds: zone == RosterZone.xi ? [player.id] : const <String>[],
      benchPlayerIds: zone == RosterZone.bench ? [player.id] : const <String>[],
    );

double _propertyNineRawForm(Random random, int size) {
  switch (size % 7) {
    case 0:
      return -1.0 - random.nextInt(20);
    case 1:
      return 0.0;
    case 2:
      return random.nextInt(1001) / 100.0;
    case 3:
      return 10.0;
    case 4:
      return 10.0 + random.nextInt(20) + 0.5;
    case 5:
      return 1.0;
    default:
      return random.nextInt(1001) / 100.0;
  }
}

String _propertyNineLocalizedZoneLabel(AppLocalizations l10n, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return l10n.squad_zoneXi;
    case RosterZone.bench:
      return l10n.squad_zoneBench;
    case RosterZone.reserve:
      return l10n.squad_zoneReserves;
  }
}

String _propertyNineFormatForm(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

int _propertyNineOccurrenceCount(String text, String value) {
  if (value.isEmpty) return 0;
  var count = 0;
  var start = 0;
  while (start < text.length) {
    final index = text.indexOf(value, start);
    if (index < 0) break;
    count++;
    start = index + value.length;
  }
  return count;
}

String _propertyNineAssignmentScenarioName(int scenario) => switch (scenario) {
  0 => 'missing',
  1 => 'exact',
  _ => 'mismatch',
};

String _propertyNineStatusScenarioName(int scenario) {
  final injury = (scenario & 1) != 0;
  final suspension = (scenario & 2) != 0;
  final mismatchRequested = (scenario & 4) != 0;
  return 'injury=$injury suspension=$suspension '
      'mismatchRequested=$mismatchRequested';
}

class _GeneratedPropertyNineCase {
  const _GeneratedPropertyNineCase({
    required this.team,
    required this.presentation,
    required this.l10n,
    required this.localeCode,
    required this.zone,
    required this.assignment,
    required this.hasActiveInjury,
    required this.hasActiveSuspension,
    required this.hasPositionMismatch,
    required this.generationSize,
    required this.token,
    required this.scenario,
    required this.shrunk,
  });

  final Team team;
  final PlayerPresentation presentation;
  final AppLocalizations l10n;
  final String localeCode;
  final RosterZone zone;
  final AssignedSlot? assignment;
  final bool hasActiveInjury;
  final bool hasActiveSuspension;
  final bool hasPositionMismatch;
  final int generationSize;
  final int token;
  final String scenario;
  final bool shrunk;

  String get diagnostics {
    final player = presentation.player;
    return 'seed=$_propertyNineSeed generationSize=$generationSize '
        'scenario=$scenario token=$token player=${player.id} '
        'position=${player.position.code} rawForm=${player.state.form} '
        'clampedForm=${presentation.clampedForm} '
        'roundedOvr=${presentation.roundedOvr} '
        'assignment=${assignment?.position.code ?? 'none'}';
  }

  @override
  String toString() => diagnostics;
}
