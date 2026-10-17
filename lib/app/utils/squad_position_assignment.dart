part of 'squad_presentation.dart';

/// An immutable index of exact formation assignments by player ID.
///
/// Only players with a non-null [PlacedPlayer.player] are stored. Looking up a
/// player that is absent returns null, which is intentionally different from a
/// position mismatch. The source placements and all input lists/maps remain
/// untouched.
@immutable
class PositionAssignmentIndex {
  PositionAssignmentIndex._(Map<String, AssignedSlot> assignments)
    : _assignments = Map.unmodifiable(assignments);

  /// Builds an index from the direct placement results.
  factory PositionAssignmentIndex.fromPlacements(
    Iterable<PlacedPlayer> placements,
  ) {
    final assignments = <String, AssignedSlot>{};
    for (final placement in placements) {
      final player = placement.player;
      if (player != null) assignments[player.id] = placement.slot;
    }
    return PositionAssignmentIndex._(assignments);
  }

  /// Creates an index from a team using the same placement algorithm used by
  /// [PitchField]. The optional formation defaults to the team's tactics.
  factory PositionAssignmentIndex.forTeam(Team team, {Formation? formation}) {
    final layout = FormationLayout.of(formation ?? team.tactics.formation);
    final playersById = <String, Player>{
      for (final player in team.roster) player.id: player,
    };
    final placements = placePlayersOnSlots(
      slots: layout.slots,
      lineupPlayerIds: team.lineupPlayerIds,
      lineupSlots: team.lineupSlots,
      playersById: playersById,
    );
    return PositionAssignmentIndex.fromPlacements(placements);
  }

  /// An immutable map containing only assigned player IDs.
  final Map<String, AssignedSlot> _assignments;

  Map<String, AssignedSlot> get assignmentsByPlayerId => _assignments;
  Map<String, AssignedSlot> get map => _assignments;
  Iterable<String> get playerIds => _assignments.keys;
  Iterable<AssignedSlot> get slots => _assignments.values;
  int get length => _assignments.length;
  bool get isEmpty => _assignments.isEmpty;
  bool get isNotEmpty => _assignments.isNotEmpty;

  AssignedSlot? operator [](String playerId) => _assignments[playerId];

  AssignedSlot? assignmentFor(String playerId) => _assignments[playerId];

  AssignedSlot? positionAssignmentFor(String playerId) =>
      _assignments[playerId];

  bool containsPlayer(String playerId) => _assignments.containsKey(playerId);
}

/// Builds an assignment index from already-computed placement results.
PositionAssignmentIndex positionAssignmentIndexFromPlacements(
  Iterable<PlacedPlayer> placements,
) => PositionAssignmentIndex.fromPlacements(placements);

/// Builds the shared assignment index from the direct placement projection.
PositionAssignmentIndex positionAssignmentIndexFor({
  required List<AssignedSlot> slots,
  required List<String> lineupPlayerIds,
  required Map<String, Player> playersById,
}) {
  final placements = placePlayersOnSlots(
    slots: slots,
    lineupPlayerIds: lineupPlayerIds,
    playersById: playersById,
  );
  return PositionAssignmentIndex.fromPlacements(placements);
}

/// Convenience projection for a complete team and its current formation.
PositionAssignmentIndex positionAssignmentIndexForTeam(
  Team team, {
  Formation? formation,
}) => PositionAssignmentIndex.forTeam(team, formation: formation);

/// Returns the immutable player-ID-to-slot map from placement results.
Map<String, AssignedSlot> assignmentsByPlayerIdFromPlacements(
  Iterable<PlacedPlayer> placements,
) => positionAssignmentIndexFromPlacements(placements).assignmentsByPlayerId;

/// Returns the immutable player-ID-to-slot map used by roster rows and
/// markers. A missing player ID is intentionally absent and resolves to null
/// through [PositionAssignmentIndex].
Map<String, AssignedSlot> assignmentsByPlayerIdFor({
  required List<AssignedSlot> slots,
  required List<String> lineupPlayerIds,
  required Map<String, Player> playersById,
}) => positionAssignmentIndexFor(
  slots: slots,
  lineupPlayerIds: lineupPlayerIds,
  playersById: playersById,
).assignmentsByPlayerId;

/// Alias for call sites that prefer the explicit "position" terminology.
Map<String, AssignedSlot> positionAssignmentsByPlayerId({
  required List<AssignedSlot> slots,
  required List<String> lineupPlayerIds,
  required Map<String, Player> playersById,
}) => assignmentsByPlayerIdFor(
  slots: slots,
  lineupPlayerIds: lineupPlayerIds,
  playersById: playersById,
);
