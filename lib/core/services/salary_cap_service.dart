import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';

/// The four payroll regimes used by player signing and trade validation.
enum CapStatus { underCap, overCap, firstApron, secondApron }

class CapSnapshot {
  const CapSnapshot({
    required this.payroll,
    required this.cap,
    required this.firstApron,
    required this.secondApron,
    required this.status,
    required this.capSpace,
  });

  final int payroll;
  final int cap;
  final int firstApron;
  final int secondApron;
  final CapStatus status;
  final int capSpace;

  bool get isAboveSecondApron => status == CapStatus.secondApron;
  bool get isBetweenAprons => status == CapStatus.firstApron;
}

/// Terms exposed by an exception before an offer is submitted.
class CapExceptionTerms {
  const CapExceptionTerms({
    required this.type,
    required this.minSalary,
    required this.maxSalary,
    required this.maxYears,
    this.exactSalary = false,
    this.exclusive = false,
  });

  final CapExceptionType type;
  final int minSalary;
  final int maxSalary;
  final int maxYears;
  final bool exactSalary;
  final bool exclusive;
}

class CapExceptionValidation {
  const CapExceptionValidation({required this.ok, this.reason, this.terms});

  final bool ok;
  final String? reason;
  final CapExceptionTerms? terms;

  const CapExceptionValidation.valid(CapExceptionTerms terms)
    : this(ok: true, terms: terms);

  const CapExceptionValidation.invalid(String reason)
    : this(ok: false, reason: reason);
}

/// Result of the centralized salary-matching rule.
class TradeMatchingResult {
  const TradeMatchingResult({
    required this.allowed,
    required this.maxIncomingSalary,
    required this.aggregationAllowed,
    required this.mode,
    this.reason,
  });

  final bool allowed;
  final int maxIncomingSalary;
  final bool aggregationAllowed;
  final TradeMatchingMode mode;
  final String? reason;
}

enum TradeMatchingMode {
  capSpace,
  salaryMatching,
  noAggregation,
  noNetPayrollIncrease,
}

/// Persisted schedule values are stored on [Season]. This value object is
/// also used by the factory/tests when creating a deterministic schedule.
class TvCapSchedule {
  const TvCapSchedule({
    required this.nextTvCapResetSeason,
    required this.nextTvCapIncreasePct,
  });

  final int nextTvCapResetSeason;
  final int nextTvCapIncreasePct;
}

/// Deterministically creates the next TV reset from the save seed. The
/// current year is part of the stream so every subsequent agreement gets a
/// new, reproducible pair without relying on mutable RNG state.
TvCapSchedule tvCapScheduleFor({
  required int currentYear,
  required int saveSeed,
}) {
  final seed = (saveSeed ^ (currentYear * 1000003) ^ 0x5f3759df) & 0x7fffffff;
  final random = Random(seed);
  return TvCapSchedule(
    nextTvCapResetSeason: currentYear + 5 + random.nextInt(3),
    nextTvCapIncreasePct: 4 + random.nextInt(9),
  );
}

class SalaryCapService {
  const SalaryCapService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  /// Returns the cap thresholds currently carried by the team. A team made
  /// by older callers still receives the injected balance defaults; after a
  /// TV update the explicitly synchronized TeamFinance values are used.
  ({int cap, int firstApron, int secondApron}) _thresholds(Team team) {
    final persisted = team.finance;
    final defaults = BalanceConfig.defaults.salaryCap;
    final usesPersistedValues =
        persisted.salaryCap != defaults.salaryCap ||
        persisted.firstApron != defaults.firstApron ||
        persisted.secondApron != defaults.secondApron;
    if (!usesPersistedValues) {
      final configured = balance.salaryCap;
      return (
        cap: configured.salaryCap,
        firstApron: configured.firstApron,
        secondApron: configured.secondApron,
      );
    }
    return (
      cap: persisted.salaryCap,
      firstApron: persisted.firstApron,
      secondApron: persisted.secondApron,
    );
  }

