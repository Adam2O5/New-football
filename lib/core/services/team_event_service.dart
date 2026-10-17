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

part 'team_event_triggers.dart';
part 'team_event_promises.dart';
part 'team_event_decisions.dart';
part 'team_event_messages.dart';
part 'team_event_helpers.dart';

/// Owns the persisted team-event state and all nine team events from
/// `docs/team_management.md`.
///
/// The service is deliberately separate from [TeamManagementService]: that
/// service applies deterministic atmosphere/chemistry primitives, while this
/// class owns event eligibility, rolls, promises, decisions and messages.
class TeamEventService
    with
        _TeamEventShared,
        _TeamEventTriggers,
        _TeamEventPromises,
        _TeamEventDecisions,
        _TeamEventMessages,
        _TeamEventHelpers {
  TeamEventService({
    this.balance = BalanceConfig.defaults,
    MessageService? messages,
    CalendarService? calendar,
    TeamManagementService? teamManagement,
  }) : messages = messages ?? MessageService(),
       calendar = calendar ?? CalendarService(balance: balance),
       teamManagement = teamManagement ?? const TeamManagementService();

  @override
  final BalanceConfig balance;
  @override
  final MessageService messages;
  @override
  final CalendarService calendar;
  @override
  final TeamManagementService teamManagement;

  @override
  int? _valueThresholdCache;
  @override
  bool _valueThresholdReady = false;

  /// Records the completed match and performs the two after-match rolls:
  /// `moreMinutesRequest` and `transferRequestI`.
  LeagueState afterMatch(
    LeagueState league,
    MatchResult result, {
    int saveSeed = 0,
  }) {
    var state = recordMatchMinutes(league, result);
    if (TeamManagementService.isWalkoverResult(result)) return state;

    _valueThresholdReady = false;
    _valueThresholdCache = null;
    try {
      for (final teamId in {result.homeTeamId, result.awayTeamId}) {
        state = _tryMoreMinutes(state, teamId, saveSeed);
        state = _tryTransferRequestI(state, teamId, saveSeed);
      }
      return state;
    } finally {
      _valueThresholdReady = false;
      _valueThresholdCache = null;
    }
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

  @override
  DateTime logicalDate(LeagueState league) => DateTime.utc(
    league.currentSeason.year,
    1,
    1,
  ).add(Duration(days: (league.currentWeek - 1) * 7 + (league.currentDay - 1)));
}

mixin _TeamEventShared {
  BalanceConfig get balance;

  MessageService get messages;

  CalendarService get calendar;

  TeamManagementService get teamManagement;

  double _eventOverall(Player player);

  int? get _valueThresholdCache;

  set _valueThresholdCache(int? value);

  bool get _valueThresholdReady;

  set _valueThresholdReady(bool value);

  DateTime logicalDate(LeagueState league);

  LeagueState _applyDecision(
    LeagueState state, {
    required String teamId,
    required String? playerId,
    required String kind,
    required String optionId,
    required int saveSeed,
    Map<String, dynamic> payload = const {},
  });

  LeagueState _queueTransferRequest(
    LeagueState state,
    String teamId,
    String playerId,
    String kind, {
    required int saveSeed,
    bool bypassWindow = false,
    Map<String, dynamic> payload = const {},
  });

  LeagueState _queueDecision(
    LeagueState state, {
    required String teamId,
    String? playerId,
    required String kind,
    required int saveSeed,
    Map<String, dynamic> payload = const {},
  });

  LeagueState _emitAutomatic(
    LeagueState state, {
    required String teamId,
    required String kind,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
    MessagePriority? priority,
  });

  LeagueState _applyTeamDeltas(
    LeagueState state,
    String teamId, {
    int atmosphere = 0,
    double chemistry = 0,
    required String reason,
    Map<String, dynamic> payload = const {},
  });

  LeagueState _applyTeamStateAndDeltas(
    LeagueState state,
    String teamId,
    TeamEventState eventState, {
    int atmosphere = 0,
    double chemistry = 0,
    required String reason,
    Map<String, dynamic> payload = const {},
  });

  LeagueState _setTeamEventState(
    LeagueState state,
    String teamId,
    TeamEventState eventState,
  );

  LeagueState _setTeamCooldown(
    LeagueState state,
    String teamId,
    String key,
    int weeks,
  );

  LeagueState _addTeamModifier(
    LeagueState state,
    String teamId, {
    required String type,
    required double value,
    required int weeks,
  });

  LeagueState _setPointValueMultiplier(
    LeagueState state,
    String teamId,
    String playerId,
    double multiplier,
  );

  LeagueState _clearPointValueMultiplier(
    LeagueState state,
    String teamId,
    String playerId,
  );

  bool _isUnderplayed(Team team, String playerId, double threshold);

  double _minutesShare(Team team, String playerId);

  int? _topTwentyPercentValueThreshold(LeagueState state);

  bool _isBottomHalf(LeagueState state, String teamId);

  int _winStreak(List<int> results);

  bool _roll(
    LeagueState state,
    String teamId,
    String? playerId,
    String eventKind,
    double probability,
    int saveSeed,
  );

  Random _random(
    LeagueState state,
    String teamId,
    String? playerId,
    String eventKind,
    int saveSeed,
  );

  bool _hasPendingDecision(
    LeagueState state,
    String? playerId,
    String kind, {
    String? teamId,
  });

  Player? _findPlayer(Team team, String playerId);

  bool _isFutureUfa(Player player);

  int _calendarWeekKey(int seasonYear, int week);
}
