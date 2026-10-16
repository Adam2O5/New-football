import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/play_in_models.dart';
import 'package:new_football/core/models/playoff_bracket.dart';
import 'package:new_football/core/models/draft_state.dart';
import 'package:new_football/core/models/season_awards.dart';

part 'season.freezed.dart';
part 'season.g.dart';

@freezed
abstract class Season with _$Season {
  const factory Season({
    required int year,
    @Default(SeasonPhase.preseason) SeasonPhase phase,
    @Default([]) List<ScheduledMatch> schedule,
    @Default([]) List<ConferenceStandings> standings,
    @Default([]) List<PlayInResult> playInResults,
    @Default([]) List<PlayInProgress> playInProgress,
    @Default([]) List<PlayoffBracket> playoffBrackets,
    String? championTeamId,
    @Default(false) bool championshipAtmosphereApplied,
    @Default(false) bool playoffMissAtmosphereApplied,
    DraftState? draftState,
    SeasonAwards? awards,
    @Default(false) bool staffGrowthDone,
    @Default(false) bool playerRetirementsDone,

    /// Persisted TV agreement: the exact reset year and increase are known
    /// before the event fires, so loading a save cannot reroll the cap.
    @Default(0) int nextTvCapResetSeason,
    @Default(0) int nextTvCapIncreasePct,
    @Default(false) bool capUpdateTvDone,

    @Default(false) bool combineDone,
    @Default(false) bool finalMockDone,
    @Default(false) bool faOpenDone,
    @Default(false) bool scoutReportDone,
    @Default(false) bool tradeDeadlineAcked,
    @Default(false) bool nextClassGenerationDone,

    /// Play-in/playoff fixtures, populated eagerly as soon as each pairing
    /// is known (see `game_calendar.md`) — placeholders for a still-pending
    /// play-in seed, replaced with the real team once decided. This is the
    /// calendar's sole source for postseason match days, the same way
    /// `schedule` is for the regular season. `playInProgress`/`playInResults`
    /// /`playoffBrackets` remain the simulation source of truth; entries here
    /// are kept in lockstep with them but exist purely for display.
    @Default(<ScheduledMatch>[]) List<ScheduledMatch> postseasonFixtures,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}
