import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';

/// Rolls career soft-cap path from [determination] (`player_management.md` §5).
///
/// Called when a [Player] is created (seed / roster) or when a prospect becomes
/// a player after draft / FA sign — never stored on [Prospect].
DevelopmentOutcome rollDevelopmentOutcome(
  int determination,
  Random rng, [
  BalanceConfig balance = BalanceConfig.defaults,
]) {
  final (exceedPct, hitPct) = balance.development.outcomeChancesFor(
    determination,
  );
  final roll = rng.nextInt(100);
  if (roll < exceedPct) return DevelopmentOutcome.exceed;
  if (roll < exceedPct + hitPct) return DevelopmentOutcome.hit;
  return DevelopmentOutcome.under;
}

/// Rolls the real development ceiling once when a player is created.
double rollDevelopmentCeilingStars(
  double potentialStars,
  DevelopmentOutcome outcome,
  Random rng, [
  BalanceConfig balance = BalanceConfig.defaults,
]) {
  final b = balance.development;
  final offset = switch (outcome) {
    DevelopmentOutcome.exceed =>
      rng.nextDouble() < b.exceedSmallOffsetChance
          ? b.exceedSmallOffset
          : b.exceedLargeOffset,
    DevelopmentOutcome.hit => 0.0,
    DevelopmentOutcome.under =>
      rng.nextDouble() < b.underSmallOffsetChance
          ? b.underSmallOffset
          : b.underLargeOffset,
  };
  return (potentialStars + offset)
      .clamp(balance.player.potentialMin, balance.player.potentialMax)
      .toDouble();
}
