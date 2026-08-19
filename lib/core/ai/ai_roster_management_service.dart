import 'dart:math';

import 'package:new_football/core/ai/ai_trade_models.dart';
import 'package:new_football/core/ai/ai_trade_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/trade_service.dart';

/// Stateless safety controller for AI rosters.
///
/// The controller is called before regular-season matchdays and postseason
/// games, plus at the retirement/rollover boundaries. It never releases a
/// player and never mutates a roster directly: free-agent additions go through
/// [ContractMarketService], while a full-roster 2-for-1 goes through the
/// persisted [TradeService] offer/accept pipeline.
class AiRosterManagementService {
  AiRosterManagementService({
    this.balance = BalanceConfig.defaults,
    ContractMarketService? contractMarket,
    TradeService? tradeService,
    AiTradeService? aiTradeService,
    CalendarService? calendar,
  }) : contractMarket =
           contractMarket ?? ContractMarketService(balance: balance),
       tradeService = tradeService ?? TradeService(balance: balance),
       aiTradeService =
           aiTradeService ??
           AiTradeService(
             balance: balance,
             tradeService: tradeService ?? TradeService(balance: balance),
           ),
       calendar = calendar ?? CalendarService(balance: balance);

  final BalanceConfig balance;
  final ContractMarketService contractMarket;
  final TradeService tradeService;
  final AiTradeService aiTradeService;
  final CalendarService calendar;

  /// Repairs every AI club immediately before matchday simulation.
  ///
  /// The method is idempotent: calling it repeatedly with the same state and
  /// seed does not duplicate a signing, repeat a major-injury decision, or
  /// create a second trade for the same roster gap.
  LeagueState ensurePreMatchdaySafety(LeagueState league, {int saveSeed = 0}) {
    var state = league;
    final teamIds = [
      for (final team in league.teams)
        if (team.ai != null && team.id != league.playerTeamId) team.id,
    ]..sort();
    for (final teamId in teamIds) {
      state = _ensureTeam(state, teamId, saveSeed: saveSeed);
    }
    return state;
  }

  /// Lifecycle alias used after the retirement calendar event.
  LeagueState replenishAfterRetirements(
    LeagueState league, {
    int saveSeed = 0,
  }) => ensurePreMatchdaySafety(league, saveSeed: saveSeed);

  /// Lifecycle alias used after season rollover and before week 1.
  LeagueState ensurePreseasonRoster(LeagueState league, {int saveSeed = 0}) =>
      ensurePreMatchdaySafety(league, saveSeed: saveSeed);

  /// General-purpose public entry point for headless harnesses and tests.
  LeagueState ensureRosterSafety(LeagueState league, {int saveSeed = 0}) =>
      ensurePreMatchdaySafety(league, saveSeed: saveSeed);

  LeagueState _ensureTeam(
    LeagueState state,
    String teamId, {
    required int saveSeed,
  }) {
    var next = _fillMinimumRoster(state, teamId, saveSeed: saveSeed);
    next = _respondToMajorInjuries(next, teamId, saveSeed: saveSeed);
    next = _repairAvailability(next, teamId, saveSeed: saveSeed);
    return next;
  }

  LeagueState _fillMinimumRoster(
    LeagueState state,
    String teamId, {
    required int saveSeed,
  }) {
    var next = state;
    while (true) {
      final team = next.teamById(teamId);
      if (team == null || team.roster.length >= balance.roster.minSize) {
        return next;
      }
      final preferred = _criticalPosition(team);
      final signed = _signOrTradeForNeed(
        next,
        teamId,
        preferred,
        saveSeed: saveSeed,
        requireAvailable: false,
      );
      if (signed == null || signed == next) return next;
      next = signed;
    }
  }

  LeagueState _repairAvailability(
    LeagueState state,
    String teamId, {
    required int saveSeed,
  }) {
    var next = state;
    final team = next.teamById(teamId);
    if (team == null) return next;
    final available = _availableCount(team);
    if (available > 13) return next;

    // A roster with fewer than an XI gets an unconditional same-day attempt;
    // the documented 90% roll applies to the softer <=13-depth response.
    final shouldAttempt =
        available < balance.roster.startingXi ||
        _rollTeam(
          next,
          team,
          'availableDepth',
          balance.ai.pRosterAvailableDepth,
          saveSeed: saveSeed,
        );
    if (!shouldAttempt) return next;

    final preferred = _criticalPosition(team);
    next =
        _signOrTradeForNeed(
          next,
          teamId,
          preferred,
          saveSeed: saveSeed,
          requireAvailable: true,
        ) ??
        next;

    // If the first emergency signing still leaves fewer than eleven available,
    // continue with deterministic candidates until the legal floor is reached.
    while (true) {
      final current = next.teamById(teamId);
      if (current == null ||
          _availableCount(current) >= balance.roster.startingXi) {
        break;
      }
      final repaired = _signOrTradeForNeed(
        next,
        teamId,
        _criticalPosition(current),
        saveSeed: saveSeed,
        requireAvailable: true,
      );
      if (repaired == null || repaired == next) break;
      next = repaired;
    }
    return next;
  }

