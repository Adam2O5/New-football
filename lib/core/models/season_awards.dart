import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'season_awards.freezed.dart';
part 'season_awards.g.dart';

@freezed
abstract class SeasonAwards with _$SeasonAwards {
  const factory SeasonAwards({
    required int year,
    String? mvpPlayerId,
    String? rotyPlayerId,
    String? dpoyPlayerId,
    String? topScorerPlayerId,
    String? topAssistPlayerId,
    String? bestGkPlayerId,
    @Default({}) Map<String, String> playerNames,
    String? coachOfYearTeamId,
    @Default({}) Map<TeamOfSeasonSlot, String> teamOfSeason,
    String? championTeamId,
  }) = _SeasonAwards;

  factory SeasonAwards.fromJson(Map<String, dynamic> json) =>
      _$SeasonAwardsFromJson(json);
}
