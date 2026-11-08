import 'package:new_football/core/balance/tactics_balance.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'tactics_setup.freezed.dart';
part 'tactics_setup.g.dart';

@freezed
abstract class TacticsSetup with _$TacticsSetup {
  const factory TacticsSetup({
    @Default(Formation.f433) Formation formation,
    @Default(Tempo.balanced) Tempo tempo,
    @Default(AttackWidth.balanced) AttackWidth attackWidth,
    @Default(DefensiveLine.normal) DefensiveLine defensiveLine,
    @Default(PressingIntensity.medium) PressingIntensity pressing,
    @Default(TacticsBalance.defaultCornersAttack) int cornersAttack,
    @Default(TacticsBalance.defaultCornersDefense) int cornersDefense,
    @Default(TacticsBalance.defaultFreeKicks) int freeKicks,
    @Default(TacticsBalance.defaultPenalties) int penalties,
  }) = _TacticsSetup;

  factory TacticsSetup.fromJson(Map<String, dynamic> json) =>
      _$TacticsSetupFromJson(json);
}
