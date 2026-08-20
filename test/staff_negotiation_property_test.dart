// Feature: staff-role-ratings, Property 9: jeden raw path negocjacji.
//
// This is intentionally independent from the Property 7 test. It rebuilds the
// raw/terms/score/counter/reaction oracle and compares every public negotiation
// boundary with the same seeded inputs. The market and AI observations are
// rebuilt from fresh LeagueState values so a persisted score cannot be hidden
// by an in-memory object reused from the UI path.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/staff_service.dart';

import 'helpers/staff_role_ratings_test_helpers.dart';

const _propertyTag =
    'Feature: staff-role-ratings, Property 9: jeden raw path negocjacji';
const _casesPerRole = 18;
const _propertySeed = staffFixtureSeed + 7099;
const _collisionLowRaw = 3.25;
const _collisionHighRaw = 3.30;

const _phases = <NegotiationPhase>[
  NegotiationPhase.freeAgencyPhaseI,
  NegotiationPhase.freeAgencyPhaseII,
  NegotiationPhase.contractExtension,
];

void main() {
  group(_propertyTag, () {
    // **Validates: Requirements 2.7, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7,
    // 7.8, 8.3, 8.4, 8.5, 10.9**
    for (final role in StaffRole.values) {
      test('${role.name}: $_casesPerRole seeded negotiation paths share one '
          'RawOverall', () {
        final seed = _seedFor(role);
        final scenarios = _scenariosForRole(role, seed);
        expect(
          scenarios,
          hasLength(_casesPerRole),
          reason:
              '$_propertyTag role=${role.name} seed=$seed: '
              'scenario generator changed its cardinality',
        );

        for (final status in TeamStatus.values) {
          expect(
            scenarios.any((scenario) => scenario.marketStatus == status),
            isTrue,
            reason:
                '$_propertyTag role=${role.name} seed=$seed: '
                'market status ${status.name} was not exercised',
          );
          expect(
            scenarios.any(
              (scenario) => scenario.directOfferingStatus == status,
            ),
            isTrue,
            reason:
                '$_propertyTag role=${role.name} seed=$seed: '
                'direct offering status ${status.name} was not exercised',
          );
          expect(
            scenarios.any((scenario) => scenario.directCurrentStatus == status),
            isTrue,
            reason:
                '$_propertyTag role=${role.name} seed=$seed: '
                'direct current status ${status.name} was not exercised',
          );
        }
        for (final phase in _phases) {
          expect(
            scenarios.any((scenario) => scenario.phase == phase),
            isTrue,
            reason:
                '$_propertyTag role=${role.name} seed=$seed: '
                'phase ${phase.name} was not exercised',
          );
        }
        expect(
          scenarios.any((scenario) => scenario.assistingCfo == null),
          isTrue,
          reason:
              '$_propertyTag role=${role.name} seed=$seed: no-CFO input '
              'was not exercised',
        );
        expect(
          scenarios.any((scenario) => scenario.assistingCfo != null),
          isTrue,
          reason:
              '$_propertyTag role=${role.name} seed=$seed: assisting CFO '
              'input was not exercised',
        );

        for (var caseIndex = 0; caseIndex < scenarios.length; caseIndex++) {
          _assertScenario(
            scenarios[caseIndex],
            caseIndex: caseIndex,
            seed: seed,
          );
        }
      });
    }

    // **Validates: Requirements 2.7, 5.4, 6.1, 6.2, 6.3, 6.4, 7.1, 7.2,
    // 7.3, 7.5, 8.1, 8.3, 8.4**
    test('raw/display collision keeps score, counter and persisted inputs '
        'distinct', () {
      for (final role in StaffRole.values) {
        final seed = _seedFor(role) + 100000;
        final low = _scenarioForRaw(
          role,
          raw: _collisionLowRaw,
          id: 'p9_collision_low_${role.name}',
          seed: seed,
        );
        final high = _scenarioForRaw(
          role,
          raw: _collisionHighRaw,
          id: 'p9_collision_high_${role.name}',
          seed: seed + 1,
        );
        final lowView = StaffPresentation.viewForMember(low.member).rating!;
        final highView = StaffPresentation.viewForMember(high.member).rating!;

        expect(
          lowView.displayedRating,
          highView.displayedRating,
          reason: _reason(low, caseIndex: -1, seed: seed),
        );
        expect(
          lowView.rawOverall,
          isNot(highView.rawOverall),
          reason:
              '${_reason(low, caseIndex: -1, seed: seed)}\nUI display must not replace RawOverall',
        );

        final lowDirect = _observeService(
          low,
          low.member,
          offeringStatus: low.marketStatus,
          currentStatus: low.marketStatus,
          cfo: low.marketCfo,
          round: 1,
          reactionSeed: low.seed,
        );
        final highDirect = _observeService(
          high,
          high.member,
          offeringStatus: high.marketStatus,
          currentStatus: high.marketStatus,
          cfo: high.marketCfo,
          round: 1,
          reactionSeed: high.seed,
        );
        expect(
          lowDirect.score,
          isNot(highDirect.score),
          reason:
              '${_reason(low, caseIndex: -1, seed: seed)}\nraw/display collision was collapsed by the direct score path',
        );
        _expectOffersDifferent(
          lowDirect.counter,
          highDirect.counter,
          reason:
              '${_reason(low, caseIndex: -1, seed: seed)}\nraw/display collision was collapsed by counter inputs',
          allowNullEquality: true,
        );

        final lowMarket = _observeMarket(low, low.member);
        final highMarket = _observeMarket(high, high.member);
        expect(
          lowMarket.score,
          isNot(highMarket.score),
          reason:
              '${_reason(low, caseIndex: -1, seed: seed)}\nContractMarketService consumed DisplayedRating',
        );
        expect(
          lowMarket.score,
          lowDirect.score,
          reason:
              '${_reason(low, caseIndex: -1, seed: seed)}\npersisted low score diverged from its raw direct path',
        );
        expect(
          highMarket.score,
          highDirect.score,
          reason:
              '${_reason(high, caseIndex: -1, seed: seed + 1)}\npersisted high score diverged from its raw direct path',
        );
      }
    });
  });
}

