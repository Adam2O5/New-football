@Tags(['slow', 'benchmark'])
@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/game_factory.dart';

/// Guards the save payload against the regression that made mid-season saves
/// grow to ~200 MB: a stored `MatchResult` used to carry full `Player` objects
/// for both lineups and both squad snapshots, i.e. ~58 players per fixture.
///
/// A full regular season is 870 fixtures. Rather than simulating all of them
/// (tens of minutes of match engine), this simulates four weeks and projects
/// the season total from the measured per-fixture cost — the per-fixture size
/// is exactly what regressed, so bounding it bounds the season.
void main() {
  const seed = 4242;
  const playerTeamId = 'team_europe_0';
  const seasonFixtures = 870;
  const simulatedDays = 28;

  /// Serialized bytes of the compact JSON actually written to disk.
  int compactBytes(Object? json) => utf8.encode(jsonEncode(json)).length;

  /// Every place a `MatchResult` outlives its match and reaches the save file.
  List<MatchResult> storedResults(LeagueState league) {
    final season = league.currentSeason;
    return [
      for (final match in season.schedule)
        if (match.result != null) match.result!,
      for (final match in season.postseasonFixtures)
        if (match.result != null) match.result!,
      for (final bracket in season.playoffBrackets)
        for (final series in [
          ...bracket.quarterFinals,
          ...bracket.semiFinals,
          ...bracket.conferenceFinal,
          if (bracket.leagueFinal != null) bracket.leagueFinal!,
        ])
          ...series.games,
      for (final playIn in season.playInResults)
        ...[playIn.game7v8, playIn.game9v10, playIn.gameFinal],
      for (final playIn in season.playInProgress)
        ...[
          playIn.game7v8,
          playIn.game9v10,
          playIn.gameFinal,
        ].whereType<MatchResult>(),
    ];
  }

  late GameSave game;
  late LeagueState league;
  late Map<String, int> millisByDayKind;

  setUpAll(() {
    game = GameFactory().create(
      const NewGameRequest(
        saveName: 'SizeGuard',
        playerTeamId: playerTeamId,
        seed: seed,
      ),
    );

    // Advances the calendar headlessly. The player's own fixture is simulated
    // like an AI one so the loop never stops for matchday UI, and interactive
    // calendar events are auto-resolved.
    final sim = DaySimulator();
    const calendar = CalendarService();
    league = game.leagueState;
    millisByDayKind = <String, int>{};

    for (var i = 0; i < simulatedDays; i++) {
      final week = league.currentWeek;
      final day = league.currentDay;
      final kind = day == 7
          ? 'weekBoundary'
          : calendar.isActualMatchDay(week, day)
          ? 'matchDay'
          : 'plainDay';

      final watch = Stopwatch()..start();
      final result = sim.simulateDay(
        league,
        saveSeed: game.saveSeed,
        simulatePlayerMatch: true,
      );
      watch.stop();
      millisByDayKind[kind] =
          (millisByDayKind[kind] ?? 0) + watch.elapsedMilliseconds;

      league = result.league;
      final eventId = result.eventId;
      if (eventId != null) {
        league = sim.resolveCalendarEvent(
          league,
          eventId,
          saveSeed: game.saveSeed,
        );
      }
    }
  });

  test('stored fixtures never persist per-match rosters or event feeds', () {
    final results = storedResults(league);
    expect(
      results,
      isNotEmpty,
      reason: '$simulatedDays days should have resolved fixtures',
    );

    for (final result in results) {
      expect(result.homeLineup, isEmpty, reason: 'homeLineup must be stripped');
      expect(result.awayLineup, isEmpty, reason: 'awayLineup must be stripped');
      expect(result.homeSnapshot.startingXi, isEmpty);
      expect(result.homeSnapshot.bench, isEmpty);
      expect(result.awaySnapshot.startingXi, isEmpty);
      expect(result.awaySnapshot.bench, isEmpty);
      expect(result.playerStats, isEmpty);
      expect(result.events, isEmpty);
      expect(result.injuries, isEmpty);
      expect(result.disciplines, isEmpty);
    }
  });

  test('projected full-season save stays within its size budget', () {
    final results = storedResults(league);
    final fixtureBytes = results.map(compactBytes).toList();
    final largestFixture = fixtureBytes.reduce((a, b) => a > b ? a : b);
    final averageFixture =
        fixtureBytes.reduce((a, b) => a + b) ~/ fixtureBytes.length;

    final measuredBytes = compactBytes(
      game.copyWith(leagueState: league).toJson(),
    );
    // The season adds the remaining fixtures on top of what is already stored.
    final projectedBytes =
        measuredBytes + (seasonFixtures - results.length) * averageFixture;

    // ignore: avoid_print
    print(
      'save size guard: measured=${measuredBytes ~/ 1024} KiB '
      'projectedSeason=${projectedBytes ~/ 1024} KiB '
      'fixtures=${results.length} '
      'avgFixture=$averageFixture B maxFixture=$largestFixture B '
      'timings=$millisByDayKind',
    );

    // A slim fixture is a couple of identifiers, two tactic setups and two
    // team stat lines. Before the optimization this was ~120 KB compact,
    // which put the season schedule alone above 100 MB.
    expect(
      largestFixture,
      lessThan(4 * 1024),
      reason: 'largest stored fixture was $largestFixture B',
    );
    expect(
      projectedBytes,
      lessThan(10 * 1024 * 1024),
      reason: 'projected season save was ${projectedBytes ~/ 1024} KiB',
    );
  });
}
