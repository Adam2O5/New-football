import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/random/seeds.dart';

/// Builds the league-wide displayed draft board (`draft.md` §"Dwa mock
/// drafty"). This is distinct from `ScoutingService.runEarlyMock`/
/// `runFinalMock`, which compute a *per-team*, watchlist-only noisy estimate
/// (scaled by that team's scout Evaluation) used to reveal scouting-tier
/// evidence. This service instead ranks the *entire* draft class (all 120
/// prospects) once, for everyone, to decide display order in the Prospects
/// screen — noise here depends only on true projected position, not on any
/// team's scouting quality.
class MockDraftService {
  MockDraftService({this.balance = BalanceConfig.defaults, Random? random})
    : _random = random ?? Random();

  final BalanceConfig balance;
  final Random _random;

  /// Hidden true ranking of the class: sorted by `potentialStars * OVR`,
  /// descending (best prospect first). Never shown to the player directly —
  /// only the noisy displayed board (below) is.
  List<Prospect> trueBoard(List<Prospect> prospects) {
    final sorted = [...prospects]
      ..sort((a, b) {
        final scoreA = a.potentialStars * a.projectedOverall(balance);
        final scoreB = b.potentialStars * b.projectedOverall(balance);
        final cmp = scoreB.compareTo(scoreA);
        return cmp != 0 ? cmp : a.id.compareTo(b.id); // stable tie-break
      });
    return sorted;
  }

  /// Mock wstępny — wieczór poniedziałku tyg. 46 (albo dzień 1 nowego save'a),
  /// tuż po wygenerowaniu klasy. Większa wariancja niż mock finalny
  /// (`balance.draft.mockEarlyNoiseMin/Max` itd.).
  /// `previousDisplayedRank` stays empty: there's nothing to compare against
  /// yet, so the UI shows no position-change indicator after this mock.
  MockDraftBoard generateInitialMock(
    List<Prospect> trueBoard, {
    int? seed,
    int seasonYear = 0,
  }) {
    return _generate(
      trueBoard,
      bandFor: _earlyMockBand,
      previous: const {},
      seed: seed,
      seasonYear: seasonYear,
      kind: 'mock-early',
    );
  }

  /// Mock finalny — piątek tyg. 45, tuż przed draftem. Mniejsza wariancja niż
  /// mock wstępny (`balance.draft.mockFinalEarlyNoiseMin/Max` itd.); ustala
  /// ostateczną kolejność tabeli prospectów w drafcie.
  /// `previous` is the board that was displayed until now (the initial
  /// mock, or a prior final mock for save-compatibility), so the UI can
  /// render the ▲/▼/⏸ indicator against it.
  MockDraftBoard generateFinalMock(
    List<Prospect> trueBoard,
    MockDraftBoard previous, {
    int? seed,
    int seasonYear = 0,
  }) {
    return _generate(
      trueBoard,
      bandFor: _finalMockBand,
      previous: previous.displayedRank,
      seed: seed,
      seasonYear: seasonYear,
      kind: 'mock-final',
    );
  }

  MockDraftBoard _generate(
    List<Prospect> trueBoard, {
    required (int min, int max) Function(int trueRankZeroBased) bandFor,
    required Map<String, int> previous,
    required int? seed,
    required int seasonYear,
    required String kind,
  }) {
    if (trueBoard.isEmpty) {
      return MockDraftBoard(previousDisplayedRank: previous);
    }
    final n = trueBoard.length;
    final trueIndexById = {for (var i = 0; i < n; i++) trueBoard[i].id: i};
    final scored = <(String id, double noisyScore)>[];
    for (var i = 0; i < n; i++) {
      final prospect = trueBoard[i];
      final (min, max) = bandFor(i);
      final random = _randomFor(
        seed: seed,
        seasonYear: seasonYear,
        kind: kind,
        prospectId: prospect.id,
      );
      final noise = min + random.nextInt(max - min + 1);
      final sign = random.nextBool() ? 1 : -1;
      scored.add((prospect.id, (i + sign * noise).toDouble()));
    }
    // Re-sort by noisy score to get a clean, gap-free displayed ranking —
    // ties broken by true rank so the order stays deterministic.
    scored.sort((a, b) {
      final cmp = a.$2.compareTo(b.$2);
      if (cmp != 0) return cmp;
      return trueIndexById[a.$1]!.compareTo(trueIndexById[b.$1]!);
    });

    return MockDraftBoard(
      displayedRank: {
        for (var i = 0; i < scored.length; i++) scored[i].$1: i + 1,
      },
      previousDisplayedRank: previous,
    );
  }

  /// "Top / wczesna R1" ≈ pierwsza połowa rundy 1 (`draft.md` nie podaje
  /// jawnej granicy); "Projected R3 / undrafted" = ostatnia runda + pula
  /// niedraftowanych (klasa − (rundy−1) × drużyny).
  int get _topBandSize => balance.draft.teams ~/ 2;
  int get _lowBandSize =>
      balance.draft.classSize -
      (balance.draft.rounds - 1) * balance.draft.teams;

  (int, int) _earlyMockBand(int trueRankZeroBased) {
    final d = balance.draft;
    if (trueRankZeroBased < _topBandSize) {
      return (d.mockEarlyNoiseMin, d.mockEarlyNoiseMax);
    }
    if (trueRankZeroBased < d.classSize - _lowBandSize) {
      return (d.mockMidNoiseMin, d.mockMidNoiseMax);
    }
    return (d.mockLateNoiseMin, d.mockLateNoiseMax);
  }

  (int, int) _finalMockBand(int trueRankZeroBased) {
    final d = balance.draft;
    if (trueRankZeroBased < _topBandSize) {
      return (d.mockFinalEarlyNoiseMin, d.mockFinalEarlyNoiseMax);
    }
    if (trueRankZeroBased < d.classSize - _lowBandSize) {
      return (d.mockFinalMidNoiseMin, d.mockFinalMidNoiseMax);
    }
    return (d.mockFinalLateNoiseMin, d.mockFinalLateNoiseMax);
  }

  Random _randomFor({
    required int? seed,
    required int seasonYear,
    required String kind,
    required String prospectId,
  }) {
    if (seed == null) return _random;
    return Random(draftEventSeed(seed, seasonYear, kind, prospectId));
  }
}
