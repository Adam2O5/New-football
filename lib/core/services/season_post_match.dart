part of 'season_service.dart';

mixin _SeasonPostMatch on _SeasonServiceShared {
  MatchResult _sim(
    LeagueState league,
    String homeId,
    String awayId, {
    required int saveSeed,
    required String matchId,
    SeasonPhase phase = SeasonPhase.regular,
    MatchStake? stake,
  }) {
    final home = league.teamById(homeId)!;
    final away = league.teamById(awayId)!;
    final context = contextFactory.createForPostseason(
      home: home,
      away: away,
      seasonYear: league.currentSeason.year,
      matchId: matchId,
      saveSeed: saveSeed,
      stake: stake ?? _stakeForPhase(phase),
      week: league.currentWeek,
    );
    return aiMatchdayService.simulateFullMatch(
      home: home,
      away: away,
      context: context,
      saveSeed: saveSeed,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      matchId: matchId,
      phase: phase,
      homeOpponentFormationHistory:
          AiMatchdayService.formationHistoryFromSchedule(
            league.currentSeason.schedule,
            home.id,
            away.id,
          ),
      awayOpponentFormationHistory:
          AiMatchdayService.formationHistoryFromSchedule(
            league.currentSeason.schedule,
            away.id,
            home.id,
          ),
    );
  }

  MatchStake _stakeForPhase(SeasonPhase phase) => switch (phase) {
    SeasonPhase.playIn => MatchStake.playIn,
    SeasonPhase.playoff => MatchStake.playoff,
    _ => MatchStake.regular,
  };

  /// Simulates one postseason game, unless the player's team is in it — in
  /// that case (and unless [simulatePlayerMatch] forces the old atomic
  /// behaviour) the pre-match message is still emitted but simulation is
  /// skipped: [result] comes back `null` and [playerMatch] describes the
  /// pending fixture so the caller (ultimately `DaySimulator`) can pause and
  /// hand off to the interactive matchday flow, exactly like a regular
  /// season fixture.
  @override
  ({LeagueState league, MatchResult? result, ScheduledMatch? playerMatch})
  _simPostseason(
    LeagueState league,
    String homeId,
    String awayId, {
    required int saveSeed,
    required String matchId,
    required SeasonPhase phase,
    MatchStake? stake,
    bool simulatePlayerMatch = false,
  }) {
    var state = rosterManagement.ensurePreMatchdaySafety(
      league,
      saveSeed: saveSeed,
    );
    final effectiveStake = stake ?? _stakeForPhase(phase);
    final home = state.teamById(homeId);
    final away = state.teamById(awayId);
    if (home != null && away != null && state.playerTeamId != null) {
      final playerInFixture =
          state.playerTeamId == homeId || state.playerTeamId == awayId;
      if (playerInFixture) {
        final context = contextFactory.createForPostseason(
          home: home,
          away: away,
          seasonYear: league.currentSeason.year,
          matchId: matchId,
          saveSeed: saveSeed,
          stake: effectiveStake,
          week: league.currentWeek,
        );
        final report = PreMatchValidator(
          balance: balance,
        ).validate(home: home, away: away);
        state = matchMessageEmitter.emitPreMatch(
          league: state,
          matchId: matchId,
          homeTeamId: homeId,
          awayTeamId: awayId,
          context: context,
          report: report,
        );
        if (!simulatePlayerMatch) {
          return (
            league: state,
            result: null,
            playerMatch: ScheduledMatch(
              id: matchId,
              homeTeamId: homeId,
              awayTeamId: awayId,
              round: -1,
            ),
          );
        }
      }
    }
    final rawResult = _sim(
      state,
      homeId,
      awayId,
      saveSeed: saveSeed,
      matchId: matchId,
      phase: phase,
      stake: effectiveStake,
    );
    final result = _resolvePostseasonTiebreak(
      rawResult,
      saveSeed: saveSeed,
      seasonYear: state.currentSeason.year,
      matchId: matchId,
    );
    var postseasonState = _applyMatchFatigue(state, result);
    postseasonState = _applyPostseasonDiscipline(
      postseasonState,
      result,
      phase,
      matchId: matchId,
    );
    postseasonState = teamEvents.afterMatch(
      postseasonState,
      result,
      saveSeed: saveSeed,
    );
    postseasonState = _recordFixtureResult(postseasonState, matchId, result);
    return (league: postseasonState, result: result, playerMatch: null);
  }

  /// Applies match fatigue to the two participating teams' rosters, mirror
  /// of `DaySimulator._applyFatigue` for regular season fixtures. Postseason
  /// games skip `_applyResult` entirely (they don't touch `standings` or
  /// `schedule`), so without this call playoff/play-in matches would leave
  /// players fully fresh no matter how many games they'd just played.
  @override
  LeagueState _applyMatchFatigue(LeagueState league, MatchResult result) {
    if (TeamManagementService.isWalkoverResult(result)) return league;
    final seasonYear = league.currentSeason.year;
    final teams = league.teams.map((t) {
      final isParticipant =
          t.id == result.homeTeamId || t.id == result.awayTeamId;
      if (!isParticipant) return t;
      final statsByPlayer = {
        for (final stats in result.playerStats) stats.playerId: stats,
      };
      final injuries = {
        for (final injury in result.injuries.where((i) => i.teamId == t.id))
          injury.playerId: injury,
      };
      final roster = t.roster
          .map(
            (player) => applyMatchPlayerEffects(
              player: player,
              teamId: t.id,
              result: result,
              seasonYear: seasonYear,
              balance: balance,
              stats: statsByPlayer[player.id],
              matchInjury: injuries[player.id],
            ),
          )
          .toList();
      return t.copyWith(roster: roster);
    }).toList();
    return league.copyWith(teams: teams);
  }

  @override
  MatchResult _resolvePostseasonTiebreak(
    MatchResult result, {
    required int saveSeed,
    required int seasonYear,
    required String matchId,
  }) {
    if (result.homeGoals != result.awayGoals) return result;

    final random = Random(matchSeed(saveSeed, seasonYear, '$matchId:tiebreak'));
    final homeId = result.homeTeamId;
    final awayId = result.awayTeamId;

    // A tied knockout match always reaches extra time. A deterministic
    // extra-time goal resolves most ties; the remaining ties go to a
    // deterministic shootout. The regulation score remains separate from
    // shootout kicks, so player/league statistics do not count penalties as
    // goals.
    if (random.nextDouble() < 0.55) {
      final homeWins = random.nextBool();
      final homeGoals = result.homeGoals + (homeWins ? 1 : 0);
      final awayGoals = result.awayGoals + (homeWins ? 0 : 1);
      final resolved = result.copyWith(
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        homeStats: result.homeStats.copyWith(goals: homeGoals),
        awayStats: result.awayStats.copyWith(goals: awayGoals),
        wentToExtraTime: true,
        winnerTeamId: homeWins ? homeId : awayId,
        matchEndMinute: 120,
      );
      return _attributeExtraTimeGoal(
        resolved,
        teamId: homeWins ? homeId : awayId,
        random: random,
      );
    }

    var homeShootout = 3 + random.nextInt(3);
    var awayShootout = 3 + random.nextInt(3);
    if (homeShootout == awayShootout) {
      if (random.nextBool()) {
        homeShootout++;
      } else {
        awayShootout++;
      }
    }
    return result.copyWith(
      wentToExtraTime: true,
      wentToShootout: true,
      shootoutHomeGoals: homeShootout,
      shootoutAwayGoals: awayShootout,
      winnerTeamId: homeShootout > awayShootout ? homeId : awayId,
      matchEndMinute: 120,
    );
  }

  MatchResult _attributeExtraTimeGoal(
    MatchResult result, {
    required String teamId,
    required Random random,
  }) {
    final teamPlayerIds = teamId == result.homeTeamId
        ? {
            ...result.homeLineup.map((player) => player.id),
            ...result.homeSnapshot.startingXi.map((player) => player.id),
            ...result.homeSnapshot.bench.map((player) => player.id),
          }
        : {
            ...result.awayLineup.map((player) => player.id),
            ...result.awaySnapshot.startingXi.map((player) => player.id),
            ...result.awaySnapshot.bench.map((player) => player.id),
          };
    final eligible = result.playerStats
        .where((stats) => teamPlayerIds.contains(stats.playerId))
        .toList();
    if (eligible.isEmpty) return result;
    final played = eligible.where((stats) => stats.minutes > 0).toList();
    final scorerPool = played.isEmpty ? eligible : played;
    final scorer = scorerPool[random.nextInt(scorerPool.length)];

    return result.copyWith(
      playerStats: [
        for (final stats in result.playerStats)
          if (stats.playerId == scorer.playerId)
            stats.copyWith(goals: stats.goals + 1)
          else
            stats,
      ],
      events: [
        ...result.events,
        MatchEvent(
          type: MatchEventType.goal,
          minute: 105,
          teamId: teamId,
          playerId: scorer.playerId,
          description: 'extra_time_goal',
        ),
      ],
    );
  }

  @override
  LeagueState _applyPostseasonDiscipline(
    LeagueState league,
    MatchResult result,
    SeasonPhase phase, {
    String? matchId,
  }) {
    final disciplineService = const DisciplineService();
    final administrativeTeamIds = TeamManagementService.walkoverTeamIds(result);
    final isAdministrative = TeamManagementService.isWalkoverResult(result);
    final statsByPlayer = {
      for (final stats in result.playerStats) stats.playerId: stats,
    };
    final injuriesByPlayer = {
      for (final injury in result.injuries)
        if (injury.teamId == result.homeTeamId ||
            injury.teamId == result.awayTeamId)
          '${injury.teamId}:${injury.playerId}': injury,
    };
    final notifications =
        <({String teamId, DisciplineNotification notification})>[];

    final teams = league.teams.map((team) {
      final isParticipant =
          team.id == result.homeTeamId || team.id == result.awayTeamId;
      if (!isParticipant) return team;

      var next = team;
      if (!isAdministrative) {
        final roster = team.roster
            .map(
              (player) => applyMatchPlayerEffects(
                player: player,
                teamId: team.id,
                result: result,
                seasonYear: league.currentSeason.year,
                balance: balance,
                stats: statsByPlayer[player.id],
                matchInjury: injuriesByPlayer['${team.id}:${player.id}'],
              ),
            )
            .toList();
        next = team.copyWith(roster: roster);

        final application = disciplineService.applyToTeam(
          team: next,
          result: result,
          phase: phase,
        );
        notifications.addAll(
          application.notifications.map(
            (notification) => (teamId: team.id, notification: notification),
          ),
        );
        next = application.team;
      }

      final original = league.teamById(team.id);
      final snapshot = team.id == result.homeTeamId
          ? result.homeLineup
          : result.awayLineup;
      final startingEleven = snapshot.isNotEmpty
          ? snapshot
          : original?.startingEleven ?? const <Player>[];
      final assignedPositions = team.id == result.homeTeamId
          ? result.homeLineupPositions
          : result.awayLineupPositions;
      next = const TeamManagementService()
          .applyMatchResult(
            team: next,
            result: result,
            startingEleven: startingEleven,
            seasonYear: league.currentSeason.year,
            assignedPositions: assignedPositions.isEmpty
                ? null
                : assignedPositions,
          )
          .team;
      if (isAdministrative && administrativeTeamIds.contains(team.id)) {
        next = const TeamManagementService().applyAtmosphereDelta(next, -15);
      }
      return next;
    }).toList();

    var state = league.copyWith(teams: teams);
    for (final item in notifications) {
      if (state.playerTeamId != item.teamId) continue;
      final notification = item.notification;
      if (notification.started) {
        state = _messages.send(
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
        state = _messages.send(
          state,
          type: MessageType.suspensionEnd,
          domain: MessageDomain.matchday,
          args: {'playerName': notification.player.name},
          payload: {'playerId': notification.player.id, 'teamId': item.teamId},
        );
      }
    }

    for (final injury in result.injuries) {
      final team = state.teamById(injury.teamId);
      final player = team?.roster.cast<Player?>().firstWhere(
        (candidate) => candidate?.id == injury.playerId,
        orElse: () => null,
      );
      if (team == null || player == null || state.playerTeamId != team.id) {
        continue;
      }
      final definition = InjuryCatalog.byId(injury.injury.id);
      state = _messages.send(
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
        state = _messages.send(
          state,
          type: MessageType.potentialLoss,
          domain: MessageDomain.health,
          args: {'playerName': player.name},
          payload: {'playerId': player.id, 'injuryId': injury.injury.id},
          dedupKey: 'potentialLoss:${player.id}:${injury.injury.id}',
        );
      }
    }

    final inspiredId = result.inspiredPerformancePlayerId;
    if (inspiredId != null) {
      final team = state.teamById(result.homeTeamId);
      final awayTeam = state.teamById(result.awayTeamId);
      final player =
          team?.roster.cast<Player?>().firstWhere(
            (candidate) => candidate?.id == inspiredId,
            orElse: () => null,
          ) ??
          awayTeam?.roster.cast<Player?>().firstWhere(
            (candidate) => candidate?.id == inspiredId,
            orElse: () => null,
          );
      final inspiredTeam = team?.roster.any((p) => p.id == inspiredId) == true
          ? team
          : awayTeam;
      if (player != null &&
          inspiredTeam != null &&
          state.playerTeamId == inspiredTeam.id) {
        final stat = statsByPlayer[inspiredId];
        state = _messages.send(
          state,
          type: MessageType.playerEvent,
          kind: 'inspiredPerformance',
          domain: MessageDomain.playerEvent,
          args: {'playerName': player.name},
          payload: {
            'playerId': inspiredId,
            'teamId': inspiredTeam.id,
            'rating': stat?.rating ?? 0.0,
            'manOfTheMatch': true,
          },
          dedupKey: 'inspired:${matchId ?? result.homeTeamId}:$inspiredId',
        );
      }
    }

    final playerTeamId = state.playerTeamId;
    if (playerTeamId == result.homeTeamId ||
        playerTeamId == result.awayTeamId) {
      if (!TeamManagementService.isWalkoverResult(result)) {
        return state;
      }
      final responsibleTeamId = result.violatingTeamIds.isEmpty
          ? result.homeTeamId
          : result.violatingTeamIds.first;
      state = _messages.send(
        state,
        type: MessageType.walkover,
        args: {
          'homeTeam':
              league.teamById(result.homeTeamId)?.name ?? result.homeTeamId,
          'awayTeam':
              league.teamById(result.awayTeamId)?.name ?? result.awayTeamId,
          'team': league.teamById(responsibleTeamId)?.name ?? responsibleTeamId,
          'reason': result.reasonCode ?? 'administrative_result',
        },
        payload: {
          'matchId': matchId,
          'homeTeamId': result.homeTeamId,
          'awayTeamId': result.awayTeamId,
          'teamId': responsibleTeamId,
          'reasonCode': result.reasonCode,
          'violatingTeamIds': result.violatingTeamIds,
        },
        dedupKey: matchId == null ? null : 'walkover:$matchId',
      );
    }
    return state;
  }
}