class _Scenario {
  const _Scenario({
    required this.member,
    required this.offer,
    required this.assistingCfo,
    required this.marketStatus,
    required this.directOfferingStatus,
    required this.directCurrentStatus,
    required this.phase,
    required this.round,
    required this.seed,
  });

  final StaffMember member;
  final StaffOffer offer;
  final StaffMember? assistingCfo;
  final TeamStatus marketStatus;
  final TeamStatus directOfferingStatus;
  final TeamStatus directCurrentStatus;
  final NegotiationPhase phase;
  final int round;
  final int seed;

  /// A CFO subject cannot also be the team's assisting CFO. Direct service
  /// tests may provide a separate assistant, but market/AI paths must pass no
  /// assistant when the subject itself occupies the CFO slot.
  StaffMember? get marketCfo =>
      member.role == StaffRole.cfo ? null : assistingCfo;

  _Scenario withMember(StaffMember nextMember) => _Scenario(
    member: nextMember,
    offer: offer,
    assistingCfo: assistingCfo,
    marketStatus: marketStatus,
    directOfferingStatus: directOfferingStatus,
    directCurrentStatus: directCurrentStatus,
    phase: phase,
    round: round,
    seed: seed,
  );
}

class _ServiceObservation {
  const _ServiceObservation({
    required this.want,
    required this.expectedSalary,
    required this.expectedLength,
    required this.breakdown,
    required this.score,
    required this.counter,
    required this.reaction,
  });

  final double want;
  final int expectedSalary;
  final int expectedLength;
  final OfferScoreBreakdown breakdown;
  final double score;
  final StaffOffer? counter;
  final StaffReaction reaction;
}

class _MarketObservation {
  const _MarketObservation({
    required this.score,
    required this.reaction,
    required this.counter,
    required this.negotiation,
  });

  final double score;
  final StaffReaction reaction;
  final StaffOffer? counter;
  final ContractNegotiation negotiation;
}

class _AiObservation {
  const _AiObservation({
    required this.offerSalary,
    required this.offerYears,
    required this.score,
    required this.negotiation,
  });

  final int offerSalary;
  final int offerYears;
  final double score;
  final ContractNegotiation negotiation;
}

List<_Scenario> _scenariosForRole(StaffRole role, int seed) {
  final random = Random(seed);
  return List<_Scenario>.generate(
    _casesPerRole,
    (caseIndex) => _scenarioForCase(role, caseIndex, random),
    growable: false,
  );
}

_Scenario _scenarioForCase(StaffRole role, int caseIndex, Random random) {
  final phase = _phases[(caseIndex + role.index) % _phases.length];
  final specialRaw = switch (caseIndex) {
    0 => _collisionLowRaw,
    1 => _collisionHighRaw,
    2 => 3.75,
    3 => 0.0,
    4 => 5.0,
    _ => null,
  };
  final attributes = specialRaw == null
      ? randomStaffAttributes(random, includeOutOfRange: true)
      : staffAttributesWithRawOverall(
          role,
          specialRaw,
          spread:
              relevantStaffAttributeNames(role).length == 1 ||
                  specialRaw == 0.0 ||
                  specialRaw == 5.0
              ? 0.0
              : 0.25,
          irrelevantValue: caseIndex.isEven ? 5.0 : -4.0,
        );
  final age = specialRaw == 0.0 || specialRaw == 5.0
      ? 60
      : 35 + random.nextInt(26);
  final member = staffMemberFor(
    role,
    attributes: attributes,
    id: 'p9_${role.name}_${caseIndex.toString().padLeft(3, '0')}',
    index: caseIndex + 1,
    age: age,
    contract: phase == NegotiationPhase.contractExtension
        ? staffFixtureContract(salary: 1100000, yearsRemaining: 1)
        : null,
  );
  final marketStatus =
      TeamStatus.values[(caseIndex + role.index) % TeamStatus.values.length];
  final directOfferingStatus = TeamStatus
      .values[(caseIndex * 2 + role.index + 1) % TeamStatus.values.length];
  final directCurrentStatus = TeamStatus
      .values[(caseIndex * 3 + role.index + 2) % TeamStatus.values.length];
  final cfo = caseIndex % 3 == 0
      ? null
      : staffCfoMember(
          negotiation: const [0.0, 1.5, 2.5, 3.25, 3.75, 5.0][caseIndex % 6],
          index: 900 + role.index * 100 + caseIndex,
        );
  final service = StaffService();
  final expected = service.expectedSalary(
    member,
    currentTeamStatus: marketStatus,
  );
  final factor = const [
    0.68,
    0.82,
    0.96,
    1.0,
    1.08,
    1.22,
    0.74,
    1.14,
  ][caseIndex % 8];
  final salary = (expected * factor).round().clamp(
    BalanceConfig.defaults.staff.minSalary,
    BalanceConfig.defaults.staff.maxSalary,
  );
  final phaseSeed = _propertySeed + role.index * 1009 + caseIndex * 37;

  return _Scenario(
    member: member,
    offer: StaffOffer(salary: salary, years: 1 + caseIndex % 4),
    assistingCfo: cfo,
    marketStatus: marketStatus,
    directOfferingStatus: directOfferingStatus,
    directCurrentStatus: directCurrentStatus,
    phase: phase,
    round: 1 + caseIndex % BalanceConfig.defaults.contracts.maxCounterRounds,
    seed: phaseSeed,
  );
}

