// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_negotiation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NegotiationOffer _$NegotiationOfferFromJson(Map<String, dynamic> json) =>
    _NegotiationOffer(
      salary: (json['salary'] as num).toInt(),
      years: (json['years'] as num).toInt(),
      exception: $enumDecodeNullable(
        _$CapExceptionTypeEnumMap,
        json['exception'],
      ),
      rookiePickSlot: (json['rookiePickSlot'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NegotiationOfferToJson(_NegotiationOffer instance) =>
    <String, dynamic>{
      'salary': instance.salary,
      'years': instance.years,
      'exception': _$CapExceptionTypeEnumMap[instance.exception],
      'rookiePickSlot': instance.rookiePickSlot,
    };

const _$CapExceptionTypeEnumMap = {
  CapExceptionType.birdRights: 'birdRights',
  CapExceptionType.midLevelException: 'midLevelException',
  CapExceptionType.rookieScale: 'rookieScale',
  CapExceptionType.rookieExtension: 'rookieExtension',
  CapExceptionType.qualifyingOffer: 'qualifyingOffer',
  CapExceptionType.fullBirdRights: 'fullBirdRights',
  CapExceptionType.earlyBirdRights: 'earlyBirdRights',
  CapExceptionType.nonBirdRights: 'nonBirdRights',
  CapExceptionType.veteranExtensionRaiseCap: 'veteranExtensionRaiseCap',
  CapExceptionType.tradedPlayerException: 'tradedPlayerException',
};

_ContractNegotiation _$ContractNegotiationFromJson(Map<String, dynamic> json) =>
    _ContractNegotiation(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      subjectKind: $enumDecode(
        _$NegotiationSubjectKindEnumMap,
        json['subjectKind'],
      ),
      teamId: json['teamId'] as String,
      phase: $enumDecode(_$NegotiationPhaseEnumMap, json['phase']),
      round: (json['round'] as num?)?.toInt() ?? 1,
      lastOffer: NegotiationOffer.fromJson(
        json['lastOffer'] as Map<String, dynamic>,
      ),
      counterOffer: json['counterOffer'] == null
          ? null
          : NegotiationOffer.fromJson(
              json['counterOffer'] as Map<String, dynamic>,
            ),
      status:
          $enumDecodeNullable(_$NegotiationStatusEnumMap, json['status']) ??
          NegotiationStatus.active,
      seasonYear: (json['seasonYear'] as num).toInt(),
      week: (json['week'] as num).toInt(),
      day: (json['day'] as num?)?.toInt() ?? 1,
      hour: (json['hour'] as num?)?.toInt() ?? 0,
      expirySeasonYear: (json['expirySeasonYear'] as num).toInt(),
      expiryWeek: (json['expiryWeek'] as num).toInt(),
      expiryDay: (json['expiryDay'] as num?)?.toInt() ?? 1,
      expiryHour: (json['expiryHour'] as num?)?.toInt() ?? 0,
      requiresFinalization: json['requiresFinalization'] as bool? ?? false,
      selectedByRival: json['selectedByRival'] as bool? ?? false,
      rivalFinalized: json['rivalFinalized'] as bool? ?? false,
      offerScore: (json['offerScore'] as num?)?.toDouble() ?? 0.0,
      isAiOffer: json['isAiOffer'] as bool? ?? false,
      waitingUntilSeasonYear: (json['waitingUntilSeasonYear'] as num?)?.toInt(),
      waitingUntilWeek: (json['waitingUntilWeek'] as num?)?.toInt(),
      waitingUntilDay: (json['waitingUntilDay'] as num?)?.toInt(),
      waitingUntilHour: (json['waitingUntilHour'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ContractNegotiationToJson(
  _ContractNegotiation instance,
) => <String, dynamic>{
  'id': instance.id,
  'subjectId': instance.subjectId,
  'subjectKind': _$NegotiationSubjectKindEnumMap[instance.subjectKind]!,
  'teamId': instance.teamId,
  'phase': _$NegotiationPhaseEnumMap[instance.phase]!,
  'round': instance.round,
  'lastOffer': instance.lastOffer,
  'counterOffer': instance.counterOffer,
  'status': _$NegotiationStatusEnumMap[instance.status]!,
  'seasonYear': instance.seasonYear,
  'week': instance.week,
  'day': instance.day,
  'hour': instance.hour,
  'expirySeasonYear': instance.expirySeasonYear,
  'expiryWeek': instance.expiryWeek,
  'expiryDay': instance.expiryDay,
  'expiryHour': instance.expiryHour,
  'requiresFinalization': instance.requiresFinalization,
  'selectedByRival': instance.selectedByRival,
  'rivalFinalized': instance.rivalFinalized,
  'offerScore': instance.offerScore,
  'isAiOffer': instance.isAiOffer,
  'waitingUntilSeasonYear': instance.waitingUntilSeasonYear,
  'waitingUntilWeek': instance.waitingUntilWeek,
  'waitingUntilDay': instance.waitingUntilDay,
  'waitingUntilHour': instance.waitingUntilHour,
};

const _$NegotiationSubjectKindEnumMap = {
  NegotiationSubjectKind.player: 'player',
  NegotiationSubjectKind.staff: 'staff',
};

const _$NegotiationPhaseEnumMap = {
  NegotiationPhase.contractExtension: 'contractExtension',
  NegotiationPhase.freeAgencyPhaseI: 'freeAgencyPhaseI',
  NegotiationPhase.freeAgencyPhaseII: 'freeAgencyPhaseII',
};

const _$NegotiationStatusEnumMap = {
  NegotiationStatus.active: 'active',
  NegotiationStatus.waiting: 'waiting',
  NegotiationStatus.pendingFinalization: 'pendingFinalization',
  NegotiationStatus.counter: 'counter',
  NegotiationStatus.rejected: 'rejected',
  NegotiationStatus.hardRejected: 'hardRejected',
  NegotiationStatus.completed: 'completed',
  NegotiationStatus.cancelled: 'cancelled',
};

_NegotiationBlock _$NegotiationBlockFromJson(Map<String, dynamic> json) =>
    _NegotiationBlock(
      subjectId: json['subjectId'] as String,
      subjectKind: $enumDecode(
        _$NegotiationSubjectKindEnumMap,
        json['subjectKind'],
      ),
      teamId: json['teamId'] as String,
      untilSeasonYear: (json['untilSeasonYear'] as num).toInt(),
      untilWeek: (json['untilWeek'] as num).toInt(),
      untilDay: (json['untilDay'] as num).toInt(),
      untilHour: (json['untilHour'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$NegotiationBlockToJson(_NegotiationBlock instance) =>
    <String, dynamic>{
      'subjectId': instance.subjectId,
      'subjectKind': _$NegotiationSubjectKindEnumMap[instance.subjectKind]!,
      'teamId': instance.teamId,
      'untilSeasonYear': instance.untilSeasonYear,
      'untilWeek': instance.untilWeek,
      'untilDay': instance.untilDay,
      'untilHour': instance.untilHour,
    };
