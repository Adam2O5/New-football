/// Monotonic elapsed-time source used by [CalendarSimulationPacer].
///
/// A source must return elapsed time from a monotonic clock. It must not be
/// implemented with wall-clock time such as `DateTime.now()`.
typedef CalendarMonotonicElapsed = Duration Function();

/// Scheduler seam used to wait for the next calendar simulation cycle.
///
/// The production implementation delegates to [Future.delayed]. Tests can
/// inject a recorder/fake scheduler so they never wait for real time.
typedef CalendarSimulationDelay = Future<void> Function(Duration duration);

/// Keeps completed calendar simulation days on a predictable presentation
/// cadence without adding timing to the domain simulation itself.
///
/// The caller starts a cycle immediately before its domain step with
/// [startDay]. After the step is committed and its observer has been notified,
/// the caller invokes [completeDay]. The pacer waits only for the positive
/// remainder of [target] after the step's elapsed time. A step that already
/// took at least the target duration therefore does not incur an additional
/// wait.
///
/// The class is intentionally independent of Flutter, Riverpod, and
/// [BuildContext]. The default clock is a per-instance [Stopwatch], while the
/// elapsed source and delay scheduler are injectable for deterministic tests.
final class CalendarSimulationPacer {
  /// The desired interval between the starts of consecutive day cycles.
  static const Duration defaultTarget = Duration(milliseconds: 500);

  /// Lower bound of the accepted presentation cadence window.
  static const Duration minimumAcceptedInterval = Duration(milliseconds: 450);

  /// Upper bound of the accepted presentation cadence window.
  static const Duration maximumAcceptedInterval = Duration(milliseconds: 600);

  /// Creates a pacer backed by an instance-local monotonic [Stopwatch] unless
  /// [elapsedSource] or [stopwatch] is supplied.
  ///
  /// Supply [elapsedSource] for a fully controlled monotonic clock in tests.
  /// [stopwatch] is provided as a convenience for callers that already own a
  /// monotonic source. It is started if it has not been started yet.
  ///
  /// [delay] defaults to a non-blocking [Future.delayed] scheduler. It is
  /// called only with a strictly positive duration.
  CalendarSimulationPacer({
    this.target = defaultTarget,
    CalendarMonotonicElapsed? elapsedSource,
    CalendarSimulationDelay? delay,
    Stopwatch? stopwatch,
  }) : assert(
         target >= Duration.zero,
         'The target duration cannot be negative.',
       ),
       assert(
         elapsedSource == null || stopwatch == null,
         'Provide either elapsedSource or stopwatch, not both.',
       ),
       _elapsedSource = elapsedSource ?? _sourceFromStopwatch(stopwatch),
       _delay = delay ?? _scheduleDelay;

  /// Target duration for one completed day cycle.
  final Duration target;

  final CalendarMonotonicElapsed _elapsedSource;
  final CalendarSimulationDelay _delay;
  Duration? _dayStartedAt;
  var _completedCycles = 0;

  /// Number of completed day cycles acknowledged by this pacer.
  ///
  /// The calendar route uses this as a presentation boundary: a real
  /// controller cycle may finish before the route-owned visual dismissal
  /// timer, so the route can wait for that timer only when the controller has
  /// actually completed a paced day. Test doubles that never invoke the
  /// pacer leave this at zero.
  int get completedCycles => _completedCycles;

  /// Whether [startDay] has been called for a day that has not yet been
  /// completed or skipped.
  bool get hasActiveDay => _dayStartedAt != null;

  /// Starts timing one calendar day cycle.
  ///
  /// Calling this while another cycle is active starts a fresh cycle. This is
  /// useful when a batch is restarted after cancellation and prevents a stale
  /// cycle from contributing to the new run's cadence.
  void startDay() {
    _dayStartedAt = _elapsedSource();
  }

  /// Completes the active day and waits for its positive cadence remainder.
  ///
  /// Call this only after the day has been committed and its presentation
  /// observer has been notified. Passing `completed: false` (or calling
  /// [skipDay]) clears the cycle without scheduling a wait, which lets callers
  /// abandon an incomplete day without creating feedback for it.
  Future<void> completeDay({bool completed = true}) async {
    final startedAt = _dayStartedAt;
    _dayStartedAt = null;

    if (!completed || startedAt == null) return;

    _completedCycles++;
    final elapsed = _elapsedSource() - startedAt;
    final remaining = target - (elapsed.isNegative ? Duration.zero : elapsed);
    if (remaining <= Duration.zero) return;

    await _delay(remaining);
  }

  /// Alias for [completeDay] that reads naturally at a cycle boundary.
  Future<void> endDay({bool completed = true}) {
    return completeDay(completed: completed);
  }

  /// Abandons the active day without waiting for the next cycle.
  void skipDay() {
    _dayStartedAt = null;
  }

  static CalendarMonotonicElapsed _sourceFromStopwatch(Stopwatch? stopwatch) {
    final source = stopwatch ?? (Stopwatch()..start());
    if (!source.isRunning) source.start();
    return () => source.elapsed;
  }

  static Future<void> _scheduleDelay(Duration duration) {
    return Future<void>.delayed(duration);
  }
}
