import 'dart:convert';
import 'package:new_football/core/balance/balance_config.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/formation_layout.dart';

/// Returns the exact roster multiset required by the slots of [formation] and
/// the four independent GK/CB/CM/ST additions.
Map<Position, int> expectedPositionCounts(Formation formation) {
  final counts = <Position, int>{
    for (final position in Position.values) position: 0,
  };

  for (final slot in FormationLayout.of(formation).slots) {
    counts[slot.position] = counts[slot.position]! + 2;
  }

  for (final extraPosition in <Position>[
    Position.gk,
    Position.cb,
    Position.cm,
    Position.st,
  ]) {
    counts[extraPosition] = counts[extraPosition]! + 1;
  }

  return counts;
}

void expectInitialTeamInvariant(Team team, int seed) {
  final context =
      'seed=$seed team=${team.id} formation=${team.tactics.formation.name}';
  final formation = team.tactics.formation;
  final slots = FormationLayout.of(formation).slots;
  final expectedCounts = expectedPositionCounts(formation);
  final actualCounts = actualPositionCounts(team);
  final rosterIds = team.roster.map((player) => player.id).toList();
  final rosterById = {for (final player in team.roster) player.id: player};
  final lineupIds = team.lineupPlayerIds;
  final lineupSet = lineupIds.toSet();
  final benchIds = team.benchPlayerIds;
  final benchSet = benchIds.toSet();

  expect(Formation.values, contains(formation), reason: '$context formation');
  expect(slots.length, 11, reason: '$context slot count');
  expect(team.roster.length, 26, reason: '$context roster length');
  const rosterRules = BalanceConfig.defaults;
  expect(
    team.roster.length,
    inInclusiveRange(rosterRules.roster.minSize, rosterRules.roster.maxSize),
    reason: '$context configured roster limits',
  );
  expect(
    lineupIds.length,
    rosterRules.roster.startingXi,
    reason: '$context configured XI size',
  );
  expect(
    benchIds.length,
    lessThanOrEqualTo(rosterRules.roster.benchSize),
    reason: '$context configured bench limit',
  );
  expect(
    rosterIds.toSet().length,
    rosterIds.length,
    reason: '$context roster IDs must be unique',
  );
  for (final position in Position.values) {
    expect(
      actualCounts[position],
      expectedCounts[position],
      reason:
          '$context position=${position.code} expected='
          '${expectedCounts[position]} actual=${actualCounts[position]}',
    );
  }

  expect(lineupIds.length, 11, reason: '$context XI length');
  expect(
    lineupSet.length,
    lineupIds.length,
    reason: '$context XI IDs must be unique',
  );
  expect(
    lineupIds.every((id) => rosterById.containsKey(id)),
    isTrue,
    reason: '$context XI must belong to roster',
  );
  expect(
    lineupIds.every((id) => rosterById[id]!.isAvailable),
    isTrue,
    reason: '$context XI must contain available players',
  );
  for (var index = 0; index < slots.length; index++) {
    final player = rosterById[lineupIds[index]];
    expect(
      player!.position,
      slots[index].position,
      reason:
          '$context slot=$index expected='
          '${slots[index].position.code} actual=${player.position.code}',
    );
  }

  expect(benchIds.length, lessThanOrEqualTo(7), reason: '$context bench limit');
  expect(
    benchSet.length,
    benchIds.length,
    reason: '$context bench IDs must be unique',
  );
  expect(
    benchIds.every((id) => rosterById.containsKey(id)),
    isTrue,
    reason: '$context bench must belong to roster',
  );
  expect(
    lineupSet.intersection(benchSet),
    isEmpty,
    reason: '$context XI and bench must be disjoint',
  );
}

String initialProjection(GameSave save) => projectionJson({
  'saveSeed': save.saveSeed,
  'playerTeamId': save.leagueState.playerTeamId,
  'teams': save.leagueState.teams.map(teamProjection).toList(),
});

Map<String, Object?> teamProjection(Team team) {
  final counts = actualPositionCounts(team);
  return {
    'teamId': team.id,
    'formation': team.tactics.formation.name,
    'roster': team.roster.map(playerProjection).toList(),
    'positionMultiset': {
      for (final position in Position.values) position.name: counts[position],
    },
    'lineupPlayerIds': team.lineupPlayerIds,
    'benchPlayerIds': team.benchPlayerIds,
  };
}

Map<String, Object?> playerProjection(Player player) => {
  'id': player.id,
  'name': player.name,
  'position': player.position.name,
  'nationality': player.nationality.name,
  'age': player.age,
  'attributes': player.attributes.toJson(),
  'personality': player.personality.name,
  'heightCm': player.heightCm,
  'optimalRole': player.optimalRole.toJson(),
  'contract': player.contract.toJson(),
  'state': player.state.toJson(),
  'hidden': player.hidden.toJson(),
  'potentialStars': player.potentialStars,
  'seasonStartOvr': player.seasonStartOvr,
  'pointValue': player.pointValue,
};

String rosterIdsProjection(dynamic league) => projectionJson({
  'teams': league.teams
      .map(
        (team) => {
          'teamId': team.id,
          'rosterIds': team.roster.map((player) => player.id).toList(),
        },
      )
      .toList(),
});

String projectionJson(Map<String, Object?> value) =>
    jsonEncode(canonicalize(value));

Object? canonicalize(Object? value) {
  if (value is Map) {
    final entries = <String, Object?>{
      for (final entry in value.entries)
        entry.key.toString(): canonicalize(entry.value),
    };
    final keys = entries.keys.toList()..sort();
    return <String, Object?>{for (final key in keys) key: entries[key]};
  }
  if (value is Iterable) {
    return value.map(canonicalize).toList();
  }
  return value;
}

Map<Position, int> actualPositionCounts(Team team) {
  final counts = <Position, int>{
    for (final position in Position.values) position: 0,
  };
  for (final player in team.roster) {
    counts[player.position] = counts[player.position]! + 1;
  }
  return counts;
}
