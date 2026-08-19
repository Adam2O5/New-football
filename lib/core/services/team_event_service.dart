import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/team_management_service.dart';

/// Owns the persisted team-event state and all nine team events from
/// `docs/team_management.md`.
///
/// The service is deliberately separate from [TeamManagementService]: that
/// service applies deterministic atmosphere/chemistry primitives, while this
/// class owns event eligibility, rolls, promises, decisions and messages.
class TeamEventService {
  TeamEventService({
    this.balance = BalanceConfig.defaults,
    MessageService? messages,
    CalendarService? calendar,
    TeamManagementService? teamManagement,
  }) : messages = messages ?? MessageService(),
       calendar = calendar ?? CalendarService(balance: balance),
       teamManagement = teamManagement ?? const TeamManagementService();

  final BalanceConfig balance;
  final MessageService messages;
  final CalendarService calendar;
  final TeamManagementService teamManagement;

  /// Returns the event-ranking OVR without assuming that a test fixture's
  /// position matches the attribute-card variant. Valid production players
  /// produce the same value as [PlayerX.overall].
  double _eventOverall(Player player) => switch (player.attributes) {
    OutfieldPlayerAttributes(:final stats) => stats.overallForPosition(
      player.position,
      balance,
    ),
    GoalkeeperPlayerAttributes(:final stats) => stats.overall,
    _ => 0.0,
  };

  /// Records the completed match and performs the two after-match rolls:
  /// `moreMinutesRequest` and `transferRequestI`.
  LeagueState afterMatch(
    LeagueState league,
    MatchResult result, {
    int saveSeed = 0,
  }) {
    var state = recordMatchMinutes(league, result);
    if (TeamManagementService.isWalkoverResult(result)) return state;

    for (final teamId in {result.homeTeamId, result.awayTeamId}) {
      state = _tryMoreMinutes(state, teamId, saveSeed);
      state = _tryTransferRequestI(state, teamId, saveSeed);
    }
    return state;
  }

  /// Adds one zero/actual-minute row for every rostered player in the two
  /// teams. This makes the six-week denominator explicit instead of deriving
  /// it from the resettable `minutesThisWeek` field.
  LeagueState recordMatchMinutes(LeagueState league, MatchResult result) {
    if (TeamManagementService.isWalkoverResult(result)) return league;
    final statsByPlayer = {
      for (final stats in result.playerStats) stats.playerId: stats,
    };
    var state = league;
    for (final teamId in {result.homeTeamId, result.awayTeamId}) {
      final team = state.teamById(teamId);
      if (team == null) continue;
      final entries = [
        for (final player in team.roster)
          MinutesHistoryEntry(
            playerId: player.id,
            seasonYear: state.currentSeason.year,
            week: state.currentWeek,
            minutes: statsByPlayer[player.id]?.minutes ?? 0,
            possibleMinutes: _possibleMinutes(player),
          ),
      ];
      state = state.updateTeam(
        team.copyWith(
          eventState: team.eventState.recordMinutes(
            entries,
            currentSeasonYear: state.currentSeason.year,
            currentWeek: state.currentWeek,
          ),
        ),
      );
    }
    return state;
  }

  /// Sunday → Monday team-event lifecycle. Promises and accepted transfer
  /// situations are settled before new weekly rolls are made.
  LeagueState weeklyTick(
    LeagueState league, {
    int saveSeed = 0,
    bool offseason = false,
  }) {
    var state = league;
    final teamIds = [for (final team in league.teams) team.id];
    for (final teamId in teamIds) {
      var team = state.teamById(teamId);
      if (team == null) continue;

      final previous = team.eventState;
      final atmosphereWeeks =
          team.atmosphere < balance.events.lowAtmosphereThreshold
          ? previous.lowAtmosphereWeeks + 1
          : 0;
      state = state.updateTeam(
        team.copyWith(
          eventState: previous.advanceWeek().copyWith(
            lowAtmosphereWeeks: atmosphereWeeks,
          ),
        ),
      );

      state = _settlePromises(state, teamId, saveSeed);
      state = _settleTransferSituations(state, teamId);
      team = state.teamById(teamId);
      if (team == null) continue;

      state = _tryDressingRoomConflict(state, teamId, saveSeed);
      state = _tryLeaderSupport(state, teamId, saveSeed);
      state = _tryPublicCriticism(state, teamId, saveSeed);
    }
    return state;
  }

  /// Resolves the post-playoff transfer demand using the current strength
  /// snapshot. A missing snapshot intentionally means no roll; it must not
  /// silently fall back to `pretender`.
  LeagueState afterPlayoffs(LeagueState league, {int saveSeed = 0}) {
    final table = league.strengthTable;
    final year = league.currentSeason.year;
    if (table == null || (table.seasonYear != 0 && table.seasonYear != year)) {
      return league;
    }

    var state = league;
    for (final originalTeam in league.teams) {
      var team = state.teamById(originalTeam.id);
      if (team == null ||
          team.eventState.hasSeasonFlag('transferRequestII', year)) {
        continue;
      }

      final entry = table.entryFor(team.id);
      if (entry == null) continue;
      final achievedRound = _playoffRoundReached(league, team.id);
      final threshold = switch (entry.teamStatus) {
        TeamStatus.elite => 3,
        TeamStatus.contender => 2,
        TeamStatus.pretender => 1,
        _ => 0,
      };
      if (threshold == 0 || achievedRound >= threshold) {
        state = _setTeamEventState(
          state,
          team.id,
          team.eventState.withSeasonFlag('transferRequestII', year),
        );
        continue;
      }

      final candidates = [...team.roster]
        ..sort((a, b) {
          final byOverall = _eventOverall(b).compareTo(_eventOverall(a));
          return byOverall != 0 ? byOverall : a.id.compareTo(b.id);
        });
      final topEleven = candidates.take(11).toList();
      final eligible = topEleven
          .where((player) => player.personality != PlayerPersonality.loyal)
          .toList();
      state = _setTeamEventState(
        state,
        team.id,
        team.eventState.withSeasonFlag('transferRequestII', year),
      );
      if (eligible.isEmpty) continue;

      final player = eligible.length == 1
          ? eligible.first
          : eligible[_random(
              state,
              team.id,
              null,
              'transferRequestIIPlayer',
              saveSeed,
            ).nextInt(eligible.length)];
      if (_isFutureUfa(player)) {
        state = _emitDeclineToExtend(state, team.id, player);
      } else {
        state = _queueTransferRequest(
          state,
          team.id,
          player.id,
          'transferRequestII',
          saveSeed: saveSeed,
        );
      }
    }
    return state;
  }

