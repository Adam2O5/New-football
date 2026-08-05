/// Helper model for displaying lottery odds in the UI.
class LotteryTeamOdds {
  const LotteryTeamOdds({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.oddsPercent,
  });

  /// Position among lottery teams (1 = worst record, highest odds)
  final int rank;

  /// Team identifier
  final String teamId;

  /// Display name of the team
  final String teamName;

  /// Percentage chance of getting pick #1
  final double oddsPercent;
}
