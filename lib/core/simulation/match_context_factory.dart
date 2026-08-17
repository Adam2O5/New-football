import 'dart:math';

import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/services/team_management_service.dart';

/// Builds the immutable, deterministic context shared by every match entry
/// point. It deliberately owns no calendar state and never mutates a league.
class MatchContextFactory {
  const MatchContextFactory({
    this.calendar = const CalendarService(),
    this.rivalryKeys = const {},
  });

  final CalendarService calendar;

  /// Canonical keys may be supplied as `teamA|teamB` (order-independent), or
  /// as the legacy `teamA:teamB` spelling. Cross-conference pairs are never
  /// considered derbies, even when a key is present.
  final Set<String> rivalryKeys;

  MatchContext create({
    required LeagueState league,
    required ScheduledMatch match,
    required int saveSeed,
    MatchStake stake = MatchStake.regular,
    int? week,
    int? day,
  }) {
    final resolved = _weekAndSlot(
      match.round,
      fallbackWeek: week ?? league.currentWeek,
    );
    final resolvedWeek = week ?? resolved.week;
    final slot = resolved.slot;
    // Resolve the canonical match day through CalendarService so callers that
    // need it cannot accidentally invent a second calendar mapping. The day is
    // not persisted in MatchContext; the fixture's round remains authoritative.
    if (day == null && calendar.isRegularSeasonWeek(resolvedWeek)) {
      matchDaysForWeek(resolvedWeek, seed: saveSeed);
    }

    final home = league.teamById(match.homeTeamId);
    final away = league.teamById(match.awayTeamId);
    if (home == null || away == null) {
      throw StateError(
        'Cannot build match context for ${match.homeTeamId} vs ${match.awayTeamId}',
      );
    }

    return createForTeams(
      home: home,
      away: away,
      seasonYear: league.currentSeason.year,
      matchId: match.id,
      saveSeed: saveSeed,
      stake: stake,
      week: resolvedWeek,
      homeMatchInWeek: slot == null ? null : slot + 1,
      awayMatchInWeek: slot == null ? null : slot + 1,
    );
  }

  MatchContext createForTeams({
    required Team home,
    required Team away,
    required int seasonYear,
    required String matchId,
    required int saveSeed,
    MatchStake stake = MatchStake.regular,
    int week = 1,
    int? homeMatchInWeek,
    int? awayMatchInWeek,
  }) {
    final seed = matchSeed(saveSeed, seasonYear, matchId);
    final rng = Random(seed);
    final weather = _weatherForWeek(rng, week);
    final temperatureC = _temperatureForWeek(rng, week);
    var refereeStrictness = 0.80 + rng.nextDouble() * 0.40;
    if (stake == MatchStake.playoff) {
      refereeStrictness *= 0.95;
    }
    refereeStrictness = refereeStrictness.clamp(0.80, 1.20).toDouble();

    final derby = isDerby(home, away);
    final homeForm =
        TeamManagementService.teamForm(home.recentMatchResults) * 100;
    final crowdIntensity =
        (45 + homeForm * 0.3 + _stakeCrowdBonus(stake) + (derby ? 20 : 0))
            .clamp(0, 100)
            .round();

    return MatchContext(
      homeTeamId: home.id,
      awayTeamId: away.id,
      weather: weather,
      temperatureC: temperatureC,
      isDerby: derby,
      stake: stake,
      refereeStrictness: refereeStrictness,
      crowdIntensity: crowdIntensity,
      homeMatchInWeek: _matchInWeek(homeMatchInWeek),
      awayMatchInWeek: _matchInWeek(awayMatchInWeek),
      seed: seed,
    );
  }

