import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'tactics_setup.freezed.dart';
part 'tactics_setup.g.dart';

@freezed
class MidfieldSlots with _$MidfieldSlots {
  const factory MidfieldSlots({
    @Default(1) int cdm,
    @Default(1) int cm,
    @Default(1) int cam,
  }) = _MidfieldSlots;

  factory MidfieldSlots.fromJson(Map<String, dynamic> json) =>
      _$MidfieldSlotsFromJson(json);
}

extension MidfieldSlotsX on MidfieldSlots {
  int get totalSlots => cdm + cm + cam;
}

@freezed
class TacticsSetup with _$TacticsSetup {
  const factory TacticsSetup({
    @Default(Formation.f433) Formation formation,
    MidfieldSlots? midfieldSlots,
    @Default(Tempo.balanced) Tempo tempo,
    @Default(AttackWidth.balanced) AttackWidth attackWidth,
    @Default(DefensiveLine.normal) DefensiveLine defensiveLine,
    @Default(PressingIntensity.medium) PressingIntensity pressing,
    @Default(50) int cornersAttack,
    @Default(50) int cornersDefense,
    @Default(30) int freeKicks,
    @Default(80) int penalties,
  }) = _TacticsSetup;

  factory TacticsSetup.fromJson(Map<String, dynamic> json) =>
      _$TacticsSetupFromJson(json);
}
