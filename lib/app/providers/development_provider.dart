import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/development_snapshot.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
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
class StaffDevEntry {
  const StaffDevEntry({
    required this.role,
    required this.member,
    required this.attributeNames,
    required this.currentValues,
    required this.deltas,
  });

  final StaffRole role;

  /// Null when the slot is vacant.
  final StaffMember? member;

  /// Attribute names relevant for this role.
  final List<String> attributeNames;

  /// Current attribute values (same order as [attributeNames]).
  final List<double> currentValues;

  /// Growth deltas (same order). Null means no previous data available.
  final List<double?> deltas;
}

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

List<StaffDevEntry> _buildStaffEntries(Team team) {
  const roles = [
    StaffRole.headCoach,
    StaffRole.youthCoach,
    StaffRole.scout,
    StaffRole.physio,
    StaffRole.doctor,
    StaffRole.cfo,
  ];

  return roles.map((role) {
    final member = team.staff.member(role);
    final attrNames = attributesForRole(role);

    if (member == null) {
      return StaffDevEntry(
        role: role,
        member: null,
        attributeNames: attrNames,
        currentValues: List.filled(attrNames.length, 0.0),
        deltas: List.filled(attrNames.length, null),
      );
    }

    final currentValues = attrNames
        .map((name) => staffAttributeValue(member.attributes, name))
        .toList();

    final deltas = attrNames.map((name) {
      final prev = member.previousAttributes;
      if (prev == null) return null;
      return staffAttributeValue(member.attributes, name) -
          staffAttributeValue(prev, name);
    }).toList();

    return StaffDevEntry(
      role: role,
      member: member,
      attributeNames: attrNames,
      currentValues: currentValues,
      deltas: deltas,
    );
  }).toList();
}
