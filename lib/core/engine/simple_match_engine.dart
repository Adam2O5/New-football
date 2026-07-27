import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';

/// Lightweight match engine v0: strength + RNG, no minute loop.
class SimpleMatchEngine {
  const SimpleMatchEngine({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  MatchResult simulate({
    required Team home,
    required Team away,
    int? seed,
  }) {
    final walkover = _checkWalkover(home, away);
    if (walkover != null) return walkover;

    final noGk = _checkNoGk(home, away);
    if (noGk != null) return noGk;

    final rng = Random(seed ?? Object.hash(home.id, away.id, DateTime.now()));
    final homeStr = _effectiveStrength(home);
    final awayStr = _effectiveStrength(away);
    final homeAdv = 1.05;
    final homeExp = (homeStr * homeAdv) / 28.0;
    final awayExp = awayStr / 28.0;

    final homeGoals = _poisson(rng, homeExp).clamp(0, 8);
    final awayGoals = _poisson(rng, awayExp).clamp(0, 8);

    return MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      homeStats: TeamMatchStats(
        teamId: home.id,
        goals: homeGoals,
        shots: homeGoals + rng.nextInt(8) + 3,
        shotsOnTarget: homeGoals + rng.nextInt(4),
        possession: 45 + rng.nextInt(11),
        xg: homeExp,
      ),
      awayStats: TeamMatchStats(
        teamId: away.id,
        goals: awayGoals,
        shots: awayGoals + rng.nextInt(8) + 3,
        shotsOnTarget: awayGoals + rng.nextInt(4),
        possession: 55 - (45 + rng.nextInt(11) - 45),
        xg: awayExp,
      ),
      events: [
        MatchEvent(
          type: MatchEventType.fullTime,
          minute: 90,
          teamId: home.id,
          description: 'Koniec meczu $homeGoals:$awayGoals',
        ),
      ],
    );
  }

  double _effectiveStrength(Team team) {
    final xi = team.startingEleven;
    if (xi.isEmpty) return 40;
    final ovr =
        xi.map((p) => p.overall(balance)).reduce((a, b) => a + b) / xi.length;
    final form =
        xi.map((p) => p.state.form).reduce((a, b) => a + b) / xi.length;
    return ovr * (0.85 + form / 50);
  }

  MatchResult? _checkWalkover(Team home, Team away) {
    final homeIllegal = !_legalRoster(home);
    final awayIllegal = !_legalRoster(away);
    if (!homeIllegal && !awayIllegal) return null;

    final b = balance.matchday;
    if (homeIllegal && awayIllegal) {
      return MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: 0,
        awayGoals: 0,
        homeStats: TeamMatchStats(teamId: home.id),
        awayStats: TeamMatchStats(teamId: away.id),
        events: [
          MatchEvent(
            type: MatchEventType.fullTime,
            minute: 0,
            teamId: home.id,
            description: 'Obie drużyny — nielegalny roster (walkower 0:0)',
          ),
        ],
      );
    }
    if (homeIllegal) {
      return MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: b.walkoverGoalsFor,
        awayGoals: b.walkoverGoalsAgainst,
        homeStats: TeamMatchStats(
          teamId: home.id,
          goals: b.walkoverGoalsFor,
        ),
        awayStats: TeamMatchStats(
          teamId: away.id,
          goals: b.walkoverGoalsAgainst,
        ),
        events: [
          MatchEvent(
            type: MatchEventType.fullTime,
            minute: 0,
            teamId: home.id,
            description: 'Walkower — nielegalny roster gospodarzy',
          ),
        ],
      );
    }
    return MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: b.walkoverGoalsAgainst,
      awayGoals: b.walkoverGoalsFor,
      homeStats: TeamMatchStats(
        teamId: home.id,
        goals: b.walkoverGoalsAgainst,
      ),
      awayStats: TeamMatchStats(
        teamId: away.id,
        goals: b.walkoverGoalsFor,
      ),
      events: [
        MatchEvent(
          type: MatchEventType.fullTime,
          minute: 0,
          teamId: away.id,
          description: 'Walkower — nielegalny roster gości',
        ),
      ],
    );
  }

  MatchResult? _checkNoGk(Team home, Team away) {
    final homeHasGk = _hasGkInXi(home);
    final awayHasGk = _hasGkInXi(away);
    if (homeHasGk && awayHasGk) return null;

    final b = balance.matchday;
    if (!homeHasGk && !awayHasGk) {
      return MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: 0,
        awayGoals: 0,
        homeStats: TeamMatchStats(teamId: home.id),
        awayStats: TeamMatchStats(teamId: away.id),
        events: [
          MatchEvent(
            type: MatchEventType.fullTime,
            minute: 0,
            teamId: home.id,
            description: 'Obie drużyny bez bramkarza — 0:0',
          ),
        ],
      );
    }
    if (!homeHasGk) {
      return MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: b.noGkGoalsFor,
        awayGoals: b.noGkGoalsAgainst,
        homeStats: TeamMatchStats(teamId: home.id, goals: b.noGkGoalsFor),
        awayStats: TeamMatchStats(teamId: away.id, goals: b.noGkGoalsAgainst),
        events: [
          MatchEvent(
            type: MatchEventType.fullTime,
            minute: 0,
            teamId: home.id,
            description: 'Brak bramkarza gospodarzy — kara wyniku',
          ),
        ],
      );
    }
    return MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: b.noGkGoalsAgainst,
      awayGoals: b.noGkGoalsFor,
      homeStats: TeamMatchStats(teamId: home.id, goals: b.noGkGoalsAgainst),
      awayStats: TeamMatchStats(teamId: away.id, goals: b.noGkGoalsFor),
      events: [
        MatchEvent(
          type: MatchEventType.fullTime,
          minute: 0,
          teamId: away.id,
          description: 'Brak bramkarza gości — kara wyniku',
        ),
      ],
    );
  }

  bool _legalRoster(Team team) {
    final size = team.roster.length;
    return size >= balance.roster.minSize && size <= balance.roster.maxSize;
  }

  bool _hasGkInXi(Team team) {
    final xi = team.startingEleven;
    if (xi.isEmpty) return false;
    return xi.first.position == Position.gk ||
        xi.any((p) => p.position == Position.gk);
  }

  int _poisson(Random rng, double lambda) {
    // Knuth for small lambda.
    final l = exp(-lambda);
    var k = 0;
    var p = 1.0;
    do {
      k++;
      p *= rng.nextDouble();
    } while (p > l);
    return k - 1;
  }
}
