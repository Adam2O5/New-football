import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';

part 'staff.freezed.dart';
part 'staff.g.dart';

/// Stable identifiers of the fields declared by [StaffAttributes].
///
/// [StaffAttributeKey.name] is the serialized JSON field name, so it doubles as
/// the stable domain identifier used by snapshots and providers. Localized
/// labels belong to the presentation layer only.
///
/// `regenaration` keeps the existing spelling of Regeneration used by
/// [StaffAttributes] and by persisted saves; renaming it would require a save
/// migration and is out of scope here.
enum StaffAttributeKey {
  tactics,
  motivation,
  development,
  mentoring,
  coverage,
  evaluation,
  rehabilitation,
  regenaration,
  prevention,
  care,
  negotiation,
}

/// Single source of truth for the staff rating (`docs/staff.md` §2).
///
/// Owns the canonical `StaffRole -> relevant attributes` mapping and the
/// RawOverall formula. RawOverall is an unrounded `double` in the inclusive
/// 0–5 scale derived only from the attributes relevant to the role, and it is
/// the only rating input for sorting, salaries, negotiations and AI.
///
/// Rounding to visual star steps (DisplayedRating) belongs to the presentation
/// layer; this class deliberately exposes no displayed API and never imports
/// Flutter.
abstract final class StaffRatingSystem {
  /// Lower bound of the star scale.
  static const double minRating = 0.0;

  /// Upper bound of the star scale.
  static const double maxRating = 5.0;

  /// Canonical role → relevant attributes, in stable presentation order.
  ///
  /// Every recognized [StaffRole] has an entry. Attributes outside a role's
  /// list never contribute to its rating: `headCoach` in particular excludes
  /// the legacy `development` field, which may still exist in old saves.
  static const Map<StaffRole, List<StaffAttributeKey>>
  roleRelevantAttributes = {
    StaffRole.headCoach: [
      StaffAttributeKey.tactics,
      StaffAttributeKey.motivation,
    ],
    StaffRole.youthCoach: [
      StaffAttributeKey.development,
      StaffAttributeKey.mentoring,
    ],
    StaffRole.scout: [StaffAttributeKey.coverage, StaffAttributeKey.evaluation],
    StaffRole.physio: [
      StaffAttributeKey.rehabilitation,
      StaffAttributeKey.regenaration,
    ],
    StaffRole.doctor: [StaffAttributeKey.prevention, StaffAttributeKey.care],
    StaffRole.cfo: [StaffAttributeKey.negotiation],
  };

  /// Relevant attribute keys of [role], in canonical order.
  static List<StaffAttributeKey> keysForRole(StaffRole role) =>
      roleRelevantAttributes[role]!;

  /// Serialized names of the relevant attributes of [role], in canonical order.
  ///
  /// Consumers such as the development snapshot must read this instead of
  /// keeping a second role switch.
  static List<String> serializedNamesForRole(StaffRole role) =>
      keysForRole(role).map((key) => key.name).toList(growable: false);

  /// Key matching the serialized [name], or `null` for an UnknownAttribute.
  ///
  /// Callers decide the fallback; the domain never throws on unknown names.
  static StaffAttributeKey? keyForSerializedName(String name) =>
      _keysBySerializedName[name];

  static final Map<String, StaffAttributeKey> _keysBySerializedName = {
    for (final key in StaffAttributeKey.values) key.name: key,
  };

  /// Value of [key] as stored in [attributes].
  ///
  /// Returns the field verbatim, so snapshots report the persisted value. The
  /// 0–5 clamp is applied by [rawOverall] before the rating is produced.
  static double attributeValue(
    StaffAttributes attributes,
    StaffAttributeKey key,
  ) => switch (key) {
    StaffAttributeKey.tactics => attributes.tactics,
    StaffAttributeKey.motivation => attributes.motivation,
    StaffAttributeKey.development => attributes.development,
    StaffAttributeKey.mentoring => attributes.mentoring,
    StaffAttributeKey.coverage => attributes.coverage,
    StaffAttributeKey.evaluation => attributes.evaluation,
    StaffAttributeKey.rehabilitation => attributes.rehabilitation,
    StaffAttributeKey.regenaration => attributes.regenaration,
    StaffAttributeKey.prevention => attributes.prevention,
    StaffAttributeKey.care => attributes.care,
    StaffAttributeKey.negotiation => attributes.negotiation,
  };

  /// RawOverall of [attributes] for [role].
  ///
  /// Two-attribute roles return the mean of exactly their two clamped relevant
  /// values; `cfo` returns the clamped `negotiation` value alone. Every input
  /// and the result are clamped to 0–5, and the result is never rounded to a
  /// star step.
  static double rawOverall(StaffAttributes attributes, StaffRole role) {
    final keys = keysForRole(role);
    final sum = keys.fold<double>(
      0,
      (total, key) => total + clampToScale(attributeValue(attributes, key)),
    );
    return clampToScale(sum / keys.length);
  }

  /// [value] limited to the inclusive 0–5 star scale.
  static double clampToScale(double value) =>
      value.clamp(minRating, maxRating).toDouble();
}

@freezed
abstract class StaffAttributes with _$StaffAttributes {
  const factory StaffAttributes({
    @Default(0.0) double tactics,
    @Default(0.0) double motivation,
    @Default(0.0) double development,
    @Default(0.0) double mentoring,
    @Default(0.0) double coverage,
    @Default(0.0) double evaluation,
    @Default(0.0) double rehabilitation,
    @Default(0.0) double regenaration,
    @Default(0.0) double prevention,
    @Default(0.0) double care,
    @Default(0.0) double negotiation,
  }) = _StaffAttributes;

  factory StaffAttributes.fromJson(Map<String, dynamic> json) =>
      _$StaffAttributesFromJson(json);
}

