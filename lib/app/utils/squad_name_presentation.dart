part of 'squad_presentation.dart';

/// The two normalized name lines used by a player row.
@immutable
class NameParts {
  const NameParts({
    required this.firstLine,
    required this.secondLine,
    this.original = '',
  });

  /// The first non-empty whitespace-separated portion, or an empty string.
  final String firstLine;

  /// All remaining portions joined by one space, or an empty string.
  final String secondLine;

  /// The original input, retained for semantic consumers that need it.
  final String original;

  String get first => firstLine;
  String get second => secondLine;
  String get givenName => firstLine;
  String get familyName => secondLine;
  bool get hasSecondLine => secondLine.isNotEmpty;

  /// The normalized name represented by these two lines.
  String get normalized =>
      [firstLine, secondLine].where((part) => part.isNotEmpty).join(' ');
}

/// Splits a player name into a first line and a remaining-name line.
///
/// One or more whitespace characters are treated as one separator and empty
/// portions are discarded. The input is never modified.
NameParts splitPlayerName(String raw) {
  final portions = raw
      .split(RegExp(r'\s+'))
      .where((portion) => portion.isNotEmpty)
      .toList(growable: false);

  if (portions.isEmpty) {
    return NameParts(firstLine: '', secondLine: '', original: raw);
  }
  if (portions.length == 1) {
    return NameParts(firstLine: portions.first, secondLine: '', original: raw);
  }

  return NameParts(
    firstLine: portions.first,
    secondLine: portions.skip(1).join(' '),
    original: raw,
  );
}
