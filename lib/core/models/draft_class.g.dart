// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

_MockDraftBoard _$MockDraftBoardFromJson(Map<String, dynamic> json) =>
    _MockDraftBoard(
      displayedRank:
          (json['displayedRank'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      previousDisplayedRank:
          (json['previousDisplayedRank'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$MockDraftBoardToJson(_MockDraftBoard instance) =>
    <String, dynamic>{
      'displayedRank': instance.displayedRank,
      'previousDisplayedRank': instance.previousDisplayedRank,
    };
