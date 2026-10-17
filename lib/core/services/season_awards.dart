part of 'season_service.dart';

mixin _SeasonAwards on _SeasonServiceShared {
  LeagueState runAwards(LeagueState league) {
    if (league.currentSeason.awards != null) return league;

    final awards = _computeAwards(league);
    var state = league.copyWith(
      currentSeason: league.currentSeason.copyWith(awards: awards),
    );
    state = _sendAwardMessages(state, awards);
    return _messages.send(
      state,
      type: MessageType.seasonSummary,
      domain: MessageDomain.season,
      args: {
        'championTeam': awards.championTeamId == null
            ? '—'
            : _teamName(state, awards.championTeamId!),
        'mvpPlayer': _playerName(state, awards.mvpPlayerId),
        'playoffTeams': _playoffQualifiedTeamIds(state).length,
        'seasonLabel': '${state.currentSeason.year}',
        'record': _playerTeamRecord(state),
        'summary': _seasonSummaryText(state, awards),
      },
      payload: {
        'championTeamId': awards.championTeamId,
        'mvpPlayerId': awards.mvpPlayerId,
        'year': awards.year,
      },
      dedupKey: 'seasonSummary:${awards.year}',
    );
  }

  SeasonAwards _computeAwards(LeagueState league) {
    final possibleMinutes = balance.awards.possibleMinutes;
    final playersById = <String, Player>{};
    final currentTeamByPlayerId = <String, String>{};
    for (final team in league.teams) {
      for (final player in team.roster) {
        playersById[player.id] = player;
        currentTeamByPlayerId[player.id] = team.id;
      }
    }

    final candidates = <_AwardCandidate>[];
    for (final player in playersById.values) {
      candidates.add(
        _AwardCandidate(
          player: player,
          teamId: currentTeamByPlayerId[player.id],
          stats: _AwardStats.fromSeasonStats(
            player.seasonStats.firstWhere(
              (item) => item.year == league.currentSeason.year,
              orElse: () => PlayerSeasonStats(year: league.currentSeason.year),
            ),
            player.position,
          ),
        ),
      );
    }

    final mvpPool = candidates.where(
      (candidate) =>
          candidate.stats.minutes >=
          possibleMinutes * balance.awards.mvpMinutesPct,
    );
    final mvp = _bestCandidate(mvpPool, (candidate) => _mvpScore(candidate));

    final rotyPool = candidates.where(
      (candidate) =>
          candidate.player.draftYear == league.currentSeason.year - 1 &&
          candidate.stats.minutes >=
              possibleMinutes * balance.awards.rotyMinutesPct,
    );
    final roty = _bestCandidate(
      rotyPool,
      (candidate) => _mvpScore(candidate, rookie: true),
    );

    final dpoyPool = candidates.where(
      (candidate) =>
          candidate.stats.minutes >=
          possibleMinutes * balance.awards.dpoyMinutesPct,
    );
    final dpoy = _bestDefender(dpoyPool);

    final topScorer = _bestStatCandidate(
      candidates,
      (candidate) => candidate.stats.goals,
      (candidate) => candidate.stats.assists,
    );
    final topAssist = _bestStatCandidate(
      candidates,
      (candidate) => candidate.stats.assists,
      (candidate) => candidate.stats.goals,
    );

    final gkPool = candidates.where(
      (candidate) =>
          candidate.stats.gkMinutes >=
          possibleMinutes * balance.awards.bestGkMinutesPct,
    );
    final bestGk = _bestGoalkeeper(gkPool);

    final coachTeamId = _coachOfYearTeamId(league);
    final teamOfSeason = _computeTeamOfSeason(
      candidates,
      possibleMinutes: possibleMinutes,
    );

    final awardedPlayerIds = <String>{
      if (mvp != null) mvp.player.id,
      if (roty != null) roty.player.id,
      if (dpoy != null) dpoy.player.id,
      if (topScorer != null) topScorer.player.id,
      if (topAssist != null) topAssist.player.id,
      if (bestGk != null) bestGk.player.id,
      ...teamOfSeason.values,
    };
    final playerNames = <String, String>{};
    for (final playerId in awardedPlayerIds) {
      final player = playersById[playerId];
      if (player != null) playerNames[playerId] = player.name;
    }

    return SeasonAwards(
      year: league.currentSeason.year,
      mvpPlayerId: mvp?.player.id,
      rotyPlayerId: roty?.player.id,
      dpoyPlayerId: dpoy?.player.id,
      topScorerPlayerId: topScorer?.player.id,
      topAssistPlayerId: topAssist?.player.id,
      bestGkPlayerId: bestGk?.player.id,
      playerNames: playerNames,
      coachOfYearTeamId: coachTeamId,
      teamOfSeason: teamOfSeason,
      championTeamId: league.currentSeason.championTeamId,
    );
  }

  LeagueState _sendAwardMessages(LeagueState league, SeasonAwards awards) {
    var state = league;

    void sendPlayerAward(String kind, String? playerId) {
      if (playerId == null) return;
      final teamId = _teamIdForPlayer(state, playerId);
      state = _messages.send(
        state,
        type: MessageType.award,
        kind: kind,
        domain: MessageDomain.season,
        args: {
          'playerName': _playerName(state, playerId),
          'teamName': teamId == null ? '—' : _teamName(state, teamId),
          'ownClub': teamId != null && teamId == state.playerTeamId,
        },
        payload: {
          'playerId': playerId,
          'teamId': teamId,
          'ownClub': teamId != null && teamId == state.playerTeamId,
          'awardYear': awards.year,
        },
      );
    }

    sendPlayerAward('mvp', awards.mvpPlayerId);
    sendPlayerAward('roty', awards.rotyPlayerId);
    sendPlayerAward('dpoy', awards.dpoyPlayerId);
    sendPlayerAward('topScorer', awards.topScorerPlayerId);
    sendPlayerAward('topAssist', awards.topAssistPlayerId);
    sendPlayerAward('bestGk', awards.bestGkPlayerId);

    final coachTeamId = awards.coachOfYearTeamId;
    if (coachTeamId != null) {
      final coachName =
          state.teamById(coachTeamId)?.staff.headCoach?.name ??
          _teamName(state, coachTeamId);
      state = _messages.send(
        state,
        type: MessageType.award,
        kind: 'coachOfYear',
        domain: MessageDomain.season,
        args: {
          'playerName': coachName,
          'teamName': _teamName(state, coachTeamId),
          'ownClub': coachTeamId == state.playerTeamId,
        },
        payload: {
          'teamId': coachTeamId,
          'ownClub': coachTeamId == state.playerTeamId,
          'awardYear': awards.year,
        },
      );
    }

    if (awards.teamOfSeason.isNotEmpty) {
      final teamOfSeasonPlayers = awards.teamOfSeason.values.toSet();
      final teamOfSeasonOwnClub = teamOfSeasonPlayers.any(
        (playerId) => _teamIdForPlayer(state, playerId) == state.playerTeamId,
      );
      state = _messages.send(
        state,
        type: MessageType.award,
        kind: 'teamOfSeason',
        domain: MessageDomain.season,
        args: {
          'playerName': teamOfSeasonPlayers
              .map((playerId) => _playerName(state, playerId))
              .join(', '),
          'slot': '4-3-3',
          'ownClub': teamOfSeasonOwnClub,
        },
        payload: {
          'teamOfSeason': awards.teamOfSeason,
          'ownClub': teamOfSeasonOwnClub,
          'awardYear': awards.year,
        },
      );
    }

    final championTeamId = awards.championTeamId;
    if (championTeamId == null) return state;
    return _messages.send(
      state,
      type: MessageType.award,
      kind: 'champion',
      domain: MessageDomain.season,
      args: {
        'teamName': _teamName(state, championTeamId),
        'ownClub': championTeamId == state.playerTeamId,
      },
      payload: {
        'teamId': championTeamId,
        'ownClub': championTeamId == state.playerTeamId,
        'awardYear': awards.year,
      },
    );
  }

  String? _teamIdForPlayer(LeagueState league, String? playerId) {
    if (playerId == null) return null;
    for (final team in league.teams) {
      if (team.roster.any((player) => player.id == playerId)) return team.id;
    }
    return null;
  }

  _AwardCandidate? _bestCandidate(
    Iterable<_AwardCandidate> candidates,
    double Function(_AwardCandidate) score,
  ) {
    _AwardCandidate? best;
    var bestScore = double.negativeInfinity;
    for (final candidate in candidates) {
      final currentScore = score(candidate);
      if (currentScore > bestScore ||
          (currentScore == bestScore &&
              (best == null ||
                  candidate.player.id.compareTo(best.player.id) < 0))) {
        best = candidate;
        bestScore = currentScore;
      }
    }
    return best;
  }

  /// The team-points share (weight 0.35) and the postseason bonus (0.05–0.10)
  /// that used to be part of this score needed per-match player rows and are
  /// gone with them — see the note on [_AwardStats]. The surviving terms keep
  /// their relative weights, so the ranking is unchanged versus leaving the
  /// two removed terms permanently at zero. [rookie] no longer changes the
  /// score and is kept so the call sites stay honest about their intent.
  double _mvpScore(_AwardCandidate candidate, {bool rookie = false}) {
    final stats = candidate.stats;
    final production = stats.minutes == 0
        ? 0.0
        : ((stats.goals + stats.assists) * 90 / stats.minutes / 4)
              .clamp(0.0, 1.0)
              .toDouble();
    final overallNorm = ((candidate.player.overall(balance) - 50) / 49)
        .clamp(0.0, 1.0)
        .toDouble();
    return 0.25 * (stats.ratingAvg / 10).clamp(0.0, 1.0).toDouble() +
        0.20 * production +
        0.10 * overallNorm;
  }

  _AwardCandidate? _bestDefender(Iterable<_AwardCandidate> pool) {
    final candidates = pool.toList();
    if (candidates.isEmpty) return null;
    final maxDefensiveActions = candidates.fold<int>(
      0,
      (max, candidate) =>
          max > candidate.stats.tackles + candidate.stats.interceptions
          ? max
          : candidate.stats.tackles + candidate.stats.interceptions,
    );
    // The goals-conceded-while-on-the-pitch term (weight 0.15) needed
    // per-match player rows — see the note on [_AwardStats].
    return _bestCandidate(candidates, (candidate) {
      final stats = candidate.stats;
      final cleanShare = stats.appearances == 0
          ? 0.0
          : stats.cleanSheets / stats.appearances;
      final actions = maxDefensiveActions == 0
          ? 0.0
          : (stats.tackles + stats.interceptions) / maxDefensiveActions;
      return 0.40 * (stats.ratingAvg / 10).clamp(0.0, 1.0).toDouble() +
          0.25 * cleanShare +
          0.20 * actions;
    });
  }

  _AwardCandidate? _bestStatCandidate(
    Iterable<_AwardCandidate> candidates,
    int Function(_AwardCandidate) primary,
    int Function(_AwardCandidate) secondary,
  ) {
    final sorted =
        candidates.where((candidate) => primary(candidate) > 0).toList()..sort((
          a,
          b,
        ) {
          final primaryCompare = primary(b).compareTo(primary(a));
          if (primaryCompare != 0) return primaryCompare;
          final minutesCompare = a.stats.minutes.compareTo(b.stats.minutes);
          if (minutesCompare != 0) return minutesCompare;
          final secondaryCompare = secondary(b).compareTo(secondary(a));
          if (secondaryCompare != 0) return secondaryCompare;
          final ratingCompare = b.stats.ratingAvg.compareTo(a.stats.ratingAvg);
          if (ratingCompare != 0) return ratingCompare;
          return a.player.id.compareTo(b.player.id);
        });
    return sorted.isEmpty ? null : sorted.first;
  }

  _AwardCandidate? _bestGoalkeeper(Iterable<_AwardCandidate> pool) {
    final candidates = pool.toList();
    if (candidates.isEmpty) return null;
    final maxCleanSheets = candidates.fold<int>(
      0,
      (max, candidate) =>
          max > candidate.stats.cleanSheets ? max : candidate.stats.cleanSheets,
    );
    final maxGoalsPrevented = candidates.fold<double>(
      0.0,
      (max, candidate) => max > candidate.stats.goalsPrevented
          ? max
          : candidate.stats.goalsPrevented.toDouble(),
    );
    return _bestCandidate(candidates, (candidate) {
      final stats = candidate.stats;
      final savePct = stats.shotsFaced == 0
          ? 0.0
          : stats.saves / stats.shotsFaced;
      final cleanSheets = maxCleanSheets == 0
          ? 0.0
          : stats.cleanSheets / maxCleanSheets;
      final goalsPrevented = maxGoalsPrevented == 0
          ? 0.0
          : stats.goalsPrevented / maxGoalsPrevented;
      return 0.45 * savePct +
          0.25 * cleanSheets +
          0.20 * goalsPrevented +
          0.10 * (stats.ratingAvg / 10).clamp(0.0, 1.0).toDouble();
    });
  }

  Map<TeamOfSeasonSlot, String> _computeTeamOfSeason(
    Iterable<_AwardCandidate> candidates, {
    required int possibleMinutes,
  }) {
    const slotPositions = <TeamOfSeasonSlot, List<Position>>{
      TeamOfSeasonSlot.gk: [Position.gk],
      TeamOfSeasonSlot.lb: [Position.lb, Position.lwb],
      TeamOfSeasonSlot.cb1: [Position.cb],
      TeamOfSeasonSlot.cb2: [Position.cb],
      TeamOfSeasonSlot.rb: [Position.rb, Position.rwb],
      TeamOfSeasonSlot.mid1: [Position.cdm, Position.cm, Position.cam],
      TeamOfSeasonSlot.mid2: [Position.cdm, Position.cm, Position.cam],
      TeamOfSeasonSlot.mid3: [Position.cdm, Position.cm, Position.cam],
      TeamOfSeasonSlot.lw: [Position.lw],
      TeamOfSeasonSlot.st: [Position.st],
      TeamOfSeasonSlot.rw: [Position.rw],
    };
    final options = <_TeamOfSeasonOption>[];
    for (final slot in TeamOfSeasonSlot.values) {
      final positions = slotPositions[slot]!;
      for (final candidate in candidates) {
        final minutes = positions.fold<int>(
          0,
          (sum, position) =>
              sum + (candidate.stats.positionMinutes[position] ?? 0),
        );
        if (minutes < possibleMinutes * balance.awards.totsSlotMinutesPct) {
          continue;
        }
        final score = _teamOfSeasonScore(candidate, minutes);
        options.add(
          _TeamOfSeasonOption(
            slot: slot,
            playerId: candidate.player.id,
            score: score,
          ),
        );
      }
    }
    options.sort((a, b) {
      final score = b.score.compareTo(a.score);
      if (score != 0) return score;
      final slot = a.slot.index.compareTo(b.slot.index);
      if (slot != 0) return slot;
      return a.playerId.compareTo(b.playerId);
    });

    final result = <TeamOfSeasonSlot, String>{};
    final usedPlayers = <String>{};
    for (final option in options) {
      if (result.containsKey(option.slot) ||
          usedPlayers.contains(option.playerId)) {
        continue;
      }
      result[option.slot] = option.playerId;
      usedPlayers.add(option.playerId);
    }
    return result;
  }

  double _teamOfSeasonScore(_AwardCandidate candidate, int minutes) {
    final stats = candidate.stats;
    final production = minutes == 0
        ? 0.0
        : ((stats.goals + stats.assists) * 90 / minutes / 4)
              .clamp(0.0, 1.0)
              .toDouble();
    final defensive = ((stats.tackles + stats.interceptions) / 40)
        .clamp(0.0, 1.0)
        .toDouble();
    return 0.60 * (stats.ratingAvg / 10).clamp(0.0, 1.0).toDouble() +
        0.25 * production +
        0.15 * defensive;
  }

  String? _coachOfYearTeamId(LeagueState league) {
    final standings =
        [
          for (final conference in league.currentSeason.standings)
            ...conference.standings,
        ]..sort((a, b) {
          final points = b.points.compareTo(a.points);
          if (points != 0) return points;
          final difference = b.goalDifference.compareTo(a.goalDifference);
          if (difference != 0) return difference;
          final goals = b.goalsFor.compareTo(a.goalsFor);
          if (goals != 0) return goals;
          return a.teamId.compareTo(b.teamId);
        });
    final finalPositions = <String, int>{
      for (var index = 0; index < standings.length; index++)
        standings[index].teamId: index + 1,
    };

    String? bestTeamId;
    var bestScore = double.negativeInfinity;
    var bestPlace = double.negativeInfinity;
    for (final team in league.teams) {
      if (team.staff.headCoach == null) continue;
      final standing = standings.firstWhere(
        (item) => item.teamId == team.id,
        orElse: () => Standing(teamId: team.id),
      );
      final entry = league.strengthTable?.entryFor(team.id);
      final expectedRank = entry?.expectedRank ?? 15;
      final finalPosition = finalPositions[team.id] ?? 30;
      final placeVsSeed = expectedRank - finalPosition;
      final winsVsProjected =
          standing.wins - TeamManagementService.expectedWins(expectedRank);
      final score = winsVsProjected + placeVsSeed;
      if (score > bestScore ||
          (score == bestScore && placeVsSeed > bestPlace) ||
          (score == bestScore &&
              placeVsSeed == bestPlace &&
              (bestTeamId == null || team.id.compareTo(bestTeamId) < 0))) {
        bestTeamId = team.id;
        bestScore = score.toDouble();
        bestPlace = placeVsSeed.toDouble();
      }
    }
    return bestTeamId;
  }

  String _playerName(LeagueState s, String? id) {
    if (id == null) return '—';
    for (final t in s.teams) {
      for (final p in t.roster) {
        if (p.id == id) return p.name;
      }
    }
    return id;
  }

  String _playerTeamRecord(LeagueState state) {
    final teamId = state.playerTeamId;
    if (teamId == null) return '—';
    for (final conference in state.currentSeason.standings) {
      for (final standing in conference.standings) {
        if (standing.teamId == teamId) {
          return '${standing.wins}-${standing.draws}-${standing.losses}';
        }
      }
    }
    return '—';
  }

  String _seasonSummaryText(LeagueState state, SeasonAwards awards) {
    final parts = <String>[
      if (awards.championTeamId != null)
        _teamName(state, awards.championTeamId!),
      if (awards.mvpPlayerId != null) _playerName(state, awards.mvpPlayerId),
    ];
    return parts.isEmpty ? '—' : parts.join(', ');
  }
}

