@Tags(['integration'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

/// Integration coverage for task 7.8.
///
/// These tests deliberately use [StaffService] and the independent fixture
/// raw oracle for domain assertions. The production presentation layer is not
/// imported, so a displayed-star regression cannot make the contract flow
/// appear correct.
void main() {
  test(
    'free-agent user flow persists raw score, honors CFO, and signs the member',
    () async {
      final role = StaffRole.headCoach;
      final assistingCfo = staffCfoMember(
        negotiation: 4.5,
        irrelevantValue: 5.0,
        index: 90,
      ).copyWith(id: 'integration-assisting-cfo');
      final actualCandidate = staffMemberFor(
        role,
        relevantValues: [4.0, 2.9],
        irrelevantValue: 0.0,
        id: 'integration-free-agent-head-coach',
        name: 'Actual free-agent coach',
      );
      final staleUiCandidate = actualCandidate.copyWith(
        name: 'Stale UI copy',
        attributes: staffAttributesForRole(role, [
          1.0,
          1.0,
        ], irrelevantValue: 5.0),
      );
      final secondCandidate = staffMemberFor(
        StaffRole.doctor,
        relevantValues: [3.0, 3.0],
        id: 'integration-hourly-guard-candidate',
      );
      final team = staffFixtureTeam(staff: TeamStaff(cfo: assistingCfo));
      final league = staffFixtureLeague(
        teams: [team],
        staffFreeAgents: [actualCandidate, secondCandidate],
      );
      final staff = StaffService();
      final offer = staffOfferFor(
        actualCandidate,
        service: staff,
        salaryFactor: 1.25,
      );
      final expectedRaw = expectedStaffRawOverall(
        actualCandidate.attributes,
        role,
      );
      final expectedScore = staff.staffOfferScore(
        actualCandidate,
        offer,
        offeringTeamStatus: TeamStatus.pretender,
        currentTeamStatus: TeamStatus.pretender,
        cfo: assistingCfo,
      );

      expect(actualCandidate.overall, expectedRaw);
      expect(league.playerTeam!.staff.member(role), isNull);
      expect(
        staff.staffOfferScore(
          actualCandidate.copyWith(
            attributes: withIrrelevantStaffAttribute(
              actualCandidate.attributes,
              role,
              value: 5.0,
            ),
          ),
          offer,
          cfo: assistingCfo,
        ),
        expectedScore,
        reason: 'irrelevant fields must not alter the persisted offer inputs',
      );
      expect(
        expectedScore,
        greaterThan(69),
        reason: 'the offer must exercise the accepted finalization path',
      );

      final container = _containerFor(_gameFor(league));
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);

      // The UI supplies a stale copy, but the market must score the member
      // currently stored in LeagueState by stable ID.
      final reaction = await controller.offerStaff(staleUiCandidate, offer);
      expect(reaction, StaffReaction.accept);
      final offered = controller.save!.leagueState;
      final negotiation = offered.negotiations.single;
      expect(negotiation.subjectKind, NegotiationSubjectKind.staff);
      expect(negotiation.subjectId, actualCandidate.id);
      expect(negotiation.offerScore, closeTo(expectedScore, 1e-9));
      expect(negotiation.status, NegotiationStatus.pendingFinalization);
      expect(negotiation.requiresFinalization, isTrue);
      expect(negotiation.lastOffer.salary, offer.salary);
      expect(negotiation.lastOffer.years, offer.years);

      // FA-I has one user staff offer per hour, even for a different role.
      final secondReaction = await controller.offerStaff(
        secondCandidate,
        staffOfferFor(secondCandidate, service: staff, salaryFactor: 1.25),
      );
      expect(secondReaction, StaffReaction.hardReject);
      expect(controller.save!.leagueState.negotiations, hasLength(1));

      final finalized = await controller.finalizeContractNegotiation(
        negotiation.id,
      );
      expect(finalized, isTrue);
      final signedState = controller.save!.leagueState;
      final signedTeam = signedState.playerTeam!;
      final signed = signedTeam.staff.member(role);
      expect(signed, isNotNull);
      expect(signed!.id, actualCandidate.id);
      expect(signed.name, actualCandidate.name);
      expect(signed.role, role);
      expect(signed.contract!.salary, offer.salary);
      expect(signed.contract!.yearsRemaining, offer.years);
      expect(signedTeam.staff.headCoach!.id, actualCandidate.id);
      expect(signedTeam.staff.cfo!.id, assistingCfo.id);
      expect(signedTeam.staff.totalSalary, offer.salary);
      expect(
        signedState.staffFreeAgents.where(
          (member) => member.id == actualCandidate.id,
        ),
        isEmpty,
      );
      expect(
        signedState.negotiationById(negotiation.id)!.status,
        NegotiationStatus.completed,
      );
    },
  );

  test(
    'FA-I waiting is resolved by the hourly user flow and recomputes raw score',
    () async {
      final candidate = staffMemberFor(
        StaffRole.doctor,
        relevantValues: [3.0, 3.0],
        id: 'integration-waiting-doctor',
      );
      final league = staffFixtureLeague(
        teams: [staffFixtureTeam()],
        staffFreeAgents: [candidate],
        teamStatus: TeamStatus.elite,
      );
      final staff = StaffService();
      final expectedSalary = staff.expectedSalary(
        candidate,
        currentTeamStatus: TeamStatus.elite,
      );
      StaffOffer? selectedOffer;
      double? selectedScore;
      for (final factor in [0.9995, 0.999, 0.9985, 0.998, 0.9975]) {
        final candidateOffer = staffOfferFor(
          candidate,
          service: staff,
          currentTeamStatus: TeamStatus.elite,
          salaryFactor: factor,
        );
        final candidateScore = staff.staffOfferScore(
          candidate,
          candidateOffer,
          offeringTeamStatus: TeamStatus.elite,
          currentTeamStatus: TeamStatus.elite,
        );
        if (candidateOffer.salary < expectedSalary &&
            candidateScore > 54 &&
            candidateScore < 70) {
          selectedOffer = candidateOffer;
          selectedScore = candidateScore;
          break;
        }
      }
      expect(selectedOffer, isNotNull);
      expect(selectedScore, isNotNull);
      final offer = selectedOffer!;
      final expectedScore = selectedScore!;

      final container = _containerFor(_gameFor(league));
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);
      final reaction = await controller.offerStaff(candidate, offer);
      expect(reaction, StaffReaction.waiting);

      final initial = controller.save!.leagueState;
      final negotiation = initial.negotiations.single;
      expect(negotiation.status, NegotiationStatus.waiting);
      expect(negotiation.waitingUntilHour, 3);
      expect(negotiation.offerScore, closeTo(expectedScore, 1e-9));

      // advanceOneHour resolves the same hourly market used by the UI. The
      // first two calls reach the persisted two-hour waiting deadline; the
      // third call evaluates the waiting record.
      for (var i = 0; i < 3; i++) {
        await controller.advanceOneHour();
      }
      final resolved = controller.save!.leagueState.negotiationById(
        negotiation.id,
      );
      expect(resolved, isNotNull);
      expect(resolved!.status, isNot(NegotiationStatus.waiting));
      expect(resolved.waitingUntilHour, isNull);
      expect(resolved.offerScore, closeTo(expectedScore, 1e-9));
      expect(
        resolved.status,
        anyOf(
          NegotiationStatus.pendingFinalization,
          NegotiationStatus.counter,
          NegotiationStatus.rejected,
          NegotiationStatus.hardRejected,
        ),
      );
      if (resolved.status == NegotiationStatus.pendingFinalization) {
        expect(resolved.requiresFinalization, isTrue);
      }
      if (resolved.status == NegotiationStatus.counter) {
        expect(resolved.counterOffer, isNotNull);
        expect(resolved.round, 2);
      }
    },
  );

  test(
    'extension counter flow signs through the controller and replaces payroll',
    () async {
      final member = staffMemberFor(
        StaffRole.scout,
        relevantValues: [3.0, 3.0],
        id: 'integration-extension-scout',
        contract: staffFixtureContract(salary: 1000000, yearsRemaining: 1),
      );
      final team = staffFixtureTeam(staff: TeamStaff(scout: member));
      final league = staffFixtureLeague(
        teams: [team],
        currentWeek: staffFixtureExtensionWeek(),
        currentDay: 2,
        currentHour: 1,
      );
      final staff = StaffService();
      final offer = staffOfferFor(member, service: staff);
      final expectedScore = staff.staffOfferScore(member, offer);
      final expectedCounter = staff.counterOfferForRound(
        member,
        offer,
        round: 1,
      );
      expect(expectedScore, lessThanOrEqualTo(54));
      expect(expectedCounter, isNotNull);

      // Find a deterministic counter-response seed before executing the same
      // operation through GameController. The seed search is only a fixture
      // selector; expected terms and persisted score remain service-derived.
      final market = ContractMarketService();
      final probe = market.submitStaffOffer(
        league: league,
        candidate: member,
        offer: offer,
        saveSeed: 0,
      );
      expect(probe, isNotNull);
      expect(probe!.reaction, StaffReaction.counter);
      final negotiationId = probe.league.negotiations.single.id;
      int? acceptingSeed;
      for (var seed = 0; seed < 100; seed++) {
        final response = market.resolveCounterResponse(
          probe.league,
          negotiationId,
          accept: true,
          saveSeed: seed,
        );
        if (response?.negotiationById(negotiationId)?.status ==
            NegotiationStatus.completed) {
          acceptingSeed = seed;
          break;
        }
      }
      expect(acceptingSeed, isNotNull);

      final container = _containerFor(
        _gameFor(league, saveSeed: acceptingSeed!),
      );
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);
      final reaction = await controller.offerStaff(member, offer);
      expect(reaction, StaffReaction.counter);
      final offered = controller.save!.leagueState;
      final negotiation = offered.negotiations.single;
      expect(negotiation.subjectId, member.id);
      expect(negotiation.phase, NegotiationPhase.contractExtension);
      expect(negotiation.offerScore, closeTo(expectedScore, 1e-9));
      expect(negotiation.status, NegotiationStatus.counter);
      expect(negotiation.round, 2);
      expect(negotiation.counterOffer!.salary, expectedCounter!.salary);
      expect(negotiation.counterOffer!.years, expectedCounter.years);
      expect(negotiation.lastOffer, negotiation.counterOffer);

      final responded = await controller.respondToStaffCounter(
        negotiation.id,
        accept: true,
      );
      expect(responded, isTrue);
      final signedState = controller.save!.leagueState;
      final signedTeam = signedState.playerTeam!;
      final signed = signedTeam.staff.member(StaffRole.scout);
      expect(signed, isNotNull);
      expect(signed!.id, member.id);
      expect(signed.role, StaffRole.scout);
      expect(signed.contract!.salary, expectedCounter.salary);
      expect(signed.contract!.yearsRemaining, expectedCounter.years);
      expect(
        signedTeam.staff.totalSalary,
        expectedCounter.salary,
        reason: 'extension must replace, not add to, the previous salary',
      );
      expect(
        signedState.staffFreeAgents,
        isEmpty,
        reason: 'an extension subject is not a free agent',
      );
      expect(
        signedState.negotiationById(negotiation.id)!.status,
        NegotiationStatus.completed,
      );
    },
  );

  test(
    'CFO subject is scored without using itself as an assisting CFO',
    () async {
      final subject = staffCfoMember(
        negotiation: 2.0,
        irrelevantValue: 5.0,
        index: 91,
        contract: staffFixtureContract(salary: 1000000, yearsRemaining: 1),
      ).copyWith(id: 'integration-cfo-subject');
      final team = staffFixtureTeam(staff: TeamStaff(cfo: subject));
      final league = staffFixtureLeague(
        teams: [team],
        currentWeek: staffFixtureExtensionWeek(),
        currentDay: 2,
        currentHour: 1,
      );
      final staff = StaffService();
      final offer = staffOfferFor(subject, service: staff, salaryFactor: 1.25);
      final expectedWithoutAssistant = staff.staffOfferScore(subject, offer);
      final incorrectSelfDiscount = staff.staffOfferScore(
        subject,
        offer,
        cfo: subject,
      );
      expect(incorrectSelfDiscount, isNot(expectedWithoutAssistant));

      final container = _containerFor(_gameFor(league));
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);
      final reaction = await controller.offerStaff(subject, offer);
      expect(reaction, StaffReaction.accept);
      final negotiation = controller.save!.leagueState.negotiations.single;
      expect(negotiation.offerScore, closeTo(expectedWithoutAssistant, 1e-9));
      expect(
        negotiation.offerScore,
        isNot(closeTo(incorrectSelfDiscount, 1e-9)),
      );
    },
  );

  test(
    'raw collision and irrelevant mutation stay distinct or invariant in the market',
    () async {
      final staff = StaffService();
      final collisionOffer = const StaffOffer(salary: 2500000, years: 3);
      final lowRaw = staffMemberFor(
        StaffRole.headCoach,
        attributes: staffAttributesWithRawOverall(StaffRole.headCoach, 3.25),
        id: 'integration-collision-low',
      );
      final highRaw = staffMemberFor(
        StaffRole.headCoach,
        attributes: staffAttributesWithRawOverall(StaffRole.headCoach, 3.5),
        id: 'integration-collision-high',
      );

      // 3.25 and 3.5 intentionally share the same half-star display bucket.
      // This test never calls presentation code; it checks raw-domain outputs
      // and the score persisted by the real user offer path.
      expect(
        lowRaw.overall,
        expectedStaffRawOverall(lowRaw.attributes, lowRaw.role),
      );
      expect(
        highRaw.overall,
        expectedStaffRawOverall(highRaw.attributes, highRaw.role),
      );
      expect(lowRaw.overall, 3.25);
      expect(highRaw.overall, 3.5);
      expect(staff.marketSalary(lowRaw), isNot(staff.marketSalary(highRaw)));
      expect(staff.staffWant(lowRaw), isNot(staff.staffWant(highRaw)));
      expect(
        staff.expectedLength(lowRaw),
        isNot(staff.expectedLength(highRaw)),
      );

      final lowResult = await _submitThroughController(
        _gameFor(
          staffFixtureLeague(
            teams: [staffFixtureTeam()],
            staffFreeAgents: [lowRaw],
          ),
        ),
        lowRaw,
        collisionOffer,
      );
      final highResult = await _submitThroughController(
        _gameFor(
          staffFixtureLeague(
            teams: [staffFixtureTeam()],
            staffFreeAgents: [highRaw],
          ),
        ),
        highRaw,
        collisionOffer,
      );
      final lowNegotiation = lowResult.save.leagueState.negotiations.single;
      final highNegotiation = highResult.save.leagueState.negotiations.single;
      expect(
        lowNegotiation.offerScore,
        closeTo(staff.staffOfferScore(lowRaw, collisionOffer), 1e-9),
      );
      expect(
        highNegotiation.offerScore,
        closeTo(staff.staffOfferScore(highRaw, collisionOffer), 1e-9),
      );
      expect(lowNegotiation.offerScore, isNot(highNegotiation.offerScore));

      final base = staffMemberFor(
        StaffRole.doctor,
        relevantValues: [3.25, 3.0],
        id: 'integration-irrelevant-invariance',
      );
      final irrelevantMutation = base.copyWith(
        attributes: withIrrelevantStaffAttribute(
          base.attributes,
          base.role,
          value: 5.0,
        ),
      );
      final invariantOffer = staffOfferFor(base, service: staff);
      expect(irrelevantMutation.overall, base.overall);
      expect(staff.marketSalary(irrelevantMutation), staff.marketSalary(base));
      expect(staff.staffWant(irrelevantMutation), staff.staffWant(base));
      expect(
        staff.expectedSalary(irrelevantMutation),
        staff.expectedSalary(base),
      );
      expect(
        staff.expectedLength(irrelevantMutation),
        staff.expectedLength(base),
      );
      final baseResult = await _submitThroughController(
        _gameFor(
          staffFixtureLeague(
            teams: [staffFixtureTeam()],
            staffFreeAgents: [base],
          ),
        ),
        base,
        invariantOffer,
      );
      final mutationResult = await _submitThroughController(
        _gameFor(
          staffFixtureLeague(
            teams: [staffFixtureTeam()],
            staffFreeAgents: [irrelevantMutation],
          ),
        ),
        irrelevantMutation,
        invariantOffer,
      );
      final baseNegotiation = baseResult.save.leagueState.negotiations.single;
      final mutationNegotiation =
          mutationResult.save.leagueState.negotiations.single;
      expect(mutationResult.reaction, baseResult.reaction);
      expect(mutationNegotiation.offerScore, baseNegotiation.offerScore);
      expect(mutationNegotiation.status, baseNegotiation.status);
      expect(mutationNegotiation.lastOffer, baseNegotiation.lastOffer);
      expect(mutationNegotiation.counterOffer, baseNegotiation.counterOffer);
    },
  );

  test(
    'staff market rejects closed hours, unavailable slots, cap overflow, and mismatches',
    () {
      final market = ContractMarketService();
      final candidate = staffMemberFor(
        StaffRole.headCoach,
        id: 'integration-guard-head-coach',
      );
      final offer = staffFixtureOffer();

      final hourZero = staffFixtureLeague(
        teams: [staffFixtureTeam()],
        staffFreeAgents: [candidate],
        currentHour: 0,
      );
      final hourAfterWindow = staffFixtureLeague(
        teams: [staffFixtureTeam()],
        staffFreeAgents: [candidate],
        currentHour: 11,
      );
      final closedDate = staffFixtureLeague(
        teams: [staffFixtureTeam()],
        staffFreeAgents: [candidate],
        currentWeek: staffFixtureExtensionWeek(),
        currentDay: 1,
        currentHour: 1,
      );
      expect(
        market.submitStaffOffer(
          league: hourZero,
          candidate: candidate,
          offer: offer,
          saveSeed: staffFixtureSaveSeed,
        ),
        isNull,
      );
      expect(
        market.submitStaffOffer(
          league: hourAfterWindow,
          candidate: candidate,
          offer: offer,
          saveSeed: staffFixtureSaveSeed,
        ),
        isNull,
      );
      expect(
        market.submitStaffOffer(
          league: closedDate,
          candidate: candidate,
          offer: offer,
          saveSeed: staffFixtureSaveSeed,
        ),
        isNull,
      );

      final occupied = staffMemberFor(
        StaffRole.headCoach,
        contract: staffFixtureContract(yearsRemaining: 2),
        id: 'integration-occupied-head-coach',
      );
      final unavailable = staffFixtureLeague(
        teams: [staffFixtureTeam(staff: TeamStaff(headCoach: occupied))],
        staffFreeAgents: [candidate],
      );
      expect(
        market.submitStaffOffer(
          league: unavailable,
          candidate: candidate,
          offer: offer,
          saveSeed: staffFixtureSaveSeed,
        ),
        isNull,
      );

      final absentCandidate = staffMemberFor(
        StaffRole.doctor,
        id: 'integration-absent-candidate',
      );
      final absent = staffFixtureLeague(teams: [staffFixtureTeam()]);
      expect(
        market.submitStaffOffer(
          league: absent,
          candidate: absentCandidate,
          offer: offer,
          saveSeed: staffFixtureSaveSeed,
        ),
        isNull,
      );

      final fullPayroll = teamStaffOf({
        StaffRole.headCoach: staffMemberFor(
          StaffRole.headCoach,
          contract: staffFixtureContract(
            salary: BalanceConfig.defaults.staff.maxSalary,
          ),
        ),
        StaffRole.youthCoach: staffMemberFor(
          StaffRole.youthCoach,
          contract: staffFixtureContract(
            salary: BalanceConfig.defaults.staff.maxSalary,
          ),
        ),
        StaffRole.scout: staffMemberFor(
          StaffRole.scout,
          contract: staffFixtureContract(
            salary: BalanceConfig.defaults.staff.maxSalary,
          ),
        ),
      });
      final capOverflow = staffFixtureLeague(
        teams: [staffFixtureTeam(staff: fullPayroll)],
        staffFreeAgents: [
          staffMemberFor(
            StaffRole.doctor,
            id: 'integration-cap-overflow-doctor',
          ),
        ],
      );
      expect(fullPayroll.totalSalary, BalanceConfig.defaults.staff.salaryCap);
      expect(
        market.submitStaffOffer(
          league: capOverflow,
          candidate: capOverflow.staffFreeAgents.single,
          offer: const StaffOffer(salary: 500000, years: 1),
          saveSeed: staffFixtureSaveSeed,
        ),
        isNull,
      );

      final mismatched =
          staffRoleMismatchedMember(
            StaffRole.headCoach,
            declaredRole: StaffRole.doctor,
          ).copyWith(
            id: 'integration-mismatched-head-slot',
            contract: staffFixtureContract(yearsRemaining: 1),
          );
      final mismatchLeague = staffFixtureLeague(
        teams: [staffFixtureTeam(staff: TeamStaff(headCoach: mismatched))],
        currentWeek: staffFixtureExtensionWeek(),
        currentDay: 2,
        currentHour: 1,
      );
      expect(
        market.submitStaffOffer(
          league: mismatchLeague,
          candidate: mismatched,
          offer: offer,
          saveSeed: staffFixtureSaveSeed,
        ),
        isNull,
      );
      expect(
        mismatchLeague.playerTeam!.staff.headCoach!.role,
        StaffRole.doctor,
      );
      expect(mismatchLeague.playerTeam!.staff.doctor, isNull);
    },
  );
}

