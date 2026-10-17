part of 'game_provider.dart';

/// Why a batch simulation (`GameController.simulateTo...`) stopped.
enum SimulationStopReason {
  /// Target date / phase end reached without any blocking event.
  reachedTarget,

  /// The player's team has a match today — UI should open matchday.
  playerMatch,

  /// An urgent inbox message needs attention.
  urgent,

  /// The next registered calendar event needs player input (e.g. draft
  /// pick) — UI should navigate there. Draft has no separate stop reason:
  /// it is just a `playerAction` event like any other.
  event,

  /// User cancelled the batch simulation.
  cancelled,

  /// No active save (nothing to simulate).
  noSave,
}

class BatchSimulationResult {
  const BatchSimulationResult({
    required this.stopReason,
    required this.daysSimulated,
    this.lastResult,
    this.eventId,
  });

  final SimulationStopReason stopReason;
  final int daysSimulated;
  final DaySimulationResult? lastResult;

  /// Set when [stopReason] is [SimulationStopReason.event] — the id of the
  /// `CalendarEventSlot` that needs attention. `null` when the stop reason is
  /// the player's match or other non-calendar reasons.
  final CalendarEventId? eventId;
}

/// Next actionable thing on the calendar: the player's upcoming fixture, or
/// the next unresolved `CalendarEventSlot`. Drives the contextual button on
/// `HomeScreen` — `kind` decides which button(s) are shown.
class UpcomingAction {
  const UpcomingAction({
    required this.kind,
    required this.id,
    this.calendarEventId,
    required this.week,
    required this.day,
  });

  final CalendarEventKind kind;

  /// Registry event id, or `'match'` for the player's next fixture.
  final String id;

  /// If this action corresponds to a calendar event from the registry, this
  /// is its typed id. `null` for the player's match.
  final CalendarEventId? calendarEventId;
  final int week;
  final int day;
}

final class _SimulationSession {
  _SimulationSession(this.runId, {required this.urgentInterruptionEnabled});

  final int runId;
  final bool urgentInterruptionEnabled;
  final cancelled = Completer<void>();
  final done = Completer<void>();

  bool get cancelRequested => cancelled.isCompleted;

  void cancel() {
    if (!cancelled.isCompleted) cancelled.complete();
  }
}
