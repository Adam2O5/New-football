// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerSeasonStats _$PlayerSeasonStatsFromJson(Map<String, dynamic> json) =>
    _PlayerSeasonStats(
      year: (json['year'] as num).toInt(),
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      appearances: (json['appearances'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellowCards'] as num?)?.toInt() ?? 0,
      redCards: (json['redCards'] as num?)?.toInt() ?? 0,
      shots: (json['shots'] as num?)?.toInt() ?? 0,
      shotsOnTarget: (json['shotsOnTarget'] as num?)?.toInt() ?? 0,
      xg: (json['xg'] as num?)?.toDouble() ?? 0.0,
      passes: (json['passes'] as num?)?.toInt() ?? 0,
      passAccuracy: (json['passAccuracy'] as num?)?.toDouble() ?? 0.0,
      duelsWon: (json['duelsWon'] as num?)?.toInt() ?? 0,
      offsides: (json['offsides'] as num?)?.toInt() ?? 0,
      corners: (json['corners'] as num?)?.toInt() ?? 0,
      tackles: (json['tackles'] as num?)?.toInt() ?? 0,
      interceptions: (json['interceptions'] as num?)?.toInt() ?? 0,
      cleanSheets: (json['cleanSheets'] as num?)?.toInt() ?? 0,
      saves: (json['saves'] as num?)?.toInt() ?? 0,
      shotsFaced: (json['shotsFaced'] as num?)?.toInt() ?? 0,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 6.0,
    );

Map<String, dynamic> _$PlayerSeasonStatsToJson(_PlayerSeasonStats instance) =>
    <String, dynamic>{
      'year': instance.year,
      'minutes': instance.minutes,
      'goals': instance.goals,
      'assists': instance.assists,
      'appearances': instance.appearances,
      'yellowCards': instance.yellowCards,
      'redCards': instance.redCards,
      'shots': instance.shots,
      'shotsOnTarget': instance.shotsOnTarget,
      'xg': instance.xg,
      'passes': instance.passes,
      'passAccuracy': instance.passAccuracy,
      'duelsWon': instance.duelsWon,
      'offsides': instance.offsides,
      'corners': instance.corners,
      'tackles': instance.tackles,
      'interceptions': instance.interceptions,
      'cleanSheets': instance.cleanSheets,
      'saves': instance.saves,
      'shotsFaced': instance.shotsFaced,
      'ratingAvg': instance.ratingAvg,
    };

_PlayerHidden _$PlayerHiddenFromJson(Map<String, dynamic> json) =>
    _PlayerHidden(
      injuryProne: (json['injuryProne'] as num).toInt(),
      determination: (json['determination'] as num).toInt(),
      overallProgress: (json['overallProgress'] as num?)?.toDouble() ?? 0.0,
      growthRate: (json['growthRate'] as num?)?.toDouble() ?? 1.0,
      developmentOutcome: $enumDecode(
        _$DevelopmentOutcomeEnumMap,
        json['developmentOutcome'],
      ),
      developmentCeilingStars:
          (json['developmentCeilingStars'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$PlayerHiddenToJson(_PlayerHidden instance) =>
    <String, dynamic>{
      'injuryProne': instance.injuryProne,
      'determination': instance.determination,
      'overallProgress': instance.overallProgress,
      'growthRate': instance.growthRate,
      'developmentOutcome':
          _$DevelopmentOutcomeEnumMap[instance.developmentOutcome]!,
      'developmentCeilingStars': instance.developmentCeilingStars,
    };

const _$DevelopmentOutcomeEnumMap = {
  DevelopmentOutcome.exceed: 'exceed',
  DevelopmentOutcome.hit: 'hit',
  DevelopmentOutcome.under: 'under',
};

_PlayerState _$PlayerStateFromJson(Map<String, dynamic> json) => _PlayerState(
  stamina: (json['stamina'] as num?)?.toInt() ?? 100,
  form: (json['form'] as num?)?.toDouble() ?? 5.0,
  injury: json['injury'] == null
      ? null
      : Injury.fromJson(json['injury'] as Map<String, dynamic>),
  regularSeasonYellowCards:
      (json['regularSeasonYellowCards'] as num?)?.toInt() ?? 0,
  playoffYellowCards: (json['playoffYellowCards'] as num?)?.toInt() ?? 0,
  suspensionGamesRemaining:
      (json['suspensionGamesRemaining'] as num?)?.toInt() ?? 0,
  role: json['role'] == null
      ? const AssignedRole.cm()
      : AssignedRole.fromJson(json['role'] as Map<String, dynamic>),
  seasonsWithTeam: (json['seasonsWithTeam'] as num?)?.toInt() ?? 0,
  minutesThisWeek: (json['minutesThisWeek'] as num?)?.toInt() ?? 0,
  lastDevelopmentOvrDelta:
      (json['lastDevelopmentOvrDelta'] as num?)?.toInt() ?? 0,
  lastDevelopmentProgressDelta:
      (json['lastDevelopmentProgressDelta'] as num?)?.toDouble() ?? 0.0,
  eventState: json['eventState'] == null
      ? const PlayerEventState()
      : PlayerEventState.fromJson(json['eventState'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlayerStateToJson(_PlayerState instance) =>
    <String, dynamic>{
      'stamina': instance.stamina,
      'form': instance.form,
      'injury': instance.injury,
      'regularSeasonYellowCards': instance.regularSeasonYellowCards,
      'playoffYellowCards': instance.playoffYellowCards,
      'suspensionGamesRemaining': instance.suspensionGamesRemaining,
      'role': instance.role,
      'seasonsWithTeam': instance.seasonsWithTeam,
      'minutesThisWeek': instance.minutesThisWeek,
      'lastDevelopmentOvrDelta': instance.lastDevelopmentOvrDelta,
      'lastDevelopmentProgressDelta': instance.lastDevelopmentProgressDelta,
      'eventState': instance.eventState,
    };

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  name: json['name'] as String,
  position: $enumDecode(_$PositionEnumMap, json['position']),
  nationality: $enumDecode(_$NationalityEnumMap, json['nationality']),
  age: (json['age'] as num).toInt(),
  attributes: PlayerAttributes.fromJson(
    json['attributes'] as Map<String, dynamic>,
  ),
  contract: Contract.fromJson(json['contract'] as Map<String, dynamic>),
  personality: $enumDecode(_$PlayerPersonalityEnumMap, json['personality']),
  potentialStars: (json['potentialStars'] as num).toDouble(),
  heightCm: (json['heightCm'] as num).toInt(),
  state: PlayerState.fromJson(json['state'] as Map<String, dynamic>),
  hidden: PlayerHidden.fromJson(json['hidden'] as Map<String, dynamic>),
  seasonStats:
      (json['seasonStats'] as List<dynamic>?)
          ?.map((e) => PlayerSeasonStats.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  pointValue: (json['pointValue'] as num?)?.toInt() ?? 0,
  optimalRole: AssignedRole.fromJson(
    json['optimalRole'] as Map<String, dynamic>,
  ),
  previousOvr: (json['previousOvr'] as num?)?.toInt(),
  seasonStartOvr: (json['seasonStartOvr'] as num?)?.toDouble(),
  previousPotential: (json['previousPotential'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'position': _$PositionEnumMap[instance.position]!,
  'nationality': _$NationalityEnumMap[instance.nationality]!,
  'age': instance.age,
  'attributes': instance.attributes,
  'contract': instance.contract,
  'personality': _$PlayerPersonalityEnumMap[instance.personality]!,
  'potentialStars': instance.potentialStars,
  'heightCm': instance.heightCm,
  'state': instance.state,
  'hidden': instance.hidden,
  'seasonStats': instance.seasonStats,
  'pointValue': instance.pointValue,
  'optimalRole': instance.optimalRole,
  'previousOvr': instance.previousOvr,
  'seasonStartOvr': instance.seasonStartOvr,
  'previousPotential': instance.previousPotential,
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

const _$PlayerPersonalityEnumMap = {
  PlayerPersonality.professional: 'professional',
  PlayerPersonality.leader: 'leader',
  PlayerPersonality.temperamental: 'temperamental',
  PlayerPersonality.ambitious: 'ambitious',
  PlayerPersonality.loyal: 'loyal',
  PlayerPersonality.balanced: 'balanced',
};

_PlayerMatchStats _$PlayerMatchStatsFromJson(Map<String, dynamic> json) =>
    _PlayerMatchStats(
      playerId: json['playerId'] as String,
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      shots: (json['shots'] as num?)?.toInt() ?? 0,
      shotsOnTarget: (json['shotsOnTarget'] as num?)?.toInt() ?? 0,
      xg: (json['xg'] as num?)?.toDouble() ?? 0.0,
      passes: (json['passes'] as num?)?.toInt() ?? 0,
      passAccuracy: (json['passAccuracy'] as num?)?.toDouble() ?? 0.0,
      duelsWon: (json['duelsWon'] as num?)?.toInt() ?? 0,
      offsides: (json['offsides'] as num?)?.toInt() ?? 0,
      corners: (json['corners'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellowCards'] as num?)?.toInt() ?? 0,
      redCards: (json['redCards'] as num?)?.toInt() ?? 0,
      tackles: (json['tackles'] as num?)?.toInt() ?? 0,
      interceptions: (json['interceptions'] as num?)?.toInt() ?? 0,
      saves: (json['saves'] as num?)?.toInt() ?? 0,
      shotsFaced: (json['shotsFaced'] as num?)?.toInt() ?? 0,
      ownGoals: (json['ownGoals'] as num?)?.toInt() ?? 0,
      cleanSheet: json['cleanSheet'] as bool? ?? false,
      staminaAfterMatch: (json['staminaAfterMatch'] as num?)?.toInt() ?? -1,
      rating: (json['rating'] as num?)?.toDouble() ?? 6.0,
    );

Map<String, dynamic> _$PlayerMatchStatsToJson(_PlayerMatchStats instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'minutes': instance.minutes,
      'goals': instance.goals,
      'assists': instance.assists,
      'shots': instance.shots,
      'shotsOnTarget': instance.shotsOnTarget,
      'xg': instance.xg,
      'passes': instance.passes,
      'passAccuracy': instance.passAccuracy,
      'duelsWon': instance.duelsWon,
      'offsides': instance.offsides,
      'corners': instance.corners,
      'yellowCards': instance.yellowCards,
      'redCards': instance.redCards,
      'tackles': instance.tackles,
      'interceptions': instance.interceptions,
      'saves': instance.saves,
      'shotsFaced': instance.shotsFaced,
      'ownGoals': instance.ownGoals,
      'cleanSheet': instance.cleanSheet,
      'staminaAfterMatch': instance.staminaAfterMatch,
      'rating': instance.rating,
    };
