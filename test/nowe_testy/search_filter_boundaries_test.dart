import 'dart:collection';

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/search_filters_provider.dart' as app;
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/search_filters.dart';
import 'package:new_football/core/services/search_filter_matching.dart';

void main() {
  test(
    'filter exports, inclusive ranges and nullable copy semantics stay stable',
    () {
      expect(const app.SearchFiltersState(), const SearchFiltersState());
      const range = RangeFilter(min: 18, max: 25);
      expect([17.9, 18.0, 25.0, 25.1].map(range.matches), [
        false,
        true,
        true,
        false,
      ]);
      expect(range.copyWith(min: null), range);
      const player = PlayersFilterState(nationality: Nationality.poland);
      expect(player.copyWith(nationality: () => null).nationality, isNull);
      expect(const RangeFilter().matches(-100), isTrue);
    },
  );

  test(
    'all filter sets preserve order-independent equality and hash codes',
    () {
      const pairs = <(Object, Object)>[
        (
          PlayersFilterState(clubIds: {'a', 'b'}),
          PlayersFilterState(clubIds: {'b', 'a'}),
        ),
        (
          ProspectsFilterState(scoutingTiers: {1, 3}),
          ProspectsFilterState(scoutingTiers: {3, 1}),
        ),
        (
          PicksFilterState(
            clubIds: {'a', 'b'},
            originalClubIds: {'c', 'd'},
            rounds: {1, 2},
          ),
          PicksFilterState(
            clubIds: {'b', 'a'},
            originalClubIds: {'d', 'c'},
            rounds: {2, 1},
          ),
        ),
        (
          SearchFiltersState(groups: {SearchGroup.players, SearchGroup.picks}),
          SearchFiltersState(groups: {SearchGroup.picks, SearchGroup.players}),
        ),
      ];
      for (final (a, b) in pairs) {
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      }
      final custom = SplayTreeSet<String>(
        (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
      )..add('a');
      final ordinary = {'A'};
      for (final (a, b) in [(custom, ordinary), (ordinary, custom)]) {
        expect(
          PlayersFilterState(clubIds: a) == PlayersFilterState(clubIds: b),
          setEquals(b, a),
        );
      }
      expect(
        const PlayersFilterState(clubIds: {'a'}),
        isNot(const PlayersFilterState(clubIds: {'b'})),
      );
      expect(
        const PicksFilterState(rounds: {1}),
        isNot(const PicksFilterState(rounds: {2})),
      );
    },
  );

  test(
    'player display rounding and free-agent club selection are unchanged',
    () {
      const player = PlayerFilterInput(
        teamId: null,
        nationality: Nationality.poland,
        position: Position.st,
        optimalRole: AssignedRole.striker(),
        potentialStars: 3.76,
        age: 20,
        overall: 86.4,
        salary: 100,
        contractYearsRemaining: 2,
      );
      const filters = PlayersFilterState(
        position: Position.st,
        potential: RangeFilter(min: 4, max: 4),
        ovr: RangeFilter(min: 86, max: 86),
        age: RangeFilter(min: 20, max: 20),
        salary: RangeFilter(max: 100),
        contractLength: RangeFilter(min: 2),
        clubIds: {PlayersFilterState.noClubSentinel},
      );
      expect(matchesPlayerFilters(player, filters), isTrue);
      expect(
        matchesPlayerFilters(player, filters.copyWith(clubIds: {'team'})),
        isFalse,
      );
      expect(
        matchesPlayerFilters(
          player,
          filters.copyWith(age: const RangeFilter(min: 21)),
        ),
        isFalse,
      );
    },
  );

  test(
    'prospect unknowns and overlap, picks and active-query detection stay stable',
    () {
      const prospect = ProspectFilterInput(
        nationality: Nationality.poland,
        position: Position.st,
        optimalRole: AssignedRole.striker(),
        age: 18,
        roleKnown: false,
        estimatedPotentialMin: 3,
        estimatedPotentialMax: 4,
        estimatedOvrMin: 70,
        estimatedOvrMax: 80,
        scoutingTier: 2,
      );
      expect(
        matchesProspectFilters(
          prospect,
          const ProspectsFilterState(
            potential: RangeFilter(min: 4),
            ovr: RangeFilter(max: 70),
            scoutingTiers: {2},
          ),
        ),
        isTrue,
      );
      expect(
        matchesProspectFilters(
          prospect,
          const ProspectsFilterState(optimalRole: AssignedRole.striker()),
        ),
        isFalse,
      );
      expect(
        matchesProspectFilters(
          prospect,
          const ProspectsFilterState(potential: RangeFilter(min: 4.5)),
        ),
        isFalse,
      );
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
    },
  );

  test(
    'Riverpod filters retain state within a save and isolate family keys',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final first = app.searchFiltersProvider(123);
      final second = app.searchFiltersProvider(456);
      container
          .read(first.notifier)
          .updatePlayers(const PlayersFilterState(position: Position.st));
      expect(container.read(first).players.position, Position.st);
      expect(container.read(second), const SearchFiltersState());
      container.read(first.notifier).setGroups({});
      expect(container.read(first).groups, const SearchFiltersState().groups);
      container.read(first.notifier).resetAll();
      expect(container.read(first), const SearchFiltersState());
    },
  );
}
