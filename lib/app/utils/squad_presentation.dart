import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Colors;
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';

/// The visual state of a roster-size range indicator.
enum RosterSizeState { inRange, outOfRange }

/// The icon state paired with [RosterSizeState].
enum RosterSizeIconState { check, x }

/// An immutable projection of a roster count onto an inclusive size range.
@immutable
class RosterSizePresentation {
  const RosterSizePresentation({
    required this.count,
    required this.min,
    required this.max,
    required this.clampedProgress,
    required this.isInRange,
    required this.state,
    required this.iconState,
  });

  /// Builds a presentation value from a count and range without mutating any
  /// caller-owned values.
  factory RosterSizePresentation.fromValues({
    required int count,
    required int min,
    required int max,
  }) {
    final inRange = count >= min && count <= max;
    final progress = max > min
        ? ((count - min) / (max - min)).clamp(0.0, 1.0).toDouble()
        : count <= min
        ? 0.0
        : 1.0;

    return RosterSizePresentation(
      count: count,
      min: min,
      max: max,
      clampedProgress: progress,
      isInRange: inRange,
      state: inRange ? RosterSizeState.inRange : RosterSizeState.outOfRange,
      iconState: inRange ? RosterSizeIconState.check : RosterSizeIconState.x,
    );
  }

  /// Current roster count.
  final int count;

  /// Inclusive lower bound of the configured roster range.
  final int min;

  /// Inclusive upper bound of the configured roster range.
  final int max;

  /// Progress on the range track, always bounded to 0–1.
  final double clampedProgress;

  /// Whether [count] is inclusively between [min] and [max].
  final bool isInRange;

  /// The semantic range state.
  final RosterSizeState state;

  /// The check/X state to display next to the range track.
  final RosterSizeIconState iconState;

  /// Short alias useful to track widgets.
  double get progress => clampedProgress;

  /// Short alias for callers that use the term "within range".
  bool get isWithinRange => isInRange;

  /// True when the range indicator should use its warning state.
  bool get isOutOfRange => !isInRange;

  /// A stable, locale-neutral state token for semantic snapshots.
  String get semanticState => isInRange ? 'in-range' : 'out-of-range';

  /// The semantic track color for the current state.
  Color get trackColor => isInRange ? Colors.green : Colors.red;

  /// The semantic icon token for the current state.
  String get iconToken => isInRange ? 'check' : 'x';
}

/// Projects a roster count into an immutable range presentation.
RosterSizePresentation rosterSizePresentation({
  required int count,
  required int min,
  required int max,
}) => RosterSizePresentation.fromValues(count: count, min: min, max: max);

/// Alias for callers that describe the operation as a projection.
RosterSizePresentation projectRosterSize({
  required int count,
  required int min,
  required int max,
}) => rosterSizePresentation(count: count, min: min, max: max);

/// The two normalized name lines used by a player row.
@immutable
class NameParts {
  const NameParts({
    required this.firstLine,
    required this.secondLine,
    this.original = '',
  });

  /// The first non-empty whitespace-separated portion, or an empty string.
  final String firstLine;

  /// All remaining portions joined by one space, or an empty string.
  final String secondLine;

  /// The original input, retained for semantic consumers that need it.
  final String original;

  String get first => firstLine;
  String get second => secondLine;
  String get givenName => firstLine;
  String get familyName => secondLine;
  bool get hasSecondLine => secondLine.isNotEmpty;

  /// The normalized name represented by these two lines.
  String get normalized =>
      [firstLine, secondLine].where((part) => part.isNotEmpty).join(' ');
}

/// Splits a player name into a first line and a remaining-name line.
///
/// One or more whitespace characters are treated as one separator and empty
/// portions are discarded. The input is never modified.
NameParts splitPlayerName(String raw) {
  final portions = raw
      .split(RegExp(r'\s+'))
      .where((portion) => portion.isNotEmpty)
      .toList(growable: false);

  if (portions.isEmpty) {
    return NameParts(firstLine: '', secondLine: '', original: raw);
  }
  if (portions.length == 1) {
    return NameParts(firstLine: portions.first, secondLine: '', original: raw);
  }

  return NameParts(
    firstLine: portions.first,
    secondLine: portions.skip(1).join(' '),
    original: raw,
  );
}

/// The independent player conditions that feed squad status presentation.
@immutable
class SquadStatus {
  const SquadStatus({
    bool? hasActiveInjury,
    bool? hasActiveSuspension,
    bool? hasPositionMismatch,
    bool? activeInjury,
    bool? activeSuspension,
    bool? positionMismatch,
  }) : hasActiveInjury = hasActiveInjury ?? activeInjury ?? false,
       hasActiveSuspension = hasActiveSuspension ?? activeSuspension ?? false,
       hasPositionMismatch = hasPositionMismatch ?? positionMismatch ?? false;

  /// True when the player has an active injury.
  final bool hasActiveInjury;

  /// True when the player has one or more suspension games remaining.
  final bool hasActiveSuspension;

  /// True only when an assigned slot exists and its exact position differs
  /// from the player's exact natural position.
  final bool hasPositionMismatch;

