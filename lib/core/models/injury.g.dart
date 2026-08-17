// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injury.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Injury _$InjuryFromJson(Map<String, dynamic> json) => _Injury(
  id: json['id'] as String,
  group: $enumDecode(_$InjuryGroupEnumMap, json['group']),
  type: $enumDecode(_$InjuryTypeEnumMap, json['type']),
  daysTotal: (json['daysTotal'] as num).toInt(),
  daysRemaining: (json['daysRemaining'] as num).toInt(),
);

Map<String, dynamic> _$InjuryToJson(_Injury instance) => <String, dynamic>{
  'id': instance.id,
  'group': _$InjuryGroupEnumMap[instance.group]!,
  'type': _$InjuryTypeEnumMap[instance.type]!,
  'daysTotal': instance.daysTotal,
  'daysRemaining': instance.daysRemaining,
};

const _$InjuryGroupEnumMap = {
  InjuryGroup.headFace: 'headFace',
  InjuryGroup.shouldersChest: 'shouldersChest',
  InjuryGroup.legMuscles: 'legMuscles',
  InjuryGroup.knees: 'knees',
  InjuryGroup.anklesFeet: 'anklesFeet',
};

const _$InjuryTypeEnumMap = {
  InjuryType.minor: 'minor',
  InjuryType.major: 'major',
};
