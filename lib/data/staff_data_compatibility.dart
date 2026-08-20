import 'package:new_football/core/models/enums.dart';

/// Stable diagnostic reasons emitted by [StaffDataCompatibility].
abstract final class StaffDataDiagnosticReason {
  static const unknownRole = 'unknownRole';
  static const roleSlotMismatch = 'roleSlotMismatch';
  static const malformedStaffRecord = 'malformedStaffRecord';
  static const malformedStaffMap = 'malformedStaffMap';
  static const malformedFreeAgentList = 'malformedFreeAgentList';
  static const duplicateStaffRecord = 'duplicateStaffRecord';
  static const malformedLeagueState = 'malformedLeagueState';
}

/// A recoverable problem found while normalizing one staff record.
///
/// Diagnostics deliberately contain raw boundary data rather than decoded
/// [StaffMember] instances. This class is therefore usable before generated
/// enum decoders are invoked and does not depend on Flutter or presentation
/// code.
final class StaffDataDiagnostic {
  const StaffDataDiagnostic({
    required this.path,
    required this.reason,
    this.memberId,
    this.rawRole,
    this.details,
  });

  /// JSON path of the discarded or malformed value.
  final String path;

  /// One of [StaffDataDiagnosticReason]'s stable string values.
  final String reason;

  /// Persisted member identifier, when it was a string.
  final String? memberId;

  /// The role value as it appeared at the JSON boundary. It can be a value
  /// other than a string when the input was malformed.
  final Object? rawRole;

  /// Optional detail that helps a loader or log identify the malformed field.
  final String? details;

  // Short aliases keep the diagnostic convenient for callers that use the
  // terminology "id" or "code" at their data boundary.
  String? get id => memberId;
  String get code => reason;
  String get message => details == null ? reason : '$reason: $details';

  @override
  String toString() {
    final fields = <String>['path=$path', 'reason=$reason'];
    if (memberId != null) fields.add('memberId=$memberId');
    if (rawRole != null) fields.add('rawRole=$rawRole');
    if (details != null) fields.add('details=$details');
    return 'StaffDataDiagnostic(${fields.join(', ')})';
  }

  @override
  bool operator ==(Object other) {
    return other is StaffDataDiagnostic &&
        other.path == path &&
        other.reason == reason &&
        other.memberId == memberId &&
        other.rawRole == rawRole &&
        other.details == details;
  }

  @override
  int get hashCode => Object.hash(path, reason, memberId, rawRole, details);
}

/// Result of normalizing a raw save or league-state JSON map.
///
/// [sanitizedJson] is a deep copy of the input. The normalizer never mutates
/// the caller's map, so a result can safely be retained for diagnostics or
/// compared with the original input. [diagnostics] is immutable and ordered
/// by the traversal order of the source JSON.
final class StaffCompatibilityResult<T extends Map<String, dynamic>> {
  StaffCompatibilityResult({
    required this.sanitizedJson,
    required List<StaffDataDiagnostic> diagnostics,
  }) : diagnostics = List<StaffDataDiagnostic>.unmodifiable(diagnostics);

  final T sanitizedJson;
  final List<StaffDataDiagnostic> diagnostics;

  /// Alias for callers that refer to the normalized map as [json].
  T get json => sanitizedJson;

  /// Additional descriptive alias for callers that use "normalized" rather
  /// than "sanitized" for the boundary result.
  T get normalizedJson => sanitizedJson;

  /// Alias useful when this result is passed through a generic data loader.
  T get value => sanitizedJson;
  T get data => sanitizedJson;

  bool get hasDiagnostics => diagnostics.isNotEmpty;
  bool get isCompatible => diagnostics.isEmpty;
}

/// Safe boundary normalization for staff data embedded in save JSON.
///
/// Generated `json_serializable` decoders use `$enumDecode` for
/// `StaffMember.role`, so an unknown role must be removed before
/// `GameSave.fromJson`, `LeagueState.fromJson` or `TeamStaff.fromJson` is
/// called. This class performs only that boundary concern:
///
/// * recognized role strings are retained exactly as persisted;
/// * a team slot retains a record only when its role matches the slot;
/// * unknown, missing or malformed roles are excluded with a recoverable
///   diagnostic;
/// * absent staff slots remain [EmptySlot] (`null`), and no member, rating or
///   contract is fabricated;
/// * partial `attributes` maps are preserved so generated defaults provide
///   missing values as `0.0`;
/// * unknown attribute names are preserved and ignored by the typed model;
/// * the legacy `headCoach.development` field is never rewritten or promoted
///   into a head-coach role attribute;
/// * all outputs are deep copies, making the operation non-mutating and
///   idempotent on an already sanitized JSON tree.
abstract final class StaffDataCompatibility {
  /// The only role names accepted by the current [StaffRole] model.
  static const List<String> canonicalRoleNames = <String>[
    'headCoach',
    'youthCoach',
    'scout',
    'physio',
    'doctor',
    'cfo',
  ];

