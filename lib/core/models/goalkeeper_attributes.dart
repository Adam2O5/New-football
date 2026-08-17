import 'package:freezed_annotation/freezed_annotation.dart';

part 'goalkeeper_attributes.freezed.dart';
part 'goalkeeper_attributes.g.dart';

/// FUT goalkeeper face stats (DIV / HAN / KIC / REF / SPD / POS).
@freezed
abstract class GoalkeeperAttributes with _$GoalkeeperAttributes {
  const factory GoalkeeperAttributes({
    required int diving,
    required int handling,
    required int kicking,
    required int reflexes,
    required int speed,
    required int positioning,
  }) = _GoalkeeperAttributes;

  factory GoalkeeperAttributes.fromJson(Map<String, dynamic> json) =>
      _$GoalkeeperAttributesFromJson(json);
}

extension GoalkeeperAttributesX on GoalkeeperAttributes {
  double get overall =>
      (diving + handling + kicking + reflexes + speed + positioning) / 6.0;

  double get averageFut => overall;
}
