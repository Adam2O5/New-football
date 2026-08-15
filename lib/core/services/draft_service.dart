import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'dart:math';

/// Service odpowiedzialny za budowanie kolejności draftu na podstawie
/// wyników loterii. Wywoływany po zakończeniu interaktywnej loterii
/// na `LotteryScreen`.
class DraftService {
  DraftService({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Buduje pełny `DraftState` (kolejność 3 rund × 30 picków) na
  /// podstawie [lotteryResults] i aktualnego stanu [league].
  ///
  /// Zwraca zaktualizowany [LeagueState] z ustawionym `draftState` oraz
  /// skonsumowanymi pickami usuniętymi z `ownedPicks` drużyn.
  LeagueState buildDraftOrder(
    LeagueState league,
    List<LotteryResult> lotteryResults,
  ) {
    final currentYear = league.currentSeason.year;
    final (order, consumedPickIds) = _buildDraftOrder(
      league,
      lotteryResults,
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

    final existingClass = league.currentSeason.draftState?.draftClass;
    final draftClass = existingClass ??
        SeedDataGenerator(
          random: _random,
        ).generateDraftClass(year: currentYear);

    final draftState = DraftState(
      year: currentYear,
      order: order,
      lotteryResults: lotteryResults,
      draftClass: draftClass,
    );

    return league.copyWith(
      teams: teams,
      currentSeason: league.currentSeason.copyWith(
        draftState: draftState,
      ),
    );
  }

  /// Buduje kolejność draftu (3 rundy × 30 drużyn) na podstawie wyników
  /// loterii i tabeli ligowej. Zwraca listę picków oraz zbiór id
  /// skonsumowanych picków z `ownedPicks`.
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
