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

    final year = league.currentSeason.year;
    final players =
        [
          for (final player in team.roster)
            if (_seasonStatsOf(player, year) case final stats?)
              _PlayerStatsRow(player: player, stats: stats),
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
        final byMvp = b.stats.motmCount.compareTo(a.stats.motmCount);
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
                  (row) => '${row.stats.motmCount}',
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
    final year = league.currentSeason.year;
    return [
      for (final team in league.teams)
        for (final player in team.roster)
          if (_seasonStatsOf(player, year) case final stats?)
            _LeaguePlayerRow(player: player, teamId: team.id, stats: stats),
    ];
  }

  /// Null for a player without a single appearance this season — the same
  /// filter the old per-match aggregation applied by omitting the key.
  PlayerSeasonStats? _seasonStatsOf(Player player, int year) {
    for (final season in player.seasonStats) {
      if (season.year == year) return season;
    }
    return null;
  }
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
  });

  final Player player;
  final String teamId;
  final PlayerSeasonStats stats;
}