  /// Compatibility aliases for callers that describe the lifecycle with a
  /// `process` or `tick` verb.
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

  LeagueState processPostPlayoffs(LeagueState league, {int saveSeed = 0}) =>
      afterPlayoffs(league, saveSeed: saveSeed);

  /// Applies a team-event decision. Inbox acknowledgement remains the
  /// responsibility of [MessageService].
  LeagueState resolveDecision(
    LeagueState league,
    GameMessage message,
    String optionId, {
    int saveSeed = 0,
  }) {
    if (message.type != MessageType.teamEvent) return league;
    final kind = message.payload['eventKind'] as String? ?? message.kind;
    final teamId = message.payload['teamId'];
    if (kind == null || teamId is! String) return league;
    final playerId = message.payload['playerId'];
    return _applyDecision(
      league,
      teamId: teamId,
      playerId: playerId is String ? playerId : null,
      kind: kind,
      optionId: optionId,
      saveSeed: saveSeed,
      payload: message.payload,
    );
  }

  /// Resolves all expired team-event decisions using the save's logical date.
  LeagueState resolveExpiredDecisions(LeagueState league, {int saveSeed = 0}) =>
      messages.resolveExpiredDecisions(
        league,
        logicalDate(league),
        onDecision: (state, message, optionId) =>
            resolveDecision(state, message, optionId, saveSeed: saveSeed),
      );

  DateTime logicalDate(LeagueState league) => DateTime.utc(
    league.currentSeason.year,
    1,
    1,
  ).add(Duration(days: (league.currentWeek - 1) * 7 + (league.currentDay - 1)));

  LeagueState _tryMoreMinutes(LeagueState state, String teamId, int saveSeed) {
    final team = state.teamById(teamId);
    if (team == null || team.eventState.isOnCooldown('moreMinutesRequest')) {
      return state;
    }
    final events = balance.events;
    final xi = team.startingEleven;
    final averageOvr = xi.isEmpty
        ? 0.0
        : xi.map((player) => _eventOverall(player)).reduce((a, b) => a + b) /
              xi.length;
    final rosterAveragePotential = team.roster.isEmpty
        ? 0.0
        : team.roster
                  .map((player) => player.potentialStars)
                  .reduce((a, b) => a + b) /
              team.roster.length;
    final candidates =
        team.roster.where((player) {
          if (!player.isAvailable) return false;
          if (_hasPendingDecision(
            state,
            player.id,
            'moreMinutesRequest',
            teamId: team.id,
          )) {
            return false;
          }
          if (team.eventState.promiseFor(player.id) != null) return false;
          if (!_isUnderplayed(
            team,
            player.id,
            events.moreMinutesLowShareThreshold,
          )) {
            return false;
          }
          final betterThanXi =
              xi.isNotEmpty && _eventOverall(player) >= averageOvr;
          final youngWithPotential =
              player.age <= 26 &&
              player.potentialStars > rosterAveragePotential;
          return betterThanXi || youngWithPotential;
        }).toList()..sort((a, b) {
          final byOverall = _eventOverall(b).compareTo(_eventOverall(a));
          return byOverall != 0 ? byOverall : a.id.compareTo(b.id);
        });
    if (candidates.isEmpty) return state;

    final player = candidates.first;
    final chance = player.personality == PlayerPersonality.ambitious
        ? events.minutesRequestAmbitiousChance
        : events.minutesRequestChance;
    final effectiveChance =
        chance *
        TeamManagementService.negativeEventMultiplier(team.atmosphere) *
        team.eventState.negativeEventMultiplier;
    final rollState = _setTeamCooldown(state, team.id, 'moreMinutesRequest', 1);
    if (!_roll(
      rollState,
      team.id,
      player.id,
      'moreMinutesRequest',
      effectiveChance,
      saveSeed,
    )) {
      return rollState;
    }
    return _queueDecision(
      rollState,
      teamId: team.id,
      playerId: player.id,
      kind: 'moreMinutesRequest',
      saveSeed: saveSeed,
      payload: {
        'minutesShare': _minutesShare(team, player.id),
        'requiredMinutesShare': events.moreMinutesPromiseShare,
      },
    );
  }

