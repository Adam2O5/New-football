import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';

/// Whether a natural position fits the assigned role's position group.
/// Left/right counterparts share a role group; formation-slot matching is
/// separate and may require an exact position.
bool positionFitsRole(Position position, AssignedRole role) => role.map(
  gk: (_) => position == Position.gk,
  cb: (_) => position == Position.cb,
  fullBack: (_) => position == Position.lb || position == Position.rb,
  wingBack: (_) => position == Position.lwb || position == Position.rwb,
  cdm: (_) => position == Position.cdm,
  cm: (_) => position == Position.cm,
  cam: (_) => position == Position.cam,
  winger: (_) => position == Position.lw || position == Position.rw,
  striker: (_) => position == Position.st,
);
