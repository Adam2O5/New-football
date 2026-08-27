@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/settings_screen.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import '../helpers/preferences_test_double.dart';

const _urgentControlKey = ValueKey<String>('settings-urgent-interruption');

void main() {
  testWidgets(
    'renders one localized urgent control for both provider states without a game save',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        for (final enabled in const [true, false]) {
          final preferences = _preferences(locale: locale, enabled: enabled);
          await _pumpSettingsScreen(
            tester,
            locale: locale,
            preferences: preferences,
          );

          final l10n = await AppLocalizations.delegate.load(locale);
          final control = find.byKey(_urgentControlKey);
          final tile = tester.widget<SwitchListTile>(control);
          final expectedDescription = enabled
              ? l10n.settings_urgentInterruptionEnabledDescription
              : l10n.settings_urgentInterruptionDisabledDescription;
          final expectedState = enabled
              ? l10n.settings_urgentInterruptionEnabledLabel
              : l10n.settings_urgentInterruptionDisabledLabel;
          final otherDescription = enabled
              ? l10n.settings_urgentInterruptionDisabledDescription
              : l10n.settings_urgentInterruptionEnabledDescription;
          final otherState = enabled
              ? l10n.settings_urgentInterruptionDisabledLabel
              : l10n.settings_urgentInterruptionEnabledLabel;

          expect(find.byType(SettingsScreen), findsOneWidget);
          expect(find.byKey(_urgentControlKey), findsOneWidget);
          expect(find.byType(SwitchListTile), findsAtLeastNWidgets(1));
          expect(find.byType(Switch), findsAtLeastNWidgets(1));
          expect(control, findsOneWidget);
          expect(tile.value, enabled);
          expect(tile.onChanged, isNotNull);
          expect(find.text(l10n.settings_title), findsOneWidget);
          expect(
            find.text(l10n.settings_urgentInterruptionTitle),
            findsOneWidget,
          );
          expect(find.text(expectedDescription), findsOneWidget);
          expect(find.text(expectedState), findsOneWidget);
          expect(find.text(otherDescription), findsNothing);
          expect(find.text(otherState), findsNothing);

          // The existing language selector and app-bar back affordance remain
          // present; the setting does not replace or duplicate either one.
          expect(find.text(l10n.settings_language), findsOneWidget);
          expect(find.byType(SegmentedButton<Locale>), findsOneWidget);
          expect(find.text(l10n.settings_language_polish), findsOneWidget);
          expect(find.text(l10n.settings_language_english), findsOneWidget);
          expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        }
      }
    },
  );

  testWidgets(
    'persists a successful interaction and reloads the saved value without remounting the app',
    (tester) async {
      final preferences = _preferences(
        locale: const Locale('pl'),
        enabled: true,
      );
      await _pumpSettingsScreen(
        tester,
        locale: const Locale('pl'),
        preferences: preferences,
      );

      final control = find.byKey(_urgentControlKey);
      await tester.tap(control);
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('pl'));
      expect(tester.widget<SwitchListTile>(control).value, isFalse);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isFalse);
      expect(
        find.text(l10n.settings_urgentInterruptionDisabledDescription),
        findsOneWidget,
      );
      expect(
        find.text(l10n.settings_urgentInterruptionDisabledLabel),
        findsOneWidget,
      );
      expect(
        find.text(l10n.settings_urgentInterruptionEnabledDescription),
        findsNothing,
      );

      // A fresh route/provider scope reads the value from the same global
      // preferences store, rather than from a game save.
      await _pumpSettingsScreen(
        tester,
        locale: const Locale('pl'),
        preferences: preferences,
      );
      expect(tester.widget<SwitchListTile>(control).value, isFalse);
      expect(
        find.text(l10n.settings_urgentInterruptionDisabledLabel),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'disables the control and shows a loading affordance while saving',
    (tester) async {
      final preferences = _preferences(
        locale: const Locale('en'),
        enabled: true,
        waitForSetBool: true,
      );
      await _pumpSettingsScreen(
        tester,
        locale: const Locale('en'),
        preferences: preferences,
      );

      final control = find.byKey(_urgentControlKey);
      await tester.tap(control);
      await tester.pump();
      await preferences.firstSetBoolStarted;

      final savingTile = tester.widget<SwitchListTile>(control);
      expect(savingTile.value, isTrue);
      expect(savingTile.onChanged, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(preferences.setBoolCallCount, 1);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isTrue);

      preferences.releaseSetBool();
      await tester.pumpAndSettle();

      final savedTile = tester.widget<SwitchListTile>(control);
      expect(savedTile.value, isFalse);
      expect(savedTile.onChanged, isNotNull);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isFalse);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'keeps the previous value and allows retry after setBool returns false',
    (tester) async {
      final preferences = _preferences(
        locale: const Locale('pl'),
        enabled: true,
        setBoolResult: false,
      );
      await _pumpSettingsScreen(
        tester,
        locale: const Locale('pl'),
        preferences: preferences,
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('pl'));
      final control = find.byKey(_urgentControlKey);
      await tester.tap(control);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(control).value, isTrue);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isTrue);
      expect(
        find.text(l10n.settings_urgentInterruptionWriteError),
        findsOneWidget,
      );
      expect(tester.widget<SwitchListTile>(control).onChanged, isNotNull);

      preferences.setBoolResult = true;
      await tester.tap(control);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(control).value, isFalse);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isFalse);
      expect(preferences.setBoolCallCount, 2);
    },
  );

  testWidgets(
    'keeps the previous value and allows retry after setBool throws',
    (tester) async {
      final preferences = _preferences(
        locale: const Locale('en'),
        enabled: false,
        setBoolException: StateError('write failed'),
      );
      await _pumpSettingsScreen(
        tester,
        locale: const Locale('en'),
        preferences: preferences,
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final control = find.byKey(_urgentControlKey);
      await tester.tap(control);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(control).value, isFalse);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isFalse);
      expect(
        find.text(l10n.settings_urgentInterruptionWriteError),
        findsOneWidget,
      );
      expect(tester.widget<SwitchListTile>(control).onChanged, isNotNull);

      preferences.setBoolException = null;
      await tester.tap(control);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(control).value, isTrue);
      expect(preferences.valueFor(urgentInterruptionSettingKey), isTrue);
      expect(preferences.setBoolCallCount, 2);
    },
  );
}

PreferencesTestDouble _preferences({
  required Locale locale,
  required bool enabled,
  bool setBoolResult = true,
  Object? setBoolException,
  bool waitForSetBool = false,
}) {
  return PreferencesTestDouble(
    initialValues: <String, Object?>{
      'app_locale': locale.languageCode,
      urgentInterruptionSettingKey: enabled,
    },
    setBoolResult: setBoolResult,
    setBoolException: setBoolException,
    waitForSetBool: waitForSetBool,
  );
}

Future<void> _pumpSettingsScreen(
  WidgetTester tester, {
  required Locale locale,
  required PreferencesTestDouble preferences,
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
        sharedPreferencesProvider.overrideWithValue(preferences),
        urgentInterruptionSettingProvider.overrideWith(
          (ref) => UrgentInterruptionSettingController(preferences),
        ),
        localeProvider.overrideWith((ref) => LocaleController(preferences)),
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
