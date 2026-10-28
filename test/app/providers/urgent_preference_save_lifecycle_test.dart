@Tags(['unit', 'property'])
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/game_factory.dart';

import '../../helpers/widgets/preferences_test_double.dart';
import '../../helpers/fixtures/game_fixtures.dart';
import '../../helpers/persistence/memory_save_repository.dart';

const _property2Label =
    'Feature: urgent-message-simulation-setting, Property 2: '
    'globality and isolation from domain models';
final _property2CaseCount =
    _StoredPreference.values.length *
    _WriteOutcome.values.length *
    _Lifecycle.values.length *
    2;

enum _StoredPreference { missing, enabled, disabled, invalid, readError }

enum _WriteOutcome { success, falseResult, exception }

enum _Lifecycle {
  createLoadClearReload,
  loadReplaceClearReload,
  loadClearCreateClear,
  createReplaceLoadClearReload,
}

final class _PropertyCase {
  const _PropertyCase(this.index);

  final int index;

  _StoredPreference get storedPreference =>
      _StoredPreference.values[index ~/
          (_WriteOutcome.values.length * _Lifecycle.values.length * 2)];

  _WriteOutcome get writeOutcome =>
      _WriteOutcome.values[(index ~/ (_Lifecycle.values.length * 2)) %
          _WriteOutcome.values.length];

  _Lifecycle get lifecycle =>
      _Lifecycle.values[(index ~/ 2) % _Lifecycle.values.length];

  bool get writeValue => index.isEven;

  String get label =>
      '$_property2Label case=$index '
      'stored=${storedPreference.name} write=${writeOutcome.name} '
      'lifecycle=${lifecycle.name}';
}

/// The matrix varies lifecycle and preferences without generating a new world
/// or performing disk I/O for each case. Real JSON/disk integration stays in
/// integration/urgent_message_simulation_save_regression_test.dart.
final class _FixtureGameFactory extends GameFactory {
  _FixtureGameFactory({required this.first, required this.second});

  final GameSave first;
  final GameSave second;

  @override
  GameSave create(NewGameRequest request) {
    return request.saveName == 'property-2-first' ? first : second;
  }
}

