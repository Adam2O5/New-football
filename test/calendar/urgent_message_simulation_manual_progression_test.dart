import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/day_simulator.dart';

import '../helpers/preferences_test_double.dart';
import '../helpers/widget_harness.dart';

const _property6Label =
    'Feature: urgent-message-simulation-setting, Property 6: '
    'behavior outside the batch scope remains unchanged';
const _property6CaseCount = 120;

enum _ManualProgression { day, hour }

// These typedefs are intentional API checks. Manual callers can only use the
// existing public entry points; the batch-only block policy is not exposed.
typedef _PublicAdvanceOneDay =
    Future<DaySimulationResult?> Function({bool resolveContractMarket});
typedef _PublicAdvanceOneHour = Future<DaySimulationResult?> Function();

void main() {
  // **Validates: Requirements 6.1–6.6, 9.8, 9.12; Design Property 6**
  test('$_property6Label holds for $_property6CaseCount deterministic '
      'day/hour scenarios and both setting values', () async {
    final dayBase = task41Game(seed: 6271);
    final hourBase = task41Game(seed: 6272);

    for (var caseIndex = 0; caseIndex < _property6CaseCount; caseIndex++) {
      for (final progression in _ManualProgression.values) {
        final base = progression == _ManualProgression.day ? dayBase : hourBase;
        final game = _manualFixture(
          base,
          caseIndex: caseIndex,
          progression: progression,
        );
        final label =
            '$_property6Label case=$caseIndex '
            'progression=${progression.name}';

        // Both calls receive the exact same immutable game fixture. The
        // only changed input is the global preference value.
        final enabled = await _runManualProgression(
          game,
          setting: true,
          progression: progression,
        );
        final disabled = await _runManualProgression(
          game,
          setting: false,
          progression: progression,
        );

        for (final observation in [enabled, disabled]) {
          expect(
            observation.result,
            isNull,
            reason: '$label must remain blocked by pending urgent',
          );
          expect(
            observation.afterClock,
            observation.beforeClock,
            reason: '$label moved the clock while blocked',
          );
          expect(
            observation.afterPendingIds,
            [observation.messageId],
            reason: '$label changed pendingUrgent membership',
          );
          expect(
            observation.afterMessageJson,
            observation.beforeMessageJson,
            reason: '$label changed the message domain payload',
          );
          expect(
            observation.afterAcknowledged,
            isFalse,
            reason: '$label auto-acknowledged the urgent message',
          );
          expect(
            observation.afterRead,
            observation.beforeRead,
            reason: '$label changed the message read state',
          );
          expect(
            observation.afterSaveContainsSetting,
            isFalse,
            reason: '$label serialized the app setting into GameSave',
          );
        }

        expect(
          enabled.afterClock,
          disabled.afterClock,
          reason: '$label differs between setting values',
        );
        expect(
          enabled.afterPendingIds,
          disabled.afterPendingIds,
          reason: '$label has different pending urgent messages',
        );
        expect(
          enabled.afterMessageJson,
          disabled.afterMessageJson,
          reason: '$label changed message data by setting value',
        );
        expect(
          enabled.afterAcknowledged,
          disabled.afterAcknowledged,
          reason: '$label changed acknowledgement by setting value',
        );
      }
    }
  });
}

