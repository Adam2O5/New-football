import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/simulation/pre_match_validator.dart';

/// Emits the four Task 15 matchday messages without putting inbox concerns in
/// the minute-by-minute engine. Messages are limited to fixtures involving
/// the player's team; AI-only matches stay silent.
class MatchMessageEmitter {
  MatchMessageEmitter({MessageService? messages})
    : _messages = messages ?? MessageService();

  final MessageService _messages;

  LeagueState emitPreMatch({
    required LeagueState league,
    required String matchId,
    required String homeTeamId,
    required String awayTeamId,
    required MatchContext context,
    required PreMatchReport report,
  }) {
    final playerTeamId = league.playerTeamId;
    if (playerTeamId == null ||
        (playerTeamId != homeTeamId && playerTeamId != awayTeamId)) {
      return league;
    }

    var state = league;
    final opponentTeamId = playerTeamId == homeTeamId ? awayTeamId : homeTeamId;
    final opponentName =
        league.teamById(opponentTeamId)?.name ?? opponentTeamId;

    if (report.isAdministrative &&
        report.violatingTeamIds.contains(playerTeamId)) {
      state = _messages.send(
        state,
        type: MessageType.walkover,
        domain: MessageDomain.matchday,
        priority: MessagePriority.urgent,
        args: {
          'team': league.teamById(playerTeamId)?.name ?? playerTeamId,
          'reason': report.reasonCode ?? 'administrative_result',
          'opponentName': opponentName,
        },
        payload: {
          'matchId': matchId,
          'teamId': playerTeamId,
          'reasonCode': report.reasonCode,
          'status': report.status.name,
        },
        dedupKey: 'walkover:$matchId',
      );
      return state;
    }

    final teamReport = report.home.teamId == playerTeamId
        ? report.home
        : report.away;
    if (report.noGkPenaltyTeamIds.contains(playerTeamId)) {
      state = _messages.send(
        state,
        type: MessageType.lineupNoGk,
        domain: MessageDomain.matchday,
        priority: MessagePriority.urgent,
        args: {
          'team': league.teamById(playerTeamId)?.name ?? playerTeamId,
          'opponentName': opponentName,
        },
        payload: {
          'matchId': matchId,
          'teamId': playerTeamId,
          'missingGoalkeeper': true,
        },
        dedupKey: 'lineupNoGk:$matchId:$playerTeamId',
      );
    }
    if (report.incompleteBenchTeamIds.contains(playerTeamId)) {
      state = _messages.send(
        state,
        type: MessageType.benchIncomplete,
        domain: MessageDomain.matchday,
        priority: MessagePriority.normal,
        args: {
          'missingCount': teamReport.missingBenchCount,
          'opponentName': opponentName,
          'currentBenchCount': teamReport.benchCount,
          'requiredBenchCount': teamReport.benchTarget,
        },
        payload: {
          'matchId': matchId,
          'teamId': playerTeamId,
          'missingCount': teamReport.missingBenchCount,
        },
        dedupKey: 'benchIncomplete:$matchId:$playerTeamId',
      );
    }
    return state;
  }
}