  CapSnapshot snapshot(Team team) {
    final thresholds = _thresholds(team);
    final payroll = team.roster.fold<int>(0, (sum, player) {
      return sum + player.contract.salary;
    });
    final status = payroll >= thresholds.secondApron
        ? CapStatus.secondApron
        : payroll >= thresholds.firstApron
        ? CapStatus.firstApron
        : payroll > thresholds.cap
        ? CapStatus.overCap
        : CapStatus.underCap;
    return CapSnapshot(
      payroll: payroll,
      cap: thresholds.cap,
      firstApron: thresholds.firstApron,
      secondApron: thresholds.secondApron,
      status: status,
      capSpace: thresholds.cap - payroll,
    );
  }

  /// V1 has no luxury tax. This method intentionally does not exist; all
  /// financial restrictions are expressed through cap/apron validation.

  /// Checks whether a signing is legal after removing [replacingSalary] from
  /// the current payroll. The replacement argument is what makes extensions
  /// validate against the net payroll change rather than double-counting the
  /// player's old contract.
  bool canSign({
    required Team team,
    required int salary,
    CapExceptionType? exception,
    int replacingSalary = 0,
  }) {
    final b = balance.salaryCap;
    if (salary < b.minSalary || salary > b.maxSalary) return false;
    final snap = snapshot(team);
    final adjustedPayroll = snap.payroll - replacingSalary;
    if (adjustedPayroll + salary <= snap.cap) return true;
    if (exception == null) return false;

    switch (exception) {
      case CapExceptionType.midLevelException:
        return team.finance.midLevelExceptionAvailable &&
            salary <= team.finance.midLevelExceptionAmount &&
            salary <= b.midLevelException;
      case CapExceptionType.tradedPlayerException:
        return team.finance.activeExceptions.any(
          (item) => item.type == exception && item.amountRemaining >= salary,
        );
      case CapExceptionType.birdRights:
      case CapExceptionType.rookieScale:
      case CapExceptionType.rookieExtension:
      case CapExceptionType.qualifyingOffer:
      case CapExceptionType.fullBirdRights:
      case CapExceptionType.earlyBirdRights:
      case CapExceptionType.nonBirdRights:
      case CapExceptionType.veteranExtensionRaiseCap:
        // The player-specific eligibility and amount are checked by
        // validateExceptionOffer; these exception types are not limited by a
        // separate TeamFinance balance.
        return true;
    }
  }

