import 'dart:math';

import 'package:new_football/core/ai/ai_evaluation_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';
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
    AiEvaluationService? evaluator,
  }) : _random = random ?? Random(),
       _evaluator = evaluator ?? AiEvaluationService(balance: balance);

  final BalanceConfig balance;
  final Random _random;
  final AiEvaluationService _evaluator;

  /// Fixed value margin for trade acceptance (AI_behaviour.md §1: no difficulty).
  static const double _valueMargin = 0.12;

  bool shouldAcceptTrade({
    required Team self,
    required Team other,
    required TradeProposal proposal,
    required TradeService tradeService,
    LeagueState? league,
    required int currentYear,
    int saveSeed = 0,
    int? week,
  }) {
    if (league != null) {
      final evaluation = _evaluator.evaluateTradeAssets(
        recipient: self,
        partner: other,
        incomingAssets: proposal.assetsFromB,
        outgoingAssets: proposal.assetsFromA,
        league: league,
        currentYear: currentYear,
        saveSeed: saveSeed,
        week: week,
      );
      if (evaluation.hardRejected) return false;
      return evaluation.surplusPct >= balance.ai.tradeAcceptLow * 100.0;
    }

    int value(Team owner, TradeAsset asset) =>
        tradeService.assetValue(owner, asset, currentYear: currentYear);

    final ourValue = proposal.assetsFromB.fold<int>(
      0,
      (s, a) => s + value(other, a),
    );
    final theirValue = proposal.assetsFromA.fold<int>(
      0,
      (s, a) => s + value(self, a),
    );
    if (theirValue == 0) return ourValue > 0;

    final ratio = ourValue / theirValue;
    // Legacy in-memory callers without a league snapshot retain the old API.
    return ratio >= 1.0 - _valueMargin * 0.5;
  }

  ContractOffer makeFaOffer(
    Player player,
    ContractService contracts, {
    int? saveSeed,
    int seasonYear = 0,
    int week = 1,
    String teamId = '',
  }) {
    final expectedSalary = contracts.expectedSalary(player);
    final expectedLength = contracts.expectedLength(player);
    final random = saveSeed == null
        ? _random
        : Random(
            aiSeed(saveSeed, seasonYear, week, teamId, DecisionType.faOffer),
          );
    final mult = 0.95 + random.nextDouble() * 0.15;
    return ContractOffer(
      salary: (expectedSalary * mult).round().clamp(
        balance.salaryCap.minSalary,
        balance.salaryCap.maxSalary,
      ),
      years: (expectedLength + random.nextInt(2) - 1).clamp(1, 5),
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
