// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchContext _$MatchContextFromJson(Map<String, dynamic> json) =>
    _MatchContext(
      homeTeamId: json['homeTeamId'] as String? ?? '',
      awayTeamId: json['awayTeamId'] as String? ?? '',
      weather:
          $enumDecodeNullable(_$WeatherEnumMap, json['weather']) ??
          Weather.clear,
      temperatureC: (json['temperatureC'] as num?)?.toInt() ?? 0,
      isDerby: json['isDerby'] as bool? ?? false,
      stake:
          $enumDecodeNullable(_$MatchStakeEnumMap, json['stake']) ??
          MatchStake.regular,
      refereeStrictness: (json['refereeStrictness'] as num?)?.toDouble() ?? 1.0,
      crowdIntensity: (json['crowdIntensity'] as num?)?.toInt() ?? 0,
      homeMatchInWeek: (json['homeMatchInWeek'] as num?)?.toInt() ?? 1,
      awayMatchInWeek: (json['awayMatchInWeek'] as num?)?.toInt() ?? 1,
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      homeAdvantage: (json['homeAdvantage'] as num?)?.toDouble() ?? 0.05,
    );

Map<String, dynamic> _$MatchContextToJson(_MatchContext instance) =>
    <String, dynamic>{
      'homeTeamId': instance.homeTeamId,
      'awayTeamId': instance.awayTeamId,
      'weather': _$WeatherEnumMap[instance.weather]!,
      'temperatureC': instance.temperatureC,
      'isDerby': instance.isDerby,
      'stake': _$MatchStakeEnumMap[instance.stake]!,
      'refereeStrictness': instance.refereeStrictness,
      'crowdIntensity': instance.crowdIntensity,
      'homeMatchInWeek': instance.homeMatchInWeek,
      'awayMatchInWeek': instance.awayMatchInWeek,
      'seed': instance.seed,
      'homeAdvantage': instance.homeAdvantage,
    };

const _$WeatherEnumMap = {
  Weather.clear: 'clear',
  Weather.overcast: 'overcast',
  Weather.rain: 'rain',
  Weather.heavyRain: 'heavyRain',
  Weather.wind: 'wind',
  Weather.snow: 'snow',
  Weather.heat: 'heat',
  Weather.cold: 'cold',
};

const _$MatchStakeEnumMap = {
  MatchStake.regular: 'regular',
  MatchStake.playIn: 'playIn',
  MatchStake.playoff: 'playoff',
  MatchStake.playoffElimination: 'playoffElimination',
  MatchStake.leagueFinal: 'leagueFinal',
};

_MatchState _$MatchStateFromJson(Map<String, dynamic> json) => _MatchState(
  minute: (json['minute'] as num?)?.toInt() ?? 0,
  homeGoals: (json['homeGoals'] as num?)?.toInt() ?? 0,
  awayGoals: (json['awayGoals'] as num?)?.toInt() ?? 0,
  homeLineup:
      (json['homeLineup'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  awayLineup:
      (json['awayLineup'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  homeBench:
      (json['homeBench'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  awayBench:
      (json['awayBench'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  homeTactics: json['homeTactics'] == null
      ? const TacticsSetup()
      : TacticsSetup.fromJson(json['homeTactics'] as Map<String, dynamic>),
  awayTactics: json['awayTactics'] == null
      ? const TacticsSetup()
      : TacticsSetup.fromJson(json['awayTactics'] as Map<String, dynamic>),
  yellowCardCounts:
      (json['yellowCardCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  sentOffPlayerIds:
      (json['sentOffPlayerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  injuriesThisMatch:
      (json['injuriesThisMatch'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  momentum: (json['momentum'] as num?)?.toDouble() ?? 0.0,
  moraleModHome: (json['moraleModHome'] as num?)?.toDouble() ?? 0.0,
  moraleModAway: (json['moraleModAway'] as num?)?.toDouble() ?? 0.0,
  context: json['context'] == null
      ? const MatchContext()
      : MatchContext.fromJson(json['context'] as Map<String, dynamic>),
  rngSeed: (json['rngSeed'] as num?)?.toInt(),
);

Map<String, dynamic> _$MatchStateToJson(_MatchState instance) =>
    <String, dynamic>{
      'minute': instance.minute,
      'homeGoals': instance.homeGoals,
      'awayGoals': instance.awayGoals,
      'homeLineup': instance.homeLineup,
      'awayLineup': instance.awayLineup,
      'homeBench': instance.homeBench,
      'awayBench': instance.awayBench,
      'homeTactics': instance.homeTactics,
      'awayTactics': instance.awayTactics,
      'yellowCardCounts': instance.yellowCardCounts,
      'sentOffPlayerIds': instance.sentOffPlayerIds,
      'injuriesThisMatch': instance.injuriesThisMatch,
      'momentum': instance.momentum,
      'moraleModHome': instance.moraleModHome,
      'moraleModAway': instance.moraleModAway,
      'context': instance.context,
      'rngSeed': instance.rngSeed,
    };
