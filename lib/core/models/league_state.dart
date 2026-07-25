import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/team.dart';

part 'league_state.freezed.dart';
part 'league_state.g.dart';

@freezed
class LeagueState with _$LeagueState {
  const factory LeagueState({
    required List<Team> teams,
    required Season currentSeason,
    @Default([]) List<SeasonHistory> history,
    @Default(Difficulty.normal) Difficulty difficulty,
    String? playerTeamId,
    @Default(0) int currentRound,
    @Default(1) int currentWeek,
    @Default(Inbox()) Inbox inbox,
    @Default(MessageSettings()) MessageSettings messageSettings,
  }) = _LeagueState;

  factory LeagueState.fromJson(Map<String, dynamic> json) =>
      _$LeagueStateFromJson(json);
}

extension LeagueStateX on LeagueState {
  Team? get playerTeam {
    if (playerTeamId == null) return null;
    return teams.firstWhere((t) => t.id == playerTeamId);
  }

  Team? teamById(String id) {
    try {
      return teams.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Team> teamsInConference(Conference conference) =>
      teams.where((t) => t.conference == conference).toList();

  LeagueState updateTeam(Team team) {
    return copyWith(
      teams: teams.map((t) => t.id == team.id ? team : t).toList(),
    );
  }
}