  /// Explicit helper for play-in/playoff games that do not have a regular
  /// season [ScheduledMatch] row.
  MatchContext createForPostseason({
    required Team home,
    required Team away,
    required int seasonYear,
    required String matchId,
    required int saveSeed,
    required MatchStake stake,
    int week = 1,
    int? homeMatchInWeek,
    int? awayMatchInWeek,
  }) => createForTeams(
    home: home,
    away: away,
    seasonYear: seasonYear,
    matchId: matchId,
    saveSeed: saveSeed,
    stake: stake,
    week: week,
    homeMatchInWeek: homeMatchInWeek,
    awayMatchInWeek: awayMatchInWeek,
  );

  bool isDerby(Team home, Team away) {
    if (home.conference != away.conference) return false;
    final canonical = rivalryKey(home.id, away.id);
    if (rivalryKeys.contains(canonical) ||
        rivalryKeys.contains(rivalryKey(home.id, away.id, separator: ':'))) {
      return true;
    }
    return _defaultSeededRivalry(home.id, away.id);
  }

  static String rivalryKey(
    String first,
    String second, {
    String separator = '|',
  }) {
    final ids = [first, second]..sort();
    return '${ids[0]}$separator${ids[1]}';
  }

  ({int week, int? slot}) _weekAndSlot(int round, {required int fallbackWeek}) {
    try {
      final (week, slot) = weekSlotForRound(round);
      return (week: week, slot: slot);
    } on ArgumentError {
      return (week: fallbackWeek, slot: null);
    }
  }

  int _matchInWeek(int? value) => (value ?? 1).clamp(1, 3);

  bool _defaultSeededRivalry(String homeId, String awayId) {
    final home = _seededTeamParts(homeId);
    final away = _seededTeamParts(awayId);
    if (home == null || away == null || home.conference != away.conference) {
      return false;
    }
    final lower = min(home.index, away.index);
    final upper = max(home.index, away.index);
    return upper - lower == 1 && lower.isEven;
  }

  ({String conference, int index})? _seededTeamParts(String id) {
    final match = RegExp(r'^team_(.+)_(\d+)$').firstMatch(id);
    if (match == null) return null;
    return (conference: match.group(1)!, index: int.parse(match.group(2)!));
  }

  Weather _weatherForWeek(Random rng, int week) {
    final weights = <Weather, int>{
      Weather.clear: 24,
      Weather.overcast: 15,
      Weather.rain: 14,
      Weather.heavyRain: 8,
      Weather.wind: 10,
      Weather.snow: 5,
      Weather.heat: 10,
      Weather.cold: 14,
    };
    if (week <= 8) {
      weights
        ..update(Weather.heat, (value) => value + 22)
        ..update(Weather.clear, (value) => value + 8)
        ..update(Weather.snow, (value) => max(1, value - 4))
        ..update(Weather.cold, (value) => max(2, value - 8));
    } else if (week >= 17 && week <= 25) {
      weights
        ..update(Weather.snow, (value) => value + 22)
        ..update(Weather.cold, (value) => value + 18)
        ..update(Weather.heavyRain, (value) => value + 8)
        ..update(Weather.heat, (value) => max(1, value - 9));
    } else if (week >= 26 && week <= 34) {
      weights
        ..update(Weather.clear, (value) => value + 8)
        ..update(Weather.heat, (value) => value + 8)
        ..update(Weather.snow, (value) => max(1, value - 5));
    }

    final total = weights.values.fold<int>(0, (sum, value) => sum + value);
    var roll = rng.nextInt(total);
    for (final entry in weights.entries) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }
    return Weather.clear;
  }

  int _temperatureForWeek(Random rng, int week) {
    final raw = -5 + rng.nextInt(44);
    final seasonalBias = week <= 8
        ? 8
        : week >= 17 && week <= 25
        ? -8
        : 0;
    return (raw + seasonalBias).clamp(-5, 38);
  }

  int _stakeCrowdBonus(MatchStake stake) => switch (stake) {
    MatchStake.regular => 0,
    MatchStake.playIn => 10,
    MatchStake.playoff => 15,
    MatchStake.playoffElimination => 25,
    MatchStake.leagueFinal => 30,
  };
}
