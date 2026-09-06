// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamAiConfig _$TeamAiConfigFromJson(Map<String, dynamic> json) =>
    _TeamAiConfig(
      aggressionLevel: (json['aggressionLevel'] as num?)?.toDouble() ?? 0.5,
      riskTolerance: (json['riskTolerance'] as num?)?.toDouble() ?? 0.5,
      playerPatternMemory:
          json['playerPatternMemory'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$TeamAiConfigToJson(_TeamAiConfig instance) =>
    <String, dynamic>{
      'aggressionLevel': instance.aggressionLevel,
      'riskTolerance': instance.riskTolerance,
      'playerPatternMemory': instance.playerPatternMemory,
    };

_TeamWeeklyHistory _$TeamWeeklyHistoryFromJson(Map<String, dynamic> json) =>
    _TeamWeeklyHistory(
      seasonYear: (json['seasonYear'] as num).toInt(),
      week: (json['week'] as num).toInt(),
      atmosphereDelta: (json['atmosphereDelta'] as num?)?.toInt() ?? 0,
      chemistryDelta: (json['chemistryDelta'] as num?)?.toDouble() ?? 0.0,
      atmosphere: (json['atmosphere'] as num).toInt(),
      chemistry: (json['chemistry'] as num).toDouble(),
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TeamWeeklyHistoryToJson(_TeamWeeklyHistory instance) =>
    <String, dynamic>{
      'seasonYear': instance.seasonYear,
      'week': instance.week,
      'atmosphereDelta': instance.atmosphereDelta,
      'chemistryDelta': instance.chemistryDelta,
      'atmosphere': instance.atmosphere,
      'chemistry': instance.chemistry,
      'wins': instance.wins,
      'draws': instance.draws,
      'losses': instance.losses,
    };

_TeamSeasonStats _$TeamSeasonStatsFromJson(Map<String, dynamic> json) =>
    _TeamSeasonStats(
      year: (json['year'] as num).toInt(),
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      shots: (json['shots'] as num?)?.toInt() ?? 0,
      shotsOnTarget: (json['shotsOnTarget'] as num?)?.toInt() ?? 0,
      possessionTotal: (json['possessionTotal'] as num?)?.toInt() ?? 0,
      xg: (json['xg'] as num?)?.toDouble() ?? 0.0,
      passes: (json['passes'] as num?)?.toInt() ?? 0,
      passAccuracy: (json['passAccuracy'] as num?)?.toDouble() ?? 0.0,
      duelsWon: (json['duelsWon'] as num?)?.toInt() ?? 0,
      offsides: (json['offsides'] as num?)?.toInt() ?? 0,
      corners: (json['corners'] as num?)?.toInt() ?? 0,
      fouls: (json['fouls'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellowCards'] as num?)?.toInt() ?? 0,
      redCards: (json['redCards'] as num?)?.toInt() ?? 0,
      saves: (json['saves'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TeamSeasonStatsToJson(_TeamSeasonStats instance) =>
    <String, dynamic>{
      'year': instance.year,
      'matches': instance.matches,
      'goals': instance.goals,
      'shots': instance.shots,
      'shotsOnTarget': instance.shotsOnTarget,
      'possessionTotal': instance.possessionTotal,
      'xg': instance.xg,
      'passes': instance.passes,
      'passAccuracy': instance.passAccuracy,
      'duelsWon': instance.duelsWon,
      'offsides': instance.offsides,
      'corners': instance.corners,
      'fouls': instance.fouls,
      'yellowCards': instance.yellowCards,
      'redCards': instance.redCards,
      'saves': instance.saves,
    };

_Team _$TeamFromJson(Map<String, dynamic> json) => _Team(
  id: json['id'] as String,
  name: json['name'] as String,
  city: json['city'] as String,
  conference: $enumDecode(_$ConferenceEnumMap, json['conference']),
  roster: (json['roster'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  finance: TeamFinance.fromJson(json['finance'] as Map<String, dynamic>),
  tactics: json['tactics'] == null
      ? const TacticsSetup()
      : TacticsSetup.fromJson(json['tactics'] as Map<String, dynamic>),
  lineupPlayerIds:
      (json['lineupPlayerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  benchPlayerIds:
      (json['benchPlayerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  atmosphere: (json['atmosphere'] as num?)?.toInt() ?? 50,
  chemistry: (json['chemistry'] as num?)?.toDouble() ?? 50.0,
  weeklyHistory:
      (json['weeklyHistory'] as List<dynamic>?)
          ?.map((e) => TeamWeeklyHistory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  seasonStats:
      (json['seasonStats'] as List<dynamic>?)
          ?.map((e) => TeamSeasonStats.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  recentMatchResults:
      (json['recentMatchResults'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  chemistryAppearances:
      (json['chemistryAppearances'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  eventState: json['eventState'] == null
      ? const TeamEventState()
      : TeamEventState.fromJson(json['eventState'] as Map<String, dynamic>),
  staff: json['staff'] == null
      ? const TeamStaff()
      : TeamStaff.fromJson(json['staff'] as Map<String, dynamic>),
  scouting: json['scouting'] == null
      ? const TeamScouting()
      : TeamScouting.fromJson(json['scouting'] as Map<String, dynamic>),
  ownedPicks:
      (json['ownedPicks'] as List<dynamic>?)
          ?.map((e) => DraftPick.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  ai: json['ai'] == null
      ? null
      : TeamAiConfig.fromJson(json['ai'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TeamToJson(_Team instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'city': instance.city,
  'conference': _$ConferenceEnumMap[instance.conference]!,
  'roster': instance.roster,
  'finance': instance.finance,
  'tactics': instance.tactics,
  'lineupPlayerIds': instance.lineupPlayerIds,
  'benchPlayerIds': instance.benchPlayerIds,
  'atmosphere': instance.atmosphere,
  'chemistry': instance.chemistry,
  'weeklyHistory': instance.weeklyHistory,
  'seasonStats': instance.seasonStats,
  'recentMatchResults': instance.recentMatchResults,
  'chemistryAppearances': instance.chemistryAppearances,
  'eventState': instance.eventState,
  'staff': instance.staff,
  'scouting': instance.scouting,
  'ownedPicks': instance.ownedPicks,
  'ai': instance.ai,
};

const _$ConferenceEnumMap = {
  Conference.europe: 'europe',
  Conference.restOfTheWorld: 'restOfTheWorld',
};
