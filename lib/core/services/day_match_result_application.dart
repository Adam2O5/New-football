part of 'day_simulator.dart';

mixin _DayMatchResultApplication {
  BalanceConfig get balance;

  MessageService get messages;

  TeamManagementService get teamManagement;

  TeamEventService get teamEvents;

  LeagueState _applyResult(
    LeagueState league,
    ScheduledMatch match,
    MatchResult result, {
    int saveSeed = 0,
  }) {
    // Only the slim projection reaches the state; the full [result] stays
    // local for the post-match pipeline below.
    final stored = result.slimForStorage();
    final newSchedule = league.currentSeason.schedule.map((m) {
      if (m.id != match.id) return m;
      return m.copyWith(result: stored);
    }).toList();

    var standings = result.status == MatchStatus.dsq
        ? league.currentSeason.standings
        : league.currentSeason.standings.map((cs) {
            final updated = cs.standings.map((s) {
              if (s.teamId == result.homeTeamId) {
                return s.applyResult(
                  goalsFor: result.homeGoals,
                  goalsAgainst: result.awayGoals,
                );
              }
              if (s.teamId == result.awayTeamId) {
                return s.applyResult(
                  goalsFor: result.awayGoals,
                  goalsAgainst: result.homeGoals,
                );
              }
              return s;
            }).toList();
            return cs.copyWith(standings: updated);
          }).toList();

    // Re-rank conferences.
    standings = standings
        .map((cs) => cs.copyWith(standings: cs.sorted))
        .toList();

    final isAdministrativeResult = TeamManagementService.isWalkoverResult(
      result,
    );
    final administrativeTeamIds = TeamManagementService.walkoverTeamIds(result);
    var teams = league.teams;
    final recoveryReturns =
        <({Player player, String injuryId, String teamId})>[];
    final disciplineNotifications =
        <({String teamId, DisciplineNotification notification})>[];
    teams = teams.map((t) {
      final isParticipant =
          t.id == result.homeTeamId || t.id == result.awayTeamId;
      final next = isParticipant && !isAdministrativeResult
          ? _applyFatigue(t, result, seasonYear: league.currentSeason.year)
          : _recoverTeam(t);
      for (final oldPlayer in t.roster) {
        final nextPlayer = next.roster.firstWhere(
          (p) => p.id == oldPlayer.id,
          orElse: () => oldPlayer,
        );
        if (oldPlayer.state.injured && !nextPlayer.state.injured) {
          recoveryReturns.add((
            player: oldPlayer,
            injuryId: oldPlayer.state.injury?.id ?? '',
            teamId: t.id,
          ));
        }
      }
      return next;
    }).toList();

    if (!isAdministrativeResult) {
      final disciplineService = const DisciplineService();
      teams = teams.map((team) {
        if (team.id != result.homeTeamId && team.id != result.awayTeamId) {
          return team;
        }
        final application = disciplineService.applyToTeam(
          team: team,
          result: result,
          phase: league.currentSeason.phase,
        );
        disciplineNotifications.addAll(
          application.notifications.map(
            (notification) => (teamId: team.id, notification: notification),
          ),
        );
        return application.team;
      }).toList();
    }

    final immediateAtmosphereDeltas = <String, int>{};
    teams = teams.map((team) {
      if (team.id != result.homeTeamId && team.id != result.awayTeamId) {
        return team;
      }
      final original = league.teamById(team.id);
      final isHome = team.id == result.homeTeamId;
      final snapshot = isHome ? result.homeLineup : result.awayLineup;
      final startingEleven = snapshot.isNotEmpty
          ? snapshot
          : original?.startingEleven ?? const <Player>[];
      final assignedPositions = isHome
          ? result.homeLineupPositions
          : result.awayLineupPositions;
      final update = teamManagement.applyMatchResult(
        team: team,
        result: result,
        startingEleven: startingEleven,
        seasonYear: league.currentSeason.year,
        assignedPositions: assignedPositions.isEmpty ? null : assignedPositions,
      );
      var next = update.team;
      if (administrativeTeamIds.contains(team.id)) {
        next = teamManagement.applyAtmosphereDelta(next, -15);
        immediateAtmosphereDeltas[team.id] = -15;
      }
      return next;
    }).toList();

    var state = league.copyWith(
      teams: teams,
      currentSeason: league.currentSeason.copyWith(
        schedule: newSchedule,
        standings: standings,
      ),
      currentRound: match.round,
    );

    final playerAtmosphereDelta = state.playerTeamId == null
        ? null
        : immediateAtmosphereDeltas[state.playerTeamId];
    if (playerAtmosphereDelta != null) {
      final playerTeam = state.teamById(state.playerTeamId!);
      final atmosphereAfter = playerTeam?.atmosphere ?? 0;
      final atmosphereBefore = atmosphereAfter - playerAtmosphereDelta;
      state = messages.send(
        state,
        type: MessageType.teamEvent,
        kind: 'atmosphereShift',
        domain: MessageDomain.teamEvent,
        priority: MessagePriority.urgent,
        args: {
          'delta': playerAtmosphereDelta,
          'oldLevel': atmosphereBefore,
          'newLevel': atmosphereAfter,
          'atmosphereBefore': atmosphereBefore,
          'atmosphereAfter': atmosphereAfter,
          'atmosphere': atmosphereAfter,
        },
        payload: {
          'teamId': state.playerTeamId,
          'atmosphereDelta': playerAtmosphereDelta,
          'oldLevel': atmosphereBefore,
          'newLevel': atmosphereAfter,
          'atmosphereBefore': atmosphereBefore,
          'atmosphereAfter': atmosphereAfter,
          'atmosphere': atmosphereAfter,
          'reason': 'walkover',
        },
        dedupKey: 'atmosphere:walkover:${match.id}',
      );
    }

    for (final injury in result.injuries) {
      final team = state.teamById(injury.teamId);
      final player = team?.roster.firstWhere(
        (p) => p.id == injury.playerId,
        orElse: () => throw StateError('Missing injured player'),
      );
      if (team == null || player == null) continue;
      if (state.playerTeamId != team.id) continue;
      final definition = InjuryCatalog.byId(injury.injury.id);
      state = messages.send(
        state,
        type: MessageType.injury,
        domain: MessageDomain.health,
        args: {
          'playerName': player.name,
          'injuryName': definition.name,
          'injuryType': injury.injury.type.name,
          'severity': injury.injury.type.name,
          'days': injury.injury.daysTotal,
          'recoveryTime': injury.injury.daysTotal,
        },
        payload: {
          'playerId': player.id,
          'teamId': team.id,
          'injuryId': injury.injury.id,
          'injuryType': injury.injury.type.name,
          'playerInStartingXi': injury.playerInStartingXi,
        },
        dedupKey: 'injury:${player.id}:${injury.injury.id}',
      );
      if (injury.potentialLoss) {
        state = messages.send(
          state,
          type: MessageType.potentialLoss,
          domain: MessageDomain.health,
          args: {'playerName': player.name},
          payload: {'playerId': player.id, 'injuryId': injury.injury.id},
          dedupKey: 'potentialLoss:${player.id}:${injury.injury.id}',
        );
      }
    }

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
    for (final item in disciplineNotifications) {
      if (state.playerTeamId != item.teamId) continue;
      final notification = item.notification;
      if (notification.started) {
        state = messages.send(
          state,
          type: MessageType.suspensionStart,
          domain: MessageDomain.matchday,
          priority: notification.playerInStartingXi
              ? MessagePriority.urgent
              : MessagePriority.normal,
          args: {
            'playerName': notification.player.name,
            'games': notification.games,
            'matches': notification.games,
            'reason': notification.reason,
          },
          payload: {
            'playerId': notification.player.id,
            'teamId': item.teamId,
            'games': notification.games,
            'reason': notification.reason,
            'playerInStartingXi': notification.playerInStartingXi,
          },
        );
      }
      if (notification.ended) {
        state = messages.send(
          state,
          type: MessageType.suspensionEnd,
          domain: MessageDomain.matchday,
          args: {'playerName': notification.player.name},
          payload: {'playerId': notification.player.id, 'teamId': item.teamId},
        );
      }
    }

    final inspiredId = result.inspiredPerformancePlayerId;
    final playerTeamId = state.playerTeamId;
    if (inspiredId != null &&
        playerTeamId != null &&
        (playerTeamId == result.homeTeamId ||
            playerTeamId == result.awayTeamId)) {
      final team = state.teamById(playerTeamId);
      Player? player;
      if (team != null) {
        for (final candidate in team.roster) {
          if (candidate.id == inspiredId) {
            player = candidate;
            break;
          }
        }
      }
      if (team != null && player != null) {
        final stat = result.playerStats.firstWhere(
          (candidate) => candidate.playerId == inspiredId,
          orElse: () => const PlayerMatchStats(playerId: ''),
        );
        state = messages.send(
          state,
          type: MessageType.playerEvent,
          kind: 'inspiredPerformance',
          domain: MessageDomain.playerEvent,
          args: {'playerName': player.name},
          payload: {
            'playerId': inspiredId,
            'teamId': team.id,
            'rating': stat.playerId.isEmpty ? 0.0 : stat.rating,
            'manOfTheMatch': true,
          },
          dedupKey: 'inspired:${match.id}:$inspiredId',
        );
      }
    }
    return teamEvents.afterMatch(state, result, saveSeed: saveSeed);
  }

  Team _applyFatigue(Team team, MatchResult result, {required int seasonYear}) {
    final statsByPlayer = {
      for (final stats in result.playerStats) stats.playerId: stats,
    };
    final injuries = {
      for (final injury in result.injuries.where((i) => i.teamId == team.id))
        injury.playerId: injury,
    };
    final roster = team.roster
        .map(
          (player) => applyMatchPlayerEffects(
            player: player,
            teamId: team.id,
            result: result,
            seasonYear: seasonYear,
            balance: balance,
            stats: statsByPlayer[player.id],
            matchInjury: injuries[player.id],
          ),
        )
        .toList();
    return team.copyWith(roster: roster);
  }

  /// Daily recovery is applied once by [_dailyRecovery]. Keeping this method
  /// side-effect free prevents teams in later fixtures from recovering twice
  /// when a round contains several matches.
  Team _recoverTeam(Team team) => team;

  LeagueState _notifyStrengthTableChanges(
    LeagueState league,
    LeagueStrengthTable? previous,
    LeagueStrengthTable next,
  ) {
    final teamId = league.playerTeamId;
    if (teamId == null || previous == null) return league;
    final before = previous.entryFor(teamId);
    final after = next.entryFor(teamId);
    if (before == null ||
        after == null ||
        before.teamStatus == after.teamStatus) {
      return league;
    }
    return messages.send(
      league,
      type: MessageType.teamStatusChange,
      domain: MessageDomain.season,
      args: {
        'oldStatus': before.teamStatus.name,
        'newStatus': after.teamStatus.name,
        'expectedRank': after.expectedRank,
        'teamPower': after.teamPower,
      },
      payload: {
        'teamId': teamId,
        'oldStatus': before.teamStatus.name,
        'newStatus': after.teamStatus.name,
        'expectedRank': after.expectedRank,
        'teamPower': after.teamPower,
      },
      dedupKey:
          'teamStatus:$teamId:${next.lastCalculatedWeek}:${next.lastCalculatedDay}',
    );
  }

  LeagueState _notifyWalkover(
    LeagueState league,
    MatchResult result, {
    String? matchId,
  }) {
    if (!TeamManagementService.isWalkoverResult(result)) {
      return league;
    }

    final responsibleTeamId = result.violatingTeamIds.isEmpty
        ? result.homeTeamId
        : result.violatingTeamIds.first;
    final playerTeamId = league.playerTeamId;
    final opponentTeamId = playerTeamId == result.homeTeamId
        ? result.awayTeamId
        : result.homeTeamId;

    return messages.send(
      league,
      type: MessageType.walkover,
      priority: MessagePriority.urgent,
      args: {
        'homeTeam':
            league.teamById(result.homeTeamId)?.name ?? result.homeTeamId,
        'awayTeam':
            league.teamById(result.awayTeamId)?.name ?? result.awayTeamId,
        'team': league.teamById(responsibleTeamId)?.name ?? responsibleTeamId,
        'reason': result.reasonCode ?? 'administrative_result',
        'opponentName': league.teamById(opponentTeamId)?.name ?? opponentTeamId,
      },
      payload: {
        'matchId': matchId,
        'homeTeamId': result.homeTeamId,
        'awayTeamId': result.awayTeamId,
        'reasonCode': result.reasonCode,
        'violatingTeamIds': result.violatingTeamIds,
      },
      dedupKey: matchId == null ? null : 'walkover:$matchId',
    );
  }
}
