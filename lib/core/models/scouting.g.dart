// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scouting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScoutingKnowledge _$ScoutingKnowledgeFromJson(
  Map<String, dynamic> json,
) => _ScoutingKnowledge(
  prospectId: json['prospectId'] as String,
  tier:
      $enumDecodeNullable(_$ScoutingTierEnumMap, json['tier']) ??
      ScoutingTier.tier1,
  estimatedSlot: $enumDecodeNullable(
    _$EstimatedDraftSlotEnumMap,
    json['estimatedSlot'],
  ),
  mockRank: (json['mockRank'] as num?)?.toInt() ?? 0,
  estimatedOvrMin: (json['estimatedOvrMin'] as num?)?.toInt(),
  estimatedOvrMax: (json['estimatedOvrMax'] as num?)?.toInt(),
  estimatedPotentialMin: (json['estimatedPotentialMin'] as num?)?.toDouble(),
  estimatedPotentialMax: (json['estimatedPotentialMax'] as num?)?.toDouble(),
  injuryProneMin: (json['injuryProneMin'] as num?)?.toInt(),
  injuryProneMax: (json['injuryProneMax'] as num?)?.toInt(),
  determinationMin: (json['determinationMin'] as num?)?.toInt(),
  determinationMax: (json['determinationMax'] as num?)?.toInt(),
  injuryProneKnown: json['injuryProneKnown'] as bool? ?? false,
  determinationKnown: json['determinationKnown'] as bool? ?? false,
);

Map<String, dynamic> _$ScoutingKnowledgeToJson(_ScoutingKnowledge instance) =>
    <String, dynamic>{
      'prospectId': instance.prospectId,
      'tier': _$ScoutingTierEnumMap[instance.tier]!,
      'estimatedSlot': _$EstimatedDraftSlotEnumMap[instance.estimatedSlot],
      'mockRank': instance.mockRank,
      'estimatedOvrMin': instance.estimatedOvrMin,
      'estimatedOvrMax': instance.estimatedOvrMax,
      'estimatedPotentialMin': instance.estimatedPotentialMin,
      'estimatedPotentialMax': instance.estimatedPotentialMax,
      'injuryProneMin': instance.injuryProneMin,
      'injuryProneMax': instance.injuryProneMax,
      'determinationMin': instance.determinationMin,
      'determinationMax': instance.determinationMax,
      'injuryProneKnown': instance.injuryProneKnown,
      'determinationKnown': instance.determinationKnown,
    };

const _$ScoutingTierEnumMap = {
  ScoutingTier.tier1: 'tier1',
  ScoutingTier.tier2: 'tier2',
  ScoutingTier.tier3: 'tier3',
  ScoutingTier.tier4: 'tier4',
  ScoutingTier.tier5: 'tier5',
};

const _$EstimatedDraftSlotEnumMap = {
  EstimatedDraftSlot.top1: 'top1',
  EstimatedDraftSlot.top3: 'top3',
  EstimatedDraftSlot.top5: 'top5',
  EstimatedDraftSlot.top10: 'top10',
  EstimatedDraftSlot.r1: 'r1',
  EstimatedDraftSlot.r2: 'r2',
  EstimatedDraftSlot.r3: 'r3',
  EstimatedDraftSlot.x: 'x',
};

_TeamScouting _$TeamScoutingFromJson(Map<String, dynamic> json) =>
    _TeamScouting(
      watchlistProspectIds:
          (json['watchlistProspectIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      knowledge:
          (json['knowledge'] as List<dynamic>?)
              ?.map(
                (e) => ScoutingKnowledge.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      combineAssignedProspectIds:
          (json['combineAssignedProspectIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mockRanks:
          (json['mockRanks'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$TeamScoutingToJson(_TeamScouting instance) =>
    <String, dynamic>{
      'watchlistProspectIds': instance.watchlistProspectIds,
      'knowledge': instance.knowledge,
      'combineAssignedProspectIds': instance.combineAssignedProspectIds,
      'mockRanks': instance.mockRanks,
    };
