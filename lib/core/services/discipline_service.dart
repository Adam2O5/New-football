import 'dart:math';
import 'package:new_football/core/balance/balance_config.dart';

import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';

class DisciplineNotification {
  const DisciplineNotification({
    required this.player,
    required this.games,
    required this.reason,
    required this.playerInStartingXi,
    required this.started,
    required this.ended,
  });

  final Player player;
  final int games;
  final String reason;
  final bool playerInStartingXi;
  final bool started;
  final bool ended;
}

class DisciplineApplication {
  const DisciplineApplication({
    required this.team,
    required this.notifications,
  });

  final Team team;
  final List<DisciplineNotification> notifications;
}

/// Applies persistent disciplinary state after a completed match.
class DisciplineService {
  const DisciplineService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  DisciplineApplication applyToTeam({
    required Team team,
    required MatchResult result,
    required SeasonPhase phase,
  }) {
    final entries = <String, MatchDiscipline>{};
    for (final discipline in result.disciplines.where(
      (item) => item.teamId == team.id,
    )) {
      final previous = entries[discipline.playerId];
      if (previous == null) {
        entries[discipline.playerId] = discipline;
        continue;
      }
      entries[discipline.playerId] = previous.copyWith(
        yellowCardsInMatch:
            previous.yellowCardsInMatch + discipline.yellowCardsInMatch,
        redCardKind: _moreSevereRed(
          previous.redCardKind,
          discipline.redCardKind,
        ),
        directRedSeverity: discipline.directRedSeverity > 0
            ? discipline.directRedSeverity
            : previous.directRedSeverity,
        playerInStartingXi:
            previous.playerInStartingXi || discipline.playerInStartingXi,
      );
    }

    final notifications = <DisciplineNotification>[];
    final roster = team.roster.map((player) {
      final oldRemaining = player.state.suspensionGamesRemaining
          .clamp(0, balance.player.suspensionGamesClampMax)
          .toInt();
      final remainingAfterMatch = oldRemaining > 0 ? oldRemaining - 1 : 0;
      final discipline = entries[player.id];
      var regularYellowCards = player.state.regularSeasonYellowCards;
      var playoffYellowCards = player.state.playoffYellowCards;
      var addedGames = 0;
      var reason = '';
      var playerInStartingXi = false;

      if (discipline != null) {
        playerInStartingXi = discipline.playerInStartingXi;
        if (phase == SeasonPhase.regular) {
          regularYellowCards += discipline.yellowCardsInMatch;
          if (regularYellowCards >= balance.player.regularYellowThreshold) {
            regularYellowCards = 0;
            addedGames = balance.player.yellowSuspensionGames;
            reason = 'yellowThreshold';
          }
        } else {
          playoffYellowCards += discipline.yellowCardsInMatch;
          if (playoffYellowCards >= balance.player.playoffYellowThreshold) {
            playoffYellowCards = 0;
            addedGames = balance.player.yellowSuspensionGames;
            reason = 'playoffYellowThreshold';
          }
        }

        final redGames = switch (discipline.redCardKind) {
          RedCardKind.none => 0,
          RedCardKind.secondYellow =>
            balance.player.secondYellowSuspensionGames,
          RedCardKind.direct =>
            discipline.directRedSeverity
                .clamp(
                  balance.player.directRedSeverityThresholds.first.$2,
                  balance.player.directRedSeverityThresholds.last.$2,
                )
                .toInt(),
        };
        if (redGames > addedGames) {
          addedGames = redGames;
          reason = discipline.redCardKind == RedCardKind.direct
              ? 'directRed'
              : 'secondYellow';
        }
      }

      final newRemaining = remainingAfterMatch > addedGames
          ? remainingAfterMatch
          : addedGames;
      final started = addedGames > 0;
      final ended = oldRemaining > 0 && newRemaining == 0 && !started;
      if (started || ended) {
        notifications.add(
          DisciplineNotification(
            player: player,
            games: started ? addedGames : 0,
            reason: reason,
            playerInStartingXi: playerInStartingXi,
            started: started,
            ended: ended,
          ),
        );
      }

      return player.copyWith(
        state: player.state.copyWith(
          regularSeasonYellowCards: regularYellowCards,
          playoffYellowCards: playoffYellowCards,
          suspensionGamesRemaining: newRemaining,
        ),
      );
    }).toList();

    return DisciplineApplication(
      team: team.copyWith(roster: roster),
      notifications: notifications,
    );
  }

  static int rollDirectRedSeverity(
    Random random, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    return balance.player.directRedSeverity(random.nextDouble());
  }

  RedCardKind _moreSevereRed(RedCardKind left, RedCardKind right) {
    if (left == RedCardKind.direct || right == RedCardKind.direct) {
      return RedCardKind.direct;
    }
    if (left == RedCardKind.secondYellow || right == RedCardKind.secondYellow) {
      return RedCardKind.secondYellow;
    }
    return RedCardKind.none;
  }
}
