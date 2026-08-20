import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/data/staff_data_compatibility.dart';

import 'helpers/staff_role_ratings_test_helpers.dart';

const _propertyTag =
    'Feature: staff-role-ratings, Property 12: EmptySlot zachowuje '
    'no-staff rules';
const _caseCount = 120;
const _baseSeed = 7_120_041;
const _saveId = 'staff-empty-slot-property-save';

void main() {
  test(_propertyTag, () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'nf_staff_empty_slot_property_',
    );
    addTearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final repository = SaveRepository(overrideDirectory: tempDirectory);
    final saveFile = File('${tempDirectory.path}/$_saveId.json');
    final observedRoles = <StaffRole>{};
    final observedSlotOrders = <String>{};
    final observedRoleSlotPairs = <String>{};

    // **Validates: Requirements 3.9–3.10, 4.13, 6.8, 9.1–9.2**
    for (var caseIndex = 0; caseIndex < _caseCount; caseIndex++) {
      final seed = _baseSeed + caseIndex * 7_919;
      final scenario = _buildScenario(seed, caseIndex);
      final reason = scenario.reason;
      observedRoles.add(scenario.emptyRole);
      observedSlotOrders.add(scenario.slotOrder.join('|'));
      observedRoleSlotPairs.add(
        '${scenario.emptyRole.name}:${scenario.mismatchSlot.name}',
      );

      final rawSave = _rawSave(scenario, seed: seed);
      final originalRawSave = _cloneMap(rawSave);
      final sanitized = StaffDataCompatibility.sanitizeGameSaveJson(rawSave);

      expect(
        rawSave,
        equals(originalRawSave),
        reason: '$reason\nsanitation must not mutate raw input',
      );
      _expectSanitizedBoundary(sanitized, scenario, reason);

      final replayScenario = _buildScenario(seed, caseIndex);
      final replayRawSave = _rawSave(replayScenario, seed: seed);
      expect(
        replayRawSave,
        equals(rawSave),
        reason: '$reason\nseeded fixture did not replay identically',
      );
      final replaySanitized = StaffDataCompatibility.sanitizeGameSaveJson(
        replayRawSave,
      );
      expect(
        replaySanitized.sanitizedJson,
        equals(sanitized.sanitizedJson),
        reason: '$reason\nsanitized JSON changed on replay',
      );
      expect(
        replaySanitized.diagnostics,
        equals(sanitized.diagnostics),
        reason: '$reason\ndiagnostics changed on replay',
      );

      final idempotent = StaffDataCompatibility.sanitizeGameSaveJson(
        sanitized.sanitizedJson,
      );
      expect(
        idempotent.sanitizedJson,
        equals(sanitized.sanitizedJson),
        reason: '$reason\nsanitization is not idempotent',
      );
      expect(
        idempotent.diagnostics,
        isEmpty,
        reason: '$reason\nsanitary records survived the first pass',
      );

      // Write the untrusted tree, not the pre-sanitized result: this proves
      // SaveRepository.load applies the same boundary before generated decode.
      await saveFile.writeAsString(jsonEncode(rawSave));
      final loaded = await repository.load(_saveId);
      expect(
        repository.lastStaffDiagnostics,
        equals(sanitized.diagnostics),
        reason: '$reason\nload did not expose sanitizer diagnostics',
      );
      _expectLoadedEmptySlots(loaded.leagueState, scenario, reason);
      _expectMarketAndAiBoundaries(loaded.leagueState, scenario, seed, reason);

      final loadedReplay = await repository.load(_saveId);
      expect(
        loadedReplay,
        equals(loaded),
        reason: '$reason\nloading the same seed/save was not replayable',
      );
      expect(
        repository.lastStaffDiagnostics,
        equals(sanitized.diagnostics),
        reason: '$reason\nreplayed load changed diagnostics',
      );
    }

    expect(
      observedRoles,
      containsAll(StaffRole.values),
      reason: 'the property did not exercise every recognized staff role',
    );
    expect(
      observedSlotOrders.length,
      greaterThan(1),
      reason: 'the property did not exercise role-slot permutations',
    );
    expect(
      observedRoleSlotPairs.length,
      greaterThan(StaffRole.values.length),
      reason: 'the property did not vary mismatch/EmptySlot placement',
    );
  });
}

