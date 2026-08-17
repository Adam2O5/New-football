import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/message_service.dart';

enum StaffReaction { accept, hardReject, waiting, counter }

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

  double marketSalary(StaffMember member) =>
      balance.staff.salaryFor(member.role, member.overall);

  /// Uproszczony `staffWant` (0–100 score, `contract_signing.md` §7):
  /// baseline ~55, podniesiony dla starszego sztabu preferującego krótsze
  /// kontrakty.
  double staffWant(StaffMember member) {
    var want = 55.0;
    if (member.age >= 55) want += 5;
    return want;
  }

  double staffOfferScore(StaffMember member, StaffOffer offer) {
    final salaryFit = (offer.salary / marketSalary(member)).clamp(0.0, 1.4);
    final yearsFit = member.age >= 55
        ? (offer.years <= 2 ? 1.1 : 0.7)
        : (offer.years >= 2 && offer.years <= 4 ? 1.05 : 0.9);
    const mandateFit = 1.0;
    const clubFit = 1.0;
    return 100 *
        (0.55 * salaryFit +
            0.25 * yearsFit +
            0.15 * mandateFit +
            0.05 * clubFit);
  }

  StaffReaction evaluateOffer(StaffMember member, StaffOffer offer) {
    final c = balance.contracts;
    final gap = staffOfferScore(member, offer) - staffWant(member);
    final noise = (_random.nextDouble() * 2 - 1) * c.staffNoiseAbs;
    final g = gap + noise;
    if (g >= c.staffAcceptGap) return StaffReaction.accept;
    if (g >= -6) return StaffReaction.counter;
    if (g >= c.staffHardRejectGap) return StaffReaction.waiting;
    return StaffReaction.hardReject;
  }

  StaffOffer counterOffer(StaffMember member, StaffOffer offer) {
    final want = marketSalary(member);
    final mult = 1.03 + _random.nextDouble() * 0.07;
    final salary = max(offer.salary, (want * mult).round());
    final years = member.age >= 55 ? min(offer.years, 2) : max(offer.years, 2);
    return StaffOffer(salary: salary, years: years);
  }

  bool isSalaryInRange(int salary) =>
      salary >= balance.staff.minSalary && salary <= balance.staff.maxSalary;

  String? hireValidationReason(Team team, int salary) {
    if (!isSalaryInRange(salary)) {
      return 'Pensja sztabu musi mieścić się w zakresie '
          '${balance.staff.minSalary}–${balance.staff.maxSalary}';
    }
    if (team.staff.totalSalary + salary > balance.staff.salaryCap) {
      return 'Przekroczony staff salary cap';
    }
    return null;
  }

  bool canHire(Team team, int salary) =>
      hireValidationReason(team, salary) == null;

  /// Returns `null` if hiring would exceed the staff salary cap, the salary
  /// range, or the role slot is already filled.
  Team? hire({
    required Team team,
    required StaffMember member,
    required StaffOffer offer,
  }) {
    if (team.staff.member(member.role) != null) return null;
    if (!canHire(team, offer.salary)) return null;
    final hired = member.copyWith(
      contract: StaffContract(
        salary: offer.salary,
        yearsRemaining: offer.years,
      ),
    );
    return team.copyWith(staff: team.staff.withMember(member.role, hired));
  }

  /// V1 does not allow terminating an active staff contract. Retirement or
  /// expiry paths remove staff elsewhere in the season pipeline.
  Team fire(Team team, StaffRole role) {
    final member = team.staff.member(role);
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
        final member = staff.member(role);
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
      StaffRole.headCoach => switch (_random.nextInt(3)) {
        0 => a.copyWith(tactics: up(a.tactics)),
        1 => a.copyWith(motivation: up(a.motivation)),
        _ => a.copyWith(development: up(a.development)),
      },
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
