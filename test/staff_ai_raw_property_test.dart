// Feature: staff-role-ratings, Property 10: AI market jest deterministycznym konsumentem raw ratingu.
//
// This is an independent property-like harness for the AI market. Its raw,
// salary and score expectations are rebuilt from the staff-role fixture oracle
// and NegotiationRules instead of calling presentation helpers as an oracle.
// Every case is replayable from the reported role/status/seed/case tuple.

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
import 'package:new_football/core/services/staff_service.dart';

import 'helpers/staff_role_ratings_test_helpers.dart';

const _propertyTag =
    'Feature: staff-role-ratings, Property 10: AI market jest deterministycznym konsumentem raw ratingu';
const _casesPerRoleAndStatus = 4;
const _propertySeed = staffFixtureSeed + 10010;
const _collisionLowRaw = 3.25;
const _collisionHighRaw = 3.30;

void main() {
  group(_propertyTag, () {
    // **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 6.1, 6.2, 6.3,
    // 6.4, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 10.9**
    test('120 seeded role/status cases keep direct AI and persisted market on '
        'canonical RawOverall', () {
      var caseCount = 0;
      for (final role in StaffRole.values) {
        for (final status in TeamStatus.values) {
          var sawExtensionPlan = false;
          for (
            var caseIndex = 0;
            caseIndex < _casesPerRoleAndStatus;
            caseIndex++
          ) {
            final scenario = _scenarioFor(
              role: role,
              status: status,
              caseIndex: caseIndex,
            );
            _assertFreeAgentCase(scenario);
            final extensionPlan = _assertExtensionCase(scenario);
            sawExtensionPlan = sawExtensionPlan || extensionPlan != null;
            caseCount++;
          }
          expect(
            sawExtensionPlan,
            isTrue,
            reason:
                '$_propertyTag role=${role.name} status=${status.name}: '
                'none of the $_casesPerRoleAndStatus deterministic seeds reached '
                'the extension offer path',
          );
        }
      }
      expect(caseCount, 120);
    });

    // **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 8.1, 8.2, 8.6, 8.7,
    // 8.8, 10.9**
    test('raw/display collisions still rank by RawOverall and exact ties by ID '
        'for every role and status', () {
      final policy = AiContractMarketService();
      for (final role in StaffRole.values) {
        for (final status in TeamStatus.values) {
          final seed = _seedFor(role, status, 90);
          final reason =
              '$_propertyTag role=${role.name} status=${status.name} '
              'seed=$seed case=collision';
          final low = staffMemberFor(
            role,
            attributes: staffAttributesWithRawOverall(
              role,
              _collisionLowRaw,
              spread: _spreadFor(role, _collisionLowRaw),
              irrelevantValue: 0.0,
            ),
            id: 'z_collision_low_${role.name}_${status.name}',
            age: 45,
          );
          final high = staffMemberFor(
            role,
            attributes: staffAttributesWithRawOverall(
              role,
              _collisionHighRaw,
              spread: _spreadFor(role, _collisionHighRaw),
              irrelevantValue: 5.0,
            ),
            id: 'a_collision_high_${role.name}_${status.name}',
            age: 45,
          );
          final mismatched = staffRoleMismatchedMember(
            role,
            declaredRole:
                StaffRole.values[(role.index + 1) % StaffRole.values.length],
            index: 901 + role.index * 10 + status.index,
          );
          final candidates = [low, mismatched, high];
          final state = _freeAgentState(
            _AiScenario(
              role: role,
              status: status,
              caseIndex: 90,
              seed: seed,
              raw: _collisionHighRaw,
              age: 45,
            ),
            candidates,
          );
          final team = state.teamById(_teamId(role, status, 90, 'fa'));
          expect(team, isNotNull, reason: reason);
          if (team == null) continue;

          final lowView = StaffPresentation.viewForMember(low).rating!;
          final highView = StaffPresentation.viewForMember(high).rating!;
          expect(
            lowView.displayedRating,
            highView.displayedRating,
            reason: '$reason raw collision did not share DisplayedRating',
          );
          expect(
            low.overall,
            isNot(high.overall),
            reason: '$reason fixture did not preserve distinct RawOverall',
          );

          final direct = policy.staffFreeAgentPlan(
            league: state,
            team: team,
            saveSeed: seed,
          );
          expect(direct, isNotNull, reason: '$reason direct AI plan missing');
          if (direct == null) continue;
          expect(
            direct.member.id,
            high.id,
            reason:
                '$reason AI selected by DisplayedRating/ID instead of higher RawOverall',
          );
          expect(
            direct.member.role,
            role,
            reason: '$reason non-canonical role selected',
          );
          _expectPlanScore(
            direct,
            status: status,
            assistingCfo: team.staff.cfo,
            subjectRole: role,
            reason: reason,
          );

          final tieA = staffMemberFor(
            role,
            attributes: staffAttributesWithRawOverall(
              role,
              3.0,
              spread: _spreadFor(role, 3.0),
            ),
            id: 'a_collision_tie_${role.name}_${status.name}',
            age: 45,
          );
          final tieZ = tieA.copyWith(
            id: 'z_collision_tie_${role.name}_${status.name}',
          );
          final tieCandidates = [tieZ, mismatched, tieA];
          final tieState = _freeAgentState(
            _AiScenario(
              role: role,
              status: status,
              caseIndex: 91,
              seed: seed + 1,
              raw: 3.0,
              age: 45,
            ),
            tieCandidates,
          );
          final tieTeam = tieState.teamById(_teamId(role, status, 91, 'fa'));
          expect(tieTeam, isNotNull, reason: reason);
          if (tieTeam == null) continue;
          final tiePlan = policy.staffFreeAgentPlan(
            league: tieState,
            team: tieTeam,
            saveSeed: seed + 1,
          );
          expect(tiePlan, isNotNull, reason: '$reason exact-tie plan missing');
          expect(
            tiePlan?.member.id,
            tieA.id,
            reason: '$reason exact raw tie did not use ascending stable ID',
          );

          final persisted = _resolveFreeAgent(tieState, seed + 1);
          final negotiation = _staffNegotiationFor(
            persisted,
            tieA.id,
            reason: '$reason persisted tie negotiation missing',
          );
          expect(
            negotiation?.lastOffer.salary,
            tiePlan?.offer.salary,
            reason: '$reason persisted tie salary diverged from direct plan',
          );
          expect(
            negotiation?.lastOffer.years,
            tiePlan?.offer.years,
            reason: '$reason persisted tie years diverged from direct plan',
          );
          if (tiePlan != null && negotiation != null) {
            expect(
              negotiation.offerScore,
              closeTo(tiePlan.offerScore, 1e-9),
              reason: '$reason persisted tie score diverged from direct plan',
            );
          }
        }
      }
    });

    // **Validates: Requirements 7.6, 7.8, 8.3, 8.4, 8.5, 8.6, 8.8, 10.9**
    test('CFO subject never self-assists in AI offer construction or persisted '
        'recomputation', () {
      for (final status in TeamStatus.values) {
        final generatedBase = _scenarioFor(
          role: StaffRole.cfo,
          status: status,
          caseIndex: 0,
        );
        final baseScenario = _AiScenario(
          role: generatedBase.role,
          status: generatedBase.status,
          caseIndex: generatedBase.caseIndex,
          seed: generatedBase.seed,
          raw: 1.0,
          age: generatedBase.age,
        );
        _AiScenario? selectedScenario;
        for (var offset = 0; offset < 2000; offset++) {
          final candidateScenario = _AiScenario(
            role: StaffRole.cfo,
            status: status,
            caseIndex: baseScenario.caseIndex,
            seed: baseScenario.seed + offset,
            raw: baseScenario.raw,
            age: baseScenario.age,
          );
          final candidateMember = _extensionMember(candidateScenario);
          final candidateState = _extensionState(
            candidateScenario,
            candidateMember,
          );
          final candidateTeam = candidateState.teamById(
            _teamId(
              candidateScenario.role,
              status,
              candidateScenario.caseIndex,
              'extension',
            ),
          );
          if (candidateTeam == null) continue;
          final candidatePlan = AiContractMarketService().staffExtensionPlan(
            league: candidateState,
            team: candidateTeam,
            saveSeed: candidateScenario.seed,
          );
          if (candidatePlan != null) {
            selectedScenario = candidateScenario;
            break;
          }
        }
        expect(
          selectedScenario,
          isNotNull,
          reason: _reason(baseScenario, path: 'cfo-self-assist-seed-search'),
        );
        if (selectedScenario == null) continue;
        final scenario = selectedScenario;
        final reason = _reason(scenario, path: 'cfo-self-assist');
        final member = _extensionMember(scenario);
        final state = _extensionState(scenario, member);
        final team = state.teamById(
          _teamId(scenario.role, status, scenario.caseIndex, 'extension'),
        );
        expect(team, isNotNull, reason: reason);
        if (team == null) continue;

        final plan = AiContractMarketService().staffExtensionPlan(
          league: state,
          team: team,
          saveSeed: scenario.seed,
        );
        expect(plan, isNotNull, reason: '$reason CFO extension plan missing');
        if (plan == null) continue;
        _expectPlanScore(
          plan,
          status: status,
          assistingCfo: null,
          subjectRole: StaffRole.cfo,
          reason: reason,
        );
        final selfAssistedScore = StaffService().staffOfferScore(
          plan.member,
          plan.offer,
          offeringTeamStatus: status,
          currentTeamStatus: status,
          cfo: plan.member,
        );
        expect(
          plan.offerScore,
          isNot(closeTo(selfAssistedScore, 1e-9)),
          reason: '$reason subject CFO was used as its own assisting CFO',
        );

        final resolved = _resolveExtension(state, scenario.seed);
        final negotiation = _staffNegotiationFor(
          resolved,
          member.id,
          reason: '$reason persisted CFO negotiation missing',
        );
        expect(
          negotiation?.offerScore,
          closeTo(plan.offerScore, 1e-9),
          reason: '$reason persisted CFO score self-assisted or diverged',
        );
      }
    });
  });
}

