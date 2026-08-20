import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';

void main() {
  CalendarMatchFeedback match({
    String id = 'match-1',
    int schedulePosition = 0,
  }) {
    return CalendarMatchFeedback(
      matchId: id,
      homeTeamId: 'home-id',
      homeTeamName: 'Home United',
      awayTeamId: 'away-id',
      awayTeamName: 'Away City',
      homeGoals: 2,
      awayGoals: 1,
      schedulePosition: schedulePosition,
      status: 'played',
      reasonCode: 'normal',
    );
  }

  test('captures stable match identity, order, names, goals, and metadata', () {
    final result = match(schedulePosition: 3);

    expect(result.identityKey, 'match-1');
    expect(result.matchId, 'match-1');
    expect(result.schedulePosition, 3);
    expect(result.scheduleIndex, 3);
    expect(result.positionInSchedule, 3);
    expect(result.homeTeamId, 'home-id');
    expect(result.homeTeamName, 'Home United');
    expect(result.awayTeamId, 'away-id');
    expect(result.awayTeamName, 'Away City');
    expect(result.homeGoals, 2);
    expect(result.awayGoals, 1);
    expect(result.status, 'played');
    expect(result.statusCode, 'played');
    expect(result.reasonCode, 'normal');
    expect(result.reason, 'normal');
  });

  test('accepts the schedule-index spelling without changing stable order', () {
    const result = CalendarMatchFeedback(
      matchId: 'match-index',
      homeTeamId: 'home-id',
      homeTeamName: 'Home United',
      awayTeamId: 'away-id',
      awayTeamName: 'Away City',
      homeGoals: 0,
      awayGoals: 0,
      scheduleIndex: 2,
    );

    expect(result.schedulePosition, 2);
    expect(result.scheduleIndex, 2);
    expect(result.status, 'played');
    expect(result.reasonCode, isNull);
  });

  test('copies day results and rejects mutation through its public list', () {
    final source = <CalendarMatchFeedback>[match(id: 'first')];
    final feedback = CalendarDaySimulationFeedback(
      runId: 4,
      sequence: 9,
      week: 12,
      day: 5,
      results: source,
    );

    source.add(match(id: 'second', schedulePosition: 1));

    expect(feedback.results, hasLength(1));
    expect(feedback.results.single.identityKey, 'first');
    expect(
      () => feedback.results.add(match(id: 'third')),
      throwsUnsupportedError,
    );
    expect(feedback.matchResults, same(feedback.results));
    expect(feedback.simulatedResults, same(feedback.results));
  });

  test('supports a completed day with no results without Flutter binding', () {
    final feedback = CalendarDaySimulationFeedback(
      runId: 1,
      sequence: 0,
      week: 1,
      day: 1,
      results: const [],
    );

    expect(feedback.results, isEmpty);
    expect(feedback.identityKey, '1:0:1:1');
    expect(feedback.completedDateKey, '1:1');
  });

  test('uses value equality while retaining result order in the identity', () {
    final first = CalendarDaySimulationFeedback(
      runId: 2,
      sequence: 1,
      week: 3,
      day: 4,
      results: [
        match(id: 'first'),
        match(id: 'second', schedulePosition: 1),
      ],
    );
    final same = CalendarDaySimulationFeedback(
      runId: 2,
      sequence: 1,
      week: 3,
      day: 4,
      results: [
        match(id: 'first'),
        match(id: 'second', schedulePosition: 1),
      ],
    );
    final reordered = CalendarDaySimulationFeedback(
      runId: 2,
      sequence: 1,
      week: 3,
      day: 4,
      results: [
        match(id: 'second', schedulePosition: 1),
        match(id: 'first'),
      ],
    );

    expect(first, same);
    expect(first.hashCode, same.hashCode);
    expect(reordered, isNot(first));
    expect(reordered.identityKey, first.identityKey);
  });

  test(
    'observer callback accepts immutable day feedback without BuildContext',
    () {
      CalendarDaySimulationFeedback? received;
      void receive(CalendarDaySimulationFeedback feedback) {
        received = feedback;
      }

      final CalendarDaySimulationObserver observer = receive;
      final feedback = CalendarDaySimulationFeedback(
        runId: 7,
        sequence: 2,
        week: 6,
        day: 2,
        results: [match()],
      );

      observer(feedback);

      expect(received, same(feedback));
    },
  );
}
