part of 'seed_data_generator.dart';

mixin _SeedDraftGeneration on _SeedGenerationShared {
  /// Liczba prospektów, przedział OVR i przedział potencjału per kubełek
  /// (`data_generation.md` §„Potencjał i OVR”). Suma liczebności musi
  /// odpowiadać `prospectCount` (domyślnie 120).

  DraftClass generateDraftClass({
    required int year,
    int? prospectCount,
    int? seed,
  }) {
    prospectCount ??= balance.draft.classSize;
    final rng = seed == null
        ? _random
        : Random(seasonEventSeed(seed, year, 'draft-class'));
    final ovrTargets =
        <(int ovrMin, int ovrMax, double starMin, double starMax)>[];
    for (final (count, ovrMin, ovrMax, starMin, starMax)
        in balance.seed.draftProfiles) {
      ovrTargets.addAll(List.filled(count, (ovrMin, ovrMax, starMin, starMax)));
    }
    if (ovrTargets.length != prospectCount) {
      throw StateError(
        'Suma liczebności w balance.seed.draftProfiles (${ovrTargets.length}) nie '
        'zgadza się z prospectCount ($prospectCount) — zaktualizuj tabelę '
        'zgodnie z data_generation.md.',
      );
    }
    ovrTargets.shuffle(rng);

    final prospects = <Prospect>[];
    for (var i = 0; i < prospectCount; i++) {
      final positions = Position.values.where((p) => p != Position.gk).toList();
      if (i < balance.seed.draftGkEligibleSlots) {
        positions.insert(0, Position.gk);
      }
      final pos = positions[rng.nextInt(positions.length)];

      final (ovrMin, ovrMax, starMin, starMax) = ovrTargets[i];
      final ovr = ovrMin + rng.nextInt(ovrMax - ovrMin + 1);
      final stars = starMin + rng.nextDouble() * (starMax - starMin);
      final roundedStars =
          (stars * balance.seed.potentialRoundingSteps).round() /
          balance.seed.potentialRoundingSteps;

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
          age:
              balance.draft.prospectAgeMin +
              rng.nextInt(
                balance.draft.prospectAgeMax - balance.draft.prospectAgeMin + 1,
              ),
          optimalRole: _randomRoleFor(pos, rng),
          attributes: _attributesForOvr(pos, ovr, rng),
          scoutGrade: balance.player.clampAttribute(
            ovr +
                rng.nextInt(
                  balance.seed.scoutGradeOffsetMax -
                      balance.seed.scoutGradeOffsetMin +
                      1,
                ) +
                balance.seed.scoutGradeOffsetMin,
          ),
          combineScore: balance.player.clampAttribute(
            ovr +
                rng.nextInt(
                  balance.seed.combineOffsetMax -
                      balance.seed.combineOffsetMin +
                      1,
                ) +
                balance.seed.combineOffsetMin,
          ),
          potentialStars: roundedStars,
          heightCm: _heightCmFor(pos, rng),
          injuryProne:
              balance.player.traitMin +
              rng.nextInt(
                balance.player.traitMax - balance.player.traitMin + 1,
              ),
          determination:
              balance.player.traitMin +
              rng.nextInt(
                balance.player.traitMax - balance.player.traitMin + 1,
              ),
        ),
      );
    }
    prospects.sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));
    return DraftClass(year: year, prospects: prospects);
  }
}
