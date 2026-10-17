part of 'squad_presentation.dart';

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

/// The single visual status that a roster-row status slot can display.
enum StatusVisualKind { none, injury, suspension }

/// An immutable, locale-neutral projection of a player's status-slot state.
@immutable
class StatusSlotPresentation {
  const StatusSlotPresentation({
    required this.visual,
    required this.hasActiveInjury,
    required this.hasActiveSuspension,
  });

  /// The prioritized visual status for the slot.
  final StatusVisualKind visual;

  /// Preserves whether an active injury is present in the source status.
  final bool hasActiveInjury;

  /// Preserves whether an active suspension is present in the source status.
  final bool hasActiveSuspension;

  /// All active meanings, retained in the stable injury-then-suspension order.
  List<StatusVisualKind> get semanticStatuses =>
      List<StatusVisualKind>.unmodifiable([
        if (hasActiveInjury) StatusVisualKind.injury,
        if (hasActiveSuspension) StatusVisualKind.suspension,
      ]);
}

/// Projects [SquadStatus] into the prioritized visual status and all active
/// semantic meanings without mutating or serializing the source state.
StatusSlotPresentation statusSlotPresentation(SquadStatus status) {
  final visual = status.hasActiveInjury
      ? StatusVisualKind.injury
      : status.hasActiveSuspension
      ? StatusVisualKind.suspension
      : StatusVisualKind.none;

  return StatusSlotPresentation(
    visual: visual,
    hasActiveInjury: status.hasActiveInjury,
    hasActiveSuspension: status.hasActiveSuspension,
  );
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
