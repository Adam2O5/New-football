part of 'season_service.dart';

mixin _SeasonLottery on _SeasonServiceShared {
  LeagueState runLottery(LeagueState league, {int saveSeed = 0}) {
    final lottery = _computeLotteryResults(league, saveSeed: saveSeed);
    final existingClass = league.currentSeason.draftState?.draftClass;
    final draftClass =
        existingClass ??
        SeedDataGenerator(
          random: _random,
        ).generateDraftClass(year: league.currentSeason.year, seed: saveSeed);
    final currentYear = league.currentSeason.year;
    final (order, consumedPickIds) = _buildDraftOrder(
      league,
      lottery,
      currentYear,
    );

    var teams = league.teams;
    if (consumedPickIds.isNotEmpty) {
      teams = teams.map((t) {
        if (!t.ownedPicks.any((p) => consumedPickIds.contains(p.id))) {
          return t;
        }
        return t.copyWith(
          ownedPicks: t.ownedPicks
              .where((p) => !consumedPickIds.contains(p.id))
              .toList(),
        );
      }).toList();
    }

    final draftState = DraftState(
      year: currentYear,
      order: order,
      lotteryResults: lottery,
      draftClass: draftClass,
    );
    var state = league.copyWith(
      teams: teams,
      currentSeason: league.currentSeason.copyWith(
        draftState: draftState,
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

  /// Buduje kolejność draftu na [currentYear]. Dla każdego slotu próbuje
  /// znaleźć pasujący, wcześniej wygenerowany `DraftPick`
  /// (`originalTeamId` + `year` + `round`) w puli którejkolwiek drużyny —
  /// tak materializuje się realny efekt handlu przyszłymi pickami
  /// (`Team.ownedPicks`, `docs/trade_rules.md`). Jeśli żadna drużyna nie
  /// posiada takiego picka (np. pierwszy sezon kariery — pick na rok
  /// bieżący nigdy nie został wstępnie wygenerowany), slot jest
  /// syntetyzowany na miejscu i przypisany drużynie oryginalnej.
  ///
  /// Zwraca zbudowaną kolejność oraz zbiór `id` picków skonsumowanych z
  /// `ownedPicks` — wywołujący (`runLottery`) musi je usunąć z odpowiednich
  /// drużyn.
  (List<DraftPick>, Set<String>) _buildDraftOrder(
    LeagueState league,
    List<LotteryResult> lottery,
    int currentYear,
  ) {
    final all = <Standing>[];
    for (final cs in league.currentSeason.standings) {
      all.addAll(cs.standings);
    }
    all.sort((a, b) {
      final pts = a.points.compareTo(b.points);
      if (pts != 0) return pts;
      return a.goalDifference.compareTo(b.goalDifference);
    });
    final lotteryIds = lottery.map((l) => l.teamId).toSet();
    final nonLottery = all
        .where((s) => !lotteryIds.contains(s.teamId))
        .toList()
        .reversed
        .toList();

    final r1 = <String>[
      ...lottery.map((l) => l.teamId),
      ...nonLottery.map((s) => s.teamId),
    ];
    while (r1.length < 30) {
      for (final s in all) {
        if (!r1.contains(s.teamId)) r1.add(s.teamId);
        if (r1.length >= 30) break;
      }
      if (r1.length < 30) break;
    }

    final consumed = <String>{};

    DraftPick? findOwnedPick(String originalTeamId, int round) {
      for (final t in league.teams) {
        for (final p in t.ownedPicks) {
          if (p.originalTeamId == originalTeamId &&
              p.year == currentYear &&
              p.round == round) {
            return p.copyWith(teamId: t.id);
          }
        }
      }
      return null;
    }

    DraftPick pickFor(String originalTeamId, int round, int overallPickNumber) {
      final owned = findOwnedPick(originalTeamId, round);
      if (owned != null) {
        consumed.add(owned.id);
        return owned.copyWith(pickNumber: overallPickNumber);
      }
      // Brak wstępnie wygenerowanego picka (typowo: pierwszy sezon kariery)
      // — syntetyzujemy slot na miejscu, przypisany oryginalnej drużynie.
      return DraftPick(
        id: 'draftpick_${currentYear}_${round}_$originalTeamId',
        year: currentYear,
        round: round,
        pickNumber: overallPickNumber,
        teamId: originalTeamId,
        originalTeamId: originalTeamId,
      );
    }

    final picks = <DraftPick>[];
    for (var round = 1; round <= 3; round++) {
      for (var i = 0; i < 30; i++) {
        final overallPickNumber = (round - 1) * 30 + i + 1;
        picks.add(pickFor(r1[i % r1.length], round, overallPickNumber));
      }
    }
    return (picks, consumed);
  }
}