final class _EmptySlotScenario {
  const _EmptySlotScenario({
    required this.seed,
    required this.caseIndex,
    required this.emptyRole,
    required this.occupiedRole,
    required this.mismatchSlot,
    required this.occupiedId,
    required this.mismatchId,
    required this.targetCandidateId,
    required this.occupiedCandidateId,
    required this.unknownCandidateId,
    required this.slotOrder,
    required this.teamStaff,
    required this.freeAgents,
  });

  final int seed;
  final int caseIndex;
  final StaffRole emptyRole;
  final StaffRole occupiedRole;
  final StaffRole mismatchSlot;
  final String occupiedId;
  final String mismatchId;
  final String targetCandidateId;
  final String occupiedCandidateId;
  final String unknownCandidateId;
  final List<StaffRole> slotOrder;
  final Map<String, dynamic> teamStaff;
  final List<Map<String, dynamic>> freeAgents;

  int get occupiedSalary => staffFixtureSalary;

  String get reason =>
      '$_propertyTag seed=$seed case=$caseIndex '
      'empty=${emptyRole.name} occupied=${occupiedRole.name} '
      'mismatchSlot=${mismatchSlot.name} '
      'slotOrder=${slotOrder.map((role) => role.name).join(',')} '
      'targetCandidate=$targetCandidateId';
}

_EmptySlotScenario _buildScenario(int seed, int caseIndex) {
  final random = Random(seed);
  final emptyRole = StaffRole.values[caseIndex % StaffRole.values.length];
  final slotOrder = List<StaffRole>.of(StaffRole.values)..shuffle(random);
  final occupiedRole = slotOrder.firstWhere((role) => role != emptyRole);
  final mismatchSlot = slotOrder.firstWhere(
    (role) => role != emptyRole && role != occupiedRole,
  );

  final occupiedId = 'empty-property-occupied-${occupiedRole.name}-$seed';
  final mismatchId = 'empty-property-mismatch-${mismatchSlot.name}-$seed';
  final targetCandidateId = 'empty-property-candidate-${emptyRole.name}-$seed';
  final occupiedCandidateId =
      'empty-property-occupied-candidate-${occupiedRole.name}-$seed';
  final unknownCandidateId = 'empty-property-unknown-$seed';

  final slots = <StaffRole, Map<String, dynamic>?>{
    for (final role in StaffRole.values) role: null,
  };
  slots[occupiedRole] = staffMemberJson(
    role: occupiedRole,
    id: occupiedId,
    attributes: staffAttributesWithRawOverall(
      occupiedRole,
      3.0,
      irrelevantValue: 5.0,
    ),
    contract: staffFixtureContract(),
  );
  // The mismatched record declares the true EmptySlot role but is stored in a
  // different slot. Sanitization must discard it, never move it to emptyRole.
  slots[mismatchSlot] = staffMemberJson(
    role: emptyRole,
    id: mismatchId,
    attributes: staffAttributesWithRawOverall(
      emptyRole,
      4.5,
      irrelevantValue: 5.0,
    ),
    contract: staffFixtureContract(salary: staffFixtureSalary + 250000),
  );

  final freeAgents = <Map<String, dynamic>>[
    staffMemberJson(
      role: emptyRole,
      id: targetCandidateId,
      attributes: staffAttributesWithRawOverall(
        emptyRole,
        3.0,
        irrelevantValue: 5.0,
      ),
    ),
    staffMemberJson(
      role: occupiedRole,
      id: occupiedCandidateId,
      attributes: staffAttributesWithRawOverall(
        occupiedRole,
        4.0,
        irrelevantValue: 5.0,
      ),
    ),
    staffMemberJson(
      role: emptyRole,
      rawRole: unknownStaffRoleValue,
      id: unknownCandidateId,
      contract: staffFixtureContract(salary: staffFixtureSalary + 500000),
    ),
  ]..shuffle(random);

  return _EmptySlotScenario(
    seed: seed,
    caseIndex: caseIndex,
    emptyRole: emptyRole,
    occupiedRole: occupiedRole,
    mismatchSlot: mismatchSlot,
    occupiedId: occupiedId,
    mismatchId: mismatchId,
    targetCandidateId: targetCandidateId,
    occupiedCandidateId: occupiedCandidateId,
    unknownCandidateId: unknownCandidateId,
    slotOrder: List<StaffRole>.unmodifiable(slotOrder),
    teamStaff: <String, dynamic>{
      for (final role in slotOrder) role.name: slots[role],
    },
    freeAgents: List<Map<String, dynamic>>.unmodifiable(freeAgents),
  );
}

