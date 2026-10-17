part of 'player_event_service.dart';

mixin _PlayerEventDecisions on _PlayerEventShared {
  LeagueState _resolvePlateau(
    LeagueState state,
    Team team,
    Player player,
    String optionId,
  ) {
    var eventState = player.state.eventState.withCounter('plateauWeeks', 0);
    if (optionId == 'accept') {
      eventState = eventState.addModifier(
        type: 'growthRate',
        value: balance.events.plateauGrowthRateBonus,
        weeks: balance.events.plateauGrowthRateDurationWeeks,
      );
    }
    return _replacePlayer(
      state,
      team.id,
      player.copyWith(state: player.state.copyWith(eventState: eventState)),
    );
  }

  LeagueState _resolveColdStreak(
    LeagueState state,
    Team team,
    Player player,
    String optionId, {
    required int saveSeed,
    required GameMessage message,
  }) {
    var eventState = player.state.eventState.withCooldown('coldStreak', 1);
    var nextForm = player.state.form;
    if (optionId == 'accept') {
      final success = _roll(
        saveSeed,
        message.seasonYear,
        message.week,
        player.id,
        'coldStreakAccept',
        balance.events.coldStreakAcceptRecoveryChance,
      );
      if (success) {
        nextForm = balance.player.clampForm(
          nextForm + balance.events.coldStreakAcceptFormBonus,
        );
      }
      eventState = eventState.addModifier(
        type: 'startingElevenRequired',
        value: 1,
        weeks: balance.events.coldStreakLineupRestrictionWeeks,
      );
    } else if (optionId == 'decline') {
      nextForm = max(
        balance.events.coldStreakDeclineFormFloor,
        player.state.form,
      );
      eventState = eventState
          .addModifier(
            type: 'formFloor',
            value: balance.events.coldStreakDeclineFormFloor,
            weeks: balance.events.coldStreakDeclineFormFloorWeeks,
          )
          .addModifier(
            type: 'growthRate',
            value: balance.events.coldStreakDeclineGrowthPenalty,
            weeks: balance.events.coldStreakDeclineGrowthPenaltyWeeks,
          )
          .addModifier(
            type: 'startingElevenBlock',
            value: 1,
            weeks: balance.events.coldStreakLineupRestrictionWeeks,
          );
    } else {
      return state;
    }
    return _replacePlayer(
      state,
      team.id,
      player.copyWith(
        state: player.state.copyWith(form: nextForm, eventState: eventState),
      ),
    );
  }

  LeagueState _resolveInjuryComplication(
    LeagueState state,
    Team team,
    Player player,
    String optionId, {
    required int saveSeed,
    required GameMessage message,
  }) {
    final original = player.state.eventState.lastMajorInjury;
    if (original == null) return state;
    var eventState = player.state.eventState.withCooldown(
      'injuryComplication',
      52,
    );
    Injury? nextInjury;
    final random = _randomFor(
      state,
      player,
      'injuryComplicationDecision',
      saveSeed,
      salt: message.week,
    );
    if (optionId == 'cautious') {
      final extra = _range(
        random,
        balance.events.injuryComplicationCautiousExtraDaysMin,
        balance.events.injuryComplicationCautiousExtraDaysMax,
      );
      nextInjury = original.copyWith(
        id: '${original.id}_complication',
        daysTotal: original.daysTotal + extra,
        daysRemaining: extra,
      );
      eventState = eventState.withCooldown('recurringInjury', 52);
    } else if (optionId == 'full') {
      if (random.nextDouble() <
          balance.events.injuryComplicationFullRecurrenceChance) {
        final fraction =
            balance.events.injuryComplicationFullRecurrenceFractionMin +
            random.nextDouble() *
                (balance.events.injuryComplicationFullRecurrenceFractionMax -
                    balance.events.injuryComplicationFullRecurrenceFractionMin);
        final days = max(1, (original.daysTotal * fraction).round());
        nextInjury = original.copyWith(
          id: '${original.id}_recurrence',
          daysTotal: days,
          daysRemaining: days,
        );
      }
    } else {
      return state;
    }
    return _replacePlayer(
      state,
      team.id,
      player.copyWith(
        state: player.state.copyWith(
          injury: nextInjury,
          eventState: eventState,
        ),
      ),
    );
  }

  LeagueState _resolveVeteranMotivation(
    LeagueState state,
    Team team,
    Player player,
    String optionId, {
    required int saveSeed,
    required GameMessage message,
  }) {
    var stateAfter = state;
    var eventState = player.state.eventState.withCooldown(
      'veteranMotivation',
      4,
    );
    final mentor = optionId == 'mentor' || optionId == 'accept';
    final ignore = optionId == 'ignore' || optionId == 'decline';
    if (mentor &&
        player.hidden.determination >=
            balance.events.veteranMentorDeterminationMin) {
      final young = team.roster
          .where(
            (candidate) => candidate.id != player.id && candidate.age <= 23,
          )
          .toList();
      if (young.isNotEmpty) {
        young.sort((a, b) => a.id.compareTo(b.id));
        final random = _randomFor(
          state,
          player,
          'veteranMentorTarget',
          saveSeed,
          salt: message.week,
        );
        final target = young[random.nextInt(young.length)];
        stateAfter = _replacePlayer(
          stateAfter,
          team.id,
          target.copyWith(
            state: target.state.copyWith(
              eventState: target.state.eventState.addModifier(
                type: 'growthRate',
                value: balance.events.veteranMentorGrowthBonus,
                weeks: balance.events.veteranMentorDurationWeeks,
              ),
            ),
          ),
        );
      }
    } else if (ignore || mentor) {
      eventState = eventState.addModifier(
        type: 'growthRate',
        value: balance.events.veteranMotivationGrowthPenalty,
        weeks: balance.events.veteranMotivationDurationWeeks,
      );
      final current = _currentPlayer(stateAfter, team.id, player.id) ?? player;
      stateAfter = _replacePlayer(
        stateAfter,
        team.id,
        current.copyWith(
          state: current.state.copyWith(
            form: balance.player.clampForm(current.state.form - 1),
          ),
        ),
      );
    } else if (!mentor && !ignore) {
      return state;
    }
    final current = _currentPlayer(stateAfter, team.id, player.id) ?? player;
    return _replacePlayer(
      stateAfter,
      team.id,
      current.copyWith(state: current.state.copyWith(eventState: eventState)),
    );
  }

  LeagueState _resolveExtraTraining(
    LeagueState state,
    Team team,
    Player player,
    String optionId,
  ) {
    var eventState = player.state.eventState.withCooldown(
      'extraTraining',
      4 * balance.events.extraTrainingCooldownMonths,
    );
    var form = player.state.form;
    if (optionId == 'accept') {
      eventState = eventState
          .addModifier(
            type: 'growthRate',
            value: balance.events.extraTrainingGrowthRateBonus,
            weeks: balance.events.extraTrainingDurationWeeks,
          )
          .addModifier(
            type: 'weeklyStaminaPenalty',
            value: -balance.events.extraTrainingStaminaPenalty.toDouble(),
            weeks: balance.events.extraTrainingDurationWeeks,
          )
          .addModifier(
            type: 'injuryRiskMultiplier',
            value: balance.events.extraTrainingInjuryRiskMultiplier - 1.0,
            weeks: balance.events.extraTrainingDurationWeeks,
          );
    } else if (optionId == 'decline') {
      if (player.personality == PlayerPersonality.ambitious) {
        form = balance.player.clampForm(form - 1);
      }
    } else {
      return state;
    }
    return _replacePlayer(
      state,
      team.id,
      player.copyWith(
        state: player.state.copyWith(form: form, eventState: eventState),
      ),
    );
  }

  LeagueState _resolvePersonalSupport(
    LeagueState state,
    Team team,
    Player player,
    String optionId,
  ) {
    if (optionId != 'accept' && optionId != 'decline') return state;
    var eventState = player.state.eventState.copyWith(
      personalProblemsFollowUpPending: false,
    );
    if (optionId == 'accept') {
      eventState = eventState
          .shortenModifiers(
            'personalProblems',
            balance.events.personalSupportDurationWeeks,
          )
          .shortenModifiers(
            'personalProblemsGrowth',
            balance.events.personalSupportDurationWeeks,
          );
    }
    return _replacePlayer(
      state,
      team.id,
      player.copyWith(state: player.state.copyWith(eventState: eventState)),
    );
  }
}
