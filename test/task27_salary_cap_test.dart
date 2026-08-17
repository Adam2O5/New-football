import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/staff_service.dart';

void main() {
  const balance = BalanceConfig.defaults;
  final sourceLeague = SeedDataGenerator().generateLeague(
    year: 2026,
    seed: 2701,
  );
  final sourceTeam = sourceLeague.teams.first;
  const capService = SalaryCapService();

  test('Task 27 finance defaults are synchronized and tax-free', () {
    expect(balance.salaryCap.salaryCap, 350000000);
    expect(balance.salaryCap.firstApron, 396700000);
    expect(balance.salaryCap.secondApron, 431700000);
    expect(balance.salaryCap.minSalary, 1000000);
    expect(balance.salaryCap.maxSalary, 60000000);
    expect(balance.salaryCap.rookiePickDecay, 0.06);
    expect(balance.staff.salaryCap, 15000000);
    expect(balance.staff.minSalary, 500000);
    expect(balance.staff.maxSalary, 5000000);

    const finance = TeamFinance();
    expect(finance.salaryCap, 350000000);
    expect(finance.firstApron, 396700000);
    expect(finance.secondApron, 431700000);
  });

  test('rookie scale uses 0.06 decay at pick 1 and pick 30', () {
    expect(balance.salaryCap.rookieSalaryForPick(1), 7547170);
    expect(balance.salaryCap.rookieSalaryForPick(30), 2857143);
    expect(
      capService
          .termsFor(
            player: _playerWith(
              sourceTeam.roster.first,
              contract: const Contract(salary: 7547169, yearsRemaining: 0),
            ),
            exception: CapExceptionType.rookieScale,
            rookiePickSlot: 1,
          )
          .maxSalary,
      7547170,
    );
  });

  test(
    'trade matching applies cap space, 125 percent, no aggregation and apron hard cap',
    () {
      final underCap = _teamWithPayroll(sourceTeam, 340000000);
      final overCap = _teamWithPayroll(sourceTeam, 360000000);
      final betweenAprons = _teamWithPayroll(sourceTeam, 400000000);
      final secondApron = _teamWithPayroll(sourceTeam, 440000000);

      expect(
        capService
            .tradeMatching(
              team: underCap,
              outgoingSalary: 10000000,
              incomingSalary: 20000000,
            )
            .allowed,
        isTrue,
      );
      expect(
        capService
            .tradeMatching(
              team: overCap,
              outgoingSalary: 10000000,
              incomingSalary: 13000000,
            )
            .allowed,
        isTrue,
      );
      expect(
        capService
            .tradeMatching(
              team: overCap,
              outgoingSalary: 10000000,
              incomingSalary: 13000001,
            )
            .allowed,
        isFalse,
      );

      final noAggregation = capService.tradeMatching(
        team: betweenAprons,
        outgoingSalary: 20000000,
        outgoingSalaries: const [10000000, 10000000],
        incomingSalary: 25000000,
      );
      expect(noAggregation.aggregationAllowed, isFalse);
      expect(noAggregation.allowed, isFalse);

      expect(
        capService
            .tradeMatching(
              team: secondApron,
              outgoingSalary: 10000000,
              incomingSalary: 10000000,
            )
            .allowed,
        isTrue,
      );
      expect(
        capService
            .tradeMatching(
              team: secondApron,
              outgoingSalary: 10000000,
              incomingSalary: 10000001,
            )
            .allowed,
        isFalse,
      );
      expect(
        capService
            .tradeMatching(
              team: secondApron,
              outgoingSalary: 10000000,
              incomingSalary: 10000000,
              incomingFirstRoundPicks: 1,
            )
            .allowed,
        isFalse,
      );
    },
  );

  test('all documented exception formulas validate their limits', () {
    final rookie = _playerWith(
      sourceTeam.roster.first,
      contract: const Contract(
        salary: 8000000,
        yearsRemaining: 1,
        isRookieScale: true,
        rookiePickSlot: 1,
      ),
      seasonsWithTeam: 1,
    );
    expect(
      capService
          .validateExceptionOffer(
            player: rookie,
            exception: CapExceptionType.rookieExtension,
            salary: 60000000,
            years: 5,
          )
          .ok,
      isTrue,
    );
    expect(
      capService
          .validateExceptionOffer(
            player: rookie.copyWith(
              contract: rookie.contract.copyWith(yearsRemaining: 0),
            ),
            exception: CapExceptionType.qualifyingOffer,
            salary: 10000000,
            years: 5,
          )
          .ok,
      isTrue,
    );

    final fullBird = _playerWith(
      sourceTeam.roster.first,
      contract: const Contract(salary: 10000000, yearsRemaining: 1),
      seasonsWithTeam: 3,
    );
    expect(
      capService
          .validateExceptionOffer(
            player: fullBird,
            exception: CapExceptionType.fullBirdRights,
            salary: 60000000,
            years: 5,
          )
          .ok,
      isTrue,
    );

    final earlyBird = _playerWith(
      sourceTeam.roster.first,
      contract: const Contract(salary: 10000000, yearsRemaining: 1),
      seasonsWithTeam: 2,
    );
    expect(
      capService
          .validateExceptionOffer(
            player: earlyBird,
            exception: CapExceptionType.earlyBirdRights,
            salary: 17500000,
            years: 4,
          )
          .ok,
      isTrue,
    );
    expect(
      capService
          .validateExceptionOffer(
            player: earlyBird,
            exception: CapExceptionType.earlyBirdRights,
            salary: 17500001,
            years: 4,
          )
          .ok,
      isFalse,
    );

    final nonBird = _playerWith(
      sourceTeam.roster.first,
      contract: const Contract(salary: 10000000, yearsRemaining: 1),
      seasonsWithTeam: 1,
    );
    expect(
      capService
          .validateExceptionOffer(
            player: nonBird,
            exception: CapExceptionType.nonBirdRights,
            salary: 12000000,
            years: 4,
          )
          .ok,
      isTrue,
    );
    expect(
      capService
          .validateExceptionOffer(
            player: nonBird,
            exception: CapExceptionType.nonBirdRights,
            salary: 12000001,
            years: 4,
          )
          .ok,
      isFalse,
    );

    final veteran = _playerWith(
      sourceTeam.roster.first,
      contract: const Contract(salary: 10000000, yearsRemaining: 1),
      seasonsWithTeam: 4,
    );
    expect(
      capService
          .validateExceptionOffer(
            player: veteran,
            exception: CapExceptionType.veteranExtensionRaiseCap,
            salary: 10800000,
            years: 5,
          )
          .ok,
      isTrue,
    );
    expect(
      capService
          .validateExceptionOffer(
            player: veteran,
            exception: CapExceptionType.veteranExtensionRaiseCap,
            salary: 10800001,
            years: 5,
          )
          .ok,
      isFalse,
    );
  });

  test(
    'ContractService replaces an existing player for a Full Bird extension',
    () {
      final player = _playerWith(
        sourceTeam.roster.first,
        contract: const Contract(salary: 10000000, yearsRemaining: 1),
        seasonsWithTeam: 3,
      );
      final team = _teamWithPayroll(
        sourceTeam.copyWith(roster: [player, ...sourceTeam.roster.skip(1)]),
        400000000,
      );
      final signed = ContractService().signPlayer(
        team: team,
        player: player,
        offer: const ContractOffer(
          salary: 60000000,
          years: 5,
          exception: CapExceptionType.fullBirdRights,
        ),
      );

      expect(signed, isNotNull);
      expect(signed!.roster.length, team.roster.length);
      expect(signed.roster.first.contract.salary, 60000000);
      expect(
        signed.roster.first.contract.exceptionType,
        CapExceptionType.fullBirdRights,
      );
    },
  );

  test('staff salaries enforce the 0.5M–5M range and 15M cap', () {
    final staff = StaffService();
    expect(staff.isSalaryInRange(500000), isTrue);
    expect(staff.isSalaryInRange(5000000), isTrue);
    expect(staff.isSalaryInRange(499999), isFalse);
    expect(staff.isSalaryInRange(5000001), isFalse);
    expect(staff.canHire(sourceTeam, 499999), isFalse);

    final nearCap = sourceTeam.copyWith(
      staff: TeamStaff(
        headCoach: const StaffMember(
          id: 'cap-hc',
          name: 'Cap HC',
          nationality: Nationality.poland,
          age: 40,
          role: StaffRole.headCoach,
          contract: StaffContract(salary: 5000000, yearsRemaining: 1),
        ),
        youthCoach: const StaffMember(
          id: 'cap-youth',
          name: 'Cap Youth',
          nationality: Nationality.poland,
          age: 40,
          role: StaffRole.youthCoach,
          contract: StaffContract(salary: 5000000, yearsRemaining: 1),
        ),
        scout: const StaffMember(
          id: 'cap-scout',
          name: 'Cap Scout',
          nationality: Nationality.poland,
          age: 40,
          role: StaffRole.scout,
          contract: StaffContract(salary: 5000000, yearsRemaining: 1),
        ),
      ),
    );
    expect(staff.canHire(nearCap, 500000), isFalse);
  });

  test('TV schedule is deterministic, persisted, and updates only once', () {
    final scheduleA = tvCapScheduleFor(currentYear: 2026, saveSeed: 2701);
    final scheduleB = tvCapScheduleFor(currentYear: 2026, saveSeed: 2701);
    expect(scheduleA.nextTvCapResetSeason, scheduleB.nextTvCapResetSeason);
    expect(scheduleA.nextTvCapIncreasePct, scheduleB.nextTvCapIncreasePct);
    expect(scheduleA.nextTvCapResetSeason, inInclusiveRange(2031, 2033));
    expect(scheduleA.nextTvCapIncreasePct, inInclusiveRange(4, 12));

    final initial = sourceLeague.copyWith(
      currentWeek: 44,
      currentDay: 1,
      currentSeason: sourceLeague.currentSeason.copyWith(
        nextTvCapResetSeason: sourceLeague.currentSeason.year,
        nextTvCapIncreasePct: 10,
        capUpdateTvDone: false,
      ),
    );
    final updated = SeasonService().runCapUpdateTv(initial, saveSeed: 2701);
    final updatedTeam = updated.teams.first;
    expect(updatedTeam.finance.salaryCap, 385000000);
    expect(updatedTeam.finance.firstApron, 436370000);
    expect(updatedTeam.finance.secondApron, 474870000);
    expect(
      updatedTeam.finance.totalPayroll,
      initial.teams.first.finance.totalPayroll,
    );
    expect(updated.currentSeason.capUpdateTvDone, isTrue);
    expect(
      updated.inbox.messages.where((m) => m.type == MessageType.capUpdateTv),
      hasLength(1),
    );

    final repeated = SeasonService().runCapUpdateTv(updated, saveSeed: 2701);
    expect(
      repeated.inbox.messages.where((m) => m.type == MessageType.capUpdateTv),
      hasLength(1),
    );

    final restored = LeagueState.fromJson(
      jsonDecode(jsonEncode(updated.toJson())) as Map<String, dynamic>,
    );
    expect(
      restored.currentSeason.nextTvCapResetSeason,
      updated.currentSeason.nextTvCapResetSeason,
    );
    expect(
      restored.currentSeason.nextTvCapIncreasePct,
      updated.currentSeason.nextTvCapIncreasePct,
    );
    expect(restored.teams.first.finance.salaryCap, 385000000);
  });
}

Player _playerWith(
  Player player, {
  required Contract contract,
  int? seasonsWithTeam,
}) => player.copyWith(
  contract: contract,
  state: player.state.copyWith(
    seasonsWithTeam: seasonsWithTeam ?? player.state.seasonsWithTeam,
  ),
);

Team _teamWithPayroll(Team team, int payroll) {
  final perPlayer = payroll ~/ team.roster.length;
  var remainder = payroll - perPlayer * team.roster.length;
  final roster = team.roster.map((player) {
    final salary = perPlayer + (remainder-- > 0 ? 1 : 0);
    return player.copyWith(contract: player.contract.copyWith(salary: salary));
  }).toList();
  return team.copyWith(
    roster: roster,
    finance: team.finance.copyWith(
      totalPayroll: payroll,
      salaryCap: 350000000,
      firstApron: 396700000,
      secondApron: 431700000,
    ),
  );
}

Matcher inInclusiveRange(num min, num max) =>
    allOf(greaterThanOrEqualTo(min), lessThanOrEqualTo(max));
