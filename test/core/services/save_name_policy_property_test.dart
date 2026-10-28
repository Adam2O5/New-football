@Tags(['property'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/core/services/save_name_policy.dart';

import '../../helpers/persistence/save_management_property_cases.dart';

const propertyTag =
    'Feature: save-management, Property 1: stable Name_Key and name validation';
const propertyRuns = 120;

void main() {
  // **Validates: Requirements 3.2, 3.3, 3.4, 8.21, 8.22, 8.23**
  Glados<GeneratedName>(
    generatedNames,
    ExploreConfig(
      numRuns: propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(1),
    ),
  ).test(
    '$propertyTag holds for $propertyRuns independently generated inputs',
    (input) {
      final persistedBefore = input.persistedName;
      final equivalentBefore = input.equivalentName;
      final trimmedPersisted = oracleTrim(input.persistedName);
      final trimmedEquivalent = oracleTrim(input.equivalentName);

      if (input.whitespaceOnly) {
        expect(trimmedPersisted, isEmpty);
        expect(trimmedEquivalent, isEmpty);
        expect(SaveNamePolicy.trimName(input.persistedName), isEmpty);
        expect(SaveNamePolicy.trimName(input.equivalentName), isEmpty);
        expect(
          () => SaveNamePolicy.nameKey(input.persistedName),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => SaveNamePolicy.nameKey(input.equivalentName),
          throwsA(isA<ArgumentError>()),
        );

        // The policy validates the candidate but does not mutate the value
        // that would remain persisted by the caller.
        expect(input.persistedName, persistedBefore);
        expect(input.equivalentName, equivalentBefore);
        return;
      }

      expect(trimmedPersisted, isNotEmpty);
      expect(trimmedEquivalent, isNotEmpty);
      expect(SaveNamePolicy.trimName(input.persistedName), trimmedPersisted);
      expect(SaveNamePolicy.trimName(input.equivalentName), trimmedEquivalent);

      // The expected key is rebuilt from the generated text, independently
      // from SaveNamePolicy's canonicalization table and implementation.
      final expectedKey = oracleNameKey(input.persistedName);
      final expectedEquivalentKey = oracleNameKey(input.equivalentName);
      expect(expectedEquivalentKey, expectedKey);
      expect(SaveNamePolicy.nameKey(input.persistedName), expectedKey);
      expect(SaveNamePolicy.nameKey(input.equivalentName), expectedKey);
      expect(
        SaveNamePolicy.nameKey(input.persistedName),
        SaveNamePolicy.nameKey(input.equivalentName),
      );

      // Name_Key is a comparison value only; neither generated persisted name
      // may be replaced by its trimmed or canonical representation.
      expect(input.persistedName, persistedBefore);
      expect(input.equivalentName, equivalentBefore);
    },
  );
}
