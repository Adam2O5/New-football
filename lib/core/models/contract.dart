import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'contract.freezed.dart';
part 'contract.g.dart';

@freezed
class Contract with _$Contract {
  const factory Contract({
    required int salary,
    required int yearsRemaining,
    @Default(false) bool hasBirdRights,
    @Default(false) bool isRookieScale,
    @Default(0) int rookiePickSlot,
    @Default(false) bool noTradeClause,
    @Default([]) List<String> blockedTeamIds,
  }) = _Contract;

  factory Contract.fromJson(Map<String, dynamic> json) =>
      _$ContractFromJson(json);
}

@freezed
class CapException with _$CapException {
  const factory CapException({
    required CapExceptionType type,
    required int amountRemaining,
    required String playerId,
    int? expiryYear,
  }) = _CapException;

  factory CapException.fromJson(Map<String, dynamic> json) =>
      _$CapExceptionFromJson(json);
}

@freezed
class TeamFinance with _$TeamFinance {
  const factory TeamFinance({
    @Default(300000000) int salaryCap,
    @Default(0) int totalPayroll,
    @Default([]) List<CapException> activeExceptions,
    @Default(20400000) int midLevelExceptionAmount,
    @Default(true) bool midLevelExceptionAvailable,
    @Default(75000000) int cashBalance,
  }) = _TeamFinance;

  factory TeamFinance.fromJson(Map<String, dynamic> json) =>
      _$TeamFinanceFromJson(json);
}

extension TeamFinanceX on TeamFinance {
  int get capSpace => salaryCap - totalPayroll;

  bool canSignPlayer(int salary, {CapExceptionType? exception}) {
    if (totalPayroll + salary <= salaryCap) return true;
    if (exception == null) return false;
    return activeExceptions.any(
      (e) => e.type == exception && e.amountRemaining >= salary,
    );
  }
}
