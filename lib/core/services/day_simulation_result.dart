part of 'day_simulator.dart';

enum DaySimulationStopReason {
  advanced,
  playerMatch,
  calendarEvent,
  urgent,
  hourAdvanced,
}

enum DaySimulationMoment { beforeEvent, duringEvent }

class DaySimulationResult {
  const DaySimulationResult({
    required this.league,
    required this.pauseForUrgent,
    this.playerMatch,
    this.simulatedResults = const [],
    this.eventId,
    this.stopReason = DaySimulationStopReason.advanced,
    this.moment = DaySimulationMoment.beforeEvent,
  });

  final LeagueState league;
  final bool pauseForUrgent;

  /// Non-null when the player's team has a match today — UI should open matchday.
  final ScheduledMatch? playerMatch;
  final List<MatchResult> simulatedResults;

  /// If the simulation stopped because a calendar event needs attention, this
  /// is the event id. `null` when the stop reason is the player's match or
  /// other non-calendar reasons.
  final CalendarEventId? eventId;
  final DaySimulationStopReason stopReason;
  final DaySimulationMoment moment;
}
