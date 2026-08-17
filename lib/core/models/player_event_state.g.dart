// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_event_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimedModifier _$TimedModifierFromJson(Map<String, dynamic> json) =>
    _TimedModifier(
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      weeksRemaining: (json['weeksRemaining'] as num).toInt(),
    );

Map<String, dynamic> _$TimedModifierToJson(_TimedModifier instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'weeksRemaining': instance.weeksRemaining,
    };

_PlayerEventState _$PlayerEventStateFromJson(Map<String, dynamic> json) =>
    _PlayerEventState(
      modifiers:
          (json['modifiers'] as List<dynamic>?)
              ?.map((e) => TimedModifier.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cooldowns:
          (json['cooldowns'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      counters:
          (json['counters'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      lateBloomerTriggered: json['lateBloomerTriggered'] as bool? ?? false,
      lastMajorInjury: json['lastMajorInjury'] == null
          ? null
          : Injury.fromJson(json['lastMajorInjury'] as Map<String, dynamic>),
      majorInjuryActiveLastTick:
          json['majorInjuryActiveLastTick'] as bool? ?? false,
      weeksSinceMajorInjury:
          (json['weeksSinceMajorInjury'] as num?)?.toInt() ?? 0,
      personalProblemsFollowUpPending:
          json['personalProblemsFollowUpPending'] as bool? ?? false,
    );

Map<String, dynamic> _$PlayerEventStateToJson(
  _PlayerEventState instance,
) => <String, dynamic>{
  'modifiers': instance.modifiers,
  'cooldowns': instance.cooldowns,
  'counters': instance.counters,
  'lateBloomerTriggered': instance.lateBloomerTriggered,
  'lastMajorInjury': instance.lastMajorInjury,
  'majorInjuryActiveLastTick': instance.majorInjuryActiveLastTick,
  'weeksSinceMajorInjury': instance.weeksSinceMajorInjury,
  'personalProblemsFollowUpPending': instance.personalProblemsFollowUpPending,
};
