import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/message_catalog.dart';
import 'package:new_football/core/models/enums.dart';

void main() {
  test('MessageCatalog keys are covered by both ARB locales', () {
    final polish = _loadArb('pl');
    final english = _loadArb('en');
    final expected = _catalogKeys();

    expect(
      polish.keys,
      containsAll(expected),
      reason:
          'Missing Polish message keys: ${expected.difference(polish.keys.toSet())}',
    );
    expect(
      english.keys,
      containsAll(expected),
      reason:
          'Missing English message keys: ${expected.difference(english.keys.toSet())}',
    );

    for (final key in expected) {
      expect(
        _placeholders(polish[key]),
        _placeholders(english[key]),
        reason: 'Placeholder mismatch for $key',
      );
    }
  });

  test('message locale key sets are identical between Polish and English', () {
    final polish = _loadArb('pl');
    final english = _loadArb('en');
    final polishMessageKeys = _messageKeys(polish);
    final englishMessageKeys = _messageKeys(english);

    expect(polishMessageKeys, equals(englishMessageKeys));
    expect(polishMessageKeys, isNotEmpty);
  });
}

Map<String, dynamic> _loadArb(String locale) {
  final file = File('lib/l10n/app_$locale.arb');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _catalogKeys() {
  final keys = <String>{};
  for (final template in MessageCatalog.templates) {
    keys
      ..add(template.titleKey)
      ..add(template.bodyKey);
    for (final action in template.actions) {
      keys.add(action.labelKey);
    }
    final decision = template.decision;
    if (decision != null) {
      for (final option in decision.options) {
        keys.add(option.labelKey);
      }
    }
    final groupKey = template.groupKey;
    if (groupKey != null) {
      final digestType = groupKey.startsWith('ovr:')
          ? MessageType.ovrDigest
          : template.type;
      keys
        ..add('msg_${digestType.name}_digest_title')
        ..add('msg_${digestType.name}_digest_body');
    }
  }

  // These are explicit keys used by legacy call-sites outside the catalog.
  keys
    ..add('msg_calendar_newWeek_title')
    ..add('msg_calendar_newWeek_body')
    ..add('msg_contractSigned_fa_title')
    ..add('msg_contractSigned_fa_body');
  return keys;
}

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((key) => key.startsWith('msg_')).toSet();

Set<String> _placeholders(Object? value) {
  if (value is! String) return {};
  return RegExp(
    r'\{([A-Za-z_]\w*)(?:\s*,[^{}]*)?\}',
  ).allMatches(value).map((match) => match.group(1)!).toSet();
}
