// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeagueState _$LeagueStateFromJson(Map<String, dynamic> json) => _LeagueState(
  teams: (json['teams'] as List<dynamic>)
      .map((e) => Team.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentSeason: Season.fromJson(json['currentSeason'] as Map<String, dynamic>),
  history:
      (json['history'] as List<dynamic>?)
          ?.map((e) => SeasonHistory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  playerTeamId: json['playerTeamId'] as String?,
  currentRound: (json['currentRound'] as num?)?.toInt() ?? 0,
  currentWeek: (json['currentWeek'] as num?)?.toInt() ?? 1,
  currentDay: (json['currentDay'] as num?)?.toInt() ?? 1,
  currentHour: (json['currentHour'] as num?)?.toInt(),
  hourlyPlayerOfferUsed: json['hourlyPlayerOfferUsed'] as bool? ?? false,
  hourlyStaffOfferUsed: json['hourlyStaffOfferUsed'] as bool? ?? false,
  inbox: json['inbox'] == null
      ? const Inbox()
      : Inbox.fromJson(json['inbox'] as Map<String, dynamic>),
  messageSettings: json['messageSettings'] == null
      ? const MessageSettings()
      : MessageSettings.fromJson(
          json['messageSettings'] as Map<String, dynamic>,
        ),
  staffFreeAgents:
      (json['staffFreeAgents'] as List<dynamic>?)
          ?.map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  freeAgents:
      (json['freeAgents'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  freshUndraftedPlayers:
      (json['freshUndraftedPlayers'] as List<dynamic>?)
          ?.map((e) => FreshUndraftedPlayer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  strengthTable: json['strengthTable'] == null
      ? null
      : LeagueStrengthTable.fromJson(
          json['strengthTable'] as Map<String, dynamic>,
        ),
  negotiations:
      (json['negotiations'] as List<dynamic>?)
          ?.map((e) => ContractNegotiation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  negotiationBlocks:
      (json['negotiationBlocks'] as List<dynamic>?)
          ?.map((e) => NegotiationBlock.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  tradeHistory:
      (json['tradeHistory'] as List<dynamic>?)
          ?.map((e) => TradeHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  tradeOffers:
      (json['tradeOffers'] as List<dynamic>?)
          ?.map((e) => TradeOffer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  ntcTradeBlocks:
      (json['ntcTradeBlocks'] as List<dynamic>?)
          ?.map((e) => NtcTradeBlock.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  draftedRights:
      (json['draftedRights'] as List<dynamic>?)
          ?.map((e) => DraftedPlayerRights.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  rfaQualifyingOffers:
      (json['rfaQualifyingOffers'] as List<dynamic>?)
          ?.map((e) => RfaQualifyingOffer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  rfaOfferSheets:
      (json['rfaOfferSheets'] as List<dynamic>?)
          ?.map((e) => RfaOfferSheet.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$LeagueStateToJson(_LeagueState instance) =>
    <String, dynamic>{
      'teams': instance.teams,
      'currentSeason': instance.currentSeason,
      'history': instance.history,
      'playerTeamId': instance.playerTeamId,
      'currentRound': instance.currentRound,
      'currentWeek': instance.currentWeek,
      'currentDay': instance.currentDay,
      'currentHour': instance.currentHour,
      'hourlyPlayerOfferUsed': instance.hourlyPlayerOfferUsed,
      'hourlyStaffOfferUsed': instance.hourlyStaffOfferUsed,
      'inbox': instance.inbox,
      'messageSettings': instance.messageSettings,
      'staffFreeAgents': instance.staffFreeAgents,
      'freeAgents': instance.freeAgents,
      'freshUndraftedPlayers': instance.freshUndraftedPlayers,
      'strengthTable': instance.strengthTable,
      'negotiations': instance.negotiations,
      'negotiationBlocks': instance.negotiationBlocks,
      'tradeHistory': instance.tradeHistory,
      'tradeOffers': instance.tradeOffers,
      'ntcTradeBlocks': instance.ntcTradeBlocks,
      'draftedRights': instance.draftedRights,
      'rfaQualifyingOffers': instance.rfaQualifyingOffers,
      'rfaOfferSheets': instance.rfaOfferSheets,
    };