class _AiScenario {
  const _AiScenario({
    required this.role,
    required this.status,
    required this.caseIndex,
    required this.seed,
    required this.raw,
    required this.age,
  });

  final StaffRole role;
  final TeamStatus status;
  final int caseIndex;
  final int seed;
  final double raw;
  final int age;
}

_AiScenario _scenarioFor({
  required StaffRole role,
  required TeamStatus status,
  required int caseIndex,
}) {
  final seed = _seedFor(role, status, caseIndex);
  final random = Random(seed);
  final raw = const [0.0, 5.0, 3.25, 3.30][caseIndex];
  final age = switch (caseIndex) {
    0 => 60,
    1 => 40,
    _ => 35 + random.nextInt(18),
  };
  return _AiScenario(
    role: role,
    status: status,
    caseIndex: caseIndex,
    seed: seed,
    raw: raw,
    age: age,
  );
}

void _assertFreeAgentCase(_AiScenario scenario) {
  final reason = _reason(scenario, path: 'free-agent');
  final candidates = _freeAgentCandidates(scenario);
  final state = _freeAgentState(scenario, candidates);
  final team = state.teamById(
    _teamId(scenario.role, scenario.status, scenario.caseIndex, 'fa'),
  );
  expect(team, isNotNull, reason: reason);
  if (team == null) return;

  final policy = AiContractMarketService();
  final plan = policy.staffFreeAgentPlan(
    league: state,
    team: team,
    saveSeed: scenario.seed,
  );
  final expectedMember = _canonicalCandidates(candidates, scenario.role).first;
  if (plan == null) {
    final replay = policy.staffFreeAgentPlan(
      league: state,
      team: team,
      saveSeed: scenario.seed,
    );
    _expectPlansEqual(
      plan,
      replay,
      '$reason same seed changed a deterministic no-plan result',
    );
    final persisted = _resolveFreeAgent(state, scenario.seed);
    expect(
      _aiStaffNegotiations(persisted),
      isEmpty,
      reason:
          '$reason central market created an offer absent from direct AI plan',
    );
    final irrelevantCandidates = candidates
        .map(
          (member) =>
              member.role == scenario.role ? _toggleIrrelevant(member) : member,
        )
        .toList(growable: false);
    final irrelevantState = _freeAgentState(scenario, irrelevantCandidates);
    final irrelevantTeam = irrelevantState.teamById(
      _teamId(scenario.role, scenario.status, scenario.caseIndex, 'fa'),
    );
    expect(irrelevantTeam, isNotNull, reason: reason);
    if (irrelevantTeam != null) {
      final irrelevantPlan = policy.staffFreeAgentPlan(
        league: irrelevantState,
        team: irrelevantTeam,
        saveSeed: scenario.seed,
      );
      _expectPlansEqual(
        plan,
        irrelevantPlan,
        '$reason irrelevant attributes changed the deterministic no-plan result',
      );
      final irrelevantPersisted = _resolveFreeAgent(
        irrelevantState,
        scenario.seed,
      );
      _assertPersistedEqual(
        persisted,
        irrelevantPersisted,
        '$reason irrelevant attributes changed persisted no-plan state',
      );
    }
    return;
  }
  expect(
    plan.member.id,
    expectedMember.id,
    reason: '$reason wrong RawOverall/ID ranking',
  );
  expect(
    plan.member.role,
    scenario.role,
    reason: '$reason non-canonical role record selected',
  );
  _expectPlanScore(
    plan,
    status: scenario.status,
    assistingCfo: team.staff.cfo,
    subjectRole: scenario.role,
    reason: reason,
  );
  _expectDisplayedProjection(plan.member, reason);

  final replay = policy.staffFreeAgentPlan(
    league: state,
    team: team,
    saveSeed: scenario.seed,
  );
  _expectPlansEqual(
    plan,
    replay,
    '$reason same seed did not replay identically',
  );

  final irrelevantCandidates = candidates
      .map(
        (member) =>
            member.role == scenario.role ? _toggleIrrelevant(member) : member,
      )
      .toList(growable: false);
  final irrelevantState = _freeAgentState(scenario, irrelevantCandidates);
  final irrelevantTeam = irrelevantState.teamById(
    _teamId(scenario.role, scenario.status, scenario.caseIndex, 'fa'),
  );
  expect(irrelevantTeam, isNotNull, reason: reason);
  if (irrelevantTeam == null) return;
  final irrelevantPlan = policy.staffFreeAgentPlan(
    league: irrelevantState,
    team: irrelevantTeam,
    saveSeed: scenario.seed,
  );
  _expectPlansEqual(
    plan,
    irrelevantPlan,
    '$reason irrelevant attributes changed AI free-agent output',
  );

  final persisted = _resolveFreeAgent(state, scenario.seed);
  _assertPersistedPlan(
    persisted,
    plan,
    expectedMember.id,
    reason: '$reason ContractMarketService persisted a different AI plan',
  );
  final irrelevantPersisted = _resolveFreeAgent(irrelevantState, scenario.seed);
  _assertPersistedEqual(
    persisted,
    irrelevantPersisted,
    '$reason irrelevant attributes changed persisted AI negotiation',
  );
}

