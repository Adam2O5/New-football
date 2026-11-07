/// Per-club knowledge. Public draft-board noise belongs to DraftBalance.
class ScoutingBalance {
  const ScoutingBalance({
    this.earlyMockNoiseMin = 10,
    this.earlyMockNoiseMax = 15,
    this.finalMockNoiseBase = 25,
    this.finalMockNoisePerStar = 4,
    this.finalMockNoiseMin = 5,
    this.finalMockNoiseMax = 25,
  });

  final int earlyMockNoiseMin;
  final int earlyMockNoiseMax;
  final int finalMockNoiseBase;
  final int finalMockNoisePerStar;
  final int finalMockNoiseMin;
  final int finalMockNoiseMax;
}
