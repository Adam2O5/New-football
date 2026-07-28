import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'assigned_role.freezed.dart';
part 'assigned_role.g.dart';

@Freezed(unionKey: 'type')
class AssignedRole with _$AssignedRole {
  const factory AssignedRole.gk({@Default(GkRole.standard) GkRole role}) =
      AssignedGkRole;

  const factory AssignedRole.cb({@Default(CbRole.standard) CbRole role}) =
      AssignedCbRole;

  const factory AssignedRole.fullBack({
    @Default(FullBackRole.standard) FullBackRole role,
  }) = AssignedFullBackRole;

  const factory AssignedRole.wingBack({
    @Default(WingBackRole.standard) WingBackRole role,
  }) = AssignedWingBackRole;

  const factory AssignedRole.cdm({@Default(CdmRole.standard) CdmRole role}) =
      AssignedCdmRole;

  const factory AssignedRole.cm({@Default(CmRole.standard) CmRole role}) =
      AssignedCmRole;

  const factory AssignedRole.cam({@Default(CamRole.standard) CamRole role}) =
      AssignedCamRole;

  const factory AssignedRole.winger({
    @Default(WingerRole.standard) WingerRole role,
  }) = AssignedWingerRole;

  const factory AssignedRole.striker({
    @Default(StrikerRole.standard) StrikerRole role,
  }) = AssignedStrikerRole;

  factory AssignedRole.fromJson(Map<String, dynamic> json) =>
      _$AssignedRoleFromJson(json);
}

extension PositionAssignedRole on Position {
  AssignedRole get defaultAssignedRole => switch (this) {
    Position.gk => const AssignedRole.gk(),
    Position.cb => const AssignedRole.cb(),
    Position.lb || Position.rb => const AssignedRole.fullBack(),
    Position.lwb || Position.rwb => const AssignedRole.wingBack(),
    Position.cdm => const AssignedRole.cdm(),
    Position.cm => const AssignedRole.cm(),
    Position.cam => const AssignedRole.cam(),
    Position.lw || Position.rw => const AssignedRole.winger(),
    Position.st => const AssignedRole.striker(),
  };
}

List<AssignedRole> rolesForPosition(Position position) => switch (position) {
  Position.gk => GkRole.values.map((r) => AssignedRole.gk(role: r)).toList(),
  Position.cb => CbRole.values.map((r) => AssignedRole.cb(role: r)).toList(),
  Position.lb || Position.rb =>
    FullBackRole.values.map((r) => AssignedRole.fullBack(role: r)).toList(),
  Position.lwb || Position.rwb =>
    WingBackRole.values.map((r) => AssignedRole.wingBack(role: r)).toList(),
  Position.cdm => CdmRole.values.map((r) => AssignedRole.cdm(role: r)).toList(),
  Position.cm => CmRole.values.map((r) => AssignedRole.cm(role: r)).toList(),
  Position.cam => CamRole.values.map((r) => AssignedRole.cam(role: r)).toList(),
  Position.lw || Position.rw =>
    WingerRole.values.map((r) => AssignedRole.winger(role: r)).toList(),
  Position.st =>
    StrikerRole.values.map((r) => AssignedRole.striker(role: r)).toList(),
};

({String label, String description}) roleDisplayInfo(AssignedRole role) {
  String title(String enumName) {
    final spaced = enumName.replaceAllMapped(
      RegExp('([a-z0-9])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    );
    return spaced[0].toUpperCase() + spaced.substring(1).toLowerCase();
  }

  return role.when(
    gk: (r) => (label: title(r.name), description: r.description),
    cb: (r) => (label: title(r.name), description: r.description),
    fullBack: (r) => (label: title(r.name), description: r.description),
    wingBack: (r) => (label: title(r.name), description: r.description),
    cdm: (r) => (label: title(r.name), description: r.description),
    cm: (r) => (label: title(r.name), description: r.description),
    cam: (r) => (label: title(r.name), description: r.description),
    winger: (r) => (label: title(r.name), description: r.description),
    striker: (r) => (label: title(r.name), description: r.description),
  );
}
