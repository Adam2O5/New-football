import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/trade_service.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

/// AI decision helpers (`docs/AI_behaviour.md`).
class TeamAiService {
  TeamAiService({
    this.balance = BalanceConfig.defaults,
    this.difficulty = Difficulty.normal,
    Random? random,
  }) : _random = random ?? Random();

  final BalanceConfig balance;
  final Difficulty difficulty;
  final Random _random;

  double get _valueMargin => difficulty == Difficulty.hard ? 0.20 : 0.12;

  bool shouldAcceptTrade({
    required Team self,
    required Team other,
    required TradeProposal proposal,
    required TradeService tradeService,
  }) {
    final profile = self.ai?.managerProfile ?? ManagerProfile.balanced;
    final ourValue = proposal.assetsFromB.fold<int>(
      0,
      (s, a) => s + tradeService.assetValue(other, a),
    );
    final theirValue = proposal.assetsFromA.fold<int>(
      0,
      (s, a) => s + tradeService.assetValue(self, a),
    );
    if (theirValue == 0) return ourValue > 0;

    final ratio = ourValue / theirValue;
    final need = switch (profile) {
      ManagerProfile.cautious => 1.0 + _valueMargin,
      ManagerProfile.balanced => 1.0,
      ManagerProfile.aggressive => 1.0 - _valueMargin * 0.5,
    };

    if (difficulty == Difficulty.hard && _isRival(self, other)) {
      return ratio >= need + 0.15;
    }
    return ratio >= need;
  }

  ContractOffer makeFaOffer(Player player, ContractService contracts) {
    final want = contracts.playerWant(player);
    final mult = difficulty == Difficulty.hard
        ? 1.1 + _random.nextDouble() * 0.15
        : 0.95 + _random.nextDouble() * 0.15;
    return ContractOffer(
      salary: (want * mult)
          .round()
          .clamp(balance.salaryCap.minSalary, balance.salaryCap.maxSalary),
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
    if (difficulty != Difficulty.hard) return const TacticsSetup();
    // Prefer a formation that counters opponent if listed.
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

  bool _isRival(Team a, Team b) => a.conference == b.conference;
}
