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

part 'squad_roster_presentation.dart';
part 'squad_name_presentation.dart';
part 'squad_status_presentation.dart';
part 'squad_position_assignment.dart';

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
