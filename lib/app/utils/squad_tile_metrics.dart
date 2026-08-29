import 'package:flutter/material.dart';

/// Which extra values a squad roster tile currently shows.
enum SquadTileMetricMode { staminaForm, potential, optimalRole }

/// Players at this age or younger still use the developing (gold) potential
/// colour. Older players use the faded gold-grey treatment.
const int developingPotentialMaxAge = 26;

bool isDevelopingPotentialAge(int age) => age <= developingPotentialMaxAge;

/// Gold for developing players, pale gold-grey after age 26.
Color potentialStarColor(int age) {
  return isDevelopingPotentialAge(age)
      ? const Color(0xFFFFC107)
      : const Color(0xFFB8A98A);
}

/// Potential shown on tiles: 0.5–5.0 in half-star steps.
double displayedPotentialStars(double raw) {
  final bounded = raw.clamp(0.5, 5.0);
  return (bounded * 2).roundToDouble() / 2.0;
}

/// Short letter code used when the full role name does not fit a tile.
String abbreviateRoleLabel(String label) {
  final words = label
      .split(RegExp(r'[\s-]+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return label;
  if (words.length == 1) {
    final word = words.first;
    return word.length <= 10 ? word : word.substring(0, 3).toUpperCase();
  }
  return words.map((word) => word[0].toUpperCase()).join();
}

String compactRoleLabel(String label, {int maxChars = 14}) {
  if (label.length <= maxChars) return label;
  return abbreviateRoleLabel(label);
}
