// Presentation-only data emitted after a calendar simulation day commits.
import 'dart:async';

//
// These types deliberately do not reference Flutter widgets, BuildContext, or
// mutable domain objects. The controller should construct them from the
// post-commit league snapshot before notifying the calendar UI.

/// Stable, presentation-safe data for one newly persisted match result.
final class CalendarMatchFeedback {
  /// Creates an immutable presentation row for a completed match.
  ///
  /// [schedulePosition] is the zero-based position in the day's schedule. The
  /// [scheduleIndex] alias is accepted as well so callers that model the value
  /// as an index can use the same stable field; exactly one should be supplied.
  const CalendarMatchFeedback({
    required this.matchId,
    required this.homeTeamId,
    required this.homeTeamName,
    required this.awayTeamId,
    required this.awayTeamName,
    required this.homeGoals,
    required this.awayGoals,
    int? schedulePosition,
    int? scheduleIndex,
    this.status = 'played',
    this.reasonCode,
  }) : assert(
         schedulePosition != null || scheduleIndex != null,
         'A stable schedule position is required.',
       ),
       assert(
         (schedulePosition ?? scheduleIndex ?? -1) >= 0,
         'The schedule position must be non-negative.',
       ),
       schedulePosition = schedulePosition ?? scheduleIndex ?? -1;

  /// Identifier of the persisted scheduled match, used for deduplication.
  final String matchId;

  /// Stable domain identifiers retained for semantics and future actions.
  final String homeTeamId;
  final String awayTeamId;

  /// Team names copied from the post-commit league snapshot.
  final String homeTeamName;
  final String awayTeamName;

  /// Final regulation/result goals to display for each team.
  final int homeGoals;
  final int awayGoals;

  /// Stable zero-based position in the day's original schedule.
  final int schedulePosition;

  /// Match status code, normally [MatchStatus.name] from the domain result.
  ///
  /// A string keeps this presentation model independent from the domain
  /// result type while retaining statuses such as `played`, `walkover`, and
  /// `dsq` for the popup or accessibility layer.
  final String status;

  /// Optional administrative/result reason code copied from the result.
  final String? reasonCode;

  /// Alias useful to code that calls the stable position an index.
  int get scheduleIndex => schedulePosition;

  /// Alias for presentation code that refers to the position generically.
  int get positionInSchedule => schedulePosition;

  /// Alias for UI code that refers to the result reason without its domain
  /// serialization suffix.
  String? get reason => reasonCode;

  /// Alias that makes the status's serialized nature explicit.
  String get statusCode => status;

  /// The match identity used to reject duplicate rows in a feedback cycle.
  String get identityKey => matchId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CalendarMatchFeedback &&
            other.matchId == matchId &&
            other.homeTeamId == homeTeamId &&
            other.homeTeamName == homeTeamName &&
            other.awayTeamId == awayTeamId &&
            other.awayTeamName == awayTeamName &&
            other.homeGoals == homeGoals &&
            other.awayGoals == awayGoals &&
            other.schedulePosition == schedulePosition &&
            other.status == status &&
            other.reasonCode == reasonCode;
  }

  @override
  int get hashCode => Object.hash(
    matchId,
    homeTeamId,
    homeTeamName,
    awayTeamId,
    awayTeamName,
    homeGoals,
    awayGoals,
    schedulePosition,
    status,
    reasonCode,
  );

  @override
  String toString() {
    return 'CalendarMatchFeedback('
        'matchId: $matchId, '
        'homeTeamName: $homeTeamName, '
        'awayTeamName: $awayTeamName, '
        'homeGoals: $homeGoals, '
        'awayGoals: $awayGoals, '
        'schedulePosition: $schedulePosition, '
        'status: $status, '
        'reasonCode: $reasonCode)';
  }
}

/// A complete, committed calendar day and every result produced by that day.
final class CalendarDaySimulationFeedback {
  /// Creates feedback for one completed calendar day.
  ///
  /// The [results] iterable is copied immediately and exposed only through an
  /// unmodifiable list. Its order is the schedule order supplied by the
  /// controller; this class intentionally does not inspect mutable league
  /// state or sort by map/completion order.
  CalendarDaySimulationFeedback({
    required this.runId,
    required this.sequence,
    required this.week,
    required this.day,
    required List<CalendarMatchFeedback> results,
  }) : assert(runId >= 0, 'The run id must be non-negative.'),
       assert(sequence >= 0, 'The feedback sequence must be non-negative.'),
       assert(week > 0, 'The calendar week must be positive.'),
       assert(day > 0 && day <= 7, 'The calendar day must be between 1 and 7.'),
       results = List<CalendarMatchFeedback>.unmodifiable(results);

  /// Identifier of the calendar batch that emitted this feedback.
  final int runId;

  /// Monotonically increasing sequence within [runId].
  final int sequence;

  /// Completed in-game calendar week and day.
  final int week;
  final int day;

  /// All newly persisted results for this day, in schedule order.
  ///
  /// This list is empty for a completed day without a match result. Such a
  /// feedback object still matters to the observer because it clears stale UI
  /// feedback, while the UI can correctly decide not to create a result popup.
  final List<CalendarMatchFeedback> results;

  /// Alias for callers that use the domain term for the result collection.
  List<CalendarMatchFeedback> get matchResults => results;

  /// Alias retained for controller/result terminology.
  List<CalendarMatchFeedback> get simulatedResults => results;

  /// Stable identity for deduplication and stale-run guards.
  String get identityKey => '$runId:$sequence:$week:$day';

  /// Explicit name for the completed calendar date.
  String get completedDateKey => '$week:$day';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CalendarDaySimulationFeedback &&
            other.runId == runId &&
            other.sequence == sequence &&
            other.week == week &&
            other.day == day &&
            _sameResults(other.results);
  }

  @override
  int get hashCode =>
      Object.hash(runId, sequence, week, day, Object.hashAll(results));

  @override
  String toString() {
    return 'CalendarDaySimulationFeedback('
        'runId: $runId, '
        'sequence: $sequence, '
        'week: $week, '
        'day: $day, '
        'results: $results)';
  }

  bool _sameResults(List<CalendarMatchFeedback> other) {
    if (results.length != other.length) return false;
    for (var index = 0; index < results.length; index++) {
      if (results[index] != other[index]) return false;
    }
    return true;
  }
}

/// Observer used only by the calendar fast-forward presentation path.
///
/// The callback receives a fully immutable snapshot and must not need a
/// [BuildContext] or read mutable controller state to render it.
typedef CalendarDaySimulationObserver =
    FutureOr<void> Function(CalendarDaySimulationFeedback feedback);
