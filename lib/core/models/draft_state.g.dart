// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
  mockDraftBoard: json['mockDraftBoard'] == null
      ? null
      : MockDraftBoard.fromJson(json['mockDraftBoard'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DraftStateToJson(_DraftState instance) =>
    <String, dynamic>{
      'year': instance.year,
      'order': instance.order,
      'completedPicks': instance.completedPicks,
      'lotteryResults': instance.lotteryResults,
      'draftClass': instance.draftClass,
      'currentPickIndex': instance.currentPickIndex,
      'mockDraftBoard': instance.mockDraftBoard,
    };

_CompletedDraft _$CompletedDraftFromJson(Map<String, dynamic> json) =>
    _CompletedDraft(
      year: (json['year'] as num).toInt(),
      completedPicks:
          (json['completedPicks'] as List<dynamic>?)
              ?.map((e) => DraftPick.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CompletedDraftToJson(_CompletedDraft instance) =>
    <String, dynamic>{
      'year': instance.year,
      'completedPicks': instance.completedPicks,
    };
