/// Shared estimated salary base used by player point value and AI contract
/// drag. This is intentionally independent from ContractService.expectedSalary:
/// the latter is a negotiation offer, while this is an objective asset-value
/// anchor.
double estimatedSalaryForOverall(double overall) {
  const minSalary = 1000000.0;
  const maxSalary = 60000000.0;
  final ovrNorm = ((overall - 50.0) * 2.0 / 100.0).clamp(0.0, 1.0).toDouble();
  return minSalary + (maxSalary - minSalary) * (ovrNorm * ovrNorm * ovrNorm);
}
