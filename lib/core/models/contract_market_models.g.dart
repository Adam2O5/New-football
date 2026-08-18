// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_market_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DraftedPlayerRights _$DraftedPlayerRightsFromJson(Map<String, dynamic> json) =>
    _DraftedPlayerRights(
      id: json['id'] as String,
      ownerTeamId: json['ownerTeamId'] as String,
      player: Player.fromJson(json['player'] as Map<String, dynamic>),
      draftYear: (json['draftYear'] as num).toInt(),
      pickNumber: (json['pickNumber'] as num).toInt(),
      reminderSent: json['reminderSent'] as bool? ?? false,
    );

Map<String, dynamic> _$DraftedPlayerRightsToJson(
  _DraftedPlayerRights instance,
) => <String, dynamic>{
  'id': instance.id,
  'ownerTeamId': instance.ownerTeamId,
  'player': instance.player,
  'draftYear': instance.draftYear,
  'pickNumber': instance.pickNumber,
  'reminderSent': instance.reminderSent,
};

_FreshUndraftedPlayer _$FreshUndraftedPlayerFromJson(
  Map<String, dynamic> json,
) => _FreshUndraftedPlayer(
  playerId: json['playerId'] as String,
  draftYear: (json['draftYear'] as num).toInt(),
  activeFromSeasonYear: (json['activeFromSeasonYear'] as num).toInt(),
  activeFromWeek: (json['activeFromWeek'] as num).toInt(),
  activeUntilSeasonYear: (json['activeUntilSeasonYear'] as num).toInt(),
  activeUntilWeek: (json['activeUntilWeek'] as num).toInt(),
);

Map<String, dynamic> _$FreshUndraftedPlayerToJson(
  _FreshUndraftedPlayer instance,
) => <String, dynamic>{
  'playerId': instance.playerId,
  'draftYear': instance.draftYear,
  'activeFromSeasonYear': instance.activeFromSeasonYear,
  'activeFromWeek': instance.activeFromWeek,
  'activeUntilSeasonYear': instance.activeUntilSeasonYear,
  'activeUntilWeek': instance.activeUntilWeek,
};

_RfaQualifyingOffer _$RfaQualifyingOfferFromJson(Map<String, dynamic> json) =>
    _RfaQualifyingOffer(
      playerId: json['playerId'] as String,
      ownerTeamId: json['ownerTeamId'] as String,
      salary: (json['salary'] as num).toInt(),
      years: (json['years'] as num?)?.toInt() ?? 1,
      seasonYear: (json['seasonYear'] as num).toInt(),
      declined: json['declined'] as bool? ?? false,
    );

Map<String, dynamic> _$RfaQualifyingOfferToJson(_RfaQualifyingOffer instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'ownerTeamId': instance.ownerTeamId,
      'salary': instance.salary,
      'years': instance.years,
      'seasonYear': instance.seasonYear,
      'declined': instance.declined,
    };

_RfaOfferSheet _$RfaOfferSheetFromJson(Map<String, dynamic> json) =>
    _RfaOfferSheet(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      originalTeamId: json['originalTeamId'] as String,
      offeringTeamId: json['offeringTeamId'] as String,
      salary: (json['salary'] as num).toInt(),
      years: (json['years'] as num).toInt(),
      phase: $enumDecode(_$NegotiationPhaseEnumMap, json['phase']),
      seasonYear: (json['seasonYear'] as num).toInt(),
      week: (json['week'] as num).toInt(),
      day: (json['day'] as num?)?.toInt() ?? 1,
      hour: (json['hour'] as num?)?.toInt() ?? 1,
      expirySeasonYear: (json['expirySeasonYear'] as num).toInt(),
      expiryWeek: (json['expiryWeek'] as num).toInt(),
      expiryDay: (json['expiryDay'] as num?)?.toInt() ?? 1,
      expiryHour: (json['expiryHour'] as num?)?.toInt() ?? 0,
      matched: json['matched'] as bool? ?? false,
      declined: json['declined'] as bool? ?? false,
    );

Map<String, dynamic> _$RfaOfferSheetToJson(_RfaOfferSheet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playerId': instance.playerId,
      'originalTeamId': instance.originalTeamId,
      'offeringTeamId': instance.offeringTeamId,
      'salary': instance.salary,
      'years': instance.years,
      'phase': _$NegotiationPhaseEnumMap[instance.phase]!,
      'seasonYear': instance.seasonYear,
      'week': instance.week,
      'day': instance.day,
      'hour': instance.hour,
      'expirySeasonYear': instance.expirySeasonYear,
      'expiryWeek': instance.expiryWeek,
      'expiryDay': instance.expiryDay,
      'expiryHour': instance.expiryHour,
      'matched': instance.matched,
      'declined': instance.declined,
    };

const _$NegotiationPhaseEnumMap = {
  NegotiationPhase.contractExtension: 'contractExtension',
  NegotiationPhase.freeAgencyPhaseI: 'freeAgencyPhaseI',
  NegotiationPhase.freeAgencyPhaseII: 'freeAgencyPhaseII',
};
