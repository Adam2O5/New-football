@Tags(['property'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/core/services/save_name_policy.dart';

import '../../helpers/persistence/save_management_property_cases.dart';

const propertyTwoTag =
    'Feature: save-management, Property 2: smallest free copy suffix';
const propertyTwoRuns = 120;

void main() {
  // **Validates: Requirements 2.3, 2.4, 5.6, 5.7, 8.4, 8.9, 8.10, 8.16, 8.17**
  Glados<GeneratedCopyCase>(
    generatedCopyCases,
    ExploreConfig(
      numRuns: propertyTwoRuns,
      initialSize: 8,
      speed: 1,
      random: Random(2),
    ),
  ).test('$propertyTwoTag holds for $propertyTwoRuns independently generated '
      'locales, source names, and occupied keys', (input) {
    final source = oracleTrim(input.sourceName);
    final suffix = input.locale == 'pl' ? '-kopia' : '-copy';
    final occupiedKeys = <String>{
      for (final occupiedName in input.occupiedKeys)
        oracleNameKey(occupiedName),
    };
    final expected = oracleCopySelection(source, suffix, occupiedKeys);
    final actual = SaveNamePolicy.copyName(
      input.sourceName,
      input.locale,
      input.occupiedKeys,
    );

    // The expected name is selected without calling any SaveNamePolicy
    // method, so the oracle independently checks the localized suffix and
    // the first free candidate.
    expect(actual, expected.name);
    expect(actual, startsWith(source));
    expect(actual, contains(suffix));
    expect(oracleNameKey(actual), isNot(isIn(occupiedKeys)));

    // A free base candidate must be returned as-is; otherwise every lower
    // numbered candidate is occupied and the selected number is >= 2.
    final baseKey = oracleNameKey('$source$suffix');
    if (input.baseCandidateOccupied) {
      expect(occupiedKeys, contains(baseKey));
      final selectedNumber = expected.number;
      expect(selectedNumber, isNotNull);
      expect(selectedNumber!, greaterThanOrEqualTo(2));
      for (var number = 2; number < selectedNumber; number++) {
        expect(occupiedKeys, contains(oracleNameKey('$source$suffix-$number')));
      }
      expect(
        occupiedKeys,
        isNot(contains(oracleNameKey('$source$suffix-$selectedNumber'))),
      );
    } else {
      expect(occupiedKeys, isNot(contains(baseKey)));
      expect(expected.number, isNull);
      expect(actual, '$source$suffix');
    }

    // The forced-gap cases prove that a free lower number wins over a
    // higher occupied number, while the candidate set and result remain
    // unique in Name_Key space.
    if (input.forcedGap != null) {
      final gap = input.forcedGap!;
      expect(input.baseCandidateOccupied, isTrue);
      expect(expected.number, gap);
      expect(
        occupiedKeys,
        contains(oracleNameKey('$source$suffix-${gap + 1}')),
      );
      expect(
        occupiedKeys,
        isNot(contains(oracleNameKey('$source$suffix-$gap'))),
      );
    }

    final candidateKeys = <String>{
      for (final candidate in expected.candidates) oracleNameKey(candidate),
    };
    expect(candidateKeys.length, expected.candidates.length);
    final allGeneratedKeys = {...occupiedKeys, oracleNameKey(actual)};
    expect(allGeneratedKeys.length, occupiedKeys.length + 1);
  });
}
