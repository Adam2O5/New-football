// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamAiConfigImpl _$$TeamAiConfigImplFromJson(Map<String, dynamic> json) =>
    _$TeamAiConfigImpl(
      managerProfile:
          $enumDecodeNullable(
            _$ManagerProfileEnumMap,
            json['managerProfile'],
          ) ??
          ManagerProfile.balanced,
      aggressionLevel: (json['aggressionLevel'] as num?)?.toDouble() ?? 0.5,
      riskTolerance: (json['riskTolerance'] as num?)?.toDouble() ?? 0.5,
      playerPatternMemory:
          json['playerPatternMemory'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$TeamAiConfigImplToJson(_$TeamAiConfigImpl instance) =>
    <String, dynamic>{
      'managerProfile': _$ManagerProfileEnumMap[instance.managerProfile]!,
      'aggressionLevel': instance.aggressionLevel,
      'riskTolerance': instance.riskTolerance,
      'playerPatternMemory': instance.playerPatternMemory,
    };

const _$ManagerProfileEnumMap = {
  ManagerProfile.cautious: 'cautious',
  ManagerProfile.balanced: 'balanced',
  ManagerProfile.aggressive: 'aggressive',
};

_$TeamImpl _$$TeamImplFromJson(Map<String, dynamic> json) => _$TeamImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  city: json['city'] as String,
  conference: $enumDecode(_$ConferenceEnumMap, json['conference']),
  roster: (json['roster'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  finance: TeamFinance.fromJson(json['finance'] as Map<String, dynamic>),
  tactics: json['tactics'] == null
      ? const TacticsSetup()
      : TacticsSetup.fromJson(json['tactics'] as Map<String, dynamic>),
  lineupPlayerIds:
      (json['lineupPlayerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  benchPlayerIds:
      (json['benchPlayerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  atmosphere: (json['atmosphere'] as num?)?.toInt() ?? 50,
  chemistry: (json['chemistry'] as num?)?.toInt() ?? 50,
  staff: json['staff'] == null
      ? const TeamStaff()
      : TeamStaff.fromJson(json['staff'] as Map<String, dynamic>),
  scouting: json['scouting'] == null
      ? const TeamScouting()
      : TeamScouting.fromJson(json['scouting'] as Map<String, dynamic>),
  ai: json['ai'] == null
      ? null
      : TeamAiConfig.fromJson(json['ai'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$TeamImplToJson(_$TeamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'conference': _$ConferenceEnumMap[instance.conference]!,
      'roster': instance.roster,
      'finance': instance.finance,
      'tactics': instance.tactics,
      'lineupPlayerIds': instance.lineupPlayerIds,
      'benchPlayerIds': instance.benchPlayerIds,
      'atmosphere': instance.atmosphere,
      'chemistry': instance.chemistry,
      'staff': instance.staff,
      'scouting': instance.scouting,
      'ai': instance.ai,
    };

const _$ConferenceEnumMap = {Conference.east: 'east', Conference.west: 'west'};