void main() {
  final seed = controllerSave();
  final first = _gameWithInbox(
    seed,
    id: 'property-2-first-save',
    name: 'Property 2 first save',
    readUrgent: false,
    acknowledgeUrgent: false,
  );
  final second = _gameWithInbox(
    seed,
    id: 'property-2-second-save',
    name: 'Property 2 second save',
    readUrgent: true,
    acknowledgeUrgent: true,
  );
  final firstRawBefore = _jsonMap(first.toJson());
  final secondRawBefore = _jsonMap(second.toJson());
  final factory = _FixtureGameFactory(first: first, second: second);
  test(
    'domain JSON preserves urgent fields and excludes global preference',
    () {
      // Exercise every persisted domain boundary directly once before the
      // lifecycle matrix. The property cases below repeat these invariants
      // after preference reads/writes and active-save transitions.
      final firstJson = _jsonMap(first.toJson());
      final firstMessage = first.leagueState.inbox.messages.first;
      expect(
        GameSave.fromJson(firstJson),
        first,
        reason: '$_property2Label: GameSave JSON round-trip changed the save',
      );
      expect(
        LeagueState.fromJson(_jsonMap(first.leagueState.toJson())),
        first.leagueState,
        reason:
            '$_property2Label: LeagueState JSON round-trip changed the '
            'domain state',
      );
      expect(
        Inbox.fromJson(_jsonMap(first.leagueState.inbox.toJson())),
        first.leagueState.inbox,
        reason:
            '$_property2Label: Inbox JSON round-trip changed message '
            'lifecycle data',
      );
      expect(
        GameMessage.fromJson(_jsonMap(firstMessage.toJson())),
        firstMessage,
        reason:
            '$_property2Label: GameMessage JSON round-trip changed '
            'priority/read/acknowledged fields',
      );
      expect(firstJson['schemaVersion'], SaveSchema.currentVersion);
      expect(
        (firstJson['meta'] as Map<String, dynamic>)['schemaVersion'],
        SaveSchema.currentVersion,
      );
      expect(first.leagueState.inbox.pendingUrgent, [firstMessage]);
      expect(firstMessage.priority, MessagePriority.urgent);
      expect(firstMessage.read, isFalse);
      expect(firstMessage.acknowledged, isFalse);
      _expectNoPreferenceKey(
        first,
        reason:
            '$_property2Label: preference key leaked into the initial '
            'domain JSON',
      );
    },
  );

  // Full Cartesian product: the setting value varies independently of lifecycle.
  for (var caseIndex = 0; caseIndex < _property2CaseCount; caseIndex++) {
    final scenario = _PropertyCase(caseIndex);
    test(scenario.label, () async {
      final repository = MemorySaveRepository(first)
        ..games[second.meta.id] = second;
      final preferences = _preferencesFor(scenario);
      final container = ProviderContainer(
        overrides: [
          saveRepositoryProvider.overrideWithValue(repository),
          gameFactoryProvider.overrideWithValue(factory),
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
      );

      try {
        final expectedInitial = _expectedEffectiveValue(scenario);
        final setting = container.read(
          urgentInterruptionSettingProvider.notifier,
        );
        expect(
          container.read(urgentInterruptionSettingProvider),
          expectedInitial,
          reason: scenario.label,
        );
        expect(
          preferences.setBoolCallCount,
          0,
          reason:
              '${scenario.label}: reading a missing, invalid, or '
              'unavailable preference must not repair SharedPreferences',
        );

        final writeSucceeded = scenario.writeOutcome == _WriteOutcome.success;
        if (writeSucceeded) {
          await setting.setUrgentInterruption(scenario.writeValue);
        } else {
          if (scenario.writeOutcome == _WriteOutcome.falseResult) {
            preferences.setBoolResult = false;
          } else {
            preferences.setBoolException = StateError(
              'deterministic preference write failure ${scenario.index}',
            );
          }
          await expectLater(
            setting.setUrgentInterruption(scenario.writeValue),
            throwsA(isA<UrgentInterruptionSettingWriteException>()),
          );
        }

        final expectedAfterWrite = writeSucceeded
            ? scenario.writeValue
            : expectedInitial;
        expect(
          container.read(urgentInterruptionSettingProvider),
          expectedAfterWrite,
          reason:
              '${scenario.label}: failed writes must retain the '
              'previous effective value',
        );
        expect(
          preferences.attemptedSetBoolKeys,
          [urgentInterruptionSettingKey],
          reason:
              '${scenario.label}: preference write used an unexpected '
              'key',
        );
        expect(
          preferences.valueFor(urgentInterruptionSettingKey),
          writeSucceeded ? scenario.writeValue : _rawStoredValue(scenario),
          reason:
              '${scenario.label}: preference write changed the raw '
              'store unexpectedly',
        );
        _expectStableSaveJson(
          _jsonMap(repository.games[first.meta.id]!.toJson()),
          firstRawBefore,
          reason:
              '${scenario.label}: changing the preference altered the '
              'first save payload or metadata other than updatedAt',
        );
        _expectStableSaveJson(
          _jsonMap(repository.games[second.meta.id]!.toJson()),
          secondRawBefore,
          reason:
              '${scenario.label}: changing the preference altered the '
              'second save payload or metadata other than updatedAt',
        );
        expect(
          _containsKey(firstRawBefore, urgentInterruptionSettingKey),
          isFalse,
          reason:
              '${scenario.label}: preference key was serialized into '
              'the first save',
        );
        expect(
          _containsKey(secondRawBefore, urgentInterruptionSettingKey),
          isFalse,
          reason:
              '${scenario.label}: preference key was serialized into '
              'the second save',
        );

        final controller = container.read(gameControllerProvider.notifier);
        await _exerciseLifecycle(
          controller: controller,
          scenario: scenario,
          first: first,
          second: second,
          firstRawBefore: firstRawBefore,
          secondRawBefore: secondRawBefore,
          currentSetting: () =>
              container.read(urgentInterruptionSettingProvider),
          expectedSetting: expectedAfterWrite,
          label: scenario.label,
        );

        // The global setting remains available with no active save, and a
        // subsequent load still cannot derive it from GameSave/LeagueState.
        expect(
          controller.save,
          isNull,
          reason: '${scenario.label}: lifecycle must finish after clear',
        );
        expect(
          container.read(urgentInterruptionSettingProvider),
          expectedAfterWrite,
          reason:
              '${scenario.label}: clearing the active save reset the '
              'global preference',
        );

        // Reconstructing the provider models an application restart. Clear
        // the injected read failure only for this restoration check; no
        // failed read may write a fallback value back to the store.
        preferences.readException = null;
        final restoredContainer = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        );
        try {
          final expectedRestored = writeSucceeded
              ? scenario.writeValue
              : (_rawStoredValue(scenario) is bool
                    ? _rawStoredValue(scenario)! as bool
                    : defaultUrgentInterruptionSetting);
          expect(
            restoredContainer.read(urgentInterruptionSettingProvider),
            expectedRestored,
            reason:
                '${scenario.label}: provider did not restore the '
                'persisted value independently of the active save',
          );
          expect(
            preferences.setBoolCallCount,
            1,
            reason:
                '${scenario.label}: restoration repaired the store '
                'instead of reading it',
          );
        } finally {
          restoredContainer.dispose();
        }

        // Preference changes must never add their key to any domain JSON,
        // including the nested Inbox and GameMessage payloads.
        _expectNoPreferenceKey(
          first,
          reason: '${scenario.label}: first save model gained preference data',
        );
        _expectNoPreferenceKey(
          second,
          reason: '${scenario.label}: second save model gained preference data',
        );
        _expectNoPreferenceKey(
          controller.save,
          reason: '${scenario.label}: active save model gained preference data',
        );
      } finally {
        container.dispose();
      }
    });
  }
}