AiStaffOfferPlan? _assertExtensionCase(_AiScenario scenario) {
  final reason = _reason(scenario, path: 'extension');
  final member = _extensionMember(scenario);
  final state = _extensionState(scenario, member);
  final team = state.teamById(
    _teamId(scenario.role, scenario.status, scenario.caseIndex, 'extension'),
  );
  expect(team, isNotNull, reason: reason);
  if (team == null) return null;

  final policy = AiContractMarketService();
  final plan = policy.staffExtensionPlan(
    league: state,
    team: team,
    saveSeed: scenario.seed,
  );
  final replay = policy.staffExtensionPlan(
    league: state,
    team: team,
    saveSeed: scenario.seed,
  );
  _expectPlansEqual(
    plan,
    replay,
    '$reason same seed did not replay identically',
  );
  if (plan == null) {
    final resolved = _resolveExtension(state, scenario.seed);
    expect(
      _staffNegotiationFor(resolved, member.id, reason: reason),
      isNull,
      reason:
          '$reason central market created an offer absent from direct AI plan',
    );
    return null;
  }

  expect(
    plan.member.id,
    member.id,
    reason: '$reason extension selected another member',
  );
  expect(
    plan.member.role,
    scenario.role,
    reason: '$reason extension selected a non-canonical role',
  );
  _expectPlanScore(
    plan,
    status: scenario.status,
    assistingCfo: team.staff.cfo,
    subjectRole: scenario.role,
    reason: reason,
  );
  _expectDisplayedProjection(plan.member, reason);

  final irrelevantMember = _toggleIrrelevant(member);
  final irrelevantState = _extensionState(scenario, irrelevantMember);
  final irrelevantTeam = irrelevantState.teamById(
    _teamId(scenario.role, scenario.status, scenario.caseIndex, 'extension'),
  );
  expect(irrelevantTeam, isNotNull, reason: reason);
  if (irrelevantTeam == null) return plan;
  final irrelevantPlan = policy.staffExtensionPlan(
    league: irrelevantState,
    team: irrelevantTeam,
    saveSeed: scenario.seed,
  );
  _expectPlansEqual(
    plan,
    irrelevantPlan,
    '$reason irrelevant attributes changed AI extension output',
  );

  final persisted = _resolveExtension(state, scenario.seed);
  _assertPersistedPlan(
    persisted,
    plan,
    member.id,
    reason: '$reason ContractMarketService persisted a different AI extension',
  );
  final irrelevantPersisted = _resolveExtension(irrelevantState, scenario.seed);
  _assertPersistedEqual(
    persisted,
    irrelevantPersisted,
    '$reason irrelevant attributes changed persisted AI extension',
  );
  return plan;
}

