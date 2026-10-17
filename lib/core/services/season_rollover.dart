part of 'season_service.dart';

mixin _SeasonRollover on _SeasonServiceShared {
  /// Removes player and staff contracts that have reached zero years. The
  /// operation is idempotent, so the season rollover can call it exactly once
  /// without duplicating free-agent entries.
  LeagueState expireContracts(LeagueState league) {
    league = ContractPeriodService(balance: balance).normalizeLeague(league);
    final freeAgents = List<Player>.from(league.freeAgents);
    final staffFreeAgents = List<StaffMember>.from(
      league.canonicalStaffFreeAgents,
    );
    var state = league;
    final playerTeamId = league.playerTeamId;
    final teams = league.teams.map((t) {
      final keep = <Player>[];
      final expiredIds = <String>{};
      for (final p in t.roster) {
        if (t.id == playerTeamId &&
            p.contract.yearsRemaining == 1 &&
            p.contract.lastSeason == league.currentSeason.year) {
          state = _messages.send(
            state,
            type: MessageType.contractExpiring,
            kind: 'player',
            domain: MessageDomain.contracts,
            args: {
              'playerName': p.name,
              'subjectName': p.name,
              'teamName': t.name,
              'yearsRemaining': p.contract.yearsRemaining,
              'seasonLabel': '${league.currentSeason.year}',
            },
            payload: {
              'playerId': p.id,
              'teamId': t.id,
              'contractKind': 'player',
              'yearsRemaining': p.contract.yearsRemaining,
            },
            dedupKey:
                'contractExpiring:player:${league.currentSeason.year}:${p.id}',
          );
        }
        if (p.contract.yearsRemaining <= 0) {
          if (!freeAgents.any((item) => item.id == p.id)) {
            freeAgents.add(p);
          }
          expiredIds.add(p.id);
          if (t.id == playerTeamId) {
            state = _messages.send(
              state,
              type: MessageType.contractExpired,
              kind: 'player',
              domain: MessageDomain.contracts,
              args: {
                'playerName': p.name,
                'subjectName': p.name,
                'teamName': t.name,
              },
              payload: {
                'playerId': p.id,
                'teamId': t.id,
                'contractKind': 'player',
                'expired': true,
              },
              dedupKey:
                  'contractExpired:player:${league.currentSeason.year}:${p.id}',
            );
          }
        } else {
          keep.add(p);
        }
      }

      var staff = t.staff;
      for (final role in StaffRole.values) {
        final member = staff.canonicalMember(role);
        final memberId = member?.id;
        final contract = member?.contract;
        if (member == null || memberId == null || contract == null) {
          continue;
        }
        if (t.id == playerTeamId &&
            contract.yearsRemaining == 1 &&
            contract.lastSeason == league.currentSeason.year) {
          state = _messages.send(
            state,
            type: MessageType.contractExpiring,
            kind: 'staff',
            domain: MessageDomain.staff,
            args: {
              'staffName': member.name,
              'subjectName': member.name,
              'role': member.role.name,
              'staffRole': member.role.name,
              'teamName': t.name,
              'yearsRemaining': contract.yearsRemaining,
              'seasonLabel': '${league.currentSeason.year}',
            },
            payload: {
              'staffId': memberId,
              'teamId': t.id,
              'contractKind': 'staff',
              'yearsRemaining': contract.yearsRemaining,
            },
            dedupKey:
                'contractExpiring:staff:${league.currentSeason.year}:$memberId',
          );
        }
        if (contract.yearsRemaining > 0) continue;
        if (!staffFreeAgents.any((item) => item.id == memberId)) {
          staffFreeAgents.add(member.copyWith(contract: null));
        }
        if (t.id == playerTeamId) {
          state = _messages.send(
            state,
            type: MessageType.contractExpired,
            kind: 'staff',
            domain: MessageDomain.staff,
            args: {
              'staffName': member.name,
              'subjectName': member.name,
              'role': member.role.name,
              'staffRole': member.role.name,
              'teamName': t.name,
            },
            payload: {
              'staffId': memberId,
              'teamId': t.id,
              'contractKind': 'staff',
              'expired': true,
            },
            dedupKey:
                'contractExpired:staff:${league.currentSeason.year}:$memberId',
          );
        }
        staff = staff.withMember(role, null);
      }

      if (expiredIds.isEmpty && staff == t.staff) return t;
      return capService.applyPayroll(
        t.copyWith(
          roster: keep,
          eventState: t.eventState.clearPlayers(expiredIds),
          staff: staff,
        ),
      );
    }).toList();
    return state.copyWith(
      teams: teams,
      freeAgents: freeAgents,
      staffFreeAgents: staffFreeAgents,
    );
  }

  LeagueState rolloverSeason(LeagueState league, {int saveSeed = 0}) {
    league = ContractPeriodService(balance: balance).normalizeLeague(league);
    final playerAges = <String, int>{};
    final staffAges = <String, int>{};
    int playerAge(Player player) =>
        playerAges.putIfAbsent(player.id, () => player.age + 1);
    int staffAge(StaffMember member) =>
        staffAges.putIfAbsent(member.id, () => member.age + 1);
    if (!league.currentSeason.playoffMissAtmosphereApplied) {
      final table = league.strengthTable;
      final qualified = _playoffQualifiedTeamIds(league);
      final atmosphereDeltas = <String, int>{};
      final teams = league.teams.map((team) {
        final status = table?.statusOf(team.id);
        final delta = status == TeamStatus.elite
            ? -15
            : status == TeamStatus.contender
            ? -12
            : status == TeamStatus.pretender
            ? -8
            : 0;
        if (delta == 0 || qualified.contains(team.id)) return team;
        final updated = const TeamManagementService().applyAtmosphereDelta(
          team,
          delta,
        );
        atmosphereDeltas[team.id] = updated.atmosphere - team.atmosphere;
        return updated;
      }).toList();
      league = league.copyWith(
        teams: teams,
        currentSeason: league.currentSeason.copyWith(
          playoffMissAtmosphereApplied: true,
        ),
      );

      final playerId = league.playerTeamId;
      final playerDelta = playerId == null ? null : atmosphereDeltas[playerId];
      if (playerDelta != null) {
        final playerTeam = league.teamById(playerId!);
        league = _messages.send(
          league,
          type: MessageType.playoffMissed,
          domain: MessageDomain.season,
          priority: MessagePriority.urgent,
          args: {
            'teamName': playerTeam?.name ?? playerId,
            'seasonLabel': '${league.currentSeason.year}',
            'atmosphereDelta': playerDelta,
            'oldLevel': (playerTeam?.atmosphere ?? 0) - playerDelta,
            'newLevel': playerTeam?.atmosphere ?? 0,
            'atmosphere': playerTeam?.atmosphere ?? 0,
          },
          payload: {
            'teamId': playerId,
            'atmosphereDelta': playerDelta,
            'oldLevel': (playerTeam?.atmosphere ?? 0) - playerDelta,
            'newLevel': playerTeam?.atmosphere ?? 0,
            'atmosphereBefore': (playerTeam?.atmosphere ?? 0) - playerDelta,
            'atmosphereAfter': playerTeam?.atmosphere ?? 0,
            'atmosphere': playerTeam?.atmosphere ?? 0,
          },
          dedupKey: 'playoffMissed:${league.currentSeason.year}:$playerId',
        );
      }
    }

    final history = SeasonHistory(
      year: league.currentSeason.year,
      finalStandings: league.currentSeason.standings,
      championTeamId: league.currentSeason.championTeamId,
      draftPicks: league.lastCompletedDraft?.completedPicks ?? [],
      awards: league.currentSeason.awards,
    );

    final newYear = league.currentSeason.year + 1;

    // draftState wygenerowana przez runNextClassGeneration (tydz. 46/1, order 1)
    // jest już klasą na `newYear` — nowy sezon dziedziczy ją wprost, bez promocji.
    final nextSeasonDraftState = league.currentSeason.draftState;

    var teams = league.teams.map((t) {
      final roster = t.roster.map((p) {
        return p
            .copyWith(
              age: playerAge(p),
              state: p.state.copyWith(
                seasonsWithTeam: p.state.seasonsWithTeam + 1,
                stamina: 90,
                regularSeasonYellowCards: 0,
                playoffYellowCards: 0,
              ),
            )
            .recalculatePointValue(balance);
      }).toList();

      final staff = StaffRole.values.fold<TeamStaff>(t.staff, (staff, role) {
        final member = staff.canonicalMember(role);
        return member == null
            ? staff
            : staff.withMember(role, member.copyWith(age: staffAge(member)));
      });

      // Player development ticks weekly in `DaySimulator`, not here — avoid
      // double-applying growth on top of the season's weekly ticks.
      var team = t.copyWith(
        roster: roster
            .map(
              (p) => p.copyWith(
                previousOvr: p.overall(balance).round(),
                seasonStartOvr: p.overall(balance),
                previousPotential: p.potentialStars,
              ),
            )
            .toList(),
        eventState: t.eventState.resetForSeason(),
        staff: staff,
        finance: t.finance.copyWith(midLevelExceptionAvailable: true),
        // Prognoza miejsca w tabeli (`projectedFinish`) i dyskonto czasowe
        // zmieniają się co sezon — przeliczyć wartość wszystkich
        // posiadanych picków pod nowy `currentYear`.
        ownedPicks: t.ownedPicks
            .map((p) => p.recalculateTradeValue(currentYear: newYear))
            .toList(),
      );

      return capService.applyPayroll(team);
    }).toList();

    final schedule = const ScheduleGenerator().generateDoubleRoundRobin(
      teams.map((t) => t.id).toList(),
    );
    final standings = [
      for (final conf in Conference.values)
        ConferenceStandings(
          conference: conf,
          standings: teams
              .where((t) => t.conference == conf)
              .map((t) => Standing(teamId: t.id))
              .toList(),
        ),
    ];

    var nextLeague = league.copyWith(
      teams: teams,
      freeAgents: [
        for (final player in league.freeAgents)
          player
              .copyWith(age: playerAge(player))
              .recalculatePointValue(balance),
      ],
      staffFreeAgents: [
        for (final member in league.canonicalStaffFreeAgents)
          member.copyWith(age: staffAge(member)),
      ],
      history: [...league.history, history],
      currentWeek: 1,
      currentDay: 1,
      currentRound: 0,
      currentSeason: Season(
        year: newYear,
        phase: SeasonPhase.regular,
        schedule: schedule,
        standings: standings,
        draftState: nextSeasonDraftState,
        staffGrowthDone: false,
        playerRetirementsDone: false,
        combineDone: false,
        finalMockDone: false,
        faOpenDone: false,
        scoutReportDone: false,
        tradeDeadlineAcked: false,
        nextClassGenerationDone: false,
        nextTvCapResetSeason: league.currentSeason.nextTvCapResetSeason,
        nextTvCapIncreasePct: league.currentSeason.nextTvCapIncreasePct,
        capUpdateTvDone: false,
      ),
    );
    nextLeague = expireContracts(nextLeague);
    nextLeague = NegotiationService(
      balance: balance,
    ).pruneHistory(nextLeague, seasonYear: newYear, week: 1, day: 1);
    return rosterManagement.ensurePreseasonRoster(
      nextLeague,
      saveSeed: saveSeed,
    );
  }

  @override
  Set<String> _playoffQualifiedTeamIds(LeagueState league) {
    final qualified = <String>{};
    for (final bracket in league.currentSeason.playoffBrackets) {
      for (final series in [
        ...bracket.quarterFinals,
        ...bracket.semiFinals,
        ...bracket.conferenceFinal,
        if (bracket.leagueFinal != null) bracket.leagueFinal!,
      ]) {
        qualified
          ..add(series.higherSeedTeamId)
          ..add(series.lowerSeedTeamId);
      }
    }
    return qualified;
  }
}