  LeagueState _tryTransferRequestI(
    LeagueState state,
    String teamId,
    int saveSeed,
  ) {
    final team = state.teamById(teamId);
    if (team == null ||
        team.eventState.isOnCooldown('transferRequestI') ||
        !calendar.isTradeWindowOpen(state.currentWeek, day: state.currentDay)) {
      return state;
    }
    final events = balance.events;
    final candidates =
        team.roster.where((player) {
          if (player.personality == PlayerPersonality.loyal ||
              !player.isAvailable) {
            return false;
          }
          if (team.eventState.transferSituationFor(player.id) != null ||
              _hasPendingDecision(
                state,
                player.id,
                'transferRequestI',
                teamId: team.id,
              )) {
            return false;
          }
          final lowAtmosphere =
              team.eventState.lowAtmosphereWeeks >= events.lowAtmosphereWeeks;
          final valuableInWeakClub =
              _isTopTwentyPercentValue(state, player) &&
              _isBottomHalf(state, team.id);
          return lowAtmosphere || valuableInWeakClub;
        }).toList()..sort((a, b) {
          final byValue = b.pointValue.compareTo(a.pointValue);
          return byValue != 0 ? byValue : a.id.compareTo(b.id);
        });
    if (candidates.isEmpty) return state;

    final player = candidates.first;
    final chance =
        events.transferRequestIChance *
        (player.personality == PlayerPersonality.ambitious
            ? events.transferRequestAmbitiousMultiplier
            : 1.0) *
        TeamManagementService.negativeEventMultiplier(team.atmosphere) *
        team.eventState.negativeEventMultiplier;
    final rollState = _setTeamCooldown(state, team.id, 'transferRequestI', 1);
    if (!_roll(
      rollState,
      team.id,
      player.id,
      'transferRequestI',
      chance,
      saveSeed,
    )) {
      return rollState;
    }
    return _queueTransferRequest(
      rollState,
      team.id,
      player.id,
      'transferRequestI',
      saveSeed: saveSeed,
    );
  }

  LeagueState _tryDressingRoomConflict(
    LeagueState state,
    String teamId,
    int saveSeed,
  ) {
    final team = state.teamById(teamId);
    if (team == null) return state;
    final events = balance.events;
    final temperamental = team.startingEleven
        .where(
          (player) => player.personality == PlayerPersonality.temperamental,
        )
        .toList();
    if (temperamental.length < events.lockerRoomConflictPlayers ||
        team.atmosphere >= events.lowAtmosphereThreshold ||
        team.eventState.isOnCooldown('dressingRoomConflict') ||
        _hasPendingDecision(
          state,
          null,
          'dressingRoomConflict',
          teamId: team.id,
        )) {
      return state;
    }
    final chance =
        events.lockerRoomConflictChance *
        TeamManagementService.negativeEventMultiplier(team.atmosphere) *
        team.eventState.negativeEventMultiplier;
    if (!_roll(
      state,
      team.id,
      null,
      'dressingRoomConflict',
      chance,
      saveSeed,
    )) {
      return state;
    }
    return _queueDecision(
      state,
      teamId: team.id,
      kind: 'dressingRoomConflict',
      saveSeed: saveSeed,
      payload: {
        'temperamentalPlayerIds': [
          for (final player in temperamental) player.id,
        ],
      },
    );
  }

  LeagueState _tryLeaderSupport(
    LeagueState state,
    String teamId,
    int saveSeed,
  ) {
    final team = state.teamById(teamId);
    if (team == null ||
        team.eventState.isOnCooldown('leaderSupport') ||
        _winStreak(team.recentMatchResults) <
            balance.events.leaderSupportWinStreak ||
        !team.startingEleven.any(
          (player) => player.personality == PlayerPersonality.leader,
        )) {
      return state;
    }
    final chance =
        balance.events.leaderSupportChance *
        TeamManagementService.positiveEventMultiplier(team.atmosphere);
    if (!_roll(state, team.id, null, 'leaderSupport', chance, saveSeed)) {
      return state;
    }
    var next = _setTeamEventState(
      state,
      team.id,
      team.eventState.withCooldown(
        'leaderSupport',
        balance.events.leaderSupportCooldownWeeks,
      ),
    );
    next = _applyTeamDeltas(
      next,
      team.id,
      atmosphere: 4,
      chemistry: 1,
      reason: 'leaderSupport',
    );
    return _emitAutomatic(
      next,
      teamId: team.id,
      kind: 'leaderSupport',
      payload: {'teamId': team.id, 'eventKind': 'leaderSupport'},
    );
  }

  LeagueState _tryPublicCriticism(
    LeagueState state,
    String teamId,
    int saveSeed,
  ) {
    final team = state.teamById(teamId);
    if (team == null ||
        team.atmosphere >= balance.events.publicCriticismAtmosphereThreshold ||
        _hasPendingDecision(state, null, 'publicCriticism', teamId: team.id)) {
      return state;
    }
    final candidate = [...team.roster]
      ..sort((a, b) {
        final byOverall = _eventOverall(b).compareTo(_eventOverall(a));
        return byOverall != 0 ? byOverall : a.id.compareTo(b.id);
      });
    final player = candidate
        .take(15)
        .where((candidate) => candidate.age > 25)
        .firstOrNull;
    if (player == null) return state;
    final rollMultiplier = team.eventState.publicCriticismRollMultiplier;
    final chance =
        balance.events.publicCriticismChance *
        TeamManagementService.negativeEventMultiplier(team.atmosphere) *
        team.eventState.negativeEventMultiplier *
        rollMultiplier;
    final resetMultiplier = _setTeamEventState(
      state,
      team.id,
      team.eventState.copyWith(publicCriticismRollMultiplier: 1.0),
    );
    if (!_roll(
      resetMultiplier,
      team.id,
      player.id,
      'publicCriticism',
      chance,
      saveSeed,
    )) {
      return resetMultiplier;
    }
    return _queueDecision(
      resetMultiplier,
      teamId: team.id,
      playerId: player.id,
      kind: 'publicCriticism',
      saveSeed: saveSeed,
      payload: {'publicCriticismMultiplier': rollMultiplier},
    );
  }

