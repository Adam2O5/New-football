import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/development_snapshot.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';

/// A single player row in the Development screen's Players tab.
class PlayerDevEntry {
  const PlayerDevEntry({
    required this.player,
    required this.ovrDelta,
    required this.potentialDelta,
    required this.progress,
    required this.progressDelta,
    required this.growthRate,
    required this.weeklyOvrDelta,
  });

  final Player player;
  final int ovrDelta;
  final double potentialDelta;
  final double progress;
  final double progressDelta;
  final double growthRate;
  final int weeklyOvrDelta;

  int get progressDirection => progressDelta.sign.toInt();
}

/// A single staff role entry in the Development screen's Staff tab.
///
/// Alias of the core [StaffDevelopmentSnapshot] so the screen keeps one name
/// while names, values and deltas stay derived from the canonical role map.
typedef StaffDevEntry = StaffDevelopmentSnapshot;

/// Aggregated data for the Development screen, computed on-demand.
class DevelopmentData {
  const DevelopmentData({required this.players, required this.staff});

  final List<PlayerDevEntry> players;
  final List<StaffDevEntry> staff;
}

/// Computes [DevelopmentData] from the current player team on-demand.
///
/// The provider recomputes whenever [activeLeagueProvider] changes.
final developmentDataProvider = Provider<DevelopmentData?>((ref) {
  final league = ref.watch(activeLeagueProvider);
  final team = league?.playerTeam;
  if (team == null) return null;
  return _buildDevelopmentData(team);
});

DevelopmentData _buildDevelopmentData(Team team) {
  return DevelopmentData(
    players: _buildPlayerEntries(team),
    staff: _buildStaffEntries(team),
  );
}

List<PlayerDevEntry> _buildPlayerEntries(Team team) {
  final sorted = [...team.roster]
    ..sort((a, b) {
      final groupCmp = positionGroupOrder(
        a.position,
      ).compareTo(positionGroupOrder(b.position));
      if (groupCmp != 0) return groupCmp;
      return a.name.compareTo(b.name);
    });

  return sorted.map((player) {
    final (ovrDelta, potDelta) = player.devDelta;
    return PlayerDevEntry(
      player: player,
      ovrDelta: ovrDelta,
      potentialDelta: potDelta,
      progress: player.hidden.overallProgress,
      progressDelta: player.state.lastDevelopmentProgressDelta,
      growthRate: player.hidden.growthRate,
      weeklyOvrDelta: player.state.lastDevelopmentOvrDelta,
    );
  }).toList();
}

List<StaffDevEntry> _buildStaffEntries(Team team) =>
    StaffDevelopmentSnapshot.forTeamStaff(team.staff);
