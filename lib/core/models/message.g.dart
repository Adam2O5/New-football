// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageAction _$MessageActionFromJson(Map<String, dynamic> json) =>
    _MessageAction(
      id: json['id'] as String,
      labelKey: json['labelKey'] as String,
    );

Map<String, dynamic> _$MessageActionToJson(_MessageAction instance) =>
    <String, dynamic>{'id': instance.id, 'labelKey': instance.labelKey};

_DecisionSpec _$DecisionSpecFromJson(Map<String, dynamic> json) =>
    _DecisionSpec(
      options: (json['options'] as List<dynamic>)
          .map((e) => MessageAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultOnExpiry: json['defaultOnExpiry'] as String,
    );

Map<String, dynamic> _$DecisionSpecToJson(_DecisionSpec instance) =>
    <String, dynamic>{
      'options': instance.options,
      'defaultOnExpiry': instance.defaultOnExpiry,
    };

_GameMessage _$GameMessageFromJson(Map<String, dynamic> json) => _GameMessage(
  id: json['id'] as String,
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  kind: json['kind'] as String?,
  domain:
      $enumDecodeNullable(_$MessageDomainEnumMap, json['domain']) ??
      MessageDomain.system,
  priority:
      $enumDecodeNullable(_$MessagePriorityEnumMap, json['priority']) ??
      MessagePriority.normal,
  seasonYear: (json['seasonYear'] as num).toInt(),
  week: (json['week'] as num).toInt(),
  day: (json['day'] as num?)?.toInt() ?? 1,
  hour: (json['hour'] as num?)?.toInt(),
  titleKey: json['titleKey'] as String,
  bodyKey: json['bodyKey'] as String,
  args: json['args'] as Map<String, dynamic>? ?? const {},
  payload: json['payload'] as Map<String, dynamic>? ?? const {},
  actions:
      (json['actions'] as List<dynamic>?)
          ?.map((e) => MessageAction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  decision: json['decision'] == null
      ? null
      : DecisionSpec.fromJson(json['decision'] as Map<String, dynamic>),
  expiresAt: json['expiresAt'] as String?,
  groupKey: json['groupKey'] as String?,
  dedupKey: json['dedupKey'] as String?,
  read: json['read'] as bool? ?? false,
  acknowledged: json['acknowledged'] as bool? ?? false,
);

Map<String, dynamic> _$GameMessageToJson(_GameMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'kind': instance.kind,
      'domain': _$MessageDomainEnumMap[instance.domain]!,
      'priority': _$MessagePriorityEnumMap[instance.priority]!,
      'seasonYear': instance.seasonYear,
      'week': instance.week,
      'day': instance.day,
      'hour': instance.hour,
      'titleKey': instance.titleKey,
      'bodyKey': instance.bodyKey,
      'args': instance.args,
      'payload': instance.payload,
      'actions': instance.actions,
      'decision': instance.decision,
      'expiresAt': instance.expiresAt,
      'groupKey': instance.groupKey,
      'dedupKey': instance.dedupKey,
      'read': instance.read,
      'acknowledged': instance.acknowledged,
    };

const _$MessageTypeEnumMap = {
  MessageType.matchPreview: 'matchPreview',
  MessageType.matchResult: 'matchResult',
  MessageType.walkover: 'walkover',
  MessageType.lineupNoGk: 'lineupNoGk',
  MessageType.benchIncomplete: 'benchIncomplete',
  MessageType.suspensionStart: 'suspensionStart',
  MessageType.suspensionEnd: 'suspensionEnd',
  MessageType.injury: 'injury',
  MessageType.injuryReturn: 'injuryReturn',
  MessageType.injuryRecurrence: 'injuryRecurrence',
  MessageType.potentialLoss: 'potentialLoss',
  MessageType.playerEvent: 'playerEvent',
  MessageType.teamEvent: 'teamEvent',
  MessageType.retirementPlayer: 'retirementPlayer',
  MessageType.retirementStaff: 'retirementStaff',
  MessageType.retirementLeagueDigest: 'retirementLeagueDigest',
  MessageType.rosterWarning: 'rosterWarning',
  MessageType.contractOffer: 'contractOffer',
  MessageType.contractOfferResponse: 'contractOfferResponse',
  MessageType.contractSigned: 'contractSigned',
  MessageType.contractExpiring: 'contractExpiring',
  MessageType.contractLostToRival: 'contractLostToRival',
  MessageType.contractExpired: 'contractExpired',
  MessageType.declineToExtend: 'declineToExtend',
  MessageType.rfaOfferSheet: 'rfaOfferSheet',
  MessageType.staffOfferResponse: 'staffOfferResponse',
  MessageType.staffSigned: 'staffSigned',
  MessageType.staffGrowth: 'staffGrowth',
  MessageType.staffHired: 'staffHired',
  MessageType.staffFired: 'staffFired',
  MessageType.staffSlotEmpty: 'staffSlotEmpty',
  MessageType.trade: 'trade',
  MessageType.tradeOffer: 'tradeOffer',
  MessageType.tradeWindowEvent: 'tradeWindowEvent',
  MessageType.lottery: 'lottery',
  MessageType.scoutReport: 'scoutReport',
  MessageType.combine: 'combine',
  MessageType.mockDraft: 'mockDraft',
  MessageType.draftPick: 'draftPick',
  MessageType.draftPickLeague: 'draftPickLeague',
  MessageType.draftedRightsReminder: 'draftedRightsReminder',
  MessageType.apronWarning: 'apronWarning',
  MessageType.capUpdateTv: 'capUpdateTv',
  MessageType.staffCapViolation: 'staffCapViolation',
  MessageType.award: 'award',
  MessageType.atmosphere: 'atmosphere',
  MessageType.teamStatusChange: 'teamStatusChange',
  MessageType.seasonSummary: 'seasonSummary',
  MessageType.playoffMissed: 'playoffMissed',
  MessageType.calendar: 'calendar',
  MessageType.system: 'system',
  MessageType.ovrDigest: 'ovrDigest',
};

const _$MessageDomainEnumMap = {
  MessageDomain.matchday: 'matchday',
  MessageDomain.health: 'health',
  MessageDomain.playerEvent: 'playerEvent',
  MessageDomain.teamEvent: 'teamEvent',
  MessageDomain.roster: 'roster',
  MessageDomain.contracts: 'contracts',
  MessageDomain.staff: 'staff',
  MessageDomain.trades: 'trades',
  MessageDomain.draft: 'draft',
  MessageDomain.finance: 'finance',
  MessageDomain.season: 'season',
  MessageDomain.system: 'system',
};

const _$MessagePriorityEnumMap = {
  MessagePriority.silenced: 'silenced',
  MessagePriority.normal: 'normal',
  MessagePriority.urgent: 'urgent',
};

_MessageSettings _$MessageSettingsFromJson(Map<String, dynamic> json) =>
    _MessageSettings(
      overrides:
          (json['overrides'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$MessageTypeEnumMap, k),
              $enumDecode(_$NotificationLevelEnumMap, e),
            ),
          ) ??
          const {},
      domainOverrides:
          (json['domainOverrides'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$MessageDomainEnumMap, k),
              $enumDecode(_$NotificationLevelEnumMap, e),
            ),
          ) ??
          const {},
    );

Map<String, dynamic> _$MessageSettingsToJson(
  _MessageSettings instance,
) => <String, dynamic>{
  'overrides': instance.overrides.map(
    (k, e) =>
        MapEntry(_$MessageTypeEnumMap[k]!, _$NotificationLevelEnumMap[e]!),
  ),
  'domainOverrides': instance.domainOverrides.map(
    (k, e) =>
        MapEntry(_$MessageDomainEnumMap[k]!, _$NotificationLevelEnumMap[e]!),
  ),
};

const _$NotificationLevelEnumMap = {
  NotificationLevel.auto: 'auto',
  NotificationLevel.important: 'important',
  NotificationLevel.normal: 'normal',
  NotificationLevel.muted: 'muted',
};

_Inbox _$InboxFromJson(Map<String, dynamic> json) => _Inbox(
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => GameMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  scheduled:
      (json['scheduled'] as List<dynamic>?)
          ?.map((e) => GameMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  archive:
      (json['archive'] as List<dynamic>?)
          ?.map((e) => GameMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$InboxToJson(_Inbox instance) => <String, dynamic>{
  'messages': instance.messages,
  'scheduled': instance.scheduled,
  'archive': instance.archive,
};