  /// Canonical `TeamStaff` slot names, in enum order.
  static const List<String> teamStaffSlotNames = canonicalRoleNames;

  static const Map<String, StaffRole> _rolesByName = <String, StaffRole>{
    'headCoach': StaffRole.headCoach,
    'youthCoach': StaffRole.youthCoach,
    'scout': StaffRole.scout,
    'physio': StaffRole.physio,
    'doctor': StaffRole.doctor,
    'cfo': StaffRole.cfo,
  };

  static const List<String> _attributeNames = <String>[
    'tactics',
    'motivation',
    'development',
    'mentoring',
    'coverage',
    'evaluation',
    'rehabilitation',
    'regenaration',
    'prevention',
    'care',
    'negotiation',
  ];

  static final Set<String> _nationalityNames = {
    for (final nationality in Nationality.values) nationality.name,
  };

  /// Returns the current enum role for a serialized role value.
  ///
  /// No fallback is applied. In particular, `developmentCoach` or any other
  /// role not represented by the current enum is an [UnknownRole].
  static StaffRole? roleForSerializedName(Object? rawRole) {
    if (rawRole is! String) return null;
    return _rolesByName[rawRole];
  }

  static bool isRecognizedRole(Object? rawRole) =>
      roleForSerializedName(rawRole) != null;

  /// Sanitizes a complete `GameSave.toJson()` map.
  static StaffCompatibilityResult<Map<String, dynamic>> sanitizeGameSaveJson(
    Map<String, dynamic> json,
  ) {
    final copy = _cloneMap(json);
    final diagnostics = <StaffDataDiagnostic>[];
    final leagueState = copy['leagueState'];

    if (leagueState == null) {
      return StaffCompatibilityResult(
        sanitizedJson: copy,
        diagnostics: diagnostics,
      );
    }

    final leagueStateMap = _asStringMap(leagueState);
    if (leagueStateMap == null) {
      diagnostics.add(
        const StaffDataDiagnostic(
          path: 'leagueState',
          reason: StaffDataDiagnosticReason.malformedLeagueState,
        ),
      );
      return StaffCompatibilityResult(
        sanitizedJson: copy,
        diagnostics: diagnostics,
      );
    }

    _sanitizeLeagueState(
      leagueStateMap,
      rootPath: 'leagueState',
      diagnostics: diagnostics,
    );
    return StaffCompatibilityResult(
      sanitizedJson: copy,
      diagnostics: diagnostics,
    );
  }

  /// Short alias for [sanitizeGameSaveJson].
  static StaffCompatibilityResult<Map<String, dynamic>> sanitizeGameSave(
    Map<String, dynamic> json,
  ) => sanitizeGameSaveJson(json);

  /// Sanitizes a raw `LeagueState.toJson()` map.
  static StaffCompatibilityResult<Map<String, dynamic>> sanitizeLeagueStateJson(
    Map<String, dynamic> json,
  ) {
    final copy = _cloneMap(json);
    final diagnostics = <StaffDataDiagnostic>[];
    _sanitizeLeagueState(copy, diagnostics: diagnostics);
    return StaffCompatibilityResult(
      sanitizedJson: copy,
      diagnostics: diagnostics,
    );
  }

  /// Short alias for [sanitizeLeagueStateJson].
  static StaffCompatibilityResult<Map<String, dynamic>> sanitizeLeagueState(
    Map<String, dynamic> json,
  ) => sanitizeLeagueStateJson(json);

  /// Automatically selects the save or league-state entry point.
  ///
  /// This is useful for callers that receive a decoded JSON root without
  /// knowing which generated model will be decoded next.
  static StaffCompatibilityResult<Map<String, dynamic>> sanitize(
    Map<String, dynamic> json,
  ) => json.containsKey('leagueState')
      ? sanitizeGameSaveJson(json)
      : sanitizeLeagueStateJson(json);

  /// Compatibility alias for code that calls the operation normalization.
  static StaffCompatibilityResult<Map<String, dynamic>> normalize(
    Map<String, dynamic> json,
  ) => sanitize(json);

