// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_event_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamTimedModifier _$TeamTimedModifierFromJson(Map<String, dynamic> json) =>
    _TeamTimedModifier(
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      weeksRemaining: (json['weeksRemaining'] as num).toInt(),
    );

Map<String, dynamic> _$TeamTimedModifierToJson(_TeamTimedModifier instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'weeksRemaining': instance.weeksRemaining,
    };

_MinutesHistoryEntry _$MinutesHistoryEntryFromJson(Map<String, dynamic> json) =>
    _MinutesHistoryEntry(
      playerId: json['playerId'] as String,
      seasonYear: (json['seasonYear'] as num).toInt(),
      week: (json['week'] as num).toInt(),
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      possibleMinutes: (json['possibleMinutes'] as num?)?.toInt() ?? 90,
    );

Map<String, dynamic> _$MinutesHistoryEntryToJson(
  _MinutesHistoryEntry instance,
) => <String, dynamic>{
  'playerId': instance.playerId,
  'seasonYear': instance.seasonYear,
  'week': instance.week,
  'minutes': instance.minutes,
  'possibleMinutes': instance.possibleMinutes,
};

_SeasonMinutesAggregate _$SeasonMinutesAggregateFromJson(
  Map<String, dynamic> json,
) => _SeasonMinutesAggregate(
  playerId: json['playerId'] as String,
  seasonYear: (json['seasonYear'] as num).toInt(),
  actualMinutes: (json['actualMinutes'] as num?)?.toInt() ?? 0,
  possibleMinutes: (json['possibleMinutes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SeasonMinutesAggregateToJson(
  _SeasonMinutesAggregate instance,
) => <String, dynamic>{
  'playerId': instance.playerId,
  'seasonYear': instance.seasonYear,
  'actualMinutes': instance.actualMinutes,
  'possibleMinutes': instance.possibleMinutes,
};

_TeamPromise _$TeamPromiseFromJson(Map<String, dynamic> json) => _TeamPromise(
  id: json['id'] as String,
  playerId: json['playerId'] as String,
  kind: json['kind'] as String,
  createdSeasonYear: (json['createdSeasonYear'] as num).toInt(),
  createdWeek: (json['createdWeek'] as num).toInt(),
  weeksElapsed: (json['weeksElapsed'] as num?)?.toInt() ?? 0,
  durationWeeks: (json['durationWeeks'] as num?)?.toInt() ?? 4,
  requiredMinutesShare:
      (json['requiredMinutesShare'] as num?)?.toDouble() ?? 0.4,
);

Map<String, dynamic> _$TeamPromiseToJson(_TeamPromise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playerId': instance.playerId,
      'kind': instance.kind,
      'createdSeasonYear': instance.createdSeasonYear,
      'createdWeek': instance.createdWeek,
      'weeksElapsed': instance.weeksElapsed,
      'durationWeeks': instance.durationWeeks,
      'requiredMinutesShare': instance.requiredMinutesShare,
    };

_TeamTransferSituation _$TeamTransferSituationFromJson(
  Map<String, dynamic> json,
) => _TeamTransferSituation(
  id: json['id'] as String,
  playerId: json['playerId'] as String,
  kind: json['kind'] as String,
  createdSeasonYear: (json['createdSeasonYear'] as num).toInt(),
  createdWeek: (json['createdWeek'] as num).toInt(),
  weeksRemaining: (json['weeksRemaining'] as num?)?.toInt() ?? 4,
);

Map<String, dynamic> _$TeamTransferSituationToJson(
  _TeamTransferSituation instance,
) => <String, dynamic>{
  'id': instance.id,
  'playerId': instance.playerId,
  'kind': instance.kind,
  'createdSeasonYear': instance.createdSeasonYear,
  'createdWeek': instance.createdWeek,
  'weeksRemaining': instance.weeksRemaining,
};

_TeamEventState _$TeamEventStateFromJson(
  Map<String, dynamic> json,
) => _TeamEventState(
  promises:
      (json['promises'] as List<dynamic>?)
          ?.map((e) => TeamPromise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  transferSituations:
      (json['transferSituations'] as List<dynamic>?)
          ?.map(
            (e) => TeamTransferSituation.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  minutesHistory:
      (json['minutesHistory'] as List<dynamic>?)
          ?.map((e) => MinutesHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  seasonMinutes:
      (json['seasonMinutes'] as List<dynamic>?)
          ?.map(
            (e) => SeasonMinutesAggregate.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  modifiers:
      (json['modifiers'] as List<dynamic>?)
          ?.map((e) => TeamTimedModifier.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  cooldowns:
      (json['cooldowns'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  seasonFlags:
      (json['seasonFlags'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  pointValueMultipliers:
      (json['pointValueMultipliers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  publicCriticismRollMultiplier:
      (json['publicCriticismRollMultiplier'] as num?)?.toDouble() ?? 1.0,
  lowAtmosphereWeeks: (json['lowAtmosphereWeeks'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TeamEventStateToJson(_TeamEventState instance) =>
    <String, dynamic>{
      'promises': instance.promises,
      'transferSituations': instance.transferSituations,
      'minutesHistory': instance.minutesHistory,
      'seasonMinutes': instance.seasonMinutes,
      'modifiers': instance.modifiers,
      'cooldowns': instance.cooldowns,
      'seasonFlags': instance.seasonFlags,
      'pointValueMultipliers': instance.pointValueMultipliers,
      'publicCriticismRollMultiplier': instance.publicCriticismRollMultiplier,
      'lowAtmosphereWeeks': instance.lowAtmosphereWeeks,
    };
