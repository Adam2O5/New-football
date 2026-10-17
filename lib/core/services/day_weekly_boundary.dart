part of 'day_simulator.dart';

mixin _DayWeeklyBoundary {
  BalanceConfig get balance;

  AiTradeService get aiTradeService;

  CalendarService get calendar;

  DevelopmentService get development;

  ScoutingService get scouting;

  ContractMarketService get contractMarket;

  MessageService get messages;

  TeamManagementService get teamManagement;

  PlayerEventService get playerEvents;

  TeamEventService get teamEvents;

  SeasonService get season;

  /// Apply a finished player match and advance the day. Match-result
  /// messages are created after the date advances, so they are delivered as
  /// part of the next day's start-of-day package.
  ///
  /// Play-in/playoff fixtures (identified by the `playIn:`/`playoff:`
  /// [ScheduledMatch.id] prefix `advancePlayInForDate`/
  /// `advancePlayoffsForDate` use for a pending `playerMatch`) do not live in
  /// `currentSeason.schedule`, so they are routed to `SeasonService`'s
  /// dedicated resume methods instead of [_applyResult].
  /// Weekly systems run once at the Sunday → Monday boundary. Shared between
  /// [simulateDay] and [applyPlayerMatchResult] so they never get silently
  /// skipped on a week where the boundary falls on a day resolved through
  /// the player-match resume path instead of normal day simulation.
  ///
  /// `state` must already have `currentWeek`/`currentDay`/`currentSeason.
  /// phase` advanced to the new week by the caller. `week`/`phase` are the
  /// *pre-advance* values (this week, about to end) — needed for rank
  /// lookups, message group keys, and offseason-transition checks that
  /// compare against the phase we're leaving.
  LeagueState _runWeeklyBoundary(
    LeagueState state, {
    required int week,
    required SeasonPhase phase,
    required int saveSeed,
    required bool resolveContractMarket,
  }) {
    final nextPhase = state.currentSeason.phase;

    // Team indicators are updated before development so the new week's
    // atmosphere is the development input.
    final weeklyUpdates = <String, TeamWeeklyUpdate>{};
    final strengthTable = state.strengthTable;
    final weeklyTeams = state.teams.map((team) {
      final update = teamManagement.updateWeekly(
        team: team,
        seasonYear: state.currentSeason.year,
        week: week,
        expectedRank: strengthTable?.rankOf(team.id) ?? 15,
        currentRank: TeamManagementService.actualRankOf(state, team.id),
      );
      weeklyUpdates[team.id] = update;
      return update.team;
    }).toList();
    state = state.copyWith(teams: weeklyTeams);

    final playerWeeklyUpdate = state.playerTeamId == null
        ? null
        : weeklyUpdates[state.playerTeamId];
    if (playerWeeklyUpdate != null &&
        (playerWeeklyUpdate.atmosphereDelta != 0 ||
            playerWeeklyUpdate.chemistryDelta != 0)) {
      final oldAtmosphere =
          playerWeeklyUpdate.team.atmosphere -
          playerWeeklyUpdate.atmosphereDelta;
      state = messages.send(
        state,
        type: MessageType.teamEvent,
        kind: 'atmosphereShift',
        domain: MessageDomain.teamEvent,
        args: {
          'delta': playerWeeklyUpdate.atmosphereDelta,
          'chemistryDelta': playerWeeklyUpdate.chemistryDelta,
          'oldLevel': oldAtmosphere,
          'newLevel': playerWeeklyUpdate.team.atmosphere,
          'atmosphereBefore': oldAtmosphere,
          'atmosphereAfter': playerWeeklyUpdate.team.atmosphere,
          'atmosphere': playerWeeklyUpdate.team.atmosphere,
          'chemistry': playerWeeklyUpdate.team.chemistry,
        },
        payload: {
          'teamId': state.playerTeamId,
          'atmosphereDelta': playerWeeklyUpdate.atmosphereDelta,
          'chemistryDelta': playerWeeklyUpdate.chemistryDelta,
          'oldLevel': oldAtmosphere,
          'newLevel': playerWeeklyUpdate.team.atmosphere,
          'atmosphereBefore': oldAtmosphere,
          'atmosphereAfter': playerWeeklyUpdate.team.atmosphere,
          'atmosphere': playerWeeklyUpdate.team.atmosphere,
          'chemistry': playerWeeklyUpdate.team.chemistry,
        },
        groupKey: 'atmosphere:$week',
      );
    }

    state = teamEvents.weeklyTick(
      state,
      saveSeed: saveSeed,
      offseason:
          phase == SeasonPhase.offseason || nextPhase == SeasonPhase.offseason,
    );

    final developmentChanges = <DevelopmentChange>[];
    final developedTeams = state.teams.map((team) {
      final tick = development.developTeamWithReport(team);
      if (team.id == state.playerTeamId) {
        developmentChanges.addAll(tick.changes.where((c) => c.ovrDelta != 0));
      }
      return tick.team;
    }).toList();
    state = state.copyWith(
      teams: developedTeams,
      freeAgents: state.freeAgents
          .map(
            (player) => development
                .developPlayerWithContext(
                  player.copyWith(
                    state: player.state.copyWith(minutesThisWeek: 0),
                  ),
                  atmosphere: 50,
                )
                .player,
          )
          .toList(),
    );

    for (final change in developmentChanges) {
      state = messages.send(
        state,
        type: MessageType.playerEvent,
        kind: 'ovrChange',
        domain: MessageDomain.playerEvent,
        titleKey: 'msg_ovrDigest_digest_title',
        bodyKey: 'msg_ovrDigest_digest_body',
        args: {'count': 1, 'week': week},
        payload: {
          'playerId': change.playerId,
          'playerName': change.playerName,
          'ovrDelta': change.ovrDelta,
          'growthRate': change.growthRate,
        },
        groupKey: 'ovr:own:$week',
      );
    }

    // Individual events consume the just-computed development result, so
    // their counters and rolls run after the weekly development tick.
    state = playerEvents.weeklyTick(
      state,
      saveSeed: saveSeed,
      offseason:
          phase == SeasonPhase.offseason || nextPhase == SeasonPhase.offseason,
    );

    // Continuous scouting tick (`docs/staff_rules.md` §5), while a draft
    // class is known (from game creation through the season's draft week).
    if (state.currentSeason.draftState != null) {
      final draftClass = state.currentSeason.draftState!.draftClass;
      state = state.copyWith(
        teams: state.teams.map((team) {
          final evalStars = team.staff.scout?.attributes.evaluation ?? 0.0;
          return team.copyWith(
            scouting: scouting.tickKnowledge(
              team.scouting,
              evalStars,
              prospects: draftClass.prospects,
              seed: saveSeed,
              seasonYear: state.currentSeason.year,
              week: state.currentWeek,
              teamId: team.id,
            ),
          );
        }).toList(),
      );
    }

    if (week == balance.calendar.draftWeek) {
      state = season.expireContracts(state);
    }

    // The market runs once at the same Sunday → Monday boundary as the
    // other weekly AI systems. It is headless and therefore also runs when
    // the player is not looking at TradeScreen.
    if (resolveContractMarket) {
      state = contractMarket.weeklyTick(state, saveSeed: saveSeed);
    }
    state = aiTradeService.weeklyTick(state, saveSeed: saveSeed).league;

    state = messages.send(
      state,
      type: MessageType.calendar,
      domain: MessageDomain.system,
      titleKey: 'msg_calendar_newWeek_title',
      bodyKey: 'msg_calendar_newWeek_body',
      args: {'week': state.currentWeek, 'phase': nextPhase.name},
    );

    if (week == balance.calendar.seasonCycleWeeks) {
      state = season.rolloverSeason(state, saveSeed: saveSeed);
      state = state.copyWith(
        currentHour: calendar.initialHourForDate(
          state.currentWeek,
          state.currentDay,
        ),
        hourlyPlayerOfferUsed: false,
        hourlyStaffOfferUsed: false,
      );
    }

    return state;
  }
}
