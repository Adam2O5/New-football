part of 'season_service.dart';

mixin _SeasonLottery on _SeasonServiceShared {
  LeagueState runLottery(LeagueState league, {int saveSeed = 0}) {
    final lottery = _computeLotteryResults(league, saveSeed: saveSeed);
    final drafted = DraftService(
      random: _random,
    ).buildDraftOrder(league, lottery, saveSeed: saveSeed);
    final state = drafted.copyWith(
      currentSeason: drafted.currentSeason.copyWith(
        phase: SeasonPhase.offseason,
      ),
    );
    final first = lottery.where((l) => l.assignedPick == 1).first;
    return _msg(
      state,
      MessageType.lottery,
      'Loteria draftu',
      'Pick 1: ${_teamName(state, first.teamId)}',
      args: {'teamName': _teamName(state, first.teamId), 'pickNumber': 1},
      urgent: true,
    );
  }

  List<LotteryResult> _computeLotteryResults(
    LeagueState league, {
    required int saveSeed,
  }) {
    final all = <Standing>[];
    for (final cs in league.currentSeason.standings) {
      all.addAll(cs.standings);
    }
    all.sort((a, b) {
      final pts = a.points.compareTo(b.points);
      if (pts != 0) return pts;
      return a.goalDifference.compareTo(b.goalDifference);
    });
    return LotteryService.computeResults(
      all,
      saveSeed: saveSeed,
      seasonYear: league.currentSeason.year,
    );
  }
}
