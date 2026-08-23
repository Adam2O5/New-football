import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

const _requiredActionKeys = <String>{
  'loadGame_duplicate',
  'loadGame_duplicateTooltip',
  'loadGame_rename',
  'loadGame_renameTooltip',
};

const _requiredDialogKeys = <String>{
  'loadGame_renameTitle',
  'loadGame_renameMessage',
  'loadGame_renameLabel',
  'loadGame_renameHint',
  'loadGame_renameConfirm',
};

const _requiredValidationKeys = <String>{
  'loadGame_nameEmpty',
  'loadGame_nameTaken',
  'loadGame_nameSame',
};

const _requiredSuccessKeys = <String>{
  'loadGame_duplicateSuccess',
  'loadGame_renameSuccess',
};

const _requiredErrorKeys = <String>{
  'loadGame_duplicateFailed',
  'loadGame_renameFailed',
  'loadGame_readFailed',
  'loadGame_indexReadFailed',
  'loadGame_sourceUnavailable',
  'loadGame_invalidSerializedSave',
  'loadGame_writeFailed',
  'loadGame_ambiguousWrite',
};

const _requiredLabelKeys = <String>{
  'loadGame_lastSaveDate',
  'loadGame_schemaCompatible',
  'loadGame_schemaOlder',
  'loadGame_schemaNewer',
};

// Size is presented with a localized label and a localized unavailable state;
// the B/KiB/MiB/GiB unit selection itself is formatter output, not an ARB key.
const _requiredUnitKeys = <String>{
  'loadGame_saveSize',
  'loadGame_sizeUnavailable',
};

const _requiredSemanticsKeys = <String>{
  'loadGame_loadSemantics',
  'loadGame_deleteSemantics',
  'loadGame_duplicateSemantics',
  'loadGame_renameSemantics',
};

const _requiredSaveManagementKeys = <String>{
  ..._requiredActionKeys,
  ..._requiredDialogKeys,
  ..._requiredValidationKeys,
  ..._requiredSuccessKeys,
  ..._requiredErrorKeys,
  ..._requiredLabelKeys,
  ..._requiredUnitKeys,
  ..._requiredSemanticsKeys,
};

const _expectedPlaceholderTypes = <String, Map<String, String>>{
  'loadGame_renameMessage': {'name': 'String'},
  'loadGame_duplicateSuccess': {'name': 'String'},
  'loadGame_renameSuccess': {'name': 'String'},
  'loadGame_loadSemantics': {'name': 'String'},
  'loadGame_deleteSemantics': {'name': 'String'},
  'loadGame_duplicateSemantics': {'name': 'String'},
  'loadGame_renameSemantics': {'name': 'String'},
};