  bool get activeInjury => hasActiveInjury;
  bool get activeSuspension => hasActiveSuspension;
  bool get positionMismatch => hasPositionMismatch;
  bool get hasInjury => hasActiveInjury;
  bool get hasSuspension => hasActiveSuspension;
  bool get isUnavailable => hasActiveInjury || hasActiveSuspension;
  bool get hasAnyStatus => isUnavailable || hasPositionMismatch;

  /// The single visual color used for the position badge/marker.
  Color get color => statusColorFor(this);

  /// Stable visual state token independent of the selected [Color].
  String get colorState {
    if (isUnavailable) return 'unavailable';
    if (hasPositionMismatch) return 'position-mismatch';
    return 'normal';
  }

  /// Creates a status projection for [player] and an optional exact slot.
  factory SquadStatus.fromPlayer(Player player, {AssignedSlot? assignment}) =>
      _statusFor(player, assignment);
}

/// Resolves injury, suspension and exact-position mismatch independently.
SquadStatus statusFor(Player player, [AssignedSlot? assignment]) =>
    _statusFor(player, assignment);

/// Named-argument façade for widget call sites.
SquadStatus squadStatusFor({
  required Player player,
  AssignedSlot? assignment,
}) => _statusFor(player, assignment);

SquadStatus _statusFor(Player player, AssignedSlot? assignment) {
  return SquadStatus(
    hasActiveInjury: player.state.injury?.isActive ?? false,
    hasActiveSuspension: player.state.suspensionGamesRemaining > 0,
    // Deliberately compare Position values, not PositionGroup values. A null
    // assignment means that no mismatch can exist.
    hasPositionMismatch:
        assignment != null && player.position != assignment.position,
  );
}

/// Resolves the status color with the required red → orange → white priority.
Color statusColorFor(SquadStatus status) {
  if (status.hasActiveInjury || status.hasActiveSuspension) return Colors.red;
  if (status.hasPositionMismatch) return Colors.orange;
  return Colors.white;
}

/// Resolves a player's status color directly from the domain player and slot.
Color statusColorForPlayer(Player player, [AssignedSlot? assignment]) =>
    statusColorFor(statusFor(player, assignment));

/// A stable semantic zone/color projection for a roster row frame.
@immutable
class RosterZonePresentation {
  const RosterZonePresentation({
    required this.zone,
    required this.label,
    required this.color,
  });

  final RosterZone zone;
  final String label;
  final Color color;

  String get accessibilityLabel => label;
}

/// Maps a roster zone to its stable label and frame color.
RosterZonePresentation rosterZonePresentation(RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return const RosterZonePresentation(
        zone: RosterZone.xi,
        label: 'XI',
        color: Colors.green,
      );
    case RosterZone.bench:
      return const RosterZonePresentation(
        zone: RosterZone.bench,
        label: 'Bench',
        color: Colors.blue,
      );
    case RosterZone.reserve:
      return const RosterZonePresentation(
        zone: RosterZone.reserve,
        label: 'Reserves',
        color: Colors.yellow,
      );
  }
}

/// Alias using the common "zone presentation" naming used by widgets.
RosterZonePresentation zonePresentationFor(RosterZone zone) =>
    rosterZonePresentation(zone);

String rosterZoneLabel(RosterZone zone) => rosterZonePresentation(zone).label;

Color rosterZoneColor(RosterZone zone) => rosterZonePresentation(zone).color;

String zoneLabelFor(RosterZone zone) => rosterZoneLabel(zone);

Color zoneColorFor(RosterZone zone) => rosterZoneColor(zone);

extension RosterZonePresentationX on RosterZone {
  RosterZonePresentation get presentation => rosterZonePresentation(this);
  String get presentationLabel => rosterZoneLabel(this);
  Color get presentationColor => rosterZoneColor(this);
}

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

/// A pure snapshot of the data a player row/marker needs to render.
@immutable
class PlayerPresentation {
  const PlayerPresentation({
    required this.player,
    required this.zone,
    required this.assignment,
    required this.status,
    required this.roundedOvr,
    required this.clampedForm,
    required this.nameParts,
  });

  /// Creates a snapshot using the supplied exact assignment, if any.
  factory PlayerPresentation.fromPlayer({
    required Player player,
    required Team team,
    AssignedSlot? assignment,
    AssignedSlot? positionAssignment,
  }) {
    final resolvedAssignment = assignment ?? positionAssignment;
    return PlayerPresentation(
      player: player,
      zone: rosterZoneOf(team, player.id),
      assignment: resolvedAssignment,
      status: statusFor(player, resolvedAssignment),
      roundedOvr: roundedOvrForDisplay(player.overall()),
      clampedForm: clampedFormValue(player.state.form),
      nameParts: splitPlayerName(player.name),
    );
  }

  /// Positional façade convenient for small pure test fixtures.
  factory PlayerPresentation.forPlayer(
    Player player, {
    required Team team,
    AssignedSlot? assignment,
    AssignedSlot? positionAssignment,
  }) => PlayerPresentation.fromPlayer(
    player: player,
    team: team,
    assignment: assignment,
    positionAssignment: positionAssignment,
  );

