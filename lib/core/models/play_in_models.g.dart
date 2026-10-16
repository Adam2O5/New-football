// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_in_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayInResult _$PlayInResultFromJson(Map<String, dynamic> json) =>
    _PlayInResult(
      conference: $enumDecode(_$ConferenceEnumMap, json['conference']),
      seed7TeamId: json['seed7TeamId'] as String,
      seed8TeamId: json['seed8TeamId'] as String,
      game7v8: MatchResult.fromJson(json['game7v8'] as Map<String, dynamic>),
      game9v10: MatchResult.fromJson(json['game9v10'] as Map<String, dynamic>),
      gameFinal: MatchResult.fromJson(
        json['gameFinal'] as Map<String, dynamic>,
      ),
      playoffSeed7TeamId: json['playoffSeed7TeamId'] as String,
      playoffSeed8TeamId: json['playoffSeed8TeamId'] as String,
    );

Map<String, dynamic> _$PlayInResultToJson(_PlayInResult instance) =>
    <String, dynamic>{
      'conference': _$ConferenceEnumMap[instance.conference]!,
      'seed7TeamId': instance.seed7TeamId,
      'seed8TeamId': instance.seed8TeamId,
      'game7v8': instance.game7v8,
      'game9v10': instance.game9v10,
      'gameFinal': instance.gameFinal,
      'playoffSeed7TeamId': instance.playoffSeed7TeamId,
      'playoffSeed8TeamId': instance.playoffSeed8TeamId,
    };

const _$ConferenceEnumMap = {
  Conference.europe: 'europe',
  Conference.restOfTheWorld: 'restOfTheWorld',
};

_PlayInProgress _$PlayInProgressFromJson(Map<String, dynamic> json) =>
    _PlayInProgress(
      conference: $enumDecode(_$ConferenceEnumMap, json['conference']),
      seed7TeamId: json['seed7TeamId'] as String,
      seed8TeamId: json['seed8TeamId'] as String,
      seed9TeamId: json['seed9TeamId'] as String,
      seed10TeamId: json['seed10TeamId'] as String,
      game7v8: json['game7v8'] == null
          ? null
          : MatchResult.fromJson(json['game7v8'] as Map<String, dynamic>),
      game9v10: json['game9v10'] == null
          ? null
          : MatchResult.fromJson(json['game9v10'] as Map<String, dynamic>),
      gameFinal: json['gameFinal'] == null
          ? null
          : MatchResult.fromJson(json['gameFinal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlayInProgressToJson(_PlayInProgress instance) =>
    <String, dynamic>{
      'conference': _$ConferenceEnumMap[instance.conference]!,
      'seed7TeamId': instance.seed7TeamId,
      'seed8TeamId': instance.seed8TeamId,
      'seed9TeamId': instance.seed9TeamId,
      'seed10TeamId': instance.seed10TeamId,
      'game7v8': instance.game7v8,
      'game9v10': instance.game9v10,
      'gameFinal': instance.gameFinal,
    };
