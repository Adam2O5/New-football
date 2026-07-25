// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OutfieldPlayerAttributesImpl _$$OutfieldPlayerAttributesImplFromJson(
  Map<String, dynamic> json,
) => _$OutfieldPlayerAttributesImpl(
  stats: FieldPlayerAttributes.fromJson(json['stats'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$OutfieldPlayerAttributesImplToJson(
  _$OutfieldPlayerAttributesImpl instance,
) => <String, dynamic>{'stats': instance.stats, 'type': instance.$type};

_$GoalkeeperPlayerAttributesImpl _$$GoalkeeperPlayerAttributesImplFromJson(
  Map<String, dynamic> json,
) => _$GoalkeeperPlayerAttributesImpl(
  stats: GoalkeeperAttributes.fromJson(json['stats'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$GoalkeeperPlayerAttributesImplToJson(
  _$GoalkeeperPlayerAttributesImpl instance,
) => <String, dynamic>{'stats': instance.stats, 'type': instance.$type};
