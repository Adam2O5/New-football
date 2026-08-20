import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/staff_service.dart';

import 'helpers/staff_role_ratings_test_helpers.dart';

const _featureTag =
    'Feature: staff-role-ratings, task 8.3 AI ContractMarketService integration';
const _status = TeamStatus.pretender;

void main() {
  group(_featureTag, () {
    // **Validates: Requirements 6.1-6.8, 7.4-7.5, 8.1-8.8, 10.9-10.10**
    test(
      'FA resolveDay persists the raw score, signs the selected staff, removes '
      'the candidate, and replays deterministically',
      () {
        final assistingCfo = staffCfoMember(
          negotiation: 4.0,
          index: 90,
          contract: staffFixtureContract(salary: 1000000, yearsRemaining: 2),
        );
        final candidate = staffMemberFor(
          StaffRole.headCoach,
          relevantValues: [4.5, 3.0],
          id: 'integration-fa-head-coach',
          age: 45,
        );
        final team = _aiStaffTeam(
          id: 'integration-fa-team',
          staff: TeamStaff(cfo: assistingCfo),
        );
        final state = _staffLeague(team: team, staffFreeAgents: [candidate]);
        final policy = AiContractMarketService();
        final plan = policy.staffFreeAgentPlan(
          league: state,
          team: team,
          saveSeed: staffFixtureSaveSeed,
        );

        expect(plan, isNotNull);
        if (plan == null) return;
        expect(plan.member.id, candidate.id);
        expect(plan.role, StaffRole.headCoach);
        expect(
          plan.offerScore,
          closeTo(
            _staffScoreOracle(candidate, plan.offer, cfo: assistingCfo),
            1e-9,
          ),
        );

        final market = ContractMarketService();
        final resolved = market.resolveDay(
          state,
          saveSeed: staffFixtureSaveSeed,
        );
        final replay = market.resolveDay(state, saveSeed: staffFixtureSaveSeed);

        _expectCompletedStaffNegotiation(
          resolved,
          member: candidate,
          plan: plan,
          phase: NegotiationPhase.freeAgencyPhaseI,
          expectedCfo: assistingCfo,
        );
        final signedTeam = resolved.teamById(team.id);
        expect(signedTeam, isNotNull);
        if (signedTeam == null) return;
        final signed = signedTeam.staff.member(StaffRole.headCoach);
        expect(signed?.id, candidate.id);
        expect(signed?.contract?.salary, plan.offer.salary);
        expect(signed?.contract?.yearsRemaining, plan.offer.years);
        expect(
          signedTeam.staff.totalSalary,
          assistingCfo.contract!.salary + plan.offer.salary,
        );
        expect(
          resolved.staffFreeAgents.any((member) => member.id == candidate.id),
          isFalse,
        );
        expect(
          resolved.currentHour,
          BalanceConfig.defaults.contracts.hoursPerDay,
        );
        expect(
          _marketProjection(replay),
          _marketProjection(resolved),
          reason: 'same AI staff day/seed did not replay the persisted flow',
        );
      },
    );

    // **Validates: Requirements 5.1-5.5, 8.1-8.2, 8.6-8.8, 10.9**
    test(
      'FA resolveHour keeps configured role priority, raw ordering, ID ties, '
      'and mismatch exclusion',
      () {
        final rawHighHead = staffMemberFor(
          StaffRole.headCoach,
          attributes: staffAttributesWithRawOverall(StaffRole.headCoach, 3.30),
          id: 'z-head-3-30',
        );
        final rawLowHead = staffMemberFor(
          StaffRole.headCoach,
          attributes: staffAttributesWithRawOverall(StaffRole.headCoach, 3.25),
          id: 'a-head-3-25',
        );
        final higherPriorityCompetition = staffMemberFor(
          StaffRole.doctor,
          relevantValues: [5.0, 5.0],
          id: 'a-doctor-5-00',
        );
        final mismatched = staffRoleMismatchedMember(
          StaffRole.headCoach,
          declaredRole: StaffRole.doctor,
          index: 700,
        );
        final team = _aiStaffTeam(id: 'integration-order-team');
        final state = _staffLeague(
          team: team,
          staffFreeAgents: [
            higherPriorityCompetition,
            rawLowHead,
            mismatched,
            rawHighHead,
          ],
        );
        final policy = AiContractMarketService();
        final plan = policy.staffFreeAgentPlan(
          league: state,
          team: team,
          saveSeed: staffFixtureSaveSeed + 1,
        );

        expect(plan, isNotNull);
        if (plan == null) return;
        expect(
          plan.member.id,
          rawHighHead.id,
          reason:
              'AI selected by global/rounded rating instead of role priority, '
              'raw order, and canonical role filtering',
        );
        expect(plan.role, StaffRole.headCoach);
        expect(
          plan.offerScore,
          closeTo(_staffScoreOracle(rawHighHead, plan.offer), 1e-9),
        );

        final resolved = ContractMarketService().resolveHour(
          state,
          hour: 1,
          saveSeed: staffFixtureSaveSeed + 1,
        );
        final negotiation = _staffNegotiationFor(resolved, rawHighHead.id);
        expect(negotiation?.status, NegotiationStatus.completed);
        expect(resolved.teamById(team.id)?.staff.headCoach?.id, rawHighHead.id);
        expect(
          resolved.staffFreeAgents.any(
            (member) => member.id == higherPriorityCompetition.id,
          ),
          isTrue,
          reason: 'one hourly slot must not sign the lower-priority role',
        );
        expect(
          resolved.staffFreeAgents.any((member) => member.id == rawLowHead.id),
          isTrue,
        );
        expect(
          resolved.staffFreeAgents.any((member) => member.id == mismatched.id),
          isTrue,
        );

        final tieA = staffMemberFor(
          StaffRole.headCoach,
          relevantValues: [3.0, 3.0],
          id: 'a-head-tie',
        );
        final tieZ = staffMemberFor(
          StaffRole.headCoach,
          relevantValues: [3.0, 3.0],
          id: 'z-head-tie',
        );
        final tieTeam = _aiStaffTeam(id: 'integration-tie-team');
        final tieState = _staffLeague(
          team: tieTeam,
          staffFreeAgents: [tieZ, tieA],
        );
        final tiePlan = policy.staffFreeAgentPlan(
          league: tieState,
          team: tieTeam,
          saveSeed: staffFixtureSaveSeed + 2,
        );
        expect(tiePlan?.member.id, tieA.id);

        final tieResolved = ContractMarketService().resolveHour(
          tieState,
          hour: 1,
          saveSeed: staffFixtureSaveSeed + 2,
        );
        expect(
          _staffNegotiationFor(tieResolved, tieA.id)?.status,
          NegotiationStatus.completed,
        );
        expect(tieResolved.teamById(tieTeam.id)?.staff.headCoach?.id, tieA.id);
        expect(
          tieResolved.staffFreeAgents.map((member) => member.id),
          contains(tieZ.id),
        );
      },
    );

    // **Validates: Requirements 7.4-7.8, 8.3-8.6, 10.9**
    test(
      'extension resolveHour signs a CFO with no self-assisting CFO and replaces '
      'the old payroll entry',
      () {
        final member = staffCfoMember(
          negotiation: 1.0,
          irrelevantValue: 5.0,
          age: 45,
          contract: staffFixtureContract(salary: 1000000, yearsRemaining: 1),
        );
        final team = _aiStaffTeam(
          id: 'integration-cfo-extension-team',
          staff: TeamStaff(cfo: member),
        );
        final state = _staffLeague(team: team, extension: true);
        final policy = AiContractMarketService();
        AiStaffOfferPlan? plan;
        var selectedSeed = -1;
        for (var seed = 0; seed < 2000; seed++) {
          final candidate = policy.staffExtensionPlan(
            league: state,
            team: team,
            saveSeed: seed,
          );
          if (candidate != null) {
            plan = candidate;
            selectedSeed = seed;
            break;
          }
        }

        expect(
          plan,
          isNotNull,
          reason: 'no deterministic CFO renewal seed found',
        );
        if (plan == null) return;
        expect(plan.isExtension, isTrue);
        expect(plan.role, StaffRole.cfo);
        expect(plan.member.id, member.id);
        final noCfoScore = _staffScoreOracle(member, plan.offer);
        final selfAssistedScore = _staffScoreOracle(
          member,
          plan.offer,
          cfo: member,
        );
        expect(plan.offerScore, closeTo(noCfoScore, 1e-9));
        expect(
          plan.offerScore,
          isNot(closeTo(selfAssistedScore, 1e-9)),
          reason: 'CFO subject was used as its own assisting CFO',
        );

        final resolved = ContractMarketService().resolveHour(
          state,
          hour: 1,
          saveSeed: selectedSeed,
        );
        _expectCompletedStaffNegotiation(
          resolved,
          member: member,
          plan: plan,
          phase: NegotiationPhase.contractExtension,
        );
        final signed = resolved.teamById(team.id)?.staff.cfo;
        expect(signed?.id, member.id);
        expect(signed?.contract?.salary, plan.offer.salary);
        expect(signed?.contract?.yearsRemaining, plan.offer.years);
        expect(
          resolved.teamById(team.id)?.staff.totalSalary,
          plan.offer.salary,
          reason: 'extension must replace, not add to, the old CFO salary',
        );
      },
    );

    // **Validates: Requirements 5.5, 8.8, 9.1-9.7, 10.10**
    test('AI leaves an unavailable occupied slot untouched and hard-rejects a '
        'mismatched persisted extension without fallback assignment', () {
      final incumbent = staffMemberFor(
        StaffRole.headCoach,
        relevantValues: [3.0, 3.0],
        id: 'integration-incumbent-head',
        contract: staffFixtureContract(yearsRemaining: 2),
      );
      final freeAgent = staffMemberFor(
        StaffRole.headCoach,
        relevantValues: [5.0, 5.0],
        id: 'integration-unavailable-head',
      );
      final occupiedTeam = _aiStaffTeam(
        id: 'integration-occupied-team',
        staff: TeamStaff(headCoach: incumbent),
      );
      final occupiedState = _staffLeague(
        team: occupiedTeam,
        staffFreeAgents: [freeAgent],
      );
      final policy = AiContractMarketService();
      expect(
        policy.staffFreeAgentPlan(
          league: occupiedState,
          team: occupiedTeam,
          saveSeed: staffFixtureSaveSeed,
        ),
        isNull,
      );
      final occupiedResolved = ContractMarketService().resolveHour(
        occupiedState,
        hour: 1,
        saveSeed: staffFixtureSaveSeed,
      );
      expect(
        occupiedResolved.negotiations.where(
          (item) => item.subjectKind == NegotiationSubjectKind.staff,
        ),
        isEmpty,
      );
      expect(
        occupiedResolved.teamById(occupiedTeam.id)?.staff.headCoach?.id,
        incumbent.id,
      );
      expect(
        occupiedResolved.staffFreeAgents.map((member) => member.id),
        contains(freeAgent.id),
      );

      final mismatched =
          staffRoleMismatchedMember(
            StaffRole.headCoach,
            declaredRole: StaffRole.doctor,
            index: 810,
          ).copyWith(
            contract: staffFixtureContract(salary: 1200000, yearsRemaining: 1),
          );
      final mismatchTeam = _aiStaffTeam(
        id: 'integration-mismatch-team',
        staff: TeamStaff(headCoach: mismatched),
      );
      final mismatchBase = _staffLeague(team: mismatchTeam, extension: true);
      expect(
        policy.staffExtensionPlan(
          league: mismatchBase,
          team: mismatchTeam,
          saveSeed: staffFixtureSaveSeed,
        ),
        isNull,
      );
      final stale = ContractNegotiation(
        id: 'integration-mismatched-ai-extension',
        subjectId: mismatched.id,
        subjectKind: NegotiationSubjectKind.staff,
        teamId: mismatchTeam.id,
        phase: NegotiationPhase.contractExtension,
        lastOffer: const NegotiationOffer(salary: staffFixtureSalary, years: 1),
        status: NegotiationStatus.pendingFinalization,
        seasonYear: mismatchBase.currentSeason.year,
        week: mismatchBase.currentWeek,
        day: mismatchBase.currentDay,
        hour: 1,
        expirySeasonYear: mismatchBase.currentSeason.year,
        expiryWeek: mismatchBase.currentWeek,
        expiryDay: mismatchBase.currentDay,
        expiryHour: 1,
        requiresFinalization: true,
        isAiOffer: true,
        offerScore: 80.0,
      );
      final mismatchResolved = ContractMarketService().resolveHour(
        mismatchBase.copyWith(negotiations: [stale]),
        hour: 1,
        saveSeed: staffFixtureSaveSeed,
      );
      expect(
        mismatchResolved.negotiationById(stale.id)?.status,
        NegotiationStatus.hardRejected,
      );
      expect(
        mismatchResolved.teamById(mismatchTeam.id)?.staff.headCoach?.id,
        mismatched.id,
      );
      expect(
        mismatchResolved.teamById(mismatchTeam.id)?.staff.doctor,
        isNull,
        reason: 'mismatch must not migrate the member to its declared role',
      );
    });

    // **Validates: Requirements 7.4-7.5, 8.1-8.5, 10.9-10.10**
    test('staff market integration does not regress AI player signing', () {
      final generated = SeedDataGenerator().generateLeague(seed: 3501);
      final sourceTeam = generated.teams.firstWhere((team) => team.ai != null);
      final sourcePlayer = sourceTeam.roster.first;
      final player = _asFreeAgent(sourcePlayer, id: 'integration-player-fa');
      final team = sourceTeam.copyWith(
        roster: const [],
        finance: const TeamFinance(),
        staff: const TeamStaff(),
        ai: const TeamAiConfig(),
      );
      final state = staffFixtureLeague(
        teams: [team],
        playerTeamId: null,
        currentWeek: staffFixtureFreeAgencyWeek(),
        currentDay: 1,
        currentHour: 1,
      ).copyWith(freeAgents: [player]);
      final policy = AiContractMarketService();
      AiPlayerOfferPlan? plan;
      var selectedSeed = -1;
      for (var seed = 0; seed < 2000; seed++) {
        final candidate = policy.phaseOnePlayerPlan(
          league: state,
          team: team,
          hour: 1,
          saveSeed: seed,
        );
        if (candidate != null) {
          plan = candidate;
          selectedSeed = seed;
          break;
        }
      }

      expect(plan, isNotNull, reason: 'no deterministic player FA seed found');
      if (plan == null) return;
      final resolved = ContractMarketService().resolveDay(
        state,
        saveSeed: selectedSeed,
      );
      final negotiation = resolved.negotiations.firstWhere(
        (item) =>
            item.subjectKind == NegotiationSubjectKind.player &&
            item.subjectId == player.id,
        orElse: () =>
            throw StateError('AI player negotiation was not persisted'),
      );
      expect(negotiation.isAiOffer, isTrue);
      expect(negotiation.lastOffer.salary, plan.offer.salary);
      expect(negotiation.lastOffer.years, plan.offer.years);
      expect(negotiation.offerScore, closeTo(plan.offerScore, 1e-9));
      expect(negotiation.status, NegotiationStatus.completed);
      expect(negotiation.requiresFinalization, isFalse);
      expect(
        resolved.freeAgents.any((candidate) => candidate.id == player.id),
        isFalse,
      );
      final signed = resolved
          .teamById(team.id)
          ?.roster
          .singleWhere((candidate) => candidate.id == player.id);
      expect(signed, isNotNull);
      if (signed == null) return;
      expect(signed.contract.salary, plan.offer.salary);
      expect(signed.contract.yearsRemaining, plan.offer.years);
      expect(
        resolved.negotiations.where(
          (item) => item.subjectKind == NegotiationSubjectKind.staff,
        ),
        isEmpty,
      );
    });
  });
}

