part of 'day_simulator.dart';

mixin _DayWorldUpdates {
  BalanceConfig get balance;

  ScoutingService get scouting;

  MessageService get messages;

  LeagueState _dailyRecovery(
    LeagueState league, {
    Set<String> excludedTeamIds = const {},
  }) {
    // The recovered roster of every team is collected before anything is
    // published. Rebuilding the league team by team would copy the whole
    // 30-team list once per team, every single day.
    final teams = <Team>[];
    final recoveryReturns =
        <({String teamId, Player player, String injuryId})>[];

    for (final team in league.teams) {
      if (excludedTeamIds.contains(team.id)) {
        teams.add(team);
        continue;
      }
      final roster = team.roster.map((player) {
        final recovered = player.recoverBetweenMatches(balance);
        if (player.state.injured && !recovered.state.injured) {
          final injuryId = player.state.injury?.id;
          if (injuryId != null) {
            recoveryReturns.add((
              teamId: team.id,
              player: player,
              injuryId: injuryId,
            ));
          }
        }
        return recovered;
      }).toList();
      teams.add(team.copyWith(roster: roster));
    }

    var state = league.copyWith(
      teams: teams,
      freeAgents: league.freeAgents
          .map((player) => player.recoverBetweenMatches(balance))
          .toList(),
    );
    for (final returned in recoveryReturns) {
      if (state.playerTeamId != returned.teamId) continue;
      final definition = InjuryCatalog.byId(returned.injuryId);
      state = messages.send(
        state,
        type: MessageType.injuryReturn,
        domain: MessageDomain.health,
        args: {
          'playerName': returned.player.name,
          'injuryName': definition.name,
        },
        payload: {
          'playerId': returned.player.id,
          'injuryId': returned.injuryId,
        },
      );
    }
    return state;
  }

  bool _isMonthlyScoutingReport(int week, int day) {
    return day == 1 &&
        week >= 5 &&
        week < balance.calendar.tradeDeadlineWeek &&
        (week - 1) % 4 == 0;
  }

  LeagueState _runMonthlyScoutingReport(
    LeagueState league, {
    required int saveSeed,
  }) {
    final draftClass = league.currentSeason.draftState?.draftClass;
    if (draftClass == null) return league;

    final ranked = [...draftClass.prospects]
      ..sort((a, b) {
        final grade = b.scoutGrade.compareTo(a.scoutGrade);
        return grade != 0 ? grade : a.id.compareTo(b.id);
      });
    final teams = league.teams.map((team) {
      if (team.isPlayerControlled) return team;
      final coverage = team.staff.scout?.attributes.coverage ?? 0.0;
      return team.copyWith(
        scouting: scouting.updateMonthlyWatchlist(
          team.scouting,
          rankedProspects: ranked,
          coverageStars: coverage,
          seed: saveSeed,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          teamId: team.id,
        ),
      );
    }).toList();

    return messages.send(
      league.copyWith(teams: teams),
      type: MessageType.scoutReport,
      kind: 'monthly',
      domain: MessageDomain.draft,
      args: {'draftYear': draftClass.year, 'count': ranked.length},
      payload: {'draftYear': draftClass.year, 'count': ranked.length},
      groupKey: 'scout:monthly:${league.currentSeason.year}',
      dedupKey:
          'scoutReport:monthly:${league.currentSeason.year}:${league.currentWeek}',
    );
  }
}