  LeagueState _settlePromises(LeagueState state, String teamId, int saveSeed) {
    final team = state.teamById(teamId);
    if (team == null || team.eventState.promises.isEmpty) return state;
    var nextState = state;
    final promises = <TeamPromise>[];
    for (final promise in team.eventState.promises) {
      final nextPromise = promise.copyWith(
        weeksElapsed: promise.weeksElapsed + 1,
      );
      final createdWeekKey = _calendarWeekKey(
        promise.createdSeasonYear,
        promise.createdWeek,
      );
      final currentWeekKey = _calendarWeekKey(
        state.currentSeason.year,
        state.currentWeek,
      );
      final elapsedCalendarWeeks = currentWeekKey - createdWeekKey;
      final history = team.eventState.minutesHistory
          .where(
            (entry) =>
                entry.playerId == promise.playerId &&
                _calendarWeekKey(entry.seasonYear, entry.week) > createdWeekKey,
          )
          .toList();
      final observedWeeks = history
          .map((entry) => _calendarWeekKey(entry.seasonYear, entry.week))
          .toSet()
          .length;
      final shouldSettle =
          nextPromise.weeksElapsed >= promise.durationWeeks &&
          (observedWeeks >= promise.durationWeeks ||
              elapsedCalendarWeeks > promise.durationWeeks);
      if (!shouldSettle) {
        promises.add(nextPromise);
        continue;
      }
      final possible = history.fold<int>(
        0,
        (sum, entry) => sum + entry.possibleMinutes,
      );
      final minutes = history.fold<int>(0, (sum, entry) => sum + entry.minutes);
      final fulfilled =
          possible > 0 && minutes / possible >= promise.requiredMinutesShare;
      final player = _findPlayer(team, promise.playerId);
      if (fulfilled) {
        nextState = _applyTeamDeltas(
          nextState,
          team.id,
          atmosphere: 5,
          reason: 'promiseFulfilled',
          payload: {'playerId': promise.playerId, 'promiseId': promise.id},
        );
      } else {
        final extraPenalty = player == null
            ? 0
            : (player.personality == PlayerPersonality.temperamental ||
                      player.personality == PlayerPersonality.ambitious
                  ? 3
                  : 0);
        nextState = _applyTeamDeltas(
          nextState,
          team.id,
          atmosphere: -12 - extraPenalty,
          reason: 'promiseBroken',
          payload: {
            'playerId': promise.playerId,
            'promiseId': promise.id,
            'minutes': minutes,
            'possibleMinutes': possible,
          },
        );
        nextState = _emitAutomatic(
          nextState,
          teamId: team.id,
          kind: 'promiseBroken',
          priority: MessagePriority.urgent,
          payload: {
            'teamId': team.id,
            'playerId': promise.playerId,
            'promiseId': promise.id,
            'eventKind': 'promiseBroken',
          },
        );
        if (player != null &&
            _roll(
              nextState,
              team.id,
              player.id,
              'transferRequestIIAfterPromise',
              balance.events.transferRequestIIChanceAfterBrokenPromise,
              saveSeed,
            )) {
          nextState = _queueTransferRequest(
            nextState,
            team.id,
            player.id,
            'transferRequestII',
            saveSeed: saveSeed,
          );
        }
      }
    }
    final current = nextState.teamById(team.id);
    if (current == null) return nextState;
    return _setTeamEventState(
      nextState,
      team.id,
      current.eventState.copyWith(promises: promises),
    );
  }

  LeagueState _settleTransferSituations(LeagueState state, String teamId) {
    final team = state.teamById(teamId);
    if (team == null || team.eventState.transferSituations.isEmpty) {
      return state;
    }
    var nextState = state;
    final active = <TeamTransferSituation>[];
    for (final situation in team.eventState.transferSituations) {
      final windowOpen = calendar.isTradeWindowOpen(
        state.currentWeek,
        day: state.currentDay,
      );
      final weeksSinceCreated =
          _calendarWeekKey(state.currentSeason.year, state.currentWeek) -
          _calendarWeekKey(situation.createdSeasonYear, situation.createdWeek);
      // The first weekly tick after acceptance starts the first full week; it
      // must not consume a week that only contains the acceptance day.
      final isInitialClock =
          weeksSinceCreated <= 1 &&
          situation.weeksRemaining >= balance.events.transferSituationWeeks;
      final remaining = isInitialClock
          ? situation.weeksRemaining
          : situation.weeksRemaining - 1;
      if (remaining > 0 && windowOpen) {
        active.add(situation.copyWith(weeksRemaining: remaining));
        continue;
      }
      nextState = _applyTeamDeltas(
        nextState,
        team.id,
        atmosphere: -15,
        chemistry: -4,
        reason: 'transferRequestExpired',
        payload: {
          'playerId': situation.playerId,
          'eventKind': situation.kind,
          'transferSituationId': situation.id,
        },
      );
      nextState = _clearPointValueMultiplier(
        nextState,
        team.id,
        situation.playerId,
      );
    }
    final current = nextState.teamById(team.id);
    if (current == null) return nextState;
    return _setTeamEventState(
      nextState,
      team.id,
      current.eventState.copyWith(transferSituations: active),
    );
  }

