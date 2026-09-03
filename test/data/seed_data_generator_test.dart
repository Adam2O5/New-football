import 'dart:math';

import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:test/test.dart';

void main() {
  group('SeedDataGenerator.generateFreeAgentPlayers', () {
    List<Player> generate(int seed) =>
        SeedDataGenerator().generateFreeAgentPlayers(rng: Random(seed));

    test('generuje pulę o liczności 25–35', () {
      for (final seed in [1, 2, 3, 4, 5]) {
        final players = generate(seed);
        expect(
          players.length,
          inInclusiveRange(25, 35),
          reason: 'seed=$seed dał ${players.length} graczy',
        );
      }
    });

    test('OVR mieści się w oczekiwanym paśmie (73–78 ± tolerancja formuły '
        'wag atrybutów)', () {
      final players = generate(42);
      for (final p in players) {
        final ovr = p.overall();
        expect(
          ovr,
          inInclusiveRange(65.0, 86.0),
          reason: '${p.name} (${p.position}) ma OVR $ovr',
        );
      }
    });

    test('wiek mieści się w przedziale 22–32', () {
      final players = generate(7);
      for (final p in players) {
        expect(p.age, inInclusiveRange(22, 32));
      }
    });

    test('potencjał mieści się w przedziale 2.5–4.0★ i jest wielokrotnością '
        '0.5', () {
      final players = generate(99);
      for (final p in players) {
        expect(p.potentialStars, inInclusiveRange(2.5, 4.0));
        expect((p.potentialStars * 2) % 1, 0.0);
      }
    });

    test('pozycja jest losowa — brak wymuszonej kwoty na bramkarzy', () {
      // Statystyczna kontrola: przy pełnym uniform rozkładzie po
      // Position.values liczba bramkarzy w wielu próbach nie jest stale
      // dodatnia ani stale zerowa — nie wymuszamy więc żadnego minimum.
      final positionsSeen = <Position>{};
      for (final seed in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) {
        for (final p in generate(seed)) {
          positionsSeen.add(p.position);
        }
      }
      // Przy 10 seedach × ~30 graczy prawdopodobieństwo, że którejś pozycji
      // (w tym GK) w ogóle nie wylosowano, jest znikome — to łapie
      // przypadkowe zawężenie puli pozycji.
      expect(positionsSeen, equals(Position.values.toSet()));
    });

    test('kontrakt oznacza brak klubu (yearsRemaining == 0)', () {
      final players = generate(5);
      for (final p in players) {
        expect(p.contract.yearsRemaining, 0);
      }
    });

    test('identyfikatory graczy są unikalne w ramach jednej puli', () {
      final players = generate(11);
      final ids = players.map((p) => p.id).toSet();
      expect(ids.length, players.length);
    });

    test('wynik jest deterministyczny dla tego samego ziarna', () {
      final a = generate(123);
      final b = generate(123);
      expect(a.map((p) => p.id).toList(), equals(b.map((p) => p.id).toList()));
      expect(
        a.map((p) => p.overall()).toList(),
        equals(b.map((p) => p.overall()).toList()),
      );
    });
  });
}
