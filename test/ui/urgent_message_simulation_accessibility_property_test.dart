@Tags(['ui'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/settings_screen.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import '../helpers/preferences_test_double.dart';

const _propertyTag =
    'Feature: urgent-message-simulation-setting, Property 9: '
    'localization, semantics, and large text';
const _urgentControlKey = ValueKey<String>('settings-urgent-interruption');
const _locales = <Locale>[Locale('pl'), Locale('en')];
const _textScales = <double>[1.0, 1.3, 1.5, 2.0];
const _caseCount = 100;

void main() {
  // Feature: urgent-message-simulation-setting, Property 9: localization,
  // semantics, and large text
  testWidgets(_propertyTag, (tester) async {
    final semanticsHandle = tester.ensureSemantics();
    try {
      for (var caseIndex = 0; caseIndex < _caseCount; caseIndex++) {
        final scenario = _scenarioFor(caseIndex);
        final caseLabel =
            '$_propertyTag case ${caseIndex + 1}/$_caseCount '
            '(locale=${scenario.locale.languageCode}, '
            'enabled=${scenario.enabled}, scale=${scenario.textScale}, '
            'accessibleNavigation=${scenario.accessibleNavigation}, '
            'boldText=${scenario.boldText}, '
            'highContrast=${scenario.highContrast})';
        final preferences = PreferencesTestDouble(
          initialValues: <String, Object?>{
            'app_locale': scenario.locale.languageCode,
            urgentInterruptionSettingKey: scenario.enabled,
          },
        );

        await tester.pumpWidget(
          _localizedSettingsApp(
            locale: scenario.locale,
            preferences: preferences,
            textScale: scenario.textScale,
            accessibleNavigation: scenario.accessibleNavigation,
            boldText: scenario.boldText,
            highContrast: scenario.highContrast,
            testKey: 'property-9-${caseIndex + 1}',
          ),
        );
        await tester.pumpAndSettle();

        final l10n = await AppLocalizations.delegate.load(scenario.locale);
        final title = l10n.settings_urgentInterruptionTitle;
        final description = scenario.enabled
            ? l10n.settings_urgentInterruptionEnabledDescription
            : l10n.settings_urgentInterruptionDisabledDescription;
        final state = scenario.enabled
            ? l10n.settings_urgentInterruptionEnabledLabel
            : l10n.settings_urgentInterruptionDisabledLabel;
        final alternateDescription = scenario.enabled
            ? l10n.settings_urgentInterruptionDisabledDescription
            : l10n.settings_urgentInterruptionEnabledDescription;
        final alternateState = scenario.enabled
            ? l10n.settings_urgentInterruptionDisabledLabel
            : l10n.settings_urgentInterruptionEnabledLabel;

        _expectLocalizedSettingSurface(
          tester,
          l10n: l10n,
          title: title,
          description: description,
          state: state,
          alternateDescription: alternateDescription,
          alternateState: alternateState,
          caseLabel: caseLabel,
        );
        _expectNoLayoutOrTextOverflow(
          tester,
          title: title,
          description: description,
          state: state,
          caseLabel: caseLabel,
        );

        final semanticsNode = _expectSwitchSemantics(
          tester,
          title: title,
          description: description,
          state: state,
          enabled: scenario.enabled,
          caseLabel: caseLabel,
        );

        // Exercise the same tap action exposed to assistive technology. The
        // setting is deliberately left in a changed state until the keyboard
        // check below toggles it back, so both activation paths are real.
        final semanticsOwner = semanticsNode.owner;
        expect(semanticsOwner, isNotNull, reason: caseLabel);
        semanticsOwner!.performAction(semanticsNode.id, ui.SemanticsAction.tap);
        await tester.pumpAndSettle();
        expect(
          preferences.valueFor(urgentInterruptionSettingKey),
          !scenario.enabled,
          reason: '$caseLabel: SemanticsAction.tap did not activate switch',
        );
        expect(
          tester.widget<SwitchListTile>(find.byKey(_urgentControlKey)).value,
          !scenario.enabled,
          reason: '$caseLabel: visual switch state did not update after tap',
        );

        // SwitchListTile deliberately excludes its inner Switch from focus;
        // the enclosing ListTile is the real keyboard activation target.
        final switchFinder = find.descendant(
          of: find.byKey(_urgentControlKey),
          matching: find.byType(Switch),
        );
        expect(switchFinder, findsOneWidget, reason: caseLabel);
        final focusableSwitchFinder = find.descendant(
          of: find.byKey(_urgentControlKey),
          matching: find.byType(ListTile),
        );
        expect(
          focusableSwitchFinder,
          findsOneWidget,
          reason: '$caseLabel: SwitchListTile must expose a focusable row',
        );
        await tester.tap(focusableSwitchFinder);
        await tester.pumpAndSettle();
        expect(
          preferences.valueFor(urgentInterruptionSettingKey),
          scenario.enabled,
          reason: '$caseLabel: switch could not be focused/tapped',
        );
        // Automated pointer taps do not request focus for InkWell. Use the
        // same focus action exposed by the merged SwitchListTile semantics
        // row, which focuses the row's real keyboard activation target.
        final focusTarget = _semanticsSubtree(_semanticsRoot(semanticsNode))
            .singleWhere(
              (node) =>
                  node.label.contains(title) &&
                  node.getSemanticsData().hasAction(ui.SemanticsAction.focus) &&
                  node.getSemanticsData().hasAction(ui.SemanticsAction.tap),
              orElse: () => throw TestFailure(
                '$caseLabel: switch semantics must expose a focusable '
                'keyboard activation target',
              ),
            );
        final focusOwner = focusTarget.owner;
        expect(focusOwner, isNotNull, reason: caseLabel);
        focusOwner!.performAction(focusTarget.id, ui.SemanticsAction.focus);
        await tester.pump();
        final primaryFocus = FocusManager.instance.primaryFocus;
        expect(
          primaryFocus,
          isNotNull,
          reason: '$caseLabel: switch did not retain a keyboard focus target',
        );
        expect(
          primaryFocus!.context,
          isNotNull,
          reason: '$caseLabel: keyboard focus target has no context',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(
          preferences.valueFor(urgentInterruptionSettingKey),
          !scenario.enabled,
          reason: '$caseLabel: keyboard activation did not toggle switch',
        );
        expect(tester.takeException(), isNull, reason: caseLabel);
      }
    } finally {
      semanticsHandle.dispose();
    }
  });
}

void _expectLocalizedSettingSurface(
  WidgetTester tester, {
  required AppLocalizations l10n,
  required String title,
  required String description,
  required String state,
  required String alternateDescription,
  required String alternateState,
  required String caseLabel,
}) {
  expect(title.trim(), isNotEmpty, reason: caseLabel);
  expect(description.trim(), isNotEmpty, reason: caseLabel);
  expect(state.trim(), isNotEmpty, reason: caseLabel);
  expect(
    <String>{title, description, state},
    hasLength(3),
    reason: '$caseLabel: localized title, description, and state must differ',
  );
  expect(
    description,
    isNot(alternateDescription),
    reason: '$caseLabel: enabled and disabled descriptions must differ',
  );
  expect(
    state,
    isNot(alternateState),
    reason: '$caseLabel: enabled and disabled labels must differ',
  );

  final control = find.byKey(_urgentControlKey);
  expect(control, findsOneWidget, reason: caseLabel);
  expect(find.byType(SwitchListTile), findsAtLeastNWidgets(1), reason: caseLabel);
  expect(find.byType(Switch), findsAtLeastNWidgets(1), reason: caseLabel);
  expect(
    tester.widget<SwitchListTile>(control).title,
    isA<Text>(),
    reason: '$caseLabel: setting title must be a localized Text widget',
  );
  expect(find.text(l10n.settings_urgentInterruptionTitle), findsOneWidget);
  expect(find.text(title), findsOneWidget, reason: caseLabel);
  expect(find.text(description), findsOneWidget, reason: caseLabel);
  expect(find.text(state), findsOneWidget, reason: caseLabel);
  expect(find.text(alternateDescription), findsNothing, reason: caseLabel);
  expect(find.text(alternateState), findsNothing, reason: caseLabel);

  final settingTexts = tester
      .widgetList<Text>(
        find.descendant(of: control, matching: find.byType(Text)),
      )
      .map((text) => text.data)
      .whereType<String>()
      .toList(growable: false);
  expect(settingTexts, contains(title), reason: caseLabel);
  expect(settingTexts, contains(description), reason: caseLabel);
  expect(settingTexts, contains(state), reason: caseLabel);
  expect(
    settingTexts.where((text) => text.contains('_')).toList(),
    isEmpty,
    reason: '$caseLabel: raw localization keys leaked into the setting',
  );
}

void _expectNoLayoutOrTextOverflow(
  WidgetTester tester, {
  required String title,
  required String description,
  required String state,
  required String caseLabel,
}) {
  final scaffoldRect = tester.getRect(find.byType(Scaffold));
  for (final text in <String>[title, description, state]) {
    final textFinder = find.text(text);
    expect(textFinder, findsOneWidget, reason: caseLabel);
    final textRect = tester.getRect(textFinder);
    expect(
      textRect.left,
      greaterThanOrEqualTo(scaffoldRect.left - 1),
      reason: '$caseLabel: "$text" is clipped on the left',
    );
    expect(
      textRect.right,
      lessThanOrEqualTo(scaffoldRect.right + 1),
      reason: '$caseLabel: "$text" is clipped on the right',
    );

    final renderParagraph = tester.renderObject<RenderParagraph>(textFinder);
    expect(
      renderParagraph.didExceedMaxLines,
      isFalse,
      reason: '$caseLabel: "$text" is truncated at the current text scale',
    );
  }

  final controlRect = tester.getRect(find.byKey(_urgentControlKey));
  expect(
    controlRect.height,
    greaterThanOrEqualTo(48),
    reason: '$caseLabel: switch tap target is too small',
  );
  expect(
    controlRect.left,
    greaterThanOrEqualTo(scaffoldRect.left - 1),
    reason: '$caseLabel: switch row is clipped on the left',
  );
  expect(
    controlRect.right,
    lessThanOrEqualTo(scaffoldRect.right + 1),
    reason: '$caseLabel: switch row is clipped on the right',
  );
  expect(tester.takeException(), isNull, reason: caseLabel);
}

SemanticsNode _expectSwitchSemantics(
  WidgetTester tester, {
  required String title,
  required String description,
  required String state,
  required bool enabled,
  required String caseLabel,
}) {
  // SwitchListTile merges its text into the row semantics while exposing the
  // toggle state and action on a descendant Switch semantics node.
  final rowFinder = find.bySemanticsLabel(RegExp(RegExp.escape(title)));
  expect(
    rowFinder,
    findsOneWidget,
    reason: '$caseLabel: switch row semantics must expose the localized title',
  );
  final rowNode = tester.getSemantics(rowFinder);
  final toggledNodes = _semanticsSubtree(rowNode)
      .where((node) => node.flagsCollection.isToggled != ui.Tristate.none)
      .toList(growable: false);

  expect(
    toggledNodes,
    hasLength(1),
    reason: '$caseLabel: urgent setting must expose exactly one switch node',
  );
  final toggleNode = toggledNodes.single;
  expect(rowNode.label, contains(title), reason: caseLabel);
  expect(rowNode.label, contains(description), reason: caseLabel);
  expect(
    <String>[rowNode.label, rowNode.value, toggleNode.label, toggleNode.value],
    anyElement(contains(state)),
    reason: '$caseLabel: semantic label/value must expose the localized state',
  );
  expect(
    toggleNode.flagsCollection.isToggled,
    enabled ? ui.Tristate.isTrue : ui.Tristate.isFalse,
    reason: '$caseLabel: semantic toggle state does not match provider',
  );
  expect(
    toggleNode.flagsCollection.isEnabled,
    ui.Tristate.isTrue,
    reason: '$caseLabel: switch is not semantically enabled',
  );
  expect(
    toggleNode.getSemanticsData().hasAction(ui.SemanticsAction.tap),
    isTrue,
    reason: '$caseLabel: switch lacks SemanticsAction.tap',
  );
  expect(
    toggleNode.value.isEmpty || toggleNode.value.contains(state),
    isTrue,
    reason: '$caseLabel: semantic value must be localized when present',
  );

  final activationRect = tester.getRect(find.byKey(_urgentControlKey));
  expect(activationRect.width, greaterThanOrEqualTo(48), reason: caseLabel);
  expect(activationRect.height, greaterThanOrEqualTo(48), reason: caseLabel);
  return toggleNode;
}

SemanticsNode _semanticsRoot(SemanticsNode node) {
  var root = node;
  while (true) {
    final parent = root.parent;
    if (parent is! SemanticsNode) return root;
    root = parent;
  }
}

List<SemanticsNode> _semanticsSubtree(SemanticsNode root) {
  final nodes = <SemanticsNode>[];

  void visit(SemanticsNode node) {
    nodes.add(node);
    for (final child in node.debugListChildrenInOrder(
      DebugSemanticsDumpOrder.traversalOrder,
    )) {
      visit(child);
    }
  }

  visit(root);
  return nodes;
}

_Property9Scenario _scenarioFor(int index) {
  return _Property9Scenario(
    locale: _locales[index % _locales.length],
    enabled: ((index ~/ _locales.length) % 2) == 0,
    textScale: _textScales[(index ~/ 4) % _textScales.length],
    accessibleNavigation: index.isEven,
    boldText: index % 3 == 0,
    highContrast: index % 5 == 0,
  );
}

Widget _localizedSettingsApp({
  required Locale locale,
  required PreferencesTestDouble preferences,
  required double textScale,
  required bool accessibleNavigation,
  required bool boldText,
  required bool highContrast,
  required String testKey,
}) {
  return ProviderScope(
    key: ValueKey<String>(testKey),
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      urgentInterruptionSettingProvider.overrideWith(
        (ref) => UrgentInterruptionSettingController(preferences),
      ),
      localeProvider.overrideWith((ref) => LocaleController(preferences)),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(textScale),
            accessibleNavigation: accessibleNavigation,
            boldText: boldText,
            highContrast: highContrast,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SettingsScreen(),
    ),
  );
}

class _Property9Scenario {
  const _Property9Scenario({
    required this.locale,
    required this.enabled,
    required this.textScale,
    required this.accessibleNavigation,
    required this.boldText,
    required this.highContrast,
  });

  final Locale locale;
  final bool enabled;
  final double textScale;
  final bool accessibleNavigation;
  final bool boldText;
  final bool highContrast;
}
