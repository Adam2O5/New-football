import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/preferences_test_double.dart';

void main() {
  test('simulateToDate keeps the enabled urgent stop before the next day and '
      'the disabled batch reaches its ordinary target', () async {
    final game = _scheduleUrgent(
      _fixtureGame(playerTeamId: null),
      id: 'date-before-target',
      week: 1,
      day: 2,
    );

    final enabled = await _runDate(
      game,
      setting: true,
      targetWeek: 1,
      targetDay: 4,
    );
    final disabled = await _runDate(
      game,
      setting: false,
      targetWeek: 1,
      targetDay: 4,
    );

    expect(enabled.result.stopReason, SimulationStopReason.urgent);
    expect(enabled.result.daysSimulated, 1);
    _expectDate(enabled, week: 1, day: 2);
    expect(enabled.result.lastResult, isNotNull);

    expect(disabled.result.stopReason, SimulationStopReason.reachedTarget);
    expect(disabled.result.daysSimulated, 3);
    _expectDate(disabled, week: 1, day: 4);
    expect(disabled.result.lastResult, isNotNull);
    _expectPending(disabled, ['date-before-target']);

    // The enabled session has completed day 1 only; it has not started the
    // day on which the scheduled urgent is delivered.
    expect(enabled.save.leagueState.currentDay, 2);
    expect(enabled.save.leagueState.currentSeason.schedule, isNotEmpty);
    expect(
      _lastResultKey(enabled.result.lastResult),
      isNot(_lastResultKey(disabled.result.lastResult)),
    );
  });

  test('simulateToDate treats an urgent delivered exactly at the target as the '
      'enabled stop but still reaches that target when disabled', () async {
    // Starting on the target date exercises the controller's explicit
    // target-boundary delivery branch without simulating beyond the target.
    final game = _scheduleUrgent(
      _fixtureGame(playerTeamId: null, day: 2),
      id: 'date-target-urgent',
      week: 1,
      day: 2,
    );

    final enabled = await _runDate(
      game,
      setting: true,
      targetWeek: 1,
      targetDay: 2,
    );
    final disabled = await _runDate(
      game,
      setting: false,
      targetWeek: 1,
      targetDay: 2,
    );

    expect(enabled.result.stopReason, SimulationStopReason.urgent);
    expect(disabled.result.stopReason, SimulationStopReason.reachedTarget);
    expect(enabled.result.daysSimulated, 0);
    expect(disabled.result.daysSimulated, 0);
    _expectDate(enabled, week: 1, day: 2);
    _expectDate(disabled, week: 1, day: 2);
    _expectPending(enabled, ['date-target-urgent']);
    _expectPending(disabled, ['date-target-urgent']);

    // No target day is simulated in either case; only the final urgent stop
    // decision differs.
    expect(enabled.result.lastResult, isNull);
    expect(disabled.result.lastResult, isNull);
    expect(
      _lastResultKey(enabled.result.lastResult),
      _lastResultKey(disabled.result.lastResult),
    );
  });

  test(
    'ordinary simulateToDate target is identical for both settings',
    () async {
      final game = _fixtureGame(playerTeamId: null);
      final enabled = await _runDate(
        game,
        setting: true,
        targetWeek: 1,
        targetDay: 2,
      );
      final disabled = await _runDate(
        game,
        setting: false,
        targetWeek: 1,
        targetDay: 2,
      );

      for (final outcome in [enabled, disabled]) {
        expect(outcome.result.stopReason, SimulationStopReason.reachedTarget);
        expect(outcome.result.daysSimulated, 1);
        _expectDate(outcome, week: 1, day: 2);
        expect(outcome.result.lastResult, isNotNull);
        expect(outcome.save.leagueState.inbox.pendingUrgent, isEmpty);
      }
      expect(
        _lastResultKey(enabled.result.lastResult),
        _lastResultKey(disabled.result.lastResult),
      );
    },
  );

  test('multiple scheduled urgents stop the enabled batch at the first message '
      'and remain pending through the disabled target batch', () async {
    var game = _fixtureGame(playerTeamId: null);
    game = _scheduleUrgent(game, id: 'multiple-urgent-day-2', week: 1, day: 2);
    game = _scheduleUrgent(game, id: 'multiple-urgent-day-3', week: 1, day: 3);

    final enabled = await _runDate(
      game,
      setting: true,
      targetWeek: 1,
      targetDay: 4,
    );
    final disabled = await _runDate(
      game,
      setting: false,
      targetWeek: 1,
      targetDay: 4,
    );

    expect(enabled.result.stopReason, SimulationStopReason.urgent);
    expect(enabled.result.daysSimulated, 1);
    _expectDate(enabled, week: 1, day: 2);
    _expectPending(enabled, ['multiple-urgent-day-2']);
    expect(
      enabled.save.leagueState.inbox.scheduled.map((message) => message.id),
      ['multiple-urgent-day-3'],
    );

    expect(disabled.result.stopReason, SimulationStopReason.reachedTarget);
    expect(disabled.result.daysSimulated, 3);
    _expectDate(disabled, week: 1, day: 4);
    _expectPending(disabled, [
      'multiple-urgent-day-2',
      'multiple-urgent-day-3',
    ]);
    expect(disabled.save.leagueState.inbox.scheduled, isEmpty);
  });

  test(
    'Home simulateToEvent uses the same policy for the upcoming player match',
    () async {
      final game = _scheduleUrgent(
        _fixtureGame(playerTeamId: 'team_europe_0'),
        id: 'home-match-urgent',
        week: 1,
        day: 1,
      );
      final enabled = await _runEvent(game, setting: true);
      final disabled = await _runEvent(game, setting: false);
      final matchDay = matchDaysForWeek(1).midweekDay;

      expect(enabled.result.stopReason, SimulationStopReason.urgent);
      expect(enabled.result.daysSimulated, 0);
      _expectDate(enabled, week: 1, day: 1);
      expect(enabled.result.lastResult, isNull);
      _expectPending(enabled, ['home-match-urgent']);

      expect(disabled.result.stopReason, SimulationStopReason.playerMatch);
      // The controller counts the day on which it returns the player match.
      expect(disabled.result.daysSimulated, matchDay);
      _expectDate(disabled, week: 1, day: matchDay);
      expect(disabled.result.lastResult, isNotNull);
      expect(disabled.result.lastResult!.playerMatch, isNotNull);
      _expectPending(disabled, ['home-match-urgent']);

      final playerFixture = disabled.save.leagueState.currentSeason.schedule
          .firstWhere(
            (match) => match.id == disabled.result.lastResult!.playerMatch!.id,
          );
      expect(
        playerFixture.result,
        isNull,
        reason: 'simulateToEvent must hand the match to Home/MatchdayScreen',
      );
    },
  );

  test('Home simulateToEvent keeps the ordinary calendar event when urgent is '
      'disabled', () async {
    final game = _scheduleUrgent(
      _combineEventGame(),
      id: 'home-event-urgent',
      week: 45,
      day: 2,
    );
    final enabled = await _runEvent(game, setting: true);
    final disabled = await _runEvent(game, setting: false);

    expect(enabled.result.stopReason, SimulationStopReason.urgent);
    expect(enabled.result.daysSimulated, 0);
    _expectDate(enabled, week: 45, day: 2);
    expect(enabled.result.lastResult, isNull);
    _expectPending(enabled, ['home-event-urgent']);

    expect(disabled.result.stopReason, SimulationStopReason.event);
    expect(disabled.result.eventId, CalendarEventId.combine);
    expect(disabled.result.daysSimulated, 1);
    _expectDate(disabled, week: 45, day: 3);
    expect(disabled.result.lastResult, isNotNull);
    _expectPending(disabled, ['home-event-urgent']);
  });

  test('hourly calendar simulation keeps the urgent stop at hour ten while the '
      'disabled policy crosses the tenth-hour day boundary', () async {
    final game = _scheduleUrgent(
      _fixtureGame(playerTeamId: null, week: 46, day: 2, hour: 1),
      id: 'hour-ten-urgent',
      week: 46,
      day: 2,
      hour: 10,
    );

    final enabled = await _runDate(
      game,
      setting: true,
      targetWeek: 46,
      targetDay: 3,
    );
    final disabled = await _runDate(
      game,
      setting: false,
      targetWeek: 46,
      targetDay: 3,
    );

    expect(enabled.result.stopReason, SimulationStopReason.urgent);
    expect(enabled.result.daysSimulated, 0);
    _expectDate(enabled, week: 46, day: 2, hour: 10);
    expect(enabled.result.lastResult, isNotNull);
    expect(enabled.result.lastResult!.league.currentHour, 10);
    _expectPending(enabled, ['hour-ten-urgent']);

    expect(disabled.result.stopReason, SimulationStopReason.reachedTarget);
    // The controller may expose the hourly step count (10) or the
    // presentation date count (1); both represent the same ten-hour run.
    expect(
      disabled.result.daysSimulated == 1 || disabled.result.daysSimulated == 10,
      isTrue,
    );
    _expectDate(disabled, week: 46, day: 3, hour: 1);
    expect(disabled.result.lastResult, isNotNull);
    // The persisted save is reset to hour 1 by the day pipeline above, while
    // lastResult deliberately retains the raw hour-10 simulation result.
    expect(disabled.result.lastResult!.league.currentHour, 10);
    _expectPending(disabled, ['hour-ten-urgent']);
  });
}

