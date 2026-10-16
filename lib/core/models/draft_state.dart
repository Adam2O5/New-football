import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/draft_class.dart';
import 'package:new_football/core/models/lottery_result.dart';
import 'package:new_football/core/models/season.dart';

part 'draft_state.freezed.dart';
part 'draft_state.g.dart';

@freezed
abstract class DraftState with _$DraftState {
  const factory DraftState({
    required int year,
    @Default([]) List<DraftPick> order,
    @Default([]) List<DraftPick> completedPicks,
    @Default([]) List<LotteryResult> lotteryResults,
    required DraftClass draftClass,
    @Default(0) int currentPickIndex,

    /// Bieżący displayed board (mock wstępny do piątku tyg. 45, potem mock
    /// finalny). `null` tylko w testach/legacy save'ach sprzed tej funkcji —
    /// produkcyjnie ustawiany razem z `draftClass` w `ProspectService`.
    MockDraftBoard? mockDraftBoard,
  }) = _DraftState;

  factory DraftState.fromJson(Map<String, dynamic> json) =>
      _$DraftStateFromJson(json);
}

/// Snapshot of a finished draft's picks, kept once `draftState` on [Season]
/// is overwritten by `generateNextClassForLeague` (week after the draft).
/// Deliberately lives on `LeagueState`, not `Season` — see `staff_rules.md`
/// discussion on keeping `Season` from accumulating unrelated history data.
@freezed
abstract class CompletedDraft with _$CompletedDraft {
  const factory CompletedDraft({
    required int year,
    @Default([]) List<DraftPick> completedPicks,
  }) = _CompletedDraft;

  factory CompletedDraft.fromJson(Map<String, dynamic> json) =>
      _$CompletedDraftFromJson(json);
}
