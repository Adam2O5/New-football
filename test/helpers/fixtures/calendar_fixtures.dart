import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/services/game_factory.dart';

final _calendarBase = GameFactory().create(
  const NewGameRequest(
    saveName: 'Calendar fixture',
    playerTeamId: 'team_europe_0',
    seed: 7,
  ),
);

/// Two complete clubs and one fixture for calendar-policy tests. Keeping full
/// rosters avoids unrelated short-roster warnings; no AI match is played on
/// the ordinary target dates when withPlayerMatch is false.
GameSave calendarFixture({int seed = 7, bool withPlayerMatch = false}) {
  final home = _calendarBase.leagueState.teams.first;
  final away = _calendarBase.leagueState.teams[1];
  return _calendarBase.copyWith(
    saveSeed: seed,
    leagueState: _calendarBase.leagueState.copyWith(
      teams: [home, away],
      freeAgents: const [],
      currentSeason: _calendarBase.leagueState.currentSeason.copyWith(
        schedule: [
          ScheduledMatch(
            id: 'calendar-player-match',
            homeTeamId: home.id,
            awayTeamId: away.id,
            round: withPlayerMatch ? 1 : 58,
          ),
        ],
      ),
    ),
  );
}