_Scenario _scenarioForRaw(
  StaffRole role, {
  required double raw,
  required String id,
  required int seed,
}) {
  final phase = NegotiationPhase.freeAgencyPhaseI;
  final member = staffMemberFor(
    role,
    attributes: staffAttributesWithRawOverall(
      role,
      raw,
      spread: relevantStaffAttributeNames(role).length == 1 ? 0.0 : 0.25,
      irrelevantValue: 5.0,
    ),
    id: id,
    age: 45,
  );
  final cfo = staffCfoMember(negotiation: 4.0, index: 990 + role.index);
  return _Scenario(
    member: member,
    offer: const StaffOffer(salary: 2550000, years: 3),
    assistingCfo: cfo,
    marketStatus: TeamStatus.pretender,
    directOfferingStatus: TeamStatus.pretender,
    directCurrentStatus: TeamStatus.pretender,
    phase: phase,
    round: 1,
    seed: seed,
  );
}

void _assertScenario(
  _Scenario scenario, {
  required int caseIndex,
  required int seed,
}) {
  final reason = _reason(scenario, caseIndex: caseIndex, seed: seed);
  final raw = expectedStaffRawOverall(
    scenario.member.attributes,
    scenario.member.role,
  );
  final displayed = expectedStaffDisplayedRating(raw);
  final view = StaffPresentation.viewForMember(scenario.member).rating;
  expect(view, isNotNull, reason: '$reason: UI did not expose a rating view');
  expect(view!.rawOverall, raw, reason: '$reason: UI changed RawOverall');
  expect(
    view.displayedRating,
    displayed,
    reason: '$reason: UI displayed rating differs from half-up oracle',
  );

  final direct = _observeService(
    scenario,
    scenario.member,
    offeringStatus: scenario.directOfferingStatus,
    currentStatus: scenario.directCurrentStatus,
    cfo: scenario.assistingCfo,
    round: scenario.round,
    reactionSeed: scenario.seed ^ 0x13579,
  );
  final irrelevantName = irrelevantStaffAttributeNames(
    scenario.member.role,
  ).first;
  final irrelevantValue =
      staffAttributeByName(scenario.member.attributes, irrelevantName) == 5.0
      ? 0.0
      : 5.0;
  final irrelevantMember = scenario.member.copyWith(
    attributes: withIrrelevantStaffAttribute(
      scenario.member.attributes,
      scenario.member.role,
      name: irrelevantName,
      value: irrelevantValue,
    ),
  );
  final irrelevantScenario = scenario.withMember(irrelevantMember);
  final irrelevantDirect = _observeService(
    irrelevantScenario,
    irrelevantMember,
    offeringStatus: scenario.directOfferingStatus,
    currentStatus: scenario.directCurrentStatus,
    cfo: scenario.assistingCfo,
    round: scenario.round,
    reactionSeed: scenario.seed ^ 0x13579,
  );
  expect(
    irrelevantMember.overall,
    raw,
    reason: '$reason: irrelevant mutation changed RawOverall',
  );
  expect(
    StaffPresentation.viewForMember(irrelevantMember).rating!.displayedRating,
    displayed,
    reason: '$reason: irrelevant mutation changed DisplayedRating',
  );
  _expectServiceEqual(
    direct,
    irrelevantDirect,
    reason: '$reason: irrelevant subject mutation changed a direct output',
  );

  final market = _observeMarket(scenario, scenario.member);
  final irrelevantMarket = _observeMarket(irrelevantScenario, irrelevantMember);
  _expectMarketEqual(
    market,
    irrelevantMarket,
    reason: '$reason: irrelevant subject mutation changed a persisted output',
  );
  expect(
    market.score,
    closeTo(
      _observeService(
        scenario,
        scenario.member,
        offeringStatus: scenario.marketStatus,
        currentStatus: scenario.marketStatus,
        cfo: scenario.marketCfo,
        round: 1,
        reactionSeed: _marketSubmissionSeed(scenario),
      ).score,
      1e-9,
    ),
    reason: '$reason: ContractMarketService persisted a non-canonical score',
  );

  _assertStaleRecompute(scenario, scenario.member, reason: reason);
  _assertWaitingCounter(scenario, scenario.member, reason: reason);
  _assertAi(scenario, scenario.member, irrelevantMember, reason: reason);

  // Replaying the same market request must not consume process-global/random
  // state: the persisted result is a pure function of the documented seed and
  // explicit offer/status/CFO/phase inputs.
  final replay = _observeMarket(scenario, scenario.member);
  _expectMarketEqual(
    market,
    replay,
    reason: '$reason: same seed/request did not replay identically',
  );
}