  final Player player;
  final RosterZone zone;
  final AssignedSlot? assignment;
  final SquadStatus status;
  final int roundedOvr;
  final double clampedForm;
  final NameParts nameParts;

  AssignedSlot? get positionAssignment => assignment;
  bool get hasActiveInjury => status.hasActiveInjury;
  bool get hasActiveSuspension => status.hasActiveSuspension;
  bool get activeInjury => status.hasActiveInjury;
  bool get activeSuspension => status.hasActiveSuspension;
  bool get positionMismatch => status.hasPositionMismatch;
  Color get statusColor => status.color;
  RosterZonePresentation get zonePresentation => rosterZonePresentation(zone);
  String get zoneLabel => zonePresentation.label;

  /// The same short form value used by the form track, kept finite and bounded.
  double get form => clampedForm;

  /// The same integer value used by the OVR badge.
  int get displayedOvr => roundedOvr;

  PlayerSemanticSnapshot get semanticSnapshot =>
      PlayerSemanticSnapshot.fromPresentation(this);

  String get semanticLabel => semanticSnapshot.label;
}

/// Builds one immutable player presentation snapshot.
PlayerPresentation playerPresentation({
  required Player player,
  required Team team,
  AssignedSlot? assignment,
  AssignedSlot? positionAssignment,
}) => PlayerPresentation.fromPlayer(
  player: player,
  team: team,
  assignment: assignment,
  positionAssignment: positionAssignment,
);

/// Alias for widget call sites that use a `for` naming convention.
PlayerPresentation presentationForPlayer({
  required Player player,
  required Team team,
  AssignedSlot? assignment,
  AssignedSlot? positionAssignment,
}) => playerPresentation(
  player: player,
  team: team,
  assignment: assignment,
  positionAssignment: positionAssignment,
);

/// Builds snapshots for the complete roster in its original domain order.
///
/// The returned list is unmodifiable and the roster itself is never sorted or
/// changed. Pass a shared [assignmentIndex] to keep rows and markers on the
/// same exact assignment projection.
List<PlayerPresentation> playerPresentationsForRoster(
  Team team, {
  PositionAssignmentIndex? assignmentIndex,
  Formation? formation,
}) {
  final index =
      assignmentIndex ??
      PositionAssignmentIndex.forTeam(team, formation: formation);
  return List<PlayerPresentation>.unmodifiable(
    team.roster.map(
      (player) => PlayerPresentation.fromPlayer(
        player: player,
        team: team,
        assignment: index[player.id],
      ),
    ),
  );
}

/// Semantic data for a player row or marker, independent of widget state.
@immutable
class PlayerSemanticSnapshot {
  const PlayerSemanticSnapshot({
    required this.playerId,
    required this.playerName,
    required this.position,
    required this.roundedOvr,
    required this.clampedForm,
    required this.zone,
    required this.zoneLabel,
    required this.hasActiveInjury,
    required this.hasActiveSuspension,
    required this.hasPositionMismatch,
  });

  factory PlayerSemanticSnapshot.fromPresentation(
    PlayerPresentation presentation,
  ) => PlayerSemanticSnapshot(
    playerId: presentation.player.id,
    playerName: presentation.player.name,
    position: presentation.player.position,
    roundedOvr: presentation.roundedOvr,
    clampedForm: presentation.clampedForm,
    zone: presentation.zone,
    zoneLabel: presentation.zoneLabel,
    hasActiveInjury: presentation.hasActiveInjury,
    hasActiveSuspension: presentation.hasActiveSuspension,
    hasPositionMismatch: presentation.positionMismatch,
  );

  final String playerId;
  final String playerName;
  final Position position;
  final int roundedOvr;
  final double clampedForm;
  final RosterZone zone;
  final String zoneLabel;
  final bool hasActiveInjury;
  final bool hasActiveSuspension;
  final bool hasPositionMismatch;

  String get positionCode => position.code;
  double get form => clampedForm;
  bool get activeInjury => hasActiveInjury;
  bool get activeSuspension => hasActiveSuspension;
  bool get positionMismatch => hasPositionMismatch;

  /// Independent status tokens; both are retained when both are active.
  List<String> get statusTokens => List<String>.unmodifiable([
    if (hasActiveInjury) 'injury',
    if (hasActiveSuspension) 'suspension',
    if (hasPositionMismatch) 'position-mismatch',
  ]);

  /// A locale-neutral fallback summary for pure consumers. Widgets should
  /// replace the status/zone words with localized labels when rendering.
  String get label {
    final parts = <String>[
      playerName,
      position.code,
      'OVR $roundedOvr',
      'form ${_formatForm(clampedForm)}',
      zoneLabel,
      ...statusTokens,
    ];
    return parts.join(', ');
  }
}

/// Builds semantic data directly from a player presentation snapshot.
PlayerSemanticSnapshot playerSemanticSnapshot(
  PlayerPresentation presentation,
) => PlayerSemanticSnapshot.fromPresentation(presentation);

String _formatForm(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}