Team _aiStaffTeam({required String id, TeamStaff staff = emptyTeamStaff}) =>
    staffFixtureTeam(id: id, staff: staff, ai: const TeamAiConfig());

LeagueState _staffLeague({
  required Team team,
  List<StaffMember> staffFreeAgents = const [],
  bool extension = false,
  TeamStatus status = _status,
}) => staffFixtureLeague(
  teams: [team],
  playerTeamId: null,
  staffFreeAgents: staffFreeAgents,
  currentWeek: extension
      ? staffFixtureExtensionWeek()
      : staffFixtureFreeAgencyWeek(),
  currentDay: extension ? 2 : 1,
  currentHour: 1,
  teamStatus: status,
);

double _staffScoreOracle(
  StaffMember member,
  StaffOffer offer, {
  StaffMember? cfo,
}) {
  final raw = expectedStaffRawOverall(member.attributes, member.role);
  final want = (raw * 20.0 + NegotiationRules.teamStatusBonus(_status))
      .clamp(0.0, 100.0)
      .toDouble();
  final balance = BalanceConfig.defaults;
  final expectedSalary = _expectedStaffSalary(want);
  final expectedLength = _expectedStaffLength(want, member.age);
  final cfoRaw = cfo == null
      ? null
      : expectedStaffRawOverall(cfo.attributes, StaffRole.cfo);
  return NegotiationRules.score(
    salary: offer.salary,
    expectedSalary: expectedSalary,
    years: offer.years,
    expectedLength: expectedLength,
    offeringTeamStatus: _status,
    cfoNegotiation: cfoRaw,
    balance: balance.contracts,
  ).score;
}

