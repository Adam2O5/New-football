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

part 'player_event_triggers.dart';
part 'player_event_decisions.dart';
part 'player_event_messages.dart';
part 'player_event_helpers.dart';

/// Resolves the individual player events from `player_management.md`.
///
/// The service owns event bookkeeping and does not use the roster index as a
/// source of randomness. Every weekly roll is keyed by save, season, week,
/// player and event kind, which makes a replay stable when the roster changes.
class PlayerEventService
    with
        _PlayerEventShared,
        _PlayerEventTriggers,
        _PlayerEventDecisions,
        _PlayerEventMessages,
        _PlayerEventHelpers {
  PlayerEventService({
    this.balance = BalanceConfig.defaults,
    MessageService? messages,
  }) : messages = messages ?? MessageService();

  @override
  final BalanceConfig balance;
  @override
  final MessageService messages;

  /// Working roster map for the current [weeklyTick]. Mutations stay here
  /// until a message or the end of the tick publishes them, so a Sunday
  /// boundary does not copy the 30-team list once per player event.
  @override
  Map<String, Team>? _tickTeams;
  @override
  Set<String>? _pendingDecisionKeys;
  @override
  Set<String>? _bottomHalfTeamIds;

  /// Applies one weekly event tick to every player in the league.
  LeagueState weeklyTick(
    LeagueState league, {
    int saveSeed = 0,
    bool offseason = false,
  }) {
    _pendingDecisionKeys = _indexPendingDecisions(league);
    _bottomHalfTeamIds = _indexBottomHalf(league);
    _tickTeams = {for (final team in league.teams) team.id: team};
    var state = league;
    try {
      for (final original in league.teams) {
        final playerIds = [for (final player in original.roster) player.id];
        for (final playerId in playerIds) {
          final team = _teamById(state, original.id);
          final player = team == null ? null : _findPlayer(team, playerId);
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
      return _publishTickTeams(state);
    } finally {
      _tickTeams = null;
      _pendingDecisionKeys = null;
      _bottomHalfTeamIds = null;
    }
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
  @override
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
        ? _teamById(league, teamId)
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
  @override
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

  static String _pendingKey(String playerId, String kind) => '$playerId|$kind';
}

mixin _PlayerEventShared {
  BalanceConfig get balance;

  MessageService get messages;

  Map<String, Team>? get _tickTeams;

  Set<String>? get _pendingDecisionKeys;

  Set<String>? get _bottomHalfTeamIds;

  LeagueState resolveDecision(
    LeagueState league,
    GameMessage message,
    String optionId, {
    int saveSeed = 0,
  });

  DateTime logicalDate(LeagueState league);

  LeagueState _emitDecision(
    LeagueState state, {
    required String teamId,
    required Player player,
    required String kind,
    required int expiryDays,
    required int saveSeed,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
  });

  LeagueState _emit(
    LeagueState state, {
    required String teamId,
    required Player player,
    String? kind,
    MessageType type = MessageType.playerEvent,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
  });

  bool _rollFor(
    LeagueState state,
    Player player,
    String eventKind,
    double probability,
    int saveSeed,
  );

  bool _roll(
    int saveSeed,
    int seasonYear,
    int week,
    String playerId,
    String eventKind,
    double probability,
  );

  Random _randomFor(
    LeagueState state,
    Player player,
    String eventKind,
    int saveSeed, {
    int salt = 0,
  });

  bool _hasPendingDecision(LeagueState state, String playerId, String kind);

  bool _isBottomHalf(LeagueState state, String teamId);

  Team? _teamById(LeagueState state, String teamId);

  LeagueState _publishTickTeams(LeagueState state);

  Player? _currentPlayer(LeagueState state, String teamId, String? playerId);

  LeagueState _replacePlayer(LeagueState state, String teamId, Player player);

  int _range(Random random, int minValue, int maxValue);
}
