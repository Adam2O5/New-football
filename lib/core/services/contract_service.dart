import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/salary_cap_service.dart';

enum ContractReaction { accept, hardReject, reject, waiting, counter }

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

class ExtensionMinutesAssessment {
  const ExtensionMinutesAssessment({
    required this.currentOvr,
    required this.seasonStartOvr,
    required this.effectiveOvr,
    required this.actualMinutes,
    required this.possibleMinutes,
    required this.actualMinutesShare,
    required this.requiredMinutesShare,
    required this.minimumPossibleMinutes,
    required this.sampleSufficient,
    required this.ruleActive,
    required this.meetsRequirement,
  });

  final double currentOvr;
  final double? seasonStartOvr;
  final double effectiveOvr;
  final int actualMinutes;
  final int possibleMinutes;
  final double actualMinutesShare;
  final double? requiredMinutesShare;
  final int minimumPossibleMinutes;
  final bool sampleSufficient;
  final bool ruleActive;
  final bool meetsRequirement;

  bool get shouldHardReject => ruleActive && !meetsRequirement;

  String? get reasonCode =>
      shouldHardReject ? 'extension_minutes_below_threshold' : null;

  Map<String, dynamic> get messagePayload => {
    'reasonCode': reasonCode,
    'effectiveOvr': effectiveOvr,
    'currentOvr': currentOvr,
    'seasonStartOvr': seasonStartOvr,
    'actualMinutes': actualMinutes,
    'possibleMinutes': possibleMinutes,
    'actualMinutesShare': actualMinutesShare,
    'requiredMinutesShare': requiredMinutesShare,
    'minimumPossibleMinutes': minimumPossibleMinutes,
    'sampleSufficient': sampleSufficient,
    'extensionMinutesRuleActive': ruleActive,
  };
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

  /// Evaluates the current-season minutes requirement for a player extension.
  ///
  /// The rolling event history is deliberately not used here. The team event
  /// state keeps a separate season aggregate, so regular-season, play-in and
  /// playoff matches all contribute without changing the six-week event
  /// window. A missing snapshot is only possible for legacy/incomplete data;
  /// in that case the current raw OVR is used as a neutral fallback.
  ExtensionMinutesAssessment assessExtensionMinutes({
    required Team team,
    required Player player,
  }) {
    final currentOvr = player.overall(balance);
    final startOvr = player.seasonStartOvr ?? currentOvr;
    final effectiveOvr = (startOvr + currentOvr) / 2.0;
    final aggregate = team.eventState.seasonMinutesFor(player.id);
    final actualMinutes = aggregate?.actualMinutes ?? 0;
    final possibleMinutes = aggregate?.possibleMinutes ?? 0;
    final actualMinutesShare = possibleMinutes > 0
        ? actualMinutes / possibleMinutes
        : 0.0;
    final requiredMinutesShare = _extensionMinutesRequiredShare(effectiveOvr);
    final minimumPossible =
        balance.contracts.extensionMinutesMinimumPossibleMinutes;
    final sampleSufficient = possibleMinutes >= minimumPossible;
    final ruleActive = sampleSufficient && requiredMinutesShare != null;

    return ExtensionMinutesAssessment(
      currentOvr: currentOvr,
      seasonStartOvr: player.seasonStartOvr,
      effectiveOvr: effectiveOvr,
      actualMinutes: actualMinutes,
      possibleMinutes: possibleMinutes,
      actualMinutesShare: actualMinutesShare,
      requiredMinutesShare: requiredMinutesShare,
      minimumPossibleMinutes: minimumPossible,
      sampleSufficient: sampleSufficient,
      ruleActive: ruleActive,
      meetsRequirement:
          !ruleActive || actualMinutesShare >= requiredMinutesShare,
    );
  }

  double? _extensionMinutesRequiredShare(double effectiveOvr) {
    final settings = balance.contracts;
    if (effectiveOvr >= settings.extensionMinutesHighOvr) {
      return settings.extensionMinutesHighRequiredShare;
    }
    if (effectiveOvr >= settings.extensionMinutesMidOvr) {
      return settings.extensionMinutesMidRequiredShare;
    }
    if (effectiveOvr >= settings.extensionMinutesLowOvr) {
      return settings.extensionMinutesLowRequiredShare;
    }
    if (effectiveOvr >= settings.extensionMinutesMinimumOvr) {
      return settings.extensionMinutesMinimumRequiredShare;
    }
    return null;
  }

