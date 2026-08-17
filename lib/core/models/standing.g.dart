// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Standing _$StandingFromJson(Map<String, dynamic> json) => _Standing(
  teamId: json['teamId'] as String,
  wins: (json['wins'] as num?)?.toInt() ?? 0,
  losses: (json['losses'] as num?)?.toInt() ?? 0,
  draws: (json['draws'] as num?)?.toInt() ?? 0,
  goalsFor: (json['goalsFor'] as num?)?.toInt() ?? 0,
  goalsAgainst: (json['goalsAgainst'] as num?)?.toInt() ?? 0,
  conferenceRank: (json['conferenceRank'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$StandingToJson(_Standing instance) => <String, dynamic>{
  'teamId': instance.teamId,
  'wins': instance.wins,
  'losses': instance.losses,
  'draws': instance.draws,
  'goalsFor': instance.goalsFor,
  'goalsAgainst': instance.goalsAgainst,
  'conferenceRank': instance.conferenceRank,
};

_ConferenceStandings _$ConferenceStandingsFromJson(Map<String, dynamic> json) =>
    _ConferenceStandings(
      conference: $enumDecode(_$ConferenceEnumMap, json['conference']),
      standings:
          (json['standings'] as List<dynamic>?)
              ?.map((e) => Standing.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ConferenceStandingsToJson(
  _ConferenceStandings instance,
) => <String, dynamic>{
  'conference': _$ConferenceEnumMap[instance.conference]!,
  'standings': instance.standings,
};

const _$ConferenceEnumMap = {
  Conference.europe: 'europe',
  Conference.restOfTheWorld: 'restOfTheWorld',
};
