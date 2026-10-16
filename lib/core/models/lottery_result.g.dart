// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LotteryResult _$LotteryResultFromJson(Map<String, dynamic> json) =>
    _LotteryResult(
      teamId: json['teamId'] as String,
      originalRank: (json['originalRank'] as num).toInt(),
      assignedPick: (json['assignedPick'] as num).toInt(),
      oddsForFirstPick: (json['oddsForFirstPick'] as num).toDouble(),
    );

Map<String, dynamic> _$LotteryResultToJson(_LotteryResult instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'originalRank': instance.originalRank,
      'assignedPick': instance.assignedPick,
      'oddsForFirstPick': instance.oddsForFirstPick,
    };
