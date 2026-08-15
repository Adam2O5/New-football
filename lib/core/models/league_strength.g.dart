// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_strength.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamStrengthEntryImpl _$$TeamStrengthEntryImplFromJson(
  Map<String, dynamic> json,
) => _$TeamStrengthEntryImpl(
  teamId: json['teamId'] as String,
  teamPower: (json['teamPower'] as num).toDouble(),
  expectedRank: (json['expectedRank'] as num).toInt(),
  teamStatus: $enumDecode(_$TeamStatusEnumMap, json['teamStatus']),
);

Map<String, dynamic> _$$TeamStrengthEntryImplToJson(
  _$TeamStrengthEntryImpl instance,
) => <String, dynamic>{
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

_$LeagueStrengthTableImpl _$$LeagueStrengthTableImplFromJson(
  Map<String, dynamic> json,
) => _$LeagueStrengthTableImpl(
  entries: (json['entries'] as List<dynamic>)
      .map((e) => TeamStrengthEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastCalculatedWeek: (json['lastCalculatedWeek'] as num).toInt(),
  lastCalculatedDay: (json['lastCalculatedDay'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$$LeagueStrengthTableImplToJson(
  _$LeagueStrengthTableImpl instance,
) => <String, dynamic>{
  'entries': instance.entries,
  'lastCalculatedWeek': instance.lastCalculatedWeek,
  'lastCalculatedDay': instance.lastCalculatedDay,
};