  /// Compatibility alias for explicit save normalization.
  static StaffCompatibilityResult<Map<String, dynamic>> normalizeGameSaveJson(
    Map<String, dynamic> json,
  ) => sanitizeGameSaveJson(json);

  /// Compatibility alias for explicit league-state normalization.
  static StaffCompatibilityResult<Map<String, dynamic>>
  normalizeLeagueStateJson(Map<String, dynamic> json) =>
      sanitizeLeagueStateJson(json);

  static void _sanitizeLeagueState(
    Map<String, dynamic> leagueState, {
    String rootPath = '',
    required List<StaffDataDiagnostic> diagnostics,
  }) {
    final seenStaffIds = <String>{};
    final teamsValue = leagueState['teams'];
    if (teamsValue is List) {
      final teamsPath = _fieldPath(rootPath, 'teams');
      for (var index = 0; index < teamsValue.length; index++) {
        final team = teamsValue[index];
        final teamMap = _asStringMap(team);
        if (teamMap == null) continue;
        _sanitizeTeamStaff(
          teamMap,
          path: '$teamsPath[$index].staff',
          diagnostics: diagnostics,
          seenStaffIds: seenStaffIds,
        );
      }
    }

    final freeAgentsValue = leagueState['staffFreeAgents'];
    if (freeAgentsValue is List) {
      final freeAgentsPath = _fieldPath(rootPath, 'staffFreeAgents');
      final retained = <dynamic>[];
      for (var index = 0; index < freeAgentsValue.length; index++) {
        final record = freeAgentsValue[index];
        final path = '$freeAgentsPath[$index]';
        final recordMap = _asStringMap(record);
        if (recordMap == null) {
          diagnostics.add(
            StaffDataDiagnostic(
              path: path,
              reason: StaffDataDiagnosticReason.malformedStaffRecord,
              details: 'record must be a JSON object',
            ),
          );
          continue;
        }
        if (_retainRecord(recordMap, path: path, diagnostics: diagnostics)) {
          final memberId = recordMap['id'] as String;
          if (!seenStaffIds.add(memberId)) {
            diagnostics.add(
              StaffDataDiagnostic(
                path: path,
                reason: StaffDataDiagnosticReason.duplicateStaffRecord,
                memberId: memberId,
                rawRole: recordMap['role'],
                details: 'staff member id already exists in the save',
              ),
            );
            continue;
          }
          retained.add(recordMap);
        }
      }
      // Replacing the cloned list, rather than editing the input list, also
      // makes removal of UnknownRole records deterministic and idempotent.
      leagueState['staffFreeAgents'] = retained;
    } else if (freeAgentsValue != null) {
      diagnostics.add(
        StaffDataDiagnostic(
          path: _fieldPath(rootPath, 'staffFreeAgents'),
          reason: StaffDataDiagnosticReason.malformedFreeAgentList,
          details: 'value must be a JSON array',
        ),
      );
      // Null has the same generated-model meaning as an absent optional list:
      // no free agents. It does not invent a member or a contract.
      leagueState['staffFreeAgents'] = null;
    }
  }

  static void _sanitizeTeamStaff(
    Map<String, dynamic> team, {
    required String path,
    required List<StaffDataDiagnostic> diagnostics,
    required Set<String> seenStaffIds,
  }) {
    final staffValue = team['staff'];
    if (staffValue == null) return;

    final staff = _asStringMap(staffValue);
    if (staff == null) {
      diagnostics.add(
        StaffDataDiagnostic(
          path: path,
          reason: StaffDataDiagnosticReason.malformedStaffMap,
          details: 'value must be a JSON object',
        ),
      );
      // TeamStaff.fromJson treats null as the documented all-EmptySlot value.
      team['staff'] = null;
      return;
    }

    for (final slotName in teamStaffSlotNames) {
      if (!staff.containsKey(slotName)) continue;
      final record = staff[slotName];
      if (record == null) continue; // EmptySlot is a first-class state.

      final recordPath = '$path.$slotName';
      final recordMap = _asStringMap(record);
      if (recordMap == null) {
        diagnostics.add(
          StaffDataDiagnostic(
            path: recordPath,
            reason: StaffDataDiagnosticReason.malformedStaffRecord,
            details: 'record must be a JSON object',
          ),
        );
        staff[slotName] = null;
        continue;
      }

      final expectedRole = _rolesByName[slotName]!;
      if (_retainRecord(
        recordMap,
        expectedRole: expectedRole,
        path: recordPath,
        diagnostics: diagnostics,
      )) {
        final memberId = recordMap['id'] as String;
        if (seenStaffIds.add(memberId)) {
          staff[slotName] = recordMap;
        } else {
          diagnostics.add(
            StaffDataDiagnostic(
              path: recordPath,
              reason: StaffDataDiagnosticReason.duplicateStaffRecord,
              memberId: memberId,
              rawRole: recordMap['role'],
              details: 'staff member id already exists in the save',
            ),
          );
          staff[slotName] = null;
        }
      } else {
        // A rejected record must not move to another role or bring its
        // contract into the active team. Null is the canonical EmptySlot JSON.
        staff[slotName] = null;
      }
    }
  }

