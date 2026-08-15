import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/league_state.dart';
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

  Widget _playerCard(
    BuildContext context,
    AppLocalizations l10n,
    _PlayerStatsRow row,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(row.player.position.code)),
        title: Text(row.player.name),
        subtitle: Text(
          '${row.teamName} · ${l10n.stats_appearances}: ${row.stats.appearances} · '
          '${l10n.stats_goals}: ${row.stats.goals} · ${l10n.stats_assists}: ${row.stats.assists}',
        ),
        trailing: Text(
          '${l10n.stats_rating}: ${row.stats.ratingAvg.toStringAsFixed(2)}',
        ),
        onTap: () => context.push('/game/player/${row.player.id}'),
      ),
    );
  }

  Widget _teamOverview(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final entries = [for (final team in league.teams) _teamRow(league, team)];
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
                  '${l10n.stats_averageOvr}: ${row.averageOvr.toStringAsFixed(1)}',
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
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  _TeamOverviewRow _teamRow(LeagueState league, Team team) {
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
    );
  }
}

class _StatsAccumulator {
  int minutes = 0;
  int goals = 0;
  int assists = 0;
  int appearances = 0;
  int yellowCards = 0;
  int redCards = 0;
  int tackles = 0;
  int interceptions = 0;
  int saves = 0;
  double ratingTotal = 0;
  int ratingWeight = 0;

  void add(PlayerMatchStats stat) {
    minutes += stat.minutes;
    goals += stat.goals;
    assists += stat.assists;
    appearances += stat.minutes > 0 ? 1 : 0;
    yellowCards += stat.yellowCards;
    redCards += stat.redCards;
    tackles += stat.tackles;
    interceptions += stat.interceptions;
    saves += stat.saves;
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
    tackles: tackles,
    interceptions: interceptions,
    saves: saves,
    ratingAvg: ratingWeight == 0 ? 0 : ratingTotal / ratingWeight,
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
  });

  final Team team;
  final Standing? standing;
  final double averageOvr;
  final int injured;
}