List<StaffMember> _freeAgentCandidates(_AiScenario scenario) {
  final competitorRaw = (scenario.raw - 0.25).clamp(0.0, 5.0).toDouble();
  final primary = staffMemberFor(
    scenario.role,
    attributes: staffAttributesWithRawOverall(
      scenario.role,
      scenario.raw,
      spread: _spreadFor(scenario.role, scenario.raw),
      irrelevantValue: scenario.caseIndex.isEven ? 5.0 : 0.0,
    ),
    id: 'z_case_${scenario.role.name}_${scenario.status.name}_${scenario.caseIndex}',
    age: scenario.age,
  );
  final competitor = staffMemberFor(
    scenario.role,
    attributes: staffAttributesWithRawOverall(
      scenario.role,
      competitorRaw,
      spread: _spreadFor(scenario.role, competitorRaw),
      irrelevantValue: scenario.caseIndex.isEven ? 0.0 : 5.0,
    ),
    id: 'a_case_${scenario.role.name}_${scenario.status.name}_${scenario.caseIndex}',
    age: scenario.age,
  );
  final mismatched = staffRoleMismatchedMember(
    scenario.role,
    declaredRole:
        StaffRole.values[(scenario.role.index + 1) % StaffRole.values.length],
    index: 700 + scenario.status.index * 10 + scenario.caseIndex,
  );
  return [primary, mismatched, competitor];
}

