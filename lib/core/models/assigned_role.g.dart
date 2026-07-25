// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignedGkRoleImpl _$$AssignedGkRoleImplFromJson(Map<String, dynamic> json) =>
    _$AssignedGkRoleImpl(
      role:
          $enumDecodeNullable(_$GkRoleEnumMap, json['role']) ?? GkRole.standard,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$AssignedGkRoleImplToJson(
  _$AssignedGkRoleImpl instance,
) => <String, dynamic>{
  'role': _$GkRoleEnumMap[instance.role]!,
  'type': instance.$type,
};

const _$GkRoleEnumMap = {
  GkRole.standard: 'standard',
  GkRole.sweeperKeeper: 'sweeperKeeper',
};

_$AssignedCbRoleImpl _$$AssignedCbRoleImplFromJson(Map<String, dynamic> json) =>
    _$AssignedCbRoleImpl(
      role:
          $enumDecodeNullable(_$CbRoleEnumMap, json['role']) ?? CbRole.standard,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$AssignedCbRoleImplToJson(
  _$AssignedCbRoleImpl instance,
) => <String, dynamic>{
  'role': _$CbRoleEnumMap[instance.role]!,
  'type': instance.$type,
};

const _$CbRoleEnumMap = {
  CbRole.standard: 'standard',
  CbRole.ballPlayingDefender: 'ballPlayingDefender',
  CbRole.noNonsenseCentreBack: 'noNonsenseCentreBack',
};

_$AssignedFullBackRoleImpl _$$AssignedFullBackRoleImplFromJson(
  Map<String, dynamic> json,
) => _$AssignedFullBackRoleImpl(
  role:
      $enumDecodeNullable(_$FullBackRoleEnumMap, json['role']) ??
      FullBackRole.standard,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$AssignedFullBackRoleImplToJson(
  _$AssignedFullBackRoleImpl instance,
) => <String, dynamic>{
  'role': _$FullBackRoleEnumMap[instance.role]!,
  'type': instance.$type,
};

const _$FullBackRoleEnumMap = {
  FullBackRole.standard: 'standard',
  FullBackRole.defensiveFullBack: 'defensiveFullBack',
  FullBackRole.attackingFullBack: 'attackingFullBack',
};

_$AssignedWingBackRoleImpl _$$AssignedWingBackRoleImplFromJson(
  Map<String, dynamic> json,
) => _$AssignedWingBackRoleImpl(
  role:
      $enumDecodeNullable(_$WingBackRoleEnumMap, json['role']) ??
      WingBackRole.standard,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$AssignedWingBackRoleImplToJson(
  _$AssignedWingBackRoleImpl instance,
) => <String, dynamic>{
  'role': _$WingBackRoleEnumMap[instance.role]!,
  'type': instance.$type,
};

const _$WingBackRoleEnumMap = {
  WingBackRole.standard: 'standard',
  WingBackRole.wingBack: 'wingBack',
  WingBackRole.invertedWingBack: 'invertedWingBack',
};

_$AssignedCdmRoleImpl _$$AssignedCdmRoleImplFromJson(
  Map<String, dynamic> json,
) => _$AssignedCdmRoleImpl(
  role: $enumDecodeNullable(_$CdmRoleEnumMap, json['role']) ?? CdmRole.standard,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$AssignedCdmRoleImplToJson(
  _$AssignedCdmRoleImpl instance,
) => <String, dynamic>{
  'role': _$CdmRoleEnumMap[instance.role]!,
  'type': instance.$type,
};

const _$CdmRoleEnumMap = {
  CdmRole.standard: 'standard',
  CdmRole.regista: 'regista',
  CdmRole.deepLyingPlaymaker: 'deepLyingPlaymaker',
  CdmRole.anchorMan: 'anchorMan',
};

_$AssignedCmRoleImpl _$$AssignedCmRoleImplFromJson(Map<String, dynamic> json) =>
    _$AssignedCmRoleImpl(
      role:
          $enumDecodeNullable(_$CmRoleEnumMap, json['role']) ?? CmRole.standard,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$AssignedCmRoleImplToJson(
  _$AssignedCmRoleImpl instance,
) => <String, dynamic>{
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

_$AssignedCamRoleImpl _$$AssignedCamRoleImplFromJson(
  Map<String, dynamic> json,
) => _$AssignedCamRoleImpl(
  role: $enumDecodeNullable(_$CamRoleEnumMap, json['role']) ?? CamRole.standard,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$AssignedCamRoleImplToJson(
  _$AssignedCamRoleImpl instance,
) => <String, dynamic>{
  'role': _$CamRoleEnumMap[instance.role]!,
  'type': instance.$type,
};

const _$CamRoleEnumMap = {
  CamRole.standard: 'standard',
  CamRole.playmaker: 'playmaker',
  CamRole.shadowStriker: 'shadowStriker',
};

_$AssignedWingerRoleImpl _$$AssignedWingerRoleImplFromJson(
  Map<String, dynamic> json,
) => _$AssignedWingerRoleImpl(
  role:
      $enumDecodeNullable(_$WingerRoleEnumMap, json['role']) ??
      WingerRole.standard,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$AssignedWingerRoleImplToJson(
  _$AssignedWingerRoleImpl instance,
) => <String, dynamic>{
  'role': _$WingerRoleEnumMap[instance.role]!,
  'type': instance.$type,
};

const _$WingerRoleEnumMap = {
  WingerRole.standard: 'standard',
  WingerRole.invertedWinger: 'invertedWinger',
  WingerRole.winger: 'winger',
};

_$AssignedStrikerRoleImpl _$$AssignedStrikerRoleImplFromJson(
  Map<String, dynamic> json,
) => _$AssignedStrikerRoleImpl(
  role:
      $enumDecodeNullable(_$StrikerRoleEnumMap, json['role']) ??
      StrikerRole.standard,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$AssignedStrikerRoleImplToJson(
  _$AssignedStrikerRoleImpl instance,
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
