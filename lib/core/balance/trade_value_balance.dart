/// Zakres wartości handlowej dla rundy draftu (`trade_rules.md`).
class RoundTradeValueRange {
  const RoundTradeValueRange({required this.valueLow, required this.valueHigh});

  final int valueLow;
  final int valueHigh;
}

/// Wspólna konfiguracja wyceny handlowej zawodników i picków draftowych.
/// Wartości wstępne (bblm26-like) — do dostrojenia po testach balansu.
class TradeValueBalance {
  const TradeValueBalance({
    this.ntcAssetMultiplier = 0.75,
    this.pointOvrBase = 70,
    this.pointOvrWeight = 30,
    this.pointPotentialGapMax = 50,
    this.pointYoungAgeMax = 26,
    this.pointYoungAgeStart = 18,
    this.pointYoungFactorBase = 4.5,
    this.pointYoungFactorDecay = 0.5,
    this.pointYoungPotentialWeight = 4.5,
    this.pointOlderAgeMin = 27,
    this.pointOlderFactorBase = 0.8,
    this.pointOlderFactorDecay = 0.08,
    this.pointOlderFactorMin = 0.15,
    this.pointAgePeakMax = 24,
    this.pointAgeDeclineMin = 34,
    this.pointAgeWeight = 150,
    this.pointContractWeight = 260,
    this.pointContractBase = 0.5,
    this.pointContractLengthWeight = 0.5,
    this.pointMin = -1000,
    this.pointMax = 1000,
    this.potentialOvrTable = const [
      (0.5, 52.5),
      (1.0, 58.0),
      (1.5, 63.0),
      (2.0, 68.0),
      (2.5, 73.0),
      (3.0, 78.0),
      (3.5, 82.5),
      (4.0, 86.5),
      (4.5, 90.5),
      (5.0, 96.0),
    ],
    this.assetSalaryMin = 1000000.0,
    this.assetSalaryMax = 60000000.0,
    this.assetSalaryOvrBase = 50.0,
    this.assetSalaryOvrScale = 2.0,
    this.assetSalaryOvrDivisor = 100.0,
    this.contractLengthCap = 5,
    this.roundRanges = _defaultRoundRanges,
    this.yearsDecayPerYear = 0.12,
    this.minTimeDiscount = 0.35,
    this.leagueTeamsCount = 30,
  });

  final double ntcAssetMultiplier;
  final double pointOvrBase;
  final double pointOvrWeight;
  final double pointPotentialGapMax;
  final int pointYoungAgeMax;
  final int pointYoungAgeStart;
  final double pointYoungFactorBase;
  final double pointYoungFactorDecay;
  final double pointYoungPotentialWeight;
  final int pointOlderAgeMin;
  final double pointOlderFactorBase;
  final double pointOlderFactorDecay;
  final double pointOlderFactorMin;
  final int pointAgePeakMax;
  final int pointAgeDeclineMin;
  final double pointAgeWeight;
  final double pointContractWeight;
  final double pointContractBase;
  final double pointContractLengthWeight;
  final int pointMin;
  final int pointMax;
  final List<(double starsMax, double ovr)> potentialOvrTable;
  final double assetSalaryMin;
  final double assetSalaryMax;
  final double assetSalaryOvrBase;
  final double assetSalaryOvrScale;
  final double assetSalaryOvrDivisor;

  double ceilingOvrForStars(double stars) {
    for (final (starsMax, ovr) in potentialOvrTable) {
      if (stars <= starsMax) return ovr;
    }
    return potentialOvrTable.last.$2;
  }

  /// Liczba lat pozostałych kontraktu, przy której mnożnik długości
  /// osiąga 1.0 (dłuższy kontrakt nie daje dodatkowego bonusu).
  final int contractLengthCap;

  /// Pasma wartości picka draftowego wg rundy.
  final Map<int, RoundTradeValueRange> roundRanges;

  /// Dyskonto wartości picka za każdy rok odległości w czasie (im dalej w
  /// przyszłość, tym mniejsza pewność co do wartości picka).
  final double yearsDecayPerYear;

  /// Dolna granica dyskonta czasowego (pick nigdy nie traci więcej niż to).
  final double minTimeDiscount;

  final int leagueTeamsCount;

  static const _defaultRoundRanges = <int, RoundTradeValueRange>{
    1: RoundTradeValueRange(valueLow: 550, valueHigh: 900),
    2: RoundTradeValueRange(valueLow: 250, valueHigh: 450),
    3: RoundTradeValueRange(valueLow: 0, valueHigh: 200),
  };

  /// Pasmo wartości dla danej rundy draftu. Rundy spoza mapy (nie powinny
  /// wystąpić — draft ma 3 rundy) spadają do pasma rundy 3.
  RoundTradeValueRange rangeForRound(int round) =>
      roundRanges[round] ?? roundRanges[3]!;

  /// Temporary bridge until Task 32 wires [expectedRank] from the league
  /// strength table into pick valuation. When supplied, the rank is clamped
  /// to the valid league range; otherwise the deterministic first-place
  /// fallback preserves the existing valuation contract.
  int projectedFinish(String teamId, {int? expectedRank}) {
    if (expectedRank == null) return 1;
    return expectedRank.clamp(1, leagueTeamsCount).toInt();
  }
}
