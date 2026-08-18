import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/staff_service.dart';

void main() {
  const balance = BalanceConfig.defaults;
  final league = SeedDataGenerator().generateLeague(seed: 28);

  test('canonical negotiation bands have no overlapping boundaries', () {
    const phase = NegotiationPhase.contractExtension;
    final random = Random(28);

    expect(
      NegotiationRules.decisionForScore(
        score: 24,
        phase: phase,
        random: random,
      ),
      NegotiationDecision.hardReject,
    );
    expect(
      NegotiationRules.decisionForScore(
        score: 25,
        phase: phase,
        random: random,
      ),
      NegotiationDecision.reject,
    );
    expect(
      NegotiationRules.decisionForScore(
        score: 39,
        phase: phase,
        random: random,
      ),
      NegotiationDecision.reject,
    );
    expect(
      NegotiationRules.decisionForScore(
        score: 40,
        phase: phase,
        random: random,
      ),
      NegotiationDecision.counter,
    );
    expect(
      NegotiationRules.decisionForScore(
        score: 54,
        phase: phase,
        random: random,
      ),
      NegotiationDecision.counter,
    );
    expect(
      NegotiationRules.decisionForScore(
        score: 55,
        phase: phase,
        random: random,
      ),
      anyOf(NegotiationDecision.counter, NegotiationDecision.accept),
    );
    expect(
      NegotiationRules.decisionForScore(
        score: 69,
        phase: phase,
        random: random,
      ),
      anyOf(NegotiationDecision.counter, NegotiationDecision.accept),
    );
    expect(
      NegotiationRules.decisionForScore(
        score: 70,
        phase: phase,
        random: random,
      ),
      NegotiationDecision.accept,
    );
  });

  test('mixed band is 50/50 at 62 with three-point slope', () {
    expect(NegotiationRules.mixedAcceptProbability(55), closeTo(0.29, 0.0001));
    expect(NegotiationRules.mixedAcceptProbability(62), closeTo(0.50, 0.0001));
    expect(NegotiationRules.mixedAcceptProbability(69), closeTo(0.71, 0.0001));
  });

  test('playerWant and staffWant follow documented formulas', () {
    final player = league.teams.first.roster.first.copyWith(
      pointValue: 400,
      personality: PlayerPersonality.leader,
    );
    final playerService = ContractService();
    expect(
      playerService.playerWant(player, currentTeamStatus: TeamStatus.contender),
      76,
    );

    const staff = StaffMember(
      id: 'task28-staff',
      name: 'Task 28 Staff',
      nationality: Nationality.poland,
      age: 40,
      role: StaffRole.headCoach,
      attributes: StaffAttributes(tactics: 4, motivation: 4),
    );
    final staffService = StaffService();
    expect(
      staffService.staffWant(staff, currentTeamStatus: TeamStatus.elite),
      87,
    );
  });

  test('expected salary and length use want and age tables', () {
    final player = league.teams.first.roster.first.copyWith(
      age: 25,
      pointValue: 0,
      personality: PlayerPersonality.balanced,
    );
    final playerService = ContractService();
    final expectedPlayerSalary =
        balance.salaryCap.minSalary +
        (balance.salaryCap.maxSalary - balance.salaryCap.minSalary) *
            0.5 *
            0.5 *
            0.5;
    expect(playerService.expectedSalary(player), expectedPlayerSalary.round());
    expect(playerService.expectedLength(player), 3);

    const staff = StaffMember(
      id: 'task28-staff-salary',
      name: 'Task 28 Staff Salary',
      nationality: Nationality.poland,
      age: 40,
      role: StaffRole.headCoach,
      attributes: StaffAttributes(tactics: 4, motivation: 4),
    );
    final staffService = StaffService();
    final staffWant = staffService.staffWant(
      staff,
      currentTeamStatus: TeamStatus.elite,
    );
    final normalizedWant = staffWant / 100;
    final expectedStaffSalary =
        balance.staff.minSalary +
        (balance.staff.maxSalary - balance.staff.minSalary) *
            normalizedWant *
            normalizedWant;
    expect(
      staffService.expectedSalary(staff, currentTeamStatus: TeamStatus.elite),
      expectedStaffSalary.round(),
    );
    expect(
      staffService.expectedLength(staff, currentTeamStatus: TeamStatus.elite),
      4,
    );
  });

  test('CFO negotiation table maps every half-star value', () {
    expect(NegotiationRules.cfoDiscount(null), 0.95);
    expect(NegotiationRules.cfoDiscount(0), 0.95);
    expect(NegotiationRules.cfoDiscount(0.5), 1.00);
    expect(NegotiationRules.cfoDiscount(2.5), 1.05);
    expect(NegotiationRules.cfoDiscount(5.0), 1.13);
  });

  test('counter offers provide exactly three rounds and documented ranges', () {
    final player = league.teams.first.roster.first.copyWith(
      pointValue: 0,
      personality: PlayerPersonality.balanced,
    );
    final playerService = ContractService();
    final playerOffer = ContractOffer(
      salary: playerService.expectedSalary(player),
      years: playerService.expectedLength(player),
    );
    final playerCounters = [
      for (var round = 1; round <= 3; round++)
        playerService.counterOfferForRound(player, playerOffer, round: round)!,
    ];
    expect(playerCounters, hasLength(3));
    expect(
      playerService.counterOfferForRound(player, playerOffer, round: 4),
      isNull,
    );
    expect(
      playerService.playerOfferScore(player, playerCounters[0]),
      inInclusiveRange(65, 100),
    );
    expect(
      playerService.playerOfferScore(player, playerCounters[1]),
      inInclusiveRange(65, 85),
    );
    expect(
      playerService.playerOfferScore(player, playerCounters[2]),
      inInclusiveRange(60, 70),
    );

    final staff = const StaffMember(
      id: 'task28-counter-staff',
      name: 'Task 28 Counter Staff',
      nationality: Nationality.poland,
      age: 40,
      role: StaffRole.headCoach,
      attributes: StaffAttributes(tactics: 4, motivation: 4),
    );
    final staffService = StaffService();
    final staffOffer = StaffOffer(
      salary: staffService.expectedSalary(staff),
      years: staffService.expectedLength(staff),
    );
    expect(
      staffService.counterOfferForRound(staff, staffOffer, round: 1),
      isNotNull,
    );
    expect(
      staffService.counterOfferForRound(staff, staffOffer, round: 4),
      isNull,
    );

    expect(playerService.counterHardRejectChance(1), 0.15);
    expect(playerService.counterHardRejectChance(2), 0.30);
    expect(playerService.counterHardRejectChance(3), 0.50);
    expect(staffService.counterHardRejectChance(3), 0.50);
  });

  test('negotiation models round-trip through JSON', () {
    const negotiation = ContractNegotiation(
      id: 'task28-json',
      subjectId: 'player-1',
      subjectKind: NegotiationSubjectKind.player,
      teamId: 'team-1',
      phase: NegotiationPhase.freeAgencyPhaseII,
      round: 2,
      lastOffer: NegotiationOffer(
        salary: 12000000,
        years: 4,
        exception: CapExceptionType.birdRights,
      ),
      counterOffer: NegotiationOffer(salary: 14000000, years: 4),
      status: NegotiationStatus.pendingFinalization,
      seasonYear: 2026,
      week: 50,
      day: 3,
      hour: 4,
      expirySeasonYear: 2026,
      expiryWeek: 50,
      expiryDay: 6,
      expiryHour: 4,
      requiresFinalization: true,
    );
    final encoded =
        jsonDecode(jsonEncode(negotiation.toJson())) as Map<String, dynamic>;
    expect(ContractNegotiation.fromJson(encoded), negotiation);
  });

  test('hard reject creates a 30-day subject-club block', () {
    final service = NegotiationService();
    final block = service.blockFor(
      subjectId: 'player-1',
      subjectKind: NegotiationSubjectKind.player,
      teamId: 'team-1',
      seasonYear: 2026,
      week: 10,
      day: 1,
    );
    final state = league.copyWith(negotiationBlocks: [block]);
    expect(
      service.isBlocked(
        league: state,
        subjectId: 'player-1',
        subjectKind: NegotiationSubjectKind.player,
        teamId: 'team-1',
        seasonYear: 2026,
        week: 10,
        day: 1,
      ),
      isTrue,
    );
    expect(
      service.isBlocked(
        league: state,
        subjectId: 'player-1',
        subjectKind: NegotiationSubjectKind.player,
        teamId: 'team-1',
        seasonYear: 2026,
        week: block.untilWeek,
        day: block.untilDay + 1,
      ),
      isFalse,
    );
  });

  test(
    'finalization timeout hard-rejects and rival selection does not block',
    () {
      final service = NegotiationService();
      final started = service.start(
        id: 'task28-timeout',
        subjectId: 'player-timeout',
        subjectKind: NegotiationSubjectKind.player,
        teamId: 'team-timeout',
        phase: NegotiationPhase.contractExtension,
        offer: const NegotiationOffer(salary: 10000000, years: 3),
        seasonYear: 2026,
        week: 10,
        day: 1,
      );
      final pending = service.applyDecision(
        negotiation: started,
        decision: NegotiationDecision.accept,
        seasonYear: 2026,
        week: 10,
        day: 1,
      );
      final timedOut = service.expireAt(
        league: league.copyWith(negotiations: [pending]),
        seasonYear: 2026,
        week: pending.expiryWeek,
        day: pending.expiryDay,
        hour: pending.expiryHour,
      );
      expect(
        timedOut.negotiationById('task28-timeout')!.status,
        NegotiationStatus.hardRejected,
      );
      expect(timedOut.negotiationBlocks, hasLength(1));

      final rival = pending.copyWith(
        id: 'task28-rival',
        subjectId: 'player-rival',
        selectedByRival: true,
      );
      final rivalResult = service.expireAt(
        league: league.copyWith(negotiations: [rival]),
        seasonYear: 2026,
        week: rival.expiryWeek,
        day: rival.expiryDay,
        hour: rival.expiryHour,
      );
      expect(
        rivalResult.negotiationById('task28-rival')!.status,
        NegotiationStatus.cancelled,
      );
      expect(rivalResult.negotiationBlocks, isEmpty);
    },
  );

  test('phase II negotiations cancel at the end of the FA window', () {
    final service = NegotiationService();
    final negotiation = service.start(
      id: 'task28-phase2',
      subjectId: 'player-phase2',
      subjectKind: NegotiationSubjectKind.player,
      teamId: 'team-phase2',
      phase: NegotiationPhase.freeAgencyPhaseII,
      offer: const NegotiationOffer(salary: 10000000, years: 3),
      seasonYear: 2026,
      week: 45,
      day: 6,
    );
    final result = service.expireAt(
      league: league.copyWith(negotiations: [negotiation]),
      seasonYear: 2026,
      week: balance.calendar.freeAgencyPhaseIIEndWeek,
      day: 7,
      hour: balance.contracts.hoursPerDay,
    );
    expect(
      result.negotiationById('task28-phase2')!.status,
      NegotiationStatus.cancelled,
    );
    expect(result.negotiationBlocks, isEmpty);
  });
}
