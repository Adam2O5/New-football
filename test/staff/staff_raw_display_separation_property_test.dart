@Tags(['property'])
library;

// Feature: staff-role-ratings, Property 3: Raw i displayed są rozdzielone.
//
// This deterministic property-like test intentionally keeps its rating oracle
// outside production code. The role projection and raw formula come from the
// docs/staff.md fixture map in staff_role_ratings_test_helpers.dart. Displayed
// values are checked separately, so a production implementation cannot make a
// rounded presentation value look like a valid domain result.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/staff_service.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

const _propertyTag =
    'Feature: staff-role-ratings, Property 3: Raw i displayed są rozdzielone';
const _casesPerRole = 24;
const _propertySeed = staffFixtureSeed + 703;
const _rawDisplayBoundary = 3.25;
const _sameDisplayedRoundedRaw = 3.5;
const _fixedOffer = StaffOffer(salary: 2500000, years: 3);

void main() {
  group(_propertyTag, () {
    // **Validates: Requirements 2.1, 2.3, 2.7, 4.1, 4.2, 4.5, 4.6, 4.12,
    // 6.1, 6.2, 6.3, 6.4, 6.8, 7.1, 7.2, 7.3, 8.1, 8.3, 8.4**
    for (final role in StaffRole.values) {
      test('${role.name}: $_casesPerRole seeded raw/display cases keep '
          'domain consumers on RawOverall', () {
        final seed = _seedFor(role);
        final random = Random(seed);
        final cases = _generatedAttributeCases(role, random);

        expect(
          cases,
          hasLength(_casesPerRole),
          reason: _caseReason(
            role: role,
            seed: seed,
            caseIndex: -1,
            attributes: cases.isEmpty ? const StaffAttributes() : cases.first,
            expectedRaw: 0.0,
            expectedDisplayed: 0.0,
          ),
        );

        for (var caseIndex = 0; caseIndex < cases.length; caseIndex++) {
          final attributes = cases[caseIndex];
          final member = staffMemberFor(
            role,
            attributes: attributes,
            id: 'raw_display_${role.name}_$caseIndex',
            index: caseIndex + 1,
            age: 35 + (caseIndex % 26),
          );
          final expectedRaw = expectedStaffRawOverall(attributes, role);
          final expectedDisplayed = _oracleDisplayedRating(expectedRaw);
          final reason = _caseReason(
            role: role,
            seed: seed,
            caseIndex: caseIndex,
            attributes: attributes,
            expectedRaw: expectedRaw,
            expectedDisplayed: expectedDisplayed,
          );

          _expectRawAndPresentation(
            member,
            role: role,
            expectedRaw: expectedRaw,
            expectedDisplayed: expectedDisplayed,
            reason: reason,
          );
          _expectContractConsumers(
            member,
            expectedRaw: expectedRaw,
            role: role,
            seed: seed,
            caseIndex: caseIndex,
            reason: reason,
          );
        }
      });
    }

    // **Validates: Requirements 4.2, 4.3, 4.4, 4.7, 4.8, 4.12**
    test('presentation oracle covers finite out-of-range and non-finite raw '
        'inputs', () {
      final rawCases = <double>[
        double.negativeInfinity,
        -10.0,
        -0.01,
        0.0,
        0.24,
        0.25,
        2.25,
        2.75,
        3.25,
        3.75,
        5.0,
        5.01,
        10.0,
        double.infinity,
        double.nan,
      ];

      for (var caseIndex = 0; caseIndex < rawCases.length; caseIndex++) {
        final raw = rawCases[caseIndex];
        final expectedDisplayed = _oracleDisplayedRating(raw);
        final reason =
            '$_propertyTag seed=$_propertySeed case=$caseIndex '
            'presentationRaw=$raw expectedDisplayed=$expectedDisplayed';

        expect(
          StaffPresentation.displayedRatingForRaw(raw),
          expectedDisplayed,
          reason: reason,
        );
        expect(
          StaffPresentation.starsForRaw(raw),
          _starsForDisplayed(expectedDisplayed),
          reason: '$reason\nGraphicStar projection changed',
        );
        expect(
          StaffPresentation.starsForRaw(raw),
          hasLength(5),
          reason: '$reason\nDisplayed rating must always have five positions',
        );
      }
    });

    // **Validates: Requirements 2.7, 5.4, 6.1, 6.2, 6.3, 6.4, 6.8, 7.1,
    // 7.2, 7.3, 7.4, 8.1, 8.3, 8.4**
    test('raw 3.25 remains distinct from displayed 3.5 through salary, '
        'negotiation, market, payroll and AI paths', () {
      for (final role in StaffRole.values) {
        final seed = _seedFor(role) + 9000;
        final rawMember = _memberWithRaw(
          role,
          _rawDisplayBoundary,
          id: 'boundary_raw_${role.name}',
          age: 45,
        );
        final roundedMember = _memberWithRaw(
          role,
          _sameDisplayedRoundedRaw,
          id: 'boundary_rounded_${role.name}',
          age: 45,
        );
        final reason =
            '$_propertyTag role=${role.name} seed=$seed '
            'boundary raw=$_rawDisplayBoundary '
            'displayed=${_oracleDisplayedRating(_rawDisplayBoundary)}';
        final service = StaffService(random: Random(seed));

        expect(
          StaffPresentation.viewForMember(rawMember).rating!.displayedRating,
          StaffPresentation.viewForMember(
            roundedMember,
          ).rating!.displayedRating,
          reason: '$reason\nBoth inputs must share one DisplayedRating bucket',
        );
        expect(
          StaffPresentation.viewForMember(rawMember).rating!.rawOverall,
          _rawDisplayBoundary,
          reason: '$reason\nThe view lost the unrounded raw input',
        );
        expect(
          StaffPresentation.viewForMember(roundedMember).rating!.rawOverall,
          _sameDisplayedRoundedRaw,
          reason: '$reason\nThe view changed the raw input',
        );

        final rawMarketSalary = service.marketSalary(rawMember);
        final roundedMarketSalary = service.marketSalary(roundedMember);
        expect(
          rawMarketSalary,
          BalanceConfig.defaults.staff.salaryFor(role, _rawDisplayBoundary),
          reason:
              '$reason\nmarketSalary did not use the independent raw oracle',
        );
        expect(
          rawMarketSalary,
          isNot(roundedMarketSalary),
          reason: '$reason\nmarketSalary appears to consume DisplayedRating',
        );

        final rawWant = service.staffWant(rawMember);
        final roundedWant = service.staffWant(roundedMember);
        expect(rawWant, 65.0, reason: '$reason\nraw staffWant changed');
        expect(
          roundedWant,
          70.0,
          reason: '$reason\nrounded comparison fixture is invalid',
        );
        expect(
          rawWant,
          isNot(roundedWant),
          reason: '$reason\nstaffWant consumed DisplayedRating',
        );

        final rawExpectedSalary = service.expectedSalary(rawMember);
        final roundedExpectedSalary = service.expectedSalary(roundedMember);
        final rawExpectedLength = service.expectedLength(rawMember);
        final roundedExpectedLength = service.expectedLength(roundedMember);
        expect(
          rawExpectedSalary,
          isNot(roundedExpectedSalary),
          reason: '$reason\nexpectedSalary consumed DisplayedRating',
        );
        expect(
          rawExpectedLength,
          3,
          reason: '$reason\nraw expectedLength crossed the display band',
        );
        expect(
          roundedExpectedLength,
          4,
          reason: '$reason\nrounded comparison fixture is invalid',
        );
        expect(
          rawExpectedLength,
          isNot(roundedExpectedLength),
          reason: '$reason\nexpectedLength consumed DisplayedRating',
        );

        final rawBreakdown = service.staffOfferBreakdown(
          rawMember,
          _fixedOffer,
        );
        final roundedBreakdown = service.staffOfferBreakdown(
          roundedMember,
          _fixedOffer,
        );
        expect(
          rawBreakdown.score,
          isNot(roundedBreakdown.score),
          reason: '$reason\nstaff negotiation score consumed DisplayedRating',
        );
        expect(
          service.staffOfferScore(rawMember, _fixedOffer),
          rawBreakdown.score,
          reason: '$reason\nstaffOfferScore diverged from raw breakdown',
        );
        expect(
          service.staffOfferScore(roundedMember, _fixedOffer),
          roundedBreakdown.score,
          reason: '$reason\nrounded score path is not self-consistent',
        );

        final rawCounter = service.counterOfferForRound(
          rawMember,
          _fixedOffer,
          round: 1,
        );
        final roundedCounter = service.counterOfferForRound(
          roundedMember,
          _fixedOffer,
          round: 1,
        );
        expect(rawCounter, isNotNull, reason: '$reason\nraw counter missing');
        expect(
          roundedCounter,
          isNotNull,
          reason: '$reason\nrounded comparison counter missing',
        );
        expect(
          rawCounter!.salary != roundedCounter!.salary ||
              rawCounter.years != roundedCounter.years,
          isTrue,
          reason: '$reason\ncounter offer consumed DisplayedRating',
        );

        final rawMarketScore = _submitMarketScore(
          rawMember,
          saveSeed: staffFixtureSaveSeed + role.index,
          reason: reason,
        );
        final roundedMarketScore = _submitMarketScore(
          roundedMember,
          saveSeed: staffFixtureSaveSeed + role.index,
          reason: reason,
        );
        expect(
          rawMarketScore,
          rawBreakdown.score,
          reason:
              '$reason\nContractMarketService recomputed a different raw score',
        );
        expect(
          roundedMarketScore,
          roundedBreakdown.score,
          reason: '$reason\nContractMarketService rounded its comparison input',
        );
        expect(
          rawMarketScore,
          isNot(roundedMarketScore),
          reason: '$reason\nContractMarketService consumed DisplayedRating',
        );

        final contract = staffFixtureContract(salary: 1750000);
        final rawPayroll = teamStaffOf({
          role: rawMember.copyWith(contract: contract),
        }).totalSalary;
        final roundedPayroll = teamStaffOf({
          role: roundedMember.copyWith(contract: contract),
        }).totalSalary;
        expect(
          rawPayroll,
          contract.salary,
          reason: '$reason\nraw payroll is not the active contract salary',
        );
        expect(
          rawPayroll,
          roundedPayroll,
          reason: '$reason\npayroll consumed a rating/display value',
        );

        _expectAiRawRanking(role: role, seed: seed, reason: reason);
      }
    });
  });
}