  /// Contractual demand score from 0 to 100 (`contracts.md` §6).
  int playerWant(
    Player player, {
    TeamStatus currentTeamStatus = TeamStatus.pretender,
  }) {
    final personalityFactor = switch (player.personality) {
      PlayerPersonality.ambitious => 5,
      PlayerPersonality.temperamental => 4,
      PlayerPersonality.leader => 1,
      PlayerPersonality.balanced => 0,
      PlayerPersonality.professional => -2,
      PlayerPersonality.loyal => -4,
    };
    final raw =
        (player.pointValue + 1000) / 20 +
        personalityFactor +
        NegotiationRules.teamStatusBonus(currentTeamStatus);
    return raw.clamp(0, 100).round();
  }

  /// Expected annual salary derived from [playerWant], not the score itself.
  int expectedSalary(
    Player player, {
    TeamStatus currentTeamStatus = TeamStatus.pretender,
  }) {
    final want = playerWant(player, currentTeamStatus: currentTeamStatus) / 100;
    final salary =
        balance.salaryCap.minSalary +
        (balance.salaryCap.maxSalary - balance.salaryCap.minSalary) *
            pow(want, 3);
    return salary.round().clamp(
      balance.salaryCap.minSalary,
      balance.salaryCap.maxSalary,
    );
  }

  int expectedLength(
    Player player, {
    TeamStatus currentTeamStatus = TeamStatus.pretender,
  }) {
    final want = playerWant(player, currentTeamStatus: currentTeamStatus);
    final band = want <= 39
        ? 0
        : want <= 69
        ? 1
        : 2;
    if (player.age <= 23) return const [2, 3, 4][band];
    if (player.age <= 29) return const [2, 3, 5][band];
    if (player.age <= 32) return const [1, 2, 3][band];
    return const [1, 1, 2][band];
  }

  double cfoDiscount({StaffMember? cfo, double? negotiation}) =>
      NegotiationRules.cfoDiscount(negotiation ?? cfo?.attributes.negotiation);

  OfferScoreBreakdown playerOfferBreakdown(
    Player player,
    ContractOffer offer, {
    TeamStatus offeringTeamStatus = TeamStatus.pretender,
    TeamStatus currentTeamStatus = TeamStatus.pretender,
    StaffMember? cfo,
    double? cfoNegotiation,
  }) {
    return NegotiationRules.score(
      salary: offer.salary,
      expectedSalary: expectedSalary(
        player,
        currentTeamStatus: currentTeamStatus,
      ),
      years: offer.years,
      expectedLength: expectedLength(
        player,
        currentTeamStatus: currentTeamStatus,
      ),
      offeringTeamStatus: offeringTeamStatus,
      cfoNegotiation: cfoNegotiation ?? cfo?.attributes.negotiation,
      balance: balance.contracts,
    );
  }

  double playerOfferScore(
    Player player,
    ContractOffer offer, {
    TeamStatus offeringTeamStatus = TeamStatus.pretender,
    TeamStatus currentTeamStatus = TeamStatus.pretender,
    StaffMember? cfo,
    double? cfoNegotiation,
  }) => playerOfferBreakdown(
    player,
    offer,
    offeringTeamStatus: offeringTeamStatus,
    currentTeamStatus: currentTeamStatus,
    cfo: cfo,
    cfoNegotiation: cfoNegotiation,
  ).score;

  ContractReaction evaluate(
    Player player,
    ContractOffer offer, {
    NegotiationPhase phase = NegotiationPhase.contractExtension,
    TeamStatus offeringTeamStatus = TeamStatus.pretender,
    TeamStatus currentTeamStatus = TeamStatus.pretender,
    StaffMember? cfo,
    double? cfoNegotiation,
    bool competingOffers = false,
    bool belowExpectation = false,
    bool forceWaiting = false,
    Random? random,
  }) {
    final decision = NegotiationRules.decisionForScore(
      score: playerOfferScore(
        player,
        offer,
        offeringTeamStatus: offeringTeamStatus,
        currentTeamStatus: currentTeamStatus,
        cfo: cfo,
        cfoNegotiation: cfoNegotiation,
      ),
      phase: phase,
      random: random ?? _random,
      competingOffers: competingOffers,
      belowExpectation: belowExpectation,
      forceWaiting: forceWaiting,
      balance: balance.contracts,
    );
    return _reactionFor(decision);
  }

