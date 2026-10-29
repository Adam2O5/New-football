import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/core/services/search_filter_matching.dart';

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
  test('pick filter intersections and their active state agree', () {
    const pick = PickFilterInput(
      teamId: 'owner',
      originalTeamId: 'origin',
      round: 2,
      year: 2028,
    );
    const filter = PicksFilterState(
      clubIds: {'owner'},
      originalClubIds: {'origin'},
      rounds: {2},
      year: RangeFilter(min: 2028, max: 2028),
    );
    expect(matchesPickFilters(pick, filter), isTrue);
    expect(matchesPickFilters(pick, filter.copyWith(rounds: {1})), isFalse);
    expect(queryOrFiltersActive('', const SearchFiltersState()), isFalse);
    expect(
      queryOrFiltersActive('', const SearchFiltersState(picks: filter)),
      isTrue,
    );
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