Future<_BatchOutcome> _runDate(
  GameSave game, {
  required bool setting,
  required int targetWeek,
  required int targetDay,
}) async {
  final container = _newContainer(game, setting: setting);
  try {
    final controller = container.read(gameControllerProvider.notifier);
    final result = await controller.simulateToDate(
      targetWeek,
      targetDay,
      pacer: _zeroPacer(),
    );
    return _BatchOutcome(result: result, save: controller.save!);
  } finally {
    container.dispose();
  }
}

Future<_BatchOutcome> _runEvent(GameSave game, {required bool setting}) async {
  final container = _newContainer(game, setting: setting);
  try {
    final controller = container.read(gameControllerProvider.notifier);
    final result = await controller.simulateToEvent();
    return _BatchOutcome(result: result, save: controller.save!);
  } finally {
    container.dispose();
  }
}

ProviderContainer _newContainer(GameSave game, {required bool setting}) {
  // Keep the policy outside GameSave and inject it explicitly for every
  // controller fixture. This also ensures the test never reads a process-wide
  // SharedPreferences singleton by accident.
  final preferences = PreferencesTestDouble(
    initialValues: {urgentInterruptionSettingKey: setting},
  );
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        return controller;
      }),
    ],
  );
}

GameSave _fixtureGame({
  int seed = 7,
  String? playerTeamId = 'team_europe_0',
  int week = 1,
  int day = 1,
  int? hour,
}) {
  final game = GameFactory().create(
    NewGameRequest(
      saveName: 'Urgent simulation controller fixture $seed',
      playerTeamId: 'team_europe_0',
      seed: seed,
    ),
  );
  return game.copyWith(
    leagueState: game.leagueState.copyWith(
      currentWeek: week,
      currentDay: day,
      currentHour: hour,
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
      playerTeamId: playerTeamId,
    ),
  );
}

