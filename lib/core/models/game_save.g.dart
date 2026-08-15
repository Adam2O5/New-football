// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_save.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameSaveMetaImpl _$$GameSaveMetaImplFromJson(Map<String, dynamic> json) =>
    _$GameSaveMetaImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      seasonYear: (json['seasonYear'] as num).toInt(),
      phase: $enumDecode(_$SeasonPhaseEnumMap, json['phase']),
      playerTeamName: json['playerTeamName'] as String?,
    );

Map<String, dynamic> _$$GameSaveMetaImplToJson(_$GameSaveMetaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'seasonYear': instance.seasonYear,
      'phase': _$SeasonPhaseEnumMap[instance.phase]!,
      'playerTeamName': instance.playerTeamName,
    };

const _$SeasonPhaseEnumMap = {
  SeasonPhase.preseason: 'preseason',
  SeasonPhase.regular: 'regular',
  SeasonPhase.playIn: 'playIn',
  SeasonPhase.playoff: 'playoff',
  SeasonPhase.offseason: 'offseason',
};

_$GameSaveImpl _$$GameSaveImplFromJson(Map<String, dynamic> json) =>
    _$GameSaveImpl(
      meta: GameSaveMeta.fromJson(json['meta'] as Map<String, dynamic>),
      leagueState: LeagueState.fromJson(
        json['leagueState'] as Map<String, dynamic>,
      ),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$GameSaveImplToJson(_$GameSaveImpl instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'leagueState': instance.leagueState,
      'schemaVersion': instance.schemaVersion,
    };
