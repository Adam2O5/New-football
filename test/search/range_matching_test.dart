import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/services/search_filter_matching.dart';

void main() {
  group('rangesOverlap', () {
    test('both bounds unset always overlaps', () {
      expect(rangesOverlap(null, null, 10, 20), isTrue);
    });

    test('only min set: excludes when known range is entirely below it', () {
      expect(rangesOverlap(15, null, 10, 14), isFalse);
      expect(rangesOverlap(15, null, 10, 15), isTrue);
    });

    test('only max set: excludes when known range is entirely above it', () {
      expect(rangesOverlap(null, 15, 16, 20), isFalse);
      expect(rangesOverlap(null, 15, 15, 20), isTrue);
    });

    test('both bounds set: overlapping ranges match', () {
      expect(rangesOverlap(10, 20, 15, 25), isTrue);
      expect(rangesOverlap(10, 20, 0, 5), isFalse);
      expect(rangesOverlap(10, 20, 25, 30), isFalse);
    });

    test('touching at a single point counts as overlap', () {
      expect(rangesOverlap(10, 20, 20, 30), isTrue);
      expect(rangesOverlap(10, 20, 0, 10), isTrue);
    });
  });
}
