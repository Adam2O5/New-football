// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutfieldPlayerAttributes _$OutfieldPlayerAttributesFromJson(
  Map<String, dynamic> json,
) => OutfieldPlayerAttributes(
  stats: FieldPlayerAttributes.fromJson(json['stats'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$OutfieldPlayerAttributesToJson(
  OutfieldPlayerAttributes instance,
) => <String, dynamic>{'stats': instance.stats, 'type': instance.$type};

GoalkeeperPlayerAttributes _$GoalkeeperPlayerAttributesFromJson(
  Map<String, dynamic> json,
) => GoalkeeperPlayerAttributes(
  stats: GoalkeeperAttributes.fromJson(json['stats'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$GoalkeeperPlayerAttributesToJson(
  GoalkeeperPlayerAttributes instance,
) => <String, dynamic>{'stats': instance.stats, 'type': instance.$type};
