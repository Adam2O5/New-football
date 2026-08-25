import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

// Keep this contract to localization keys, not their UI copy. The ARB files
// remain the source of truth for the text asserted by this smoke test.
const _requiredUrgentLocalizationKeys = <String>{
  'settings_urgentInterruptionTitle',
  'settings_urgentInterruptionEnabledDescription',
  'settings_urgentInterruptionDisabledDescription',
  'settings_urgentInterruptionEnabledLabel',
  'settings_urgentInterruptionDisabledLabel',
  'settings_urgentInterruptionWriteError',
  'simulation_pendingUrgentNotice',
  'simulation_openInbox',
};

void main() {
  test(
    'urgent simulation localization resources are complete for Polish and English',
    () async {
      final polishArb = _loadArb('pl');
      final englishArb = _loadArb('en');
      final polishKeys = _urgentResourceKeys(polishArb);
      final englishKeys = _urgentResourceKeys(englishArb);

      expect(
        polishKeys,
        equals(englishKeys),
        reason: _keyDiffMessage(
          polishKeys,
          englishKeys,
          context: 'Urgent simulation localization ARB keys differ',
        ),
      );
      expect(
        polishKeys,
        equals(_requiredUrgentLocalizationKeys),
        reason: _requiredKeyDiffMessage(polishKeys),
      );

      final polish = await AppLocalizations.delegate.load(const Locale('pl'));
      final english = await AppLocalizations.delegate.load(const Locale('en'));
      final polishGenerated = _generatedUrgentResources(polish);
      final englishGenerated = _generatedUrgentResources(english);

      _expectGeneratedResourcesMatchArb(
        locale: 'pl',
        generated: polishGenerated,
        arb: polishArb,
      );
      _expectGeneratedResourcesMatchArb(
        locale: 'en',
        generated: englishGenerated,
        arb: englishArb,
      );

      for (final key in _requiredUrgentLocalizationKeys) {
        final polishValue = polishGenerated[key]!;
        final englishValue = englishGenerated[key]!;
        expect(
          polishValue,
          isNot(equals(englishValue)),
          reason:
              'Polish and English translations must be locale-appropriate for $key; '
              'both generated getters currently return the same value.',
        );
      }
    },
  );
}

Map<String, dynamic> _loadArb(String locale) {
  final file = File('lib/l10n/app_$locale.arb');
  return Map<String, dynamic>.from(jsonDecode(file.readAsStringSync()) as Map);
}

Set<String> _urgentResourceKeys(Map<String, dynamic> arb) => arb.keys
    .where(
      (key) =>
          key.startsWith('settings_urgentInterruption') ||
          key.startsWith('simulation_pendingUrgent') ||
          key.startsWith('simulation_openInbox'),
    )
    .toSet();

Map<String, String> _generatedUrgentResources(AppLocalizations l10n) => {
  'settings_urgentInterruptionTitle': l10n.settings_urgentInterruptionTitle,
  'settings_urgentInterruptionEnabledDescription':
      l10n.settings_urgentInterruptionEnabledDescription,
  'settings_urgentInterruptionDisabledDescription':
      l10n.settings_urgentInterruptionDisabledDescription,
  'settings_urgentInterruptionEnabledLabel':
      l10n.settings_urgentInterruptionEnabledLabel,
  'settings_urgentInterruptionDisabledLabel':
      l10n.settings_urgentInterruptionDisabledLabel,
  'settings_urgentInterruptionWriteError':
      l10n.settings_urgentInterruptionWriteError,
  'simulation_pendingUrgentNotice': l10n.simulation_pendingUrgentNotice,
  'simulation_openInbox': l10n.simulation_openInbox,
};

void _expectGeneratedResourcesMatchArb({
  required String locale,
  required Map<String, String> generated,
  required Map<String, dynamic> arb,
}) {
  expect(
    generated.keys.toSet(),
    equals(_requiredUrgentLocalizationKeys),
    reason:
        'Generated AppLocalizations for $locale do not expose every required '
        'urgent-setting/pending-Inbox getter.',
  );

  for (final key in _requiredUrgentLocalizationKeys) {
    final sourceValue = arb[key];
    expect(
      sourceValue,
      isA<String>(),
      reason:
          'lib/l10n/app_$locale.arb is missing a string value for urgent '
          'localization key $key.',
    );
    final generatedValue = generated[key];
    expect(
      generatedValue,
      equals(sourceValue),
      reason:
          'Generated AppLocalizations.$key for $locale does not match '
          'lib/l10n/app_$locale.arb. Run flutter gen-l10n and check the ARB key.',
    );
    expect(
      generatedValue!.trim(),
      isNotEmpty,
      reason:
          'Generated AppLocalizations.$key for $locale is empty or whitespace-only.',
    );
  }
}

String _requiredKeyDiffMessage(Set<String> actual) {
  final missing = _requiredUrgentLocalizationKeys.difference(actual);
  final unexpected = actual.difference(_requiredUrgentLocalizationKeys);
  return 'Urgent localization contract differs from task 4.1. '
      'Missing ARB keys: $missing; unexpected ARB keys: $unexpected.';
}

String _keyDiffMessage(
  Set<String> polish,
  Set<String> english, {
  required String context,
}) {
  return '$context. Missing in pl: ${english.difference(polish)}; '
      'missing in en: ${polish.difference(english)}.';
}
