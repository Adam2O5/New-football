// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_save.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameSaveMeta _$GameSaveMetaFromJson(Map<String, dynamic> json) =>
    _GameSaveMeta(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      seasonYear: (json['seasonYear'] as num).toInt(),
      phase: $enumDecode(_$SeasonPhaseEnumMap, json['phase']),
      playerTeamName: json['playerTeamName'] as String?,
      schemaVersion:
          (json['schemaVersion'] as num?)?.toInt() ?? SaveSchema.unknownVersion,
    );

Map<String, dynamic> _$GameSaveMetaToJson(_GameSaveMeta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'seasonYear': instance.seasonYear,
      'phase': _$SeasonPhaseEnumMap[instance.phase]!,
      'playerTeamName': instance.playerTeamName,
      'schemaVersion': instance.schemaVersion,
    };

const _$SeasonPhaseEnumMap = {
  SeasonPhase.preseason: 'preseason',
  SeasonPhase.regular: 'regular',
  SeasonPhase.playIn: 'playIn',
  SeasonPhase.playoff: 'playoff',
  SeasonPhase.offseason: 'offseason',
};

_GameSave _$GameSaveFromJson(Map<String, dynamic> json) => _GameSave(
  meta: GameSaveMeta.fromJson(json['meta'] as Map<String, dynamic>),
  leagueState: LeagueState.fromJson(
    json['leagueState'] as Map<String, dynamic>,
  ),
  saveSeed: (json['saveSeed'] as num).toInt(),
  schemaVersion:
      (json['schemaVersion'] as num?)?.toInt() ?? SaveSchema.unknownVersion,
);

Map<String, dynamic> _$GameSaveToJson(_GameSave instance) => <String, dynamic>{
  'meta': instance.meta,
  'leagueState': instance.leagueState,
  'saveSeed': instance.saveSeed,
  'schemaVersion': instance.schemaVersion,
};
