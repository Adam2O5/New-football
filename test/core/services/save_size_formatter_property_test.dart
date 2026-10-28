@Tags(['property'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/save_formatters.dart';

void main() {
  const kibibyte = 1024;
  const mebibyte = kibibyte * 1024;
  const gibibyte = mebibyte * 1024;
  const propertySixRuns = 120;

  // This oracle mirrors the requirements directly and does not call the
  // production formatter or reuse its unit-selection helpers.
  String? oracleSize(int? sizeBytes) {
    if (sizeBytes == null) return null;
    if (sizeBytes < kibibyte) return '$sizeBytes B';
    if (sizeBytes >= gibibyte) {
      return '${(sizeBytes / gibibyte).toStringAsFixed(1)} GiB';
    }
    if (sizeBytes >= mebibyte) {
      return '${(sizeBytes / mebibyte).toStringAsFixed(1)} MiB';
    }
    return '${(sizeBytes / kibibyte).toStringAsFixed(1)} KiB';
  }

  final generatedSizes = any.simple<int?>(
    generate: (random, size) {
      // Cycle through unavailable and every unit boundary so the minimum
      // number of runs cannot accidentally miss a required threshold.
      switch (size % 11) {
        case 0:
          return null;
        case 1:
          return 0;
        case 2:
          return 1;
        case 3:
          return kibibyte - 1;
        case 4:
          return kibibyte;
        case 5:
          return kibibyte + 1;
        case 6:
          return mebibyte - 1;
        case 7:
          return mebibyte;
        case 8:
          return gibibyte - 1;
        case 9:
          return gibibyte;
        default:
          final wholeGib = random.nextInt(8);
          final remainder = random.nextInt(1 << 30);
          return wholeGib * gibibyte + remainder;
      }
    },
    shrink: (input) sync* {
      if (input == null || input == 0) return;
      yield 0;
    },
  );

  Glados<int?>(
    generatedSizes,
    ExploreConfig(
      numRuns: propertySixRuns,
      initialSize: 8,
      speed: 1,
      random: Random(6),
    ),
  ).test(
    'Feature: save-management, Property 6: binary size formatter holds for '
    '$propertySixRuns generated sizes and null cases',
    (sizeBytes) {
      final actual = SaveSizeFormatter.format(sizeBytes);
      expect(actual, oracleSize(sizeBytes));

      if (sizeBytes == null) {
        // Unavailable size must stay unavailable, never become zero bytes.
        expect(actual, isNull);
        expect(actual, isNot('0'));
        expect(actual, isNot('0 B'));
        return;
      }

      expect(sizeBytes, greaterThanOrEqualTo(0));
      if (sizeBytes < kibibyte) {
        expect(actual, '$sizeBytes B');
        expect(actual, endsWith(' B'));
      } else if (sizeBytes < mebibyte) {
        expect(actual, endsWith(' KiB'));
      } else if (sizeBytes < gibibyte) {
        expect(actual, endsWith(' MiB'));
      } else {
        expect(actual, endsWith(' GiB'));
      }

      // These exact cases are generated repeatedly and make each transition
      // explicit, including the values immediately below each threshold.
      final boundaryExpectation = <int, String>{
        0: '0 B',
        kibibyte - 1: '1023 B',
        kibibyte: '1.0 KiB',
        mebibyte - 1: '1024.0 KiB',
        mebibyte: '1.0 MiB',
        gibibyte - 1: '1024.0 MiB',
        gibibyte: '1.0 GiB',
      }[sizeBytes];
      if (boundaryExpectation != null) {
        expect(actual, boundaryExpectation);
      }
    },
  );
}
