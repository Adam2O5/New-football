import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/team.dart';

/// Weekly player development tick (`docs/player_management.md`).
class DevelopmentService {
  DevelopmentService({this.balance = BalanceConfig.defaults, Random? random})
    : _random = random ?? Random();

  final BalanceConfig balance;
  final Random _random;

  Team developTeam(Team team) {
    // Head Coach lifts development for the whole squad; Youth Coach adds a
    // further boost for young players (`docs/staff_rules.md` §4).
    final hcStars = team.staff.headCoach?.attributes.development ?? 0.0;
    final youthStars = team.staff.youthCoach?.attributes.development ?? 0.0;
    final youthMaxAge = balance.staff.youthCoachMaxAge;
    return team.copyWith(
      roster: team.roster.map((p) {
        final staffStars = p.age <= youthMaxAge
            ? hcStars * 0.4 + youthStars * 0.6
            : hcStars;
        final multiplier = 1.0 + staffStars * 0.06;
        return developPlayer(p, staffMultiplier: multiplier);
      }).toList(),
    );
  }

  Player developPlayer(Player player, {double staffMultiplier = 1.0}) {
    final b = balance.development;
    final age = player.age;
    final growthRate = player.state.injury?.isActive == true
        ? min(player.hidden.growthRate, 0.0)
        : player.hidden.growthRate;
    double delta;
    if (age <= b.developmentAgeMax) {
      delta = 0.4 * growthRate;
    } else if (age <= b.plateauAgeMax) {
      delta = 0.4 * growthRate * b.plateauGrowthMult;
    } else {
      delta = -0.25 * (1.0 + (age - b.declineAgeMin) * 0.05);
    }
    if (delta > 0) delta *= staffMultiplier;

    delta *= switch (player.hidden.developmentOutcome) {
      DevelopmentOutcome.exceed => 1.35,
      DevelopmentOutcome.hit => 1.0,
      DevelopmentOutcome.under => 0.65,
    };

    final progress = (player.hidden.overallProgress + delta)
        .clamp(0.0, 99.0)
        .round();
    var attrs = player.attributes;
    if (delta > 0 && _random.nextDouble() < (delta / 25).clamp(0.0, 0.35)) {
      attrs = _nudgeAttributes(attrs, 1);
    } else if (delta < 0 &&
        _random.nextDouble() < ((-delta) / 20).clamp(0.0, 0.4)) {
      attrs = _nudgeAttributes(attrs, -1);
    }

    return player.copyWith(
      attributes: attrs,
      hidden: player.hidden.copyWith(overallProgress: progress),
    );
  }

  PlayerAttributes _nudgeAttributes(PlayerAttributes attrs, int delta) {
    return attrs.map(
      outfield: (o) {
        final s = o.stats;
        int clamp(int v) => (v + delta).clamp(50, 99);
        final pick = _random.nextInt(6);
        final next = switch (pick) {
          0 => s.copyWith(pace: clamp(s.pace)),
          1 => s.copyWith(shooting: clamp(s.shooting)),
          2 => s.copyWith(passing: clamp(s.passing)),
          3 => s.copyWith(dribbling: clamp(s.dribbling)),
          4 => s.copyWith(defending: clamp(s.defending)),
          _ => s.copyWith(physicality: clamp(s.physicality)),
        };
        return PlayerAttributes.outfield(stats: next);
      },
      goalkeeper: (g) {
        final s = g.stats;
        int clamp(int v) => (v + delta).clamp(50, 99);
        final pick = _random.nextInt(6);
        final next = switch (pick) {
          0 => s.copyWith(diving: clamp(s.diving)),
          1 => s.copyWith(handling: clamp(s.handling)),
          2 => s.copyWith(kicking: clamp(s.kicking)),
          3 => s.copyWith(reflexes: clamp(s.reflexes)),
          4 => s.copyWith(speed: clamp(s.speed)),
          _ => s.copyWith(positioning: clamp(s.positioning)),
        };
        return PlayerAttributes.goalkeeper(stats: next);
      },
    );
  }
}
