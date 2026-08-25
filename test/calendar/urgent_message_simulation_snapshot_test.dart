@Tags(['property'])
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/preferences_test_double.dart';

const _property7Label =
    'Feature: urgent-message-simulation-setting, Property 7: '
    'active-batch snapshot and next-batch value';
const _property7CaseCount = 100;

void main() {
  // **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.6, 9.7; Design Property 7**
  test('$_property7Label keeps one snapshot across multiple urgent points for '
      '$_property7CaseCount deterministic cases', () async {
    final baseGame = _baseGame();

    for (var caseIndex = 0; caseIndex < _property7CaseCount; caseIndex++) {
      // Vary the distance between urgent points. Both plans still have two
      // points, but the second one can be immediately adjacent or separated
      // by an ordinary day.
      final secondUrgentDay = caseIndex.isEven ? 3 : 4;
      final game = _gameWithScheduledUrgent(
        baseGame,
        caseIndex: caseIndex,
        urgentDays: [2, secondUrgentDay],
      );
      final preferences = PreferencesTestDouble(
        initialValues: <String, Object?>{urgentInterruptionSettingKey: false},
      );
      final container = _containerFor(game, preferences);
      final gate = _ControlledPacer(controlledDelays: 2);
      final completedDays = <String>[];
      final caseLabel = '$_property7Label case=$caseIndex';

      try {
        final controller = container.read(gameControllerProvider.notifier);
        final setting = container.read(
          urgentInterruptionSettingProvider.notifier,
        );
        final activeBatch = controller.simulateToDate(
          1,
          secondUrgentDay + 1,
          observer: (feedback) {
            completedDays.add(feedback.completedDateKey);
          },
          pacer: gate.pacer,
        );

        // The first gate is reached after day 1 is committed but before
        // result.pauseForUrgent is evaluated. The write therefore happens
        // after the active session has captured false and before its first
        // urgent stop point.
        await gate.waitUntilEntered(1);
        await setting.setUrgentInterruption(true);
        expect(
          container.read(urgentInterruptionSettingProvider),
          isTrue,
          reason: '$caseLabel: first write did not publish',
        );
        gate.release(1);

        // The second gate is reached before the next urgent stop decision.
        // Changing the live provider back to false here must not alter the
        // already captured policy, nor restart or rewind the active batch.
        await gate.waitUntilEntered(2);
        await setting.setUrgentInterruption(false);
        expect(
          container.read(urgentInterruptionSettingProvider),
          isFalse,
          reason: '$caseLabel: second write did not publish',
        );
        gate.release(2);

        final result = await activeBatch;
        final save = controller.save!;
        final league = save.leagueState;
        final pendingIds = league.inbox.pendingUrgent
            .map((message) => message.id)
            .toSet();

        expect(
          result.stopReason,
          SimulationStopReason.reachedTarget,
          reason: '$caseLabel: active batch changed policy mid-run',
        );
        expect(
          result.daysSimulated,
          secondUrgentDay,
          reason: '$caseLabel: active batch restarted, rewound, or overshot',
        );
        expect(
          (league.currentWeek, league.currentDay),
          (1, secondUrgentDay + 1),
          reason: '$caseLabel: final date was not the requested target',
        );
        expect(
          completedDays,
          [for (var day = 1; day <= secondUrgentDay; day++) '1:$day'],
          reason: '$caseLabel: completed days were replayed or skipped',
        );
        expect(pendingIds, {
          'snapshot-$caseIndex-urgent-2',
          'snapshot-$caseIndex-urgent-$secondUrgentDay',
        }, reason: '$caseLabel: pending urgent lifecycle changed');
        for (final message in league.inbox.pendingUrgent) {
          expect(message.priority, MessagePriority.urgent, reason: caseLabel);
          expect(message.read, isFalse, reason: caseLabel);
          expect(message.acknowledged, isFalse, reason: caseLabel);
        }
        expect(
          preferences.valueFor(urgentInterruptionSettingKey),
          isFalse,
          reason: '$caseLabel: final persisted preference mismatch',
        );
      } finally {
        container.dispose();
      }
    }
  });

  // **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 9.7; Design Property 7**
  test('$_property7Label applies a successful write only to the next batch for '
      '$_property7CaseCount deterministic cases', () async {
    final baseGame = _baseGame();

    for (var caseIndex = 0; caseIndex < _property7CaseCount; caseIndex++) {
      // A day-2 urgent stops after the first completed day; a day-3 urgent
      // makes the active batch cross one additional ordinary day before the
      // same snapshot is consulted at the urgent point.
      final urgentDay = caseIndex.isEven ? 2 : 3;
      final game = _gameWithScheduledUrgent(
        baseGame,
        caseIndex: caseIndex,
        urgentDays: [urgentDay],
      );
      final preferences = PreferencesTestDouble(
        initialValues: <String, Object?>{urgentInterruptionSettingKey: true},
      );
      final container = _containerFor(game, preferences);
      final gate = _ControlledPacer(controlledDelays: 2);
      final caseLabel = '$_property7Label successful case=$caseIndex';

      try {
        final controller = container.read(gameControllerProvider.notifier);
        final setting = container.read(
          urgentInterruptionSettingProvider.notifier,
        );
        final activeBatch = controller.simulateToDate(
          1,
          urgentDay + 1,
          pacer: gate.pacer,
        );

        await gate.waitUntilEntered(1);
        await setting.setUrgentInterruption(false);
        expect(
          container.read(urgentInterruptionSettingProvider),
          isFalse,
          reason: '$caseLabel: successful write was not published',
        );
        gate.release(1);

        // For a day-3 message the second gate is the actual urgent point;
        // releasing it proves that the active true snapshot still stops.
        if (urgentDay == 3) {
          await gate.waitUntilEntered(2);
          gate.release(2);
        }

        final activeResult = await activeBatch;
        final afterActive = controller.save!;
        expect(
          activeResult.stopReason,
          SimulationStopReason.urgent,
          reason: '$caseLabel: active batch used the live false value',
        );
        expect(
          activeResult.daysSimulated,
          urgentDay - 1,
          reason: '$caseLabel: active batch date progression changed',
        );
        expect(
          (
            afterActive.leagueState.currentWeek,
            afterActive.leagueState.currentDay,
          ),
          (1, urgentDay),
          reason: '$caseLabel: urgent stop rewound or overshot the date',
        );

        // The pending message is intentionally not acknowledged. The next
        // batch must read the newly persisted false policy and continue to
        // the ordinary target instead of stopping on this same message.
        final nextResult = await controller.simulateToDate(
          1,
          urgentDay + 1,
          pacer: _instantPacer(),
        );
        final afterNext = controller.save!;
        expect(
          nextResult.stopReason,
          SimulationStopReason.reachedTarget,
          reason: '$caseLabel: next batch did not use the new false value',
        );
        expect(
          nextResult.daysSimulated,
          1,
          reason: '$caseLabel: next batch did not advance exactly to target',
        );
        expect(
          (afterNext.leagueState.currentWeek, afterNext.leagueState.currentDay),
          (1, urgentDay + 1),
          reason: '$caseLabel: next batch overshot or rewound',
        );
        expect(
          afterNext.leagueState.inbox.pendingUrgent,
          hasLength(1),
          reason: '$caseLabel: next batch changed Inbox lifecycle',
        );
        expect(
          afterNext.leagueState.inbox.pendingUrgent.single.acknowledged,
          isFalse,
          reason: '$caseLabel: next batch acknowledged the urgent message',
        );
      } finally {
        container.dispose();
      }
    }
  });

  // **Validates: Requirements 7.1, 7.2, 7.3, 7.5, 7.6, 9.7; Design Property 7**
  test(
    '$_property7Label keeps the previous value after false or exception writes '
    'for $_property7CaseCount deterministic cases',
    () async {
      final baseGame = _baseGame();

      for (var caseIndex = 0; caseIndex < _property7CaseCount; caseIndex++) {
        final failedByReturnValue = caseIndex.isEven;
        final messageId = 'failed-write-$caseIndex-urgent-2';
        final game = _gameWithScheduledUrgent(
          baseGame,
          caseIndex: caseIndex,
          urgentDays: [2],
          idPrefix: 'failed-write',
        );
        final preferences = PreferencesTestDouble(
          initialValues: <String, Object?>{urgentInterruptionSettingKey: true},
          setBoolResult: !failedByReturnValue,
          setBoolException: failedByReturnValue
              ? null
              : StateError('controlled write failure $caseIndex'),
        );
        final container = _containerFor(game, preferences);
        final gate = _ControlledPacer(controlledDelays: 1);
        final caseLabel =
            '$_property7Label failed-write case=$caseIndex '
            'mode=${failedByReturnValue ? 'false-result' : 'exception'}';

        try {
          final controller = container.read(gameControllerProvider.notifier);
          final setting = container.read(
            urgentInterruptionSettingProvider.notifier,
          );
          final activeBatch = controller.simulateToDate(
            1,
            3,
            pacer: gate.pacer,
          );

          await gate.waitUntilEntered(1);
          await expectLater(
            setting.setUrgentInterruption(false),
            throwsA(isA<UrgentInterruptionSettingWriteException>()),
          );
          expect(
            container.read(urgentInterruptionSettingProvider),
            isTrue,
            reason: '$caseLabel: failed write changed the published policy',
          );
          expect(
            preferences.valueFor(urgentInterruptionSettingKey),
            isTrue,
            reason: '$caseLabel: failed write changed persisted state',
          );
          gate.release(1);

          final activeResult = await activeBatch;
          final afterActive = controller.save!;
          expect(
            activeResult.stopReason,
            SimulationStopReason.urgent,
            reason: '$caseLabel: active snapshot did not preserve true',
          );
          expect(
            (
              afterActive.leagueState.currentWeek,
              afterActive.leagueState.currentDay,
            ),
            (1, 2),
            reason: '$caseLabel: active batch moved after the urgent stop',
          );
          expect(
            afterActive.leagueState.inbox.pendingUrgent.map(
              (message) => message.id,
            ),
            [messageId],
            reason: '$caseLabel: active Inbox pending contract changed',
          );
          expect(
            afterActive.leagueState.inbox.pendingUrgent.single.acknowledged,
            isFalse,
            reason: '$caseLabel: active batch auto-acknowledged the message',
          );

          // The failed write must not become a policy for a later session.
          // Since the previous true value remains active, the same pending
          // message produces the existing Inbox/urgent stop contract again.
          final nextResult = await controller.simulateToDate(
            1,
            3,
            pacer: _instantPacer(),
          );
          final afterNext = controller.save!;
          expect(
            nextResult.stopReason,
            SimulationStopReason.urgent,
            reason: '$caseLabel: next batch used the failed false value',
          );
          expect(nextResult.daysSimulated, 0, reason: caseLabel);
          expect(
            (
              afterNext.leagueState.currentWeek,
              afterNext.leagueState.currentDay,
            ),
            (1, 2),
            reason: '$caseLabel: next batch changed the date before Inbox',
          );
          expect(
            afterNext.leagueState.inbox.pendingUrgent.map(
              (message) => message.id,
            ),
            [messageId],
            reason: '$caseLabel: next Inbox contract changed',
          );
          expect(
            afterNext.leagueState.inbox.pendingUrgent.single.acknowledged,
            isFalse,
            reason: '$caseLabel: next batch acknowledged the message',
          );
        } finally {
          container.dispose();
        }
      }
    },
  );
}

