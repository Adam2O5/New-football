// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignedGkRole _$AssignedGkRoleFromJson(Map<String, dynamic> json) =>
    AssignedGkRole(
      role:
          $enumDecodeNullable(_$GkRoleEnumMap, json['role']) ?? GkRole.standard,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$AssignedGkRoleToJson(AssignedGkRole instance) =>
    <String, dynamic>{
      'role': _$GkRoleEnumMap[instance.role]!,
      'type': instance.$type,
    };

const _$GkRoleEnumMap = {
  GkRole.standard: 'standard',
  GkRole.sweeperKeeper: 'sweeperKeeper',
};

AssignedCbRole _$AssignedCbRoleFromJson(Map<String, dynamic> json) =>
    AssignedCbRole(
      role:
          $enumDecodeNullable(_$CbRoleEnumMap, json['role']) ?? CbRole.standard,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$AssignedCbRoleToJson(AssignedCbRole instance) =>
    <String, dynamic>{
      'role': _$CbRoleEnumMap[instance.role]!,
      'type': instance.$type,
    };

const _$CbRoleEnumMap = {
  CbRole.standard: 'standard',
  CbRole.ballPlayingDefender: 'ballPlayingDefender',
  CbRole.noNonsenseCentreBack: 'noNonsenseCentreBack',
};

AssignedFullBackRole _$AssignedFullBackRoleFromJson(
  Map<String, dynamic> json,
) => AssignedFullBackRole(
  role:
      $enumDecodeNullable(_$FullBackRoleEnumMap, json['role']) ??
      FullBackRole.standard,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$AssignedFullBackRoleToJson(
  AssignedFullBackRole instance,
) => <String, dynamic>{
  'role': _$FullBackRoleEnumMap[instance.role]!,
  'type': instance.$type,
};

const _$FullBackRoleEnumMap = {
  FullBackRole.standard: 'standard',
  FullBackRole.defensiveFullBack: 'defensiveFullBack',
  FullBackRole.attackingFullBack: 'attackingFullBack',
};

AssignedWingBackRole _$AssignedWingBackRoleFromJson(
  Map<String, dynamic> json,
) => AssignedWingBackRole(
  role:
      $enumDecodeNullable(_$WingBackRoleEnumMap, json['role']) ??
      WingBackRole.standard,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$AssignedWingBackRoleToJson(
  AssignedWingBackRole instance,
) => <String, dynamic>{
  'role': _$WingBackRoleEnumMap[instance.role]!,
  'type': instance.$type,
};

const _$WingBackRoleEnumMap = {
  WingBackRole.standard: 'standard',
  WingBackRole.wingBack: 'wingBack',
  WingBackRole.invertedWingBack: 'invertedWingBack',
};

AssignedCdmRole _$AssignedCdmRoleFromJson(
  Map<String, dynamic> json,
) => AssignedCdmRole(
  role: $enumDecodeNullable(_$CdmRoleEnumMap, json['role']) ?? CdmRole.standard,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$AssignedCdmRoleToJson(AssignedCdmRole instance) =>
    <String, dynamic>{
      'role': _$CdmRoleEnumMap[instance.role]!,
      'type': instance.$type,
    };

const _$CdmRoleEnumMap = {
  CdmRole.standard: 'standard',
  CdmRole.regista: 'regista',
  CdmRole.deepLyingPlaymaker: 'deepLyingPlaymaker',
  CdmRole.anchorMan: 'anchorMan',
};

AssignedCmRole _$AssignedCmRoleFromJson(Map<String, dynamic> json) =>
    AssignedCmRole(
      role:
          $enumDecodeNullable(_$CmRoleEnumMap, json['role']) ?? CmRole.standard,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$AssignedCmRoleToJson(AssignedCmRole instance) =>
    <String, dynamic>{
      'role': _$CmRoleEnumMap[instance.role]!,
      'type': instance.$type,
    };

const _$CmRoleEnumMap = {
  CmRole.standard: 'standard',
  CmRole.ballWinning: 'ballWinning',
  CmRole.playmaker: 'playmaker',
  CmRole.boxToBox: 'boxToBox',
  CmRole.mezzala: 'mezzala',
};

AssignedCamRole _$AssignedCamRoleFromJson(
  Map<String, dynamic> json,
) => AssignedCamRole(
  role: $enumDecodeNullable(_$CamRoleEnumMap, json['role']) ?? CamRole.standard,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$AssignedCamRoleToJson(AssignedCamRole instance) =>
    <String, dynamic>{
      'role': _$CamRoleEnumMap[instance.role]!,
      'type': instance.$type,
    };

const _$CamRoleEnumMap = {
  CamRole.standard: 'standard',
  CamRole.playmaker: 'playmaker',
  CamRole.shadowStriker: 'shadowStriker',
};

AssignedWingerRole _$AssignedWingerRoleFromJson(Map<String, dynamic> json) =>
    AssignedWingerRole(
      role:
          $enumDecodeNullable(_$WingerRoleEnumMap, json['role']) ??
          WingerRole.standard,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$AssignedWingerRoleToJson(AssignedWingerRole instance) =>
    <String, dynamic>{
      'role': _$WingerRoleEnumMap[instance.role]!,
      'type': instance.$type,
    };

const _$WingerRoleEnumMap = {
  WingerRole.standard: 'standard',
  WingerRole.invertedWinger: 'invertedWinger',
  WingerRole.winger: 'winger',
};

AssignedStrikerRole _$AssignedStrikerRoleFromJson(Map<String, dynamic> json) =>
    AssignedStrikerRole(
      role:
          $enumDecodeNullable(_$StrikerRoleEnumMap, json['role']) ??
          StrikerRole.standard,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$AssignedStrikerRoleToJson(
  AssignedStrikerRole instance,
) => <String, dynamic>{
  'role': _$StrikerRoleEnumMap[instance.role]!,
  'type': instance.$type,
};

const _$StrikerRoleEnumMap = {
  StrikerRole.standard: 'standard',
  StrikerRole.falseNine: 'falseNine',
  StrikerRole.deepLyingForward: 'deepLyingForward',
  StrikerRole.pressingForward: 'pressingForward',
  StrikerRole.completeForward: 'completeForward',
};