void _expectRawAndPresentation(
  StaffMember member, {
  required StaffRole role,
  required double expectedRaw,
  required double expectedDisplayed,
  required String reason,
}) {
  expect(
    StaffRatingSystem.rawOverall(member.attributes, role),
    expectedRaw,
    reason:
        '$reason\nStaffRatingSystem differs from the independent raw oracle',
  );
  expect(
    member.overall,
    expectedRaw,
    reason:
        '$reason\nStaffMember.overall must stay unrounded and role-specific',
  );

  final slot = StaffPresentation.viewForMember(member);
  expect(slot.state, StaffSlotState.occupied, reason: reason);
  final rating = slot.rating;
  if (rating == null) {
    fail('$reason\nStaffPresentation did not create an occupied rating view');
  }

  expect(
    rating.rawOverall,
    expectedRaw,
    reason: '$reason\nStaffRatingView.rawOverall was rounded or remapped',
  );
  expect(
    rating.displayedRating,
    expectedDisplayed,
    reason: '$reason\nDisplayedRating did not use half-up/clamp oracle',
  );
  expect(
    rating.stars,
    _starsForDisplayed(expectedDisplayed),
    reason: '$reason\nGraphicStar segments are not derived from displayed',
  );
  expect(
    rating.accessibilityValue,
    expectedDisplayed.toStringAsFixed(1),
    reason: '$reason\nAccessibility value must come from displayed',
  );
  expect(
    rating.accessibilityLabel,
    'Rating ${expectedDisplayed.toStringAsFixed(1)} out of 5',
    reason: '$reason\nAccessibility label must come from displayed',
  );
  if (expectedRaw != expectedDisplayed) {
    expect(
      rating.rawOverall,
      isNot(expectedDisplayed),
      reason: '$reason\nThe view exposed DisplayedRating as raw domain input',
    );
  }
}