GameSave _gameFor(LeagueState league, {int saveSeed = staffFixtureSaveSeed}) {
  final now = DateTime.utc(2026, 1, 1);
  return GameSave(
    meta: GameSaveMeta(
      id: 'staff-contract-integration',
      name: 'Staff contract integration',
      createdAt: now,
      updatedAt: now,
      seasonYear: league.currentSeason.year,
      phase: league.currentSeason.phase,
      playerTeamName: league.playerTeam?.name,
      schemaVersion: SaveSchema.currentVersion,
    ),
    leagueState: league,
    saveSeed: saveSeed,
    schemaVersion: SaveSchema.currentVersion,
  );
}

ProviderContainer _containerFor(GameSave game) => ProviderContainer(
  overrides: [
    saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
    gameControllerProvider.overrideWith((ref) {
      final controller = GameController(ref);
      controller.state = AsyncValue.data(game);
      return controller;
    }),
  ],
);

Future<({StaffReaction reaction, GameSave save})> _submitThroughController(
  GameSave game,
  StaffMember candidate,
  StaffOffer offer,
) async {
  final container = _containerFor(game);
  try {
    final controller = container.read(gameControllerProvider.notifier);
    final reaction = await controller.offerStaff(candidate, offer);
    return (reaction: reaction, save: controller.save!);
  } finally {
    container.dispose();
  }
}

class _NoopSaveRepository extends SaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}