_ServiceObservation _observeService(
  _Scenario scenario,
  StaffMember member, {
  required TeamStatus offeringStatus,
  required TeamStatus currentStatus,
  required StaffMember? cfo,
  required int round,
  required int reactionSeed,
}) {
  const balance = BalanceConfig.defaults;
  final service = StaffService(random: Random(reactionSeed));
  final raw = expectedStaffRawOverall(member.attributes, member.role);
  final want = _oracleStaffWant(raw, currentStatus);
  final expectedSalary = _oracleExpectedSalary(want, balance);
  final expectedLength = _oracleExpectedLength(want, member.age);
  final cfoRaw = cfo == null
      ? null
      : expectedStaffRawOverall(cfo.attributes, StaffRole.cfo);
  final expectedBreakdown = NegotiationRules.score(
    salary: scenario.offer.salary,
    expectedSalary: expectedSalary,
    years: scenario.offer.years,
    expectedLength: expectedLength,
    offeringTeamStatus: offeringStatus,
    cfoNegotiation: cfoRaw,
    balance: balance.contracts,
  );
  final breakdown = service.staffOfferBreakdown(
    member,
    scenario.offer,
    offeringTeamStatus: offeringStatus,
    currentTeamStatus: currentStatus,
    cfo: cfo,
  );
  _expectBreakdownEqual(
    breakdown,
    expectedBreakdown,
    reason:
        '${_reason(scenario, caseIndex: -1, seed: reactionSeed)}: direct breakdown is not a raw/status/CFO/offer function',
  );

  final expectedCounter = _oracleCounter(
    member: member,
    offer: scenario.offer,
    round: round,
    offeringStatus: offeringStatus,
    currentStatus: currentStatus,
    cfoNegotiation: cfoRaw,
  );
  final counter = service.counterOfferForRound(
    member,
    scenario.offer,
    round: round,
    offeringTeamStatus: offeringStatus,
    currentTeamStatus: currentStatus,
    cfo: cfo,
  );
  _expectOffersEqual(
    counter,
    expectedCounter,
    reason:
        '${_reason(scenario, caseIndex: -1, seed: reactionSeed)}: direct counter path changed its raw oracle',
  );

  final belowExpectation = scenario.offer.salary < expectedSalary;
  final expectedReaction = _oracleReaction(
    score: expectedBreakdown.score,
    phase: scenario.phase,
    random: Random(reactionSeed),
    belowExpectation: belowExpectation,
  );
  final reaction = service.evaluateOffer(
    member,
    scenario.offer,
    phase: scenario.phase,
    offeringTeamStatus: offeringStatus,
    currentTeamStatus: currentStatus,
    cfo: cfo,
    belowExpectation: belowExpectation,
    random: Random(reactionSeed),
  );
  expect(
    reaction,
    expectedReaction,
    reason:
        '${_reason(scenario, caseIndex: -1, seed: reactionSeed)}: evaluateOffer diverged from the raw score/replay oracle',
  );

  return _ServiceObservation(
    want: service.staffWant(member, currentTeamStatus: currentStatus),
    expectedSalary: service.expectedSalary(
      member,
      currentTeamStatus: currentStatus,
    ),
    expectedLength: service.expectedLength(
      member,
      currentTeamStatus: currentStatus,
    ),
    breakdown: breakdown,
    score: service.staffOfferScore(
      member,
      scenario.offer,
      offeringTeamStatus: offeringStatus,
      currentTeamStatus: currentStatus,
      cfo: cfo,
    ),
    counter: counter,
    reaction: reaction,
  );
}

_MarketObservation _observeMarket(_Scenario scenario, StaffMember member) {
  final league = _marketLeague(scenario, member, playerControlled: true);
  final team = league.teamById(_teamId(scenario));
  if (team == null) {
    fail(
      '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: '
      'market fixture did not contain its offering team',
    );
  }
  final market = ContractMarketService();
  final result = market.submitStaffOffer(
    league: league,
    candidate: member,
    offer: scenario.offer,
    saveSeed: scenario.seed,
  );
  if (result == null) {
    fail(
      '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: '
      'ContractMarketService rejected a legal staff fixture',
    );
  }
  final negotiations = result.league.negotiations.where(
    (item) => item.subjectId == member.id,
  );
  if (negotiations.length != 1) {
    fail(
      '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: '
      'persisted ${negotiations.length} staff negotiations instead of one',
    );
  }
  final negotiation = negotiations.single;
  final expected = _observeService(
    scenario,
    member,
    offeringStatus: scenario.marketStatus,
    currentStatus: scenario.marketStatus,
    cfo: scenario.marketCfo,
    round: 1,
    reactionSeed: _marketSubmissionSeed(scenario),
  );
  expect(
    result.reaction,
    expected.reaction,
    reason:
        '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: UI/market reaction did not replay from the same raw score',
  );
  expect(
    negotiation.offerScore,
    closeTo(expected.score, 1e-9),
    reason:
        '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: persisted offerScore did not use StaffService RawOverall',
  );
  _expectNegotiationCounter(
    negotiation,
    expected.reaction == StaffReaction.counter ? expected.counter : null,
    reason:
        '${_reason(scenario, caseIndex: -1, seed: scenario.seed)}: persisted counter diverged from StaffService',
  );
  return _MarketObservation(
    score: negotiation.offerScore,
    reaction: result.reaction,
    counter: _staffOfferFromNegotiation(negotiation.counterOffer),
    negotiation: negotiation,
  );
}

