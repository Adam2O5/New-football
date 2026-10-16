import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/position_group.dart';

/// Keeps valid manual assignments, then applies the existing position/group
/// fallback once to unassigned players. This helper has no Flutter dependency.
Map<String, String> assignLineupSlots({
  required List<AssignedSlot> slots,
  required List<String> lineupPlayerIds,
  required Map<String, Player> playersById,
  Map<String, String> saved = const {},
}) {
  final ids = lineupPlayerIds.where(playersById.containsKey).toSet();
  final result = <String, String>{};
  final used = <String>{};
  for (final slot in slots) {
    final id = saved[slot.key];
    if (id != null && ids.contains(id) && used.add(id)) result[slot.key] = id;
  }
  final pending = [
    for (final id in ids)
      if (!used.contains(id)) playersById[id]!,
  ];
  final remaining = [
    for (final slot in slots)
      if (!result.containsKey(slot.key)) slot,
  ];
  void takeMatches(bool Function(AssignedSlot, Player) matches) {
    for (var i = pending.length - 1; i >= 0; i--) {
      final player = pending[i];
      final index = remaining.indexWhere((slot) => matches(slot, player));
      if (index < 0) continue;
      result[remaining.removeAt(index).key] = player.id;
      pending.removeAt(i);
    }
  }

  takeMatches((slot, player) => slot.position == player.position);
  takeMatches((slot, player) => slot.group == positionGroupOf(player.position));
  for (final player in pending) {
    if (remaining.isEmpty) break;
    result[remaining.removeAt(0).key] = player.id;
  }
  return result;
}

Team reconcileLineupSlots(Team team) {
  final byId = {for (final player in team.roster) player.id: player};
  final lineup = team.lineupPlayerIds
      .where((id) => byId[id]?.isEligibleForStartingEleven == true)
      .toSet()
      .take(11)
      .toList();
  final bench = team.benchPlayerIds
      .where((id) => !lineup.contains(id) && byId[id]?.isAvailable == true)
      .toSet()
      .toList();
  final slots = assignLineupSlots(
    slots: FormationLayout.of(team.tactics.formation).slots,
    lineupPlayerIds: lineup,
    playersById: byId,
    saved: team.lineupSlots,
  );
  if (team.lineupSlots.length == slots.length &&
      slots.entries.every((e) => team.lineupSlots[e.key] == e.value) &&
      team.lineupPlayerIds.length == lineup.length &&
      team.lineupPlayerIds.every(lineup.contains) &&
      team.benchPlayerIds.length == bench.length &&
      team.benchPlayerIds.every(bench.contains)) {
    return team;
  }
  return team.copyWith(
    lineupSlots: slots,
    lineupPlayerIds: lineup,
    benchPlayerIds: bench,
  );
}

LeagueState reconcileLeagueLineups(LeagueState league) {
  final teams = league.teams.map(reconcileLineupSlots).toList();
  if (List.generate(
    teams.length,
    (i) => identical(teams[i], league.teams[i]),
  ).every((same) => same)) {
    return league;
  }
  return league.copyWith(teams: teams);
}

/// Uses the latest team snapshot; a stale gesture cannot reinsert a removed
/// or unavailable player. Slot assignments are swapped, not recomputed by role.
Team swapLineupPlayers(Team team, String firstId, String secondId) {
  if (firstId == secondId) return team;
  final current = reconcileLineupSlots(team);
  final byId = {for (final player in current.roster) player.id: player};
  if (!byId.containsKey(firstId) || !byId.containsKey(secondId)) return team;
  final firstXi = current.lineupPlayerIds.contains(firstId);
  final secondXi = current.lineupPlayerIds.contains(secondId);
  final firstBench = current.benchPlayerIds.contains(firstId);
  final secondBench = current.benchPlayerIds.contains(secondId);
  if (!firstXi && !secondXi && !firstBench && !secondBench) return team;
  if ((secondXi && !byId[firstId]!.isEligibleForStartingEleven) ||
      (firstXi && !byId[secondId]!.isEligibleForStartingEleven) ||
      (secondBench && !byId[firstId]!.isAvailable) ||
      (firstBench && !byId[secondId]!.isAvailable)) {
    return team;
  }
  String swap(String id) => id == firstId
      ? secondId
      : id == secondId
      ? firstId
      : id;
  return current.copyWith(
    lineupSlots: {
      for (final entry in current.lineupSlots.entries)
        entry.key: swap(entry.value),
    },
    lineupPlayerIds: current.lineupPlayerIds.map(swap).toList(),
    benchPlayerIds: current.benchPlayerIds.map(swap).toList(),
  );
}