  LeagueState _applyDecision(
    LeagueState state, {
    required String teamId,
    required String? playerId,
    required String kind,
    required String optionId,
    required int saveSeed,
    Map<String, dynamic> payload = const {},
  }) {
    final team = state.teamById(teamId);
    if (team == null) return state;
    final player = playerId == null ? null : _findPlayer(team, playerId);

    switch (kind) {
      case 'moreMinutesRequest':
        if (player == null) return state;
        if (optionId == 'accept') {
          final promise = TeamPromise(
            id: 'moreMinutes:${state.currentSeason.year}:${state.currentWeek}:${player.id}',
            playerId: player.id,
            kind: 'moreMinutesRequest',
            createdSeasonYear: state.currentSeason.year,
            createdWeek: state.currentWeek,
            durationWeeks: balance.events.moreMinutesPromiseWeeks,
            requiredMinutesShare: balance.events.moreMinutesPromiseShare,
          );
          var next = _applyTeamStateAndDeltas(
            state,
            teamId,
            team.eventState.copyWith(
              promises: [
                ...team.eventState.promises.where(
                  (item) => item.playerId != player.id,
                ),
                promise,
              ],
            ),
            atmosphere: -3,
            reason: 'moreMinutesAccept',
            payload: {'playerId': player.id, 'promiseId': promise.id},
          );
          final updatedTeam = next.teamById(teamId);
          if (updatedTeam == null) return next;
          final promisedPlayer = updatedTeam.roster.cast<Player?>().firstWhere(
            (candidate) => candidate?.id == player.id,
            orElse: () => null,
          );
          if (promisedPlayer == null) return next;
          return next.updateTeam(
            updatedTeam.copyWith(
              roster: updatedTeam.roster
                  .map(
                    (candidate) => candidate.id == player.id
                        ? candidate.copyWith(
                            state: candidate.state.copyWith(
                              eventState: candidate.state.eventState
                                  .replaceModifier(
                                    type: 'promiseMatchScoreBonus',
                                    value: balance
                                        .events
                                        .moreMinutesPromiseMatchScoreBonus,
                                    weeks:
                                        balance.events.moreMinutesPromiseWeeks,
                                  ),
                            ),
                          )
                        : candidate,
                  )
                  .toList(),
            ),
          );
        }
        if (optionId == 'decline') {
          final extra =
              player.personality == PlayerPersonality.temperamental ||
                  player.personality == PlayerPersonality.ambitious
              ? 3
              : 0;
          return _applyTeamDeltas(
            state,
            teamId,
            atmosphere: -7 - extra,
            reason: 'moreMinutesDecline',
            payload: {'playerId': player.id},
          );
        }
        return state;

      case 'transferRequestI':
      case 'transferRequestII':
        if (player == null) return state;
        if (optionId == 'accept') {
          final situation = TeamTransferSituation(
            id: '$kind:${state.currentSeason.year}:${state.currentWeek}:${player.id}',
            playerId: player.id,
            kind: kind,
            createdSeasonYear: state.currentSeason.year,
            createdWeek: state.currentWeek,
            weeksRemaining: balance.events.transferSituationWeeks,
          );
          var next = _applyTeamStateAndDeltas(
            state,
            teamId,
            team.eventState.copyWith(
              transferSituations: [
                ...team.eventState.transferSituations.where(
                  (item) => item.playerId != player.id,
                ),
                situation,
              ],
            ),
            atmosphere: 3,
            reason: '${kind}Accept',
            payload: {'playerId': player.id, 'situationId': situation.id},
          );
          next = _setPointValueMultiplier(next, teamId, player.id, 0.9);
          final updated = next.teamById(teamId);
          if (updated == null) return next;
          return _setTeamEventState(
            next,
            teamId,
            updated.eventState
                .replaceModifier(
                  type: 'tradeAppetite:${player.id}',
                  value: balance.events.transferTradeAppetiteMultiplier - 1.0,
                  weeks: balance.events.transferSituationWeeks,
                )
                .replaceModifier(
                  type: 'tradeSurplusPct:${player.id}',
                  value: balance.events.transferTradeSurplusShift,
                  weeks: balance.events.transferSituationWeeks,
                ),
          );
        }
        if (optionId == 'decline') {
          var next = _applyTeamDeltas(
            state,
            teamId,
            atmosphere: -6,
            chemistry: -2,
            reason: '${kind}Decline',
            payload: {'playerId': player.id},
          );
          next = _clearPointValueMultiplier(next, teamId, player.id);
          return next;
        }
        return state;

      case 'dressingRoomConflict':
        final ids =
            (payload['temperamentalPlayerIds'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            const <String>[];
        var next = _setTeamCooldown(state, teamId, 'dressingRoomConflict', 1);
        if (optionId == 'intervene') {
          final positive =
              _random(
                next,
                teamId,
                null,
                'dressingRoomConflictOutcome',
                saveSeed,
              ).nextDouble() <
              0.5;
          next = _applyTeamDeltas(
            next,
            teamId,
            atmosphere: positive ? 2 : -3,
            chemistry: -2,
            reason: 'dressingRoomConflictIntervene',
          );
          if (!positive) {
            next = _addTeamModifier(
              next,
              teamId,
              type: 'negativeEventMultiplier',
              value: 0.2,
              weeks: balance.events.dressingRoomConflictPenaltyWeeks,
            );
          }
          if (ids.isEmpty) return next;
          final transferPlayer = _findPlayer(next.teamById(teamId)!, ids.first);
          if (transferPlayer == null) return next;
          return _queueTransferRequest(
            next,
            teamId,
            transferPlayer.id,
            'transferRequestI',
            saveSeed: saveSeed,
            bypassWindow: true,
          );
        }
        if (optionId == 'ignore') {
          next = _applyTeamDeltas(
            next,
            teamId,
            atmosphere: -3,
            chemistry: -2,
            reason: 'dressingRoomConflictIgnore',
          );
          return _addTeamModifier(
            next,
            teamId,
            type: 'negativeEventMultiplier',
            value: 0.2,
            weeks: balance.events.dressingRoomConflictPenaltyWeeks,
          );
        }
        return state;

      case 'publicCriticism':
        if (player == null) return state;
        final nextMultiplier = switch (optionId) {
          'punish' => balance.events.publicCriticismPunishRollMultiplier,
          'ignore' => balance.events.publicCriticismIgnoreRollMultiplier,
          'response' => 1.0,
          _ => null,
        };
        if (nextMultiplier == null) return state;
        final (atmosphere, chemistry) = switch (optionId) {
          'punish' => (-2, -2.0),
          'response' => (-1, -1.0),
          _ => (-1, -1.0),
        };
        final current = team.eventState.copyWith(
          publicCriticismRollMultiplier: nextMultiplier,
        );
        return _applyTeamStateAndDeltas(
          state,
          teamId,
          current,
          atmosphere: atmosphere,
          chemistry: chemistry,
          reason: 'publicCriticism:$optionId',
          payload: {'playerId': player.id, 'option': optionId},
        );

      default:
        return state;
    }
  }

  LeagueState _queueTransferRequest(
    LeagueState state,
    String teamId,
    String playerId,
    String kind, {
    required int saveSeed,
    bool bypassWindow = false,
  }) {
    final team = state.teamById(teamId);
    final player = team == null ? null : _findPlayer(team, playerId);
    if (team == null || player == null) return state;
    if (player.personality == PlayerPersonality.loyal ||
        team.eventState.transferSituationFor(playerId) != null ||
        _hasPendingDecision(state, playerId, kind, teamId: team.id)) {
      return state;
    }
    if (!bypassWindow &&
        kind == 'transferRequestI' &&
        !calendar.isTradeWindowOpen(state.currentWeek, day: state.currentDay)) {
      return state;
    }
    if (kind == 'transferRequestII' && _isFutureUfa(player)) {
      return _emitDeclineToExtend(state, teamId, player);
    }
    var next = _setPointValueMultiplier(state, teamId, playerId, 0.9);
    return _queueDecision(
      next,
      teamId: teamId,
      playerId: playerId,
      kind: kind,
      saveSeed: saveSeed,
    );
  }

  LeagueState _emitDeclineToExtend(
    LeagueState state,
    String teamId,
    Player player,
  ) {
    final team = state.teamById(teamId);
    if (team == null ||
        team.eventState.hasSeasonFlag(
          'declineToExtend:${player.id}',
          state.currentSeason.year,
        )) {
      return state;
    }
    final flagged = team.eventState.withSeasonFlag(
      'declineToExtend:${player.id}',
      state.currentSeason.year,
    );
    final next = _setTeamEventState(state, teamId, flagged);
    return _emitAutomatic(
      next,
      teamId: teamId,
      kind: 'declineToExtend',
      args: {'playerName': player.name},
      payload: {
        'teamId': teamId,
        'playerId': player.id,
        'eventKind': 'declineToExtend',
      },
    );
  }

  LeagueState _queueDecision(
    LeagueState state, {
    required String teamId,
    String? playerId,
    required String kind,
    required int saveSeed,
    Map<String, dynamic> payload = const {},
  }) {
    final team = state.teamById(teamId);
    if (team == null) return state;
    final player = playerId == null ? null : _findPlayer(team, playerId);
    final expandedPayload = <String, dynamic>{
      'teamId': teamId,
      'eventKind': kind,
    };
    if (playerId != null) {
      expandedPayload['playerId'] = playerId;
    }
    expandedPayload.addAll(payload);
    if (state.playerTeamId == teamId) {
      return _emitDecisionMessage(
        state,
        teamId: teamId,
        player: player,
        kind: kind,
        payload: expandedPayload,
      );
    }
    final option = _aiDecisionOption(state, team, player, kind, saveSeed);
    return _applyDecision(
      state,
      teamId: teamId,
      playerId: playerId,
      kind: kind,
      optionId: option,
      saveSeed: saveSeed,
      payload: expandedPayload,
    );
  }

  String _aiDecisionOption(
    LeagueState state,
    Team team,
    Player? player,
    String kind,
    int saveSeed,
  ) {
    final roll = _aiDecisionRoll(state, team.id, kind, saveSeed);
    switch (kind) {
      case 'moreMinutesRequest':
        final acceptChance = player != null && _isTopFourteen(team, player.id)
            ? balance.events.aiMoreMinutesTopFourteenAcceptChance
            : balance.events.aiMoreMinutesDepthAcceptChance;
        return roll < acceptChance ? 'accept' : 'decline';
      case 'transferRequestI':
        // `TradeService.assetValue` has no player-only API here. pointValue is
        // its existing objective asset proxy; the temporary event multiplier
        // is included so a devalued player is not treated as a positive asset.
        final positiveAsset =
            player != null &&
            player.pointValue *
                    team.eventState.pointValueMultiplierFor(player.id) >
                0;
        final inTradeWindow = calendar.isTradeWindowOpen(
          state.currentWeek,
          day: state.currentDay,
        );
        final acceptChance = positiveAsset && inTradeWindow
            ? balance.events.aiTransferRequestAcceptChance
            : balance.events.aiTransferRequestOtherAcceptChance;
        return roll < acceptChance ? 'accept' : 'decline';
      case 'transferRequestII':
        return roll < balance.events.aiTransferRequestIIAcceptChance
            ? 'accept'
            : 'decline';
      case 'dressingRoomConflict':
        return roll < balance.events.aiDressingRoomInterveneChance
            ? 'intervene'
            : 'ignore';
      case 'publicCriticism':
        if (roll < balance.events.aiPublicCriticismPunishChance)
          return 'punish';
        if (roll < balance.events.aiPublicCriticismResponseCutoff) {
          return 'response';
        }
        return 'ignore';
      default:
        return 'decline';
    }
  }

  double _aiDecisionRoll(
    LeagueState state,
    String teamId,
    String kind,
    int saveSeed,
  ) => Random(
    teamEventSeed(
      saveSeed,
      state.currentSeason.year,
      state.currentWeek,
      teamId,
      'aiDecision:$kind',
    ),
  ).nextDouble();

  bool _isTopFourteen(Team team, String playerId) {
    final ranked = [...team.roster]
      ..sort((a, b) {
        final byOverall = _eventOverall(b).compareTo(_eventOverall(a));
        return byOverall != 0 ? byOverall : a.id.compareTo(b.id);
      });
    final rank = ranked.indexWhere((player) => player.id == playerId);
    return rank >= 0 && rank < 14;
  }

  LeagueState _emitDecisionMessage(
    LeagueState state, {
    required String teamId,
    required Player? player,
    required String kind,
    required Map<String, dynamic> payload,
  }) {
    // Team events are generated at the end of a simulated day and become
    // actionable at the next day's start. Keep the configured one actionable
    // day after that delivery boundary instead of expiring at that boundary.
    final expiry = logicalDate(state)
        .add(Duration(days: balance.events.teamEventDecisionExpiryDays + 1))
        .toIso8601String();
    return messages.send(
      state,
      type: MessageType.teamEvent,
      kind: kind,
      domain: MessageDomain.teamEvent,
      priority: MessagePriority.urgent,
      args: {if (player != null) 'playerName': player.name, ...payload},
      payload: payload,
      expiresAt: expiry,
      dedupKey:
          'teamEvent:$kind:$teamId:${player?.id ?? 'team'}:${state.currentSeason.year}:${state.currentWeek}',
    );
  }

  LeagueState _emitAutomatic(
    LeagueState state, {
    required String teamId,
    required String kind,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
    MessagePriority? priority,
  }) {
    if (state.playerTeamId != teamId) return state;
    return messages.send(
      state,
      type: MessageType.teamEvent,
      kind: kind,
      domain: MessageDomain.teamEvent,
      priority: priority ?? MessagePriority.normal,
      args: args,
      payload: payload,
      dedupKey:
          'teamEvent:$kind:$teamId:${payload['playerId'] ?? 'team'}:${state.currentSeason.year}:${state.currentWeek}',
    );
  }

  LeagueState _applyTeamDeltas(
    LeagueState state,
    String teamId, {
    int atmosphere = 0,
    double chemistry = 0,
    required String reason,
    Map<String, dynamic> payload = const {},
  }) {
    if (atmosphere == 0 && chemistry == 0) return state;
    final team = state.teamById(teamId);
    if (team == null) return state;
    final updated = teamManagement.applyChemistryDelta(
      teamManagement.applyAtmosphereDelta(team, atmosphere),
      chemistry,
    );
    var next = state.updateTeam(updated);
    final actualAtmosphere = updated.atmosphere - team.atmosphere;
    final actualChemistry = updated.chemistry - team.chemistry;
    if (state.playerTeamId != teamId) return next;
    next = messages.send(
      next,
      type: MessageType.teamEvent,
      kind: 'atmosphereShift',
      domain: MessageDomain.teamEvent,
      args: {
        'delta': actualAtmosphere,
        'chemistryDelta': actualChemistry,
        'oldLevel': team.atmosphere,
        'newLevel': updated.atmosphere,
        'atmosphereBefore': team.atmosphere,
        'atmosphereAfter': updated.atmosphere,
        'atmosphere': updated.atmosphere,
        'chemistry': updated.chemistry,
        ...payload,
      },
      payload: {
        'teamId': teamId,
        'eventKind': 'atmosphereShift',
        'atmosphereDelta': actualAtmosphere,
        'chemistryDelta': actualChemistry,
        'oldLevel': team.atmosphere,
        'newLevel': updated.atmosphere,
        'atmosphereBefore': team.atmosphere,
        'atmosphereAfter': updated.atmosphere,
        'atmosphere': updated.atmosphere,
        'chemistry': updated.chemistry,
        'reason': reason,
        ...payload,
      },
      dedupKey:
          'atmosphere:event:$reason:$teamId:${state.currentSeason.year}:${state.currentWeek}',
    );
    return next;
  }

  LeagueState _applyTeamStateAndDeltas(
    LeagueState state,
    String teamId,
    TeamEventState eventState, {
    int atmosphere = 0,
    double chemistry = 0,
    required String reason,
    Map<String, dynamic> payload = const {},
  }) {
    final stateWithEvent = _setTeamEventState(state, teamId, eventState);
    return _applyTeamDeltas(
      stateWithEvent,
      teamId,
      atmosphere: atmosphere,
      chemistry: chemistry,
      reason: reason,
      payload: payload,
    );
  }

  LeagueState _setTeamEventState(
    LeagueState state,
    String teamId,
    TeamEventState eventState,
  ) {
    final team = state.teamById(teamId);
    return team == null
        ? state
        : state.updateTeam(team.copyWith(eventState: eventState));
  }

  LeagueState _setTeamCooldown(
    LeagueState state,
    String teamId,
    String key,
    int weeks,
  ) {
    final team = state.teamById(teamId);
    return team == null
        ? state
        : _setTeamEventState(
            state,
            teamId,
            team.eventState.withCooldown(key, weeks),
          );
  }

  LeagueState _addTeamModifier(
    LeagueState state,
    String teamId, {
    required String type,
    required double value,
    required int weeks,
  }) {
    final team = state.teamById(teamId);
    return team == null
        ? state
        : _setTeamEventState(
            state,
            teamId,
            team.eventState.addModifier(type: type, value: value, weeks: weeks),
          );
  }

  LeagueState _setPointValueMultiplier(
    LeagueState state,
    String teamId,
    String playerId,
    double multiplier,
  ) {
    final team = state.teamById(teamId);
    return team == null
        ? state
        : _setTeamEventState(
            state,
            teamId,
            team.eventState.withPointValueMultiplier(playerId, multiplier),
          );
  }

  LeagueState _clearPointValueMultiplier(
    LeagueState state,
    String teamId,
    String playerId,
  ) {
    final team = state.teamById(teamId);
    if (team == null) return state;
    final eventState = team.eventState
        .clearPointValueMultiplier(playerId)
        .clearModifier('tradeAppetite:$playerId')
        .clearModifier('tradeSurplusPct:$playerId');
    return _setTeamEventState(state, teamId, eventState);
  }

  bool _isUnderplayed(Team team, String playerId, double threshold) {
    final entries = team.eventState.minutesHistory
        .where((entry) => entry.playerId == playerId)
        .toList();
    if (entries.isEmpty) return false;
    final minutes = entries.fold<int>(0, (sum, entry) => sum + entry.minutes);
    final possible = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.possibleMinutes,
    );
    return possible > 0 && minutes / possible < threshold;
  }

  double _minutesShare(Team team, String playerId) {
    final entries = team.eventState.minutesHistory
        .where((entry) => entry.playerId == playerId)
        .toList();
    final minutes = entries.fold<int>(0, (sum, entry) => sum + entry.minutes);
    final possible = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.possibleMinutes,
    );
    return possible == 0 ? 0 : minutes / possible;
  }

