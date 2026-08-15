import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/trade_service.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

/// AI decision helpers (`docs/AI_behaviour.md`).
///
/// V1: jeden model AI — bez poziomów trudności i bez profili menedżera.
/// Brak biasu przeciw graczowi (§1.3).
class TeamAiService {
  TeamAiService({
    this.balance = BalanceConfig.defaults,
    Random? random,
  }) : _random = random ?? Random();

  final BalanceConfig balance;
  final Random _random;

  /// Fixed value margin for trade acceptance (AI_behaviour.md §1: no difficulty).
  static const double _valueMargin = 0.12;

  bool shouldAcceptTrade({
    required Team self,
    required Team other,
    required TradeProposal proposal,
    required TradeService tradeService,
    required int currentYear,
  }) {
    final ourValue = proposal.assetsFromB.fold<int>(
      0,
      (s, a) => s + tradeService.assetValue(other, a, currentYear: currentYear),
    );
    final theirValue = proposal.assetsFromA.fold<int>(
      0,
      (s, a) => s + tradeService.assetValue(self, a, currentYear: currentYear),
    );
    if (theirValue == 0) return ourValue > 0;

    final ratio = ourValue / theirValue;
    // V1: single acceptance threshold, no profile differentiation.
    return ratio >= 1.0 - _valueMargin * 0.5;
  }

  ContractOffer makeFaOffer(Player player, ContractService contracts) {
    final want = contracts.playerWant(player);
    final mult = 0.95 + _random.nextDouble() * 0.15;
    return ContractOffer(
      salary: (want * mult).round().clamp(
        balance.salaryCap.minSalary,
        balance.salaryCap.maxSalary,
      ),
      years: 2 + _random.nextInt(3),
    );
  }

  /// Pick best available GK + top outfielders by overall for lineup.
  Team autoSelectLineup(Team team) {
    final available = team.availablePlayers.toList()
      ..sort((a, b) => b.overall(balance).compareTo(a.overall(balance)));
    final gk = available.where((p) => p.position == Position.gk).toList();
    final outfield = available.where((p) => p.position != Position.gk).toList();

    final xi = <Player>[];
    if (gk.isNotEmpty) xi.add(gk.first);
    xi.addAll(outfield.take(10));
    while (xi.length < 11 && outfield.length + gk.length > xi.length) {
      final rest = available.where((p) => !xi.contains(p)).toList();
      if (rest.isEmpty) break;
      xi.add(rest.first);
    }

    final used = xi.map((p) => p.id).toSet();
    final bench = available
        .where((p) => !used.contains(p.id))
        .take(balance.roster.benchSize)
        .map((p) => p.id)
        .toList();

    return team.copyWith(
      lineupPlayerIds: xi.map((p) => p.id).toList(),
      benchPlayerIds: bench,
    );
  }

  TacticsSetup counterTactics(TacticsSetup opponent) {
    // V1: always attempt counter-formation from matchup table.
    for (final m in balance.tactics.formationMatchups) {
      if (m.formationB == opponent.formation) {
        return TacticsSetup(
          formation: m.formationA,
          pressing: PressingIntensity.high,
          defensiveLine: DefensiveLine.high,
        );
      }
    }
    return TacticsSetup(
      formation: opponent.formation == Formation.f433
          ? Formation.f442
          : Formation.f433,
      pressing: PressingIntensity.high,
    );
  }
}
