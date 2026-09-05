import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';

void main() {
  group('RangeFilter', () {
    test('is unset by default', () {
      const filter = RangeFilter();
      expect(filter.isSet, isFalse);
      expect(filter.min, isNull);
      expect(filter.max, isNull);
    });

    test('isSet is true when either bound is set', () {
      expect(const RangeFilter(min: 1).isSet, isTrue);
      expect(const RangeFilter(max: 1).isSet, isTrue);
      expect(const RangeFilter(min: 1, max: 2).isSet, isTrue);
    });

    test('matches everything when unset', () {
      const filter = RangeFilter();
      expect(filter.matches(-1000), isTrue);
      expect(filter.matches(0), isTrue);
      expect(filter.matches(1000), isTrue);
    });

    test('matches respects a min-only bound', () {
      const filter = RangeFilter(min: 10);
      expect(filter.matches(10), isTrue);
      expect(filter.matches(11), isTrue);
      expect(filter.matches(9.999), isFalse);
    });

    test('matches respects a max-only bound', () {
      const filter = RangeFilter(max: 10);
      expect(filter.matches(10), isTrue);
      expect(filter.matches(9), isTrue);
      expect(filter.matches(10.001), isFalse);
    });

    test('matches respects both bounds inclusively', () {
      const filter = RangeFilter(min: 10, max: 20);
      expect(filter.matches(10), isTrue);
      expect(filter.matches(20), isTrue);
      expect(filter.matches(15), isTrue);
      expect(filter.matches(9.999), isFalse);
      expect(filter.matches(20.001), isFalse);
    });

    test('copyWith overrides only the given bound', () {
      const filter = RangeFilter(min: 10, max: 20);
      expect(filter.copyWith(min: 5), const RangeFilter(min: 5, max: 20));
      expect(filter.copyWith(max: 25), const RangeFilter(min: 10, max: 25));
    });

    test('equality is value-based', () {
      expect(
        const RangeFilter(min: 1, max: 2),
        const RangeFilter(min: 1, max: 2),
      );
      expect(
        const RangeFilter(min: 1, max: 2).hashCode,
        const RangeFilter(min: 1, max: 2).hashCode,
      );
      expect(const RangeFilter(min: 1), isNot(const RangeFilter(min: 2)));
    });
  });

  group('PlayersFilterState.copyWith', () {
    test('defaults are all unset', () {
      const state = PlayersFilterState();
      expect(state.nationality, isNull);
      expect(state.position, isNull);
      expect(state.optimalRole, isNull);
      expect(state.potential.isSet, isFalse);
      expect(state.age.isSet, isFalse);
      expect(state.ovr.isSet, isFalse);
      expect(state.salary.isSet, isFalse);
      expect(state.contractLength.isSet, isFalse);
      expect(state.clubIds, isEmpty);
    });

    test('updates one field without touching the others', () {
      const state = PlayersFilterState(position: Position.st);
      final updated = state.copyWith(age: const RangeFilter(min: 20, max: 30));
      expect(updated.position, Position.st);
      expect(updated.age, const RangeFilter(min: 20, max: 30));
    });

    test('the nullable-setter pattern can clear a previously set value', () {
      const state = PlayersFilterState(nationality: Nationality.brazil);
      final cleared = state.copyWith(nationality: () => null);
      expect(cleared.nationality, isNull);
    });

    test('omitting the setter leaves the current value untouched', () {
      const state = PlayersFilterState(nationality: Nationality.brazil);
      final updated = state.copyWith(position: () => Position.st);
      expect(updated.nationality, Nationality.brazil);
      expect(updated.position, Position.st);
    });
  });

  group('ProspectsFilterState.copyWith', () {
    test('defaults are all unset', () {
      const state = ProspectsFilterState();
      expect(state.nationality, isNull);
      expect(state.position, isNull);
      expect(state.optimalRole, isNull);
      expect(state.potential.isSet, isFalse);
      expect(state.age.isSet, isFalse);
      expect(state.ovr.isSet, isFalse);
      expect(state.scoutingTiers, isEmpty);
    });

    test('updates one field without touching the others', () {
      const state = ProspectsFilterState(scoutingTiers: {1, 2});
      final updated = state.copyWith(
        optimalRole: () => const AssignedRole.striker(),
      );
      expect(updated.scoutingTiers, {1, 2});
      expect(updated.optimalRole, const AssignedRole.striker());
    });

    test('the nullable-setter pattern can clear optimalRole', () {
      const state = ProspectsFilterState(optimalRole: AssignedRole.striker());
      final cleared = state.copyWith(optimalRole: () => null);
      expect(cleared.optimalRole, isNull);
    });
  });

  group('PicksFilterState.copyWith', () {
    test('defaults are all unset', () {
      const state = PicksFilterState();
      expect(state.clubIds, isEmpty);
      expect(state.originalClubIds, isEmpty);
      expect(state.rounds, isEmpty);
      expect(state.year.isSet, isFalse);
    });

    test('updates one field without touching the others', () {
      const state = PicksFilterState(clubIds: {'team-1'});
      final updated = state.copyWith(rounds: {1, 2});
      expect(updated.clubIds, {'team-1'});
      expect(updated.rounds, {1, 2});
    });
  });

  group('SearchFiltersState defaults', () {
    test('all three groups are selected by default', () {
      const state = SearchFiltersState();
      expect(state.groups, {
        SearchGroup.players,
        SearchGroup.prospects,
        SearchGroup.picks,
      });
    });

    test('copyWith replaces only the given sub-state', () {
      const state = SearchFiltersState();
      final updated = state.copyWith(
        players: const PlayersFilterState(position: Position.st),
      );
      expect(updated.players.position, Position.st);
      expect(updated.prospects, const ProspectsFilterState());
      expect(updated.picks, const PicksFilterState());
      expect(updated.groups, state.groups);
    });
  });

  group('SearchFiltersNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('starts from the default state for a fresh save key', () {
      final state = container.read(searchFiltersProvider(1));
      expect(state, const SearchFiltersState());
    });

    test('setGroups replaces the visible groups', () {
      final notifier = container.read(searchFiltersProvider(1).notifier);
      notifier.setGroups({SearchGroup.players});
      expect(container.read(searchFiltersProvider(1)).groups, {
        SearchGroup.players,
      });
    });

    test(
      'setGroups ignores an empty set (at least one group stays selected)',
      () {
        final notifier = container.read(searchFiltersProvider(1).notifier);
        notifier.setGroups({SearchGroup.picks});
        notifier.setGroups({});
        expect(container.read(searchFiltersProvider(1)).groups, {
          SearchGroup.picks,
        });
      },
    );

    test('updatePlayers replaces only the players sub-state', () {
      final notifier = container.read(searchFiltersProvider(1).notifier);
      notifier.updatePlayers(const PlayersFilterState(position: Position.st));
      final state = container.read(searchFiltersProvider(1));
      expect(state.players.position, Position.st);
      expect(state.prospects, const ProspectsFilterState());
      expect(state.picks, const PicksFilterState());
    });

    test('updateProspects replaces only the prospects sub-state', () {
      final notifier = container.read(searchFiltersProvider(1).notifier);
      notifier.updateProspects(const ProspectsFilterState(scoutingTiers: {1}));
      final state = container.read(searchFiltersProvider(1));
      expect(state.prospects.scoutingTiers, {1});
      expect(state.players, const PlayersFilterState());
    });

    test('updatePicks replaces only the picks sub-state', () {
      final notifier = container.read(searchFiltersProvider(1).notifier);
      notifier.updatePicks(const PicksFilterState(rounds: {1}));
      final state = container.read(searchFiltersProvider(1));
      expect(state.picks.rounds, {1});
      expect(state.players, const PlayersFilterState());
    });

    test('resetAll restores every default', () {
      final notifier = container.read(searchFiltersProvider(1).notifier);
      notifier.setGroups({SearchGroup.picks});
      notifier.updatePlayers(const PlayersFilterState(position: Position.st));
      notifier.updatePicks(const PicksFilterState(rounds: {1}));

      notifier.resetAll();

      expect(
        container.read(searchFiltersProvider(1)),
        const SearchFiltersState(),
      );
    });

    test('different save keys hold independent state', () {
      final notifierA = container.read(searchFiltersProvider(1).notifier);
      notifierA.updatePlayers(const PlayersFilterState(position: Position.st));

      final stateA = container.read(searchFiltersProvider(1));
      final stateB = container.read(searchFiltersProvider(2));

      expect(stateA.players.position, Position.st);
      expect(stateB.players.position, isNull);
    });
  });
}
