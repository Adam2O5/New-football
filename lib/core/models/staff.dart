import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'staff.freezed.dart';
part 'staff.g.dart';

@freezed
class StaffAttributes with _$StaffAttributes {
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
  /// Average of the attributes relevant to [role] (`staff_rules.md` §2).
  double overallForRole(StaffRole role) {
    switch (role) {
      case StaffRole.headCoach:
        return (tactics + motivation + development) / 3.0;
      case StaffRole.youthCoach:
        return (development + mentoring) / 2.0;
      case StaffRole.scout:
        return (coverage + evaluation) / 2.0;
      case StaffRole.physio:
        return (rehabilitation + regenaration) / 2.0;
      case StaffRole.doctor:
        return (prevention + care) / 2.0;
      case StaffRole.cfo:
        return negotiation;
    }
  }
}

@freezed
class StaffContract with _$StaffContract {
  const factory StaffContract({
    required int salary,
    required int yearsRemaining,
  }) = _StaffContract;

  factory StaffContract.fromJson(Map<String, dynamic> json) =>
      _$StaffContractFromJson(json);
}

@freezed
class StaffMember with _$StaffMember {
  const factory StaffMember({
    required String id,
    required String name,
    required Nationality nationality,
    required int age,
    required StaffRole role,
    @Default(StaffAttributes()) StaffAttributes attributes,
    StaffContract? contract,
  }) = _StaffMember;

  factory StaffMember.fromJson(Map<String, dynamic> json) =>
      _$StaffMemberFromJson(json);
}

extension StaffMemberX on StaffMember {
  double get overall => attributes.overallForRole(role);
}

@freezed
class TeamStaff with _$TeamStaff {
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
  List<StaffMember> get members => [
    ?headCoach,
    ?youthCoach,
    ?scout,
    ?physio,
    ?doctor,
    ?cfo,
  ];

  int get totalSalary =>
      members.fold(0, (sum, m) => sum + (m.contract?.salary ?? 0));

  StaffMember? member(StaffRole role) => switch (role) {
    StaffRole.headCoach => headCoach,
    StaffRole.youthCoach => youthCoach,
    StaffRole.scout => scout,
    StaffRole.physio => physio,
    StaffRole.doctor => doctor,
    StaffRole.cfo => cfo,
  };

  TeamStaff withMember(StaffRole role, StaffMember? member) => switch (role) {
    StaffRole.headCoach => copyWith(headCoach: member),
    StaffRole.youthCoach => copyWith(youthCoach: member),
    StaffRole.scout => copyWith(scout: member),
    StaffRole.physio => copyWith(physio: member),
    StaffRole.doctor => copyWith(doctor: member),
    StaffRole.cfo => copyWith(cfo: member),
  };
}