  LeagueState _respondToMajorInjuries(
    LeagueState state,
    String teamId, {
    required int saveSeed,
  }) {
    var next = state;
    final snapshot = next.teamById(teamId);
    if (snapshot == null) return next;

    for (final player in snapshot.roster) {
      final injury = player.state.injury;
      if (injury == null ||
          !injury.isActive ||
          injury.type != InjuryType.major) {
        continue;
      }
      final current = next.teamById(teamId);
      if (current == null) break;
      final flag = 'aiRosterMajor:${player.id}:${injury.id}';
      if (current.eventState.hasSeasonFlag(flag, next.currentSeason.year)) {
        continue;
      }

      // Mark before the roll and before a signing attempt. This makes a
      // failed/no-op response replay-safe while regular depth repair can still
      // retry on a later day if a new free agent appears.
      next = _markTeamFlag(next, teamId, flag);
      final currentPlayer = _findPlayer(next.teamById(teamId), player.id);
      if (currentPlayer == null) continue;
      final team = next.teamById(teamId)!;
      final isGoalkeeper = currentPlayer.position == Position.gk;
      final remainingGoalkeepers = team.roster
          .where(
            (candidate) =>
                candidate.position == Position.gk &&
                !(candidate.state.injury?.isActive ?? false),
          )
          .length;
      final goalkeeperResponse = isGoalkeeper && remainingGoalkeepers <= 1;
      final lineupResponse =
          _wasLikelyStarter(team, currentPlayer.id) &&
          !_hasCloseSubstitute(team, currentPlayer);
      if (!goalkeeperResponse && !lineupResponse) continue;

      final probability = goalkeeperResponse
          ? balance.ai.pRosterMajorGk
          : balance.ai.pRosterMajorInjury;
      final eventKind = goalkeeperResponse ? 'majorGk' : 'majorStarter';
      if (!_rollPlayer(
        next,
        team,
        currentPlayer,
        eventKind,
        probability,
        saveSeed: saveSeed,
      )) {
        continue;
      }
      next =
          _signOrTradeForNeed(
            next,
            teamId,
            goalkeeperResponse ? Position.gk : currentPlayer.position,
            saveSeed: saveSeed,
            requireAvailable: true,
          ) ??
          next;
    }
    return next;
  }

  LeagueState? _signOrTradeForNeed(
    LeagueState state,
    String teamId,
    Position? preferredPosition, {
    required int saveSeed,
    required bool requireAvailable,
  }) {
    final team = state.teamById(teamId);
    if (team == null) return null;
    if (team.roster.length < balance.roster.maxSize) {
      return contractMarket.signEmergencyFreeAgent(
        state,
        teamId: teamId,
        preferredPosition: preferredPosition,
        requireAvailable: requireAvailable,
        years: balance.ai.rosterEmergencyOfferYears,
        saveSeed: saveSeed,
      );
    }

    if (preferredPosition == null ||
        !_isCriticalNeed(team, preferredPosition)) {
      return null;
    }
    if (!_rollTeam(
      state,
      team,
      'rosterSpaceTrade',
      balance.ai.pRosterSpaceTrade,
      saveSeed: saveSeed,
    )) {
      return null;
    }
    return _tryTwoForOne(state, teamId, preferredPosition, saveSeed: saveSeed);
  }

  LeagueState? _tryTwoForOne(
    LeagueState state,
    String teamId,
    Position preferredPosition, {
    required int saveSeed,
  }) {
    if (!calendar.isTradeWindowOpen(state.currentWeek, day: state.currentDay)) {
      return null;
    }
    final source = state.teamById(teamId);
    if (source == null || source.roster.length != balance.roster.maxSize) {
      return null;
    }
    final partners = [
      for (final team in state.teams)
        if (team.id != source.id &&
            team.ai != null &&
            team.roster.length < balance.roster.maxSize)
          team,
    ]..sort((a, b) => a.id.compareTo(b.id));
    if (partners.isEmpty) return null;

    final outgoing = _tradeOutgoers(source);
    if (outgoing.length < 2) return null;
    for (final partner in partners) {
      final incoming = [...partner.roster]
        ..sort((a, b) {
          final aPreferred = a.position == preferredPosition;
          final bPreferred = b.position == preferredPosition;
          if (aPreferred != bPreferred) return aPreferred ? -1 : 1;
          final byValue = b.pointValue.compareTo(a.pointValue);
          return byValue != 0 ? byValue : a.id.compareTo(b.id);
        });
      for (final target in incoming) {
        final proposal = TradeProposal(
          teamAId: source.id,
          teamBId: partner.id,
          assetsFromA: [
            TradeAsset.player(outgoing[0].id),
            TradeAsset.player(outgoing[1].id),
          ],
          assetsFromB: [TradeAsset.player(target.id)],
        );
        final validation = tradeService.validateLeague(
          state,
          proposal,
          currentWeek: state.currentWeek,
          currentDay: state.currentDay,
        );
        if (!validation.ok) continue;
        final decision = aiTradeService.evaluateOffer(
          league: state,
          proposal: proposal,
          evaluatingTeamId: partner.id,
          saveSeed: saveSeed,
          packageSalt: target.id.length,
        );
        if (decision.action != AiTradeAction.accept) continue;
        final created = tradeService.createOffer(
          state,
          proposal,
          offeringTeamId: source.id,
          emitMessages: false,
        );
        if (!created.changed || created.offerId == null) continue;
        final accepted = tradeService.acceptOffer(
          created.league,
          created.offerId!,
          actingTeamId: partner.id,
          emitMessages: false,
        );
        if (accepted.outcome == 'accepted' && accepted.changed) {
          return accepted.league;
        }
      }
    }
    return null;
  }

