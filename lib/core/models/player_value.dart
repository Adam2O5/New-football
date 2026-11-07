import 'package:new_football/core/balance/balance_config.dart';

/// Shared estimated salary base used by player point value and AI contract
/// drag. This is intentionally independent from ContractService.expectedSalary:
/// the latter is a negotiation offer, while this is an objective asset-value
/// anchor.
double estimatedSalaryForOverall(
  double overall, [
  BalanceConfig balance = BalanceConfig.defaults,
]) {
  final b = balance.tradeValue;
  final minSalary = b.assetSalaryMin;
  final maxSalary = b.assetSalaryMax;
  final ovrNorm =
      ((overall - b.assetSalaryOvrBase) *
              b.assetSalaryOvrScale /
              b.assetSalaryOvrDivisor)
          .clamp(0.0, 1.0)
          .toDouble();
  return minSalary + (maxSalary - minSalary) * (ovrNorm * ovrNorm * ovrNorm);
}
