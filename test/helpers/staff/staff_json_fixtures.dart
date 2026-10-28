part of '../staff_role_ratings_test_helpers.dart';

// ---------------------------------------------------------------------------
// Raw persisted JSON fixtures
// ---------------------------------------------------------------------------

/// Compatibility cases a persisted staff record can be in.
enum StaffJsonCase {
  /// Fully populated, recognized record.
  valid,

  /// Recognized role, but a relevant attribute key is absent (legacy save).
  missingRelevantAttribute,

  /// Recognized role plus an attribute key the model does not declare.
  unknownAttribute,

  /// Role identifier outside `StaffRole`.
  unknownRole,
}

/// Raw attribute map.
///
/// [omit] removes keys so the generated decoder falls back to `0.0`, and
/// [extra] adds names the model does not declare.
Map<String, dynamic> staffAttributesJson(
  StaffAttributes attributes, {
  Set<String> omit = const {},
  Map<String, double> extra = const {},
}) => <String, dynamic>{
  for (final name in staffAttributeNames)
    if (!omit.contains(name)) name: staffAttributeByName(attributes, name),
  ...extra,
};

/// Raw persisted staff record.
///
/// [rawRole] overrides the serialized role with an arbitrary string, which is
/// how an UnknownRole reaches the loader before the generated decoder runs.
Map<String, dynamic> staffMemberJson({
  StaffRole role = StaffRole.headCoach,
  String? rawRole,
  String? id,
  int index = 1,
  String? name,
  Nationality nationality = Nationality.poland,
  int age = 45,
  StaffAttributes? attributes,
  Set<String> omitAttributes = const {},
  Map<String, double> extraAttributes = const {},
  StaffContract? contract,
  StaffAttributes? previousAttributes,
}) => <String, dynamic>{
  'id': id ?? staffFixtureId(role, index),
  'name': name ?? '${rawRole ?? role.name} #$index',
  'nationality': nationality.name,
  'age': age,
  'role': rawRole ?? role.name,
  'attributes': staffAttributesJson(
    attributes ?? staffAttributesWithRawOverall(role, 3.0),
    omit: omitAttributes,
    extra: extraAttributes,
  ),
  'contract': contract == null
      ? null
      : <String, dynamic>{
          'salary': contract.salary,
          'yearsRemaining': contract.yearsRemaining,
        },
  'previousAttributes': previousAttributes == null
      ? null
      : staffAttributesJson(previousAttributes),
};

/// Raw record for one [StaffJsonCase].
Map<String, dynamic> staffJsonRecord(
  StaffJsonCase kind, {
  StaffRole role = StaffRole.headCoach,
  int index = 1,
  StaffContract? contract,
}) => switch (kind) {
  StaffJsonCase.valid => staffMemberJson(
    role: role,
    index: index,
    contract: contract,
  ),
  StaffJsonCase.missingRelevantAttribute => staffMemberJson(
    role: role,
    index: index,
    contract: contract,
    omitAttributes: {relevantStaffAttributeNames(role).first},
  ),
  StaffJsonCase.unknownAttribute => staffMemberJson(
    role: role,
    index: index,
    contract: contract,
    extraAttributes: const {unknownStaffAttributeName: 4.0},
  ),
  StaffJsonCase.unknownRole => staffMemberJson(
    role: role,
    rawRole: unknownStaffRoleValue,
    index: index,
    contract: contract,
  ),
};

/// Raw `TeamStaff` map. Roles absent from [slots] stay `null`, i.e. EmptySlot.
///
/// Any record may be placed in any slot, which is how a role/slot mismatch is
/// built: `teamStaffJson({StaffRole.headCoach: staffMemberJson(role:
/// StaffRole.scout)})`.
Map<String, dynamic> teamStaffJson(
  Map<StaffRole, Map<String, dynamic>?> slots,
) => <String, dynamic>{
  for (final role in StaffRole.values) role.name: slots[role],
};

/// Raw staff data covering every compatibility case at once: valid records, a
/// missing relevant attribute, an UnknownAttribute, an EmptySlot, a role/slot
/// mismatch and an UnknownRole free agent.
({
  Map<String, dynamic> teamStaff,
  List<Map<String, dynamic>> freeAgents,
  List<String> validIds,
  List<String> invalidIds,
})
mixedStaffJson() {
  final valid = staffJsonRecord(
    StaffJsonCase.valid,
    role: StaffRole.headCoach,
    contract: staffFixtureContract(),
  );
  final missing = staffJsonRecord(
    StaffJsonCase.missingRelevantAttribute,
    role: StaffRole.scout,
  );
  final unknownAttribute = staffJsonRecord(
    StaffJsonCase.unknownAttribute,
    role: StaffRole.doctor,
  );
  final mismatched = staffMemberJson(
    role: StaffRole.youthCoach,
    index: 2,
    id: staffFixtureId(StaffRole.physio, 2),
  );
  final unknownRole = staffJsonRecord(
    StaffJsonCase.unknownRole,
    role: StaffRole.cfo,
    index: 3,
  );
  final validFreeAgent = staffJsonRecord(
    StaffJsonCase.valid,
    role: StaffRole.youthCoach,
    index: 4,
  );
  return (
    teamStaff: teamStaffJson({
      StaffRole.headCoach: valid,
      StaffRole.scout: missing,
      StaffRole.doctor: unknownAttribute,
      StaffRole.physio: mismatched,
      StaffRole.cfo: unknownRole,
    }),
    freeAgents: [validFreeAgent, unknownRole],
    validIds: [
      valid['id'] as String,
      missing['id'] as String,
      unknownAttribute['id'] as String,
      validFreeAgent['id'] as String,
    ],
    invalidIds: [mismatched['id'] as String, unknownRole['id'] as String],
  );
}

/// Pure JSON tree for [save].
///
/// `toJson` on a freezed model keeps nested models as objects, so a raw-map
/// test has to round-trip through [jsonEncode] first.
Map<String, dynamic> decodedSaveJson(GameSave save) =>
    jsonDecode(jsonEncode(save.toJson())) as Map<String, dynamic>;

/// Copy of a serialized save with raw staff data injected.
///
/// Only the staff subtree of [teamId] and the raw free-agent list change; the
/// rest of the save, including `schemaVersion`, is left untouched.
Map<String, dynamic> withRawStaffJson(
  Map<String, dynamic> saveJson, {
  String teamId = staffFixtureTeamId,
  Map<String, dynamic>? teamStaff,
  List<Map<String, dynamic>>? staffFreeAgents,
}) {
  final copy = jsonDecode(jsonEncode(saveJson)) as Map<String, dynamic>;
  final league = copy['leagueState'] as Map<String, dynamic>;
  if (teamStaff != null) {
    final teams = (league['teams'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final team = teams.firstWhere(
      (item) => item['id'] == teamId,
      orElse: () => throw ArgumentError.value(
        teamId,
        'teamId',
        'Not present in the serialized league',
      ),
    );
    team['staff'] = teamStaff;
  }
  if (staffFreeAgents != null) {
    league['staffFreeAgents'] = staffFreeAgents;
  }
  return copy;
}