GameSave _combineEventGame() {
  final game = _fixtureGame(seed: 17, playerTeamId: null, week: 45, day: 2);
  return game.copyWith(
    leagueState: game.leagueState.copyWith(
      currentSeason: game.leagueState.currentSeason.copyWith(
        scoutReportDone: true,
        combineDone: false,
      ),
    ),
  );
}

GameSave _scheduleUrgent(
  GameSave game, {
  required String id,
  required int week,
  required int day,
  int? hour,
}) {
  final league = game.leagueState;
  final message = GameMessage(
    id: id,
    type: MessageType.tradeWindowEvent,
    priority: MessagePriority.urgent,
    seasonYear: league.currentSeason.year,
    week: week,
    day: day,
    hour: hour,
    titleKey: 'urgent.simulation.$id.title',
    bodyKey: 'urgent.simulation.$id.body',
  );
  return game.copyWith(
    leagueState: league.copyWith(inbox: league.inbox.scheduleMessage(message)),
  );
}

void _expectDate(
  _BatchOutcome outcome, {
  required int week,
  required int day,
  int? hour,
}) {
  final league = outcome.save.leagueState;
  expect(league.currentWeek, week);
  expect(league.currentDay, day);
  expect(league.currentHour, hour);
}

void _expectPending(_BatchOutcome outcome, List<String> expectedIds) {
  final inbox = outcome.save.leagueState.inbox;
  expect(inbox.pendingUrgent.map((message) => message.id), expectedIds);
  for (final id in expectedIds) {
    final message = inbox.messages.firstWhere(
      (candidate) => candidate.id == id,
    );
    expect(message.read, isFalse, reason: '$id must remain unread');
    expect(message.acknowledged, isFalse, reason: '$id must remain pending');
  }
}

String _lastResultKey(DaySimulationResult? result) {
  if (result == null) return 'null';
  final league = result.league;
  final matches = result.simulatedResults
      .map(
        (match) =>
            '${match.homeTeamId}->${match.awayTeamId}:'
            '${match.homeGoals}-${match.awayGoals}:'
            '${match.status.name}:${match.reasonCode}',
      )
      .join('|');
  return [
    league.currentWeek,
    league.currentDay,
    league.currentHour,
    result.pauseForUrgent,
    result.playerMatch?.id,
    result.eventId?.name,
    matches,
  ].join(':');
}

CalendarSimulationPacer _zeroPacer() {
  var elapsed = Duration.zero;
  return CalendarSimulationPacer(
    elapsedSource: () => elapsed,
    delay: (duration) async {
      elapsed += duration;
    },
  );
}

final class _BatchOutcome {
  const _BatchOutcome({required this.result, required this.save});

  final BatchSimulationResult result;
  final GameSave save;
}

final class _NoopSaveRepository extends SaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}
