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
