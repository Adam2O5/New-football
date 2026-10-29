@Tags(['property'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import '../../helpers/fixtures/presentation_fixtures.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/position_group.dart';

import '../../helpers/presentation/form_color_oracle.dart';

const _propertyRuns = 120;

void main() {
  const propertyOneSeed = 8201;
  final propertyOneTemplateTeam = presentationTeam();

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
          final expectedColor = expectedFormColorForPropertySix(
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
          final changedExpectedColor = expectedFormColorForPropertySix(
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
}
