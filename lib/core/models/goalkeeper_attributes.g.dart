// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goalkeeper_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoalkeeperAttributesImpl _$$GoalkeeperAttributesImplFromJson(
  Map<String, dynamic> json,
) => _$GoalkeeperAttributesImpl(
  diving: (json['diving'] as num).toInt(),
  handling: (json['handling'] as num).toInt(),
  kicking: (json['kicking'] as num).toInt(),
  reflexes: (json['reflexes'] as num).toInt(),
  speed: (json['speed'] as num).toInt(),
  positioning: (json['positioning'] as num).toInt(),
);

Map<String, dynamic> _$$GoalkeeperAttributesImplToJson(
  _$GoalkeeperAttributesImpl instance,
) => <String, dynamic>{
  'diving': instance.diving,
  'handling': instance.handling,
  'kicking': instance.kicking,
  'reflexes': instance.reflexes,
  'speed': instance.speed,
  'positioning': instance.positioning,
};