Future<void> _exerciseLifecycle({
  required GameController controller,
  required _PropertyCase scenario,
  required GameSave first,
  required GameSave second,
  required Map<String, dynamic> firstRawBefore,
  required Map<String, dynamic> secondRawBefore,
  required bool Function() currentSetting,
  required bool expectedSetting,
  required String label,
}) async {
  void expectSetting(String point) {
    expect(
      currentSetting(),
      expectedSetting,
      reason: '$label: save lifecycle changed the global preference at $point',
    );
    expect(
      controller.save,
      isNotNull,
      reason: '$label: expected an active save at $point',
    );
  }

  Future<void> loadFirst() async {
    await controller.loadGame(first.meta.id);
    expectSetting('load first');
    _expectActiveSave(
      controller.save!,
      first,
      rawBaseline: firstRawBefore,
      label: '$label: load first',
    );
  }

  Future<void> loadSecond() async {
    await controller.loadGame(second.meta.id);
    expectSetting('load second');
    _expectActiveSave(
      controller.save!,
      second,
      rawBaseline: secondRawBefore,
      label: '$label: load second',
    );
  }

  Future<void> createFirst() async {
    await controller.createNewGame(
      const NewGameRequest(
        saveName: 'property-2-first',
        playerTeamId: 'team_europe_0',
        seed: 20260308,
      ),
    );
    expectSetting('create first');
    _expectActiveSave(
      controller.save!,
      first,
      rawBaseline: firstRawBefore,
      label: '$label: create first',
    );
  }

  Future<void> createSecond() async {
    await controller.createNewGame(
      const NewGameRequest(
        saveName: 'property-2-second',
        playerTeamId: 'team_europe_0',
        seed: 20260309,
      ),
    );
    expectSetting('create second / replace');
    _expectActiveSave(
      controller.save!,
      second,
      rawBaseline: secondRawBefore,
      label: '$label: create second / replace',
    );
  }

  Future<void> clearActive(String point) async {
    await controller.clear();
    expect(
      currentSetting(),
      expectedSetting,
      reason: '$label: clear at $point reset the global preference',
    );
    expect(
      controller.save,
      isNull,
      reason: '$label: clear at $point must remove the active save',
    );
  }

  switch (scenario.lifecycle) {
    case _Lifecycle.createLoadClearReload:
      await createFirst();
      await loadFirst();
      await clearActive('after first load');
      await loadSecond();
      await clearActive('after second load');
    case _Lifecycle.loadReplaceClearReload:
      await loadFirst();
      await createSecond();
      await clearActive('after replacement');
      await loadSecond();
      await clearActive('after replacement reload');
    case _Lifecycle.loadClearCreateClear:
      await loadFirst();
      await clearActive('before new game');
      await createSecond();
      await clearActive('after new game');
    case _Lifecycle.createReplaceLoadClearReload:
      await createFirst();
      await createSecond();
      await loadFirst();
      await clearActive('after replacing active save back to first');
      await loadSecond();
      await clearActive('after final reload');
  }
}

