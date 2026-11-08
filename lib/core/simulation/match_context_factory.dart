import 'package:new_football/core/balance/balance_config.dart';
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
    CalendarService? calendar,
    this.balance = BalanceConfig.defaults,
    Set<String>? rivalryKeys,
  }) : _calendar = calendar,
       _rivalryKeys = rivalryKeys;

  final BalanceConfig balance;
  final Set<String>? _rivalryKeys;
  final CalendarService? _calendar;
  CalendarService get calendar =>
      _calendar ?? CalendarService(balance: balance);

  /// Explicit keys override the configured catalog, including an empty set.
  Set<String> get rivalryKeys => _rivalryKeys ?? balance.matchday.rivalryKeys;

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
    var refereeStrictness =
        balance.matchday.refereeRandomMin +
        rng.nextDouble() * balance.matchday.refereeRandomSpan;
    if (stake == MatchStake.playoff) {
      refereeStrictness *= balance.matchday.playoffRefereeMultiplier;
    }
    refereeStrictness = refereeStrictness
        .clamp(balance.matchday.refereeMin, balance.matchday.refereeMax)
        .toDouble();

    final derby = isDerby(home, away);
    final homeForm =
        TeamManagementService.teamForm(home.recentMatchResults, balance) * 100;
    final crowdIntensity =
        (balance.matchday.crowdBase +
                homeForm * balance.matchday.crowdFormWeight +
                _stakeCrowdBonus(stake) +
                (derby ? balance.matchday.crowdDerbyBonus : 0))
            .clamp(balance.matchday.crowdMin, balance.matchday.crowdMax)
            .round();

    return MatchContext(
      homeAdvantage: balance.matchday.homeAdvantage,
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

  bool isDerby(Team home, Team away) =>
      home.id != away.id && rivalryKeys.contains(rivalryKey(home.id, away.id));

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

  Weather _weatherForWeek(Random rng, int week) {
    final weights = Map<Weather, int>.of(balance.matchday.weatherBaseWeights);
    final season = _seasonForWeek(week);
    if (season != null) {
      for (final entry in season.deltas.entries) {
        weights.update(
          entry.key,
          (value) => season.minimums.containsKey(entry.key)
              ? max(season.minimums[entry.key]!, value + entry.value)
              : value + entry.value,
        );
      }
    }

    final total = weights.values.fold<int>(0, (sum, value) => sum + value);
    var roll = rng.nextInt(total);
    for (final entry in weights.entries) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }
    return Weather.clear;
  }

  WeatherSeasonProfile? _seasonForWeek(int week) {
    for (final season in balance.matchday.weatherSeasons) {
      if (season.contains(week)) return season;
    }
    return null;
  }

  int _temperatureForWeek(Random rng, int week) {
    final b = balance.matchday;
    final raw = b.temperatureMin + rng.nextInt(b.temperatureRandomRange);
    final seasonalBias = _seasonForWeek(week)?.temperatureBias ?? 0;
    return (raw + seasonalBias).clamp(b.temperatureMin, b.temperatureMax);
  }

  int _stakeCrowdBonus(MatchStake stake) =>
      balance.matchday.stakeCrowdBonuses[stake] ?? 0;
}
