import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/development.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/season_awards.dart';
import 'package:new_football/core/models/standing.dart';

part 'draft_models.freezed.dart';
part 'draft_models.g.dart';

@freezed
abstract class Prospect with _$Prospect {
  const factory Prospect({
    required String id,
    required String name,
    required Nationality nationality,
    required Position position,
    required int age,
    required PlayerAttributes attributes,
    @Default(0) int scoutGrade, //unevaluated
    @Default(0) int combineScore, //unevaluated
    required double potentialStars,
    required int heightCm,
    required int injuryProne,
    required int determination,
    required PlayerPersonality personality,

    /// Optymalna rola taktyczna (`player_management.md`).
    /// Ujawniana przez Combine (`offseason.md` §7).
    required AssignedRole optimalRole,
  }) = _Prospect;

  factory Prospect.fromJson(Map<String, dynamic> json) =>
      _$ProspectFromJson(json);
}

extension ProspectX on Prospect {
  double projectedOverall([BalanceConfig balance = BalanceConfig.defaults]) =>
      attributes.overallForPosition(position, balance);

  /// Converts prospect → player after draft pick or undrafted FA sign.
  /// Rolls [DevelopmentOutcome] here (hidden while still a prospect).
  Player toPlayer({required Contract contract, required Random rng}) {
    final outcome = rollDevelopmentOutcome(determination, rng);
    final player = Player(
      id: id,
      name: name,
      position: position,
      nationality: nationality,
      age: age,
      attributes: attributes,
      contract: contract,
      personality: personality,
      potentialStars: potentialStars,
      heightCm: heightCm,
      optimalRole: optimalRole,
      state: PlayerState(
        stamina: 100,
        form: (1 + rng.nextInt(10)).toDouble(),
        role: position.defaultAssignedRole,
        seasonsWithTeam: 0,
      ),
      hidden: PlayerHidden(
        injuryProne: injuryProne,
        determination: determination,
        overallProgress: (40 + rng.nextInt(50)).toDouble(),
        growthRate: BalanceConfig.defaults.development.baseGrowthRateFor(
          determination,
        ),
        developmentOutcome: outcome,
        developmentCeilingStars: rollDevelopmentCeilingStars(
          potentialStars,
          outcome,
          rng,
        ),
      ),
    );
    return player.copyWith(seasonStartOvr: player.overall());
  }
}

@freezed
abstract class LotteryResult with _$LotteryResult {
  const factory LotteryResult({
    required String teamId,
    required int originalRank,
    required int assignedPick,
    required double oddsForFirstPick,
  }) = _LotteryResult;

  factory LotteryResult.fromJson(Map<String, dynamic> json) =>
      _$LotteryResultFromJson(json);
}

@freezed
abstract class DraftClass with _$DraftClass {
  const factory DraftClass({
    required int year,
    @Default([]) List<Prospect> prospects,
  }) = _DraftClass;

  factory DraftClass.fromJson(Map<String, dynamic> json) =>
      _$DraftClassFromJson(json);
}

@freezed
abstract class DraftState with _$DraftState {
  const factory DraftState({
    required int year,
    @Default([]) List<DraftPick> order,
    @Default([]) List<DraftPick> completedPicks,
    @Default([]) List<LotteryResult> lotteryResults,
    required DraftClass draftClass,
    @Default(0) int currentPickIndex,
  }) = _DraftState;

  factory DraftState.fromJson(Map<String, dynamic> json) =>
      _$DraftStateFromJson(json);
}

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

@freezed
abstract class PlayoffBracket with _$PlayoffBracket {
  const factory PlayoffBracket({
    required Conference conference,
    @Default([]) List<PlayoffSeries> quarterFinals,
    @Default([]) List<PlayoffSeries> semiFinals,
    @Default([]) List<PlayoffSeries> conferenceFinal,
    PlayoffSeries? leagueFinal,
  }) = _PlayoffBracket;

  factory PlayoffBracket.fromJson(Map<String, dynamic> json) =>
      _$PlayoffBracketFromJson(json);
}

@freezed
abstract class Season with _$Season {
  const factory Season({
    required int year,
    @Default(SeasonPhase.preseason) SeasonPhase phase,
    @Default([]) List<ScheduledMatch> schedule,
    @Default([]) List<ConferenceStandings> standings,
    @Default([]) List<PlayInResult> playInResults,
    @Default([]) List<PlayInProgress> playInProgress,
    @Default([]) List<PlayoffBracket> playoffBrackets,
    String? championTeamId,
    @Default(false) bool championshipAtmosphereApplied,
    @Default(false) bool playoffMissAtmosphereApplied,
    DraftState? draftState,
    SeasonAwards? awards,
    @Default(false) bool staffGrowthDone,
    @Default(false) bool playerRetirementsDone,

    /// Persisted TV agreement: the exact reset year and increase are known
    /// before the event fires, so loading a save cannot reroll the cap.
    @Default(0) int nextTvCapResetSeason,
    @Default(0) int nextTvCapIncreasePct,
    @Default(false) bool capUpdateTvDone,

    @Default(false) bool combineDone,
    @Default(false) bool finalMockDone,
    @Default(false) bool faOpenDone,
    @Default(false) bool scoutReportDone,
    @Default(false) bool tradeDeadlineAcked,
    DraftState? nextDraftState,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}

@freezed
abstract class SeasonHistory with _$SeasonHistory {
  const factory SeasonHistory({
    required int year,
    required List<ConferenceStandings> finalStandings,
    String? championTeamId,
    @Default([]) List<DraftPick> draftPicks,
  }) = _SeasonHistory;

  factory SeasonHistory.fromJson(Map<String, dynamic> json) =>
      _$SeasonHistoryFromJson(json);
}
