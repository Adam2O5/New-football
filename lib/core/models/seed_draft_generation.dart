part of 'seed_data_generator.dart';

mixin _SeedDraftGeneration on _SeedGenerationShared {
  /// Liczba prospektów, przedział OVR i przedział potencjału per kubełek
  /// (`data_generation.md` §„Potencjał i OVR”). Suma liczebności musi
  /// odpowiadać `prospectCount` (domyślnie 120).
  static const List<
    (int count, int ovrMin, int ovrMax, double starMin, double starMax)
  >
  _draftClassOvrTable = [
    (3, 77, 79, 4.0, 5.0),
    (8, 74, 76, 3.5, 4.5),
    (12, 70, 73, 3.5, 4.0),
    (10, 65, 75, 3.0, 4.5),
    (20, 66, 69, 3.0, 3.5),
    (20, 62, 65, 2.5, 3.0),
    (20, 58, 61, 2.0, 2.5),
    (27, 58, 79, 2.0, 5.0),
  ];

  DraftClass generateDraftClass({
    required int year,
    int prospectCount = 120,
    int? seed,
  }) {
    final rng = seed == null
        ? _random
        : Random(seasonEventSeed(seed, year, 'draft-class'));
    final ovrTargets =
        <(int ovrMin, int ovrMax, double starMin, double starMax)>[];
    for (final (count, ovrMin, ovrMax, starMin, starMax)
        in _draftClassOvrTable) {
      ovrTargets.addAll(List.filled(count, (ovrMin, ovrMax, starMin, starMax)));
    }
    if (ovrTargets.length != prospectCount) {
      throw StateError(
        'Suma liczebności w _draftClassOvrTable (${ovrTargets.length}) nie '
        'zgadza się z prospectCount ($prospectCount) — zaktualizuj tabelę '
        'zgodnie z data_generation.md.',
      );
    }
    ovrTargets.shuffle(rng);

    final prospects = <Prospect>[];
    for (var i = 0; i < prospectCount; i++) {
      final positions = Position.values.where((p) => p != Position.gk).toList();
      if (i < 3) {
        positions.insert(0, Position.gk);
      }
      final pos = positions[rng.nextInt(positions.length)];

      final (ovrMin, ovrMax, starMin, starMax) = ovrTargets[i];
      final ovr = ovrMin + rng.nextInt(ovrMax - ovrMin + 1);
      final stars = starMin + rng.nextDouble() * (starMax - starMin);
      final roundedStars = (stars * 2).round() / 2.0;

      final nationality =
          Nationality.values[rng.nextInt(Nationality.values.length)];

      prospects.add(
        Prospect(
          id: 'prospect_${year}_$i',
          personality: PlayerPersonality
              .values[rng.nextInt(PlayerPersonality.values.length)],
          name: _generateName(rng, nationality),
          nationality: nationality,
          position: pos,
          age: 18 + rng.nextInt(3),
          optimalRole: _randomRoleFor(pos, rng),
          attributes: _attributesForOvr(pos, ovr, rng),
          scoutGrade: (ovr + rng.nextInt(8) - 4).clamp(30, 99),
          combineScore: (ovr + rng.nextInt(12) - 6).clamp(30, 99),
          potentialStars: roundedStars,
          heightCm: _heightCmFor(pos, rng),
          injuryProne: 1 + rng.nextInt(10),
          determination: 1 + rng.nextInt(10),
        ),
      );
    }
    prospects.sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));
    return DraftClass(year: year, prospects: prospects);
  }
}
