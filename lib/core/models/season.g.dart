// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Season _$SeasonFromJson(Map<String, dynamic> json) => _Season(
  year: (json['year'] as num).toInt(),
  phase:
      $enumDecodeNullable(_$SeasonPhaseEnumMap, json['phase']) ??
      SeasonPhase.preseason,
  schedule:
      (json['schedule'] as List<dynamic>?)
          ?.map((e) => ScheduledMatch.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  standings:
      (json['standings'] as List<dynamic>?)
          ?.map((e) => ConferenceStandings.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  playInResults:
      (json['playInResults'] as List<dynamic>?)
          ?.map((e) => PlayInResult.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  playInProgress:
      (json['playInProgress'] as List<dynamic>?)
          ?.map((e) => PlayInProgress.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  playoffBrackets:
      (json['playoffBrackets'] as List<dynamic>?)
          ?.map((e) => PlayoffBracket.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  championTeamId: json['championTeamId'] as String?,
  championshipAtmosphereApplied:
      json['championshipAtmosphereApplied'] as bool? ?? false,
  playoffMissAtmosphereApplied:
      json['playoffMissAtmosphereApplied'] as bool? ?? false,
  draftState: json['draftState'] == null
      ? null
      : DraftState.fromJson(json['draftState'] as Map<String, dynamic>),
  awards: json['awards'] == null
      ? null
      : SeasonAwards.fromJson(json['awards'] as Map<String, dynamic>),
  staffGrowthDone: json['staffGrowthDone'] as bool? ?? false,
  playerRetirementsDone: json['playerRetirementsDone'] as bool? ?? false,
  nextTvCapResetSeason: (json['nextTvCapResetSeason'] as num?)?.toInt() ?? 0,
  nextTvCapIncreasePct: (json['nextTvCapIncreasePct'] as num?)?.toInt() ?? 0,
  capUpdateTvDone: json['capUpdateTvDone'] as bool? ?? false,
  combineDone: json['combineDone'] as bool? ?? false,
  finalMockDone: json['finalMockDone'] as bool? ?? false,
  faOpenDone: json['faOpenDone'] as bool? ?? false,
  scoutReportDone: json['scoutReportDone'] as bool? ?? false,
  tradeDeadlineAcked: json['tradeDeadlineAcked'] as bool? ?? false,
  nextClassGenerationDone: json['nextClassGenerationDone'] as bool? ?? false,
  postseasonFixtures:
      (json['postseasonFixtures'] as List<dynamic>?)
          ?.map((e) => ScheduledMatch.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ScheduledMatch>[],
);

Map<String, dynamic> _$SeasonToJson(_Season instance) => <String, dynamic>{
  'year': instance.year,
  'phase': _$SeasonPhaseEnumMap[instance.phase]!,
  'schedule': instance.schedule,
  'standings': instance.standings,
  'playInResults': instance.playInResults,
  'playInProgress': instance.playInProgress,
  'playoffBrackets': instance.playoffBrackets,
  'championTeamId': instance.championTeamId,
  'championshipAtmosphereApplied': instance.championshipAtmosphereApplied,
  'playoffMissAtmosphereApplied': instance.playoffMissAtmosphereApplied,
  'draftState': instance.draftState,
  'awards': instance.awards,
  'staffGrowthDone': instance.staffGrowthDone,
  'playerRetirementsDone': instance.playerRetirementsDone,
  'nextTvCapResetSeason': instance.nextTvCapResetSeason,
  'nextTvCapIncreasePct': instance.nextTvCapIncreasePct,
  'capUpdateTvDone': instance.capUpdateTvDone,
  'combineDone': instance.combineDone,
  'finalMockDone': instance.finalMockDone,
  'faOpenDone': instance.faOpenDone,
  'scoutReportDone': instance.scoutReportDone,
  'tradeDeadlineAcked': instance.tradeDeadlineAcked,
  'nextClassGenerationDone': instance.nextClassGenerationDone,
  'postseasonFixtures': instance.postseasonFixtures,
};

const _$SeasonPhaseEnumMap = {
  SeasonPhase.preseason: 'preseason',
  SeasonPhase.regular: 'regular',
  SeasonPhase.playIn: 'playIn',
  SeasonPhase.playoff: 'playoff',
  SeasonPhase.offseason: 'offseason',
};