void _assertStaleRecompute(
  _Scenario scenario,
  StaffMember member, {
  required String reason,
}) {
  final source = _marketLeague(scenario, member, playerControlled: true);
  final team = source.teamById(_teamId(scenario));
  if (team == null) fail('$reason: stale fixture lost its offering team');
  final date = _marketDate(scenario);
  final stale = const NegotiationService()
      .start(
        id: 'p9-stale:${member.id}:${scenario.phase.name}',
        subjectId: member.id,
        subjectKind: NegotiationSubjectKind.staff,
        teamId: team.id,
        phase: scenario.phase,
        offer: NegotiationOffer(
          salary: scenario.offer.salary,
          years: scenario.offer.years,
        ),
        seasonYear: date.seasonYear,
        week: date.week,
        day: date.day,
        hour: date.hour,
        offerScore: -999.0,
      )
      .copyWith(status: NegotiationStatus.pendingFinalization);
  final state = source.copyWith(negotiations: [stale]);
  final resolved = _resolveMarketState(state, scenario);
  final updated = resolved.negotiationById(stale.id);
  expect(updated, isNotNull, reason: '$reason: stale negotiation disappeared');
  final expected = StaffService().staffOfferScore(
    member,
    scenario.offer,
    offeringTeamStatus: scenario.marketStatus,
    currentTeamStatus: scenario.marketStatus,
    cfo: scenario.marketCfo,
  );
  expect(
    updated!.offerScore,
    closeTo(expected, 1e-9),
    reason: '$reason: persisted recompute kept stale/rounded score',
  );
}

void _assertWaitingCounter(
  _Scenario scenario,
  StaffMember member, {
  required String reason,
}) {
  final source = _marketLeague(scenario, member, playerControlled: true);
  final team = source.teamById(_teamId(scenario));
  if (team == null) fail('$reason: waiting fixture lost its offering team');
  final date = _marketDate(scenario);
  final waiting = const NegotiationService()
      .start(
        id: 'p9-waiting:${member.id}:${scenario.phase.name}',
        subjectId: member.id,
        subjectKind: NegotiationSubjectKind.staff,
        teamId: team.id,
        phase: scenario.phase,
        offer: NegotiationOffer(
          salary: scenario.offer.salary,
          years: scenario.offer.years,
        ),
        seasonYear: date.seasonYear,
        week: date.week,
        day: date.day,
        hour: date.hour,
        offerScore: -777.0,
      )
      .copyWith(
        status: NegotiationStatus.waiting,
        waitingUntilSeasonYear: date.seasonYear,
        waitingUntilWeek: date.week,
        waitingUntilDay: date.day,
        waitingUntilHour: date.hour,
      );
  final resolved = _resolveMarketState(
    source.copyWith(negotiations: [waiting]),
    scenario,
  );
  final updated = resolved.negotiationById(waiting.id);
  expect(
    updated,
    isNotNull,
    reason: '$reason: waiting negotiation disappeared',
  );
  final service = StaffService();
  final score = service.staffOfferScore(
    member,
    scenario.offer,
    offeringTeamStatus: scenario.marketStatus,
    currentTeamStatus: scenario.marketStatus,
    cfo: scenario.marketCfo,
  );
  expect(
    updated!.offerScore,
    closeTo(score, 1e-9),
    reason: '$reason: waiting recompute did not use the canonical raw score',
  );
  final expectedStatus = _waitingStatus(
    score: score,
    scenario: scenario,
    league: source,
    team: team,
    round: 1,
  );
  expect(
    updated.status,
    expectedStatus,
    reason: '$reason: waiting reaction changed with a non-raw heuristic',
  );
  if (expectedStatus == NegotiationStatus.counter) {
    final expectedCounter = service.counterOfferForRound(
      member,
      scenario.offer,
      round: 1,
      offeringTeamStatus: scenario.marketStatus,
      currentTeamStatus: scenario.marketStatus,
      cfo: scenario.marketCfo,
    );
    _expectNegotiationCounter(
      updated,
      expectedCounter,
      reason: '$reason: persisted waiting counter did not use raw terms',
    );
  }
}

