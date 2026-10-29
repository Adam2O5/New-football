@Tags(['property'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/squad_presentation.dart';

const _propertyRuns = 120;
const _propertyFourSeed = 8205;

void main() {
  // Feature: squad-screen-redesign, Property 4: Whitespace name normalization
  // **Validates: Requirements 5.3, 5.4**
  Glados<_GeneratedNameNormalizationCase>(
    _generatedNameNormalizationCases,
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(_propertyFourSeed),
    ),
  ).test('Feature: squad-screen-redesign, Property 4: Whitespace name '
      'normalization holds for $_propertyRuns generated cases', (input) {
    final reason = input.diagnostics;
    final presentation = splitPlayerName(input.rawName);
    final expectedFirstLine = input.expectedPortions.isEmpty
        ? ''
        : input.expectedPortions.first;
    final expectedSecondLine = input.expectedPortions.length <= 1
        ? ''
        : input.expectedPortions.skip(1).join(' ');

    expect(presentation.firstLine, expectedFirstLine, reason: reason);
    expect(presentation.secondLine, expectedSecondLine, reason: reason);

    // A whitespace-only name and a name with one non-empty portion both have
    // no lower name line after empty portions are discarded.
    if (input.expectedPortions.length <= 1) {
      expect(presentation.secondLine, isEmpty, reason: reason);
    }
  });
}

final Generator<_GeneratedNameNormalizationCase>
_generatedNameNormalizationCases = any.simple<_GeneratedNameNormalizationCase>(
  generate: (random, size) {
    final scenario = size % 5;
    if (scenario == 0) {
      final whitespace = _repeatedNameWhitespace(random);
      return _GeneratedNameNormalizationCase(
        rawName: '$whitespace${_repeatedNameWhitespace(random)}',
        expectedPortions: const <String>[],
        generationSize: size,
        scenario: 'whitespace-only',
        shrunk: false,
      );
    }

    final portionCount = scenario == 1 ? 1 : 2 + random.nextInt(4);
    final portions = <String>[
      for (var index = 0; index < portionCount; index++)
        _randomNamePortion(random, size, index),
    ];
    final rawName = StringBuffer(_repeatedNameWhitespace(random));
    for (var index = 0; index < portions.length; index++) {
      if (index > 0) rawName.write(_repeatedNameWhitespace(random));
      rawName.write(portions[index]);
    }
    rawName.write(_repeatedNameWhitespace(random));

    return _GeneratedNameNormalizationCase(
      rawName: rawName.toString(),
      expectedPortions: List<String>.unmodifiable(portions),
      generationSize: size,
      scenario: scenario == 1 ? 'single-portion' : 'multiple-portions',
      shrunk: false,
    );
  },
  shrink: (input) sync* {
    if (input.shrunk) return;
    yield const _GeneratedNameNormalizationCase(
      rawName: ' \t  ',
      expectedPortions: <String>[],
      generationSize: 0,
      scenario: 'shrunk-whitespace-only',
      shrunk: true,
    );
  },
);

const _nameWhitespaceCharacters = <String>[' ', '\t', '\n', '\r'];

String _repeatedNameWhitespace(Random random) {
  final count = 2 + random.nextInt(5);
  final whitespace = StringBuffer();
  for (var index = 0; index < count; index++) {
    whitespace.write(
      _nameWhitespaceCharacters[random.nextInt(
        _nameWhitespaceCharacters.length,
      )],
    );
  }
  return whitespace.toString();
}

String _randomNamePortion(Random random, int size, int index) {
  const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const lowercase = 'abcdefghijklmnopqrstuvwxyz';
  final length = 1 + random.nextInt(8);
  final portion = StringBuffer(uppercase[random.nextInt(uppercase.length)]);
  for (var character = 1; character < length; character++) {
    portion.write(lowercase[random.nextInt(lowercase.length)]);
  }
  return '${portion.toString()}-$size-$index';
}

String _nameForDiagnostics(String rawName) => rawName
    .replaceAll(' ', '·')
    .replaceAll('\t', r'\t')
    .replaceAll('\r', r'\r')
    .replaceAll('\n', r'\n');

class _GeneratedNameNormalizationCase {
  const _GeneratedNameNormalizationCase({
    required this.rawName,
    required this.expectedPortions,
    required this.generationSize,
    required this.scenario,
    required this.shrunk,
  });

  final String rawName;
  final List<String> expectedPortions;
  final int generationSize;
  final String scenario;
  final bool shrunk;

  String get diagnostics =>
      'seed=$_propertyFourSeed generationSize=$generationSize '
      'scenario=$scenario raw=${_nameForDiagnostics(rawName)} '
      'portions=${expectedPortions.join('|')}';

  @override
  String toString() => diagnostics;
}
