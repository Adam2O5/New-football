import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'scouting.freezed.dart';
part 'scouting.g.dart';

@freezed
abstract class ScoutingKnowledge with _$ScoutingKnowledge {
  const factory ScoutingKnowledge({
    required String prospectId,
    @Default(ScoutingTier.tier1) ScoutingTier tier,
    EstimatedDraftSlot? estimatedSlot,
    @Default(false) bool injuryProneKnown,
    @Default(false) bool determinationKnown,
  }) = _ScoutingKnowledge;

  factory ScoutingKnowledge.fromJson(Map<String, dynamic> json) =>
      _$ScoutingKnowledgeFromJson(json);
}

@freezed
abstract class TeamScouting with _$TeamScouting {
  const factory TeamScouting({
    @Default([]) List<String> watchlistProspectIds,
    @Default([]) List<ScoutingKnowledge> knowledge,
    @Default([]) List<String> combineAssignedProspectIds,
  }) = _TeamScouting;

  factory TeamScouting.fromJson(Map<String, dynamic> json) =>
      _$TeamScoutingFromJson(json);
}

extension TeamScoutingX on TeamScouting {
  ScoutingKnowledge? forProspect(String prospectId) {
    try {
      return knowledge.firstWhere((k) => k.prospectId == prospectId);
    } catch (_) {
      return null;
    }
  }
}
