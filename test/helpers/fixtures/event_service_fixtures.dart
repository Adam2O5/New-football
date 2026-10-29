import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player_event_state.dart';

import 'game_fixtures.dart';

const eventBalance = BalanceConfig(
  events: EventsBalance(
    minutesRequestChance: 0,
    minutesRequestAmbitiousChance: 0,
    transferRequestIChance: 0,
    transferRequestIIChanceAfterBrokenPromise: 0,
    lockerRoomConflictChance: 0,
    leaderSupportChance: 0,
    publicCriticismChance: 0,
    breakthroughChance: 0,
    coldStreakChance: 0,
    majorInjuryComplicationChance: 0,
    veteranMotivationChance: 0,
    extraTrainingChance: 0,
    personalProblemsChance: 0,
    professionalPersonalProblemsChance: 0,
    personalSupportChance: 0,
    lateBloomerChance: 0,
    recurringInjuryChance: 0,
    plateauWeeks: 1,
    plateauChance: 1,
    aiPlateauAcceptChance: 1,
  ),
);

LeagueState eventLeague() {
  final league = controllerSave().leagueState;
  final team = league.teams.single;
  return league.updateTeam(
    team.copyWith(
      roster: team.roster.take(2).map((player) {
        return player.copyWith(
          state: player.state.copyWith(
            lastDevelopmentOvrDelta: 0,
            eventState: const PlayerEventState(),
          ),
        );
      }).toList(),
    ),
  );
}
