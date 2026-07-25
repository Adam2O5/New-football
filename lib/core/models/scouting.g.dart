// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scouting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScoutingKnowledgeImpl _$$ScoutingKnowledgeImplFromJson(
  Map<String, dynamic> json,
) => _$ScoutingKnowledgeImpl(
  prospectId: json['prospectId'] as String,
  tier:
      $enumDecodeNullable(_$ScoutingTierEnumMap, json['tier']) ??
      ScoutingTier.tier1,
  estimatedSlot: $enumDecodeNullable(
    _$EstimatedDraftSlotEnumMap,
    json['estimatedSlot'],
  ),
  injuryProneKnown: json['injuryProneKnown'] as bool? ?? false,
  determinationKnown: json['determinationKnown'] as bool? ?? false,
);

Map<String, dynamic> _$$ScoutingKnowledgeImplToJson(
  _$ScoutingKnowledgeImpl instance,
) => <String, dynamic>{
  'prospectId': instance.prospectId,
  'tier': _$ScoutingTierEnumMap[instance.tier]!,
  'estimatedSlot': _$EstimatedDraftSlotEnumMap[instance.estimatedSlot],
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

_$TeamScoutingImpl _$$TeamScoutingImplFromJson(Map<String, dynamic> json) =>
    _$TeamScoutingImpl(
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
    );

Map<String, dynamic> _$$TeamScoutingImplToJson(_$TeamScoutingImpl instance) =>
    <String, dynamic>{
      'watchlistProspectIds': instance.watchlistProspectIds,
      'knowledge': instance.knowledge,
      'combineAssignedProspectIds': instance.combineAssignedProspectIds,
    };
