import 'package:intl/intl.dart';

/// Pure presentation helpers for save metadata.
///
/// These helpers only format values supplied by the caller. They do not read
/// the clock, the filesystem, or the save index.
abstract final class SaveDateFormatter {
  /// Formats [value] using the requested locale.
  ///
  /// [localeCode] may be omitted to use the deterministic `en` default. The
  /// [formatDateTime] alias provides a named required-locale form for call
  /// sites that already use named locale arguments. The value is formatted as
  /// supplied; no timezone conversion or current-time lookup is performed.
  static String format(DateTime value, [String? localeCode]) {
    final requestedLocale = localeCode ?? 'en';
    final effectiveLocale = requestedLocale.trim().isEmpty
        ? 'en'
        : requestedLocale;

    // yMd follows the calendar order for the active locale. add_Hm keeps the
    // date and both hour and minute in the displayed value.
    return DateFormat.yMd(effectiveLocale).add_Hm().format(value);
  }

  /// Named alias that makes the locale requirement explicit at call sites.
  static String formatDateTime(DateTime value, {required String locale}) {
    return format(value, locale);
  }
}

/// Pure formatter for the byte length of a serialized save file.
abstract final class SaveSizeFormatter {
  static const int _kibibyte = 1024;
  static const int _mebibyte = _kibibyte * 1024;
  static const int _gibibyte = _mebibyte * 1024;

  /// Returns a binary-unit representation of [sizeBytes].
  ///
  /// A null value means that the file size is unavailable and remains null so
  /// callers can replace it with a localized unavailable-state label. It is
  /// deliberately never converted to `0 B`.
  static String? format(int? sizeBytes) {
    if (sizeBytes == null || sizeBytes < 0) {
      return null;
    }

    if (sizeBytes < _kibibyte) {
      return '$sizeBytes B';
    }

    final (value, unit) = switch (sizeBytes) {
      >= _gibibyte => (sizeBytes / _gibibyte, 'GiB'),
      >= _mebibyte => (sizeBytes / _mebibyte, 'MiB'),
      _ => (sizeBytes / _kibibyte, 'KiB'),
    };

    return '${value.toStringAsFixed(1)} $unit';
  }
}

/// Convenience function for callers that prefer top-level formatters.
String formatSaveDate(DateTime value, [String? localeCode]) {
  return SaveDateFormatter.format(value, localeCode);
}

/// Convenience function for callers that prefer top-level formatters.
String? formatSaveSize(int? sizeBytes) {
  return SaveSizeFormatter.format(sizeBytes);
}
