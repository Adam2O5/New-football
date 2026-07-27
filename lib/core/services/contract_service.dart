import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/salary_cap_service.dart';

enum ContractReaction { accept, hardReject, waiting, counter }

class ContractOffer {
  const ContractOffer({
    required this.salary,
    required this.years,
    this.useBird = false,
    this.useMle = false,
  });

  final int salary;
  final int years;
  final bool useBird;
  final bool useMle;
}

class ContractService {
  ContractService({
    this.balance = BalanceConfig.defaults,
    SalaryCapService? capService,
    Random? random,
  }) : capService = capService ?? SalaryCapService(balance: balance),
       _random = random ?? Random();

  final BalanceConfig balance;
  final SalaryCapService capService;
  final Random _random;

  int playerWant(Player player) {
    final ovr = player.overall(balance);
    final base = (ovr - 50) * 1200000 + 2000000;
    final ageFactor = player.age <= 26
        ? 1.1
        : player.age >= 33
        ? 0.75
        : 1.0;
    return (base * ageFactor)
        .round()
        .clamp(balance.salaryCap.minSalary, balance.salaryCap.maxSalary);
  }

  double playerOfferScore(Player player, ContractOffer offer) {
    final want = playerWant(player);
    final salaryScore = offer.salary / want;
    final yearsScore = offer.years >= 3
        ? 1.1
        : offer.years == 2
        ? 1.0
        : 0.85;
    return salaryScore * yearsScore;
  }

  ContractReaction evaluate(Player player, ContractOffer offer) {
    final score = playerOfferScore(player, offer);
    if (score >= 1.05) return ContractReaction.accept;
    if (score >= 0.9) {
      return _random.nextDouble() < 0.55
          ? ContractReaction.accept
          : ContractReaction.waiting;
    }
    if (score >= 0.75) return ContractReaction.counter;
    if (score >= 0.6) return ContractReaction.waiting;
    return ContractReaction.hardReject;
  }

  ContractOffer counterOffer(Player player, ContractOffer offer) {
    final want = playerWant(player);
    return ContractOffer(
      salary: ((offer.salary + want) / 2).round().clamp(
        balance.salaryCap.minSalary,
        balance.salaryCap.maxSalary,
      ),
      years: max(offer.years, 2),
      useBird: offer.useBird,
      useMle: offer.useMle,
    );
  }

  Team? signPlayer({
    required Team team,
    required Player player,
    required ContractOffer offer,
  }) {
    final exception = offer.useBird
        ? CapExceptionType.birdRights
        : offer.useMle
        ? CapExceptionType.midLevelException
        : null;
    if (!capService.canSign(
      team: team,
      salary: offer.salary,
      exception: exception,
    )) {
      return null;
    }
    if (team.roster.length >= balance.roster.maxSize) return null;

    final signed = player.copyWith(
      contract: Contract(
        salary: offer.salary,
        yearsRemaining: offer.years,
        hasBirdRights: offer.useBird || player.contract.hasBirdRights,
      ),
      state: player.state.copyWith(seasonsWithTeam: 0),
    );
    var updated = team.copyWith(roster: [...team.roster, signed]);
    if (offer.useMle) {
      updated = updated.copyWith(
        finance: updated.finance.copyWith(midLevelExceptionAvailable: false),
      );
    }
    return capService.applyPayroll(updated);
  }
}
