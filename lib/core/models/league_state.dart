import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';

part 'league_state.freezed.dart';
part 'league_state.g.dart';

@freezed
class LeagueState with _$LeagueState {
  const factory LeagueState({
    required List<Team> teams,
    required Season currentSeason,
    @Default([]) List<SeasonHistory> history,
    String? playerTeamId,
    @Default(0) int currentRound,
    @Default(1) int currentWeek,

    /// 1 = Monday … 7 = Sunday within [currentWeek].
    @Default(1) int currentDay,

    /// Hourly contract mode clock. Null outside extensions/FA phase I;
    /// otherwise 1–10 identifies the current offer slot.
    int? currentHour,
    @Default(false) bool hourlyPlayerOfferUsed,
    @Default(false) bool hourlyStaffOfferUsed,
    @Default(Inbox()) Inbox inbox,
    @Default(MessageSettings()) MessageSettings messageSettings,

    /// Sztab bez klubu — pula dostępna do zatrudnienia (`docs/staff_rules.md`).
    @Default([]) List<StaffMember> staffFreeAgents,

    /// Zawodnicy bez klubu — niedraftowani + wygasłe kontrakty
    /// (`docs/contract_signing.md`, `docs/offseason.md`).
    @Default([]) List<Player> freeAgents,

    /// Tabela siły ligi (`team_management.md`). Jedno źródło prawdy dla
    /// `teamStatus`, `expectedRank` i `teamPower` wszystkich 30 drużyn.
    /// `null` = jeszcze nie przeliczona (zostanie obliczona przy pierwszym
    /// `shouldRecalculate` w `DaySimulator`).
    LeagueStrengthTable? strengthTable,
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
