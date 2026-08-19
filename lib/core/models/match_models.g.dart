// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchEvent _$MatchEventFromJson(Map<String, dynamic> json) => _MatchEvent(
  type: $enumDecode(_$MatchEventTypeEnumMap, json['type']),
  minute: (json['minute'] as num).toInt(),
  teamId: json['teamId'] as String,
  playerId: json['playerId'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$MatchEventToJson(_MatchEvent instance) =>
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
  MatchEventType.foul: 'foul',
};

_MatchInjury _$MatchInjuryFromJson(Map<String, dynamic> json) => _MatchInjury(
  teamId: json['teamId'] as String,
  playerId: json['playerId'] as String,
  injury: Injury.fromJson(json['injury'] as Map<String, dynamic>),
  playerInStartingXi: json['playerInStartingXi'] as bool,
  potentialLoss: json['potentialLoss'] as bool? ?? false,
);

Map<String, dynamic> _$MatchInjuryToJson(_MatchInjury instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'playerId': instance.playerId,
      'injury': instance.injury,
      'playerInStartingXi': instance.playerInStartingXi,
      'potentialLoss': instance.potentialLoss,
    };

_MatchDiscipline _$MatchDisciplineFromJson(Map<String, dynamic> json) =>
    _MatchDiscipline(
      teamId: json['teamId'] as String,
      playerId: json['playerId'] as String,
      yellowCardsInMatch: (json['yellowCardsInMatch'] as num?)?.toInt() ?? 0,
      redCardKind:
          $enumDecodeNullable(_$RedCardKindEnumMap, json['redCardKind']) ??
          RedCardKind.none,
      directRedSeverity: (json['directRedSeverity'] as num?)?.toInt() ?? 0,
      playerInStartingXi: json['playerInStartingXi'] as bool? ?? false,
    );

Map<String, dynamic> _$MatchDisciplineToJson(_MatchDiscipline instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'playerId': instance.playerId,
      'yellowCardsInMatch': instance.yellowCardsInMatch,
      'redCardKind': _$RedCardKindEnumMap[instance.redCardKind]!,
      'directRedSeverity': instance.directRedSeverity,
      'playerInStartingXi': instance.playerInStartingXi,
    };

const _$RedCardKindEnumMap = {
  RedCardKind.none: 'none',
  RedCardKind.secondYellow: 'secondYellow',
  RedCardKind.direct: 'direct',
};

