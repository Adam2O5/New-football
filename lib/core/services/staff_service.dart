import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';

enum StaffReaction { accept, hardReject, reject, waiting, counter }

class StaffOffer {
  const StaffOffer({required this.salary, required this.years});

  final int salary;
  final int years;
}

/// Sztab: zatrudnianie, zwalnianie, rozwój i emerytury (`docs/staff_rules.md`,
/// `docs/contract_signing.md` §7–9).
class StaffService {
  StaffService({
    this.balance = BalanceConfig.defaults,
    Random? random,
    MessageService? messages,
  }) : _random = random ?? Random(),
       _messages = messages ?? MessageService();

  final BalanceConfig balance;
  final Random _random;
  final MessageService _messages;

  /// Returns the canonical, unrounded role-specific rating for contract work.
  ///
  /// Contract formulas must consume [StaffRatingSystem.rawOverall] directly;
  /// [DisplayedRating] belongs to the presentation layer and must never enter
  /// salary or negotiation calculations. The final guard keeps malformed
  /// legacy numeric values finite without introducing another role mapping.
  double _rawOverall(StaffMember member) => _finiteClampRating(
    StaffRatingSystem.rawOverall(member.attributes, member.role),
  );

  /// Normalizes the separate CFO input used by negotiation rules.
  ///
  /// A subject's rating and the offering team's assisting CFO are independent
  /// inputs. The CFO input is therefore always projected as the canonical
  /// single-field `cfo` rating, regardless of the assisting member's role.
  double? _cfoNegotiationValue({StaffMember? cfo, double? negotiation}) {
    final raw =
        negotiation ??
        (cfo == null
            ? null
            : StaffRatingSystem.rawOverall(cfo.attributes, StaffRole.cfo));
    return raw == null ? null : _finiteClampRating(raw);
  }

  /// Clamps a rating while converting malformed non-finite values to a safe
  /// finite value. NaN is treated as the neutral lower-bound rating; infinities
  /// retain the direction implied by the documented 0–5 scale.
  double _finiteClampRating(double value) {
    if (value.isNaN || value == double.negativeInfinity) {
      return StaffRatingSystem.minRating;
    }
    if (value == double.infinity) return StaffRatingSystem.maxRating;
    return value
        .clamp(StaffRatingSystem.minRating, StaffRatingSystem.maxRating)
        .toDouble();
  }

  double marketSalary(StaffMember member) =>
      balance.staff.salaryFor(member.role, _rawOverall(member));

  /// Contractual demand score from 0 to 100 (`contracts.md` §7).
  double staffWant(
    StaffMember member, {
    TeamStatus currentTeamStatus = TeamStatus.pretender,
  }) {
    final raw =
        _rawOverall(member) * 20 +
        NegotiationRules.teamStatusBonus(currentTeamStatus);
    return raw.clamp(0.0, 100.0).toDouble();
  }

  int expectedSalary(
    StaffMember member, {
    TeamStatus currentTeamStatus = TeamStatus.pretender,
  }) {
    final want = staffWant(member, currentTeamStatus: currentTeamStatus) / 100;
    final salary =
        balance.staff.minSalary +
        (balance.staff.maxSalary - balance.staff.minSalary) * want * want;
    return salary.round().clamp(
      balance.staff.minSalary,
      balance.staff.maxSalary,
    );
  }

  int expectedLength(
    StaffMember member, {
    TeamStatus currentTeamStatus = TeamStatus.pretender,
  }) {
    final want = staffWant(member, currentTeamStatus: currentTeamStatus);
    final band = want <= 39
        ? 0
        : want <= 69
        ? 1
        : 2;
    if (member.age <= 54) return const [2, 3, 4][band];
    if (member.age <= 59) return const [1, 2, 2][band];
    return 1;
  }

  double cfoDiscount({StaffMember? cfo, double? negotiation}) =>
      NegotiationRules.cfoDiscount(
        _cfoNegotiationValue(cfo: cfo, negotiation: negotiation),
      );

  OfferScoreBreakdown staffOfferBreakdown(
    StaffMember member,
    StaffOffer offer, {
    TeamStatus offeringTeamStatus = TeamStatus.pretender,
    TeamStatus currentTeamStatus = TeamStatus.pretender,
    StaffMember? cfo,
    double? cfoNegotiation,
  }) {
    return NegotiationRules.score(
      salary: offer.salary,
      expectedSalary: expectedSalary(
        member,
        currentTeamStatus: currentTeamStatus,
      ),
      years: offer.years,
      expectedLength: expectedLength(
        member,
        currentTeamStatus: currentTeamStatus,
      ),
      offeringTeamStatus: offeringTeamStatus,
      cfoNegotiation: _cfoNegotiationValue(
        cfo: cfo,
        negotiation: cfoNegotiation,
      ),
      balance: balance.contracts,
    );
  }