Map<String, dynamic> _rawSave(
  _EmptySlotScenario scenario, {
  required int seed,
}) {
  final teamId = 'empty-property-team-$seed';
  final timestamp = DateTime.utc(2026, 1, 1).toIso8601String();
  return <String, dynamic>{
    'schemaVersion': SaveSchema.currentVersion,
    'meta': <String, dynamic>{
      'id': _saveId,
      'name': 'EmptySlot property $seed',
      'createdAt': timestamp,
      'updatedAt': timestamp,
      'seasonYear': staffFixtureSeasonYear,
      'phase': SeasonPhase.regular.name,
      'playerTeamName': 'EmptySlot property team',
      'schemaVersion': SaveSchema.currentVersion,
    },
    'saveSeed': seed,
    'leagueState': <String, dynamic>{
      'teams': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': teamId,
          'name': 'EmptySlot property team',
          'city': 'Fixture City',
          'conference': Conference.europe.name,
          'roster': <dynamic>[],
          'finance': <String, dynamic>{},
          'staff': scenario.teamStaff,
        },
      ],
      'currentSeason': <String, dynamic>{
        'year': staffFixtureSeasonYear,
        'phase': SeasonPhase.offseason.name,
      },
      'playerTeamId': teamId,
      'currentWeek': staffFixtureFreeAgencyWeek(),
      'currentDay': 1,
      'currentHour': 1,
      'staffFreeAgents': scenario.freeAgents,
    },
  };
}

void _expectSanitizedBoundary(
  StaffCompatibilityResult<Map<String, dynamic>> result,
  _EmptySlotScenario scenario,
  String reason,
) {
  final league = result.sanitizedJson['leagueState'] as Map<String, dynamic>;
  final team =
      (league['teams'] as List<dynamic>).single as Map<String, dynamic>;
  final staff = team['staff'] as Map<String, dynamic>;
  final freeAgents = league['staffFreeAgents'] as List<dynamic>;

  expect(
    staff[scenario.emptyRole.name],
    isNull,
    reason: '$reason\ntrue EmptySlot was populated during sanitization',
  );
  expect(
    staff[scenario.mismatchSlot.name],
    isNull,
    reason: '$reason\nrole-slot mismatch was retained or reassigned',
  );
  expect(
    (staff[scenario.occupiedRole.name] as Map<String, dynamic>)['id'],
    scenario.occupiedId,
    reason: '$reason\nvalid occupied record was not preserved',
  );
  expect(
    freeAgents
        .whereType<Map<String, dynamic>>()
        .map((record) => record['id'])
        .toSet(),
    {scenario.targetCandidateId, scenario.occupiedCandidateId},
    reason: '$reason\nUnknownRole was not excluded from free agents',
  );

  expect(
    result.diagnostics.any(
      (diagnostic) =>
          diagnostic.path.endsWith('.${scenario.emptyRole.name}') &&
          diagnostic.reason != StaffDataDiagnosticReason.duplicateStaffRecord,
    ),
    isFalse,
    reason: '$reason\ntrue EmptySlot incorrectly produced a diagnostic',
  );
  expect(
    result.diagnostics.any(
      (diagnostic) =>
          diagnostic.memberId == scenario.mismatchId &&
          diagnostic.reason == StaffDataDiagnosticReason.roleSlotMismatch,
    ),
    isTrue,
    reason: '$reason\nrole-slot mismatch was not diagnosed',
  );
  expect(
    result.diagnostics.any(
      (diagnostic) => diagnostic.memberId == scenario.unknownCandidateId,
    ),
    isTrue,
    reason: '$reason\nUnknownRole free agent was not diagnosed',
  );
}

