import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';

/// The subset of `Player` fields the search screen filters on, decoupled
/// from the full model so filter logic can be unit tested without
/// constructing a complete (freezed) `Player`/`Contract`.
class PlayerFilterInput {
  const PlayerFilterInput({
    required this.teamId,
    required this.nationality,
    required this.position,
    required this.optimalRole,
    required this.potentialStars,
    required this.age,
    required this.overall,
    required this.salary,
    required this.contractYearsRemaining,
  });

  /// `null` for free agents.
  final String? teamId;
  final Nationality nationality;
  final Position position;
  final AssignedRole optimalRole;
  final double potentialStars;
  final int age;
  final double overall;
  final double salary;
  final int contractYearsRemaining;
}

/// The subset of `Prospect` (+ scouting knowledge) fields the search screen
/// filters on. `estimated*`/`scoutingTier` are `null` when the scout hasn't
/// evaluated that attribute yet.
class ProspectFilterInput {
  const ProspectFilterInput({
    required this.nationality,
    required this.position,
    required this.optimalRole,
    required this.age,
    required this.roleKnown,
    this.estimatedPotentialMin,
    this.estimatedPotentialMax,
    this.estimatedOvrMin,
    this.estimatedOvrMax,
    this.scoutingTier,
  });

  final Nationality nationality;
  final Position position;
  final AssignedRole optimalRole;
  final int age;

  /// Whether the combine has revealed this prospect's optimal role (see
  /// `search_screen.dart`'s `combineAvailable`/`combineAssignedProspectIds`
  /// check). The optimal-role filter can only match when this is true.
  final bool roleKnown;
  final double? estimatedPotentialMin;
  final double? estimatedPotentialMax;
  final int? estimatedOvrMin;
  final int? estimatedOvrMax;

  /// `ScoutingTier.index` (0-4), or `null` if unscouted.
  final int? scoutingTier;
}

/// The subset of `DraftPick` fields the search screen filters on.
class PickFilterInput {
  const PickFilterInput({
    required this.teamId,
    required this.originalTeamId,
    required this.round,
    required this.year,
  });

  final String teamId;
  final String originalTeamId;
  final int round;
  final int year;
}

/// Whether `filterMin`-`filterMax` (either bound may be unset, meaning
/// unbounded on that side) overlaps the known `knownMin`-`knownMax` range.
bool rangesOverlap(
  double? filterMin,
  double? filterMax,
  double knownMin,
  double knownMax,
) {
  if (filterMin != null && knownMax < filterMin) return false;
  if (filterMax != null && knownMin > filterMax) return false;
  return true;
}

double _roundToHalf(double value) => (value * 2).round() / 2;

/// Integer slider bounds for the picks year range filter: `min`/`max` are
/// the whole years to show on the track and `divisions` is the number of
/// steps, chosen so every step lands exactly on a whole year.
///
/// A previous version padded `max` with a `+0.001` epsilon (to keep
/// `max > min` when every pick fell in one year) while computing
/// `divisions` from the un-padded span. That made the step size a hair over
/// 1.0, so a handle dragged to the position labelled "2028" actually held a
/// value like 2028.0005 — just high enough that a real 2028 pick failed the
/// `value >= min` check. Filtering "2028-2028" matched nothing, and
/// "2028-2029" silently dropped the lower bound. Keeping `max` and
/// `divisions` both whole numbers makes every step exact.
({int min, int max, int divisions}) yearSliderBounds(
  Iterable<int> years, {
  required int fallbackYear,
}) {
  if (years.isEmpty) {
    return (min: fallbackYear, max: fallbackYear + 3, divisions: 3);
  }
  final minYear = years.reduce((a, b) => a < b ? a : b);
  final rawMaxYear = years.reduce((a, b) => a > b ? a : b);
  final maxYear = rawMaxYear > minYear ? rawMaxYear : minYear + 1;
  return (min: minYear, max: maxYear, divisions: maxYear - minYear);
}

