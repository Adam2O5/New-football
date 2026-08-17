// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_awards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SeasonAwards _$SeasonAwardsFromJson(Map<String, dynamic> json) =>
    _SeasonAwards(
      year: (json['year'] as num).toInt(),
      mvpPlayerId: json['mvpPlayerId'] as String?,
      rotyPlayerId: json['rotyPlayerId'] as String?,
      dpoyPlayerId: json['dpoyPlayerId'] as String?,
      topScorerPlayerId: json['topScorerPlayerId'] as String?,
      topAssistPlayerId: json['topAssistPlayerId'] as String?,
      bestGkPlayerId: json['bestGkPlayerId'] as String?,
      coachOfYearTeamId: json['coachOfYearTeamId'] as String?,
      teamOfSeason:
          (json['teamOfSeason'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$TeamOfSeasonSlotEnumMap, k),
              e as String,
            ),
          ) ??
          const {},
      championTeamId: json['championTeamId'] as String?,
    );

Map<String, dynamic> _$SeasonAwardsToJson(_SeasonAwards instance) =>
    <String, dynamic>{
      'year': instance.year,
      'mvpPlayerId': instance.mvpPlayerId,
      'rotyPlayerId': instance.rotyPlayerId,
      'dpoyPlayerId': instance.dpoyPlayerId,
      'topScorerPlayerId': instance.topScorerPlayerId,
      'topAssistPlayerId': instance.topAssistPlayerId,
      'bestGkPlayerId': instance.bestGkPlayerId,
      'coachOfYearTeamId': instance.coachOfYearTeamId,
      'teamOfSeason': instance.teamOfSeason.map(
        (k, e) => MapEntry(_$TeamOfSeasonSlotEnumMap[k]!, e),
      ),
      'championTeamId': instance.championTeamId,
    };

const _$TeamOfSeasonSlotEnumMap = {
  TeamOfSeasonSlot.gk: 'gk',
  TeamOfSeasonSlot.lb: 'lb',
  TeamOfSeasonSlot.cb1: 'cb1',
  TeamOfSeasonSlot.cb2: 'cb2',
  TeamOfSeasonSlot.rb: 'rb',
  TeamOfSeasonSlot.mid1: 'mid1',
  TeamOfSeasonSlot.mid2: 'mid2',
  TeamOfSeasonSlot.mid3: 'mid3',
  TeamOfSeasonSlot.lw: 'lw',
  TeamOfSeasonSlot.st: 'st',
  TeamOfSeasonSlot.rw: 'rw',
};
