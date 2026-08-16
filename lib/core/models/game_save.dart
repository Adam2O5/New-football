import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';

part 'game_save.freezed.dart';
part 'game_save.g.dart';

@freezed
class GameSaveMeta with _$GameSaveMeta {
  const factory GameSaveMeta({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int seasonYear,
    required SeasonPhase phase,
    String? playerTeamName,
  }) = _GameSaveMeta;

  factory GameSaveMeta.fromJson(Map<String, dynamic> json) =>
      _$GameSaveMetaFromJson(json);
}

@freezed
class GameSave with _$GameSave {
  const factory GameSave({
    required GameSaveMeta meta,
    required LeagueState leagueState,
    required int saveSeed,
    @Default(2) int schemaVersion,
  }) = _GameSave;

  factory GameSave.fromJson(Map<String, dynamic> json) =>
      _$GameSaveFromJson(json);
}