void _assertAi(
  _Scenario scenario,
  StaffMember member,
  StaffMember irrelevantMember, {
  required String reason,
}) {
  final original = _observeAi(scenario, member, reason: reason);
  final irrelevant = _observeAi(
    scenario.withMember(irrelevantMember),
    irrelevantMember,
    reason: '$reason irrelevant mutation',
  );
  if (original == null || irrelevant == null) {
    expect(
      irrelevant,
      isNull,
      reason:
          '$reason: AI renewal/free-agent classification changed after '
          'an irrelevant attribute mutation',
    );
    return;
  }
  expect(irrelevant.offerSalary, original.offerSalary, reason: reason);
  expect(irrelevant.offerYears, original.offerYears, reason: reason);
  expect(irrelevant.score, original.score, reason: reason);
  expect(
    irrelevant.negotiation.offerScore,
    original.negotiation.offerScore,
    reason: '$reason: AI persisted score changed after irrelevant mutation',
  );
}

_AiObservation? _observeAi(
  _Scenario scenario,
  StaffMember member, {
  required String reason,
}) {
  final league = _marketLeague(scenario, member, playerControlled: false);
  final team = league.teamById(_teamId(scenario));
  if (team == null) fail('$reason: AI fixture lost its team');
  final policy = AiContractMarketService();
  final plan = scenario.phase == NegotiationPhase.contractExtension
      ? policy.staffExtensionPlan(
          league: league,
          team: team,
          saveSeed: scenario.seed,
        )
      : policy.staffFreeAgentPlan(
          league: league,
          team: team,
          saveSeed: scenario.seed,
        );
  if (plan == null) {
    final resolved = _resolveMarketState(league, scenario);
    expect(
      resolved.negotiations.where((item) => item.subjectId == member.id),
      isEmpty,
      reason:
          '$reason: central AI created an offer absent from its direct plan',
    );
    return null;
  }
  expect(
    plan.member.id,
    member.id,
    reason: '$reason: AI selected another role',
  );
  expect(
    plan.role,
    member.role,
    reason: '$reason: AI changed the configured role',
  );
  final expectedScore = StaffService().staffOfferScore(
    member,
    plan.offer,
    offeringTeamStatus: scenario.marketStatus,
    currentTeamStatus: scenario.marketStatus,
    cfo: scenario.marketCfo,
  );
  expect(
    plan.offerScore,
    closeTo(expectedScore, 1e-9),
    reason: '$reason: AI plan score did not use StaffService RawOverall',
  );

  final resolved = _resolveMarketState(league, scenario);
  final matches = resolved.negotiations.where(
    (item) => item.subjectId == member.id && item.isAiOffer,
  );
  if (matches.length != 1) {
    fail(
      '$reason: central AI persisted ${matches.length} offers for the '
      'directly selected staff subject',
    );
  }
  final negotiation = matches.single;
  expect(
    negotiation.offerScore,
    closeTo(expectedScore, 1e-9),
    reason: '$reason: central AI recompute diverged from StaffService',
  );
  expect(
    negotiation.lastOffer.salary,
    plan.offer.salary,
    reason: '$reason: central AI persisted a different salary input',
  );
  expect(
    negotiation.lastOffer.years,
    plan.offer.years,
    reason: '$reason: central AI persisted a different length input',
  );
  return _AiObservation(
    offerSalary: plan.offer.salary,
    offerYears: plan.offer.years,
    score: plan.offerScore,
    negotiation: negotiation,
  );
}

LeagueState _marketLeague(
  _Scenario scenario,
  StaffMember member, {
  required bool playerControlled,
}) {
  final team = _marketTeam(
    scenario,
    member,
    playerControlled: playerControlled,
  );
  final date = _marketDate(scenario);
  return staffFixtureLeague(
    teams: [team],
    playerTeamId: playerControlled ? team.id : null,
    staffFreeAgents: scenario.phase == NegotiationPhase.contractExtension
        ? const []
        : [member],
    currentWeek: date.week,
    currentDay: date.day,
    currentHour: date.hour,
    teamStatus: scenario.marketStatus,
  );
}

Team _marketTeam(
  _Scenario scenario,
  StaffMember member, {
  required bool playerControlled,
}) {
  final slots = <StaffRole, StaffMember?>{};
  if (scenario.phase == NegotiationPhase.contractExtension) {
    slots[scenario.member.role] = member;
  }
  if (scenario.marketCfo != null && scenario.member.role != StaffRole.cfo) {
    slots[StaffRole.cfo] = scenario.marketCfo;
  }
  if (!playerControlled) {
    for (final role in StaffRole.values) {
      if (role == scenario.member.role) continue;
      if (role == StaffRole.cfo) {
        if (scenario.marketCfo != null) continue;
        // A missing assisting CFO must remain an EmptySlot; a low-rated
        // filler would change the negotiation multiplier.
        continue;
      }
      slots[role] = staffMemberFor(
        role,
        attributes: staffAttributesWithRawOverall(role, 1.0),
        id: 'p9_ai_fill_${scenario.member.role.name}_${role.name}',
      );
    }
  }
  return staffFixtureTeam(
    id: _teamId(scenario),
    staff: teamStaffOf(slots),
    ai: playerControlled ? null : const TeamAiConfig(),
  );
}

LeagueState _resolveMarketState(LeagueState state, _Scenario scenario) {
  final market = ContractMarketService();
  return scenario.phase == NegotiationPhase.freeAgencyPhaseII
      ? market.resolveDay(state, saveSeed: scenario.seed)
      : market.resolveHour(
          state,
          hour: _marketDate(scenario).hour,
          saveSeed: scenario.seed,
        );
}

