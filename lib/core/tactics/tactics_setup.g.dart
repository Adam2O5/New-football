// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tactics_setup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TacticsSetup _$TacticsSetupFromJson(Map<String, dynamic> json) =>
    _TacticsSetup(
      formation:
          $enumDecodeNullable(_$FormationEnumMap, json['formation']) ??
          Formation.f433,
      tempo:
          $enumDecodeNullable(_$TempoEnumMap, json['tempo']) ?? Tempo.balanced,
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

Map<String, dynamic> _$TacticsSetupToJson(_TacticsSetup instance) =>
    <String, dynamic>{
      'formation': _$FormationEnumMap[instance.formation]!,
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
  Formation.f3421: 'f3421',
  Formation.f352: 'f352',
  Formation.f3511: 'f3511',
  Formation.f41212Narrow: 'f41212Narrow',
  Formation.f4132: 'f4132',
  Formation.f4141: 'f4141',
  Formation.f4231: 'f4231',
  Formation.f4231Wide: 'f4231Wide',
  Formation.f424: 'f424',
  Formation.f4312: 'f4312',
  Formation.f4321: 'f4321',
  Formation.f433: 'f433',
  Formation.f433Attack: 'f433Attack',
  Formation.f433Defend: 'f433Defend',
  Formation.f442: 'f442',
  Formation.f442Defend: 'f442Defend',
  Formation.f451: 'f451',
  Formation.f5212: 'f5212',
  Formation.f523: 'f523',
  Formation.f532: 'f532',
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
