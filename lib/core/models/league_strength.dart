import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'league_strength.freezed.dart';
part 'league_strength.g.dart';

/// Single team's entry in the league strength table (`team_management.md`).
@freezed
abstract class TeamStrengthEntry with _$TeamStrengthEntry {
  const factory TeamStrengthEntry({
    required String teamId,

    /// Avg overall of top 15 players (missing slots counted as 50).
    required double teamPower,

    /// Position 1–30 in the league power ranking (1 = strongest).
    required int expectedRank,

    /// Status tier derived from expectedRank.
    required TeamStatus teamStatus,
  }) = _TeamStrengthEntry;

  factory TeamStrengthEntry.fromJson(Map<String, dynamic> json) =>
      _$TeamStrengthEntryFromJson(json);
}

/// The full league strength table — one source of truth for teamStatus
/// and expectedRank across all 30 teams (`team_management.md`).
@freezed
abstract class LeagueStrengthTable with _$LeagueStrengthTable {
  const factory LeagueStrengthTable({
    /// Sorted descending by teamPower (index 0 = rank 1).
    required List<TeamStrengthEntry> entries,

    /// Week when this table was last calculated.
    required int lastCalculatedWeek,

    /// Day when this table was last calculated.
    @Default(1) int lastCalculatedDay,

    /// Season that owns this snapshot. Zero keeps legacy in-memory fixtures
    /// compatible and is treated as unknown by the recalculation guard.
    @Default(0) int seasonYear,
  }) = _LeagueStrengthTable;

  factory LeagueStrengthTable.fromJson(Map<String, dynamic> json) =>
      _$LeagueStrengthTableFromJson(json);
}

extension LeagueStrengthTableX on LeagueStrengthTable {
  /// Lookup entry by team ID. Returns null if not found.
  TeamStrengthEntry? entryFor(String teamId) {
    for (final e in entries) {
      if (e.teamId == teamId) return e;
    }
    return null;
  }

  /// TeamStatus for a given team. Falls back to `pretender` if not found.
  TeamStatus statusOf(String teamId) =>
      entryFor(teamId)?.teamStatus ?? TeamStatus.pretender;

  /// ExpectedRank (1–30) for a given team. Falls back to 15 if not found.
  int rankOf(String teamId) => entryFor(teamId)?.expectedRank ?? 15;
}
