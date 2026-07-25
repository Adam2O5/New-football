// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchContextImpl _$$MatchContextImplFromJson(Map<String, dynamic> json) =>
    _$MatchContextImpl(
      isDerby: json['isDerby'] as bool? ?? false,
      weather:
          $enumDecodeNullable(_$WeatherEnumMap, json['weather']) ??
          Weather.clear,
      stakes:
          $enumDecodeNullable(_$SeasonPhaseEnumMap, json['stakes']) ??
          SeasonPhase.regular,
      homeAdvantage: (json['homeAdvantage'] as num?)?.toDouble() ?? 0.05,
    );

Map<String, dynamic> _$$MatchContextImplToJson(_$MatchContextImpl instance) =>
    <String, dynamic>{
      'isDerby': instance.isDerby,
      'weather': _$WeatherEnumMap[instance.weather]!,
      'stakes': _$SeasonPhaseEnumMap[instance.stakes]!,
      'homeAdvantage': instance.homeAdvantage,
    };

const _$WeatherEnumMap = {
  Weather.clear: 'clear',
  Weather.rain: 'rain',
  Weather.snow: 'snow',
  Weather.heat: 'heat',
};

const _$SeasonPhaseEnumMap = {
  SeasonPhase.preseason: 'preseason',
  SeasonPhase.regular: 'regular',
  SeasonPhase.playIn: 'playIn',
  SeasonPhase.playoff: 'playoff',
  SeasonPhase.draft: 'draft',
  SeasonPhase.offseason: 'offseason',
};

_$MatchStateImpl _$$MatchStateImplFromJson(Map<String, dynamic> json) =>
    _$MatchStateImpl(
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

Map<String, dynamic> _$$MatchStateImplToJson(_$MatchStateImpl instance) =>
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