void main() {
  test(
    'save-management ARB keys and translations are complete in both locales',
    () {
      final polish = _loadArb('pl');
      final english = _loadArb('en');
      final polishSaveKeys = _saveMessageKeys(polish);
      final englishSaveKeys = _saveMessageKeys(english);

      _expectSameSet(
        polishSaveKeys,
        englishSaveKeys,
        reason: 'loadGame_* key sets differ between Polish and English',
      );
      _expectSameSet(
        polishSaveKeys.intersection(_requiredSaveManagementKeys),
        _requiredSaveManagementKeys,
        reason: 'Polish is missing a required save-management key',
      );
      _expectSameSet(
        englishSaveKeys.intersection(_requiredSaveManagementKeys),
        _requiredSaveManagementKeys,
        reason: 'English is missing a required save-management key',
      );

      for (final locale in const ['pl', 'en']) {
        final arb = locale == 'pl' ? polish : english;
        for (final key in _requiredSaveManagementKeys) {
          final value = arb[key];
          expect(
            value,
            isA<String>(),
            reason: '$locale has no string for $key',
          );
          expect(
            (value as String).trim(),
            isNotEmpty,
            reason: '$locale has an empty translation for $key',
          );
        }

        _expectKeysPresent(arb, _requiredActionKeys, locale, 'action');
        _expectKeysPresent(arb, _requiredDialogKeys, locale, 'dialog');
        _expectKeysPresent(arb, _requiredValidationKeys, locale, 'validation');
        _expectKeysPresent(arb, _requiredSuccessKeys, locale, 'success');
        _expectKeysPresent(arb, _requiredErrorKeys, locale, 'error');
        _expectKeysPresent(arb, _requiredLabelKeys, locale, 'label');
        _expectKeysPresent(arb, _requiredUnitKeys, locale, 'unit');
        _expectKeysPresent(arb, _requiredSemanticsKeys, locale, 'Semantics');
      }
    },
  );

  test('save-management placeholder metadata matches between locales', () {
    final polish = _loadArb('pl');
    final english = _loadArb('en');

    for (final key in _requiredSaveManagementKeys) {
      final polishValue = polish[key] as String;
      final englishValue = english[key] as String;
      _expectSameSet(
        _placeholders(polishValue),
        _placeholders(englishValue),
        reason: 'Placeholder names differ for $key',
      );

      final polishTypes = _placeholderTypes(polish, key);
      final englishTypes = _placeholderTypes(english, key);
      _expectStringMapEqual(
        polishTypes,
        englishTypes,
        reason: 'Placeholder types differ between locales for $key',
      );
      _expectSameSet(
        polishTypes.keys.toSet(),
        _placeholders(polishValue),
        reason: 'Polish metadata does not describe placeholders for $key',
      );
      _expectSameSet(
        englishTypes.keys.toSet(),
        _placeholders(englishValue),
        reason: 'English metadata does not describe placeholders for $key',
      );

      final expectedTypes =
          _expectedPlaceholderTypes[key] ?? const <String, String>{};
      _expectStringMapEqual(
        polishTypes,
        expectedTypes,
        reason: 'Unexpected placeholder metadata for $key',
      );
    }
  });

  test(
    'configured l10n generator builds public localizations for pl and en',
    () async {
      final result = await _runConfiguredL10nGenerator();
      expect(
        result.exitCode,
        0,
        reason:
            'flutter gen-l10n failed:\nstdout: ${result.stdout}\nstderr: ${result.stderr}',
      );

      final polish = await AppLocalizations.delegate.load(const Locale('pl'));
      final english = await AppLocalizations.delegate.load(const Locale('en'));
      final polishMessages = _generatedSaveMessages(polish);
      final englishMessages = _generatedSaveMessages(english);

      expect(polishMessages.keys, containsAll(_requiredSaveManagementKeys));
      expect(englishMessages.keys, containsAll(_requiredSaveManagementKeys));
      expect(polishMessages.values, everyElement(isNotEmpty));
      expect(englishMessages.values, everyElement(isNotEmpty));
      expect(
        polish.loadGame_renameMessage('Smoke save'),
        contains('Smoke save'),
      );
      expect(
        english.loadGame_renameMessage('Smoke save'),
        contains('Smoke save'),
      );
    },
  );
}

Future<ProcessResult> _runConfiguredL10nGenerator() {
  final executable = Platform.isWindows ? 'flutter.bat' : 'flutter';
  return Process.run(executable, const [
    'gen-l10n',
  ], workingDirectory: Directory.current.path);
}