Future<_ManualObservation> _runManualProgression(
  GameSave game, {
  required bool setting,
  required _ManualProgression progression,
}) async {
  final preferences = PreferencesTestDouble(
    initialValues: <String, Object?>{urgentInterruptionSettingKey: setting},
  );
  final container = ProviderContainer(
    overrides: [
      // Keep the preference store explicit even though this test also
      // overrides the state provider. This proves the setting is global and
      // independent from the active game fixture.
      sharedPreferencesProvider.overrideWithValue(preferences),
      urgentInterruptionSettingProvider.overrideWith(
        (ref) => UrgentInterruptionSettingController(preferences),
      ),
      saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        return controller;
      }),
    ],
  );

  try {
    expect(container.read(urgentInterruptionSettingProvider), setting);
    final controller = container.read(gameControllerProvider.notifier);
    final beforeSave = controller.save!;
    final before = beforeSave.leagueState;
    final beforeMessage = before.inbox.pendingUrgent.single;

    // Assigning the public tear-offs to these exact function types is a
    // compile-time guard for the manual API. In particular, callers do not
    // receive a public `blockOnPendingUrgent`/disable-policy parameter.
    final _PublicAdvanceOneDay advanceDay = controller.advanceOneDay;
    final _PublicAdvanceOneHour advanceHour = controller.advanceOneHour;
    final result = progression == _ManualProgression.day
        ? await advanceDay()
        : await advanceHour();

    final afterSave = controller.save!;
    final after = afterSave.leagueState;
    final afterMessage = after.inbox.messages.singleWhere(
      (message) => message.id == beforeMessage.id,
    );

    return _ManualObservation(
      result: result,
      beforeClock: _clock(before),
      afterClock: _clock(after),
      messageId: beforeMessage.id,
      beforeRead: beforeMessage.read,
      afterRead: afterMessage.read,
      afterAcknowledged: afterMessage.acknowledged,
      beforeMessageJson: beforeMessage.toJson(),
      afterMessageJson: afterMessage.toJson(),
      afterPendingIds: after.inbox.pendingUrgent
          .map((message) => message.id)
          .toList(),
      afterSaveContainsSetting: _containsKeyDeep(
        afterSave.toJson(),
        urgentInterruptionSettingKey,
      ),
    );
  } finally {
    container.dispose();
  }
}

GameSave _manualFixture(
  GameSave base, {
  required int caseIndex,
  required _ManualProgression progression,
}) {
  final isHourly = progression == _ManualProgression.hour;
  final week = isHourly ? 46 : 1;
  final day = isHourly ? 2 : 1 + (caseIndex % 7);
  final hour = isHourly ? 10 : null;
  final message = GameMessage(
    id: 'property-6-${progression.name}-$caseIndex',
    type: MessageType.system,
    domain: MessageDomain.system,
    priority: MessagePriority.urgent,
    seasonYear: base.leagueState.currentSeason.year,
    week: week,
    day: day,
    titleKey: 'property6UrgentTitle',
    bodyKey: 'property6UrgentBody',
    args: <String, dynamic>{'case': caseIndex},
    payload: <String, dynamic>{'scope': 'manual'},
    read: caseIndex.isOdd,
  );

  final league = base.leagueState.copyWith(
    currentWeek: week,
    currentDay: day,
    currentHour: hour,
    hourlyPlayerOfferUsed: false,
    hourlyStaffOfferUsed: false,
    // Replacing the inbox keeps every generated case deterministic and makes
    // this urgent message the only pending item under test.
    inbox: Inbox(messages: [message]),
  );
  return base.copyWith(leagueState: league);
}

(int, int, int?) _clock(LeagueState league) =>
    (league.currentWeek, league.currentDay, league.currentHour);

bool _containsKeyDeep(Object? value, String key) {
  if (value is Map<Object?, Object?>) {
    if (value.containsKey(key)) return true;
    return value.values.any((entry) => _containsKeyDeep(entry, key));
  }
  if (value is Iterable<Object?>) {
    return value.any((entry) => _containsKeyDeep(entry, key));
  }
  return false;
}

class _ManualObservation {
  const _ManualObservation({
    required this.result,
    required this.beforeClock,
    required this.afterClock,
    required this.messageId,
    required this.beforeRead,
    required this.afterRead,
    required this.afterAcknowledged,
    required this.beforeMessageJson,
    required this.afterMessageJson,
    required this.afterPendingIds,
    required this.afterSaveContainsSetting,
  });

  final DaySimulationResult? result;
  final (int, int, int?) beforeClock;
  final (int, int, int?) afterClock;
  final String messageId;
  final bool beforeRead;
  final bool afterRead;
  final bool afterAcknowledged;
  final Map<String, dynamic> beforeMessageJson;
  final Map<String, dynamic> afterMessageJson;
  final List<String> afterPendingIds;
  final bool afterSaveContainsSetting;
}
