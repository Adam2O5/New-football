// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeagueStateImpl _$$LeagueStateImplFromJson(Map<String, dynamic> json) =>
    _$LeagueStateImpl(
      teams: (json['teams'] as List<dynamic>)
          .map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentSeason: Season.fromJson(
        json['currentSeason'] as Map<String, dynamic>,
      ),
      history:
          (json['history'] as List<dynamic>?)
              ?.map((e) => SeasonHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      difficulty:
          $enumDecodeNullable(_$DifficultyEnumMap, json['difficulty']) ??
          Difficulty.normal,
      playerTeamId: json['playerTeamId'] as String?,
      currentRound: (json['currentRound'] as num?)?.toInt() ?? 0,
      currentWeek: (json['currentWeek'] as num?)?.toInt() ?? 1,
      currentDay: (json['currentDay'] as num?)?.toInt() ?? 1,
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
    );

Map<String, dynamic> _$$LeagueStateImplToJson(_$LeagueStateImpl instance) =>
    <String, dynamic>{
      'teams': instance.teams,
      'currentSeason': instance.currentSeason,
      'history': instance.history,
      'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
      'playerTeamId': instance.playerTeamId,
      'currentRound': instance.currentRound,
      'currentWeek': instance.currentWeek,
      'currentDay': instance.currentDay,
      'inbox': instance.inbox,
      'messageSettings': instance.messageSettings,
      'staffFreeAgents': instance.staffFreeAgents,
      'freeAgents': instance.freeAgents,
    };

const _$DifficultyEnumMap = {
  Difficulty.easy: 'easy',
  Difficulty.normal: 'normal',
  Difficulty.hard: 'hard',
};
