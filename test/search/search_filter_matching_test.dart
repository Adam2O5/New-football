import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/services/search_filter_matching.dart';

/// A fully-matching default player: no filter dimension should reject it
/// when the corresponding filter is left unset.
PlayerFilterInput _player({
  String? teamId = 'team-1',
  Nationality nationality = Nationality.poland,
  Position position = Position.cm,
  AssignedRole optimalRole = const AssignedRole.cm(),
  double potentialStars = 3.0,
  int age = 25,
  double overall = 75.0,
  double salary = 5000000,
  int contractYearsRemaining = 2,
}) {
  return PlayerFilterInput(
    teamId: teamId,
    nationality: nationality,
    position: position,
    optimalRole: optimalRole,
    potentialStars: potentialStars,
    age: age,
    overall: overall,
    salary: salary,
    contractYearsRemaining: contractYearsRemaining,
  );
}

ProspectFilterInput _prospect({
  Nationality nationality = Nationality.poland,
  Position position = Position.cm,
  AssignedRole optimalRole = const AssignedRole.cm(),
  int age = 19,
  bool roleKnown = true,
  double? estimatedPotentialMin = 2.5,
  double? estimatedPotentialMax = 3.5,
  int? estimatedOvrMin = 65,
  int? estimatedOvrMax = 75,
  int? scoutingTier = 2,
}) {
  return ProspectFilterInput(
    nationality: nationality,
    position: position,
    optimalRole: optimalRole,
    age: age,
    roleKnown: roleKnown,
    estimatedPotentialMin: estimatedPotentialMin,
    estimatedPotentialMax: estimatedPotentialMax,
    estimatedOvrMin: estimatedOvrMin,
    estimatedOvrMax: estimatedOvrMax,
    scoutingTier: scoutingTier,
  );
}

PickFilterInput _pick({
  String teamId = 'team-1',
  String originalTeamId = 'team-1',
  int round = 1,
  int year = 2027,
}) {
  return PickFilterInput(
    teamId: teamId,
    originalTeamId: originalTeamId,
    round: round,
    year: year,
  );
}

