import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'contract.freezed.dart';
part 'contract.g.dart';

@freezed
abstract class Contract with _$Contract {
  const factory Contract({
    required int salary,
    required int yearsRemaining,
    @Default(false) bool hasBirdRights,
    @Default(false) bool isRookieScale,
    @Default(0) int rookiePickSlot,
    CapExceptionType? exceptionType,
    @Default(false) bool noTradeClause,
    @Default([]) List<String> blockedTeamIds,
  }) = _Contract;

  factory Contract.fromJson(Map<String, dynamic> json) =>
      _$ContractFromJson(json);
}

@freezed
abstract class CapException with _$CapException {
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
abstract class TeamFinance with _$TeamFinance {
  const factory TeamFinance({
    @Default(350000000) int salaryCap,
    @Default(396700000) int firstApron,
    @Default(431700000) int secondApron,
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
    switch (exception) {
      case CapExceptionType.midLevelException:
        return midLevelExceptionAvailable && salary <= midLevelExceptionAmount;
      case CapExceptionType.tradedPlayerException:
        return activeExceptions.any(
          (e) => e.type == exception && e.amountRemaining >= salary,
        );
      case CapExceptionType.birdRights:
      case CapExceptionType.rookieScale:
      case CapExceptionType.rookieExtension:
      case CapExceptionType.qualifyingOffer:
      case CapExceptionType.fullBirdRights:
      case CapExceptionType.earlyBirdRights:
      case CapExceptionType.nonBirdRights:
      case CapExceptionType.veteranExtensionRaiseCap:
        // Player-specific eligibility and limits are enforced by
        // SalaryCapService/ContractService; TeamFinance only answers whether
        // a named exception path is available in principle.
        return true;
    }
  }
}
