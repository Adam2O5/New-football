import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';

void main() {
  late _FakeMonotonicClock clock;
  late List<Duration> scheduledDelays;

  setUp(() {
    clock = _FakeMonotonicClock();
    scheduledDelays = <Duration>[];
  });

  CalendarSimulationPacer createPacer() {
    return CalendarSimulationPacer(
      elapsedSource: clock.read,
      delay: (duration) async {
        scheduledDelays.add(duration);
        // Advance the fake monotonic clock instead of sleeping in a test.
        clock.advance(duration);
      },
    );
  }

  test(
    'uses the 500 ms production target and documents its acceptance window',
    () {
      final pacer = createPacer();

      expect(pacer.target, const Duration(milliseconds: 500));
      expect(
        CalendarSimulationPacer.defaultTarget,
        const Duration(milliseconds: 500),
      );
      expect(
        CalendarSimulationPacer.minimumAcceptedInterval,
        const Duration(milliseconds: 450),
      );
      expect(
        CalendarSimulationPacer.maximumAcceptedInterval,
        const Duration(milliseconds: 600),
      );
    },
  );

  test('waits only for the positive remainder after a fast day', () async {
    final pacer = createPacer();

    pacer.startDay();
    clock.advance(const Duration(milliseconds: 50));
    await pacer.completeDay();

    expect(scheduledDelays, [const Duration(milliseconds: 450)]);
    expect(clock.elapsed, const Duration(milliseconds: 500));
    expect(pacer.hasActiveDay, isFalse);
  });

  test(
    'does not schedule a negative or zero remainder for a slow day',
    () async {
      final pacer = createPacer();

      pacer.startDay();
      clock.advance(const Duration(milliseconds: 500));
      await pacer.completeDay();
      pacer.startDay();
      clock.advance(const Duration(milliseconds: 600));
      await pacer.endDay();

      expect(scheduledDelays, isEmpty);
      expect(pacer.hasActiveDay, isFalse);
    },
  );

  test('uses the injected monotonic source for cycle boundaries', () async {
    final readings = <Duration>[];
    final pacer = CalendarSimulationPacer(
      elapsedSource: () {
        final value = clock.elapsed;
        readings.add(value);
        return value;
      },
      delay: (duration) async {
        scheduledDelays.add(duration);
      },
    );

    pacer.startDay();
    clock.advance(const Duration(milliseconds: 100));
    await pacer.completeDay();

    expect(readings, [Duration.zero, const Duration(milliseconds: 100)]);
    expect(scheduledDelays, [const Duration(milliseconds: 400)]);
  });

  test(
    'checks the 450/600 ms acceptance boundaries with a fake scheduler',
    () async {
      var elapsed = Duration.zero;
      final delays = <Duration>[];
      final pacer = CalendarSimulationPacer(
        elapsedSource: () => elapsed,
        delay: (duration) async {
          delays.add(duration);
          elapsed += duration;
        },
      );

      // A 50 ms step needs the exact positive 450 ms remainder to hit 500.
      pacer.startDay();
      elapsed += const Duration(milliseconds: 50);
      await pacer.completeDay();
      expect(delays, [const Duration(milliseconds: 450)]);

      // A 600 ms step is already beyond target and must not wait negatively.
      pacer.startDay();
      elapsed += const Duration(milliseconds: 600);
      await pacer.completeDay();
      expect(delays, [const Duration(milliseconds: 450)]);
      expect(
        CalendarSimulationPacer.minimumAcceptedInterval,
        const Duration(milliseconds: 450),
      );
      expect(
        CalendarSimulationPacer.maximumAcceptedInterval,
        const Duration(milliseconds: 600),
      );
    },
  );

  test('skipping an incomplete day never schedules a wait', () async {
    final pacer = createPacer();

    pacer.startDay();
    clock.advance(const Duration(milliseconds: 100));
    await pacer.completeDay(completed: false);

    expect(scheduledDelays, isEmpty);
    expect(pacer.hasActiveDay, isFalse);

    pacer.startDay();
    clock.advance(const Duration(milliseconds: 50));
    pacer.skipDay();
    await pacer.completeDay();

    expect(scheduledDelays, isEmpty);
    expect(pacer.hasActiveDay, isFalse);
  });

  test('completing without an active day is a no-op', () async {
    final pacer = createPacer();

    await pacer.completeDay();

    expect(scheduledDelays, isEmpty);
    expect(pacer.hasActiveDay, isFalse);
  });
}

final class _FakeMonotonicClock {
  Duration elapsed = Duration.zero;

  Duration read() => elapsed;

  void advance(Duration duration) {
    elapsed += duration;
  }
}
