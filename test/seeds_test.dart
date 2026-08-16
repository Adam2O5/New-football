import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/random/seeds.dart';

void main() {
  test('matchSeed is stable for the same match identity', () {
    final first = matchSeed(1234, 2026, 'match-17');
    final second = matchSeed(1234, 2026, 'match-17');

    expect(first, second);
    expect(matchSeed(1234, 2026, 'match-18'), isNot(first));
  });

  test('aiSeed separates decision types', () {
    final lineup = aiSeed(
      1234,
      2026,
      12,
      'team_europe_0',
      DecisionType.lineup,
    );
    final tactics = aiSeed(
      1234,
      2026,
      12,
      'team_europe_0',
      DecisionType.tactics,
    );

    expect(tactics, isNot(lineup));
  });
}
