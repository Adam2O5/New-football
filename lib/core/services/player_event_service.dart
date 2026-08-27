import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/balance/injury_catalog.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/message_service.dart';

/// Resolves the individual player events from `player_management.md`.
///
/// The service owns event bookkeeping and does not use the roster index as a
/// source of randomness. Every weekly roll is keyed by save, season, week,
/// player and event kind, which makes a replay stable when the roster changes.
class PlayerEventService {
  PlayerEventService({
    this.balance = BalanceConfig.defaults,
    MessageService? messages,
  }) : messages = messages ?? MessageService();

  final BalanceConfig balance;
  final MessageService messages;

  /// Applies one weekly event tick to every player in the league.
  LeagueState weeklyTick(
    LeagueState league, {
    int saveSeed = 0,
    bool offseason = false,
  }) {
    var state = league;
    final playerIdsByTeam = {
      for (final team in league.teams)
        team.id: [for (final player in team.roster) player.id],
    };

    for (final teamEntry in playerIdsByTeam.entries) {
      for (final playerId in teamEntry.value) {
        final team = state.teamById(teamEntry.key);
        final player = team?.roster.where((p) => p.id == playerId).firstOrNull;
        if (team == null || player == null) continue;
        state = _tickPlayer(
          state,
          team,
          player,
          saveSeed: saveSeed,
          offseason:
              offseason || state.currentSeason.phase == SeasonPhase.offseason,
        );
      }
    }
    return state;
  }

  /// Explicit aliases keep the service convenient for simulation and tests
  /// that use either `tick` or `process` terminology.
  LeagueState tickWeekly(
    LeagueState league, {
    int saveSeed = 0,
    bool offseason = false,
  }) => weeklyTick(league, saveSeed: saveSeed, offseason: offseason);

  LeagueState processWeeklyEvents(
    LeagueState league, {
    int saveSeed = 0,
    bool offseason = false,
  }) => weeklyTick(league, saveSeed: saveSeed, offseason: offseason);

  /// Alias used by callers that model offseason separately from a regular
  /// weekly tick. The same counters/cooldowns are intentionally shared.
  LeagueState offseasonTick(LeagueState league, {int saveSeed = 0}) =>
      weeklyTick(league, saveSeed: saveSeed, offseason: true);

  /// Applies a national-team call-up. There is no representation schedule in
  /// V1, so this is an explicit integration API rather than an automatic roll.
  LeagueState triggerNationalTeam(
    LeagueState league,
    String playerId, {
    String? teamId,
  }) {
    final team = teamId == null
        ? _findTeamWithPlayer(league, playerId)
        : league.teamById(teamId);
    final player = team == null ? null : _findPlayer(team, playerId);
    if (team == null || player == null) return league;

    final next = player.copyWith(
      state: player.state.copyWith(
        stamina: balance.player.clampStamina(
          player.state.stamina - balance.events.nationalTeamStaminaPenalty,
        ),
        form: balance.player.clampForm(
          player.state.form + balance.events.nationalTeamFormBonus,
        ),
      ),
    );
    var state = _replacePlayer(league, team.id, next);
    return _emit(
      state,
      teamId: team.id,
      player: next,
      kind: 'nationalTeam',
      args: {'playerName': next.name},
      payload: {
        'playerId': next.id,
        'teamId': team.id,
        'formDelta': balance.events.nationalTeamFormBonus,
        'staminaDelta': -balance.events.nationalTeamStaminaPenalty,
      },
    );
  }

  /// Compatibility alias for integrations that use the event name as a verb.
  LeagueState onNationalTeamCallUp(LeagueState league, String playerId) =>
      triggerNationalTeam(league, playerId);

  /// Applies the domain effect of a player-event message decision.
  ///
  /// Inbox acknowledgement remains the responsibility of [MessageService].
  /// This method only changes game state, which makes it safe to use from both
  /// a button handler and the expiry path.
  LeagueState resolveDecision(
    LeagueState league,
    GameMessage message,
    String optionId, {
    int saveSeed = 0,
  }) {
    if (message.type != MessageType.playerEvent) return league;
    final playerId = message.payload['playerId'];
    if (playerId is! String) return league;
    final teamId = message.payload['teamId'];
    final team = teamId is String
        ? league.teamById(teamId)
        : _findTeamWithPlayer(league, playerId);
    final player = team == null ? null : _findPlayer(team, playerId);
    if (team == null || player == null) return league;

    final eventKind = message.payload['eventKind'] as String? ?? message.kind;
    if (eventKind == null) return league;

    return switch (eventKind) {
      'plateau' => _resolvePlateau(league, team, player, optionId),
      'coldStreak' => _resolveColdStreak(
        league,
        team,
        player,
        optionId,
        saveSeed: saveSeed,
        message: message,
      ),
      'injuryComplication' => _resolveInjuryComplication(
        league,
        team,
        player,
        optionId,
        saveSeed: saveSeed,
        message: message,
      ),
      'veteranMotivation' => _resolveVeteranMotivation(
        league,
        team,
        player,
        optionId,
        saveSeed: saveSeed,
        message: message,
      ),
      'extraTraining' => _resolveExtraTraining(league, team, player, optionId),
      'personalSupport' => _resolvePersonalSupport(
        league,
        team,
        player,
        optionId,
      ),
      _ => league,
    };
  }