  List<Player> _tradeOutgoers(Team team) {
    final lineup = team.lineupPlayerIds.toSet();
    final candidates = team.roster.where((player) {
      if (lineup.contains(player.id)) return false;
      if (player.position == Position.gk &&
          team.roster
                  .where((candidate) => candidate.position == Position.gk)
                  .length <=
              2) {
        return false;
      }
      return !_isCriticalNeed(team, player.position);
    }).toList();
    candidates.sort((a, b) {
      final byValue = a.pointValue.compareTo(b.pointValue);
      return byValue != 0 ? byValue : a.id.compareTo(b.id);
    });
    if (candidates.length >= 2) return candidates;

    final fallback = [...team.roster]
      ..sort((a, b) {
        final byValue = a.pointValue.compareTo(b.pointValue);
        return byValue != 0 ? byValue : a.id.compareTo(b.id);
      });
    return fallback;
  }

  Position? _criticalPosition(Team team) {
    final definitions = balance.ai.rosterGroups;
    for (final definition in definitions) {
      final count = team.roster
          .where((player) => definition.positions.contains(player.position))
          .length;
      if (count < definition.min) return definition.positions.first;
    }
    return null;
  }

  bool _isCriticalNeed(Team team, Position position) {
    for (final definition in balance.ai.rosterGroups) {
      if (!definition.positions.contains(position)) continue;
      final count = team.roster
          .where((player) => definition.positions.contains(player.position))
          .length;
      return count < definition.min;
    }
    return false;
  }

  bool _wasLikelyStarter(Team team, String playerId) {
    if (team.lineupPlayerIds.isNotEmpty) {
      return team.lineupPlayerIds.contains(playerId);
    }
    final ranked = [...team.roster]
      ..sort((a, b) {
        final byOverall = b.overall(balance).compareTo(a.overall(balance));
        return byOverall != 0 ? byOverall : a.id.compareTo(b.id);
      });
    return ranked
        .take(balance.roster.startingXi)
        .any((player) => player.id == playerId);
  }

  bool _hasCloseSubstitute(Team team, Player injured) {
    for (final candidate in team.roster) {
      if (candidate.id == injured.id || !candidate.isAvailable) continue;
      if (!_sameRosterGroup(candidate.position, injured.position)) continue;
      if (injured.overall(balance) - candidate.overall(balance) <=
          balance.ai.rosterMajorInjuryOvrGap) {
        return true;
      }
    }
    return false;
  }

  bool _sameRosterGroup(Position first, Position second) {
    for (final definition in balance.ai.rosterGroups) {
      if (definition.positions.contains(first)) {
        return definition.positions.contains(second);
      }
    }
    return first == second;
  }

  int _availableCount(Team team) =>
      team.roster.where((player) => player.isAvailable).length;

  Player? _findPlayer(Team? team, String playerId) {
    if (team == null) return null;
    for (final player in team.roster) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  LeagueState _markTeamFlag(LeagueState state, String teamId, String flag) {
    final team = state.teamById(teamId);
    if (team == null) return state;
    return state.updateTeam(
      team.copyWith(
        eventState: team.eventState.withSeasonFlag(
          flag,
          state.currentSeason.year,
        ),
      ),
    );
  }

  bool _rollTeam(
    LeagueState state,
    Team team,
    String eventKind,
    double probability, {
    required int saveSeed,
  }) {
    if (probability <= 0) return false;
    if (probability >= 1) return true;
    return Random(
          teamEventSeed(
            saveSeed,
            state.currentSeason.year,
            state.currentWeek,
            team.id,
            eventKind,
            salt: state.currentDay,
          ),
        ).nextDouble() <
        probability;
  }

  bool _rollPlayer(
    LeagueState state,
    Team team,
    Player player,
    String eventKind,
    double probability, {
    required int saveSeed,
  }) {
    if (probability <= 0) return false;
    if (probability >= 1) return true;
    return Random(
          playerEventSeed(
            saveSeed,
            state.currentSeason.year,
            state.currentWeek,
            player.id,
            'aiRoster:$eventKind',
            salt: team.id.length,
          ),
        ).nextDouble() <
        probability;
  }
}