bool matchesPlayerFilters(PlayerFilterInput input, PlayersFilterState f) {
  if (f.nationality != null && input.nationality != f.nationality) {
    return false;
  }
  if (f.position != null && input.position != f.position) return false;
  if (f.optimalRole != null && input.optimalRole != f.optimalRole) {
    return false;
  }
  // `overall()`/`potentialStars` are raw doubles, but both are always shown
  // rounded (OVR to a whole number, potential to a half-star) and the OVR
  // slider only offers whole-number steps. Comparing the raw value against
  // an integer/half-step bound silently excludes anything whose displayed
  // value matches but whose exact value sits just past the bound (e.g. a
  // player showing "86 OVR" with a real overall of 86.4 was rejected by an
  // `86-86` filter). Round to the displayed unit first so the filter always
  // matches what's on screen.
  if (!f.potential.matches(_roundToHalf(input.potentialStars))) return false;
  if (!f.age.matches(input.age.toDouble())) return false;
  if (!f.ovr.matches(input.overall.roundToDouble())) return false;
  if (!f.salary.matches(input.salary)) return false;
  if (!f.contractLength.matches(input.contractYearsRemaining.toDouble())) {
    return false;
  }
  if (f.clubIds.isNotEmpty) {
    final key = input.teamId ?? PlayersFilterState.noClubSentinel;
    if (!f.clubIds.contains(key)) return false;
  }
  return true;
}

bool matchesProspectFilters(ProspectFilterInput input, ProspectsFilterState f) {
  if (f.nationality != null && input.nationality != f.nationality) {
    return false;
  }
  if (f.position != null && input.position != f.position) return false;
  if (f.optimalRole != null) {
    if (!input.roleKnown || input.optimalRole != f.optimalRole) return false;
  }
  if (f.potential.isSet) {
    final min = input.estimatedPotentialMin;
    final max = input.estimatedPotentialMax;
    if (min == null || max == null) return false;
    if (!rangesOverlap(f.potential.min, f.potential.max, min, max)) {
      return false;
    }
  }
  if (!f.age.matches(input.age.toDouble())) return false;
  if (f.ovr.isSet) {
    final min = input.estimatedOvrMin;
    final max = input.estimatedOvrMax;
    if (min == null || max == null) return false;
    if (!rangesOverlap(f.ovr.min, f.ovr.max, min.toDouble(), max.toDouble())) {
      return false;
    }
  }
  if (f.scoutingTiers.isNotEmpty) {
    final tier = input.scoutingTier;
    if (tier == null || !f.scoutingTiers.contains(tier)) return false;
  }
  return true;
}

bool matchesPickFilters(PickFilterInput input, PicksFilterState f) {
  if (f.clubIds.isNotEmpty && !f.clubIds.contains(input.teamId)) {
    return false;
  }
  if (f.originalClubIds.isNotEmpty &&
      !f.originalClubIds.contains(input.originalTeamId)) {
    return false;
  }
  if (f.rounds.isNotEmpty && !f.rounds.contains(input.round)) return false;
  if (!f.year.matches(input.year.toDouble())) return false;
  return true;
}

/// The search screen shows nothing for an empty query unless at least one
/// filter (in any tab) is active — otherwise opening the screen would dump
/// the entire league.
bool queryOrFiltersActive(String query, SearchFiltersState filters) {
  if (query.isNotEmpty) return true;
  final p = filters.players;
  final pr = filters.prospects;
  final pk = filters.picks;
  return p.nationality != null ||
      p.position != null ||
      p.optimalRole != null ||
      p.potential.isSet ||
      p.age.isSet ||
      p.ovr.isSet ||
      p.salary.isSet ||
      p.contractLength.isSet ||
      p.clubIds.isNotEmpty ||
      pr.nationality != null ||
      pr.position != null ||
      pr.optimalRole != null ||
      pr.potential.isSet ||
      pr.age.isSet ||
      pr.ovr.isSet ||
      pr.scoutingTiers.isNotEmpty ||
      pk.clubIds.isNotEmpty ||
      pk.originalClubIds.isNotEmpty ||
      pk.rounds.isNotEmpty ||
      pk.year.isSet;
}
