import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

enum _StatsSort { ovr, goals, assists, rating }

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  final _searchController = TextEditingController();
  _StatsSort _sort = _StatsSort.ovr;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Scaffold(
        appBar: _appBar(context, l10n),
        body: Center(child: Text(l10n.stats_noStats)),
      );
    }
    return DefaultTabController(
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
              _playerStats(context, l10n, league),
              _teamOverview(context, l10n, league),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, AppLocalizations l10n) =>
      AppBar(title: Text(l10n.stats_title));

  Widget _playerStats(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final aggregates = _aggregateStats(league);
    final players = [
      for (final team in league.teams)
        for (final player in team.roster)
          if (aggregates.containsKey(player.id))
            _PlayerStatsRow(
              player: player,
              teamName: team.name,
              stats: aggregates[player.id]!,
            ),
    ];
    final query = _searchController.text.trim().toLowerCase();
    final filtered =
        players
            .where((row) => row.player.name.toLowerCase().contains(query))
            .toList()
          ..sort((a, b) {
            return switch (_sort) {
              _StatsSort.ovr => b.player.overall().compareTo(
                a.player.overall(),
              ),
              _StatsSort.goals => b.stats.goals.compareTo(a.stats.goals),
              _StatsSort.assists => b.stats.assists.compareTo(a.stats.assists),
              _StatsSort.rating => b.stats.ratingAvg.compareTo(
                a.stats.ratingAvg,
              ),
            };
          });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: l10n.stats_search,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<_StatsSort>(
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
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sort = value);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Card(child: ListTile(title: Text(l10n.stats_noStats)))
        else
          ...filtered.map((row) => _playerCard(context, l10n, row)),
      ],
    );
  }

  Map<String, PlayerSeasonStats> _aggregateStats(LeagueState league) {
    final accumulators = <String, _StatsAccumulator>{};
    for (final match in league.currentSeason.schedule) {
      final result = match.result;
      if (result == null) continue;
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

  Map<String, TeamMatchStats> _aggregateTeamStats(LeagueState league) {
    final accumulators = <String, _TeamStatsAccumulator>{};
    for (final match in league.currentSeason.schedule) {
      final result = match.result;
      if (result == null) continue;
      accumulators
          .putIfAbsent(
            result.homeStats.teamId,
            () => _TeamStatsAccumulator(result.homeStats.teamId),
          )
          .add(result.homeStats);
      accumulators
          .putIfAbsent(
            result.awayStats.teamId,
            () => _TeamStatsAccumulator(result.awayStats.teamId),
          )
          .add(result.awayStats);
    }
    return {
      for (final entry in accumulators.entries)
        entry.key: entry.value.toStats(),
    };
  }

  Widget _playerCard(
    BuildContext context,
    AppLocalizations l10n,
    _PlayerStatsRow row,
  ) {
    final stats = row.stats;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(row.player.position.code)),
            title: Text(row.player.name),
            subtitle: Text(
              '${row.teamName} · ${l10n.stats_appearances}: ${stats.appearances} · '
              '${l10n.stats_goals}: ${stats.goals} · ${l10n.stats_assists}: ${stats.assists}',
            ),
            trailing: Text(
              '${l10n.stats_rating}: ${stats.ratingAvg.toStringAsFixed(2)}',
            ),
            onTap: () => context.push('/game/player/${row.player.id}'),
          ),
          ExpansionTile(
            title: Text(l10n.stats_boxScore),
            children: [
              _statGrid([
                _StatLine(l10n.stats_appearances, '${stats.appearances}'),
                _StatLine(l10n.stats_minutes, '${stats.minutes}'),
                _StatLine(l10n.stats_goals, '${stats.goals}'),
                _StatLine(l10n.stats_assists, '${stats.assists}'),
                _StatLine(l10n.stats_shots, '${stats.shots}'),
                _StatLine(l10n.stats_shotsOnTarget, '${stats.shotsOnTarget}'),
                _StatLine(l10n.stats_xg, _formatDecimal(stats.xg)),
                _StatLine(l10n.stats_passes, '${stats.passes}'),
                _StatLine(
                  l10n.stats_passAccuracy,
                  _formatPercent(stats.passAccuracy),
                ),
                _StatLine(l10n.stats_duelsWon, '${stats.duelsWon}'),
                _StatLine(l10n.stats_offsides, '${stats.offsides}'),
                _StatLine(l10n.stats_corners, '${stats.corners}'),
                _StatLine(l10n.stats_tackles, '${stats.tackles}'),
                _StatLine(l10n.stats_interceptions, '${stats.interceptions}'),
                _StatLine(l10n.stats_cleanSheets, '${stats.cleanSheets}'),
                _StatLine(l10n.stats_saves, '${stats.saves}'),
                _StatLine(l10n.stats_shotsFaced, '${stats.shotsFaced}'),
                _StatLine(l10n.stats_yellowCards, '${stats.yellowCards}'),
                _StatLine(l10n.stats_redCards, '${stats.redCards}'),
                _StatLine(l10n.stats_rating, _formatDecimal(stats.ratingAvg)),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statGrid(List<_StatLine> lines) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount = constraints.maxWidth >= 520 ? 3 : 2;
          final width =
              (constraints.maxWidth - (columnCount - 1) * 12) / columnCount;
          return Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final line in lines)
                SizedBox(
                  width: width,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          line.label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        line.value,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _teamOverview(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final matchStats = _aggregateTeamStats(league);
    final entries = [
      for (final team in league.teams)
        _teamRow(league, team, matchStats[team.id]),
    ];
    entries.sort((a, b) => b.averageOvr.compareTo(a.averageOvr));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: entries
          .map(
            (row) => Card(
              child: ExpansionTile(
                leading: CircleAvatar(
                  child: Text(row.averageOvr.round().toString()),
                ),
                title: Text(row.team.name),
                subtitle: Text(
                  '${l10n.stats_record}: ${row.standing?.wins ?? 0}-${row.standing?.draws ?? 0}-${row.standing?.losses ?? 0} · '
                  '${l10n.stats_averageOvr}: ${row.averageOvr.toStringAsFixed(1)}'
                  '${row.matchStats == null ? '' : ' · ${l10n.stats_xg}: ${_formatDecimal(row.matchStats!.xg)}'}',
                ),
                children: [
                  ListTile(
                    title: Text(l10n.stats_roster),
                    trailing: Text('${row.team.roster.length}'),
                  ),
                  ListTile(
                    title: Text(l10n.stats_injured),
                    trailing: Text('${row.injured}'),
                  ),
                  ListTile(
                    title: Text(l10n.stats_payroll),
                    trailing: Text(
                      formatMoney(context, row.team.finance.totalPayroll),
                    ),
                  ),
                  ListTile(
                    title: Text(l10n.stats_atmosphere),
                    trailing: Text('${row.team.atmosphere}'),
                  ),
                  ListTile(
                    title: Text(l10n.stats_chemistry),
                    trailing: Text('${row.team.chemistry}'),
                  ),
                  if (row.matchStats != null)
                    ExpansionTile(
                      title: Text(l10n.stats_boxScore),
                      children: [
                        _statGrid([
                          _StatLine(
                            l10n.stats_goals,
                            '${row.matchStats!.goals}',
                          ),
                          _StatLine(
                            l10n.stats_shots,
                            '${row.matchStats!.shots}',
                          ),
                          _StatLine(
                            l10n.stats_shotsOnTarget,
                            '${row.matchStats!.shotsOnTarget}',
                          ),
                          _StatLine(
                            l10n.stats_xg,
                            _formatDecimal(row.matchStats!.xg),
                          ),
                          _StatLine(
                            l10n.stats_possession,
                            '${row.matchStats!.possession}%',
                          ),
                          _StatLine(
                            l10n.stats_passes,
                            '${row.matchStats!.passes}',
                          ),
                          _StatLine(
                            l10n.stats_passAccuracy,
                            _formatPercent(row.matchStats!.passAccuracy),
                          ),
                          _StatLine(
                            l10n.stats_duelsWon,
                            '${row.matchStats!.duelsWon}',
                          ),
                          _StatLine(
                            l10n.stats_offsides,
                            '${row.matchStats!.offsides}',
                          ),
                          _StatLine(
                            l10n.stats_corners,
                            '${row.matchStats!.corners}',
                          ),
                          _StatLine(
                            l10n.stats_fouls,
                            '${row.matchStats!.fouls}',
                          ),
                          _StatLine(
                            l10n.stats_yellowCards,
                            '${row.matchStats!.yellowCards}',
                          ),
                          _StatLine(
                            l10n.stats_redCards,
                            '${row.matchStats!.redCards}',
                          ),
                          _StatLine(
                            l10n.stats_saves,
                            '${row.matchStats!.saves}',
                          ),
                        ]),
                      ],
                    ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  _TeamOverviewRow _teamRow(
    LeagueState league,
    Team team,
    TeamMatchStats? matchStats,
  ) {
    Standing? standing;
    for (final conference in league.currentSeason.standings) {
      final found = conference.forTeam(team.id);
      if (found != null) standing = found;
    }
    final average = team.roster.isEmpty
        ? 0.0
        : team.roster.map((p) => p.overall()).reduce((a, b) => a + b) /
              team.roster.length;
    return _TeamOverviewRow(
      team: team,
      standing: standing,
      averageOvr: average,
      injured: team.roster.where((p) => p.state.injured).length,
      matchStats: matchStats,
    );
  }
}

String _formatDecimal(double value) => value.toStringAsFixed(2);

String _formatPercent(double value) => '${value.toStringAsFixed(1)}%';

class _StatLine {
  const _StatLine(this.label, this.value);

  final String label;
  final String value;
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

class _TeamStatsAccumulator {
  _TeamStatsAccumulator(this.teamId);

  final String teamId;
  int goals = 0;
  int shots = 0;
  int shotsOnTarget = 0;
  int possessionTotal = 0;
  double xg = 0.0;
  int passes = 0;
  double passAccuracyWeighted = 0.0;
  int passAccuracyWeight = 0;
  int duelsWon = 0;
  int offsides = 0;
  int corners = 0;
  int fouls = 0;
  int yellowCards = 0;
  int redCards = 0;
  int saves = 0;
  int matches = 0;

  void add(TeamMatchStats stats) {
    matches++;
    goals += stats.goals;
    shots += stats.shots;
    shotsOnTarget += stats.shotsOnTarget;
    possessionTotal += stats.possession;
    xg += stats.xg;
    passes += stats.passes;
    passAccuracyWeighted += stats.passAccuracy * stats.passes;
    passAccuracyWeight += stats.passes;
    duelsWon += stats.duelsWon;
    offsides += stats.offsides;
    corners += stats.corners;
    fouls += stats.fouls;
    yellowCards += stats.yellowCards;
    redCards += stats.redCards;
    saves += stats.saves;
  }

  TeamMatchStats toStats() => TeamMatchStats(
    teamId: teamId,
    goals: goals,
    shots: shots,
    shotsOnTarget: shotsOnTarget,
    possession: matches == 0 ? 0 : (possessionTotal / matches).round(),
    xg: xg,
    passes: passes,
    passAccuracy: passAccuracyWeight == 0
        ? 0.0
        : passAccuracyWeighted / passAccuracyWeight,
    duelsWon: duelsWon,
    offsides: offsides,
    corners: corners,
    fouls: fouls,
    yellowCards: yellowCards,
    redCards: redCards,
    saves: saves,
  );
}

class _PlayerStatsRow {
  const _PlayerStatsRow({
    required this.player,
    required this.teamName,
    required this.stats,
  });

  final Player player;
  final String teamName;
  final PlayerSeasonStats stats;
}

class _TeamOverviewRow {
  const _TeamOverviewRow({
    required this.team,
    required this.standing,
    required this.averageOvr,
    required this.injured,
    required this.matchStats,
  });

  final Team team;
  final Standing? standing;
  final double averageOvr;
  final int injured;
  final TeamMatchStats? matchStats;
}