  /// Returns the documented first/second/third counter offer. The legacy
  /// method remains non-null for existing UI callers; callers that need to
  /// detect the fourth-round limit should use [counterOfferForRound].
  ContractOffer counterOffer(
    Player player,
    ContractOffer offer, {
    int round = 1,
    TeamStatus offeringTeamStatus = TeamStatus.pretender,
    TeamStatus currentTeamStatus = TeamStatus.pretender,
    StaffMember? cfo,
    double? cfoNegotiation,
  }) =>
      counterOfferForRound(
        player,
        offer,
        round: round,
        offeringTeamStatus: offeringTeamStatus,
        currentTeamStatus: currentTeamStatus,
        cfo: cfo,
        cfoNegotiation: cfoNegotiation,
      ) ??
      offer;

  ContractOffer? counterOfferForRound(
    Player player,
    ContractOffer offer, {
    required int round,
    TeamStatus offeringTeamStatus = TeamStatus.pretender,
    TeamStatus currentTeamStatus = TeamStatus.pretender,
    StaffMember? cfo,
    double? cfoNegotiation,
  }) {
    if (round < 1 || round > balance.contracts.maxCounterRounds) return null;
    final target = NegotiationRules.counterTargetScore(
      round,
      balance: balance.contracts,
    );
    final years = expectedLength(
      player,
      currentTeamStatus: currentTeamStatus,
    ).clamp(1, 5);
    final expected = expectedSalary(
      player,
      currentTeamStatus: currentTeamStatus,
    );
    final discount = cfoDiscount(cfo: cfo, negotiation: cfoNegotiation);
    final length = NegotiationRules.lengthFit(
      years: years,
      expectedLength: expectedLength(
        player,
        currentTeamStatus: currentTeamStatus,
      ),
      balance: balance.contracts,
    );
    final desiredSalaryFit =
        target / discount -
        length -
        NegotiationRules.teamStatusBonus(offeringTeamStatus) -
        balance.contracts.salaryFitBase;
    final percentage = desiredSalaryFit >= 0
        ? desiredSalaryFit / balance.contracts.salaryAboveBonusPerPct
        : desiredSalaryFit / balance.contracts.salaryBelowPenaltyPerPct;
    final salary = (expected * (1 + percentage / 100)).round().clamp(
      balance.salaryCap.minSalary,
      balance.salaryCap.maxSalary,
    );
    return ContractOffer(
      salary: salary,
      years: years,
      exception: offer.exception,
      rookiePickSlot: offer.rookiePickSlot,
      useBird: offer.useBird,
      useMle: offer.useMle,
    );
  }

  double counterHardRejectChance(int round) =>
      NegotiationRules.counterHardRejectChance(
        round,
        balance: balance.contracts,
      );

  ContractReaction evaluateCounterResponse(
    Player player,
    ContractOffer offer, {
    required int round,
    Random? random,
  }) {
    if (round < 1 || round > balance.contracts.maxCounterRounds) {
      return ContractReaction.hardReject;
    }
    return (random ?? _random).nextDouble() < counterHardRejectChance(round)
        ? ContractReaction.hardReject
        : ContractReaction.accept;
  }

  ContractReaction _reactionFor(NegotiationDecision decision) =>
      switch (decision) {
        NegotiationDecision.accept => ContractReaction.accept,
        NegotiationDecision.hardReject => ContractReaction.hardReject,
        NegotiationDecision.reject => ContractReaction.reject,
        NegotiationDecision.waiting => ContractReaction.waiting,
        NegotiationDecision.counter => ContractReaction.counter,
      };

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

  /// Eligibility is deliberately pure so UI previews and deterministic AI
  /// signing can use the same threshold before the random roll.
  bool isNtcEligible(Player player, ContractOffer offer) =>
      player.age >= 30 &&
      player.state.seasonsWithTeam >= 4 &&
      player.pointValue >= 200 &&
      offer.years >= 2;

  Team? signPlayer({
    required Team team,
    required Player player,
    required ContractOffer offer,
    Random? ntcRandom,
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
    final isExtension = existingIndex >= 0;
    final receivesNtc =
        isNtcEligible(player, offer) &&
        (ntcRandom ?? _random).nextDouble() < 0.20;
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
        // NTC is rolled at every qualifying signing/extension. A new FA
        // signing must not inherit a clause from an expired contract.
        noTradeClause: receivesNtc,
        blockedTeamIds: receivesNtc && isExtension
            ? player.contract.blockedTeamIds
            : const [],
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
