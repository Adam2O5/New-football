@Tags(['property'])
library;

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/settings_provider.dart';

import '../../helpers/preferences_test_double.dart';

const _property1Label =
    'Feature: urgent-message-simulation-setting, Property 1: '
    'global preference resolution and persistence';
const _property1CaseCount = 120;

void main() {
  // **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 9.1, 9.2; Design Property 1**
  test(
    '$_property1Label holds for $_property1CaseCount deterministic generated '
    'storage states',
    () async {
      final random = Random(20260308);

      for (var caseIndex = 0; caseIndex < _property1CaseCount; caseIndex++) {
        final generated = _generateStorageCase(caseIndex, random);
        final caseLabel =
            '$_property1Label case=$caseIndex '
            'scenario=${generated.scenario}';
        final preferences = PreferencesTestDouble(
          initialValues: generated.initialValues,
          readException: generated.readException,
        );
        final container = _containerFor(preferences);

        try {
          final controller = container.read(
            urgentInterruptionSettingProvider.notifier,
          );

          expect(
            container.read(urgentInterruptionSettingProvider),
            generated.expectedInitialValue,
            reason: caseLabel,
          );
          expect(
            preferences.setBoolCallCount,
            0,
            reason: '$caseLabel must not repair the stored value on read',
          );

          final persistedValue = random.nextBool();
          await controller.setUrgentInterruption(persistedValue);

          expect(
            container.read(urgentInterruptionSettingProvider),
            persistedValue,
            reason: '$caseLabel did not publish the successful write',
          );
          expect(
            preferences.valueFor(urgentInterruptionSettingKey),
            persistedValue,
            reason: '$caseLabel did not persist the exact bool value',
          );

          // A read failure is transient in this fixture. Clearing it models a
          // fresh controller after the successful write has completed.
          preferences.readException = null;
          final restoredContainer = _containerFor(preferences);
          try {
            expect(
              restoredContainer.read(urgentInterruptionSettingProvider),
              persistedValue,
              reason: '$caseLabel did not restore the last successful value',
            );
          } finally {
            restoredContainer.dispose();
          }
        } finally {
          container.dispose();
        }
      }
    },
  );

  test(
    'a false setBool result is a typed failure and preserves the previous state',
    () async {
      final preferences = PreferencesTestDouble(
        initialValues: <String, Object?>{urgentInterruptionSettingKey: true},
        setBoolResult: false,
      );
      final container = _containerFor(preferences);
      addTearDown(container.dispose);
      final controller = container.read(
        urgentInterruptionSettingProvider.notifier,
      );
      final emissions = <bool>[];
      final subscription = container.listen(
        urgentInterruptionSettingProvider,
        (_, next) => emissions.add(next),
        fireImmediately: false,
      );
      addTearDown(subscription.close);

      await expectLater(
        controller.setUrgentInterruption(false),
        throwsA(
          isA<UrgentInterruptionSettingWriteException>()
              .having((error) => error.value, 'value', false)
              .having((error) => error.cause, 'cause', isA<StateError>()),
        ),
      );

      expect(container.read(urgentInterruptionSettingProvider), isTrue);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isTrue);
      expect(emissions, isEmpty);

      // A failed operation must not poison the queue for a later retry.
      preferences.setBoolResult = true;
      await controller.setUrgentInterruption(false);
      expect(container.read(urgentInterruptionSettingProvider), isFalse);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isFalse);
    },
  );

  test(
    'a write exception is typed and leaves the previous state published',
    () async {
      final writeFailure = StateError('preference store unavailable');
      final preferences = PreferencesTestDouble(
        initialValues: <String, Object?>{urgentInterruptionSettingKey: false},
        setBoolException: writeFailure,
      );
      final container = _containerFor(preferences);
      addTearDown(container.dispose);
      final controller = container.read(
        urgentInterruptionSettingProvider.notifier,
      );
      final emissions = <bool>[];
      final subscription = container.listen(
        urgentInterruptionSettingProvider,
        (_, next) => emissions.add(next),
        fireImmediately: false,
      );
      addTearDown(subscription.close);

      await expectLater(
        controller.setUrgentInterruption(true),
        throwsA(
          isA<UrgentInterruptionSettingWriteException>()
              .having((error) => error.value, 'value', true)
              .having((error) => error.cause, 'cause', same(writeFailure)),
        ),
      );

      expect(container.read(urgentInterruptionSettingProvider), isFalse);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isFalse);
      expect(emissions, isEmpty);

      preferences.setBoolException = null;
      await controller.setUrgentInterruption(true);
      expect(container.read(urgentInterruptionSettingProvider), isTrue);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isTrue);
    },
  );

  test(
    'the provider does not publish a new value before setBool succeeds',
    () async {
      final preferences = PreferencesTestDouble(
        initialValues: <String, Object?>{urgentInterruptionSettingKey: false},
        waitForSetBool: true,
      );
      final container = _containerFor(preferences);
      addTearDown(container.dispose);
      final controller = container.read(
        urgentInterruptionSettingProvider.notifier,
      );
      final emissions = <bool>[];
      final subscription = container.listen(
        urgentInterruptionSettingProvider,
        (_, next) => emissions.add(next),
        fireImmediately: false,
      );
      addTearDown(subscription.close);

      final write = controller.setUrgentInterruption(true);
      await preferences.firstSetBoolStarted;

      expect(container.read(urgentInterruptionSettingProvider), isFalse);
      expect(emissions, isEmpty);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isFalse);

      preferences.releaseSetBool();
      await write;

      expect(container.read(urgentInterruptionSettingProvider), isTrue);
      expect(emissions, [true]);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isTrue);
    },
  );

  test(
    'rapid writes are serialized and publish the final successful value last',
    () async {
      final preferences = PreferencesTestDouble(
        initialValues: <String, Object?>{urgentInterruptionSettingKey: true},
        waitForSetBool: true,
      );
      final container = _containerFor(preferences);
      addTearDown(container.dispose);
      final controller = container.read(
        urgentInterruptionSettingProvider.notifier,
      );
      final emissions = <bool>[];
      final subscription = container.listen(
        urgentInterruptionSettingProvider,
        (_, next) => emissions.add(next),
        fireImmediately: false,
      );
      addTearDown(subscription.close);

      final firstWrite = controller.setUrgentInterruption(false);
      await preferences.firstSetBoolStarted;
      final secondWrite = controller.setUrgentInterruption(true);
      final thirdWrite = controller.setUrgentInterruption(false);

      // Only the first I/O operation may be in flight while its gate is held.
      expect(preferences.attemptedSetBoolValues, [false]);
      expect(container.read(urgentInterruptionSettingProvider), isTrue);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isTrue);

      preferences.releaseSetBool();
      await Future.wait([firstWrite, secondWrite, thirdWrite]);

      expect(preferences.attemptedSetBoolKeys, [
        urgentInterruptionSettingKey,
        urgentInterruptionSettingKey,
        urgentInterruptionSettingKey,
      ]);
      expect(preferences.attemptedSetBoolValues, [false, true, false]);
      expect(emissions, [false, true, false]);
      expect(container.read(urgentInterruptionSettingProvider), isFalse);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isFalse);
    },
  );
}