int _expectedStaffSalary(double want) {
  final balance = BalanceConfig.defaults;
  final normalized = want / 100.0;
  return (balance.staff.minSalary +
          (balance.staff.maxSalary - balance.staff.minSalary) *
              normalized *
              normalized)
      .round()
      .clamp(balance.staff.minSalary, balance.staff.maxSalary);
}

int _expectedStaffLength(double want, int age) {
  final band = want <= 39
      ? 0
      : want <= 69
      ? 1
      : 2;
  if (age <= 54) return const [2, 3, 4][band];
  if (age <= 59) return const [1, 2, 2][band];
  return 1;
}

void _expectCompletedStaffNegotiation(
  LeagueState state, {
  required StaffMember member,
  required AiStaffOfferPlan plan,
  required NegotiationPhase phase,
  StaffMember? expectedCfo,
}) {
  final negotiation = _staffNegotiationFor(state, member.id);
  expect(negotiation, isNotNull);
  if (negotiation == null) return;
  expect(negotiation.subjectKind, NegotiationSubjectKind.staff);
  expect(negotiation.phase, phase);
  expect(negotiation.isAiOffer, isTrue);
  expect(negotiation.lastOffer.salary, plan.offer.salary);
  expect(negotiation.lastOffer.years, plan.offer.years);
  expect(
    negotiation.offerScore,
    closeTo(_staffScoreOracle(member, plan.offer, cfo: expectedCfo), 1e-9),
  );
  expect(negotiation.offerScore, closeTo(plan.offerScore, 1e-9));
  expect(negotiation.status, NegotiationStatus.completed);
  expect(negotiation.requiresFinalization, isFalse);
}

