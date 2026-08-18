// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TradeAssetSnapshot _$TradeAssetSnapshotFromJson(Map<String, dynamic> json) =>
    _TradeAssetSnapshot(
      type: json['type'] as String,
      playerId: json['playerId'] as String?,
      draftedRightsId: json['draftedRightsId'] as String?,
      pickId: json['pickId'] as String?,
      pickYear: (json['pickYear'] as num?)?.toInt(),
      pickRound: (json['pickRound'] as num?)?.toInt(),
      originalTeamId: json['originalTeamId'] as String?,
    );

Map<String, dynamic> _$TradeAssetSnapshotToJson(_TradeAssetSnapshot instance) =>
    <String, dynamic>{
      'type': instance.type,
      'playerId': instance.playerId,
      'draftedRightsId': instance.draftedRightsId,
      'pickId': instance.pickId,
      'pickYear': instance.pickYear,
      'pickRound': instance.pickRound,
      'originalTeamId': instance.originalTeamId,
    };

_TradeHistoryEntry _$TradeHistoryEntryFromJson(
  Map<String, dynamic> json,
) => _TradeHistoryEntry(
  id: json['id'] as String,
  teamAId: json['teamAId'] as String,
  teamBId: json['teamBId'] as String,
  seasonYear: (json['seasonYear'] as num).toInt(),
  week: (json['week'] as num).toInt(),
  day: (json['day'] as num?)?.toInt() ?? 1,
  outcome: json['outcome'] as String? ?? 'accepted',
  assetsFromA:
      (json['assetsFromA'] as List<dynamic>?)
          ?.map((e) => TradeAssetSnapshot.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  assetsFromB:
      (json['assetsFromB'] as List<dynamic>?)
          ?.map((e) => TradeAssetSnapshot.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  reason: json['reason'] as String?,
  ntcPlayerId: json['ntcPlayerId'] as String?,
  ntcConsentProbability: (json['ntcConsentProbability'] as num?)?.toDouble(),
  offerId: json['offerId'] as String?,
  threadId: json['threadId'] as String?,
  round: (json['round'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$TradeHistoryEntryToJson(_TradeHistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamAId': instance.teamAId,
      'teamBId': instance.teamBId,
      'seasonYear': instance.seasonYear,
      'week': instance.week,
      'day': instance.day,
      'outcome': instance.outcome,
      'assetsFromA': instance.assetsFromA,
      'assetsFromB': instance.assetsFromB,
      'reason': instance.reason,
      'ntcPlayerId': instance.ntcPlayerId,
      'ntcConsentProbability': instance.ntcConsentProbability,
      'offerId': instance.offerId,
      'threadId': instance.threadId,
      'round': instance.round,
    };

_NtcTradeBlock _$NtcTradeBlockFromJson(Map<String, dynamic> json) =>
    _NtcTradeBlock(
      playerId: json['playerId'] as String,
      destinationTeamId: json['destinationTeamId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$NtcTradeBlockToJson(_NtcTradeBlock instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'destinationTeamId': instance.destinationTeamId,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

_TradeOffer _$TradeOfferFromJson(Map<String, dynamic> json) => _TradeOffer(
  id: json['id'] as String,
  threadId: json['threadId'] as String,
  parentOfferId: json['parentOfferId'] as String?,
  teamAId: json['teamAId'] as String,
  teamBId: json['teamBId'] as String,
  assetsFromA:
      (json['assetsFromA'] as List<dynamic>?)
          ?.map((e) => TradeAssetSnapshot.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  assetsFromB:
      (json['assetsFromB'] as List<dynamic>?)
          ?.map((e) => TradeAssetSnapshot.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  round: (json['round'] as num?)?.toInt() ?? 1,
  status:
      $enumDecodeNullable(_$TradeOfferStatusEnumMap, json['status']) ??
      TradeOfferStatus.pending,
  awaitingTeamId: json['awaitingTeamId'] as String,
  seasonYear: (json['seasonYear'] as num).toInt(),
  week: (json['week'] as num).toInt(),
  day: (json['day'] as num?)?.toInt() ?? 1,
  hour: (json['hour'] as num?)?.toInt() ?? 0,
  expirySeasonYear: (json['expirySeasonYear'] as num).toInt(),
  expiryWeek: (json['expiryWeek'] as num).toInt(),
  expiryDay: (json['expiryDay'] as num?)?.toInt() ?? 1,
  expiryHour: (json['expiryHour'] as num?)?.toInt() ?? 0,
  supersededById: json['supersededById'] as String?,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$TradeOfferToJson(_TradeOffer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'threadId': instance.threadId,
      'parentOfferId': instance.parentOfferId,
      'teamAId': instance.teamAId,
      'teamBId': instance.teamBId,
      'assetsFromA': instance.assetsFromA,
      'assetsFromB': instance.assetsFromB,
      'round': instance.round,
      'status': _$TradeOfferStatusEnumMap[instance.status]!,
      'awaitingTeamId': instance.awaitingTeamId,
      'seasonYear': instance.seasonYear,
      'week': instance.week,
      'day': instance.day,
      'hour': instance.hour,
      'expirySeasonYear': instance.expirySeasonYear,
      'expiryWeek': instance.expiryWeek,
      'expiryDay': instance.expiryDay,
      'expiryHour': instance.expiryHour,
      'supersededById': instance.supersededById,
      'reason': instance.reason,
    };

const _$TradeOfferStatusEnumMap = {
  TradeOfferStatus.pending: 'pending',
  TradeOfferStatus.countered: 'countered',
  TradeOfferStatus.accepted: 'accepted',
  TradeOfferStatus.rejected: 'rejected',
  TradeOfferStatus.hardRejected: 'hardRejected',
  TradeOfferStatus.expired: 'expired',
  TradeOfferStatus.ntcRefused: 'ntcRefused',
  TradeOfferStatus.cancelled: 'cancelled',
};
