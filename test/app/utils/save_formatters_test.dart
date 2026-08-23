import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:new_football/app/utils/save_formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pl');
    await initializeDateFormatting('en');
  });

  group('SaveDateFormatter', () {
    test('formats a locale date with hour and minute', () {
      final value = DateTime(2025, 7, 14, 16, 37);
      final polish = SaveDateFormatter.format(value, 'pl');
      final english = SaveDateFormatter.format(value, 'en');

      expect(polish, contains('2025'));
      expect(polish, contains('14'));
      expect(polish, contains('16'));
      expect(polish, contains('37'));
      expect(english, contains('2025'));
      expect(english, contains('14'));
      expect(english, contains('16'));
      expect(english, contains('37'));
      expect(polish, isNot(equals(english)));
    });
  });

  group('SaveSizeFormatter', () {
    test('formats byte boundaries using binary units', () {
      expect(SaveSizeFormatter.format(0), '0 B');
      expect(SaveSizeFormatter.format(1023), '1023 B');
      expect(SaveSizeFormatter.format(1024), '1.0 KiB');
      expect(SaveSizeFormatter.format(1024 * 1024), '1.0 MiB');
      expect(SaveSizeFormatter.format(1024 * 1024 * 1024), '1.0 GiB');
    });

    test('returns an unavailable marker rather than displaying zero', () {
      expect(SaveSizeFormatter.format(null), isNull);
      expect(formatSaveSize(null), isNull);
      expect(SaveSizeFormatter.format(null), isNot('0 B'));
    });
  });
}
