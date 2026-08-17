import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/team.dart';

/// One player's result from the weekly development tick.
class DevelopmentChange {
  const DevelopmentChange({
    required this.playerId,
    required this.playerName,
    required this.oldOverall,
    required this.newOverall,
    required this.progressDelta,
    required this.growthRate,
  });

  final String playerId;
  final String playerName;
  final double oldOverall;
  final double newOverall;
  final double progressDelta;
  final double growthRate;

  int get ovrDelta => newOverall.round() - oldOverall.round();
}

/// Updated team plus the changes produced by its weekly development tick.
class DevelopmentTickResult {
  const DevelopmentTickResult({required this.team, required this.changes});

  final Team team;
  final List<DevelopmentChange> changes;
}

/// Weekly player development tick (`docs/player_management.md`).
class DevelopmentService {
  DevelopmentService({this.balance = BalanceConfig.defaults, Random? random});

  final BalanceConfig balance;

  /// Backwards-compatible team-only API for existing callers.
  Team developTeam(Team team) => developTeamWithReport(team).team;

  DevelopmentTickResult developTeamWithReport(Team team) {
    final headCoachStars = team.staff.headCoach?.attributes.development ?? 0.0;
    final youthCoachStars =
        team.staff.youthCoach?.attributes.development ?? 0.0;
    final youthMentoring = team.staff.youthCoach?.attributes.mentoring;

    final changes = <DevelopmentChange>[];
    final roster = team.roster.map((player) {
      final result = developPlayerWithContext(
        player,
        headCoachStars: headCoachStars,
        youthCoachStars: youthCoachStars,
        youthMentoring: youthMentoring,
        atmosphere: team.atmosphere,
      );
      changes.add(result.change);
      return result.player;
    }).toList();

    return DevelopmentTickResult(
      team: team.copyWith(roster: roster),
      changes: changes,
    );
  }

  /// Compatibility entry point retained for tests and older call sites.
  Player developPlayer(Player player, {double staffMultiplier = 1.0}) {
    final result = developPlayerWithContext(player, atmosphere: 50);
    if (staffMultiplier == 1.0) return result.player;
    final rate = (result.player.hidden.growthRate * staffMultiplier).clamp(
      balance.development.growthRateMin,
      balance.development.growthRateMax,
    );
    return result.player.copyWith(
      hidden: result.player.hidden.copyWith(growthRate: rate.toDouble()),
    );
  }

  ({Player player, DevelopmentChange change}) developPlayerWithContext(
    Player player, {
    double? headCoachStars,
    double? youthCoachStars,
    double? youthMentoring,
    required int atmosphere,
  }) {
    final oldOverall = player.overall(balance);
    final rate = calculateGrowthRate(
      player,
      headCoachStars: headCoachStars,
      youthCoachStars: youthCoachStars,
      youthMentoring: youthMentoring,
      atmosphere: atmosphere,
    );
    final progressDelta = balance.development.progressFor(rate);
    var progress = player.hidden.overallProgress + progressDelta;
    var attributes = player.attributes;
    var appliedOvrDelta = 0;

    if (progress >= 100.0) {
      if (oldOverall < player.developmentCeilingOvr(balance)) {
        attributes = _changeAllAttributes(attributes, 1);
        appliedOvrDelta = 1;
        progress = 0.0;
      } else {
        // The career outcome is a real ceiling: progress cannot create an
        // attribute increase after the player reaches it.
        progress = 99.0;
      }
    } else if (progress < 0.0) {
      attributes = _changeAllAttributes(attributes, -1);
      appliedOvrDelta = -1;
      progress = 99.0;
    } else {
      progress = progress.clamp(0.0, 99.999999).toDouble();
    }

    final next = player
        .copyWith(
          attributes: attributes,
          hidden: player.hidden.copyWith(
            overallProgress: progress,
            growthRate: rate,
          ),
          state: player.state.copyWith(
            minutesThisWeek: 0,
            lastDevelopmentOvrDelta: appliedOvrDelta,
            lastDevelopmentProgressDelta: progressDelta,
          ),
        )
        .recalculatePointValue(balance);
    final newOverall = next.overall(balance);

    return (
      player: next,
      change: DevelopmentChange(
        playerId: player.id,
        playerName: player.name,
        oldOverall: oldOverall,
        newOverall: newOverall,
        progressDelta: progressDelta,
        growthRate: rate,
      ),
    );
  }

  double calculateGrowthRate(
    Player player, {
    double? headCoachStars,
    double? youthCoachStars,
    double? youthMentoring,
    required int atmosphere,
  }) {
    final b = balance.development;
    var rate = b.baseGrowthRateFor(player.hidden.determination);
    rate += b.formBonusFor(player.state.form);
    rate += b.ageBonusFor(player.age);
    rate += player.state.minutesThisWeek * 0.01;

    final staffStars = player.age <= b.developmentAgeMax
        ? (youthCoachStars ?? headCoachStars ?? 0.0)
        : (headCoachStars ?? 0.0);
    rate += b.staffDevelopmentBonusFor(staffStars);
    rate += b.atmosphereBonusFor(atmosphere);

    if (player.age <= b.developmentAgeMax && youthMentoring != null) {
      rate *= 1.0 + b.staffDevelopmentBonusFor(youthMentoring);
    }
    if (player.personality == PlayerPersonality.ambitious) rate *= 1.10;
    // Individual event modifiers are additive and must be applied before the
    // documented growth-rate clamp.
    rate += player.state.eventState.modifierValue('growthRate');
    rate += player.state.eventState.modifierValue('personalProblemsGrowth');
    if (player.state.injured) rate = min(rate, 0.0);

    return rate.clamp(b.growthRateMin, b.growthRateMax).toDouble();
  }

  PlayerAttributes _changeAllAttributes(
    PlayerAttributes attributes,
    int delta,
  ) {
    int clamp(int value) => (value + delta).clamp(50, 99);
    return attributes.map(
      outfield: (outfield) => PlayerAttributes.outfield(
        stats: outfield.stats.copyWith(
          pace: clamp(outfield.stats.pace),
          shooting: clamp(outfield.stats.shooting),
          passing: clamp(outfield.stats.passing),
          dribbling: clamp(outfield.stats.dribbling),
          defending: clamp(outfield.stats.defending),
          physicality: clamp(outfield.stats.physicality),
        ),
      ),
      goalkeeper: (goalkeeper) => PlayerAttributes.goalkeeper(
        stats: goalkeeper.stats.copyWith(
          diving: clamp(goalkeeper.stats.diving),
          handling: clamp(goalkeeper.stats.handling),
          kicking: clamp(goalkeeper.stats.kicking),
          reflexes: clamp(goalkeeper.stats.reflexes),
          speed: clamp(goalkeeper.stats.speed),
          positioning: clamp(goalkeeper.stats.positioning),
        ),
      ),
    );
  }
}
