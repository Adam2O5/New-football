import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/theme/app_theme.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

enum _LeagueSort { ovr, leagueRank, expectedRank }

class TeamOverviewScreen extends ConsumerStatefulWidget {
  const TeamOverviewScreen({super.key});

  @override
  ConsumerState<TeamOverviewScreen> createState() => _TeamOverviewScreenState();
}

class _TeamOverviewScreenState extends ConsumerState<TeamOverviewScreen> {
  _LeagueSort _sort = _LeagueSort.ovr;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final activeTeamId = league?.playerTeamId;
    final useLegacyColorTheme = ref.watch(legacyColorThemeSettingProvider);
    final branding = ref
        .watch(clubBrandingProvider)
        .resolve(activeTeamId ?? '');

    if (league == null) {
      return _themed(
        useLegacyColorTheme,
        branding.primaryColor,
        branding.secondaryColor,
        _messageScaffold(
          context,
          l10n.teamOverview_title,
          l10n.teamOverview_noLeague,
        ),
      );
    }

    final team = activeTeamId == null ? null : league.teamById(activeTeamId);
    if (team == null) {
      return _themed(
        useLegacyColorTheme,
        branding.primaryColor,
        branding.secondaryColor,
        _messageScaffold(
          context,
          l10n.teamOverview_title,
          l10n.teamOverview_invalidTeam,
        ),
      );
    }

    final standings = _standingsFor(league, team.id);
    final strengthEntry = league.strengthTable?.entryFor(team.id);