void _expectLoadedEmptySlots(
  LeagueState league,
  _EmptySlotScenario scenario,
  String reason,
) {
  final team = league.playerTeam!;
  final emptyRoles = StaffRole.values
      .where((role) => team.staff.member(role) == null)
      .toList(growable: false);

  expect(
    team.staff.member(scenario.emptyRole),
    isNull,
    reason: '$reason\ntrue EmptySlot was populated after load',
  );
  expect(
    team.staff.member(scenario.mismatchSlot),
    isNull,
    reason: '$reason\nrole-slot mismatch became an occupied slot after load',
  );
  expect(
    team.staff.canonicalMember(scenario.emptyRole),
    isNull,
    reason: '$reason\ncanonicalMember fabricated an empty-role member',
  );
  expect(
    team.staff.members.map((member) => member.id).toList(),
    [scenario.occupiedId],
    reason: '$reason\nEmptySlot/mismatch leaked into active members',
  );
  expect(
    team.staff.totalSalary,
    scenario.occupiedSalary,
    reason: '$reason\nEmptySlot/mismatch contract entered payroll',
  );

  for (final role in emptyRoles) {
    final view = StaffPresentation.viewForSlot(team.staff.member(role), role);
    expect(
      view.state,
      StaffSlotState.empty,
      reason: '$reason\nrole=${role.name} is not presented as EmptySlot',
    );
    expect(
      view.member,
      isNull,
      reason: '$reason\nrole=${role.name} received a fabricated member',
    );
    expect(
      view.rating,
      isNull,
      reason: '$reason\nrole=${role.name} received a fabricated rating',
    );
    expect(
      view.relevantAttributes,
      isEmpty,
      reason: '$reason\nrole=${role.name} exposed attributes without a member',
    );
    expect(
      view.stars,
      isEmpty,
      reason: '$reason\nrole=${role.name} exposed stars without a member',
    );
    expect(
      view.rawOverall,
      isNull,
      reason: '$reason\nrole=${role.name} exposed RawOverall without a member',
    );
    expect(
      view.displayedRating,
      isNull,
      reason:
          '$reason\nrole=${role.name} exposed DisplayedRating without a member',
    );
  }

  final occupiedView = StaffPresentation.viewForSlot(
    team.staff.member(scenario.occupiedRole),
    scenario.occupiedRole,
  );
  expect(
    occupiedView.state,
    StaffSlotState.occupied,
    reason: '$reason\nvalid occupied role lost its slot state',
  );

  final candidates = league.canonicalStaffFreeAgents;
  expect(
    candidates.where((member) => member.id == scenario.unknownCandidateId),
    isEmpty,
    reason: '$reason\nUnknownRole reached typed free-agent projections',
  );
  expect(
    candidates.every((member) => member.contract == null),
    isTrue,
    reason: '$reason\nfree-agent projection fabricated a contract',
  );

  for (final role in StaffRole.values) {
    final sorted = StaffPresentation.sortStaffCandidates(candidates, role);
    expect(
      sorted.every((member) => member.role == role),
      isTrue,
      reason: '$reason\nrole=${role.name} sorter assigned a fallback role',
    );
  }

  final targetSorted = StaffPresentation.sortStaffCandidates(
    candidates,
    scenario.emptyRole,
  );
  expect(
    targetSorted.map((member) => member.id).toList(),
    [scenario.targetCandidateId],
    reason: '$reason\nrecognized candidate did not target the true empty role',
  );
}