StaffMember _extensionMember(_AiScenario scenario) => staffMemberFor(
  scenario.role,
  attributes: staffAttributesWithRawOverall(
    scenario.role,
    scenario.raw,
    spread: _spreadFor(scenario.role, scenario.raw),
    irrelevantValue: scenario.caseIndex.isEven ? 5.0 : 0.0,
  ),
  id: 'extension_${scenario.role.name}_${scenario.status.name}_${scenario.caseIndex}',
  age: scenario.age,
  contract: staffFixtureContract(salary: 1000000, yearsRemaining: 1),
);

Team _freeAgentTeam(_AiScenario scenario) {
  final members = <StaffRole, StaffMember?>{};
  for (final role in StaffRole.values) {
    if (role == scenario.role) continue;
    members[role] = staffMemberFor(
      role,
      attributes: staffAttributesWithRawOverall(
        role,
        role == StaffRole.cfo ? 4.0 : 1.0,
      ),
      id:
          'free_fill_${scenario.role.name}_${scenario.status.name}_'
          '${scenario.caseIndex}_${role.name}',
      age: 45,
    );
  }
  return staffFixtureTeam(
    id: _teamId(scenario.role, scenario.status, scenario.caseIndex, 'fa'),
    staff: teamStaffOf(members),
    ai: const TeamAiConfig(),
  );
}

Team _extensionTeam(_AiScenario scenario, StaffMember member) {
  final members = <StaffRole, StaffMember?>{};
  for (final role in StaffRole.values) {
    if (role == scenario.role) {
      members[role] = member;
      continue;
    }
    members[role] = staffMemberFor(
      role,
      attributes: staffAttributesWithRawOverall(
        role,
        role == StaffRole.cfo ? 4.0 : 1.0,
      ),
      id:
          'extension_fill_${scenario.role.name}_${scenario.status.name}_'
          '${scenario.caseIndex}_${role.name}',
      age: 45,
      contract: staffFixtureContract(salary: 1000000, yearsRemaining: 2),
    );
  }
  return staffFixtureTeam(
    id: _teamId(
      scenario.role,
      scenario.status,
      scenario.caseIndex,
      'extension',
    ),
    staff: teamStaffOf(members),
    ai: const TeamAiConfig(),
  );
}

