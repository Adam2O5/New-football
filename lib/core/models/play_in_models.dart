import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';

part 'play_in_models.freezed.dart';
part 'play_in_models.g.dart';

@freezed
abstract class PlayInResult with _$PlayInResult {
  const factory PlayInResult({
    required Conference conference,
    required String seed7TeamId,
    required String seed8TeamId,
    required MatchResult game7v8,
    required MatchResult game9v10,
    required MatchResult gameFinal,
    required String playoffSeed7TeamId,
    required String playoffSeed8TeamId,
  }) = _PlayInResult;

  factory PlayInResult.fromJson(Map<String, dynamic> json) =>
      _$PlayInResultFromJson(json);
}

/// Persisted intermediate play-in state used by the dated calendar flow.
/// It keeps the existing atomic [PlayInResult] API intact while allowing the
/// Wednesday games and Saturday decider to be resolved on their own dates.
@freezed
abstract class PlayInProgress with _$PlayInProgress {
  const factory PlayInProgress({
    required Conference conference,
    required String seed7TeamId,
    required String seed8TeamId,
    required String seed9TeamId,
    required String seed10TeamId,
    MatchResult? game7v8,
    MatchResult? game9v10,
    MatchResult? gameFinal,
  }) = _PlayInProgress;

  factory PlayInProgress.fromJson(Map<String, dynamic> json) =>
      _$PlayInProgressFromJson(json);
}
