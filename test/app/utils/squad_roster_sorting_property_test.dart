@Tags(['property'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import '../../helpers/fixtures/presentation_fixtures.dart';
import 'package:new_football/core/tactics/player_sort.dart';

const _propertyRuns = 120;

void main() {
  const propertyEightSeed = 8209;
  final propertyEightTemplateTeam = presentationTeam();

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
}
