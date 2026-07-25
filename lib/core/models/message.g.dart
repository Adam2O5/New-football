// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameMessageImpl _$$GameMessageImplFromJson(Map<String, dynamic> json) =>
    _$GameMessageImpl(
      id: json['id'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      priority:
          $enumDecodeNullable(_$MessagePriorityEnumMap, json['priority']) ??
          MessagePriority.normal,
      title: json['title'] as String,
      body: json['body'] as String,
      week: (json['week'] as num).toInt(),
      read: json['read'] as bool? ?? false,
      payload: json['payload'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$GameMessageImplToJson(_$GameMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'priority': _$MessagePriorityEnumMap[instance.priority]!,
      'title': instance.title,
      'body': instance.body,
      'week': instance.week,
      'read': instance.read,
      'payload': instance.payload,
    };

const _$MessageTypeEnumMap = {
  MessageType.injury: 'injury',
  MessageType.retirementPlayer: 'retirementPlayer',
  MessageType.retirementStaff: 'retirementStaff',
  MessageType.staffGrowth: 'staffGrowth',
  MessageType.award: 'award',
  MessageType.lottery: 'lottery',
  MessageType.scoutReport: 'scoutReport',
  MessageType.combine: 'combine',
  MessageType.mockDraft: 'mockDraft',
  MessageType.draftPick: 'draftPick',
  MessageType.contractOffer: 'contractOffer',
  MessageType.contractSigned: 'contractSigned',
  MessageType.trade: 'trade',
  MessageType.walkover: 'walkover',
  MessageType.matchPreview: 'matchPreview',
  MessageType.matchResult: 'matchResult',
  MessageType.atmosphere: 'atmosphere',
  MessageType.calendar: 'calendar',
  MessageType.system: 'system',
};

const _$MessagePriorityEnumMap = {
  MessagePriority.normal: 'normal',
  MessagePriority.urgent: 'urgent',
};

_$MessageSettingsImpl _$$MessageSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$MessageSettingsImpl(
  overrides:
      (json['overrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$MessageTypeEnumMap, k),
          $enumDecode(_$NotificationLevelEnumMap, e),
        ),
      ) ??
      const {},
);

Map<String, dynamic> _$$MessageSettingsImplToJson(
  _$MessageSettingsImpl instance,
) => <String, dynamic>{
  'overrides': instance.overrides.map(
    (k, e) =>
        MapEntry(_$MessageTypeEnumMap[k]!, _$NotificationLevelEnumMap[e]!),
  ),
};

const _$NotificationLevelEnumMap = {
  NotificationLevel.important: 'important',
  NotificationLevel.normal: 'normal',
  NotificationLevel.muted: 'muted',
};

_$InboxImpl _$$InboxImplFromJson(Map<String, dynamic> json) => _$InboxImpl(
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => GameMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$InboxImplToJson(_$InboxImpl instance) =>
    <String, dynamic>{'messages': instance.messages};
