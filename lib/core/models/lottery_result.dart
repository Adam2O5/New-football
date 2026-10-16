import 'package:freezed_annotation/freezed_annotation.dart';

part 'lottery_result.freezed.dart';
part 'lottery_result.g.dart';

@freezed
abstract class LotteryResult with _$LotteryResult {
  const factory LotteryResult({
    required String teamId,
    required int originalRank,
    required int assignedPick,
    required double oddsForFirstPick,
  }) = _LotteryResult;

  factory LotteryResult.fromJson(Map<String, dynamic> json) =>
      _$LotteryResultFromJson(json);
}