void _expectActiveSave(
  GameSave actual,
  GameSave expected, {
  required Map<String, dynamic> rawBaseline,
  required String label,
}) {
  expect(actual.meta.id, expected.meta.id, reason: label);
  expect(actual.meta.name, expected.meta.name, reason: label);
  expect(actual.leagueState == expected.leagueState, isTrue, reason: label);
  expect(actual.saveSeed, expected.saveSeed, reason: label);
  expect(actual.schemaVersion, expected.schemaVersion, reason: label);
  expect(
    actual.leagueState.inbox.pendingUrgent,
    expected.leagueState.inbox.pendingUrgent,
    reason: label,
  );
  final actualMessages = actual.leagueState.inbox.messages;
  final expectedMessages = expected.leagueState.inbox.messages;
  expect(actualMessages, hasLength(expectedMessages.length), reason: label);
  for (var index = 0; index < expectedMessages.length; index++) {
    final actualMessage = actualMessages[index];
    final expectedMessage = expectedMessages[index];
    expect(actualMessage.id, expectedMessage.id, reason: label);
    expect(actualMessage.priority, expectedMessage.priority, reason: label);
    expect(actualMessage.read, expectedMessage.read, reason: label);
    expect(
      actualMessage.acknowledged,
      expectedMessage.acknowledged,
      reason: label,
    );
  }
  _expectNoPreferenceKey(
    actual,
    reason: '$label: preference key leaked into loaded domain JSON',
  );
  _expectStableSaveJson(
    _jsonMap(actual.toJson()),
    rawBaseline,
    reason: '$label: load/save changed the persisted payload or metadata',
  );
}

PreferencesTestDouble _preferencesFor(_PropertyCase scenario) {
  final initialValues = <String, Object?>{};
  Object? readException;
  switch (scenario.storedPreference) {
    case _StoredPreference.missing:
      break;
    case _StoredPreference.enabled:
      initialValues[urgentInterruptionSettingKey] = true;
    case _StoredPreference.disabled:
      initialValues[urgentInterruptionSettingKey] = false;
    case _StoredPreference.invalid:
      initialValues[urgentInterruptionSettingKey] = 'not-a-bool';
    case _StoredPreference.readError:
      // Keep an underlying persisted false so the test can prove that a read
      // error uses true without repairing or overwriting the stored value.
      initialValues[urgentInterruptionSettingKey] = false;
      readException = StateError('deterministic preference read failure');
  }
  return PreferencesTestDouble(
    initialValues: initialValues,
    readException: readException,
  );
}