void main() {
  group('rangesOverlap', () {
    test('both bounds unset always overlaps', () {
      expect(rangesOverlap(null, null, 10, 20), isTrue);
    });

    test('only min set: excludes when known range is entirely below it', () {
      expect(rangesOverlap(15, null, 10, 14), isFalse);
      expect(rangesOverlap(15, null, 10, 15), isTrue);
    });

    test('only max set: excludes when known range is entirely above it', () {
      expect(rangesOverlap(null, 15, 16, 20), isFalse);
      expect(rangesOverlap(null, 15, 15, 20), isTrue);
    });

    test('both bounds set: overlapping ranges match', () {
      expect(rangesOverlap(10, 20, 15, 25), isTrue);
      expect(rangesOverlap(10, 20, 0, 5), isFalse);
      expect(rangesOverlap(10, 20, 25, 30), isFalse);
    });

    test('touching at a single point counts as overlap', () {
      expect(rangesOverlap(10, 20, 20, 30), isTrue);
      expect(rangesOverlap(10, 20, 0, 10), isTrue);
    });
  });

  group('matchesPlayerFilters', () {
    test('default (unset) filter state matches any player', () {
      expect(
        matchesPlayerFilters(_player(), const PlayersFilterState()),
        isTrue,
      );
    });

    test('nationality filter', () {
      const f = PlayersFilterState(nationality: Nationality.brazil);
      expect(
        matchesPlayerFilters(_player(nationality: Nationality.brazil), f),
        isTrue,
      );
      expect(
        matchesPlayerFilters(_player(nationality: Nationality.poland), f),
        isFalse,
      );
    });

    test('position filter', () {
      const f = PlayersFilterState(position: Position.st);
      expect(matchesPlayerFilters(_player(position: Position.st), f), isTrue);
      expect(matchesPlayerFilters(_player(position: Position.cm), f), isFalse);
    });

    test('optimal role filter', () {
      const f = PlayersFilterState(optimalRole: AssignedRole.striker());
      expect(
        matchesPlayerFilters(
          _player(optimalRole: const AssignedRole.striker()),
          f,
        ),
        isTrue,
      );
      expect(
        matchesPlayerFilters(
          _player(
            optimalRole: const AssignedRole.striker(
              role: StrikerRole.falseNine,
            ),
          ),
          f,
        ),
        isFalse,
      );
      expect(
        matchesPlayerFilters(_player(optimalRole: const AssignedRole.cm()), f),
        isFalse,
      );
    });

    test('potential range filter', () {
      const f = PlayersFilterState(potential: RangeFilter(min: 3, max: 4));
      expect(matchesPlayerFilters(_player(potentialStars: 3.5), f), isTrue);
      expect(matchesPlayerFilters(_player(potentialStars: 3), f), isTrue);
      expect(matchesPlayerFilters(_player(potentialStars: 4), f), isTrue);
      expect(matchesPlayerFilters(_player(potentialStars: 2.5), f), isFalse);
      expect(matchesPlayerFilters(_player(potentialStars: 4.5), f), isFalse);
    });

    test('regression: potential is rounded to the nearest half-star before '
        'comparing, so raw floating-point noise around a whole/half value '
        "doesn't fall just outside the filter", () {
      const f = PlayersFilterState(potential: RangeFilter(min: 4, max: 4));
      expect(matchesPlayerFilters(_player(potentialStars: 4.24), f), isTrue);
      expect(matchesPlayerFilters(_player(potentialStars: 3.76), f), isTrue);
      expect(matchesPlayerFilters(_player(potentialStars: 3.74), f), isFalse);
      expect(matchesPlayerFilters(_player(potentialStars: 4.26), f), isFalse);
    });

    test('age range filter', () {
      const f = PlayersFilterState(age: RangeFilter(min: 20, max: 30));
      expect(matchesPlayerFilters(_player(age: 20), f), isTrue);
      expect(matchesPlayerFilters(_player(age: 30), f), isTrue);
      expect(matchesPlayerFilters(_player(age: 19), f), isFalse);
      expect(matchesPlayerFilters(_player(age: 31), f), isFalse);
    });

    test('ovr range filter', () {
      const f = PlayersFilterState(ovr: RangeFilter(min: 70, max: 90));
      expect(matchesPlayerFilters(_player(overall: 70), f), isTrue);
      expect(matchesPlayerFilters(_player(overall: 90), f), isTrue);
      // .4 rounds down / .6 rounds up, so these land just outside the range
      // even after rounding to the nearest whole point.
      expect(matchesPlayerFilters(_player(overall: 69.4), f), isFalse);
      expect(matchesPlayerFilters(_player(overall: 90.6), f), isFalse);
    });

    test(
      'regression: a fractional overall matching the displayed (rounded) OVR '
      'is included, even right at the filter boundary — reported as '
      '"OVR 86-86 only found one of two 86-OVR players"',
      () {
        const f = PlayersFilterState(ovr: RangeFilter(min: 86, max: 86));
        // Displays as "86 OVR" but the raw value is just past 86 — must
        // still match an "86-86" filter.
        expect(matchesPlayerFilters(_player(overall: 86.4), f), isTrue);
        // Displays as "87 OVR" — must not match.
        expect(matchesPlayerFilters(_player(overall: 86.6), f), isFalse);
      },
    );

    test('salary range filter', () {
      const f = PlayersFilterState(
        salary: RangeFilter(min: 1000000, max: 10000000),
      );
      expect(matchesPlayerFilters(_player(salary: 5000000), f), isTrue);
      expect(matchesPlayerFilters(_player(salary: 999999), f), isFalse);
      expect(matchesPlayerFilters(_player(salary: 10000001), f), isFalse);
    });

    test('contract length range filter', () {
      const f = PlayersFilterState(contractLength: RangeFilter(min: 1, max: 3));
      expect(
        matchesPlayerFilters(_player(contractYearsRemaining: 1), f),
        isTrue,
      );
      expect(
        matchesPlayerFilters(_player(contractYearsRemaining: 3), f),
        isTrue,
      );
      expect(
        matchesPlayerFilters(_player(contractYearsRemaining: 0), f),
        isFalse,
      );
      expect(
        matchesPlayerFilters(_player(contractYearsRemaining: 4), f),
        isFalse,
      );
    });

    group('club filter', () {
      test('empty selection means no restriction', () {
        const f = PlayersFilterState();
        expect(matchesPlayerFilters(_player(teamId: 'team-1'), f), isTrue);
        expect(matchesPlayerFilters(_player(teamId: null), f), isTrue);
      });

      test('matches a selected team, rejects others', () {
        const f = PlayersFilterState(clubIds: {'team-1'});
        expect(matchesPlayerFilters(_player(teamId: 'team-1'), f), isTrue);
        expect(matchesPlayerFilters(_player(teamId: 'team-2'), f), isFalse);
      });

      test('noClubSentinel selects free agents specifically', () {
        final f = PlayersFilterState(
          clubIds: {PlayersFilterState.noClubSentinel},
        );
        expect(matchesPlayerFilters(_player(teamId: null), f), isTrue);
        expect(matchesPlayerFilters(_player(teamId: 'team-1'), f), isFalse);
      });

      test('a team + noClubSentinel selection includes both', () {
        final f = PlayersFilterState(
          clubIds: {'team-1', PlayersFilterState.noClubSentinel},
        );
        expect(matchesPlayerFilters(_player(teamId: 'team-1'), f), isTrue);
        expect(matchesPlayerFilters(_player(teamId: null), f), isTrue);
        expect(matchesPlayerFilters(_player(teamId: 'team-2'), f), isFalse);
      });
    });

    test('every filter dimension must pass simultaneously', () {
      const f = PlayersFilterState(
        nationality: Nationality.brazil,
        position: Position.st,
        age: RangeFilter(min: 20, max: 25),
      );
      final almost = _player(
        nationality: Nationality.brazil,
        position: Position.st,
        age: 30,
      );
      expect(matchesPlayerFilters(almost, f), isFalse);
      final full = _player(
        nationality: Nationality.brazil,
        position: Position.st,
        age: 22,
      );
      expect(matchesPlayerFilters(full, f), isTrue);
    });
  });

  group('matchesProspectFilters', () {
    test('default (unset) filter state matches any prospect', () {
      expect(
        matchesProspectFilters(_prospect(), const ProspectsFilterState()),
        isTrue,
      );
    });

    test('nationality filter', () {
      const f = ProspectsFilterState(nationality: Nationality.brazil);
      expect(
        matchesProspectFilters(_prospect(nationality: Nationality.brazil), f),
        isTrue,
      );
      expect(
        matchesProspectFilters(_prospect(nationality: Nationality.poland), f),
        isFalse,
      );
    });

    test('position filter', () {
      const f = ProspectsFilterState(position: Position.st);
      expect(
        matchesProspectFilters(_prospect(position: Position.st), f),
        isTrue,
      );
      expect(
        matchesProspectFilters(_prospect(position: Position.cm), f),
        isFalse,
      );
    });

    group('optimal role filter', () {
      const f = ProspectsFilterState(optimalRole: AssignedRole.striker());

      test('matches only when role is known and equal', () {
        expect(
          matchesProspectFilters(
            _prospect(
              optimalRole: const AssignedRole.striker(),
              roleKnown: true,
            ),
            f,
          ),
          isTrue,
        );
      });

      test('rejects when role matches but is not yet revealed', () {
        expect(
          matchesProspectFilters(
            _prospect(
              optimalRole: const AssignedRole.striker(),
              roleKnown: false,
            ),
            f,
          ),
          isFalse,
        );
      });

      test('rejects when role is known but does not match', () {
        expect(
          matchesProspectFilters(
            _prospect(optimalRole: const AssignedRole.cm(), roleKnown: true),
            f,
          ),
          isFalse,
        );
      });
    });

    group('potential range filter (scout-estimated)', () {
      const f = ProspectsFilterState(potential: RangeFilter(min: 3, max: 4));

      test('excludes prospects the scout has not evaluated', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedPotentialMin: null, estimatedPotentialMax: null),
            f,
          ),
          isFalse,
        );
      });

      test('matches when the estimated range overlaps the filter', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedPotentialMin: 3.5, estimatedPotentialMax: 4.5),
            f,
          ),
          isTrue,
        );
      });

      test('rejects when the estimated range does not overlap the filter', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedPotentialMin: 0.5, estimatedPotentialMax: 1.5),
            f,
          ),
          isFalse,
        );
      });
    });

    test('age range filter', () {
      const f = ProspectsFilterState(age: RangeFilter(min: 18, max: 21));
      expect(matchesProspectFilters(_prospect(age: 18), f), isTrue);
      expect(matchesProspectFilters(_prospect(age: 21), f), isTrue);
      expect(matchesProspectFilters(_prospect(age: 17), f), isFalse);
      expect(matchesProspectFilters(_prospect(age: 22), f), isFalse);
    });

    group('ovr range filter (scout-estimated)', () {
      const f = ProspectsFilterState(ovr: RangeFilter(min: 70, max: 80));

      test('excludes prospects with no scouted ovr range', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedOvrMin: null, estimatedOvrMax: null),
            f,
          ),
          isFalse,
        );
      });

      test('matches on any overlap with the estimated range', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedOvrMin: 78, estimatedOvrMax: 85),
            f,
          ),
          isTrue,
        );
      });

      test('rejects a disjoint estimated range', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedOvrMin: 50, estimatedOvrMax: 60),
            f,
          ),
          isFalse,
        );
      });
    });

    group('scouting tier filter', () {
      test('empty selection means no restriction, even if unscouted', () {
        const f = ProspectsFilterState();
        expect(
          matchesProspectFilters(_prospect(scoutingTier: null), f),
          isTrue,
        );
      });

      test('excludes unscouted prospects once a tier is selected', () {
        const f = ProspectsFilterState(scoutingTiers: {1, 2});
        expect(
          matchesProspectFilters(_prospect(scoutingTier: null), f),
          isFalse,
        );
      });

      test('matches a selected tier, rejects others', () {
        const f = ProspectsFilterState(scoutingTiers: {1, 2});
        expect(matchesProspectFilters(_prospect(scoutingTier: 2), f), isTrue);
        expect(matchesProspectFilters(_prospect(scoutingTier: 4), f), isFalse);
      });
    });
  });

  group('matchesPickFilters', () {
    test('default (unset) filter state matches any pick', () {
      expect(matchesPickFilters(_pick(), const PicksFilterState()), isTrue);
    });

    test('owning club filter', () {
      const f = PicksFilterState(clubIds: {'team-1'});
      expect(matchesPickFilters(_pick(teamId: 'team-1'), f), isTrue);
      expect(matchesPickFilters(_pick(teamId: 'team-2'), f), isFalse);
    });

    test('original club filter', () {
      const f = PicksFilterState(originalClubIds: {'team-9'});
      expect(matchesPickFilters(_pick(originalTeamId: 'team-9'), f), isTrue);
      expect(matchesPickFilters(_pick(originalTeamId: 'team-1'), f), isFalse);
    });

    test('round filter', () {
      const f = PicksFilterState(rounds: {1, 2});
      expect(matchesPickFilters(_pick(round: 1), f), isTrue);
      expect(matchesPickFilters(_pick(round: 2), f), isTrue);
      expect(matchesPickFilters(_pick(round: 3), f), isFalse);
    });

    test('year range filter', () {
      const f = PicksFilterState(year: RangeFilter(min: 2026, max: 2028));
      expect(matchesPickFilters(_pick(year: 2026), f), isTrue);
      expect(matchesPickFilters(_pick(year: 2028), f), isTrue);
      expect(matchesPickFilters(_pick(year: 2025), f), isFalse);
      expect(matchesPickFilters(_pick(year: 2029), f), isFalse);
    });

    test('owning club and original club filters combine independently', () {
      const f = PicksFilterState(
        clubIds: {'team-1'},
        originalClubIds: {'team-9'},
      );
      expect(
        matchesPickFilters(
          _pick(teamId: 'team-1', originalTeamId: 'team-9'),
          f,
        ),
        isTrue,
      );
      expect(
        matchesPickFilters(
          _pick(teamId: 'team-1', originalTeamId: 'team-2'),
          f,
        ),
        isFalse,
      );
    });
  });

  group('queryOrFiltersActive', () {
    test('non-empty query is always active, regardless of filters', () {
      expect(queryOrFiltersActive('messi', const SearchFiltersState()), isTrue);
    });

    test('empty query with all-default filters is inactive', () {
      expect(queryOrFiltersActive('', const SearchFiltersState()), isFalse);
    });

    test('empty query becomes active for every players-tab filter', () {
      const base = SearchFiltersState();
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            players: const PlayersFilterState(nationality: Nationality.brazil),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            players: const PlayersFilterState(position: Position.st),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            players: const PlayersFilterState(
              optimalRole: AssignedRole.striker(),
            ),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            players: const PlayersFilterState(potential: RangeFilter(min: 1)),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            players: const PlayersFilterState(age: RangeFilter(min: 1)),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            players: const PlayersFilterState(ovr: RangeFilter(min: 1)),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            players: const PlayersFilterState(salary: RangeFilter(min: 1)),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            players: const PlayersFilterState(
              contractLength: RangeFilter(min: 1),
            ),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(players: const PlayersFilterState(clubIds: {'team-1'})),
        ),
        isTrue,
      );
    });

    test('empty query becomes active for every prospects-tab filter', () {
      const base = SearchFiltersState();
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            prospects: const ProspectsFilterState(
              nationality: Nationality.brazil,
            ),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            prospects: const ProspectsFilterState(position: Position.st),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            prospects: const ProspectsFilterState(
              optimalRole: AssignedRole.striker(),
            ),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            prospects: const ProspectsFilterState(
              potential: RangeFilter(min: 1),
            ),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            prospects: const ProspectsFilterState(age: RangeFilter(min: 1)),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            prospects: const ProspectsFilterState(ovr: RangeFilter(min: 1)),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            prospects: const ProspectsFilterState(scoutingTiers: {1}),
          ),
        ),
        isTrue,
      );
    });

    test('empty query becomes active for every picks-tab filter', () {
      const base = SearchFiltersState();
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(picks: const PicksFilterState(clubIds: {'team-1'})),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            picks: const PicksFilterState(originalClubIds: {'team-1'}),
          ),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(picks: const PicksFilterState(rounds: {1})),
        ),
        isTrue,
      );
      expect(
        queryOrFiltersActive(
          '',
          base.copyWith(
            picks: const PicksFilterState(year: RangeFilter(min: 1)),
          ),
        ),
        isTrue,
      );
    });
  });

  group('yearSliderBounds', () {
    test(
      'falls back to fallbackYear..fallbackYear+3 when there are no picks',
      () {
        final bounds = yearSliderBounds(const [], fallbackYear: 2027);
        expect(bounds.min, 2027);
        expect(bounds.max, 2030);
        expect(bounds.divisions, 3);
      },
    );

    test('every distinct year present spans exactly one whole-number step', () {
      final bounds = yearSliderBounds([2027, 2028, 2029], fallbackYear: 2000);
      expect(bounds.min, 2027);
      expect(bounds.max, 2029);
      expect(bounds.divisions, 2);
      expect((bounds.max - bounds.min) / bounds.divisions, 1.0);
    });

    test(
      'a single distinct year still yields a valid (non-zero-span) slider',
      () {
        final bounds = yearSliderBounds([2028, 2028, 2028], fallbackYear: 2000);
        expect(bounds.min, 2028);
        expect(bounds.max, greaterThan(bounds.min));
        expect(bounds.divisions, greaterThan(0));
      },
    );

    test('regression: filtering the single distinct year end-to-end matches '
        'that year and only that year — reproduces "pick year 2028-2028 '
        'matched nothing"', () {
      final bounds = yearSliderBounds([2028, 2028], fallbackYear: 2000);
      // What the UI does when both RangeSlider handles sit exactly on the
      // "2028" tick: the value IS 2028.0 (not 2028-plus-a-hair, which is
      // what the old epsilon-padded bounds produced).
      final f = PicksFilterState(
        year: RangeFilter(
          min: bounds.min.toDouble(),
          max: bounds.min.toDouble(),
        ),
      );
      expect(matchesPickFilters(_pick(year: 2028), f), isTrue);
      expect(matchesPickFilters(_pick(year: 2029), f), isFalse);
    });
  });
}
