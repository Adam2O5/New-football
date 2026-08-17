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
    this.exception,
    this.rookiePickSlot,
    this.useBird = false,
    this.useMle = false,
  });

  final int salary;
  final int years;

  /// Explicit exception for extension/FA validation. [useBird] and [useMle]
  /// remain as compatibility shorthands for existing UI callers.
  final CapExceptionType? exception;
  final int? rookiePickSlot;
  final bool useBird;
  final bool useMle;

  CapExceptionType? get effectiveException =>
      exception ??
      (useBird
          ? CapExceptionType.birdRights
          : useMle
          ? CapExceptionType.midLevelException
          : null);
}

class ContractOfferValidation {
  const ContractOfferValidation({
    required this.ok,
    this.reason,
    this.exception,
    this.terms,
  });

  final bool ok;
  final String? reason;
  final CapExceptionType? exception;
  final CapExceptionTerms? terms;

  const ContractOfferValidation.valid({
    CapExceptionType? exception,
    CapExceptionTerms? terms,
  }) : this(ok: true, exception: exception, terms: terms);

  const ContractOfferValidation.invalid(String reason)
    : this(ok: false, reason: reason);
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
    return (base * ageFactor).round().clamp(
      balance.salaryCap.minSalary,
      balance.salaryCap.maxSalary,
    );
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
      exception: offer.exception,
      rookiePickSlot: offer.rookiePickSlot,
      useBird: offer.useBird,
      useMle: offer.useMle,
    );
  }

  /// Validates the complete player/club relationship before the cap check.
  /// This is the single contract API used by signing and extensions, so the
  /// exception formulas cannot drift between UI previews and execution.
  ContractOfferValidation validateOffer({
    required Team team,
    required Player player,
    required ContractOffer offer,
  }) {
    final exception = offer.effectiveException;
    final existingIndex = team.roster.indexWhere(
      (item) => item.id == player.id,
    );
    final isExtension = existingIndex >= 0;
    final replacingSalary = isExtension ? player.contract.salary : 0;

    if (offer.years < 1) {
      return const ContractOfferValidation.invalid(
        'Kontrakt musi trwać co najmniej rok',
      );
    }

    if (exception != null) {
      final requiresExistingPlayer = switch (exception) {
        CapExceptionType.rookieExtension ||
        CapExceptionType.fullBirdRights ||
        CapExceptionType.birdRights ||
        CapExceptionType.earlyBirdRights ||
        CapExceptionType.nonBirdRights ||
        CapExceptionType.veteranExtensionRaiseCap => true,
        _ => false,
      };
      if (requiresExistingPlayer && !isExtension) {
        return const ContractOfferValidation.invalid(
          'Ten wyjątek jest wyłączny dla zawodnika obecnego w klubie',
        );
      }

      final exceptionValidation = capService.validateExceptionOffer(
        player: player,
        exception: exception,
        salary: offer.salary,
        years: offer.years,
        rookiePickSlot: offer.rookiePickSlot,
      );
      if (!exceptionValidation.ok) {
        return ContractOfferValidation.invalid(
          exceptionValidation.reason ?? 'Nieprawidłowe warunki wyjątku',
        );
      }
      if (!capService.canSign(
        team: team,
        salary: offer.salary,
        exception: exception,
        replacingSalary: replacingSalary,
      )) {
        return const ContractOfferValidation.invalid(
          'Drużyna nie ma dostępnego wyjątku salary cap',
        );
      }
      return ContractOfferValidation.valid(
        exception: exception,
        terms: exceptionValidation.terms,
      );
    }

    if (offer.salary < balance.salaryCap.minSalary ||
        offer.salary > balance.salaryCap.maxSalary) {
      return const ContractOfferValidation.invalid(
        'Pensja zawodnika jest poza zakresem 1–60M',
      );
    }
    if (!capService.canSign(
      team: team,
      salary: offer.salary,
      replacingSalary: replacingSalary,
    )) {
      return const ContractOfferValidation.invalid(
        'Brak cap space lub odpowiedniego wyjątku',
      );
    }
    return const ContractOfferValidation.valid();
  }

  Team? signPlayer({
    required Team team,
    required Player player,
    required ContractOffer offer,
  }) {
    final validation = validateOffer(team: team, player: player, offer: offer);
    if (!validation.ok) return null;

    final existingIndex = team.roster.indexWhere(
      (item) => item.id == player.id,
    );
    if (existingIndex < 0 && team.roster.length >= balance.roster.maxSize) {
      return null;
    }

    final exception = validation.exception;
    final retainsBird =
        exception == CapExceptionType.birdRights ||
        exception == CapExceptionType.fullBirdRights ||
        player.contract.hasBirdRights;
    final isRookieScale = exception == CapExceptionType.rookieScale;
    final signed = player.copyWith(
      contract: Contract(
        salary: offer.salary,
        yearsRemaining: offer.years,
        hasBirdRights: retainsBird,
        isRookieScale: isRookieScale,
        rookiePickSlot: isRookieScale
            ? (offer.rookiePickSlot ?? player.contract.rookiePickSlot)
            : 0,
        exceptionType: exception,
        noTradeClause: player.contract.noTradeClause,
        blockedTeamIds: player.contract.blockedTeamIds,
      ),
      state: existingIndex >= 0
          ? player.state
          : player.state.copyWith(seasonsWithTeam: 0),
    );

    final roster = List<Player>.from(team.roster);
    if (existingIndex >= 0) {
      roster[existingIndex] = signed;
    } else {
      roster.add(signed);
    }

    var finance = team.finance;
    if (exception == CapExceptionType.midLevelException) {
      finance = finance.copyWith(midLevelExceptionAvailable: false);
    }
    final exceptionIndex = exception == null
        ? -1
        : finance.activeExceptions.indexWhere((item) => item.type == exception);
    if (exceptionIndex >= 0) {
      final active = finance.activeExceptions[exceptionIndex];
      final remaining = active.amountRemaining - offer.salary;
      final exceptions = List<CapException>.from(finance.activeExceptions);
      if (remaining <= 0) {
        exceptions.removeAt(exceptionIndex);
      } else {
        exceptions[exceptionIndex] = active.copyWith(
          amountRemaining: remaining,
        );
      }
      finance = finance.copyWith(activeExceptions: exceptions);
    }

    return capService.applyPayroll(
      team.copyWith(roster: roster, finance: finance),
    );
  }
}