void _expectContractConsumers(
  StaffMember member, {
  required StaffRole role,
  required double expectedRaw,
  required int seed,
  required int caseIndex,
  required String reason,
}) {
  const balance = BalanceConfig.defaults;
  final status =
      TeamStatus.values[(role.index + caseIndex) % TeamStatus.values.length];
  final service = StaffService(random: Random(seed + caseIndex));
  final expectedWant = _oracleStaffWant(expectedRaw, status);
  final expectedSalary = _oracleExpectedSalary(expectedWant, balance);
  final expectedLength = _oracleExpectedLength(expectedWant, member.age);

  expect(
    service.marketSalary(member),
    balance.staff.salaryFor(role, expectedRaw),
    reason: '$reason\nmarketSalary did not consume canonical RawOverall',
  );
  expect(
    service.staffWant(member, currentTeamStatus: status),
    expectedWant,
    reason: '$reason\nstaffWant did not consume canonical RawOverall',
  );
  expect(
    service.expectedSalary(member, currentTeamStatus: status),
    expectedSalary,
    reason: '$reason\nexpectedSalary did not use raw staffWant',
  );
  expect(
    service.expectedLength(member, currentTeamStatus: status),
    expectedLength,
    reason: '$reason\nexpectedLength did not use raw staffWant',
  );

  final expectedBreakdown = NegotiationRules.score(
    salary: _fixedOffer.salary,
    expectedSalary: expectedSalary,
    years: _fixedOffer.years,
    expectedLength: expectedLength,
    offeringTeamStatus: status,
    cfoNegotiation: 4.0,
    balance: balance.contracts,
  );
  final breakdown = service.staffOfferBreakdown(
    member,
    _fixedOffer,
    offeringTeamStatus: status,
    currentTeamStatus: status,
    cfoNegotiation: 4.0,
  );
  _expectClose(
    breakdown.salaryFit,
    expectedBreakdown.salaryFit,
    '$reason\nraw salary-fit oracle mismatch',
  );
  _expectClose(
    breakdown.lengthFit,
    expectedBreakdown.lengthFit,
    '$reason\nraw length-fit oracle mismatch',
  );
  _expectClose(
    breakdown.teamStatus,
    expectedBreakdown.teamStatus,
    '$reason\nteam-status score changed',
  );
  _expectClose(
    breakdown.cfoDiscount,
    expectedBreakdown.cfoDiscount,
    '$reason\nCFO score input changed',
  );
  _expectClose(
    breakdown.score,
    expectedBreakdown.score,
    '$reason\nstaffOfferBreakdown consumed displayed instead of raw',
  );
  _expectClose(
    service.staffOfferScore(
      member,
      _fixedOffer,
      offeringTeamStatus: status,
      currentTeamStatus: status,
      cfoNegotiation: 4.0,
    ),
    expectedBreakdown.score,
    '$reason\nstaffOfferScore diverged from the raw negotiation oracle',
  );

  final irrelevantName = irrelevantStaffAttributeNames(role).first;
  final irrelevantCurrent = staffAttributeByName(
    member.attributes,
    irrelevantName,
  );
  final irrelevantValue = irrelevantCurrent == 5.0 ? 0.0 : 5.0;
  final irrelevantMutation = member.copyWith(
    attributes: withIrrelevantStaffAttribute(
      member.attributes,
      role,
      name: irrelevantName,
      value: irrelevantValue,
    ),
  );
  expect(
    staffAttributeByName(irrelevantMutation.attributes, irrelevantName),
    isNot(irrelevantCurrent),
    reason: '$reason\nfixture did not mutate an irrelevant field',
  );
  expect(
    irrelevantMutation.overall,
    expectedRaw,
    reason: '$reason\nlegacy/irrelevant mutation changed RawOverall',
  );
  expect(
    service.marketSalary(irrelevantMutation),
    service.marketSalary(member),
    reason: '$reason\nmarketSalary changed after irrelevant mutation',
  );
  expect(
    service.staffWant(irrelevantMutation, currentTeamStatus: status),
    service.staffWant(member, currentTeamStatus: status),
    reason: '$reason\nstaffWant changed after irrelevant mutation',
  );
  expect(
    service.expectedSalary(irrelevantMutation, currentTeamStatus: status),
    service.expectedSalary(member, currentTeamStatus: status),
    reason: '$reason\nexpectedSalary changed after irrelevant mutation',
  );
  expect(
    service.expectedLength(irrelevantMutation, currentTeamStatus: status),
    service.expectedLength(member, currentTeamStatus: status),
    reason: '$reason\nexpectedLength changed after irrelevant mutation',
  );

  final mutatedBreakdown = service.staffOfferBreakdown(
    irrelevantMutation,
    _fixedOffer,
    offeringTeamStatus: status,
    currentTeamStatus: status,
    cfoNegotiation: 4.0,
  );
  _expectClose(
    mutatedBreakdown.score,
    breakdown.score,
    '$reason\nstaff negotiation score changed after irrelevant mutation',
  );
  _expectClose(
    service.staffOfferScore(
      irrelevantMutation,
      _fixedOffer,
      offeringTeamStatus: status,
      currentTeamStatus: status,
      cfoNegotiation: 4.0,
    ),
    breakdown.score,
    '$reason\nstaffOfferScore changed after irrelevant mutation',
  );

  final memberCounter = service.counterOfferForRound(
    member,
    _fixedOffer,
    round: 1,
    offeringTeamStatus: status,
    currentTeamStatus: status,
    cfoNegotiation: 4.0,
  );
  final irrelevantCounter = service.counterOfferForRound(
    irrelevantMutation,
    _fixedOffer,
    round: 1,
    offeringTeamStatus: status,
    currentTeamStatus: status,
    cfoNegotiation: 4.0,
  );
  expect(
    irrelevantCounter?.salary,
    memberCounter?.salary,
    reason: '$reason\ncounter salary changed after irrelevant mutation',
  );
  expect(
    irrelevantCounter?.years,
    memberCounter?.years,
    reason: '$reason\ncounter length changed after irrelevant mutation',
  );

  final reaction = service.evaluateOffer(
    member,
    _fixedOffer,
    phase: NegotiationPhase.freeAgencyPhaseI,
    offeringTeamStatus: status,
    currentTeamStatus: status,
    cfoNegotiation: 4.0,
    belowExpectation: _fixedOffer.salary < expectedSalary,
    random: Random(seed + caseIndex + 100000),
  );
  final irrelevantReaction = service.evaluateOffer(
    irrelevantMutation,
    _fixedOffer,
    phase: NegotiationPhase.freeAgencyPhaseI,
    offeringTeamStatus: status,
    currentTeamStatus: status,
    cfoNegotiation: 4.0,
    belowExpectation: _fixedOffer.salary < expectedSalary,
    random: Random(seed + caseIndex + 100000),
  );
  expect(
    irrelevantReaction,
    reaction,
    reason: '$reason\nreaction changed after irrelevant mutation',
  );

  final contract = staffFixtureContract(
    salary: 1250000 + role.index * 10000 + caseIndex,
  );
  final memberWithContract = member.copyWith(contract: contract);
  final irrelevantWithContract = irrelevantMutation.copyWith(
    contract: contract,
  );
  final memberPayroll = teamStaffOf({role: memberWithContract}).totalSalary;
  final irrelevantPayroll = teamStaffOf({
    role: irrelevantWithContract,
  }).totalSalary;
  expect(
    memberPayroll,
    contract.salary,
    reason: '$reason\npayroll was not the active contract salary',
  );
  expect(
    irrelevantPayroll,
    memberPayroll,
    reason: '$reason\npayroll changed with irrelevant/rating data',
  );
}

