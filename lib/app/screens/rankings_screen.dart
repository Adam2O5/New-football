import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/theme/app_theme.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class RankingsScreen extends ConsumerWidget {
  const RankingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          appBar: AppBar(title: Text(l10n.rankings_title)),
          body: ScreenBackground(
            child: Center(child: Text(l10n.rankings_noData)),
          ),
        ),
      );
    }

    return _themed(
      useLegacyColorTheme,
      branding.primaryColor,
      branding.secondaryColor,
      DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.rankings_title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: l10n.rankings_teamRanking),
                Tab(text: l10n.rankings_tradePowerRanking),
                Tab(text: l10n.rankings_youngPlayersRanking),
                Tab(text: l10n.rankings_playersRanking),
              ],
            ),
          ),
          body: ScreenBackground(
            child: TabBarView(
              children: [
                _teamRankingTab(context, l10n, league),
                _tradePowerRankingTab(context, l10n, league),
                _youngPlayersRankingTab(context, l10n, league),
                _playersRankingTab(context, l10n, league),
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

  // ---------------------------------------------------------------------
  // Team ranking
  // ---------------------------------------------------------------------

  Widget _teamRankingTab(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final leagueRanks = _computeLeagueTableRanks(league);
    final rows =
        [
          for (final team in league.teams)
            _TeamRankingRow(
              team: team,
              leagueRank: leagueRanks[team.id],
              entry: league.strengthTable?.entryFor(team.id),
            ),
        ]..sort(
          (a, b) => (a.entry?.expectedRank ?? 999).compareTo(
            b.entry?.expectedRank ?? 999,
          ),
        );

    if (rows.isEmpty) return Center(child: Text(l10n.rankings_noData));

    return _table(
      columns: [
        DataColumn(label: Text(l10n.rankings_columnNumber)),
        DataColumn(label: Text(l10n.rankings_team)),
        DataColumn(
          label: Text(l10n.rankings_columnLeaguePosition),
          numeric: true,
        ),
        DataColumn(label: Text(l10n.rankings_status)),
        DataColumn(
          label: Text(l10n.rankings_columnProjectedPosition),
          numeric: true,
        ),
      ],
      rows: [
        for (var i = 0; i < rows.length; i++)
          DataRow(
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(_teamCell(rows[i].team)),
              DataCell(Text(rows[i].leagueRank?.toString() ?? '—')),
              DataCell(
                Text(
                  rows[i].entry == null
                      ? '—'
                      : _statusLabel(l10n, rows[i].entry!.teamStatus),
                ),
              ),
              DataCell(Text(rows[i].entry?.expectedRank.toString() ?? '—')),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Trade power ranking
  // ---------------------------------------------------------------------

  Widget _tradePowerRankingTab(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final currentYear = league.currentSeason.year;
    final rows = [
      for (final team in league.teams)
        _TradePowerRow(
          team: team,
          entry: league.strengthTable?.entryFor(team.id),
          totalPointValue: _teamAssetPointValueSum(team, currentYear),
        ),
    ]..sort((a, b) => b.totalPointValue.compareTo(a.totalPointValue));

    if (rows.isEmpty) return Center(child: Text(l10n.rankings_noData));

    return _table(
      columns: [
        DataColumn(label: Text(l10n.rankings_columnNumber)),
        DataColumn(label: Text(l10n.rankings_team)),
        DataColumn(label: Text(l10n.rankings_status)),
        DataColumn(
          label: Text(l10n.rankings_columnTotalPointValue),
          numeric: true,
        ),
      ],
      rows: [
        for (var i = 0; i < rows.length; i++)
          DataRow(
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(_teamCell(rows[i].team)),
              DataCell(
                Text(
                  rows[i].entry == null
                      ? '—'
                      : _statusLabel(l10n, rows[i].entry!.teamStatus),
                ),
              ),
              DataCell(Text('${rows[i].totalPointValue}')),
            ],
          ),
      ],
    );
  }

  /// Suma point value wszystkich assetów drużyny: zawodnicy z rosteru
  /// (`Player.computePointValue`) oraz posiadane picki draftowe
  /// (`DraftPick.computeTradeValue`). Prawa draftowe (`draftedRights`)
  /// celowo pominięte — decyzja z 04.09.2026.
  int _teamAssetPointValueSum(Team team, int currentYear) {
    var sum = 0;
    for (final player in team.roster) {
      sum += player.computePointValue();
    }
    for (final pick in team.ownedPicks) {
      sum += pick.computeTradeValue(currentYear: currentYear).toInt();
    }
    return sum;
  }

  // ---------------------------------------------------------------------
  // Young players ranking
  // ---------------------------------------------------------------------

  Widget _youngPlayersRankingTab(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final candidates = <_PlayerRankingRow>[];
    for (final team in league.teams) {
      for (final player in team.roster) {
        if (player.age < 18 || player.age > 21) continue;
        candidates.add(
          _PlayerRankingRow(
            team: team,
            player: player,
            sortValue: player.potentialStars * player.overall(),
          ),
        );
      }
    }
    candidates.sort((a, b) => b.sortValue.compareTo(a.sortValue));
    final top = candidates.take(30).toList();

    if (top.isEmpty) return Center(child: Text(l10n.rankings_noData));
    return _playerTable(l10n, top);
  }

  // ---------------------------------------------------------------------
  // Players ranking
  // ---------------------------------------------------------------------

  Widget _playersRankingTab(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final all = <_PlayerRankingRow>[];
    for (final team in league.teams) {
      for (final player in team.roster) {
        all.add(_PlayerRankingRow(team: team, player: player, sortValue: 0));
      }
    }
    all.sort((a, b) {
      final byOvr = b.player.overall().compareTo(a.player.overall());
      if (byOvr != 0) return byOvr;
      final byPotential = b.player.potentialStars.compareTo(
        a.player.potentialStars,
      );
      if (byPotential != 0) return byPotential;
      final byAge = a.player.age.compareTo(b.player.age);
      if (byAge != 0) return byAge;
      return b.player.computePointValue().compareTo(
        a.player.computePointValue(),
      );
    });
    final top = all.take(30).toList();

    if (top.isEmpty) return Center(child: Text(l10n.rankings_noData));
    return _playerTable(l10n, top);
  }

  Widget _playerTable(AppLocalizations l10n, List<_PlayerRankingRow> rows) {
    return _table(
      columns: [
        DataColumn(label: Text(l10n.rankings_columnNumber)),
        const DataColumn(label: Text('')),
        DataColumn(label: Text(l10n.rankings_columnPlayer)),
        DataColumn(label: Text(l10n.rankings_columnAge), numeric: true),
        DataColumn(label: Text(l10n.rankings_columnOvr), numeric: true),
        DataColumn(label: Text(l10n.rankings_columnPotential), numeric: true),
      ],
      rows: [
        for (var i = 0; i < rows.length; i++)
          DataRow(
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(TeamLogo(teamId: rows[i].team.id, size: 28)),
              DataCell(Text(rows[i].player.name)),
              DataCell(Text('${rows[i].player.age}')),
              DataCell(Text(rows[i].player.overall().round().toString())),
              DataCell(
                Text('${rows[i].player.potentialStars.toStringAsFixed(1)} ★'),
              ),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Wspólne elementy
  // ---------------------------------------------------------------------

  Widget _teamCell(Team team) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TeamLogo(teamId: team.id, size: 28),
        const SizedBox(width: 8),
        Text(team.name),
      ],
    );
  }

  Widget _table({
    required List<DataColumn> columns,
    required List<DataRow> rows,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(columns: columns, rows: rows),
      ),
    );
  }

  /// Miejsce w tabeli ligowej liczone globalnie (po wszystkich konferencjach
  /// łącznie), tak jak w `TeamOverviewScreen._computeOverallRanks` — punkty,
  /// przy remisie różnica bramek.
  Map<String, int> _computeLeagueTableRanks(LeagueState league) {
    final all =
        [
          for (final conference in league.currentSeason.standings)
            ...conference.standings,
        ]..sort((a, b) {
          final byPoints = b.points.compareTo(a.points);
          if (byPoints != 0) return byPoints;
          return b.goalDifference.compareTo(a.goalDifference);
        });
    return {for (var i = 0; i < all.length; i++) all[i].teamId: i + 1};
  }

  String _statusLabel(AppLocalizations l10n, TeamStatus status) =>
      switch (status) {
        TeamStatus.rebuild => l10n.rankings_statusRebuild,
        TeamStatus.retool => l10n.rankings_statusRetool,
        TeamStatus.pretender => l10n.rankings_statusPretender,
        TeamStatus.contender => l10n.rankings_statusContender,
        TeamStatus.elite => l10n.rankings_statusElite,
      };
}

class _TeamRankingRow {
  const _TeamRankingRow({
    required this.team,
    required this.leagueRank,
    required this.entry,
  });

  final Team team;
  final int? leagueRank;
  final TeamStrengthEntry? entry;
}

class _TradePowerRow {
  const _TradePowerRow({
    required this.team,
    required this.entry,
    required this.totalPointValue,
  });

  final Team team;
  final TeamStrengthEntry? entry;
  final int totalPointValue;
}

class _PlayerRankingRow {
  const _PlayerRankingRow({
    required this.team,
    required this.player,
    required this.sortValue,
  });

  final Team team;
  final Player player;
  final double sortValue;
}
