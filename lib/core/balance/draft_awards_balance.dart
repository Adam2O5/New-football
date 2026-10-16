class DraftBalance {
  const DraftBalance({
    this.classSize = 120,
    this.rounds = 3,
    this.teams = 30,
    this.lotteryTeams = 10,
    this.prospectAgeMin = 18,
    this.prospectAgeMax = 20,
    this.mockEarlyNoiseMin = 10,
    this.mockEarlyNoiseMax = 15,
    this.mockMidNoiseMin = 15,
    this.mockMidNoiseMax = 22,
    this.mockLateNoiseMin = 25,
    this.mockLateNoiseMax = 30,
    this.mockFinalEarlyNoiseMin = 8,
    this.mockFinalEarlyNoiseMax = 12,
    this.mockFinalMidNoiseMin = 12,
    this.mockFinalMidNoiseMax = 18,
    this.mockFinalLateNoiseMin = 18,
    this.mockFinalLateNoiseMax = 25,
  });

  final int classSize;
  final int rounds;
  final int teams;
  final int lotteryTeams;
  final int prospectAgeMin;
  final int prospectAgeMax;

  final int mockEarlyNoiseMin;
  final int mockEarlyNoiseMax;
  final int mockMidNoiseMin;
  final int mockMidNoiseMax;
  final int mockLateNoiseMin;
  final int mockLateNoiseMax;

  final int mockFinalEarlyNoiseMin;
  final int mockFinalEarlyNoiseMax;
  final int mockFinalMidNoiseMin;
  final int mockFinalMidNoiseMax;
  final int mockFinalLateNoiseMin;
  final int mockFinalLateNoiseMax;

  int get picksPerDraft => teams * rounds;

  /// Lottery weights for ranks 1–10 among lottery teams (worst first).
  static const lotteryWeights = <int>[
    140,
    140,
    140,
    125,
    105,
    90,
    75,
    60,
    45,
    30,
  ];
}

class AwardsBalance {
  const AwardsBalance({
    this.regularSeasonGames = 58,
    this.minutesPerGame = 90,
    this.mvpMinutesPct = 0.40,
    this.dpoyMinutesPct = 0.40,
    this.bestGkMinutesPct = 0.40,
    this.scoringTitleMinutesPct = 0.30,
    this.assistTitleMinutesPct = 0.30,
    this.totsSlotMinutesPct = 0.30,
    this.rotyMinutesPct = 0.25,
  });

  final int regularSeasonGames;
  final int minutesPerGame;
  final double mvpMinutesPct;
  final double dpoyMinutesPct;
  final double bestGkMinutesPct;
  final double scoringTitleMinutesPct;
  final double assistTitleMinutesPct;
  final double totsSlotMinutesPct;
  final double rotyMinutesPct;

  int get possibleMinutes => regularSeasonGames * minutesPerGame;
}