ProviderContainer _containerFor(PreferencesTestDouble preferences) {
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
  );
}

_GeneratedStorageCase _generateStorageCase(int caseIndex, Random random) {
  switch (caseIndex % 5) {
    case 0:
      return const _GeneratedStorageCase(
        scenario: 'missing key',
        initialValues: <String, Object?>{},
        expectedInitialValue: defaultUrgentInterruptionSetting,
      );
    case 1:
      final value = caseIndex.isEven;
      return _GeneratedStorageCase(
        scenario: 'stored true/false bool',
        initialValues: <String, Object?>{urgentInterruptionSettingKey: value},
        expectedInitialValue: value,
      );
    case 2:
      final value = !caseIndex.isEven;
      return _GeneratedStorageCase(
        scenario: 'stored false/true bool',
        initialValues: <String, Object?>{urgentInterruptionSettingKey: value},
        expectedInitialValue: value,
      );
    case 3:
      final invalidValues = <Object?>[
        'true',
        1,
        0.0,
        <Object?>[true],
        <String, Object?>{'value': false},
        null,
      ];
      final invalidIndex = (caseIndex ~/ 5) % invalidValues.length;
      return _GeneratedStorageCase(
        scenario: 'invalid stored type $invalidIndex',
        initialValues: <String, Object?>{
          urgentInterruptionSettingKey: invalidValues[invalidIndex],
        },
        expectedInitialValue: defaultUrgentInterruptionSetting,
      );
    case 4:
      return _GeneratedStorageCase(
        scenario: 'read exception',
        initialValues: <String, Object?>{
          urgentInterruptionSettingKey: random.nextBool(),
        },
        readException: StateError('read failure case $caseIndex'),
        expectedInitialValue: defaultUrgentInterruptionSetting,
      );
  }

  throw StateError('unsupported generated scenario');
}

class _GeneratedStorageCase {
  const _GeneratedStorageCase({
    required this.scenario,
    required this.initialValues,
    required this.expectedInitialValue,
    this.readException,
  });

  final String scenario;
  final Map<String, Object?> initialValues;
  final Object? readException;
  final bool expectedInitialValue;
}