GameSave _baseGame() {
  return GameFactory().create(
    const NewGameRequest(
      saveName: 'Urgent snapshot property fixture',
      playerTeamId: 'team_europe_0',
      seed: 7,
    ),
  );
}

GameSave _gameWithScheduledUrgent(
  GameSave baseGame, {
  required int caseIndex,
  required List<int> urgentDays,
  String idPrefix = 'snapshot',
}) {
  final year = baseGame.leagueState.currentSeason.year;
  final scheduled = [
    for (final day in urgentDays)
      GameMessage(
        id: '$idPrefix-$caseIndex-urgent-$day',
        type: MessageType.tradeWindowEvent,
        priority: MessagePriority.urgent,
        seasonYear: year,
        week: 1,
        day: day,
        titleKey: 'urgent.snapshot.title',
        bodyKey: 'urgent.snapshot.body',
      ),
  ];

  return baseGame.copyWith(
    leagueState: baseGame.leagueState.copyWith(
      playerTeamId: null,
      currentWeek: 1,
      currentDay: 1,
      currentHour: null,
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
      inbox: Inbox(scheduled: scheduled),
    ),
  );
}

ProviderContainer _containerFor(
  GameSave game,
  PreferencesTestDouble preferences,
) {
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

CalendarSimulationPacer _instantPacer() {
  var elapsed = Duration.zero;
  return CalendarSimulationPacer(
    elapsedSource: () => elapsed,
    delay: (duration) async {
      elapsed += duration;
    },
  );
}

final class _ControlledPacer {
  _ControlledPacer({required int controlledDelays})
    : _entered = [
        for (var index = 0; index < controlledDelays; index++)
          Completer<void>(),
      ],
      _releases = [
        for (var index = 0; index < controlledDelays; index++)
          Completer<void>(),
      ];

  final List<Completer<void>> _entered;
  final List<Completer<void>> _releases;
  var _delayCount = 0;
  var _elapsed = Duration.zero;

  CalendarSimulationPacer get pacer => CalendarSimulationPacer(
    elapsedSource: () => _elapsed,
    delay: (duration) async {
      _elapsed += duration;
      final delayNumber = ++_delayCount;
      if (delayNumber > _entered.length) return;
      _entered[delayNumber - 1].complete();
      await _releases[delayNumber - 1].future;
    },
  );

  Future<void> waitUntilEntered(int delayNumber) =>
      _entered[delayNumber - 1].future;

  void release(int delayNumber) {
    final completer = _releases[delayNumber - 1];
    if (!completer.isCompleted) completer.complete();
  }
}

final class _NoopSaveRepository extends SaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}
