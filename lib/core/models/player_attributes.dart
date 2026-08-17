import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';

part 'player_attributes.freezed.dart';
part 'player_attributes.g.dart';

/// union of `FieldPlayerAttributes` and `GoalkeeperAttributes`
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.snake)
abstract class PlayerAttributes with _$PlayerAttributes {
  const factory PlayerAttributes.outfield({
    required FieldPlayerAttributes stats,
  }) = OutfieldPlayerAttributes;

  const factory PlayerAttributes.goalkeeper({
    required GoalkeeperAttributes stats,
  }) = GoalkeeperPlayerAttributes;

  factory PlayerAttributes.fromJson(Map<String, dynamic> json) =>
      _$PlayerAttributesFromJson(json);
}

extension PlayerAttributesX on PlayerAttributes {
  double overallForPosition(
    Position position, [
    BalanceConfig balance = BalanceConfig.defaults,
  ]) => map(
    outfield: (a) => a.stats.overallForPosition(position, balance),
    goalkeeper: (a) {
      if (position != Position.gk) {
        throw ArgumentError.value(
          position,
          'position',
          'Goalkeeper card attributes require Position.gk',
        );
      }
      return a.stats.overall;
    },
  );
}