  double staffOfferScore(
    StaffMember member,
    StaffOffer offer, {
    TeamStatus offeringTeamStatus = TeamStatus.pretender,
    TeamStatus currentTeamStatus = TeamStatus.pretender,
    StaffMember? cfo,
    double? cfoNegotiation,
  }) => staffOfferBreakdown(
    member,
    offer,
    offeringTeamStatus: offeringTeamStatus,
    currentTeamStatus: currentTeamStatus,
    cfo: cfo,
    cfoNegotiation: cfoNegotiation,
  ).score;

  StaffReaction evaluateOffer(
    StaffMember member,
    StaffOffer offer, {
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
      score: staffOfferScore(
        member,
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

  StaffOffer counterOffer(
    StaffMember member,
    StaffOffer offer, {
    int round = 1,
    TeamStatus offeringTeamStatus = TeamStatus.pretender,
    TeamStatus currentTeamStatus = TeamStatus.pretender,
    StaffMember? cfo,
    double? cfoNegotiation,
  }) =>
      counterOfferForRound(
        member,
        offer,
        round: round,
        offeringTeamStatus: offeringTeamStatus,
        currentTeamStatus: currentTeamStatus,
        cfo: cfo,
        cfoNegotiation: cfoNegotiation,
      ) ??
      offer;

  StaffOffer? counterOfferForRound(
    StaffMember member,
    StaffOffer offer, {
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
      member,
      currentTeamStatus: currentTeamStatus,
    ).clamp(1, 4);
    final expected = expectedSalary(
      member,
      currentTeamStatus: currentTeamStatus,
    );
    final discount = cfoDiscount(cfo: cfo, negotiation: cfoNegotiation);
    final length = NegotiationRules.lengthFit(
      years: years,
      expectedLength: expectedLength(
        member,
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
      balance.staff.minSalary,
      balance.staff.maxSalary,
    );
    return StaffOffer(salary: salary, years: years);
  }

  double counterHardRejectChance(int round) =>
      NegotiationRules.counterHardRejectChance(
        round,
        balance: balance.contracts,
      );

  StaffReaction evaluateCounterResponse(
    StaffMember member,
    StaffOffer offer, {
    required int round,
    Random? random,
  }) {
    if (round < 1 || round > balance.contracts.maxCounterRounds) {
      return StaffReaction.hardReject;
    }
    return (random ?? _random).nextDouble() < counterHardRejectChance(round)
        ? StaffReaction.hardReject
        : StaffReaction.accept;
  }

  StaffReaction _reactionFor(NegotiationDecision decision) =>
      switch (decision) {
        NegotiationDecision.accept => StaffReaction.accept,
        NegotiationDecision.hardReject => StaffReaction.hardReject,
        NegotiationDecision.reject => StaffReaction.reject,
        NegotiationDecision.waiting => StaffReaction.waiting,
        NegotiationDecision.counter => StaffReaction.counter,
      };

  bool isSalaryInRange(int salary) =>
      salary >= balance.staff.minSalary && salary <= balance.staff.maxSalary;

  String? hireValidationReason(
    Team team,
    int salary, {
    int replacingSalary = 0,
  }) {
    if (!isSalaryInRange(salary)) {
      return 'Pensja sztabu musi mieścić się w zakresie '
          '${balance.staff.minSalary}–${balance.staff.maxSalary}';
    }
    final adjustedPayroll = team.staff.totalSalary - replacingSalary;
    if (adjustedPayroll + salary > balance.staff.salaryCap) {
      return 'Przekroczony staff salary cap';
    }
    return null;
  }

  bool canHire(Team team, int salary, {int replacingSalary = 0}) =>
      hireValidationReason(team, salary, replacingSalary: replacingSalary) ==
      null;

  /// Signs a staff member in either an empty slot or over their own expiring
  /// contract. Replacing the member's old salary keeps an extension from
  /// double-counting payroll against the staff cap.
  Team? sign({
    required Team team,
    required StaffMember member,
    required StaffOffer offer,
  }) {
    final existing = team.staff.canonicalMember(member.role);
    if (existing != null && existing.id != member.id) return null;
    final replacingSalary = existing?.contract?.salary ?? 0;
    if (!canHire(team, offer.salary, replacingSalary: replacingSalary)) {
      return null;
    }
    final signed = member.copyWith(
      contract: StaffContract(
        salary: offer.salary,
        yearsRemaining: offer.years,
      ),
    );
    return team.copyWith(staff: team.staff.withMember(member.role, signed));
  }

  /// Returns `null` if hiring would exceed the staff salary cap, the salary
  /// range, or the role slot is already filled. Extensions use [sign]
  /// directly so this compatibility API remains a new-hire-only operation.
  Team? hire({
    required Team team,
    required StaffMember member,
    required StaffOffer offer,
  }) {
    if (team.staff.canonicalMember(member.role) != null) return null;
    return sign(team: team, member: member, offer: offer);
  }

  /// V1 does not allow terminating an active staff contract. Retirement or
  /// expiry paths remove staff elsewhere in the season pipeline.
  Team fire(Team team, StaffRole role) {
    final member = team.staff.canonicalMember(role);
    if (member?.contract != null && member!.contract!.yearsRemaining > 0) {
      return team;
    }
    return team.copyWith(staff: team.staff.withMember(role, null));
  }

  /// Rozwój ★ (35–45) i emerytury (55–60), raz na sezon, po finale przed
  /// Awards (`docs/staff_rules.md` §6–7).
  LeagueState growthAndRetireTick(LeagueState league) {
    var state = league;
    for (final team in league.teams) {
      var staff = team.staff;
      var changed = false;
      for (final role in StaffRole.values) {
        final member = staff.canonicalMember(role);
        if (member == null) continue;

        final baseline = member.copyWith(previousAttributes: member.attributes);
        staff = staff.withMember(role, baseline);
        changed = true;

        if (member.age >= balance.staff.retireAgeMin) {
          final chance = balance.staff.retireChanceForAge(member.age);
          if (_random.nextDouble() < chance) {
            staff = staff.withMember(role, null);
            state = _msg(
              state,
              MessageType.retirementStaff,
              'Odejście sztabu: ${member.name}',
              '${team.name}: ${member.role.name} (${member.age} lat) kończy pracę.',
            );
            continue;
          }
        }

        if (member.age >= balance.staff.growthAgeMin &&
            member.age <= balance.staff.growthAgeMax) {
          final chance = balance.staff.growthChanceForAge(member.age);
          if (_random.nextDouble() < chance) {
            final grown = baseline.copyWith(
              attributes: _bumpAttribute(baseline.attributes, baseline.role),
            );
            staff = staff.withMember(role, grown);
            state = _msg(
              state,
              MessageType.staffGrowth,
              'Rozwój sztabu: ${member.name}',
              '${team.name}: ${member.role.name} zyskuje ★.',
            );
          }
        }
      }
      if (changed) {
        state = state.updateTeam(team.copyWith(staff: staff));
      }
    }
    return state;
  }

  StaffAttributes _bumpAttribute(StaffAttributes a, StaffRole role) {
    double up(double v) => (v + balance.staff.starStep).clamp(
      balance.staff.starMin,
      balance.staff.starMax,
    );
    return switch (role) {
      // `docs/staff.md` §5: only Tactics and Motivation are role-relevant for
      // the head coach, so growth never touches the legacy `development` field.
      StaffRole.headCoach =>
        _random.nextBool()
            ? a.copyWith(tactics: up(a.tactics))
            : a.copyWith(motivation: up(a.motivation)),
      StaffRole.youthCoach =>
        _random.nextBool()
            ? a.copyWith(development: up(a.development))
            : a.copyWith(mentoring: up(a.mentoring)),
      StaffRole.scout =>
        _random.nextBool()
            ? a.copyWith(coverage: up(a.coverage))
            : a.copyWith(evaluation: up(a.evaluation)),
      StaffRole.physio =>
        _random.nextBool()
            ? a.copyWith(rehabilitation: up(a.rehabilitation))
            : a.copyWith(regenaration: up(a.regenaration)),
      StaffRole.doctor =>
        _random.nextBool()
            ? a.copyWith(prevention: up(a.prevention))
            : a.copyWith(care: up(a.care)),
      StaffRole.cfo => a.copyWith(negotiation: up(a.negotiation)),
    };
  }

  LeagueState _msg(
    LeagueState league,
    MessageType type,
    String title,
    String body,
  ) {
    return _messages.send(
      league,
      type: type,
      domain: MessageDomain.staff,
      titleKey: 'msg_${type.name}_title',
      bodyKey: 'msg_${type.name}_body',
      args: {'_legacyTitle': title, '_legacyBody': body},
    );
  }
}
