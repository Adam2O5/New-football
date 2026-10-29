@Tags(['property'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import '../../helpers/fixtures/presentation_fixtures.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';

const _propertyRuns = 120;

void main() {
  const squadRowPropertyFourSeed = 8213;
  final propertyFourTemplateTeam = presentationTeam();

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
}
