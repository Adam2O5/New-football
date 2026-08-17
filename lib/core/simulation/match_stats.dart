import 'dart:convert';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/sequence_chain_resolver.dart';
import 'package:new_football/core/simulation/sequence_resolver.dart';
import 'package:new_football/core/simulation/shot_models.dart';

/// Converts one completed simulation into the persisted match contract.
///
/// All values are collected from the runtime trace, events and stamina maps.
/// In particular, this class deliberately does not recreate shots, xG or
/// possession from the final score.
class MatchResultAssembler {
  const MatchResultAssembler({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  MatchResult assemble({
    required Team home,
    required Team away,
    required SimulationLiveMatch live,
    required SimulationResult simulation,
  }) {
    final administrative = live.legacyMatch.administrativeResult;
    if (administrative != null) return administrative;

    final players = live.legacyMatch.playersById;
    final teamByPlayerId = live.legacyMatch.teamByPlayerId;
    final totals = <String, _PlayerTotals>{
      for (final player in players.values)
        player.id: _PlayerTotals(
          playerId: player.id,
          teamId: teamByPlayerId[player.id] ?? away.id,
          minutes: live.legacyMatch.minutesPlayed[player.id] ?? 0,
          staminaAfterMatch: live.legacyMatch.visibleStamina(player),
        ),
    };

    void forPlayer(String? playerId, void Function(_PlayerTotals) apply) {
      if (playerId == null) return;
      final total = totals[playerId];
      if (total != null) apply(total);
    }

    for (final event in simulation.events) {
      final description = (event.description ?? '').toLowerCase();
      final ownGoal = description.contains('samobój');
      forPlayer(event.playerId, (total) {
        switch (event.type) {
          case MatchEventType.goal:
          case MatchEventType.scoredPenalty:
            if (ownGoal) {
              total.ownGoals++;
            } else {
              total.goals++;
            }
          case MatchEventType.yellowCard:
            total.yellowCards++;
          case MatchEventType.redCard:
            total.redCards++;
          default:
            break;
        }
      });
    }

    for (final discipline in simulation.disciplines) {
      final total = totals[discipline.playerId];
      if (total == null) continue;
      total.yellowCards = total.yellowCards < discipline.yellowCardsInMatch
          ? discipline.yellowCardsInMatch
          : total.yellowCards;
      if (discipline.redCardKind != RedCardKind.none) total.redCards = 1;
    }

    for (final trace in simulation.minuteTraces) {
      for (final sequence in trace.sequences) {
        final chain = sequence.chain;
        if (chain != null) {
          for (final duel in chain.duels) {
            if (duel.attackerWon) {
              forPlayer(duel.attackerId, (total) {
                total.duelsWon++;
                total.offensiveDuelsWon++;
              });
            } else {
              forPlayer(duel.defenderId, (total) {
                total.duelsWon++;
                total.defensiveDuelsWon++;
              });
            }
          }
        }

        final shot = sequence.shot;
        if (shot != null && shot.isShot) {
          forPlayer(shot.shooterId, (total) {
            total.shots++;
            total.xg += shot.xg;
            if (shot.isOnTarget) total.shotsOnTarget++;
            if (shot.reboundAttempted) {
              total.shots++;
              total.xg += shot.reboundXg;
              if (shot.reboundGoal) total.shotsOnTarget++;
            }
            if (!shot.isGoal && shot.xg > 0.4) {
              total.missedBigChances++;
            }
          });

          final goalkeeper = totals[shot.goalkeeperId];
          if (goalkeeper != null) {
            goalkeeper.shotsFaced++;
            if (shot.outcome == ShotOutcome.saved) {
              goalkeeper.saves++;
            }
            if (sequence.setPiece?.type == SetPieceType.penalty &&
                shot.outcome == ShotOutcome.saved) {
              goalkeeper.penaltySaves++;
            }
          }
        }

        if (sequence.setPiece?.type == SetPieceType.corner) {
          forPlayer(sequence.setPiece?.shooterId, (total) {
            total.corners++;
          });
        }

        if (sequence.type != SequenceType.setPiece && chain != null) {
          final passerId = chain.duels.length > 1
              ? chain.duels[chain.duels.length - 2].attackerId
              : sequence.attackerId;
          final passer = totals[passerId];
          if (passer != null) {
            passer.passAttempts++;
            if (chain.longBallPassed && chain.wonDuels > 0) {
              passer.passes++;
            }
          }

          if (shot?.isGoal == true &&
              passerId != shot!.shooterId &&
              chain.longBallPassed &&
              chain.wonDuels > 0) {
            forPlayer(passerId, (total) => total.assists++);
          }

          if (shot?.isGoal == true) {
            SequenceDuelTrace? losingDuel;
            for (final duel in chain.duels.reversed) {
              if (!duel.attackerWon) {
                losingDuel = duel;
                break;
              }
            }
            if (losingDuel != null) {
              forPlayer(
                losingDuel.defenderId,
                (total) => total.defensiveDuelLossesLeadingToGoal++,
              );
            }
          }
        }
      }
    }

    final homeGoals = simulation.homeGoals;
    final awayGoals = simulation.awayGoals;
    final playerStats = [
      for (final player in players.values)
        _toPlayerStats(
          player,
          totals[player.id]!,
          teamConceded: (teamByPlayerId[player.id] == home.id)
              ? awayGoals
              : homeGoals,
        ),
    ];
    final manOfTheMatch = _manOfTheMatch(playerStats);
    final inspired =
        manOfTheMatch == null ||
            MatchRandom(
                  _stableSeed(simulation.seed, manOfTheMatch),
                ).nextDouble() >=
                balance.events.inspiringPerformanceChance
        ? null
        : manOfTheMatch.playerId;

    return MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      homeStats: _teamStats(
        teamId: home.id,
        goals: homeGoals,
        shots: simulation.homeShots,
        shotsOnTarget: simulation.homeShotsOnTarget,
        possession: simulation.homePossessionPercent,
        xg: simulation.homeXg,
        corners: simulation.homeCorners,
        fouls: simulation.homeFouls,
        disciplines: simulation.disciplines,
        totals: totals,
      ),
      awayStats: _teamStats(
        teamId: away.id,
        goals: awayGoals,
        shots: simulation.awayShots,
        shotsOnTarget: simulation.awayShotsOnTarget,
        possession: simulation.awayPossessionPercent,
        xg: simulation.awayXg,
        corners: simulation.awayCorners,
        fouls: simulation.awayFouls,
        disciplines: simulation.disciplines,
        totals: totals,
      ),
      context: simulation.context,
      homeTactics: live.state.homeTactics,
      awayTactics: live.state.awayTactics,
      homeLineup: live.legacyMatch.homeStartingLineup,
      awayLineup: live.legacyMatch.awayStartingLineup,
      homeLineupPositions:
          live.legacyMatch.homeSnapshot?.assignedPositions ?? const [],
      awayLineupPositions:
          live.legacyMatch.awaySnapshot?.assignedPositions ?? const [],
      homeSnapshot: live.legacyMatch.homeSnapshot ?? const MatchTeamSnapshot(),
      awaySnapshot: live.legacyMatch.awaySnapshot ?? const MatchTeamSnapshot(),
      noGkPenalty: simulation.homeNoGkPenalty || simulation.awayNoGkPenalty,
      noGkPenaltyTeamIds: [
        if (simulation.homeNoGkPenalty) home.id,
        if (simulation.awayNoGkPenalty) away.id,
      ],
      playerStats: playerStats,
      events: simulation.events,
      injuries: simulation.injuries,
      disciplines: simulation.disciplines,
      manOfTheMatchPlayerId: manOfTheMatch?.playerId,
      inspiredPerformancePlayerId: inspired,
      matchEndMinute: simulation.matchEndMinute,
      stoppageTime: simulation.stoppageTime,
    );
  }

  PlayerMatchStats _toPlayerStats(
    Player player,
    _PlayerTotals total, {
    required int teamConceded,
  }) {
    final minutes = total.minutes;
    var contribution = 0.0;
    for (var i = 0; i < total.goals; i++) {
      contribution += _goalContribution(player.position);
    }
    contribution += total.assists * 0.7;
    contribution += total.offensiveDuelsWon * 0.05;
    contribution += total.defensiveDuelsWon * 0.06;
    contribution -= total.defensiveDuelLossesLeadingToGoal * 0.45;
    contribution += total.saves * 0.10;
    contribution += total.penaltySaves * 1.2;
    if (_isDefenderOrGoalkeeper(player.position) &&
        minutes >= 60 &&
        teamConceded == 0) {
      contribution += 0.6;
    }
    contribution -= total.ownGoals * 1.5;
    contribution -= total.yellowCards * 0.3;
    contribution -= total.redCards * 1.5;
    contribution -= total.missedBigChances * 0.25;
    if (minutes > 0 && minutes < 20) contribution *= minutes / 20.0;

    final rating = minutes == 0
        ? 6.0
        : (6.0 + contribution).clamp(1.0, 10.0).toDouble();
    return PlayerMatchStats(
      playerId: player.id,
      minutes: minutes,
      goals: total.goals,
      assists: total.assists,
      shots: total.shots,
      shotsOnTarget: total.shotsOnTarget,
      xg: total.xg,
      passes: total.passAttempts,
      passAccuracy: total.passAttempts == 0
          ? 0.0
          : total.passes / total.passAttempts * 100.0,
      duelsWon: total.duelsWon,
      offsides: total.offsides,
      corners: total.corners,
      yellowCards: total.yellowCards,
      redCards: total.redCards,
      saves: total.saves,
      shotsFaced: total.shotsFaced,
      ownGoals: total.ownGoals,
      cleanSheet:
          _isDefenderOrGoalkeeper(player.position) &&
          minutes >= 60 &&
          teamConceded == 0,
      staminaAfterMatch: total.staminaAfterMatch,
      tackles: total.defensiveDuelsWon,
      interceptions: total.defensiveDuelsWon,
      rating: rating,
    );
  }

  TeamMatchStats _teamStats({
    required String teamId,
    required int goals,
    required int shots,
    required int shotsOnTarget,
    required double possession,
    required double xg,
    required int corners,
    required int fouls,
    required List<MatchDiscipline> disciplines,
    required Map<String, _PlayerTotals> totals,
  }) {
    final players = totals.values.where((total) => total.teamId == teamId);
    var passAttempts = 0;
    var completedPasses = 0;
    var duelsWon = 0;
    var offsides = 0;
    var saves = 0;
    for (final total in players) {
      passAttempts += total.passAttempts;
      completedPasses += total.passes;
      duelsWon += total.duelsWon;
      offsides += total.offsides;
      saves += total.saves;
    }
    final yellowCards = disciplines
        .where((item) => item.teamId == teamId)
        .fold<int>(0, (sum, item) => sum + item.yellowCardsInMatch);
    final redCards = disciplines
        .where(
          (item) =>
              item.teamId == teamId && item.redCardKind != RedCardKind.none,
        )
        .length;
    return TeamMatchStats(
      teamId: teamId,
      goals: goals,
      shots: shots,
      shotsOnTarget: shotsOnTarget,
      possession: possession.round(),
      xg: xg,
      passes: passAttempts,
      passAccuracy: passAttempts == 0
          ? 0.0
          : completedPasses / passAttempts * 100.0,
      duelsWon: duelsWon,
      offsides: offsides,
      corners: corners,
      fouls: fouls,
      yellowCards: yellowCards,
      redCards: redCards,
      saves: saves,
    );
  }

  PlayerMatchStats? _manOfTheMatch(List<PlayerMatchStats> stats) {
    final eligible =
        stats
            .where(
              (stat) =>
                  stat.minutes > 0 &&
                  stat.rating >= balance.events.inspiringPerformanceRatingMin,
            )
            .toList()
          ..sort((a, b) {
            final rating = b.rating.compareTo(a.rating);
            if (rating != 0) return rating;
            return a.playerId.compareTo(b.playerId);
          });
    return eligible.isEmpty ? null : eligible.first;
  }

  double _goalContribution(Position position) => switch (position) {
    Position.st || Position.lw || Position.rw => 1.0,
    Position.cdm || Position.cm || Position.cam => 1.3,
    _ => 1.6,
  };

  bool _isDefenderOrGoalkeeper(Position position) => switch (position) {
    Position.gk ||
    Position.cb ||
    Position.lb ||
    Position.rb ||
    Position.lwb ||
    Position.rwb => true,
    _ => false,
  };

  int _stableSeed(int seed, PlayerMatchStats stats) {
    var hash = 2166136261;
    for (final byte in utf8.encode(stats.playerId)) {
      hash = ((hash ^ byte) * 16777619) & 0x7fffffff;
    }
    return seed ^ hash;
  }
}

class _PlayerTotals {
  _PlayerTotals({
    required this.playerId,
    required this.teamId,
    required this.minutes,
    required this.staminaAfterMatch,
  });

  final String playerId;
  final String teamId;
  final int minutes;
  final int staminaAfterMatch;
  int goals = 0;
  int assists = 0;
  int shots = 0;
  int shotsOnTarget = 0;
  double xg = 0.0;
  int passAttempts = 0;
  int passes = 0;
  int duelsWon = 0;
  int offensiveDuelsWon = 0;
  int defensiveDuelsWon = 0;
  int defensiveDuelLossesLeadingToGoal = 0;
  int offsides = 0;
  int corners = 0;
  int yellowCards = 0;
  int redCards = 0;
  int saves = 0;
  int shotsFaced = 0;
  int penaltySaves = 0;
  int ownGoals = 0;
  int missedBigChances = 0;
}