void _expectAiRawRanking({
  required StaffRole role,
  required int seed,
  required String reason,
}) {
  final low = _memberWithRaw(role, 3.26, id: 'a_low_${role.name}');
  final high = _memberWithRaw(role, 3.30, id: 'z_high_${role.name}');
  final tieA = _memberWithRaw(role, 3.0, id: 'a_tie_${role.name}');
  final tieZ = _memberWithRaw(role, 3.0, id: 'z_tie_${role.name}');

  expect(
    _oracleDisplayedRating(low.overall),
    _oracleDisplayedRating(high.overall),
    reason: '$reason\nAI collision fixtures must share DisplayedRating',
  );
  final sorted = StaffPresentation.sortStaffCandidates([high, low], role);
  expect(
    sorted.map((member) => member.id),
    ['z_high_${role.name}', 'a_low_${role.name}'],
    reason: '$reason\nvisual rounding replaced raw candidate ordering',
  );
  final sortedTies = StaffPresentation.sortStaffCandidates([tieZ, tieA], role);
  expect(
    sortedTies.map((member) => member.id),
    ['a_tie_${role.name}', 'z_tie_${role.name}'],
    reason: '$reason\nexact raw tie did not use stable ID order',
  );

  final team = staffFixtureTeam();
  final league = staffFixtureLeague(
    teams: [team],
    staffFreeAgents: [high, low],
  );
  final policy = AiContractMarketService();
  final plan = policy.staffFreeAgentPlan(
    league: league,
    team: team,
    saveSeed: seed,
  );
  expect(
    plan,
    isNotNull,
    reason: '$reason\nAI did not build a legal staff plan',
  );
  if (plan == null) return;
  expect(
    plan.member.id,
    high.id,
    reason:
        '$reason\nAI selected by DisplayedRating/ID instead of higher RawOverall',
  );
  expect(plan.role, role, reason: '$reason\nAI changed the selected role');

  final expectedScore = StaffService().staffOfferScore(
    plan.member,
    plan.offer,
    offeringTeamStatus: TeamStatus.pretender,
    currentTeamStatus: TeamStatus.pretender,
  );
  _expectClose(
    plan.offerScore,
    expectedScore,
    '$reason\nAI offer score did not use StaffService RawOverall path',
  );

  final irrelevantHigh = high.copyWith(
    attributes: withIrrelevantStaffAttribute(high.attributes, role, value: 0.0),
  );
  final irrelevantLeague = staffFixtureLeague(
    teams: [team],
    staffFreeAgents: [irrelevantHigh, low],
  );
  final irrelevantPlan = policy.staffFreeAgentPlan(
    league: irrelevantLeague,
    team: team,
    saveSeed: seed,
  );
  expect(
    irrelevantPlan,
    isNotNull,
    reason: '$reason\nAI plan disappeared after irrelevant mutation',
  );
  if (irrelevantPlan == null) return;
  expect(
    irrelevantPlan.member.id,
    plan.member.id,
    reason: '$reason\nAI member changed after irrelevant mutation',
  );
  expect(
    irrelevantPlan.offer.salary,
    plan.offer.salary,
    reason: '$reason\nAI salary offer changed after irrelevant mutation',
  );
  expect(
    irrelevantPlan.offer.years,
    plan.offer.years,
    reason: '$reason\nAI contract length changed after irrelevant mutation',
  );
  _expectClose(
    irrelevantPlan.offerScore,
    plan.offerScore,
    '$reason\nAI score changed after irrelevant mutation',
  );

  final tieLeague = staffFixtureLeague(
    teams: [team],
    staffFreeAgents: [tieZ, tieA],
  );
  final tiePlan = policy.staffFreeAgentPlan(
    league: tieLeague,
    team: team,
    saveSeed: seed,
  );
  expect(tiePlan, isNotNull, reason: '$reason\nAI tie fixture was not legal');
  expect(
    tiePlan?.member.id,
    tieA.id,
    reason: '$reason\nAI exact raw tie did not use ascending stable ID',
  );
}

