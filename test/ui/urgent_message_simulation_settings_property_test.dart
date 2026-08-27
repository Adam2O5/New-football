@Tags(['property', 'ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/settings_screen.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/preferences_test_double.dart';
import '../helpers/widget_harness.dart';

const _urgentControlKey = ValueKey<String>('settings-urgent-interruption');
const _property8Label =
    'Feature: urgent-message-simulation-setting, Property 8: '
    'Settings UI reflects provider without save dependency';
const _property8CaseCount = 120;

enum _PreferenceStorage {
  missing,
  storedTrue,
  storedFalse,
  invalidString,
  invalidInt,
  readError,
}

enum _GameSaveState { absent, loading, changed }

enum _WriteOutcome { success, falseResult, exception }

class _PropertyCase {
  const _PropertyCase({
    required this.index,
    required this.storage,
    required this.locale,
    required this.remountLocale,
    required this.gameSaveState,
    required this.remountGameSaveState,
    required this.writeOutcome,
  });

  final int index;
  final _PreferenceStorage storage;
  final Locale locale;
  final Locale remountLocale;
  final _GameSaveState gameSaveState;
  final _GameSaveState remountGameSaveState;
  final _WriteOutcome writeOutcome;

  bool get initialValue => switch (storage) {
    _PreferenceStorage.storedFalse => false,
    _ => true,
  };

  bool get expectedAfterWrite =>
      writeOutcome == _WriteOutcome.success ? !initialValue : initialValue;

  Map<String, Object?> get initialValues => switch (storage) {
    _PreferenceStorage.missing => const <String, Object?>{},
    _PreferenceStorage.storedTrue => const <String, Object?>{
      urgentInterruptionSettingKey: true,
    },
    _PreferenceStorage.storedFalse => const <String, Object?>{
      urgentInterruptionSettingKey: false,
    },
    _PreferenceStorage.invalidString => const <String, Object?>{
      urgentInterruptionSettingKey: 'true',
    },
    _PreferenceStorage.invalidInt => const <String, Object?>{
      urgentInterruptionSettingKey: 1,
    },
    _PreferenceStorage.readError => const <String, Object?>{
      urgentInterruptionSettingKey: true,
    },
  };

  Object? get readException => storage == _PreferenceStorage.readError
      ? StateError('preference read failed for property case $index')
      : null;

  bool get setBoolResult => writeOutcome != _WriteOutcome.falseResult;

  Object? get setBoolException => writeOutcome == _WriteOutcome.exception
      ? StateError('preference write failed for property case $index')
      : null;

  String get label =>
      '$_property8Label case=$index storage=${storage.name} '
      'locale=${locale.languageCode} remountLocale=${remountLocale.languageCode} '
      'save=${gameSaveState.name}->${remountGameSaveState.name} '
      'write=${writeOutcome.name}';
}

void main() {
  // **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.6, 2.8; Design Property 8**
  testWidgets('$_property8Label holds across the generated settings matrix', (
    tester,
  ) async {
    final scenarios = _propertyCases();
    expect(scenarios, hasLength(greaterThanOrEqualTo(100)));

    for (final scenario in scenarios) {
      final preferences = PreferencesTestDouble(
        initialValues: scenario.initialValues,
        readException: scenario.readException,
        setBoolResult: scenario.setBoolResult,
        setBoolException: scenario.setBoolException,
      );
      final localePreferences = PreferencesTestDouble(
        initialValues: <String, Object?>{
          'app_locale': scenario.locale.languageCode,
        },
      );
      final initialGame = _gameFor(
        scenario.gameSaveState,
        seed: 7000 + scenario.index,
      );

      await _pumpSettingsScreen(
        tester,
        scenario: scenario,
        gameSaveState: scenario.gameSaveState,
        locale: scenario.locale,
        preferences: preferences,
        localePreferences: localePreferences,
        game: initialGame,
      );

      _expectRenderedSetting(
        tester,
        locale: scenario.locale,
        expectedValue: scenario.initialValue,
        reason: scenario.label,
      );
      _expectGameSaveState(
        tester,
        expectedState: scenario.gameSaveState,
        expectedGame: initialGame,
        reason: scenario.label,
      );

      final control = find.byKey(_urgentControlKey);
      await tester.tap(control);
      await tester.pumpAndSettle();

      _expectRenderedSetting(
        tester,
        locale: scenario.locale,
        expectedValue: scenario.expectedAfterWrite,
        reason: scenario.label,
      );
      _expectGameSaveState(
        tester,
        expectedState: scenario.gameSaveState,
        expectedGame: initialGame,
        reason: '${scenario.label}: setting write changed game state',
      );

      if (scenario.writeOutcome == _WriteOutcome.success) {
        expect(
          preferences.valueFor(urgentInterruptionSettingKey),
          scenario.expectedAfterWrite,
          reason: '${scenario.label}: successful write was not persisted',
        );
      } else {
        expect(
          preferences.valueFor(urgentInterruptionSettingKey),
          scenario.initialValues[urgentInterruptionSettingKey],
          reason: '${scenario.label}: failed write changed the store',
        );
        final l10n = await AppLocalizations.delegate.load(scenario.locale);
        expect(
          find.text(l10n.settings_urgentInterruptionWriteError),
          findsOneWidget,
          reason: '${scenario.label}: failed write did not expose an error',
        );
      }

      // A fresh route and ProviderScope model a navigation remount and a
      // save switch. The setting is read from SharedPreferences again; the
      // SettingsScreen never serializes it through GameSave.
      if (scenario.storage == _PreferenceStorage.readError) {
        // The first render intentionally exercises the safe read fallback.
        // Let this remount model a recovered preference read so successful
        // writes can also be checked across a new provider instance.
        preferences.readException = null;
      }
      localePreferences.seed('app_locale', scenario.remountLocale.languageCode);
      final remountedGame = _gameFor(
        scenario.remountGameSaveState,
        seed: 17000 + scenario.index,
      );

      await _pumpSettingsScreen(
        tester,
        scenario: scenario,
        gameSaveState: scenario.remountGameSaveState,
        locale: scenario.remountLocale,
        preferences: preferences,
        localePreferences: localePreferences,
        game: remountedGame,
      );

      _expectRenderedSetting(
        tester,
        locale: scenario.remountLocale,
        expectedValue: scenario.expectedAfterWrite,
        reason: '${scenario.label}: remounted route/provider',
      );
      _expectGameSaveState(
        tester,
        expectedState: scenario.remountGameSaveState,
        expectedGame: remountedGame,
        reason: '${scenario.label}: remount changed setting through save',
      );
    }
  });
}

List<_PropertyCase> _propertyCases() {
  return [
    for (var index = 0; index < _property8CaseCount; index++)
      _PropertyCase(
        index: index,
        storage:
            _PreferenceStorage.values[index % _PreferenceStorage.values.length],
        locale: index.isEven ? const Locale('pl') : const Locale('en'),
        remountLocale: index % 3 == 0
            ? (index.isEven ? const Locale('en') : const Locale('pl'))
            : (index.isEven ? const Locale('pl') : const Locale('en')),
        gameSaveState:
            _GameSaveState.values[index % _GameSaveState.values.length],
        remountGameSaveState:
            _GameSaveState.values[(index + 1) % _GameSaveState.values.length],
        writeOutcome:
            _WriteOutcome.values[(index ~/ _PreferenceStorage.values.length) %
                _WriteOutcome.values.length],
      ),
  ];
}

GameSave? _gameFor(_GameSaveState state, {required int seed}) {
  return state == _GameSaveState.changed ? task41Game(seed: seed) : null;
}

Future<void> _pumpSettingsScreen(
  WidgetTester tester, {
  required _PropertyCase scenario,
  required _GameSaveState gameSaveState,
  required Locale locale,
  required PreferencesTestDouble preferences,
  required PreferencesTestDouble localePreferences,
  required GameSave? game,
}) async {
  final router = GoRouter(
    initialLocation: '/settings',
    routes: [
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        // The setting controller is explicitly overridden for every case,
        // including missing/invalid/read-error storage states.
        sharedPreferencesProvider.overrideWithValue(preferences),
        urgentInterruptionSettingProvider.overrideWith(
          (ref) => UrgentInterruptionSettingController(preferences),
        ),
        localeProvider.overrideWith(
          (ref) => LocaleController(localePreferences),
        ),
        // SettingsScreen must remain usable for every active-save state and
        // must not derive the global preference from this provider.
        saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
        gameControllerProvider.overrideWith((ref) {
          final controller = GameController(ref);
          controller.state = switch (gameSaveState) {
            _GameSaveState.absent => const AsyncValue.data(null),
            _GameSaveState.loading => const AsyncValue.loading(),
            _GameSaveState.changed => AsyncValue.data(game),
          };
          return controller;
        }),
      ],
      child: MaterialApp.router(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectRenderedSetting(
  WidgetTester tester, {
  required Locale locale,
  required bool expectedValue,
  required String reason,
}) {
  final settings = find.byType(SettingsScreen);
  final control = find.byKey(_urgentControlKey);
  expect(settings, findsOneWidget, reason: reason);
  expect(find.byType(SwitchListTile), findsAtLeastNWidgets(1), reason: reason);
  expect(find.byType(Switch), findsAtLeastNWidgets(1), reason: reason);
  expect(control, findsOneWidget, reason: reason);

  final container = ProviderScope.containerOf(tester.element(settings));
  final providerValue = container.read(urgentInterruptionSettingProvider);
  expect(providerValue, expectedValue, reason: '$reason: provider value');

  final tile = tester.widget<SwitchListTile>(control);
  expect(tile.value, providerValue, reason: '$reason: switch value');
  expect(tile.onChanged, isNotNull, reason: '$reason: control is not active');

  final l10n = AppLocalizations.of(tester.element(settings))!;
  final expectedDescription = providerValue
      ? l10n.settings_urgentInterruptionEnabledDescription
      : l10n.settings_urgentInterruptionDisabledDescription;
  final expectedLabel = providerValue
      ? l10n.settings_urgentInterruptionEnabledLabel
      : l10n.settings_urgentInterruptionDisabledLabel;
  final otherDescription = providerValue
      ? l10n.settings_urgentInterruptionDisabledDescription
      : l10n.settings_urgentInterruptionEnabledDescription;
  final otherLabel = providerValue
      ? l10n.settings_urgentInterruptionDisabledLabel
      : l10n.settings_urgentInterruptionEnabledLabel;

  expect(
    find.text(l10n.settings_urgentInterruptionTitle),
    findsOneWidget,
    reason: reason,
  );
  expect(find.text(expectedDescription), findsOneWidget, reason: reason);
  expect(find.text(expectedLabel), findsOneWidget, reason: reason);
  expect(find.text(otherDescription), findsNothing, reason: reason);
  expect(find.text(otherLabel), findsNothing, reason: reason);
}

void _expectGameSaveState(
  WidgetTester tester, {
  required _GameSaveState expectedState,
  required GameSave? expectedGame,
  required String reason,
}) {
  final settings = find.byType(SettingsScreen);
  final container = ProviderScope.containerOf(tester.element(settings));
  final state = container.read(gameControllerProvider);

  switch (expectedState) {
    case _GameSaveState.absent:
      expect(state.hasValue, isTrue, reason: reason);
      expect(state.value, isNull, reason: reason);
    case _GameSaveState.loading:
      expect(state.isLoading, isTrue, reason: reason);
      expect(state.hasValue, isFalse, reason: reason);
    case _GameSaveState.changed:
      expect(expectedGame, isNotNull, reason: reason);
      expect(state.value?.meta.id, expectedGame!.meta.id, reason: reason);
      expect(state.value?.meta.name, expectedGame.meta.name, reason: reason);
  }
}
