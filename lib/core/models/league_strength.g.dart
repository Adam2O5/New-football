// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_strength.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamStrengthEntry _$TeamStrengthEntryFromJson(Map<String, dynamic> json) =>
    _TeamStrengthEntry(
      teamId: json['teamId'] as String,
      teamPower: (json['teamPower'] as num).toDouble(),
      expectedRank: (json['expectedRank'] as num).toInt(),
      teamStatus: $enumDecode(_$TeamStatusEnumMap, json['teamStatus']),
    );

Map<String, dynamic> _$TeamStrengthEntryToJson(_TeamStrengthEntry instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'teamPower': instance.teamPower,
      'expectedRank': instance.expectedRank,
      'teamStatus': _$TeamStatusEnumMap[instance.teamStatus]!,
    };

const _$TeamStatusEnumMap = {
  TeamStatus.rebuild: 'rebuild',
  TeamStatus.retool: 'retool',
  TeamStatus.pretender: 'pretender',
  TeamStatus.contender: 'contender',
  TeamStatus.elite: 'elite',
};

_LeagueStrengthTable _$LeagueStrengthTableFromJson(Map<String, dynamic> json) =>
    _LeagueStrengthTable(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => TeamStrengthEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastCalculatedWeek: (json['lastCalculatedWeek'] as num).toInt(),
      lastCalculatedDay: (json['lastCalculatedDay'] as num?)?.toInt() ?? 1,
      seasonYear: (json['seasonYear'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LeagueStrengthTableToJson(
  _LeagueStrengthTable instance,
) => <String, dynamic>{
  'entries': instance.entries,
  'lastCalculatedWeek': instance.lastCalculatedWeek,
  'lastCalculatedDay': instance.lastCalculatedDay,
  'seasonYear': instance.seasonYear,
};
