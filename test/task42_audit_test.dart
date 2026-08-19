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

  test('production user-facing literals have reviewed legacy exceptions', () {
    final violations = <String>[];
    for (final root in ['lib/app', 'lib/core']) {
      for (final file in _dartFiles(Directory(root))) {
        final path = _relativePath(file.path);
        if (_isGenerated(path)) continue;

        final source = file.readAsStringSync();
        final matches = <RegExpMatch>[
          ..._quotedMatches(source, RegExp(r"Text\(\s*(?:const\s+)?'([^']*)'")),
          ..._quotedMatches(
            source,
            RegExp(r'''Text\(\s*(?:const\s+)?"([^"]*)"'''),
          ),
          ..._quotedMatches(
            source,
            RegExp(
              r"(?:reason|description|title|body|message)\s*:\s*(?:const\s+)?'([^']*)'",
            ),
          ),
          ..._quotedMatches(
            source,
            RegExp(
              r'''(?:reason|description|title|body|message)\s*:\s*(?:const\s+)?"([^"]*)"''',
            ),
          ),
        ];

        if (_legacyUserFacingFiles.contains(path)) continue;
        for (final match in matches) {
          final literal = match.group(1)!;
          if (literal.contains(r'$') || _isPresentationToken(literal)) {
            continue;
          }
          violations.add('$path:${_lineOf(source, match.start)}: $literal');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'New user-facing literals require an ARB key or an explicit reviewed baseline:\n'
          '${violations.join('\n')}',
    );
  });

  test('named game constants outside balance have reviewed exceptions', () {
    final violations = <String>[];
    for (final file in _dartFiles(Directory('lib/core'))) {
      final path = _relativePath(file.path);
      if (_isGenerated(path) || path.startsWith('lib/core/balance/')) {
        continue;
      }
      if (_legacyNumericFiles.contains(path)) continue;

      final source = file.readAsStringSync();
      final numericAssignments = RegExp(
        r'\b(?:const|final|var)\s+\w+\s*=\s*(-?\d+(?:\.\d+)?)\b',
      ).allMatches(source);
      for (final match in numericAssignments) {
        final value = match.group(1)!;
        if (_trivialNumericValues.contains(value)) continue;
        violations.add('$path:${_lineOf(source, match.start)}: $value');
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'New named game constants belong in lib/core/balance or need an explicit reviewed exception:\n'
          '${violations.join('\n')}',
    );
  });
}

const _legacyUserFacingFiles = <String>{
  // Existing user-facing strings scheduled for incremental ARB migration.
  'lib/app/screens/draft_screen.dart',
  'lib/app/screens/lottery_screen.dart',
  'lib/app/screens/rankings_screen.dart',
  'lib/app/widgets/lottery_odds_table.dart',
  'lib/app/widgets/lottery_results_table.dart',
  'lib/core/ai/ai_trade_service.dart',
  'lib/core/models/enums.dart',
  'lib/core/services/calendar_service.dart',
  'lib/core/services/draft_trade_service.dart',
  'lib/core/services/season_service.dart',
  'lib/core/services/team_event_service.dart',
  'lib/core/services/trade_service.dart',
  'lib/core/simulation/match_bootstrap.dart',
  'lib/core/simulation/match_engine.dart',
};

const _legacyNumericFiles = <String>{
  // Existing domain constants pending centralization in BalanceConfig.
  'lib/core/ai/ai_draft_service.dart',
  'lib/core/ai/ai_evaluation_service.dart',
  'lib/core/ai/ai_matchday_service.dart',
  'lib/core/ai/ai_trade_service.dart',
  'lib/core/ai/team_ai_service.dart',
  'lib/core/models/game_save.dart',
  'lib/core/models/message.dart',
  'lib/core/models/player.dart',
  'lib/core/models/player_value.dart',
  'lib/core/models/seed_data_generator.dart',
  'lib/core/random/match_random.dart',
  'lib/core/random/seeds.dart',
  'lib/core/services/discipline_service.dart',
  'lib/core/services/draft_trade_service.dart',
  'lib/core/services/injury_service.dart',
  'lib/core/services/league_strength_service.dart',
  'lib/core/services/season_service.dart',
  'lib/core/services/team_management_service.dart',
  'lib/core/services/trade_service.dart',
  'lib/core/simulation/duel_resolver.dart',
  'lib/core/simulation/match_bootstrap.dart',
  'lib/core/simulation/match_context_factory.dart',
  'lib/core/simulation/match_engine.dart',
  'lib/core/simulation/match_stats.dart',
  'lib/core/simulation/sequence_chain_resolver.dart',
  'lib/core/simulation/sequence_resolver.dart',
  'lib/core/simulation/shot_resolver.dart',
  'lib/core/simulation/team_shape.dart',
  'lib/core/simulation/unit_ratings.dart',
};

const _trivialNumericValues = {'0', '1', '-1'};

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

Iterable<File> _dartFiles(Directory directory) sync* {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}

String _relativePath(String path) =>
    path.replaceAll('\\', '/').replaceFirst(RegExp(r'^\./'), '');

bool _isGenerated(String path) =>
    path.contains('/generated/') ||
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart');

Iterable<RegExpMatch> _quotedMatches(String source, RegExp expression) sync* {
  yield* expression.allMatches(source);
}

bool _isPresentationToken(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ||
      trimmed == '#' ||
      trimmed == '?' ||
      trimmed == '—' ||
      trimmed == '-' ||
      trimmed == '·';
}

int _lineOf(String source, int offset) =>
    source.substring(0, offset).split('\n').length;
