import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/season_awards.dart';

part 'season_history.freezed.dart';
part 'season_history.g.dart';

@freezed
abstract class SeasonHistory with _$SeasonHistory {
  const factory SeasonHistory({
    required int year,
    required List<ConferenceStandings> finalStandings,
    String? championTeamId,
    @Default([]) List<DraftPick> draftPicks,
    SeasonAwards? awards,
  }) = _SeasonHistory;

  factory SeasonHistory.fromJson(Map<String, dynamic> json) =>
      _$SeasonHistoryFromJson(json);
}
