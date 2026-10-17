import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/search_filters.dart';

export 'package:new_football/core/models/search_filters.dart';

class SearchFiltersNotifier extends Notifier<SearchFiltersState> {
  SearchFiltersNotifier(this.saveSeed);

  final int saveSeed;

  @override
  SearchFiltersState build() => const SearchFiltersState();

  void setGroups(Set<SearchGroup> groups) =>
      state = state.copyWith(groups: groups.isEmpty ? state.groups : groups);

  void updatePlayers(PlayersFilterState players) =>
      state = state.copyWith(players: players);

  void updateProspects(ProspectsFilterState prospects) =>
      state = state.copyWith(prospects: prospects);

  void updatePicks(PicksFilterState picks) =>
      state = state.copyWith(picks: picks);

  void resetAll() => state = const SearchFiltersState();
}

/// Filters live only in memory (cleared on app restart) and are scoped to
/// the active save: switching saves (a different `saveSeed`) starts from a
/// fresh, unset filter state. Deliberately NOT `autoDispose` — the person
/// can leave and return to search repeatedly within the same save and the
/// filters must still be there.
final searchFiltersProvider =
    NotifierProvider.family<SearchFiltersNotifier, SearchFiltersState, int>(
      SearchFiltersNotifier.new,
    );

/// Convenience accessor that derives the family key from the active save.
final activeSearchFiltersKeyProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(gameControllerProvider).value?.saveSeed ?? 0;
});
