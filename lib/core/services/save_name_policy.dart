/// Pure naming rules for save-management operations.
///
/// The policy only compares names. It never changes the stored source name and
/// does not perform any file-system or locale lookups.
abstract final class SaveNamePolicy {
  /// Removes leading and trailing whitespace from a proposed save name.
  ///
  /// An empty result is retained so callers such as a rename dialog can report
  /// a validation error without losing the user's input. [nameKey] and
  /// [copyName] reject empty results before using them as names.
  static String trimName(String input) => input.trim();

  /// Returns the locale-independent key used to compare save names.
  ///
  /// Comparison trims the name, folds case, and removes Latin diacritics.
  /// This includes all Polish letters (`ą ć ę ł ń ó ś ź ż`). The returned key
  /// is used only for comparison; the original spelling remains unchanged.
  ///
  /// Throws [ArgumentError] when [input] contains no non-whitespace
  /// characters, because a blank name cannot be a valid save name.
  static String nameKey(String input) {
    final trimmed = trimName(input);
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        input,
        'input',
        'Save name must contain at least one non-whitespace character',
      );
    }

    return _canonicalize(trimmed);
  }

  /// Selects a deterministic, unused name for a duplicate of [sourceName].
  ///
  /// The unsuffixed candidate is tried first. If it is occupied, candidates
  /// are tried in ascending order beginning at `-2`, so gaps in existing
  /// numbering are reused. [occupiedKeys] may contain canonical `Name_Key`
  /// values; canonicalizing the values again also makes the method safe for a
  /// caller that supplies trimmed display names.
  ///
  /// `pl` (including regional forms such as `pl-PL`) uses `-kopia`; every
  /// other supported locale uses `-copy`. The source name itself is never
  /// modified by this operation.
  static String copyName(
    String sourceName,
    String localeCode,
    Set<String> occupiedKeys,
  ) {
    final source = trimName(sourceName);
    if (source.isEmpty) {
      throw ArgumentError.value(
        sourceName,
        'sourceName',
        'Save name must contain at least one non-whitespace character',
      );
    }

    final occupied = <String>{
      for (final key in occupiedKeys)
        if (key.trim().isNotEmpty) _canonicalize(key.trim()),
    };
    final suffix = _copySuffix(localeCode);
    final baseCandidate = '$source$suffix';

    if (!occupied.contains(nameKey(baseCandidate))) {
      return baseCandidate;
    }

    for (var number = 1; ; number++) {
      final candidate = '$source$suffix-${number + 1}';
      if (!occupied.contains(nameKey(candidate))) {
        return candidate;
      }
    }
  }

  static String _copySuffix(String localeCode) {
    final languageCode = localeCode
        .trim()
        .toLowerCase()
        .split(RegExp(r'[-_]'))
        .first;
    return languageCode == 'pl' ? '-kopia' : '-copy';
  }

  static String _canonicalize(String value) {
    final lowerCased = value.toLowerCase();
    final buffer = StringBuffer();

    for (final rune in lowerCased.runes) {
      // Remove combining marks as well as precomposed characters. This makes
      // both `e\u0301` and `é` canonicalize to `e`.
      if (_isCombiningMark(rune)) continue;
      buffer.write(_diacriticReplacement(rune));
    }

    return buffer.toString();
  }

  static bool _isCombiningMark(int rune) =>
      (rune >= 0x0300 && rune <= 0x036f) ||
      (rune >= 0x1ab0 && rune <= 0x1aff) ||
      (rune >= 0x1dc0 && rune <= 0x1dff) ||
      (rune >= 0x20d0 && rune <= 0x20ff) ||
      (rune >= 0xfe20 && rune <= 0xfe2f);

  static String _diacriticReplacement(int rune) =>
      _diacriticReplacements[rune] ?? String.fromCharCode(rune);

  // Values are lower-case because _canonicalize performs case folding first.
  // The table covers Latin-1, Latin Extended-A, and the common Latin letters
  // used by the supported locales. A few compatibility letters are included
  // so canonical comparison remains useful for names entered in other scripts.
  static const Map<int, String> _diacriticReplacements = <int, String>{
    // Latin-1 supplement.
    0x00e0: 'a',
    0x00e1: 'a',
    0x00e2: 'a',
    0x00e3: 'a',
    0x00e4: 'a',
    0x00e5: 'a',
    0x00e6: 'ae',
    0x00e7: 'c',
    0x00e8: 'e',
    0x00e9: 'e',
    0x00ea: 'e',
    0x00eb: 'e',
    0x00ec: 'i',
    0x00ed: 'i',
    0x00ee: 'i',
    0x00ef: 'i',
    0x00f0: 'd',
    0x00f1: 'n',
    0x00f2: 'o',
    0x00f3: 'o',
    0x00f4: 'o',
    0x00f5: 'o',
    0x00f6: 'o',
    0x00f8: 'o',
    0x00f9: 'u',
    0x00fa: 'u',
    0x00fb: 'u',
    0x00fc: 'u',
    0x00fd: 'y',
    0x00fe: 'th',
    0x00ff: 'y',

    // Latin Extended-A, including the Polish alphabet.
    0x0101: 'a',
    0x0103: 'a',
    0x0105: 'a', // ą
    0x0107: 'c',
    0x0109: 'c',
    0x010b: 'c',
    0x010d: 'c',
    0x010f: 'd',
    0x0111: 'd',
    0x0113: 'e',
    0x0115: 'e',
    0x0117: 'e',
    0x0119: 'e', // ę
    0x011b: 'e',
    0x011d: 'g',
    0x011f: 'g',
    0x0121: 'g',
    0x0123: 'g',
    0x0125: 'h',
    0x0127: 'h',
    0x0129: 'i',
    0x012b: 'i',
    0x012d: 'i',
    0x012f: 'i',
    0x0131: 'i',
    0x0135: 'j',
    0x0137: 'k',
    0x0138: 'k',
    0x013a: 'l',
    0x013c: 'l',
    0x013e: 'l',
    0x0140: 'l',
    0x0142: 'l', // ł
    0x0144: 'n', // ń
    0x0146: 'n',
    0x0148: 'n',
    0x014b: 'n',
    0x014d: 'o',
    0x014f: 'o',
    0x0151: 'o',
    0x0153: 'oe',
    0x0155: 'r',
    0x0157: 'r',
    0x0159: 'r',
    0x015b: 's', // ś
    0x015d: 's',
    0x015f: 's',
    0x0161: 's',
    0x0163: 't',
    0x0165: 't',
    0x0167: 't',
    0x0169: 'u',
    0x016b: 'u',
    0x016d: 'u',
    0x016f: 'u',
    0x0171: 'u',
    0x0173: 'u',
    0x0175: 'w',
    0x0177: 'y',
    0x017a: 'z', // ź
    0x017c: 'z', // ż
    0x017e: 'z',

    // Common Latin Extended-B and compatibility letters.
    0x0180: 'b',
    0x0183: 'b',
    0x0188: 'c',
    0x018c: 'd',
    0x0192: 'f',
    0x0195: 'h',
    0x0199: 'k',
    0x019a: 'l',
    0x019e: 'n',
    0x01a1: 'o',
    0x01a3: 'o',
    0x01a5: 'p',
    0x01a8: 'q',
    0x01ad: 't',
    0x01b0: 'u',
    0x01b4: 'y',
    0x01b6: 'z',
    0x01b9: 'z',
    0x01bd: 'z',
    0x01c6: 'dz',
    0x01cc: 'dz',
    0x01f0: 'j',
    0x021b: 't',
    0x0233: 'y',
    0x0253: 'b',
    0x0254: 'o',
    0x0256: 'd',
    0x0257: 'd',
    0x0259: 'e',
    0x025b: 'e',
    0x0260: 'g',
    0x0263: 'g',
    0x0268: 'i',
    0x0269: 'i',
    0x026f: 'm',
    0x0272: 'n',
    0x0275: 'o',
    0x027d: 'r',
    0x0280: 'r',
    0x0282: 's',
    0x0288: 't',
    0x0289: 'u',
    0x028b: 'v',
    0x0292: 'z',
    0x0141: 'l', // Ł, retained for callers bypassing the lower-case path.
    0x00d8: 'o', // Ø
    0x00d0: 'd', // Ð
    0x00de: 'th', // Þ
    0x00c6: 'ae', // Æ
    0x0152: 'oe', // Œ
  };
}
