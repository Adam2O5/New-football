// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_pick.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DraftPick _$DraftPickFromJson(Map<String, dynamic> json) => _DraftPick(
  id: json['id'] as String,
  year: (json['year'] as num).toInt(),
  round: (json['round'] as num).toInt(),
  pickNumber: (json['pickNumber'] as num?)?.toInt(),
  teamId: json['teamId'] as String,
  originalTeamId: json['originalTeamId'] as String,
  prospectId: json['prospectId'] as String?,
  playerName: json['playerName'] as String?,
  protectedTopN: (json['protectedTopN'] as num?)?.toInt(),
  tradeValue: (json['tradeValue'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DraftPickToJson(_DraftPick instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'round': instance.round,
      'pickNumber': instance.pickNumber,
      'teamId': instance.teamId,
      'originalTeamId': instance.originalTeamId,
      'prospectId': instance.prospectId,
      'playerName': instance.playerName,
      'protectedTopN': instance.protectedTopN,
      'tradeValue': instance.tradeValue,
    };