List<StaffAttributes> _generatedAttributeCases(StaffRole role, Random random) {
  final relevantCount = relevantStaffAttributeNames(role).length;
  List<double> values(double first, double second) =>
      relevantCount == 1 ? [first] : [first, second];
  final cases = <StaffAttributes>[
    staffAttributesWithRawOverall(
      role,
      3.25,
      spread: relevantCount == 1 ? 0.0 : 0.25,
      irrelevantValue: 5.0,
    ),
    staffAttributesWithRawOverall(
      role,
      3.75,
      spread: relevantCount == 1 ? 0.0 : 0.25,
      irrelevantValue: -4.0,
    ),
    staffAttributesForRole(role, values(0.0, 5.0), irrelevantValue: 5.0),
    staffAttributesForRole(role, values(5.0, 0.0), irrelevantValue: -4.0),
    staffAttributesForRole(
      role,
      List<double>.filled(relevantCount, -4.0),
      irrelevantValue: 9.5,
    ),
    staffAttributesForRole(
      role,
      List<double>.filled(relevantCount, 9.5),
      irrelevantValue: -4.0,
    ),
    staffAttributesWithRawOverall(role, 3.0, irrelevantValue: 5.0),
    staffAttributesWithRawOverall(role, 3.0, irrelevantValue: 0.0),
  ];

  while (cases.length < _casesPerRole) {
    cases.add(randomStaffAttributes(random, includeOutOfRange: true));
  }
  return cases;
}

