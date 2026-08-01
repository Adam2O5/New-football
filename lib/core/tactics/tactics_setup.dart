import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'tactics_setup.freezed.dart';
part 'tactics_setup.g.dart';

@freezed
class TacticsSetup with _$TacticsSetup {
  const factory TacticsSetup({
    @Default(Formation.f433) Formation formation,
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
