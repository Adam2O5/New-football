import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/services/search_filter_matching.dart';

void main() {
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
}