({int seasonYear, int week, int day, int hour}) _marketDate(
  _Scenario scenario,
) {
  switch (scenario.phase) {
    case NegotiationPhase.freeAgencyPhaseI:
      return (
        seasonYear: staffFixtureSeasonYear,
        week: staffFixtureFreeAgencyWeek(),
        day: 1,
        hour: 1,
      );
    case NegotiationPhase.freeAgencyPhaseII:
      return (
        seasonYear: staffFixtureSeasonYear,
        // Phase II wraps into weeks 1–45. Week 1 keeps the resolver before
        // its documented phase-II expiry boundary.
        week: 1,
        day: 1,
        hour: 0,
      );
    case NegotiationPhase.contractExtension:
      return (
        seasonYear: staffFixtureSeasonYear,
        week: staffFixtureExtensionWeek(),
        day: 2,
        hour: 1,
      );
  }
}

String _teamId(_Scenario scenario) =>
    'p9_team_${scenario.member.role.name}_${scenario.seed}';

int _marketSubmissionSeed(_Scenario scenario) {
  final date = _marketDate(scenario);
  final value =
      '${scenario.seed}:${date.seasonYear}:${date.week}:'
      '${date.day}:${date.hour}:${_teamId(scenario)}:'
      '${scenario.member.id}:submit:${scenario.phase.name}';
  return _stableSeed(value);
}

int _marketWaitingSeed(_Scenario scenario, LeagueState league, Team team) {
  final date = _marketDate(scenario);
  final value =
      '${scenario.seed}:${date.seasonYear}:${date.week}:'
      '${date.day}:${date.hour}:${team.id}:${scenario.member.id}:waiting:1';
  return _stableSeed(value);
}

NegotiationStatus _waitingStatus({
  required double score,
  required _Scenario scenario,
  required LeagueState league,
  required Team team,
  required int round,
}) {
  final balance = BalanceConfig.defaults.contracts;
  if (score >= 70) return NegotiationStatus.pendingFinalization;
  if (score >= 55) {
    final random = Random(_marketWaitingSeed(scenario, league, team));
    final probability = (0.50 + (score - 62) * 0.03).clamp(0.0, 1.0);
    if (random.nextDouble() < probability) {
      return NegotiationStatus.pendingFinalization;
    }
  }
  if (score >= 40) return NegotiationStatus.counter;
  return score <= balance.hardRejectScoreMax
      ? NegotiationStatus.hardRejected
      : NegotiationStatus.rejected;
}

double _oracleStaffWant(double raw, TeamStatus status) =>
    (raw * 20.0 + NegotiationRules.teamStatusBonus(status))
        .clamp(0.0, 100.0)
        .toDouble();

int _oracleExpectedSalary(double want, BalanceConfig balance) {
  final normalized = want / 100.0;
  final salary =
      balance.staff.minSalary +
      (balance.staff.maxSalary - balance.staff.minSalary) *
          normalized *
          normalized;
  return salary.round().clamp(balance.staff.minSalary, balance.staff.maxSalary);
}

int _oracleExpectedLength(double want, int age) {
  final band = want <= 39
      ? 0
      : want <= 69
      ? 1
      : 2;
  if (age <= 54) return const [2, 3, 4][band];
  if (age <= 59) return const [1, 2, 2][band];
  return 1;
}

StaffOffer? _oracleCounter({
  required StaffMember member,
  required StaffOffer offer,
  required int round,
  required TeamStatus offeringStatus,
  required TeamStatus currentStatus,
  required double? cfoNegotiation,
}) {
  const balance = BalanceConfig.defaults;
  if (round < 1 || round > balance.contracts.maxCounterRounds) return null;
  final raw = expectedStaffRawOverall(member.attributes, member.role);
  final want = _oracleStaffWant(raw, currentStatus);
  final expectedLength = _oracleExpectedLength(want, member.age);
  final years = expectedLength.clamp(1, 4);
  final expectedSalary = _oracleExpectedSalary(want, balance);
  final target = NegotiationRules.counterTargetScore(
    round,
    balance: balance.contracts,
  );
  final discount = NegotiationRules.cfoDiscount(cfoNegotiation);
  final length = NegotiationRules.lengthFit(
    years: years,
    expectedLength: expectedLength,
    balance: balance.contracts,
  );
  final desiredSalaryFit =
      target / discount -
      length -
      NegotiationRules.teamStatusBonus(offeringStatus) -
      balance.contracts.salaryFitBase;
  final percentage = desiredSalaryFit >= 0
      ? desiredSalaryFit / balance.contracts.salaryAboveBonusPerPct
      : desiredSalaryFit / balance.contracts.salaryBelowPenaltyPerPct;
  final salary = (expectedSalary * (1 + percentage / 100)).round().clamp(
    balance.staff.minSalary,
    balance.staff.maxSalary,
  );
  return StaffOffer(salary: salary, years: years);
}

