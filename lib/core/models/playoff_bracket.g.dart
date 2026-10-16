// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playoff_bracket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayoffBracket _$PlayoffBracketFromJson(Map<String, dynamic> json) =>
    _PlayoffBracket(
      conference: $enumDecode(_$ConferenceEnumMap, json['conference']),
      quarterFinals:
          (json['quarterFinals'] as List<dynamic>?)
              ?.map((e) => PlayoffSeries.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      semiFinals:
          (json['semiFinals'] as List<dynamic>?)
              ?.map((e) => PlayoffSeries.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      conferenceFinal:
          (json['conferenceFinal'] as List<dynamic>?)
              ?.map((e) => PlayoffSeries.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      leagueFinal: json['leagueFinal'] == null
          ? null
          : PlayoffSeries.fromJson(json['leagueFinal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlayoffBracketToJson(_PlayoffBracket instance) =>
    <String, dynamic>{
      'conference': _$ConferenceEnumMap[instance.conference]!,
      'quarterFinals': instance.quarterFinals,
      'semiFinals': instance.semiFinals,
      'conferenceFinal': instance.conferenceFinal,
      'leagueFinal': instance.leagueFinal,
    };

const _$ConferenceEnumMap = {
  Conference.europe: 'europe',
  Conference.restOfTheWorld: 'restOfTheWorld',
};