extension StaffAttributesX on StaffAttributes {
  /// RawOverall for [role] (`docs/staff.md` §2).
  ///
  /// Compatibility facade over [StaffRatingSystem.rawOverall]; it keeps no
  /// mapping of its own.
  double overallForRole(StaffRole role) =>
      StaffRatingSystem.rawOverall(this, role);
}

@freezed
abstract class StaffContract with _$StaffContract {
  const factory StaffContract({
    required int salary,
    required int yearsRemaining,
  }) = _StaffContract;

  factory StaffContract.fromJson(Map<String, dynamic> json) =>
      _$StaffContractFromJson(json);
}

@freezed
abstract class StaffMember with _$StaffMember {
  const factory StaffMember({
    required String id,
    required String name,
    required Nationality nationality,
    required int age,
    required StaffRole role,
    @Default(StaffAttributes()) StaffAttributes attributes,
    StaffContract? contract,

    /// Previous attributes captured before the last growth tick.
    /// Used by the Development screen to compute growth deltas.
    StaffAttributes? previousAttributes,
  }) = _StaffMember;

  factory StaffMember.fromJson(Map<String, dynamic> json) =>
      _$StaffMemberFromJson(json);
}

extension StaffMemberX on StaffMember {
  /// RawOverall of this member for its own [StaffMember.role].
  ///
  /// Thin delegation to [StaffRatingSystem.rawOverall]: unrounded, clamped to
  /// 0–5 and never averaged a second time over all attributes.
  double get overall => StaffRatingSystem.rawOverall(attributes, role);

  /// Relevant attribute keys of this member's role, in canonical order.
  List<StaffAttributeKey> get relevantAttributeKeys =>
      StaffRatingSystem.keysForRole(role);
}

@freezed
abstract class TeamStaff with _$TeamStaff {
  const factory TeamStaff({
    StaffMember? headCoach,
    StaffMember? youthCoach,
    StaffMember? scout,
    StaffMember? physio,
    StaffMember? doctor,
    StaffMember? cfo,
  }) = _TeamStaff;

  factory TeamStaff.fromJson(Map<String, dynamic> json) =>
      _$TeamStaffFromJson(json);
}

extension TeamStaffX on TeamStaff {
  /// Occupied, canonical slots only; an EmptySlot (`null`), a mismatched
  /// legacy record, an empty identifier or a duplicate identifier contributes
  /// nothing to the active staff collection.
  List<StaffMember> get members {
    final result = <StaffMember>[];
    final seenIds = <String>{};
    for (final role in StaffRole.values) {
      final member = canonicalMember(role);
      if (member == null || !seenIds.add(member.id)) continue;
      result.add(member);
    }
    return result;
  }

  /// Payroll of active, well-formed staff contracts.
  ///
  /// Reads `contract.salary` only: no rating, raw or displayed value takes
  /// part in reconstructing payroll. Expired, out-of-range and mismatched
  /// legacy records are not active payroll entries.
  int get totalSalary => members.fold(0, (sum, member) {
    final contract = member.contract;
    if (contract == null || contract.yearsRemaining <= 0) return sum;
    if (contract.salary < BalanceConfig.defaults.staff.minSalary ||
        contract.salary > BalanceConfig.defaults.staff.maxSalary) {
      return sum;
    }
    return sum + contract.salary;
  });

  /// Raw member in the recognized [role] slot, or `null` for an EmptySlot.
  ///
  /// This accessor intentionally preserves a role/slot mismatch so the UI and
  /// diagnostics can represent it as an unavailable state rather than
  /// silently converting it to a different role. Domain consumers should use
  /// [canonicalMember] when they need an active role assignment.
  StaffMember? member(StaffRole role) => switch (role) {
    StaffRole.headCoach => headCoach,
    StaffRole.youthCoach => youthCoach,
    StaffRole.scout => scout,
    StaffRole.physio => physio,
    StaffRole.doctor => doctor,
    StaffRole.cfo => cfo,
  };

  /// Member in [role] only when the stored record is safe for that role.
  ///
  /// Unknown roles cannot exist in the typed enum model, but a legacy typed
  /// fixture can still place a recognized member in the wrong slot. Such a
  /// record is never used for salary, negotiation, AI or gameplay assignment.
  StaffMember? canonicalMember(StaffRole role) {
    final candidate = member(role);
    if (candidate == null || candidate.role != role || candidate.id.isEmpty) {
      return null;
    }
    return candidate;
  }

  TeamStaff withMember(StaffRole role, StaffMember? member) => switch (role) {
    StaffRole.headCoach => copyWith(headCoach: member),
    StaffRole.youthCoach => copyWith(youthCoach: member),
    StaffRole.scout => copyWith(scout: member),
    StaffRole.physio => copyWith(physio: member),
    StaffRole.doctor => copyWith(doctor: member),
    StaffRole.cfo => copyWith(cfo: member),
  };
}

/// Defensive projection of a typed free-agent collection.
///
/// Persisted UnknownRole values are removed before decoding. This second
/// guard protects in-memory/test/legacy state that already contains typed
/// records: only canonical roles with non-empty IDs are exposed and duplicate
/// IDs are retained once, in source order.
extension StaffMemberCollectionX on Iterable<StaffMember> {
  List<StaffMember> canonicalStaffMembers({StaffRole? role}) {
    final result = <StaffMember>[];
    final seenIds = <String>{};
    for (final member in this) {
      if (member.id.isEmpty ||
          !StaffRatingSystem.roleRelevantAttributes.containsKey(member.role) ||
          (role != null && member.role != role) ||
          !seenIds.add(member.id)) {
        continue;
      }
      result.add(member);
    }
    return result;
  }
}
