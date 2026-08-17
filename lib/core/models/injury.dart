import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'injury.freezed.dart';
part 'injury.g.dart';

/// Canonical active injury state persisted with a player.
@freezed
abstract class Injury with _$Injury {
  const factory Injury({
    required String id,
    required InjuryGroup group,
    required InjuryType type,
    required int daysTotal,
    required int daysRemaining,
  }) = _Injury;

  factory Injury.fromJson(Map<String, dynamic> json) => _$InjuryFromJson(json);
}

extension InjuryX on Injury {
  bool get isActive => daysRemaining > 0;
}
