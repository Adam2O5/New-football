import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app_pl and app_en contain identical localization keys', () {
    final polish = _loadArb('pl');
    final english = _loadArb('en');
    final polishKeys = _localizedKeys(polish);
    final englishKeys = _localizedKeys(english);

    expect(
      polishKeys,
      equals(englishKeys),
      reason: _keyDiffMessage(polishKeys, englishKeys),
    );
    expect(polishKeys, isNotEmpty);

    for (final key in polishKeys) {
      expect(
        _placeholders(polish[key]),
        equals(_placeholders(english[key])),
        reason: 'Placeholder mismatch for $key',
      );
    }
  });
}

Map<String, dynamic> _loadArb(String locale) {
  final file = File('lib/l10n/app_$locale.arb');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _localizedKeys(Map<String, dynamic> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

String _keyDiffMessage(Set<String> polish, Set<String> english) {
  final missingInEnglish = polish.difference(english);
  final missingInPolish = english.difference(polish);
  return 'Missing in en: $missingInEnglish; missing in pl: $missingInPolish';
}

Set<String> _placeholders(Object? value) {
  if (value is! String) return {};
  return RegExp(
    r'\{([A-Za-z_]\w*)(?:\s*,[^{}]*)?\}',
  ).allMatches(value).map((match) => match.group(1)!).toSet();
}