ContractNegotiation? _staffNegotiationFor(LeagueState state, String memberId) {
  final matches = state.negotiations
      .where(
        (item) =>
            item.subjectKind == NegotiationSubjectKind.staff &&
            item.subjectId == memberId,
      )
      .toList(growable: false);
  expect(matches.length, lessThanOrEqualTo(1));
  return matches.isEmpty ? null : matches.single;
}

String _marketProjection(LeagueState state) {
  final teams = state.teams
      .map((team) {
        final slots = StaffRole.values
            .map((role) {
              final member = team.staff.member(role);
              final contract = member?.contract;
              return '${role.name}:${member?.id ?? '-'}:${contract?.salary ?? 0}:'
                  '${contract?.yearsRemaining ?? 0}';
            })
            .join(',');
        return '${team.id}[$slots]${team.staff.totalSalary}';
      })
      .join('|');
  final staff = state.staffFreeAgents.map((member) => member.id).join(',');
  final players = state.freeAgents.map((player) => player.id).join(',');
  final negotiations = state.negotiations
      .map((negotiation) {
        return '${negotiation.id}:${negotiation.subjectKind.name}:'
            '${negotiation.subjectId}:${negotiation.lastOffer.salary}:'
            '${negotiation.lastOffer.years}:${negotiation.offerScore}:'
            '${negotiation.status.name}:${negotiation.requiresFinalization}:'
            '${negotiation.isAiOffer}';
      })
      .join('|');
  return '$teams|staff=$staff|players=$players|negotiations=$negotiations';
}

Player _asFreeAgent(Player source, {required String id}) {
  const balance = BalanceConfig.defaults;
  return source.copyWith(
    id: id,
    name: 'Integration $id',
    contract: source.contract.copyWith(
      salary: balance.salaryCap.minSalary,
      yearsRemaining: 0,
      isRookieScale: false,
      rookiePickSlot: 0,
      hasBirdRights: false,
      exceptionType: null,
      noTradeClause: false,
      blockedTeamIds: const [],
    ),
    potentialStars: 4.0,
    pointValue: 240,
    state: source.state.copyWith(seasonsWithTeam: 0),
    seasonStartOvr: source.overall(balance),
  );
}
