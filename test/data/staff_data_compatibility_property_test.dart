@Tags(['property'])
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/data/staff_data_compatibility.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

/// Feature: staff-role-ratings, Property 11: normalizacja zachowuje valid
/// records i odrzuca UnknownRole.
///
/// This is deliberately a deterministic property-like test rather than a new
/// PBT dependency. The oracle below is written in terms of the persisted save
/// contract: recognized staff records are retained when their required fields
/// are valid, partial attribute maps and unknown attribute names are opaque
/// payload, and invalid role/record/slot/identity combinations are excluded.
void main() {
  test(
    'Property 11: staff normalization preserves valid records and excludes invalid ones',
    () {
      const baseSeed = 913_004;
      const caseCount = 128;
      final teamPermutations = <String>{};
      final freeAgentPermutations = <String>{};

      for (var caseIndex = 0; caseIndex < caseCount; caseIndex++) {
        final seed = baseSeed + caseIndex * 7919;
        final generated = _buildCase(seed);
        final expected = _oracle(generated);
        final original = _cloneMap(generated.save);

        final result = StaffDataCompatibility.sanitizeGameSaveJson(
          generated.save,
        );

        expect(
          generated.save,
          equals(original),
          reason: 'sanitization mutated its input; seed=$seed',
        );
        expect(
          result.sanitizedJson,
          equals(expected.sanitizedSave),
          reason: 'save contract mismatch; seed=$seed',
        );
        expect(
          _diagnosticProjection(result.diagnostics),
          equals(expected.diagnostics),
          reason: 'diagnostic oracle mismatch; seed=$seed',
        );

        _expectRoleCoverageAndNoFallback(
          result.sanitizedJson,
          result.diagnostics,
          seed: seed,
        );
        _expectEmptySlotsRemainEmpty(generated, result.sanitizedJson, seed);

        final replay = _buildCase(seed);
        expect(
          replay.save,
          equals(generated.save),
          reason: 'generator is not replayable for seed=$seed',
        );
        final replayResult = StaffDataCompatibility.sanitizeGameSaveJson(
          replay.save,
        );
        expect(
          replayResult.sanitizedJson,
          equals(result.sanitizedJson),
          reason: 'same seed produced a different sanitized save; seed=$seed',
        );
        expect(
          replayResult.diagnostics,
          equals(result.diagnostics),
          reason: 'diagnostics are not stable on replay; seed=$seed',
        );

        final idempotent = StaffDataCompatibility.sanitizeGameSaveJson(
          result.sanitizedJson,
        );
        expect(
          idempotent.sanitizedJson,
          equals(result.sanitizedJson),
          reason: 'sanitization is not idempotent; seed=$seed',
        );
        expect(
          idempotent.diagnostics,
          isEmpty,
          reason:
              'a sanitized save still contains a rejected record; seed=$seed',
        );

        final league = generated.save['leagueState'] as Map<String, dynamic>;
        final teams = (league['teams'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final freeAgents = league['staffFreeAgents'] as List<dynamic>;
        teamPermutations.add(teams.map((team) => team['id']).join('|'));
        freeAgentPermutations.add(
          freeAgents
              .map(
                (record) => record is Map ? record['id'] : record.runtimeType,
              )
              .join('|'),
        );
      }

      expect(
        teamPermutations.length,
        greaterThan(1),
        reason: 'property cases did not exercise team-list permutations',
      );
      expect(
        freeAgentPermutations.length,
        greaterThan(1),
        reason: 'property cases did not exercise free-agent permutations',
      );
    },
  );
}

enum _RecordKind {
  valid,
  partialAttributes,
  unknownAttribute,
  legacyHeadCoachDevelopment,
  unknownRole,
  missingRequiredField,
  malformedKnownAttribute,
  malformedContract,
  malformedObject,
  roleSlotMismatch,
}

extension on _RecordKind {
  bool get isAccepted => switch (this) {
    _RecordKind.valid ||
    _RecordKind.partialAttributes ||
    _RecordKind.unknownAttribute ||
    _RecordKind.legacyHeadCoachDevelopment => true,
    _ => false,
  };
}

/// One source occurrence. The same ID may intentionally occur more than once;
/// duplicate resolution is part of the oracle and follows save traversal order.
final class _Occurrence {
  const _Occurrence({
    required this.record,
    required this.kind,
    this.declaredRole,
  });

  final Object? record;
  final _RecordKind kind;
  final StaffRole? declaredRole;
}

final class _TeamCase {
  _TeamCase(this.id)
    : slots = {for (final role in StaffRole.values) role: null};

  final String id;
  final Map<StaffRole, _Occurrence?> slots;
}

final class _GeneratedCase {
  const _GeneratedCase({
    required this.seed,
    required this.save,
    required this.teamsById,
    required this.freeAgentOccurrences,
  });

  final int seed;
  final Map<String, dynamic> save;
  final Map<String, _TeamCase> teamsById;
  final List<_Occurrence> freeAgentOccurrences;
}

final class _OracleResult {
  const _OracleResult({required this.sanitizedSave, required this.diagnostics});

  final Map<String, dynamic> sanitizedSave;
  final List<Map<String, dynamic>> diagnostics;
}

final class _DiagnosticExpectation {
  const _DiagnosticExpectation({
    required this.path,
    required this.reason,
    this.memberId,
    this.rawRole,
  });

  final String path;
  final String reason;
  final String? memberId;
  final Object? rawRole;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'path': path,
    'reason': reason,
    'memberId': memberId,
    'rawRole': rawRole,
  };
}

_GeneratedCase _buildCase(int seed) {
  final random = Random(seed);
  final roles = List<StaffRole>.of(StaffRole.values);
  final teams = [
    _TeamCase('team-property-$seed-primary'),
    _TeamCase('team-property-$seed-invalid'),
    _TeamCase('team-property-$seed-duplicate'),
  ];

  // Every recognized role has a canonical team record. The variants exercise
  // partial maps, unknown attributes and the inert legacy head-coach field.
  for (final role in roles) {
    final kind = role == StaffRole.headCoach
        ? _RecordKind.legacyHeadCoachDevelopment
        : switch (role.index % 3) {
            0 => _RecordKind.valid,
            1 => _RecordKind.partialAttributes,
            _ => _RecordKind.unknownAttribute,
          };
    final id = 'team-valid-${role.name}-$seed';
    teams[0].slots[role] = _occurrence(random, role: role, id: id, kind: kind);
  }

  // Each invalid team slot has a different boundary failure. In particular,
  // malformed values are represented both as bad fields and as non-objects.
  final invalidKinds = <_RecordKind>[
    _RecordKind.unknownRole,
    _RecordKind.roleSlotMismatch,
    _RecordKind.missingRequiredField,
    _RecordKind.malformedKnownAttribute,
    _RecordKind.malformedContract,
    _RecordKind.malformedObject,
  ];
  for (var index = 0; index < roles.length; index++) {
    final slot = roles[index];
    final kind = invalidKinds[index];
    final declaredRole = kind == _RecordKind.roleSlotMismatch
        ? roles[(slot.index + 1) % roles.length]
        : slot;
    teams[1].slots[slot] = _occurrence(
      random,
      role: declaredRole,
      id: 'team-invalid-${slot.name}-$seed',
      kind: kind,
    );
  }

  // A valid duplicate has a different payload so the first traversal winner
  // is observable when the team list is permuted.
  final duplicateRole = roles[random.nextInt(roles.length)];
  final source = teams[0].slots[duplicateRole]!;
  final sourceMap = source.record as Map<String, dynamic>;
  final duplicate = _cloneMap(sourceMap);
  duplicate['name'] = '${duplicate['name']} duplicate';
  teams[2].slots[duplicateRole] = _Occurrence(
    record: duplicate,
    kind: _RecordKind.valid,
    declaredRole: duplicateRole,
  );

  final freeAgentEntries = <_Occurrence>[
    for (final role in roles)
      _occurrence(
        random,
        role: role,
        id: 'free-valid-${role.name}-$seed',
        kind: switch (role.index % 3) {
          0 => _RecordKind.valid,
          1 => _RecordKind.partialAttributes,
          _ => _RecordKind.unknownAttribute,
        },
      ),
  ];

  // A duplicate pair in free agents makes the retained payload depend on the
  // generated permutation while keeping both records contract-valid.
  final freeDuplicateRole = roles[random.nextInt(roles.length)];
  final freeDuplicateId = 'free-duplicate-${freeDuplicateRole.name}-$seed';
  final freeOriginal = _occurrence(
    random,
    role: freeDuplicateRole,
    id: freeDuplicateId,
    kind: _RecordKind.valid,
  );
  final freeDuplicateMap = _cloneMap(
    freeOriginal.record as Map<String, dynamic>,
  );
  freeDuplicateMap['name'] = '${freeDuplicateMap['name']} duplicate';
  freeAgentEntries
    ..add(freeOriginal)
    ..add(
      _Occurrence(
        record: freeDuplicateMap,
        kind: _RecordKind.valid,
        declaredRole: freeDuplicateRole,
      ),
    );

  // A duplicate across active team staff and free agents must not create a
  // second active record or a fallback assignment in the free-agent list.
  freeAgentEntries.add(
    _Occurrence(
      record: _cloneMap(
        (teams[0].slots[duplicateRole]!.record as Map<String, dynamic>),
      ),
      kind: _RecordKind.valid,
      declaredRole: duplicateRole,
    ),
  );

  freeAgentEntries
    ..add(
      _occurrence(
        random,
        role: roles[random.nextInt(roles.length)],
        id: 'free-unknown-$seed',
        kind: _RecordKind.unknownRole,
      ),
    )
    ..add(
      _occurrence(
        random,
        role: roles[random.nextInt(roles.length)],
        id: 'free-missing-role-$seed',
        kind: _RecordKind.unknownRole,
        omitRole: true,
      ),
    )
    ..add(
      _occurrence(
        random,
        role: roles[random.nextInt(roles.length)],
        id: 'free-malformed-field-$seed',
        kind: _RecordKind.missingRequiredField,
      ),
    )
    ..add(
      _occurrence(
        random,
        role: roles[random.nextInt(roles.length)],
        id: 'free-malformed-object-$seed',
        kind: _RecordKind.malformedObject,
      ),
    );

  final teamOrder = List<_TeamCase>.of(teams)..shuffle(random);
  final freeAgentOrder = List<_Occurrence>.of(freeAgentEntries)
    ..shuffle(random);
  final serializedTeams = [
    for (final team in teamOrder)
      <String, dynamic>{'id': team.id, 'staff': _serializeSlots(team, random)},
  ];
  final serializedFreeAgents = [
    for (final occurrence in freeAgentOrder) occurrence.record,
  ];

  return _GeneratedCase(
    seed: seed,
    save: <String, dynamic>{
      'schemaVersion': 1,
      'meta': <String, dynamic>{
        'id': 'property-save-$seed',
        'schemaVersion': 1,
      },
      'leagueState': <String, dynamic>{
        'teams': serializedTeams,
        'staffFreeAgents': serializedFreeAgents,
        'unrelatedState': <String, dynamic>{
          'seed': seed,
          'sentinel': 'must remain untouched',
        },
      },
      'unrelatedRoot': <String, dynamic>{'seed': seed},
    },
    teamsById: {for (final team in teams) team.id: team},
    freeAgentOccurrences: freeAgentOrder,
  );
}

_Occurrence _occurrence(
  Random random, {
  required StaffRole role,
  required String id,
  required _RecordKind kind,
  bool omitRole = false,
}) {
  if (kind == _RecordKind.malformedObject) {
    return const _Occurrence(
      record: <dynamic>['not', 'a', 'staff', 'object'],
      kind: _RecordKind.malformedObject,
    );
  }

  var attributes = randomStaffAttributes(random, includeOutOfRange: true);
  if (kind == _RecordKind.legacyHeadCoachDevelopment) {
    attributes = withStaffAttribute(attributes, 'development', 5.0);
  }
  final record = staffMemberJson(
    role: role,
    id: id,
    attributes: attributes,
    omitAttributes: kind == _RecordKind.partialAttributes
        ? {relevantStaffAttributeNames(role).first}
        : const {},
    extraAttributes: kind == _RecordKind.unknownAttribute
        ? const {unknownStaffAttributeName: 4.0}
        : const {},
    previousAttributes: random.nextBool()
        ? randomStaffAttributes(random, includeOutOfRange: true)
        : null,
    contract: random.nextBool() ? staffFixtureContract() : null,
    rawRole: kind == _RecordKind.unknownRole ? unknownStaffRoleValue : null,
  );

  if (kind == _RecordKind.missingRequiredField) {
    record.remove('name');
  }
  if (kind == _RecordKind.malformedKnownAttribute) {
    final attributeMap = Map<String, dynamic>.from(
      record['attributes'] as Map<String, dynamic>,
    );
    attributeMap['tactics'] = 'not-a-number';
    record['attributes'] = attributeMap;
  }
  if (kind == _RecordKind.malformedContract) {
    record['contract'] = <String, dynamic>{
      'salary': 'not-a-number',
      'yearsRemaining': 2,
    };
  }
  if (omitRole) record.remove('role');

  return _Occurrence(record: record, kind: kind, declaredRole: role);
}

Map<String, dynamic> _serializeSlots(_TeamCase team, Random random) {
  final roleOrder = List<StaffRole>.of(StaffRole.values)..shuffle(random);
  return <String, dynamic>{
    for (final role in roleOrder) role.name: team.slots[role]?.record,
  };
}

_OracleResult _oracle(_GeneratedCase generated) {
  final sanitized = _cloneMap(generated.save);
  final league = sanitized['leagueState'] as Map<String, dynamic>;
  final sourceLeague = generated.save['leagueState'] as Map<String, dynamic>;
  final seenIds = <String>{};
  final diagnostics = <_DiagnosticExpectation>[];

  final sourceTeams = (sourceLeague['teams'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final sanitizedTeams = (league['teams'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  for (var teamIndex = 0; teamIndex < sourceTeams.length; teamIndex++) {
    final sourceTeam = sourceTeams[teamIndex];
    final teamId = sourceTeam['id'] as String;
    final teamCase = generated.teamsById[teamId]!;
    final sanitizedStaff =
        sanitizedTeams[teamIndex]['staff'] as Map<String, dynamic>;

    for (final slot in StaffRole.values) {
      final occurrence = teamCase.slots[slot];
      if (occurrence == null) continue;
      final path = 'leagueState.teams[$teamIndex].staff.${slot.name}';
      final diagnostic = _diagnosticFor(
        occurrence,
        expectedRole: slot,
        path: path,
      );
      if (diagnostic != null) {
        diagnostics.add(diagnostic);
        sanitizedStaff[slot.name] = null;
        continue;
      }

      final record = occurrence.record as Map<String, dynamic>;
      final memberId = record['id'] as String;
      if (!seenIds.add(memberId)) {
        diagnostics.add(
          _DiagnosticExpectation(
            path: path,
            reason: StaffDataDiagnosticReason.duplicateStaffRecord,
            memberId: memberId,
            rawRole: record['role'],
          ),
        );
        sanitizedStaff[slot.name] = null;
      }
    }
  }

  final sourceFreeAgents = sourceLeague['staffFreeAgents'] as List<dynamic>;
  final sanitizedFreeAgents = league['staffFreeAgents'] as List<dynamic>;
  final retainedFreeAgents = <dynamic>[];
  for (var index = 0; index < sourceFreeAgents.length; index++) {
    final occurrence = generated.freeAgentOccurrences[index];
    final path = 'leagueState.staffFreeAgents[$index]';
    final diagnostic = _diagnosticFor(occurrence, path: path);
    if (diagnostic != null) {
      diagnostics.add(diagnostic);
      continue;
    }

    final record = occurrence.record as Map<String, dynamic>;
    final memberId = record['id'] as String;
    if (!seenIds.add(memberId)) {
      diagnostics.add(
        _DiagnosticExpectation(
          path: path,
          reason: StaffDataDiagnosticReason.duplicateStaffRecord,
          memberId: memberId,
          rawRole: record['role'],
        ),
      );
      continue;
    }
    retainedFreeAgents.add(sanitizedFreeAgents[index]);
  }
  league['staffFreeAgents'] = retainedFreeAgents;

  return _OracleResult(
    sanitizedSave: sanitized,
    diagnostics: [for (final diagnostic in diagnostics) diagnostic.toJson()],
  );
}

_DiagnosticExpectation? _diagnosticFor(
  _Occurrence occurrence, {
  StaffRole? expectedRole,
  required String path,
}) {
  final record = occurrence.record;
  final memberId = record is Map<String, dynamic> && record['id'] is String
      ? record['id'] as String
      : null;
  final rawRole = record is Map<String, dynamic> ? record['role'] : null;

  // TeamStaff checks the JSON-object boundary before it can inspect a role;
  // a scalar/list record is malformed, not a role-slot mismatch.
  if (record is! Map<String, dynamic>) {
    return _DiagnosticExpectation(
      path: path,
      reason: StaffDataDiagnosticReason.malformedStaffRecord,
      memberId: memberId,
      rawRole: rawRole,
    );
  }

  if (occurrence.kind == _RecordKind.unknownRole) {
    return _DiagnosticExpectation(
      path: path,
      reason: StaffDataDiagnosticReason.unknownRole,
      memberId: memberId,
      rawRole: rawRole,
    );
  }
  if (expectedRole != null && occurrence.declaredRole != expectedRole) {
    return _DiagnosticExpectation(
      path: path,
      reason: StaffDataDiagnosticReason.roleSlotMismatch,
      memberId: memberId,
      rawRole: rawRole,
    );
  }
  if (!occurrence.kind.isAccepted) {
    return _DiagnosticExpectation(
      path: path,
      reason: StaffDataDiagnosticReason.malformedStaffRecord,
      memberId: memberId,
      rawRole: rawRole,
    );
  }
  return null;
}

void _expectRoleCoverageAndNoFallback(
  Map<String, dynamic> sanitizedSave,
  List<StaffDataDiagnostic> diagnostics, {
  required int seed,
}) {
  const canonicalRoleNames = <String>[
    'headCoach',
    'youthCoach',
    'scout',
    'physio',
    'doctor',
    'cfo',
  ];
  expect(
    StaffRole.values.map((role) => role.name).toList(),
    equals(canonicalRoleNames),
    reason: 'serialized StaffRole set changed; seed=$seed',
  );

  final league = sanitizedSave['leagueState'] as Map<String, dynamic>;
  final roleNames = <String>{};
  final outputIds = <String>{};
  for (final team
      in (league['teams'] as List<dynamic>).cast<Map<String, dynamic>>()) {
    final staff = team['staff'] as Map<String, dynamic>;
    for (final slot in canonicalRoleNames) {
      final record = staff[slot];
      if (record is Map<String, dynamic>) {
        roleNames.add(record['role'] as String);
        outputIds.add(record['id'] as String);
      }
    }
  }
  for (final record in league['staffFreeAgents'] as List<dynamic>) {
    final map = record as Map<String, dynamic>;
    roleNames.add(map['role'] as String);
    outputIds.add(map['id'] as String);
  }

  expect(
    roleNames,
    containsAll(canonicalRoleNames),
    reason: 'not all canonical roles survived semantically; seed=$seed',
  );
  final rejectedIds = diagnostics
      .where(
        (diagnostic) =>
            diagnostic.reason != StaffDataDiagnosticReason.duplicateStaffRecord,
      )
      .map((diagnostic) => diagnostic.memberId)
      .whereType<String>()
      .toSet();
  expect(
    outputIds.intersection(rejectedIds),
    isEmpty,
    reason: 'rejected record received a fallback assignment; seed=$seed',
  );
}

void _expectEmptySlotsRemainEmpty(
  _GeneratedCase generated,
  Map<String, dynamic> sanitizedSave,
  int seed,
) {
  final sourceLeague = generated.save['leagueState'] as Map<String, dynamic>;
  final sourceTeams = (sourceLeague['teams'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final outputLeague = sanitizedSave['leagueState'] as Map<String, dynamic>;
  final outputTeams = (outputLeague['teams'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  for (var index = 0; index < sourceTeams.length; index++) {
    final teamId = sourceTeams[index]['id'] as String;
    final teamCase = generated.teamsById[teamId]!;
    final outputStaff = outputTeams[index]['staff'] as Map<String, dynamic>;
    for (final role in StaffRole.values) {
      if (teamCase.slots[role] == null) {
        expect(
          outputStaff[role.name],
          isNull,
          reason: 'EmptySlot was populated by a fallback; seed=$seed',
        );
      }
    }
  }
}

List<Map<String, dynamic>> _diagnosticProjection(
  List<StaffDataDiagnostic> diagnostics,
) => [
  for (final diagnostic in diagnostics)
    <String, dynamic>{
      'path': diagnostic.path,
      'reason': diagnostic.reason,
      'memberId': diagnostic.memberId,
      'rawRole': diagnostic.rawRole,
    },
];

Map<String, dynamic> _cloneMap(Map<String, dynamic> source) =>
    jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