LeagueState _freeAgentState(
  _AiScenario scenario,
  List<StaffMember> candidates,
) => staffFixtureLeague(
  teams: [_freeAgentTeam(scenario)],
  playerTeamId: null,
  staffFreeAgents: candidates,
  currentWeek: staffFixtureFreeAgencyWeek(),
  currentDay: 1,
  currentHour: 1,
  teamStatus: scenario.status,
);

LeagueState _extensionState(_AiScenario scenario, StaffMember member) =>
    staffFixtureLeague(
      teams: [_extensionTeam(scenario, member)],
      playerTeamId: null,
      currentWeek: staffFixtureExtensionWeek(),
      currentDay: 2,
      currentHour: 1,
      teamStatus: scenario.status,
    );

LeagueState _resolveFreeAgent(LeagueState state, int seed) =>
    ContractMarketService().resolveHour(state, hour: 1, saveSeed: seed);

LeagueState _resolveExtension(LeagueState state, int seed) =>
    ContractMarketService().resolveHour(state, hour: 1, saveSeed: seed);

List<ContractNegotiation> _aiStaffNegotiations(LeagueState state) => state
    .negotiations
    .where(
      (item) =>
          item.subjectKind == NegotiationSubjectKind.staff && item.isAiOffer,
    )
    .toList(growable: false);

ContractNegotiation? _staffNegotiationFor(
  LeagueState state,
  String memberId, {
  required String reason,
}) {
  final matches = state.negotiations.where(
    (item) =>
        item.subjectKind == NegotiationSubjectKind.staff &&
        item.subjectId == memberId &&
        item.isAiOffer,
  );
  if (matches.length > 1) {
    fail('$reason: persisted ${matches.length} AI staff negotiations');
  }
  return matches.isEmpty ? null : matches.single;
}

void _assertPersistedPlan(
  LeagueState state,
  AiStaffOfferPlan plan,
  String memberId, {
  required String reason,
}) {
  final negotiation = _staffNegotiationFor(state, memberId, reason: reason);
  expect(negotiation, isNotNull, reason: reason);
  if (negotiation == null) return;
  expect(negotiation.lastOffer.salary, plan.offer.salary, reason: reason);
  expect(negotiation.lastOffer.years, plan.offer.years, reason: reason);
  expect(
    negotiation.offerScore,
    closeTo(plan.offerScore, 1e-9),
    reason: '$reason persisted score is not the direct raw score',
  );
  expect(
    negotiation.status,
    NegotiationStatus.completed,
    reason: '$reason AI plan did not finalize through ContractMarketService',
  );
}

void _assertPersistedEqual(LeagueState left, LeagueState right, String reason) {
  final leftStaff = left.negotiations.where(
    (item) =>
        item.subjectKind == NegotiationSubjectKind.staff && item.isAiOffer,
  );
  final rightStaff = right.negotiations.where(
    (item) =>
        item.subjectKind == NegotiationSubjectKind.staff && item.isAiOffer,
  );
  expect(rightStaff.length, leftStaff.length, reason: reason);
  for (var index = 0; index < leftStaff.length; index++) {
    final a = leftStaff.elementAt(index);
    final b = rightStaff.elementAt(index);
    expect(b.subjectId, a.subjectId, reason: reason);
    expect(b.lastOffer.salary, a.lastOffer.salary, reason: reason);
    expect(b.lastOffer.years, a.lastOffer.years, reason: reason);
    expect(b.offerScore, closeTo(a.offerScore, 1e-9), reason: reason);
  }
}

