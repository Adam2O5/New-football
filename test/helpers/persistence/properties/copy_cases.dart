part of '../save_management_property_cases.dart';

final Generator<GeneratedCopyCase> generatedCopyCases = any
    .simple<GeneratedCopyCase>(
      generate: (random, size) {
        final scenario = size % 4;
        // Locale selection is an independent generator draw, not derived from
        // the source spelling or occupied-number layout.
        final locale = random.nextBool() ? 'en' : 'pl';
        final sourceName = generatedCopySourceName(random, size);
        final source = oracleTrim(sourceName);
        final suffix = locale == 'pl' ? '-kopia' : '-copy';
        final baseCandidateOccupied = scenario != 0;
        final occupiedKeys = <String>{};
        if (baseCandidateOccupied) {
          occupiedKeys.add(oracleNameKey('$source$suffix'));
        }

        final maxNumber = 3 + random.nextInt(5);
        final occupiedNumbers = <int>{};
        int? forcedGap;
        if (scenario == 0) {
          // Numbered names may exist even while the unsuffixed base is free.
          for (var number = 2; number <= maxNumber; number++) {
            if (random.nextBool()) occupiedNumbers.add(number);
          }
        } else if (scenario == 1) {
          // Occupy every lower number, leave a deliberate gap, and occupy a
          // higher number so the oracle must choose the gap.
          forcedGap = 2 + random.nextInt(4);
          for (var number = 2; number < forcedGap; number++) {
            occupiedNumbers.add(number);
          }
          occupiedNumbers.add(forcedGap + 1);
          for (var number = forcedGap + 2; number <= maxNumber + 1; number++) {
            if (random.nextBool()) occupiedNumbers.add(number);
          }
        } else if (scenario == 2) {
          // A contiguous prefix checks that the next number is selected.
          for (var number = 2; number <= maxNumber; number++) {
            occupiedNumbers.add(number);
          }
        } else {
          // Sparse random numbering covers additional holes and collisions.
          for (var number = 2; number <= maxNumber; number++) {
            if (random.nextBool()) occupiedNumbers.add(number);
          }
          if (occupiedNumbers.isEmpty) occupiedNumbers.add(2);
        }

        for (final number in occupiedNumbers) {
          occupiedKeys.add(oracleNameKey('$source$suffix-$number'));
        }

        // These unrelated keys make the occupied-key set independently
        // generated rather than a list containing only expected candidates.
        final unrelatedCount = random.nextInt(3);
        for (var index = 0; index < unrelatedCount; index++) {
          occupiedKeys.add(
            'independent-key-${size.abs()}-$index-'
            '${random.nextInt(1000000)}',
          );
        }

        return GeneratedCopyCase(
          sourceName: sourceName,
          locale: locale,
          occupiedKeys: occupiedKeys,
          baseCandidateOccupied: baseCandidateOccupied,
          forcedGap: forcedGap,
        );
      },
      shrink: (input) sync* {
        if (input.sourceName == ' A ') return;

        final suffix = input.locale == 'pl' ? '-kopia' : '-copy';
        if (input.forcedGap != null) {
          final gap = input.forcedGap!;
          yield GeneratedCopyCase(
            sourceName: ' A ',
            locale: input.locale,
            occupiedKeys: {
              oracleNameKey('A$suffix'),
              for (var number = 2; number < gap; number++)
                oracleNameKey('A$suffix-$number'),
              oracleNameKey('A$suffix-${gap + 1}'),
            },
            baseCandidateOccupied: true,
            forcedGap: gap,
          );
        } else if (input.baseCandidateOccupied) {
          yield GeneratedCopyCase(
            sourceName: ' A ',
            locale: input.locale,
            occupiedKeys: {oracleNameKey('A$suffix')},
            baseCandidateOccupied: true,
            forcedGap: null,
          );
        } else {
          yield GeneratedCopyCase(
            sourceName: ' A ',
            locale: input.locale,
            occupiedKeys: const <String>{},
            baseCandidateOccupied: false,
            forcedGap: null,
          );
        }
      },
    );

String generatedCopySourceName(Random random, int size) {
  final units = switch (size % 3) {
    0 => polishUnits,
    1 => latinUnits,
    _ => randomUnits(random, size),
  };
  final length = 1 + random.nextInt(size.clamp(1, 8));
  final body = StringBuffer();
  for (var index = 0; index < length; index++) {
    final variants = units[random.nextInt(units.length)];
    body.write(variants[random.nextInt(variants.length)]);
  }
  final rendered = random.nextBool() ? body.toString().toUpperCase() : body;
  return '${outerWhitespace(random)}$rendered${outerWhitespace(random)}';
}

OracleCopySelection oracleCopySelection(
  String source,
  String suffix,
  Set<String> occupiedKeys,
) {
  final candidates = <String>[];
  final baseCandidate = '$source$suffix';
  candidates.add(baseCandidate);
  if (!occupiedKeys.contains(oracleNameKey(baseCandidate))) {
    return OracleCopySelection(
      name: baseCandidate,
      number: null,
      candidates: List<String>.unmodifiable(candidates),
    );
  }

  for (var number = 2; ; number++) {
    final candidate = '$source$suffix-$number';
    candidates.add(candidate);
    if (!occupiedKeys.contains(oracleNameKey(candidate))) {
      return OracleCopySelection(
        name: candidate,
        number: number,
        candidates: List<String>.unmodifiable(candidates),
      );
    }
  }
}

class GeneratedCopyCase {
  const GeneratedCopyCase({
    required this.sourceName,
    required this.locale,
    required this.occupiedKeys,
    required this.baseCandidateOccupied,
    required this.forcedGap,
  });

  final String sourceName;
  final String locale;
  final Set<String> occupiedKeys;
  final bool baseCandidateOccupied;
  final int? forcedGap;

  @override
  String toString() =>
      'GeneratedCopyCase('
      'sourceName: ${sourceName.replaceAll('\n', r'\n')}, '
      'locale: $locale, occupiedKeys: $occupiedKeys, '
      'baseCandidateOccupied: $baseCandidateOccupied, '
      'forcedGap: $forcedGap)';
}

class OracleCopySelection {
  const OracleCopySelection({
    required this.name,
    required this.number,
    required this.candidates,
  });

  final String name;
  final int? number;
  final List<String> candidates;
}
