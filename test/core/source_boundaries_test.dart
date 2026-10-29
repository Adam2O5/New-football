import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
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

        // Message templates are the PL/EN resources themselves, not UI literals.
        if (_localizedMessageResources.contains(path) ||
            _legacyUserFacingFiles.contains(_libraryOwner(path, source))) {
          continue;
        }
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
      final source = file.readAsStringSync();
      if (_legacyNumericFiles.contains(_libraryOwner(path, source))) continue;
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
      trimmed == '·' ||
      trimmed == '•' ||
      RegExp(r'^[+-]?\d+(?:\.\d+)?$').hasMatch(trimmed);
}

int _lineOf(String source, int offset) =>
    source.substring(0, offset).split('\n').length;

// Exemptions belong to the original library, including files extracted as parts.
// This is a narrow source heuristic, not a complete Dart AST audit.
String _libraryOwner(String path, String source) {
  final directive = RegExp(r'''^part of ['"]([a-z_]+\.dart)['"];''');
  final match = directive.firstMatch(source);
  return match == null
      ? path
      : '${path.substring(0, path.lastIndexOf('/') + 1)}${match.group(1)}';
}

const _localizedMessageResources = {
  'lib/core/balance/message_templates_pl.dart',
  'lib/core/balance/message_templates_en.dart',
};