  bool _isTopTwentyPercentValue(LeagueState state, Player player) {
    final values = [
      for (final team in state.teams)
        for (final candidate in team.roster) candidate.pointValue,
    ]..sort((a, b) => b.compareTo(a));
    if (values.isEmpty) return false;
    final count = max(1, (values.length * 0.20).ceil());
    return player.pointValue >= values[min(count - 1, values.length - 1)];
  }

  bool _isBottomHalf(LeagueState state, String teamId) {
    final rank = TeamManagementService.actualRankOf(state, teamId);
    return rank > state.teams.length / 2;
  }

  int _playoffRoundReached(LeagueState league, String teamId) {
    var reached = 0;
    for (final bracket in league.currentSeason.playoffBrackets) {
      bool includes(Iterable<PlayoffSeries> series) => series.any(
        (item) =>
            item.higherSeedTeamId == teamId || item.lowerSeedTeamId == teamId,
      );
      if (includes(bracket.quarterFinals)) reached = max(reached, 1);
      if (includes(bracket.semiFinals)) reached = max(reached, 2);
      if (includes(bracket.conferenceFinal)) reached = max(reached, 3);
      final finalSeries = bracket.leagueFinal;
      if (finalSeries != null &&
          (finalSeries.higherSeedTeamId == teamId ||
              finalSeries.lowerSeedTeamId == teamId)) {
        reached = max(reached, 4);
      }
    }
    return reached;
  }