StaffMember _memberWithRaw(
  StaffRole role,
  double raw, {
  required String id,
  int age = 45,
}) => staffMemberFor(
  role,
  attributes: staffAttributesWithRawOverall(
    role,
    raw,
    spread: relevantStaffAttributeNames(role).length == 1 ? 0.0 : 0.0,
    irrelevantValue: 5.0,
  ),
  id: id,
  age: age,
);

double _oracleDisplayedRating(double raw) {
  final bounded = raw.isNaN ? 0.0 : raw.clamp(0.0, 5.0).toDouble();
  return ((bounded * 2.0) + 0.5).floorToDouble() / 2.0;
}

List<GraphicStar> _starsForDisplayed(double displayed) {
  final full = displayed.floor();
  final half = displayed - full >= 0.5 ? 1 : 0;
  return [
    ...List<GraphicStar>.filled(full, GraphicStar.full),
    if (half == 1) GraphicStar.half,
    ...List<GraphicStar>.filled(5 - full - half, GraphicStar.empty),
  ];
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

double _submitMarketScore(
  StaffMember candidate, {
  required int saveSeed,
  required String reason,
}) {
  final result = ContractMarketService().submitStaffOffer(
    league: staffFixtureLeague(
      teams: [staffFixtureTeam()],
      staffFreeAgents: [candidate],
    ),
    candidate: candidate,
    offer: _fixedOffer,
    saveSeed: saveSeed,
  );
  if (result == null) {
    fail('$reason\nContractMarketService rejected the legal staff fixture');
  }
  final negotiations = result.league.negotiations;
  if (negotiations.length != 1) {
    fail(
      '$reason\nContractMarketService created ${negotiations.length} '
      'negotiations instead of one',
    );
  }
  return negotiations.single.offerScore;
}

void _expectClose(double actual, double expected, String reason) {
  expect(actual, closeTo(expected, 1e-9), reason: reason);
}

int _seedFor(StaffRole role) => _propertySeed + role.index * 1009;

String _caseReason({
  required StaffRole role,
  required int seed,
  required int caseIndex,
  required StaffAttributes attributes,
  required double expectedRaw,
  required double expectedDisplayed,
}) =>
    '$_propertyTag role=${role.name} seed=$seed case=$caseIndex '
    'raw=$expectedRaw displayed=$expectedDisplayed attributes=$attributes';
