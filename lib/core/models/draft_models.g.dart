// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Prospect _$ProspectFromJson(Map<String, dynamic> json) => _Prospect(
  id: json['id'] as String,
  name: json['name'] as String,
  nationality: $enumDecode(_$NationalityEnumMap, json['nationality']),
  position: $enumDecode(_$PositionEnumMap, json['position']),
  age: (json['age'] as num).toInt(),
  attributes: PlayerAttributes.fromJson(
    json['attributes'] as Map<String, dynamic>,
  ),
  scoutGrade: (json['scoutGrade'] as num?)?.toInt() ?? 0,
  combineScore: (json['combineScore'] as num?)?.toInt() ?? 0,
  potentialStars: (json['potentialStars'] as num).toDouble(),
  heightCm: (json['heightCm'] as num).toInt(),
  injuryProne: (json['injuryProne'] as num).toInt(),
  determination: (json['determination'] as num).toInt(),
  personality: $enumDecode(_$PlayerPersonalityEnumMap, json['personality']),
  optimalRole: AssignedRole.fromJson(
    json['optimalRole'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ProspectToJson(_Prospect instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nationality': _$NationalityEnumMap[instance.nationality]!,
  'position': _$PositionEnumMap[instance.position]!,
  'age': instance.age,
  'attributes': instance.attributes,
  'scoutGrade': instance.scoutGrade,
  'combineScore': instance.combineScore,
  'potentialStars': instance.potentialStars,
  'heightCm': instance.heightCm,
  'injuryProne': instance.injuryProne,
  'determination': instance.determination,
  'personality': _$PlayerPersonalityEnumMap[instance.personality]!,
  'optimalRole': instance.optimalRole,
};

const _$NationalityEnumMap = {
  Nationality.poland: 'poland',
  Nationality.brazil: 'brazil',
  Nationality.france: 'france',
  Nationality.spain: 'spain',
  Nationality.england: 'england',
  Nationality.germany: 'germany',
  Nationality.argentina: 'argentina',
  Nationality.portugal: 'portugal',
  Nationality.italy: 'italy',
  Nationality.netherlands: 'netherlands',
  Nationality.belgium: 'belgium',
  Nationality.croatia: 'croatia',
  Nationality.nigeria: 'nigeria',
  Nationality.senegal: 'senegal',
  Nationality.japan: 'japan',
  Nationality.usa: 'usa',
  Nationality.mexico: 'mexico',
  Nationality.morocco: 'morocco',
  Nationality.colombia: 'colombia',
  Nationality.switzerland: 'switzerland',
  Nationality.uruguay: 'uruguay',
  Nationality.egypt: 'egypt',
  Nationality.china: 'china',
};

const _$PositionEnumMap = {
  Position.gk: 'gk',
  Position.cb: 'cb',
  Position.lb: 'lb',
  Position.rb: 'rb',
  Position.lwb: 'lwb',
  Position.rwb: 'rwb',
  Position.cdm: 'cdm',
  Position.cm: 'cm',
  Position.cam: 'cam',
  Position.lw: 'lw',
  Position.rw: 'rw',
  Position.st: 'st',
};

const _$PlayerPersonalityEnumMap = {
  PlayerPersonality.professional: 'professional',
  PlayerPersonality.leader: 'leader',
  PlayerPersonality.temperamental: 'temperamental',
  PlayerPersonality.ambitious: 'ambitious',
  PlayerPersonality.loyal: 'loyal',
  PlayerPersonality.balanced: 'balanced',
};

_LotteryResult _$LotteryResultFromJson(Map<String, dynamic> json) =>
    _LotteryResult(
      teamId: json['teamId'] as String,
      originalRank: (json['originalRank'] as num).toInt(),
      assignedPick: (json['assignedPick'] as num).toInt(),
      oddsForFirstPick: (json['oddsForFirstPick'] as num).toDouble(),
    );

Map<String, dynamic> _$LotteryResultToJson(_LotteryResult instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'originalRank': instance.originalRank,
      'assignedPick': instance.assignedPick,
      'oddsForFirstPick': instance.oddsForFirstPick,
    };

_DraftClass _$DraftClassFromJson(Map<String, dynamic> json) => _DraftClass(
  year: (json['year'] as num).toInt(),
  prospects:
      (json['prospects'] as List<dynamic>?)
          ?.map((e) => Prospect.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DraftClassToJson(_DraftClass instance) =>
    <String, dynamic>{'year': instance.year, 'prospects': instance.prospects};

_DraftState _$DraftStateFromJson(Map<String, dynamic> json) => _DraftState(
  year: (json['year'] as num).toInt(),
  order:
      (json['order'] as List<dynamic>?)
          ?.map((e) => DraftPick.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  completedPicks:
      (json['completedPicks'] as List<dynamic>?)
          ?.map((e) => DraftPick.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lotteryResults:
      (json['lotteryResults'] as List<dynamic>?)
          ?.map((e) => LotteryResult.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  draftClass: DraftClass.fromJson(json['draftClass'] as Map<String, dynamic>),
  currentPickIndex: (json['currentPickIndex'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DraftStateToJson(_DraftState instance) =>
    <String, dynamic>{
      'year': instance.year,
      'order': instance.order,
      'completedPicks': instance.completedPicks,
      'lotteryResults': instance.lotteryResults,
      'draftClass': instance.draftClass,
      'currentPickIndex': instance.currentPickIndex,
    };

_PlayInResult _$PlayInResultFromJson(Map<String, dynamic> json) =>
    _PlayInResult(
      conference: $enumDecode(_$ConferenceEnumMap, json['conference']),
      seed7TeamId: json['seed7TeamId'] as String,
      seed8TeamId: json['seed8TeamId'] as String,
      game7v8: MatchResult.fromJson(json['game7v8'] as Map<String, dynamic>),
      game9v10: MatchResult.fromJson(json['game9v10'] as Map<String, dynamic>),
      gameFinal: MatchResult.fromJson(
        json['gameFinal'] as Map<String, dynamic>,
      ),
      playoffSeed7TeamId: json['playoffSeed7TeamId'] as String,
      playoffSeed8TeamId: json['playoffSeed8TeamId'] as String,
    );

Map<String, dynamic> _$PlayInResultToJson(_PlayInResult instance) =>
    <String, dynamic>{
      'conference': _$ConferenceEnumMap[instance.conference]!,
      'seed7TeamId': instance.seed7TeamId,
      'seed8TeamId': instance.seed8TeamId,
      'game7v8': instance.game7v8,
      'game9v10': instance.game9v10,
      'gameFinal': instance.gameFinal,
      'playoffSeed7TeamId': instance.playoffSeed7TeamId,
      'playoffSeed8TeamId': instance.playoffSeed8TeamId,
    };

const _$ConferenceEnumMap = {
  Conference.europe: 'europe',
  Conference.restOfTheWorld: 'restOfTheWorld',
};

_PlayInProgress _$PlayInProgressFromJson(Map<String, dynamic> json) =>
    _PlayInProgress(
      conference: $enumDecode(_$ConferenceEnumMap, json['conference']),
      seed7TeamId: json['seed7TeamId'] as String,
      seed8TeamId: json['seed8TeamId'] as String,
      seed9TeamId: json['seed9TeamId'] as String,
      seed10TeamId: json['seed10TeamId'] as String,
      game7v8: json['game7v8'] == null
          ? null
          : MatchResult.fromJson(json['game7v8'] as Map<String, dynamic>),
      game9v10: json['game9v10'] == null
          ? null
          : MatchResult.fromJson(json['game9v10'] as Map<String, dynamic>),
      gameFinal: json['gameFinal'] == null
          ? null
          : MatchResult.fromJson(json['gameFinal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlayInProgressToJson(_PlayInProgress instance) =>
    <String, dynamic>{
      'conference': _$ConferenceEnumMap[instance.conference]!,
      'seed7TeamId': instance.seed7TeamId,
      'seed8TeamId': instance.seed8TeamId,
      'seed9TeamId': instance.seed9TeamId,
      'seed10TeamId': instance.seed10TeamId,
      'game7v8': instance.game7v8,
      'game9v10': instance.game9v10,
      'gameFinal': instance.gameFinal,
    };

_PlayoffBracket _$PlayoffBracketFromJson(Map<String, dynamic> json) =>
    _PlayoffBracket(
      conference: $enumDecode(_$ConferenceEnumMap, json['conference']),
      quarterFinals:
          (json['quarterFinals'] as List<dynamic>?)
              ?.map((e) => PlayoffSeries.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      semiFinals:
          (json['semiFinals'] as List<dynamic>?)
              ?.map((e) => PlayoffSeries.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      conferenceFinal:
          (json['conferenceFinal'] as List<dynamic>?)
              ?.map((e) => PlayoffSeries.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      leagueFinal: json['leagueFinal'] == null
          ? null
          : PlayoffSeries.fromJson(json['leagueFinal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlayoffBracketToJson(_PlayoffBracket instance) =>
    <String, dynamic>{
      'conference': _$ConferenceEnumMap[instance.conference]!,
      'quarterFinals': instance.quarterFinals,
      'semiFinals': instance.semiFinals,
      'conferenceFinal': instance.conferenceFinal,
      'leagueFinal': instance.leagueFinal,
    };

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
  nextDraftState: json['nextDraftState'] == null
      ? null
      : DraftState.fromJson(json['nextDraftState'] as Map<String, dynamic>),
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
  'nextDraftState': instance.nextDraftState,
};

const _$SeasonPhaseEnumMap = {
  SeasonPhase.preseason: 'preseason',
  SeasonPhase.regular: 'regular',
  SeasonPhase.playIn: 'playIn',
  SeasonPhase.playoff: 'playoff',
  SeasonPhase.offseason: 'offseason',
};

_SeasonHistory _$SeasonHistoryFromJson(Map<String, dynamic> json) =>
    _SeasonHistory(
      year: (json['year'] as num).toInt(),
      finalStandings: (json['finalStandings'] as List<dynamic>)
          .map((e) => ConferenceStandings.fromJson(e as Map<String, dynamic>))
          .toList(),
      championTeamId: json['championTeamId'] as String?,
      draftPicks:
          (json['draftPicks'] as List<dynamic>?)
              ?.map((e) => DraftPick.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SeasonHistoryToJson(_SeasonHistory instance) =>
    <String, dynamic>{
      'year': instance.year,
      'finalStandings': instance.finalStandings,
      'championTeamId': instance.championTeamId,
      'draftPicks': instance.draftPicks,
    };