_TeamMatchStats _$TeamMatchStatsFromJson(Map<String, dynamic> json) =>
    _TeamMatchStats(
      teamId: json['teamId'] as String,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      shots: (json['shots'] as num?)?.toInt() ?? 0,
      shotsOnTarget: (json['shotsOnTarget'] as num?)?.toInt() ?? 0,
      possession: (json['possession'] as num?)?.toInt() ?? 0,
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

Map<String, dynamic> _$TeamMatchStatsToJson(_TeamMatchStats instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'goals': instance.goals,
      'shots': instance.shots,
      'shotsOnTarget': instance.shotsOnTarget,
      'possession': instance.possession,
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

_MatchTeamSnapshot _$MatchTeamSnapshotFromJson(Map<String, dynamic> json) =>
    _MatchTeamSnapshot(
      teamId: json['teamId'] as String? ?? '',
      startingXi:
          (json['startingXi'] as List<dynamic>?)
              ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bench:
          (json['bench'] as List<dynamic>?)
              ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      assignedPositions:
          (json['assignedPositions'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$PositionEnumMap, e))
              .toList() ??
          const [],
      assignedRoles:
          (json['assignedRoles'] as List<dynamic>?)
              ?.map((e) => AssignedRole.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tactics: json['tactics'] == null
          ? const TacticsSetup()
          : TacticsSetup.fromJson(json['tactics'] as Map<String, dynamic>),
      chemistry: (json['chemistry'] as num?)?.toDouble() ?? 50.0,
      atmosphere: (json['atmosphere'] as num?)?.toInt() ?? 50,
      cohesionMultiplier:
          (json['cohesionMultiplier'] as num?)?.toDouble() ?? 1.0,
      staff: json['staff'] == null
          ? const TeamStaff()
          : TeamStaff.fromJson(json['staff'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MatchTeamSnapshotToJson(_MatchTeamSnapshot instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'startingXi': instance.startingXi,
      'bench': instance.bench,
      'assignedPositions': instance.assignedPositions
          .map((e) => _$PositionEnumMap[e]!)
          .toList(),
      'assignedRoles': instance.assignedRoles,
      'tactics': instance.tactics,
      'chemistry': instance.chemistry,
      'atmosphere': instance.atmosphere,
      'cohesionMultiplier': instance.cohesionMultiplier,
      'staff': instance.staff,
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

_MatchResult _$MatchResultFromJson(Map<String, dynamic> json) => _MatchResult(
  homeTeamId: json['homeTeamId'] as String,
  awayTeamId: json['awayTeamId'] as String,
  homeGoals: (json['homeGoals'] as num).toInt(),
  awayGoals: (json['awayGoals'] as num).toInt(),
  homeStats: TeamMatchStats.fromJson(json['homeStats'] as Map<String, dynamic>),
  awayStats: TeamMatchStats.fromJson(json['awayStats'] as Map<String, dynamic>),
  status:
      $enumDecodeNullable(_$MatchStatusEnumMap, json['status']) ??
      MatchStatus.played,
  reasonCode: json['reasonCode'] as String?,
  violatingTeamIds:
      (json['violatingTeamIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isWalkover: json['isWalkover'] as bool? ?? false,
  noGkPenalty: json['noGkPenalty'] as bool? ?? false,
  noGkPenaltyTeamIds:
      (json['noGkPenaltyTeamIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  context: json['context'] == null
      ? const MatchContext()
      : MatchContext.fromJson(json['context'] as Map<String, dynamic>),
  homeTactics: json['homeTactics'] == null
      ? const TacticsSetup()
      : TacticsSetup.fromJson(json['homeTactics'] as Map<String, dynamic>),
  awayTactics: json['awayTactics'] == null
      ? const TacticsSetup()
      : TacticsSetup.fromJson(json['awayTactics'] as Map<String, dynamic>),
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
  homeLineupPositions:
      (json['homeLineupPositions'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PositionEnumMap, e))
          .toList() ??
      const [],
  awayLineupPositions:
      (json['awayLineupPositions'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PositionEnumMap, e))
          .toList() ??
      const [],
  homeSnapshot: json['homeSnapshot'] == null
      ? const MatchTeamSnapshot()
      : MatchTeamSnapshot.fromJson(
          json['homeSnapshot'] as Map<String, dynamic>,
        ),
  awaySnapshot: json['awaySnapshot'] == null
      ? const MatchTeamSnapshot()
      : MatchTeamSnapshot.fromJson(
          json['awaySnapshot'] as Map<String, dynamic>,
        ),
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
  disciplines:
      (json['disciplines'] as List<dynamic>?)
          ?.map((e) => MatchDiscipline.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  manOfTheMatchPlayerId: json['manOfTheMatchPlayerId'] as String?,
  inspiredPerformancePlayerId: json['inspiredPerformancePlayerId'] as String?,
  wentToExtraTime: json['wentToExtraTime'] as bool? ?? false,
  wentToShootout: json['wentToShootout'] as bool? ?? false,
  shootoutHomeGoals: (json['shootoutHomeGoals'] as num?)?.toInt() ?? 0,
  shootoutAwayGoals: (json['shootoutAwayGoals'] as num?)?.toInt() ?? 0,
  winnerTeamId: json['winnerTeamId'] as String?,
  matchEndMinute: (json['matchEndMinute'] as num?)?.toInt() ?? 90,
  stoppageTime: (json['stoppageTime'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MatchResultToJson(_MatchResult instance) =>
    <String, dynamic>{
      'homeTeamId': instance.homeTeamId,
      'awayTeamId': instance.awayTeamId,
      'homeGoals': instance.homeGoals,
      'awayGoals': instance.awayGoals,
      'homeStats': instance.homeStats,
      'awayStats': instance.awayStats,
      'status': _$MatchStatusEnumMap[instance.status]!,
      'reasonCode': instance.reasonCode,
      'violatingTeamIds': instance.violatingTeamIds,
      'isWalkover': instance.isWalkover,
      'noGkPenalty': instance.noGkPenalty,
      'noGkPenaltyTeamIds': instance.noGkPenaltyTeamIds,
      'context': instance.context,
      'homeTactics': instance.homeTactics,
      'awayTactics': instance.awayTactics,
      'homeLineup': instance.homeLineup,
      'awayLineup': instance.awayLineup,
      'homeLineupPositions': instance.homeLineupPositions
          .map((e) => _$PositionEnumMap[e]!)
          .toList(),
      'awayLineupPositions': instance.awayLineupPositions
          .map((e) => _$PositionEnumMap[e]!)
          .toList(),
      'homeSnapshot': instance.homeSnapshot,
      'awaySnapshot': instance.awaySnapshot,
      'playerStats': instance.playerStats,
      'events': instance.events,
      'injuries': instance.injuries,
      'disciplines': instance.disciplines,
      'manOfTheMatchPlayerId': instance.manOfTheMatchPlayerId,
      'inspiredPerformancePlayerId': instance.inspiredPerformancePlayerId,
      'wentToExtraTime': instance.wentToExtraTime,
      'wentToShootout': instance.wentToShootout,
      'shootoutHomeGoals': instance.shootoutHomeGoals,
      'shootoutAwayGoals': instance.shootoutAwayGoals,
      'winnerTeamId': instance.winnerTeamId,
      'matchEndMinute': instance.matchEndMinute,
      'stoppageTime': instance.stoppageTime,
    };

const _$MatchStatusEnumMap = {
  MatchStatus.played: 'played',
  MatchStatus.walkover: 'walkover',
  MatchStatus.dsq: 'dsq',
};

_MatchSetup _$MatchSetupFromJson(Map<String, dynamic> json) => _MatchSetup(
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

Map<String, dynamic> _$MatchSetupToJson(_MatchSetup instance) =>
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

_ScheduledMatch _$ScheduledMatchFromJson(Map<String, dynamic> json) =>
    _ScheduledMatch(
      id: json['id'] as String,
      homeTeamId: json['homeTeamId'] as String,
      awayTeamId: json['awayTeamId'] as String,
      round: (json['round'] as num).toInt(),
      result: json['result'] == null
          ? null
          : MatchResult.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ScheduledMatchToJson(_ScheduledMatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'homeTeamId': instance.homeTeamId,
      'awayTeamId': instance.awayTeamId,
      'round': instance.round,
      'result': instance.result,
    };

_PlayoffSeries _$PlayoffSeriesFromJson(Map<String, dynamic> json) =>
    _PlayoffSeries(
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

Map<String, dynamic> _$PlayoffSeriesToJson(_PlayoffSeries instance) =>
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