  /// Resolves all logical-time expiries currently due in the inbox.
  ///
  /// Event messages use a deterministic season calendar (rather than wall
  /// clock time), so the same save behaves identically after reload.
  LeagueState resolveExpiredDecisions(LeagueState league, {int saveSeed = 0}) {
    return messages.resolveExpiredDecisions(
      league,
      logicalDate(league),
      onDecision: (state, message, optionId) =>
          resolveDecision(state, message, optionId, saveSeed: saveSeed),
    );
  }

  /// Date representation used in `GameMessage.expiresAt` for this save.
  DateTime logicalDate(LeagueState league) => DateTime.utc(
    league.currentSeason.year,
    1,
    1,
  ).add(Duration(days: (league.currentWeek - 1) * 7 + (league.currentDay - 1)));

  LeagueState _tickPlayer(
    LeagueState state,
    Team team,
    Player player, {
    required int saveSeed,
    required bool offseason,
  }) {
    final events = balance.events;
    final previousEventState = player.state.eventState;
    var eventState = previousEventState.advanceWeek();
    var recoveryWeek = false;

    final injury = player.state.injury;
    if (injury?.isActive == true && injury!.type == InjuryType.major) {
      final newMajor = eventState.lastMajorInjury?.id != injury.id;
      eventState = eventState.copyWith(
        lastMajorInjury: injury,
        majorInjuryActiveLastTick: true,
        weeksSinceMajorInjury: 0,
      );
      if (newMajor) {
        eventState = eventState.withCounter(
          'majorInjuryDays',
          injury.daysTotal,
        );
      }
    } else if (eventState.lastMajorInjury != null) {
      recoveryWeek = eventState.majorInjuryActiveLastTick;
      eventState = eventState.copyWith(
        majorInjuryActiveLastTick: false,
        weeksSinceMajorInjury: eventState.majorInjuryActiveLastTick
            ? 1
            : (eventState.weeksSinceMajorInjury + 1).clamp(0, 999),
      );
    }

    final highFormWeeks = player.state.form >= events.breakthroughFormMin
        ? player.state.eventState.counterValue('highFormWeeks') + 1
        : 0;
    final lowFormWeeks = player.state.form <= events.coldStreakFormMax
        ? player.state.eventState.counterValue('lowFormWeeks') + 1
        : 0;
    final plateauWeeks = player.state.lastDevelopmentOvrDelta == 0
        ? player.state.eventState.counterValue('plateauWeeks') + 1
        : 0;
    eventState = eventState
        .withCounter('highFormWeeks', highFormWeeks)
        .withCounter('lowFormWeeks', lowFormWeeks)
        .withCounter('plateauWeeks', plateauWeeks);

    var nextPlayer = player.copyWith(
      state: player.state.copyWith(eventState: eventState),
    );
    final weeklyStaminaPenalty = eventState.modifierValue(
      'weeklyStaminaPenalty',
    );
    if (weeklyStaminaPenalty != 0) {
      nextPlayer = nextPlayer.copyWith(
        state: nextPlayer.state.copyWith(
          stamina: balance.player.clampStamina(
            nextPlayer.state.stamina + weeklyStaminaPenalty.round(),
          ),
        ),
      );
    }
    state = _replacePlayer(state, team.id, nextPlayer);

    if (previousEventState.personalProblemsFollowUpPending &&
        !_hasPendingDecision(state, nextPlayer.id, 'personalSupport') &&
        _roll(
          saveSeed,
          state.currentSeason.year,
          state.currentWeek,
          nextPlayer.id,
          'personalSupport',
          events.personalSupportChance,
        )) {
      state = _emitDecision(
        state,
        teamId: team.id,
        player: nextPlayer,
        kind: 'personalSupport',
        expiryDays: 3,
        saveSeed: saveSeed,
        payload: {'followUp': true},
      );
    }
    final afterFollowUp = _currentPlayer(state, team.id, nextPlayer.id);
    if (afterFollowUp != null &&
        afterFollowUp.state.eventState.personalProblemsFollowUpPending) {
      state = _replacePlayer(
        state,
        team.id,
        afterFollowUp.copyWith(
          state: afterFollowUp.state.copyWith(
            eventState: afterFollowUp.state.eventState.copyWith(
              personalProblemsFollowUpPending: false,
            ),
          ),
        ),
      );
    }

    state = _tryBreakthrough(state, team.id, nextPlayer.id, saveSeed);
    state = _tryColdStreak(state, team.id, nextPlayer.id, saveSeed);
    state = _tryInjuryComplication(
      state,
      team.id,
      nextPlayer.id,
      saveSeed,
      recoveryWeek: recoveryWeek,
    );
    state = _tryVeteranMotivation(state, team.id, nextPlayer.id, saveSeed);
    state = _tryExtraTraining(state, team.id, nextPlayer.id, saveSeed);
    state = _tryPersonalProblems(state, team.id, nextPlayer.id, saveSeed);
    state = _tryLateBloomer(
      state,
      team.id,
      nextPlayer.id,
      saveSeed,
      offseason: offseason,
    );
    state = _tryRecurringInjury(state, team.id, nextPlayer.id, saveSeed);
    state = _tryPlateau(state, team.id, nextPlayer.id, saveSeed);
    return state;
  }