Map<String, String> _generatedSaveMessages(AppLocalizations localizations) => {
  'loadGame_duplicate': localizations.loadGame_duplicate,
  'loadGame_duplicateTooltip': localizations.loadGame_duplicateTooltip,
  'loadGame_rename': localizations.loadGame_rename,
  'loadGame_renameTooltip': localizations.loadGame_renameTooltip,
  'loadGame_renameTitle': localizations.loadGame_renameTitle,
  'loadGame_renameMessage': localizations.loadGame_renameMessage('Smoke save'),
  'loadGame_renameLabel': localizations.loadGame_renameLabel,
  'loadGame_renameHint': localizations.loadGame_renameHint,
  'loadGame_renameConfirm': localizations.loadGame_renameConfirm,
  'loadGame_nameEmpty': localizations.loadGame_nameEmpty,
  'loadGame_nameTaken': localizations.loadGame_nameTaken,
  'loadGame_nameSame': localizations.loadGame_nameSame,
  'loadGame_duplicateSuccess': localizations.loadGame_duplicateSuccess(
    'Smoke save',
  ),
  'loadGame_renameSuccess': localizations.loadGame_renameSuccess('Smoke save'),
  'loadGame_duplicateFailed': localizations.loadGame_duplicateFailed,
  'loadGame_renameFailed': localizations.loadGame_renameFailed,
  'loadGame_readFailed': localizations.loadGame_readFailed,
  'loadGame_indexReadFailed': localizations.loadGame_indexReadFailed,
  'loadGame_sourceUnavailable': localizations.loadGame_sourceUnavailable,
  'loadGame_invalidSerializedSave':
      localizations.loadGame_invalidSerializedSave,
  'loadGame_writeFailed': localizations.loadGame_writeFailed,
  'loadGame_ambiguousWrite': localizations.loadGame_ambiguousWrite,
  'loadGame_lastSaveDate': localizations.loadGame_lastSaveDate,
  'loadGame_saveSize': localizations.loadGame_saveSize,
  'loadGame_sizeUnavailable': localizations.loadGame_sizeUnavailable,
  'loadGame_schemaCompatible': localizations.loadGame_schemaCompatible,
  'loadGame_schemaOlder': localizations.loadGame_schemaOlder,
  'loadGame_schemaNewer': localizations.loadGame_schemaNewer,
  'loadGame_loadSemantics': localizations.loadGame_loadSemantics('Smoke save'),
  'loadGame_deleteSemantics': localizations.loadGame_deleteSemantics(
    'Smoke save',
  ),
  'loadGame_duplicateSemantics': localizations.loadGame_duplicateSemantics(
    'Smoke save',
  ),
  'loadGame_renameSemantics': localizations.loadGame_renameSemantics(
    'Smoke save',
  ),
};

Map<String, dynamic> _loadArb(String locale) {
  final value = jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync());
  return Map<String, dynamic>.from(value as Map);
}

Set<String> _saveMessageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((key) => key.startsWith('loadGame_')).toSet();

Set<String> _placeholders(String value) => RegExp(
  r'\{([A-Za-z_]\w*)(?:\s*,[^{}]*)?\}',
).allMatches(value).map((match) => match.group(1)!).toSet();

Map<String, String> _placeholderTypes(Map<String, dynamic> arb, String key) {
  final metadata = arb['@$key'];
  if (metadata is! Map) return {};
  final placeholders = metadata['placeholders'];
  if (placeholders is! Map) return {};

  final types = <String, String>{};
  for (final entry in placeholders.entries) {
    final definition = entry.value;
    final type = definition is Map ? definition['type'] : null;
    types[entry.key.toString()] = type is String ? type : '';
  }
  return types;
}

void _expectKeysPresent(
  Map<String, dynamic> arb,
  Set<String> required,
  String locale,
  String category,
) {
  final available = arb.keys.toSet();
  _expectSameSet(
    available.intersection(required),
    required,
    reason: '$locale is missing required $category localization keys',
  );
}

void _expectSameSet(
  Set<String> actual,
  Set<String> expected, {
  required String reason,
}) {
  expect(actual.difference(expected), isEmpty, reason: reason);
  expect(expected.difference(actual), isEmpty, reason: reason);
}

void _expectStringMapEqual(
  Map<String, String> actual,
  Map<String, String> expected, {
  required String reason,
}) {
  _expectSameSet(actual.keys.toSet(), expected.keys.toSet(), reason: reason);
  for (final key in expected.keys) {
    expect(actual[key], expected[key], reason: reason);
  }
}