bool _expectedEffectiveValue(_PropertyCase scenario) {
  switch (scenario.storedPreference) {
    case _StoredPreference.enabled:
      return true;
    case _StoredPreference.disabled:
      return false;
    case _StoredPreference.missing:
    case _StoredPreference.invalid:
    case _StoredPreference.readError:
      return defaultUrgentInterruptionSetting;
  }
}

Object? _rawStoredValue(_PropertyCase scenario) {
  switch (scenario.storedPreference) {
    case _StoredPreference.missing:
      return null;
    case _StoredPreference.enabled:
      return true;
    case _StoredPreference.disabled:
      return false;
    case _StoredPreference.invalid:
      return 'not-a-bool';
    case _StoredPreference.readError:
      return false;
  }
}

GameSave _gameWithInbox(
  GameSave seed, {
  required String id,
  required String name,
  required bool readUrgent,
  required bool acknowledgeUrgent,
}) {
  final pending = GameMessage(
    id: '$id-pending-urgent',
    type: MessageType.playerEvent,
    domain: MessageDomain.playerEvent,
    priority: MessagePriority.urgent,
    seasonYear: seed.leagueState.currentSeason.year,
    week: 1,
    day: 1,
    titleKey: 'msg_playerEvent_title',
    bodyKey: 'msg_playerEvent_body',
    read: readUrgent,
    acknowledged: acknowledgeUrgent,
    args: const {'case': 'property-2'},
  );
  final normal = GameMessage(
    id: '$id-normal',
    type: MessageType.system,
    domain: MessageDomain.system,
    priority: MessagePriority.normal,
    seasonYear: seed.leagueState.currentSeason.year,
    week: 1,
    day: 2,
    titleKey: 'msg_system_title',
    bodyKey: 'msg_system_body',
    read: true,
    acknowledged: true,
  );
  return seed.copyWith(
    meta: seed.meta.copyWith(id: id, name: name),
    leagueState: seed.leagueState.copyWith(
      inbox: Inbox(messages: [pending, normal]),
    ),
  );
}

void _expectNoPreferenceKey(GameSave? save, {required String reason}) {
  if (save == null) return;
  final saveJson = _jsonMap(save.toJson());
  final leagueJson = _jsonMap(save.leagueState.toJson());
  final inboxJson = _jsonMap(save.leagueState.inbox.toJson());
  final messagesJson = save.leagueState.inbox.messages
      .map(_jsonMap)
      .toList(growable: false);

  expect(
    _containsKey(saveJson, urgentInterruptionSettingKey),
    isFalse,
    reason: reason,
  );
  expect(
    _containsKey(leagueJson, urgentInterruptionSettingKey),
    isFalse,
    reason: reason,
  );
  expect(
    _containsKey(inboxJson, urgentInterruptionSettingKey),
    isFalse,
    reason: reason,
  );
  for (final messageJson in messagesJson) {
    expect(
      _containsKey(messageJson, urgentInterruptionSettingKey),
      isFalse,
      reason: reason,
    );
  }
}

void _expectStableSaveJson(
  Map<String, dynamic> actual,
  Map<String, dynamic> expected, {
  required String reason,
}) {
  expect(
    _withoutUpdatedAt(actual),
    _withoutUpdatedAt(expected),
    reason: reason,
  );
}

Map<String, dynamic> _withoutUpdatedAt(Map<String, dynamic> json) {
  final clone = _jsonMap(json);
  final rawMeta = clone['meta'];
  if (rawMeta is Map<String, dynamic>) {
    rawMeta.remove('updatedAt');
  }
  return clone;
}

Map<String, dynamic> _jsonMap(Object? value) {
  return jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
}

bool _containsKey(Object? value, String key) {
  if (value is Map) {
    if (value.keys.any((candidate) => candidate == key)) return true;
    return value.values.any((nested) => _containsKey(nested, key));
  }
  if (value is Iterable) {
    return value.any((nested) => _containsKey(nested, key));
  }
  return false;
}