void _expectPlanScore(
  AiStaffOfferPlan plan, {
  required TeamStatus status,
  required StaffMember? assistingCfo,
  required StaffRole subjectRole,
  required String reason,
}) {
  final expectedRaw = expectedStaffRawOverall(
    plan.member.attributes,
    subjectRole,
  );
  expect(
    plan.member.overall,
    expectedRaw,
    reason: '$reason raw rating changed',
  );
  final expectedWant = _oracleStaffWant(expectedRaw, status);
  final expectedSalary = _oracleExpectedSalary(expectedWant);
  final expectedLength = _oracleExpectedLength(expectedWant, plan.member.age);
  final cfoRaw = assistingCfo == null
      ? null
      : expectedStaffRawOverall(assistingCfo.attributes, StaffRole.cfo);
  final expected = NegotiationRules.score(
    salary: plan.offer.salary,
    expectedSalary: expectedSalary,
    years: plan.offer.years,
    expectedLength: expectedLength,
    offeringTeamStatus: status,
    cfoNegotiation: subjectRole == StaffRole.cfo ? null : cfoRaw,
    balance: BalanceConfig.defaults.contracts,
  );
  expect(
    plan.offer.salary,
    inInclusiveRange(
      BalanceConfig.defaults.staff.minSalary,
      BalanceConfig.defaults.staff.maxSalary,
    ),
    reason: '$reason AI produced an illegal staff salary',
  );
  expect(plan.offer.years, inInclusiveRange(1, 4), reason: reason);
  expect(
    plan.offerScore,
    closeTo(expected.score, 1e-9),
    reason: '$reason AI offer score is not a function of raw/status/CFO inputs',
  );
}

void _expectDisplayedProjection(StaffMember member, String reason) {
  final raw = expectedStaffRawOverall(member.attributes, member.role);
  final rating = StaffPresentation.viewForMember(member).rating;
  expect(rating, isNotNull, reason: '$reason missing rating projection');
  expect(
    rating?.rawOverall,
    raw,
    reason: '$reason presentation replaced RawOverall',
  );
  expect(
    rating?.displayedRating,
    expectedStaffDisplayedRating(raw),
    reason: '$reason presentation rounding changed AI input',
  );
}

void _expectPlansEqual(
  AiStaffOfferPlan? left,
  AiStaffOfferPlan? right,
  String reason,
) {
  expect(right == null, left == null, reason: reason);
  if (left == null || right == null) return;
  expect(right.member.id, left.member.id, reason: reason);
  expect(right.role, left.role, reason: reason);
  expect(right.isExtension, left.isExtension, reason: reason);
  expect(right.offer.salary, left.offer.salary, reason: reason);
  expect(right.offer.years, left.offer.years, reason: reason);
  expect(right.offerScore, closeTo(left.offerScore, 1e-9), reason: reason);
}

StaffMember _toggleIrrelevant(StaffMember member) {
  final name = irrelevantStaffAttributeNames(member.role).first;
  final current = staffAttributeByName(member.attributes, name);
  return member.copyWith(
    attributes: withIrrelevantStaffAttribute(
      member.attributes,
      member.role,
      name: name,
      value: current == 5.0 ? 0.0 : 5.0,
    ),
  );
}

List<StaffMember> _canonicalCandidates(
  Iterable<StaffMember> candidates,
  StaffRole role,
) {
  final sorted = candidates.where((member) => member.role == role).toList();
  sorted.sort((a, b) {
    final raw = expectedStaffRawOverall(
      b.attributes,
      role,
    ).compareTo(expectedStaffRawOverall(a.attributes, role));
    return raw == 0 ? a.id.compareTo(b.id) : raw;
  });
  return sorted;
}

double _oracleStaffWant(double raw, TeamStatus status) =>
    (raw * 20.0 + NegotiationRules.teamStatusBonus(status))
        .clamp(0.0, 100.0)
        .toDouble();

int _oracleExpectedSalary(double want) {
  final balance = BalanceConfig.defaults;
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

double _spreadFor(StaffRole role, double raw) {
  final relevantCount = relevantStaffAttributeNames(role).length;
  if (relevantCount == 1 || raw < 0.25 || raw > 4.75) return 0.0;
  return 0.25;
}

int _seedFor(StaffRole role, TeamStatus status, int caseIndex) =>
    _propertySeed + role.index * 1009 + status.index * 101 + caseIndex * 37;

String _teamId(
  StaffRole role,
  TeamStatus status,
  int caseIndex,
  String phase,
) => 'p10_${phase}_${role.name}_${status.name}_$caseIndex';

String _reason(_AiScenario scenario, {required String path}) =>
    '$_propertyTag path=$path role=${scenario.role.name} '
    'status=${scenario.status.name} seed=${scenario.seed} '
    'case=${scenario.caseIndex} raw=${scenario.raw} age=${scenario.age} '
    'displayed=${expectedStaffDisplayedRating(scenario.raw)}';
