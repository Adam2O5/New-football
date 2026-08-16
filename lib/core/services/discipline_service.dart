import 'dart:math';

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
  const DisciplineService();

  static const regularYellowThreshold = 5;
  static const playoffYellowThreshold = 3;

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
          .clamp(0, 100)
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
          if (regularYellowCards >= regularYellowThreshold) {
            regularYellowCards = 0;
            addedGames = 1;
            reason = 'yellowThreshold';
          }
        } else {
          playoffYellowCards += discipline.yellowCardsInMatch;
          if (playoffYellowCards >= playoffYellowThreshold) {
            playoffYellowCards = 0;
            addedGames = 1;
            reason = 'playoffYellowThreshold';
          }
        }

        final redGames = switch (discipline.redCardKind) {
          RedCardKind.none => 0,
          RedCardKind.secondYellow => 1,
          RedCardKind.direct =>
            discipline.directRedSeverity.clamp(1, 3).toInt(),
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

  static int rollDirectRedSeverity(Random random) {
    final roll = random.nextDouble();
    if (roll < 0.60) return 1;
    if (roll < 0.90) return 2;
    return 3;
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
