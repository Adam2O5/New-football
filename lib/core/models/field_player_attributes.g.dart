// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_player_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FieldPlayerAttributes _$FieldPlayerAttributesFromJson(
  Map<String, dynamic> json,
) => _FieldPlayerAttributes(
  pace: (json['pace'] as num).toInt(),
  shooting: (json['shooting'] as num).toInt(),
  passing: (json['passing'] as num).toInt(),
  dribbling: (json['dribbling'] as num).toInt(),
  defending: (json['defending'] as num).toInt(),
  physicality: (json['physicality'] as num).toInt(),
);

Map<String, dynamic> _$FieldPlayerAttributesToJson(
  _FieldPlayerAttributes instance,
) => <String, dynamic>{
  'pace': instance.pace,
  'shooting': instance.shooting,
  'passing': instance.passing,
  'dribbling': instance.dribbling,
  'defending': instance.defending,
  'physicality': instance.physicality,
};