StaffReaction _oracleReaction({
  required double score,
  required NegotiationPhase phase,
  required Random random,
  required bool belowExpectation,
}) {
  final decision = NegotiationRules.decisionForScore(
    score: score,
    phase: phase,
    random: random,
    belowExpectation: belowExpectation,
    balance: BalanceConfig.defaults.contracts,
  );
  return switch (decision) {
    NegotiationDecision.accept => StaffReaction.accept,
    NegotiationDecision.hardReject => StaffReaction.hardReject,
    NegotiationDecision.reject => StaffReaction.reject,
    NegotiationDecision.waiting => StaffReaction.waiting,
    NegotiationDecision.counter => StaffReaction.counter,
  };
}

void _expectServiceEqual(
  _ServiceObservation expected,
  _ServiceObservation actual, {
  required String reason,
}) {
  expect(actual.want, expected.want, reason: '$reason: want');
  expect(
    actual.expectedSalary,
    expected.expectedSalary,
    reason: '$reason: expected salary',
  );
  expect(
    actual.expectedLength,
    expected.expectedLength,
    reason: '$reason: expected length',
  );
  _expectBreakdownEqual(actual.breakdown, expected.breakdown, reason: reason);
  expect(actual.score, expected.score, reason: '$reason: score');
  _expectOffersEqual(
    actual.counter,
    expected.counter,
    reason: '$reason: counter',
  );
  expect(actual.reaction, expected.reaction, reason: '$reason: reaction');
}

void _expectMarketEqual(
  _MarketObservation expected,
  _MarketObservation actual, {
  required String reason,
}) {
  expect(actual.score, expected.score, reason: '$reason: persisted score');
  expect(
    actual.reaction,
    expected.reaction,
    reason: '$reason: persisted reaction',
  );
  _expectOffersEqual(
    actual.counter,
    expected.counter,
    reason: '$reason: persisted counter',
  );
  expect(
    actual.negotiation.status,
    expected.negotiation.status,
    reason: '$reason: persisted status',
  );
  expect(
    actual.negotiation.lastOffer.salary,
    expected.negotiation.lastOffer.salary,
    reason: '$reason: persisted last salary',
  );
  expect(
    actual.negotiation.lastOffer.years,
    expected.negotiation.lastOffer.years,
    reason: '$reason: persisted last years',
  );
}

void _expectBreakdownEqual(
  OfferScoreBreakdown actual,
  OfferScoreBreakdown expected, {
  required String reason,
}) {
  expect(
    actual.salaryFit,
    closeTo(expected.salaryFit, 1e-9),
    reason: '$reason: salary fit',
  );
  expect(
    actual.lengthFit,
    closeTo(expected.lengthFit, 1e-9),
    reason: '$reason: length fit',
  );
  expect(
    actual.teamStatus,
    closeTo(expected.teamStatus, 1e-9),
    reason: '$reason: team status',
  );
  expect(
    actual.cfoDiscount,
    closeTo(expected.cfoDiscount, 1e-9),
    reason: '$reason: CFO discount',
  );
  expect(actual.score, closeTo(expected.score, 1e-9), reason: '$reason: score');
}

void _expectOffersEqual(
  StaffOffer? actual,
  StaffOffer? expected, {
  required String reason,
}) {
  expect(actual?.salary, expected?.salary, reason: '$reason: salary');
  expect(actual?.years, expected?.years, reason: '$reason: years');
}

void _expectOffersDifferent(
  StaffOffer? first,
  StaffOffer? second, {
  required String reason,
  required bool allowNullEquality,
}) {
  if (allowNullEquality && (first == null || second == null)) return;
  expect(first, isNotNull, reason: '$reason: first counter was null');
  expect(second, isNotNull, reason: '$reason: second counter was null');
  expect(
    first!.salary != second!.salary || first.years != second.years,
    isTrue,
    reason: reason,
  );
}

void _expectNegotiationCounter(
  ContractNegotiation negotiation,
  StaffOffer? expected, {
  required String reason,
}) {
  expect(
    negotiation.counterOffer?.salary,
    expected?.salary,
    reason: '$reason: salary',
  );
  expect(
    negotiation.counterOffer?.years,
    expected?.years,
    reason: '$reason: years',
  );
}

StaffOffer? _staffOfferFromNegotiation(NegotiationOffer? offer) =>
    offer == null ? null : StaffOffer(salary: offer.salary, years: offer.years);

int _stableSeed(String value) {
  var result = 0x45d9f3b;
  for (final code in value.codeUnits) {
    result = ((result * 33) ^ code) & 0x7fffffff;
  }
  return result == 0 ? 1 : result;
}

int _seedFor(StaffRole role) => _propertySeed + role.index * 1009;

String _reason(
  _Scenario scenario, {
  required int caseIndex,
  required int seed,
}) {
  final raw = expectedStaffRawOverall(
    scenario.member.attributes,
    scenario.member.role,
  );
  final displayed = expectedStaffDisplayedRating(raw);
  return '$_propertyTag role=${scenario.member.role.name} seed=$seed '
      'case=$caseIndex replaySeed=${scenario.seed} raw=$raw '
      'displayed=$displayed offer=${scenario.offer.salary}/'
      '${scenario.offer.years} marketStatus=${scenario.marketStatus.name} '
      'directOffering=${scenario.directOfferingStatus.name} '
      'directCurrent=${scenario.directCurrentStatus.name} '
      'phase=${scenario.phase.name} round=${scenario.round} '
      'cfo=${scenario.assistingCfo?.overall}';
}
