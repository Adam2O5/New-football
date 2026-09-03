import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';

/// Which of the three record groups are currently shown in search results
/// and in the filters sub-screen's tab bar.
enum SearchGroup { players, prospects, picks }

/// An inclusive numeric range filter. `null` bounds mean "not set" (no
/// restriction on that side), matching the "restore defaults" contract:
/// defaults are unset values, not a pre-selected full range.
class RangeFilter {
  const RangeFilter({this.min, this.max});

  final double? min;
  final double? max;

  bool get isSet => min != null || max != null;

  bool matches(double value) {
    if (min != null && value < min!) return false;
    if (max != null && value > max!) return false;
    return true;
  }

  RangeFilter copyWith({double? min, double? max}) =>
      RangeFilter(min: min ?? this.min, max: max ?? this.max);

  @override
  bool operator ==(Object other) =>
      other is RangeFilter && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}

class PlayersFilterState {
  const PlayersFilterState({
    this.nationality,
    this.position,
    this.optimalRole,
    this.potential = const RangeFilter(),
    this.age = const RangeFilter(),
    this.ovr = const RangeFilter(),
    this.salary = const RangeFilter(),
    this.contractLength = const RangeFilter(),
    this.clubIds = const {},
  });

  final Nationality? nationality;
  final Position? position;
  final AssignedRole? optimalRole;
  final RangeFilter potential;
  final RangeFilter age;
  final RangeFilter ovr;
  final RangeFilter salary;
  final RangeFilter contractLength;

  /// Selected team ids. Contains [noClubSentinel] when free agents should be
  /// included. Empty set = no restriction (all clubs and free agents match).
  final Set<String> clubIds;

  static const String noClubSentinel = '__no_club__';

  PlayersFilterState copyWith({
    Nationality? Function()? nationality,
    Position? Function()? position,
    AssignedRole? Function()? optimalRole,
    RangeFilter? potential,
    RangeFilter? age,
    RangeFilter? ovr,
    RangeFilter? salary,
    RangeFilter? contractLength,
    Set<String>? clubIds,
  }) {
    return PlayersFilterState(
      nationality: nationality != null ? nationality() : this.nationality,
      position: position != null ? position() : this.position,
      optimalRole: optimalRole != null ? optimalRole() : this.optimalRole,
      potential: potential ?? this.potential,
      age: age ?? this.age,
      ovr: ovr ?? this.ovr,
      salary: salary ?? this.salary,
      contractLength: contractLength ?? this.contractLength,
      clubIds: clubIds ?? this.clubIds,
    );
  }
}

class ProspectsFilterState {
  const ProspectsFilterState({
    this.nationality,
    this.position,
    this.optimalRole,
    this.potential = const RangeFilter(),
    this.age = const RangeFilter(),
    this.ovr = const RangeFilter(),
    this.scoutingTiers = const {},
  });

  final Nationality? nationality;
  final Position? position;
  final AssignedRole? optimalRole;
  final RangeFilter potential;
  final RangeFilter age;
  final RangeFilter ovr;

  /// Selected `ScoutingTier` indices (0-4, i.e. tier1-tier5). Empty = no
  /// restriction.
  final Set<int> scoutingTiers;

  ProspectsFilterState copyWith({
    Nationality? Function()? nationality,
    Position? Function()? position,
    AssignedRole? Function()? optimalRole,
    RangeFilter? potential,
    RangeFilter? age,
    RangeFilter? ovr,
    Set<int>? scoutingTiers,
  }) {
    return ProspectsFilterState(
      nationality: nationality != null ? nationality() : this.nationality,
      position: position != null ? position() : this.position,
      optimalRole: optimalRole != null ? optimalRole() : this.optimalRole,
      potential: potential ?? this.potential,
      age: age ?? this.age,
      ovr: ovr ?? this.ovr,
      scoutingTiers: scoutingTiers ?? this.scoutingTiers,
    );
  }
}

class PicksFilterState {
  const PicksFilterState({
    this.clubIds = const {},
    this.originalClubIds = const {},
    this.rounds = const {},
    this.year = const RangeFilter(),
  });

  final Set<String> clubIds;
  final Set<String> originalClubIds;

  /// Selected round numbers (1-3). Empty = no restriction.
  final Set<int> rounds;
  final RangeFilter year;

  PicksFilterState copyWith({
    Set<String>? clubIds,
    Set<String>? originalClubIds,
    Set<int>? rounds,
    RangeFilter? year,
  }) {
    return PicksFilterState(
      clubIds: clubIds ?? this.clubIds,
      originalClubIds: originalClubIds ?? this.originalClubIds,
      rounds: rounds ?? this.rounds,
      year: year ?? this.year,
    );
  }
}

class SearchFiltersState {
  const SearchFiltersState({
    this.groups = const {
      SearchGroup.players,
      SearchGroup.prospects,
      SearchGroup.picks,
    },
    this.players = const PlayersFilterState(),
    this.prospects = const ProspectsFilterState(),
    this.picks = const PicksFilterState(),
  });

  final Set<SearchGroup> groups;
  final PlayersFilterState players;
  final ProspectsFilterState prospects;
  final PicksFilterState picks;

  SearchFiltersState copyWith({
    Set<SearchGroup>? groups,
    PlayersFilterState? players,
    ProspectsFilterState? prospects,
    PicksFilterState? picks,
  }) {
    return SearchFiltersState(
      groups: groups ?? this.groups,
      players: players ?? this.players,
      prospects: prospects ?? this.prospects,
      picks: picks ?? this.picks,
    );
  }
}

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

/// Filters live only in memory and are scoped to the active save: switching
/// saves (a different `saveSeed`) starts from a fresh, unset filter state,
/// and `autoDispose` drops a save's filters once no screen is watching them.
final searchFiltersProvider = NotifierProvider.autoDispose
    .family<SearchFiltersNotifier, SearchFiltersState, int>(
      SearchFiltersNotifier.new,
    );

/// Convenience accessor that derives the family key from the active save.
final activeSearchFiltersKeyProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(gameControllerProvider).value?.saveSeed ?? 0;
});
