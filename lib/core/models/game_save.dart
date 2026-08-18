import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';

part 'game_save.freezed.dart';
part 'game_save.g.dart';

/// Versioning contract for persisted saves.
///
/// Any change to a serialized model must increase [currentVersion]. V1 does
/// not migrate old saves; it keeps them visible so the user can remove them.
abstract final class SaveSchema {
  static const unknownVersion = 0;
  static const currentVersion = 21;
}

enum SaveCompatibility { compatible, older, newer }

@freezed
abstract class GameSaveMeta with _$GameSaveMeta {
  const factory GameSaveMeta({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int seasonYear,
    required SeasonPhase phase,
    String? playerTeamName,
    @Default(SaveSchema.unknownVersion) int schemaVersion,
  }) = _GameSaveMeta;

  factory GameSaveMeta.fromJson(Map<String, dynamic> json) =>
      _$GameSaveMetaFromJson(json);
}

extension GameSaveMetaCompatibility on GameSaveMeta {
  SaveCompatibility compatibilityWith(int supportedVersion) {
    if (schemaVersion == supportedVersion) {
      return SaveCompatibility.compatible;
    }
    return schemaVersion < supportedVersion
        ? SaveCompatibility.older
        : SaveCompatibility.newer;
  }
}

@freezed
abstract class GameSave with _$GameSave {
  const factory GameSave({
    required GameSaveMeta meta,
    required LeagueState leagueState,
    required int saveSeed,
    @Default(SaveSchema.unknownVersion) int schemaVersion,
  }) = _GameSave;

  factory GameSave.fromJson(Map<String, dynamic> json) =>
      _$GameSaveFromJson(json);
}