class _AwardCandidate {
  const _AwardCandidate({
    required this.player,
    required this.teamId,
    required this.stats,
  });

  final Player player;
  final String? teamId;
  final _AwardStats stats;
}

/// Award inputs, derived purely from the player's accumulated season row.
///
/// TODO(awards): this is a deliberately degraded stand-in. Stored fixtures no
/// longer keep per-match player rows, so metrics that needed them are gone:
/// the share of team points earned while on the pitch, the postseason bonus,
/// per-slot minutes (now attributed wholly to the natural position) and goals
/// prevented (now derived from the player's own goals rather than the goals
/// his team conceded). Rebuild these on purpose-built accumulators when the
/// awards system gets its final design.
class _AwardStats {
  _AwardStats.fromSeasonStats(PlayerSeasonStats stats, Position naturalPosition)
    : minutes = stats.minutes,
      goals = stats.goals,
      assists = stats.assists,
      appearances = stats.appearances,
      tackles = stats.tackles,
      interceptions = stats.interceptions,
      cleanSheets = stats.cleanSheets,
      saves = stats.saves,
      shotsFaced = stats.shotsFaced,
      ratingTotal = stats.ratingAvg * (stats.minutes > 0 ? stats.minutes : 1),
      ratingWeight = stats.minutes > 0 ? stats.minutes : 1,
      gkMinutes = naturalPosition == Position.gk ? stats.minutes : 0,
      goalsPrevented = (stats.shotsFaced - stats.goals).clamp(
        0,
        stats.shotsFaced,
      ),
      positionMinutes = {naturalPosition: stats.minutes};

  final int minutes;
  final int goals;
  final int assists;
  final int appearances;
  final int tackles;
  final int interceptions;
  final int cleanSheets;
  final int saves;
  final int shotsFaced;
  final int gkMinutes;
  final int goalsPrevented;
  final double ratingTotal;
  final int ratingWeight;
  final Map<Position, int> positionMinutes;

  double get ratingAvg => ratingWeight == 0 ? 0.0 : ratingTotal / ratingWeight;
}

class _TeamOfSeasonOption {
  const _TeamOfSeasonOption({
    required this.slot,
    required this.playerId,
    required this.score,
  });

  final TeamOfSeasonSlot slot;
  final String playerId;
  final double score;
}
