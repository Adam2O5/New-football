part of 'squad_presentation.dart';

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
