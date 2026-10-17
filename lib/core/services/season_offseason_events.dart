part of 'season_service.dart';

mixin _SeasonOffseasonEvents on _SeasonServiceShared {
  LeagueState runCapUpdateTv(LeagueState league, {int saveSeed = 0}) {
    final season = league.currentSeason;
    if (season.capUpdateTvDone) return league;

    var resetSeason = season.nextTvCapResetSeason;
    var increasePct = season.nextTvCapIncreasePct;
    if (resetSeason <= 0 || increasePct <= 0) {
      final initial = capService.tvScheduleFor(
        currentYear: season.year,
        saveSeed: saveSeed,
      );
      resetSeason = initial.nextTvCapResetSeason;
      increasePct = initial.nextTvCapIncreasePct;
    }

    if (season.year != resetSeason) {
      return league.copyWith(
        currentSeason: season.copyWith(
          nextTvCapResetSeason: resetSeason,
          nextTvCapIncreasePct: increasePct,
          capUpdateTvDone: true,
        ),
      );
    }

    final updatedTeams = capService.applyTvUpdate(
      league.teams,
      increasePct: increasePct,
    );
    final nextAgreement = capService.tvScheduleFor(
      currentYear: season.year,
      saveSeed: saveSeed,
    );
    var state = league.copyWith(
      teams: updatedTeams,
      currentSeason: season.copyWith(
        nextTvCapResetSeason: nextAgreement.nextTvCapResetSeason,
        nextTvCapIncreasePct: nextAgreement.nextTvCapIncreasePct,
        capUpdateTvDone: true,
      ),
    );

    state = _messages.send(
      state,
      type: MessageType.capUpdateTv,
      domain: MessageDomain.finance,
      priority: MessagePriority.urgent,
      args: {
        'increasePct': increasePct,
        'salaryCap': state.teams.first.finance.salaryCap,
        'newCap': state.teams.first.finance.salaryCap,
        'seasonLabel': '${season.year}',
        'firstApron': state.teams.first.finance.firstApron,
        'secondApron': state.teams.first.finance.secondApron,
        'nextResetSeason': nextAgreement.nextTvCapResetSeason,
      },
      payload: {
        'increasePct': increasePct,
        'salaryCap': state.teams.first.finance.salaryCap,
        'firstApron': state.teams.first.finance.firstApron,
        'secondApron': state.teams.first.finance.secondApron,
        'nextTvCapResetSeason': nextAgreement.nextTvCapResetSeason,
      },
      dedupKey: 'capUpdateTv:${season.year}',
    );

    final playerTeam = state.playerTeam;
    if (playerTeam != null) {
      final snapshot = capService.snapshot(playerTeam);
      if (snapshot.status == CapStatus.firstApron ||
          snapshot.status == CapStatus.secondApron) {
        state = _messages.send(
          state,
          type: MessageType.apronWarning,
          domain: MessageDomain.finance,
          args: {
            'payroll': snapshot.payroll,
            'currentPayroll': snapshot.payroll,
            'thresholdName': snapshot.status.name,
            'firstApron': snapshot.firstApron,
            'secondApron': snapshot.secondApron,
            'payrollAboveSecondApron': snapshot.isAboveSecondApron,
          },
          payload: {
            'teamId': playerTeam.id,
            'payroll': snapshot.payroll,
            'firstApron': snapshot.firstApron,
            'secondApron': snapshot.secondApron,
            'payrollAboveSecondApron': snapshot.isAboveSecondApron,
          },
          dedupKey: 'apronWarning:${season.year}:${playerTeam.id}',
        );
      }
    }
    return state;
  }

  LeagueState runStaffGrowthAndRetire(LeagueState league, {int saveSeed = 0}) {
    if (league.currentSeason.staffGrowthDone) return league;
    final state = staffService.growthAndRetireTick(league, saveSeed: saveSeed);
    return state.copyWith(
      currentSeason: state.currentSeason.copyWith(staffGrowthDone: true),
    );
  }

  /// Emerytury (śr tyg. 44): wyłącznie tabela bazowa
  /// `BalanceConfig.retirement.baseChanceForAge(age)`, bez modyfikatorów.
  LeagueState runPlayerRetirements(LeagueState league, {int? saveSeed}) {
    if (league.currentSeason.playerRetirementsDone) return league;
    final retired = <({String id, String name, String teamId})>[];
    final rolls = <String, bool>{};
    bool retires(Player player) => rolls.putIfAbsent(player.id, () {
      final chance = balance.retirement.baseChanceForAge(player.age);
      final rng = saveSeed == null
          ? _random
          : Random(
              seasonEventSeed(
                saveSeed,
                league.currentSeason.year,
                'player-retire',
                subjectId: player.id,
              ),
            );
      return chance > 0 && rng.nextDouble() < chance;
    });
    final teams = league.teams.map((t) {
      final keep = <Player>[];
      final retiredIds = <String>{};
      for (final p in t.roster) {
        if (retires(p)) {
          retired.add((id: p.id, name: p.name, teamId: t.id));
          retiredIds.add(p.id);
        } else {
          keep.add(p);
        }
      }
      var updated = t.copyWith(roster: keep);
      if (retiredIds.isNotEmpty) {
        updated = updated.copyWith(
          eventState: t.eventState.clearPlayers(retiredIds),
        );
      }
      return capService.applyPayroll(updated);
    }).toList();

    final freeAgents = [
      for (final player in league.freeAgents)
        if (!retires(player)) player,
    ];
    var state = league.copyWith(
      teams: teams,
      freeAgents: freeAgents,
      currentSeason: league.currentSeason.copyWith(playerRetirementsDone: true),
    );

    for (final record in retired) {
      if (record.teamId != state.playerTeamId) continue;
      state = _messages.send(
        state,
        type: MessageType.retirementPlayer,
        domain: MessageDomain.roster,
        args: {
          'playerName': record.name,
          'ownClub': true,
          'seasonLabel': '${state.currentSeason.year}',
        },
        payload: {
          'playerId': record.id,
          'teamId': record.teamId,
          'ownClub': true,
        },
        dedupKey: 'retirementPlayer:${state.currentSeason.year}:${record.id}',
      );
    }

    if (retired.isNotEmpty) {
      state = _messages.send(
        state,
        type: MessageType.retirementLeagueDigest,
        domain: MessageDomain.roster,
        priority: MessagePriority.silenced,
        titleKey: 'msg_retirementLeagueDigest_digest_title',
        bodyKey: 'msg_retirementLeagueDigest_digest_body',
        args: {'count': retired.length, 'week': state.currentWeek},
        payload: {
          'retiredPlayers': [
            for (final record in retired)
              {
                'playerId': record.id,
                'playerName': record.name,
                'teamId': record.teamId,
              },
          ],
          'isLeagueMessage': true,
        },
        groupKey: 'retire:league:${state.currentWeek}',
        dedupKey: 'retire:league:${state.currentSeason.year}',
      );
    }

    return rosterManagement.replenishAfterRetirements(
      state,
      saveSeed: saveSeed ?? 0,
    );
  }

  LeagueState runFreeAgencyOpen(LeagueState league) {
    var state = league.copyWith(
      currentSeason: league.currentSeason.copyWith(faOpenDone: true),
    );
    return _msg(
      state,
      MessageType.calendar,
      'Rynek wolnych agentów otwarty',
      'Możesz teraz składać oferty zawodnikom i sztabowi bez klubu.',
      kind: 'freeAgencyOpen',
    );
  }
}
