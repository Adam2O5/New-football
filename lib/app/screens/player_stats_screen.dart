import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/theme/app_theme.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

enum _StatsSort { ovr, goals, assists, rating, appearances }

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  _StatsSort _sort = _StatsSort.ovr;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final useLegacyColorTheme = ref.watch(legacyColorThemeSettingProvider);
    final branding = ref
        .watch(clubBrandingProvider)
        .resolve(league?.playerTeamId ?? '');

    if (league == null) {
      return _themed(
        useLegacyColorTheme,
        branding.primaryColor,
        branding.secondaryColor,
        Scaffold(
          appBar: _appBar(context, l10n),
          body: Center(child: Text(l10n.stats_noStats)),
        ),
      );
    }
    return _themed(
      useLegacyColorTheme,
      branding.primaryColor,
      branding.secondaryColor,
      DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.stats_title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            bottom: TabBar(
              tabs: [
                Tab(text: l10n.stats_players),
                Tab(text: l10n.stats_teamOverview),
              ],
            ),
          ),
          body: ScreenBackground(
            child: TabBarView(
              children: [
                _myTeamTab(context, l10n, league),
                _leagueTab(context, l10n, league),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _themed(
    bool useLegacyColorTheme,
    Color primary,
    Color secondary,
    Widget child,
  ) {
    if (useLegacyColorTheme) return child;
    return Theme(
      data: AppTheme.forClub(primary: primary, secondary: secondary),
      child: child,
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, AppLocalizations l10n) =>
      AppBar(title: Text(l10n.stats_title));

  Widget _myTeamTab(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final playerTeamId = league.playerTeamId;
    final team = playerTeamId == null ? null : league.teamById(playerTeamId);
    if (team == null) {
      return Center(child: Text(l10n.teamOverview_invalidTeam));
    }

    final aggregates = _aggregateStats(league);
    final players =
        [
          for (final player in team.roster)
            if (aggregates.containsKey(player.id))
              _PlayerStatsRow(player: player, stats: aggregates[player.id]!),
        ]..sort((a, b) {
          return switch (_sort) {
            _StatsSort.ovr => b.player.overall().compareTo(a.player.overall()),
            _StatsSort.goals => b.stats.goals.compareTo(a.stats.goals),
            _StatsSort.assists => b.stats.assists.compareTo(a.stats.assists),
            _StatsSort.rating => b.stats.ratingAvg.compareTo(a.stats.ratingAvg),
            _StatsSort.appearances => b.stats.appearances.compareTo(
              a.stats.appearances,
            ),
          };
        });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(l10n.stats_sort),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<_StatsSort>(
                isExpanded: true,
                value: _sort,
                items: [
                  DropdownMenuItem(
                    value: _StatsSort.ovr,
                    child: Text(l10n.stats_sortOvr),
                  ),
                  DropdownMenuItem(
                    value: _StatsSort.goals,
                    child: Text(l10n.stats_sortGoals),
                  ),
                  DropdownMenuItem(
                    value: _StatsSort.assists,
                    child: Text(l10n.stats_sortAssists),
                  ),
                  DropdownMenuItem(
                    value: _StatsSort.rating,
                    child: Text(l10n.stats_sortRating),
                  ),
                  DropdownMenuItem(
                    value: _StatsSort.appearances,
                    child: Text(l10n.stats_sortAppearances),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _sort = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (players.isEmpty)
          Card(child: ListTile(title: Text(l10n.stats_seasonNotStarted)))
        else
          ...players.map((row) => _playerTile(context, l10n, row)),
      ],
    );
  }

  Widget _playerTile(
    BuildContext context,
    AppLocalizations l10n,
    _PlayerStatsRow row,
  ) {
    final stats = row.stats;
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(row.player.position.code)),
        title: Text(row.player.name),
        subtitle: Text(
          '${l10n.stats_appearances}: ${stats.appearances} · '
          '${l10n.stats_goals}: ${stats.goals} · ${l10n.stats_assists}: ${stats.assists}',
        ),
        trailing: Text(
          '${l10n.stats_rating}: ${stats.ratingAvg.toStringAsFixed(2)}',
        ),
        onTap: () => context.push('/game/player/${row.player.id}'),
      ),
    );
  }

  Widget _leagueTab(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final rows = _leaguePlayerRows(league);

    final goalsRows = [...rows]
      ..sort((a, b) {
        final byGoals = b.stats.goals.compareTo(a.stats.goals);
        if (byGoals != 0) return byGoals;
        return b.stats.ratingAvg.compareTo(a.stats.ratingAvg);
      });
    final assistsRows = [...rows]
      ..sort((a, b) {
        final byAssists = b.stats.assists.compareTo(a.stats.assists);
        if (byAssists != 0) return byAssists;
        return b.stats.ratingAvg.compareTo(a.stats.ratingAvg);
      });
    final cleanSheetsRows = [...rows]
      ..sort((a, b) {
        final byCleanSheets = b.stats.cleanSheets.compareTo(
          a.stats.cleanSheets,
        );
        if (byCleanSheets != 0) return byCleanSheets;
        return b.stats.ratingAvg.compareTo(a.stats.ratingAvg);
      });
    final mvpRows = [...rows]
      ..sort((a, b) {
        final byMvp = b.mvpTitles.compareTo(a.mvpTitles);
        if (byMvp != 0) return byMvp;
        return b.stats.ratingAvg.compareTo(a.stats.ratingAvg);
      });

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: l10n.stats_leagueGoals),
              Tab(text: l10n.stats_leagueAssists),
              Tab(text: l10n.stats_leagueCleanSheets),
              Tab(text: l10n.stats_leagueMvp),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _rankedTable(
                  context,
                  l10n,
                  l10n.stats_leagueGoals,
                  goalsRows.take(15).toList(),
                  (row) => '${row.stats.goals}',
                ),
                _rankedTable(
                  context,
                  l10n,
                  l10n.stats_leagueAssists,
                  assistsRows.take(15).toList(),
                  (row) => '${row.stats.assists}',
                ),
                _rankedTable(
                  context,
                  l10n,
                  l10n.stats_leagueCleanSheets,
                  cleanSheetsRows.take(15).toList(),
                  (row) => '${row.stats.cleanSheets}',
                ),
                _rankedTable(
                  context,
                  l10n,
                  l10n.stats_leagueMvp,
                  mvpRows.take(15).toList(),
                  (row) => '${row.mvpTitles}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const double _rankColumnWidth = 68;
  static const double _statColumnWidth = 56;

  Widget _rankedTable(
    BuildContext context,
    AppLocalizations l10n,
    String statLabel,
    List<_LeaguePlayerRow> rows,
    String Function(_LeaguePlayerRow row) statValueOf,
  ) {
    if (rows.isEmpty) {
      return Center(child: Text(l10n.stats_seasonNotStarted));
    }

    final headerStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const SizedBox(width: _rankColumnWidth),
              const Expanded(child: SizedBox()),
              SizedBox(
                width: _statColumnWidth,
                child: Text(
                  statLabel,
                  textAlign: TextAlign.center,
                  style: headerStyle,
                ),
              ),
              SizedBox(
                width: _statColumnWidth,
                child: Text(
                  l10n.stats_rating,
                  textAlign: TextAlign.center,
                  style: headerStyle,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              return Card(
                child: ListTile(
                  leading: SizedBox(
                    width: _rankColumnWidth,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text('${index + 1}', textAlign: TextAlign.end),
                        ),
                        const SizedBox(width: 8),
                        TeamLogo(teamId: row.teamId, size: 28),
                      ],
                    ),
                  ),
                  title: Text(row.player.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: _statColumnWidth,
                        child: Text(
                          statValueOf(row),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: _statColumnWidth,
                        child: Text(
                          row.stats.ratingAvg.toStringAsFixed(2),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/game/player/${row.player.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<_LeaguePlayerRow> _leaguePlayerRows(LeagueState league) {
    final aggregates = _aggregateStats(league);
    final mvpCounts = _mvpCounts(league);
    return [
      for (final team in league.teams)
        for (final player in team.roster)
          if (aggregates.containsKey(player.id))
            _LeaguePlayerRow(
              player: player,
              teamId: team.id,
              stats: aggregates[player.id]!,
              mvpTitles: mvpCounts[player.id] ?? 0,
            ),
    ];
  }

  Map<String, int> _mvpCounts(LeagueState league) {
    final counts = <String, int>{};
    for (final result in _allSeasonResults(league)) {
      final id = result.manOfTheMatchPlayerId;
      if (id == null) continue;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, PlayerSeasonStats> _aggregateStats(LeagueState league) {
    final accumulators = <String, _StatsAccumulator>{};
    for (final result in _allSeasonResults(league)) {
      for (final stat in result.playerStats) {
        accumulators
            .putIfAbsent(stat.playerId, _StatsAccumulator.new)
            .add(stat);
      }
    }
    return {
      for (final entry in accumulators.entries)
        entry.key: entry.value.toStats(league.currentSeason.year),
    };
  }

  List<MatchResult> _allSeasonResults(LeagueState league) {
    final results = <MatchResult>[];
    final seen = <MatchResult>{};
    void add(MatchResult? result) {
      if (result != null && seen.add(result)) results.add(result);
    }

    for (final match in league.currentSeason.schedule) {
      add(match.result);
    }
    for (final progress in league.currentSeason.playInProgress) {
      add(progress.game7v8);
      add(progress.game9v10);
      add(progress.gameFinal);
    }
    for (final result in league.currentSeason.playInResults) {
      add(result.game7v8);
      add(result.game9v10);
      add(result.gameFinal);
    }
    for (final bracket in league.currentSeason.playoffBrackets) {
      for (final series in [
        ...bracket.quarterFinals,
        ...bracket.semiFinals,
        ...bracket.conferenceFinal,
        if (bracket.leagueFinal != null) bracket.leagueFinal!,
      ]) {
        for (final result in series.games) {
          add(result);
        }
      }
    }
    return results;
  }
}

class _StatsAccumulator {
  int minutes = 0;
  int goals = 0;
  int assists = 0;
  int appearances = 0;
  int yellowCards = 0;
  int redCards = 0;
  int shots = 0;
  int shotsOnTarget = 0;
  double xg = 0.0;
  int passes = 0;
  double passAccuracyWeighted = 0.0;
  int passAccuracyWeight = 0;
  int duelsWon = 0;
  int offsides = 0;
  int corners = 0;
  int tackles = 0;
  int interceptions = 0;
  int cleanSheets = 0;
  int saves = 0;
  int shotsFaced = 0;
  double ratingTotal = 0;
  int ratingWeight = 0;

  void add(PlayerMatchStats stat) {
    minutes += stat.minutes;
    goals += stat.goals;
    assists += stat.assists;
    appearances += stat.minutes > 0 ? 1 : 0;
    yellowCards += stat.yellowCards;
    redCards += stat.redCards;
    shots += stat.shots;
    shotsOnTarget += stat.shotsOnTarget;
    xg += stat.xg;
    passes += stat.passes;
    passAccuracyWeighted += stat.passAccuracy * stat.passes;
    passAccuracyWeight += stat.passes;
    duelsWon += stat.duelsWon;
    offsides += stat.offsides;
    corners += stat.corners;
    tackles += stat.tackles;
    interceptions += stat.interceptions;
    cleanSheets += stat.cleanSheet ? 1 : 0;
    saves += stat.saves;
    shotsFaced += stat.shotsFaced;
    final weight = stat.minutes > 0 ? stat.minutes : 1;
    ratingTotal += stat.rating * weight;
    ratingWeight += weight;
  }

  PlayerSeasonStats toStats(int year) => PlayerSeasonStats(
    year: year,
    minutes: minutes,
    goals: goals,
    assists: assists,
    appearances: appearances,
    yellowCards: yellowCards,
    redCards: redCards,
    shots: shots,
    shotsOnTarget: shotsOnTarget,
    xg: xg,
    passes: passes,
    passAccuracy: passAccuracyWeight == 0
        ? 0.0
        : passAccuracyWeighted / passAccuracyWeight,
    duelsWon: duelsWon,
    offsides: offsides,
    corners: corners,
    tackles: tackles,
    interceptions: interceptions,
    cleanSheets: cleanSheets,
    saves: saves,
    shotsFaced: shotsFaced,
    ratingAvg: ratingWeight == 0 ? 0 : ratingTotal / ratingWeight,
  );
}

class _PlayerStatsRow {
  const _PlayerStatsRow({required this.player, required this.stats});

  final Player player;
  final PlayerSeasonStats stats;
}

class _LeaguePlayerRow {
  const _LeaguePlayerRow({
    required this.player,
    required this.teamId,
    required this.stats,
    required this.mvpTitles,
  });

  final Player player;
  final String teamId;
  final PlayerSeasonStats stats;
  final int mvpTitles;
}