  int _possibleMinutes(Player player) =>
      player.isAvailable ? balance.player.minutesPerMatch : 0;

  int _winStreak(List<int> results) {
    if (results.isEmpty || results.last != 1) return 0;
    var count = 0;
    for (var index = results.length - 1; index >= 0; index--) {
      if (results[index] != 1) break;
      count++;
    }
    return count;
  }

  bool _roll(
    LeagueState state,
    String teamId,
    String? playerId,
    String eventKind,
    double probability,
    int saveSeed,
  ) {
    if (probability <= 0) return false;
    if (probability >= 1) return true;
    return _random(state, teamId, playerId, eventKind, saveSeed).nextDouble() <
        probability;
  }

  Random _random(
    LeagueState state,
    String teamId,
    String? playerId,
    String eventKind,
    int saveSeed, {
    int salt = 0,
  }) => Random(
    teamEventSeed(
      saveSeed,
      state.currentSeason.year,
      state.currentWeek,
      teamId,
      eventKind,
      playerId: playerId,
      salt: salt,
    ),
  );

  bool _hasPendingDecision(
    LeagueState state,
    String? playerId,
    String kind, {
    String? teamId,
  }) => [...state.inbox.messages, ...state.inbox.scheduled].any(
    (message) =>
        !message.acknowledged &&
        message.type == MessageType.teamEvent &&
        message.kind == kind &&
        (teamId == null || message.payload['teamId'] == teamId) &&
        (playerId == null || message.payload['playerId'] == playerId),
  );

  Player? _findPlayer(Team team, String playerId) {
    for (final player in team.roster) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  bool _isFutureUfa(Player player) {
    // Contract has no explicit QO/RFA flag yet. Rookie-scale contracts are
    // the only restricted path represented by the current model, so avoid
    // emitting a UFA declaration for them; veteran contracts are treated as
    // UFA candidates when their remaining term reaches one year.
    return player.contract.yearsRemaining <= 1 &&
        !player.contract.isRookieScale;
  }

  int _calendarWeekKey(int seasonYear, int week) => seasonYear * 52 + week;
}
