// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchEventImpl _$$MatchEventImplFromJson(Map<String, dynamic> json) =>
    _$MatchEventImpl(
      type: $enumDecode(_$MatchEventTypeEnumMap, json['type']),
      minute: (json['minute'] as num).toInt(),
      teamId: json['teamId'] as String,
      playerId: json['playerId'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$MatchEventImplToJson(_$MatchEventImpl instance) =>
    <String, dynamic>{
      'type': _$MatchEventTypeEnumMap[instance.type]!,
      'minute': instance.minute,
      'teamId': instance.teamId,
      'playerId': instance.playerId,
      'description': instance.description,
    };

const _$MatchEventTypeEnumMap = {
  MatchEventType.goal: 'goal',
  MatchEventType.yellowCard: 'yellowCard',
  MatchEventType.redCard: 'redCard',
  MatchEventType.minorInjury: 'minorInjury',
  MatchEventType.majorInjury: 'majorInjury',
  MatchEventType.substitution: 'substitution',
  MatchEventType.scoredPenalty: 'scoredPenalty',
  MatchEventType.missedPenalty: 'missedPenalty',
  MatchEventType.halfTime: 'halfTime',
  MatchEventType.fullTime: 'fullTime',
};

_$MatchInjuryImpl _$$MatchInjuryImplFromJson(Map<String, dynamic> json) =>
    _$MatchInjuryImpl(
      teamId: json['teamId'] as String,
      playerId: json['playerId'] as String,
      injury: Injury.fromJson(json['injury'] as Map<String, dynamic>),
      playerInStartingXi: json['playerInStartingXi'] as bool,
      potentialLoss: json['potentialLoss'] as bool? ?? false,
    );

Map<String, dynamic> _$$MatchInjuryImplToJson(_$MatchInjuryImpl instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'playerId': instance.playerId,
      'injury': instance.injury,
      'playerInStartingXi': instance.playerInStartingXi,
      'potentialLoss': instance.potentialLoss,
    };

_$TeamMatchStatsImpl _$$TeamMatchStatsImplFromJson(Map<String, dynamic> json) =>
    _$TeamMatchStatsImpl(
      teamId: json['teamId'] as String,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      shots: (json['shots'] as num?)?.toInt() ?? 0,
      shotsOnTarget: (json['shotsOnTarget'] as num?)?.toInt() ?? 0,
      possession: (json['possession'] as num?)?.toInt() ?? 0,
      xg: (json['xg'] as num?)?.toDouble() ?? 0.0,
      corners: (json['corners'] as num?)?.toInt() ?? 0,
      fouls: (json['fouls'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellowCards'] as num?)?.toInt() ?? 0,
      redCards: (json['redCards'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TeamMatchStatsImplToJson(
  _$TeamMatchStatsImpl instance,
) => <String, dynamic>{
  'teamId': instance.teamId,
  'goals': instance.goals,
  'shots': instance.shots,
  'shotsOnTarget': instance.shotsOnTarget,
  'possession': instance.possession,
  'xg': instance.xg,
  'corners': instance.corners,
  'fouls': instance.fouls,
  'yellowCards': instance.yellowCards,
  'redCards': instance.redCards,
};

_$MatchResultImpl _$$MatchResultImplFromJson(
  Map<String, dynamic> json,
) => _$MatchResultImpl(
  homeTeamId: json['homeTeamId'] as String,
  awayTeamId: json['awayTeamId'] as String,
  homeGoals: (json['homeGoals'] as num).toInt(),
  awayGoals: (json['awayGoals'] as num).toInt(),
  homeStats: TeamMatchStats.fromJson(json['homeStats'] as Map<String, dynamic>),
  awayStats: TeamMatchStats.fromJson(json['awayStats'] as Map<String, dynamic>),
  playerStats:
      (json['playerStats'] as List<dynamic>?)
          ?.map((e) => PlayerMatchStats.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  injuries:
      (json['injuries'] as List<dynamic>?)
          ?.map((e) => MatchInjury.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MatchResultImplToJson(_$MatchResultImpl instance) =>
    <String, dynamic>{
      'homeTeamId': instance.homeTeamId,
      'awayTeamId': instance.awayTeamId,
      'homeGoals': instance.homeGoals,
      'awayGoals': instance.awayGoals,
      'homeStats': instance.homeStats,
      'awayStats': instance.awayStats,
      'playerStats': instance.playerStats,
      'events': instance.events,
      'injuries': instance.injuries,
    };

_$MatchSetupImpl _$$MatchSetupImplFromJson(Map<String, dynamic> json) =>
    _$MatchSetupImpl(
      homeTeamId: json['homeTeamId'] as String,
      awayTeamId: json['awayTeamId'] as String,
      homeLineup: (json['homeLineup'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      awayLineup: (json['awayLineup'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeTactics: TacticsSetup.fromJson(
        json['homeTactics'] as Map<String, dynamic>,
      ),
      awayTactics: TacticsSetup.fromJson(
        json['awayTactics'] as Map<String, dynamic>,
      ),
      isHomeAdvantage: json['isHomeAdvantage'] as bool? ?? false,
      roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MatchSetupImplToJson(_$MatchSetupImpl instance) =>
    <String, dynamic>{
      'homeTeamId': instance.homeTeamId,
      'awayTeamId': instance.awayTeamId,
      'homeLineup': instance.homeLineup,
      'awayLineup': instance.awayLineup,
      'homeTactics': instance.homeTactics,
      'awayTactics': instance.awayTactics,
      'isHomeAdvantage': instance.isHomeAdvantage,
      'roundNumber': instance.roundNumber,
    };

_$ScheduledMatchImpl _$$ScheduledMatchImplFromJson(Map<String, dynamic> json) =>
    _$ScheduledMatchImpl(
      id: json['id'] as String,
      homeTeamId: json['homeTeamId'] as String,
      awayTeamId: json['awayTeamId'] as String,
      round: (json['round'] as num).toInt(),
      result: json['result'] == null
          ? null
          : MatchResult.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ScheduledMatchImplToJson(
  _$ScheduledMatchImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'homeTeamId': instance.homeTeamId,
  'awayTeamId': instance.awayTeamId,
  'round': instance.round,
  'result': instance.result,
};

_$PlayoffSeriesImpl _$$PlayoffSeriesImplFromJson(Map<String, dynamic> json) =>
    _$PlayoffSeriesImpl(
      id: json['id'] as String,
      higherSeedTeamId: json['higherSeedTeamId'] as String,
      lowerSeedTeamId: json['lowerSeedTeamId'] as String,
      winsNeeded: (json['winsNeeded'] as num).toInt(),
      higherSeedWins: (json['higherSeedWins'] as num?)?.toInt() ?? 0,
      lowerSeedWins: (json['lowerSeedWins'] as num?)?.toInt() ?? 0,
      games:
          (json['games'] as List<dynamic>?)
              ?.map((e) => MatchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      winnerTeamId: json['winnerTeamId'] as String?,
    );

Map<String, dynamic> _$$PlayoffSeriesImplToJson(_$PlayoffSeriesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'higherSeedTeamId': instance.higherSeedTeamId,
      'lowerSeedTeamId': instance.lowerSeedTeamId,
      'winsNeeded': instance.winsNeeded,
      'higherSeedWins': instance.higherSeedWins,
      'lowerSeedWins': instance.lowerSeedWins,
      'games': instance.games,
      'winnerTeamId': instance.winnerTeamId,
    };