  /// Returns the documented salary and term limits for [exception].
  CapExceptionValidation validateExceptionOffer({
    required Player player,
    required CapExceptionType exception,
    required int salary,
    required int years,
    int? rookiePickSlot,
  }) {
    final b = balance.salaryCap;
    final previousSalary = player.contract.salary;
    final slot = rookiePickSlot ?? player.contract.rookiePickSlot;
    late final CapExceptionTerms terms;

    switch (exception) {
      case CapExceptionType.rookieScale:
        if (slot <= 0) {
          return const CapExceptionValidation.invalid(
            'Rookie scale wymaga slotu draftu',
          );
        }
        final scaleSalary = b.rookieSalaryForPick(slot);
        terms = CapExceptionTerms(
          type: exception,
          minSalary: scaleSalary,
          maxSalary: scaleSalary,
          maxYears: b.rookieScaleYears,
          exactSalary: true,
        );
      case CapExceptionType.rookieExtension:
        if (!player.contract.isRookieScale ||
            player.contract.yearsRemaining > 1) {
          return const CapExceptionValidation.invalid(
            'Rookie extension jest dostępne wyłącznie w ostatnim roku skali',
          );
        }
        terms = CapExceptionTerms(
          type: exception,
          minSalary: b.minSalary,
          maxSalary: b.maxSalary,
          maxYears: 5,
          exclusive: true,
        );
      case CapExceptionType.qualifyingOffer:
        if (!player.contract.isRookieScale ||
            player.contract.yearsRemaining > 0) {
          return const CapExceptionValidation.invalid(
            'QO/RFA wymaga zakończonego kontraktu rookie scale',
          );
        }
        final qualifyingOffer = max(
          b.qualifyingOfferMin,
          (previousSalary * b.qualifyingOfferMultiplier).ceil(),
        );
        terms = CapExceptionTerms(
          type: exception,
          minSalary: qualifyingOffer,
          maxSalary: b.maxSalary,
          maxYears: 5,
        );
      case CapExceptionType.fullBirdRights:
      case CapExceptionType.birdRights:
        if (player.state.seasonsWithTeam < b.birdRightsSeasons &&
            !player.contract.hasBirdRights) {
          return const CapExceptionValidation.invalid(
            'Full Bird Rights wymagają co najmniej 3 sezonów w klubie',
          );
        }
        terms = CapExceptionTerms(
          type: exception,
          minSalary: b.minSalary,
          maxSalary: b.maxSalary,
          maxYears: 5,
        );
      case CapExceptionType.earlyBirdRights:
        if (player.state.seasonsWithTeam != 2) {
          return const CapExceptionValidation.invalid(
            'Early Bird Rights wymagają dokładnie 2 sezonów w klubie',
          );
        }
        terms = CapExceptionTerms(
          type: exception,
          minSalary: b.minSalary,
          maxSalary: min(
            (previousSalary * 1.75).round(),
            (b.maxSalary * 0.60).round(),
          ),
          maxYears: 4,
        );
      case CapExceptionType.nonBirdRights:
        if (player.state.seasonsWithTeam >= 2) {
          return const CapExceptionValidation.invalid(
            'Non-Bird Rights dotyczą stażu krótszego niż 2 sezony',
          );
        }
        terms = CapExceptionTerms(
          type: exception,
          minSalary: b.minSalary,
          maxSalary: (previousSalary * 1.20).round(),
          maxYears: 4,
        );
      case CapExceptionType.veteranExtensionRaiseCap:
        if (player.contract.isRookieScale) {
          return const CapExceptionValidation.invalid(
            'Veteran Extension Raise Cap nie dotyczy rookie scale',
          );
        }
        terms = CapExceptionTerms(
          type: exception,
          minSalary: b.minSalary,
          maxSalary: min(b.maxSalary, (previousSalary * 1.08).round()),
          maxYears: 5,
        );
      case CapExceptionType.midLevelException:
        terms = CapExceptionTerms(
          type: exception,
          minSalary: b.minSalary,
          maxSalary: b.midLevelException,
          maxYears: 4,
        );
      case CapExceptionType.tradedPlayerException:
        terms = CapExceptionTerms(
          type: exception,
          minSalary: b.minSalary,
          maxSalary: b.maxSalary,
          maxYears: 5,
        );
    }

    if (years < 1 || years > terms.maxYears) {
      return CapExceptionValidation.invalid(
        'Maksymalna długość tego wyjątku to ${terms.maxYears} lat',
      );
    }
    if (terms.exactSalary && salary != terms.maxSalary) {
      return CapExceptionValidation.invalid(
        'Rookie scale wymaga pensji ${terms.maxSalary}',
      );
    }
    if (salary < terms.minSalary || salary > terms.maxSalary) {
      return CapExceptionValidation.invalid(
        'Pensja musi mieścić się w zakresie ${terms.minSalary}–${terms.maxSalary}',
      );
    }
    return CapExceptionValidation.valid(terms);
  }

  CapExceptionTerms termsFor({
    required Player player,
    required CapExceptionType exception,
    int? rookiePickSlot,
  }) {
    final b = balance.salaryCap;
    final slot = rookiePickSlot ?? player.contract.rookiePickSlot;
    final probeSalary = switch (exception) {
      CapExceptionType.rookieScale when slot > 0 => b.rookieSalaryForPick(slot),
      CapExceptionType.qualifyingOffer => max(
        b.qualifyingOfferMin,
        (player.contract.salary * b.qualifyingOfferMultiplier).ceil(),
      ),
      _ => b.minSalary,
    };
    final result = validateExceptionOffer(
      player: player,
      exception: exception,
      salary: probeSalary,
      years: 1,
      rookiePickSlot: rookiePickSlot,
    );
    if (!result.ok || result.terms == null) {
      throw ArgumentError(result.reason ?? 'Niedozwolony wyjątek cap');
    }
    return result.terms!;
  }

  /// Returns the cap update schedule for a save/current season.
  TvCapSchedule tvScheduleFor({
    required int currentYear,
    required int saveSeed,
  }) => tvCapScheduleFor(currentYear: currentYear, saveSeed: saveSeed);

  /// Scales both aprons by the same ratios as the current cap. Existing
  /// player contracts are never touched; only TeamFinance thresholds change.
  List<Team> applyTvUpdate(List<Team> teams, {required int increasePct}) {
    final pct = increasePct.clamp(4, 12).toInt();
    return teams.map((team) {
      final current = snapshot(team);
      final newCap = (current.cap * (100 + pct) / 100).round();
      final newFirst = (newCap * current.firstApron / current.cap).round();
      final newSecond = (newCap * current.secondApron / current.cap).round();
      return team.copyWith(
        finance: team.finance.copyWith(
          salaryCap: newCap,
          firstApron: newFirst,
          secondApron: newSecond,
        ),
      );
    }).toList();
  }

