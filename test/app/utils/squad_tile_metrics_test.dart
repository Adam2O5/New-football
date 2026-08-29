import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/utils/squad_tile_metrics.dart';

void main() {
  test('clamps potential to half-star steps between 0.5 and 5', () {
    expect(displayedPotentialStars(0), 0.5);
    expect(displayedPotentialStars(0.24), 0.5);
    expect(displayedPotentialStars(1.24), 1.0);
    expect(displayedPotentialStars(1.25), 1.5);
    expect(displayedPotentialStars(4.76), 5.0);
    expect(displayedPotentialStars(9), 5.0);
  });

  test('uses gold stars through age 26 and faded stars afterwards', () {
    expect(isDevelopingPotentialAge(26), isTrue);
    expect(isDevelopingPotentialAge(27), isFalse);
    expect(potentialStarColor(18), const Color(0xFFFFC107));
    expect(potentialStarColor(26), const Color(0xFFFFC107));
    expect(potentialStarColor(27), const Color(0xFFB8A98A));
  });

  test('keeps short role names and abbreviates long ones', () {
    expect(compactRoleLabel('Sweeper'), 'Sweeper');
    expect(compactRoleLabel('Very Long Role Name', maxChars: 14), 'VLRN');
    expect(abbreviateRoleLabel('Box-to-Box'), 'BTB');
  });
}