  LeagueState _tryBreakthrough(
    LeagueState state,
    String teamId,
    String playerId,
    int saveSeed,
  ) {
    final team = state.teamById(teamId);
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
    final team = state.teamById(teamId);
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
    final team = state.teamById(teamId);
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
    final team = state.teamById(teamId);
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
    final team = state.teamById(teamId);
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
    final team = state.teamById(teamId);
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
    final team = state.teamById(teamId);
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
    final team = state.teamById(teamId);
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
      args: {'playerName': next.name, 'days': days},
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
    final team = state.teamById(teamId);
    final player = team == null
        ? null
        : _currentPlayer(state, teamId, playerId);
    if (team == null || player == null) return state;
    final eventState = player.state.eventState;
    if (eventState.counterValue('plateauWeeks') < balance.events.plateauWeeks ||
        _hasPendingDecision(state, player.id, 'plateau')) {
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

  LeagueState _emitDecision(
    LeagueState state, {
    required String teamId,
    required Player player,
    required String kind,
    required int expiryDays,
    required int saveSeed,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
  }) {
    final completePayload = <String, dynamic>{
      'playerId': player.id,
      'teamId': teamId,
      'eventKind': kind,
      ...payload,
    };
    final completeArgs = <String, dynamic>{'playerName': player.name, ...args};

    // AI decisions are resolved synchronously. Building an in-memory message
    // keeps all six effects on the same [resolveDecision] path as the player
    // UI without putting an AI event into the human inbox.
    if (state.playerTeamId != teamId) {
      final message = GameMessage(
        id: 'ai:playerEvent:$kind:$teamId:${player.id}:${state.currentSeason.year}:${state.currentWeek}',
        type: MessageType.playerEvent,
        kind: kind,
        domain: MessageDomain.playerEvent,
        seasonYear: state.currentSeason.year,
        week: state.currentWeek,
        day: state.currentDay,
        titleKey: 'ai.playerEvent.$kind.title',
        bodyKey: 'ai.playerEvent.$kind.body',
        args: completeArgs,
        payload: completePayload,
      );
      return resolveDecision(
        state,
        message,
        _aiDecisionOption(state, player, kind, saveSeed),
        saveSeed: saveSeed,
      );
    }

    return _emit(
      state,
      teamId: teamId,
      player: player,
      kind: kind,
      args: completeArgs,
      payload: completePayload,
      expiryDays: expiryDays,
    );
  }

  String _aiDecisionOption(
    LeagueState state,
    Player player,
    String kind,
    int saveSeed,
  ) {
    final probability = switch (kind) {
      'plateau' => balance.events.aiPlateauAcceptChance,
      'coldStreak' => balance.events.aiColdStreakAcceptChance,
      'injuryComplication' => balance.events.aiInjuryComplicationCautiousChance,
      'veteranMotivation' => balance.events.aiVeteranMentorChance,
      'extraTraining' =>
        state.currentSeason.phase == SeasonPhase.playoff
            ? balance.events.aiExtraTrainingPlayoffAcceptChance
            : balance.events.aiExtraTrainingAcceptChance,
      'personalSupport' => balance.events.aiPersonalSupportAcceptChance,
      _ => 0.0,
    };
    final roll = Random(
      playerEventSeed(
        saveSeed,
        state.currentSeason.year,
        state.currentWeek,
        player.id,
        'aiDecision:$kind',
      ),
    ).nextDouble();

    return switch (kind) {
      'plateau' => roll < probability ? 'accept' : 'decline',
      'coldStreak' => roll < probability ? 'accept' : 'decline',
      'injuryComplication' => roll < probability ? 'cautious' : 'full',
      'veteranMotivation' =>
        player.hidden.determination >=
                    balance.events.veteranMentorDeterminationMin &&
                roll < probability
            ? 'mentor'
            : 'ignore',
      'extraTraining' => roll < probability ? 'accept' : 'decline',
      'personalSupport' => roll < probability ? 'accept' : 'decline',
      _ => 'decline',
    };
  }

  LeagueState _emit(
    LeagueState state, {
    required String teamId,
    required Player player,
    String? kind,
    MessageType type = MessageType.playerEvent,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
    int? expiryDays,
  }) {
    // The inbox is the manager's inbox; AI-club events still affect simulation
    // but are not actionable messages for the human manager.
    if (state.playerTeamId != teamId) return state;
    final expiresAt = expiryDays == null
        ? null
        : logicalDate(state).add(Duration(days: expiryDays)).toIso8601String();
    return messages.send(
      state,
      type: type,
      kind: type == MessageType.playerEvent ? kind : null,
      domain: type == MessageType.playerEvent
          ? MessageDomain.playerEvent
          : MessageDomain.health,
      args: args,
      payload: payload,
      expiresAt: expiresAt,
      priority: type == MessageType.playerEvent && expiryDays != null
          ? MessagePriority.urgent
          : MessagePriority.normal,
      dedupKey:
          '${type.name}:$kind:${player.id}:${state.currentSeason.year}:${state.currentWeek}',
    );
  }

  bool _rollFor(
    LeagueState state,
    Player player,
    String eventKind,
    double probability,
    int saveSeed,
  ) => _roll(
    saveSeed,
    state.currentSeason.year,
    state.currentWeek,
    player.id,
    eventKind,
    probability,
  );

  bool _roll(
    int saveSeed,
    int seasonYear,
    int week,
    String playerId,
    String eventKind,
    double probability, {
    int salt = 0,
  }) {
    if (probability <= 0) return false;
    if (probability >= 1) return true;
    return Random(
          playerEventSeed(
            saveSeed,
            seasonYear,
            week,
            playerId,
            eventKind,
            salt: salt,
          ),
        ).nextDouble() <
        probability;
  }

  Random _randomFor(
    LeagueState state,
    Player player,
    String eventKind,
    int saveSeed, {
    int salt = 0,
  }) => Random(
    playerEventSeed(
      saveSeed,
      state.currentSeason.year,
      state.currentWeek,
      player.id,
      eventKind,
      salt: salt,
    ),
  );

  bool _hasPendingDecision(LeagueState state, String playerId, String kind) =>
      [...state.inbox.messages, ...state.inbox.scheduled].any(
        (message) =>
            !message.acknowledged &&
            message.type == MessageType.playerEvent &&
            message.kind == kind &&
            message.payload['playerId'] == playerId,
      );

  bool _isBottomHalf(LeagueState state, String teamId) {
    final all = [
      for (final conference in state.currentSeason.standings)
        ...conference.standings,
    ];
    if (all.isEmpty) return false;
    final sorted = [...all]
      ..sort((a, b) {
        final points = b.points.compareTo(a.points);
        if (points != 0) return points;
        return b.goalDifference.compareTo(a.goalDifference);
      });
    final rank = sorted.indexWhere((standing) => standing.teamId == teamId);
    return rank >= (sorted.length / 2).ceil();
  }

  Team? _findTeamWithPlayer(LeagueState state, String playerId) {
    for (final team in state.teams) {
      if (_findPlayer(team, playerId) != null) return team;
    }
    return null;
  }

  Player? _findPlayer(Team team, String? playerId) {
    if (playerId == null) return null;
    for (final player in team.roster) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  Player? _currentPlayer(LeagueState state, String teamId, String? playerId) {
    final team = state.teamById(teamId);
    if (team == null) return null;
    if (playerId != null) return _findPlayer(team, playerId);
    return team.roster.isEmpty ? null : team.roster.first;
  }

  LeagueState _replacePlayer(LeagueState state, String teamId, Player player) {
    final team = state.teamById(teamId);
    if (team == null) return state;
    return state.updateTeam(
      team.copyWith(
        roster: [
          for (final candidate in team.roster)
            candidate.id == player.id ? player : candidate,
        ],
      ),
    );
  }

  int _range(Random random, int minValue, int maxValue) => minValue == maxValue
      ? minValue
      : minValue + random.nextInt(maxValue - minValue + 1);
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
