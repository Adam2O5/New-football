// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SeasonHistory _$SeasonHistoryFromJson(Map<String, dynamic> json) =>
    _SeasonHistory(
      year: (json['year'] as num).toInt(),
      finalStandings: (json['finalStandings'] as List<dynamic>)
          .map((e) => ConferenceStandings.fromJson(e as Map<String, dynamic>))
          .toList(),
      championTeamId: json['championTeamId'] as String?,
      draftPicks:
          (json['draftPicks'] as List<dynamic>?)
              ?.map((e) => DraftPick.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      awards: json['awards'] == null
          ? null
          : SeasonAwards.fromJson(json['awards'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SeasonHistoryToJson(_SeasonHistory instance) =>
    <String, dynamic>{
      'year': instance.year,
      'finalStandings': instance.finalStandings,
      'championTeamId': instance.championTeamId,
      'draftPicks': instance.draftPicks,
      'awards': instance.awards,
    };