  static bool _retainRecord(
    Map<String, dynamic> record, {
    StaffRole? expectedRole,
    required String path,
    required List<StaffDataDiagnostic> diagnostics,
  }) {
    final rawRole = record['role'];
    final role = roleForSerializedName(rawRole);
    final memberId = record['id'] is String ? record['id'] as String : null;

    if (role == null) {
      diagnostics.add(
        StaffDataDiagnostic(
          path: path,
          reason: StaffDataDiagnosticReason.unknownRole,
          memberId: memberId,
          rawRole: rawRole,
          details: 'role is not one of ${canonicalRoleNames.join(', ')}',
        ),
      );
      return false;
    }

    if (expectedRole != null && role != expectedRole) {
      diagnostics.add(
        StaffDataDiagnostic(
          path: path,
          reason: StaffDataDiagnosticReason.roleSlotMismatch,
          memberId: memberId,
          rawRole: rawRole,
          details: 'slot expects ${expectedRole.name}',
        ),
      );
      return false;
    }

    final malformedField = _firstMalformedField(record);
    if (malformedField != null) {
      diagnostics.add(
        StaffDataDiagnostic(
          path: path,
          reason: StaffDataDiagnosticReason.malformedStaffRecord,
          memberId: memberId,
          rawRole: rawRole,
          details: malformedField,
        ),
      );
      return false;
    }

    return true;
  }

  /// Returns the first field that would make a generated StaffMember decoder
  /// throw. Missing optional attribute maps are intentionally valid: the
  /// generated StaffAttributes defaults fill absent fields with 0.0.
  static String? _firstMalformedField(Map<String, dynamic> record) {
    if (record['id'] is! String || (record['id'] as String).isEmpty) {
      return 'id must be a non-empty string';
    }
    if (record['name'] is! String) return 'name must be a string';
    if (record['nationality'] is! String ||
        !_nationalityNames.contains(record['nationality'])) {
      return 'nationality must be a recognized serialized enum value';
    }
    if (record['age'] is! num) return 'age must be numeric';

    final attributesError = _attributeMapError(record, fieldName: 'attributes');
    if (attributesError != null) return attributesError;

    final previousError = _attributeMapError(
      record,
      fieldName: 'previousAttributes',
    );
    if (previousError != null) return previousError;

    final contract = record['contract'];
    if (contract != null) {
      final contractMap = _asStringMap(contract);
      if (contractMap == null) return 'contract must be a JSON object or null';
      if (contractMap['salary'] is! num) {
        return 'contract.salary must be numeric';
      }
      if (contractMap['yearsRemaining'] is! num) {
        return 'contract.yearsRemaining must be numeric';
      }
    }

    return null;
  }

  static String? _attributeMapError(
    Map<String, dynamic> record, {
    required String fieldName,
  }) {
    if (!record.containsKey(fieldName)) return null;
    final value = record[fieldName];
    if (value == null) return null;
    final map = _asStringMap(value);
    if (map == null) return '$fieldName must be a JSON object or null';

    // Unknown attribute names are deliberately ignored by StaffAttributes.
    // Known values must remain numeric (or null) so generated decoding cannot
    // fail. Missing known values remain untouched and decode to 0.0.
    for (final name in _attributeNames) {
      final attribute = map[name];
      if (attribute != null && attribute is! num) {
        return '$fieldName.$name must be numeric';
      }
    }
    return null;
  }

  static String _fieldPath(String rootPath, String field) =>
      rootPath.isEmpty ? field : '$rootPath.$field';

  static Map<String, dynamic>? _asStringMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }

  static Map<String, dynamic> _cloneMap(Map<String, dynamic> source) =>
      _cloneJsonValue(source) as Map<String, dynamic>;

  static Object? _cloneJsonValue(Object? value) {
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        if (entry.key is String) {
          result[entry.key as String] = _cloneJsonValue(entry.value);
        }
      }
      return result;
    }
    if (value is List) {
      return [for (final item in value) _cloneJsonValue(item)];
    }
    return value;
  }
}
