import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';

part 'field_player_attributes.freezed.dart';
part 'field_player_attributes.g.dart';

@freezed
class FieldPlayerAttributes with _$FieldPlayerAttributes {
  const factory FieldPlayerAttributes({
    required int pace,
    required int shooting,
    required int passing,
    required int dribbling,
    required int defending,
    required int physicality,
  }) = _FieldPlayerAttributes;

  factory FieldPlayerAttributes.fromJson(Map<String, dynamic> json) =>
      _$FieldPlayerAttributesFromJson(json);
}

extension FieldPlayerAttributesX on FieldPlayerAttributes {
  double get overall =>
      (pace + shooting + passing + dribbling + defending + physicality) / 6.0;

  /// Weighted position overall; weights from [BalanceConfig.player].
  double overallForPosition(
    Position position, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) {
    final w = balance.player.outfieldWeightsFor(position);
    return (pace * w.pace +
            shooting * w.shooting +
            passing * w.passing +
            dribbling * w.dribbling +
            defending * w.defending +
            physicality * w.physicality) /
        w.total;
  }
}
