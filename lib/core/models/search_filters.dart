import 'assigned_role.dart';
import 'enums.dart';

bool _setEquals<T>(Set<T> a, Set<T> b) =>
    identical(a, b) || (a.length == b.length && b.containsAll(a));

/// Order-independent hash for a set's elements (XOR is commutative), since
/// `Set` has no defined iteration order to hash against.
int _unorderedHash(Iterable<Object?> items) =>
    items.fold(0, (acc, item) => acc ^ item.hashCode);

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayersFilterState &&
          other.nationality == nationality &&
          other.position == position &&
          other.optimalRole == optimalRole &&
          other.potential == potential &&
          other.age == age &&
          other.ovr == ovr &&
          other.salary == salary &&
          other.contractLength == contractLength &&
          _setEquals(other.clubIds, clubIds);

  @override
  int get hashCode => Object.hash(
    nationality,
    position,
    optimalRole,
    potential,
    age,
    ovr,
    salary,
    contractLength,
    _unorderedHash(clubIds),
  );
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProspectsFilterState &&
          other.nationality == nationality &&
          other.position == position &&
          other.optimalRole == optimalRole &&
          other.potential == potential &&
          other.age == age &&
          other.ovr == ovr &&
          _setEquals(other.scoutingTiers, scoutingTiers);

  @override
  int get hashCode => Object.hash(
    nationality,
    position,
    optimalRole,
    potential,
    age,
    ovr,
    _unorderedHash(scoutingTiers),
  );
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PicksFilterState &&
          _setEquals(other.clubIds, clubIds) &&
          _setEquals(other.originalClubIds, originalClubIds) &&
          _setEquals(other.rounds, rounds) &&
          other.year == year;

  @override
  int get hashCode => Object.hash(
    _unorderedHash(clubIds),
    _unorderedHash(originalClubIds),
    _unorderedHash(rounds),
    year,
  );
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFiltersState &&
          _setEquals(other.groups, groups) &&
          other.players == players &&
          other.prospects == prospects &&
          other.picks == picks;

  @override
  int get hashCode =>
      Object.hash(_unorderedHash(groups), players, prospects, picks);
}
