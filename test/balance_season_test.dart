import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/engine/match_engine.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/game_factory.dart';

/// Lightweight multi-season balance smoke test (Etap 6).
void main() {
  test('full regular season sim produces sensible standings', () {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Balance',
        playerTeamId: 'team_east_0',
        seed: 123,
      ),
    );
    // Treat player team as AI for bulk sim.
    var league = game.leagueState;
    const engine = MatchEngine();

    for (final match in league.currentSeason.schedule) {
      if (match.result != null) continue;
      final home = league.teamById(match.homeTeamId)!;
      final away = league.teamById(match.awayTeamId)!;
      final result = engine.simulateFull(
        home: home,
        away: away,
        rngSeed: Object.hash(match.id, 123),
      );
      final newSchedule = league.currentSeason.schedule
          .map((m) => m.id == match.id ? m.copyWith(result: result) : m)
          .toList();
      final standings = league.currentSeason.standings.map((cs) {
        final updated = cs.standings.map((s) {
          if (s.teamId == result.homeTeamId) {
            return s.applyResult(
              goalsFor: result.homeGoals,
              goalsAgainst: result.awayGoals,
            );
          }
          if (s.teamId == result.awayTeamId) {
            return s.applyResult(
              goalsFor: result.awayGoals,
              goalsAgainst: result.homeGoals,
            );
          }
          return s;
        }).toList();
        return cs.copyWith(standings: updated);
      }).toList();
      league = league.copyWith(
        currentSeason: league.currentSeason.copyWith(
          schedule: newSchedule,
          standings: standings,
        ),
      );
    }

    for (final cs in league.currentSeason.standings) {
      final sorted = cs.sorted;
      expect(sorted.length, 15);
      expect(sorted.first.points, greaterThan(sorted.last.points));
      for (final s in sorted) {
        expect(s.gamesPlayed, 58);
        expect(s.goalsFor, greaterThan(0));
      }
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
