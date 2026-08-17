// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Contract _$ContractFromJson(Map<String, dynamic> json) => _Contract(
  salary: (json['salary'] as num).toInt(),
  yearsRemaining: (json['yearsRemaining'] as num).toInt(),
  hasBirdRights: json['hasBirdRights'] as bool? ?? false,
  isRookieScale: json['isRookieScale'] as bool? ?? false,
  rookiePickSlot: (json['rookiePickSlot'] as num?)?.toInt() ?? 0,
  noTradeClause: json['noTradeClause'] as bool? ?? false,
  blockedTeamIds:
      (json['blockedTeamIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ContractToJson(_Contract instance) => <String, dynamic>{
  'salary': instance.salary,
  'yearsRemaining': instance.yearsRemaining,
  'hasBirdRights': instance.hasBirdRights,
  'isRookieScale': instance.isRookieScale,
  'rookiePickSlot': instance.rookiePickSlot,
  'noTradeClause': instance.noTradeClause,
  'blockedTeamIds': instance.blockedTeamIds,
};

_CapException _$CapExceptionFromJson(Map<String, dynamic> json) =>
    _CapException(
      type: $enumDecode(_$CapExceptionTypeEnumMap, json['type']),
      amountRemaining: (json['amountRemaining'] as num).toInt(),
      playerId: json['playerId'] as String,
      expiryYear: (json['expiryYear'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CapExceptionToJson(_CapException instance) =>
    <String, dynamic>{
      'type': _$CapExceptionTypeEnumMap[instance.type]!,
      'amountRemaining': instance.amountRemaining,
      'playerId': instance.playerId,
      'expiryYear': instance.expiryYear,
    };

const _$CapExceptionTypeEnumMap = {
  CapExceptionType.birdRights: 'birdRights',
  CapExceptionType.midLevelException: 'midLevelException',
  CapExceptionType.rookieScale: 'rookieScale',
  CapExceptionType.tradedPlayerException: 'tradedPlayerException',
};

_TeamFinance _$TeamFinanceFromJson(Map<String, dynamic> json) => _TeamFinance(
  salaryCap: (json['salaryCap'] as num?)?.toInt() ?? 300000000,
  totalPayroll: (json['totalPayroll'] as num?)?.toInt() ?? 0,
  activeExceptions:
      (json['activeExceptions'] as List<dynamic>?)
          ?.map((e) => CapException.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  midLevelExceptionAmount:
      (json['midLevelExceptionAmount'] as num?)?.toInt() ?? 20400000,
  midLevelExceptionAvailable:
      json['midLevelExceptionAvailable'] as bool? ?? true,
  cashBalance: (json['cashBalance'] as num?)?.toInt() ?? 75000000,
);

Map<String, dynamic> _$TeamFinanceToJson(_TeamFinance instance) =>
    <String, dynamic>{
      'salaryCap': instance.salaryCap,
      'totalPayroll': instance.totalPayroll,
      'activeExceptions': instance.activeExceptions,
      'midLevelExceptionAmount': instance.midLevelExceptionAmount,
      'midLevelExceptionAvailable': instance.midLevelExceptionAvailable,
      'cashBalance': instance.cashBalance,
    };