void _expectMarketAndAiBoundaries(
  LeagueState league,
  _EmptySlotScenario scenario,
  int seed,
  String reason,
) {
  final team = league.playerTeam!;
  final candidates = league.canonicalStaffFreeAgents;
  final target = candidates.firstWhere(
    (member) => member.id == scenario.targetCandidateId,
  );
  final occupiedCandidate = candidates.firstWhere(
    (member) => member.id == scenario.occupiedCandidateId,
  );
  final offer = staffFixtureOffer();
  final market = ContractMarketService();

  expect(
    market.phaseAt(league),
    isNotNull,
    reason: '$reason\nfixture did not enter a staff market window',
  );

  final occupiedResult = market.submitStaffOffer(
    league: league,
    candidate: occupiedCandidate,
    offer: offer,
    saveSeed: seed,
  );
  expect(
    occupiedResult,
    isNull,
    reason: '$reason\nmarket offered a candidate for an occupied role',
  );

  final forged = target.copyWith(id: 'empty-property-forged-$seed');
  final forgedResult = market.submitStaffOffer(
    league: league,
    candidate: forged,
    offer: offer,
    saveSeed: seed,
  );
  expect(
    forgedResult,
    isNull,
    reason: '$reason\nmarket created an offer for a member absent from state',
  );

  final targetResult = market.submitStaffOffer(
    league: league,
    candidate: target,
    offer: offer,
    saveSeed: seed,
  );
  expect(
    targetResult,
    isNotNull,
    reason: '$reason\nrecognized candidate could not target true EmptySlot',
  );
  expect(
    targetResult!.league.negotiations
        .where((item) => item.subjectId == target.id)
        .length,
    1,
    reason: '$reason\naccepted target offer was not tied to its member',
  );
  expect(
    targetResult.league.playerTeam!.staff.member(scenario.emptyRole),
    isNull,
    reason: '$reason\nsubmitting an offer signed into EmptySlot prematurely',
  );

  final noMemberLeague = league.copyWith(
    staffFreeAgents: const <StaffMember>[],
  );
  final noMemberOffer = market.submitStaffOffer(
    league: noMemberLeague,
    candidate: target,
    offer: offer,
    saveSeed: seed,
  );
  expect(
    noMemberOffer,
    isNull,
    reason: '$reason\nmarket created an offer without a state member',
  );

  final noMemberTeam = noMemberLeague.playerTeam!;
  final policy = AiContractMarketService();
  final plan = policy.staffFreeAgentPlan(
    league: league,
    team: team,
    saveSeed: seed,
  );
  expect(
    plan,
    isNotNull,
    reason: '$reason\nAI did not see the recognized candidate for EmptySlot',
  );
  expect(
    plan!.role,
    scenario.emptyRole,
    reason: '$reason\nAI assigned the candidate to a different role',
  );
  expect(
    plan.member.id,
    scenario.targetCandidateId,
    reason: '$reason\nAI selected a fabricated/fallback candidate',
  );

  expect(
    policy.staffFreeAgentPlan(
      league: noMemberLeague,
      team: noMemberTeam,
      saveSeed: seed,
    ),
    isNull,
    reason: '$reason\nAI fabricated a plan without a free-agent member',
  );
  expect(
    policy.staffExtensionPlan(
      league: noMemberLeague,
      team: noMemberTeam,
      saveSeed: seed,
    ),
    isNull,
    reason: '$reason\nAI fabricated an extension without a member',
  );

  final noMemberNegotiation = ContractNegotiation(
    id: 'empty-property-no-member-negotiation-$seed',
    subjectId: target.id,
    subjectKind: NegotiationSubjectKind.staff,
    teamId: noMemberTeam.id,
    phase: NegotiationPhase.freeAgencyPhaseI,
    lastOffer: NegotiationOffer(salary: offer.salary, years: offer.years),
    status: NegotiationStatus.pendingFinalization,
    requiresFinalization: true,
    seasonYear: noMemberLeague.currentSeason.year,
    week: noMemberLeague.currentWeek,
    day: noMemberLeague.currentDay,
    hour: noMemberLeague.currentHour ?? 1,
    expirySeasonYear: noMemberLeague.currentSeason.year,
    expiryWeek: noMemberLeague.currentWeek,
    expiryDay: noMemberLeague.currentDay,
    expiryHour: noMemberLeague.currentHour ?? 1,
  );
  final noMemberWithNegotiation = noMemberLeague.copyWith(
    negotiations: [noMemberNegotiation],
  );
  final finalized = market.finalizeNegotiation(
    noMemberWithNegotiation,
    noMemberNegotiation.id,
    saveSeed: seed,
  );
  expect(
    finalized,
    isNull,
    reason: '$reason\nsigning fabricated a member absent from free-agent state',
  );
  expect(
    noMemberWithNegotiation.playerTeam!.staff.member(scenario.emptyRole),
    isNull,
    reason: '$reason\nfailed signing guard changed the EmptySlot',
  );
  expect(
    noMemberWithNegotiation.playerTeam!.staff.totalSalary,
    scenario.occupiedSalary,
    reason: '$reason\nfailed signing guard changed payroll',
  );
}

Map<String, dynamic> _cloneMap(Map<String, dynamic> source) =>
    jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
