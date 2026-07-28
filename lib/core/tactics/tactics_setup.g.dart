// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tactics_setup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MidfieldSlotsImpl _$$MidfieldSlotsImplFromJson(Map<String, dynamic> json) =>
    _$MidfieldSlotsImpl(
      cdm: (json['cdm'] as num?)?.toInt() ?? 1,
      cm: (json['cm'] as num?)?.toInt() ?? 1,
      cam: (json['cam'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$MidfieldSlotsImplToJson(_$MidfieldSlotsImpl instance) =>
    <String, dynamic>{
      'cdm': instance.cdm,
      'cm': instance.cm,
      'cam': instance.cam,
    };

_$TacticsSetupImpl _$$TacticsSetupImplFromJson(
  Map<String, dynamic> json,
) => _$TacticsSetupImpl(
  formation:
      $enumDecodeNullable(_$FormationEnumMap, json['formation']) ??
      Formation.f433,
  midfieldSlots: json['midfieldSlots'] == null
      ? null
      : MidfieldSlots.fromJson(json['midfieldSlots'] as Map<String, dynamic>),
  tempo: $enumDecodeNullable(_$TempoEnumMap, json['tempo']) ?? Tempo.balanced,
  attackWidth:
      $enumDecodeNullable(_$AttackWidthEnumMap, json['attackWidth']) ??
      AttackWidth.balanced,
  defensiveLine:
      $enumDecodeNullable(_$DefensiveLineEnumMap, json['defensiveLine']) ??
      DefensiveLine.normal,
  pressing:
      $enumDecodeNullable(_$PressingIntensityEnumMap, json['pressing']) ??
      PressingIntensity.medium,
  cornersAttack: (json['cornersAttack'] as num?)?.toInt() ?? 50,
  cornersDefense: (json['cornersDefense'] as num?)?.toInt() ?? 50,
  freeKicks: (json['freeKicks'] as num?)?.toInt() ?? 30,
  penalties: (json['penalties'] as num?)?.toInt() ?? 80,
);

Map<String, dynamic> _$$TacticsSetupImplToJson(_$TacticsSetupImpl instance) =>
    <String, dynamic>{
      'formation': _$FormationEnumMap[instance.formation]!,
      'midfieldSlots': instance.midfieldSlots,
      'tempo': _$TempoEnumMap[instance.tempo]!,
      'attackWidth': _$AttackWidthEnumMap[instance.attackWidth]!,
      'defensiveLine': _$DefensiveLineEnumMap[instance.defensiveLine]!,
      'pressing': _$PressingIntensityEnumMap[instance.pressing]!,
      'cornersAttack': instance.cornersAttack,
      'cornersDefense': instance.cornersDefense,
      'freeKicks': instance.freeKicks,
      'penalties': instance.penalties,
    };

const _$FormationEnumMap = {
  Formation.f343: 'f343',
  Formation.f352: 'f352',
  Formation.f424: 'f424',
  Formation.f433: 'f433',
  Formation.f442Wide: 'f442Wide',
  Formation.f442Narrow: 'f442Narrow',
  Formation.f451Wide: 'f451Wide',
  Formation.f451Narrow: 'f451Narrow',
  Formation.f523: 'f523',
  Formation.f532: 'f532',
  Formation.f541Wide: 'f541Wide',
  Formation.f541Narrow: 'f541Narrow',
};

const _$TempoEnumMap = {
  Tempo.slow: 'slow',
  Tempo.balanced: 'balanced',
  Tempo.fast: 'fast',
};

const _$AttackWidthEnumMap = {
  AttackWidth.narrow: 'narrow',
  AttackWidth.balanced: 'balanced',
  AttackWidth.wide: 'wide',
};

const _$DefensiveLineEnumMap = {
  DefensiveLine.deep: 'deep',
  DefensiveLine.normal: 'normal',
  DefensiveLine.high: 'high',
};

const _$PressingIntensityEnumMap = {
  PressingIntensity.low: 'low',
  PressingIntensity.medium: 'medium',
  PressingIntensity.high: 'high',
  PressingIntensity.gegenpressing: 'gegenpressing',
};
