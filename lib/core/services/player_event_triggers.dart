part of 'player_event_service.dart';

mixin _PlayerEventTriggers on _PlayerEventShared {
  LeagueState _tryBreakthrough(
    LeagueState state,
    String teamId,
    String playerId,
    int saveSeed,
  ) {
    final team = _teamById(state, teamId);
    final player = team == null
        ? null
        : _currentPlayer(state, teamId, playerId);
    if (team == null || player == null) return state;
    final events = balance.events;
    final eventState = player.state.eventState;
    if (player.age > events.breakthroughAgeMax ||
        player.hidden.overallProgress < events.breakthroughProgressMin ||
        eventState.counterValue('highFormWeeks') <
            events.breakthroughFormWeeks ||
        eventState.counterValue('breakthroughYear') ==
            state.currentSeason.year ||
        _hasPendingDecision(state, player.id, 'breakthrough') ||
        !_rollFor(
          state,
          player,
          'breakthrough',
          events.breakthroughChance,
          saveSeed,
        )) {
      return state;
    }
    final next = player.copyWith(
      state: player.state.copyWith(
        eventState: eventState
            .addModifier(
              type: 'growthRate',
              value: events.breakthroughGrowthRateBonus,
              weeks: events.breakthroughDurationWeeks,
            )
            .withCooldown(
              'breakthrough',
              52 * events.breakthroughCooldownSeasons,
            )
            .withCounter('breakthroughYear', state.currentSeason.year),
      ),
    );
    state = _replacePlayer(state, team.id, next);
    return _emit(
      state,
      teamId: team.id,
      player: next,
      kind: 'breakthrough',
      args: {'playerName': next.name},
      payload: {
        'playerId': next.id,
        'teamId': team.id,
        'growthRateDelta': events.breakthroughGrowthRateBonus,
        'durationWeeks': events.breakthroughDurationWeeks,
      },
    );
  }

  LeagueState _tryColdStreak(
    LeagueState state,
    String teamId,
    String playerId,
    int saveSeed,
  ) {
    final team = _teamById(state, teamId);
    final player = team == null
        ? null
        : _currentPlayer(state, teamId, playerId);
    if (team == null || player == null) return state;
    final events = balance.events;
    final eventState = player.state.eventState;
    if (player.personality == PlayerPersonality.professional ||
        player.state.form > events.coldStreakFormMax ||
        eventState.counterValue('lowFormWeeks') < events.coldStreakWeeks ||
        eventState.isOnCooldown('coldStreak') ||
        _hasPendingDecision(state, player.id, 'coldStreak') ||
        !_rollFor(
          state,
          player,
          'coldStreak',
          events.coldStreakChance,
          saveSeed,
        )) {
      return state;
    }
    return _emitDecision(
      state,
      teamId: team.id,
      player: player,
      kind: 'coldStreak',
      expiryDays: 1,
      saveSeed: saveSeed,
      payload: {
        'form': player.state.form,
        'lowFormWeeks': eventState.counterValue('lowFormWeeks'),
      },
    );
  }

  LeagueState _tryInjuryComplication(
    LeagueState state,
    String teamId,
    String playerId,
    int saveSeed, {
    required bool recoveryWeek,
  }) {
    final team = _teamById(state, teamId);
    final player = team == null
        ? null
        : _currentPlayer(state, teamId, playerId);
    if (team == null || player == null) return state;
    final events = balance.events;
    final eventState = player.state.eventState;
    final eligible =
        recoveryWeek ||
        (!eventState.majorInjuryActiveLastTick &&
            eventState.weeksSinceMajorInjury == 1);
    if (!eligible ||
        eventState.lastMajorInjury == null ||
        eventState.isOnCooldown('injuryComplication') ||
        _hasPendingDecision(state, player.id, 'injuryComplication') ||
        !_rollFor(
          state,
          player,
          'injuryComplication',
          events.majorInjuryComplicationChance,
          saveSeed,
        )) {
      return state;
    }
    final original = eventState.lastMajorInjury!;
    return _emitDecision(
      state,
      teamId: team.id,
      player: player,
      kind: 'injuryComplication',
      expiryDays: 1,
      saveSeed: saveSeed,
      args: {'extraDays': events.injuryComplicationCautiousExtraDaysMin},
      payload: {
        'injuryId': original.id,
        'originalDays': original.daysTotal,
        'injuryGroup': original.group.name,
      },
    );
  }

  LeagueState _tryVeteranMotivation(
    LeagueState state,
    String teamId,
    String playerId,
    int saveSeed,
  ) {
    final team = _teamById(state, teamId);
    final player = team == null
        ? null
        : _currentPlayer(state, teamId, playerId);
    if (team == null || player == null) return state;
    final events = balance.events;
    if (player.age < 32 ||
        player.state.seasonsWithTeam < 4 ||
        player.personality == PlayerPersonality.professional ||
        player.personality == PlayerPersonality.leader ||
        !_isBottomHalf(state, team.id) ||
        player.state.eventState.isOnCooldown('veteranMotivation') ||
        _hasPendingDecision(state, player.id, 'veteranMotivation') ||
        !_rollFor(
          state,
          player,
          'veteranMotivation',
          events.veteranMotivationChance,
          saveSeed,
        )) {
      return state;
    }
    return _emitDecision(
      state,
      teamId: team.id,
      player: player,
      kind: 'veteranMotivation',
      expiryDays: 2,
      saveSeed: saveSeed,
      payload: {
        'determination': player.hidden.determination,
        'determinationRequired': events.veteranMentorDeterminationMin,
      },
    );
  }

  LeagueState _tryExtraTraining(
    LeagueState state,
    String teamId,
    String playerId,
    int saveSeed,
  ) {
    final team = _teamById(state, teamId);
    final player = team == null
        ? null
        : _currentPlayer(state, teamId, playerId);
    if (team == null || player == null) return state;
    final events = balance.events;
    final eventState = player.state.eventState;
    if (player.hidden.determination < 7 ||
        player.state.form < 6 ||
        player.state.injured ||
        eventState.isOnCooldown('extraTraining') ||
        _hasPendingDecision(state, player.id, 'extraTraining') ||
        !_rollFor(
          state,
          player,
          'extraTraining',
          events.extraTrainingChance,
          saveSeed,
        )) {
      return state;
    }
    return _emitDecision(
      state,
      teamId: team.id,
      player: player,
      kind: 'extraTraining',
      expiryDays: 1,
      saveSeed: saveSeed,
      payload: {
        'determination': player.hidden.determination,
        'injuryRiskMultiplier': events.extraTrainingInjuryRiskMultiplier,
      },
    );
  }

  LeagueState _tryPersonalProblems(
    LeagueState state,
    String teamId,
    String playerId,
    int saveSeed,
  ) {
    final team = _teamById(state, teamId);
    final player = team == null
        ? null
        : _currentPlayer(state, teamId, playerId);
    if (team == null || player == null) return state;
    final events = balance.events;
    final eventState = player.state.eventState;
    if (eventState.hasModifier('personalProblems') ||
        eventState.personalProblemsFollowUpPending) {
      return state;
    }
    final chance = player.personality == PlayerPersonality.professional
        ? events.professionalPersonalProblemsChance
        : events.personalProblemsChance;
    if (!_rollFor(state, player, 'personalProblems', chance, saveSeed)) {
      return state;
    }
    final next = player.copyWith(
      state: player.state.copyWith(
        form: balance.player.clampForm(
          player.state.form + events.personalProblemsFormPenalty,
        ),
        eventState: eventState
            .addModifier(
              type: 'personalProblems',
              value: 1,
              weeks: events.personalProblemsDurationWeeks,
            )
            .addModifier(
              type: 'personalProblemsGrowth',
              value: events.personalProblemsGrowthPenalty,
              weeks: events.personalProblemsDurationWeeks,
            )
            .copyWith(personalProblemsFollowUpPending: true),
      ),
    );
    state = _replacePlayer(state, team.id, next);
    return _emit(
      state,
      teamId: team.id,
      player: next,
      kind: 'personalProblems',
      args: {'playerName': next.name},
      payload: {
        'playerId': next.id,
        'teamId': team.id,
        'formDelta': events.personalProblemsFormPenalty,
        'growthRateDelta': events.personalProblemsGrowthPenalty,
        'durationWeeks': events.personalProblemsDurationWeeks,
      },
    );
  }

  LeagueState _tryLateBloomer(
    LeagueState state,
    String teamId,
    String playerId,
    int saveSeed, {
    required bool offseason,
  }) {
    final team = _teamById(state, teamId);
    final player = team == null
        ? null
        : _currentPlayer(state, teamId, playerId);
    if (team == null || player == null) return state;
    final events = balance.events;
    if (!offseason ||
        player.age < events.lateBloomerAgeMin ||
        player.age > events.lateBloomerAgeMax ||
        player.hidden.overallProgress >= events.lateBloomerProgressMax ||
        player.state.eventState.lateBloomerTriggered ||
        !_rollFor(
          state,
          player,
          'lateBloomer',
          events.lateBloomerChance,
          saveSeed,
        )) {
      return state;
    }
    final attributes = player.attributes.map(
      outfield: (outfield) => PlayerAttributes.outfield(
        stats: outfield.stats.copyWith(
          physicality:
              (outfield.stats.physicality + events.lateBloomerAttributeBonus)
                  .clamp(50, 99),
        ),
      ),
      goalkeeper: (goalkeeper) => PlayerAttributes.goalkeeper(
        stats: goalkeeper.stats.copyWith(
          speed: (goalkeeper.stats.speed + events.lateBloomerAttributeBonus)
              .clamp(50, 99),
        ),
      ),
    );
    final next = player
        .copyWith(
          attributes: attributes,
          hidden: player.hidden,
          state: player.state.copyWith(
            eventState: player.state.eventState.copyWith(
              lateBloomerTriggered: true,
            ),
          ),
        )
        .recalculatePointValue(balance);
    state = _replacePlayer(state, team.id, next);
    return _emit(
      state,
      teamId: team.id,
      player: next,
      kind: 'lateBloomer',
      args: {'playerName': next.name},
      payload: {
        'playerId': next.id,
        'teamId': team.id,
        'attribute': player.position == Position.gk ? 'speed' : 'physicality',
        'delta': events.lateBloomerAttributeBonus,
      },
    );
  }

  LeagueState _tryRecurringInjury(
    LeagueState state,
    String teamId,
    String playerId,
    int saveSeed,
  ) {
    final team = _teamById(state, teamId);
    final player = team == null
        ? null
        : _currentPlayer(state, teamId, playerId);
    if (team == null || player == null) return state;
    final events = balance.events;
    final eventState = player.state.eventState;
    final oldMajor = eventState.lastMajorInjury;
    if (oldMajor == null ||
        oldMajor.type != InjuryType.major ||
        eventState.weeksSinceMajorInjury > 52 ||
        player.hidden.injuryProne < 7 ||
        player.state.injured ||
        eventState.isOnCooldown('recurringInjury') ||
        !_rollFor(
          state,
          player,
          'recurringInjury',
          events.recurringInjuryChance,
          saveSeed,
        )) {
      return state;
    }
    final minorDefinitions = InjuryCatalog.definitions
        .where(
          (definition) =>
              definition.group == oldMajor.group &&
              definition.type == InjuryType.minor,
        )
        .toList();
    if (minorDefinitions.isEmpty) return state;
    final random = _randomFor(state, player, 'recurringInjury', saveSeed);
    final definition =
        minorDefinitions[random.nextInt(minorDefinitions.length)];
    final days = _range(random, definition.minDays, definition.maxDays);
    final recurrence = Injury(
      id: definition.id,
      group: definition.group,
      type: InjuryType.minor,
      daysTotal: days,
      daysRemaining: days,
    );
    final next = player.copyWith(
      state: player.state.copyWith(
        injury: recurrence,
        eventState: eventState.withCooldown(
          'recurringInjury',
          52 * events.recurringInjuryCooldownMonths ~/ 12,
        ),
      ),
    );
    state = _replacePlayer(state, team.id, next);
    return _emit(
      state,
      teamId: team.id,
      player: next,
      type: MessageType.injuryRecurrence,
      kind: null,
      args: {
        'playerName': next.name,
        'injuryName': definition.name,
        'days': days,
        'recoveryTime': days,
      },
      payload: {
        'playerId': next.id,
        'teamId': team.id,
        'injuryId': recurrence.id,
        'injuryGroup': recurrence.group.name,
        'injuryType': recurrence.type.name,
      },
    );
  }

  LeagueState _tryPlateau(
    LeagueState state,
    String teamId,
    String playerId,
    int saveSeed,
  ) {
    final team = _teamById(state, teamId);
    final player = team == null
        ? null
        : _currentPlayer(state, teamId, playerId);
    if (team == null || player == null) return state;
    final events = balance.events;
    final eventState = player.state.eventState;
    if (eventState.counterValue('plateauWeeks') < events.plateauWeeks ||
        _hasPendingDecision(state, player.id, 'plateau') ||
        !_rollFor(state, player, 'plateau', events.plateauChance, saveSeed)) {
      return state;
    }
    return _emitDecision(
      state,
      teamId: team.id,
      player: player,
      kind: 'plateau',
      expiryDays: 2,
      saveSeed: saveSeed,
      payload: {'plateauWeeks': eventState.counterValue('plateauWeeks')},
    );
  }
}