  /// Applies current roster payroll to the persisted finance snapshot.
  Team applyPayroll(Team team) {
    final payroll = team.roster.fold<int>(
      0,
      (sum, player) => sum + player.contract.salary,
    );
    return team.copyWith(finance: team.finance.copyWith(totalPayroll: payroll));
  }

  /// Central matching rule used by both UI previews and trade submission.
  TradeMatchingResult tradeMatching({
    required Team team,
    required int outgoingSalary,
    required int incomingSalary,
    List<int> outgoingSalaries = const [],
    int incomingFirstRoundPicks = 0,
  }) {
    final snap = snapshot(team);
    final salaries = outgoingSalaries.where((salary) => salary > 0).toList();
    final outgoing = max(0, outgoingSalary);
    final effectiveOutgoing = salaries.isEmpty
        ? outgoing
        : salaries.fold<int>(0, (sum, salary) => sum + salary);

    late final int maxIncoming;
    late final bool aggregationAllowed;
    late final TradeMatchingMode mode;
    String? reason;

    switch (snap.status) {
      case CapStatus.underCap:
        // A team may use all of its cap space in addition to salary it sends.
        maxIncoming = effectiveOutgoing + max(0, snap.capSpace);
        aggregationAllowed = true;
        mode = TradeMatchingMode.capSpace;
      case CapStatus.overCap:
        maxIncoming =
            (effectiveOutgoing * balance.salaryCap.salaryMatchPct +
                    balance.salaryCap.salaryMatchBuffer)
                .round();
        aggregationAllowed = true;
        mode = TradeMatchingMode.salaryMatching;
      case CapStatus.firstApron:
        // No aggregation: only one outgoing contract can be used as the
        // matching base for incoming salary.
        final matchingSalary = salaries.isEmpty
            ? outgoing
            : salaries.reduce(max);
        maxIncoming =
            (matchingSalary * balance.salaryCap.salaryMatchPct +
                    balance.salaryCap.salaryMatchBuffer)
                .round();
        aggregationAllowed = false;
        mode = TradeMatchingMode.noAggregation;
      case CapStatus.secondApron:
        maxIncoming = effectiveOutgoing;
        aggregationAllowed = false;
        mode = TradeMatchingMode.noNetPayrollIncrease;
        if (incomingFirstRoundPicks > 0) {
          reason = 'Drużyna powyżej 2. apronu nie może otrzymać picka R1';
        }
    }

    final allowed = reason == null && incomingSalary <= maxIncoming;
    if (!allowed && reason == null) {
      reason = switch (mode) {
        TradeMatchingMode.capSpace => 'Przekroczony cap space',
        TradeMatchingMode.salaryMatching => 'Przekroczony matching 125%',
        TradeMatchingMode.noAggregation =>
          'Między apronami nie wolno agregować pensji',
        TradeMatchingMode.noNetPayrollIncrease =>
          'Powyżej 2. apronu payroll nie może wzrosnąć',
      };
    }
    return TradeMatchingResult(
      allowed: allowed,
      maxIncomingSalary: maxIncoming,
      aggregationAllowed: aggregationAllowed,
      mode: mode,
      reason: reason,
    );
  }

  bool canMatchTrade({
    required Team team,
    required int outgoingSalary,
    required int incomingSalary,
    List<int> outgoingSalaries = const [],
    int incomingFirstRoundPicks = 0,
  }) => tradeMatching(
    team: team,
    outgoingSalary: outgoingSalary,
    incomingSalary: incomingSalary,
    outgoingSalaries: outgoingSalaries,
    incomingFirstRoundPicks: incomingFirstRoundPicks,
  ).allowed;

  int maxIncomingSalary({
    required Team team,
    required int outgoingSalary,
    List<int> outgoingSalaries = const [],
  }) => tradeMatching(
    team: team,
    outgoingSalary: outgoingSalary,
    incomingSalary: 0,
    outgoingSalaries: outgoingSalaries,
  ).maxIncomingSalary;
}