    return _themed(
      useLegacyColorTheme,
      branding.primaryColor,
      branding.secondaryColor,
      DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.teamOverview_title),
            leading: IconButton(
              tooltip: l10n.common_cancel,
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            bottom: TabBar(
              tabs: [
                Tab(text: l10n.teamOverview_tabMyTeam),
                Tab(text: l10n.teamOverview_tabLeagueOverview),
              ],
            ),
          ),
          body: ScreenBackground(
            child: TabBarView(
              children: [
                _myTeamTab(context, l10n, team, standings, strengthEntry),
                _leagueOverviewTab(context, l10n, league),
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

  Widget _myTeamTab(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
    _TeamStandings standings,
    TeamStrengthEntry? strengthEntry,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _teamHeader(context, l10n, team),
        const SizedBox(height: 12),
        _sectionCard(
          context,
          title: l10n.teamOverview_standings,
          icon: Icons.leaderboard_outlined,
          children: [
            _valueRow(
              l10n.teamOverview_record,
              standings.standing == null
                  ? '—'
                  : '${standings.standing!.wins}-${standings.standing!.draws}-${standings.standing!.losses}',
            ),
            _valueRow(
              l10n.teamOverview_conferenceRank,
              standings.conferenceRank == null
                  ? '—'
                  : '#${standings.conferenceRank}',
            ),
            _valueRow(
              l10n.teamOverview_overallRank,
              standings.overallRank == null ? '—' : '#${standings.overallRank}',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionCard(
          context,
          title: l10n.teamOverview_financials,
          icon: Icons.account_balance_wallet_outlined,
          children: [
            _valueRow(
              l10n.teamOverview_payroll,
              formatMoney(context, team.finance.totalPayroll),
            ),
            _valueRow(
              l10n.teamOverview_cap,
              formatMoney(context, team.finance.salaryCap),
            ),
            _valueRow(
              l10n.teamOverview_capSpace,
              formatMoney(
                context,
                team.finance.salaryCap - team.finance.totalPayroll,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionCard(
          context,
          title: l10n.teamOverview_teamState,
          icon: Icons.groups_outlined,
          children: [
            _valueRow(l10n.teamOverview_atmosphere, '${team.atmosphere}'),
            _valueRow(
              l10n.teamOverview_chemistry,
              team.chemistry.toStringAsFixed(1),
            ),
            _valueRow(
              l10n.teamOverview_teamPower,
              strengthEntry?.teamPower.toStringAsFixed(2) ?? '—',
            ),
            _valueRow(
              l10n.teamOverview_expectedRank,
              strengthEntry == null ? '—' : '#${strengthEntry.expectedRank}',
            ),
            _valueRow(
              l10n.teamOverview_status,
              strengthEntry?.teamStatus.name ?? '—',
            ),
            _valueRow(l10n.teamOverview_roster, '${team.roster.length}'),
            _valueRow(l10n.teamOverview_staff, '${team.staff.members.length}'),
          ],
        ),
      ],
    );
  }

  Widget _leagueOverviewTab(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final matchStats = _aggregateTeamStats(league);
    final overallRanks = _computeOverallRanks(league);
    final entries = [
      for (final team in league.teams)
        _teamRow(league, team, matchStats[team.id], overallRanks[team.id]),
    ];
    entries.sort((a, b) {
      switch (_sort) {
        case _LeagueSort.ovr:
          return b.averageOvr.compareTo(a.averageOvr);
        case _LeagueSort.leagueRank:
          return (a.overallRank ?? 999).compareTo(b.overallRank ?? 999);
        case _LeagueSort.expectedRank:
          return (a.expectedRank ?? 999).compareTo(b.expectedRank ?? 999);
      }
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(l10n.stats_sort),
            const SizedBox(width: 8),
            DropdownButton<_LeagueSort>(
              value: _sort,
              items: [
                DropdownMenuItem(
                  value: _LeagueSort.ovr,
                  child: Text(l10n.stats_sortOvr),
                ),
                DropdownMenuItem(
                  value: _LeagueSort.leagueRank,
                  child: Text(l10n.teamOverview_sortLeagueRank),
                ),
                DropdownMenuItem(
                  value: _LeagueSort.expectedRank,
                  child: Text(l10n.teamOverview_expectedRank),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sort = value);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...entries.map((row) => _teamOverviewCard(context, l10n, row)),
      ],
    );
  }

  Widget _teamOverviewCard(
    BuildContext context,
    AppLocalizations l10n,
    _TeamOverviewRow row,
  ) {
    return Card(
      child: ExpansionTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TeamLogo(teamId: row.team.id, size: 36),
            const SizedBox(width: 8),
            CircleAvatar(child: Text(row.averageOvr.round().toString())),
          ],
        ),
        title: Text(row.team.name),
        subtitle: Text(
          '${l10n.stats_record}: ${row.standing?.wins ?? 0}-${row.standing?.draws ?? 0}-${row.standing?.losses ?? 0}',
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
            trailing: Text(formatMoney(context, row.team.finance.totalPayroll)),
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
                  _StatLine(l10n.stats_goals, '${row.matchStats!.goals}'),
                  _StatLine(l10n.stats_shots, '${row.matchStats!.shots}'),
                  _StatLine(
                    l10n.stats_shotsOnTarget,
                    '${row.matchStats!.shotsOnTarget}',
                  ),
                  _StatLine(l10n.stats_xg, _formatDecimal(row.matchStats!.xg)),
                  _StatLine(
                    l10n.stats_possession,
                    '${row.matchStats!.possession}%',
                  ),
                  _StatLine(l10n.stats_passes, '${row.matchStats!.passes}'),
                  _StatLine(
                    l10n.stats_passAccuracy,
                    _formatPercent(row.matchStats!.passAccuracy),
                  ),
                  _StatLine(l10n.stats_duelsWon, '${row.matchStats!.duelsWon}'),
                  _StatLine(l10n.stats_offsides, '${row.matchStats!.offsides}'),
                  _StatLine(l10n.stats_corners, '${row.matchStats!.corners}'),
                  _StatLine(l10n.stats_fouls, '${row.matchStats!.fouls}'),
                  _StatLine(
                    l10n.stats_yellowCards,
                    '${row.matchStats!.yellowCards}',
                  ),
                  _StatLine(l10n.stats_redCards, '${row.matchStats!.redCards}'),
                  _StatLine(l10n.stats_saves, '${row.matchStats!.saves}'),
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

  Widget _teamHeader(BuildContext context, AppLocalizations l10n, Team team) {
    return Card(
      child: ListTile(
        leading: TeamLogo(teamId: team.id, size: 40),
        title: Text(team.name, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(
          '${team.city} · ${l10n.teamOverview_conference(_conferenceLabel(l10n, team.conference))}',
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _valueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Scaffold _messageScaffold(
    BuildContext context,
    String title,
    String message,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          tooltip: AppLocalizations.of(context)!.common_cancel,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenBackground(child: Center(child: Text(message))),
    );
  }

  _TeamStandings _standingsFor(LeagueState league, String teamId) {
    Standing? standing;
    int? conferenceRank;
    for (final conference in league.currentSeason.standings) {
      final found = conference.forTeam(teamId);
      if (found == null) continue;
      standing = found;
      final sorted = conference.sorted;
      final index = sorted.indexWhere((entry) => entry.teamId == teamId);
      conferenceRank = index < 0 ? null : index + 1;
    }

    final overallRanks = _computeOverallRanks(league);
    return _TeamStandings(
      standing: standing,
      conferenceRank: conferenceRank,
      overallRank: overallRanks[teamId],
    );
  }

  Map<String, int> _computeOverallRanks(LeagueState league) {
    final overall =
        [
          for (final conference in league.currentSeason.standings)
            ...conference.standings,
        ]..sort((a, b) {
          final byPoints = b.points.compareTo(a.points);
          if (byPoints != 0) return byPoints;
          return b.goalDifference.compareTo(a.goalDifference);
        });
    return {for (var i = 0; i < overall.length; i++) overall[i].teamId: i + 1};
  }

  Map<String, TeamMatchStats> _aggregateTeamStats(LeagueState league) {
    final accumulators = <String, _TeamStatsAccumulator>{};
    for (final result in _allSeasonResults(league)) {
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

  _TeamOverviewRow _teamRow(
    LeagueState league,
    Team team,
    TeamMatchStats? matchStats,
    int? overallRank,
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
      overallRank: overallRank,
      expectedRank: league.strengthTable?.entryFor(team.id)?.expectedRank,
    );
  }

  String _conferenceLabel(AppLocalizations l10n, Conference conference) =>
      switch (conference) {
        Conference.europe => l10n.teamOverview_conferenceEurope,
        Conference.restOfTheWorld => l10n.teamOverview_conferenceRestOfWorld,
      };
}

String _formatDecimal(double value) => value.toStringAsFixed(2);

String _formatPercent(double value) => '${value.toStringAsFixed(1)}%';

class _StatLine {
  const _StatLine(this.label, this.value);

  final String label;
  final String value;
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

class _TeamStandings {
  const _TeamStandings({
    required this.standing,
    required this.conferenceRank,
    required this.overallRank,
  });

  final Standing? standing;
  final int? conferenceRank;
  final int? overallRank;
}

class _TeamOverviewRow {
  const _TeamOverviewRow({
    required this.team,
    required this.standing,
    required this.averageOvr,
    required this.injured,
    required this.matchStats,
    required this.overallRank,
    required this.expectedRank,
  });

  final Team team;
  final Standing? standing;
  final double averageOvr;
  final int injured;
  final TeamMatchStats? matchStats;
  final int? overallRank;
  final int? expectedRank;
}
